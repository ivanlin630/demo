extends SceneTree

# @bed-kind: acceptance
# slice: 票甲 —— 可交易品集合與價目表分家（HOW spec 2026-09-15-coin-is-the-unit）
#
# ★★★這張票【今天不改變任何數字】：新集合恰好等於 `BASE_PRICE` 的鍵集
#   ⇒ **fp 逐位元不變是【預期】** ⇒ ★不准拿「症狀沒改善」判它失敗。
#   ★★零差別的今天，防的是票乙的明天（補 coin 價格時不擴大交易集合）。
#
# ★三格（systems 2026-09-15 訂正我的第一版）：
#   ①**宣告形狀**：`TRADEABLE_RES` 的宣告右側不得含 `BASE_PRICE`
#     ⇒ ★誠實的儀器就是讀原始碼 —— 這一格【今天就有鑑別力】
#   ②★★**陽性對照（同支測試內）**：拿一段故意違規的字串跑同一個判準，斷言它會紅
#     ⇒ ★★★否則那個判準本身可能根本不會紅，而沒人會發現
#   ③**語意**：集合不含 coin ——★明寫它【今天恆真】，鑑別力要到票乙才出現
#     ⇒ **不准拿它當硬約束的證明**（★我第一版就是栽在這裡）
#
# ★★而我原本提的「往 BASE_PRICE 塞假鍵」寫不出來：`const Dictionary` 在 Godot 4.2
#   是**編譯期** `Cannot assign a new value to a constant` ⇒ 整支測試檔載不起來
#   ⇒ ★★★那不是「那一格紅」，是【整支閘死掉】—— 而永遠 FAIL 的閘三天後就是背景噪音。

var _fails: int = 0

func _ok(cond: bool, msg: String) -> void:
	print(("  [OK] " if cond else "  [FAIL] ") + msg)
	if not cond: _fails += 1

# ★判準本體抽成函式 —— ★★這樣格②才能拿【同一個判準】去跑違規字串
#   （若判準只寫在格①裡面，陽性對照驗的就是另一份 code）
static func _decl_uses_base_price(src: String) -> bool:
	var i: int = src.find("const TRADEABLE_RES")
	if i < 0:
		return true   # ★找不到宣告 ⇒ 當成違規（★不是「通過」——查無 ≠ 沒問題）
	var j: int = src.find("]", i)
	if j < 0:
		j = src.length()
	return src.substr(i, j - i).find("BASE_PRICE") >= 0

func _init() -> void:
	print("=== 票甲：可交易品集合與價目表分家 ===")
	var f: FileAccess = FileAccess.open("res://scripts/simulation/trade_valuation.gd", FileAccess.READ)
	if f == null:
		print("  [FAIL] 讀不到 trade_valuation.gd ⇒ ★本輪【沒有判過】（不是通過）")
		print("=== DONE === SECTIONS=1/1 FAILS=1")
		print("[TEST-SUITE-COMPLETE]")
		quit()
		return
	var src: String = f.get_as_text()
	f.close()

	print("★①宣告形狀：`TRADEABLE_RES` 的宣告右側不得含 `BASE_PRICE`")
	_ok(not _decl_uses_base_price(src),
		"①宣告是**字面列舉**，不是 `BASE_PRICE.keys()`（★換個名字的同一張表，票乙補 coin 照樣炸）")

	print("★②陽性對照（同支測試內，不碰 production）：故意違規的字串必須被判紅")
	var bad: String = "const TRADEABLE_RES: Array = TradeValuation.BASE_PRICE.keys()\n"
	_ok(_decl_uses_base_price(bad), "②違規寫法**會紅** ⇒ ★這個判準有鑑別力")
	var good: String = "const TRADEABLE_RES: Array = [\"food\", \"tools\"]\n"
	_ok(not _decl_uses_base_price(good), "②-b 合規寫法**不會亂紅** ⇒ ★成對，只驗會紅那邊證明不了穩定")
	_ok(_decl_uses_base_price("（完全沒有宣告）"), "②-c 找不到宣告時判紅 ⇒ ★**查無 ≠ 沒問題**")

	print("★③語意：集合不含 coin")
	_ok(not ("coin" in TradeValuation.TRADEABLE_RES),
		"③不含 coin —— ★★而它**今天恆真**（coin 本來就不在價目表裡）⇒ **鑑別力要到票乙才出現**")
	print("   ★★★所以③**不能**當成①那條硬約束的證明：違規寫法在③這一格是【綠的】")

	print("★④今天的集合內容（★與 `BASE_PRICE` 鍵集比對，兩者相等是【預期】）")
	var only_tr: Array = []
	for r in TradeValuation.TRADEABLE_RES:
		if not TradeValuation.BASE_PRICE.has(r):
			only_tr.append(r)
	var only_bp: Array = []
	for k in TradeValuation.BASE_PRICE:
		if not (k in TradeValuation.TRADEABLE_RES):
			only_bp.append(k)
	print("   集合 %d 項｜價目表 %d 鍵｜只在集合：%s｜只在價目表：%s" % [
		TradeValuation.TRADEABLE_RES.size(), TradeValuation.BASE_PRICE.size(),
		str(only_tr), str(only_bp)])
	_ok(only_tr.is_empty() and only_bp.is_empty(),
		"④今天兩者**內容相同** ⇒ ★**fp 逐位元不變是預期**（★★零差別的今天，防的是票乙的明天）")

	# ── ★★★§⑤【新集合真的被走到】（systems 票甲 §④）──
	#   ★`fp` 不變只證【等價】，**不證【被走到】** ——
	#   ★★「改完了而其實沒接上」會以 fp 不變的形式通過驗收。
	print("")
	print("★★★⑤新集合有沒有真的被走到（★跑一段真世界，不是静態推）")
	seed(1337)
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/warring_states.json")
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)
	for _t in range(1440):
		runner.advance_tick(st, no_player)
	var sites: Array = ["encounter_sell", "barter_give", "barter_pay",
		"player_sellable", "player_mapper"]
	var hit: int = 0
	for site in sites:
		var n: int = int(Probe.counts.get("tradeable.read." + String(site), 0))
		if n > 0: hit += 1
		print("   %-18s %d 次%s" % [site, n,
			"" if n > 0 else "   ← ★本窗 0（★★【沒被走到】與【這條路本窗沒發生】是兩個結論）"])
	_ok(hit > 0, "⑤至少一處真的讀了新集合 —— ★否則 fp 不變只證明了【我什麼都沒接】")
	print("   ★★而玩家側兩處（player_*）**本床跑不到**（無玩家）⇒ 它們的 0 是【第二種】")
	print("★fp = %s" % StateFingerprint.compute(st))
	print("=== DONE === SECTIONS=1/1 FAILS=%d" % _fails)
	print("[TEST-SUITE-COMPLETE]")
	quit()
