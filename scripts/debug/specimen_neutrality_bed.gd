extends SceneTree
# investigation（純查不改 production）：specimen 非中立性最小重現。
# ★兩段式（長跑被 reap 也不虧）：PERF_CONFIG=A → 無 specimen、逐 tick fp 落檔；
#   PERF_CONFIG=B → specimen 掛 N 隊、逐 tick fp 落檔並與 A 檔比對、印第一個分岔 tick。
# 用法：PERF_SEED=1337 PERF_DAYS=1500 PERF_CONFIG=A ... 然後 PERF_CONFIG=B ...

# ★衛生修：原本硬編某 worktree 絕對路徑（該 worktree 一刪就壞）→ 改走 env（WARRING_OUT，
# godot-detach 白名單內）、預設落 user://（Godot 使用者目錄、與 worktree 生命週期解耦）。
static func _out_a() -> String:
	var p: String = OS.get_environment("WARRING_OUT")
	return p if p != "" else "user://specimen_neutral_A.txt"

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var seed_v: int = int(OS.get_environment("PERF_SEED")) if OS.get_environment("PERF_SEED") != "" else 1337
	var ticks: int = int(OS.get_environment("PERF_DAYS")) if OS.get_environment("PERF_DAYS") != "" else 1500
	var mode: String = OS.get_environment("PERF_CONFIG") if OS.get_environment("PERF_CONFIG") != "" else "A"
	var nspec: int = int(OS.get_environment("LW_MONTHS")) if OS.get_environment("LW_MONTHS") != "" else 7
	print("=== specimen neutrality bed：mode=%s seed=%d ticks=%d nspec=%d ===" % [mode, seed_v, ticks, nspec])
	if mode == "A":
		var fa: Array = _run_pass(seed_v, ticks, [], _out_a())   # ★增量落檔（被 reap 也留 partial）
		print("[bed] A pass done → %s（%d fp）" % [_out_a(), (fa[0] as Array).size()])
		return
	# B pass
	var base: Array = _load(_out_a())
	if base.is_empty():
		print("[bed] ✗ 先跑 A pass（找不到 %s）" % _out_a()); return
	var probe_pass: Array = _run_pass(seed_v, 0, [], "")   # 只 setup 拿 team 清單（零 tick）
	var picks: Array = (probe_pass[1] as Array).slice(0, nspec)
	print("[bed] B pass specimens=%s" % str(picks))
	var fb: Array = _run_pass(seed_v, mini(ticks, base.size()), picks, "")   # B 只跑到 A 有的長度
	var b: Array = fb[0]
	var n: int = mini(base.size(), b.size())
	var first: int = -1
	for i in range(n):
		if base[i] != b[i]:
			first = i; break
	if first == -1:
		print("[bed] ★零分岔（%d tick 內 fp 全同）" % n)
	else:
		print("[bed] ★第一個分岔 tick=%d（A=%s B=%s）" % [first, String(base[first]).substr(0,10), String(b[first]).substr(0,10)])
		for i in range(maxi(first - 2, 0), mini(first + 2, n)):
			print("   tick %d: A=%s B=%s%s" % [i, String(base[i]).substr(0,10), String(b[i]).substr(0,10), "  ←分岔" if base[i] != b[i] else ""])

func _dump(path: String, fps: Array) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null: return
	for x in fps: f.store_line(String(x))
	f.close()

func _load(path: String) -> Array:
	if not FileAccess.file_exists(path): return []
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null: return []
	var out: Array = []
	while not f.eof_reached():
		var l: String = f.get_line()
		if l != "": out.append(l)
	f.close()
	return out

# 回 [fp 陣列, 有 leader 的 team_id 清單]
func _run_pass(seed_v: int, ticks: int, specimens: Array, dump_path: String) -> Array:
	seed(seed_v)
	Probe.enabled = false
	SpecimenTracer.reset()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/warring_states.json")
	config["seed"] = seed_v
	GameSetup.setup(state, config)
	var picks: Array = []
	var keys: Array = state.teams.keys(); keys.sort()
	for tid in keys:
		if state.teams[tid].leader_id != -1: picks.append(tid)
	if not specimens.is_empty():
		var _sp: Array[int] = []
		for _x in specimens: _sp.append(int(_x))
		state.specimen_team_ids = _sp
		SpecimenTracer.enabled = true
	var fps: Array = []
	var no_player := Vector2i(-1, -1)
	var _f: FileAccess = FileAccess.open(dump_path, FileAccess.WRITE) if dump_path != "" else null
	for _t in range(ticks):
		runner.advance_tick(state, no_player)
		var _fp: String = StateFingerprint.compute(state)
		fps.append(_fp)
		if _f != null:
			_f.store_line(_fp)
			if _t % 50 == 0: _f.flush()   # ★每 50 tick flush：長跑被 reap 也留 partial
	if _f != null: _f.close()
	SpecimenTracer.enabled = false
	return [fps, picks]
