class_name LaborSystem

# ★統一勞力池（HOW spec 2026-08-03）：共址 PRODUCE pop=有限稀缺勞力，需求加權分配給採集/製造工位。
# 採集+製造共讀同一 allocator（統一非平行）。size 在生產 genuinely matter（大隊/集團餵得動多工位→真產多）。
# ★守憲：deterministic(sorted key + 純算術 + 溢出 cascade 固定迭代)零 RNG；承載(current/COLLECT_RATE/regen)不碰、
#   只換 pop_mult→labor_mult 那一支；決策/util/argmax 不碰。genuine-value 非 crank([[feedback_genuine_value_not_crank]])。

const K_MFG: float = 3.0                 # TEST VALUE — 每設施 level 要 3 手（L2 workshop demand=6）
const K_GATHER: float = 5.0              # TEST VALUE — 每採集線 5 手飽和
const K_FARM: float = 5.0                # TEST VALUE — 每 farming_level 5 手飽和（★農業a 農田工位、與 gather/mfg 競爭同池）
const LABOR_SCALE: float = 1.0           # TEST VALUE — 校準:pop5 單隊單工位 fill=1→labor_mult=1.0=現 pop_mult@pop5
const LABOR_CADENCE: int = TimeScale.TICK_PER_DAY * 3   # 常駐慢 cadence（非每 tick 抖）
const LABOR_CRISIS_FOOD_DAYS: float = 2.0              # 共址任一隊 food_days<此→即時重算(危機搶勞力)
const OVERFLOW_ITERS: int = 8           # demand-cap 溢出串聯迭代上限（deterministic 防無限）
const GATHER_SKIP: Array = ["wild_horses", "wild_game"]   # 活物不走 generic gather（同 _collect_from_tile）

# lazy-on-cadence：僅 current_tick>=labor_eval_next_tick 才真重算；否則直讀既存 alloc（生產每 tick 只讀 share、零雙算）。
static func ensure_fresh(state: WorldState, tile: HexTileData) -> void:
	# ★T0-A1 ③：共址任一 PRODUCE 隊糧餘命跌破危機線＝勞力危機 → 共址各隊當 tick 可重新思考
	# （原本只有「重算勞力分配」，隊自己不會因此提前重評）。純讀既有 food_runway，零 RNG。
	for _tid in state.teams:
		var _t: TeamData = state.teams[_tid]
		if _t.tile_pos != tile.tile_pos or not TeamData.TAG_PRODUCE in _t.tags:
			continue
		if _t.food_runway > 0.0 and _t.food_runway < LABOR_CRISIS_FOOD_DAYS:
			WorldEvents.emit(state, "labor_crisis", [_tid])
	if state.world.current_tick < tile.labor_eval_next_tick and not tile.labor_alloc.is_empty():
		return
	rebalance(state, tile)

# ★军民混编 Slice B：可務農勞力 = pop×(1−動員比)（動員的人當兵不下田=guns-vs-butter）。
static func labor_pop(team: TeamData) -> float:
	return float(team.population) * (1.0 - clampf(team.mobilized_fraction, 0.0, 1.0))

# 共址 PRODUCE 勞力池（軍隊無 TAG_PRODUCE 不算）；動員後只算未動員勞力。≥1 防除零。
static func pool_of(state: WorldState, tile: HexTileData) -> float:
	var p: float = 0.0
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.tile_pos == tile.tile_pos and TeamData.TAG_PRODUCE in t.tags:
			p += labor_pop(t)
	return maxf(p, 1.0)

# rebalance（deterministic）：pool → 列 workstations → need 權重 → 比例+demand-cap+溢出串聯 → fill。
static func rebalance(state: WorldState, tile: HexTileData) -> void:
	var teams: Array = []
	var pool: float = 0.0
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.tile_pos == tile.tile_pos and TeamData.TAG_PRODUCE in t.tags:
			teams.append(t); pool += labor_pop(t)   # ★動員後只算未動員勞力（guns-vs-butter）
	# 列 workstations（sorted key，deterministic）：active 採集資源 + active 製造設施。
	var demand: Dictionary = {}
	for res in tile.resources.keys():
		if res in GATHER_SKIP or float(tile.resources.get(res, 0)) <= 0.0:
			continue
		demand["gather:" + String(res)] = K_GATHER
	for level_key in ManufacturingSystem.RECIPE_GROUPS:
		var lvl: int = int(tile.get(level_key))
		if lvl > 0:
			demand["mfg:" + String(level_key)] = float(lvl) * K_MFG
	# ★農業a：農田工位=勞力池新 demand 源（farming_level>0 才列、與 gather/mfg 競爭=guns-vs-butter 自動）。
	if tile.farming_level > 0:
		demand["farm"] = float(tile.farming_level) * K_FARM
	var keys: Array = demand.keys(); keys.sort()
	# need 權重（need_oracle，per-workstation output res，Σ 共址隊；survival 天然拉高食，無 scripted floor）。
	var wgt: Dictionary = {}
	var total_w: float = 0.0
	for k in keys:
		var w: float = _workstation_need(state, teams, String(k), tile)
		wgt[k] = w; total_w += w
	# 需求加權比例 + demand-cap + 溢出串聯（iterate 到穩，固定上限）。
	var alloc: Dictionary = {}
	var capped: Dictionary = {}
	for k in keys: alloc[k] = 0.0
	var remaining: float = pool
	if total_w > 0.0:
		for _i in range(OVERFLOW_ITERS):
			var rw: float = 0.0
			for k in keys:
				if not capped.get(k, false) and float(wgt[k]) > 0.0: rw += float(wgt[k])
			if rw <= 0.0 or remaining <= 0.001: break
			var overflow: float = 0.0
			var new_cap: bool = false
			for k in keys:
				if capped.get(k, false) or float(wgt[k]) <= 0.0: continue
				var give: float = remaining * float(wgt[k]) / rw
				var newshare: float = float(alloc[k]) + give
				if newshare >= float(demand[k]):
					overflow += newshare - float(demand[k])
					alloc[k] = float(demand[k]); capped[k] = true; new_cap = true
				else:
					alloc[k] = newshare
			remaining = overflow
			if not new_cap: break
	# fill + 存
	var out: Dictionary = {}
	for k in keys:
		var d: float = float(demand[k])
		var f: float = clampf(float(alloc[k]) / d, 0.0, 1.0) if d > 0.0 else 0.0
		out[k] = {"demand": d, "share": float(alloc[k]), "fill": f}
	tile.labor_alloc = out
	tile.labor_eval_next_tick = state.world.current_tick + LABOR_CADENCE

static func _workstation_need(state: WorldState, teams: Array, key: String, tile: HexTileData) -> float:
	# ★labor v2 T1 食物真邊際分配：食物組(gather:food + farm)合併 need=food_need 單一(double-count keep、
	# 跨資源不變)、組內按 per-labor yield 分配 labor 流向高者(farm 發展好 yield_f 高自然拿多)。
	if key == "gather:food" or key == "farm":
		return _food_group_need(state, teams, key, tile)
	var w: float = 0.0
	if key.begins_with("gather:"):
		var res: String = key.substr(7)
		for t in teams:
			var lv: Dictionary = TradeValuation.leader_vals(state, t)
			w += NeedOracle.need_keep(state, t, res, lv) + NeedOracle.demand(state, t, res, lv)
	elif key.begins_with("mfg:"):
		var lk: String = key.substr(4)
		for recipe in ManufacturingSystem.RECIPE_GROUPS.get(lk, []):
			var res: String = String(recipe["out"])
			for t in teams:
				var lv: Dictionary = TradeValuation.leader_vals(state, t)
				w += NeedOracle.need_keep(state, t, res, lv) + NeedOracle.demand(state, t, res, lv)
	return w

# ★labor v2 T1：食物組 per-labor yield 比例分。food_need(單一)×yield/(yg+yf)、labor 流向高 per-labor yield 者。
# yield_g=productivity×COLLECT_RATE(own-tile、gather 隨池竭遞減)、yield_f=farming_level×FUY×harvest(own-tile、
# ★level-dependent 發展越高每勞力越產)。純算術零 randf。
static func _food_group_need(state: WorldState, teams: Array, key: String, tile: HexTileData) -> float:
	var food_need: float = 0.0
	for t in teams:
		var lv: Dictionary = TradeValuation.leader_vals(state, t)
		food_need += NeedOracle.need_keep(state, t, "food", lv) + NeedOracle.demand(state, t, "food", lv)
	if food_need <= 0.0:
		return 0.0
	var yield_g: float = tile.productivity * ResourceSystem.COLLECT_RATE
	var yield_f: float = float(tile.farming_level) * ResourceSystem.FARM_UNIT_YIELD * tile.harvest_factor
	var denom: float = yield_g + yield_f
	if denom <= 0.0:
		return food_need if key == "gather:food" else 0.0
	if key == "gather:food":
		return food_need * yield_g / denom
	return food_need * yield_f / denom   # farm

# ★labor v2 T2 level-decouple：農田產出用 level-independent 正規化勞力(share/K_FARM×SCALE、非 fill=share/
# (level×K_FARM) 的 level 相消)。production=level×FUY×harvest×farm_labor → ∝ level×alloc、labor-starved 也
# 隨 level 真增產(治 level-cancellation)。demand=level×K_FARM 僅 alloc capacity cap、不除進 production。
static func farm_labor(tile: HexTileData) -> float:
	var a: Dictionary = tile.labor_alloc.get("farm", {})
	if a.is_empty():
		return 0.0
	return float(a.get("share", 0.0)) / K_FARM * LABOR_SCALE

# labor_mult(tile, workstation_key) = fill × LABOR_SCALE（取代 pop_mult；fill∈[0,1] 乘 SCALE 還原量級）。
# 未分配(w=0/工位不存在)→0（need-driven：不需要的工位無勞力）。
static func labor_mult(tile: HexTileData, key: String) -> float:
	var a: Dictionary = tile.labor_alloc.get(key, {})
	if a.is_empty():
		return 0.0
	return float(a.get("fill", 0.0)) * LABOR_SCALE
