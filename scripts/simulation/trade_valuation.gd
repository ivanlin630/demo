class_name TradeValuation

# ──────── trade 估值唯一真值源 ────────
# 消 interaction_system / player_trade_system 兩份漂移副本：canonical 表 + 唯一 local_value。
# 表取自 interaction_system 現值（NPC market，含「# in」原料成本調過值）；player_trade 舊副本是 drift 出的 stale。
# 定價規則：成品價 ≥ 原料價值（Σ in × BASE_PRICE）× 1.2（工藝品 gem 路線豁免）
const BASE_PRICE: Dictionary = {
	"food":               2.0,
	"material":           4.0,
	"herb":               3.0,
	"goods":             15.0,   # in 12
	"gem":               20.0,
	"ore_gold":          10.0,
	"ore_silver":         5.0,
	"ore_iron":           8.0,
	"ore_steel":         24.0,   # in 20
	"weapon_melee_low":  34.0,   # in 28
	"weapon_melee_high": 72.0,   # in 60
	"weapon_ranged_low": 39.0,   # in 32
	"weapon_ranged_high": 77.0,  # in 64
	"tools":             20.0,   # in 16
	"arrows":             4.0,   # in 3.2
	"armor_low":         30.0,   # in 24
	"armor_high":        72.0,   # in 60
	"horses":            15.0,
	"mounts":            45.0,   # horses + 草料 + 軍設施 margin
	"wagons":            72.0,   # in 59
	"medicine":          12.0,   # in 6
}
const TARGET_PER_POP: Dictionary = {
	"food":              10.0,
	"material":           5.0,
	"goods":              3.0,
	"gem":                1.0,
	"ore_gold":           2.0,
	"ore_silver":         3.0,
	"ore_iron":           3.0,
	"ore_steel":          1.5,
	"weapon_melee_low":   1.0,
	"weapon_melee_high":  0.5,
	"weapon_ranged_low":  0.8,
	"weapon_ranged_high": 0.4,
	"tools":              0.5,
	"arrows":             2.0,
	"armor_low":          0.3,
	"armor_high":         0.15,
	"horses":             0.5,
	"medicine":           1.0,
	"herb":               1.0,
	"mounts":             0.2,
	"wagons":             0.2,
}
const SURVIVAL_GOODS: Array = ["food", "medicine"]   # 飢荒不對稱 clamp 適用；★活命糧 reserve 不液化(絕境不甩)
const FOOD_RESERVE_TICKS: float = 20.0   # TEST VALUE — food 最低自留（pop × 0.1 × N ticks）；單一源

# ── 市場液化（unified-commerce M3/M5，收 market-liquidize）：非活命品 reserve 降底+人格化 = 流動為底 ──
# ★只非活命品；SURVIVAL_GOODS(food/medicine) 走各自 survival-floor，不液化不甩活命糧。
const RESERVE_BASE: float = 0.6          # TEST VALUE — 非活命品 reserve 降底基準(<1.0→願賣方變多)
const RESERVE_HOARD_K: float = 0.5       # TEST VALUE — 貪婪/慎重守貨斜率(高→reserve 高守貨)
const RESERVE_URGENCY_K: float = 0.4     # TEST VALUE — 急迫/絕境鬆手斜率(高 urgency→reserve 低賣)
const RESERVE_FACTOR_MIN: float = 0.1    # TEST VALUE — 液化下限(絕境也留一點非活命品緩衝)
const RESERVE_FACTOR_MAX: float = 1.2    # TEST VALUE — 守貨上限(貪婪囤)
const URGENCY_COIN_COMFORT: float = 10.0 # TEST VALUE — 人均 coin 舒適線(低於→缺幣壓力升 urgency)
# ── ask/bid 液化：折扣人格化(急鬆手/貪守價)，willing 對閉合邊際價差 ──
const COMMERCE_DISCOUNT_K: float = 0.1   # TEST VALUE — 商業技能折扣斜率
const URGENCY_DISCOUNT_K: float = 0.3    # TEST VALUE — 急迫賣方折扣加深(鬆手賣)
const GREED_HOLD_K: float = 0.2          # TEST VALUE — 貪婪賣方守價(折扣收窄→部分談崩=摩擦質感)
const DISCOUNT_MAX: float = 0.5          # TEST VALUE — 折扣上限(不倒貼)
const SPREAD_TOL: float = 0.05           # TEST VALUE — willing 對成交容差(閉合邊際價差)

# 留底（不賣掉自己需要的）：food 按人格安全天數、coin 半留、非活命品液化人格化。單一源。
# 候選1 helper：從 state 取隊領袖人格值(供 reserve 人格化)。null/無領袖→{}→BASE 目標。
static func leader_vals(state: WorldState, team: TeamData) -> Dictionary:
	if state == null or team.leader_id == -1:
		return {}
	var l: PersonData = state.persons.get(team.leader_id)
	return l.values if l != null else {}

# ★storage-aware stock —— ★★null fallback【已刪除】(2026-08-26)：
#   簽名擋住的東西不該被實作放行。舊版的「state != null 才算糧倉、否則只算私產」是【靜默】給出錯的估值
#   （定居隊糧在糧倉、私產 0 ⇒ 誤判自己沒糧）——★崩會被看見，那個不會。
#   ★同一個病已經修過一輪（own_granary_null_caller_test 檔頭：「根修＝呼點補傳 state」），
#     而 default 讓它長回來 ⇒ ★★修實例會長回來，刪掉 default 才不會。
static func _stock(state: WorldState, team: TeamData, res: String) -> float:
	return ResourceSystem.effective_holding(state, team, res)

static func reserve(team: TeamData, res: String, leader_values: Dictionary, state: WorldState) -> float:
	# need-oracle S4b：reserve = 保留向 need_keep（R² 核心兩量落點）。coin 特例保留。
	if res == "coin":
		return float(team.resources.get("coin", 0)) * 0.5
	# food/medicine（SURVIVAL）：need_keep 已含 food 自用/medicine 終端自用＝survival floor，不液化（絕境不甩活命糧）。
	if res == "food" or res in SURVIVAL_GOODS:
		return NeedOracle.need_keep(state, team, res, leader_values)
	# ★material-hold-protection（脫貧第三腿）：material 有 active construction-need（想蓋 facility 缺料）
	# → 用 food-only factor（對 coin_urg 免疫）→ 守住要蓋的料不被 coin 焦慮逼賣（本 case 病治）；acute food 仍釋放(守護)。
	if res == "material" and state != null \
			and NeedOracle._construction_facility_need(state, team, "material", leader_values) > 0.0:
		return NeedOracle.need_keep(state, team, res, leader_values) * _reserve_factor_food_only(team, leader_values, state)
	# 非活命品：need_keep（自用+供應鏈）× 液化（貪婪守/絕境鬆手＝可賣餘量轉換層安全網）。
	# goods need_keep=0 → reserve=0 → 可賣餘量=holding（有 demand 才賣，死鎖解）。
	return NeedOracle.need_keep(state, team, res, leader_values) * _reserve_factor(team, leader_values, state)

# 非活命品 reserve 人格化液化係數：貪婪/慎重↑守貨(高)、急迫/絕境↓鬆手賣(低)。純算術零 randf。
static func _reserve_factor(team: TeamData, leader_values: Dictionary, state: WorldState) -> float:
	var hoard: float = (float(leader_values.get("貪婪", 0.5)) + float(leader_values.get("慎重", 0.5))) * 0.5
	var factor: float = RESERVE_BASE + (hoard - 0.5) * RESERVE_HOARD_K - _urgency(team, state) * RESERVE_URGENCY_K
	return clampf(factor, RESERVE_FACTOR_MIN, RESERVE_FACTOR_MAX)

# ★material-hold-protection：construction-material reserve 用「只食急迫」液化係數（對 coin_urg 免疫）。
# =_reserve_factor 但 urgency 只用 food_urg 非 max(food,coin)→coin 焦慮不逼賣要蓋的料；acute food 仍降 factor 可賣(守護)。
static func _reserve_factor_food_only(team: TeamData, leader_values: Dictionary, state: WorldState) -> float:
	var hoard: float = (float(leader_values.get("貪婪", 0.5)) + float(leader_values.get("慎重", 0.5))) * 0.5
	var factor: float = RESERVE_BASE + (hoard - 0.5) * RESERVE_HOARD_K - _food_urgency(team, state) * RESERVE_URGENCY_K
	return clampf(factor, RESERVE_FACTOR_MIN, RESERVE_FACTOR_MAX)

# 只食急迫 [0,1]：食物天數低→鬆手賣（decouple coin_urg，供 material-hold food-only factor + acute 守護）。純狀態零 randf。
static func _food_urgency(team: TeamData, state: WorldState) -> float:
	var pop: float = maxf(float(team.population), 1.0)
	var food_days: float = _stock(state, team, "food") / (pop * ResourceSystem.FOOD_PER_PERSON_PER_DAY)
	return clampf((DecisionTerms.DESPERATION_DAYS - food_days) / DecisionTerms.DESPERATION_DAYS, 0.0, 1.0)

# 隊急迫度 [0,1]：食物天數低 + 人均 coin 缺 → 鬆手賣非活命品換 coin/糧。純狀態，零 randf。
static func _urgency(team: TeamData, state: WorldState) -> float:
	var pop: float = maxf(float(team.population), 1.0)
	var coin_urg: float = clampf(1.0 - float(team.resources.get("coin", 0)) / (pop * URGENCY_COIN_COMFORT), 0.0, 1.0)
	return maxf(_food_urgency(team, state), coin_urg)

# ask 售價：折扣人格化——商業技能 + 急迫鬆手(折扣深)，貪婪守價(折扣收窄→部分談崩)。零 randf。
static func ask_price(seller: TeamData, res: String, commerce: float, leader_values: Dictionary, state: WorldState) -> float:
	var greed: float = float(leader_values.get("貪婪", 0.5))
	var discount: float = clampf(
		commerce * COMMERCE_DISCOUNT_K + _urgency(seller, state) * URGENCY_DISCOUNT_K - (greed - 0.5) * GREED_HOLD_K,
		0.0, DISCOUNT_MAX)
	return local_value(seller, res, state) * (1.0 - discount)

# 唯一 local_value：coin 恆 face value；survival 不對稱(饑荒最高 5×)；非 survival clamp[-0.5,1.0]。
# M4：state 給→stock 算 effective_holding(糧倉貨算進,不誤判短缺)；null→team.resources 私產。
static func local_value(team: TeamData, res: String, state: WorldState) -> float:
	if res == "coin":
		return 1.0   # currency: always face value, no supply/demand modulation
	if not BASE_PRICE.has(res):
		return 0.0
	var pop: float    = maxf(float(team.population), 1.0)
	var stock: float  = _stock(state, team, res)
	# ★★接線的【執行證據】tap（2026-08-26）：`fp` 不變只證等價、不證執行。
	#   ★這裡直接量【傳了 state 之後，看到的庫存有沒有真的不一樣】——
	#     `blind` ＝ 舊行為（只看 team.resources）、`stock` ＝ 新行為（含糧倉/公庫）。
	#   ⇒ `differs` 非零 ＝ 新路徑真的被走到且真的改變了估值；
	#     全 0 ＝ 要嘛沒走到、要嘛這些隊本來就沒有糧倉（兩者用 `calls_with_state` 分）。
	if Probe.enabled:
		Probe.bump("local_value.calls")
		if state != null:
			Probe.bump("local_value.calls_with_state")
			var blind: float = float(team.resources.get(res, 0))
			if not is_equal_approx(blind, stock):
				Probe.bump("local_value.state_changes_stock")
				Probe.bump("local_value.state_changes_stock." + res)
	var target: float = pop * float(TARGET_PER_POP.get(res, 1.0))
	var shortage: float = (target - stock) / maxf(target, 1.0)   # ≤ 1.0
	if res in SURVIVAL_GOODS and shortage > 0.5:
		shortage = 1.0 + (shortage - 0.5) * 6.0
	var _hi: float = 4.0 if res in SURVIVAL_GOODS else 1.0
	# ★★★第⑩票（2026-09-06，用戶裁「拆」）：穩定閥 `clampf(shortage, -0.5, _hi)` 【已拆除】。
	#   ★上臂是【結構性死碼】：`stock = effective_holding = team.resources + 自家糧倉`（兩項皆 >= 0）
	#     ⇒ `shortage = (target - stock)/maxf(target,1.0)` 恆 <= 1.0
	#     ⇒ 生存品放大後恰好 4.0、非生存品恰好 1.0 —— ★★【恰好等於上界，永不超過】
	#     ⇒ ★★★拆上臂【零行為改動】；而【若 fp 變了，代表上面這串推導錯了】—— 那才是要停下來的時刻。
	#   ★而下臂 -0.5 【是真的會夾】⇒ 拆它是【真正的行為改動】：深過剩的貨會一路跌到白送。
	#
	# ★★★★價格【定義域 floor 0】—— blueprint 裁：「價格不得為負」是【這個量的定義】不是閥。
	#   「爛大街 ⇒ 白送(0)」；而【「倒貼你拿走」的物流世界不在本作 scope】。
	#   ★★而它【直接寫 0.0，不具名成常數】—— 具名會讓下一個人以為它可調，
	#     ★★★而它是【定義域】不是【旋鈕】。
	if Probe.enabled:
		# ★★原本三桶量的是「有沒有被夾」，而【閥拆掉之後那個問題不存在了】
		#   ⇒ ★改量【raw shortage 落在哪一帶】，★★key 一併改名（`band_` 不再叫 `clamp_`）——
		#     留著舊名會產生【孤兒讀者】：讀的人以為還有閥在夾（今天已經踩過一次同型）。
		#   ★★★第四桶（`shortage < -1` ＝ `stock > 2×target` ＝【深度過剩】）是 blueprint 點名那格：
		#     拆後那些貨的價格【直接是 0】⇒ 若 food 落在這桶比例高 ⇒ 農隊賣糧收入歸零
		#     —— ★那是 regime change 不是價格波動。
		if shortage < -1.0:
			Probe.bump("valuation.band_deep_glut")
		elif shortage < -0.5:
			Probe.bump("valuation.band_glut")
		elif shortage > _hi:
			Probe.bump("valuation.band_over_hi")   # ★恆 0 ＝ 上臂死碼的反向斷言
		else:
			Probe.bump("valuation.band_normal")
	var price: float = float(BASE_PRICE[res]) * maxf(1.0 + shortage, 0.0)
	if Probe.enabled:
		Probe.bump("valuation.priced")
		if price <= 0.0:
			Probe.bump("valuation.price_zero")
			Probe.bump("valuation.price_zero." + res)
		Probe.add_amount("valuation.price_sum", price)
	return price
