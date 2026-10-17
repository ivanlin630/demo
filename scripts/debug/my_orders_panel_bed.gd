extends SceneTree
# @bed-kind: acceptance
# slice: 我的掛單與押貨（只讀；spec 2026-10-15-my-orders-and-escrow-readonly-HOW）
# ★格（修前紅：P1／E1／E2）：
#   P1  NPC 隊在別人市集寄賣糧 12（真押貨），走真實 sync_possession 邊附身 ⇒ 情報頁「待領 糧食 ×12｜在 (q,r)」（押貨那格）、
#       事件流一則 goods_returned(why=possession)；同格另一隊的待領不列
#   P2  API 掛寄賣單 ⇒「押在 (q,r)｜還有 N 天…到期」，N＝(expire−now) 換算；撥鐘一天 ⇒ N 少一天
#   P3  三種位置字：押在／掛在 … 自家市集／沒上板
#   E1  到期 ⇒ goods_returned(why=expire)、待領列出現、掛單列消失
#   E2  API 撤單 ⇒ goods_returned(why=cancel)
#   E3  單格待領糧 12＋錢 3、到場 ⇒ goods_claimed 恰一則、句子含兩種資源各自的量；待領列消失、存量＋12、錢＋3
#   E4  NPC 不喚醒：不附身、單到期 ⇒ 同 tick 內 pending_rethink 不含該 NPC 隊（clear 後直接呼、當場讀）
#   E5  同勢力 NPC 單到期 ⇒ 匯流排零則 goods_returned
#   CAP 8 筆不同（格、種類、資源）的待領 ⇒ 5 列＋「另有 3 筆」
#   SCAN 情報頁查詢的全圖掃描時間（只記錄，不判）

const EXPECTED: Array = ["P1", "P2", "P3", "E1", "E2", "E3", "E4", "E5", "CAP", "SCAN"]
const SEED: int = 20261015
const X: int = 940   # NPC 寄賣隊
const Y: int = 941   # 市集主
var _errors: int = 0
var _present: Dictionary = {}

func _initialize() -> void:
	print("=== my_orders_panel：我的掛單與押貨 ===")
	_p1()
	_p2_p3_e1_e2()
	_e3()
	_e4_e5()
	_cap_scan()
	var miss: Array = []
	for c in EXPECTED:
		if not _present.has(c):
			miss.append(c)
	if not miss.is_empty():
		_check("到場點名缺 %s" % str(miss), false)
	print("=== my_orders_panel DONE === 到場 %d／%d errors: %d" % [_present.size(), EXPECTED.size(), _errors])
	quit(1 if _errors > 0 else 0)

func _check(msg: String, cond: bool) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_errors += 1
		push_error("[FAIL] " + msg)

func _cell(c: String) -> void:
	_present[c] = true

func _world() -> WorldState:
	seed(SEED)
	return MeasureBedHelper.arm_and_setup("res://config/default.json", false)

func _pt(st: WorldState) -> TeamData:
	return st.teams[st.get_player_team_id()]

static func _free_tile(st: WorldState, avoid: Array) -> HexTileData:
	for k in st.world.tiles:
		var t: HexTileData = st.world.tiles[k]
		if t.outpost_level == 0 and t.pending_claims.is_empty() and not avoid.has(t.tile_pos):
			return t
	return null

# 一支隊（帶隊長）
func _team(st: WorldState, tid: int, pos: Vector2i, food: float) -> TeamData:
	var t := TeamData.new()
	t.team_id = tid
	t.faction_id = -1
	t.tile_pos = pos
	var p := PersonData.new()
	p.id = tid * 10 + 1
	p.team_id = tid
	p.person_name = "隊長%d" % tid
	st.persons[p.id] = p
	t.leader_id = p.id
	AnonTierSystem.add_anon(t, AnonCohort.TIER_PLEB, 3)
	t.resources["food"] = food
	st.teams[tid] = t
	return t

# Y 在 tile 上開一個市集（別人的據點 ⇒ 站在上面掛賣單＝寄賣、真押貨）
func _market(st: WorldState, owner: TeamData, tile: HexTileData) -> void:
	tile.outpost_level = 1
	tile.outpost_type = "civilian"
	OutpostOwnerBank.set_owner(st, tile, owner.team_id, "bed")

static func _intel(st: WorldState) -> Array:
	var env: Dictionary = PlayerQueryApi.new().query_memory_panel(st)
	return TextUiMain.intel_lines(env.get("data", {}), st.world.current_tick, st)

static func _section(lines: Array) -> Array:
	var out: Array = []
	var on: bool = false
	for l in lines:
		if String(l).begins_with("── "):
			on = String(l).contains("我的掛單與待領")
			continue
		if on:
			out.append(String(l).strip_edges())
	return out

static func _events(st: WorldState, kind: String, seq0: int) -> Array:
	return st.player_events.filter(func(e): return String(e.get("kind", "")) == kind and int(e.get("seq", 0)) > seq0)

# ── P1 ───────────────────────────────────────────────────────────────────────
func _p1() -> void:
	print("\n── P1 附身撤單 ⇒ 待領列＋事件 ──")
	var st: WorldState = _world()
	var tile: HexTileData = _free_tile(st, [_pt(st).tile_pos])
	var y: TeamData = _team(st, Y, tile.tile_pos, 10.0)
	_market(st, y, tile)
	var x: TeamData = _team(st, X, tile.tile_pos, 30.0)
	var oid: int = OrderSystem.new().post_order(st, x, "sell", "food", 12)
	# ★A3′：本人站在市集上 ⇒ 待領當場結清（不留待領列）⇒ 掛完單 X、Y 都離場，量的是「外地寄賣」那一型
	x.tile_pos = _pt(st).tile_pos
	y.tile_pos = _pt(st).tile_pos
	var esc: Dictionary = tile.market_escrow.get(oid, {})
	print("   佈置：Team%d 在 Team%d 的市集 (%d,%d) 寄賣糧 12，押貨 %s" % [X, Y, tile.tile_pos.x, tile.tile_pos.y, str(esc)])
	_check("P1 佈置：真押貨 12", float(esc.get("qty", 0)) == 12.0)
	InteractionSystem.add_pending_claim(st, tile, "goods", "material", 5.0, Y, st.world.current_tick)   # 同格別隊的待領（n3）
	var seq0: int = st.player_event_seq
	st.player_id = x.leader_id
	st.sync_possession()   # ★真實的附身邊（先撤單、後設 possessed）
	var sec: Array = _section(_intel(st))
	var ev: Array = _events(st, "goods_returned", seq0)
	print("   情報頁第五類 %s｜事件 %s" % [str(sec), str(ev.map(func(e): return String(e.get("text", ""))))])
	var want: String = "待領 糧食 ×12｜在 (%d,%d)" % [tile.tile_pos.x, tile.tile_pos.y]
	_check("P1 情報頁有「%s」、不列同格別隊的待領" % want, sec.size() == 1 and String(sec[0]).begins_with(want))
	_check("P1 事件流一則 goods_returned（why=possession）",
		ev.size() == 1 and String((ev[0]["info"] as Dictionary).get("why", "")) == "possession" and String(ev[0]["text"]).contains("附身時撤下隊上的單"))
	_cell("P1")

# ── P2／P3／E1／E2 ───────────────────────────────────────────────────────────
func _p2_p3_e1_e2() -> void:
	print("\n── P2／P3 掛單列、E1 到期、E2 撤單 ──")
	var st: WorldState = _world()
	var pt: TeamData = _pt(st)
	ResourceBank.set_amt(pt, "food", 200.0, "bed")
	ResourceBank.set_amt(pt, "material", 200.0, "bed")
	var api := PlayerCommandApi.new()
	# 押在：站在別人的市集
	var mt: HexTileData = _free_tile(st, [pt.tile_pos])
	var y: TeamData = _team(st, Y, mt.tile_pos, 10.0)
	_market(st, y, mt)
	var home: Vector2i = pt.tile_pos
	pt.tile_pos = mt.tile_pos
	var r1: Dictionary = api.post_sell_order(st, "food", 12)
	var oid1: int = int(r1.get("data", r1).get("order_id", r1.get("order_id", -1))) if r1.has("data") else int(r1.get("order_id", -1))
	if oid1 < 0:
		for o in pt.active_orders: oid1 = int(o.get("order_id", -1))
	var sec: Array = _section(_intel(st))
	var line1: String = String(sec[0]) if not sec.is_empty() else ""
	var rem: int = int(pt.active_orders[0].get("expire_tick", 0)) - st.world.current_tick
	var nd: int = rem / WorldState.TICKS_PER_DAY
	print("   P2 %s｜剩 %d tick ⇒ %d 天" % [line1, rem, nd])
	st.world.current_tick += WorldState.TICKS_PER_DAY
	var line1b: String = String(_section(_intel(st))[0])
	print("   P2 撥鐘一天 ⇒ %s" % line1b)
	_check("P2 掛單列「押在 (q,r)｜還有 %d 天…到期」；撥鐘一天 ⇒ %d 天" % [nd, nd - 1],
		line1.begins_with("賣 糧食 ×12｜押在 (%d,%d)｜還有 %d 天" % [mt.tile_pos.x, mt.tile_pos.y, nd]) and line1b.contains("還有 %d 天" % (nd - 1)))
	_cell("P2")
	# 掛在自家市集：玩家在自己的據點上掛（自家櫃檯不押貨）
	var ot: HexTileData = _free_tile(st, [mt.tile_pos, home])
	_market(st, pt, ot)
	pt.tile_pos = ot.tile_pos
	api.post_sell_order(st, "material", 7)
	# 沒上板：玩家沒有任何據點的情況改用一支新世界（避免自家市集）
	var st2: WorldState = _world()
	var pt2: TeamData = _pt(st2)
	ResourceBank.set_amt(pt2, "food", 50.0, "bed")
	for k in st2.world.tiles:
		var tt: HexTileData = st2.world.tiles[k]
		if tt.outpost_owner == pt2.team_id:
			OutpostOwnerBank.set_owner(st2, tt, -1, "bed")
	PlayerCommandApi.new().post_sell_order(st2, "food", 4)
	var sec_all: Array = _section(_intel(st))
	var sec2: Array = _section(_intel(st2))
	print("   P3 %s｜%s" % [str(sec_all), str(sec2)])
	var has_board: bool = sec_all.any(func(l): return String(l).begins_with("賣 木材 ×7｜掛在 (%d,%d) 自家市集" % [ot.tile_pos.x, ot.tile_pos.y]) \
		or String(l).contains("×7｜掛在 (%d,%d) 自家市集" % [ot.tile_pos.x, ot.tile_pos.y]))
	_check("P3 三種位置字：押在、掛在 … 自家市集、沒上板（只靠碰面傳出去）",
		sec_all.any(func(l): return String(l).contains("押在 (")) and has_board
		and sec2.any(func(l): return String(l).contains("沒上板（只靠碰面傳出去）")))
	_cell("P3")
	# E1 到期：糧那張單撥到 expire
	var seq0: int = st.player_event_seq
	var exp1: int = 0
	for o in pt.active_orders:
		if String(o.get("res", "")) == "food": exp1 = int(o.get("expire_tick", 0))
	st.world.current_tick = exp1
	OrderSystem.new().tick_team_orders(st, pt)
	var ev1: Array = _events(st, "goods_returned", seq0)
	var sec_e1: Array = _section(_intel(st))
	print("   E1 事件 %s｜第五類 %s" % [str(ev1.map(func(e): return String(e.get("text", "")))), str(sec_e1)])
	_check("E1 到期 ⇒ goods_returned(why=expire)、待領列出現、糧那張掛單列消失",
		ev1.size() >= 1 and String((ev1[0]["info"] as Dictionary).get("why", "")) == "expire"
		and sec_e1.any(func(l): return String(l).begins_with("待領 糧食 ×12｜在 (%d,%d)" % [mt.tile_pos.x, mt.tile_pos.y]))
		and not sec_e1.any(func(l): return String(l).begins_with("賣 糧食")))
	_cell("E1")
	# E2 撤單：在別人市集再掛一張木材（押貨）然後撤
	pt.tile_pos = mt.tile_pos
	api.post_sell_order(st, "material", 3)
	var oid_m: int = -1
	for o in pt.active_orders:
		if String(o.get("res", "")) == "material" and bool(o.get("escrowed", false)): oid_m = int(o.get("order_id", -1))
	var seq1: int = st.player_event_seq
	var rc: Dictionary = api.cancel_order(st, oid_m)
	var ev2: Array = _events(st, "goods_returned", seq1)
	print("   E2 撤 #%d ⇒ %s｜事件 %s" % [oid_m, str(rc.get("ok", rc)), str(ev2.map(func(e): return String(e.get("text", ""))))])
	_check("E2 API 撤單 ⇒ goods_returned(why=cancel)", oid_m != -1 and ev2.size() == 1 and String((ev2[0]["info"] as Dictionary).get("why", "")) == "cancel")
	_cell("E2")

# ── E3 到場領回 ──────────────────────────────────────────────────────────────
func _e3() -> void:
	print("\n── E3 到場領回 ──")
	var st: WorldState = _world()
	var pt: TeamData = _pt(st)
	var tile: HexTileData = _free_tile(st, [pt.tile_pos])
	InteractionSystem.add_pending_claim(st, tile, "goods", "food", 12.0, pt.team_id, st.world.current_tick)
	InteractionSystem.add_pending_claim(st, tile, "coin", "coin", 3.0, pt.team_id, st.world.current_tick)
	var f0: float = float(pt.resources.get("food", 0))
	var c0: float = float(pt.resources.get("coin", 0))
	var before: Array = _section(_intel(st))
	pt.tile_pos = tile.tile_pos
	var seq0: int = st.player_event_seq
	InteractionSystem.claim_on_arrival(st, pt, tile)
	var ev: Array = _events(st, "goods_claimed", seq0)
	var after: Array = _section(_intel(st))
	print("   E3 前 %s｜事件 %s｜後 %s｜糧 %+.1f 錢 %+.1f" % [str(before), str(ev.map(func(e): return String(e.get("text", "")))), str(after),
		float(pt.resources.get("food", 0)) - f0, float(pt.resources.get("coin", 0)) - c0])
	var txt: String = String(ev[0].get("text", "")) if ev.size() == 1 else ""
	_check("E3 goods_claimed 恰一則、句含「糧食 ×12」與「錢 ×3」；待領列消失、糧＋12、錢＋3",
		ev.size() == 1 and txt.contains("糧食 ×12") and txt.contains("錢 ×3") and before.size() == 2 and after == ["尚無"]
		and absf(float(pt.resources.get("food", 0)) - f0 - 12.0) < 0.001 and absf(float(pt.resources.get("coin", 0)) - c0 - 3.0) < 0.001)
	_cell("E3")

# ── E4／E5 NPC 不喚醒、同勢力不進匯流排 ─────────────────────────────────────────
func _e4_e5() -> void:
	print("\n── E4／E5 NPC 單到期 ──")
	for same_faction in [false, true]:
		var st: WorldState = _world()
		var pt: TeamData = _pt(st)
		var tile: HexTileData = _free_tile(st, [pt.tile_pos])
		var y: TeamData = _team(st, Y, tile.tile_pos, 10.0)
		_market(st, y, tile)
		var x: TeamData = _team(st, X, tile.tile_pos, 30.0)
		if same_faction:
			if pt.faction_id == -1:
				st.create_faction(pt.team_id)
			st.set_team_faction(x, pt.faction_id, WorldState.JOIN_SETUP)
		OrderSystem.new().post_order(st, x, "sell", "food", 12)
		x.tile_pos = pt.tile_pos   # ★A3′：本人在場會當場領回 ⇒ 離場，量「退貨落格」那一型
		var exp1: int = int(x.active_orders[0].get("expire_tick", 0))
		st.world.current_tick = exp1
		var seq0: int = st.player_event_seq
		st.pending_rethink.clear()
		OrderSystem.new().tick_team_orders(st, x)
		var woke: bool = st.pending_rethink.has(X)   # ★當場讀（跑完整個 tick 會被 consume_and_clear 清空而恆綠）
		var ev: Array = _events(st, "goods_returned", seq0)
		var claimed: bool = false
		for c in tile.pending_claims:
			if int(c.get("owner_team", -1)) == X and String(c.get("res", "")) == "food": claimed = true
		print("   %s：退貨落格 %s｜pending_rethink 含 Team%d=%s｜玩家匯流排 goods_returned %d 則" % [
			"同勢力" if same_faction else "獨立", str(claimed), X, str(woke), ev.size()])
		if not same_faction:
			_check("E4 NPC 單到期（退貨落格 %s）⇒ 同 tick pending_rethink 不含該 NPC 隊" % str(claimed), claimed and not woke)
			_cell("E4")
		else:
			_check("E5 同勢力 NPC 單到期 ⇒ 匯流排零則 goods_returned", claimed and ev.is_empty())
			_cell("E5")

# ── CAP／SCAN ────────────────────────────────────────────────────────────────
func _cap_scan() -> void:
	print("\n── CAP 每類上限、SCAN 掃描時間 ──")
	var st: WorldState = _world()
	var pt: TeamData = _pt(st)
	var used: Array = [pt.tile_pos]
	var ress: Array = ["food", "material", "tools", "medicine"]
	var n: int = 0
	while n < 8:
		var t: HexTileData = _free_tile(st, used)
		used.append(t.tile_pos)
		InteractionSystem.add_pending_claim(st, t, "goods", String(ress[n % ress.size()]), 2.0, pt.team_id, n)
		n += 1
	var sec: Array = _section(_intel(st))
	print("   CAP %s" % str(sec))
	_check("CAP 8 筆不同（格、種類、資源）的待領 ⇒ %d 列＋「另有 3 筆」" % UiPages.INTEL_ROWS_PER_KIND,
		sec.size() == UiPages.INTEL_ROWS_PER_KIND + 1 and String(sec.back()) == TextUiMain.INTEL_MORE_FMT % 3)
	_cell("CAP")
	var api := PlayerQueryApi.new()
	var best: int = 1 << 30
	var worst: int = 0
	for i in range(20):
		var t0: int = Time.get_ticks_usec()
		api.query_memory_panel(st)
		var dt: int = Time.get_ticks_usec() - t0
		best = mini(best, dt)
		worst = maxi(worst, dt)
	var t1: int = Time.get_ticks_usec()
	for i in range(20):
		PlayerQueryApi.my_orders(st, pt)
	var only_scan: int = (Time.get_ticks_usec() - t1) / 20
	print("   SCAN 地圖 %d 格｜query_memory_panel 一次 %d～%d µs｜其中 my_orders（全圖掃待領）平均 %d µs（只記錄）" % [
		st.world.tiles.size(), best, worst, only_scan])
	_cell("SCAN")
