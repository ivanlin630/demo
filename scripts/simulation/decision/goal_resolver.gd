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
	# ★S4 設施發展 goal 生成（組件 A 最小）：隊對 F 有 desire（_facility_deficit≥threshold 且未建）→ 掛 build_F goal。
	# S7 才做 util-門檻掛退 cadence 泛化；S4 只掛（desire 掉→下 handler 自然 satisfied[F 建成]或無 candidate）。
	var own: Vector2i = FactionAISystem.new()._find_own_outpost(state, team)
	var otile: HexTileData = state.world.tiles.get(own.x * 1000 + own.y) if own != Vector2i(-1, -1) else null
	if otile != null:
		var fai := FactionAISystem.new()
		for gt2 in GoalRegistry.BUILD_FACILITY_GOALS:   # 決定性順序
			if have.has(gt2):
				continue
			var f: String = String(GoalRegistry.BUILD_FACILITY_GOALS[gt2])
			var fdef: Dictionary = OutpostSystem.FACILITY_DEF.get(f, {})
			if not (otile.outpost_type in fdef.get("allowed_outpost", [])):
				continue   # 該 outpost type 不能建此 F → 不掛
			if int(otile.get(fdef.get("current_level_key", ""))) > 0:
				continue   # 已建 → 不掛
			if fai._facility_deficit(state, team, f, otile) >= NeedOracle.CONSTRUCTION_DESIRE_MIN:
				team.goal_state.append({"goal_type": gt2, "target": null,
					"created_tick": state.world.current_tick, "status": "active"})

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
		# ★S4 設施發展 goal（build_F）：walk build-cost/facility-type/manpower 前置→frontier or build_F action。
		if def.has("facility"):
			var bc: Dictionary = _resolve_build_facility(state, team, ctx, g, gt, def)
			if not bc.is_empty():
				out.append(bc)
			continue
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
	# ★S5 委派 peer option（組件 D）：build/settle 型 candidate 產「派子隊做」變體並列 rank 池（跟自己做競 util）。
	var delegated: Array = []
	for c in out:
		var dv: Dictionary = _delegate_variant(state, team, ctx, c)
		if not dv.is_empty():
			delegated.append(dv)
	out.append_array(delegated)
	return out

# ★S5 委派變體（組件 D）：build/settle 型 action 產「派子隊做」變體。★gate② 正解:applicable=真 viability
# （pop − settler_count ≥ MIN_PARENT_POP_AFTER_DISPATCH，attempt=dispatch 同源→無 pop 8-12 浪費帶）。
# 委派 util=自己做 util+多線紅利(母隊留守+子隊並行)−餘力成本;must-fix① clamp<survival 沿用。純狀態零 randf。
const DELEGATE_MULTILINE_BONUS: float = 0.3   # TEST VALUE — 多線紅利（母隊留守本業+子隊並行，不離 food base）
const DELEGATE_COST: float = 0.1              # TEST VALUE — 餘力成本（分兵管理開銷）
static func _delegate_variant(state: WorldState, team: TeamData, ctx: DecisionContext, self_cand: Dictionary) -> Dictionary:
	var to_task: Dictionary = self_cand.get("to_task", {})
	var task: String = String(to_task.get("task", ""))
	if task != TeamData.TASK_BUILD and task != TeamData.TASK_SETTLE:
		return {}   # 只 build/settle 型委派（S5）
	# ★gate② viability（attempt=dispatch 同源，根治 8-12 浪費帶）
	var pop: int = team.population
	var settler: int = clampi(pop / 4, 2, 5)
	if pop - settler < FactionAISystem.MIN_PARENT_POP_AFTER_DISPATCH:
		return {}   # 餘力不足 → 無委派變體（只自己做，pop-guard 擋=多線無委派恆贏）
	var base_u: float = float(self_cand.get("util", 0.0))
	var deleg_u: float = clampf(base_u + DELEGATE_MULTILINE_BONUS - DELEGATE_COST, 0.0, GOAL_UTIL_CAP)   # must-fix① clamp 沿用
	var dtask: Dictionary = to_task.duplicate()
	dtask["delegate"] = true
	dtask["settler"] = settler   # 派子隊 pop（餘力 gate 配額）
	return {
		"util": deleg_u,
		"to_task": dtask,
		"source_goal": self_cand.get("source_goal", {}),
		"label": String(self_cand.get("label", "")) + ":delegate",
		"delegate": true,
	}

# ★S4 設施發展 resolution（組件 C 設施型）：walk build_F 前置鏈——resource(build-cost)→facility(outpost-type)
# →manpower(pop)→全滿 build_F action。first-unsatisfied 前置生 frontier（means-end 湧現順序）。
static func _resolve_build_facility(state: WorldState, team: TeamData, ctx: DecisionContext,
		g: Dictionary, gt: String, def: Dictionary) -> Dictionary:
	var f: String = String(def.get("facility", ""))
	var fdef: Dictionary = OutpostSystem.FACILITY_DEF.get(f, {})
	if fdef.is_empty():
		return {}
	var payoff: float = float(def.get("payoff", 1.5))
	var own: Vector2i = FactionAISystem.new()._find_own_outpost(state, team)
	var own_tile: HexTileData = state.world.tiles.get(own.x * 1000 + own.y) if own != Vector2i(-1, -1) else null
	# F 已建 → satisfied（無 candidate）。
	if own_tile != null and int(own_tile.get(fdef.get("current_level_key", ""))) > 0:
		return {}
	# 前置 1：resource build-cost（material/tools）——缺→接 S2/S3 資源鏈（need_keep 已含 construction need）。
	var cost: Dictionary = OutpostSystem.upgrade_cost(f, 1)
	for res in ["material", "tools"]:
		if float(cost.get(res, 0)) > 0.0:
			var c: Dictionary = _resolve_resource_prereq(state, team, ctx, g, gt, payoff, {"kind": GoalRegistry.PREREQ_RESOURCE, "res": res})
			if not c.is_empty():
				return c   # first-unsatisfied resource → 取得 frontier（買/採）
	# 前置 2：facility outpost-type（需 allowed_outpost type outpost）——無合適 type→建 outpost frontier。
	var allowed: Array = fdef.get("allowed_outpost", [])
	if own_tile == null or not (own_tile.outpost_type in allowed):
		# ★unowned track（reviewer R²）：隊在自己 tile 未建→建 outpost（start_build 自然擋已占）；有 outpost 但 type 不符=改建複雜 S4 不做。
		var cur: HexTileData = state.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)
		if cur != null and cur.outpost_level == 0:
			return _mk_candidate(team, g, gt, GoalRegistry.PREREQ_FACILITY, payoff, ctx, {"task": TeamData.TASK_BUILD, "target": team.tile_pos})
		return {}   # 無合適位置 → 靜默（whole-system-first，不造假）
	# 前置 3：manpower pop（既有 build pop 門檻）——不足→靜默（S4 最小，passive 繁殖增，無主動 recruit task）。
	if team.population < GoalRegistry.FACILITY_BUILD_POP_MIN:
		return {}
	# ★全滿 → build_F action candidate（在 own outpost 建 F；to_task 帶 facility 供 dispatch 接既有 build 機械）。
	return _mk_candidate(team, g, gt, GoalRegistry.PREREQ_FACILITY, payoff, ctx,
		{"task": TeamData.TASK_BUILD, "target": own_tile.tile_pos, "facility": f})

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
			return _mk_candidate(team, g, gt, GoalRegistry.PREREQ_RESOURCE, payoff, ctx, {"task": TeamData.TASK_TRADE, "target": mp})
	# ── 取得手段 2：採@地形（S3，買不到→定位取得）★material 缺口鏈：需該地形 outpost 採。
	# ★湧現閉環：缺料→(a)移動到 forest→(b)到了建 outpost→own.terrain==forest→採 satisfied。
	if RES_HARVEST_TERRAIN.has(res):
		var terrain: String = String(RES_HARVEST_TERRAIN[res])
		var own: Vector2i = FactionAISystem.new()._find_own_outpost(state, team)
		var own_tile: HexTileData = state.world.tiles.get(own.x * 1000 + own.y) if own != Vector2i(-1, -1) else null
		if own_tile != null and own_tile.terrain == terrain:
			return {}   # ★閉環完成:已有該地形 outpost → 採 satisfied（既有 harvest 供給）
		var cur: HexTileData = state.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)
		if cur != null and cur.terrain == terrain and cur.outpost_level == 0:
			# ★build-closure frontier（REDO）：隊已在目標地形 tile 且未建 → 「建 outpost 那裡」candidate（in-place build）。
			# unowned 過濾:目標格已被別隊擁有→outpost_level>0 不進此支;真被占 start_build 自然擋。委派 build=S5 別提前。
			return _mk_candidate(team, g, gt, GoalRegistry.PREREQ_FACILITY, payoff, ctx, {"task": TeamData.TASK_BUILD, "target": team.tile_pos})
		var pos: Vector2i = find_nearest_terrain_tile(state, team, terrain, SEEK_TILE_RANGE)   # 純地形=公共地理
		if pos != Vector2i(-1, -1) and pos != team.tile_pos:
			# frontier1「移動到最近可達地形 tile」（防 d=0 對自己 tile 生移動卡住）。
			return _mk_candidate(team, g, gt, GoalRegistry.PREREQ_LOCATION, payoff, ctx, {"task": TeamData.TASK_MIGRATE, "target": pos})
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
	return _mk_candidate(team, g, gt, GoalRegistry.PREREQ_LOCATION, payoff, ctx, {"task": TeamData.TASK_MIGRATE, "target": pos})

static func _mk_candidate(team: TeamData, g: Dictionary, gt: String, frontier_kind: String, payoff: float,
		ctx: DecisionContext, to_task: Dictionary) -> Dictionary:
	return {
		"util": _candidate_util(payoff, ctx, _estimate_delay_days(team, to_task)),   # ★S6:util 含 delay 折現
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

# ★S6 折現（組件 F，HOW §7）：delay-based discount（連續，符憲法 utility 連續）。
const MOVE_TILES_PER_DAY: float = 2.0   # TEST VALUE — 移速估（淺啟發，delay 有界）
const BUILD_DAYS_EST: float = 3.0       # TEST VALUE — build/settle 工期估（淺啟發，非讀細 BUILD_TICKS）
const DISCOUNT_BASE: float = 0.5        # TEST VALUE — 折現率基值（人格/絕境調）

# delay 估（淺啟發有界）：移動天數（target hex dist÷移速）+ build/settle 工期。純狀態零 randf。
static func _estimate_delay_days(team: TeamData, to_task: Dictionary) -> float:
	var days: float = 0.0
	var target = to_task.get("target", Vector2i(-1, -1))
	if team != null and target is Vector2i and target != Vector2i(-1, -1) and target != team.tile_pos:
		days += float(FactionAISystem.new()._hex_dist(team.tile_pos, target)) / MOVE_TILES_PER_DAY
	var task: String = String(to_task.get("task", ""))
	if task == TeamData.TASK_BUILD or task == TeamData.TASK_SETTLE:
		days += BUILD_DAYS_EST
	return days

# ★人格折現率 rate（WHAT §6「人格=折現率」，權重非 gate）：絕境→高(短視,遠 candidate 折趨零不走遠路)/
# 慎重耐心高→低(遠視肯投遠利)。純狀態零 randf。
static func _discount_rate(ctx: DecisionContext) -> float:
	var desperation: float = clampf(1.0 - ctx.food_days / DecisionTerms.DESPERATION_DAYS, 0.0, 1.0)   # food→0→1(絕境)
	var caution: float = float(ctx.leader_values.get("慎重", 0.5))   # 遠視(rate 降;極慎重=純遠視 rate→0)
	return maxf(DISCOUNT_BASE * (desperation + 1.0 - caution), 0.0)   # 中性有 baseline 折現;絕境高;極慎重趨 0

# ★must-fix① util 護欄（HOW §8，reviewer S2/S6 回歸點）+ S6 折現：
# util = payoff × dev_coeff(絕境→0) × discount(delay,人格 rate)，clamp<survival。★折現乘法(≤1)只變小非變大→護欄不破。
static func _candidate_util(payoff: float, ctx: DecisionContext, delay_days: float = 0.0) -> float:
	# dev_urgency_coeff：鏡射 consistency_coeff 對「發展/遠層」壓制——food_days→0（絕境）→ 0（遠慾望歸零讓 survival 奪 argmax）。
	var dev_coeff: float = clampf(ctx.food_days / DecisionTerms.DESPERATION_DAYS, 0.0, 1.0)
	# ★S6 折現:discount=1/(1+rate×delay)（delay=0→1 近/即時不折;delay 大+絕境 rate 高→趨零不走遠路）。遞減有界。
	var discount: float = 1.0 / (1.0 + _discount_rate(ctx) * maxf(delay_days, 0.0))
	# clamp 上界 GOAL_UTIL_CAP < SURVIVAL_BOOST_MAX：硬保證 < 絕境 survival-boosted static util（折現只讓 util 更小=護欄更穩）。
	return clampf(payoff * dev_coeff * discount, 0.0, GOAL_UTIL_CAP)
