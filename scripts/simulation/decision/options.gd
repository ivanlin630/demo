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
}

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
				if ctx.is_merchant and ctx.food_days < DecisionTerms.RESTOCK_DAYS and ctx.has_home_outpost:
					out.append(opt)
			"覓食", "survival":
				out.append(opt)   # 恆候選（survival 靠權重，非守衛）
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
		_:        return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
