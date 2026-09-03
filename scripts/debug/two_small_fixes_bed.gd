extends SceneTree
# @observe-pure
# ★★★兩個小修的驗收床（#2 crisis 絕對餓／#4 生育截斷懸崖）。
#   ★兩條都用【最小構造】直接問那一個 predicate —— ★★不繞 30 日 sim：
#   要證的是「這個條件成不成立」，而那是秒級可判的；organic 的逐隊 dump 另跑。
var _fail: int = 0

func _initialize() -> void:
	_test_crisis_absolute_hunger()
	_test_breed_no_cliff()
	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond: print("  [PASS] %s" % msg)
	else: _fail += 1; print("  [FAIL] %s" % msg)

func _mk(state: WorldState, tid: int, pop: int, food: float) -> TeamData:
	var p := PersonData.new(); p.id = tid * 10; p.team_id = tid
	state.persons[p.id] = p
	var t := TeamData.new()
	t.team_id = tid; t.leader_id = p.id; t.tile_pos = Vector2i(1, 1)
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", pop)
	t.resources = {"food": food}
	t.food_flow_avg = 0.0        # ★三條舊判準全不成立：flow 0、無 pop 崩跌
	t.rung_pop_last = 0
	state.teams[tid] = t
	return t

func _test_crisis_absolute_hunger() -> void:
	print("--- #2：存量歸零 ⇒ crisis（★而三條舊判準都不成立）---")
	var s: WorldState = MeasureBedHelper.arm_and_new()
	s.world.current_tick = 100
	var ai := FactionAISystem.new()
	var starved: TeamData = _mk(s, 1, 6, 0.0)
	var fed: TeamData = _mk(s, 2, 6, 50.0)
	_ok(ai._decision_crisis(s, starved), "food=0、flow=0、無崩跌 ⇒ crisis（★修前這一支是 false）")
	_ok(not ai._decision_crisis(s, fed), "food=50 同條件 ⇒ 非 crisis（★陰性對照：不是恆真）")
	# ★★★真值來源：糧倉公庫算不算 —— 這一條才是 WS-1 那個坑
	var s2: WorldState = MeasureBedHelper.arm_and_new()
	s2.world.current_tick = 100
	var stored: TeamData = _mk(s2, 3, 6, 0.0)   # 私產 0
	var tile := HexTileData.new()
	tile.tile_pos = stored.tile_pos
	tile.outpost_level = 1
	tile.outpost_owner = stored.team_id
	tile.public_storage = {"food": 80.0}        # ★倉裡有糧
	s2.world.tiles[stored.tile_pos.x * 1000 + stored.tile_pos.y] = tile
	OwnerOutpostIndex.invalidate()
	_ok(not ai._decision_crisis(s2, stored),
		"★私產 0 但自家糧倉有 80 ⇒ 【不是】絕對餓（effective_food=%.1f）"
		% ResourceSystem.effective_food(s2, stored))

func _test_breed_no_cliff() -> void:
	print("--- #4：pop ≤ 4 的隊生育慾望不再結構性恆 0 ---")
	var rs := ReactionSystem.new()
	var p := PersonData.new()
	p.needs = {"safety": 0.9, "food": 0.9}      # safe 且 fed
	p.skills = {}
	var results: Array = []
	for pop in [1, 2, 3, 4, 5, 10]:
		var t := TeamData.new()
		t.team_id = 100 + pop
		AnonCohort.add(t.anon_cohorts, "平民", "healthy", pop)
		var sc: float = rs._score_breed(p, t)
		results.append("pop=%d minor=%d score=%.2f" % [pop, t.minor_population, sc])
		if pop <= 4:
			_ok(sc > 0.0, "pop=%d（minor=%d）⇒ score=%.2f > 0（★修前 int(pop*0.2)=0 恆假）" % [pop, t.minor_population, sc])
	print("     逐點：%s" % " ｜ ".join(PackedStringArray(results)))
	# ★陰性對照：minor 已超過 20% ⇒ 仍應為 0（★不是把門檻整個拿掉）
	var t2 := TeamData.new()
	t2.team_id = 999
	AnonCohort.add(t2.anon_cohorts, "平民", "healthy", 10)
	# ★`minor_population` 是 TeamData 上的獨立 int 欄位（不是從 cohort 推的）——
	#   ★★我第一版拿 AnonCohort 加「孩童」去湊，而那個欄位【根本不會動】⇒ 陰性對照假紅。
	#   ★★★而假紅比假綠好：它逼我去查那個欄位是誰寫的（population_system.gd:18-20）。
	t2.minor_population = 5
	_ok(rs._score_breed(p, t2) == 0.0,
		"★minor 5 / pop 10 = 50% > 20% ⇒ score 0（陰性對照：門檻還在，只是不再截斷）")
