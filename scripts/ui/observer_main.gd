# scripts/ui/observer_main.gd — 觀測 GUI 根（三件：ticker/inspect/速度）。
# 玩家路徑零 diff：main scene 不換，跑法 godot.ps1 res://scenes/ObserverMain.tscn
# 截圖 harness：-- --obs-seed=N --obs-run-months=M --obs-shots=t1,t2 --obs-out=dir
extends Control

const SHOW_PERF_DEBUG := false

const SPEED_LABELS: Array = ["暫停", "1x", "4x", "MAX"]
const SPEED_TPS: Array = [0.0, 240.0, 960.0, -1.0]   # ticks/sec；-1 = 預算內盡量
const UI_REFRESH_SEC: float = 0.25   # 面板/地圖重繪節流（sim 推進不受此限）

var _runner: SimRunner
var _state: WorldState
var _bridge: ObserverBridge
var _speed_idx: int = 0
var _tick_carry: float = 0.0
var _ui_accum: float = 0.0
var _speed_btns: Array = []
var _time_label: Label
var _map: Node2D
var _ticker: ObserverTickerPanel
var _inspect: ObserverInspectPanel
# Task4 hitch 量測
var _hitch_max_ms: float = 0.0
var _hitch_over150: int = 0
var _frames: int = 0
# 截圖 harness（bar 第 5 條依賴）
var _harness: bool = false
var _shots: Array = []        # 升冪 tick
var _shot_idx: int = 0
var _end_tick: int = 0
var _out_dir: String = "."
var _obs_seed: int = 1337
var _capturing: bool = false
var _obs_select: int = -1   # harness：截圖前選中此隊（驗過濾/inspect/同步 path）

func _ready() -> void:
	var args: Dictionary = _parse_obs_args()
	var world_seed: int = int(args.get("obs-seed", 1337))
	seed(world_seed)   # 同 WarringHarness：播 global RNG → 與 headless bed 同流
	_state = WorldState.new()
	_runner = SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/warring_states.json")
	config["seed"] = world_seed
	GameSetup.setup(_state, config)
	_bridge = ObserverBridge.new(_runner, _state)
	_build_ui()
	_refresh_ui()
	print("[Observer] ready seed=%d teams=%d" % [world_seed, _state.teams.size()])
	if args.has("obs-shots") or args.has("obs-run-months"):
		_harness = true
		_obs_seed = world_seed
		_out_dir = String(args.get("obs-out", "."))
		DirAccess.make_dir_recursive_absolute(_out_dir)
		for tok in String(args.get("obs-shots", "")).split(",", false):
			if tok.strip_edges().is_valid_int():
				_shots.append(int(tok.strip_edges()))
		_shots.sort()
		var months: int = int(args.get("obs-run-months", 0))
		_end_tick = months * WorldState.TICKS_PER_MONTH
		if _end_tick == 0 and not _shots.is_empty():
			_end_tick = _shots[-1]
		_obs_select = int(args.get("obs-select", -1))
		_on_speed(3)   # max
		print("[Observer] harness shots=%s end=%d out=%s select=%d" % [
			str(_shots), _end_tick, _out_dir, _obs_select])

func _parse_obs_args() -> Dictionary:
	var out: Dictionary = {}
	for a in OS.get_cmdline_user_args():
		var s: String = a
		if s.begins_with("--"):
			s = s.substr(2)
		var eq: int = s.find("=")
		if eq > 0:
			out[s.substr(0, eq)] = s.substr(eq + 1)
	return out

func _build_ui() -> void:
	_map = load("res://scripts/ui/world_map_view.gd").new()
	_map.name = "MapView"
	add_child(_map)
	_map.setup_observer(_bridge)
	# 頂部速度列
	var top := HBoxContainer.new()
	top.name = "TopBar"
	top.position = Vector2(8, 8)
	add_child(top)
	for i in range(SPEED_LABELS.size()):
		var b := Button.new()
		b.text = SPEED_LABELS[i]
		b.toggle_mode = true
		b.button_pressed = (i == _speed_idx)
		b.pressed.connect(_on_speed.bind(i))
		top.add_child(b)
		_speed_btns.append(b)
	_time_label = Label.new()
	_time_label.text = ""
	top.add_child(_time_label)
	# 右側欄（inspect 上 / ticker 下）
	var right := VBoxContainer.new()
	right.name = "RightPanel"
	right.anchor_left = 1.0
	right.anchor_right = 1.0
	right.anchor_bottom = 1.0
	right.offset_left = -420.0
	right.offset_top = 44.0
	add_child(right)
	_inspect = ObserverInspectPanel.new()
	_inspect.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(_inspect)
	_inspect.setup(_bridge)
	_ticker = ObserverTickerPanel.new()
	_ticker.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(_ticker)
	_ticker.setup(_bridge)
	# 三方同步：map ↔ inspect ↔ ticker filter
	_map.team_picked.connect(func(tid: int):
		_inspect.select_team(tid)
		_ticker.set_filter_team(tid))
	_inspect.team_selected.connect(func(tid: int):
		_map.select_team(tid)
		_ticker.set_filter_team(tid))
	_inspect.follow_toggled.connect(func(on: bool): _map.set_follow(on))

func _on_speed(idx: int) -> void:
	_speed_idx = idx
	_tick_carry = 0.0
	for i in range(_speed_btns.size()):
		_speed_btns[i].button_pressed = (i == idx)

func _process(delta: float) -> void:
	_frames += 1
	var ms: float = delta * 1000.0
	if ms > _hitch_max_ms: _hitch_max_ms = ms
	if ms > 150.0: _hitch_over150 += 1
	if _harness:
		if _capturing:
			return
		_harness_step()
		return
	var tps: float = SPEED_TPS[_speed_idx]
	var did: int = 0
	if tps < 0.0:
		did = _bridge.tick_step(1000000)
	elif tps > 0.0:
		_tick_carry = minf(_tick_carry + tps * delta, tps)   # backlog 上限 1 秒量
		var want: int = int(_tick_carry)
		if want > 0:
			did = _bridge.tick_step(want)
			_tick_carry -= float(did)
	_ui_accum += delta
	if did > 0 and _ui_accum >= UI_REFRESH_SEC:
		_ui_accum = 0.0
		_refresh_ui()

# harness 步進：跑到下一 shot tick（不 overshoot、預算內攤 frame）→ 截圖 → 跑滿 end_tick 印統計 quit
func _harness_step() -> void:
	var now: int = _bridge.current_tick()
	var next_stop: int = _end_tick
	if _shot_idx < _shots.size():
		next_stop = mini(_shots[_shot_idx], _end_tick)
	if now < next_stop:
		_bridge.tick_step(next_stop - now)
		_ui_accum += get_process_delta_time()
		if _ui_accum >= UI_REFRESH_SEC:
			_ui_accum = 0.0
			_refresh_ui()
		return
	if _shot_idx < _shots.size() and now >= _shots[_shot_idx]:
		_capture(_shots[_shot_idx])
		_shot_idx += 1
		return
	if now >= _end_tick:
		print("[Observer] harness done tick=%d frames=%d hitch_max=%.0fms over150=%d" % [
			now, _frames, _hitch_max_ms, _hitch_over150])
		get_tree().quit()

func _capture(tick: int) -> void:
	_capturing = true
	if _obs_select != -1:
		# 走真同步 path（同 inspect team_selected 接線）：map 高亮 + ticker 過濾 + 詳情
		_inspect.select_team(_obs_select)
		_map.select_team(_obs_select)
		_ticker.set_filter_team(_obs_select)
		_ticker.enable_filter(true)
	_refresh_ui()
	await get_tree().process_frame
	await get_tree().process_frame
	var img: Image = get_viewport().get_texture().get_image()
	var path: String = _out_dir.path_join("obs_s%d_t%d.png" % [_obs_seed, tick])
	var err: int = img.save_png(path)
	print("[Observer] shot t=%d → %s (err=%d)" % [tick, path, err])
	_capturing = false

func _refresh_ui() -> void:
	var tick: int = _bridge.current_tick()
	var month: int = tick / WorldState.TICKS_PER_MONTH + 1
	var day: int = (tick % WorldState.TICKS_PER_MONTH) / WorldState.TICKS_PER_DAY + 1
	_time_label.text = "  月%d 日%d（tick %d）" % [month, day, tick]
	if SHOW_PERF_DEBUG:
		_time_label.text += "  hitch max %.0fms" % _hitch_max_ms
	_map.refresh()
	_ticker.poll()
	_inspect.refresh()
