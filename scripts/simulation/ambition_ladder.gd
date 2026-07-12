class_name AmbitionLadder

const RUNG_SURVIVE: int = 0
const RUNG_ACCUMULATE: int = 1
const RUNG_EXPAND: int = 2
const RUNG_STATE: int = 3
const RUNG_HEGEMON: int = 4

const ARCHETYPE_FORCE: String = "武力"
const ARCHETYPE_TRADE: String = "商業"
const ARCHETYPE_SETTLE: String = "定居"

const LADDER_EVAL_CADENCE: int = 10 * WorldState.TICKS_PER_HOUR
# 安全門檻 proxy（TEST VALUE）
const SURPLUS_DAYS: float = 7.0
# R2 flow-not-stock：積累 rung 讀持續淨食物流盈餘（食物/天），非 stale 滿倉 stock。
# 有真盈餘可積累才升 rung；覓食/爆倉 net~0 隊卡生存（苟活）。TEST VALUE，bed 校。
const ACCUMULATE_FLOW_MIN: float = 0.5   # TEST VALUE — 升積累 rung 所需日均淨食物盈餘
const EXPAND_MIN_POP: int = 8
const STATE_MIN_FACTION_TEAMS: int = 2
const HEGEMON_MIN_FACTION_TEAMS: int = 4
const RUNG_STALL_K: int = 3   # TEST VALUE — 連續失守 milestone 幾 cadence 才降 rung（遲滯）
const RUNG_CRASH_POP_DROP_PCT: float = 0.30   # TEST VALUE — S3 survival-bypass：pop 單期驟降門檻
const RUNG_CRASH_FOOD_DEEP: float = -2.0      # TEST VALUE — S3：food_flow 深負門檻（/day）

# R2 單一人格傾向公式（intent/archetype 共源）：_intent_scores 人格層原式搬家（數字不動）。
# viability 疊加（established/weak_enemy/can_levy）留在 FactionAISystem._intent_scores。TEST VALUE 權重。
static func disposition_scores(values: Dictionary) -> Dictionary:
	var ambition: float = float(values.get("野心", 0.5))
	var greed:    float = float(values.get("貪婪", 0.5))
	var honor:    float = float(values.get("義氣", 0.5))
	var martial:  float = float(values.get("好戰", 0.5))
	var caution:  float = float(values.get("慎重", 0.5))
	return {
		"守成": 0.25,  # default base
		"征服": ambition * 0.4 + martial * 0.4 - honor * 0.4,
		"致富": greed * 0.6 + ambition * 0.1,
		"防衛": caution * 0.4 + honor * 0.2,
	}

# R2：委派 argmax(disposition_scores) → archetype 映射（征服→武力、致富→商業、防衛|守成→定居）。
# 平手序 武力>商業>定居（等分先 FORCE）。與 intent scorer 共源 → desync 結構歸零。
static func derive_archetype(leader: PersonData) -> String:
	if leader == null:
		return ARCHETYPE_SETTLE
	var scores: Dictionary = disposition_scores(leader.values)
	var best: String = "征服"
	for key in ["征服", "致富", "防衛", "守成"]:   # 順序=平手序（前者贏）
		if scores[key] > scores[best]:
			best = key
	match best:
		"征服": return ARCHETYPE_FORCE
		"致富": return ARCHETYPE_TRADE
	return ARCHETYPE_SETTLE   # 防衛|守成

# 野心 → 封頂 rung（TEST VALUE）
static func derive_cap(leader: PersonData) -> int:
	if leader == null:
		return RUNG_ACCUMULATE
	var amb: float = float(leader.values.get("野心", 0.5))
	if amb < 0.3: return RUNG_ACCUMULATE
	if amb < 0.55: return RUNG_EXPAND
	if amb < 0.8: return RUNG_STATE
	return RUNG_HEGEMON

# 安全門檻達到的最高 rung（capped by ambition_cap）。proxy 指標 TEST VALUE。
static func target_rung(state: WorldState, team: TeamData, leader: PersonData) -> int:
	var rung: int = RUNG_SURVIVE
	var pop: int = team.population
	# R2 flow-not-stock：積累讀持續淨食物流盈餘（income−consumption 日均），非 stale 滿倉。
	# 定居隊爆倉但 net~0 → 不誤判積累；plains net>0 / 交易 net>0 → 升 rung。
	# 積累：糧盈餘（flow）
	if team.food_flow_avg >= ACCUMULATE_FLOW_MIN:
		rung = RUNG_ACCUMULATE
		# 擴張：盈餘 + 夠人
		if pop >= EXPAND_MIN_POP:
			rung = RUNG_EXPAND
			# 立國/稱霸：faction 規模
			if team.faction_id != -1 and state.factions.has(team.faction_id):
				var fteams: int = state.factions[team.faction_id].member_team_ids.size()
				if fteams >= STATE_MIN_FACTION_TEAMS:
					rung = RUNG_STATE
				if fteams >= HEGEMON_MIN_FACTION_TEAMS:
					rung = RUNG_HEGEMON
	return mini(rung, team.ambition_cap)

# milestone_met(N) = 「夠格在 rung N」的階梯條件（累進；複用 target_rung gate 語意）
static func milestone_met(state: WorldState, team: TeamData, rung_val: int) -> bool:
	var pop: int = team.population
	match rung_val:
		RUNG_SURVIVE:    return true   # 地板恆夠格
		RUNG_ACCUMULATE: return team.food_flow_avg >= ACCUMULATE_FLOW_MIN
		RUNG_EXPAND:     return team.food_flow_avg >= ACCUMULATE_FLOW_MIN and pop >= EXPAND_MIN_POP
		RUNG_STATE, RUNG_HEGEMON:
			if team.food_flow_avg < ACCUMULATE_FLOW_MIN or pop < EXPAND_MIN_POP: return false
			if team.faction_id == -1 or not state.factions.has(team.faction_id): return false
			var ft: int = state.factions[team.faction_id].member_team_ids.size()
			return ft >= (STATE_MIN_FACTION_TEAMS if rung_val == RUNG_STATE else HEGEMON_MIN_FACTION_TEAMS)
	return false

# 事件驅動 rung：升=milestone_met(next)、降=連續 K 次失守 milestone_met(current)（遲滯）。無 trend。
static func update(state: WorldState, team: TeamData) -> void:
	var leader: PersonData = state.persons.get(team.leader_id)
	team.ambition_archetype = derive_archetype(leader)
	team.ambition_cap = derive_cap(leader)
	# S3 survival-bypass：劇變幅度（pop 驟降/food 深負/leader 失）→ 無視 K 遲滯，
	# 立即重算 rung 為當前承載力（連續 milestone_met 爬到的最高 rung）。
	# ★層次分離：只改 ambition_rung（目標階層），不碰 _evaluate_survival（行動層插隊覓食）。
	var pop_now: int = team.population
	var pop_drop: bool = team.rung_pop_last > 0 \
		and float(team.rung_pop_last - pop_now) / float(team.rung_pop_last) > RUNG_CRASH_POP_DROP_PCT
	var food_crash: bool = team.food_flow_avg < RUNG_CRASH_FOOD_DEEP
	var leader_lost: bool = leader == null
	if pop_drop or food_crash or leader_lost:
		var carry: int = RUNG_SURVIVE
		var n: int = RUNG_ACCUMULATE
		while n <= team.ambition_cap and milestone_met(state, team, n):
			carry = n; n += 1
		if carry < team.ambition_rung:
			team.ambition_rung = carry
			team.rung_stall_count = 0
			Probe.bump("g2.ambition_crash_bypass")
		team.rung_pop_last = pop_now
		team.ambition_eval_next_tick = state.world.current_tick + LADDER_EVAL_CADENCE
		return   # 劇變當 cadence 只做 bypass，不再走正常升降
	team.rung_pop_last = pop_now
	var old: int = team.ambition_rung
	var next_rung: int = old + 1
	# 升：milestone_met(next) 達成（capped by ambition_cap）
	if next_rung <= team.ambition_cap and milestone_met(state, team, next_rung):
		var amb: float = float(leader.values.get("野心", 0.5)) if leader else 0.5
		var prud: float = float(leader.values.get("慎重", 0.5)) if leader else 0.5
		var reckless: bool = amb > 0.65 and prud < 0.4
		if reckless:   # reckless 直跳到最高連續達成的 rung
			var t: int = next_rung
			while t + 1 <= team.ambition_cap and milestone_met(state, team, t + 1):
				t += 1
			team.ambition_rung = t
		else:
			team.ambition_rung = next_rung
		team.rung_stall_count = 0
		Probe.bump("g2.ambition_promote")
	# 降：連續 K 次失守當前 rung milestone（遲滯，瞬時跌不降；含 plateau-below-threshold）
	elif old > RUNG_SURVIVE:
		if not milestone_met(state, team, old):
			team.rung_stall_count += 1
			if team.rung_stall_count >= RUNG_STALL_K:
				team.ambition_rung = old - 1
				team.rung_stall_count = 0
				Probe.bump("g2.ambition_demote")
		else:
			team.rung_stall_count = 0   # 仍夠格 → 撐住
	team.ambition_eval_next_tick = state.world.current_tick + LADDER_EVAL_CADENCE
	if team.ambition_rung != old:
		print("[Ambition] Team%d rung %d→%d (%s cap=%d)" % [
			team.team_id, old, team.ambition_rung, team.ambition_archetype, team.ambition_cap])

# 序3：rung_task (archetype,rung)→task 查表已溶入決策引擎（archetype/rung 當 weight context，
# 訓練 option + train_drive term 驅動；idle-filler 走 DecisionEngine.rank_scored_ctx）。融合驗見 rung_dissolution_check.gd。
