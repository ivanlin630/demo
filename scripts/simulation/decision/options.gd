class_name DecisionOptions

# 統一決策引擎：Option 註冊表 + applicable 守衛 + to_task 對映。
# 商隊切片首批 option → [[term_name, weight_key], ...]。加候選 = 加 row（bar #2）。
const REGISTRY: Dictionary = {
	"貿易":   [["economic_opp", "economic"]],
	"生產":   [["produce_need", "settle"], ["ambition_drive", "ambition"]],
	"建設":   [["settle_fit", "settle"], ["ambition_drive", "ambition"]],
	"覓食":   [["survival_pressure", "survival_pressure"]],
	"survival":[["survival_pressure", "survival_pressure"]],
	"駐守":   [["settle_fit", "settle"]],
}

static func applicable(ctx: DecisionContext) -> Array:
	var out: Array = []
	for opt in REGISTRY:
		match opt:
			"貿易":
				# roam-trade = 商隊角色（棄不棄據點巡市集）。生產隊原地掛單賣，不列候選。
				if (ctx.has_goods or ctx.has_arb) and ctx.is_merchant: out.append(opt)
			"生產", "駐守":
				if ctx.has_own_outpost: out.append(opt)
			"建設":
				out.append(opt)   # bootstrap(無據點建新) + 升級(有據點) 皆候選 → 無據點生產隊不被困
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
		"覓食":   return {"task": TeamData.TASK_FORAGE, "target": team.move_target}
		"survival": return {"task": TeamData.TASK_FLEE, "target": Vector2i(-1,-1)}
		"駐守":   return {"task": TeamData.TASK_GOVERN, "target": team.tile_pos}
		_:        return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
