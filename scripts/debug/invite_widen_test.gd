extends SceneTree

# slice A2 TDD：拓寬 invite 候選（_try_invite_nearby_exile filter）。passed-filter→reach diplomacy→invite_cooldown set；filtered→no cooldown。

var _fail: int = 0
func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else: _fail += 1; print("  [FAIL] %s" % m)

# 建 lord(有空 outpost)+ 一候選團(tags/task/parent 依參)。回 [state, lord, tile, cand_id]。
func _mk(cand_tags: Array, cand_task: String, cand_combat: int, cand_parent: int) -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100000
	var lord := TeamData.new(); lord.team_id = 1; lord.faction_id = 0; lord.tile_pos = Vector2i(5,5)
	var llp := PersonData.new(); llp.id = 11; state.persons[11] = llp; lord.leader_id = 11
	state.teams[1] = lord
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(5,5); tile.terrain = "plains"; tile.outpost_level = 1; tile.outpost_owner = 1
	state.world.tiles[5005] = tile
	var cand := TeamData.new(); cand.team_id = 2; cand.faction_id = -1; cand.tile_pos = Vector2i(6,5)
	cand.tags = cand_tags; cand.current_task = cand_task; cand.combat_target = cand_combat; cand.parent_team_id = cand_parent
	AnonCohort.add(cand.anon_cohorts, "平民", "healthy", 4)
	var clp := PersonData.new(); clp.id = 22; clp.values = {}; state.persons[22] = clp; cand.leader_id = 22
	state.teams[2] = cand
	state.team_discovered[1] = [2]
	BeliefSystem.record_claim(state, 1, 2, 1, "親見", {"tile_pos": Vector2i(6,5)}, 1.0, false)
	return [state, lord, tile, 2]

func _reached(cand_tags: Array, cand_task: String = TeamData.TASK_IDLE, cand_combat: int = -1, cand_parent: int = -1) -> bool:
	var a := _mk(cand_tags, cand_task, cand_combat, cand_parent)
	FactionAISystem.new()._try_invite_nearby_exile(a[0], a[1], a[2])
	return (a[1] as TeamData).invite_cooldown.has(a[3])   # cooldown set = 過 filter 到 diplomacy

func _initialize() -> void:
	print("=== A2 拓寬 invite 候選 filter ===")
	# ①現況流亡 team 邀得到（regression）。
	_ok(_reached(["流亡"]), "①流亡 wanderer 邀得到（regression、過 filter 到 diplomacy）")
	# ②非生產非戰鬥遊蕩 wanderer（no PRODUCE/no combat、含 idle merchant）現在邀得到（新）。
	_ok(_reached([]), "②非生產非戰鬥遊蕩團(無 tag)邀得到（★A2 新拓寬）")
	_ok(_reached([TeamData.TAG_MERCHANT]), "②idle merchant drifter 邀得到（★A2 新拓寬）")
	# ③戰鬥中 war-band 不被邀（語意排除）。
	_ok(not _reached([], TeamData.TASK_IDLE, 99), "③戰鬥中(combat_target≠-1)war-band 不被邀（語意排除）")
	_ok(not _reached([], TeamData.TASK_ATTACK), "③攻擊掠奪中(task=攻擊)不被邀（active raider 排除）")
	# ④生產隊 / 子隊不被邀。
	_ok(not _reached([TeamData.TAG_PRODUCE]), "④生產隊不被邀（已 settled）")
	_ok(not _reached([], TeamData.TASK_IDLE, -1, 5), "④子隊(parent_team_id≠-1)不被邀")

	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()
