# scripts/ui/text_ui_main.gd
extends Node
class_name TextUiMain

var _runner: SimRunner
var _bridge: SimBridge

# Q7-5: 子隊派遣可選任務（合理子集；command 介面不變,已支援任意 sub_task）。
# 每項 [任務常數, 顯示名]。1=idle 為預設。
const SUBTEAM_TASK_CHOICES: Array = [
	[TeamData.TASK_IDLE,   "待機"],
	[TeamData.TASK_FORAGE, "覓食"],
	[TeamData.TASK_SETTLE, "安頓"],
	[TeamData.TASK_PATROL, "巡邏"],
	[TeamData.TASK_BUILD,  "建設"],
	[TeamData.TASK_SCOUT,  "偵查"],
]

# Q7-5: 子隊任務選單組字（static → 可單元測）。回傳如「1)待機 2)覓食 …」
static func _subteam_task_menu_str() -> String:
	var parts: Array = []
	for i in range(SUBTEAM_TASK_CHOICES.size()):
		parts.append("%d)%s" % [i + 1, SUBTEAM_TASK_CHOICES[i][1]])
	return "  ".join(parts)

# Q7-5: 由選單編號（1-based）取 task 常數；越界 → idle。
static func _subteam_task_from_index(idx_1based: int) -> String:
	var i: int = idx_1based - 1
	if i < 0 or i >= SUBTEAM_TASK_CHOICES.size():
		return TeamData.TASK_IDLE
	return SUBTEAM_TASK_CHOICES[i][0]

var _cursor: Vector2i = Vector2i(4, 4)
var _selected: Vector2i = Vector2i(-1, -1)
var _player_tid: int = 0
var _events: Array = []

var _input_mode: bool   = false
var _input_buffer: String = ""
var _input_mode_type: String = "numeric"   # "numeric" | "string"
var _input_mode_callback: Callable         # (buffer: String) -> void
var _input_mode_prompt: String = ""
var _member_mode: bool  = false
var _inv_mode: bool     = false
var _inv_selection: int = -1

var _interact_mode:   bool = false
var _interact_target: int  = -1
var _interact_page:   int  = 0   # 互動選單分頁（>9 項翻頁）
# -1 = 目標/事件選擇階段；>= 0 = 已選 pending target，顯示行動清單

# ── 新 Panel Modes（互斥）────────────────────────────────────────────────────
var _faction_mode:  bool = false
var _outpost_mode:  bool = false
var _subteam_mode:  bool = false
var _advisor_mode:  bool = false
var _subteam_selection: int = -1   # 當前選中的子隊 team_id
var _advisor_selection: int = -1   # 當前選中的顧問 person_id

# ── 公庫面板 + 破壞性二次確認暫存 ────────────────────────────────────────────
var _storage_mode: bool = false
var _storage_page: int = 0
var _outpost_pending_abandon: bool = false   # abandon_outpost 二次確認 armed
var _faction_extract_pending: float = -1.0   # 高比例 extract_treasury 二次確認暫存比例

# ── gather_intel submode ─────────────────────────────────────────────────────
var _intel_mode: bool = false
var _intel_target_id: int = -1
var _intel_options: Array = []     # Array[Dictionary] 每項 {"label": String}

# ── 招募子模式（recruit menu payload 消費；A-1）───────────────────────────────
var _recruit_mode: bool = false
var _recruit_target_id: int = -1
var _recruit_members: Array = []        # willing_members DTO（記名候選）
var _recruit_anon_available: bool = false
var _recruit_anon_cost: int = 0
var _recruit_named_cost: int = 0

# ── Alert bar ────────────────────────────────────────────────────────────────
var _pending_alerts: Array = []    # Array[String] 待顯示的警報文字
var _alert_bar: Label              # 動態建立，置於 InputBar 上方
var _encounter_view: Control       # 動態建立，遭遇戰 overlay

# ── chrome P2：常駐 chrome 區（動態建立，仿 _alert_bar）─────────────────────────
var _log_strip: Label              # 常駐事件 log（與 panel 共存，永遠顯最新 N 條）
var _feedback_line: Label          # 指令成敗 feedback（著色，持續到下個指令）
var _hint_line: Label              # 當前模式可用鍵
var _res_baseline: Dictionary = {} # 資源每日基準（日邊界更新）→ 趨勢箭頭
var _res_baseline_day: int = -1

# ── Pre-encounter submode ────────────────────────────────────────────────────
var _pre_encounter_mode: bool = false

# ── Trade submode ────────────────────────────────────────────────────────────
var _trade_mode: bool = false
var _trade_target_id: int = -1
var _trade_page: int = 0   # offer-builder 清單分頁（>9 項翻頁）
var _input_mode_allow_empty: bool = false

var _cached_snapshot: Dictionary = {}

# member_mode state machine
var _member_selection: int    = 0   # index into members_detail
# submode: 0=quick_card 1=health 2=equipment 3=stats
var _member_detail_submode: int = 0

@onready var _map_label:   RichTextLabel = $VBox/HBox/MapLabel
@onready var _state_label: Label         = $VBox/HBox/StateLabel
@onready var _event_label: Label         = $VBox/EventLabel
@onready var _debug_bar:   Label         = $VBox/DebugBar
@onready var _input_bar:   Label         = $VBox/InputBar
@onready var _vbox:        VBoxContainer = $VBox

func _ready() -> void:
	var ws := WorldState.new()
	_runner = SimRunner.new()
	_bridge = SimBridge.new(_runner, ws)
	var config := GameSetup.load_config("res://config/default.json")
	GameSetup.setup(ws, config)
	_player_tid = _bridge.get_player_team_id()
	_cursor = _bridge.get_player_tile_pos()
	# 動態建立 alert bar（置於 InputBar 之前）
	_alert_bar = Label.new()
	_alert_bar.name = "AlertBar"
	_alert_bar.modulate = Color(1.0, 0.8, 0.0)   # 黃色警報
	var vbox: Node = _input_bar.get_parent()
	vbox.add_child(_alert_bar)
	vbox.move_child(_alert_bar, _input_bar.get_index())
	# 動態建立常駐 chrome 區（順序 …LogStrip → FeedbackLine → HintLine → AlertBar → InputBar）
	_log_strip = Label.new()
	_log_strip.name = "LogStrip"
	_log_strip.modulate = Color(0.7, 0.7, 0.7)   # 灰：背景事件
	vbox.add_child(_log_strip)
	vbox.move_child(_log_strip, _alert_bar.get_index())
	_feedback_line = Label.new()
	_feedback_line.name = "FeedbackLine"
	vbox.add_child(_feedback_line)
	vbox.move_child(_feedback_line, _alert_bar.get_index())
	_hint_line = Label.new()
	_hint_line.name = "HintLine"
	_hint_line.modulate = Color(0.6, 0.7, 0.9)   # 藍：操作提示
	vbox.add_child(_hint_line)
	vbox.move_child(_hint_line, _alert_bar.get_index())
	# 動態建立 EncounterView overlay
	_encounter_view = load("res://scripts/ui/encounter_view.gd").new()
	_encounter_view.name = "EncounterView"
	add_child(_encounter_view)
	_encounter_view.setup(_bridge)
	_encounter_view.encounter_ended.connect(_on_encounter_ended)
	_refresh()

func _enter_encounter() -> void:
	_vbox.visible = false
	_encounter_view.show_encounter()

func _on_encounter_ended() -> void:
	_vbox.visible = true
	_refresh_snapshot()
	_refresh()

func _refresh_snapshot() -> void:
	var request: Dictionary = {}
	if _interact_target >= 0:
		request["focus_team_id"] = _interact_target
	if _selected != Vector2i(-1, -1):
		request["cursor_tile_q"] = _selected.x
		request["cursor_tile_r"] = _selected.y
	var _result := _bridge.query_player(request)
	_cached_snapshot = _result.get("data", {}).get("snapshot", {})

func _process(_delta: float) -> void:
	if not _bridge.is_advancing(): return
	var result := _bridge.tick_step()
	_events.append_array(result.get("events", []))
	if _events.size() > 100:
		_events = _events.slice(_events.size() - 100)

	var move_target: Vector2i = _bridge.get_player_move_target()
	if move_target == Vector2i(-1, -1) and _input_bar.text.begins_with("移動中"):
		_bridge.cancel_advance()
		_input_bar.text = ""
		var pos: Vector2i = _bridge.get_player_tile_pos()
		_log_event("Team%d 到達 (%d,%d)" % [_player_tid, pos.x, pos.y])

	if result.get("done", false):
		var mt2: Vector2i = _bridge.get_player_move_target()
		if _input_bar.text.begins_with("移動中") and mt2 != Vector2i(-1, -1):
			_bridge.request_advance(99999)
		else:
			_input_bar.text = ""
	elif not _input_bar.text.begins_with("移動中"):
		_input_bar.text = "推進中 Tick:%d [Esc]停止" % _bridge.get_current_tick()
	_refresh()
	var ps: Dictionary = _cached_snapshot.get("player_summary", {})
	if ps.get("pre_encounter_pending", false) and not _pre_encounter_mode:
		_bridge.cancel_advance()
		_pre_encounter_mode = true
		_refresh()
	elif ps.get("encounter_active", false):
		_bridge.cancel_advance()
		_enter_encounter()
	elif not _cached_snapshot.get("forced_interaction", {}).get("interaction_id", "").is_empty() \
			and not _interact_mode and not _pre_encounter_mode:
		# U19: 強制事件（乞食/繼承/勒索回應…）自動進互動模式顯選單，否則玩家無從回應 → 卡死
		# （choose_heir 凍世界，更須自動進）。回應 handler/render 已在 interact mode 內。
		_bridge.cancel_advance()
		_interact_mode = true
		_interact_target = -1
		_interact_page = 0
		_refresh()

func _input(event: InputEvent) -> void:
	if not event is InputEventKey: return
	if not event.pressed: return
	# 遭遇戰 overlay 顯示中（含戰後「按任意鍵離開」畫面，此時 encounter_active 已 false）
	# → 鍵盤全權交給 encounter_view，主畫面一律不處理。
	# 否則 Q 會落到下方 KEY_Q→get_tree().quit() 造成戰後一按鍵就閃退；
	# WASD 也會同時漂移世界地圖游標。用 overlay 可見性（非 encounter_active）判定。
	if _encounter_view != null and _encounter_view.visible:
		return
	if _input_mode:
		_handle_input_mode(event.keycode)
		return
	if _pre_encounter_mode:
		_handle_pre_encounter_mode(event.keycode)
		return
	if _trade_mode:
		_handle_trade_mode(event.keycode)
		return
	if _intel_mode:
		_handle_intel_mode(event.keycode)
		return
	if _recruit_mode:
		_handle_recruit_mode(event.keycode)
		return
	if _inv_mode:
		_handle_inv_mode(event.keycode)
		return
	if _interact_mode:
		_handle_interact_mode(event.keycode)
		return
	if _member_mode:
		_handle_member_mode(event.keycode)
		return
	if _faction_mode:
		_handle_faction_mode(event.keycode)
		return
	if _outpost_mode:
		_handle_outpost_mode(event.keycode)
		return
	if _subteam_mode:
		_handle_subteam_mode(event.keycode)
		return
	if _advisor_mode:
		_handle_advisor_mode(event.keycode)
		return
	if _storage_mode:
		_handle_storage_mode(event.keycode)
		return
	match event.keycode:
		KEY_W: _move_cursor(Vector2i(0, -1))
		KEY_S: _move_cursor(Vector2i(0,  1))
		KEY_A: _move_cursor(Vector2i(-1, 0))
		KEY_D: _move_cursor(Vector2i( 1, 0))
		KEY_ENTER:
			_selected = _cursor
			_refresh()
		KEY_M:
			var r: Dictionary = _bridge.command_player("move_to", {"tile_q": _cursor.x, "tile_r": _cursor.y})
			if r.get("ok"):
				_log_event(r.get("message", ""))
				_bridge.request_advance(99999)
				_input_bar.text = "移動中 [Esc]停止"
			else:
				_log_event(r.get("message", "移動失敗"))
			_set_feedback(r.get("ok", true), r.get("message", ""))
			_refresh()
		KEY_SPACE:
			_bridge.request_advance(WorldState.TICKS_PER_DAY)
		KEY_G:
			_input_mode = true
			_input_mode_type = "numeric"
			_input_mode_prompt = "跳過 tick 數: "
			_input_buffer = ""
			_input_mode_callback = Callable()   # 無 callback → 使用舊有行為
			_input_bar.text = "跳過 tick 數: _"
		KEY_H:
			_cursor = _bridge.get_player_tile_pos()
			_refresh()
		KEY_R:
			# U18：設匿名武裝比例（輸入 0~100 百分比）
			_input_mode = true
			_input_mode_type = "numeric"
			_input_mode_prompt = "武裝比例 %: "
			_input_buffer = ""
			_input_mode_callback = func(buf: String) -> void:
				var pct: float = clampf(buf.to_float(), 0.0, 100.0)
				var st = _bridge.get_state()
				st.player_state["armed_ratio_input"] = pct / 100.0
				var r: Dictionary = _bridge.command_player("execute_action",
					{"action_id": "set_armed_anon_ratio", "target": {"kind": "none"}})
				_set_feedback(r.get("ok", false), r.get("message", r.get("result_summary", "")))
				_refresh()
			_input_bar.text = "武裝比例 %: _"
		KEY_P:
			_member_mode = not _member_mode
			if _inv_mode: _inv_mode = false
			_refresh()
		KEY_I:
			_inv_mode = not _inv_mode
			if _member_mode: _member_mode = false
			_inv_selection = -1
			_refresh()
		KEY_T:
			_interact_mode = not _interact_mode
			if _interact_mode:
				if _inv_mode: _inv_mode = false
				if _member_mode: _member_mode = false
				_interact_target = -1
				_interact_page = 0
				_bridge.refresh_interaction_targets()  # 掃描同格 NPC，讓 ignore 後仍可再次互動
			_refresh()
		KEY_F:
			_faction_mode = not _faction_mode
			if _faction_mode: _close_all_modes("faction")
			_refresh()
		KEY_O:
			_outpost_mode = not _outpost_mode
			if _outpost_mode: _close_all_modes("outpost")
			_refresh()
		KEY_U:
			_subteam_mode = not _subteam_mode
			if _subteam_mode: _close_all_modes("subteam")
			_subteam_selection = -1
			_refresh()
		KEY_V:
			_advisor_mode = not _advisor_mode
			if _advisor_mode: _close_all_modes("advisor")
			_advisor_selection = -1
			_refresh()
		KEY_K:
			# 公庫面板（[G] 已綁跳 Tick，故用 [K]）
			_storage_mode = not _storage_mode
			if _storage_mode: _close_all_modes("storage")
			_storage_page = 0
			_refresh()
		KEY_ESCAPE:
			if _bridge.is_advancing():
				_bridge.cancel_advance()
				_input_bar.text = ""
				_refresh()
			elif _interact_mode:
				if _interact_target >= 0:
					_interact_target = -1   # 退回目標清單
				else:
					_interact_mode = false   # 關閉
				_refresh()
			elif _member_mode:
				_member_mode = false
				_refresh()
			elif _inv_mode:
				_inv_mode = false
				_inv_selection = -1
				_refresh()
			elif _faction_mode:
				_faction_mode = false
				_refresh()
			elif _outpost_mode:
				_outpost_mode = false
				_refresh()
			elif _subteam_mode:
				if _subteam_selection >= 0:
					_subteam_selection = -1
				else:
					_subteam_mode = false
				_refresh()
		KEY_Q:
			if _bridge != null and _bridge.is_encounter_active():
				pass    # encounter_view handles Q as northwest movement
			else:
				get_tree().quit()
		KEY_Z:
			if not _pending_alerts.is_empty():
				_pending_alerts.pop_front()
			_check_alerts()

func _handle_input_mode(keycode: int) -> void:
	if _input_mode_type == "string":
		# 接受 A-Z 字元
		if keycode >= KEY_A and keycode <= KEY_Z:
			if _input_buffer.length() < 30:
				_input_buffer += char(keycode).to_lower()
			_input_bar.text = "%s%s_" % [_input_mode_prompt, _input_buffer]
			return
		match keycode:
			KEY_BACKSPACE:
				if _input_buffer.length() > 0:
					_input_buffer = _input_buffer.left(_input_buffer.length() - 1)
				_input_bar.text = "%s%s_" % [_input_mode_prompt, _input_buffer]
			KEY_ENTER:
				if _input_buffer.length() > 0 or _input_mode_allow_empty:
					_input_mode = false
					_input_mode_allow_empty = false
					_input_bar.text = ""
					if _input_mode_callback.is_valid():
						_input_mode_callback.call(_input_buffer)
					_input_buffer = ""
					_refresh()
			KEY_ESCAPE:
				_input_mode = false
				_input_mode_allow_empty = false
				_input_buffer = ""
				_input_bar.text = ""
				_input_mode_callback = Callable()
				_refresh()
		return

	# 原有 numeric 模式
	if keycode >= KEY_0 and keycode <= KEY_9:
		if _input_buffer.length() < 6:
			_input_buffer += str(keycode - KEY_0)
		_input_bar.text = "%s%s_" % [_input_mode_prompt if not _input_mode_prompt.is_empty() else "跳過 tick 數: ", _input_buffer]
		return
	match keycode:
		KEY_BACKSPACE:
			if _input_buffer.length() > 0:
				_input_buffer = _input_buffer.left(_input_buffer.length() - 1)
			_input_bar.text = "%s%s_" % [_input_mode_prompt if not _input_mode_prompt.is_empty() else "跳過 tick 數: ", _input_buffer]
		KEY_ENTER:
			if _input_buffer.length() > 0:
				if _input_mode_callback.is_valid():
					_input_mode = false
					_input_bar.text = ""
					_input_mode_callback.call(_input_buffer)
					_input_buffer = ""
					_input_mode_callback = Callable()
					_refresh()
				elif int(_input_buffer) > 0:
					# 舊有行為：跳過 N tick
					var n: int = mini(int(_input_buffer), 99999)
					_input_mode = false
					_input_bar.text = ""
					_bridge.request_advance(n)
					_input_buffer = ""
					_refresh()
		KEY_ESCAPE:
			_input_mode = false
			_input_buffer = ""
			_input_bar.text = ""
			_input_mode_callback = Callable()
			_refresh()

# U13: inv 選取版面 — 已裝備槽在前（[數字] 1..eq_n），背包次之，Team 取出最後
#   [E]裝備背包物  [U]卸下已裝備槽  [S]存背包物  [G]取 Team 物
func _inv_equipped_slots() -> Array:
	var inv_state: Dictionary = _cached_snapshot.get("inventory_state", {})
	var equipped: Dictionary  = inv_state.get("equipped_items", {})
	var out: Array = []
	for slot in ["hand_1", "hand_2"]:
		var g: String = equipped.get(slot, "")
		if not g.is_empty():
			out.append({ "slot": slot, "grade": g })
	var body: Dictionary = _bridge.query_body_slots()
	for slot in ["head", "torso", "right_arm", "left_arm", "right_leg", "left_leg"]:
		var bg: String = body.get(slot, "")
		if not bg.is_empty():
			out.append({ "slot": slot, "grade": bg })
	return out

func _handle_inv_mode(keycode: int) -> void:
	var eq: Array          = _inv_equipped_slots()
	var inv: Array         = _cached_snapshot.get("inventory_state", {}).get("inventory_items", [])
	var team_items: Array  = _get_team_takeable_items(null)
	var eq_n: int  = eq.size()
	var inv_n: int = inv.size()

	if keycode >= KEY_1 and keycode <= KEY_9:
		var num: int  = keycode - KEY_1
		var total: int = eq_n + inv_n + team_items.size()
		if num < total:
			_inv_selection = num
		_refresh()
		return

	match keycode:
		KEY_E:
			var inv_idx: int = _inv_selection - eq_n
			if inv_idx >= 0 and inv_idx < inv_n:
				var grade: String = inv[inv_idx].get("grade", "")
				var slot: String  = "torso" if grade.begins_with("armor") else "hand_1"
				var r: Dictionary = _bridge.command_player("equip_item", {"slot_id": slot, "item_grade": grade})
				_set_feedback(r.get("ok", false), r.get("message", ""))
				_inv_selection = -1
		KEY_U:
			if _inv_selection >= 0 and _inv_selection < eq_n:
				var slot: String = eq[_inv_selection].get("slot", "")
				if slot != "":
					var r: Dictionary = _bridge.command_player("unequip_item", {"slot_id": slot})
					_set_feedback(r.get("ok", false), r.get("message", ""))
				_inv_selection = -1
		KEY_S:
			var inv_idx2: int = _inv_selection - eq_n
			if inv_idx2 >= 0 and inv_idx2 < inv_n:
				var grade: String = inv[inv_idx2].get("grade", "")
				var qty: int      = inv[inv_idx2].get("qty", 0)
				_bridge.command_player("deposit_item", {"item_grade": grade, "qty": qty})
				_inv_selection = -1
		KEY_G:
			var team_idx: int = _inv_selection - eq_n - inv_n
			if team_idx >= 0 and team_idx < team_items.size():
				_bridge.command_player("take_team_item", {"item_grade": team_items[team_idx], "qty": 1})
				_inv_selection = -1
		KEY_I, KEY_ESCAPE:
			_inv_mode = false
			_inv_selection = -1
	_refresh()

func _move_cursor(delta: Vector2i) -> void:
	var new_pos := _cursor + delta
	if _bridge.is_valid_tile(new_pos.x, new_pos.y):
		_cursor = new_pos
	_refresh()

func _refresh() -> void:
	_refresh_snapshot()
	_map_label.text  = _bridge.render_text_map(_player_tid, _cursor)
	_state_label.text = _build_state_str()
	_debug_bar.text  = "" if (_interact_mode or _member_mode or _inv_mode) else _build_debug_str()

	if _pre_encounter_mode:
		_event_label.text = _build_pre_encounter_str()
	elif _trade_mode:
		_event_label.text = _build_trade_str()
	elif _interact_mode:
		_event_label.text = _build_interact_str()
	elif _member_mode:
		_event_label.text = _build_member_str()
	elif _inv_mode:
		_event_label.text = _build_inv_str()
	elif _faction_mode:
		_event_label.text = _build_faction_str()
	elif _outpost_mode:
		_event_label.text = _build_outpost_str()
	elif _subteam_mode:
		_event_label.text = _build_subteam_str()
	elif _advisor_mode:
		_event_label.text = _build_advisor_str()
	elif _storage_mode:
		_event_label.text = _build_storage_str()
	elif _intel_mode:
		_event_label.text = _build_intel_str()
	elif _recruit_mode:
		_event_label.text = _build_recruit_str()
	else:
		var log_lines: Array = []
		var show_count: int = mini(_events.size(), 6)
		for i in range(_events.size() - show_count, _events.size()):
			var e = _events[i]
			log_lines.append("[T%d] %s" % [_bridge.get_current_tick(), str(e)])
		_event_label.text = "\n".join(log_lines)
	# 常駐 chrome：hint（當前模式鍵表）+ LogStrip（與 panel 共存，永遠顯最新 N 條）
	_hint_line.text = _mode_keymap(_current_mode_name())
	_log_strip.text = _log_strip_text(_events, 3)
	_check_alerts()

func _get_hp_status(person: PersonData) -> String:
	var has_severe: bool = false
	var has_wound: bool  = false
	for part in person.body_parts.values():
		var status: String = part.get("status", "healthy")
		if status == "severed" or status == "critical":
			has_severe = true
		elif status == "wounded":
			has_wound = true
	if has_severe: return "重傷"
	if has_wound:  return "輕傷"
	return "正常"

func _visible_team_at(tile_key: int) -> int:
	var q: int = tile_key / 1000
	var r: int = tile_key % 1000
	for vt in _cached_snapshot.get("visible_teams", []):
		var pos: Dictionary = vt.get("position", {})
		if pos.get("q", -999) == q and pos.get("r", -999) == r:
			return vt.get("id", -1)
	return -1

# ── chrome P2 helpers（純函數，供 ui_logic_test 單元覆蓋）─────────────────────

# 成員健康一行摘要：有傷列傷員，全正常則簡短「全員正常」
static func _member_health_line(members: Array) -> String:
	var hurt: Array = []
	for m in members:
		var s: String = str(m.get("hp_status", "正常"))
		if s != "正常":
			hurt.append("%s(%s)" % [m.get("name", "?"), s])
	if hurt.is_empty():
		return "成員: 全員正常"
	return "成員傷: " + "、".join(hurt)

# 資源趨勢箭頭：相對每日基準的 delta（>0.5 ↑、<-0.5 ↓、否則無）
static func _resource_trend(baseline: float, cur: float) -> String:
	if cur > baseline + 0.5: return "↑"
	if cur < baseline - 0.5: return "↓"
	return ""

# 當前模式可用鍵表（依各 _handle_*_mode 實際鍵對齊）
const MODE_KEYMAP: Dictionary = {
	"main":          "[WASD]移游標 [Enter]選格 [M]移動 [Space]推進日 [G]跳Tick [I]物品 [P]成員 [F]勢力 [O]前哨 [K]公庫 [U]子隊 [V]顧問 [T]互動 [Q]離開",
	"interact":      "[1-9]選目標/行動 [Esc]返回",
	"member":        "[W/S]選員 [1-4]切頁(卡/傷/裝/能) [P/Esc]關閉",
	"inv":           "[1-9]選 [E]裝備 [U]卸下 [S]存入 [G]取出 [I/Esc]關閉",
	"faction":       "[A]目標 [B]徵收率 [G]徵用國庫 [C]離開 [D]背叛 [E]解散 [1-9]下令成員 [F/Esc]關閉",
	"outpost":       "[1-9]行動 [O/Esc]關閉",
	"subteam":       "[1-9]選隊 [N]派遣 [A]下令移動 [B]召回 [U/Esc]關閉",
	"advisor":       "[1-9]選顧問問策 [V/Esc]關閉",
	"storage":       "[數字]存/取 [,.]翻頁 [Esc]離開",
	"intel":         "[1-5]選題 [Esc]取消",
	"trade":         "[數字]選項 [Enter]送出 [C]清 [,.]翻頁 [Esc]離開",
	"pre_encounter": "[1]迎擊 [2]投降",
}
static func _mode_keymap(mode: String) -> String:
	return MODE_KEYMAP.get(mode, MODE_KEYMAP["main"])

# feedback 行文字（成✓ 敗✗）
static func _feedback_text(ok: bool, msg: String) -> String:
	return ("✓ " if ok else "✗ ") + msg
static func _feedback_color(ok: bool) -> Color:
	return Color(0.5, 0.9, 0.5) if ok else Color(0.95, 0.5, 0.5)

# event LogStrip 組字：取最新 n 條的 msg，以「 | 」串接
static func _log_strip_text(events: Array, n: int) -> String:
	var out: Array = []
	var start: int = maxi(0, events.size() - n)
	for i in range(start, events.size()):
		out.append(str(events[i].get("msg", "")))
	return " | ".join(out)

# 當前模式字串（依各 mode flag，順序對齊 _input dispatch）
func _current_mode_name() -> String:
	if _input_mode:         return _current_mode_name_under_input()
	if _pre_encounter_mode: return "pre_encounter"
	if _trade_mode:         return "trade"
	if _intel_mode:         return "intel"
	if _recruit_mode:       return "recruit"
	if _inv_mode:           return "inv"
	if _interact_mode:      return "interact"
	if _member_mode:        return "member"
	if _faction_mode:       return "faction"
	if _outpost_mode:       return "outpost"
	if _subteam_mode:       return "subteam"
	if _advisor_mode:       return "advisor"
	if _storage_mode:       return "storage"
	return "main"

# 輸入模式時保留底層 panel 的提示（次要：顯通用輸入提示）
func _current_mode_name_under_input() -> String:
	return "main"

# 指令成敗 feedback（持續到下個指令，不清）
func _set_feedback(ok: bool, msg: String) -> void:
	if _feedback_line == null: return
	if str(msg).is_empty(): return
	_feedback_line.text = _feedback_text(ok, msg)
	_feedback_line.modulate = _feedback_color(ok)

func _build_state_str() -> String:
	var ct: Dictionary  = _cached_snapshot.get("controlled_team", {})
	var ps: Dictionary  = _cached_snapshot.get("player_summary", {})
	var lc: Dictionary  = _cached_snapshot.get("location_context", {})
	if ct.is_empty(): return "（無玩家 team）"
	var lines: Array = []

	var pos: Dictionary = ct.get("position", {})
	lines.append("Team%d @ (%d,%d) [%s]" % [
		ct.get("id", _player_tid),
		pos.get("q", 0), pos.get("r", 0),
		ct.get("faction_display", "?")])
	lines.append("狀態: %s  疲勞: %d%%" % [ct.get("task_summary", ""), ct.get("fatigue_pct", 0)])
	lines.append("人口: %d  武裝: %d (比例%d%%) | 未成年: %d" % [ct.get("population", 0), ct.get("armed_count", 0), int(float(ct.get("armed_ratio", 0.0)) * 100.0), ct.get("minor_population", 0)])
	var food_days: float = float(ct.get("food_days", 99.0))
	var starving: bool = bool(ct.get("starving", false))
	lines.append("糧: %.1f 天%s" % [food_days, "  ⚠斷糧" if starving else ""])
	var cap: Dictionary = ct.get("capabilities", {})
	if not cap.is_empty():
		lines.append("狩獵 %d%%/%.0f糧  戰力 %.0f  日耗 %.1f食(撐%.0f天)" % [
			int(float(cap.get("hunt_chance", 0.0)) * 100), float(cap.get("hunt_yield", 0.0)),
			float(cap.get("combat_power", 0.0)), float(cap.get("food_burn_per_day", 0.0)),
			food_days])
	lines.append(_member_health_line(ct.get("members", [])))

	if ps.get("player_exists", false):
		lines.append("────────────────")
		lines.append("玩家: %s  HP:%s" % [ps.get("player_name", ""), ps.get("hp_status", "")])
		var skill_parts: Array = []
		for sk in ps.get("skills", {}):
			skill_parts.append("%s:%.2f" % [sk, float(ps["skills"][sk])])
		if not skill_parts.is_empty():
			lines.append("  " + " ".join(skill_parts))

	var res: Dictionary = ct.get("resources", {})
	var day: int = _bridge.get_current_tick() / WorldState.TICKS_PER_DAY
	if day != _res_baseline_day:
		_res_baseline_day = day
		_res_baseline = res.duplicate()
	lines.append("────────────────")
	lines.append("資源:")
	lines.append("  食:%d%s 幣:%d%s 材:%d%s" % [
		res.get("food", 0),     _resource_trend(float(_res_baseline.get("food", res.get("food", 0))), float(res.get("food", 0))),
		res.get("coin", 0),     _resource_trend(float(_res_baseline.get("coin", res.get("coin", 0))), float(res.get("coin", 0))),
		res.get("material", 0), _resource_trend(float(_res_baseline.get("material", res.get("material", 0))), float(res.get("material", 0)))])
	lines.append("  低武:%d 高武:%d" % [res.get("weapon_melee_low", 0), res.get("weapon_melee_high", 0)])
	lines.append("  低甲:%d 高甲:%d" % [res.get("armor_low", 0), res.get("armor_high", 0)])
	lines.append("  藥:%d 工:%d" % [res.get("medicine", 0), res.get("tools", 0)])

	if _selected != Vector2i(-1, -1):
		var sel_tile: Dictionary = _bridge.query_tile(_selected.x, _selected.y)
		lines.append("────────────────")
		if not sel_tile.is_empty():
			lines.append("選中: (%d,%d) %s" % [_selected.x, _selected.y, sel_tile.get("terrain", "?")])
			lines.append("  農:%.0f%%  食:%d" % [
				sel_tile.get("productivity", 0) * 100,
				int(sel_tile.get("resources", {}).get("food", 0))])
			var occ: Array = lc.get("occupants", [])
			if not occ.is_empty():
				var vts: Array = _cached_snapshot.get("visible_teams", [])
				for o in occ:
					var oid: int = o.get("team_id", -1)
					var f_display: String = "?"
					var pop: int = 0
					for vt in vts:
						if vt.get("id", -1) == oid:
							f_display = vt.get("faction_display", "?")
							pop = vt.get("population", 0)
							break
					var pop_str: String = ("~%d" % pop) if pop >= 0 else "?"
					lines.append("  %s [%s] 人口:%s" % [o.get("team_name", "Team?"), f_display, pop_str])
		else:
			lines.append("選中: (%d,%d) [無效格]" % [_selected.x, _selected.y])

	lines.append("────────────────")
	lines.append("Tick: %d  (Day %d)" % [
		_bridge.get_current_tick(),
		_bridge.get_current_tick() / WorldState.TICKS_PER_DAY])
	var _pending_n: int = _cached_snapshot.get("pending_targets", []).size()
	var _forced_n:  int = 0 if _cached_snapshot.get("forced_interaction", {}).get("interaction_id", "").is_empty() else 1
	if _pending_n > 0 or _forced_n > 0:
		var _hint: String = "[T] 互動"
		if _pending_n > 0: _hint += ": 同格%d隊" % _pending_n
		if _forced_n > 0:  _hint += "  ⚠強制事件"
		lines.append(_hint)
	return "\n".join(lines)

func _build_debug_str() -> String:
	var tick: int  = _bridge.get_current_tick()
	var hour: int  = (tick / WorldState.TICKS_PER_HOUR) % 24
	var day: int   = (tick / WorldState.TICKS_PER_DAY) % 30 + 1
	var month: int = (tick / WorldState.TICKS_PER_MONTH) % 12
	var season_names: Array = ["春","春","春","夏","夏","夏","秋","秋","秋","冬","冬","冬"]
	var season: String = season_names[month]
	var lines: Array = []
	lines.append("[DEBUG] Tick:%d Hour:%d Day:%d Month:%d Season:%s" % [tick, hour, day, month + 1, season])

	var teams_debug: Array = _bridge.get_all_teams_debug()
	var team_strs: Array = []
	for td in teams_debug:
		var pos: Vector2i = td.get("pos", Vector2i.ZERO)
		team_strs.append("T%d@(%d,%d)pop=%d %s" % [td["id"], pos.x, pos.y, td["pop"], td["task"]])
	lines.append("Teams: " + " | ".join(team_strs))

	var evt_strs: Array = []
	for i in range(maxi(0, _events.size() - 10), _events.size()):
		var e = _events[i]
		evt_strs.append("[%s]%s" % [str(e.get("type","?")), str(e.get("msg",""))])
	lines.append("Events(last10): " + " | ".join(evt_strs))

	var msgs: Array = _bridge.query_global_messages(10)
	lines.append("Msgs(last10): " + " | ".join(msgs))

	return "\n".join(lines)

func _handle_member_mode(keycode: int) -> void:
	var members: Array = _cached_snapshot.get("members_detail", [])
	match keycode:
		KEY_W:
			if members.size() > 0:
				_member_selection = posmod(_member_selection - 1, members.size())
		KEY_S:
			if members.size() > 0:
				_member_selection = posmod(_member_selection + 1, members.size())
		KEY_1:
			_member_detail_submode = 0
		KEY_2:
			_member_detail_submode = 1
		KEY_3:
			_member_detail_submode = 2
		KEY_4:
			_member_detail_submode = 3
		KEY_E:
			# U13b：裝備選中成員 hand_1（裝 team 池第一個可用武器）
			if _member_detail_submode == 2 and members.size() > 0:
				_equip_selected_member(members[_member_selection])
		KEY_U:
			# U13b：卸下選中成員 hand_1
			if _member_detail_submode == 2 and members.size() > 0:
				_unequip_selected_member(members[_member_selection])
		KEY_Y:
			# S9：調選中成員薪資（任一 submode）
			if members.size() > 0:
				_prompt_member_salary(members[_member_selection])
				return
		KEY_P, KEY_ESCAPE:
			_member_mode = false
	_refresh()

# U13b：裝 team 武器池第一個可用武器到成員 hand_1
func _equip_selected_member(member: Dictionary) -> void:
	var ct: Dictionary = _cached_snapshot.get("controlled_team", {})
	var tid: int = int(ct.get("id", -1))
	var mid: int = int(member.get("id", -1))
	if tid == -1 or mid == -1:
		return
	const WEAPON_GRADES: Array = ["weapon_melee_high", "weapon_melee_low",
		"weapon_ranged_high", "weapon_ranged_low"]
	var res: Dictionary = ct.get("resources", {})
	var grade: String = ""
	for g in WEAPON_GRADES:
		if int(res.get(g, 0)) > 0:
			grade = g
			break
	if grade == "":
		_set_feedback(false, "team 無可裝備武器")
		return
	var r: Dictionary = _bridge.command_player("execute_action",
		{"action_id": "equip_member",
		 "target": {"kind": "member", "team_id": tid, "member_id": mid,
			"slot_id": "hand_1", "item_grade": grade}})
	_set_feedback(r.get("ok", false), r.get("message", r.get("result_summary", "")))

# U13b：卸下成員 hand_1
func _unequip_selected_member(member: Dictionary) -> void:
	var ct: Dictionary = _cached_snapshot.get("controlled_team", {})
	var tid: int = int(ct.get("id", -1))
	var mid: int = int(member.get("id", -1))
	if tid == -1 or mid == -1:
		return
	var r: Dictionary = _bridge.command_player("execute_action",
		{"action_id": "unequip_member",
		 "target": {"kind": "member", "team_id": tid, "member_id": mid, "slot_id": "hand_1"}})
	_set_feedback(r.get("ok", false), r.get("message", r.get("result_summary", "")))

# S9：數字輸入收薪資 → set_member_salary
func _prompt_member_salary(member: Dictionary) -> void:
	var ct: Dictionary = _cached_snapshot.get("controlled_team", {})
	var tid: int = int(ct.get("id", -1))
	var mid: int = int(member.get("id", -1))
	_input_mode = true
	_input_mode_type = "numeric"
	_input_mode_prompt = "%s 薪資: " % member.get("name", "成員")
	_input_buffer = ""
	_input_mode_callback = func(buf: String) -> void:
		var st = _bridge.get_state()
		st.player_state["salary_input"] = buf.to_float()
		var r: Dictionary = _bridge.command_player("execute_action",
			{"action_id": "set_member_salary",
			 "target": {"kind": "member", "team_id": tid, "member_id": mid}})
		_set_feedback(r.get("ok", false), r.get("message", r.get("result_summary", "")))
		_refresh()
	_input_bar.text = "%s薪資: _" % member.get("name", "成員")

func _build_member_str() -> String:
	var members: Array    = _cached_snapshot.get("members_detail", [])
	var team_stats: Dictionary = _cached_snapshot.get("team_stats", {})
	var ct: Dictionary    = _cached_snapshot.get("controlled_team", {})
	if members.is_empty() and ct.is_empty():
		return "（無玩家 team）"

	# Clamp selection to valid range
	if members.size() > 0:
		_member_selection = clampi(_member_selection, 0, members.size() - 1)

	var selected_member: Dictionary = members[_member_selection] if members.size() > 0 else {}

	var detail_lines: Array = []
	match _member_detail_submode:
		0: detail_lines = TeamUiHelper.render_quick_card(selected_member)
		1: detail_lines = TeamUiHelper.render_health_detail(selected_member)
		2: detail_lines = TeamUiHelper.render_equipment_detail(selected_member)
		3: detail_lines = TeamUiHelper.render_stats_detail(selected_member)

	var team_name: String = ct.get("name", "Team?")
	var body: String = TeamUiHelper.render_three_columns(
		members,
		_member_selection,
		detail_lines,
		team_stats,
		team_name,
		_bridge.get_current_tick()
	)
	var hint: String = "[W/S]選成員 [1-4]切頁 [Y]調薪"
	if _member_detail_submode == 2:
		hint += " [E]裝備 [U]卸下"
	hint += " [P/Esc]關閉"
	return body + "\n" + hint

func _get_team_takeable_items(_pt: TeamData) -> Array:
	return ["weapon_melee_low", "weapon_melee_high", "weapon_ranged_low", "weapon_ranged_high",
		"armor_low", "armor_high", "medicine", "tools"]

func _build_inv_str() -> String:
	var ct: Dictionary        = _cached_snapshot.get("controlled_team", {})
	var inv_state: Dictionary = _cached_snapshot.get("inventory_state", {})
	if ct.is_empty() or inv_state.is_empty(): return "（無資料）"
	var lines: Array = []
	const SLOT_NAMES: Dictionary = {
		"hand_1": "右手", "hand_2": "左手", "head": "頭", "torso": "胸",
		"right_arm": "右臂", "left_arm": "左臂", "right_leg": "右腿", "left_leg": "左腿"
	}

	# ── 已裝備（可選取 → [U]卸下） ──
	var eq: Array = _inv_equipped_slots()
	lines.append("── 裝備（[U]卸下選中）──")
	if eq.is_empty():
		lines.append("  （無已裝備物）")
	for i in range(eq.size()):
		var prefix: String = "[%d]*" % (i + 1) if _inv_selection == i else "[%d]" % (i + 1)
		lines.append("  %s %s: %s" % [prefix, SLOT_NAMES.get(eq[i]["slot"], eq[i]["slot"]), eq[i]["grade"]])

	# ── 背包（[E]裝備 / [S]存入） ──
	var inv: Array = inv_state.get("inventory_items", [])
	lines.append("── 背包 (%d/%d) ──" % [inv.size(), PlayerSystem.PLAYER_INVENTORY_MAX_SLOTS])
	for i in range(inv.size()):
		var item = inv[i]
		var sel_idx: int = eq.size() + i
		var prefix: String = "[%d]*" % (sel_idx + 1) if _inv_selection == sel_idx else "[%d]" % (sel_idx + 1)
		lines.append("  %s %s × %d" % [prefix, item.get("grade", "?"), item.get("qty", 0)])

	# ── 從 Team 取出（[G]） ──
	var team_items: Array = _get_team_takeable_items(null)
	lines.append("── 從 Team 取出 ──")
	for i in range(team_items.size()):
		var sel_idx2: int = eq.size() + inv.size() + i
		var prefix: String = "[%d]*" % (sel_idx2 + 1) if _inv_selection == sel_idx2 else "[%d]" % (sel_idx2 + 1)
		var qty: int = ct.get("resources", {}).get(team_items[i], 0)
		lines.append("  %s %s: %d%s" % [prefix, team_items[i], qty, "" if qty > 0 else "（灰）"])

	lines.append("── [數字]選取 [E]裝備 [U]卸下 [S]存入 [G]取出 [I/Esc]關閉 ──")
	return "\n".join(lines)

func _log_event(msg: String) -> void:
	_events.append({ "type": "ui", "msg": msg })
	if _events.size() > 100:
		_events = _events.slice(_events.size() - 100)

func _handle_interact_mode(keycode: int) -> void:
	# ESC 處理
	if keycode == KEY_ESCAPE:
		if _interact_target >= 0:
			_interact_target = -1
		else:
			_interact_mode = false
		_interact_page = 0   # 切換視圖重置分頁
		_refresh()
		return

	# 翻頁（選單 >9 項時）：[,] 上一頁 / [.] 下一頁
	if keycode == KEY_COMMA:
		_interact_page = maxi(0, _interact_page - 1); _refresh(); return
	if keycode == KEY_PERIOD:
		_interact_page += 1; _refresh(); return
	# 數字鍵 1–9（含頁偏移）
	if keycode < KEY_1 or keycode > KEY_9:
		return
	var num: int = (keycode - KEY_1) + _interact_page * 9   # 0-based + 頁偏移

	# ── 已選目標：顯示行動清單（只 team-target 動作）──
	if _interact_target >= 0:
		var actions: Array = _interact_action_split()["team"]
		if num < actions.size():
			var act: Dictionary = actions[num]
			var action_id: String = act.get("action_id", "")
			if action_id == "gather_intel":
				# 進入 gather_intel 子模式
				_intel_target_id = _interact_target
				_bridge.set_player_input("pending_intel_target", _intel_target_id)
				var ir: Dictionary = _bridge.command_player(
					act.get("command_name", "execute_action"), act.get("command_args", {}))
				_intel_options = ir.get("payload", {}).get("inquiry_options", [])
				if _intel_options.is_empty():
					_log_event("[打聽] 無可用問題")
				else:
					_intel_mode = true
					_interact_mode = false
			elif action_id == "recruit":
				# recruit 回 menu payload → 進招募子模式（記名候選 + 匿名選項）
				var rr: Dictionary = _bridge.command_player(
					act.get("command_name", "execute_action"), act.get("command_args", {}))
				if not rr.get("ok", false):
					_log_event("[招募] %s" % rr.get("message", rr.get("msg", "無法招募")))
				else:
					var rp: Dictionary = rr.get("payload", {})
					_recruit_members        = rp.get("willing_members", [])
					_recruit_anon_available = rp.get("anon_available", false)
					_recruit_anon_cost      = int(rp.get("anon_cost", 0))
					_recruit_named_cost     = int(rp.get("named_cost", 0))
					if _recruit_members.is_empty() and not _recruit_anon_available:
						_log_event("[招募] 無可招募對象")
					else:
						_recruit_target_id = _interact_target
						_recruit_mode = true
						_interact_mode = false
			else:
				var result: Dictionary = _bridge.command_player(
					act.get("command_name", "execute_action"), act.get("command_args", {}))
				_log_event("[互動] %s" % result.get("message", ""))
				_set_feedback(result.get("ok", true), result.get("message", ""))
				# 貿易預覽流程：進入 trade submode
				if result.get("ok") and result.get("payload", {}).get("requires_preview", false):
					_trade_target_id = result.get("payload", {}).get("preview_target_id", -1)
					_bridge.set_player_input("trade_offer", {"player_gives": {}, "player_wants": {}})
					_trade_page = 0
					_trade_mode = true
					_interact_mode = false
					_refresh()
					return
			_interact_target = -1   # 回到目標清單
			_bridge.refresh_interaction_targets()   # 重掃同格 NPC（行動後重建選單）
			# 若行動觸發遭遇戰，關閉 interact_mode
			_refresh_snapshot()
			if _cached_snapshot.get("player_summary", {}).get("encounter_active", false):
				_interact_mode = false
				_enter_encounter()
		_refresh()
		return

	# ── 目標選擇階段 ──
	var fi: Dictionary = _cached_snapshot.get("forced_interaction", {})
	var fi_responses: Array = fi.get("responses", [])
	var fe_count: int = fi_responses.size()

	# forced_event 回應
	if not fi.get("interaction_id", "").is_empty() and num < fe_count:
		var resp_args: Dictionary = fi_responses[num].get("command_args", {})
		var result: Dictionary = _bridge.command_player("respond_to_forced", resp_args)
		_log_event("[強制互動] %s" % result.get("message", ""))
		_set_feedback(result.get("ok", true), result.get("message", ""))
		_refresh()
		return

	# P4-2:self/原地動作（hunt 等,直接執行不需選隊）
	var self_acts: Array = _interact_action_split()["self"]
	var self_idx: int = num - fe_count
	if self_idx >= 0 and self_idx < self_acts.size():
		var sa: Dictionary = self_acts[self_idx]
		if not sa.get("enabled", true):
			_set_feedback(false, sa.get("disabled_reason", "不可執行"))
			_refresh(); return
		var sr: Dictionary = _bridge.command_player(
			sa.get("command_name", "execute_action"), sa.get("command_args", {}))
		_log_event("[原地] %s" % sr.get("message", ""))
		_set_feedback(sr.get("ok", true), sr.get("message", ""))
		_refresh_snapshot()
		if _cached_snapshot.get("player_summary", {}).get("encounter_active", false):
			_interact_mode = false
			_enter_encounter()
		_refresh()
		return

	# pending_targets 選擇
	var pending_idx: int = num - fe_count - self_acts.size()
	var pending_tgts: Array = _cached_snapshot.get("pending_targets", [])
	if pending_idx >= 0 and pending_idx < pending_tgts.size():
		_interact_target = pending_tgts[pending_idx].get("target_id", -1)
		_interact_page = 0   # 進行動清單從頁 0
		_refresh()

# P4-2:分離 self/原地動作(hunt/hunt_beast/establish_faction 等 allowed_kinds 非 team)
# 與 team-target 動作。forced 另由 forced_interaction.responses 處理;move_to/cancel_move 有專鍵。
func _interact_action_split() -> Dictionary:
	var team_acts: Array = []
	var self_acts: Array = []
	for a in _cached_snapshot.get("available_actions", []):
		var tr: Dictionary = a.get("target_requirements", {})
		if tr.get("requires_forced_interaction", false):
			continue
		var aid: String = a.get("action_id", "")
		if aid == "move_to" or aid == "cancel_move":
			continue
		var ak = tr.get("allowed_kinds", PackedStringArray())
		if "team" in ak:
			team_acts.append(a)
		else:
			self_acts.append(a)   # none/tile = 自身/原地動作
	return { "team": team_acts, "self": self_acts }

func _build_interact_str() -> String:
	var lines: Array = []

	# 已選目標：顯示行動清單（只 team-target 動作,self-actions 在目標選擇階段）
	if _interact_target >= 0:
		var tgt_name: String = "Team%d" % _interact_target
		lines.append("── %s 行動 ──" % tgt_name)
		var actions: Array = _interact_action_split()["team"]
		var a_start: int = _interact_page * 9
		var row: String = ""
		var a_shown: int = 0
		for gi in range(a_start, mini(a_start + 9, actions.size())):
			a_shown += 1
			row += "[%d]%s  " % [a_shown, actions[gi].get("label", actions[gi].get("action_id", ""))]
			if a_shown % 4 == 0:
				lines.append(row.strip_edges())
				row = ""
		if not row.strip_edges().is_empty():
			lines.append(row.strip_edges())
		if actions.size() > 9:
			lines.append("第 %d/%d 頁 [,]上 [.]下" % [_interact_page + 1, int(ceil(actions.size() / 9.0))])
		lines.append("── [Esc]返回 ──")
		return "\n".join(lines)

	# 目標選擇階段
	lines.append("── 互動 ──")
	# 合一清單（與 handler 全域索引一致：forced 回應 → self/原地動作 → pending 目標）→ 分頁
	var fi: Dictionary = _cached_snapshot.get("forced_interaction", {})
	var items: Array = []
	if not fi.get("interaction_id", "").is_empty():
		var msg: String = fi.get("message", "強制事件")
		for r in fi.get("responses", []):
			items.append("⚠ %s：%s" % [msg, r.get("label", "?")])
	for sa in _interact_action_split()["self"]:   # P4-2:self/原地動作(hunt 等)直接可選,不需先選隊
		var en: bool = sa.get("enabled", true)
		items.append("%s%s" % [sa.get("label", sa.get("action_id", "")), "" if en else "（不可）"])
	var pending_tgts: Array = _cached_snapshot.get("pending_targets", [])
	var vts: Array = _cached_snapshot.get("visible_teams", [])
	for target_info in pending_tgts:
		var tid: int = target_info.get("target_id", -1)
		var vt: Dictionary = {}
		for v in vts:
			if v.get("id", -1) == tid: vt = v; break
		if vt.is_empty():
			items.append("Team%d" % tid)
			continue
		var pos: Dictionary = vt.get("position", {})
		items.append("Team%d @(%d,%d) %s pop:%d" % [
			tid, pos.get("q", 0), pos.get("r", 0), vt.get("faction_display", "?"), vt.get("population", 0)])
	if items.is_empty():
		lines.append("（無可互動目標）")
	else:
		var t_start: int = _interact_page * 9
		var t_shown: int = 0
		for gi in range(t_start, mini(t_start + 9, items.size())):
			t_shown += 1
			lines.append("[%d] %s" % [t_shown, items[gi]])
		if items.size() > 9:
			lines.append("第 %d/%d 頁 [,]上 [.]下" % [_interact_page + 1, int(ceil(items.size() / 9.0))])

	lines.append("── [T/Esc]關閉 ──")
	return "\n".join(lines)

func _handle_faction_mode(keycode: int) -> void:
	if keycode == KEY_F or keycode == KEY_ESCAPE:
		_faction_mode = false
		_refresh()
		return
	var fp: Dictionary = _bridge.query_faction_panel().get("data", {}).get("faction_panel", {})
	if not fp.get("in_faction", false):
		_faction_mode = false
		_refresh()
		return
	var member_orders: Array = fp.get("member_orders", [])

	var is_faction_leader: bool = fp.get("is_leader", false)

	match keycode:
		KEY_A:   # 設定目標（Q7-6：僅 leader；非 leader no-op,顯示亦不列）
			if not is_faction_leader:
				_refresh()
				return
			_input_mode = true
			_input_mode_type = "string"
			_input_mode_prompt = "設定勢力目標: "
			_input_buffer = ""
			_input_mode_callback = func(buf: String):
				_bridge.set_player_input("faction_goal_input", buf)
				var r := _bridge.command_player("execute_action",
					{"action_id": "set_faction_goal", "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}})
				_log_event("[勢力] %s" % r.get("message", ""))
				_set_feedback(r.get("ok", true), r.get("message", ""))
			_input_bar.text = "%s_" % _input_mode_prompt
		KEY_B:   # 調整徵收率（Q7-6：僅 leader）
			if not is_faction_leader:
				_refresh()
				return
			_input_mode = true
			_input_mode_type = "numeric"
			_input_mode_prompt = "徵收率 (0-100): "
			_input_buffer = ""
			_input_mode_callback = func(buf: String):
				var rate: float = clampf(float(buf) / 100.0, 0.0, 1.0)
				_bridge.set_player_input("tribute_rate_input", rate)
				var r := _bridge.command_player("execute_action",
					{"action_id": "set_tribute_rate", "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}})
				_log_event("[勢力] %s" % r.get("message", ""))
				_set_feedback(r.get("ok", true), r.get("message", ""))
			_input_bar.text = "%s_" % _input_mode_prompt
		KEY_C:   # 離開勢力
			var r := _bridge.command_player("execute_action",
				{"action_id": "leave_faction", "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}})
			_log_event("[勢力] %s" % r.get("message", ""))
			_set_feedback(r.get("ok", true), r.get("message", ""))
		KEY_D:   # 背叛勢力
			var r := _bridge.command_player("execute_action",
				{"action_id": "betray_faction", "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}})
			_log_event("[勢力] %s" % r.get("message", ""))
			_set_feedback(r.get("ok", true), r.get("message", ""))
		KEY_E:   # 解散勢力（僅 leader）
			var r := _bridge.command_player("execute_action",
				{"action_id": "disband_faction", "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}})
			_log_event("[勢力] %s" % r.get("message", ""))
			_set_feedback(r.get("ok", true), r.get("message", ""))
		KEY_G:   # 徵用國庫（僅 leader；高比例二次確認）
			if not fp.get("is_leader", false):
				_set_feedback(false, "只有 Leader 可徵用國庫")
				_refresh()
				return
			if _faction_extract_pending > 0.0:
				# 高比例第二次按 G → 確認執行
				var ratio2: float = _faction_extract_pending
				_faction_extract_pending = -1.0
				_bridge.set_player_input("extract_ratio", ratio2)
				var rc := _bridge.command_player("execute_action",
					{"action_id": "extract_treasury", "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}})
				_log_event("[勢力] %s" % rc.get("message", rc.get("msg", "")))
				_set_feedback(rc.get("ok", false), rc.get("message", rc.get("msg", "")))
				_refresh()
				return
			_input_mode = true
			_input_mode_type = "numeric"
			_input_mode_prompt = "徵用比例 (1-100): "
			_input_buffer = ""
			_input_mode_callback = func(buf: String):
				var ratio: float = clampf(float(buf) / 100.0, 0.0, 1.0)
				if ratio <= 0.0:
					_set_feedback(false, "比例須 (0,100]")
					_refresh()
					return
				if ratio > 0.5:
					# 破壞性高比例 → armed，需再按 G 確認
					_faction_extract_pending = ratio
					_set_feedback(false, "高比例 %.0f%%！再按 [G] 確認徵用" % (ratio * 100.0))
					_refresh()
					return
				_bridge.set_player_input("extract_ratio", ratio)
				var r2 := _bridge.command_player("execute_action",
					{"action_id": "extract_treasury", "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}})
				_log_event("[勢力] %s" % r2.get("message", r2.get("msg", "")))
				_set_feedback(r2.get("ok", false), r2.get("message", r2.get("msg", "")))
				_refresh()
			_input_bar.text = "%s_" % _input_mode_prompt
		_:
			# [1~9] 下令成員
			if keycode >= KEY_1 and keycode <= KEY_9:
				var idx: int = keycode - KEY_1
				if idx < member_orders.size():
					var mo: Dictionary = member_orders[idx]
					var member_tid: int = mo.get("team_id", -1)
					_input_mode = true
					_input_mode_type = "string"
					_input_mode_allow_empty = true
					_input_mode_prompt = "下令 Team%d 任務(空=清除): " % member_tid
					_input_buffer = ""
					_input_mode_callback = func(buf: String):
						_bridge.set_player_input("order_member_id", member_tid)
						var r: Dictionary
						if buf.strip_edges().is_empty():
							r = _bridge.command_player("execute_action",
								{"action_id": "clear_member_order", "target": {"kind": "none", "team_id": member_tid, "member_id": -1, "tile_q": -1, "tile_r": -1}})
						else:
							_bridge.set_player_input("member_task", buf)
							r = _bridge.command_player("execute_action",
								{"action_id": "order_faction_member", "target": {"kind": "none", "team_id": member_tid, "member_id": -1, "tile_q": -1, "tile_r": -1}})
						_log_event("[勢力] %s" % r.get("message", ""))
						_set_feedback(r.get("ok", true), r.get("message", ""))
					_input_bar.text = "%s_" % _input_mode_prompt
	_refresh()

func _build_faction_str() -> String:
	var fp: Dictionary = _bridge.query_faction_panel().get("data", {}).get("faction_panel", {})
	if not fp.get("in_faction", false):
		return "── 勢力面板 ──\n（玩家不在任何勢力）\n[F/Esc]關閉"
	var lines: Array = []
	var role_str: String = "Leader" if fp.get("is_leader", false) else "成員"
	lines.append("── 勢力%d [%s] ──" % [fp.get("faction_id", -1), role_str])
	lines.append("AI 目標: %s   玩家目標: %s" % [
		fp.get("faction_goal", "（無）"),
		fp.get("player_goal_override", "（跟隨 AI）") if not fp.get("player_goal_override", "").is_empty() else "（跟隨 AI）"])
	lines.append("徵收率: %.0f%%" % (fp.get("tribute_rate", 0.0) * 100))
	lines.append("")
	lines.append("── 成員指令 ──")
	var member_orders: Array = fp.get("member_orders", [])
	for i in range(member_orders.size()):
		var mo: Dictionary = member_orders[i]
		var pos: Dictionary = mo.get("tile_pos", {})
		var task_str: String
		if mo.get("pending_task", "") != "":
			task_str = "傳達中（%s）" % mo.get("pending_task", "")
		elif mo.get("commanded_task", "") != "":
			task_str = mo.get("commanded_task", "")
		else:
			task_str = "無"
		var pos_v: Vector2i = mo.get("tile_pos", Vector2i.ZERO) as Vector2i
		lines.append("[%d] Team%d @(%d,%d)  指令: %s" % [
			i + 1, mo.get("team_id", -1), pos_v.x, pos_v.y, task_str])
	lines.append("")
	lines.append("── 行動 ──")
	# Q7-6：[A]目標 / [B]徵收率 僅 leader 可用 → 非 leader 不顯（display 對齊 command 權限）
	if fp.get("is_leader", false):
		lines.append("[A]設定目標  [B]調整徵收率  [C]離開勢力")
		lines.append("[G]徵用國庫（Leader）")
		lines.append("[D]背叛勢力  [E]解散勢力（Leader）")
	else:
		lines.append("[C]離開勢力")
		lines.append("[D]背叛勢力")
	lines.append("[F/Esc]關閉")
	return "\n".join(lines)

func _handle_outpost_mode(keycode: int) -> void:
	if keycode == KEY_O or keycode == KEY_ESCAPE:
		_outpost_mode = false
		_outpost_pending_abandon = false
		_refresh()
		return
	if keycode >= KEY_1 and keycode <= KEY_9:
		var op: Dictionary = _bridge.query_outpost_panel().get("data", {}).get("outpost_panel", {})
		var actions: Array = op.get("actions", [])
		var idx: int = keycode - KEY_1
		if idx < actions.size():
			var action_id: String = actions[idx]
			# 任何非 abandon 的選擇都解除棄置 armed
			var was_armed: bool = _outpost_pending_abandon
			if action_id != "abandon_outpost":
				_outpost_pending_abandon = false
			if action_id == "build_facility":
				_prompt_build_facility(op)
				_refresh()
				return
			if action_id == "abandon_outpost":
				# 破壞性：二次確認
				if not was_armed:
					_outpost_pending_abandon = true
					_set_feedback(false, "棄置據點？再按一次確認")
					_refresh()
					return
				_outpost_pending_abandon = false
				var pos: Vector2i = op.get("tile_pos", Vector2i.ZERO) as Vector2i
				_bridge.set_player_input("abandon_pos", [pos.x, pos.y])
				var ra := _bridge.command_player("execute_action", {
					"action_id": "abandon_outpost",
					"target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}})
				_log_event("[前哨] %s" % ra.get("message", ra.get("msg", "")))
				_set_feedback(ra.get("ok", false), ra.get("message", ra.get("msg", "")))
				_refresh()
				return
			if action_id == "build_outpost":
				# 進入輸入模式：選擇建設類型
				_input_mode = true
				_input_mode_type = "numeric"
				_input_mode_prompt = "建設類型 [1]民用 [2]軍事: "
				_input_buffer = ""
				_input_mode_callback = func(buf: String):
					var btype: String = "civilian" if buf.strip_edges() == "1" else "military"
					_bridge.set_player_input("build_type", btype)
					var r2 := _bridge.command_player("execute_action", {
						"action_id": "build_outpost",
						"target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}})
					_log_event("[前哨] %s" % r2.get("message", ""))
					_set_feedback(r2.get("ok", true), r2.get("message", ""))
				_input_bar.text = "%s_" % _input_mode_prompt
				_refresh()
				return
			else:
				var r := _bridge.command_player("execute_action",
					{"action_id": action_id, "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}})
				_log_event("[前哨] %s" % r.get("message", ""))
				_set_feedback(r.get("ok", true), r.get("message", ""))
	_refresh()

# 蓋設施：列出本 outpost_type 允許且尚有空 slot 的設施 → 數字選 → build_facility
func _facility_choices(otype: String) -> Array:
	var out: Array = []
	for fac in OutpostSystem.FACILITY_DEF:
		if otype in OutpostSystem.FACILITY_DEF[fac]["allowed_outpost"]:
			out.append(fac)
	return out

func _prompt_build_facility(op: Dictionary) -> void:
	var otype: String = op.get("outpost_type", "")
	var choices: Array = _facility_choices(otype)
	if choices.is_empty():
		_set_feedback(false, "此據點類型無可蓋設施")
		return
	var menu: Array = []
	for i in range(choices.size()):
		menu.append("[%d]%s" % [i + 1, choices[i]])
	_input_mode = true
	_input_mode_type = "numeric"
	_input_mode_prompt = "蓋設施 %s 選: " % " ".join(menu)
	_input_buffer = ""
	_input_mode_callback = func(buf: String) -> void:
		var ci: int = int(buf) - 1
		if ci < 0 or ci >= choices.size():
			_set_feedback(false, "無效設施編號")
			_refresh()
			return
		_bridge.set_player_input("facility_type", choices[ci])
		var r := _bridge.command_player("execute_action", {
			"action_id": "build_facility",
			"target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}})
		_log_event("[前哨] %s" % r.get("message", r.get("msg", "")))
		_set_feedback(r.get("ok", false), r.get("message", r.get("msg", "")))
		_refresh()
	_input_bar.text = "%s_" % _input_mode_prompt

func _build_outpost_str() -> String:
	var op: Dictionary = _bridge.query_outpost_panel().get("data", {}).get("outpost_panel", {})
	var lines: Array = []
	var pos: Vector2i = op.get("tile_pos", Vector2i.ZERO) as Vector2i
	lines.append("── 前哨站 @(%d,%d) ──" % [pos.x, pos.y])
	var otype: String = op.get("outpost_type", "")
	lines.append("類型: %s  等級: %d" % [
		otype if otype != "" else "無",
		op.get("outpost_level", 0)])
	if otype != "":
		var fl: int = op.get("farming_level", 0)
		var fm: int = op.get("farming_max", 0)
		var ml: int = op.get("manufacturing_level", 0)
		var mm: int = op.get("manufacturing_max", 0)
		if fm > 0 or mm > 0:
			lines.append("農作: %d/%d  製造: %d/%d" % [fl, fm, ml, mm])
	var owner: int = op.get("outpost_owner", -1)
	lines.append("擁有者: %s  支配權: %s" % [
		"Team%d" % owner if owner >= 0 else "無",
		"是" if op.get("has_control", false) else "否"])
	if op.get("construction_in_progress", false):
		lines.append("施工中：剩餘 %d Tick" % op.get("ticks_left", 0))
	lines.append("")
	lines.append("── 可用行動 ──")
	const ACTION_LABELS: Dictionary = {
		"build_outpost":          "建設前哨站",
		"upgrade_outpost":        "升級等級",
		"upgrade_farming":        "升級農作",
		"upgrade_manufacturing":  "升級製造",
		"demolish_outpost":       "拆除",
		"build_facility":         "蓋設施",
		"abandon_outpost":        "棄置據點",
	}
	var actions: Array = op.get("actions", [])
	if actions.is_empty():
		lines.append("（無可用行動）")
	for i in range(actions.size()):
		lines.append("[%d]%s" % [i + 1, ACTION_LABELS.get(actions[i], actions[i])])
	lines.append("[O/Esc]關閉")
	return "\n".join(lines)

# ── 公庫面板（deposit/withdraw_to_storage）────────────────────────────────────
# 扁平化列：team_res→存入、stored→取出，索引一致供數字鍵選取（對齊 trade mode 模式）
func _storage_rows() -> Array:
	var d: Dictionary = _bridge.query_storage_panel().get("data", {}).get("storage_panel", {})
	var rows: Array = []
	for it in d.get("team_res", []):
		rows.append({"dir": "deposit", "res": it.get("res",""), "qty": it.get("qty",0)})
	for it in d.get("stored", []):
		rows.append({"dir": "withdraw", "res": it.get("res",""), "qty": it.get("qty",0), "cap": it.get("cap",0)})
	return rows

func _build_storage_str() -> String:
	var d: Dictionary = _bridge.query_storage_panel().get("data", {}).get("storage_panel", {})
	if not d.get("feasible", false):
		return "── 公庫 ──\n（%s）\n[K/Esc]離開" % d.get("reason", "")
	var lines: Array = ["── 公庫 ──"]
	var rows: Array = _storage_rows()
	var start: int = _storage_page * 9
	var endi: int = mini(start + 9, rows.size())
	var shown_dep: bool = false
	var shown_wd: bool = false
	for gi in range(start, endi):
		var row: Dictionary = rows[gi]
		var label: int = gi - start + 1
		if row["dir"] == "deposit":
			if not shown_dep: lines.append("存入（我方→公庫）："); shown_dep = true
			lines.append("  [%d] %s ×%d" % [label, row["res"], int(row["qty"])])
		else:
			if not shown_wd: lines.append("取出（公庫→我方）："); shown_wd = true
			lines.append("  [%d] %s ×%d/%d" % [label, row["res"], int(row["qty"]), int(row["cap"])])
	if rows.is_empty():
		lines.append("（公庫與我方皆無可存取資源）")
	if rows.size() > 9:
		lines.append("第 %d/%d 頁 [,]上 [.]下" % [_storage_page + 1, int(ceil(rows.size()/9.0))])
	lines.append("[數字]選項 [K/Esc]離開")
	return "\n".join(lines)

func _handle_storage_mode(keycode: int) -> void:
	if keycode == KEY_K or keycode == KEY_ESCAPE:
		_storage_mode = false; _storage_page = 0; _refresh(); return
	if keycode == KEY_COMMA:
		_storage_page = maxi(0, _storage_page - 1); _refresh(); return
	if keycode == KEY_PERIOD:
		_storage_page += 1; _refresh(); return
	if keycode < KEY_1 or keycode > KEY_9:
		return
	var idx: int = (keycode - KEY_1) + _storage_page * 9
	var rows: Array = _storage_rows()
	if idx >= rows.size(): return
	var row: Dictionary = rows[idx]
	_input_mode = true
	_input_mode_type = "numeric"
	_input_buffer = ""
	_input_mode_prompt = "%s %s 數量: " % ["存" if row["dir"] == "deposit" else "取", row["res"]]
	_input_mode_callback = func(buf: String) -> void:
		var qty: int = int(buf)
		if qty > 0:
			_bridge.set_player_input("storage_res", row["res"])
			_bridge.set_player_input("storage_amount", float(qty))
			var aid: String = "deposit_to_storage" if row["dir"] == "deposit" else "withdraw_from_storage"
			var r: Dictionary = _bridge.command_player("execute_action", {
				"action_id": aid,
				"target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}})
			_set_feedback(r.get("ok", false), r.get("message", r.get("msg", "")))
		_refresh()
	_input_bar.text = "%s_" % _input_mode_prompt

func _handle_subteam_mode(keycode: int) -> void:
	if keycode == KEY_U or keycode == KEY_ESCAPE:
		_subteam_mode = false
		_subteam_selection = -1
		_refresh()
		return
	var sp: Dictionary = _bridge.query_subteam_panel().get("data", {}).get("subteam_panel", {})
	var subteams: Array = sp.get("subteams", [])

	if _subteam_selection == -1:
		# [N] 派遣新子隊
		if keycode == KEY_N:
			var candidates: Array = sp.get("dispatch_candidates", [])
			var max_pop: int = sp.get("player_population", 0)
			if candidates.is_empty():
				_log_event("[子隊] 無可用隊長（需命名非 leader 成員）")
				_refresh()
				return
			# 步驟 1：選隊長
			_input_mode = true
			_input_mode_type = "numeric"
			_input_mode_prompt = "選隊長 (1~%d): " % candidates.size()
			_input_buffer = ""
			_input_mode_callback = func(buf1: String):
				var cidx: int = int(buf1) - 1
				if cidx < 0 or cidx >= candidates.size():
					_log_event("[子隊] 無效隊長編號")
					return
				var leader_id: int = candidates[cidx].get("person_id", -1)
				_bridge.set_player_input("sub_leader_id", leader_id)
				# 步驟 2：人數
				_input_mode = true
				_input_mode_type = "numeric"
				_input_mode_prompt = "派遣人數 (1~%d): " % (max_pop - 1)
				_input_buffer = ""
				_input_mode_callback = func(buf2: String):
					var pop: int = int(buf2)
					_bridge.set_player_input("sub_pop_count", pop)
					# 步驟 3：選任務（Q7-5：非寫死 IDLE,開放合理子集）
					_input_mode = true
					_input_mode_type = "numeric"
					_input_mode_prompt = "選任務 %s: " % _subteam_task_menu_str()
					_input_buffer = ""
					_input_mode_callback = func(buf_task: String):
						var task_id: String = _subteam_task_from_index(int(buf_task))
						_bridge.set_player_input("sub_task", task_id)
						# 步驟 4：目標 q
						_input_mode = true
						_input_mode_type = "numeric"
						_input_mode_prompt = "目標格 Q: "
						_input_buffer = ""
						_input_mode_callback = func(buf3: String):
							var dq: int = int(buf3)
							_bridge.set_player_input("sub_move_q", dq)
							# 步驟 5：目標 r → 執行
							_input_mode = true
							_input_mode_type = "numeric"
							_input_mode_prompt = "目標格 R: "
							_input_buffer = ""
							_input_mode_callback = func(buf4: String):
								var dr: int = int(buf4)
								_bridge.set_player_input("sub_move_r", dr)
								var res := _bridge.command_player("execute_action", {
									"action_id": "dispatch_subteam",
									"target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}})
								_log_event("[子隊] %s" % res.get("message", ""))
								_set_feedback(res.get("ok", true), res.get("message", ""))
							_input_bar.text = "目標格 R: _"
						_input_bar.text = "目標格 Q: _"
					_input_bar.text = "選任務 %s: _" % _subteam_task_menu_str()
				_input_bar.text = "派遣人數 (1~%d): _" % (max_pop - 1)
			_input_bar.text = "選隊長 (1~%d): _" % candidates.size()
			_refresh()
			return
		# 選子隊
		if keycode >= KEY_1 and keycode <= KEY_9:
			var idx: int = keycode - KEY_1
			if idx < subteams.size():
				_subteam_selection = subteams[idx].get("team_id", -1)
		_refresh()
		return

	# 已選子隊：[A] 下令移動, [B] 召回
	match keycode:
		KEY_A:
			_input_mode = true
			_input_mode_type = "numeric"
			_input_mode_prompt = "目標 q（按 Enter 繼續）: "
			_input_buffer = ""
			var sub_id_cap: int = _subteam_selection
			_input_mode_callback = func(buf_q: String):
				var q_val: int = int(buf_q)
				_input_mode = true
				_input_mode_type = "numeric"
				_input_mode_prompt = "目標 r: "
				_input_buffer = ""
				_input_mode_callback = func(buf_r: String):
					var r_val: int = int(buf_r)
					# Q7-5：order 同樣開放任務選擇（非寫死 IDLE）
					_input_mode = true
					_input_mode_type = "numeric"
					_input_mode_prompt = "選任務 %s: " % _subteam_task_menu_str()
					_input_buffer = ""
					_input_mode_callback = func(buf_t: String):
						var new_task_id: String = _subteam_task_from_index(int(buf_t))
						_bridge.set_player_input("order_sub_id", sub_id_cap)
						_bridge.set_player_input("sub_new_move_q", q_val)
						_bridge.set_player_input("sub_new_move_r", r_val)
						_bridge.set_player_input("sub_new_task", new_task_id)
						var res := _bridge.command_player("execute_action",
							{"action_id": "order_subteam", "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}})
						_log_event("[子隊] %s" % res.get("message", ""))
						_set_feedback(res.get("ok", true), res.get("message", ""))
						_subteam_selection = -1
					_input_bar.text = "選任務 %s: _" % _subteam_task_menu_str()
				_input_bar.text = "%s_" % _input_mode_prompt
			_input_bar.text = "%s_" % _input_mode_prompt
		KEY_B:
			_bridge.set_player_input("recall_sub_id", _subteam_selection)
			var r := _bridge.command_player("execute_action",
				{"action_id": "recall_subteam", "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}})
			_log_event("[子隊] %s" % r.get("message", ""))
			_set_feedback(r.get("ok", true), r.get("message", ""))
			_subteam_selection = -1
	_refresh()

func _build_subteam_str() -> String:
	var sp: Dictionary = _bridge.query_subteam_panel().get("data", {}).get("subteam_panel", {})
	var subteams: Array = sp.get("subteams", [])
	var candidates: Array = sp.get("dispatch_candidates", [])
	var lines: Array = []
	lines.append("── 子隊 ──")
	if subteams.is_empty():
		lines.append("（無子隊）")
	for i in range(subteams.size()):
		var st: Dictionary = subteams[i]
		var pos_v: Vector2i = st.get("tile_pos", Vector2i.ZERO) as Vector2i
		var task_str: String = st.get("player_commanded_task", st.get("current_task", "?"))
		var selected_mark: String = "* " if st.get("team_id", -1) == _subteam_selection else "  "
		lines.append("[%d]%sTeam%d @(%d,%d)  %s  人口:%d" % [
			i + 1, selected_mark, st.get("team_id", -1), pos_v.x, pos_v.y,
			task_str, st.get("population", 0)])
		if st.get("team_id", -1) == _subteam_selection:
			var pop: int = sp.get("player_population", 0)
			var can_recall: bool = not candidates.is_empty() and pop >= 2
			if can_recall:
				lines.append("    [A]下令移動  [B]召回")
			else:
				var reason: String = "人數不足" if pop < 2 else "需命名非 leader 成員"
				lines.append("    [A]下令移動  [B]召回（不可：%s）" % reason)
	lines.append("")
	lines.append("── 可派遣隊長 ──")
	if candidates.is_empty():
		# N-1: 全 anon 隊死路引導——有 anon 可拔擢時告知去互動選單 promote_anon（補 Q7-4 發現性）
		if int(sp.get("anon_count", 0)) > 0:
			lines.append("（無可用隊長——先到互動選單『拔擢匿名→記名』培養成員）")
		else:
			lines.append("（無：需命名非 leader 成員）")
	for i in range(candidates.size()):
		lines.append("  %d. %s" % [i + 1, candidates[i].get("name", "?")])
	if not candidates.is_empty():
		lines.append("[N]派遣新子隊")
	lines.append("[U/Esc]關閉")
	return "\n".join(lines)

func _handle_advisor_mode(keycode: int) -> void:
	if keycode == KEY_V or keycode == KEY_ESCAPE:
		_advisor_mode = false
		_advisor_selection = -1
		_refresh()
		return
	var members: Array = _cached_snapshot.get("members_detail", [])
	if keycode >= KEY_1 and keycode <= KEY_9:
		var idx: int = keycode - KEY_1
		if idx < members.size():
			_advisor_selection = members[idx].get("id", -1)
			if _advisor_selection >= 0:
				_input_mode = true
				_input_mode_type = "string"
				_input_mode_prompt = "情境關鍵字 (attack/diplomacy/resource): "
				_input_buffer = ""
				var advisor_pid_cap: int = _advisor_selection
				_input_mode_callback = func(buf: String):
					var advice: String = _bridge.query_advisor_advice(advisor_pid_cap, buf)
					_log_event("[Advisor] 建議：%s" % advice)
				_input_bar.text = "%s_" % _input_mode_prompt
	_refresh()

func _build_advisor_str() -> String:
	var members: Array = _cached_snapshot.get("members_detail", [])
	var lines: Array = []
	lines.append("── 顧問 ──")
	if members.is_empty():
		lines.append("（無可用顧問）")
	for i in range(members.size()):
		var m: Dictionary = members[i]
		var skills: Dictionary = m.get("skills", {})
		lines.append("[%d] %s  計謀:%.1f 交涉:%.1f 戰術:%.1f" % [
			i + 1, m.get("name", "?"),
			float(skills.get("計謀", 0)),
			float(skills.get("交涉", 0)),
			float(skills.get("戰術", 0))])
	lines.append("選顧問後輸入情境關鍵字 (attack/diplomacy/resource)")
	lines.append("[V/Esc]關閉")
	return "\n".join(lines)

func _handle_pre_encounter_mode(keycode: int) -> void:
	var ps: Dictionary = _cached_snapshot.get("player_summary", {})
	var atk_id: int = ps.get("pre_encounter_attacker_id", -1)
	var target: Dictionary = {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}
	match keycode:
		KEY_1:
			var r := _bridge.command_player("execute_action",
				{"action_id": "accept_encounter", "target": target})
			_log_event("[遭遇] %s" % r.get("message", ""))
			_set_feedback(r.get("ok", true), r.get("message", ""))
			_pre_encounter_mode = false
			# encounter_active 現在為 true，下一幀 _process 會偵測並進入 encounter_view
			_refresh()
		KEY_2:
			var r := _bridge.command_player("execute_action",
				{"action_id": "surrender_pre_encounter", "target": target})
			_log_event("[遭遇] %s" % r.get("message", ""))
			_set_feedback(r.get("ok", true), r.get("message", ""))
			_pre_encounter_mode = false
			# 若投降遭拒，encounter_active = true，下一幀進入 encounter_view
			_refresh_snapshot()
			if _cached_snapshot.get("player_summary", {}).get("encounter_active", false):
				_enter_encounter()
			else:
				_refresh()
		_:
			pass   # 其他鍵不處理，玩家必須明確選擇

func _build_pre_encounter_str() -> String:
	var ps: Dictionary = _cached_snapshot.get("player_summary", {})
	var atk_id: int = ps.get("pre_encounter_attacker_id", -1)
	var lines: Array = []
	lines.append("！ 遭受攻擊 ！")
	lines.append("Team%d 向你發起進攻" % atk_id)
	lines.append("")
	lines.append("[1] 迎擊（進入戰場）")
	lines.append("[2] 投降（嘗試免戰，對方可能拒絕）")
	return "\n".join(lines)

func _handle_trade_mode(keycode: int) -> void:
	# 翻頁（清單 >9 項）
	if keycode == KEY_COMMA:
		_trade_page = maxi(0, _trade_page - 1); _refresh(); return
	if keycode == KEY_PERIOD:
		_trade_page += 1; _refresh(); return
	# 離開（清出價）
	if keycode == KEY_ESCAPE:
		_bridge.command_player("execute_action", {
			"action_id": "cancel_trade",
			"target": {"kind": "team", "team_id": _trade_target_id,
						"member_id": -1, "tile_q": -1, "tile_r": -1}})
		_bridge.set_player_input("trade_offer", {})
		_log_event("[交易] 已離開")
		_trade_mode = false; _trade_target_id = -1; _trade_page = 0
		_refresh(); return
	# 清空出價
	if keycode == KEY_C:
		_bridge.set_player_input("trade_offer", {"player_gives": {}, "player_wants": {}})
		_refresh(); return
	# 送出
	if keycode == KEY_ENTER or keycode == KEY_KP_ENTER:
		var r: Dictionary = _bridge.command_player("execute_action", {
			"action_id": "submit_trade_offer",
			"target": {"kind": "team", "team_id": _trade_target_id,
						"member_id": -1, "tile_q": -1, "tile_r": -1}})
		_log_event("[交易] %s" % r.get("message", ""))
		_set_feedback(r.get("ok", false), r.get("message", ""))
		if r.get("ok", false):
			_trade_mode = false; _trade_target_id = -1; _trade_page = 0
		_refresh(); return
	# 數字選項 → 選清單某項 → 收數量
	if keycode < KEY_1 or keycode > KEY_9:
		return
	var idx: int = (keycode - KEY_1) + _trade_page * 9
	var rows: Array = _trade_session_rows()
	if idx >= rows.size():
		return
	var row: Dictionary = rows[idx]
	_input_mode = true
	_input_mode_type = "numeric"
	_input_buffer = ""
	_input_mode_prompt = "%s %s 數量: " % ["給" if row["side"] == "give" else "要", row["grade"]]
	_input_mode_callback = func(buf: String) -> void:
		var qty: int = int(buf)
		if qty > 0:
			_trade_add(row["side"], row["grade"], qty)
		_refresh()
	_input_bar.text = "%s_" % _input_mode_prompt

# offer-builder 列：player_items→「我給」、target_items→「我要」，扁平化供索引一致
func _trade_session_rows() -> Array:
	var d: Dictionary = _bridge.query_trade_session(_trade_target_id).get("data", {})
	var rows: Array = []
	for it in d.get("player_items", []):
		rows.append({"side": "give", "grade": it.get("grade", ""),
			"qty": it.get("qty", 0), "unit_value": it.get("unit_value", 0.0)})
	for it in d.get("target_items", []):
		rows.append({"side": "want", "grade": it.get("grade", ""),
			"qty": it.get("qty", 0), "unit_value": it.get("unit_value", 0.0)})
	return rows

# 加一項到當前出價（讀 DTO 既有出價→寫回，守 UI 邊界：不直存 state）
func _trade_add(side: String, grade: String, qty: int) -> void:
	var d: Dictionary = _bridge.query_trade_session(_trade_target_id).get("data", {})
	var off: Dictionary = d.get("offer", {})
	var gives: Dictionary = (off.get("gives", {}) as Dictionary).duplicate()
	var wants: Dictionary = (off.get("wants", {}) as Dictionary).duplicate()
	if side == "give":
		gives[grade] = float(gives.get(grade, 0)) + qty
	else:
		wants[grade] = float(wants.get(grade, 0)) + qty
	_bridge.set_player_input("trade_offer", {"player_gives": gives, "player_wants": wants})

func _build_trade_str() -> String:
	var lines: Array = ["── 物物交換 Team%d ──" % _trade_target_id]
	if _trade_target_id < 0:
		lines.append("（目標無效）"); lines.append("[Esc]離開")
		return "\n".join(lines)
	var d: Dictionary = _bridge.query_trade_session(_trade_target_id).get("data", {})
	if not d.get("feasible", false):
		lines.append("（需與對方同格才能交易）"); lines.append("[Esc]離開")
		return "\n".join(lines)
	var rows: Array = _trade_session_rows()
	var start: int = _trade_page * 9
	var endi: int = mini(start + 9, rows.size())
	var shown_give: bool = false
	var shown_want: bool = false
	for gi in range(start, endi):
		var row: Dictionary = rows[gi]
		var label: int = gi - start + 1
		if row["side"] == "give":
			if not shown_give:
				lines.append("我給（我方物資）："); shown_give = true
		else:
			if not shown_want:
				lines.append("我要（對方物資）："); shown_want = true
		lines.append("  [%d] %s ×%d (值%.1f)" % [label, row["grade"], int(row["qty"]), float(row["unit_value"])])
	if rows.size() > 9:
		lines.append("第 %d/%d 頁 [,]上 [.]下" % [_trade_page + 1, int(ceil(rows.size() / 9.0))])
	# 當前出價
	var off: Dictionary = d.get("offer", {})
	var gives: Dictionary = off.get("gives", {})
	var wants: Dictionary = off.get("wants", {})
	var go: Array = []
	for k in gives: go.append("%s×%d" % [k, int(gives[k])])
	var wo: Array = []
	for k in wants: wo.append("%s×%d" % [k, int(wants[k])])
	lines.append("出價：給 %s ⇄ 要 %s" % [
		"—" if go.is_empty() else "、".join(go),
		"—" if wo.is_empty() else "、".join(wo)])
	# 天平 + NPC 接受預估
	var acc: String = ""
	if not gives.is_empty() or not wants.is_empty():
		acc = "  NPC:%s" % ("✓接受" if d.get("npc_would_accept", false) else "✗拒絕")
	lines.append("給值 %.1f ⇄ 要值 %.1f%s" % [
		float(d.get("give_value", 0.0)), float(d.get("want_value", 0.0)), acc])
	lines.append("[數字]選項 [Enter]送出 [C]清 [Esc]離開")
	return "\n".join(lines)

func _handle_intel_mode(keycode: int) -> void:
	if keycode == KEY_ESCAPE:
		_intel_mode = false
		_intel_options = []
		_refresh()
		return
	if keycode >= KEY_1 and keycode <= KEY_9:
		var idx: int = keycode - KEY_1
		if idx < _intel_options.size():
			var choice: String = _intel_options[idx].get("id", "")
			_bridge.set_player_input("gather_intel_npc_id", _intel_target_id)
			_bridge.set_player_input("gather_intel_choice", choice)
			var r := _bridge.command_player("execute_action",
				{"action_id": "confirm_gather_intel",
				 "target": {"kind": "none", "team_id": _intel_target_id, "member_id": -1, "tile_q": -1, "tile_r": -1}})
			_log_event("[Inquiry] %s" % r.get("message", ""))
			_set_feedback(r.get("ok", true), r.get("message", ""))
			_intel_mode = false
			_intel_options = []
	_refresh()

func _build_intel_str() -> String:
	var lines: Array = []
	lines.append("── 打聽 Team%d ──" % _intel_target_id)
	if _intel_options.is_empty():
		lines.append("（無可用問題）")
	for i in range(_intel_options.size()):
		lines.append("[%d] %s" % [i + 1, _intel_options[i].get("label", "?")])
	lines.append("[1~5]選題  [Esc]取消")
	return "\n".join(lines)

# 招募子模式：列記名候選（[1..N]）+ 匿名選項（[0/A]）。reuse 既有 command 路徑,勿複製招募邏輯。
func _handle_recruit_mode(keycode: int) -> void:
	if keycode == KEY_ESCAPE:
		_exit_recruit_mode()
		return
	# 匿名招募：[A] 或 [0]
	if (keycode == KEY_A or keycode == KEY_0) and _recruit_anon_available:
		var ra: Dictionary = _bridge.command_player("execute_action", {
			"action_id": "recruit_anon",
			"target": {"kind": "team", "team_id": _recruit_target_id,
					   "member_id": -1, "tile_q": -1, "tile_r": -1}})
		_log_event("[招募] %s" % ra.get("message", ra.get("msg", "")))
		_set_feedback(ra.get("ok", true), ra.get("message", ra.get("msg", "")))
		_exit_recruit_mode()
		return
	# 記名招募：[1..N] 選候選 → recruit_named（member-kind，經 execute_action_with_target）
	if keycode >= KEY_1 and keycode <= KEY_9:
		var idx: int = keycode - KEY_1
		if idx < _recruit_members.size():
			var pid_r: int = int(_recruit_members[idx].get("person_id", -1))
			var rn: Dictionary = _bridge.command_player("execute_action", {
				"action_id": "recruit_named",
				"target": {"kind": "member", "team_id": _recruit_target_id,
						   "member_id": pid_r, "tile_q": -1, "tile_r": -1}})
			_log_event("[招募] %s" % rn.get("message", rn.get("msg", "")))
			_set_feedback(rn.get("ok", true), rn.get("message", rn.get("msg", "")))
			_exit_recruit_mode()
	_refresh()

func _exit_recruit_mode() -> void:
	_recruit_mode = false
	_recruit_target_id = -1
	_recruit_members = []
	_recruit_anon_available = false
	_bridge.refresh_interaction_targets()   # 招募後重掃同格（pop/named 已變）
	_refresh()

func _build_recruit_str() -> String:
	var lines: Array = ["── 招募 Team%d ──" % _recruit_target_id]
	if _recruit_members.is_empty():
		lines.append("（無願投靠的記名成員）")
	for i in range(_recruit_members.size()):
		var m: Dictionary = _recruit_members[i]
		lines.append("[%d] %s 忠誠%.2f %s（記名 %d coin）" % [
			i + 1, m.get("name", "?"), float(m.get("loyalty", 0.0)),
			m.get("top_skill", "—"), _recruit_named_cost])
	if _recruit_anon_available:
		lines.append("[A] 招募匿名人口（%d coin）" % _recruit_anon_cost)
	else:
		lines.append("[A] 匿名招募（不可用：金幣不足或無匿名人口）")
	lines.append("[1~9]記名  [A]匿名  [Esc]取消")
	return "\n".join(lines)

func _close_all_modes(keep: String = "") -> void:
	if keep != "interact": _interact_mode = false; _interact_target = -1
	if keep != "member":   _member_mode   = false
	if keep != "inv":      _inv_mode      = false; _inv_selection   = -1
	if keep != "faction":  _faction_mode  = false
	if keep != "outpost":  _outpost_mode  = false
	if keep != "subteam":  _subteam_mode  = false
	if keep != "advisor":  _advisor_mode  = false
	if keep != "storage":  _storage_mode  = false; _storage_page = 0
	_outpost_pending_abandon = false
	_faction_extract_pending = -1.0
	_intel_mode          = false
	_recruit_mode        = false
	_recruit_target_id   = -1
	_recruit_members     = []
	_recruit_anon_available = false
	_trade_mode          = false
	_trade_target_id     = -1
	_pre_encounter_mode  = false

func _check_alerts() -> void:
	var new_alerts: Array = _bridge.get_and_clear_alerts()
	for a in new_alerts:
		var atype: String = a.get("type", "")
		var text: String
		match atype:
			"food_critical":            text = "警告：糧食危急"
			"faction_member_betrayed":  text = "警告：勢力成員叛離"
			_:                          text = "警告：%s" % a.get("description", atype)
		_pending_alerts.append(text)
	if not _pending_alerts.is_empty():
		_alert_bar.text = "[!] %s  [Z 確認]" % _pending_alerts[0]
	else:
		_alert_bar.text = ""
