# Player Interaction UI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 讓玩家能透過 text UI 實際使用互動系統（pending_targets 選單 + forced_event 回應），並修正 `_accept_diplomacy` stub。

**Architecture:** 在 `text_ui_main.gd` 新增 `_interact_mode`（同 `_inv_mode` 模式），T 鍵開關，event_label 顯示互動清單。`PlayerCommandSystem` 作為薄 API 層，UI 不直接操作 WorldState 互動欄位。`player_command_system.gd` 的 `_accept_diplomacy` 同步修正為呼叫 `_form_alliance`。

**Tech Stack:** Godot 4.2.2 GDScript。測試：headless_test.gd（邏輯層）+ 手動啟動 Godot（UI 層）。

---

## 檔案結構

| 檔案 | 動作 | 職責 |
|---|---|---|
| `scripts/simulation/player_command_system.gd` | 修改 | 修 `_accept_diplomacy` stub |
| `scripts/debug/headless_test.gd` | 修改 | 加 `_accept_diplomacy` 驗證 |
| `scripts/ui/text_ui_main.gd` | 修改 | 加 `_interact_mode` + `_interact_target` + `_player_cmd`；T 鍵；`_handle_interact_mode()`；`_build_interact_str()`；state panel 提示 |

---

## 現有程式碼參考

### `text_ui_main.gd` 現有 mode 模式（仿照寫）

```gdscript
var _member_mode: bool  = false
var _inv_mode: bool     = false

# _input(event) 中的模式切換模式：
if _inv_mode:
    _handle_inv_mode(event.keycode)
    return
match event.keycode:
    KEY_I:
        _inv_mode = not _inv_mode
        if _member_mode: _member_mode = false
        _inv_selection = -1
        _refresh()
    KEY_ESCAPE:
        if _inv_mode:
            _inv_mode = false
            _inv_selection = -1
            _refresh()

# _refresh() 中：
if _member_mode:
    _event_label.text = _build_member_str()
elif _inv_mode:
    _event_label.text = _build_inv_str()
else:
    # 顯示 event log
```

### `PlayerCommandSystem` API（`scripts/simulation/player_command_system.gd`）

```gdscript
# 已存在，可直接呼叫：
func get_available_actions(state: WorldState, target_id: int) -> Array[String]
# 返回子集合自：["ignore","attack","trade","propose_alliance","demand_tribute","extort","recruit"]

func execute_action(state: WorldState, target_id: int, action: String) -> Dictionary
# 返回 { "ok": bool, "msg": String }

func get_forced_response_options(state: WorldState) -> Array[String]
# "diplomacy" → ["accept","refuse"]；"extort" → ["pay","refuse"]

func respond_to_forced(state: WorldState, response: String) -> Dictionary
# 返回 { "ok": bool, "msg": String }，執行後清除 player_forced_event
```

### `WorldState` 互動欄位

```gdscript
var player_pending_targets: Array = []  # Array[int] team_ids
var player_forced_event: Dictionary = {}
# 非空格式：{ "from_id": int, "action": "diplomacy"|"extort", "proposal": String（diplomacy 時） }
```

### `DiplomaticAiSystem._form_alliance`（`scripts/simulation/diplomatic_ai_system.gd:98`）

```gdscript
func _form_alliance(state: WorldState, team_a: TeamData, team_b: TeamData) -> void:
    if team_a.faction_id != -1:
        team_b.faction_id = team_a.faction_id
        var f: FactionData = state.factions.get(team_a.faction_id)
        if f and not f.member_team_ids.has(team_b.team_id):
            f.member_team_ids.append(team_b.team_id)
        state.snapshot_faction_member(team_b.team_id, state.world.current_tick)
    elif team_b.faction_id != -1:
        team_a.faction_id = team_b.faction_id
        var f: FactionData = state.factions.get(team_b.faction_id)
        if f and not f.member_team_ids.has(team_a.team_id):
            f.member_team_ids.append(team_a.team_id)
        state.snapshot_faction_member(team_a.team_id, state.world.current_tick)
    # 若雙方 faction_id 皆 == -1：無 else，不產生效果（需在呼叫前建立勢力）
```

---

## Task 1：修正 `_accept_diplomacy` stub

**Files:**
- Modify: `scripts/simulation/player_command_system.gd:147-155`
- Modify: `scripts/debug/headless_test.gd`（末尾 `=== DONE ===` 前加驗證）

- [ ] **Step 1：先加 headless_test 驗證（預期失敗）**

在 `headless_test.gd` 末尾、`print("=== DONE ===")` 之前加：

```gdscript
	# ── _accept_diplomacy 驗證 ──
	print("--- _accept_diplomacy Tests ---")
	var _cmd_a := PlayerCommandSystem.new()
	# 建立 NPC 勢力（Team1 為領袖）
	var _npc_faction_id: int = state.create_faction(1)
	var _pt_a: TeamData = state.teams.get(state.persons.get(state.player_id).team_id)
	assert(_pt_a.faction_id == -1, "_accept_diplomacy 前玩家無勢力")
	# 模擬 NPC 外交提案
	state.player_forced_event = { "from_id": 1, "action": "diplomacy", "proposal": "alliance" }
	var _resp_a := _cmd_a.respond_to_forced(state, "accept")
	assert(_resp_a.get("ok"), "_accept_diplomacy 應成功")
	assert(_pt_a.faction_id == _npc_faction_id, "接受後玩家應加入 NPC 勢力")
	assert(state.player_forced_event.is_empty(), "accept 後 forced_event 應清除")
	print("  [OK] _accept_diplomacy alliance: player faction_id=%d" % _pt_a.faction_id)
	# 清理（避免影響其他測試）
	_pt_a.faction_id = -1
	print("--- _accept_diplomacy Tests PASSED ---")
```

- [ ] **Step 2：執行測試，確認失敗**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：assertion 失敗於 `_pt_a.faction_id == _npc_faction_id`（因 stub 不呼叫 `_form_alliance`）

- [ ] **Step 3：修正 `_accept_diplomacy`**

將 `scripts/simulation/player_command_system.gd` 第 147–155 行：

```gdscript
func _accept_diplomacy(state: WorldState, from_id: int, proposal: String) -> Dictionary:
	# STUB — 接受 NPC 外交提案，具體邏輯留後續實裝
	# 完整實裝應依 proposal 類型呼叫 DiplomaticAiSystem 對應方法
	var pt: TeamData  = _get_player_team(state)
	var npc: TeamData = state.teams.get(from_id)
	if pt == null or npc == null:
		return { "ok": false, "msg": "隊伍不存在" }
	print("[PlayerCmd] 玩家接受 Team%d 的 %s 提案（STUB）" % [from_id, proposal])
	return { "ok": true, "msg": "接受：%s" % proposal }
```

改為：

```gdscript
func _accept_diplomacy(state: WorldState, from_id: int, proposal: String) -> Dictionary:
	var from_team: TeamData = state.teams.get(from_id)
	var pt: TeamData = _get_player_team(state)
	if from_team == null or pt == null:
		return { "ok": false, "msg": "隊伍不存在" }
	match proposal:
		"alliance", "surrender":
			# 雙方皆獨立時 _form_alliance 無效，需先建立勢力
			if from_team.faction_id == -1 and pt.faction_id == -1:
				state.create_faction(from_id)   # NPC 為領袖
			_diplomatic._form_alliance(state, from_team, pt)
			return { "ok": true, "msg": "接受同盟，加入勢力%d" % from_team.faction_id }
		"tribute":
			return _pay_extortion(state, from_id)
	return { "ok": false, "msg": "未知提案類型：%s" % proposal }
```

- [ ] **Step 4：執行測試，確認通過**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`--- _accept_diplomacy Tests PASSED ---` 與 `=== DONE ===`，無 SCRIPT ERROR

- [ ] **Step 5：Commit**

```
git add scripts/simulation/player_command_system.gd scripts/debug/headless_test.gd
git commit -m "fix(player-cmd): _accept_diplomacy calls _form_alliance instead of stub"
```

---

## Task 2：加入 `_interact_mode` 基礎架構

**Files:**
- Modify: `scripts/ui/text_ui_main.gd`

- [ ] **Step 1：加狀態變數與 `_player_cmd`**

在 `text_ui_main.gd` 現有 `_inv_selection: int = -1` 下方加：

```gdscript
var _interact_mode:   bool = false
var _interact_target: int  = -1
# -1 = 目標/事件選擇階段；>= 0 = 已選 pending target，顯示行動清單
var _player_cmd: PlayerCommandSystem = PlayerCommandSystem.new()
```

- [ ] **Step 2：在 `_input()` 加 T 鍵與 interact mode 截取**

在 `_input()` 函式，`if _inv_mode:` 區塊後加：

```gdscript
	if _interact_mode:
		_handle_interact_mode(event.keycode)
		return
```

在 `match event.keycode:` 區塊加 T 鍵（放在 KEY_I 附近）：

```gdscript
		KEY_T:
			_interact_mode = not _interact_mode
			if _interact_mode:
				if _inv_mode: _inv_mode = false
				if _member_mode: _member_mode = false
				_interact_target = -1
			_refresh()
```

在 `KEY_ESCAPE` 處理加 interact_mode 判斷（加在現有 member_mode/inv_mode 前）：

```gdscript
		KEY_ESCAPE:
			if _interact_mode:
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
```

- [ ] **Step 3：加 stub `_handle_interact_mode()` 與 `_build_interact_str()`**

在 `text_ui_main.gd` 末尾加：

```gdscript
func _handle_interact_mode(_keycode: int) -> void:
	# TODO: Task 3 實裝
	if _keycode == KEY_ESCAPE:
		if _interact_target >= 0:
			_interact_target = -1
		else:
			_interact_mode = false
	_refresh()

func _build_interact_str() -> String:
	return "── 互動 ──\n（尚未實裝）\n── [T/Esc]關閉 ──"
```

- [ ] **Step 4：在 `_refresh()` 加 interact_mode 分支**

在 `_refresh()` 的 `if _member_mode:` 之前加：

```gdscript
	if _interact_mode:
		_event_label.text = _build_interact_str()
	elif _member_mode:
```

- [ ] **Step 5：在 `_build_state_str()` 加提示行**

在 `_build_state_str()` 末尾 `return "\n".join(lines)` 前加：

```gdscript
	var _pending_n: int = _state.player_pending_targets.size()
	var _forced_n:  int = 0 if _state.player_forced_event.is_empty() else 1
	if _pending_n > 0 or _forced_n > 0:
		var _hint: String = "[T] 互動"
		if _pending_n > 0: _hint += ": 同格%d隊" % _pending_n
		if _forced_n > 0:  _hint += "  ⚠強制事件"
		lines.append(_hint)
```

- [ ] **Step 6：手動啟動 Godot，確認 T 鍵開/關 interact_mode，無 SCRIPT ERROR**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --scene scenes/TextUI.tscn
```

確認：按 T 開啟顯示「（尚未實裝）」，再按 T 或 ESC 關閉。

- [ ] **Step 7：Commit**

```
git add scripts/ui/text_ui_main.gd
git commit -m "feat(ui): add _interact_mode skeleton (T key, ESC, state panel hint)"
```

---

## Task 3：實裝 `_build_interact_str()` 顯示邏輯

**Files:**
- Modify: `scripts/ui/text_ui_main.gd`

- [ ] **Step 1：實裝 `_build_interact_str()`**

將 stub 替換為：

```gdscript
func _build_interact_str() -> String:
	var lines: Array = []
	lines.append("── 互動 ──")

	var fe: Dictionary = _state.player_forced_event
	var fe_count: int = 0   # forced_event 佔用的號碼數

	# forced_event（若有，排第一）
	if not fe.is_empty():
		var from_id: int     = fe.get("from_id", -1)
		var action: String   = fe.get("action", "")
		var proposal: String = fe.get("proposal", "")
		var opts: Array[String] = _player_cmd.get_forced_response_options(_state)
		var opts_str: String = ""
		for i in range(opts.size()):
			opts_str += " [%d]%s" % [i + 1, opts[i]]
			fe_count += 1
		var desc: String
		match action:
			"diplomacy": desc = "Team%d 要求 %s" % [from_id, proposal]
			"extort":    desc = "Team%d 要求勒索" % from_id
			_:           desc = "Team%d 強制事件" % from_id
		lines.append("[!] %s →%s" % [desc, opts_str])

	# pending_targets（從 fe_count+1 開始編號）
	var idx: int = fe_count + 1
	if _state.player_pending_targets.is_empty() and fe.is_empty():
		lines.append("（無可互動目標）")
	for tid in _state.player_pending_targets:
		var t: TeamData = _state.teams.get(tid)
		if t == null: continue
		var faction_str: String = "獨立" if t.faction_id < 0 else "勢力%d" % t.faction_id
		lines.append("[%d] Team%d @(%d,%d) %s pop:%d" % [
			idx, tid, t.tile_pos.x, t.tile_pos.y, faction_str, t.population])
		idx += 1

	lines.append("── [T/Esc]關閉 ──")
	return "\n".join(lines)
```

- [ ] **Step 2：手動測試顯示**

啟動 Godot，讓玩家與 NPC 同格（或手動在 debug 注入 `state.player_pending_targets = [1]`）。
按 T：確認清單正確顯示 Team id、位置、勢力、人口。

- [ ] **Step 3：Commit**

```
git add scripts/ui/text_ui_main.gd
git commit -m "feat(ui): implement _build_interact_str target list display"
```

---

## Task 4：實裝 `_handle_interact_mode()` + 完整 `_build_interact_str()`

**Files:**
- Modify: `scripts/ui/text_ui_main.gd`

- [ ] **Step 1：實裝 `_handle_interact_mode()`**

將 stub 替換為完整實作：

```gdscript
func _handle_interact_mode(keycode: int) -> void:
	# ESC 處理
	if keycode == KEY_ESCAPE:
		if _interact_target >= 0:
			_interact_target = -1
		else:
			_interact_mode = false
		_refresh()
		return

	# 數字鍵 1–9
	if keycode < KEY_1 or keycode > KEY_9:
		return
	var num: int = keycode - KEY_1   # 0-based

	# ── 已選目標：顯示行動清單 ──
	if _interact_target >= 0:
		var actions: Array[String] = _player_cmd.get_available_actions(_state, _interact_target)
		if num < actions.size():
			var result: Dictionary = _player_cmd.execute_action(_state, _interact_target, actions[num])
			_log_event("[互動] %s" % result.get("msg", ""))
			_interact_target = -1   # 回到目標清單
			# 若行動觸發遭遇戰，關閉 interact_mode
			if _state.encounter_active:
				_interact_mode = false
		_refresh()
		return

	# ── 目標選擇階段 ──
	var fe: Dictionary = _state.player_forced_event
	var fe_opts: Array[String] = _player_cmd.get_forced_response_options(_state)
	var fe_count: int = fe_opts.size()

	# forced_event 回應
	if not fe.is_empty() and num < fe_count:
		var response: String = fe_opts[num]
		var result: Dictionary = _player_cmd.respond_to_forced(_state, response)
		_log_event("[強制互動] %s" % result.get("msg", ""))
		_refresh()
		return

	# pending_targets 選擇
	var pending_idx: int = num - fe_count
	if pending_idx >= 0 and pending_idx < _state.player_pending_targets.size():
		_interact_target = _state.player_pending_targets[pending_idx]
		_refresh()
```

- [ ] **Step 2：將 `_build_interact_str()` 完整替換**（加入行動清單分支）

Task 3 的版本僅有目標清單。此步驟將整個函式替換為含 `_interact_target >= 0` 行動清單分支的完整版本：

```gdscript
func _build_interact_str() -> String:
	var lines: Array = []

	# 已選目標：顯示行動清單
	if _interact_target >= 0:
		var tgt: TeamData = _state.teams.get(_interact_target)
		var tgt_name: String = "Team%d" % _interact_target if tgt else "未知"
		lines.append("── %s 行動 ──" % tgt_name)
		var actions: Array[String] = _player_cmd.get_available_actions(_state, _interact_target)
		var row: String = ""
		for i in range(actions.size()):
			row += "[%d]%s  " % [i + 1, actions[i]]
			if (i + 1) % 4 == 0:
				lines.append(row.strip_edges())
				row = ""
		if not row.strip_edges().is_empty():
			lines.append(row.strip_edges())
		lines.append("── [Esc]返回 ──")
		return "\n".join(lines)

	# 目標選擇階段
	lines.append("── 互動 ──")
	var fe: Dictionary = _state.player_forced_event
	var fe_count: int = 0

	if not fe.is_empty():
		var from_id: int     = fe.get("from_id", -1)
		var action: String   = fe.get("action", "")
		var proposal: String = fe.get("proposal", "")
		var opts: Array[String] = _player_cmd.get_forced_response_options(_state)
		var opts_str: String = ""
		for i in range(opts.size()):
			opts_str += " [%d]%s" % [i + 1, opts[i]]
			fe_count += 1
		var desc: String
		match action:
			"diplomacy": desc = "Team%d 要求 %s" % [from_id, proposal]
			"extort":    desc = "Team%d 要求勒索" % from_id
			_:           desc = "Team%d 強制事件" % from_id
		lines.append("[!] %s →%s" % [desc, opts_str])

	var idx: int = fe_count + 1
	if _state.player_pending_targets.is_empty() and fe.is_empty():
		lines.append("（無可互動目標）")
	for tid in _state.player_pending_targets:
		var t: TeamData = _state.teams.get(tid)
		if t == null: continue
		var faction_str: String = "獨立" if t.faction_id < 0 else "勢力%d" % t.faction_id
		lines.append("[%d] Team%d @(%d,%d) %s pop:%d" % [
			idx, tid, t.tile_pos.x, t.tile_pos.y, faction_str, t.population])
		idx += 1

	lines.append("── [T/Esc]關閉 ──")
	return "\n".join(lines)
```

- [ ] **Step 3：手動測試完整互動流程**

啟動 Godot，推進 tick 直到 NPC 與玩家同格：
1. state panel 顯示 `[T] 互動: 同格N隊`
2. 按 T → 目標清單出現
3. 按數字選目標 → 行動清單出現
4. 按數字選行動 → event log 顯示結果
5. ESC 退回目標清單，再 T 或 ESC 關閉

測試 forced_event：
手動在 Godot 主畫面對玩家 state 注入 forced_event（或等 NPC 外交觸發），確認：
1. 按 T → `[!] Team2 要求 alliance → [1]accept [2]refuse`
2. 按 1 → 接受，event log 顯示「接受同盟，加入勢力X」
3. `player_forced_event` 清空

- [ ] **Step 4：Commit**

```
git add scripts/ui/text_ui_main.gd
git commit -m "feat(ui): implement _handle_interact_mode and full _build_interact_str"
```

---

## 驗證清單

```powershell
# headless test（_accept_diplomacy 邏輯層驗證）
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：
- `--- _accept_diplomacy Tests PASSED ---`
- `=== DONE ===`，無 SCRIPT ERROR

UI 手動驗證：
- [ ] T 鍵開關 `_interact_mode`，不影響其他 mode
- [ ] `_interact_mode` 時 ESC：有目標 → 退回清單；無目標 → 關閉
- [ ] forced_event 非空 → 顯示 `[!]` 提示 + 正確選項
- [ ] 選 pending target → 行動清單顯示正確行動
- [ ] 執行行動 → event log 顯示 msg
- [ ] 攻擊行動後 `_interact_mode` 自動關閉（encounter 觸發）
- [ ] state panel 提示行正確（有互動才顯示）

---

## 注意事項

- **`_interact_target` 與 `player_pending_targets` 一致性**：若執行行動後 pending 清除但 `_interact_target` 未清，`get_available_actions` 對已不存在的 target 回傳預設清單。實裝中已在執行行動後重設 `_interact_target = -1`。
- **forced_event 號碼偏移**：forced_event 有 2 個選項時（diplomacy 或 extort 皆有 2 個），pending_targets 從 `[3]` 開始。`fe_count` 計算邏輯在 `_build_interact_str` 與 `_handle_interact_mode` 中必須一致。
- **場景路徑**：手動測試使用 `scenes/TextUI.tscn`，確認場景存在。若不存在，改用 `scenes/main.tscn` 或現有正確路徑。
