extends SceneTree
# @bed-kind: diagnostic
# ★量測員（systems 2026-10-06，確認派錯世界後重派）：Q-raid 窗(team=11,tick 13350-13400)
# 其實屬於「玩家死後」那個分支世界（seed 1337，第3天殺玩家），不是 30 天活玩家那個世界。
# 佈置照 scripts/debug/player_death_7day_specimen.gd 的 PASS C（先推3天、照
# story_end_not_physics_bed.gd:67-73 殺玩家、斷言 game_over==true），只是這次只需要推到
# tick 14400（涵蓋窗尾）就夠，不用推滿7天。
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/q_raid_death_branch_window.gd

const SEED: int = 1337
const WARMUP_DAYS: int = 3
const RUN_TO_TICK: int = 14400   # 涵蓋窗尾 13400 即可


func _initialize() -> void:
	var tree_sha: String = _git_head_sha()
	print("[TREE] HEAD=%s" % tree_sha)
	print("[SEED] %d" % SEED)

	seed(SEED)
	var ws: WorldState = MeasureBedHelper.arm_and_setup("res://config/default.json", false)
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)

	Probe.sample_window["raid.composition"] = {"team": 11, "tick_min": 13350, "tick_max": 13400}

	var day_len: int = WorldState.TICKS_PER_DAY
	for _d in range(WARMUP_DAYS):
		for _i in range(day_len):
			runner.advance_tick(ws, no_player)
	print("[WARMUP] done｜current_tick=%d" % ws.world.current_tick)

	var player_tid: int = ws.get_player_team_id()
	var player_team: TeamData = ws.teams.get(player_tid)
	var pid: int = ws.player_id
	for m in player_team.named_members.duplicate():
		ws.remove_member(player_team, int(m), false)
		if int(m) == pid:
			ws.persons.erase(pid)
	EventSystem.new().handle_player_succession(ws, player_team)
	print("[KILL] game_over=%s" % str(ws.game_over))
	if not ws.game_over:
		print("[HALT] 母體地板沒過，停")
		quit(1)
		return

	var ticks_left: int = RUN_TO_TICK - ws.world.current_tick
	for _i in range(ticks_left):
		runner.advance_tick(ws, no_player)
	print("[RUN] current_tick=%d" % ws.world.current_tick)

	var raid_samples: Array = Probe.samples.get("raid.composition", [])
	var dropped: int = int(Probe.sample_window_dropped.get("raid.composition", 0))
	print("\n[Q-raid] 窗內收到 %d 筆（窗外擋掉 %d 筆）" % [raid_samples.size(), dropped])
	for i in range(raid_samples.size()):
		var row: Dictionary = raid_samples[i]
		print("  #%d｜tick=%s｜team=%s｜原始util(drive)=%s｜需求層加權後=%s｜人格調製後=%s｜最終合成=%s" % [
			i, str(row.get("tick", "?")), str(row.get("team", "?")),
			str(row.get("drive", "?")), str(row.get("after_weight", "?")),
			str(row.get("after_coeff", "?")), str(row.get("final", "?"))])

	var out_path: String = "docs/measurements/q-raid-death-branch-team11.jsonl"
	var f: FileAccess = FileAccess.open(out_path, FileAccess.WRITE)
	f.store_line(JSON.stringify({"kind": "meta", "tree": tree_sha, "seed": SEED, "dropped": dropped}))
	for row in raid_samples:
		f.store_line(JSON.stringify({"kind": "Q_raid", "row": row}))
	f.close()
	print("\n[DUMP-PATH] %s" % out_path)
	print("=== q_raid_death_branch_window DONE ===")
	quit(0)


func _git_head_sha() -> String:
	var out: Array = []
	OS.execute("git", ["rev-parse", "--short=9", "HEAD"], out, true)
	if out.size() > 0:
		return String(out[0]).strip_edges()
	return "UNKNOWN"
