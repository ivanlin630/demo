extends SceneTree
# @bed-kind: diagnostic
# P6d（spec 2026-10-13-terminal-input-prompts-and-threat-clip 第二刀）：派遣六項任務在「腳下」與「一格外」各派一次、推 1 天，
#   記子隊實際做了什麼（task 變化序列、位置、隊上糧、有沒有建東西）⇒ 腳下有沒有【靜默空轉】的任務（前提由 systems 定）
#   ★誠實限：一個種子、一支派遣隊；遭遇以 draw 結束；「產出」只看隊上糧與腳下據點／營地等級變化
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/dispatch_task_at_foot_census.gd

const SEED: int = 1337


func _initialize() -> void:
	print("=== dispatch_task_at_foot_census：六項任務 × 腳下／一格外，推 1 天 ===")
	for t in PlayerCommandSystem.ORDERABLE_TASKS:
		for where in ["腳下", "一格外"]:
			_run(String(t[0]), String(t[1]), where)
	print("=== dispatch_task_at_foot_census DONE ===")
	quit(0)


func _run(task: String, label: String, where: String) -> void:
	seed(SEED)
	var st := WorldState.new()
	GameSetup.setup(st, GameSetup.load_config("res://config/default.json"))
	var ptid: int = st.get_player_team_id()
	var pt: TeamData = st.teams[ptid]
	var tgt: Vector2i = pt.tile_pos if where == "腳下" else pt.tile_pos + Vector2i(1, 0)
	var leader: int = -1
	for pid in pt.named_members:
		if pid != pt.leader_id:
			leader = pid
			break
	st.player_state["sub_leader_id"] = leader
	st.player_state["sub_pop_count"] = 2
	st.player_state["sub_task"] = task
	st.player_state["sub_move_q"] = tgt.x
	st.player_state["sub_move_r"] = tgt.y
	var r: Dictionary = PlayerCommandSystem.new().execute_action(st, -1, "dispatch_subteam")
	var sid: int = int(r.get("sub_id", -1))
	if sid == -1:
		print("   %s｜%s：派不出去（%s）" % [label, where, String(r.get("msg", ""))])
		return
	var sub: TeamData = st.teams[sid]
	var tasks: Array = [sub.current_task]
	var food0: float = float(sub.resources.get("food", 0.0))
	var t_tile: HexTileData = st.world.tiles.get(tgt.x * 1000 + tgt.y)
	var camp0: int = t_tile.camp_level if t_tile else -1
	var op0: int = t_tile.outpost_level if t_tile else -1
	var runner := SimRunner.new()
	var moved: int = 0
	var last_pos: Vector2i = sub.tile_pos
	for i in range(WorldState.TICKS_PER_DAY):
		var p: TeamData = st.teams.get(st.get_player_team_id())
		runner.advance_tick(st, p.tile_pos if p != null else Vector2i(-1, -1))
		if st.encounter_active:
			runner._encounter_system.resolve_encounter_end(st, "draw")
		if not st.teams.has(sid):
			tasks.append("（併回／消失）")
			break
		sub = st.teams[sid]
		if sub.current_task != String(tasks[tasks.size() - 1]):
			tasks.append(sub.current_task)
		if sub.tile_pos != last_pos:
			moved += 1
			last_pos = sub.tile_pos
	var alive: bool = st.teams.has(sid)
	var food1: float = float(sub.resources.get("food", 0.0)) if alive else -1.0
	var camp1: int = t_tile.camp_level if t_tile else -1
	var op1: int = t_tile.outpost_level if t_tile else -1
	print("   %-4s｜%-3s｜task 序列 %s｜移動 %d 步｜糧 %.1f→%.1f｜目標格 營地 %d→%d 據點 %d→%d" % [label, where,
		str(tasks), moved, food0, food1, camp0, camp1, op0, op1])
