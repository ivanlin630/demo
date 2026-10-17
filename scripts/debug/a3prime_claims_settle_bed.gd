extends SceneTree
# @bed-kind: invariant
# ══ 票 A3′：待領資產在本人站上那個市集的那一刻結清（任何市集、任何任務）═══════════════════════
# spec：`docs/superpowers/specs/2026-10-07-a3prime-claims-settle-when-owner-stands-on-the-market-HOW.md` §2
#
# ★走真入口：抵達＝`SimRunner._step3c_read_market_board(state, [tid])`；產生＝真的撮合（resolver 吃寄賣單）與真的到期退貨
# 格：P2 非貿易抵達（巡邏）⇒ 同 tick 結清；★反向：同格別隊的待領不動
#     P3 站著產生：寄賣者站在市集上、別人吃了它的寄賣單 ⇒ 同 tick 款進 coin、tile 上不留它的條目；
#        P3b 同一形狀換成到期退貨（`order_system.gd` release_order_escrow 那個呼叫點）
#     P4 一次：TRADE＋承諾領取抵達別人市集且有待領 ⇒ 結清恰 1 次、「領取|格」落空記號 0
#     P5 守恆（逐格）：帳本 claim_coin／claim_goods 的 delta 總和 ＝ 條目 amt 總和
#     P6 `_claim_pending_here(` 的呼叫者只有 claim_on_arrival 與 add_pending_claim（排除註解、宣告）
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/a3prime_claims_settle_bed.gd

var _errors: int = 0
var _cells_ran: Array = []
const EXPECTED_CELLS: Array = ["P2", "P3", "P3b", "P4", "P5", "P6"]
const AMT: float = 7.0
var _ledger_sum: float = 0.0
var _entry_sum: float = 0.0


func _initialize() -> void:
	print("=== a3prime_claims_settle：待領在本人站上市集那一刻結清 ===")
	WorldState.driver_ledger_enabled = true
	_p2_non_trade_arrival()
	_p3_standing_escrow_fill()
	_p3b_standing_escrow_expire()
	_p4_trade_arrival_once()
	_p5_conservation()
	_p6_single_settle_point()
	WorldState.driver_ledger_enabled = false
	var missing: Array = []
	for c in EXPECTED_CELLS:
		if not _cells_ran.has(String(c)):
			missing.append(String(c))
	_check("★到場點名：%d／%d（缺：%s）" % [_cells_ran.size(), EXPECTED_CELLS.size(), str(missing)], missing.is_empty())
	print("\n=== a3prime_claims_settle DONE === errors: %d" % _errors)
	quit(1 if _errors > 0 else 0)


func _check(msg: String, cond: bool) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_errors += 1
		push_error("[FAIL] " + msg)


func _mk_world() -> WorldState:
	seed(1337)
	var ws: WorldState = MeasureBedHelper.arm_and_setup("res://config/default.json", true)
	WorldState.clear_driver_ledger()
	return ws


# 有主市集格＋owner 以外的兩支非野獸隊
func _pick(ws: WorldState) -> Array:
	var ids: Array = ws.world.tiles.keys()
	ids.sort()
	for k in ids:
		var tile: HexTileData = ws.world.tiles[k]
		if tile.outpost_level <= 0 or not ws.teams.has(tile.outpost_owner):
			continue
		var others: Array = []
		var tids: Array = ws.teams.keys()
		tids.sort()
		for t in tids:
			var tt: TeamData = ws.teams[t]
			if int(t) != tile.outpost_owner and tt.beast_kind == "" and tt.parent_team_id == -1:
				others.append(tt)
			if others.size() >= 2:
				return [tile, ws.teams[tile.outpost_owner], others[0], others[1]]
	return []


func _ledger_delta(ws: WorldState, team: TeamData, reasons: Array) -> float:
	var s: float = 0.0
	for e in WorldState.driver_ledger:
		var ent = e["entity"]
		if ent is TeamData and (ent as TeamData).team_id == team.team_id and reasons.has(String(e["reason"])):
			s += float(e["delta"])
	return s


func _mine(tile: HexTileData, tid: int) -> float:
	var s: float = 0.0
	for c in tile.pending_claims:
		if int(c.get("owner_team", -1)) == tid:
			s += float(c.get("amt", 0.0))
	return s


# ══ P2 ═══════════════════════════════════════════════════════════════════════════════════════════
func _p2_non_trade_arrival() -> void:
	print("\n── P2 帶非貿易任務（巡邏）抵達有自己待領的市集 ⇒ 同 tick 結清；別隊的不動 ──")
	var ws: WorldState = _mk_world()
	var pk: Array = _pick(ws)
	_check("★母體地板：找得到有主市集＋兩支別隊", not pk.is_empty())
	if pk.is_empty():
		_cells_ran.append("P2")
		return
	var tile: HexTileData = pk[0]
	var a: TeamData = pk[2]
	var b: TeamData = pk[3]
	tile.pending_claims.append({"owner_team": a.team_id, "kind": "goods", "res": "material", "amt": AMT, "since_tick": 0})
	tile.pending_claims.append({"owner_team": b.team_id, "kind": "coin", "res": "coin", "amt": AMT, "since_tick": 0})
	a.tile_pos = tile.tile_pos
	a.move_target = Vector2i(-1, -1)
	a.current_task = TeamData.TASK_PATROL
	a.current_option = "巡邏"
	b.tile_pos = Vector2i(-50, -50)   # ★b 不在場
	var m0: float = float(a.resources.get("material", 0.0))
	SimRunner.new()._step3c_read_market_board(ws, [a.team_id])
	var m1: float = float(a.resources.get("material", 0.0))
	print("   %s｜Team%d task=%s material %.1f → %.1f｜自己的待領剩 %.1f｜Team%d（不在場）的待領剩 %.1f" % [
		str(tile.tile_pos), a.team_id, a.current_task, m0, m1, _mine(tile, a.team_id), b.team_id, _mine(tile, b.team_id)])
	_check("★★★P2 巡邏抵達 ⇒ material +%.1f" % AMT, is_equal_approx(m1 - m0, AMT))
	_check("★★P2 自己的條目清掉", _mine(tile, a.team_id) == 0.0)
	_check("★★P2【反向】別隊（不在場）的待領不動（%.1f）" % _mine(tile, b.team_id), is_equal_approx(_mine(tile, b.team_id), AMT))
	_ledger_sum += _ledger_delta(ws, a, ["claim_coin", "claim_goods"])
	_entry_sum += AMT
	_cells_ran.append("P2")


# ══ P3 ═══════════════════════════════════════════════════════════════════════════════════════════
# 佈置：寄賣者 x 在 owner 的市集寄賣糧（escrow），人留在那一格；訪客 v 帶貿易抵達、吃那張單 ⇒ 款進待領 ⇒ x 在場 ⇒ 當場結清
func _p3_standing_escrow_fill() -> void:
	print("\n── P3 站著產生：寄賣者站在市集上、別人吃了它的寄賣單 ⇒ 同 tick 款進 coin ──")
	var ws: WorldState = _mk_world()
	var pk: Array = _pick(ws)
	if pk.is_empty():
		_check("★母體地板：找得到有主市集＋兩支別隊", false)
		_cells_ran.append("P3")
		return
	var tile: HexTileData = pk[0]
	var x: TeamData = pk[2]
	var v: TeamData = pk[3]
	x.tile_pos = tile.tile_pos
	x.move_target = Vector2i(-1, -1)
	x.current_task = TeamData.TASK_IDLE
	x.resources["food"] = 40.0
	var oid: int = OrderSystem.new().post_order(ws, x, "sell", "food", 12)
	var esc: Dictionary = (tile.market_escrow.get(oid, {}) as Dictionary).duplicate()   # ★複本：撮合會就地改同一個 dict
	print("   佈置：Team%d 在 Team%d 的市集 %s 寄賣糧，押貨 %s；人留在格上" % [x.team_id, tile.outpost_owner, str(tile.tile_pos), str(esc)])
	_check("★母體地板：真押貨（escrow 路）", float(esc.get("qty", 0.0)) > 0.0)
	v.tile_pos = tile.tile_pos
	v.move_target = tile.tile_pos
	v.current_task = TeamData.TASK_TRADE
	v.current_option = "貿易"
	v.resources["coin"] = 500.0
	v.resources["food"] = 0.0
	var c0: float = float(x.resources.get("coin", 0.0))
	var a0: float = float(Probe.amounts.get("mkt.claim.added.coin", 0.0))
	WorldState.clear_driver_ledger()
	SimRunner.new()._step3c_read_market_board(ws, [v.team_id])
	var c1: float = float(x.resources.get("coin", 0.0))
	var claimed: float = _ledger_delta(ws, x, ["claim_coin"])
	var added: float = float(Probe.amounts.get("mkt.claim.added.coin", 0.0)) - a0   # ★這一次撮合進待領的款（＝訪客吃單付的錢）
	var esc2: Dictionary = tile.market_escrow.get(oid, {})
	print("   Team%d 吃單後：押貨剩 %s｜進待領 %.2f｜Team%d 帳本 claim_coin %+.2f｜coin %.2f → %.2f（★含同格 peer 交易，不拿來判）｜tile 上它的條目 %.2f" % [
		v.team_id, str(esc2), added, x.team_id, claimed, c0, c1, _mine(tile, x.team_id)])
	_check("★母體地板：訪客真的吃到寄賣單（押貨變少、進待領 %.2f > 0）" % added, float(esc2.get("qty", 0.0)) < float(esc.get("qty", 0.0)) and added > 0.0)
	_check("★★★P3 同 tick 款進 team.coin：帳本 claim_coin %+.2f ＝ 進待領 %.2f" % [claimed, added], added > 0.0 and is_equal_approx(claimed, added))
	_check("★★★P3 tile.pending_claims 不留它的條目（%.2f）" % _mine(tile, x.team_id), _mine(tile, x.team_id) == 0.0)
	_ledger_sum += claimed
	_entry_sum += added
	_cells_ran.append("P3")


func _p3b_standing_escrow_expire() -> void:
	print("\n── P3b 站著產生（到期退貨）：寄賣單到期、本人站在格上 ⇒ 貨當場回到手上 ──")
	var ws: WorldState = _mk_world()
	var pk: Array = _pick(ws)
	if pk.is_empty():
		_check("★母體地板：找得到有主市集＋兩支別隊", false)
		_cells_ran.append("P3b")
		return
	var tile: HexTileData = pk[0]
	var x: TeamData = pk[2]
	x.tile_pos = tile.tile_pos
	x.move_target = Vector2i(-1, -1)
	x.resources["food"] = 40.0
	var oid: int = OrderSystem.new().post_order(ws, x, "sell", "food", 12)
	var f0: float = float(x.resources.get("food", 0.0))
	var exp1: int = -1
	for o in x.active_orders:
		if int(o.get("order_id", -1)) == oid:
			exp1 = int(o.get("expire_tick", -1))
	_check("★母體地板：寄賣單有到期 tick", exp1 > 0)
	ws.world.current_tick = exp1
	WorldState.clear_driver_ledger()
	OrderSystem.new().tick_team_orders(ws, x)
	var f1: float = float(x.resources.get("food", 0.0))
	var got: float = _ledger_delta(ws, x, ["claim_goods"])
	print("   到期後：Team%d food %.1f → %.1f（帳本 claim_goods %+.1f）｜tile 上它的條目 %.1f｜押貨 %s" % [
		x.team_id, f0, f1, got, _mine(tile, x.team_id), str(tile.market_escrow.get(oid, {}))])
	_check("★★★P3b 到期退貨當場回到手上（food %+.1f ＝ 12）" % (f1 - f0), is_equal_approx(f1 - f0, 12.0) and is_equal_approx(got, 12.0))
	_check("★★P3b tile 上不留它的條目", _mine(tile, x.team_id) == 0.0)
	_ledger_sum += got
	_entry_sum += 12.0
	_cells_ran.append("P3b")


# ══ P4 ═══════════════════════════════════════════════════════════════════════════════════════════
func _p4_trade_arrival_once() -> void:
	print("\n── P4 TRADE＋承諾領取抵達別人市集 ⇒ 結清恰 1 次、落空記號 0 ──")
	var ws: WorldState = _mk_world()
	var pk: Array = _pick(ws)
	if pk.is_empty():
		_check("★母體地板：找得到有主市集＋兩支別隊", false)
		_cells_ran.append("P4")
		return
	var tile: HexTileData = pk[0]
	var a: TeamData = pk[2]
	tile.pending_claims.append({"owner_team": a.team_id, "kind": "coin", "res": "coin", "amt": AMT, "since_tick": 0})
	a.tile_pos = tile.tile_pos
	a.move_target = tile.tile_pos
	a.current_task = TeamData.TASK_TRADE
	a.current_option = "領取"   # ★承諾領取：resolver 若再結一次（第二次必空）就會記落空 ⇒ 這一格才分得出「兩次」
	var t0: int = int(Probe.counts.get("mkt.claim.taken", 0))
	WorldState.clear_driver_ledger()
	SimRunner.new()._step3c_read_market_board(ws, [a.team_id])
	var n: int = int(Probe.counts.get("mkt.claim.taken", 0)) - t0
	var k: String = FailureMemory.key("領取", str(tile.tile_id))
	var got: float = _ledger_delta(ws, a, ["claim_coin"])
	print("   mkt.claim.taken +%d｜帳本 claim_coin %+.2f｜recent_failures 有「%s」＝ %s" % [n, got, k, str(a.recent_failures.has(k))])
	_check("★★★P4 結清恰 1 次（%d）" % n, n == 1)
	_check("★★★P4「領取」落空記號 0", not a.recent_failures.has(k))
	_check("★★P4 領到的就是那一筆（%+.2f）" % got, is_equal_approx(got, AMT))
	_ledger_sum += got
	_entry_sum += AMT
	_cells_ran.append("P4")


# ══ P5 ═══════════════════════════════════════════════════════════════════════════════════════════
func _p5_conservation() -> void:
	print("\n── P5 守恆：上面各格帳本 claim_* delta 總和 ＝ 條目 amt 總和 ──")
	print("   帳本 %.3f｜條目 %.3f" % [_ledger_sum, _entry_sum])
	_check("★★P5 帳本＝條目（逐格累加；世界級對帳在 a3prime_claim_census）", _entry_sum > 0.0 and absf(_ledger_sum - _entry_sum) < 0.001)
	_cells_ran.append("P5")


# ══ P6 ═══════════════════════════════════════════════════════════════════════════════════════════
func _p6_single_settle_point() -> void:
	print("\n── P6 _claim_pending_here 的呼叫者 ──")
	var hits: Array = []
	var dir := DirAccess.open("res://scripts/simulation")
	var files: Array = []
	_collect(dir, "res://scripts/simulation", files)
	for f in files:
		var lines: PackedStringArray = FileAccess.get_file_as_string(f).split("\n")
		var fn: String = ""
		for i in range(lines.size()):
			var raw: String = lines[i]
			var l: String = raw.strip_edges()
			if l.begins_with("static func ") or l.begins_with("func "):
				fn = l.split("(")[0].replace("static func ", "").replace("func ", "")
			if l.begins_with("#") or l.contains("func _claim_pending_here"):
				continue
			if l.split("#")[0].contains("_claim_pending_here("):
				hits.append("%s:%d(%s)" % [f.get_file(), i + 1, fn])
	print("   呼叫點：%s" % str(hits))
	var fns: Array = []
	for h in hits:
		fns.append(String(h).split("(")[1].trim_suffix(")"))
	fns.sort()
	_check("★★P6 呼叫者只有 add_pending_claim、claim_on_arrival（%s）" % str(fns), fns == ["add_pending_claim", "claim_on_arrival"])
	_cells_ran.append("P6")


func _collect(dir: DirAccess, path: String, out: Array) -> void:
	if dir == null:
		return
	dir.list_dir_begin()
	var n: String = dir.get_next()
	while n != "":
		if dir.current_is_dir():
			if not n.begins_with("."):
				_collect(DirAccess.open(path + "/" + n), path + "/" + n, out)
		elif n.ends_with(".gd"):
			out.append(path + "/" + n)
		n = dir.get_next()
	dir.list_dir_end()
