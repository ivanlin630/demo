extends SceneTree
# @bed-kind: acceptance
# slice: 恩怨帳 切片A（HOW spec 2026-09-16-grudge-ledger-sliceA-HOW.md §3）
#
# ★★★這一票的核心不是加功能，是【接上兩個世界一直在寫、而沒有人聽得懂的名字】：
#   勒索寫的是 `special_taxed`、求救不應寫的是 `rejected_aid`、受援寫的是 `benefactor`
#   —— ★三個都不在任何 match 裡 ⇒ 落進 `_` ⇒ **零邊、零標量、零 goal。**
# ★★所以本床最重要的一格是【名字那一格】（格7），而不是任何一個數值格。
#
# ★★★【誠實限】本床是 **fixture 級**：它證明【名字接上了】與【式子算對了】，
#   ★**它不證明那三個寫入點在真世界裡會 fire** —— 那由世界床的 `grudge.form.*` 母體回答。
#   ★★而「全 0 是母體塌陷，不是答案」：每一格都印【發生了幾次／母體多大】。

func _initialize() -> void:
	Probe.arm()   # ★arm 先於任何 fixture（bed-arm 閘）
	_run()
	# ★★★【不可判也不是綠】（systems 裁 2026-09-16）：
	#   ★一個綠的格，要驗的是**它宣稱的東西** —— 而本切片有兩格**驗不了它宣稱的東西**
	#   ⇒ ★★它們**不能安靜地不存在**，也不能改寫成一個比較容易的問題然後變綠
	#   ⇒ ★★★所以 `[不可判]` 有**自己的離開碼**（2）：它與 `[FAIL]`（1）**是兩件事**，
	#     而它與 `[OK]`（0）**更不是同一件事**。
	# ★★★【離開碼與判準的分工】（systems 2026-09-16）：
	#   ★我原本讓 `[不可判]` 走離開碼 2 —— ★★而 merge-gate runner **看離開碼**：
	#     非 0 ⇒ 直接判紅 ⇒ **這一閘會【永遠紅】，`expect` 根本輪不到比對。**
	#   ⇒ ★★★照 systems 立的 **「判準看橫幅，不看離開碼」**：判別力搬到 registry 的 `expect`
	#     （釘住 `[FAIL] 數 ＝ 0｜[不可判] 數 ＝ 2`）—— **切片B 落地讓那個 2 變 0 的那天它會紅。**
	#   ★所以離開碼只反映**真紅**；`[不可判]` 的可見性由 **橫幅 ＋ `push_error` ＋ `expect`** 三處承擔。
	#   ★★**而「不可判不是綠」沒有被放棄** —— 它從離開碼搬到了【閘的判準】上。
	quit(1 if _fails > 0 else 0)

var _fails: int = 0
var _undec: int = 0
var _undec_names: Array = []

func _ok(cond: bool, msg: String) -> void:
	if cond: print("  [OK] %s" % msg)
	else:
		_fails += 1
		push_error("[FAIL] %s" % msg)

# ★【本切片不可判】＝ 這一格宣稱要驗的東西，**在本切片的 code 上不存在可達的路徑**。
#   ★★處置不是刪掉它，也不是把它換成一個做得到的問題 —— **是把它留著、標明、並且不算綠。**
func _undecidable(cell: String, claim: String, why: String, unblocks: String) -> void:
	_undec += 1
	_undec_names.append(cell)
	push_error("[不可判] %s：%s" % [cell, claim])
	print("  [不可判] %s ——" % cell)
	print("       宣稱：%s" % claim)
	print("       為什麼驗不了：%s" % why)
	print("       什麼時候可判：%s" % unblocks)

func _mk_person(id: int, vals: Dictionary) -> PersonData:
	var p := PersonData.new(); p.id = id; p.values = vals
	return p

func _w_of(p: PersonData) -> float:
	return TradeValuation.grudge_weight(p.values)

func _run() -> void:
	print("=== 恩怨帳 切片A 驗收（fixture 級，不跑世界）===")
	var ai := NpcAiSystem.new()

	# ── 格1：同一重徵序列，義氣 0.9 vs 0.1 ⇒ feud 強度分化 ──
	var hi := _mk_person(1, {"義氣": 0.9, "好戰": 0.5, "慎重": 0.5})
	var lo := _mk_person(2, {"義氣": 0.1, "好戰": 0.5, "慎重": 0.5})
	ai.write_memory(hi, "special_taxed", 99, 0, 0.3)
	ai.write_memory(lo, "special_taxed", 99, 0, 0.3)
	var f_hi: float = RelationGraph.intensity_to(hi.relation_edges, "feud", 99)
	var f_lo: float = RelationGraph.intensity_to(lo.relation_edges, "feud", 99)
	print("★格1 義氣0.9 feud=%.4f｜義氣0.1 feud=%.4f（母體：各 1 次重徵）" % [f_hi, f_lo])
	_ok(f_hi > f_lo, "格1 人格**進了 feud 強度**（★兩者相同 ⇒ `form_feud` 的個性 factor 沒作用）")

	# ── ★★★格2-0【本切片的發現，systems 的 §0 沒有掃到】：
	#   `form_feud` 的 `FEUD_MIN` 是一個**逐事件**的門檻，而且它在 `add_edge` **之前**
	#   ⇒ ★中庸人格（義氣 0.5／好戰 0.5）遇一次小重徵：0.3 × factor(0.75) ＝ 0.225 < 0.30
	#     ⇒ **邊根本不產生** ⇒ ★★**十次也還是零** ——
	#   ⇒ ★★★**「小怨累積會爆」（WHAT）在今天的 code 上【到不了】**：
	#     飽和疊加接好了，而**它永遠收不到那些小怨** ——
	#     ★這與本票在修的病是同一族：**機制接好了，但它上游有一個閘讓它看不到輸入。**
	#   ★**我不自己改 `FEUD_MIN` 的語意**（把它移到累積後 ＝ 改機制 ＝ 不是我的格）⇒ 已回報 systems。
	var meek_stack := _mk_person(5, {"義氣": 0.5, "好戰": 0.5, "慎重": 0.5})
	for i in range(10):
		NpcAiSystem.new().write_memory(meek_stack, "special_taxed", 99, i, 0.3)
	var meek_i: float = RelationGraph.intensity_to(meek_stack.relation_edges, "feud", 99)
	print("★格2-0 中庸人格 × 十次小重徵 ⇒ feud=%.4f（單次 intensity 0.225 < FEUD_MIN %.2f ⇒ 逐事件被丟）" % [
		meek_i, NpcAiSystem.FEUD_MIN])
	_ok(meek_i == 0.0,
		"格2-0 ★**釘住現況**：中庸人格的小怨**一條邊都不產生** ⇒ 飽和疊加收不到輸入"
		+ "｜★★★這一格若哪天變綠不了（即 meek_i > 0），代表 systems 把 `FEUD_MIN` 移到累積之後 ——"
		+ " **那時候要回來把這一格改寫成「累積後跨線」，而不是刪掉它**")

	# ── ★★★spec 的格2【本切片不可判】（systems 裁 2026-09-16）──
	_undecidable("格2（spec 原文）",
		"十次**小**重徵 ⇒ feud 累積到可觸發拒賣（★`maxf` 版永遠到不了 ＝ 它的對照）",
		"`FEUD_MIN` 是**逐事件**門檻且在 `add_edge` **之前** ⇒ 小怨**一條邊都不產生**"
		+ "（格2-0 實測 0.0000）⇒ **飽和疊加永遠收不到它要累積的東西**",
		"切片B 第一項（門檻從【記錄】移到【行動】；它牽動 4 個 feud 讀者，要一起對齊）")
	print("       ★★★原則（systems 立，比這張票大）：**門檻要放在【行動】上，不要放在【記錄】上** ——")
	print("          放在記錄上 ⇒ 小事件永久消失 ⇒ 症狀是【公式接好了、床綠了、而世界裡一次也不會發生】。")

	# ── 格2′：**邊已經存在的人**身上，疊加是不是飽和式（★這【不是】spec 的格2）──
	#   ★★我上一版把這一格叫做「格2」而且讓它綠了 —— **而它驗的是「大怨會疊加」不是「小怨會累積」**
	#     ⇒ ★★★**一個綠的格，要驗的是它宣稱的東西**；改名不是修辭，是**把它宣稱的範圍縮回它做得到的**。
	#   ★人格取義氣 0.9 ⇒ 單次 0.30 × factor(1.03) ＝ 0.309 ≥ `FEUD_MIN` ⇒ **邊存在**，疊加才問得出來。
	var stacker := _mk_person(3, {"義氣": 0.9, "好戰": 0.5, "慎重": 0.5})
	var trace: Array = []
	for i in range(10):
		ai.write_memory(stacker, "special_taxed", 99, i, 0.3)
		trace.append(snappedf(RelationGraph.intensity_to(stacker.relation_edges, "feud", 99), 0.001))
	var i10: float = RelationGraph.intensity_to(stacker.relation_edges, "feud", 99)
	var w_mid: float = TradeValuation.grudge_weight({"義氣": 0.9, "慎重": 0.5})
	var once: float = float(trace[0])
	print("★格2′（**邊已存在者**的疊加）十次逐次：%s" % str(trace))
	print("   一次=%.4f ⇒ 十次=%.4f｜W(中庸)=%.3f｜I×W=%.4f vs h(最薄)=%.3f" % [
		once, i10, w_mid, i10 * w_mid, TradeValuation.SPREAD_TOL])
	_ok(i10 > once + 0.001,
		"格2′-a 十次 > 一次（★★**相同 ⇒ 還是 `maxf`** —— 那正是這一格存在的理由）")
	_ok(i10 * w_mid > TradeValuation.SPREAD_TOL,
		"格2′-b 累積**跨過最薄的那一端**（I×W %.4f > h %.3f）" % [i10 * w_mid, TradeValuation.SPREAD_TOL])
	# ★★★這一格問的是 systems 反解的**要求①**，而它逐字寫的是【中庸人格】
	#   ⇒ ★上一版我拿了**義氣 0.9 的 W** 去驗它 ⇒ 0.0834 > 0.05 紅 ——
	#     ★★而紅的是**我讀錯了判準的主詞**，不是世界：義氣 0.9 的人本來就該為小怨翻臉。
	var w_neutral: float = TradeValuation.grudge_weight({"義氣": 0.5, "慎重": 0.5})
	var once_neutral: float = NpcAiSystem.FEUD_MIN   # ★存在的怨一律 I ≥ FEUD_MIN ⇒ 最弱的怨就是它
	print("   要求①（最弱的怨 × **中庸**人格）：%.3f × %.3f ＝ %.4f vs h(最薄) %.3f" % [
		once_neutral, w_neutral, once_neutral * w_neutral, TradeValuation.SPREAD_TOL])
	_ok(once_neutral * w_neutral <= TradeValuation.SPREAD_TOL,
		"格2′-c ★**成對的另一半**：**最弱的怨 × 中庸人格不該秒殺交易**（%.4f ≤ %.3f）" % [
			once_neutral * w_neutral, TradeValuation.SPREAD_TOL]
		+ "｜★★這條不等式正是 `GRUDGE_PRICE_W_BASE` 的**來源**，不是它的裝飾")
	_ok(i10 <= 1.0, "格2′-d 飽和 ⇒ **永不破 1**（實測 %.4f）" % i10)

	# ── 格6：`protect` 邊疊加兩次 ⇒ 飽和值（不是 max）──
	#   ★疊加放在**共用點** ⇒ 它必須對 feud 以外的 type 也成立；★★只有 feud 改到 ⇒ 沒進共用點。
	var lord := _mk_person(4, {"義氣": 0.5})
	RelationGraph.add_edge(lord.relation_edges, "protect", 77, 0.4, 0)
	RelationGraph.add_edge(lord.relation_edges, "protect", 77, 0.4, 1)
	var pr: float = RelationGraph.intensity_to(lord.relation_edges, "protect", 77)
	var expect: float = 1.0 - (1.0 - 0.4) * (1.0 - 0.4)
	print("★格6 protect 疊兩次 0.4 ⇒ %.4f（飽和式 %.4f；`maxf` 版會是 0.4000）" % [pr, expect])
	_ok(absf(pr - expect) < 0.0005,
		"格6 **飽和疊加進了共用點**（★等於 0.4 ⇒ 只有 feud 改到）")

	# ── 格7：★★★名字那一格 —— 三個世界真的在寫的 type 各出現一條邊 ──
	#   ★誠實限：這一格證明【名字接上了】，**不證明那三個呼叫點在真世界會 fire**
	#     ⇒ 後者由世界床的 `grudge.form.*` 母體回答。
	var names: Array = [
		["special_taxed", "feud", "interaction_system.gd:696（重徵）"],
		["rejected_aid", "feud", "interaction_system.gd:1533／player_command_system.gd:1003／sim_runner.gd:381（求救不應）"],
		["benefactor", "gratitude", "interaction_system.gd:1218/:1560／player_command_system.gd:1024（★受人援助——systems 的 §0 沒掃到這一個）"],
	]
	var wired: int = 0
	for row in names:
		var subj := _mk_person(100 + wired, {"義氣": 0.9, "好戰": 0.9, "慎重": 0.1})
		ai.write_memory(subj, String(row[0]), 55, 0, 0.5)
		var got: float = RelationGraph.intensity_to(subj.relation_edges, String(row[1]), 55)
		print("   `%s` ⇒ %s 邊 %.4f   寫入點：%s" % [row[0], row[1], got, row[2]])
		if got > 0.0: wired += 1
	print("★格7 接上的名字 %d／母體 %d" % [wired, names.size()])
	_ok(wired == names.size(),
		"格7 三個名字**各產生一條邊**（★邊數 0 ⇒ 名字又沒接上——那正是本票要修的病）")
	# ★★而「舊死名字不該再有人聽得懂」也要成對驗：`extorted` 現在應該**什麼都不做**
	var ghost := _mk_person(200, {"義氣": 0.9, "好戰": 0.9})
	ai.write_memory(ghost, "extorted", 55, 0, 0.5)
	_ok(RelationGraph.intensity_to(ghost.relation_edges, "feud", 55) == 0.0,
		"格7-b ★**成對的另一半**：`extorted` 是死名字 ⇒ **不再有分支接它**"
		+ "（★若它仍產生邊 ⇒ 我留了一個永遠不會被觸發、卻看起來接好了的分支）")

	# ── 格3／格4：交易逐方估值 ──
	# ★★★【走 `MeasureBedHelper.arm_and_new()`】（bed-arm 閘；同掠奪票那一刀）：
	#   ★閘的母體就是 `WorldState.new()` 的呼叫檔 ⇒ 自己 new 會讓「未涵蓋」+1
	#   ★★而白名單**不是**出路：那份檔的檔頭逐字寫「**新增床不得加進來**」
	#   ⇒ ★★★手工組世界的正規入口是 `arm_and_new`（閘檔頭 :28 逐字列了它）。
	var state := MeasureBedHelper.arm_and_new()
	var seller := TeamData.new(); seller.team_id = 10; seller.leader_id = 1000
	# ★★★`TeamData.population` 是**計算屬性**，直接賦值會被**靜默吞掉**（跑出來有 [SETTER-SWALLOWED]）
	#   ⇒ 用 `AnonCohort` 真的放人進去。
	AnonCohort.add(seller.anon_cohorts, "平民", "healthy", 10)
	# ★★存量要**低於** `pop × TARGET_PER_POP.food`（10×10＝100），否則 `local_value` 落到定義域 floor 0
	#   ⇒ ★**ask 恆 0 ⇒ 乘數乘什麼都是 0** —— 上一版我給了 400，於是「加價」在一個 0 上看不出來。
	seller.resources = {"food": 20.0}
	var sl := _mk_person(1000, {"義氣": 0.9, "慎重": 0.1, "貪婪": 0.5})
	state.persons[1000] = sl; state.teams[10] = seller
	var foe := TeamData.new(); foe.team_id = 11; foe.leader_id = 1100
	AnonCohort.add(foe.anon_cohorts, "平民", "healthy", 10)
	# ★★★【買方必須落在「薄餘裕」那一端】（systems §1.4b）：
	#   ★上一版買方存量 0 ⇒ bid 頂到 10.0 而 ask 只有 5.47 ⇒ **h ＝ 0.92**
	#     ⇒ 深仇的加價 0.24 **遠不足以跨線** ⇒ 拒賣問不出來。
	#   ★★而那不是「機制沒用」，是**我挑的那一筆交易本來就餘裕滿滿** ——
	#     ★★★這正是 systems 要求印 `h` 分佈的理由：**兩者在「沒拒賣」這一句上長得一模一樣。**
	foe.resources = {"food": 36.0}   # ⇒ bid 落到 ask 附近 ⇒ h 薄
	state.persons[1100] = _mk_person(1100, {}); state.teams[11] = foe
	var third := TeamData.new(); third.team_id = 12; third.leader_id = 1200
	AnonCohort.add(third.anon_cohorts, "平民", "healthy", 10); third.resources = {}
	state.persons[1200] = _mk_person(1200, {}); state.teams[12] = third
	RelationGraph.add_edge(sl.relation_edges, "feud", 1100, 0.9, 0)   # 深仇

	var base_ask: float = TradeValuation.ask_price(seller, "food", 0.0, sl.values, state)
	var foe_ask: float = TradeValuation.ask_price(seller, "food", 0.0, sl.values, state, 1100)
	var third_ask: float = TradeValuation.ask_price(seller, "food", 0.0, sl.values, state, 1200)
	var bid: float = TradeValuation.local_value(foe, "food", state)
	var h: float = bid * (1.0 + TradeValuation.SPREAD_TOL) / maxf(base_ask, 0.0001) - 1.0
	print("★格3 base_ask=%.4f｜對仇人=%.4f｜對第三方=%.4f｜買方 bid=%.4f｜**h（這一筆的餘裕）=%.4f**" % [
		base_ask, foe_ask, third_ask, bid, h])
	_ok(foe_ask > base_ask, "格3-a 對加害者**索價升高**")
	_ok(absf(third_ask - base_ask) < 0.0001,
		"格3-b ★**對照**：對第三方**照原價賣**（★也變貴 ⇒ 是全域變貴不是恩怨）")
	_ok(foe_ask > bid * (1.0 + TradeValuation.SPREAD_TOL),
		"格3-c **撮合自然失敗 ＝ 湧現的拒賣**（%.3f > %.3f）★不是硬 gate 擋的" % [
			foe_ask, bid * (1.0 + TradeValuation.SPREAD_TOL)]
		+ "｜★★★拿不出樣本 ⇒ **回報 systems：這個定義不成立，不要加 gate 補上**")
	_ok(third_ask <= bid * (1.0 + TradeValuation.SPREAD_TOL),
		"格3-c2 ★**同一筆餘裕下，對第三方【成得了交】**（%.3f ≤ %.3f）" % [
			third_ask, bid * (1.0 + TradeValuation.SPREAD_TOL)]
		+ "｜★★沒有這一半，「拒賣」與【這筆交易本來就做不成】長得一模一樣")
	print("   ★★而 `h` 不是常數：`ask_base ≈ bid` 時它≈`SPREAD_TOL`，賣方折價時可到 0.3 ——")
	print("      ★★★沒有它的分佈，「沒成交」分不出【機制錯】與【這批交易本來就沒餘裕】。")
	_ok(absf(base_ask - TradeValuation.ask_price(seller, "food", 0.0, sl.values, state, -1)) < 0.000001,
		"格4 `buyer_leader_id = -1` ⇒ **索價逐字等同舊值**（★變了 ⇒ 預設路徑被改到，5 個既有呼叫點全中招）")

	# ── 格5：報恩消耗 ／ 被動不消耗 ──
	#   ★唯一鐵則（WHAT）：**消耗邊的是【事件】，被動與無不消耗。**
	RelationGraph.add_edge(sl.relation_edges, "gratitude", 1200, 0.6, 0)
	var g0: float = RelationGraph.intensity_to(sl.relation_edges, "gratitude", 1200)
	var _passive: float = TradeValuation.ask_price(seller, "food", 0.0, sl.values, state, 1200)
	var g_passive: float = RelationGraph.intensity_to(sl.relation_edges, "gratitude", 1200)
	var taken: float = NpcAiSystem.repay_gratitude(state, seller, 1200)
	var g1: float = RelationGraph.intensity_to(sl.relation_edges, "gratitude", 1200)
	print("★格5 恩 %.4f → 被動(只算價) %.4f → 報恩事件後 %.4f（消耗 %.4f）" % [g0, g_passive, g1, taken])
	_ok(absf(g_passive - g0) < 0.000001,
		"格5-a ★**被動不消耗**（★★降了 ⇒ **鐵則破**：算一次價就等於報了一次恩）")
	_ok(g1 < g0 - 0.001, "格5-b **報恩事件後恩下降**（★沒降 ⇒ 消耗邊沒接上）")
	_ok(taken > 0.0 and absf(taken - g0 * _w_of(sl)) < 0.0005,
		"格5-c 消耗量 ＝ `grat × W`（實測 %.4f）★**零新常數**：讓掉多少就報掉多少" % taken)
	_undecidable("格5-d（賠禮被收 ⇒ feud 降）",
		"和解（賠禮＝offer，對方秤決定收不收）被收下 ⇒ **消耗對方的怨**",
		"**求和今天沒有「被收下」這個狀態**：`interaction_system.gd:539-544` 的 `TASK_TRIBUTE_OFFER`"
		+ " 只做 `release + cooldown`，那段註解自己寫著「真息兵行為＝backlog」"
		+ "｜★★**而我沒有拿 `propose_alliance` 的 accept 頂替它** —— 結盟不是賠禮，"
		+ "★★★**用一個假的 offer 讓這一格變綠，比讓它不可判更糟**",
		"切片B（真息兵 handler：`sue_for_peace`／`offer_tribute`）")

	print("")
	print("★母體對帳：`grudge.form.feud`=%d｜`grudge.stack`=%d｜`grudge.consume.repay_trade`=%d｜`trade.grudge_markup.eval`=%d" % [
		int(Probe.counts.get("grudge.form.feud", 0)), int(Probe.counts.get("grudge.stack", 0)),
		int(Probe.counts.get("grudge.consume.repay_trade", 0)),
		int(Probe.counts.get("trade.grudge_markup.eval", 0))])
	print("-- 量測完成；[FAIL] 數 ＝ %d｜[不可判] 數 ＝ %d --" % [_fails, _undec])
	# ★★★【判準看橫幅，不看離開碼】（systems 立的規矩）：
	#   ★離開碼只有 runner 看得到，而**註冊表的 `expect` 是對著輸出比對的**
	#   ⇒ ★★所以「幾格不可判、是哪幾格」必須**印在結尾橫幅上**，不能只活在 exit code 裡。
	#   ★★★而 `expect` 釘的是【數量】：`[不可判] 2 格` ——
	#     **切片B 落地讓它變成 0 的那一天，這一閘會紅** ⇒ **那正是鬧鐘，不是要被修綠的東西。**
	print("[不可判] %d 格：%s" % [_undec, "／".join(_undec_names)])
	if _undec > 0:
		print("★★★**本床在切片B 落地前【不是綠的】** —— 這是蓄意的：")
		print("   ★「不可判」若換成綠，下一個人會以為那兩件事已經驗過了；")
		print("   ★★而若換成 [FAIL]，它會跟【真的壞了】混在一起 ⇒ **兩種紅要分得開。**")
