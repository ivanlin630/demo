extends SceneTree
# @bed-kind: acceptance
# slice: 相位樹（淨值 self_us）＋ 未登記相位的閘
#
# ★本票不優化任何東西 —— 它讓那張表【可以排序】：總計欄是巢狀的，
#   用它排序＝把父親和兒子放進同一個排行榜。
# ★★★而 "*multi"（一個名字可能從多個外層被觸發）不參與減法：
#   ★負值是看得見的症狀，而同一個成因也會造出【正的、但錯的】淨值 —— 那個沒有任何一格會紅。

var _fails: int = 0
var _sections: int = 0
const EXPECT_SECTIONS: int = 4

func _initialize() -> void:
	print("=== 相位樹床 ===")
	_test_net_value()
	_test_unregistered_gate()
	_test_negative_message()
	_test_no_hot_path_cost()
	if _sections != EXPECT_SECTIONS:
		_fails += 1
		push_error("[FAIL] 只跑完 %d/%d 段" % [_sections, EXPECT_SECTIONS])
	print("=== DONE === SECTIONS=%d/%d FAILS=%d" % [_sections, EXPECT_SECTIONS, _fails])
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_fails += 1
		push_error("[FAIL] " + msg)

func _test_net_value() -> void:
	print("-- ② 淨值：父的 self ＝ total − 直接子 --")
	var ph := {"loop1.assign_tasks": 1000, "assign.leader_unified": 400, "assign.members": 250}
	var rep: String = FactionAISystem.phase_report(ph, 1000)
	print("    %s" % rep.substr(0, 150))
	_ok(rep.contains("loop1.assign_tasks=self350us/"),
		"②父 self ＝ 1000 − 400 − 250 ＝ 350（★兒子只減【直接】子，不重複減孫）")
	_ok(rep.contains("assign.leader_unified=self400us/"), "②葉子的 self ＝ 它自己的 total")
	# ★★"*multi"：不參與減法，且輸出要具名標示
	var ph2 := {"loop1.assign_tasks": 1000, "gather.market": 900}   # ★unified.rank 已按呼叫端拆開、不再 multi
	var rep2: String = FactionAISystem.phase_report(ph2, 1000)
	print("    multi：%s" % rep2.substr(0, 150))
	_ok(rep2.contains("loop1.assign_tasks=self1000us/"),
		"★★multi 不被減進父親（否則父親會被【多減】而看起來很乾淨）")
	# ★訂正：multi 現在【分段印】（systems §③：它的 self 恆等於 tot ⇒ 不可與真淨值同排行榜）
	_ok(rep2.contains("[multi・不參與淨值・self≡tot]") and rep2.contains("gather.market=tot900us"),
		"★★multi 列【分段印】且標明 self≡tot（★★★混在同一排序裡＝同一張表兩種口徑）")
	# ★systems §①：self==tot 有兩種意思 ⇒ 印【已登記兒子數】當場分得出來
	_ok(rep.contains("loop1.assign_tasks=self350us/tot1000us(kids"),
		"★每一列印【已登記兒子數】—— 分得出「真的沒有兒子」與「兒子沒被登記」")
	_sections += 1

func _test_unregistered_gate() -> void:
	print("-- ① 閘會咬：沒登記的名字 ⇒ 具名紅；登記後回綠 --")
	var ph := {"loop1.factions": 500, "brand.new_tap": 120}
	var rep: String = FactionAISystem.phase_report(ph, 500)
	_ok(rep.contains("未登記相位") and rep.contains("brand.new_tap"),
		"①新 tap 沒登記 ⇒ 【具名】亮（名字要印出來，不是只說「有一個」）")
	var ph2 := {"loop1.factions": 500, "assign.members": 120}
	var rep2: String = FactionAISystem.phase_report(ph2, 500)
	_ok(not rep2.contains("未登記相位"), "①★成對：全部登記過 ⇒ 不亮（不亂咬）")
	# ⑤覆蓋率：登記／實際出現兩個數字
	_ok(rep.contains("登記 1/2") and rep2.contains("登記 2/2"),
		"⑤印出【已登記／實際出現】兩個數字（★相等才算表是完整的）")
	_ok(FactionAISystem.phase_report({}, 0).contains("登記 0/0"),
		"⑤★空母體：印 0/0 而不是假裝正常（★★母體地板）")
	_sections += 1

func _test_negative_message() -> void:
	print("-- ②★★★負值：紅燈訊息必須把【三種成因】並列 --")
	var ph := {"loop1.infra": 100, "infra.facility": 400}   # 子 > 父 ⇒ 父 self 為負
	var rep: String = FactionAISystem.phase_report(ph, 100)
	print("    %s" % rep.substr(0, 240))
	_ok(rep.contains("self_us 為負") and rep.contains("loop1.infra"), "②負值被具名")
	_ok(rep.contains("父子表寫錯") and rep.contains("區間重疊") and rep.contains("不只一件事"),
		"②★★★三種成因並列（★否則下一個看到紅燈的人只會去改父子表，而問題可能不在那）")
	_ok(rep.contains("gather.") and rep.contains("拆開計時鍵"),
		"②★點名第三種的候選族群與它的【處置】")
	_sections += 1

func _test_no_hot_path_cost() -> void:
	print("-- ④ 零熱路徑成本：phase_timing 關閉時不得做任何額外工作 --")
	var f := FileAccess.open("res://scripts/simulation/faction_ai_system.gd", FileAccess.READ)
	var src: String = f.get_as_text() if f != null else ""
	if f != null:
		f.close()
	var idx: int = src.find("phase_report(_fai_ph")
	_ok(idx > 0, "④找得到呼叫點（母體地板）")
	# ★呼叫點前面 400 字內必須有 `if _zoom`（＝phase_timing 那道旗標）
	var before: String = src.substr(maxi(0, idx - 400), mini(400, idx))
	_ok(before.contains("if _zoom"),
		"④phase_report 只在 phase_timing 開啟時被呼叫（★關閉時零額外工作）")
	_sections += 1
