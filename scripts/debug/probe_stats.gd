# @observe-pure  ★observer-no-global-RNG 靜態閘納管(純觀測零 RNG;違=FAIL)
class_name Probe

# 量測累計器（純觀測）。enabled 預設 false → 一般跑 no-op；只 game_sim_test 開。
# 事件點插 1 行 Probe.bump(...)；結尾 Probe.summary()。禁改遊戲 state。
static var enabled: bool = false
static var counts: Dictionary = {}
static var peaks: Dictionary = {}
static var amounts: Dictionary = {}   # 浮點累計器（如鑄幣 coin 總量 ledger）
static var samples: Dictionary = {}   # event → Array[Dictionary]（≤cap 個具體 instance，聚合帶故事）

# ★★★熱路徑細節旗標（2026-09-04，血證＝90 日窗撞 3000s timeout）：
#   ★有些 tap 掛在【每 tick × 每個視野內 pair】的路上（例 `record_claim` 的同格分類）——
#     ★★它們自己很便宜，但乘上母體之後【會把長窗跑批跑不完】。
#   ★★★而「跑不完」與「跑完但沒有那一格」在下游長得不一樣：前者連尾標記都沒有。
#   ⇒ 這類 tap 掛在這個旗標下，預設 off；要那一格的人自己開（床讀 env 設）。
static var hot_detail: bool = false

# ★★★arm 順序自檢（bed-arm-helper §5①，R² 二審反轉後的形狀）：
#   ★觀察方向【反過來】：不是 arm 去問世界，是【建世界的那一刻回頭問 arm】
#     —— arm 當下世界還不存在，問不到。
#   ★★而這一欄【不走 bump()】、也【不看 enabled】：
#     若自檢自己包在 `if Probe.enabled` 裡，arm 太晚時 enabled == false ⇒ 自檢不執行
#     ⇒ ★★★循環自證（偵測「儀器沒開」的儀器自己沒開）。
#   ★★★而它【刻意不被 reset() 清掉】：典型盲床的順序正是
#     `GameSetup.setup()` → `Probe.reset(); enabled = true`
#     ⇒ 若 reset 會清它，證據會被【它要偵測的那個 bug 本身】抹掉。
static var setup_saw_unarmed: int = 0
static var setup_unarmed_sites: Array = []   # 呼叫端線索（stack 頂幾層），給人回頭找是哪張床

# ★由 GameSetup.setup() 呼叫；★★不檢查 enabled（見上），★★★不進 counts（reset 會清）。
# ★★★★而它【只記錄、不判定、不輸出】（systems 裁定 2026-09-01）：
#   ★正常遊戲【從不 arm Probe】⇒「setup 時未 armed」在 production 是【常態】不是異常
#   ⇒ ★★在這裡輸出＝條件恆真＝每次開局都印＝污染所有人的 log（且 bed-parse-gate 讀 stdout）
#   ⇒ ★★★所以【記錄】留在這裡（掛在一定會走的路），【判定】搬到 arm 那一刻。
static func note_setup_unarmed(hint: String = "") -> void:
	setup_saw_unarmed += 1
	if setup_unarmed_sites.size() < 20 and hint != "":
		setup_unarmed_sites.append(hint)

# ────────── 判定：arm 那一刻才發生 ──────────
# ★為什麼判定要在這裡而不是在 setup：
#   ★★production 沒有人 arm ⇒ 【判定根本不發生】⇒ 零噪音、零風險
#   ★★★床一 arm 就【立刻】知道自己晚了 —— 而 arm 是床一定會做的事
#   ⇒ 兩個時點各自掛在【該情境下一定會走】的路上，而不是掛在「有人來問」。
# ★實測前提：production（scripts/ui/*、scripts/simulation/*）零處呼叫 Probe.reset()
#   或寫 Probe.enabled = true —— 全域 grep 為空，所以這裡輸出對 production 是不可達的。
static var _late_arm_reported: bool = false

static func check_arm_order() -> void:
	if _late_arm_reported or setup_saw_unarmed == 0:
		return
	_late_arm_reported = true
	print("[ARM-ORDER] ★候選：本進程有 %d 次 GameSetup.setup() 在 Probe armed 之前跑過"
		% setup_saw_unarmed)
	print("[ARM-ORDER]   ⇒ 若那個世界【是】要被量的那個，它的 tap 是盲的，")
	print("[ARM-ORDER]     而少掉的數字與「那段沒發生」長得一模一樣。")
	print("[ARM-ORDER]   ★★這是【候選不是確診】：旗標是 process 全域的，")
	print("[ARM-ORDER]     ⇒ 多段床若有一段【完全不用 Probe】地建了世界，也會在這裡出現")
	print("[ARM-ORDER]     （血證 seam3_sysreg_test：第一段不用 Probe、第二段自己 arm 得好好的）。")
	print("[ARM-ORDER]   ★★★過度回報是【刻意的方向】：漏判會長得跟正常一模一樣，誤判只是多一次人判。")
	print("[ARM-ORDER]   ⇒ 處置：要量的那段改用 MeasureBedHelper.arm_and_setup()｜線索=%s"
		% str(setup_unarmed_sites))

# ★便利入口：床用它 arm 就自動帶判定（helper 走這條）。
static func arm() -> void:
	reset()
	enabled = true
	check_arm_order()

const AMBUSH_UNDEREST := 0.5   # TEST VALUE：belief 武力低估 < 真值 50% → 視為被誤導

static func bump(event: String, n: int = 1) -> void:
	if not enabled: return
	# ★判定時點②（catch-all）：有些床只寫 `Probe.enabled = true` 而不呼 reset()（實測 195 vs 218）
	#   ⇒ 光靠 reset() 會漏掉那一族。★★而「arm 了之後一定會寫至少一筆」是床的定義本身。
	#   ★★★成本＝兩個 bool 讀（_late_arm_reported 短路），只在真的晚 arm 時才走進去。
	if not _late_arm_reported and setup_saw_unarmed > 0: check_arm_order()
	counts[event] = int(counts.get(event, 0)) + n

# ★★★per-team 維度（systems 派 2026-08-26 / slice per-team-funnel-slice）：
#   ★病：漏斗只有【總量】⇒ 一支隊佔了 86%（Team6 70/81）就把其餘 11 隊蓋掉，
#     而「總數上升」被讀成「大家都變活躍」——★★今天第二次踩同型（material 均值 74 而實際只有 4/12 隊 ≥50）。
#   ★修：同一個事件同時記兩份 —— `event+day_suffix`（原樣不動）與 `event+".team.<id>"`（★總量，不逐日）。
#   ★★為什麼 per-team 不逐日：12 隊 × 十幾類 × 30 天 ⇒ key 爆炸而且沒人讀得完。
#   ★★★壞掉會長什麼樣：若有人只呼 `bump` 不呼 `bump_pt`，per-team 那一格【不會報錯，只會少一隊】，
#     而少掉的那一隊看起來就像「這隊那一段沒發生」——★與「這隊在那一段被漏記」完全同形。
#     ⇒ 讀的人必須拿【全隊名冊】當母體去對，不能只看 tap 印出來的那幾隊（床已照做）。
static func bump_pt(event: String, day_suffix: String, team_id: int, n: int = 1) -> void:
	if not enabled: return
	counts[event + day_suffix] = int(counts.get(event + day_suffix, 0)) + n
	var k: String = event + ".team." + str(team_id)
	counts[k] = int(counts.get(k, 0)) + n

static func note(event: String, value: float) -> void:
	if not enabled: return
	peaks[event] = maxf(float(peaks.get(event, 0.0)), value)

# 浮點累計（sum，非 peak）。ledger 用（鑄幣總量守恆審計）。
static func add_amount(event: String, value: float) -> void:
	if not enabled: return
	amounts[event] = float(amounts.get(event, 0.0)) + value

# 決定性聚合帶 bounded 具體案例（§④b）：計數 key 旁存 ≤cap 個 instance，落 fullprobe 供決策帶故事。
# ★first-N cap（size<cap 才 append），★禁 reservoir（reservoir 需 randf=違 observer-no-rng 鐵律）。純確定性。
# instance dict 由 caller 傳（{tick,team,res,...}），Probe 不算不 re-query（免耗 RNG/污染）。只寫 Probe.samples（禁改 sim state）。
static func bump_sample(event: String, instance: Dictionary, cap: int = 8) -> void:
	if not enabled: return
	var arr: Array = samples.get(event, [])
	if arr.size() < cap:
		arr.append(instance)
		samples[event] = arr

static func amount(event: String) -> float:
	return float(amounts.get(event, 0.0))

static func reset() -> void:
	# ★★★setup_saw_unarmed / setup_unarmed_sites 【刻意不清】——
	#   盲床的順序就是「先 setup、後 reset+arm」⇒ 清掉的話證據會被它要抓的那個 bug 抹掉。
	counts = {}; peaks = {}; amounts = {}; samples = {}
	_streak = {}
	_levy_last = {}
	# ★判定時點①：reset() 是床 arm 時一定會走的路（218 處呼叫），而 production 零處。
	check_arm_order()

# ★★★「卡在單一迴圈」的儀器（systems 判準 2026-09-05）——
#   ★判準是【同一 option 連續贏 ≥ N 次】★★且【該隊資源沒有下降】，兩條件缺一不可：
#     「一直贏同一個」單獨【不算】，它可能是【正確的持續行為】（例如持續維持據點）
#     ⇒ ★★★「資源沒下降」那半才排除掉「它正在解決問題」這個競爭解釋。
#   ★而 N【由實測分布定，不先手填】⇒ 這裡印的是【連勝長度的分布】，不是一個判定結果。
#   ★★零 RNG、純累加；★★★而它【只在 enabled 下動】，production 完全不走。
static var _streak: Dictionary = {}   # team_id → {opt,len,food0,coin0,food1,coin1}

static func note_winner(team_id: int, opt: String, food: float, coin: float) -> void:
	if not enabled: return
	var st: Dictionary = _streak.get(team_id, {})
	if st.is_empty() or String(st.get("opt", "")) != opt:
		if not st.is_empty(): _flush_streak(st)
		_streak[team_id] = {"opt": opt, "len": 1, "food0": food, "coin0": coin,
			"food1": food, "coin1": coin}
	else:
		st["len"] = int(st["len"]) + 1
		st["food1"] = food
		st["coin1"] = coin
		_streak[team_id] = st

static func _flush_streak(st: Dictionary) -> void:
	var n: int = int(st.get("len", 0))
	if n <= 0: return
	bump("winstreak.len.%03d" % clampi(n, 0, 999))
	bump("winstreak.opt.%s.len.%03d" % [String(st.get("opt", "?")), clampi(n, 0, 999)])
	# ★單點連勝（len==1）沒有「區間內資源變化」可談 ⇒ 不進資源欄（★否則分母被灌水）
	if n < 2: return
	var f0: float = float(st.get("food0", 0.0)); var f1: float = float(st.get("food1", f0))
	var c0: float = float(st.get("coin0", 0.0)); var c1: float = float(st.get("coin1", c0))
	var _fd: String = "down" if f1 < f0 else ("flat" if f1 == f0 else "up")
	bump("winstreak.food." + _fd)
	bump("winstreak.coin." + ("down" if c1 < c0 else ("flat" if c1 == c0 else "up")))
	# ★★★判準的【兩條件交叉】：長度分帶 × 資源有沒有下降 —— ★這才是 systems 要的那張表
	bump("winstreak.cross.%s.%s" % [
		("02to04" if n < 5 else ("05to09" if n < 10 else ("10to19" if n < 20 else "20up"))),
		("res_down" if f1 < f0 else "res_not_down")])

# ★跑批結尾必呼：★★否則【還沒結束的那一段連勝】永遠不進分布 —— 而長連勝正是最可能還沒結束的那些
static func flush_all_streaks() -> void:
	for k in _streak.keys(): _flush_streak(_streak[k])
	_streak = {}

# ★★★`徵收` 重複頻率（blueprint pre-register 2026-09-05）——
#   ★要的是【同一 pair 連續兩次徵收的間隔分布】，★★不是平均：
#     平均會把「一對每小時收一次」與「很多對各收一次」混成同一個數字。
#   ★★★故事尺（blueprint 原話）：天天來收稅＝惡政喜劇；收一次飽一陣＝健康政權。
static var _levy_last: Dictionary = {}   # "collector-payer" → tick

static func note_levy(collector_id: int, payer_id: int, tick: int) -> void:
	if not enabled: return
	var k: String = "%d-%d" % [collector_id, payer_id]
	if _levy_last.has(k):
		var gap: int = tick - int(_levy_last[k])
		var hours: int = gap / 60   # TICKS_PER_HOUR=60（★這裡只用來分帶，不進任何決策）
		bump("levy.gap.%s" % (
			"0_未滿1時" if hours < 1 else (
			"1_1到6時" if hours < 6 else (
			"2_6到24時" if hours < 24 else (
			"3_1到3日" if hours < 72 else (
			"4_3到7日" if hours < 168 else "5_超過7日"))))))
		bump_sample("levy.gap.row", {"collector": collector_id, "payer": payer_id,
			"gap_ticks": gap, "gap_hours": hours}, 24)
		bump("levy.pair.repeat")
	else:
		bump("levy.pair.first")
	_levy_last[k] = tick

static func ambush_check(state: WorldState, attacker_id: int, defender_id: int) -> void:
	if not enabled: return
	var defender = state.teams.get(defender_id)
	if defender == null: return
	var bel: Dictionary = BeliefSystem.best_estimate(state, attacker_id, defender_id)
	if bel.is_empty(): return
	var bel_str: float = float(bel.get("armed_est", bel.get("population_est", 0.0)))
	var real_str: float = float(defender.population)   # 真實力 proxy（armed 解算在戰鬥，pop 為穩定 proxy）
	if real_str > 0.0 and bel_str < real_str * AMBUSH_UNDEREST:
		bump("g3.ambush")

static func _rate(num_key: String, den_key: String) -> String:
	var den: int = int(counts.get(den_key, 0))
	if den == 0: return "n/a"
	return "%.1f%%" % (100.0 * float(counts.get(num_key, 0)) / float(den))

static func summary() -> void:
	print("\n========== [ProbeSummary] ==========")
	var keys: Array = counts.keys(); keys.sort()
	for k in keys:
		print("[ProbeSummary] %-28s = %d" % [k, int(counts[k])])
	for k in peaks:
		print("[ProbeSummary] %-28s peak= %.1f" % [k, float(peaks[k])])
	# 衍生率
	print("[ProbeSummary] 礦村建立次數  = %d" % int(counts.get("g1.mine_founded", 0)))
	print("[ProbeSummary] 鑄幣次數     = %d" % int(counts.get("g1.mint", 0)))
	print("[ProbeSummary] 訂單履約率   = %s" % _rate("g1.order_fulfilled", "g1.order_placed"))
	print("[ProbeSummary] 套利命中率   = %s" % _rate("g1.arb_hit", "g1.arb_attempt"))
	print("[ProbeSummary] scout 收斂率 = %s" % _rate("g3.scout_converge", "g3.scout_dispatch"))
	# 征服名實斷點：想=征服(conq.intent) 的隊在 _decide_unified 實際 winner 分布 + 掠奪達 capture 率
	print("[ProbeSummary] 征服intent winner: loot=%s prosp=%s other=%s none=%s" % [
		_rate("conq.winner_loot", "conq.intent"), _rate("conq.winner_prosperity", "conq.intent"),
		_rate("conq.winner_other", "conq.intent"), _rate("conq.winner_none", "conq.intent")])
	print("[ProbeSummary] prosperity-attack 走到 = %d 次" % int(counts.get("conq.prosperity_reached", 0)))
	print("[ProbeSummary] 掠奪達capture率(占總capture) = %s (by_attack=%d)" % [
		_rate("loot.achieved_capture", "capture.total"), int(counts.get("capture.by_attack", 0))])
	print("====================================")
