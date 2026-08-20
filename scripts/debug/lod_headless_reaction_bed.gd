extends SceneTree
# ★gate②：無玩家 headless（player_pos=(-1,-1)＝全隊 far）走真 SimRunner.advance_tick，
# 個體反應層是否真的跑到（修前：reactions 是 LOD_NEAR → 全隊 far ⇒ 全世界零個體反應、
# breedgate.calls=0、minor_population 全 0）。合成世界給足生育前提，跑短窗即可判有/無。

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	print("=== LOD headless reaction bed（無玩家、全隊 far）===")
	seed(1337)
	Probe.enabled = true; Probe.reset()
	var s := WorldState.new(); s.world = WorldData.new(); s.player_id = -1
	for x in range(0, 4):
		var t := HexTileData.new(); t.tile_id = x*1000; t.tile_pos = Vector2i(x,0); t.terrain = "plains"
		t.resources = {"food": 300.0, "material": 100.0}
		t.resource_cap = {"food": 400.0, "material": 200.0}
		t.outpost_level = 1 if x == 1 else 0
		t.outpost_type = "civilian"
		s.world.tiles[t.tile_id] = t
	var team := TeamData.new(); team.team_id = 1; team.tile_pos = Vector2i(1,0); team.faction_id = -1
	team.tags = [TeamData.TAG_PRODUCE]
	team.resources = {"food": 400.0}
	team.food_flow_avg = 5.0
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", 40)
	team.anon_female_ratio = 0.5
	s.teams[1] = team
	s.world.tiles[1000].outpost_owner = 1
	for i in range(4):
		var p := PersonData.new(); p.id = 50 + i; p.team_id = 1
		p.sex = "男" if i % 2 == 0 else "女"
		p.needs = {"safety": 0.95, "food": 0.95}
		p.loyalty = 0.9; p.stress = 0.05
		p.skills = {"統領": 0.6}
		s.persons[p.id] = p
		team.named_members.append(p.id)
	team.leader_id = team.named_members[0]
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)   # ★無玩家＝全隊 far（修前這條路完全不跑個體反應）
	for _t in range(600):
		runner.advance_tick(s, no_player)
		team.food_flow_avg = 5.0   # 維持盈餘前提（避免採集波動把生育前提洗掉；只動這個測試前提值）
	var breed: int = int(Probe.counts.get("reaction.breed", 0))
	print("[bed] reaction.breed=%d minor_population=%d pop=%d" % [breed, team.minor_population, team.population])
	if breed > 0 and team.minor_population > 0:
		print("[bed] ★PASS 無玩家 headless 下遠隊個體反應真的跑（修前為 0）")
	else:
		print("[bed] ✗FAIL 仍為 0 → 個體反應層沒接到 far pass")
	Probe.enabled = false
	print("=== bed DONE ===")
