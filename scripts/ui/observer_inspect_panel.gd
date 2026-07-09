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
var _selected: int = -1                          # 選中隊 id，-1 sentinel
var _selected_tile: Vector2i = Vector2i(-1, -1)  # 選中據點格，(-1,-1) sentinel
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
	_selected_tile = Vector2i(-1, -1)   # 互斥：選隊清據點
	_render_detail()
	team_selected.emit(_selected)

# 外部同步（地圖 pick 隊）：選中 + 詳情，不回發 signal（防循環）
func select_team(tid: int) -> void:
	_selected = tid
	_selected_tile = Vector2i(-1, -1)   # 互斥：選隊清據點
	var idx: int = _row_tids.find(tid)
	if idx >= 0:
		_list.select(idx)
		_list.ensure_current_is_visible()
	_render_detail()

# 外部同步（地圖 pick 空格/據點）：切據點詳情，互斥清隊選取
func select_tile(tpos: Vector2i) -> void:
	_selected_tile = tpos
	_selected = -1
	_list.deselect_all()
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
	# 互斥判斷順序固定：據點格 sentinel 優先 → 隊 sentinel → 皆空提示。
	if _selected_tile != Vector2i(-1, -1):
		_render_outpost_detail()
		return
	if _selected == -1:
		_detail.text = "（點地圖或清單選隊；點地圖格看據點）"
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
	lines.append(_resources_line(d.get("resources_nonzero", {}), true))  # skip food/coin（隊已有專屬行）
	_detail.text = "\n".join(lines)

# 非零資源段（skip_food_coin=隊詳情已有專屬行時排除；其餘全露，中文標籤人看得懂）
func _resources_line(res: Dictionary, skip_food_coin: bool) -> String:
	var parts: Array = []
	for k in res:
		if skip_food_coin and (k == "food" or k == "coin"):
			continue
		parts.append("%s %s" % [ObserverQueryApi.res_label(k), _fmt_amount(res[k])])
	if parts.is_empty():
		return "資源持有：（無其他資源）"
	return "資源持有：" + "，".join(parts)

static func _fmt_amount(v) -> String:
	if v is float:
		return "%.0f" % v
	return str(v)

func _render_outpost_detail() -> void:
	var o: Dictionary = _bridge.query_outpost(_selected_tile)
	if o.is_empty():
		_detail.text = "格 (%d,%d)：此格無據點" % [_selected_tile.x, _selected_tile.y]
		return
	var type_zh: String = "民生" if str(o["outpost_type"]) == "civilian" else "軍事"
	var lines: Array = [
		"[b]據點 (%d,%d)[/b]" % [_selected_tile.x, _selected_tile.y],
		"類型：%s  等級：%d" % [type_zh, int(o["outpost_level"])],
		"擁有：%s%s" % [str(o["owner_team"]),
			"（%s）" % str(o["owner_faction"]) if str(o["owner_faction"]) != "" else ""],
		"駐軍：%d 人" % int(o["garrison"]),
		"武器坊等級：%d" % int(o["weaponsmith_level"]),
	]
	lines.append(_resources_line(o.get("resources_nonzero", {}), false))  # 據點含 food(糧倉) 全露
	_detail.text = "\n".join(lines)
