class_name GoalResolver

# ★means-end 長程規劃（組件 C，HOW spec 2026-07-24 §4）：runtime frontier 合成中間層。
# 對 team.goal_state 每個 active goal，walk GoalRegistry[goal_type].prereqs 拆前置鏈，
# 合成當前可動 frontier candidate 餵 decision rank 池（與 static option 同池 argmax 競爭）。
# ★唯讀合成、每 tick 重算 transient frontier（不寫回 goal_state=無 plan-state，守 HOW §9）。
# ★路徑必 scripts/simulation/decision/（constitution_gate GV_FILE_RE 涵蓋）→ god-view/RNG detector 看得到。
#
# Candidate 結構（HOW §4）：{ util:float, to_task:Dictionary, source_goal:GoalInstance, label:String, delegate:bool }。
#
# ★S2：資源型 resolution 接通（第一實質 slice，打破 byte-identical）。只 resource 前置→「買」取得 candidate；
#   定位(採)/設施(產)前置=S3/S4 回無 candidate（stub 邊界）。折現/委派/子目標=S3-S6 別提前（whole-system-first）。

# ★must-fix① util 護欄（HOW §8，首上場硬做）：goal candidate util 恆 < 絕境 survival-boosted static util。
# = payoff × dev_urgency_coeff（絕境 food_days→0→0=壓遠慾望）+ clamp 上界 < SURVIVAL_BOOST_MAX（硬保證）。
const GOAL_UTIL_CAP: float = 1.5   # TEST VALUE — < DecisionEngine.SURVIVAL_BOOST_MAX(2.5) 硬護欄:goal candidate 永不蓋絕境 survival boost

# ★組件 A（S2 版）：冪等確保 team.goal_state 含 5 資源維持 goal + 更新 active/satisfied（holding<need_keep→active）。
# S7 才做 util-門檻掛退 cadence 泛化；S2 固定 goal-set。純讀狀態+need_keep，零 randf。
static func ensure_maintain_goals(state: WorldState, team: TeamData) -> void:
	if state == null or team == null or state.world == null:
		return
	var lv: Dictionary = TradeValuation.leader_vals(state, team)
	var have: Dictionary = {}
	for g in team.goal_state:
		have[String(g.get("goal_type", ""))] = true
	# 冪等補齊缺的 maintain goal（決定性順序：REGISTRY key 序）
	for gt in GoalRegistry.MAINTAIN_GOAL_RES:
		if not have.has(gt):
			team.goal_state.append({"goal_type": gt, "target": null,
				"created_tick": state.world.current_tick, "status": "active"})
	# 更新 status：holding < need_keep(res) → active（想維持）；否則 satisfied。
	for g in team.goal_state:
		var gt: String = String(g.get("goal_type", ""))
		if not GoalRegistry.MAINTAIN_GOAL_RES.has(gt):
			continue   # 非 maintain goal（S3+ 別型）不在此管
		var res: String = String(GoalRegistry.MAINTAIN_GOAL_RES[gt])
		var target: float = NeedOracle.need_keep(state, team, res, lv)
		var holding: float = ResourceSystem.effective_holding(state, team, res)
		g["status"] = "active" if holding < target else "satisfied"

static func frontier_candidates(state: WorldState, team: TeamData, ctx: DecisionContext) -> Array:
	if state == null or team == null or ctx == null:
		return []   # harness 無 state/team → 無 goal frontier（安全）
	var out: Array = []
	var lv: Dictionary = TradeValuation.leader_vals(state, team)
	for g in team.goal_state:
		if String(g.get("status", "")) != "active":
			continue
		var gt: String = String(g.get("goal_type", ""))
		var def: Dictionary = GoalRegistry.REGISTRY.get(gt, {})
		if def.is_empty():
			continue
		var payoff: float = float(def.get("payoff", 1.0))
		for prereq in def.get("prereqs", []):
			var kind: String = String(prereq.get("kind", ""))
			var cand: Dictionary = {}
			if kind == GoalRegistry.PREREQ_RESOURCE:
				cand = _resolve_resource_prereq(state, team, ctx, g, gt, payoff, prereq)   # S2 買 + S3 採@地形
			elif kind == GoalRegistry.PREREQ_LOCATION:
				cand = _resolve_location_prereq(state, team, ctx, g, gt, payoff, prereq)   # S3 定位型
			# manpower/facility/subgoal = S4-S6（無 candidate，stub 邊界）
			if not cand.is_empty():
				out.append(cand)
	return out

# ★S2/S3 資源型前置 resolution：未滿→取得 candidate（S2 買 / S3 採@地形定位）。
const SEEK_TILE_RANGE: int = 30   # TEST VALUE — belief-reachable 上界（bounded seek，非全知 PathSystem live）
# ★資源→採集地形（material←forest 核心缺口鏈，arc 原始動機）。S3 只 material；他 res 採集地形=後續。
const RES_HARVEST_TERRAIN: Dictionary = {"material": "forest"}

static func _resolve_resource_prereq(state: WorldState, team: TeamData, ctx: DecisionContext,
		g: Dictionary, gt: String, payoff: float, prereq: Dictionary) -> Dictionary:
	var res: String = String(prereq.get("res", ""))
	var lv: Dictionary = TradeValuation.leader_vals(state, team)
	# 組件 E 泛化：qty 走通用 need_keep（任 res）。
	if ResourceSystem.effective_holding(state, team, res) >= NeedOracle.need_keep(state, team, res, lv):
		return {}   # 前置滿
	# ── 取得手段 1：買（S2，市場取得不需定位；belief-gated）──
	if ctx.has_specie:
		var mp: Vector2i = FactionAISystem.new()._nearest_market_outpost_with(state, team, res)
		if mp != Vector2i(-1, -1):
			return _mk_candidate(g, gt, GoalRegistry.PREREQ_RESOURCE, payoff, ctx, {"task": TeamData.TASK_TRADE, "target": mp})
	# ── 取得手段 2：採@地形（S3，買不到→定位取得）★material 缺口鏈：需該地形 outpost 採；無→移動到最近可達地形 tile。
	if RES_HARVEST_TERRAIN.has(res):
		var terrain: String = String(RES_HARVEST_TERRAIN[res])
		var own: Vector2i = FactionAISystem.new()._find_own_outpost(state, team)
		var own_tile: HexTileData = state.world.tiles.get(own.x * 1000 + own.y) if own != Vector2i(-1, -1) else null
		if own_tile != null and own_tile.terrain == terrain:
			return {}   # 已有該地形 outpost → 採 satisfied（既有 harvest 供給），無 move candidate
		var pos: Vector2i = find_nearest_terrain_tile(state, team, terrain, SEEK_TILE_RANGE)   # 純地形=公共地理
		if pos != Vector2i(-1, -1):
			# frontier「移動到最近可達地形 tile」（到了下一 frontier=建 outpost 那裡，前置滿才 applicable→湧現順序）。
			return _mk_candidate(g, gt, GoalRegistry.PREREQ_LOCATION, payoff, ctx, {"task": TeamData.TASK_MIGRATE, "target": pos})
	return {}   # S3 無取得手段（產=S4 設施）

# ★S3 定位型前置 handler（組件 C）：{kind:location, terrain, control?}。查隊在/有滿足 tile，未滿→tile frontier candidate。
static func _resolve_location_prereq(state: WorldState, team: TeamData, ctx: DecisionContext,
		g: Dictionary, gt: String, payoff: float, prereq: Dictionary) -> Dictionary:
	var terrain: String = String(prereq.get("terrain", ""))
	var need_control: bool = bool(prereq.get("control", false))
	# 已滿？隊在/擁有滿足條件 tile（own outpost terrain match）。
	var own: Vector2i = FactionAISystem.new()._find_own_outpost(state, team)
	var own_tile: HexTileData = state.world.tiles.get(own.x * 1000 + own.y) if own != Vector2i(-1, -1) else null
	if own_tile != null and (terrain == "" or own_tile.terrain == terrain):
		return {}   # 已在/擁有 → 前置滿
	# 未滿 → ★tile-resolver 拆兩類（must-fix②）：
	var pos: Vector2i
	if need_control:
		# (ii) 所有權/control 動態狀態 → belief store（踩市集判例，禁全圖 god-view）
		pos = find_nearest_known_tile(state, team, terrain)
	else:
		# (i) 純地形/物理地理 → 公共知識全圖掃（# gate-ok）
		pos = find_nearest_terrain_tile(state, team, terrain, SEEK_TILE_RANGE)
	if pos == Vector2i(-1, -1):
		return {}
	return _mk_candidate(g, gt, GoalRegistry.PREREQ_LOCATION, payoff, ctx, {"task": TeamData.TASK_MIGRATE, "target": pos})

static func _mk_candidate(g: Dictionary, gt: String, frontier_kind: String, payoff: float,
		ctx: DecisionContext, to_task: Dictionary) -> Dictionary:
	return {
		"util": _candidate_util(payoff, ctx),
		"to_task": to_task,
		"source_goal": g,
		"label": gt + ":" + frontier_kind,   # root_goal + frontier_kind（有界 label，HOW §7）
		"delegate": false,   # 委派變體 = S5（組件 D）別提前
	}

# ★must-fix②(i) 純地形/物理地理查詢（公共知識 legit）→ 全圖掃標 # gate-ok（比照 constitution_gate:41）。
# belief-reachable=bounded hex dist（非全知 PathSystem live）。決定性 tie-break tile_id。零 randf。
static func find_nearest_terrain_tile(state: WorldState, team: TeamData, terrain: String, max_range: int) -> Vector2i:
	var best: Vector2i = Vector2i(-1, -1)
	var best_d: int = 1 << 30
	var best_id: int = 1 << 30
	var fai := FactionAISystem.new()
	for tid in state.world.tiles:   # gate-ok: 地理=公共知識（terrain 靜態物理地理非動態所有權，比照 constitution_gate:41 市集地理先例）
		var t: HexTileData = state.world.tiles[tid]
		if t == null or (terrain != "" and t.terrain != terrain):
			continue
		var d: int = fai._hex_dist(team.tile_pos, t.tile_pos)
		if d > max_range:
			continue   # belief-reachable bounded（非全知 PathSystem）
		if d < best_d or (d == best_d and int(tid) < best_id):
			best_d = d; best_id = int(tid); best = t.tile_pos
	return best

# ★must-fix②(ii) 所有權/control 動態查詢（踩 invariants:192 市集判例）→ 讀 team_tile_known belief（禁全圖 god-view）。
# 決定性 tie-break tile_id。零 randf。
static func find_nearest_known_tile(state: WorldState, team: TeamData, terrain: String) -> Vector2i:
	_harvest_tile_known(state, team)
	var known: Dictionary = state.team_tile_known.get(team.team_id, {})
	var best: Vector2i = Vector2i(-1, -1)
	var best_d: int = 1 << 30
	var best_id: int = 1 << 30
	var fai := FactionAISystem.new()
	for tid in known:   # 只掃 belief store（已發現 tile，非全圖）→ 無 god-view
		var t: HexTileData = state.world.tiles.get(tid)
		if t == null or (terrain != "" and t.terrain != terrain):
			continue
		var d: int = fai._hex_dist(team.tile_pos, t.tile_pos)
		if d < best_d or (d == best_d and int(tid) < best_id):
			best_d = d; best_id = int(tid); best = t.tile_pos
	return best

# ★team_tile_known belief harvest（鏡射 _harvest_market_known）：兩源=bounded vision + relay。禁 RNG。
static func _harvest_tile_known(state: WorldState, team: TeamData) -> void:
	var known: Dictionary = state.team_tile_known.get(team.team_id, {})
	var fai := FactionAISystem.new()
	var vr: int = VisionSystem.VISION_RADIUS
	for dx in range(-vr, vr + 1):   # bounded=vision（非全圖 god-view）
		for dy in range(-vr, vr + 1):
			var p: Vector2i = team.tile_pos + Vector2i(dx, dy)
			if fai._hex_dist(team.tile_pos, p) > vr:
				continue
			var tid: int = p.x * 1000 + p.y
			if state.world.tiles.has(tid):
				known[tid] = true
	# relay：team_known tile 訊息 pos（reuse market pos extractor）→ known
	for msg in state.team_known.get(team.team_id, []):
		var mpos: Vector2i = fai._msg_market_pos(msg)
		if mpos == Vector2i(-999, -999):
			continue
		known[mpos.x * 1000 + mpos.y] = true
	state.team_tile_known[team.team_id] = known

# ★must-fix① util 護欄（HOW §8，reviewer S2 指定回歸點）：
# dev_urgency_coeff(絕境壓遠慾望) × payoff，clamp 上界 < survival boost → goal candidate 永不蓋活命。
static func _candidate_util(payoff: float, ctx: DecisionContext) -> float:
	# dev_urgency_coeff：鏡射 NeedHierarchy consistency_coeff 對「發展/遠層」的壓制精神——
	# food_days→0（絕境）→ 0（遠慾望歸零，讓眼前 survival 奪 argmax）；food 足→1。
	var dev_coeff: float = clampf(ctx.food_days / DecisionTerms.DESPERATION_DAYS, 0.0, 1.0)
	# clamp 上界 GOAL_UTIL_CAP < SURVIVAL_BOOST_MAX：即使 payoff 巨、dev_coeff 未全 0，硬保證 < 絕境 survival-boosted static util。
	return clampf(payoff * dev_coeff, 0.0, GOAL_UTIL_CAP)
