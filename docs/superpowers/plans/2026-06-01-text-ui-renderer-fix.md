# Text UI Renderer Fix & Real-time Refresh Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 修正 hex 地圖渲染（每 Y 一條線）並讓 tick 推進改為非阻塞（每 TICKS_PER_HOUR 渲染一次）。

**Architecture:** TextMapRenderer 重寫 `render()` 移除 even/odd 子行；SimBridge 新增 tick scheduling API（`request_advance`/`tick_step`）；text_ui_main 新增 `_process()` 消費 SimBridge，KEY_SPACE/G 改為非阻塞。

**Tech Stack:** Godot 4.2.2 GDScript。測試：手動啟動 `scenes/TextUI.tscn` + headless 確認無 SCRIPT ERROR。

---

## 現有程式碼參考

### `scripts/ui/text_map_renderer.gd`（目前問題）

```gdscript
# 現有 render()：每個 Y 產生兩條子行（even_line / odd_line）
for drow in range(ymin, ymax + 1):
    var even_line: String = ""
    var odd_line:  String = "  "
    for dcol in range(dcol_min, dcol_max + 1):
        var tx: int = dcol - int(floor(float(drow - mid_y) / 2.0))
        var pos := Vector2i(tx, drow)
        var cell := _cell(...)
        if (dcol - dcol_min) % 2 == 0:
            even_line += cell
        else:
            odd_line += cell
    lines.append(even_line)
    lines.append(odd_line)
```

問題：同一 Y 的格子被拆成兩條，`mid_y` 計算的 dcol 系統讓 X 順序混亂。

### `scripts/ui/sim_bridge.gd`（目前 API）

```gdscript
class_name SimBridge

const TICKS_PER_TURN: int = 24

var _runner: SimRunner
var _state: WorldState

func _init(runner: SimRunner, state: WorldState) -> void: ...

func advance_ticks(n: int) -> Array:
    # 推進最多 n ticks，遇事件（encounter/new_team）提前中止
    # 返回 Array of event dicts

func advance_encounter_tick() -> String: ...
func get_player_team_id() -> int: ...
func get_state() -> WorldState: ...
```

### `scripts/ui/text_ui_main.gd` 現有 KEY_SPACE / KEY_G / KEY_ESCAPE 段落（行號約 82-114）

```gdscript
KEY_SPACE:
    for _i in range(WorldState.TICKS_PER_DAY):
        var evts: Array = _bridge.advance_ticks(1)
        _events.append_array(evts)
    if _events.size() > 100:
        _events = _events.slice(_events.size() - 100)
    _refresh()
KEY_G:
    _input_mode = true
    _input_buffer = ""
    _input_bar.text = "跳過 tick 數: _"
KEY_ESCAPE:
    if _interact_mode:
        if _interact_target >= 0:
            _interact_target = -1
        else:
            _interact_mode = false
        _refresh()
    elif _member_mode:
        _member_mode = false
        _refresh()
    elif _inv_mode:
        _inv_mode = false
        _inv_selection = -1
        _refresh()
```

### `_handle_input_mode()` KEY_ENTER 段落（行號約 128-137）

```gdscript
KEY_ENTER:
    if _input_buffer.length() > 0 and int(_input_buffer) > 0:
        var n: int = mini(int(_input_buffer), 99999)
        _input_mode = false
        _input_bar.text = ""
        for _i in range(n):
            var evts: Array = _bridge.advance_ticks(1)
            _events.append_array(evts)
        if _events.size() > 100:
            _events = _events.slice(_events.size() - 100)
        _refresh()
```

---

## Task 1：修正 TextMapRenderer

**Files:**
- Modify: `scripts/ui/text_map_renderer.gd:7-55`（`render()` 函式）

- [ ] **Step 1：將 `render()` 函式全部替換**

將 `scripts/ui/text_map_renderer.gd` 中第 7 行 `static func render(...)` 到第 55 行 `return "\n".join(lines)` 整段替換為：

```gdscript
static func render(state: WorldState, player_tid: int, cursor: Vector2i) -> String:
	var player_team: TeamData = state.teams.get(player_tid)
	var player_pos: Vector2i  = player_team.tile_pos if player_team else Vector2i(4, 4)
	var discovered: Array     = state.team_discovered.get(player_tid, [])

	# 找地圖邊界（tile 實際 x/y 範圍）
	var xs: Array = []; var ys: Array = []
	for tile in state.world.tiles.values():
		xs.append(tile.tile_pos.x); ys.append(tile.tile_pos.y)
	if xs.is_empty(): return "（無地圖）"
	var xmin: int = xs.min(); var xmax: int = xs.max()
	var ymin: int = ys.min(); var ymax: int = ys.max()

	# 建 team 位置查詢表（tile_key → team_id list）
	var team_at: Dictionary = {}
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		var k: int = t.tile_pos.x * 1000 + t.tile_pos.y
		if not team_at.has(k): team_at[k] = []
		(team_at[k] as Array).append(tid)

	# 每個 Y 一條線，奇數 Y 縮排 2（hex stagger）
	var lines: Array = []
	for y in range(ymin, ymax + 1):
		var indent: String = "  " if y % 2 == 1 else ""
		var line: String = indent
		for x in range(xmin, xmax + 1):
			line += _cell(state, Vector2i(x, y), player_pos, player_tid, cursor, discovered, team_at)
		lines.append(line)
	return "\n".join(lines)
```

注意：`_cell()`、`_visible_team()`、`_hex_dist()` 不動。`mid_y` 計算和 `dcol_min/dcol_max` 計算整段刪除。

- [ ] **Step 2：確認無 SCRIPT ERROR**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`=== DONE ===`，無 SCRIPT ERROR（headless 不跑 UI，但確認 class 載入無誤）

- [ ] **Step 3：手動啟動確認地圖排列**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --scene scenes/TextUI.tscn
```

確認：
- 地圖每 Y 一條線（不再是交錯的兩條子行）
- 奇數 Y 行縮排 2 格（hex stagger 效果）
- `@`（玩家位置）在正確格子
- WASD 移動游標，`@` 跟著移動到正確位置
- 數字標記（其他 team）出現在正確格子

- [ ] **Step 4：Commit**

```
git add scripts/ui/text_map_renderer.gd
git commit -m "fix(ui): rewrite TextMapRenderer — one line per Y, odd-Y indent for hex stagger"
```

---

## Task 2：SimBridge Tick Scheduling

**Files:**
- Modify: `scripts/ui/sim_bridge.gd`

- [ ] **Step 1：新增 `_ticks_remaining` 與四個方法**

在 `sim_bridge.gd` 現有 `var _state: WorldState` 下方加：

```gdscript
var _ticks_remaining: int = 0
```

在 `get_state()` 下方加四個方法：

```gdscript
# 請求推進 n ticks（非阻塞，由 tick_step 每 frame 分批執行）
func request_advance(n: int) -> void:
	_ticks_remaining = n

# 取消推進
func cancel_advance() -> void:
	_ticks_remaining = 0

# 是否正在推進
func is_advancing() -> bool:
	return _ticks_remaining > 0

# 每 frame 呼叫：推進 TICKS_PER_HOUR ticks，回傳結果
# 遭遇戰/新發現事件觸發時自動停止
# 返回 { "events": Array, "done": bool }
func tick_step() -> Dictionary:
	if _ticks_remaining <= 0:
		return { "events": [], "done": true }
	var n: int = mini(WorldState.TICKS_PER_HOUR, _ticks_remaining)
	var events := advance_ticks(n)
	_ticks_remaining = maxi(0, _ticks_remaining - n)
	if events.size() > 0:
		_ticks_remaining = 0   # 重要事件 → 停止推進
	return { "events": events, "done": _ticks_remaining <= 0 }
```

- [ ] **Step 2：確認無 SCRIPT ERROR**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`=== DONE ===`，無 SCRIPT ERROR

- [ ] **Step 3：Commit**

```
git add scripts/ui/sim_bridge.gd
git commit -m "feat(ui): add SimBridge tick scheduling (request_advance, tick_step, cancel_advance)"
```

---

## Task 3：text_ui_main 非阻塞改造

**Files:**
- Modify: `scripts/ui/text_ui_main.gd`

Task 2 必須先完成。

- [ ] **Step 1：新增 `_process()`**

在 `_ready()` 與 `_input()` 之間插入：

```gdscript
func _process(_delta: float) -> void:
	if not _bridge.is_advancing(): return
	var result := _bridge.tick_step()
	_events.append_array(result.get("events", []))
	if _events.size() > 100:
		_events = _events.slice(_events.size() - 100)
	if result.get("done", false):
		_input_bar.text = ""
	else:
		_input_bar.text = "推進中 Tick:%d [Esc]停止" % _state.world.current_tick
	_refresh()
	if _state.encounter_active:
		_bridge.cancel_advance()
```

- [ ] **Step 2：修改 `_input()` 中的 KEY_SPACE**

將：
```gdscript
KEY_SPACE:
    for _i in range(WorldState.TICKS_PER_DAY):
        var evts: Array = _bridge.advance_ticks(1)
        _events.append_array(evts)
    if _events.size() > 100:
        _events = _events.slice(_events.size() - 100)
    _refresh()
```

改為：
```gdscript
KEY_SPACE:
    _bridge.request_advance(WorldState.TICKS_PER_DAY)
```

- [ ] **Step 3：修改 `_handle_input_mode()` 中的 KEY_ENTER**

將：
```gdscript
KEY_ENTER:
    if _input_buffer.length() > 0 and int(_input_buffer) > 0:
        var n: int = mini(int(_input_buffer), 99999)
        _input_mode = false
        _input_bar.text = ""
        for _i in range(n):
            var evts: Array = _bridge.advance_ticks(1)
            _events.append_array(evts)
        if _events.size() > 100:
            _events = _events.slice(_events.size() - 100)
        _refresh()
```

改為：
```gdscript
KEY_ENTER:
    if _input_buffer.length() > 0 and int(_input_buffer) > 0:
        var n: int = mini(int(_input_buffer), 99999)
        _input_mode = false
        _input_bar.text = ""
        _bridge.request_advance(n)
        _refresh()
```

- [ ] **Step 4：修改 `_input()` 中的 KEY_ESCAPE（加 advance 取消）**

將：
```gdscript
KEY_ESCAPE:
    if _interact_mode:
        if _interact_target >= 0:
            _interact_target = -1
        else:
            _interact_mode = false
        _refresh()
    elif _member_mode:
        _member_mode = false
        _refresh()
    elif _inv_mode:
        _inv_mode = false
        _inv_selection = -1
        _refresh()
```

改為：
```gdscript
KEY_ESCAPE:
    if _bridge.is_advancing():
        _bridge.cancel_advance()
        _input_bar.text = ""
        _refresh()
    elif _interact_mode:
        if _interact_target >= 0:
            _interact_target = -1
        else:
            _interact_mode = false
        _refresh()
    elif _member_mode:
        _member_mode = false
        _refresh()
    elif _inv_mode:
        _inv_mode = false
        _inv_selection = -1
        _refresh()
```

- [ ] **Step 5：手動測試非阻塞推進**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --scene scenes/TextUI.tscn
```

確認：
- 按 Space：地圖每 10 ticks 更新一次（可見地圖/debug bar 持續變化），input_bar 顯示「推進中 Tick:X [Esc]停止」
- 按 ESC 中途停止：推進立即停止，input_bar 清空
- 按 G，輸入數字（如 500），確認地圖即時刷新並最終停在正確 tick
- 遭遇戰觸發（NPC 攻擊玩家）：推進自動停止，等待玩家操作
- M 鍵（自動移動）：行為不變（仍為阻塞模式）

- [ ] **Step 6：headless 最終確認**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`=== DONE ===`，無 SCRIPT ERROR

- [ ] **Step 7：Commit**

```
git add scripts/ui/text_ui_main.gd
git commit -m "feat(ui): non-blocking tick advance with per-hour refresh, ESC to cancel"
```
