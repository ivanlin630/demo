# scripts/ui/observer_main.gd — 觀測 GUI 根（三件：ticker/inspect/速度）。
# 玩家路徑零 diff：main scene 不換，跑法 godot.ps1 res://scenes/ObserverMain.tscn
# 截圖 harness：-- --obs-seed=N --obs-run-months=M --obs-shots=t1,t2 --obs-out=dir
extends Control

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
# Task4 hitch 量測
var _hitch_max_ms: float = 0.0
var _hitch_over150: int = 0
var _frames: int = 0

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

func _refresh_ui() -> void:
	var tick: int = _bridge.current_tick()
	var month: int = tick / WorldState.TICKS_PER_MONTH + 1
	var day: int = (tick % WorldState.TICKS_PER_MONTH) / WorldState.TICKS_PER_DAY + 1
	_time_label.text = "  月%d 日%d（tick %d）  hitch max %.0fms" % [month, day, tick, _hitch_max_ms]
	_map.refresh()
