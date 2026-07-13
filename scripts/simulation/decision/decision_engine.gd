class_name DecisionEngine

# 統一決策引擎：一隊一個 decide()。utility weigh + 承諾慣性（單一決策生產者）。
# 蒐集 DecisionContext → 列候選 Option → 每 option util = Σ(人格權重 × 驅力 term)
# + 現行 option 承諾 bonus → argmax。平手 → 保持現行（承諾慣性防震盪）。
const COMMITMENT_BONUS: float = 0.3   # TEST VALUE：承諾慣性（防震盪）

# options 依 util 降序（index tiebreak：util 相等→applicable 順序在前者勝，同 argmax strict >）。
# 排序後帶 util 的 scored 陣列 [{u,i,opt}, ...]（降序）。rank() 只取 opt；
# 量測探針（征服名實）要讀 util 排序根 → 走此無損 accessor（不重算 term loop）。
static func rank_scored(state: WorldState, team: TeamData) -> Array:
	var ctx: DecisionContext = DecisionContext.gather(state, team)
	var scored: Array = rank_scored_ctx(ctx, team.current_option)
	SpecimenTracer.capture_options(state, team, scored)   # specimen tap（no-op-unless-specimen）
	return scored

# ctx-taking 純打分 accessor（鏡射 rank_threat(ctx)）：不 gather、不寫 current_option、不 specimen tap。
# 融合驗 harness 手構 ctx 驗 rank（繞世界 setup，deterministic）；rank_scored 委派此避重複 loop。
static func rank_scored_ctx(ctx: DecisionContext, current_option: String = "") -> Array:
	var scored: Array = []
	var idx: int = 0
	for opt in DecisionOptions.applicable(ctx):
		var u: float = 0.0
		for tw in DecisionOptions.terms_of(opt):
			u += DecisionTerms.weight(tw[1], ctx.leader_values) * DecisionTerms.eval(tw[0], ctx, opt)
		# 需求金字塔重構：五層急迫度一致性係數(§3)統一調變全 23 option。純乘一係數，不改 term 內部。
		# ★乘在 COMMITMENT_BONUS 之前（承諾慣性是決策層加成，不受需求調變）。
		var _coeff: float = NeedHierarchy.consistency_coeff(opt, ctx.need_urgency, ctx.leader_values)
		u *= _coeff
		if Probe.enabled and ctx.need_urgency.size() == NeedHierarchy.N_LAYERS:
			Probe.bump("decision.coeff_applied_n")   # 全 23 option 受 coeff 覆蓋計數
			if _coeff < 0.5: Probe.bump("decision.coeff_lowhalf")   # 遠層被顯著壓比例
			# per-option probe（①全覆蓋/④不死鎖，比照 rung_dist；純觀測零行為變）
			Probe.bump("decision.opt_applicable." + opt)          # 候選分母
			if _coeff < 1.0: Probe.bump("decision.opt_coeff_pressed." + opt)   # coeff 確隨急迫度變(非恆1)
		if opt == current_option:
			u += COMMITMENT_BONUS
		scored.append({"u": u, "i": idx, "opt": opt})
		idx += 1
	scored.sort_custom(func(a, b):
		if a["u"] != b["u"]: return a["u"] > b["u"]
		return a["i"] < b["i"])   # tiebreak：applicable 順序
	# per-option 選中分布（argmax=rank[0]；判「applicable 過但選中恆 0」=結構性死鎖 ④）
	if Probe.enabled and not scored.is_empty() and ctx.need_urgency.size() == NeedHierarchy.N_LAYERS:
		Probe.bump("decision.opt_chosen." + String(scored[0]["opt"]))
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
	var scored: Array = []
	var idx: int = 0
	for opt in DecisionOptions.applicable(ctx):
		if opt not in DecisionOptions.SURVIVAL_OPTION_SET: continue
		var u: float = 0.0
		for tw in DecisionOptions.terms_of(opt):
			u += DecisionTerms.weight(tw[1], ctx.leader_values) * DecisionTerms.eval(tw[0], ctx, opt)
		# churn 防抖：比對 previous_task（非 current_task）——survival-latch relatch 路 release→current_task=IDLE，
		# previous_task 保留 release 前 survival task，防餓隊每 cadence 亂跳（覓食/買糧/掠奪/併入）。
		# 常態路 previous_task==current_task（_trigger_survival 設）→等價。
		if DecisionOptions.to_task(state, team, opt).get("task") == team.previous_task:
			u += COMMITMENT_BONUS
		scored.append({"u": u, "i": idx, "opt": opt})
		idx += 1
	scored.sort_custom(func(a, b):
		if a["u"] != b["u"]: return a["u"] > b["u"]
		return a["i"] < b["i"])
	SpecimenTracer.capture_options(state, team, scored)   # specimen tap（no-op-unless-specimen）
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
