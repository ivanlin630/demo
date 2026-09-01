class_name ResourceBank

# Pattern B 所有權 banker：team.resources 單一 owner(簡 wrapper 保原數學=守恆 by construction)。
# reason → WorldState.record_driver（driver-ledger；預設 off 零成本）。
# ★★★真盈餘計量（2026-09-01）：食物的【流入/流出】在這個【單寫者窄口】分流累計。
#   ★為什麼掛在這裡而不是逐個呼叫點：team.resources 的單一 owner 就是本檔
#   ⇒ ★★掛窄口＝不需要枚舉「有哪些地方會加糧」（枚舉＝黑名單＝今天已經失敗過三次的形狀）。
#   ★★★而它只【記帳】不改任何數值 ⇒ 對世界是純加法。
static func _tally_food(team: TeamData, res: String, delta: float) -> void:
	if res != "food" or team == null or delta == 0.0:
		return
	if delta > 0.0: team.food_in_today += delta
	else:           team.food_out_today += -delta

static func add(team: TeamData, res: String, amt: float, reason: String) -> void:
	team.resources[res] = float(team.resources.get(res, 0.0)) + amt
	_tally_food(team, res, amt)
	WorldState.record_driver(team, res, amt, reason, "resource")

static func remove(team: TeamData, res: String, amt: float, reason: String) -> float:
	var have: float = float(team.resources.get(res, 0.0))
	var m: float = clampf(amt, 0.0, have)
	team.resources[res] = have - m
	_tally_food(team, res, -m)
	WorldState.record_driver(team, res, -m, reason, "resource")
	return m

static func set_amt(team: TeamData, res: String, amt: float, reason: String) -> void:
	# ★set 是【蓋值】⇒ 流量＝新值 − 舊值（★不能當成「流入 amt」，那會把吃飯記成收成）
	var prev: float = float(team.resources.get(res, 0.0))
	team.resources[res] = amt
	_tally_food(team, res, amt - prev)
	WorldState.record_driver(team, res, amt, reason, "resource")

static func clear_all(team: TeamData, reason: String) -> void:
	team.resources.clear()
	WorldState.record_driver(team, "*resources*", 0.0, reason, "bulk")

# person.coin 單一寫者（Pattern B 所有權：私產 coin 唯一入口，保 CoinAudit 全池覆蓋）。
# 私產流動一律轉移（team/treasury↔person）→ delta 對稱、守恆 by construction。
static func adjust_person_coin(person: PersonData, delta: float, reason: String) -> void:
	person.coin = maxf(person.coin + delta, 0.0)
	WorldState.record_driver(person, "coin", delta, reason, "resource")
