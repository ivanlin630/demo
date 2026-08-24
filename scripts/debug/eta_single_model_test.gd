extends SceneTree
# eta-single-model TDD（spec `2026-08-21-eta-single-model-HOW.md` §3 gate 1-3）。
#
# ★病：`PathSystem.eta_ticks` 自己算「走一格要多久」（只吃疲勞），
#   真實走一格是 `MovementSystem._move_cost`（隊速組成×地形×疲勞×超載×車輛，clamp[BASE/3, BASE×3]）。
#   porter 永遠超載 ⇒ 真實每格吃 MAX clamp（3×BASE），而 eta 只算 1×BASE
#   ⇒ T3 預算 = MULT(3.0) × eta = 真實路程時間本身 ⇒ **餘裕恰好 0**，最後一格必超支。
#
# ★本床的判準【不抄任何物理常數】：一律拿 `eta_ticks` 跟「逐格 `_move_cost` 累加」對照
#   ——同一個模型的兩種算法必須一致，這是結構斷言，不是我拍的數字。

var _fail := 0
func _ok(c: bool, m: String) -> void:
	if c: print("  PASS ", m)
	else: _fail += 1; print("  FAIL ", m)

func _initialize() -> void:
	_run(); quit()

# 直線鋪一條 tile 路（同一 terrain），回傳 path（含起點）
func _lay_line(state: WorldState, from: Vector2i, n: int, terrain: String) -> Array:
	var path: Array = []
	for i in range(n):
		var p := Vector2i(from.x + i, from.y)
		var t := HexTileData.new()
		t.tile_id = p.x * 1000 + p.y; t.tile_pos = p; t.terrain = terrain
		state.world.tiles[t.tile_id] = t
		path.append(p)
	return path

# 真值：把隊伍逐格擺過去，累加 `_move_cost`（＝世界真的會花的 tick）
func _walk_cost(state: WorldState, team: TeamData, path: Array) -> int:
	var mv := MovementSystem.new()
	var keep: Vector2i = team.tile_pos
	var total: int = 0
	for i in range(path.size() - 1):
		team.tile_pos = path[i]
		total += mv._move_cost(state, team)
	team.tile_pos = keep
	return total

func _mk_team(pop: int) -> TeamData:
	var t := TeamData.new()
	t.team_id = 1
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", pop)
	return t

func _case(label: String, state: WorldState, team: TeamData, path: Array) -> void:
	team.tile_pos = path[0]
	var walked: int = _walk_cost(state, team, path)
	var eta: int = PathSystem.eta_ticks(state, team, path)
	var err: float = abs(float(eta) - float(walked)) / maxf(float(walked), 1.0)
	_ok(err <= 0.05, "gate2 %s：eta=%d vs 逐格累加=%d（誤差 %.1f%% ≤5%%）" % [label, eta, walked, err * 100.0])

func _run() -> void:
	print("=== eta-single-model test ===")

	# ── gate2-a 超載（porter 原型：pop=1 背一堆貨）
	var s1 := WorldState.new(); s1.world = WorldData.new()
	var p1: Array = _lay_line(s1, Vector2i(0, 0), 6, "plains")
	var t1 := _mk_team(1)
	t1.resources = {"food": 200.0, "weapon_melee_low": 20.0}
	s1.teams[t1.team_id] = t1
	_case("超載", s1, t1, p1)

	# ── gate2-b 地形（forest/mountain 混合線）
	var s2 := WorldState.new(); s2.world = WorldData.new()
	var p2a: Array = _lay_line(s2, Vector2i(0, 0), 3, "forest")
	var p2b: Array = _lay_line(s2, Vector2i(3, 0), 3, "mountain")
	var p2: Array = p2a + p2b
	var t2 := _mk_team(6)
	t2.resources = {"food": 5.0}
	s2.teams[t2.team_id] = t2
	_case("地形", s2, t2, p2)

	# ── gate2-c 車輛
	var s3 := WorldState.new(); s3.world = WorldData.new()
	var p3: Array = _lay_line(s3, Vector2i(0, 0), 6, "forest")
	var t3 := _mk_team(8)
	t3.resources = {"food": 20.0, "wagons": 3.0}
	s3.teams[t3.team_id] = t3
	_case("車輛", s3, t3, p3)

	# ── gate2-d 疲勞（舊模型唯一吃到的因素——不得因為改模型而掉）
	var s4 := WorldState.new(); s4.world = WorldData.new()
	var p4: Array = _lay_line(s4, Vector2i(0, 0), 6, "plains")
	var t4 := _mk_team(6)
	t4.resources = {"food": 5.0}
	t4.fatigue = 0.8
	s4.teams[t4.team_id] = t4
	_case("疲勞", s4, t4, p4)
	t4.tile_pos = p4[0]
	var eta_tired: int = PathSystem.eta_ticks(s4, t4, p4)
	t4.fatigue = 0.0
	var eta_fresh: int = PathSystem.eta_ticks(s4, t4, p4)
	_ok(eta_tired > eta_fresh, "gate2-d 疲勞仍延長 ETA（%d > %d）" % [eta_tired, eta_fresh])

	# ── gate3 T3 餘裕恢復：預算 / 真實路程時間 ≈ MULT（修前 ≈1.0 ＝ 零餘裕）
	#   ★用超載 porter（就是實際會下 T3 判決的那種隊）
	t1.tile_pos = p1[0]
	var real_walk: float = float(_walk_cost(s1, t1, p1))
	var budget: float = FactionAISystem.RETURN_ABANDON_ETA_MULT * float(PathSystem.eta_ticks(s1, t1, p1))
	var slack: float = budget / maxf(real_walk, 1.0)
	_ok(abs(slack - FactionAISystem.RETURN_ABANDON_ETA_MULT) / FactionAISystem.RETURN_ABANDON_ETA_MULT <= 0.05,
		"★gate3 T3 餘裕＝MULT（budget/真實路程 = %.2f，應 ≈ %.2f，修前 ≈1.0）"
			% [slack, FactionAISystem.RETURN_ABANDON_ETA_MULT])

	# ── 邊界：起點＝終點（find_path 回 [from]）⇒ ETA 0，不得爆
	var s5 := WorldState.new(); s5.world = WorldData.new()
	var p5: Array = _lay_line(s5, Vector2i(0, 0), 1, "plains")
	var t5 := _mk_team(3)
	s5.teams[t5.team_id] = t5
	t5.tile_pos = p5[0]
	_ok(PathSystem.eta_ticks(s5, t5, p5) == 0, "邊界：單格 path → ETA 0")
	_ok(PathSystem.eta_ticks(s5, t5, []) == 0, "邊界：空 path → ETA 0")

	print("=== %s（fail=%d）===" % ["ALL PASS" if _fail == 0 else "HAS FAILURE", _fail])
