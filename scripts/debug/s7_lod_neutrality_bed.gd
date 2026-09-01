extends SceneTree

# ★★★S7 LOD產出中性性驗證床(measurer側,純觀測,零production改動)。
#   同一座工坊、同一組人、同一份配方——一組near一組far，比每日【真實產出量】
#   (manufacture.output.<res>，不是runs_per_day()估算函式)。
#
# 用法：LOD_MODE=near|far BED_DAYS=30 godot --script scripts/debug/s7_lod_neutrality_bed.gd
#   near: player_pos=團隊位置(距離0，落在LOD_NEAR_RADIUS內)
#   far:  player_pos=極遠處(超過LOD_NEAR_RADIUS)

func _mk() -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 0
	for x in range(0, 12):
		for y in range(0, 12):
			var tl := HexTileData.new(); tl.tile_pos = Vector2i(x, y); tl.terrain = "plains"
			state.world.tiles[x * 1000 + y] = tl
	var team := TeamData.new()
	team.team_id = 1
	team.tile_pos = Vector2i(5, 5)
	team.faction_id = -1
	team.tags = ["生產"]
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", 10)
	var l := PersonData.new()
	l.id = 10
	l.team_id = 1
	l.values = {"好戰": 0.3, "貪婪": 0.3, "慎重": 0.5, "野心": 0.3, "義氣": 0.5}
	l.skills = {"生產": 0.5, "統領": 0.5}
	state.persons[10] = l
	team.leader_id = 10
	state.teams[1] = team
	var tile: HexTileData = state.world.tiles[5 * 1000 + 5]
	tile.outpost_owner = 1
	tile.outpost_type = "civilian"
	tile.outpost_level = 2
	tile.manufacturing_level = 2   # ★工坊(workshop)直接手動已建成，繞開organic build-up的世界軌跡差異
	# ★材料塞爆量：確保material/food永遠不是瓶頸——這輪要測的是LOD頻率不是料夠不夠
	#   ★血證：第一版忘了塞food，團隊活活餓死+spawn子隊also餓死，30日窗中途崩潰，數字不可信
	team.resources["food"] = 1000000.0
	team.resources["material"] = 1000000.0
	team.resources["horses"] = 1000000.0
	team.resources["tools"] = 1000000.0
	team.resources["gem"] = 1000000.0
	return [state, team]

func _initialize() -> void:
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 30
	var mode: String = OS.get_environment("LOD_MODE") if OS.has_environment("LOD_MODE") else "near"
	seed(1337)
	Probe.reset()
	Probe.enabled = true
	var w: Array = _mk()
	var state: WorldState = w[0]
	var team: TeamData = w[1]
	var player_pos: Vector2i = team.tile_pos if mode == "near" else Vector2i(team.tile_pos.x + 100, team.tile_pos.y + 100)
	var runner := SimRunner.new()
	var ticks: int = days * WorldState.TICKS_PER_DAY
	for _t in range(ticks):
		runner.advance_tick(state, player_pos)

	print("=== s7_lod_neutrality_bed === mode=%s days=%d ticks=%d player_pos=%s team_pos=%s"
		% [mode, days, ticks, str(player_pos), str(team.tile_pos)])
	print("母體：population=%d｜manufacturing_level=%d｜material剩餘=%.1f"
		% [team.population, (state.world.tiles[5 * 1000 + 5] as HexTileData).manufacturing_level,
		   float(team.resources.get("material", 0))])
	print("── manufacture.output.* 原始總量+每日 ──")
	var any_output: bool = false
	for k in Probe.amounts:
		var ks: String = String(k)
		if ks.begins_with("manufacture.output."):
			any_output = true
			var total: float = float(Probe.amounts[k])
			print("  %-30s 總量=%.4f  每日=%.4f" % [ks, total, total / float(days)])
	if not any_output:
		print("  ★沒有任何manufacture.output.*——這件事本輪從未發生(Probe是ON)")
	print("── 輔助診斷(manufacture三桶，看是no_facility/no_material/fired哪一種) ──")
	for name in ["fired", "noop_no_outpost", "noop_no_worker", "noop_no_facility", "noop_no_material"]:
		var total2: int = int(Probe.counts.get("manufacture." + name, 0))
		print("  %-20s 總數=%d" % [name, total2])
	print("=== s7_lod_neutrality_bed DONE ===")
	quit()
