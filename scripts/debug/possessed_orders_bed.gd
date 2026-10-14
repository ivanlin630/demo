extends SceneTree
# @bed-kind: invariant
# 附身隊後續 甲（spec 2026-10-13-possessed-team-followups-HOW §甲）：AI 不替附身隊掛買賣單（不變量 #12 的 orders）
#   A1  附身隊與非附身隊同樣塞滿餘貨、推 1 天 ⇒ 附身隊新增 AI 單 0；非附身隊 >0（同床對照：條件真的會觸發掛單）
#   A1b 直呼 tick_team_orders（cadence 不論）⇒ 附身隊 0 張、非附身隊 >0
#   A2  附身前先有一張寄賣（押貨）AI 單 ⇒ 附身那一刻撤下（殘單量測任一資源扣住 >20% ⇒ 撤；同一條 release_order_escrow 守恆路）、
#       押貨進待領帳；押貨帳對帳零違反、貨總量守恆
#       ★訂單沒有來源欄 ⇒「AI 單」由床在附身【之前】直接呼 post_order 造；驗收不宣稱分得出來源
#   A3  玩家自己的掛單（player_command_api.post_sell_order → post_order）照常成立
#   負對照：拿掉 order_system.tick_team_orders 的 possessed return ⇒ A1／A1b 紅；拿掉 sync_possession 的撤單 ⇒ A2 紅
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/possessed_orders_bed.gd

const SEED: int = 1337
const SURPLUS: float = 400.0

var _errors: int = 0


func _check(label: String, ok: bool) -> void:
	if ok:
		print("  PASS: " + label)
	else:
		_errors += 1
		push_error("[FAIL] " + label)


func _initialize() -> void:
	print("=== possessed_orders：AI 不替附身隊掛單；到期退貨與玩家自己的單照舊 ===")
	_a1_real_day()
	_a1b_direct()
	_a2_expiry_returns()
	_a3_player_order()
	print("=== possessed_orders DONE === errors: %d" % _errors)
	quit(1 if _errors > 0 else 0)


func _world() -> WorldState:
	seed(SEED)
	var st := WorldState.new()
	GameSetup.setup(st, GameSetup.load_config("res://config/default.json"))
	return st


# 一支有領袖、非玩家、非野獸的 NPC 隊（對照組）
func _npc_team(st: WorldState) -> TeamData:
	var ptid: int = st.get_player_team_id()
	var ids: Array = st.teams.keys()
	ids.sort()
	for tid in ids:
		var t: TeamData = st.teams[tid]
		if int(tid) == ptid or t.leader_id == -1 or t.possessed or t.beast_kind != "":
			continue
		return t
	return null


func _stuff(t: TeamData) -> void:
	ResourceBank.set_amt(t, "goods", float(t.resources.get("goods", 0.0)) + SURPLUS, "bed_seed")


# 新單（order_id ≥ oid0）累計：逐 tick 收，免得一天內成交消失的單漏數
func _collect_new(t: TeamData, oid0: int, seen: Dictionary) -> void:
	for o in t.active_orders:
		var oid: int = int(o.get("order_id", -1))
		if oid >= oid0:
			seen[oid] = "%s %s" % [String(o.get("kind", "")), String(o.get("res", ""))]


func _a1_real_day() -> void:
	print("\n── A1 推 1 天：附身隊 0 張新 AI 單；非附身隊 >0 ──")
	var st: WorldState = _world()
	var pt: TeamData = st.teams[st.get_player_team_id()]
	var nt: TeamData = _npc_team(st)
	_check("★母體地板：玩家隊 possessed＝真、對照隊存在且非附身", pt.possessed and nt != null and not nt.possessed)
	if nt == null:
		return
	_stuff(pt)
	_stuff(nt)
	var oid0: int = st.next_order_id
	var seen_p: Dictionary = {}
	var seen_n: Dictionary = {}
	var runner := SimRunner.new()
	for i in range(WorldState.TICKS_PER_DAY):
		var p: TeamData = st.teams.get(st.get_player_team_id())
		runner.advance_tick(st, p.tile_pos if p != null else Vector2i(-1, -1))
		if st.encounter_active:
			runner._encounter_system.resolve_encounter_end(st, "draw")
		_collect_new(pt, oid0, seen_p)
		_collect_new(nt, oid0, seen_n)
	print("   附身隊 T%d 新單 %d %s｜對照 T%d 新單 %d %s" % [pt.team_id, seen_p.size(), str(seen_p.values()),
		nt.team_id, seen_n.size(), str(seen_n.values())])
	_check("A1 附身隊推 1 天：新增 AI 單 0", seen_p.is_empty())
	_check("A1 對照：非附身隊同條件 >0（條件真的會觸發掛單）", seen_n.size() > 0)


func _a1b_direct() -> void:
	print("\n── A1b 直呼 tick_team_orders：附身隊 0；非附身隊 >0 ──")
	var st: WorldState = _world()
	var pt: TeamData = st.teams[st.get_player_team_id()]
	var nt: TeamData = _npc_team(st)
	if nt == null:
		_check("★對照隊存在", false)
		return
	_stuff(pt)
	_stuff(nt)
	var np0: int = pt.active_orders.size()
	var nn0: int = nt.active_orders.size()
	var os_ := OrderSystem.new()
	os_.tick_team_orders(st, pt)
	os_.tick_team_orders(st, nt)
	print("   附身隊 %d→%d｜對照 %d→%d" % [np0, pt.active_orders.size(), nn0, nt.active_orders.size()])
	_check("A1b 附身隊：tick_team_orders 不掛新單", pt.active_orders.size() == np0)
	_check("A1b 對照：非附身隊掛了單", nt.active_orders.size() > nn0)


# 找一格別隊擁有的據點（寄賣才押貨）
func _foreign_outpost(st: WorldState, tid: int) -> HexTileData:
	var ids: Array = st.world.tiles.keys()
	ids.sort()
	for k in ids:
		var t: HexTileData = st.world.tiles[k]
		if t.outpost_level > 0 and t.outpost_owner >= 0 and t.outpost_owner != tid:
			return t
	return null


func _goods_total(st: WorldState, pt: TeamData, tile: HexTileData) -> float:
	var s: float = float(pt.resources.get("goods", 0.0))
	for oid in tile.market_escrow:
		var e: Dictionary = tile.market_escrow[oid]
		if int(e.get("owner_team", -1)) == pt.team_id and String(e.get("res", "")) == "goods":
			s += float(e.get("qty", 0.0))
	for c in tile.pending_claims:
		var d: Dictionary = c
		if int(d.get("owner_team", -1)) == pt.team_id and String(d.get("kind", "")) == "goods" and String(d.get("res", "")) == "goods":
			s += float(d.get("amt", 0.0))
	return s


func _a2_expiry_returns() -> void:
	print("\n── A2 附身前的寄賣單：附身那一刻撤下（殘單量測 >20% 線）、押貨落待領、押貨帳零違反、貨總量守恆 ──")
	var st: WorldState = _world()
	var pt: TeamData = st.teams[st.get_player_team_id()]
	var tile: HexTileData = _foreign_outpost(st, pt.team_id)
	if tile == null:
		_check("★母體地板：地圖上有別隊據點可寄賣", false)
		return
	pt.tile_pos = tile.tile_pos
	_stuff(pt)
	# 附身前：解除附身 ⇒ 用 post_order 造一張 AI 單（寄賣押貨）
	var pid: int = st.player_id
	st.player_id = -1
	st.sync_possession()
	var os_ := OrderSystem.new()
	var oid: int = os_.post_order(st, pt, "sell", "goods", 10)
	var o: Dictionary = {}
	for x in pt.active_orders:
		if int(x.get("order_id", -1)) == oid:
			o = x
	var esc_before: float = float((tile.market_escrow.get(oid, {}) as Dictionary).get("qty", 0.0))
	var before: float = _goods_total(st, pt, tile)
	var aud0: Dictionary = OrderSystem.audit_escrow(st)   # ★附身前：母體非空（checked>0）才算對過帳
	_check("★母體地板：附身前那張單真的押了貨（escrowed）、對帳母體非空且零違反",
		bool(o.get("escrowed", false)) and esc_before > 0.0 and not pt.possessed and int(aud0["checked"]) > 0 and _clean(aud0))
	# 附身（sync_possession 的 false→true 邊）
	st.player_id = pid
	st.sync_possession()
	var after: float = _goods_total(st, pt, tile)
	var still: bool = false
	for x in pt.active_orders:
		if int(x.get("order_id", -1)) == oid:
			still = true
	var aud: Dictionary = OrderSystem.audit_escrow(st)
	print("   押貨 %.1f｜附身後 possessed=%s 單還在=%s｜押貨帳還在=%s｜貨總量 %.1f→%.1f｜audit 前 %s 後 %s" % [esc_before, str(pt.possessed),
		str(still), str(tile.market_escrow.has(oid)), before, after, str(aud0), str(aud)])
	_check("A2 附身那一刻：AI 殘單撤下、押貨移出", pt.possessed and not still and not tile.market_escrow.has(oid))
	_check("A2 貨總量守恆（隊上＋押貨＋待領）", absf(after - before) < 0.01)
	_check("A2 撤後押貨帳對帳零違反（checked=%d：這張單已出帳，0 是預期）" % int(aud["checked"]), _clean(aud))
	os_.tick_team_orders(st, pt)
	_check("A2 附身隊 tick_team_orders 之後沒有新的 AI 單", pt.active_orders.is_empty())


func _clean(a: Dictionary) -> bool:
	return int(a["orphan_escrow"]) == 0 and int(a["orphan_stub"]) == 0 and int(a["qty_mismatch"]) == 0


func _a3_player_order() -> void:
	print("\n── A3 玩家自己的掛單照常 ──")
	var st: WorldState = _world()
	var pt: TeamData = st.teams[st.get_player_team_id()]
	_stuff(pt)
	var r: Dictionary = PlayerCommandApi.new().post_sell_order(st, "goods", 5)
	var oid: int = int((r.get("payload", {}) as Dictionary).get("order_id", -1))
	var found: bool = false
	for x in pt.active_orders:
		if int(x.get("order_id", -1)) == oid and oid >= 0:
			found = true
	print("   回傳 %s｜附身隊 active_orders 有那張=%s" % [str(r), str(found)])
	_check("A3 玩家 post_sell_order 成立、單在附身隊上", found)
