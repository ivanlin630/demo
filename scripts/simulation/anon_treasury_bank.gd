class_name AnonTreasuryBank

# Pattern B 所有權 banker：anon_treasury(隊公庫 coin)單一 owner。
# transfer/transfer_all 原子 → 守恆 by construction(優於分離 += / =0)。
# reason → WorldState.record_driver（driver-ledger；預設 off 零成本）。
static func deposit(team: TeamData, amt: float, reason: String = "") -> void:
	var m: float = maxf(amt, 0.0)
	team.anon_treasury += m
	WorldState.record_driver(team, "anon_treasury", m, reason)

static func withdraw(team: TeamData, amt: float, reason: String = "") -> float:
	var m: float = clampf(amt, 0.0, team.anon_treasury)
	team.anon_treasury -= m
	WorldState.record_driver(team, "anon_treasury", -m, reason)
	return m

static func transfer(src: TeamData, dst: TeamData, amt: float, reason: String = "") -> void:
	var m: float = clampf(amt, 0.0, src.anon_treasury)
	src.anon_treasury -= m
	dst.anon_treasury += m
	WorldState.record_driver(src, "anon_treasury", -m, reason)
	WorldState.record_driver(dst, "anon_treasury", m, reason)

static func transfer_all(src: TeamData, dst: TeamData, reason: String = "") -> void:
	var m: float = src.anon_treasury
	dst.anon_treasury += m
	src.anon_treasury = 0.0
	WorldState.record_driver(src, "anon_treasury", -m, reason)
	WorldState.record_driver(dst, "anon_treasury", m, reason)

static func reset(team: TeamData, reason: String = "") -> void:
	WorldState.record_driver(team, "anon_treasury", -team.anon_treasury, reason)
	team.anon_treasury = 0.0
	Probe.bump("g1.treasury_reset")
