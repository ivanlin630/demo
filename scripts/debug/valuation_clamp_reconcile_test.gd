extends SceneTree

# ★★★物價 clamp 命中率的對帳測（systems 2026-09-06，對比輪 D 格）
#
# ★量的是【有沒有被夾住】，不是【結果落在哪】——
#   measurer 原本提的是比 clamp【之後】的 `sr` 是否貼近邊界(±1e-6)，
#   ★★而那會把【被夾住】與【剛好等於邊界】混在一起，還要靠一個 epsilon。
#   ⇒ ★★★改成比 clamp【之前】的 `shortage` 與邊界：精確、零 epsilon。
#
# ★★驗收兩條，缺一不可：
#   ①三桶【互斥且窮盡】：lo + hi + none == `local_value.calls`
#     —— ★對帳式要【真的印出來】，不是心算。
#   ②★★★三桶【各自都要非零】—— 沒有這條，「加總對得上」在【兩個桶永遠不 fire】時
#     照樣全綠（0 + 0 + N == N）⇒ 那個對帳式對【tap 死掉】完全不敏感。

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
	# ★★★走 `MeasureBedHelper.arm_and_new()`（bed-arm 閘裁定）——★它是【手工組世界】那條入口：
	#   本床不走 `GameSetup`（只要一個空 state 給 `local_value` 讀），
	#   ★★而 `arm_and_new()` 把「arm 先於建世界」的順序【寫死】⇒ 沒得選錯。
	#   ★★★不走 helper 的另一條路是【加白名單】，而閘自己說得很清楚：
	#     加白名單會讓那個「未納管存量」的數字變大 —— 那是【刻意可見】的代價。
	#     ⇒ 本床不需要付那個代價：它能走 helper。
	var state: WorldState = MeasureBedHelper.arm_and_new()

	# ★三種情況各造幾次 —— ★★而「造得出來」本身就是【邊界可達】的證據：
	#   若某一桶造不出來，那不是測試寫壞，是【那個邊界在真實參數下不可達】⇒ 要回報不是放寬。
	var cases: Array = [
		# [pop, res, stock, 期望桶]
		[1, "food",     999.0, "lo"],    # 庫存遠超 target ⇒ shortage 很負 ⇒ 撞下界 -0.5
		[8, "food",       0.0, "hi"],    # 生存品、缺到底 ⇒ 放大後 > 4.0 ⇒ 撞上界
		[8, "material",   0.0, "hi"],    # 非生存品上界 1.0 ⇒ shortage=1.0 不撞；用 0 庫存看 none/hi
		[4, "food",       2.0, "none"],  # 中間
	]
	for c in cases:
		var t: TeamData = _mk(int(c[0]), String(c[1]), float(c[2]))
		var v: float = TradeValuation.local_value(t, String(c[1]), state)
		print("     pop=%d res=%-9s stock=%6.1f ⇒ value=%.3f" % [int(c[0]), String(c[1]), float(c[2]), v])

	var lo: int = int(Probe.counts.get("valuation.clamp_lo", 0))
	var hi: int = int(Probe.counts.get("valuation.clamp_hi", 0))
	var none: int = int(Probe.counts.get("valuation.clamp_none", 0))
	var calls: int = int(Probe.counts.get("local_value.calls", 0))
	print("  ── 對帳（★真的印出來，不心算）──")
	print("     clamp_lo=%d ｜ clamp_hi=%d ｜ clamp_none=%d ｜ 合計=%d ｜ local_value.calls=%d"
		% [lo, hi, none, lo + hi + none, calls])

	_ok(lo + hi + none == calls,
		"①三桶【互斥且窮盡】：%d + %d + %d == %d（calls）" % [lo, hi, none, calls])
	# ★★★而 ② 第一次跑就把 `clamp_hi` 抓成 0 —— ★而那【不是測試寫壞】，是【上界結構性不可達】：
	#   `_stock` = `ResourceSystem.effective_holding`（:592-595 = team.resources + 糧倉，兩項皆 >= 0）
	#   ⇒ `shortage = (target - stock) / maxf(target, 1.0) <= 1.0` 恆成立
	#   ⇒ 生存品放大：`1.0 + (1.0 - 0.5) * 6.0 = 4.0` **恰好等於上界**，永不超過
	#   ⇒ 非生存品：`shortage <= 1.0` **恰好等於上界 1.0**，永不超過
	#   ⇒ ★★`clampf(shortage, -0.5, hi)` 的【上臂是死的】—— 它從來不夾任何東西。
	#   ⇒ ★★★所以 D 格的「上界命中率」【恆為 0%】，而那是【由構造決定】不是【世界觀察】。
	#      ★我把它斷言成 0 而不是斷言成 >0 —— ★★若哪天它非 0，那是【前提破了】(stock 變成可負／
	#      放大係數改了)，而那才是真正該紅的時刻。
	_ok(lo > 0 and none > 0,
		"②可達的兩桶【各自非零】(lo=%d none=%d) —— ★沒有這條，「加總對得上」在桶不 fire 時照樣全綠"
			% [lo, none])
	_ok(hi == 0,
		"③★★★上界桶【恆為 0】(hi=%d)：`shortage <= 1.0` ⇒ 放大後恰好等於上界、永不超過 ⇒ 上臂是死的"
			% hi)
	print("     ★而這條是【反向斷言】：它非 0 ＝ 前提破了（stock 可負／放大係數改了）⇒ 那時該紅的是它。")

	Probe.enabled = false
