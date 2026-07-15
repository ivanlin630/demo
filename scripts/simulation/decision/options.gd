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
	# S-A §HOW-6：統一「併入」（join+整併合一，取代兩 row）。絕境求生 food-scaled；weight=求生欲/(1-野心)
	# （§HOW-6 定，非 join weight——join weight×low_ambition 使 併入 rank 過低不勝 survival first=0 regression）。
	"併入":   [["join_drive", "mergein"]],
	# S-A §HOW-7：強方擴張 pull「吸納」（強隊主動吸弱鄰，擴張-class @PRIO_DISPATCH，非 survival）。
	"吸納":   [["absorb_drive", "absorb"]],
	"紮營":   [["camp_drive", "camp"]],
	"乞食":   [["beg_drive",  "beg"]],
	# 序4 vendetta 溶入：feud_pull term 掛入 → 血仇成攻擊的一個 weight 驅力（衝動 leader 血仇高→攻擊贏 rank）。
	"攻擊":   [["faction_duty", "faction_duty"], ["attack_drive", "attack"], ["intent_fit", "intent_fit"], ["feud_pull", "feud"]],
	"徵收":   [["faction_duty", "faction_duty"], ["levy_drive", "levy"]],
	"外交":   [["faction_duty", "faction_duty"], ["diplo_drive", "diplo"]],
	"買糧":   [["buyfood_drive", "buyfood"]],
	# Fix B 遷移找糧：絕境階梯新階（當地求生全不可 fulfill → 移向視野內可達糧源）。獨立 option 保承諾慣性/trace
	# 可讀；weight 複用 survival_pressure（食物越低越想動，同覓食驅力）。排序 emergent（weight×人格 argmax）非硬階梯。
	"遷移找糧":[["survival_pressure", "survival_pressure"]],
	# means-end：致富+餘糧 → 蓋倉囤貨低買高賣（複用 TASK_TRADE 到市集 hub，非新機制）。
	"囤貨":   [["intent_fit", "intent_fit"]],
	# 融合 threat（序1 溶入）：4 反應 repertoire 中的 3（FLEE=既有 survival option）。
	# threat-gated（applicable 讀 threat_react≥threshold），人格秤 argmax（撕除舊手算）。
	"備戰":   [["prepare_drive", "prepare"]],
	"迎戰":   [["defend_drive", "defend"]],
	"求和":   [["pacify_drive", "pacify"]],
	# 野心階梯溶入（序3）：FORCE-archetype 累積階練兵（原 rung_task ACCUMULATE×FORCE→TASK_TRAIN）。
	# archetype/rung 當 weight（ambient_train_drive）驅動，非查表塞 task。
	"訓練":   [["train_drive", "train"]],
	# A2a 子隊溶入：歸建＝服從母團權威/回母團集結（duty 驅，通用 row，非子隊專屬 term）。
	# faction_duty weight 已 _duty_factor(loyalty,野心)→忠誠子隊聽令回母團；不忠→掠奪(greed)贏 rank。
	"歸建":   [["faction_duty", "faction_duty"]],
}

# A2a 通用戰略-gate：子隊不自主發起「擴張自身戰略足跡」的 option（立據/奪據/練兵＝leader/faction 決定；
# 母團命令走 pre-set lifecycle task，引擎點結構上無 strategic directive）。新增戰略 option 入 SET 自動涵蓋。
const STRATEGIC_SELFINIT_SET: Array = ["建設", "佔村", "訓練", "吸納"]   # §HOW-7 吸納=擴張戰略,子隊不自主發起

# survival-class option 子集（P2b-1：non-unified _trigger_survival 委派 rank_survival 用）。
const SURVIVAL_OPTION_SET: Array = ["返家補給", "覓食", "掠奪", "佔村", "併入", "紮營", "乞食", "買糧", "遷移找糧"]   # S-A §HOW-6：統一「併入」(join+整併合一)絕境求生；Fix B 遷移找糧

# 序4 vendetta 溶入：血仇開打門檻（防輕微不快即戰）。TEST VALUE。
const FEUD_ATTACK_MIN := 0.5

static func applicable(ctx: DecisionContext) -> Array:
	var out: Array = []
	for opt in REGISTRY:
		# A2a 通用戰略-gate（match 前，一條規則管全部）：子隊不自主發起戰略級 option
		# （立據/奪據/練兵＝leader/faction 決定；母團戰略令走 pre-set lifecycle task）。
		# 非子隊 is_subteam=false → 不觸 → 行為零變。
		if ctx.is_subteam and opt in STRATEGIC_SELFINIT_SET:
			continue
		match opt:
			"貿易":
				# roam-trade：商隊主力；生產隊也可(軟壓低 via economic_opp 角色因子,非禁)。
				# 駐村隊（movement 居民鎖）不濾：掛 TRADE 站自家村=擺攤營業（來客觸發 _resolve_market
				# + absorb 糧倉賣餘糧=需求側環實體）。漏斗 r3 實證：濾掉→村攤關門→成交崩，勿再加鎖。
				if ctx.has_goods or ctx.has_arb: out.append(opt)
			"生產":
				# S1：製造需設施 precondition（A2 補缺）——無製造設施→濾掉（否則無設施選製造=no-op 空轉）。
				if ctx.has_own_outpost and ctx.has_manufacturing_facility:
					out.append(opt)
				elif ctx.has_own_outpost and Probe.enabled:
					Probe.bump("produce.appl_kill_nofacility")   # 生產被 precondition 濾（A2 主病可觀測）
			"駐守":
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
				# Fix4：+ 覓食可達性預檢——本格/鄰格無 wild_game tile 則不 applicable（防 forage-to-nowhere churn）。
				if ctx.population <= FactionAISystem.FORAGE_VIABLE_POP and ctx.has_forage_tile:
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
			"併入":
				# §HOW-8 ungate + §3b：絕境 OR 威脅認慫。host = rep 保護傘(strong_neighbor,跨faction) 或 consolidate_target(同faction)。
				# Fix A-2 v2：+ has_acceptable_join_host（可達且未近期被拒的 host）→ 不追必被拒的併入幻覺 loop。
				if (ctx.has_strong_neighbor or ctx.consolidate_target_id != -1) \
						and ctx.has_acceptable_join_host \
						and (ctx.food_days < DecisionTerms.DESPERATION_DAYS \
							or (ctx.has_strong_neighbor and ctx.threat > ctx.threat_threshold)): out.append(opt)
			"吸納":
				# §HOW-7：有 capacity-bound 可吸弱鄰（finder 已保統領餘裕裝得下）→ 擴張候選（無 food gate）。
				if ctx.absorb_target_id != -1: out.append(opt)
			"紮營":
				if ctx.food_days < DecisionTerms.DESPERATION_DAYS and ctx.has_farmable_tile \
						and not ctx.has_own_outpost: out.append(opt)
			"乞食":
				if ctx.food_days < DecisionTerms.DESPERATION_DAYS and ctx.has_aid_target: out.append(opt)
			"攻擊":
				# 混合協調：派系 directive=攻擊 且有獨立 target → 候選（無 directive 時零影響）。
				# means-end：征服 intent 隊亦開攻擊（非只 faction_stakes），target=intent_target/weak_prey。
				# 序4 血仇路：強血仇(≥FEUD_ATTACK_MIN)+可見仇敵 → 攻擊 applicable（衝動 leader 拉隊打仇人）。
				if ("攻擊" in ctx.faction_stakes and ctx.faction_attack_target != -1) \
						or (ctx.intent == "征服" and ctx.intent_target != -1) \
						or (ctx.strongest_feud >= FEUD_ATTACK_MIN and ctx.feud_target_id != -1):
					out.append(opt)
			"囤貨":
				# means-end：致富 intent + 有餘糧 + 有貿易機會(arb/市集) → 蓋倉囤貨候選。
				# 駐村隊不濾（同「貿易」註：TRADE 姿態=村攤營業，非 zombie）。
				if ctx.intent == "致富" and ctx.food_days >= DecisionTerms.SURPLUS_FOOD_DAYS \
						and (ctx.has_arb or ctx.has_food_market):
					out.append(opt)
			"徵收":
				# 派系 directive=徵收 且有更富 member target → 候選。
				if "徵收" in ctx.faction_stakes and ctx.faction_tribute_target != -1: out.append(opt)
			"外交":
				# 派系 directive=外交 且有獨立鄰 target + ★target 未在 reject_cooldown 內（被拒不再纏）→ 候選。
				if "外交" in ctx.faction_stakes and ctx.faction_diplo_target != -1 \
						and not ctx.diplo_target_on_cooldown: out.append(opt)
			"買糧":
				# 餓 + 有市集 + 有錢 + ★聽過食物賣單(has_buyable_food) → 買糧候選（Fix A look-before-leap：
				# 從沒聽過任何食物賣單=不追純幻覺；無錢=乞食真語意，不入）。駐村隊不濾。
				if ctx.food_days < DecisionTerms.DESPERATION_DAYS and ctx.has_food_market \
						and ctx.has_specie and ctx.has_buyable_food:
					out.append(opt)
			"遷移找糧":
				# Fix B 絕境階梯新階：餓 + 有可達已知糧源(food_seek_target) + 當地覓食·買糧皆不 applicable
				# → 移向糧源（有 local 出路優先 local，不遷移）。撲空/target 消失由 cadence 重秤 + C 連貫死收。
				var _forage_ok: bool = ctx.population <= FactionAISystem.FORAGE_VIABLE_POP and ctx.has_forage_tile
				var _buyfood_ok: bool = ctx.has_food_market and ctx.has_specie and ctx.has_buyable_food
				if ctx.food_days < DecisionTerms.DESPERATION_DAYS \
						and ctx.food_seek_target != Vector2i(-1, -1) \
						and not _forage_ok and not _buyfood_ok:
					out.append(opt)
			# ── 融合 threat：threat-gated（威脅過門檻才候選）──
			"備戰":
				if ctx.threat_react >= ctx.threat_threshold: out.append(opt)
			"迎戰":
				# 居民團不可迎戰（鏡射舊 _dispatch_threat_response is_resident 排除）。
				if ctx.threat_react >= ctx.threat_threshold and not ctx.is_resident: out.append(opt)
			"求和":
				# ★求和 target(threat_id) 未在 reject_cooldown 內才候選（被拒不再纏 loop，diplomacy grounded）。
				if ctx.threat_react >= ctx.threat_threshold and not ctx.pacify_target_on_cooldown: out.append(opt)
			# 野心階梯溶入（序3）：FORCE-archetype + 有 anon 可練 → 練兵候選。
			"訓練":
				if ctx.archetype == AmbitionLadder.ARCHETYPE_FORCE and ctx.has_trainable: out.append(opt)
			# A2a 子隊：歸建＝服從母團，僅子隊候選（duty↔掠奪 rank 競秤，忠誠→歸建贏）。
			"歸建":
				if ctx.is_subteam: out.append(opt)
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
		"遷移找糧":
			# Fix B：移向視野內可達糧源（wild_game 遠格/糧市 pos）。複用 TASK_FORAGE（移動+抵達覓食）。
			# 抵達後本地覓食/買糧於 next cadence 引擎重秤自然承接（零新 try_set 落點；憲法閘 baseline 不變）。
			var fst: Vector2i = FactionAISystem.new()._find_food_seek_target(state, team)
			if fst == Vector2i(-1, -1): return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1, -1)}
			return {"task": TeamData.TASK_FORAGE, "target": fst}
		"survival": return {"task": TeamData.TASK_FLEE, "target": Vector2i(-1,-1)}
		"駐守":   return {"task": TeamData.TASK_GOVERN, "target": team.tile_pos}
		"返家補給": return {"task": TeamData.TASK_RETURN_HOME, "target": FactionAISystem.new()._find_own_outpost(state, team)}
		"掠奪":
			var pid: int = FactionAISystem.new()._find_weakest_prey(state, team)
			if pid == -1: return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1, -1)}
			# god-view 位置根治：敵情走 belief last-seen（含 staleness）；無 belief/過期→撲空棄（不移向真值/自身）。
			var pid_pos: Vector2i = BeliefSystem.belief_pos(state, team.team_id, pid)
			if pid_pos == Vector2i(-1, -1): return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1, -1)}
			return {"task": TeamData.TASK_LOOT, "target": pid_pos, "combat_target": pid}
		"佔村":
			# 攻取據村：TASK_ATTACK 到村格 → 戰勝 capture 自動翻旗（既有）→ 次 cadence has_own_outpost
			# → 生產/駐守 + _evaluate_outpost_residency 派駐（既有）接手 → 食引擎點火。不新造據點系統。
			var vid: int = FactionAISystem.new()._find_occupy_target(state, team)
			if vid == -1: return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1, -1)}
			# ★#7 佔村→打村格（outpost tile 靜態真值：物理設施非隊瞬時位置；belief last-seen 可能覓食位=打空地）。
			var vpos: Vector2i = FactionAISystem.new()._find_own_outpost(state, state.teams[vid])
			if vpos == Vector2i(-1, -1): return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1, -1)}
			return {"task": TeamData.TASK_ATTACK, "target": vpos, "combat_target": vid}
		"併入":
			# §3b：host = rep 保護傘(strong_neighbor,跨faction,喂-讀對齊磁鐵) 優先；無則 consolidate_target(同faction)。
			var _hc: DecisionContext = DecisionContext.gather(state, team)
			var host: int = _hc.strong_neighbor_id if _hc.strong_neighbor_id != -1 else _hc.consolidate_target_id
			if host == -1 or not state.teams.has(host): return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
			# belief_pos 內部分流：strong_neighbor(跨-faction)→belief / consolidate(同-faction)→known_member_states。
			var host_pos: Vector2i = BeliefSystem.belief_pos(state, team.team_id, host)
			if host_pos == Vector2i(-1, -1): return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
			return {"task": TeamData.TASK_JOIN, "target": host_pos,
				"social_target": host, "order_target": host}
		"吸納":
			# §HOW-7：強方向弱鄰行軍吸納。TASK_MERGE(merger=本強隊,order_target=弱鄰)→_try_merge 分流。
			var _ac: DecisionContext = DecisionContext.gather(state, team)
			var prey: int = _ac.absorb_target_id
			if prey == -1 or not state.teams.has(prey): return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
			var prey_pos: Vector2i = BeliefSystem.belief_pos(state, team.team_id, prey)   # 弱鄰位置走 belief（同-faction 走 known_member_states）
			if prey_pos == Vector2i(-1, -1): return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
			return {"task": TeamData.TASK_MERGE, "target": prey_pos, "order_target": prey}
		"紮營":
			var ft: Vector2i = FactionAISystem.new()._find_unowned_farmable_tile(state, team)
			if ft == Vector2i(-1,-1): return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
			return {"task": TeamData.TASK_CAMP, "target": ft}
		"乞食":
			var aid: int = FactionAISystem.new()._find_aid_target(state, team)
			if aid == -1: return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
			# 社交意圖：設 social_target 非 combat_target（resolver 讀 social_target）。位置走 belief（無/過期→撲空）。
			var aid_pos: Vector2i = BeliefSystem.belief_pos(state, team.team_id, aid)
			if aid_pos == Vector2i(-1, -1): return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
			return {"task": TeamData.TASK_BEG, "target": aid_pos, "social_target": aid}
		"攻擊":
			# 多源攻擊 target（優先序 faction directive > 征服 intent > 血仇 fallback）。序4 vendetta 溶入：
			# 純血仇驅動時 target=仇敵（feud_target_id），非粗取 _nearest_independent。ctx gather 取三源
			# （鏡射 迎戰/求和 局部 gather 法，避改 to_task 簽名 17 caller）。
			var _ac: DecisionContext = DecisionContext.gather(state, team)
			var atid: int = _ac.faction_attack_target if _ac.faction_attack_target != -1 \
				else (_ac.intent_target if _ac.intent_target != -1 else _ac.feud_target_id)
			if atid == -1 or not state.teams.has(atid):
				return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
			var atid_pos: Vector2i = BeliefSystem.belief_pos(state, team.team_id, atid)   # 攻擊 target 走 belief last-seen
			if atid_pos == Vector2i(-1, -1): return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
			return {"task": TeamData.TASK_ATTACK, "target": atid_pos, "combat_target": atid}
		"徵收":
			# 派系指定最富 member 徵貢（非戰，不設 combat_target）。排除自身（_richest_member 未排）。
			var f4 = state.factions.get(team.faction_id)
			if f4 == null: return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
			var rt: int = FactionAISystem.new()._richest_member(state, f4)
			if rt == -1 or rt == team.team_id: return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
			# #12 同-faction 徵收 → belief_pos 內走 known_member_states 通道（自家人非敵情 belief）。
			var rt_pos: Vector2i = BeliefSystem.belief_pos(state, team.team_id, rt)
			if rt_pos == Vector2i(-1, -1): return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
			return {"task": TeamData.TASK_TRIBUTE, "target": rt_pos}
		"外交":
			# 派系指定最近獨立隊外交（非戰，不設 combat_target）。
			var dt: int = FactionAISystem.new()._nearest_independent(state, team)
			if dt == -1: return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
			var dt_pos: Vector2i = BeliefSystem.belief_pos(state, team.team_id, dt)   # 外交 target(跨-faction)走 belief last-seen
			if dt_pos == Vector2i(-1, -1): return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
			return {"task": TeamData.TASK_DIPLOMACY, "target": dt_pos}
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
		# ── 融合 threat：3 反應映射（threat_pos/id 需 ctx → 局部 gather，避改 to_task 簽名 17 caller）──
		"備戰":
			# 備戰=原地整軍，無 target。
			return {"task": TeamData.TASK_PREPARE, "target": Vector2i(-1, -1)}
		"迎戰":
			var _dc: DecisionContext = DecisionContext.gather(state, team)
			if _dc.threat_id == -1: return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1, -1)}
			return {"task": TeamData.TASK_DEFEND, "target": _dc.threat_pos,
				"prosperity_target": _dc.threat_id}
		"求和":
			var _pc: DecisionContext = DecisionContext.gather(state, team)
			if _pc.threat_id == -1: return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1, -1)}
			return {"task": TeamData.TASK_DIPLOMACY, "target": _pc.threat_pos,
				"order_target": _pc.threat_id, "order_task": TeamData.TASK_TRIBUTE_OFFER}
		# 野心階梯溶入（序3）：練兵=原地 TASK_TRAIN（training_system 累積階兵）。
		"訓練":   return {"task": TeamData.TASK_TRAIN, "target": team.tile_pos}
		# A2a 歸建：由 _decide_subteam 特判為 lifecycle move（set move_target + merge_queue），
		# 不進 to_task 標準派工；此 fallback 為安全（若誤入標準路 → IDLE）。
		"歸建":   return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
		_:        return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
