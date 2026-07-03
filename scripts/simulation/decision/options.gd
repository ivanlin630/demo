class_name DecisionOptions

# 統一決策引擎：Option 註冊表 + applicable 守衛 + to_task 對映。
# 商隊切片首批 option → [[term_name, weight_key], ...]。加候選 = 加 row（bar #2）。
const REGISTRY: Dictionary = {
	"貿易":   [["economic_opp", "economic"], ["intent_fit", "intent_fit"]],
	"生產":   [["produce_need", "settle"], ["ambition_drive", "ambition"]],
	"建設":   [["settle_fit", "settle"], ["ambition_drive", "ambition"]],
	"覓食":   [["survival_pressure", "survival_pressure"]],
	"survival":[["threat_pressure", "survival_pressure"]],
	"駐守":   [["settle_fit", "settle"]],
	"返家補給":[["restock_need", "survival_pressure"]],
	"掠奪":   [["loot_drive", "loot"], ["intent_fit", "intent_fit"]],
	# 佔村：奪據點+搬進去（雙引擎咬合）。與掠奪同 menu 秤 util argmax（零新判斷器）。
	# intent_fit=匱乏→奪產村 boost（與掠奪 parallel）；occupy_drive=野心 base_need edge（決定佔 vs 搶）。
	"佔村":   [["occupy_drive", "occupy"], ["intent_fit", "intent_fit"]],
	"投靠":   [["join_drive", "join"]],
	"紮營":   [["camp_drive", "camp"]],
	"乞食":   [["beg_drive",  "beg"]],
	"攻擊":   [["faction_duty", "faction_duty"], ["attack_drive", "attack"], ["intent_fit", "intent_fit"]],
	"徵收":   [["faction_duty", "faction_duty"], ["levy_drive", "levy"]],
	"外交":   [["faction_duty", "faction_duty"], ["diplo_drive", "diplo"]],
	"買糧":   [["buyfood_drive", "buyfood"]],
	# means-end：致富+餘糧 → 蓋倉囤貨低買高賣（複用 TASK_TRADE 到市集 hub，非新機制）。
	"囤貨":   [["intent_fit", "intent_fit"]],
}

# survival-class option 子集（P2b-1：non-unified _trigger_survival 委派 rank_survival 用）。
const SURVIVAL_OPTION_SET: Array = ["返家補給", "覓食", "掠奪", "佔村", "投靠", "紮營", "乞食", "買糧"]

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
				# 經濟底 home-empty gate：家糧倉 < RESTOCK_MIN（空家）→ 不 offer（返空家乾耗無意義）
				#   → 讓 買糧/交易/覓食 接手（forest 隊賣特產換糧而非返空家）。
				if ctx.has_home_outpost and ctx.home_food >= DecisionTerms.RESTOCK_MIN and ( \
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
			"佔村":
				# means-end：要根據地的狼（無自家 outpost 最需要 / 或征服 intent）+ 有可據弱村 + pop 夠守+分駐。
				if ctx.has_occupy_target:
					Probe.bump("occupy.ctx_hastarget")
					if ctx.population < DecisionTerms.OCCUPY_MIN_POP:
						Probe.bump("occupy.appl_kill_pop")
					elif ctx.has_own_outpost and ctx.intent != "征服":
						Probe.bump("occupy.appl_kill_hasbase")
					else:
						Probe.bump("occupy.applicable")
						out.append(opt)
			"投靠":
				if ctx.food_days < DecisionTerms.DESPERATION_DAYS and ctx.has_strong_neighbor: out.append(opt)
			"紮營":
				if ctx.food_days < DecisionTerms.DESPERATION_DAYS and ctx.has_farmable_tile \
						and not ctx.has_own_outpost: out.append(opt)
			"乞食":
				if ctx.food_days < DecisionTerms.DESPERATION_DAYS and ctx.has_aid_target: out.append(opt)
			"攻擊":
				# 混合協調：派系 directive=攻擊 且有獨立 target → 候選（無 directive 時零影響）。
				# means-end：征服 intent 隊亦開攻擊（非只 faction_stakes），target=intent_target/weak_prey。
				if ("攻擊" in ctx.faction_stakes and ctx.faction_attack_target != -1) \
						or (ctx.intent == "征服" and ctx.intent_target != -1):
					out.append(opt)
			"囤貨":
				# means-end：致富 intent + 有餘糧 + 有貿易機會(arb/市集) → 蓋倉囤貨候選。
				if ctx.intent == "致富" and ctx.food_days >= DecisionTerms.SURPLUS_FOOD_DAYS \
						and (ctx.has_arb or ctx.has_food_market):
					out.append(opt)
			"徵收":
				# 派系 directive=徵收 且有更富 member target → 候選。
				if "徵收" in ctx.faction_stakes and ctx.faction_tribute_target != -1: out.append(opt)
			"外交":
				# 派系 directive=外交 且有獨立鄰 target → 候選。
				if "外交" in ctx.faction_stakes and ctx.faction_diplo_target != -1: out.append(opt)
			"買糧":
				# 餓 + 有市集 + 有錢 → 買糧候選（無錢=乞食真語意，不入）。
				if ctx.food_days < DecisionTerms.DESPERATION_DAYS and ctx.has_food_market and ctx.has_specie:
					out.append(opt)
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
		"佔村":
			# 攻取據村：TASK_ATTACK 到村格 → 戰勝 capture 自動翻旗（既有）→ 次 cadence has_own_outpost
			# → 生產/駐守 + _evaluate_outpost_residency 派駐（既有）接手 → 食引擎點火。不新造據點系統。
			var vid: int = FactionAISystem.new()._find_occupy_target(state, team)
			if vid == -1: return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1, -1)}
			return {"task": TeamData.TASK_ATTACK, "target": state.teams[vid].tile_pos, "combat_target": vid}
		"投靠":
			var sn: int = FactionAISystem.new()._find_strong_neighbor(state, team)
			if sn == -1: return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
			# 社交意圖：設 social_target 非 combat_target（否則 _try_interact:197 早退擋死 JOIN resolver）
			return {"task": TeamData.TASK_JOIN, "target": state.teams[sn].tile_pos, "social_target": sn}
		"紮營":
			var ft: Vector2i = FactionAISystem.new()._find_unowned_farmable_tile(state, team)
			if ft == Vector2i(-1,-1): return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
			return {"task": TeamData.TASK_CAMP, "target": ft}
		"乞食":
			var aid: int = FactionAISystem.new()._find_aid_target(state, team)
			if aid == -1: return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
			# 社交意圖：設 social_target 非 combat_target（resolver 讀 social_target）
			return {"task": TeamData.TASK_BEG, "target": state.teams[aid].tile_pos, "social_target": aid}
		"攻擊":
			# 混合協調：對派系指定的最近獨立隊發動攻擊（combat_target 接線複用 _decide_unified:864）。
			var atid: int = FactionAISystem.new()._nearest_independent(state, team)
			if atid == -1: return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
			return {"task": TeamData.TASK_ATTACK, "target": state.teams[atid].tile_pos, "combat_target": atid}
		"徵收":
			# 派系指定最富 member 徵貢（非戰，不設 combat_target）。排除自身（_richest_member 未排）。
			var f4 = state.factions.get(team.faction_id)
			if f4 == null: return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
			var rt: int = FactionAISystem.new()._richest_member(state, f4)
			if rt == -1 or rt == team.team_id: return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
			return {"task": TeamData.TASK_TRIBUTE, "target": state.teams[rt].tile_pos}
		"外交":
			# 派系指定最近獨立隊外交（非戰，不設 combat_target）。
			var dt: int = FactionAISystem.new()._nearest_independent(state, team)
			if dt == -1: return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
			return {"task": TeamData.TASK_DIPLOMACY, "target": state.teams[dt].tile_pos}
		"買糧":
			# 到最近市集 outpost 走既有 TASK_TRADE；到場 _resolve_market 餓隊 food local_value 高→買 food。
			var mp: Vector2i = FactionAISystem.new()._nearest_market_outpost(state, team)
			if mp == Vector2i(-1, -1): return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
			return {"task": TeamData.TASK_TRADE, "target": mp}
		"囤貨":
			# 致富囤貨：到市集 hub 低買囤積（複用 TASK_TRADE，target=市集 outpost）；無市集則退貿易對象。
			var hub: Vector2i = FactionAISystem.new()._nearest_market_outpost(state, team)
			if hub == Vector2i(-1, -1):
				hub = FactionAISystem.new()._merchant_trade_target(state, team)
			if hub == Vector2i(-1, -1): return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
			return {"task": TeamData.TASK_TRADE, "target": hub}
		_:        return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
