class_name AnonTreasuryBank

# Pattern B 所有權 banker：anon_treasury(隊公庫 coin)單一 owner。
# transfer/transfer_all 原子 → 守恆 by construction(優於分離 += / =0)。
static func deposit(team: TeamData, amt: float, reason: String = "") -> void:
	team.anon_treasury += maxf(amt, 0.0)

static func withdraw(team: TeamData, amt: float, reason: String = "") -> float:
	var m: float = clampf(amt, 0.0, team.anon_treasury)
	team.anon_treasury -= m
	return m

static func transfer(src: TeamData, dst: TeamData, amt: float, reason: String = "") -> void:
	var m: float = clampf(amt, 0.0, src.anon_treasury)
	src.anon_treasury -= m
	dst.anon_treasury += m

static func transfer_all(src: TeamData, dst: TeamData, reason: String = "") -> void:
	dst.anon_treasury += src.anon_treasury
	src.anon_treasury = 0.0

static func reset(team: TeamData, reason: String = "") -> void:
	team.anon_treasury = 0.0
	Probe.bump("g1.treasury_reset")
