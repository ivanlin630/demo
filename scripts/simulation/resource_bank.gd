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

# ★★★coin 流量 tap（第⑨票驗收④：月週轉 ＝ 成交額 ÷ 存量）——
#   ★為什麼放在 `ResourceBank` 而不是某個「結算函式」：★★我【不知道】哪一支是「那個」結算點，
#     而去猜一支就是【拿一個沒查過的前提當量測基礎】（今天已經被這種事咬過好幾次）。
#   ⇒ ★★★放在【唯一寫入口】上：每一筆 coin 變動都逐 reason 記，
#     而【哪些 reason 算成交】是【讀的人的判斷】—— 儀器不替判讀做選擇。
#   ★熱路徑 ⇒ 全部在 `Probe.enabled` 之內（關掉時零成本）。
static func _tap_coin(res: String, delta: float, reason: String) -> void:
	if not Probe.enabled:
		return
	# ★★★對照格：★所有 res 的寫入次數 —— 它讓「coin 沒動」與「儀器沒開」分得開。
	#   ★沒有它，`coin.flow.n == 0` 有兩種意思，而【兩種印出來一模一樣】。
	Probe.bump("bank.writes.n")
	if res != "coin" or delta == 0.0:
		return
	Probe.add_amount("coin.flow.abs", absf(delta))
	Probe.add_amount("coin.flow.by." + reason, absf(delta))
	Probe.bump("coin.flow.n")

static func add(team: TeamData, res: String, amt: float, reason: String) -> void:
	team.resources[res] = float(team.resources.get(res, 0.0)) + amt
	_tally_food(team, res, amt)
	_tap_coin(res, amt, reason)
	WorldState.record_driver(team, res, amt, reason, "resource")

static func remove(team: TeamData, res: String, amt: float, reason: String) -> float:
	var have: float = float(team.resources.get(res, 0.0))
	var m: float = clampf(amt, 0.0, have)
	team.resources[res] = have - m
	_tally_food(team, res, -m)
	_tap_coin(res, -m, reason)
	WorldState.record_driver(team, res, -m, reason, "resource")
	return m

static func set_amt(team: TeamData, res: String, amt: float, reason: String) -> void:
	# ★set 是【蓋值】⇒ 流量＝新值 − 舊值（★不能當成「流入 amt」，那會把吃飯記成收成）
	var prev: float = float(team.resources.get(res, 0.0))
	team.resources[res] = amt
	_tally_food(team, res, amt - prev)
	WorldState.record_driver(team, res, amt, reason, "resource")

static func clear_all(team: TeamData, reason: String) -> void:
	# ★清空也是【流出】：不記＝這批食物憑空消失在流量帳上
	_tally_food(team, "food", -float(team.resources.get("food", 0.0)))
	team.resources.clear()
	WorldState.record_driver(team, "*resources*", 0.0, reason, "bulk")

# person.coin 單一寫者（Pattern B 所有權：私產 coin 唯一入口，保 CoinAudit 全池覆蓋）。
# 私產流動一律轉移（team/treasury↔person）→ delta 對稱、守恆 by construction。
static func adjust_person_coin(person: PersonData, delta: float, reason: String) -> void:
	person.coin = maxf(person.coin + delta, 0.0)
	WorldState.record_driver(person, "coin", delta, reason, "resource")
