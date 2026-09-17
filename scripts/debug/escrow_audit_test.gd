extends SceneTree

# ★★★escrow 對帳不變量（B-v0）——★systems 問的「誰負責發現存根與實貨分歧」的答案。
#
# ★`mkt.escrow.partial` 抓的是【發生的那一刻】，而分歧是【持續狀態】：
#   ★★一個沒有對帳不變量的權威搬家，分歧會【靜默累積】。
#
# ★★★判準形狀（systems 收下的）：【`checked > 0` 且三個分歧都 0】——
#   ★而不是只寫【三個分歧都 0】：`checked == 0` 時那三個 0 是【沒東西可比】不是【沒有分歧】。
#
# ★★而三種分歧【分開造、分開斷言】，因為處置完全不同：
#   orphan_escrow 貨卡死 ／ orphan_stub 賣家被騙 ／ qty_mismatch 要決定信誰

var _fail: int = 0
const EXPECTED_CELLS: Array = ["_run"]

# ★★★【到場點名】（systems 派工；本支的格【藏在 `_run` 裡】而橫幅印在 `_initialize`）——
#   ★實測（2026-09-18）：讓 `_run` 中途死掉 ⇒ **`=== DONE === ALL PASS` 照印、rc=0**
#     ⇒ ★★「跑完了」與「死在一半」在畫面上一模一樣。
#   ★★★這一支的點名粒度只能是 `_run`（格是 inline 的）——
#     **1／1 看起來很小，但它守的正是那個洞**：`_run` 沒跑完 ⇒ 0／1 ⇒ 橫幅變 FAIL。
#   ★用法必須是 `_selftest_gate("格名").noop()`（死亡要發生在那一格自己的 frame 裡）。
var _cells_ran: Array = []

func _cell(name: String) -> void:
	if not _cells_ran.has(name):
		_cells_ran.append(name)

func noop() -> void:
	pass

func _selftest_gate(cell: String) -> Object:
	if OS.get_environment("BED_SELFTEST_DIE") != cell:
		return self
	print("[SELFTEST] ★故意讓 `%s` 這一格在中途死掉" % cell)
	return null

func _roll_call_missing() -> Array:
	var missing: Array = []
	for c in EXPECTED_CELLS:
		if not _cells_ran.has(c): missing.append(c)
	if not missing.is_empty():
		print("[roll-call] ❌ ★**有格沒有跑完**：%s —— 執行期錯誤會靜默中止一支 func，而那看起來像綠" % str(missing))
	return missing
func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else: _fail += 1; print("  [FAIL] %s" % m)

func _initialize() -> void:
	_run()
	var _miss: Array = _roll_call_missing()
	var _suffix: String = "｜到場點名 %d／%d" % [_cells_ran.size(), EXPECTED_CELLS.size()]
	if _fail == 0 and _miss.is_empty(): print("=== DONE === ALL PASS%s" % _suffix)
	else: print("=== DONE === %d FAIL%s" % [_fail + _miss.size(), _suffix])
	quit()

func _mk() -> WorldState:
	var s: WorldState = MeasureBedHelper.arm_and_new()
	return s

func _tile(s: WorldState, pos: Vector2i, owner: int) -> HexTileData:
	var t := HexTileData.new()
	t.tile_pos = pos; t.outpost_level = 1; t.outpost_owner = owner
	s.world.tiles[pos.x * 1000 + pos.y] = t
	return t

func _team(s: WorldState, tid: int) -> TeamData:
	var t := TeamData.new(); t.team_id = tid
	s.teams[tid] = t
	return t

func _run() -> void:
	_selftest_gate("_run").noop()
	# ── ①一致：存根與實貨對得上 ⇒ 三個分歧都 0，而 checked > 0 ──
	var s1 := _mk()
	var t1 := _tile(s1, Vector2i(1, 1), 9)
	var m1 := _team(s1, 5)
	m1.active_orders.append({"order_id": 7, "kind": "sell", "res": "food",
		"qty_remaining": 10, "escrowed": true})
	t1.market_escrow[7] = {"res": "food", "qty": 10.0, "owner_team": 5, "since_tick": 0}
	var r1: Dictionary = OrderSystem.audit_escrow(s1)
	_ok(int(r1["checked"]) > 0 and int(r1["orphan_escrow"]) == 0
		and int(r1["orphan_stub"]) == 0 and int(r1["qty_mismatch"]) == 0,
		"①一致：checked=%d 且三個分歧都 0（★judged 形狀是【checked>0 且三個都 0】）" % int(r1["checked"]))

	# ── ②orphan_escrow：貨在市場、存根不見了 ⇒【貨永遠沒有人來領】──
	var s2 := _mk()
	var t2 := _tile(s2, Vector2i(1, 1), 9)
	_team(s2, 5)   # ★存根【故意不建】
	t2.market_escrow[7] = {"res": "food", "qty": 10.0, "owner_team": 5, "since_tick": 0}
	var r2: Dictionary = OrderSystem.audit_escrow(s2)
	_ok(int(r2["orphan_escrow"]) == 1 and int(r2["orphan_stub"]) == 0,
		"②orphan_escrow=1（實得 %d）—— ★貨卡死：市場有貨而沒有人的存根指向它" % int(r2["orphan_escrow"]))

	# ── ③orphan_stub：存根說 escrowed、市場沒貨 ⇒【賣家以為自己還有貨在賣】──
	var s3 := _mk()
	_tile(s3, Vector2i(1, 1), 9)
	var m3 := _team(s3, 5)
	m3.active_orders.append({"order_id": 7, "kind": "sell", "res": "food",
		"qty_remaining": 10, "escrowed": true})
	var r3: Dictionary = OrderSystem.audit_escrow(s3)
	_ok(int(r3["orphan_stub"]) == 1 and int(r3["orphan_escrow"]) == 0,
		"③orphan_stub=1（實得 %d）—— ★賣家被騙：他的存根說貨在賣，而市場沒有" % int(r3["orphan_stub"]))

	# ── ④qty_mismatch：兩邊都在、數量不同 ⇒【要決定信誰】（權威在 tile）──
	var s4 := _mk()
	var t4 := _tile(s4, Vector2i(1, 1), 9)
	var m4 := _team(s4, 5)
	m4.active_orders.append({"order_id": 7, "kind": "sell", "res": "food",
		"qty_remaining": 10, "escrowed": true})
	t4.market_escrow[7] = {"res": "food", "qty": 4.0, "owner_team": 5, "since_tick": 0}
	var r4: Dictionary = OrderSystem.audit_escrow(s4)
	_ok(int(r4["qty_mismatch"]) == 1,
		"④qty_mismatch=1（實得 %d）—— ★要決定信誰，而權威在 tile" % int(r4["qty_mismatch"]))

	# ── ⑤★★★母體塌陷不得偽裝成通過 ──
	var s5 := _mk()
	_tile(s5, Vector2i(1, 1), 9)
	_team(s5, 5)   # 沒有任何 escrow、也沒有任何存根
	var r5: Dictionary = OrderSystem.audit_escrow(s5)
	_ok(int(r5["checked"]) == 0 and int(r5["orphan_escrow"]) == 0,
		"⑤空世界：checked=0 且分歧 0 —— ★★★而【那不是通過】：判準要求 checked>0")
	print("     ★沒有這條，一個【什麼都沒有的世界】會讓「三個分歧都 0」永遠成立，")
	print("        ★★而那正是「儀器裝好但沒接電」在【判準層】的長相。")

	# ── ⑥★接電證明：`audit_escrow` 真的被【production 以外的東西】呼叫過 ──
	print("     ★★★而本測本身就是 `audit_escrow` 的 caller —— ★它先前【零 caller】（systems 實測抓到），")
	print("        而【儀器裝好但沒接電】是既有 memory 裡的第 6 型。")
	Probe.enabled = false
	_cell("_run")
