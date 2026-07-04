# scripts/ui/observer_ticker_panel.gd — 事件 ticker（三件之一）。
# 吃 bridge.consume_messages 全量增量；人話 formatter；隊過濾；歷史 500 條。
extends VBoxContainer
class_name ObserverTickerPanel

const MAX_ENTRIES: int = 500

var _bridge: ObserverBridge
var _since_tick: int = -1
var _entries: Array = []   # {text: String, teams: Array, type: String}
var _filter_tid: int = -1
var _filter_check: CheckBox
var _hide_orders_check: CheckBox
var _log: RichTextLabel

func setup(bridge: ObserverBridge) -> void:
	_bridge = bridge
	var head := HBoxContainer.new()
	var title := Label.new()
	title.text = "事件"
	head.add_child(title)
	_filter_check = CheckBox.new()
	_filter_check.text = "只看選中隊"
	_filter_check.disabled = true
	_filter_check.toggled.connect(func(_on): _render())
	head.add_child(_filter_check)
	_hide_orders_check = CheckBox.new()
	_hide_orders_check.text = "隱藏訂單"
	_hide_orders_check.button_pressed = true
	_hide_orders_check.toggled.connect(func(_on): _render())
	head.add_child(_hide_orders_check)
	add_child(head)
	_log = RichTextLabel.new()
	_log.scroll_following = true
	_log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_log.fit_content = false
	add_child(_log)

# 過濾開關（等同勾「只看選中隊」；harness 截圖驗證用同一 path）
func enable_filter(on: bool) -> void:
	if _filter_tid != -1:
		_filter_check.button_pressed = on
	_render()

# 選中隊變更（inspect/地圖同步呼）。tid=-1 清除。
func set_filter_team(tid: int) -> void:
	_filter_tid = tid
	_filter_check.disabled = (tid == -1)
	if tid == -1:
		_filter_check.button_pressed = false
	_render()

func poll() -> void:
	var state: WorldState = _bridge.get_state()
	var fresh: Array = _bridge.consume_messages(_since_tick)
	_since_tick = _bridge.current_tick()
	if fresh.is_empty():
		return
	for msg in fresh:
		_entries.append({
			"text": ObserverEventText.render(state, msg),
			"teams": ObserverEventText.related_teams(msg),
			"type": String(msg.type),
		})
	if _entries.size() > MAX_ENTRIES:
		_entries = _entries.slice(_entries.size() - MAX_ENTRIES)
	_render()

func _render() -> void:
	var lines: Array = []
	var filtering: bool = _filter_check.button_pressed and _filter_tid != -1
	var hide_orders: bool = _hide_orders_check.button_pressed
	for e in _entries:
		if filtering and not (e["teams"] as Array).has(_filter_tid):
			continue
		if hide_orders and e.get("type", "") in ["order_buy", "order_sell"]:
			continue
		lines.append(e["text"])
	_log.text = "\n".join(lines)
