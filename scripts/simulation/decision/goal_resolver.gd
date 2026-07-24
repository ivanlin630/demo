class_name GoalResolver

# ★means-end 長程規劃（組件 C，HOW spec 2026-07-24 §4）：runtime frontier 合成中間層。
# 對 team.goal_state 每個 active goal，walk GoalRegistry[goal_type].prereqs 拆前置鏈，
# 合成當前可動 frontier candidate 餵 decision rank 池（與 static option 同池 argmax 競爭）。
# ★唯讀合成、每 tick 重算 transient frontier（不寫回 goal_state=無 plan-state，守 HOW §9）。
# ★路徑必 scripts/simulation/decision/（constitution_gate GV_FILE_RE 涵蓋）→ god-view/RNG detector 看得到。
#
# Candidate 結構（HOW §4）：{ util:float, to_task:Dictionary, source_goal:GoalInstance, label:String, delegate:bool }。
#
# ★S2：資源型 resolution 接通（第一實質 slice，打破 byte-identical）。只 resource 前置→「買」取得 candidate；
#   定位(採)/設施(產)前置=S3/S4 回無 candidate（stub 邊界）。折現/委派/子目標=S3-S6 別提前（whole-system-first）。

# ★must-fix① util 護欄（HOW §8，首上場硬做）：goal candidate util 恆 < 絕境 survival-boosted static util。
# = payoff × dev_urgency_coeff（絕境 food_days→0→0=壓遠慾望）+ clamp 上界 < SURVIVAL_BOOST_MAX（硬保證）。
const GOAL_UTIL_CAP: float = 1.5   # TEST VALUE — < DecisionEngine.SURVIVAL_BOOST_MAX(2.5) 硬護欄:goal candidate 永不蓋絕境 survival boost

# ★組件 A（S2 版）：冪等確保 team.goal_state 含 5 資源維持 goal + 更新 active/satisfied（holding<need_keep→active）。
# S7 才做 util-門檻掛退 cadence 泛化；S2 固定 goal-set。純讀狀態+need_keep，零 randf。
static func ensure_maintain_goals(state: WorldState, team: TeamData) -> void:
	if state == null or team == null or state.world == null:
		return
	var lv: Dictionary = TradeValuation.leader_vals(state, team)
	var have: Dictionary = {}
	for g in team.goal_state:
		have[String(g.get("goal_type", ""))] = true
	# 冪等補齊缺的 maintain goal（決定性順序：REGISTRY key 序）
	for gt in GoalRegistry.MAINTAIN_GOAL_RES:
		if not have.has(gt):
			team.goal_state.append({"goal_type": gt, "target": null,
				"created_tick": state.world.current_tick, "status": "active"})
	# 更新 status：holding < need_keep(res) → active（想維持）；否則 satisfied。
	for g in team.goal_state:
		var gt: String = String(g.get("goal_type", ""))
		if not GoalRegistry.MAINTAIN_GOAL_RES.has(gt):
			continue   # 非 maintain goal（S3+ 別型）不在此管
		var res: String = String(GoalRegistry.MAINTAIN_GOAL_RES[gt])
		var target: float = NeedOracle.need_keep(state, team, res, lv)
		var holding: float = ResourceSystem.effective_holding(state, team, res)
		g["status"] = "active" if holding < target else "satisfied"

static func frontier_candidates(state: WorldState, team: TeamData, ctx: DecisionContext) -> Array:
	if state == null or team == null or ctx == null:
		return []   # harness 無 state/team → 無 goal frontier（安全）
	var out: Array = []
	var lv: Dictionary = TradeValuation.leader_vals(state, team)
	for g in team.goal_state:
		if String(g.get("status", "")) != "active":
			continue
		var gt: String = String(g.get("goal_type", ""))
		var def: Dictionary = GoalRegistry.REGISTRY.get(gt, {})
		if def.is_empty():
			continue
		var payoff: float = float(def.get("payoff", 1.0))
		for prereq in def.get("prereqs", []):
			var kind: String = String(prereq.get("kind", ""))
			# ★S2 只 resource 前置：定位/人力/設施/子目標 → 無 candidate（S3-S6 stub 邊界）。
			if kind != GoalRegistry.PREREQ_RESOURCE:
				continue
			var res: String = String(prereq.get("res", ""))
			# 組件 E 泛化：qty 走通用 need_keep（任 res，非只 material/tools construction scope）。
			var target: float = NeedOracle.need_keep(state, team, res, lv)
			var holding: float = ResourceSystem.effective_holding(state, team, res)
			if holding >= target:
				continue   # 前置滿 → 無需取得
			# 未滿 → 「取得 res」candidate。★S2 只接「買」（市場取得不需定位；採/產=S3/S4）。
			# 需有籌碼 + 已知市場有此 res（belief-gated，感知鐵律非 god-view）。
			if not ctx.has_specie:
				continue
			var mp: Vector2i = FactionAISystem.new()._nearest_market_outpost_with(state, team, res)
			if mp == Vector2i(-1, -1):
				continue   # 無已知市場有此 res → S2 無取得手段（採/產=定位/設施前置，S3/S4）
			out.append({
				"util": _candidate_util(payoff, ctx),
				"to_task": {"task": TeamData.TASK_TRADE, "target": mp},
				"source_goal": g,
				"label": gt + ":" + GoalRegistry.PREREQ_RESOURCE,   # root_goal + frontier_kind（有界 label，HOW §7）
				"delegate": false,   # 委派變體 = S5（組件 D）別提前
			})
	return out

# ★must-fix① util 護欄（HOW §8，reviewer S2 指定回歸點）：
# dev_urgency_coeff(絕境壓遠慾望) × payoff，clamp 上界 < survival boost → goal candidate 永不蓋活命。
static func _candidate_util(payoff: float, ctx: DecisionContext) -> float:
	# dev_urgency_coeff：鏡射 NeedHierarchy consistency_coeff 對「發展/遠層」的壓制精神——
	# food_days→0（絕境）→ 0（遠慾望歸零，讓眼前 survival 奪 argmax）；food 足→1。
	var dev_coeff: float = clampf(ctx.food_days / DecisionTerms.DESPERATION_DAYS, 0.0, 1.0)
	# clamp 上界 GOAL_UTIL_CAP < SURVIVAL_BOOST_MAX：即使 payoff 巨、dev_coeff 未全 0，硬保證 < 絕境 survival-boosted static util。
	return clampf(payoff * dev_coeff, 0.0, GOAL_UTIL_CAP)
