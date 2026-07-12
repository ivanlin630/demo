# scripts/ui/observer_inspect_panel.gd — 隊伍 inspect（三件之一）。
# 全隊清單（一行摘要）→ 點選詳情；與地圖 click pick 雙向同步。read-only。
extends VBoxContainer
class_name ObserverInspectPanel

signal team_selected(tid: int)
signal follow_toggled(on: bool)

var _bridge: ObserverBridge
var _list: ItemList
var _outpost_list: ItemList
var _detail: RichTextLabel
var _follow_btn: CheckBox
var _selected: int = -1                          # 選中隊 id，-1 sentinel
var _selected_tile: Vector2i = Vector2i(-1, -1)  # 選中據點格，(-1,-1) sentinel
var _row_tids: Array = []
var _outpost_rows: Array = []                    # 據點列表各行 tile_pos（Vector2i）

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
	var op_title := Label.new()
	op_title.text = "據點"
	add_child(op_title)
	_outpost_list = ItemList.new()
	_outpost_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_outpost_list.item_selected.connect(_on_outpost_row)
	add_child(_outpost_list)
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
	_outpost_list.deselect_all()
	_render_detail()
	team_selected.emit(_selected)

# 據點列表點選 → 走既有據點詳情路（select_tile）
func _on_outpost_row(idx: int) -> void:
	if idx < 0 or idx >= _outpost_rows.size():
		return
	select_tile(_outpost_rows[idx])

# 外部同步（地圖 pick 隊）：選中 + 詳情，不回發 signal（防循環）
func select_team(tid: int) -> void:
	_selected = tid
	_selected_tile = Vector2i(-1, -1)   # 互斥：選隊清據點
	_outpost_list.deselect_all()
	var idx: int = _row_tids.find(tid)
	if idx >= 0:
		_list.select(idx)
		_list.ensure_current_is_visible()
	_render_detail()

# 外部同步（地圖 pick 空格/據點 or 據點列表）：切據點詳情，互斥清隊選取
func select_tile(tpos: Vector2i) -> void:
	_selected_tile = tpos
	_selected = -1
	_list.deselect_all()
	var oidx: int = _outpost_rows.find(tpos)
	if oidx >= 0:
		_outpost_list.select(oidx)
		_outpost_list.ensure_current_is_visible()
	else:
		_outpost_list.deselect_all()
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
	# 據點列表（並存，互斥 sentinel 不干擾）
	var ops: Array = _bridge.query_all_outposts()
	_outpost_list.clear()
	_outpost_rows.clear()
	for o in ops:
		var tp: Vector2i = o["tile_pos"]
		_outpost_rows.append(tp)
		var type_zh: String = "民生" if str(o["outpost_type"]) == "civilian" else "軍事"
		_outpost_list.add_item("(%d,%d) %sLv%d %s 設施%d" % [
			tp.x, tp.y, type_zh, int(o["outpost_level"]),
			str(o["owner_team"]), int(o["facility_count"])])
	var oidx: int = _outpost_rows.find(_selected_tile)
	if oidx >= 0:
		_outpost_list.select(oidx)
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
		"計畫：%s" % (str(d.get("plan_phase", "")) if str(d.get("plan_phase", "")) != "" else "（無）"),
		"勢力：%s" % (str(d["faction"]) if str(d["faction"]) != "" else "（獨立）"),
		"任務：%s（%s）" % [str(d["task"]),
			str(d["task_reason"]) if str(d["task_reason"]) != "" else "—"],
		"戰略意圖：%s" % (str(d["solo_intent"]) if str(d["solo_intent"]) != "" else "（無）"),
		"戰備：%.2f  疲勞：%.2f  傷兵：%d" % [float(d["readiness"]), float(d["fatigue"]), int(d["wounded"])],
		"位置：(%d,%d)" % [d["tile_pos"].x, d["tile_pos"].y],
	]
	lines.append(_resources_line(d.get("resources_nonzero", {}), true))  # skip food/coin（隊已有專屬行）
	# 該隊駐守格若有據點 → 附據點段（多數據點被 owner 駐隊佔 → 方塊點擊落隊,據點靠此露）。
	var op: Dictionary = _bridge.query_outpost(d["tile_pos"])
	if not op.is_empty():
		lines.append("─ 駐守據點 ─")
		lines.append_array(_outpost_lines(op))
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

# 據點詳情行（無 header，供 select_tile 直選 + team 詳情附段共用）
func _outpost_lines(o: Dictionary) -> Array:
	var type_zh: String = "民生" if str(o["outpost_type"]) == "civilian" else "軍事"
	var lines: Array = [
		"類型：%s  等級：%d" % [type_zh, int(o["outpost_level"])],
		"擁有：%s%s" % [str(o["owner_team"]),
			"（%s）" % str(o["owner_faction"]) if str(o["owner_faction"]) != "" else ""],
		"駐軍：%d 人" % int(o["garrison"]),
		_facilities_line(o.get("facilities_nonzero", {})),
	]
	lines.append(_resources_line(o.get("resources_nonzero", {}), false))  # 據點含 food(糧倉) 全露
	return lines

# 設施段（非零全出，中文標籤；空則「（無設施）」）
func _facilities_line(fac: Dictionary) -> String:
	var parts: Array = []
	for k in fac:
		parts.append("%sLv%d" % [ObserverQueryApi.facility_label(k), int(fac[k])])
	if parts.is_empty():
		return "設施：（無設施）"
	return "設施：" + " ".join(parts)

func _render_outpost_detail() -> void:
	var o: Dictionary = _bridge.query_outpost(_selected_tile)
	if o.is_empty():
		_detail.text = "格 (%d,%d)：此格無據點" % [_selected_tile.x, _selected_tile.y]
		return
	var lines: Array = ["[b]據點 (%d,%d)[/b]" % [_selected_tile.x, _selected_tile.y]]
	lines.append_array(_outpost_lines(o))
	_detail.text = "\n".join(lines)
