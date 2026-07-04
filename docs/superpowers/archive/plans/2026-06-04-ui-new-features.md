# UI New Features Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 暴露 batch1-3 新功能的 UI 入口：勢力面板 [F]、前哨站面板 [O]、子隊面板 [U]、顧問模式 [V]、Alert Bar、gather_intel 子模式、encounter_view [S][J] 按鍵。

**Architecture:** WorldState 加 player_pending_orders 欄位；interaction_system._deliver_order 偵測 player herald 並設 player_commanded_task；_action_order_faction_member 改用信使機制；text_ui_main.gd 加 4 個新 mode + alert bar + intel submode；encounter_view.gd 加 2 個按鍵。

**Tech Stack:** Godot 4.2.2 GDScript。前置條件：Plan 1（ui-api-completeness）已完成。Plan 2（ui-state-decoupling）可選，新功能只新增 code 不衝突。

---

## 檔案結構

| 檔案 | 改動 |
|---|---|
| `scripts/data/world_state.gd` | 加 `player_pending_orders: Dictionary = {}` |
| `scripts/simulation/interaction_system.gd` | `_deliver_order` 加 player herald 偵測 |
| `scripts/simulation/player_command_system.gd` | `_action_order_faction_member` 改用 herald |
| `scripts/ui/text_ui_main.gd` | 加 4 mode + alert bar + intel submode + 彈性 input mode |
| `scripts/ui/encounter_view.gd` | 加 [S] surrender + [J] subjugate |

---

### Task 1: WorldState.player_pending_orders + _deliver_order 延伸

**Files:**
- Modify: `scripts/data/world_state.gd`
- Modify: `scripts/simulation/interaction_system.gd`

- [ ] **Step 1: 在 world_state.gd 加 player_pending_orders**

在 `var player_alerts: Array = []` 後加：

```gdscript
var player_pending_orders: Dictionary = {}
# 格式：{ member_team_id(String) → { "task": String, "herald_id": int } }
# 信使出發後寫入；信使抵達同格後 interaction_system 清除並設 player_commanded_task
```

同時，在 Plan 1 已寫入的 `PlayerApiMapper.map_faction_panel`（`scripts/simulation/player_api_mapper.gd`）裡，找到舊的相容讀法：

```gdscript
var pending_orders: Dictionary = state.get("player_pending_orders", {}) \
	if state.has_method("get") else {}
```

替換成：

```gdscript
var pending_orders: Dictionary = state.player_pending_orders
```

- [ ] **Step 2: 在 interaction_system._deliver_order 加 player herald 偵測**

找到 `_deliver_order` 函式（約 line 815）。在 `target.current_task = order` **之後**，`messenger.current_task = "idle"` **之前**，插入：

```gdscript
	# player herald：若信使是玩家下令派出的，同時更新 player_commanded_task
	var str_target_id: String = str(target_id)
	if state.player_pending_orders.has(str_target_id):
		var pending: Dictionary = state.player_pending_orders[str_target_id]
		if pending.get("herald_id", -1) == messenger_id:
			target.player_commanded_task = order
			state.player_pending_orders.erase(str_target_id)
			print("[Order] player herald 抵達 Team%d，player_commanded_task = %s" % [target_id, order])
```

完整修改後的 `_deliver_order`（供確認）：

```gdscript
func _deliver_order(state: WorldState, messenger_id: int, target_id: int) -> void:
	var messenger: TeamData = state.teams[messenger_id]
	var target: TeamData    = state.teams[target_id]
	var order: String = messenger.order_task if messenger.order_task != "" else "idle"
	target.current_task = order
	# player herald 偵測
	var str_target_id: String = str(target_id)
	if state.player_pending_orders.has(str_target_id):
		var pending: Dictionary = state.player_pending_orders[str_target_id]
		if pending.get("herald_id", -1) == messenger_id:
			target.player_commanded_task = order
			state.player_pending_orders.erase(str_target_id)
			print("[Order] player herald 抵達 Team%d，player_commanded_task = %s" % [target_id, order])
	messenger.current_task    = "idle"
	messenger.order_target_id = -1
	messenger.order_task      = ""
	var parent: TeamData = state.teams.get(messenger.parent_team_id)
	if parent != null:
		messenger.move_target = parent.tile_pos
	if messenger.parent_team_id != -1:
		state.snapshot_faction_member(messenger.parent_team_id, state.world.current_tick)
	_msg.emit_message(state, "order_delivered",
		TextBank.fmt("order_delivered", "honest", {
			"origin": str(messenger_id), "target": str(target_id), "task": order
		}),
		messenger,
		{ "origin": str(messenger_id), "target": str(target_id), "task": order })
	print("[Order] Team%d 傳令 Team%d → %s" % [messenger_id, target_id, order])
```

- [ ] **Step 3: 跑 headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

Expected: `=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 4: Commit**

```
git add scripts/data/world_state.gd scripts/simulation/interaction_system.gd scripts/simulation/player_api_mapper.gd
git commit -m "feat(data): add player_pending_orders; feat(interaction): player herald detection in _deliver_order"
```

---

### Task 2: _action_order_faction_member 改用信使

**Files:**
- Modify: `scripts/simulation/player_command_system.gd`

- [ ] **Step 1: 替換整個 _action_order_faction_member**

找到 `_action_order_faction_member`（約 line 489-501），替換為：

```gdscript
func _action_order_faction_member(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	var member_id: int    = int(state.player_state.get("order_member_id", -1))
	var m_task: String    = str(state.player_state.get("member_task", ""))
	var member_team: TeamData = state.teams.get(member_id)
	if member_team == null:
		return { "ok": false, "msg": "目標成員不存在" }
	if m_task.is_empty():
		return { "ok": false, "msg": "未指定任務" }
	if pt.population < 2:
		return { "ok": false, "msg": "人數不足以派信使" }
	# 從 named_members 選一非 leader 的成員當信使
	var herald_leader_id: int = -1
	for pid in pt.named_members:
		if pid != pt.leader_id:
			herald_leader_id = pid
			break
	if herald_leader_id == -1:
		return { "ok": false, "msg": "無可用的信使人選（需至少一名非隊長的記名成員）" }
	var herald_id: int = SubteamSystem.new().dispatch(
		state, pt_id, herald_leader_id, 1, TeamData.TASK_HERALD,
		member_team.tile_pos, member_id, m_task)
	if herald_id == -1:
		return { "ok": false, "msg": "派信使失敗" }
	# 寫入 player_pending_orders 供 UI 顯示「傳達中」狀態
	state.player_pending_orders[str(member_id)] = {"task": m_task, "herald_id": herald_id}
	print("[PlayerCmd] order_faction_member Team%d → herald Team%d 傳達任務: %s" % [member_id, herald_id, m_task])
	return { "ok": true, "msg": "信使 Team%d 已出發至 Team%d" % [herald_id, member_id] }
```

- [ ] **Step 2: 跑 headless test**

Expected: `=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 3: Commit**

```
git add scripts/simulation/player_command_system.gd
git commit -m "feat(player): order_faction_member now uses herald mechanism (TASK_HERALD)"
```

---

### Task 3: text_ui_main.gd — 新變數 + 彈性 input mode + alert bar

**Files:**
- Modify: `scripts/ui/text_ui_main.gd`

- [ ] **Step 1: 在現有 mode 變數後加新 mode 變數**

找到 `var _interact_mode: bool = false` 等現有 mode 變數，在其後加：

```gdscript
# ── 新 Panel Modes（互斥）────────────────────────────────────────────────────
var _faction_mode:  bool = false
var _outpost_mode:  bool = false
var _subteam_mode:  bool = false
var _advisor_mode:  bool = false
var _subteam_selection: int = -1   # 當前選中的子隊 team_id
var _advisor_selection: int = -1   # 當前選中的顧問 person_id

# ── gather_intel submode ─────────────────────────────────────────────────────
var _intel_mode: bool = false
var _intel_target_id: int = -1
var _intel_options: Array = []     # Array[Dictionary] 每項 {"label": String}

# ── Alert bar ────────────────────────────────────────────────────────────────
var _pending_alerts: Array = []    # Array[String] 待顯示的警報文字
var _alert_bar: Label              # 動態建立，置於 InputBar 上方
```

- [ ] **Step 2: 擴充 input_mode 支援字串輸入**

找到現有的 `var _input_mode: bool` 和 `var _input_buffer: String`，在其後加：

```gdscript
var _input_mode_type: String = "numeric"   # "numeric" | "string"
var _input_mode_callback: Callable         # (buffer: String) -> void
var _input_mode_prompt: String = ""
```

- [ ] **Step 3: 在 _ready() 末尾（_refresh() 前）建立 alert_bar**

```gdscript
	# 動態建立 alert bar（置於 InputBar 之前）
	_alert_bar = Label.new()
	_alert_bar.name = "AlertBar"
	_alert_bar.modulate = Color(1.0, 0.8, 0.0)   # 黃色警報
	var vbox: Node = _input_bar.get_parent()
	vbox.add_child(_alert_bar)
	vbox.move_child(_alert_bar, _input_bar.get_index())
	_refresh()
```

**注意：** 若 _ready() 原本最後一行是 `_refresh()`，移除那行並讓以上的 `_refresh()` 取代。

- [ ] **Step 4: 替換 _handle_input_mode() 支援字串 + callback**

將現有 `_handle_input_mode()` 替換：

```gdscript
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
				if _input_buffer.length() > 0:
					_input_mode = false
					_input_bar.text = ""
					if _input_mode_callback.is_valid():
						_input_mode_callback.call(_input_buffer)
					_input_buffer = ""
					_refresh()
			KEY_ESCAPE:
				_input_mode = false
				_input_buffer = ""
				_input_bar.text = ""
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
```

**注意：** `KEY_G`（跳過 tick）的觸發邏輯要對應更新 prompt：

```gdscript
KEY_G:
	_input_mode = true
	_input_mode_type = "numeric"
	_input_mode_prompt = "跳過 tick 數: "
	_input_buffer = ""
	_input_mode_callback = Callable()   # 無 callback → 使用舊有行為
	_input_bar.text = "跳過 tick 數: _"
```

- [ ] **Step 5: 加 _close_all_modes() + _check_alerts() 輔助函式**

在文件末尾加：

```gdscript
func _close_all_modes(keep: String = "") -> void:
	if keep != "interact": _interact_mode = false; _interact_target = -1
	if keep != "member":   _member_mode   = false
	if keep != "inv":      _inv_mode      = false; _inv_selection   = -1
	if keep != "faction":  _faction_mode  = false
	if keep != "outpost":  _outpost_mode  = false
	if keep != "subteam":  _subteam_mode  = false
	if keep != "advisor":  _advisor_mode  = false
	_intel_mode = false

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
```

- [ ] **Step 6: 在 _refresh() 加 _check_alerts() 呼叫**

在 `_refresh()` 函式末尾（return 前）加：

```gdscript
	_check_alerts()
```

- [ ] **Step 7: 加 [Z] dismiss alert 按鍵**

在主 `_input()` 的 match 區塊加：

```gdscript
KEY_Z:
	if not _pending_alerts.is_empty():
		_pending_alerts.pop_front()
	_check_alerts()
```

- [ ] **Step 8: 跑 headless test**

Expected: `=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 9: Commit**

```
git add scripts/ui/text_ui_main.gd
git commit -m "feat(ui): add mode vars, flexible input mode, alert bar to text_ui_main"
```

---

### Task 4: text_ui_main.gd — [F] 勢力面板

**Files:**
- Modify: `scripts/ui/text_ui_main.gd`

前置：Plan 1 的 `_bridge.query_faction_panel()` 已實裝。

- [ ] **Step 1: 在主 input handler 加 [F] 鍵**

在現有 `KEY_T` 或 `KEY_P` 的 match 區塊旁加：

```gdscript
KEY_F:
	_faction_mode = not _faction_mode
	if _faction_mode: _close_all_modes("faction")
	_refresh()
```

- [ ] **Step 2: 在 _input() 頂部 mode 路由加 _faction_mode 判斷**

在 `if _member_mode:` 的 `_handle_member_mode(event.keycode)` 後加：

```gdscript
	if _faction_mode:
		_handle_faction_mode(event.keycode)
		return
```

- [ ] **Step 3: 加 _handle_faction_mode()**

```gdscript
func _handle_faction_mode(keycode: int) -> void:
	if keycode == KEY_F or keycode == KEY_ESCAPE:
		_faction_mode = false
		_refresh()
		return
	var fp: Dictionary = _bridge.query_faction_panel().get("data", {})
	if not fp.get("in_faction", false):
		_faction_mode = false
		_refresh()
		return
	var member_orders: Array = fp.get("member_orders", [])

	match keycode:
		KEY_A:   # 設定目標
			_input_mode = true
			_input_mode_type = "string"
			_input_mode_prompt = "設定勢力目標: "
			_input_buffer = ""
			_input_mode_callback = func(buf: String):
				_bridge.set_player_input("faction_goal_input", buf)
				var r := _bridge.command_player("execute_action",
					{"action_id": "set_faction_goal", "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}})
				_log_event("[勢力] %s" % r.get("message", ""))
			_input_bar.text = "%s_" % _input_mode_prompt
		KEY_B:   # 調整徵收率
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
			_input_bar.text = "%s_" % _input_mode_prompt
		KEY_C:   # 離開勢力
			var r := _bridge.command_player("execute_action",
				{"action_id": "leave_faction", "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}})
			_log_event("[勢力] %s" % r.get("message", ""))
		KEY_D:   # 背叛勢力
			var r := _bridge.command_player("execute_action",
				{"action_id": "betray_faction", "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}})
			_log_event("[勢力] %s" % r.get("message", ""))
		KEY_E:   # 解散勢力（僅 leader）
			var r := _bridge.command_player("execute_action",
				{"action_id": "disband_faction", "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}})
			_log_event("[勢力] %s" % r.get("message", ""))
		_:
			# [1~9] 下令成員
			if keycode >= KEY_1 and keycode <= KEY_9:
				var idx: int = keycode - KEY_1
				if idx < member_orders.size():
					var mo: Dictionary = member_orders[idx]
					var member_tid: int = mo.get("team_id", -1)
					_input_mode = true
					_input_mode_type = "string"
					_input_mode_prompt = "下令 Team%d 任務: " % member_tid
					_input_buffer = ""
					_input_mode_callback = func(buf: String):
						_bridge.set_player_input("order_member_id", member_tid)
						_bridge.set_player_input("member_task", buf)
						var r := _bridge.command_player("execute_action",
							{"action_id": "order_faction_member", "target": {"kind": "none", "team_id": member_tid, "member_id": -1, "tile_q": -1, "tile_r": -1}})
						_log_event("[勢力] %s" % r.get("message", ""))
					_input_bar.text = "%s_" % _input_mode_prompt
	_refresh()
```

- [ ] **Step 4: 加 _build_faction_str()**

```gdscript
func _build_faction_str() -> String:
	var fp: Dictionary = _bridge.query_faction_panel().get("data", {})
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
		var pos_v: Vector2i = pos if pos is Vector2i else Vector2i(pos.get("x", 0), pos.get("y", 0))
		lines.append("[%d] Team%d @(%d,%d)  指令: %s" % [
			i + 1, mo.get("team_id", -1), pos_v.x, pos_v.y, task_str])
	lines.append("")
	lines.append("── 行動 ──")
	lines.append("[A]設定目標  [B]調整徵收率  [C]離開勢力")
	if fp.get("is_leader", false):
		lines.append("[D]背叛勢力  [E]解散勢力（Leader）")
	else:
		lines.append("[D]背叛勢力")
	lines.append("[F/Esc]關閉")
	return "\n".join(lines)
```

- [ ] **Step 5: 在 _refresh() 加 faction_mode 分支**

在 `_refresh()` 函式的 `if _interact_mode:` / `elif _member_mode:` / `elif _inv_mode:` 段加：

```gdscript
	elif _faction_mode:
		_event_label.text = _build_faction_str()
```

- [ ] **Step 6: 在 Esc 處理加 faction_mode**

找到 `KEY_ESCAPE` 的 match 段，在關閉 mode 的 elif 串中加：

```gdscript
			elif _faction_mode:
				_faction_mode = false
				_refresh()
```

- [ ] **Step 7: 跑 headless test**

Expected: `=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 8: Commit**

```
git add scripts/ui/text_ui_main.gd
git commit -m "feat(ui): add [F] faction panel to text_ui_main"
```

---

### Task 5: text_ui_main.gd — [O] 前哨站 + [U] 子隊面板

**Files:**
- Modify: `scripts/ui/text_ui_main.gd`

前置：Plan 1 的 `_bridge.query_outpost_panel()` 和 `_bridge.query_subteam_panel()` 已實裝。

- [ ] **Step 1: 加 [O] + [U] 鍵到主 input handler**

```gdscript
KEY_O:
	_outpost_mode = not _outpost_mode
	if _outpost_mode: _close_all_modes("outpost")
	_refresh()
KEY_U:
	_subteam_mode = not _subteam_mode
	if _subteam_mode: _close_all_modes("subteam")
	_subteam_selection = -1
	_refresh()
```

- [ ] **Step 2: 在 _input() mode 路由加 outpost + subteam**

```gdscript
	if _outpost_mode:
		_handle_outpost_mode(event.keycode)
		return
	if _subteam_mode:
		_handle_subteam_mode(event.keycode)
		return
```

- [ ] **Step 3: 加 _handle_outpost_mode()**

```gdscript
func _handle_outpost_mode(keycode: int) -> void:
	if keycode == KEY_O or keycode == KEY_ESCAPE:
		_outpost_mode = false
		_refresh()
		return
	if keycode >= KEY_1 and keycode <= KEY_9:
		var op: Dictionary = _bridge.query_outpost_panel().get("data", {})
		var actions: Array = op.get("actions", [])
		var idx: int = keycode - KEY_1
		if idx < actions.size():
			var action_id: String = actions[idx]
			var r := _bridge.command_player("execute_action",
				{"action_id": action_id, "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}})
			_log_event("[前哨] %s" % r.get("message", ""))
	_refresh()
```

- [ ] **Step 4: 加 _build_outpost_str()**

```gdscript
func _build_outpost_str() -> String:
	var op: Dictionary = _bridge.query_outpost_panel().get("data", {})
	var lines: Array = []
	var pos: Dictionary = op.get("tile_pos", {})
	var pos_v: Vector2i = pos if pos is Vector2i else Vector2i(pos.get("x", 0), pos.get("y", 0))
	lines.append("── 前哨站 @(%d,%d) ──" % [pos_v.x, pos_v.y])
	lines.append("類型: %s  等級: %d" % [
		op.get("outpost_type", "無") if op.get("outpost_type", "") != "" else "無",
		op.get("outpost_level", 0)])
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
	}
	var actions: Array = op.get("actions", [])
	if actions.is_empty():
		lines.append("（無可用行動）")
	for i in range(actions.size()):
		lines.append("[%d]%s" % [i + 1, ACTION_LABELS.get(actions[i], actions[i])])
	lines.append("[O/Esc]關閉")
	return "\n".join(lines)
```

- [ ] **Step 5: 加 _handle_subteam_mode()**

```gdscript
func _handle_subteam_mode(keycode: int) -> void:
	if keycode == KEY_U or keycode == KEY_ESCAPE:
		_subteam_mode = false
		_subteam_selection = -1
		_refresh()
		return
	var sp: Dictionary = _bridge.query_subteam_panel().get("data", {})
	var subteams: Array = sp.get("subteams", [])

	if _subteam_selection == -1:
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
					_bridge.set_player_input("order_sub_id", sub_id_cap)
					_bridge.set_player_input("order_sub_q", q_val)
					_bridge.set_player_input("order_sub_r", r_val)
					_bridge.set_player_input("order_sub_task", "移動")
					var res := _bridge.command_player("execute_action",
						{"action_id": "order_subteam", "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}})
					_log_event("[子隊] %s" % res.get("message", ""))
					_subteam_selection = -1
				_input_bar.text = "%s_" % _input_mode_prompt
			_input_bar.text = "%s_" % _input_mode_prompt
		KEY_B:
			_bridge.set_player_input("recall_sub_id", _subteam_selection)
			var r := _bridge.command_player("execute_action",
				{"action_id": "recall_subteam", "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}})
			_log_event("[子隊] %s" % r.get("message", ""))
			_subteam_selection = -1
	_refresh()
```

- [ ] **Step 6: 加 _build_subteam_str()**

```gdscript
func _build_subteam_str() -> String:
	var sp: Dictionary = _bridge.query_subteam_panel().get("data", {})
	var subteams: Array = sp.get("subteams", [])
	var lines: Array = []
	lines.append("── 子隊 ──")
	if subteams.is_empty():
		lines.append("（無子隊）")
	for i in range(subteams.size()):
		var st: Dictionary = subteams[i]
		var tpos = st.get("tile_pos", {})
		var pos_v: Vector2i = tpos if tpos is Vector2i else Vector2i(tpos.get("x", 0), tpos.get("y", 0))
		var task_str: String = st.get("player_commanded_task", st.get("current_task", "?"))
		var selected_mark: String = "* " if st.get("team_id", -1) == _subteam_selection else "  "
		lines.append("[%d]%sTeam%d @(%d,%d)  %s  人口:%d" % [
			i + 1, selected_mark, st.get("team_id", -1), pos_v.x, pos_v.y,
			task_str, st.get("population", 0)])
		if st.get("team_id", -1) == _subteam_selection:
			lines.append("    [A]下令移動  [B]召回")
	lines.append("[U/Esc]關閉")
	return "\n".join(lines)
```

- [ ] **Step 7: 在 _refresh() 加 outpost + subteam 分支**

在 `elif _faction_mode:` 後加：

```gdscript
	elif _outpost_mode:
		_event_label.text = _build_outpost_str()
	elif _subteam_mode:
		_event_label.text = _build_subteam_str()
```

- [ ] **Step 8: 在 Esc 加 outpost + subteam 關閉**

```gdscript
			elif _outpost_mode:
				_outpost_mode = false
				_refresh()
			elif _subteam_mode:
				if _subteam_selection >= 0:
					_subteam_selection = -1
				else:
					_subteam_mode = false
				_refresh()
```

- [ ] **Step 9: 跑 headless test + commit**

```
git add scripts/ui/text_ui_main.gd
git commit -m "feat(ui): add [O] outpost panel and [U] subteam panel"
```

---

### Task 6: text_ui_main.gd — [V] 顧問模式 + gather_intel 子模式

**Files:**
- Modify: `scripts/ui/text_ui_main.gd`

- [ ] **Step 1: 加 [V] 鍵到主 input handler**

```gdscript
KEY_V:
	_advisor_mode = not _advisor_mode
	if _advisor_mode: _close_all_modes("advisor")
	_advisor_selection = -1
	_refresh()
```

- [ ] **Step 2: 加 advisor_mode 路由到 _input()**

```gdscript
	if _advisor_mode:
		_handle_advisor_mode(event.keycode)
		return
```

- [ ] **Step 3: 加 _handle_advisor_mode()**

`AdvisorSystem` 已存在於 `scripts/simulation/`。直接實例化呼叫，無需透過 bridge。

```gdscript
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
					var advisor_p = _bridge.get_state().persons.get(advisor_pid_cap) if _bridge.get_state() else null
					if advisor_p == null:
						_log_event("[顧問] 顧問不存在")
						return
					var advice: String = AdvisorSystem.new().get_advice(advisor_p, buf, {}, _bridge.get_state())
					_log_event("[Advisor] %s：%s" % [advisor_p.person_name, advice])
				_input_bar.text = "%s_" % _input_mode_prompt
	_refresh()
```

**注意：** `_bridge.get_state()` 在 Plan 2 後被移除（若 Plan 2 先完成）。若 Plan 2 已完成，advisor 查詢改為：在 SimBridge 加一個 `query_advisor_advice(advisor_pid: int, situation: String) -> String` wrapper，讓 bridge 內部取 state 後呼叫 AdvisorSystem。若 Plan 2 未完成，`_bridge.get_state()` 仍可用。**建議：加 SimBridge wrapper。**

加到 `sim_bridge.gd`：

```gdscript
func query_advisor_advice(advisor_pid: int, situation: String) -> String:
	var p: PersonData = _state.persons.get(advisor_pid)
	if p == null: return "顧問不存在"
	return AdvisorSystem.new().get_advice(p, situation, {}, _state)
```

然後 callback 改為：

```gdscript
				_input_mode_callback = func(buf: String):
					var advice: String = _bridge.query_advisor_advice(advisor_pid_cap, buf)
					_log_event("[Advisor] 建議：%s" % advice)
```

- [ ] **Step 4: 加 _build_advisor_str()**

```gdscript
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
```

- [ ] **Step 5: 在 _refresh() 加 advisor 分支**

```gdscript
	elif _advisor_mode:
		_event_label.text = _build_advisor_str()
```

- [ ] **Step 6: 加 gather_intel 子模式支援**

在 `_handle_interact_mode()` 已選目標段（`if _interact_target >= 0:`），找到：

```gdscript
			var result: Dictionary = _bridge.command_player(act.get("command_name", "execute_action"), act.get("command_args", {}))
			_log_event("[互動] %s" % result.get("message", ""))
			_interact_target = -1
```

替換為：

```gdscript
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
			else:
				var result: Dictionary = _bridge.command_player(
					act.get("command_name", "execute_action"), act.get("command_args", {}))
				_log_event("[互動] %s" % result.get("message", ""))
			_interact_target = -1
```

- [ ] **Step 7: 加 _handle_intel_mode() + _build_intel_str()**

```gdscript
func _handle_intel_mode(keycode: int) -> void:
	if keycode == KEY_ESCAPE:
		_intel_mode = false
		_intel_options = []
		_refresh()
		return
	if keycode >= KEY_1 and keycode <= KEY_9:
		var idx: int = keycode - KEY_1
		if idx < _intel_options.size():
			var choice: String = _intel_options[idx].get("label", "")
			_bridge.set_player_input("gather_intel_npc_id", _intel_target_id)
			_bridge.set_player_input("gather_intel_choice", choice)
			var r := _bridge.command_player("execute_action",
				{"action_id": "confirm_gather_intel",
				 "target": {"kind": "none", "team_id": _intel_target_id, "member_id": -1, "tile_q": -1, "tile_r": -1}})
			_log_event("[Inquiry] %s" % r.get("message", ""))
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
```

- [ ] **Step 8: 在 _input() mode 路由加 _intel_mode**

在 `if _input_mode:` 之後（最高優先）加：

```gdscript
	if _intel_mode:
		_handle_intel_mode(event.keycode)
		return
```

- [ ] **Step 9: 在 _refresh() 加 intel 分支**

```gdscript
	elif _intel_mode:
		_event_label.text = _build_intel_str()
```

- [ ] **Step 10: 跑 headless test 確認 [Advisor] + [Inquiry] print**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

**新增驗證 print：** headless_test.gd 裡加一段直接呼叫 `AdvisorSystem` 的測試（無需 UI）：

在 `headless_test.gd` 的 1000 tick 測試後加：

```gdscript
# 顧問 / 打聽系統 smoke test
var pt2: TeamData = _state.teams.get(_bridge.get_player_team_id())
if pt2 and pt2.leader_id != -1:
	var leader_p2: PersonData = _state.persons.get(pt2.leader_id)
	if leader_p2:
		var advice2: String = AdvisorSystem.new().get_advice(leader_p2, "attack", {}, _state)
		print("[Advisor] smoke test advice: ", advice2)
print("[Inquiry] smoke test done")
```

Expected output: `[Advisor] smoke test advice: ...`（任意文字）和 `[Inquiry] smoke test done`。

- [ ] **Step 11: Commit**

```
git add scripts/ui/text_ui_main.gd scripts/ui/sim_bridge.gd scripts/debug/headless_test.gd
git commit -m "feat(ui): add [V] advisor mode, gather_intel submode to text_ui_main"
```

---

### Task 7: encounter_view.gd — [S] 投降 + [J] 收編

**Files:**
- Modify: `scripts/ui/encounter_view.gd`

- [ ] **Step 1: 在 encounter_view.gd 的 _handle_key() 中加 KEY_S 和 KEY_J**

找到 `_handle_key(keycode: int)` 函式（或其內容的 match 區塊），在現有按鍵之後加：

```gdscript
		KEY_S:
			var state2: WorldState = _bridge.get_state()
			if state2.encounter_active:
				var r := _bridge.command_player("execute_action",
					{"action_id": "surrender_in_encounter",
					 "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}})
				_log(r.get("message", ""))
		KEY_J:
			var state3: WorldState = _bridge.get_state()
			if not state3.encounter_active and state3.last_encounter_result.get("can_subjugate", false):
				var r := _bridge.command_player("execute_action",
					{"action_id": "subjugate_enemy",
					 "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}})
				_log(r.get("message", ""))
```

**注意：** 若 encounter_view 沒有 `_log()` 函式，加上：

```gdscript
func _log(msg: String) -> void:
	print("[EncounterView] ", msg)
```

若 encounter_view 使用 `_lbl_actions` 顯示按鍵提示，在其 text 中加：
`R:攻擊  S:投降  Z:命令  Space:待機`，並在戰鬥結束可收編時顯示 `J:收編`。

- [ ] **Step 2: 在 _refresh_ui() 更新 _lbl_actions 文字**

找到 `_lbl_actions.text = "..."` 行（約 line 70），替換為：

```gdscript
	var state_ui: WorldState = _bridge.get_state()
	var action_hints: String = "QWEASD:移動  R:攻擊\nZ:命令  S:投降  Space:待機"
	if not state_ui.encounter_active and state_ui.last_encounter_result.get("can_subjugate", false):
		action_hints += "\nJ:收編敗者"
	_lbl_actions.text = action_hints
```

- [ ] **Step 3: 跑 headless test**

Expected: `=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 4: Commit + hand-back**

```
git add scripts/ui/encounter_view.gd
git commit -m "feat(ui): add [S] surrender and [J] subjugate to encounter_view"
```

完成後按 CLAUDE.md 格式寫 hand-back 文件到 `docs/superpowers/handbacks/`，push branch，選 Option 3（Keep as-is）。
