extends SceneTree

func _initialize() -> void:
	var state := WorldState.new()
	var gen = load("res://scripts/simulation/world_generator.gd").new()
	gen.generate(state, { "radius": 4, "seed": 42 })

	# 玩家放「偏離地圖中心」的格（近邊界）→ 驗視窗仍以 @ 為中心（U16 真因:舊版整圖絕對座標 @ 會偏）
	var team := TeamData.new()
	team.team_id = 0
	team.population = 10
	team.tile_pos = Vector2i(6, 2)   # 偏離中心(地圖中心 4,4)但仍在 radius-4 圖內
	team.tags = ["統領"]
	team.resources = { "food": 500.0, "coin": 50 }
	state.teams[0] = team
	state.team_known[0] = []
	state.team_discovered[0] = []

	var leader := PersonData.new()
	leader.id = 0; leader.person_name = "玩家"; leader.role = "leader"
	leader.team_id = 0; leader.loyalty = 1.0
	state.persons[0] = leader
	team.leader_id = 0
	state.player_id = 0

	var cursor := Vector2i(-99, -99)   # 無 cursor
	var map_str := TextMapRenderer.render(state, 0, cursor)
	print("=== MAP RENDER (player off-center @6,2) ===")
	print(map_str)
	print("=== END MAP ===")

	var lines_arr := map_str.split("\n")
	var expect_rows: int = TextMapRenderer.VIEW_RADIUS * 2 + 1
	var mid: int = TextMapRenderer.VIEW_RADIUS
	# 診斷印（不 assert,避免失敗擋 quit 卡死）
	team.tile_pos = Vector2i(2, 5)   # 另一有效偏離格
	var map_str2 := TextMapRenderer.render(state, 0, cursor)
	var lines2 := map_str2.split("\n")
	var col1: int = lines_arr[mid].find("@") if mid < lines_arr.size() else -1
	var col2: int = lines2[mid].find("@") if mid < lines2.size() else -1
	# 先印診斷（assert 失敗會擋 quit 致 idle 卡死,故先印）
	print("[DIAG] rows=%d (expect %d) mid=%d col1=%d col2=%d count@=%d" % [
		lines_arr.size(), expect_rows, mid, col1, col2, map_str.count("@")])
	# U16 回歸:@ 恆在視窗正中（不論玩家絕對座標）
	assert(lines_arr.size() == expect_rows, "視窗應 %d 列" % expect_rows)
	assert(lines_arr[mid].contains("@"), "@ 應在正中列 %d" % mid)
	assert(not lines_arr[0].contains("@") and not lines_arr[expect_rows-1].contains("@"), "@ 不在邊列")
	assert(map_str.count("@") == 1, "@ 僅一個")
	assert(col1 == col2 and col1 != -1, "換位 @ 仍同欄正中（視窗跟玩家）col1=%d col2=%d" % [col1, col2])
	print("=== ASSERTIONS PASSED === @ 恆在視窗正中 row=%d col=%d" % [mid, col1])
	quit()
