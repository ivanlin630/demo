class_name UnrestBank

# Pattern B 所有權 banker：unrest_turns 單一 owner。所有 unrest 寫經此(禁裸 team.unrest_turns =)。
# reason 供審計(誰改民怨);reset 為唯一蓄意歸零路徑(split-resolution 類)。
static func add(team: TeamData, n: int, reason: String = "") -> void:
	team.unrest_turns = maxi(team.unrest_turns + n, 0)

static func reduce(team: TeamData, n: int, reason: String = "") -> void:
	team.unrest_turns = maxi(team.unrest_turns - n, 0)

static func reset(team: TeamData, reason: String = "") -> void:
	team.unrest_turns = 0
	Probe.bump("g1.unrest_reset")
