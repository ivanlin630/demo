class_name DecisionOptions

# 統一決策引擎：Option 註冊表 + applicable 守衛 + to_task 對映。
# ★seam#1 S1（registry 化，byte-identical 純重構）：每 option = 一筆 data entry
#   { terms, applicable:Callable, to_task:Callable }。加候選 = 加 REGISTRY 1 entry
#   （applicable()/to_task() 本體零改，消兩平行 match）＝擴充性 proof。
# ★const→static var：entry 內含 Callable（lambda）不能進 const（constant expression 限制）。
#   REGISTRY 是 Dictionary → GDScript4 保插入序 → applicable() 產出池順序 byte-identical。
# ★caveat①（觀測 byte-identical）：applicable lambda 內嵌 Probe.bump 診斷副作用逐條原位保留。
# ★caveat②（A2a 共用前置閘）：subteam STRATEGIC_SELFINIT_SET 排除閘在 applicable() 迭代框架層
#   統一套一次（每 entry predicate 之前），非塞進各 entry pred → 未來加 option 不會漏套。
static var REGISTRY: Dictionary = {
	"貿易": {
		"affinity": [0.2, 0.0, 0.1, 0.6, 0.1], "sets": {"ambient": true},
		"terms": [["economic_opp", "economic"], ["intent_fit", "intent_fit"]],
		# roam-trade：商隊主力；生產隊也可(軟壓低 via economic_opp 角色因子,非禁)。
		# 駐村隊（movement 居民鎖）不濾：掛 TRADE 站自家村=擺攤營業（來客觸發 _resolve_market
		# + absorb 糧倉賣餘糧=需求側環實體）。漏斗 r3 實證：濾掉→村攤關門→成交崩，勿再加鎖。
		"applicable": func(ctx: DecisionContext) -> bool:
			return ctx.has_goods or ctx.has_arb,
		"to_task": func(state: WorldState, team: TeamData) -> Dictionary:
			var tgt: Vector2i = FactionAISystem.new()._merchant_trade_target(state, team)
			# ★god-view Slice C：belief-gate 後無已知市集→(-1,-1)。只 roaming merchant→IDLE（無市集去=無事可做）；
			# ★resident 擺攤 (-1,-1)=合法原地交易（PRODUCE 居民站自家村待客）→保 TASK_TRADE，防村攤關門(r3 regression)。
			if tgt == Vector2i(-1, -1) and not FactionAISystem.is_resident_static(state, team):
				return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1, -1)}
			return {"task": TeamData.TASK_TRADE, "target": tgt},
	},
	"生產": {
		"affinity": [0.3, 0.0, 0.0, 0.5, 0.2], "sets": {"ambient": true},
		"terms": [["produce_need", "settle"], ["ambition_drive", "ambition"]],
		# S1：製造需設施 precondition（A2 補缺）——無製造設施→濾掉（否則無設施選製造=no-op 空轉）。
		"applicable": func(ctx: DecisionContext) -> bool:
			if ctx.has_own_outpost and ctx.has_manufacturing_facility:
				return true
			elif ctx.has_own_outpost and Probe.enabled:
				Probe.bump("produce.appl_kill_nofacility")   # 生產被 precondition 濾（A2 主病可觀測）
			return false,
		"to_task": func(_state: WorldState, team: TeamData) -> Dictionary:
			return {"task": TeamData.TASK_MANUFACTURE, "target": team.tile_pos},
	},
	"建設": {
		"affinity": [0.1, 0.0, 0.0, 0.3, 0.6], "sets": {"ambient": true, "strategic_selfinit": true},
		# ★B idle-labor→建設：idle_employ_value=雇用閒 PRODUCE 勞力於待建產能真期望產出（只此 option、guardrail）。
		"terms": [["settle_fit", "settle"], ["ambition_drive", "ambition"], ["idle_employ_value", "idle_employ"]],
		"applicable": func(_ctx: DecisionContext) -> bool:
			return true,   # bootstrap(無據點建新) + 升級(有據點) 皆候選 → 無據點生產隊不被困
		"to_task": func(_state: WorldState, team: TeamData) -> Dictionary:
			return {"task": TeamData.TASK_BUILD, "target": team.tile_pos},
	},
	"覓食": {
		"affinity": [0.9, 0.1, 0.0, 0.0, 0.0], "sets": {"survival": true, "passive_survival": true},
		"terms": [["survival_pressure", "survival_pressure"]],
		# P2b-1：viable-pop 守衛移入 applicable（舊 _trigger_survival forage 限 pop≤此值）。
		# Fix4：+ 覓食可達性預檢——本格/鄰格無 wild_game tile 則不 applicable（防 forage-to-nowhere churn）。
		"applicable": func(ctx: DecisionContext) -> bool:
			return ctx.population <= FactionAISystem.FORAGE_VIABLE_POP and ctx.has_forage_tile,
		"to_task": func(state: WorldState, team: TeamData) -> Dictionary:
			return {"task": TeamData.TASK_FORAGE, "target": FactionAISystem.new()._find_forage_tile(state, team)},
	},
	"自救建田": {
		"affinity": [0.8, 0.0, 0.0, 0.0, 0.2], "sets": {"survival": true, "passive_survival": true},
		# ★復甦 R2 §2B.1（build-as-survival self-rescue、blueprint 裁 YES genuine）：飢餓村料備妥產糧設施 →
		# 蓋田自救（永久產能）勝覓食（臨時填）。util=1+食安價值 frac × P(survive_to_harvest)（ctx.rescue_build_util、
		# genuine 非死常數）；蓋不完(build_eta≥食窗)/料未備 → viable=false → 落覓食（可能餓死+料浪費=失敗案留、禁 crank）。
		# scope 硬限：僅產糧設施+料已備 means-end build→food（_food_rescue_eval 內 gate），禁泛化 build-instead-of-forage。
		"terms": [["food_rescue_build", "survival_pressure"]],
		"applicable": func(ctx: DecisionContext) -> bool:
			return ctx.can_rescue_build,
		"to_task": func(_state: WorldState, team: TeamData) -> Dictionary:
			return {"task": TeamData.TASK_BUILD, "target": team.tile_pos},
	},
	"survival": {
		"affinity": [0.2, 0.8, 0.0, 0.0, 0.0], "sets": {"threat": true},
		"terms": [["threat_pressure", "survival_pressure"]],
		"applicable": func(ctx: DecisionContext) -> bool:
			# null-belief-flee 根治（applicability-gate）：FLEE 僅當威脅有 belief 座標(threat_pos!=-1)才 applicable。
			# threat_pos 鏡射 _flee_threat_pos（同 team_discovered×ThreatAssessment.score max→belief_pos）——
			# positionless（威脅存在但無座標/stale）→ FLEE not applicable → 不選中 → 落次佳(覓食/defend)，
			# 非卡 task=逃跑 凍結餓死（movement 無座標無 target+continue，沒人 release）。不回退 live-track（無座標=真不知威脅在哪=顧眼前生存）。
			return ctx.threat_pos != Vector2i(-1, -1),
		"to_task": func(_state: WorldState, _team: TeamData) -> Dictionary:
			return {"task": TeamData.TASK_FLEE, "target": Vector2i(-1, -1)},
	},
	"駐守": {
		"affinity": [0.2, 0.1, 0.1, 0.1, 0.5], "sets": {"ambient": true},
		"terms": [["settle_fit", "settle"]],
		"applicable": func(ctx: DecisionContext) -> bool:
			return ctx.has_own_outpost,
		"to_task": func(_state: WorldState, team: TeamData) -> Dictionary:
			return {"task": TeamData.TASK_GOVERN, "target": team.tile_pos},
	},
	"返家補給": {
		"affinity": [0.7, 0.2, 0.1, 0.0, 0.0], "sets": {"survival": true, "passive_survival": true},
		"terms": [["restock_need", "survival_pressure"]],
		# 商隊 proactive 補給：糧低於 RESTOCK 且有家可回 → 回家補 carried(避 survival latch)。
		# P2b-1 generalize：任何有家隊絕境(food<DESPERATION)→回家(保 non-unified 1037 熱路徑)。
		# 經濟底 home-empty gate：家糧倉 < RESTOCK_MIN（空家）→ 不 offer（返空家乾耗無意義）
		#   → 讓 買糧/交易/覓食 接手（forest 隊賣特產換糧而非返空家）。
		# ★GATE-A：home-empty gate 加 OR home_food_productive——產糧家即使 granary 空也值得返（回去採飽，
		# 非空 granary trap）。harvest positional→離 food-rich home 買糧=home 沒人採→餓死 surplus 平原之修。
		# ★GATE-A 二刀 hysteresis：+returning 隊撐到 food≥RETURN_HYSTERESIS_DAYS(5) 才釋放——破 oscillation
		# (返家途中 food 過 DESPERATION 3→option 消失→漂回 idle/trade→re-warn，days_left 卡 1.6-3.0 never 爬升)。
		# band[3,5]:trigger 3 開始返家、途中撐到 food≥5 停 → 完成返家+到家 harvest 補到 5+ 才出門。
		"applicable": func(ctx: DecisionContext) -> bool:
			return ctx.has_home_outpost and (ctx.home_food >= DecisionTerms.RESTOCK_MIN or ctx.home_food_productive) and ( \
					(ctx.is_merchant and ctx.food_days < DecisionTerms.RESTOCK_DAYS) \
					or ctx.food_days < ctx.desperation_entry_threshold \
					or (ctx.current_task == TeamData.TASK_RETURN_HOME and ctx.food_days < DecisionTerms.RETURN_HYSTERESIS_DAYS)),
		"to_task": func(state: WorldState, team: TeamData) -> Dictionary:
			return {"task": TeamData.TASK_RETURN_HOME, "target": FactionAISystem.new()._find_own_outpost(state, team)},
	},
	"掠奪": {
		"affinity": [0.4, 0.0, 0.0, 0.5, 0.1], "sets": {"survival": true},
		"terms": [["loot_drive", "loot"], ["intent_fit", "intent_fit"]],
		"applicable": func(ctx: DecisionContext) -> bool:
			return ctx.has_weak_prey,
		"to_task": func(state: WorldState, team: TeamData) -> Dictionary:
			var pid: int = FactionAISystem.new()._find_weakest_prey(state, team)
			if pid == -1: return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1, -1)}
			# god-view 位置根治：敵情走 belief last-seen（含 staleness）；無 belief/過期→撲空棄（不移向真值/自身）。
			var pid_pos: Vector2i = BeliefSystem.belief_pos(state, team.team_id, pid)
			if pid_pos == Vector2i(-1, -1): return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1, -1)}
			return {"task": TeamData.TASK_LOOT, "target": pid_pos, "combat_target": pid},
	},
	# 佔村：奪據點+搬進去（雙引擎咬合）。與掠奪同 menu 秤 util argmax（零新判斷器）。
	# intent_fit=匱乏→奪產村 boost（與掠奪 parallel）；occupy_drive=野心 base_need edge（決定佔 vs 搶）。
	"佔村": {
		"affinity": [0.3, 0.0, 0.0, 0.4, 0.3], "sets": {"survival": true, "strategic_selfinit": true},
		"terms": [["occupy_drive", "occupy"], ["intent_fit", "intent_fit"]],
		# means-end：要根據地的狼（無自家 outpost 最需要 / 或征服 intent）+ 有可據弱村 + pop 夠守+分駐。
		"applicable": func(ctx: DecisionContext) -> bool:
			if ctx.has_occupy_target:
				Probe.bump("occupy.ctx_hastarget")
				if ctx.population < DecisionTerms.OCCUPY_MIN_POP:
					Probe.bump("occupy.appl_kill_pop")
				elif ctx.has_own_outpost and ctx.intent != "征服":
					Probe.bump("occupy.appl_kill_hasbase")
				else:
					Probe.bump("occupy.applicable")
					return true
			return false,
		"to_task": func(state: WorldState, team: TeamData) -> Dictionary:
			# 攻取據村：TASK_ATTACK 到村格 → 戰勝 capture 自動翻旗（既有）→ 次 cadence has_own_outpost
			# → 生產/駐守 + _evaluate_outpost_residency 派駐（既有）接手 → 食引擎點火。不新造據點系統。
			var vid: int = FactionAISystem.new()._find_occupy_target(state, team)
			if vid == -1: return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1, -1)}
			# ★#7 佔村→打村格（outpost tile 靜態真值：物理設施非隊瞬時位置；belief last-seen 可能覓食位=打空地）。
			var vpos: Vector2i = FactionAISystem.new()._find_own_outpost(state, state.teams[vid])
			if vpos == Vector2i(-1, -1): return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1, -1)}
			return {"task": TeamData.TASK_ATTACK, "target": vpos, "combat_target": vid},
	},
	# S-A §HOW-6：統一「併入」（join+整併合一，取代兩 row）。絕境求生 food-scaled；weight=求生欲/(1-野心)
	# （§HOW-6 定，非 join weight——join weight×low_ambition 使 併入 rank 過低不勝 survival first=0 regression）。
	"併入": {
		"affinity": [0.3, 0.1, 0.6, 0.0, 0.0], "sets": {"survival": true, "passive_survival": true},
		"terms": [["join_drive", "mergein"]],
		# §HOW-8 ungate + §3b：絕境 OR 威脅認慫。host = rep 保護傘(strong_neighbor,跨faction) 或 consolidate_target(同faction)。
		# Fix A-2 v2：+ has_acceptable_join_host（可達且未近期被拒的 host）→ 不追必被拒的併入幻覺 loop。
		"applicable": func(ctx: DecisionContext) -> bool:
			return (ctx.has_strong_neighbor or ctx.consolidate_target_id != -1) \
					and ctx.has_acceptable_join_host \
					and (ctx.food_days < ctx.desperation_entry_threshold \
						or (ctx.has_strong_neighbor and ctx.threat > ctx.threat_threshold)),
		"to_task": func(state: WorldState, team: TeamData) -> Dictionary:
			# §3b：host = rep 保護傘(strong_neighbor,跨faction,喂-讀對齊磁鐵) 優先；無則 consolidate_target(同faction)。
			var _hc: DecisionContext = DecisionContext.gather(state, team)
			var host: int = _hc.strong_neighbor_id if _hc.strong_neighbor_id != -1 else _hc.consolidate_target_id
			if host == -1 or not state.teams.has(host): return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1, -1)}
			# belief_pos 內部分流：strong_neighbor(跨-faction)→belief / consolidate(同-faction)→known_member_states。
			var host_pos: Vector2i = BeliefSystem.belief_pos(state, team.team_id, host)
			if host_pos == Vector2i(-1, -1): return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1, -1)}
			return {"task": TeamData.TASK_JOIN, "target": host_pos,
				"social_target": host, "order_target": host},
	},
	# S-A §HOW-7：強方擴張 pull「吸納」（強隊主動吸弱鄰，擴張-class @PRIO_DISPATCH，非 survival）。
	"吸納": {
		"affinity": [0.0, 0.0, 0.4, 0.3, 0.3], "sets": {"strategic_selfinit": true},
		"terms": [["absorb_drive", "absorb"]],
		# §HOW-7：有 capacity-bound 可吸弱鄰（finder 已保統領餘裕裝得下）→ 擴張候選（無 food gate）。
		"applicable": func(ctx: DecisionContext) -> bool:
			return ctx.absorb_target_id != -1,
		"to_task": func(state: WorldState, team: TeamData) -> Dictionary:
			# §HOW-7：強方向弱鄰行軍吸納。TASK_MERGE(merger=本強隊,order_target=弱鄰)→_try_merge 分流。
			var _ac: DecisionContext = DecisionContext.gather(state, team)
			var prey: int = _ac.absorb_target_id
			if prey == -1 or not state.teams.has(prey): return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1, -1)}
			var prey_pos: Vector2i = BeliefSystem.belief_pos(state, team.team_id, prey)   # 弱鄰位置走 belief（同-faction 走 known_member_states）
			if prey_pos == Vector2i(-1, -1): return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1, -1)}
			return {"task": TeamData.TASK_MERGE, "target": prey_pos, "order_target": prey},
	},
	"紮營": {
		"affinity": [0.6, 0.1, 0.0, 0.1, 0.2], "sets": {"survival": true, "passive_survival": true},
		"terms": [["camp_drive", "camp"]],
		"applicable": func(ctx: DecisionContext) -> bool:
		# ★接入 arc de-patch（實測分流：母隊零採集 1109 次中，517 卡此門檻／592 applicable 卻秤輸／0 找不到可耕地）：
		# ★沒有被動收入的隊不該等到瀕餓才准紮營——那是 catch-22：不餓→不 applicable；餓了→ applicable
		#   但必然輸給「立刻找吃的」（覓食/買糧吃 survival boost）。⇒ 拿掉絕境門檻，改由 camp_drive 的真值
		#   （marg × urgency × 選址記憶）自己秤（term 非 gate）。★不抬 camp 分數、不加補償補丁；
		#   秤輸與否留常設 tap（camp.lost_to.* / camp.won_argmax）看得見。
			return ctx.has_farmable_tile and not ctx.has_own_outpost,
		"to_task": func(state: WorldState, team: TeamData) -> Dictionary:
			var ft: Vector2i = FactionAISystem.new()._find_unowned_farmable_tile(state, team)
			if ft == Vector2i(-1, -1):
				# ★R² 保險 tap：applicable 算過可以、to_task 真呼時卻沒地了（同函式、不同時間點；
				#   中間可能被同 tick 別隊佔走）。「證明不出會發生」≠「不會發生」→ 留一個看得見的 tap。
				if Probe.enabled: Probe.bump("camp.applicable_but_idle")
				return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1, -1)}
			return {"task": TeamData.TASK_CAMP, "target": ft},
	},
	"紮根": {
		# ★§4a 建點入引擎（取代 _evaluate_l0_settle scaffolding）：L0 營地 → L1 據點的工期決策。
		# applicable=★只物理可行性（站自己 L0 空地 or 自己未完工地）——viability 不做硬門檻，
		#   撐不撐得過工期由 rooting_drive 的可行性帳表達（瀕餓 util→0 自然不開工、禁硬門檻回潮）。
		# ★to_task 零世界寫入（只回 {task,target,settle_site}）：construction_* / corvee_site 由
		#   try_set 成功後的 commit-hook 寫（faction_ai._commit_settle_site）——否則 try_set false
		#   （combat 鎖／crisis 免疫窗／persist hold／搶班失敗）會留下「tile 標記但隊沒進 BUILD」的 zombie 工地。
		"affinity": [0.5, 0.1, 0.0, 0.2, 0.2], "sets": {"survival": true},
		# ★commit priority 解耦（§4a REDO）：留在 survival set（rank_survival 只收 survival-set，
		#   拿掉＝絕境隊結構性沒紮根選項＝隱含硬門檻），但 committed 後只值 @50——
		#   否則 @80 > PRIO_THREAT(70) 會讓壓境威脅再也打不斷 L1 工期（敵人壓境還在蓋房子）。
		"priority": TaskArbiter.PRIO_DISPATCH,
		"terms": [["rooting_drive", "rooting"]],
		"applicable": func(ctx: DecisionContext) -> bool:
			return ctx.can_settle_here or ctx.settle_resume_site != Vector2i(-1, -1),
		"to_task": func(state: WorldState, team: TeamData) -> Dictionary:
			var _ctx: DecisionContext = DecisionContext.gather(state, team)
			var _site: Vector2i = _ctx.settle_resume_site if _ctx.settle_resume_site != Vector2i(-1, -1) else team.tile_pos
			return {"task": TeamData.TASK_BUILD, "target": _site, "settle_site": _site},
	},
	"擴點": {
		# ★§4b ②擴張動機（純邊際帳）：有家的隊開第二據點。原本 紮營 被 not has_own_outpost 擋死＝
		#   有家隊結構性無法擴張（size-matter arc 記的 spread gap）→ 本 option 補上。
		# applicable=只物理可行性（有家＋選址有效候選＋母隊 pop 足以派子隊[沿用 _dispatch_builder
		#   既有規則、不新增門檻]＋非玩家）；值不值得擴全由 expand_drive 的邊際帳決定。
		# to_task=delegate 既有路（build_type）→ _dispatch_builder：六道 guard 全在前、唯一世界寫入
		#   在最後一行 all-or-nothing → 與 §4a 那種 to_task 副作用 race 不同類，不需額外 commit-hook。
		"affinity": [0.1, 0.1, 0.0, 0.3, 0.5], "sets": {"ambient": true, "strategic_selfinit": true},
		# ★commit priority（§4a invariants 契約）：擴點＝發展型動作 → @50，壓境威脅/絕境仍能打斷。
		"priority": TaskArbiter.PRIO_DISPATCH,
		"terms": [["expand_drive", "expand"]],
		"applicable": func(ctx: DecisionContext) -> bool:
			return ctx.can_expand,
		"to_task": func(state: WorldState, team: TeamData) -> Dictionary:
			var _ctx: DecisionContext = DecisionContext.gather(state, team)
			if not _ctx.can_expand: return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1, -1)}
			var _ldr: PersonData = state.persons.get(team.leader_id)
			var _tile: HexTileData = state.world.tiles.get(ResourceSystem._pos_to_tile_id(_ctx.expand_pos))
			var _type: String = FactionAISystem.new()._pick_outpost_type(state, team, _ldr, _tile)
			return {"delegate": true, "task": TeamData.TASK_BUILD, "target": _ctx.expand_pos,
				"build_type": _type, "settler": _ctx.expand_settler},
	},
	"乞食": {
		"affinity": [0.8, 0.0, 0.2, 0.0, 0.0], "sets": {"survival": true, "passive_survival": true},
		"terms": [["beg_drive", "beg"]],
		"applicable": func(ctx: DecisionContext) -> bool:
			return ctx.food_days < ctx.desperation_entry_threshold and ctx.has_aid_target,
		"to_task": func(state: WorldState, team: TeamData) -> Dictionary:
			var aid: int = FactionAISystem.new()._find_aid_target(state, team)
			if aid == -1: return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1, -1)}
			# 社交意圖：設 social_target 非 combat_target（resolver 讀 social_target）。位置走 belief（無/過期→撲空）。
			var aid_pos: Vector2i = BeliefSystem.belief_pos(state, team.team_id, aid)
			if aid_pos == Vector2i(-1, -1): return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1, -1)}
			return {"task": TeamData.TASK_BEG, "target": aid_pos, "social_target": aid},
	},
	# 序4 vendetta 溶入：feud_pull term 掛入 → 血仇成攻擊的一個 weight 驅力（衝動 leader 血仇高→攻擊贏 rank）。
	"攻擊": {
		"affinity": [0.1, 0.1, 0.0, 0.6, 0.2], "sets": {"stakes": true},
		"terms": [["faction_duty", "faction_duty"], ["attack_drive", "attack"], ["intent_fit", "intent_fit"], ["feud_pull", "feud"]],
		# 混合協調：派系 directive=攻擊 且有獨立 target → 候選（無 directive 時零影響）。
		# means-end：征服 intent 隊亦開攻擊（非只 faction_stakes），target=intent_target/weak_prey。
		# 序4 血仇路：強血仇(≥FEUD_ATTACK_MIN)+可見仇敵 → 攻擊 applicable（衝動 leader 拉隊打仇人）。
		"applicable": func(ctx: DecisionContext) -> bool:
			return ("攻擊" in ctx.faction_stakes and ctx.faction_attack_target != -1) \
					or (ctx.intent == "征服" and ctx.intent_target != -1) \
					or (ctx.strongest_feud >= FEUD_ATTACK_MIN and ctx.feud_target_id != -1),
		"to_task": func(state: WorldState, team: TeamData) -> Dictionary:
			# 多源攻擊 target（優先序 faction directive > 征服 intent > 血仇 fallback）。序4 vendetta 溶入：
			# 純血仇驅動時 target=仇敵（feud_target_id），非粗取 _nearest_independent。ctx gather 取三源
			# （鏡射 迎戰/求和 局部 gather 法，避改 to_task 簽名 17 caller）。
			var _ac: DecisionContext = DecisionContext.gather(state, team)
			var atid: int = _ac.faction_attack_target if _ac.faction_attack_target != -1 \
				else (_ac.intent_target if _ac.intent_target != -1 else _ac.feud_target_id)
			if atid == -1 or not state.teams.has(atid):
				return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1, -1)}
			var atid_pos: Vector2i = BeliefSystem.belief_pos(state, team.team_id, atid)   # 攻擊 target 走 belief last-seen
			if atid_pos == Vector2i(-1, -1): return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1, -1)}
			return {"task": TeamData.TASK_ATTACK, "target": atid_pos, "combat_target": atid},
	},
	"徵收": {
		"affinity": [0.0, 0.0, 0.2, 0.6, 0.2], "sets": {"stakes": true},
		"terms": [["faction_duty", "faction_duty"], ["levy_drive", "levy"]],
		# 派系 directive=徵收 且有更富 member target → 候選。
		"applicable": func(ctx: DecisionContext) -> bool:
			return "徵收" in ctx.faction_stakes and ctx.faction_tribute_target != -1,
		"to_task": func(state: WorldState, team: TeamData) -> Dictionary:
			# 派系指定最富 member 徵貢（非戰，不設 combat_target）。排除自身（_richest_member 未排）。
			var f4 = state.factions.get(team.faction_id)
			if f4 == null: return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1, -1)}
			var rt: int = FactionAISystem.new()._richest_member(state, f4)
			if rt == -1 or rt == team.team_id: return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1, -1)}
			# #12 同-faction 徵收 → belief_pos 內走 known_member_states 通道（自家人非敵情 belief）。
			var rt_pos: Vector2i = BeliefSystem.belief_pos(state, team.team_id, rt)
			if rt_pos == Vector2i(-1, -1): return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1, -1)}
			return {"task": TeamData.TASK_TRIBUTE, "target": rt_pos},
	},
	"外交": {
		"affinity": [0.0, 0.1, 0.6, 0.1, 0.2], "sets": {"stakes": true},
		"terms": [["faction_duty", "faction_duty"], ["diplo_drive", "diplo"]],
		# 派系 directive=外交 且有獨立鄰 target + ★target 未在 reject_cooldown 內（被拒不再纏）→ 候選。
		"applicable": func(ctx: DecisionContext) -> bool:
			return "外交" in ctx.faction_stakes and ctx.faction_diplo_target != -1 \
					and not ctx.diplo_target_on_cooldown,
		"to_task": func(state: WorldState, team: TeamData) -> Dictionary:
			# 派系指定最近獨立隊外交（非戰，不設 combat_target）。
			var dt: int = FactionAISystem.new()._nearest_independent(state, team)
			if dt == -1: return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1, -1)}
			var dt_pos: Vector2i = BeliefSystem.belief_pos(state, team.team_id, dt)   # 外交 target(跨-faction)走 belief last-seen
			if dt_pos == Vector2i(-1, -1): return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1, -1)}
			return {"task": TeamData.TASK_DIPLOMACY, "target": dt_pos},
	},
	"買糧": {
		"affinity": [0.9, 0.0, 0.1, 0.0, 0.0], "sets": {"survival": true, "passive_survival": true},
		"terms": [["buyfood_drive", "buyfood"]],
		# 餓 + 有市集 + 有錢 + ★聽過食物賣單(has_buyable_food) → 買糧候選（Fix A look-before-leap：
		# 從沒聽過任何食物賣單=不追純幻覺；無錢=乞食真語意，不入）。駐村隊不濾。
		# ★GATE-A（reviewer R² 必加）：加 not home_food_productive——產糧家結構偏好返家採飽（非離家買糧
		# 海市蜃樓餓死）。閉商隊 toss-up trap（返家 1.0≈買糧 merchant 1.0，靠 drive 競不贏→結構 gate）。
		# 鏡射 material-buy food-ok gate 互斥。targeted:forest(home_food_productive=false)→買糧不變(仍離家買=多樣性)。
		"applicable": func(ctx: DecisionContext) -> bool:
			return ctx.food_days < ctx.desperation_entry_threshold and ctx.has_food_market \
					and ctx.has_specie and ctx.has_buyable_food and not ctx.home_food_productive,
		"to_task": func(state: WorldState, team: TeamData) -> Dictionary:
			# 到最近市集 outpost 走既有 TASK_TRADE；到場 _resolve_market 餓隊 food local_value 高→買 food。
			var mp: Vector2i = FactionAISystem.new()._nearest_market_outpost(state, team)
			if mp == Vector2i(-1, -1): return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1, -1)}
			return {"task": TeamData.TASK_TRADE, "target": mp},
	},
	# ★買料（material means-end，Gate B trade-primary 核心）：想建 facility→material need（NeedOracle _construction_facility_need）
	# → 缺料 + 有 material 市場 + 有籌碼 → 到有 material 的最近已知市集買（閉環:reserve>0→_market_visitor_buy want-driven 買 material→建得起）。
	# 仿買糧結構;非 survival（economic），PRIO_DISPATCH。
	"買料": {
		"affinity": [0.2, 0.2, 0.2, 0.2, 0.2], "sets": {},   # ★F4 INV-1：買料非表2→顯式 UNIFORM(保序、非訂正)

		"terms": [["buymaterial_drive", "buymaterial"]],
		"applicable": func(ctx: DecisionContext) -> bool:
			# ★v2a food-ok gate（reviewer R²）：買料非 survival-class→util 高搶 survival rank；餓隊買料→餓死。
			# food_days>=entry_threshold（鏡射買糧 food<threshold=互斥）→餓時只買糧、食足才投資建設料=結構防餓死。
			# ★F1 靶A：讀同一 ctx.desperation_entry_threshold（買糧<threshold 的 mutex 補集、保互斥不破 gap/overlap）。
			return ctx.food_days >= ctx.desperation_entry_threshold \
					and ctx.material_shortfall > 0.0 and ctx.has_material_market and ctx.has_specie,
		"to_task": func(state: WorldState, team: TeamData) -> Dictionary:
			var mp: Vector2i = FactionAISystem.new()._nearest_market_outpost_with(state, team, "material")
			if mp == Vector2i(-1, -1): return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1, -1)}
			return {"task": TeamData.TASK_TRADE, "target": mp},
	},
	# Fix B 遷移找糧：絕境階梯新階（當地求生全不可 fulfill → 移向視野內可達糧源）。獨立 option 保承諾慣性/trace
	# 可讀；weight 複用 survival_pressure（食物越低越想動，同覓食驅力）。排序 emergent（weight×人格 argmax）非硬階梯。
	"遷移找糧": {
		"affinity": [0.2, 0.2, 0.2, 0.2, 0.2], "sets": {"survival": true},   # ★F4 INV-1：遷移找糧非表2→顯式 UNIFORM(保序;∈SURVIVAL_SET 但 uniform affinity=follow-up behavior slice)

		"terms": [["survival_pressure", "survival_pressure"]],
		# Fix B 絕境階梯新階：餓 + 有可達已知糧源(food_seek_target) + 當地覓食·買糧皆不 applicable
		# → 移向糧源（有 local 出路優先 local，不遷移）。撲空/target 消失由 cadence 重秤 + C 連貫死收。
		"applicable": func(ctx: DecisionContext) -> bool:
			var _forage_ok: bool = ctx.population <= FactionAISystem.FORAGE_VIABLE_POP and ctx.has_forage_tile
			var _buyfood_ok: bool = ctx.has_food_market and ctx.has_specie and ctx.has_buyable_food
			return ctx.food_days < ctx.desperation_entry_threshold \
					and ctx.food_seek_target != Vector2i(-1, -1) \
					and not _forage_ok and not _buyfood_ok,
		"to_task": func(state: WorldState, team: TeamData) -> Dictionary:
			# Fix B：移向視野內可達糧源（wild_game 遠格/糧市 pos）。複用 TASK_FORAGE（移動+抵達覓食）。
			# 抵達後本地覓食/買糧於 next cadence 引擎重秤自然承接（零新 try_set 落點；憲法閘 baseline 不變）。
			var fst: Vector2i = FactionAISystem.new()._find_food_seek_target(state, team)
			if fst == Vector2i(-1, -1): return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1, -1)}
			return {"task": TeamData.TASK_FORAGE, "target": fst},
	},
	# means-end：致富+餘糧 → 蓋倉囤貨低買高賣（複用 TASK_TRADE 到市集 hub，非新機制）。
	"囤貨": {
		"affinity": [0.1, 0.0, 0.0, 0.7, 0.2], "sets": {"ambient": true},
		"terms": [["intent_fit", "intent_fit"]],
		# means-end：致富 intent + 有餘糧 + 有貿易機會(arb/市集) → 蓋倉囤貨候選。
		# 駐村隊不濾（同「貿易」註：TRADE 姿態=村攤營業，非 zombie）。
		"applicable": func(ctx: DecisionContext) -> bool:
			return ctx.intent == "致富" and ctx.food_days >= DecisionTerms.SURPLUS_FOOD_DAYS \
					and (ctx.has_arb or ctx.has_food_market),
		"to_task": func(state: WorldState, team: TeamData) -> Dictionary:
			# 致富囤貨：到市集 hub 低買囤積（複用 TASK_TRADE，target=市集 outpost）；無市集則退貿易對象。
			var hub: Vector2i = FactionAISystem.new()._nearest_market_outpost(state, team)
			if hub == Vector2i(-1, -1):
				hub = FactionAISystem.new()._merchant_trade_target(state, team)
			if hub == Vector2i(-1, -1): return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1, -1)}
			return {"task": TeamData.TASK_TRADE, "target": hub},
	},
	# ── 融合 threat（序1 溶入）：4 反應 repertoire 中的 3（FLEE=既有 survival option）。
	# threat-gated（applicable 讀 threat_react≥threshold），人格秤 argmax（撕除舊手算）。
	"備戰": {
		"affinity": [0.1, 0.8, 0.0, 0.1, 0.0], "sets": {"threat": true},
		"terms": [["prepare_drive", "prepare"]],
		"applicable": func(ctx: DecisionContext) -> bool:
			return ctx.threat_react >= ctx.threat_threshold,
		"to_task": func(_state: WorldState, _team: TeamData) -> Dictionary:
			# 備戰=原地整軍，無 target。
			return {"task": TeamData.TASK_PREPARE, "target": Vector2i(-1, -1)},
	},
	"迎戰": {
		"affinity": [0.1, 0.6, 0.0, 0.3, 0.0], "sets": {"threat": true},
		"terms": [["defend_drive", "defend"]],
		# 居民團不可迎戰（鏡射舊 _dispatch_threat_response is_resident 排除）。
		"applicable": func(ctx: DecisionContext) -> bool:
			return ctx.threat_react >= ctx.threat_threshold and not ctx.is_resident,
		"to_task": func(state: WorldState, team: TeamData) -> Dictionary:
			var _dc: DecisionContext = DecisionContext.gather(state, team)
			if _dc.threat_id == -1: return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1, -1)}
			return {"task": TeamData.TASK_DEFEND, "target": _dc.threat_pos,
				"prosperity_target": _dc.threat_id},
	},
	"求和": {
		"affinity": [0.1, 0.7, 0.2, 0.0, 0.0], "sets": {"threat": true},
		"terms": [["pacify_drive", "pacify"]],
		# ★求和 target(threat_id) 未在 reject_cooldown 內才候選（被拒不再纏 loop，diplomacy grounded）。
		"applicable": func(ctx: DecisionContext) -> bool:
			return ctx.threat_react >= ctx.threat_threshold and not ctx.pacify_target_on_cooldown,
		"to_task": func(state: WorldState, team: TeamData) -> Dictionary:
			var _pc: DecisionContext = DecisionContext.gather(state, team)
			if _pc.threat_id == -1: return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1, -1)}
			return {"task": TeamData.TASK_DIPLOMACY, "target": _pc.threat_pos,
				"order_target": _pc.threat_id, "order_task": TeamData.TASK_TRIBUTE_OFFER},
	},
	# ★資訊網 Part2 (a) side-action（de-patch）：求援/偵察 **脫離主 argmax**（原 REGISTRY entry 移除）——
	# 派 1 anon 跑腿=平行 side-action（派信使≠放棄自救、村莊邊覓食邊派人求救；逼進單 task argmax=category error）。
	# → 移到 faction_ai `_info_side_dispatch`（sim_runner _step6b2、平行 tick step、mini-util cost-benefit）。
	# 主決策 winner 不變（移除本就 rank 3/4 的 loser 對 argmax 中性、determinism-neutral）。
	# 野心階梯溶入（序3）：FORCE-archetype 累積階練兵（原 rung_task ACCUMULATE×FORCE→TASK_TRAIN）。
	# archetype/rung 當 weight（ambient_train_drive）驅動，非查表塞 task。
	"訓練": {
		"affinity": [0.0, 0.1, 0.0, 0.7, 0.2], "sets": {"ambient": true, "strategic_selfinit": true},
		"terms": [["train_drive", "train"]],
		# ★named-scarcity B：訓練 applicable 連 officer-need（非只 FORCE archetype）——缺 officer 領主(ambient_train_drive>0
		#   =officer_need>0)亦可練兵補班底;officer 夠 且 非 FORCE → 不 applicable（bounded、非 always-train）。
		"applicable": func(ctx: DecisionContext) -> bool:
			return ctx.has_trainable and (ctx.archetype == AmbitionLadder.ARCHETYPE_FORCE or ctx.ambient_train_drive > 0.0),
		"to_task": func(_state: WorldState, team: TeamData) -> Dictionary:
			# 野心階梯溶入（序3）：練兵=原地 TASK_TRAIN（training_system 累積階兵）。
			return {"task": TeamData.TASK_TRAIN, "target": team.tile_pos},
	},
	# A2a 子隊溶入：歸建＝服從母團權威/回母團集結（duty 驅，通用 row，非子隊專屬 term）。
	# faction_duty weight 已 _duty_factor(loyalty,野心)→忠誠子隊聽令回母團；不忠→掠奪(greed)贏 rank。
	"歸建": {
		"affinity": [0.1, 0.1, 0.8, 0.0, 0.0], "sets": {},
		"terms": [["faction_duty", "faction_duty"]],
		"applicable": func(ctx: DecisionContext) -> bool:
			return ctx.is_subteam,
		"to_task": func(_state: WorldState, _team: TeamData) -> Dictionary:
			# A2a 歸建：由 _decide_subteam 特判為 lifecycle move（set move_target + merge_queue），
			# 不進 to_task 標準派工；此 fallback 為安全（若誤入標準路 → IDLE）。
			return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1, -1)},
	},
}

# ★F4 統一註冊表（INV-2b fork=b）：6 個舊 OPTION_SET const array 已刪、單源 REGISTRY[opt].sets。
# set name: survival / passive_survival / threat / ambient / strategic_selfinit / stakes。
# is_in_set：REGISTRY.has guard（非-REGISTRY opt→false，等價舊 `opt in SET`）+ sets.get(name,false)。
static func is_in_set(opt: String, name: String) -> bool:
	return REGISTRY.has(opt) and bool((REGISTRY[opt].get("sets", {}) as Dictionary).get(name, false))

# options_in_set：REGISTRY 插入序迭代 filter（byte-identical 迭代序：STAKES 手序 ["攻擊","徵收","外交"] = REGISTRY 序）。
static func options_in_set(name: String) -> Array:
	var out: Array = []
	for opt in REGISTRY:
		if bool((REGISTRY[opt].get("sets", {}) as Dictionary).get(name, false)):
			out.append(opt)
	return out

# 序4 vendetta 溶入：血仇開打門檻（防輕微不快即戰）。TEST VALUE。
const FEUD_ATTACK_MIN := 0.5

# ★絕境經濟 ① survival 保序單一源（team19/subteam whack-a-mole 收單一源；散落常數=統一矩陣程序正靶）：
# option → commit priority。**全 dispatch 路一律讀此**（_decide_unified/_evaluate_solo/_trigger_survival/
# _decide_subteam/_try_join_target）→ 不變量:survival 保序=命運不看走哪 dispatch 路，solo/unified/subteam
# commit priority 一致（survival-class 皆 PRIO_SURVIVAL）。加 survival-class option 自動涵蓋（SURVIVAL_OPTION_SET）。
# ★護欄①白名單（§4a REDO addendum）：REGISTRY "priority" 欄的合法值域＝TaskArbiter 具名常數本身。
# 新增優先序層級時在 TaskArbiter 定常數並加進此表（單一源），不接受 REGISTRY 端自創數字。
const PRIORITY_ALLOWED: Array = [
	TaskArbiter.PRIO_DISPATCH, TaskArbiter.PRIO_PLAYER, TaskArbiter.PRIO_THREAT, TaskArbiter.PRIO_SURVIVAL,
]

static func priority_for(opt: String) -> int:
	# ★§4a REDO：REGISTRY 通用 optional 欄 "priority" 優先——set membership（在哪些 rank 清單競爭）
	# 與 commit priority（committed 後誰能打斷）本是兩件事，原本被此函式綁死。長工期的發展型
	# survival option（紮根）是第一個暴露它的：留在 survival set（絕境層也要能同秤競爭、
	# 禁隱含硬門檻），但 commit 只值 PRIO_DISPATCH（壓境威脅/絕境仍能打斷工期＝S2b 中斷路）。
	var entry: Dictionary = REGISTRY.get(opt, {})
	if entry.has("priority"):
		# ★護欄①值域鎖死（reviewer 要求、code 端落實非只靠註解）：只認 TaskArbiter 既有具名常數，
		#   禁裸 int（防日後隨手標 99 繞過整個優先序階梯）。非法值→assert 擋下 + 退回預設推導。
		var _p: int = int(entry["priority"])
		assert(_p in PRIORITY_ALLOWED, "option '%s' 的 priority 欄只准填 TaskArbiter 具名常數（禁裸 int），得到 %d" % [opt, _p])
		if _p in PRIORITY_ALLOWED:
			return _p
	if is_in_set(opt, "survival") or opt == "survival":
		return TaskArbiter.PRIO_SURVIVAL   # 求生 preempt 同層(絕境隊命運不看 dispatch 路)
	if opt in ["備戰", "迎戰", "求和"]:
		return TaskArbiter.PRIO_THREAT      # threat 反應 @70(finding3 黏性)
	return TaskArbiter.PRIO_DISPATCH

static func applicable(ctx: DecisionContext) -> Array:
	var out: Array = []
	var stalled_excluded: Array = []   # ② 因 stall 排除的 raw-applicable survival option（design-5 單一 option 豁免候選）
	var has_survival: bool = false     # ② 排除後仍有 applicable survival option？（無→觸發豁免）
	for opt in REGISTRY:
		# ★caveat②：A2a 通用戰略-gate（每 entry predicate 之前統一套一次，非塞進各 entry pred）：
		# 子隊不自主發起戰略級 option（立據/奪據/練兵＝leader/faction 決定；母團戰略令走 pre-set lifecycle task）。
		# 非子隊 is_subteam=false → 不觸 → 行為零變。新增戰略 option 入 STRATEGIC_SELFINIT_SET 自動涵蓋。
		if ctx.is_subteam and is_in_set(opt, "strategic_selfinit"):
			continue
		var _is_surv: bool = is_in_set(opt, "survival")
		# ② 絕境階梯失敗回饋單一源：stall cooldown 內的 survival option 暫退候選（全 rank 路共用=unified/solo/subteam/survival）。
		# argmax 自然選次高 base-weight applicable survival 格 → 產階梯 progression。被排除者記入 stalled_excluded 供豁免。
		if _is_surv and opt in ctx.survival_stall_active:
			if REGISTRY[opt]["applicable"].call(ctx):
				stalled_excluded.append(opt)
			continue
		if REGISTRY[opt]["applicable"].call(ctx):
			out.append(opt)
			if _is_surv: has_survival = true
	# ② design-5 單一 option 豁免（★單一源，全 rank 路共用：solo/unified/subteam/survival 皆走此 applicable）：
	# stall 排除後若無任何 applicable survival option → ride 被排除者（唯一 survival 生路，非 idle-starve/窮死出路）。
	if not has_survival and stalled_excluded.size() > 0:   # gate-ok: ② design-5 單一 option 豁免（引擎絕境生路 ride 窮死，非 patch override/機械 pre-empt）
		out.append_array(stalled_excluded)
	return out

static func terms_of(opt: String) -> Array:
	return REGISTRY.get(opt, {}).get("terms", [])

# Option → 既有 TASK_* + target（複用既有 dispatch helper）。未知 opt → IDLE fallback。
static func to_task(state: WorldState, team: TeamData, opt: String) -> Dictionary:
	var entry: Dictionary = REGISTRY.get(opt, {})
	if entry.is_empty():
		return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1, -1)}
	return entry["to_task"].call(state, team)
