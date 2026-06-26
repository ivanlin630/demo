class_name DecisionOptions

# 統一決策引擎：Option 註冊表 + applicable 守衛 + to_task 對映。
# 商隊切片首批 option → [[term_name, weight_key], ...]。加候選 = 加 row（bar #2）。
const REGISTRY: Dictionary = {
	"貿易":   [["economic_opp", "economic"]],
	"生產":   [["produce_need", "settle"], ["ambition_drive", "ambition"]],
	"建設":   [["settle_fit", "settle"], ["ambition_drive", "ambition"]],
	"覓食":   [["survival_pressure", "survival_pressure"]],
	"survival":[["threat_pressure", "survival_pressure"]],
	"駐守":   [["settle_fit", "settle"]],
	"返家補給":[["restock_need", "survival_pressure"]],
	"掠奪":   [["loot_drive", "loot"]],
	"投靠":   [["join_drive", "join"]],
	"紮營":   [["camp_drive", "camp"]],
	"乞食":   [["beg_drive",  "beg"]],
	"攻擊":   [["faction_duty", "faction_duty"], ["attack_drive", "attack"]],
}

# survival-class option 子集（P2b-1：non-unified _trigger_survival 委派 rank_survival 用）。
const SURVIVAL_OPTION_SET: Array = ["返家補給", "覓食", "掠奪", "投靠", "紮營", "乞食"]

static func applicable(ctx: DecisionContext) -> Array:
	var out: Array = []
	for opt in REGISTRY:
		match opt:
			"貿易":
				# roam-trade：商隊主力；生產隊也可(軟壓低 via economic_opp 角色因子,非禁)。
				if ctx.has_goods or ctx.has_arb: out.append(opt)
			"生產", "駐守":
				if ctx.has_own_outpost: out.append(opt)
			"建設":
				out.append(opt)   # bootstrap(無據點建新) + 升級(有據點) 皆候選 → 無據點生產隊不被困
			"返家補給":
				# 商隊 proactive 補給：糧低於 RESTOCK 且有家可回 → 回家補 carried(避 survival latch)。
				# P2b-1 generalize：任何有家隊絕境(food<DESPERATION)→回家(保 non-unified 1037 熱路徑)。
				if ctx.has_home_outpost and ( \
						(ctx.is_merchant and ctx.food_days < DecisionTerms.RESTOCK_DAYS) \
						or ctx.food_days < DecisionTerms.DESPERATION_DAYS):
					out.append(opt)
			"覓食":
				# P2b-1：viable-pop 守衛移入 applicable（舊 _trigger_survival forage 限 pop≤此值）。
				if ctx.population <= FactionAISystem.FORAGE_VIABLE_POP:
					out.append(opt)
			"survival":
				out.append(opt)   # 恆候選（FLEE 靠 threat 權重，非守衛）
			"掠奪":
				if ctx.has_weak_prey: out.append(opt)
			"投靠":
				if ctx.food_days < DecisionTerms.DESPERATION_DAYS and ctx.has_strong_neighbor: out.append(opt)
			"紮營":
				if ctx.food_days < DecisionTerms.DESPERATION_DAYS and ctx.has_farmable_tile \
						and not ctx.has_own_outpost: out.append(opt)
			"乞食":
				if ctx.food_days < DecisionTerms.DESPERATION_DAYS and ctx.has_aid_target: out.append(opt)
			"攻擊":
				# 混合協調：派系 directive=攻擊 且有獨立 target → 候選（無 directive 時零影響）。
				if ctx.faction_directive == "攻擊" and ctx.faction_attack_target != -1: out.append(opt)
	return out

static func terms_of(opt: String) -> Array:
	return REGISTRY.get(opt, [])

# Option → 既有 TASK_* + target（複用既有 dispatch helper）。
static func to_task(state: WorldState, team: TeamData, opt: String) -> Dictionary:
	match opt:
		"貿易":   return {"task": TeamData.TASK_TRADE, "target": FactionAISystem.new()._merchant_trade_target(state, team)}
		"生產":   return {"task": TeamData.TASK_MANUFACTURE, "target": team.tile_pos}
		"建設":   return {"task": TeamData.TASK_BUILD, "target": team.tile_pos}
		"覓食":   return {"task": TeamData.TASK_FORAGE, "target": FactionAISystem.new()._find_forage_tile(state, team)}
		"survival": return {"task": TeamData.TASK_FLEE, "target": Vector2i(-1,-1)}
		"駐守":   return {"task": TeamData.TASK_GOVERN, "target": team.tile_pos}
		"返家補給": return {"task": TeamData.TASK_RETURN_HOME, "target": FactionAISystem.new()._find_own_outpost(state, team)}
		"掠奪":
			var pid: int = FactionAISystem.new()._find_weakest_prey(state, team)
			if pid == -1: return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1, -1)}
			return {"task": TeamData.TASK_LOOT, "target": state.teams[pid].tile_pos, "combat_target": pid}
		"投靠":
			var sn: int = FactionAISystem.new()._find_strong_neighbor(state, team)
			if sn == -1: return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
			return {"task": TeamData.TASK_JOIN, "target": state.teams[sn].tile_pos, "combat_target": sn}
		"紮營":
			var ft: Vector2i = FactionAISystem.new()._find_unowned_farmable_tile(state, team)
			if ft == Vector2i(-1,-1): return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
			return {"task": TeamData.TASK_CAMP, "target": ft}
		"乞食":
			var aid: int = FactionAISystem.new()._find_aid_target(state, team)
			if aid == -1: return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
			return {"task": TeamData.TASK_BEG, "target": state.teams[aid].tile_pos, "combat_target": aid}
		"攻擊":
			# 混合協調：對派系指定的最近獨立隊發動攻擊（combat_target 接線複用 _decide_unified:864）。
			var atid: int = FactionAISystem.new()._nearest_independent(state, team)
			if atid == -1: return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
			return {"task": TeamData.TASK_ATTACK, "target": state.teams[atid].tile_pos, "combat_target": atid}
		_:        return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
