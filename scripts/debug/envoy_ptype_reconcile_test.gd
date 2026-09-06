extends SceneTree

# ★★★envoy 失敗原因的 `ptype` 歸因對帳（defer `envoy-ptype-tap`，2026-09-06）
#
# ★病（已寫進 known_issues）：四個 fail counter 的母體是【全站所有 envoy 用途】
#   ⇒ ★★「回報因為沒名人而失敗 501 次」這句【講不得】—— 那 501 裡有多少是結盟的，答不出來。
#
# ★★本測守的是【兩層之間的對帳】：
#   Σ(各 ptype 的同一原因) == 該原因的總計
#   ⇒ ★★★而它同時是【新桶偵測器】：哪天多一種 ptype 而沒人更新讀者，Σ 就會對不上。
#
# ★★★而【對帳恆等】本身沒有鑑別力（0 == 0 也成立）⇒ 所以另有一條：
#   至少要造出【兩種 ptype × 同一個原因】—— 否則「Σ 對得上」只是在說「只有一個桶」。

var _fail: int = 0

func _initialize() -> void:
	_run()
	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond: print("  [PASS] %s" % msg)
	else: _fail += 1; print("  [FAIL] %s" % msg)

const REASONS: Array = ["目標不在名冊", "不知道對方在哪", "母隊只剩一人", "沒有可派的名人"]

func _run() -> void:
	var state: WorldState = MeasureBedHelper.arm_and_new()
	var fa := FactionAISystem.new()

	# ★造【最容易且最乾淨】的那個原因：目標不在名冊（target == null）——
	#   ★★它在函式最前面，不依賴 belief／人力，★★★所以它能【單獨】把兩種 ptype 都推一次。
	var mother := TeamData.new()
	mother.team_id = 1
	state.teams[1] = mother
	for ptype in ["alliance", "member_report"]:
		for _i in range(3 if ptype == "alliance" else 5):
			fa._dispatch_envoy(state, mother, 999, ptype)   # 999 不在名冊

	var total: int = int(Probe.counts.get("envoy.fail.目標不在名冊", 0))
	var a: int = int(Probe.counts.get("envoy.fail.alliance.目標不在名冊", 0))
	var m: int = int(Probe.counts.get("envoy.fail.member_report.目標不在名冊", 0))
	print("  ── 對帳（★真的印出來）──")
	print("     總計=%d ｜ alliance=%d ｜ member_report=%d ｜ Σ=%d" % [total, a, m, a + m])

	_ok(a + m == total, "①Σ(各 ptype) == 總計：%d + %d == %d" % [a, m, total])
	_ok(a == 3 and m == 5,
		"②★逐桶【數字要對】不是「非零就好」：alliance=%d(期望3) member_report=%d(期望5)" % [a, m])
	_ok(a > 0 and m > 0,
		"③★★★兩種 ptype 【都】造得出來 —— 沒有這條，「Σ 對得上」只是在說【只有一個桶】")

	# ★★而另外三個原因【本測沒有造】—— ★這是誠實限不是遺漏：
	#   它們要真的世界（belief／人力狀態）才觸發得到，而【在單元床裡硬造會變成造假前提】。
	var missing: Array = []
	for r in REASONS:
		if r != "目標不在名冊" and int(Probe.counts.get("envoy.fail." + r, 0)) == 0:
			missing.append(r)
	print("     ★本測只覆蓋 1/4 個原因；未覆蓋：%s" % str(missing))
	print("        ★★它們要真實世界狀態（belief 缺位／人力不足）才觸發 ——")
	print("        ★★★在單元床裡硬造＝造假前提；覆蓋它們要靠長跑床，而【那不是這支的工作】。")
	print("        ⇒ ★所以這支的 PASS 【不代表四個原因的 ptype 歸因都對】，只代表【接線形狀對】。")

	Probe.enabled = false
