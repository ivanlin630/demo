extends SceneTree
# 暫用（不 commit）：同 world_fp_snapshot_bed 的世界，每 500 tick 印逐域指紋，終局寫全 canon
func _init() -> void:
	var out: String = OS.get_environment("DUMP_OUT")
	seed(20260922)
	var st := WorldState.new()
	GameSetup.setup(st, GameSetup.load_config("res://config/warring_states.json"))
	st.player_id = -1
	var runner := SimRunner.new()
	var stop_at: int = int(OS.get_environment("DUMP_STOP")) if OS.has_environment("DUMP_STOP") else 20000
	for t in range(stop_at):
		runner.advance_tick(st, Vector2i(-1, -1))
		if (t + 1) % 500 == 0:
			print("[DOM] %d %s" % [t + 1, str(StateFingerprint.compute_domains(st))])
	var buf := PackedStringArray()
	StateFingerprint._emit_teams(st, buf); StateFingerprint._emit_persons(st, buf)
	StateFingerprint._emit_factions(st, buf); StateFingerprint._emit_belief(st, buf)
	StateFingerprint._emit_tiles(st, buf); StateFingerprint._emit_world(st, buf)
	StateFingerprint._emit_player(st, buf)
	var f := FileAccess.open(out, FileAccess.WRITE)
	f.store_string("\n".join(buf)); f.close()
	print("DUMP_DONE")
	quit(0)
