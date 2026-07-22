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
	return _self_use(team, res, leader_values) + _supply_chain(state, team, res) \
		+ _construction_facility_need(state, team, res, leader_values)

# ★means-end material need（Gate B trade-primary 核心）：team 想建的 facility → 其 build-cost material need
# （前瞻買料建設，破 chicken-egg:material need gated on 已有 facility→builder 不帶 need→買不到→建不了）。
# 讀既有 _facility_deficit 慾望信號（blueprint 認可耦合;憲法=utility 餵 utility 非 scripted）。
# ★★循環守衛（結構性，reviewer R²）：`if cost_mat<=0: continue` 必在 `_facility_deficit` 呼叫之前
#   （只對 build-cost 含 material 的 facility 讀 deficit）。★結構不變量：build-cost res(material/tools) ∩
#   facility-output res(goods/weapon/ore_steel/armor/medicine/mounts)=∅（grep 驗無 facility output material）→
#   讀 deficit 的 facility 其 deficit 計算(_generic_res_deficit(outputs)/need_keep(outputs≠material))永不回呼
#   need_keep(material)→結構無遞迴（非靠 depth-1）。★禁擴到「同時是 build-cost 且 facility-output」的 res
#   （需 visited-set guard）；本刀只 material（純 build-cost 非任何 output）=結構安全。
const CONSTRUCTION_DESIRE_MIN: float = 0.3    # TEST VALUE — facility desire≥此才前瞻買料（夠想才囤料）
const CONSTRUCTION_MATERIAL_NEED_CAP: float = 100.0   # TEST VALUE — 防多 material-facility 疊爆 over-buy（≈單一最貴 material-facility cost）
static func _construction_facility_need(state: WorldState, team: TeamData, res: String, lv: Dictionary) -> float:
	if res != "material" or state == null:
		return 0.0   # scope:material only（tools/ore 另軌供給 gap；★禁擴 build-cost∩output≠∅ 的 res）
	var own_pos: Vector2i = FactionAISystem.new()._find_own_outpost(state, team)
	if own_pos == Vector2i(-1, -1):
		return 0.0
	var tile: HexTileData = state.world.tiles.get(own_pos.x * 1000 + own_pos.y)
	if tile == null or tile.outpost_level == 0:
		return 0.0
	var total: float = 0.0
	for facility in OutpostSystem.FACILITY_DEF:
		var def: Dictionary = OutpostSystem.FACILITY_DEF[facility]
		if not (tile.outpost_type in def.get("allowed_outpost", [])):
			continue   # 該格能建
		var cur: int = int(tile.get(def["current_level_key"]))
		if cur >= 3:
			continue
		var cost_mat: float = float(OutpostSystem.upgrade_cost(facility, cur + 1).get("material", 0))
		if cost_mat <= 0.0:
			continue   # ★★循環守衛:cost-guard 在 _facility_deficit 呼叫之前（只讀 build-cost 含 material 的 facility）
		var desire: float = FactionAISystem.new()._facility_deficit(state, team, facility, tile)   # 0-1 既有信號
		if desire < CONSTRUCTION_DESIRE_MIN:
			continue   # 夠想才前瞻買料（desire 當 gate）
		total += cost_mat   # ★v2a：過閘=夠想建→全 build-cost（非 ×desire 稀釋；稀釋 24<80=白買 QA 半破根）
	return minf(total, CONSTRUCTION_MATERIAL_NEED_CAP)   # ★cap 防疊爆 over-buy

# ★v2a：team 對 material-facility 的 max 建設迫切（0-1，reuse _facility_deficit 信號）。
# 買料 util 繫此=買料是建設前置（想建強→買料 util 高，競得過建設），非 shortfall band 墊底（1.7% 敗）。
# mirror _construction_facility_need 列舉（cost-guard 前置同結構安全），聚合改 max desire 非 sum cost。
static func max_material_facility_desire(state: WorldState, team: TeamData) -> float:
	if state == null:
		return 0.0
	var own_pos: Vector2i = FactionAISystem.new()._find_own_outpost(state, team)
	if own_pos == Vector2i(-1, -1):
		return 0.0
	var tile: HexTileData = state.world.tiles.get(own_pos.x * 1000 + own_pos.y)
	if tile == null or tile.outpost_level == 0:
		return 0.0
	var best: float = 0.0
	for facility in OutpostSystem.FACILITY_DEF:
		var def: Dictionary = OutpostSystem.FACILITY_DEF[facility]
		if not (tile.outpost_type in def.get("allowed_outpost", [])):
			continue
		var cur: int = int(tile.get(def["current_level_key"]))
		if cur >= 3:
			continue
		if float(OutpostSystem.upgrade_cost(facility, cur + 1).get("material", 0)) <= 0.0:
			continue   # 只認 build-cost 含 material 的 facility（買料才有意義）
		best = maxf(best, FactionAISystem.new()._facility_deficit(state, team, facility, tile))
	return best

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

# ── 貿易 demand（★S3）：市場「有效」買單（非幽靈：過期單不供產，僅履約排序用）+ 致富野心。綁 deal 側。──
# 讀 team_known 親聞 order_buy（感知鐵律：聽過才算，非 god-view）。過期單濾除＝非幽靈視圖（R²#1-issue）。
static func _trade_demand(state: WorldState, team: TeamData, res: String, leader_values: Dictionary) -> float:
	if state == null:
		return 0.0
	var tick: int = state.world.current_tick
	var total: float = 0.0
	for m in state.team_known.get(team.team_id, []):
		if m.type != "order_buy":
			continue
		if String(m.params.get("res", "")) != res:
			continue
		if int(m.params.get("origin_team", -1)) == team.team_id:
			continue   # 自己的買單不算 demand
		# ★非幽靈：過期買單不供產（production demand 濾過期；過期單僅供履約排序，不在此）
		if int(m.params.get("expire_tick", 0)) <= tick:
			continue
		total += float(m.params.get("qty", 0))
	if total <= 0.0:
		return 0.0
	# 致富野心秤：野心高→更積極追貿易（綁 deal 側，TEST VALUE）。
	var ambition: float = float(leader_values.get("野心", 0.5))
	return total * (0.5 + ambition)
