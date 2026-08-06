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
	var ctx: DecisionContext = DecisionContext.gather(state, team)
	var scored: Array = rank_scored_ctx(ctx, team.current_option, state, team)   # ★means-end:傳 state/team 供 goal frontier hook
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
		# 層0 安全氣囊（★插在 coeff 乘法之後——寫死此序：coeff 前會被 0.15 floor 打折失效）：
		# 極低糧時 survival-class 加法超量級破頂，隨 food→0 線性放大，奪回 argmax。全 SURVIVAL_OPTION_SET 等量加
		# (不改 survival-class 內部相對序，只集體破頂)。food_days=FLOOR 時加成=0 平滑銜接無 flip-flop。
		if ctx.food_days < SURVIVAL_BOOST_FLOOR and opt in DecisionOptions.SURVIVAL_OPTION_SET:
			u += SURVIVAL_BOOST_MAX * (SURVIVAL_BOOST_FLOOR - ctx.food_days) / SURVIVAL_BOOST_FLOOR
			if Probe.enabled: Probe.bump("survival.boost_fire")   # 觸發頻率=健康指標(measurer 要)
		# ★threat-oracle S2 break-top boost（解 skeptic finding3 單 term-多 term 不匹配）：severity≥FLOOR 時
		# threat option 加法破頂 ∝ severity（鏡射 survival，全 THREAT_OPTION_SET 等量加，保內部序）
		# ★capped 且 < survival boost(2.5)：threat=belief→survival(存亡)保序不破；blueprint② 非偽裝硬閘。
		if ctx.threat_react >= THREAT_BOOST_FLOOR and opt in THREAT_OPTION_SET:
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
			scored.append({"u": float(cand.get("util", 0.0)), "i": idx, "opt": String(cand.get("label", "")), "cand": cand})
			idx += 1
	scored.sort_custom(func(a, b):
		if a["u"] != b["u"]: return a["u"] > b["u"]
		return a["i"] < b["i"])   # tiebreak：applicable 順序
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

# 被動求生 repertoire（定案）：覓食/買糧/乞食/返家補給/紮營/併入=被動求生(食物+投靠認慫)→"survival" 一組
# 保 fallthrough；★排攻擊型 掠奪/佔村（主動侵略，靠人格 weight 主導非 fallthrough 保底，否則溫和 fed 隊誤 loot）。
const PASSIVE_SURVIVAL_SET: Array = ["覓食", "買糧", "乞食", "返家補給", "紮營", "併入", "自救建田"]   # ★復甦 R2 §2B.1：自救建田=被動求生(蓋田自食)→同 survival 需求組 fallthrough

# 需求分組：PASSIVE_SURVIVAL_SET 成員→"survival"（不看 affinity）；非→按 affinity 主層。
static func _need_category(opt: String) -> String:
	if opt in PASSIVE_SURVIVAL_SET:
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
	var ctx: DecisionContext = DecisionContext.gather(state, team)
	# ② 絕境階梯：applicable() 已收單一源 stall 排除 + 單一 option 豁免（全 rank 路共用）→ 此處直取 survival 子集。
	var candidates: Array = []
	for opt in DecisionOptions.applicable(ctx):
		if opt in DecisionOptions.SURVIVAL_OPTION_SET: candidates.append(opt)
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
	SpecimenTracer.capture_options(state, team, scored, ctx)   # specimen tap（no-op-unless-specimen）；ctx 帶 threat 來源
	var out: Array = []
	for e in scored: out.append(e["opt"])
	return out

# 融合 threat 子集排序（序1 溶入：non-unified _evaluate_threat 委派用，鏡射 rank_survival）。
# 取 ctx（呼叫端已 gather，避重算）→ applicable ∩ THREAT_OPTION_SET → util 秤 → 降序。
# 無 commitment bonus（鏡射舊 _dispatch_threat_response 純 argmax；threat 每 cadence idle 才重觸發）。
const THREAT_OPTION_SET: Array = ["survival", "備戰", "迎戰", "求和"]   # survival=FLEE(逃跑)

static func rank_threat(ctx: DecisionContext) -> Array:
	var scored: Array = []
	for opt in DecisionOptions.applicable(ctx):
		if opt not in THREAT_OPTION_SET: continue
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
const AMBIENT_OPTION_SET: Array = ["訓練", "貿易", "生產", "建設", "囤貨", "駐守"]

static func rank_ambient(ctx: DecisionContext) -> Array:
	var scored: Array = []
	for opt in DecisionOptions.applicable(ctx):
		if opt not in AMBIENT_OPTION_SET: continue
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
