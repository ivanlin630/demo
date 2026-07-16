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

# 純中間品（只當配方 input，非終端消耗）→ 自用=0，need 全走供應鏈傳導。
const PURE_INTERMEDIATE: Array = ["material", "ore_iron", "ore_steel", "gem", "herb"]

# ── 自用推導（消耗率=世界物理 flat；buffer 天數人格化。取代 TARGET_PER_POP 自用身分）──
# food 真推導；純中間品=0（走供應鏈）；終端消耗品（武器/tools/藥/armor/arrows）=buffer base
# （★S4 換真消耗率×人格 buffer；S2 暫用 TARGET_PER_POP base，reader 未切故無產線影響）。goods=純貿易 need_keep=0。
static func _self_use(team: TeamData, res: String, leader_values: Dictionary) -> float:
	if res == "food":
		return ResourceSystem.FOOD_PER_PERSON_PER_DAY * float(team.population) \
			* DecisionTerms.food_security_target(leader_values)
	if res == "goods":
		return 0.0   # goods 純貿易品，無自用消費 sink（#6）
	if res in PURE_INTERMEDIATE:
		return 0.0   # 純中間品 need 全走供應鏈
	# 終端消耗品 buffer base（S4 換真戰耗/造耗/傷耗率×人格 buffer 天）
	return float(team.population) * float(TradeValuation.TARGET_PER_POP.get(res, 0.0))

# ── 供應鏈傳導（★S2）：下游 gap 傳導——傳導量 = Σ 下游 max(need_keep−holding,0) × 配方係數。
# gap 非 raw（防已持成品仍囤原料）+ 設施 gating（無該設施不背）+ 同 out 多配方取 max 係數（不重複加總）。
# walk 有限層無循環（RECIPE out→in DAG，#4 已驗）。holding 用 team.resources 私產（oracle 內部 gap，非 reader）。
static func _supply_chain(state: WorldState, team: TeamData, res: String) -> float:
	if res == "food" or state == null:
		return 0.0   # food 終端無供應鏈；無 state 無法 gating/gap
	# 同 out 多配方：per 下游-out 取「該隊設施可造」的 max 係數（不重複加總 out gap）
	var out_maxcoef: Dictionary = {}
	for level_key in ManufacturingSystem.RECIPE_GROUPS:
		if not _team_has_facility(state, team, level_key):
			continue   # ★設施 gating：無此製造設施的隊不背此供應鏈 need
		for recipe in ManufacturingSystem.RECIPE_GROUPS[level_key]:
			var inputs: Dictionary = recipe["in"]
			if not inputs.has(res):
				continue
			var out: String = String(recipe["out"])
			var coef: float = float(inputs[res])
			out_maxcoef[out] = maxf(float(out_maxcoef.get(out, 0.0)), coef)   # 多配方取 max 不重複
	if out_maxcoef.is_empty():
		return 0.0
	var lv: Dictionary = TradeValuation.leader_vals(state, team)
	var total: float = 0.0
	for out in out_maxcoef:
		var gap: float = maxf(need_keep(state, team, out, lv) - float(team.resources.get(out, 0)), 0.0)   # ★gap 非 raw
		total += gap * float(out_maxcoef[out])
	return total

# 設施 gating：隊「自家」outpost 有此製造設施（非 positional——掃 team 擁有的 outpost，讀自家 need 側）。
static func _team_has_facility(state: WorldState, team: TeamData, level_key: String) -> bool:
	for tid in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tid]
		if tile.outpost_owner == team.team_id and tile.outpost_level > 0 and int(tile.get(level_key)) > 0:
			return true
	return false

# ── 貿易 demand（市場有效買單+野心+可載）——★S3 實作；S1 fallback 0（reader 尚未切，賣邏輯仍走舊路）──
static func _trade_demand(_state: WorldState, _team: TeamData, _res: String, _leader_values: Dictionary) -> float:
	return 0.0
