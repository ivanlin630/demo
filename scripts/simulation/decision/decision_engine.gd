class_name DecisionEngine

# 統一決策引擎：一隊一個 decide()。utility weigh + 承諾慣性（單一決策生產者）。
# 蒐集 DecisionContext → 列候選 Option → 每 option util = Σ(人格權重 × 驅力 term)
# + 現行 option 承諾 bonus → argmax。平手 → 保持現行（承諾慣性防震盪）。
const COMMITMENT_BONUS: float = 0.3   # TEST VALUE：承諾慣性（防震盪）
const PRODUCE_WANT_THRESH: float = 0.3   # TEST VALUE — produce_pull>此=有意義想產（wanted_not_chosen tap 過濾噪音）
# 層0 安全氣囊：極低糧→survival-class option 加法超量級，突破 coeff [0,1] 天花板奪回 argmax。
# floor 低→正常隊靠層1/2/5 安全網不觸發；boost 觸發頻率=健康指標(常觸發=安全網失職)。
const SURVIVAL_BOOST_FLOOR: float = 2.0   # TEST VALUE — 極低糧門檻(遠低人格安全存量,安全氣囊非日常剎車)
const SURVIVAL_BOOST_MAX: float = 2.5     # TEST VALUE — food→0 時 survival util +此(碾壓任何 dev,復原舊 12 域碾壓力)
# ★threat-oracle S2 break-top boost（TEST VALUE，measure 校；★硬約束 THREAT_BOOST_MAX < SURVIVAL_BOOST_MAX）
const THREAT_BOOST_FLOOR: float = 1.0     # TEST VALUE(S2 calibrate ↑0.6)— boost 只在真高威脅(organic:threat 碾平經濟修)
const THREAT_BOOST_MAX: float = 0.5       # TEST VALUE(S2 calibrate ↓1.2)— <survival 2.5；organic 迎戰 over-shoot 修

# ── ② 絕境階梯失敗回饋（spec 2026-07-18-desperation-ladder-failure-feedback v2）──
# 根:SURVIVAL_BOOST 集體等量 order-preserving→最高 base-weight 格恆贏,卡格 latch(QA 7隊33+天不換序,action 從未 resolve)。
# 修:committed option stall 偵測(relief before/after magnitude,禁瞬時)→硬排除 bounded window(reject_cooldown idiom,鏡射
#   diplomatic_ai_system.gd:5 REJECT_COOLDOWN)→argmax 換次格產階梯。單一 option 豁免(無次格 ride 窮死非 idle-churn)。
enum { STALL_WAITING, STALL_RESOLVING, STALL_STALLED }
const STALL_BASE_DAYS: float = 8.0        # TEST VALUE — 耐性基準天(× patience_factor;latch 33+天前介入升級)
const STALL_RELIEF_MIN: float = 1.0       # TEST VALUE — food_days 較 baseline 回升 ≥此 才算 resolving(非「沒更低就算解」)
# TIER: n/a — 語意時長非節律（某事多久算過期，不是多久評一次）
const STALL_EXCLUDE_WINDOW: int = WorldState.TICKS_PER_DAY * 20   # TEST VALUE — 硬排除窗(> STALL_DAYS max 防 A 太快回來 ping-pong)
const STALL_PATIENCE_MIN: float = 0.5     # patience clamp 下限(急換者)
const STALL_PATIENCE_MAX: float = 1.5     # patience clamp 上限(撐久者)

# stall 判定：before/after relief-magnitude（禁瞬時比昨日；比 committed baseline）。純函式（可測）。
static func stall_verdict(committed_tick: int, committed_food: float, cur_tick: int, cur_food: float,
		stall_ticks: int, relief_min: float) -> int:
	if cur_tick - committed_tick < stall_ticks:
		return STALL_WAITING   # 未到判定窗(耐性)——不早判
	if cur_food - committed_food >= relief_min:
		return STALL_RESOLVING   # relief 足→X 起作用,留它(重置 stall)
	return STALL_STALLED   # relief 不足(含 plateau 慢產/惡化)→升級換格

# 耐性人格 factor：慎重↑撐久、求生欲↑急換。禁虛構 trait（person_data 無「堅忍」，只用既有 慎重/求生欲）。
static func stall_patience_factor(leader_values: Dictionary) -> float:
	var caution: float = float(leader_values.get("慎重", 0.5))
	var survival: float = float(leader_values.get("求生欲", 0.5))
	return clampf(caution + (1.0 - survival), STALL_PATIENCE_MIN, STALL_PATIENCE_MAX)

# ② EXCLUDE + design-5 單一 option 豁免收進 DecisionOptions.applicable()（單一源，全 rank 路共用）——
# 舊 apply_stall_exclusion（rank_survival-only 半路豁免）已退役，避「機制部分路非全路」。

# options 依 util 降序（index tiebreak：util 相等→applicable 順序在前者勝，同 argmax strict >）。
# 排序後帶 util 的 scored 陣列 [{u,i,opt}, ...]（降序）。rank() 只取 opt；
# 量測探針（征服名實）要讀 util 排序根 → 走此無損 accessor（不重算 term loop）。
static func rank_scored(state: WorldState, team: TeamData) -> Array:
	GoalResolver.ensure_maintain_goals(state, team)   # ★means-end S2（組件 A）:冪等確保 5 資源維持 goal + 更新 active/satisfied
	var ctx: DecisionContext = DecisionContext.gather(state, team, true)   # ★真決策評估入口 → 推進 EWMA（advance=true）
	var scored: Array = rank_scored_ctx(ctx, team.current_option, state, team)   # ★means-end:傳 state/team 供 goal frontier hook
	# ★★★flee-to-safety 驗收③：【因為沒有 believed 目的地而改派去哪】—— ★記【去向分布】不只記備戰。
	#   ★★只記「備戰幾次」會漏掉「其實跑去覓食了」那種答案，而那正是「恐懼有沒有被吞掉」要看的。
	#   ★★★母體＝有威脅座標＋怕過門檻＋無目的地（＝原本會選 FLEE、現在不 applicable 的那批）。
	#   ★而恆 0 不等於退化路好好的 —— ★★它也可能是母體塌陷（沒人落進來），兩種要拿 gather 的兩個 band 桶分開。
	if Probe.enabled and ctx.threat_pos != Vector2i(-1, -1) and ctx.flee_dest == Vector2i(-1, -1) \
			and ctx.threat_react >= ctx.threat_threshold:
		Probe.bump("flee.degrade.total")
		Probe.bump("flee.degrade.top_" + (String(scored[0]["opt"]) if not scored.is_empty() else "NONE"))
	_beg_tap(ctx, scored, team, "begu.")   # ★#12：統一全 pool 路的乞食命中（★★與絕境階梯路分開記）
	_prep_tap(ctx, scored, team)   # ★備戰 root-check（純觀測）
	SpecimenTracer.capture_options(state, team, scored, ctx)   # specimen tap（no-op-unless-specimen）；ctx 帶 threat 來源
	return scored

# ctx-taking 純打分 accessor（鏡射 rank_threat(ctx)）：不 gather、不寫 current_option、不 specimen tap。
# 融合驗 harness 手構 ctx 驗 rank（繞世界 setup，deterministic）；rank_scored 委派此避重複 loop。
# ★means-end（組件 G）：加 optional state/team 供 goal frontier hook（harness 手構 ctx 無此→null→hook skip）。
static func rank_scored_ctx(ctx: DecisionContext, current_option: String = "", state: WorldState = null, team: TeamData = null) -> Array:
	var scored: Array = []
	var idx: int = 0
	# ★持守統一 Slice 1：current_option 承諾慣性讀 persist_strength（人格加權沉沒成本，取代 flat COMMITMENT_BONUS）。
	# 迴圈前算一次（cadence 級，per-team 定值）；harness 無 team → 退回 flat（測不破）。
	var _persist: float = PersistStrength.compute(state, team) if team != null else COMMITMENT_BONUS
	for opt in DecisionOptions.applicable(ctx):
		var u: float = 0.0
		for tw in DecisionOptions.terms_of(opt):
			u += DecisionTerms.weight(tw[1], ctx.leader_values) * DecisionTerms.eval(tw[0], ctx, opt)
		# 需求金字塔重構：五層急迫度一致性係數(§3)統一調變全 23 option。純乘一係數，不改 term 內部。
		# ★乘在 COMMITMENT_BONUS 之前（承諾慣性是決策層加成，不受需求調變）。
		var _coeff: float = NeedHierarchy.consistency_coeff(opt, ctx.need_urgency, ctx.leader_values)
		u *= _coeff
		# ★執行失敗反饋（用戶立法 2026-08-21）：同一原因反覆撞 → 連續折價（非硬 cooldown、非新 term 線）。
		# ★乘在 survival/threat 破頂【加法】boost 之前 → 絕境仍能壓過折價再試（FLOOR + 加法 boost 雙保險，
		# 不得絕對否決）。未接線的 option 恆 1.0 ＝ 對其餘 option 零行為。
		if team != null:
			u *= FailureMemory.mult_for_option(state, team, opt)
		# 層0 安全氣囊（★插在 coeff 乘法之後——寫死此序：coeff 前會被 0.15 floor 打折失效）：
		# 極低糧時 survival-class 加法超量級破頂，隨 food→0 線性放大，奪回 argmax。全 SURVIVAL_OPTION_SET 等量加
		# (不改 survival-class 內部相對序，只集體破頂)。food_days=FLOOR 時加成=0 平滑銜接無 flip-flop。
		if ctx.food_days < SURVIVAL_BOOST_FLOOR and DecisionOptions.is_in_set(opt, "survival"):
			u += SURVIVAL_BOOST_MAX * (SURVIVAL_BOOST_FLOOR - ctx.food_days) / SURVIVAL_BOOST_FLOOR
			if Probe.enabled: Probe.bump("survival.boost_fire")   # 觸發頻率=健康指標(measurer 要)
		# ★threat-oracle S2 break-top boost（解 skeptic finding3 單 term-多 term 不匹配）：severity≥FLOOR 時
		# threat option 加法破頂 ∝ severity（鏡射 survival，全 THREAT_OPTION_SET 等量加，保內部序）
		# ★capped 且 < survival boost(2.5)：threat=belief→survival(存亡)保序不破；blueprint② 非偽裝硬閘。
		if ctx.threat_react >= THREAT_BOOST_FLOOR and DecisionOptions.is_in_set(opt, "threat"):
			u += THREAT_BOOST_MAX * clampf((ctx.threat_react - THREAT_BOOST_FLOOR) / (DecisionTerms.SEVERITY_MAX - THREAT_BOOST_FLOOR), 0.0, 1.0)
			if Probe.enabled: Probe.bump("threat.boost_fire")
		if Probe.enabled and ctx.need_urgency.size() == NeedHierarchy.N_LAYERS:
			Probe.bump("decision.coeff_applied_n")   # 全 23 option 受 coeff 覆蓋計數
			if _coeff < 0.5: Probe.bump("decision.coeff_lowhalf")   # 遠層被顯著壓比例
			# per-option probe（①全覆蓋/④不死鎖，比照 rung_dist；純觀測零行為變）
			Probe.bump("decision.opt_applicable." + opt)          # 候選分母
			if _coeff < 1.0: Probe.bump("decision.opt_coeff_pressed." + opt)   # coeff 確隨急迫度變(非恆1)
		if opt == current_option:
			u += _persist   # ★持守統一：flat COMMITMENT_BONUS → persist_strength（bonus-collapse）
		scored.append({"u": u, "i": idx, "opt": opt})
		idx += 1
	# ★means-end 長程規劃（組件 G，HOW §8）：goal frontier candidates 追加進同一 rank 池（sort 前→與 static option 同 argmax 競爭）。
	# ★S1 骨架：GoalResolver.frontier_candidates stub 回 []→此迴圈 no-op→byte-identical。harness 無 state/team(null)→skip。
	# S2+ candidate util 護欄（HOW §8 must-fix①）：走 dev_urgency 壓制 + 上界<survival boost（發展慾望絕不蓋活命）。
	if state != null and team != null:
		for cand in GoalResolver.frontier_candidates(state, team, ctx):
			if Probe.enabled:
				var _ctt: Dictionary = (cand.get("to_task", {}) as Dictionary)
				if _ctt.has("build_type"):
					Probe.bump("goal.cand_build_emitted")
					Probe.bump("goal.cand_build_day.%03d" % int(state.world.current_tick / WorldState.TICKS_PER_DAY))
				# ★★施工漏斗 ①段【分母】(2026-08-26)：既有的 `cand_build_emitted` 只數 build 那一類
				#   ⇒ 「贏了幾次」沒有可比的母數。★這裡數【所有】goal candidate 的產出。
				#   ★key 有界：goal_type（`GoalRegistry` 有限），不是 label（label 帶 target 會爆 key）。
				Probe.bump("funnel.cand.emitted")
				# ★★★時間軸（systems 派 2026-08-26）：30 天的總數說不出【沉默從哪一天開始】。
				#   ★壞掉會長什麼樣：`by_goal.maintain_material = 125` 讀起來像「30 天都在生」，
				#     而實際可能全部集中在開局那一個 tick —— ★attempt 那顆就是這樣（39 次全在 tick 10）。
				#   ★key 有界：按【日】分桶（30 天 → 30 個 key），不是每個 tick 一個。
				var _day: int = int(state.world.current_tick / WorldState.TICKS_PER_DAY)
				Probe.bump("funnel.cand.day.%03d" % _day)
				if (cand.get("to_task", {}) as Dictionary).has("build_type"):
					Probe.bump("funnel.cand.build.day.%03d" % _day)   # ★build 類還生不生得出來
				# ★goal_type 在 `source_goal` 裡，不在 candidate 頂層（`_mk_candidate` 回
				#   {util,to_task,source_goal,label,delegate}）——★第一版我讀頂層，結果 845 筆全部落到 "?"。
				#   ★★那正是我這兩天一直在替別人修的那顆病（欄位讀空→key 說謊），這次是我自己造的。
				# ★★仍有一類【本來就沒有 source_goal】：後勤那兩支 candidate 不走 `_mk_candidate`
				#   （`goal_resolver:222 distribute_food` / `:312 deliver_<res>`）⇒ 它們的 `?` 是【真實類別】
				#   不是讀錯層。★用 label 當它們的名字，不要讓兩種不同的原因共用同一個 "?"。
				var _sg: Dictionary = (cand.get("source_goal", {}) as Dictionary)
				var _gt_key: String = String(_sg.get("goal_type", ""))
				if _gt_key == "":
					_gt_key = "no_source_goal:" + String(cand.get("label", "?"))
				Probe.bump("funnel.cand.by_goal." + _gt_key)
				# ★★★逐筆樣本帶 `tick` 與 `team`（systems 併進本段 2026-08-26）：
				#   ★counter 說得出「發生幾次」，說不出【是誰】在【第幾 tick】
				#   ⇒ 「同一支隊在同一 tick 提了多個 candidate」（一個行動穿多件戲服）
				#     與「不同隊各提一次」在計數上長得一模一樣，而意義完全不同。
				#   ★欄位名與 `means_end.candidate_identity` 對齊，免得下游寫兩套解析。
				Probe.bump_sample("funnel.cand.identity", {
					"tick": state.world.current_tick, "team": team.team_id,
					"goal": _gt_key, "label": String(cand.get("label", "")),
					"target": (cand.get("to_task", {}) as Dictionary).get("target"),
					"util": snappedf(float(cand.get("util", 0.0)), 0.0001)}, 500)
			scored.append({"u": float(cand.get("util", 0.0)), "i": idx, "opt": String(cand.get("label", "")), "cand": cand})
			idx += 1
	scored.sort_custom(func(a, b):
		if a["u"] != b["u"]: return a["u"] > b["u"]
		return a["i"] < b["i"])   # tiebreak：applicable 順序
	# ★★won_argmax（systems 要）：【產出】≠【贏】。
	#   emitted > 0 且 fp 不變 可以同時為真，而最危險的解釋是
	#   「接上了、有產出、但【從不改變結果】」——沒這顆 tap 就分不出來。
	if Probe.enabled and not scored.is_empty():
		var _w: Dictionary = (scored[0].get("cand", {}) as Dictionary)
		if bool(_w.get("means_end", false)):
			Probe.bump("means_end.won_argmax")
		# ★★★施工漏斗 ①段【贏了沒／排第幾】(2026-08-26)：
		#   ★勝負要有【成對】的分母：winner 是 candidate 還是 static option，兩邊都數
		#     ⇒ 只有「贏了 N 次」而沒有「總共決策幾次」，正是 33→41 那個坑。
		#   ★★「排第幾」比「贏沒贏」多一個維度：差一名與差二十名是不同的病
		#     ——bucket 化（有界 key），不是每個名次一個 counter。
		Probe.bump("funnel.decide.total")
		# ★★★`state` 是【預設 null 的參數】（本函式簽名 :58）——單元測試就有不傳的呼叫端。
		#   ★我這顆 tap 原本無條件寫 `state.world.current_tick` ⇒ 那些呼叫端一旦 Probe.enabled 就【崩潰】。
		#     實測：`Invalid get index 'world' (on base: 'Nil')` —— ★★觀測把被觀測的世界弄掛了。
		#   ★★★而修法【不是靜靜跳過】：跳過會讓日桶少計、而總量照計 ⇒ 我自己建的對帳式無聲變不平。
		#     ⇒ 給它一個【看得見的桶】`.day.no_state`：對帳仍然平，而異常自己會冒出來。
		var _dsuf: String = (".day.%03d" % int(state.world.current_tick / WorldState.TICKS_PER_DAY)) if state != null else ".day.no_state"
		Probe.bump("funnel.decide%s" % _dsuf)   # ★分母也要有時間軸，否則比例算不出來
		if _w.is_empty():
			Probe.bump("funnel.decide.winner_static")
			Probe.bump("funnel.decide.winner_static%s" % _dsuf)
		else:
			Probe.bump("funnel.decide.winner_cand")
			Probe.bump("funnel.decide.winner_cand%s" % _dsuf)
			Probe.bump("funnel.decide.winner_cand.by_goal." + String((_w.get("source_goal", {}) as Dictionary).get("goal_type", "?")))
		var _best_rank: int = -1
		for _ri in range(scored.size()):
			if not (scored[_ri].get("cand", {}) as Dictionary).is_empty():
				_best_rank = _ri
				break
		if _best_rank >= 0:
			var _bucket: String = "0_won" if _best_rank == 0 else \
				("1_2" if _best_rank <= 2 else ("3_5" if _best_rank <= 5 else "6plus"))
			Probe.bump("funnel.cand.best_rank." + _bucket)
			# ★贏不了的時候，【輸給誰、差多少】才是可行動的資訊（鏡射既有 camp.lost_to 形狀）
			if _best_rank > 0:
				Probe.bump_sample("funnel.cand.lost_to", {
					"cand": String(scored[_best_rank].get("opt", "")),
					"cand_util": snappedf(float(scored[_best_rank].get("u", 0.0)), 0.0001),
					"winner": String(scored[0].get("opt", "")),
					"winner_util": snappedf(float(scored[0].get("u", 0.0)), 0.0001),
					"rank": _best_rank,
					"team": team.team_id if team != null else -1,
					"tick": state.world.current_tick}, 200)
		# ★★per-option util dump（systems 派）：要的是【對照】不是一個數字。
		#   ★差 2 倍 vs 差 100 倍 是完全不同的病；而【贏的那一次】是唯一真改變世界的案例。
		#   ★懷疑點(i) depth 指數衰減／(ii) payoff 恆等 —— 兩欄都 dump，讓數字自己分。
		var _best_me: Dictionary = {}
		for _e in scored:
			var _c2: Dictionary = (_e.get("cand", {}) as Dictionary)
			if bool(_c2.get("means_end", false)):
				_best_me = {"u": float(_e.get("u", 0.0)), "cand": _c2}
				break
		if not _best_me.is_empty():
			var _mc: Dictionary = (_best_me["cand"] as Dictionary)
			Probe.bump_sample("means_end.util_vs_winner", {
				"me_util": snappedf(float(_best_me["u"]), 0.0001),
				"winner_util": snappedf(float(scored[0].get("u", 0.0)), 0.0001),
				"winner_opt": String(scored[0].get("opt", "")),
				"me_won": bool(_w.get("means_end", false)),
				"depth": int(_mc.get("me_depth", -1)),
				"payoff": snappedf(float(_mc.get("me_payoff", 0.0)), 0.0001),
				"res": String(_mc.get("me_res", "")),
				# ★是【哪一支隊】(2026-08-26)：沒這欄就只有分佈、沒有【故事的主角】，
				#   specimen 選樣也無從指名（先前只能全隊掃或猜）。純 tap 欄位，不參與任何判斷。
				"team": team.team_id if team != null else -1,
				"tick": state.world.current_tick}, 200)
	# ★接入 arc 常設可觀測（gate4 失敗反饋：反覆不 fire 要能被看見，不得靜默）：
	#   紮營 applicable 卻不是 argmax → 記「輸給誰、差多少」；贏了記 camp.won_argmax。
	if Probe.enabled and not scored.is_empty() and team != null:
		for e in scored:
			if String(e["opt"]) == "紮營":
				if String(scored[0]["opt"]) != "紮營":
					Probe.bump("camp.lost_to." + String(scored[0]["opt"]))
					Probe.bump_sample("camp.lost", {
						"team": team.team_id, "camp_u": snappedf(float(e["u"]), 0.001),
						"winner": String(scored[0]["opt"]), "win_u": snappedf(float(scored[0]["u"]), 0.001),
						"food_days": snappedf(ctx.food_days, 0.01),
					}, 30)
				else:
					Probe.bump("camp.won_argmax")
				break
		# ★紮根（L0→L1）funnel 可觀測：驗收 #1 是二值（l0_to_l1 > 0），要能分辨
		#   「沒 applicable」vs「applicable 但秤輸」——否則 0 只是個沒有解釋的 0。
		for e in scored:
			if String(e["opt"]) == "紮根":
				if String(scored[0]["opt"]) != "紮根":
					Probe.bump("root.lost_to." + String(scored[0]["opt"]))
					# ★measurer L3 tap(2026-08-25,exact-pair-hitrate票)：輸家(team,target)配對,供distinct-target計算
					var _wcand: Dictionary = (scored[0]["cand"] as Dictionary) if scored[0].has("cand") else {}
					var _wtgt = _wcand.get("target", (_wcand.get("to_task", {}) as Dictionary).get("target", null))
					Probe.bump_sample("root.lost_to.pair", {"team": team.team_id,
						"winner": String(scored[0]["opt"]), "target": (str(_wtgt) if _wtgt != null else "無")}, 200)
				else:
					Probe.bump("root.won_argmax")
				break
	# per-option 選中分布（argmax=rank[0]；判「applicable 過但選中恆 0」=結構性死鎖 ④）
	if Probe.enabled and not scored.is_empty() and ctx.need_urgency.size() == NeedHierarchy.N_LAYERS:
		Probe.bump("decision.opt_chosen." + String(scored[0]["opt"]))
		# ★製造 bootstrap 子根②觀測：想產(produce_pull>THRESH，含 facility)但落選(rank[0]≠生產)→task-competition 輸
		# （供 QA 判②demand-responsive 後是否仍卡於 rank；純觀測零行為變、Probe-gated 無 RNG）。
		if ctx.produce_pull > PRODUCE_WANT_THRESH and String(scored[0]["opt"]) != "生產":
			Probe.bump("produce.wanted_not_chosen")
		# ★B idle-labor→建設 觀測（全量 tap、§5#4）：閒 PRODUCE 勞力有 genuine 建產能價值→是否選建
		# （QA/§8 判 idle→build 因果 + genuine 邊界）。純觀測、Probe-gated、零 RNG、零行為變。
		if ctx.idle_employ_value > 0.0:
			Probe.bump("idle_employ.value_positive")
			if String(scored[0]["opt"]) == "建設":
				Probe.bump("idle_employ.build_chosen_with_idle")
		# 診斷(裁A)：zero-option 三類分流（coeff-lockout / base-util 競爭 / applicable 稀有）。純觀測。
		var winner: Dictionary = scored[0]
		for e in scored:
			if e["opt"] == winner["opt"]: continue
			var opt: String = e["opt"]
			var cf: float = NeedHierarchy.consistency_coeff(opt, ctx.need_urgency, ctx.leader_values)
			var ml: int = NeedHierarchy.main_layer_of(opt)
			Probe.bump("diag.%s.appl_n" % opt)                                  # 分母:applicable-but-lost
			Probe.add_amount("diag.%s.coeff_sum" % opt, cf)                     # 平均 coeff
			if cf < 0.5: Probe.bump("diag.%s.coeff_pressed" % opt)             # coeff-lockout 候選
			Probe.add_amount("diag.%s.mainurg_sum" % opt, ctx.need_urgency[ml] if ml >= 0 else 0.0)  # 主層 urgency
			Probe.add_amount("diag.%s.ownutil_sum" % opt, float(e["u"]))       # 自己 util(post-coeff)
			Probe.add_amount("diag.%s.winutil_sum" % opt, float(winner["u"]))  # winner util
	return scored

# ★F4：PASSIVE_SURVIVAL_SET const 已刪、單源 REGISTRY[opt].sets.passive_survival（is_in_set 讀）。
# 被動求生 repertoire：覓食/買糧/乞食/返家補給/紮營/併入/自救建田=被動求生→"survival" 一組保 fallthrough。
# 需求分組：passive_survival 成員→"survival"（不看 affinity）；非→按 affinity 主層。
static func _need_category(opt: String) -> String:
	if DecisionOptions.is_in_set(opt, "passive_survival"):
		return "survival"
	return "L%d" % NeedHierarchy.main_layer_of(opt)

# 同需求 fallthrough：rank[0] 不可 dispatch 時，落同需求組的次佳（非跨組落生產）。
# same-cat 在前、其餘在後，各組保 util 降序（穩定 partition）。rank[0] dispatchable→仍首試=NO-OP。純函式零 randf。
static func reorder_same_need_first(ranked: Array) -> Array:
	if ranked.size() <= 1:
		return ranked
	var top_cat: String = _need_category(String(ranked[0].get("opt", "")))
	var same: Array = []
	var rest: Array = []
	for e in ranked:
		if _need_category(String(e.get("opt", ""))) == top_cat:
			same.append(e)
		else:
			rest.append(e)
	return same + rest

static func rank(state: WorldState, team: TeamData) -> Array:
	var out: Array = []
	for e in rank_scored(state, team): out.append(e["opt"])
	return out

# survival-class 子集排序（P2b-1：non-unified _trigger_survival 委派用）。
# 同 rank()，但 applicable 過濾到 SURVIVAL_OPTION_SET；不寫 team.current_option
# （non-unified 隊 current_option 由 faction_ai 非-survival 行為管，survival dispatch 不奪）。
# 承諾慣性比對 team.current_task（non-unified 無 current_option 語意）。
static func rank_survival(state: WorldState, team: TeamData) -> Array:
	var ctx: DecisionContext = DecisionContext.gather(state, team, true)   # ★真決策評估入口 → 推進 EWMA（advance=true）
	# ② 絕境階梯：applicable() 已收單一源 stall 排除 + 單一 option 豁免（全 rank 路共用）→ 此處直取 survival 子集。
	var candidates: Array = []
	for opt in DecisionOptions.applicable(ctx):
		if DecisionOptions.is_in_set(opt, "survival"): candidates.append(opt)
	var scored: Array = []
	var idx: int = 0
	# ★持守統一 Slice 1：survival churn 防抖承諾慣性讀 persist_strength（取代 flat COMMITMENT_BONUS）。迴圈前算一次。
	var _persist: float = PersistStrength.compute(state, team) if team != null else COMMITMENT_BONUS
	for opt in candidates:
		var u: float = 0.0
		for tw in DecisionOptions.terms_of(opt):
			u += DecisionTerms.weight(tw[1], ctx.leader_values) * DecisionTerms.eval(tw[0], ctx, opt)
		# churn 防抖：比對 previous_task（非 current_task）——survival-latch relatch 路 release→current_task=IDLE，
		# previous_task 保留 release 前 survival task，防餓隊每 cadence 亂跳（覓食/買糧/掠奪/併入）。
		# 常態路 previous_task==current_task（_trigger_survival 設）→等價。
		if DecisionOptions.to_task(state, team, opt).get("task") == team.previous_task:
			u += _persist   # ★持守統一：flat COMMITMENT_BONUS → persist_strength（bonus-collapse）
		scored.append({"u": u, "i": idx, "opt": opt})
		idx += 1
	scored.sort_custom(func(a, b):
		if a["u"] != b["u"]: return a["u"] > b["u"]
		return a["i"] < b["i"])
	# ★★★#12 乞食 dump（純觀測）—— ★兩條 rank 路都要記：
	#   乞食 的 sets 是 `{survival, passive_survival}` ⇒ ★★它【同時】在 rank_survival 的子集裡，
	#   也在 rank_scored 的全 pool 裡 ⇒ ★★★只監一條會把另一條的命中讀成 0。
	_beg_tap(ctx, scored, team, "beg.")
	SpecimenTracer.capture_options(state, team, scored, ctx)   # specimen tap（no-op-unless-specimen）；ctx 帶 threat 來源
	var out: Array = []
	for e in scored: out.append(e["opt"])
	return out

# 融合 threat 子集排序（序1 溶入：non-unified _evaluate_threat 委派用，鏡射 rank_survival）。
# 取 ctx（呼叫端已 gather，避重算）→ applicable ∩ THREAT_OPTION_SET → util 秤 → 降序。
# 無 commitment bonus（鏡射舊 _dispatch_threat_response 純 argmax；threat 每 cadence idle 才重觸發）。
# ★F4：THREAT_OPTION_SET const 已刪、單源 REGISTRY[opt].sets.threat（is_in_set 讀）。survival=FLEE(逃跑)。

static func rank_threat(ctx: DecisionContext) -> Array:
	var scored: Array = []
	for opt in DecisionOptions.applicable(ctx):
		if not DecisionOptions.is_in_set(opt, "threat"): continue
		var u: float = 0.0
		if opt == "survival":
			# threat repertoire FLEE：鏡射舊 _dispatch survival*0.8 + (threat_react−0.5)*0.3。
			# 用 raw threat_react（非 threat_pressure term 的 reputation-filtered ctx.threat，該 term 服務主 rank
			# unified survival，語意較軟）→ 高 raw 威脅 survival leader 恆逃（faithful to old）。
			u = float(ctx.leader_values.get("求生欲", 0.5)) * 0.8 + (ctx.threat_react - 0.5) * 0.3
		else:
			for tw in DecisionOptions.terms_of(opt):
				u += DecisionTerms.weight(tw[1], ctx.leader_values) * DecisionTerms.eval(tw[0], ctx, opt)
		scored.append({"opt": opt, "u": u})
	scored.sort_custom(func(a, b): return a["u"] > b["u"])
	var out: Array = []
	for s in scored: out.append(s["opt"])
	return out

# 融合 ambient 子集排序（序3 follow-up：idle-filler 委派用，鏡射 rank_threat）。
# 取 ctx（呼叫端已 gather，避重算）→ applicable ∩ AMBIENT_OPTION_SET → util 秤 → 降序 → opt 字串陣列。
# 無 survival 特例、無 commitment：ambient 只填 idle；team 到此已過 loop3 survival/threat/prosperity 評估，
# ambient 不該二次猜生存/威脅 → 排除 survival/FLEE/threat option（收窄 idle 隊次門檻 FLEE churn）。
# ★F4：AMBIENT_OPTION_SET const 已刪、單源 REGISTRY[opt].sets.ambient（is_in_set 讀）。

static func rank_ambient(ctx: DecisionContext) -> Array:
	var scored: Array = []
	for opt in DecisionOptions.applicable(ctx):
		if not DecisionOptions.is_in_set(opt, "ambient"): continue
		var u: float = 0.0
		for tw in DecisionOptions.terms_of(opt):
			u += DecisionTerms.weight(tw[1], ctx.leader_values) * DecisionTerms.eval(tw[0], ctx, opt)
		scored.append({"opt": opt, "u": u})
	scored.sort_custom(func(a, b): return a["u"] > b["u"])
	var out: Array = []
	for s in scored: out.append(s["opt"])
	return out

static func decide(state: WorldState, team: TeamData) -> String:
	var r: Array = rank(state, team)
	if r.is_empty(): return team.current_option
	team.current_option = r[0]
	return r[0]

# ★★★#12 乞食 dump 的單一實作（純觀測，Probe-gated）——
#   ★兩條 rank 路共用一份 ⇒ ★★定義不會分歧（兩份實作就會出現「兩邊數字不一致而沒人知道為什麼」）。
#   ★★★prefix 分開两條路：`beg.`＝rank_survival（絕境階梯）、`begu.`＝rank_scored（統一全 pool）。
static func _beg_tap(ctx: DecisionContext, scored: Array, team: TeamData, pfx: String) -> void:
	if not Probe.enabled or team == null:
		return
	Probe.bump(pfx + "rank_calls")                       # ★母體：這條路被呼叫的次數
	Probe.bump(pfx + "rank_team.%d" % team.team_id)      # ★★母體：隣數（per-team 桶，無 cap）
	var _food_ok: bool = ctx.food_days < ctx.desperation_entry_threshold
	if _food_ok: Probe.bump(pfx + "gate.food_ok")
	if ctx.has_aid_target: Probe.bump(pfx + "gate.aid_ok")
	if _food_ok and not ctx.has_aid_target: Probe.bump(pfx + "gate.blocked_by_no_aid")
	if not _food_ok: Probe.bump(pfx + "gate.blocked_by_food_threshold")
	var _bi: int = -1
	for _n in range(scored.size()):
		if String(scored[_n]["opt"]) == "乞食": _bi = _n; break
	if _bi == -1:
		Probe.bump(pfx + "not_in_candidates")
		return
	Probe.bump(pfx + "in_candidates")
	var _bu: float = float(scored[_bi]["u"])
	var _wo: String = String(scored[0]["opt"])
	var _wu: float = float(scored[0]["u"])
	Probe.add_amount(pfx + "util_sum", _bu)
	Probe.add_amount(pfx + "winner_util_sum", _wu)
	if _wo == "乞食":
		Probe.bump(pfx + "won")
		return
	Probe.bump(pfx + "lost_to." + _wo)
	# ★差距分桶：★★「差一點點」跟「從來不是對手」是兩種不同的事，
	#   而它們在「輸了幾次」這個數字上長得一模一樣。
	var _gap: float = _wu - _bu
	if _gap < 0.1: Probe.bump(pfx + "gap.lt0.1")
	elif _gap < 0.5: Probe.bump(pfx + "gap.0.1to0.5")
	elif _gap < 1.0: Probe.bump(pfx + "gap.0.5to1")
	elif _gap < 2.0: Probe.bump(pfx + "gap.1to2")
	else: Probe.bump(pfx + "gap.ge2")

# ★★★備戰 root-check tap（純觀測，2026-09-02）—— ★三份獨立量測指向同一個贏家。
#   ★★母體與命中同印：【備戰贏 0 次】與【沒有隊在候選裡】在輸出上長得一樣。
#   ★★★門檻那一格單獨記：`threat_react >= threat_threshold` 是 applicable 的全部條件，
#     而「幾隊過門檻」跟「幾次贏」是兩件事：前者講 applicable 鬆不鬆，後者講 util 高不高。
static func _prep_tap(ctx: DecisionContext, scored: Array, team: TeamData) -> void:
	if not Probe.enabled or team == null:
		return
	Probe.bump("prep.rank_calls")
	Probe.add_amount("prep.threat_react_sum", ctx.threat_react)
	Probe.add_amount("prep.threat_threshold_sum", ctx.threat_threshold)
	if ctx.threat_react >= ctx.threat_threshold:
		Probe.bump("prep.gate_pass")            # ★applicable 的全部條件
	else:
		Probe.bump("prep.gate_fail")
	var _pi: int = -1
	for _n in range(scored.size()):
		if String(scored[_n]["opt"]) == "備戰": _pi = _n; break
	if _pi == -1:
		Probe.bump("prep.not_in_candidates")
		return
	Probe.bump("prep.in_candidates")
	var _pu: float = float(scored[_pi]["u"])
	Probe.add_amount("prep.util_sum", _pu)
	var _wo: String = String(scored[0]["opt"])
	if _wo == "備戰":
		Probe.bump("prep.won")
		Probe.add_amount("prep.win_util_sum", _pu)
		# ★贏的時候【贏第二名多少】—— ★★贏很多跟贏一點點是兩種不同的病。
		if scored.size() > 1:
			Probe.add_amount("prep.win_margin_sum", _pu - float(scored[1]["u"]))
			Probe.bump("prep.win_margin_n")
		return
	Probe.bump("prep.lost_to." + _wo)
