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
const EXPAND_MIN_POP: int = 8
const STATE_MIN_FACTION_TEAMS: int = 2
const HEGEMON_MIN_FACTION_TEAMS: int = 4

# leader values 最高軸 → archetype（平手序 武力>商業>定居）。TEST VALUE 權重。
static func derive_archetype(leader: PersonData) -> String:
	if leader == null:
		return ARCHETYPE_SETTLE
	var v: Dictionary = leader.values
	var force: float = float(v.get("野心", 0.5)) * 0.5 + float(v.get("好戰", 0.5)) * 0.5
	var trade: float = float(v.get("貪婪", 0.5))
	var settle: float = float(v.get("義氣", 0.5)) * 0.5 + float(v.get("慎重", 0.5)) * 0.5
	if force >= trade and force >= settle:
		return ARCHETYPE_FORCE
	if trade >= settle:
		return ARCHETYPE_TRADE
	return ARCHETYPE_SETTLE

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
	var food: float = float(team.resources.get("food", 0))
	var surplus_need: float = float(pop) * 2.4 * SURPLUS_DAYS   # 2.4 = 日餐量量級(對齊既有)
	# 積累：糧盈餘
	if food >= surplus_need:
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

static func update(state: WorldState, team: TeamData) -> void:
	var leader: PersonData = state.persons.get(team.leader_id)
	team.ambition_archetype = derive_archetype(leader)
	team.ambition_cap = derive_cap(leader)
	var target: int = target_rung(state, team, leader)
	var old: int = team.ambition_rung
	if target < old:
		team.ambition_rung = old - 1        # 安全崩：一步退（可連續退到生存）
		Probe.bump("g2.ambition_demote")
	elif target > old:
		var amb: float = float(leader.values.get("野心", 0.5)) if leader else 0.5
		var prud: float = float(leader.values.get("慎重", 0.5)) if leader else 0.5
		var reckless: bool = amb > 0.65 and prud < 0.4
		team.ambition_rung = target if reckless else old + 1   # 躁進直跳 / 否則一步
		Probe.bump("g2.ambition_promote")
	team.ambition_eval_next_tick = state.world.current_tick + LADDER_EVAL_CADENCE
	if team.ambition_rung != old:
		print("[Ambition] Team%d rung %d→%d (%s cap=%d)" % [
			team.team_id, old, team.ambition_rung, team.ambition_archetype, team.ambition_cap])

# (archetype, rung) → ambient 常態 task。""=不指派(交 survival/prosperity/faction strategic)。TEST VALUE。
static func rung_task(_state: WorldState, team: TeamData) -> String:
	match team.ambition_rung:
		RUNG_ACCUMULATE:
			match team.ambition_archetype:
				ARCHETYPE_FORCE:  return TeamData.TASK_TRAIN
				ARCHETYPE_TRADE:  return TeamData.TASK_TRADE
				ARCHETYPE_SETTLE: return TeamData.TASK_PRODUCE
		RUNG_EXPAND:
			match team.ambition_archetype:
				ARCHETYPE_FORCE:  return ""                    # 交 _evaluate_prosperity_attack
				ARCHETYPE_TRADE:  return TeamData.TASK_TRADE    # G1 未上線→近程 TRADE
				ARCHETYPE_SETTLE: return TeamData.TASK_BUILD
	return ""   # 生存/立國/稱霸 → 交 survival / faction strategic
