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

func _initialize() -> void:
	_run()
	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
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
