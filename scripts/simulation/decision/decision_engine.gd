class_name DecisionEngine

# 統一決策引擎：一隊一個 decide()。utility weigh + 承諾慣性（單一決策生產者）。
# 蒐集 DecisionContext → 列候選 Option → 每 option util = Σ(人格權重 × 驅力 term)
# + 現行 option 承諾 bonus → argmax。平手 → 保持現行（承諾慣性防震盪）。
const COMMITMENT_BONUS: float = 0.3   # TEST VALUE：承諾慣性（防震盪）

# options 依 util 降序（index tiebreak：util 相等→applicable 順序在前者勝，同 argmax strict >）。
static func rank(state: WorldState, team: TeamData) -> Array:
	var ctx: DecisionContext = DecisionContext.gather(state, team)
	var scored: Array = []
	var idx: int = 0
	for opt in DecisionOptions.applicable(ctx):
		var u: float = 0.0
		for tw in DecisionOptions.terms_of(opt):
			u += DecisionTerms.weight(tw[1], ctx.leader_values) * DecisionTerms.eval(tw[0], ctx, opt)
		if opt == team.current_option:
			u += COMMITMENT_BONUS
		scored.append({"u": u, "i": idx, "opt": opt})
		idx += 1
	scored.sort_custom(func(a, b):
		if a["u"] != b["u"]: return a["u"] > b["u"]
		return a["i"] < b["i"])   # tiebreak：applicable 順序
	var out: Array = []
	for e in scored: out.append(e["opt"])
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
		if DecisionOptions.to_task(state, team, opt).get("task") == team.current_task:
			u += COMMITMENT_BONUS
		scored.append({"u": u, "i": idx, "opt": opt})
		idx += 1
	scored.sort_custom(func(a, b):
		if a["u"] != b["u"]: return a["u"] > b["u"]
		return a["i"] < b["i"])
	var out: Array = []
	for e in scored: out.append(e["opt"])
	return out

static func decide(state: WorldState, team: TeamData) -> String:
	var r: Array = rank(state, team)
	if r.is_empty(): return team.current_option
	team.current_option = r[0]
	return r[0]
