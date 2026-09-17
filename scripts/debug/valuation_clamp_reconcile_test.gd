extends SceneTree

# ★★★物價【拆閥之後】的分帶對帳與定義域斷言（第⑩票 2026-09-06）
#
# ★本檔原本測的是「clamp 命中率三桶」，而第⑩票【把閥拆了】⇒ 那三個 key 不再存在。
#   ⇒ ★★key 改名（`clamp_*` → `band_*`）的同一顆 commit【必須一起改讀者】——
#     留著舊名的讀者會印 0，而【那個 0 是「找不到」不是「沒發生」】（今天已踩過一次同型）。
#
# ★★★判準四條，而第②③兩條是【這張票的兩段風險】：
#   ①四桶互斥且窮盡（Σ == local_value.calls）
#   ②★上臂桶【恆 0】—— 上臂是結構性死碼；★★它非 0 ＝【我的推導錯了】，那才是要停的時刻
#   ③★★★價格【恆 >= 0】—— floor 是【定義域】不是閥（blueprint 裁）
#   ④★深過剩（stock > 2×target）⇒ 價格【就是 0】—— ★★而那是 regime change 的入口，
#      不是 bug：若 food 大量落在這桶，農隊賣糧收入歸零。

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

func _mk(pop: int, res: String, stock: float) -> TeamData:
	var t := TeamData.new()
	t.team_id = 1
	for i in range(pop - 1):
		t.named_members.append(100 + i)
	t.resources = {res: stock}
	return t

func _run() -> void:
	_selftest_gate("_run").noop()
	var state: WorldState = MeasureBedHelper.arm_and_new()
	# [pop, res, stock, 期望帶]
	# ★★★而【不寫「期望帶」那一欄】：`team.population` 與 `TARGET_PER_POP` 的互動我沒有逐案算過，
	#   ⇒ ★寫一個【我沒算過的期望值】在卷面上，就是在印一個【看起來被驗證過】的猜測。
	#   ⇒ ★★case 的作用是【把四桶推到至少兩個非空】，而那件事由下面的對帳式【真的驗】。
	var cases: Array = [
		[1, "food",      999.0],   # 庫存遠超 target ⇒ 過剩側
		[4, "food",       60.0],
		[8, "food",        0.0],   # 缺到底 ⇒ 放大後恰好等於上界（★不超過）
		[4, "food",        2.0],
		[8, "material",    0.0],
	]
	var min_price: float = 1e9
	for c in cases:
		var t: TeamData = _mk(int(c[0]), String(c[1]), float(c[2]))
		var v: float = TradeValuation.local_value(t, String(c[1]), state)
		min_price = minf(min_price, v)
		print("     pop=%d res=%-9s stock=%6.1f ⇒ price=%.3f" % [int(c[0]), String(c[1]), float(c[2]), v])

	var dg: int = int(Probe.counts.get("valuation.band_deep_glut", 0))
	var g: int = int(Probe.counts.get("valuation.band_glut", 0))
	var oh: int = int(Probe.counts.get("valuation.band_over_hi", 0))
	var nm: int = int(Probe.counts.get("valuation.band_normal", 0))
	var calls: int = int(Probe.counts.get("local_value.calls", 0))
	var zero: int = int(Probe.counts.get("valuation.price_zero", 0))
	print("  ── 對帳（★真的印出來，不心算）──")
	print("     deep_glut=%d ｜ glut=%d ｜ over_hi=%d ｜ normal=%d ｜ Σ=%d ｜ calls=%d ｜ price_zero=%d"
		% [dg, g, oh, nm, dg + g + oh + nm, calls, zero])

	_ok(dg + g + oh + nm == calls, "①四桶互斥且窮盡：%d == calls %d" % [dg + g + oh + nm, calls])
	_ok(oh == 0,
		"②★上臂桶【恆 0】(over_hi=%d)：shortage <= 1.0 ⇒ 放大後恰好等於上界、永不超過" % oh)
	print("        ★★它非 0 ＝【推導錯了】(stock 變可負／放大係數改了) —— 那才是要停下來的時刻，")
	print("           ★★★而【拆上臂 fp 逐位元不變】這條驗收，靠的就是這個推導。")
	_ok(min_price >= 0.0, "③★★價格恆 >= 0（本輪最小 %.3f）—— floor 是【定義域】不是閥" % min_price)
	_ok(dg > 0 and zero > 0,
		"④★深過剩桶非空(%d) 且【價格真的落到 0】(%d 次) —— ★★沒有這條，③『>= 0』在【從來不到 0】時也綠"
			% [dg, zero])
	print("        ★★★而「food 大量落在深過剩桶」是 regime change 的入口（農隊賣糧收入歸零），")
	print("           ⇒ 那要靠長跑床的比例讀數，★不是這支單元床能答的。")

	Probe.enabled = false
	_cell("_run")
