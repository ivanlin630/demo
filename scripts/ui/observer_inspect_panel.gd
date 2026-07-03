# scripts/ui/observer_inspect_panel.gd — 隊伍 inspect（三件之一）。
# 全隊清單（一行摘要）→ 點選詳情；與地圖 click pick 雙向同步。read-only。
extends VBoxContainer
class_name ObserverInspectPanel

signal team_selected(tid: int)
signal follow_toggled(on: bool)

var _bridge: ObserverBridge
var _list: ItemList
var _detail: RichTextLabel
var _follow_btn: CheckBox
var _selected: int = -1
var _row_tids: Array = []

func setup(bridge: ObserverBridge) -> void:
	_bridge = bridge
	var head := HBoxContainer.new()
	var title := Label.new()
	title.text = "隊伍"
	head.add_child(title)
	_follow_btn = CheckBox.new()
	_follow_btn.text = "鏡頭跟隨"
	_follow_btn.toggled.connect(func(on): follow_toggled.emit(on))
	head.add_child(_follow_btn)
	add_child(head)
	_list = ItemList.new()
	_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_list.item_selected.connect(_on_row)
	add_child(_list)
	_detail = RichTextLabel.new()
	_detail.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_detail.fit_content = false
	_detail.bbcode_enabled = true
	add_child(_detail)
	refresh()

func _on_row(idx: int) -> void:
	if idx < 0 or idx >= _row_tids.size():
		return
	_selected = _row_tids[idx]
	_render_detail()
	team_selected.emit(_selected)

# 外部同步（地圖 pick）：選中 + 詳情，不回發 signal（防循環）
func select_team(tid: int) -> void:
	_selected = tid
	var idx: int = _row_tids.find(tid)
	if idx >= 0:
		_list.select(idx)
		_list.ensure_current_is_visible()
	_render_detail()

func refresh() -> void:
	var rows: Array = _bridge.query_all_teams()
	_list.clear()
	_row_tids.clear()
	for r in rows:
		if r.get("is_beast", false):
			continue
		_row_tids.append(int(r["id"]))
		_list.add_item("%s  %d人 階%d %s" % [r["label"], int(r["pop"]), int(r["rung"]), str(r["task"])])
	var idx: int = _row_tids.find(_selected)
	if idx >= 0:
		_list.select(idx)
	_render_detail()

func _render_detail() -> void:
	if _selected == -1:
		_detail.text = "（點地圖或清單選隊）"
		return
	var d: Dictionary = _bridge.query_team(_selected)
	if d.is_empty():
		_detail.text = "（隊%d 已不存在）" % _selected
		return
	var lines: Array = [
		"[b]%s[/b]" % d["label"],
		"領袖：%s" % d["leader_name"],
		"人口：%d（記名%d／匿名%d／未成年%d／俘虜%d）" % [
			int(d["pop"]), int(d["pop_named"]), int(d["pop_anon"]),
			int(d["pop_minor"]), int(d["pop_captive"])],
		"糧食：%.0f（日流 %+.1f）  錢：%d" % [float(d["food"]), float(d["food_flow"]), int(d["coin"])],
		"野心：階%d／上限%d（%s）" % [int(d["rung"]), int(d["rung_cap"]),
			str(d["archetype"]) if str(d["archetype"]) != "" else "未定"],
		"勢力：%s" % (str(d["faction"]) if str(d["faction"]) != "" else "（獨立）"),
		"任務：%s（%s）" % [str(d["task"]),
			str(d["task_reason"]) if str(d["task_reason"]) != "" else "—"],
		"戰略意圖：%s" % (str(d["solo_intent"]) if str(d["solo_intent"]) != "" else "（無）"),
		"戰備：%.2f  疲勞：%.2f  傷兵：%d" % [float(d["readiness"]), float(d["fatigue"]), int(d["wounded"])],
		"位置：(%d,%d)" % [d["tile_pos"].x, d["tile_pos"].y],
	]
	_detail.text = "\n".join(lines)
