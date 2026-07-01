class_name UnrestBank

# Pattern B 所有權 banker：unrest_turns 單一 owner。所有 unrest 寫經此(禁裸 team.unrest_turns =)。
# reason → WorldState.record_driver（driver-ledger；預設 off 零成本）。reset 為唯一蓄意歸零路徑。
static func add(team: TeamData, n: int, reason: String = "") -> void:
	team.unrest_turns = maxi(team.unrest_turns + n, 0)
	WorldState.record_driver(team, "unrest_turns", float(n), reason)

static func reduce(team: TeamData, n: int, reason: String = "") -> void:
	team.unrest_turns = maxi(team.unrest_turns - n, 0)
	WorldState.record_driver(team, "unrest_turns", float(-n), reason)

static func reset(team: TeamData, reason: String = "") -> void:
	WorldState.record_driver(team, "unrest_turns", float(-team.unrest_turns), reason)
	team.unrest_turns = 0
	Probe.bump("g1.unrest_reset")
