class_name NeedOracle

# ──────── Arc1 統一 need oracle（★獨立新 module，出兩量）────────
# spec: docs/superpowers/specs/2026-07-16-arc1-unified-need-oracle.md
# ★與 NeedHierarchy 不同概念：NeedHierarchy=心理五層 Maslow 急迫度；NeedOracle=資源數量 need 側統一源。
# 對任 (team, res) 出兩量（核心修 R²#1 方向缺陷）：
#   need_keep(team,res) = 自用 + 供應鏈     # 保留向：要留住多少（可賣餘量 = holding − need_keep）
#   demand(team,res)    = 貿易               # 流出向：外部想拿走多少（實際賣 = min(餘量, demand)）
# ★S1：只 food 自用真推導（消耗率×pop×人格 buffer 天）；供應鏈(S2)/貿易(S3) 未實作分量 fallback 舊常數
# （TARGET_PER_POP，防中間態 target=0 全隊倒貨/價格鎖死，R²#5）。reader 全切 oracle = S4。

# 保留向 need：自用(消耗品) + 供應鏈(中間品下游 gap 傳導)。
static func need_keep(state: WorldState, team: TeamData, res: String, leader_values: Dictionary = {}) -> float:
	return _self_use(team, res, leader_values) + _supply_chain(state, team, res)

# 流出向 need：貿易 demand（市場有效買單 + 野心 + 可載，綁 deal 側）。goods 只有此量（need_keep=0）。
static func demand(state: WorldState, team: TeamData, res: String, leader_values: Dictionary = {}) -> float:
	return _trade_demand(state, team, res, leader_values)

# ── 自用推導（消耗率=世界物理 flat；buffer 天數人格化。取代 TARGET_PER_POP 自用身分）──
# ★S1：food 真推導。非 food 自用（武器戰耗/tools 造耗/藥傷耗）= S2+ 實作，S1 回 0（走供應鏈 fallback）。
static func _self_use(team: TeamData, res: String, leader_values: Dictionary) -> float:
	if res == "food":
		# food 自用 = 日耗(flat) × pop × 人格安全存量天(food_security_target)。不賣到自己餓。
		return ResourceSystem.FOOD_PER_PERSON_PER_DAY * float(team.population) \
			* DecisionTerms.food_security_target(leader_values)
	return 0.0

# ── 供應鏈傳導（中間品下游 gap）——★S2 實作；S1 fallback 舊 TARGET_PER_POP（非 food 自用/供應鏈合體舊值）──
static func _supply_chain(_state: WorldState, team: TeamData, res: String) -> float:
	if res == "food":
		return 0.0   # food 無供應鏈（終端消耗），自用已涵蓋
	# S1 fallback：非 food 走舊 TARGET_PER_POP（S2 換 gap 傳導、S4 正式退役常數）。
	return float(team.population) * float(TradeValuation.TARGET_PER_POP.get(res, 0.0))

# ── 貿易 demand（市場有效買單+野心+可載）——★S3 實作；S1 fallback 0（reader 尚未切，賣邏輯仍走舊路）──
static func _trade_demand(_state: WorldState, _team: TeamData, _res: String, _leader_values: Dictionary) -> float:
	return 0.0
