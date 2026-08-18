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
		var w: float = _workstation_need(state, teams, String(k))
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

static func _workstation_need(state: WorldState, teams: Array, key: String) -> float:
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
	elif key == "farm":
		# ★農業a：農田工位 need=food need（farm 產 food，同 gather:food 的 need 權重法）。
		for t in teams:
			var lv: Dictionary = TradeValuation.leader_vals(state, t)
			w += NeedOracle.need_keep(state, t, "food", lv) + NeedOracle.demand(state, t, "food", lv)
	return w

# labor_mult(tile, workstation_key) = fill × LABOR_SCALE（取代 pop_mult；fill∈[0,1] 乘 SCALE 還原量級）。
# 未分配(w=0/工位不存在)→0（need-driven：不需要的工位無勞力）。
static func labor_mult(tile: HexTileData, key: String) -> float:
	var a: Dictionary = tile.labor_alloc.get(key, {})
	if a.is_empty():
		return 0.0
	return float(a.get("fill", 0.0)) * LABOR_SCALE
