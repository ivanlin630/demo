extends SceneTree
# @observe-pure
# ★★★A#27 step A：把 `disband_faction` 的直寫導回 `set_team_faction` 之後，★世界有沒有變。
#   systems 判準：fp 逐位元不變 ⇒ 收工；★★fp 變了 ⇒ 停下來報，【不要抹平】
#   （fp 變＝那兩條路本來就不等價，而那個不等價本身是發現）。
# ★三把尺都印（fp 只看決策/生命週期那半；ephemeral 看快取；full 反射掃全屬性）。

func _mk(state: WorldState, tid: int, pos: Vector2i) -> TeamData:
	var t := HexTileData.new()
	t.tile_id = pos.x * 1000 + pos.y; t.tile_pos = pos; t.terrain = "plains"
	t.outpost_owner = -1; t.outpost_level = 0
	state.world.tiles[t.tile_id] = t
	var ldr := PersonData.new(); ldr.id = tid * 100 + 1; ldr.team_id = tid
	ldr.values = {"好戰": 0.4, "野心": 0.5}
	ldr.skills = {"統領": 0.3 + 0.1 * float(tid)}
	state.persons[ldr.id] = ldr
	var team := TeamData.new(); team.team_id = tid; team.leader_id = ldr.id
	team.tile_pos = pos; team.current_task = TeamData.TASK_IDLE
	state.teams[tid] = team
	state.add_member(team, ldr.id)
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", 5)
	team.resources = {"food": 120.0}
	return team

func _init() -> void:
	print("=== A#27 step A：disband_faction routing 的 fp 影響 ===")
	var state := MeasureBedHelper.arm_and_new()
	seed(1337)
	for i in range(4):
		_mk(state, i, Vector2i(3 + i * 2, 5))
	var fid: int = state.create_faction(0)
	for i in [1, 2, 3]:
		state.set_team_faction(state.teams[i], fid)
	print("  解散前：faction %d 成員 = %s" % [fid, str(state.factions[fid].member_team_ids)])
	state.disband_faction(fid)
	var left: Array = []
	for i in range(4):
		left.append(int(state.teams[i].faction_id))
	print("  解散後：★每隊 faction_id = %s（期望全 -1）｜factions 還在嗎 = %s"
		% [str(left), str(state.factions.has(fid))])
	print("  fp   = %s" % StateFingerprint.compute(state))
	print("  eph  = %s" % EphemeralStateHash.compute(state))
	print("  full = %s" % FullStateHash.compute(state))
	print("★讀法：把本輸出與【routing 前】的同一份逐行比 —— 三個 hash 全同 ⇒ 兩條路等價")
	quit()
