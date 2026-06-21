class_name DecisionEngine

# 統一決策引擎：一隊一個 decide()。utility weigh + 承諾慣性（單一決策生產者）。
# 蒐集 DecisionContext → 列候選 Option → 每 option util = Σ(人格權重 × 驅力 term)
# + 現行 option 承諾 bonus → argmax。平手 → 保持現行（承諾慣性防震盪）。
const COMMITMENT_BONUS: float = 0.3   # TEST VALUE：承諾慣性（防震盪）

static func decide(state: WorldState, team: TeamData) -> String:
	var ctx: DecisionContext = DecisionContext.gather(state, team)
	var best_opt: String = team.current_option
	var best_u: float = -1e9
	for opt in DecisionOptions.applicable(ctx):
		var u: float = 0.0
		for tw in DecisionOptions.terms_of(opt):
			var term_name: String = tw[0]
			var weight_key: String = tw[1]
			u += DecisionTerms.weight(weight_key, ctx.leader_values) * DecisionTerms.eval(term_name, ctx, opt)
		if opt == team.current_option:
			u += COMMITMENT_BONUS
		if u > best_u:
			best_u = u; best_opt = opt
	team.current_option = best_opt
	return best_opt
