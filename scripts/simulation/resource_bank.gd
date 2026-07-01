class_name ResourceBank

# Pattern B 所有權 banker：team.resources 單一 owner(簡 wrapper 保原數學=守恆 by construction)。
# reason → WorldState.record_driver（driver-ledger；預設 off 零成本）。
static func add(team: TeamData, res: String, amt: float, reason: String = "") -> void:
	team.resources[res] = float(team.resources.get(res, 0.0)) + amt
	WorldState.record_driver(team, res, amt, reason)

static func remove(team: TeamData, res: String, amt: float, reason: String = "") -> float:
	var have: float = float(team.resources.get(res, 0.0))
	var m: float = clampf(amt, 0.0, have)
	team.resources[res] = have - m
	WorldState.record_driver(team, res, -m, reason)
	return m

static func set_amt(team: TeamData, res: String, amt: float, reason: String = "") -> void:
	team.resources[res] = amt
	WorldState.record_driver(team, res, amt, reason)

static func clear_all(team: TeamData, reason: String = "") -> void:
	team.resources.clear()
	WorldState.record_driver(team, "*resources*", 0.0, reason)

# person.coin 單一寫者（Pattern B 所有權：私產 coin 唯一入口，保 CoinAudit 全池覆蓋）。
# 私產流動一律轉移（team/treasury↔person）→ delta 對稱、守恆 by construction。
static func adjust_person_coin(person: PersonData, delta: float, reason: String = "") -> void:
	person.coin = maxf(person.coin + delta, 0.0)
	WorldState.record_driver(person, "coin", delta, reason)
