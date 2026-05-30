# scripts/ui/turn_controls.gd
extends HBoxContainer

const TICKS_PER_SECOND: int = 4   # TEST VALUE — world ticks rendered per second
const SKIP_OPTIONS: Array   = [10, 50, 100]

var _bridge: SimBridge
var _advancing: bool  = false
var _target_n: int    = 0
var _ticked_n: int    = 0
var _timer: float     = 0.0
var _tick_interval: float = 1.0 / TICKS_PER_SECOND

signal tick_advanced(events: Array)
signal advance_stopped()

func setup(bridge: SimBridge) -> void:
	_bridge = bridge
	_build_ui()

func _build_ui() -> void:
	var btn_end := Button.new()
	btn_end.text = "結束回合"
	btn_end.pressed.connect(_on_end_turn)
	add_child(btn_end)

	var skip_opt := OptionButton.new()
	skip_opt.add_item("跳 10")
	skip_opt.add_item("跳 50")
	skip_opt.add_item("跳 100")
	skip_opt.item_selected.connect(_on_skip_selected)
	add_child(skip_opt)

	var btn_wait := Button.new()
	btn_wait.text = "等待事件"
	btn_wait.pressed.connect(_on_wait_event)
	add_child(btn_wait)

func _on_end_turn() -> void:
	if _advancing:
		_stop()
	else:
		_start(SimBridge.TICKS_PER_TURN)

func _on_skip_selected(idx: int) -> void:
	_start(SKIP_OPTIONS[idx])

func _on_wait_event() -> void:
	if _advancing:
		_stop()
	else:
		_start(99999)

func _start(n: int) -> void:
	_target_n  = n
	_ticked_n  = 0
	_advancing = true
	_timer     = 0.0

func _stop() -> void:
	_advancing = false
	advance_stopped.emit()

func _process(delta: float) -> void:
	if not _advancing or _bridge == null: return
	_timer += delta
	while _timer >= _tick_interval and _advancing:
		_timer -= _tick_interval
		var events: Array = _bridge.advance_ticks(1)
		_ticked_n += 1
		tick_advanced.emit(events)
		if events.size() > 0 or _ticked_n >= _target_n:
			_stop()
			return

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		if _advancing:
			_stop()
