extends SceneTree

# ★★★世界級排程「到期比較」的等價性測（`modulo-same-shape-4`，systems 裁 (b)）
#
# ★這支要證的【不是】「新寫法會 fire」，是【新寫法與舊寫法 fire 在同一組 tick 上】——
#   ★★因為對比輪正在跑兩顆固定 commit，fp 一動，measurer 已交出去的兩格就跟後面八格
#     【不在同一個世界】。⇒ ★★★所以判準是【等價】不是【有效】。
#
# ★★而第二條判準才是這張票【買到的東西】：外層 cadence 不整除時，
#   舊制【整段不 fire】而新制【到期後第一次補上】—— ★沒有這條，這張票等於什麼都沒做。

var _fail: int = 0
const EXPECTED_CELLS: Array = ["_run"]

# ★★★【到場點名】（systems 派工；本支的格【藏在 `_run` 裡】而橫幅印在 `_initialize`）——
#   ★實測（2026-09-18）：讓 `_run` 中途死掉 ⇒ **通過橫幅照印、rc=0** ⇒ 「跑完了」與「死在一半」長得一樣。
#   ★★**`1／1` 不是「只有一格」，是【這支床的格粒度就是 `_run`】** —— 格是 inline 在 `_run` 裡的，
#     能被獨立點名的最小單位就是 `_run` 本身；要更細得先把格拆成 func（那是另一票）。
#   ★★★用法必須是 `_selftest_gate("格名").noop()`（死亡要發生在那一格自己的 frame 裡）。
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

func _initialize() -> void:
	_run()
	var _miss: Array = _roll_call_missing()
	var _suffix: String = "｜到場點名 %d／%d" % [_cells_ran.size(), EXPECTED_CELLS.size()]
	if _fail == 0 and _miss.is_empty(): print("=== DONE === ALL PASS%s" % _suffix)
	else: print("=== DONE === %d FAIL%s" % [_fail + _miss.size(), _suffix])
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond: print("  [PASS] %s" % msg)
	else: _fail += 1; print("  [FAIL] %s" % msg)

# 舊制：呼叫端每 outer 跑一次，而閘是 tick % cadence == 0
# ★★★★訂正（2026-09-06）：迴圈從 `outer` 起跑，不是從 0 ——
#   ★真正的呼叫端（`_step4c_harvest_tick` / `_step1d_overflow`）的閘是 `tick % outer == 0`，
#     而 `current_tick` 在系統跑之前就遞增 ⇒ ★★【第一次呼叫是 t = outer，不是 t = 0】。
#   ★★★而我原本從 0 起跑 ⇒ 測試印綠、實跑岔開 —— 【測試對呼叫端的模型是錯的】。
#   ⇒ 這就是「算術與實跑不是同一件事」的具體長相：算術沒錯，錯的是【算術的前提】。
func _old_fire_ticks(total: int, outer: int, cadence: int) -> Array:
	var out: Array = []
	for t in range(outer, total + 1, outer):
		if t % cadence == 0:
			out.append(t)
	return out

# 新制：呼叫端每 outer 跑一次，而閘是 current >= next
func _new_fire_ticks(total: int, outer: int, cadence: int) -> Array:
	var out: Array = []
	var w := WorldData.new()
	var nxt: int = cadence   # ★初值＝第一個邊界（與 WorldData 的欄位初值同源語意）
	for t in range(outer, total + 1, outer):
		w.current_tick = t
		var d: Array = HarvestSystem._due(w, nxt, cadence)
		nxt = int(d[1])
		if bool(d[0]):
			out.append(t)
	return out

func _run() -> void:
	_selftest_gate("_run").noop()
	var DAY: int = WorldState.TICKS_PER_DAY          # 1440
	var MONTH: int = WorldState.TICKS_PER_MONTH      # 43200
	var HARVEST_OUTER: int = DAY / 4                 # 360（_step4c_harvest_tick 的外層）
	var OVERFLOW_OUTER: int = DAY                    # 1440（_step1d_overflow 的外層）

	# ── ①等價性：現行參數下，新舊 fire 在【同一組 tick】 ──
	var cases: Array = [
		["harvest daily", HARVEST_OUTER, DAY, MONTH * 2],
		["harvest monthly", HARVEST_OUTER, MONTH, MONTH * 3],
		["overflow monthly", OVERFLOW_OUTER, MONTH, MONTH * 3],
	]
	for c in cases:
		var o: Array = _old_fire_ticks(int(c[3]), int(c[1]), int(c[2]))
		var n: Array = _new_fire_ticks(int(c[3]), int(c[1]), int(c[2]))
		_ok(o == n, "①%-18s 新舊 fire tick 完全相同（%d 次）%s"
			% [String(c[0]), o.size(), "" if o == n else "  舊=%s 新=%s" % [str(o), str(n)]])
	print("     ★★這一條是【fp 逐位元不變】的理由 —— 而它是【算出來的】不是【假設的】。")

	# ── ②★★★這張票買到的東西：外層 cadence 不整除時，舊制整段不 fire ──
	#   ★用一個【故意不整除】的外層（500），INTERVAL 仍是 1440：1440 % 500 != 0
	var bad_outer: int = 500
	var o2: Array = _old_fire_ticks(DAY * 10, bad_outer, DAY)
	var n2: Array = _new_fire_ticks(DAY * 10, bad_outer, DAY)
	print("  ── ②外層 cadence 改成 %d（不整除 %d）──" % [bad_outer, DAY])
	print("     舊制 fire 次數 = %d ｜ 新制 fire 次數 = %d" % [o2.size(), n2.size()])
	_ok(o2.size() <= 1 and n2.size() >= 9,
		"②★舊制幾乎整段不 fire(%d 次)、新制照常補上(%d 次) —— ★★這才是這張票買到的東西"
			% [o2.size(), n2.size()])
	print("        ★★★沒有這條，①「新舊完全相同」會【自己證明自己什麼都沒改】。")

	# ── ③首次呼叫必 fire（等同舊制 0 % INTERVAL == 0）──
	var w := WorldData.new()
	w.current_tick = 0
	w.current_tick = HARVEST_OUTER
	var d0: Array = HarvestSystem._due(w, MONTH, MONTH)
	_ok(not bool(d0[0]) and int(d0[1]) == MONTH,
		"③★第一次呼叫（t=%d、next=%d）【不 fire】" % [HARVEST_OUTER, MONTH])
	print("        ★★這條就是 fp 實跑 A/B 抓到的那個坑：原本初值 0 ⇒ 第一次必 fire，")
	print("           而舊制在 t=%d 不 fire（%d %% 1440 != 0）⇒ ★★★世界從第一天就岔開。" % [HARVEST_OUTER, HARVEST_OUTER])
	_cell("_run")
