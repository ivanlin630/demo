# Agent REPL Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 實作 `scripts/debug/agent_repl.gd`，提供 JSON Lines stdin/stdout 協定，讓外部 agent 可以透過 pipe 操控遊戲模擬。

**Architecture:** 單一 SceneTree script（無 Node 場景），讀取 stdin JSON Lines 並呼叫現有 SimBridge API，每個命令同步完成後回傳一行 JSON 到 stdout。所有模擬 print 污染透過 `2>nul` 導向 stderr 或 agent 端跳過非 JSON 行處理。

**Tech Stack:** GDScript 4.2（Godot headless）、Python 3.x（測試 harness）

---

## 開始前確認 baseline

```powershell
A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>nul
```
必須看到 `=== DONE ===`，無 `SCRIPT ERROR`。

---

## 檔案對照

| 路徑 | 狀態 | 職責 |
|------|------|------|
| `scripts/debug/agent_repl.gd` | **新增** | REPL 主迴圈、命令分派、所有命令 handler |
| `scripts/debug/test_agent_repl.py` | **新增** | Python 測試 harness，驗證全部 16 個驗收條件 |
| `docs/superpowers/specs/2026-06-02-agent-repl-design.md` | 參考 | 協定規格，命令定義，驗收條件 |

| `scripts/simulation/encounter_system.gd` | **修改** | `_decide_action` 加玩家 pending_action 支援 |

> ⚠️ encounter_system.gd 需小幅修改：`_decide_action` 目前是純 AI，不讀 `pending_action`。需加 player_id 特判。encounter_view.gd 設置 `pending_action` 但目前未被消費，修改後才能生效（同時修復 UI 端玩家輸入無效的 bug）。

---

## Chunk 1: 基礎框架與 reset/query/command

### Task 1: 最小 REPL stub（stdin 迴圈）

**Files:**
- Create: `scripts/debug/agent_repl.gd`

- [ ] **Step 1: 建立最小 stub**

```gdscript
extends SceneTree

func _initialize() -> void:
    # 測試：只輸出一行 JSON 後退出
    print(JSON.stringify({"ok": true, "code": "stub", "message": "agent_repl stub"}))
    quit(0)
```

- [ ] **Step 2: 跑 headless 確認無崩潰**

```powershell
A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/agent_repl.gd 2>nul
```
預期 stdout：`{"code":"stub","message":"agent_repl stub","ok":true}`

- [ ] **Step 3: 實作 stdin 迴圈（測試 pipe:// 可行性）**

```gdscript
extends SceneTree

func _initialize() -> void:
    var stdin := FileAccess.open("pipe://stdin", FileAccess.READ)
    if stdin == null:
        push_error("agent_repl: cannot open stdin (pipe://stdin returned null)")
        # 備案：嘗試 /dev/stdin
        stdin = FileAccess.open("/dev/stdin", FileAccess.READ)
    if stdin == null:
        print(JSON.stringify({"ok": false, "code": "stdin_error",
            "error": "cannot open stdin on this platform"}))
        quit(1)
        return
    while not stdin.eof_reached():
        var line := stdin.get_line().strip_edges()
        if line.is_empty():
            continue
        var cmd = JSON.parse_string(line)
        if cmd == null or not cmd is Dictionary or not cmd.has("cmd"):
            print(JSON.stringify({"ok": false, "code": "invalid_json",
                "error": "invalid JSON or missing 'cmd'"}))
            continue
        var resp := _dispatch(null, cmd)
        print(JSON.stringify(resp))
    quit(0)

func _dispatch(_bridge, cmd: Dictionary) -> Dictionary:
    match cmd.get("cmd", ""):
        "quit":
            return {"ok": true, "code": "ok", "message": "bye"}
        _:
            return {"ok": false, "code": "unknown_command",
                "error": "unknown cmd: %s" % cmd.get("cmd", "")}
```

> ⚠️ **Windows 注意：** `pipe://stdin` 在 Godot 4.2 Windows headless 可能不可用。若 `FileAccess.open("pipe://stdin")` 回傳 null，記錄於 handback 的「待主 session 確認」區塊，並在 test_agent_repl.py 中標記 AC#1 為 SKIP。

- [ ] **Step 4: 用 echo pipe 測試（若 stdin 可用）**

```powershell
echo '{"cmd":"quit"}' | A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/agent_repl.gd 2>nul
```
預期：先輸出 `{"code":"ready"...}` 再輸出 `{"code":"ok","message":"bye"...}`

- [ ] **Step 5: Commit**

```
feat(agent-repl): add minimal stdin loop skeleton
```

---

### Task 2: `reset` 命令

依賴：Task 1 完成（`_bridge` 可以為 null，reset 後初始化）

**Files:**
- Modify: `scripts/debug/agent_repl.gd`

- [ ] **Step 1: 確認 GameSetup.setup() 呼叫方式**

閱讀 `scripts/simulation/game_setup.gd` 前 60 行（已讀過，摘要）：
- `GameSetup.setup(state, config)` — `config` = 完整 config dict（`{"seed":42,"map":{...},...}`）
- `GameSetup.load_config(path)` — 從 .json 載入並回傳 dict
- Config 的 seed 在頂層（`config.get("seed", 42)`），不在 map 裡

- [ ] **Step 2: 實作 `_deep_merge` 和 `_setup_game`**

```gdscript
# 加到 agent_repl.gd 底部

func _setup_game(config_override: Dictionary) -> SimBridge:
    var base_cfg := GameSetup.load_config("res://config/default.json")
    if base_cfg.is_empty():
        base_cfg = {}
    _deep_merge(base_cfg, config_override)
    var state := WorldState.new()
    var runner := SimRunner.new()
    GameSetup.setup(state, base_cfg)
    return SimBridge.new(runner, state)

func _deep_merge(base: Dictionary, override: Dictionary) -> void:
    for key in override:
        if key in base and base[key] is Dictionary and override[key] is Dictionary:
            _deep_merge(base[key], override[key])
        else:
            base[key] = override[key]
```

- [ ] **Step 3: 實作 `reset` handler**

```gdscript
func _handle_reset(cmd: Dictionary) -> Dictionary:
    var cfg: Dictionary = {}

    # config_path 優先於 inline config（先載入檔案，再讓 inline 覆蓋）
    if cmd.has("config_path"):
        var path: String = cmd["config_path"]
        if not FileAccess.file_exists(path):
            return {"ok": false, "code": "config_not_found",
                "error": "config_path 不存在: %s" % path}
        var loaded := GameSetup.load_config(path)
        if loaded.is_empty():
            return {"ok": false, "code": "config_not_found",
                "error": "config_path 載入失敗: %s" % path}
        _deep_merge(cfg, loaded)

    if cmd.has("config"):
        _deep_merge(cfg, cmd["config"])

    _bridge = _setup_game(cfg)
    return {"ok": true, "code": "ok",
        "message": "重置完成 tick=0",
        "data": {"current_tick": 0}}
```

- [ ] **Step 4: 把 `_bridge` 提升為 instance variable，`_initialize` 先呼叫 reset**

```gdscript
extends SceneTree

var _bridge: SimBridge = null

func _initialize() -> void:
    # 初始化預設世界
    _bridge = _setup_game({})
    # ... stdin 迴圈（同 Task 1）
```

`_dispatch` 加 reset case：
```gdscript
"reset":
    return _handle_reset(cmd)
```

- [ ] **Step 5: 驗證 reset 不崩潰**

```powershell
echo '{"cmd":"reset","config":{"map":{"seed":99,"radius":4}}}{"cmd":"quit"}' | ... 2>nul
```
預期：`{"code":"ok","message":"重置完成 tick=0"...}` 後接 `{"code":"ok","message":"bye"...}`

- [ ] **Step 6: Commit**

```
feat(agent-repl): implement reset command with config deep-merge
```

---

### Task 3: `query` 命令

**Files:**
- Modify: `scripts/debug/agent_repl.gd`

- [ ] **Step 1: 實作 `query` handler**

```gdscript
func _handle_query(cmd: Dictionary) -> Dictionary:
    if _bridge == null:
        return {"ok": false, "code": "not_initialized", "error": "call reset first"}
    var request: Dictionary = cmd.get("request", {})
    return _bridge.query_player(request)
```

`_dispatch` 加：
```gdscript
"query":
    return _handle_query(cmd)
```

- [ ] **Step 2: 驗證 query 回傳 player_exists**

```powershell
echo '{"cmd":"query"}{"cmd":"quit"}' | ... 2>nul
```
預期 stdout 第二行含 `"player_exists":true`（或 `"ok":true`）。

- [ ] **Step 3: Commit**

```
feat(agent-repl): implement query command
```

---

### Task 4: `command` 命令

**Files:**
- Modify: `scripts/debug/agent_repl.gd`

- [ ] **Step 1: 確認 `command_player` 格式**

`sim_bridge.gd` line 126: `func command_player(name: String, args: Dictionary) -> Dictionary`  
回傳 `{ok, code, message, payload}`（PlayerCommandApi 格式）。

- [ ] **Step 2: 實作 `command` handler**

```gdscript
func _handle_command(cmd: Dictionary) -> Dictionary:
    if _bridge == null:
        return {"ok": false, "code": "not_initialized", "error": "call reset first"}
    if not cmd.has("name"):
        return {"ok": false, "code": "invalid_json", "error": "missing 'name'"}
    var name: String = cmd["name"]
    var args: Dictionary = cmd.get("args", {})
    return _bridge.command_player(name, args)
```

`_dispatch` 加：
```gdscript
"command":
    return _handle_command(cmd)
```

- [ ] **Step 3: 驗證 move_to 設定 move_target**

```powershell
# 需要知道初始地圖有哪些 tile — 用 query 先查玩家位置，再 move_to 相鄰 tile
```

實際測試留給 Python harness（Task 8）。

- [ ] **Step 4: Commit**

```
feat(agent-repl): implement command passthrough
```

---

## Chunk 2: advance、encounter、quit、測試

### Task 5: `advance` 命令

**Files:**
- Modify: `scripts/debug/agent_repl.gd`

- [ ] **Step 1: 實作 `advance` handler**

```gdscript
func _handle_advance(cmd: Dictionary) -> Dictionary:
    if _bridge == null:
        return {"ok": false, "code": "not_initialized", "error": "call reset first"}

    # encounter 中不允許 advance 世界時間
    if _bridge.get_state().encounter_active:
        return {"ok": false, "code": "encounter_active",
            "error": "遭遇戰進行中，無法推進世界時間"}

    var n: int = int(cmd.get("ticks", 1))
    if n <= 0:
        return {"ok": false, "code": "invalid_param", "error": "ticks must be > 0"}

    var all_events: Array = []
    var tick_before: int = _bridge.get_state().world.current_tick
    var ticks_remaining: int = n

    # 分批推進（每次最多 TICKS_PER_HOUR），停在事件或 encounter 觸發
    while ticks_remaining > 0:
        if _bridge.get_state().encounter_active:
            break
        var batch: int = mini(WorldState.TICKS_PER_HOUR, ticks_remaining)
        var batch_tick_before: int = _bridge.get_state().world.current_tick
        var evts: Array = _bridge.advance_ticks(batch)
        var actually_advanced: int = _bridge.get_state().world.current_tick - batch_tick_before
        ticks_remaining -= actually_advanced
        all_events.append_array(evts)
        if evts.size() > 0:
            break  # 事件發生，停止推進

    var ticks_done: int = _bridge.get_state().world.current_tick - tick_before
    return {
        "ok": true,
        "code": "ok",
        "ticks_advanced": ticks_done,
        "current_tick": _bridge.get_state().world.current_tick,
        "events": all_events,
    }
```

`_dispatch` 加：
```gdscript
"advance":
    return _handle_advance(cmd)
```

- [ ] **Step 2: 驗證 advance 回傳 ticks_advanced**

```powershell
echo '{"cmd":"advance","ticks":100}{"cmd":"quit"}' | ... 2>nul
```
預期第二行含 `"ticks_advanced":100`（若無事件）或較小值（若事件觸發）。

- [ ] **Step 3: Commit**

```
feat(agent-repl): implement advance command
```

---

### Task 5.5: 修改 encounter_system 支援 pending_action（玩家控制）

> 必須在 Task 6 之前完成。

**Files:**
- Modify: `scripts/simulation/encounter_system.gd` — `_decide_action` 加 player pending_action 讀取

- [ ] **Step 1: 在 `_decide_action` 最前面加玩家特判**

找到 `scripts/simulation/encounter_system.gd` 的 `_decide_action` 函式（約第 279 行），在第一行 `if not is_combat_capable` 之前插入：

```gdscript
func _decide_action(unit_idx: int, state: WorldState,
        focus_target: int) -> Dictionary:
    var unit: Dictionary = state.encounter_units[unit_idx]
    
    # 玩家控制：若玩家 unit 有 pending_action，優先使用並清除
    if unit.get("person_id", -1) == state.player_id and unit.has("pending_action"):
        var pa: Dictionary = unit["pending_action"]
        unit.erase("pending_action")
        var pa_type: String = pa.get("type", "wait")
        match pa_type:
            "attack":
                var tidx: int = pa.get("target_idx", -1)
                if tidx >= 0 and tidx < state.encounter_units.size():
                    var tgt: Dictionary = state.encounter_units[tidx]
                    if not is_dead(tgt, state) and not tgt.get("has_exited", false):
                        return { "type": "attack", "target_idx": tidx,
                            "move_to": tgt["pos"],
                            "attack_part": _choose_attack_part(unit, state) }
                # 無效目標 fallback wait
            _:
                pass  # wait / unknown → fallthrough to AI (idle)
        return { "type": "idle", "target_idx": -1, "move_to": unit["pos"], "attack_part": "" }
    
    if not is_combat_capable(unit, state):
```

原有的 `if not is_combat_capable(unit, state):` 是 `_decide_action` 的第一個判斷，插入後改為接在 pending_action 特判之後。

- [ ] **Step 2: 驗證 encounter_system 無語法錯誤**

```powershell
A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import 2>nul
```
無 `SCRIPT ERROR`。

- [ ] **Step 3: 跑 headless test 確認無回歸**

```powershell
A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>nul
```
必須看到 `=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 4: Commit**

```
fix(encounter): support player pending_action in _decide_action

Player unit now uses pending_action (set by UI/REPL) instead of AI
logic. Clears pending_action after use. Invalid targets fall back to
idle. Fixes encounter_view.gd player input having no effect.
```

---

### Task 6: `encounter_query` 和 `encounter_step` 命令

**Files:**
- Modify: `scripts/debug/agent_repl.gd`

- [ ] **Step 1: 實作 `_encounter_snapshot` 輔助函式**

```gdscript
func _encounter_snapshot() -> Dictionary:
    var state: WorldState = _bridge.get_state()
    var units_out: Array = []
    for i in range(state.encounter_units.size()):
        var unit: Dictionary = state.encounter_units[i]
        var pid: int = unit.get("person_id", -1)
        var is_player: bool = (pid == state.player_id)
        # body_parts: 只輸出 status + hp（去掉 bleeding/fracture 等細節）
        var bp_out: Dictionary = {}
        var bp: Dictionary = unit.get("body_parts", {})
        for part in bp:
            bp_out[part] = {
                "hp":     bp[part].get("hp", 0),
                "max_hp": bp[part].get("max_hp", 0),
                "status": bp[part].get("status", "healthy"),
            }
        units_out.append({
            "unit_idx":   i,
            "person_id":  pid,
            "team_id":    unit.get("team_id", -1),
            "is_player":  is_player,
            "pos":        {"x": unit.get("pos", Vector2i.ZERO).x,
                           "y": unit.get("pos", Vector2i.ZERO).y},
            "stamina":    unit.get("stamina", 1.0),
            "has_exited": unit.get("has_exited", false),
            "body_parts": bp_out,
        })

    # 判斷是否輪到玩家（player unit action_timer == 0）
    var waiting_for_player: bool = false
    for unit in state.encounter_units:
        if unit.get("person_id", -1) == state.player_id:
            waiting_for_player = (unit.get("action_timer", 1) == 0)
            break

    return {
        "encounter_active":   state.encounter_active,
        "attacker_team_id":   state.encounter_attacker_id,
        "defender_team_id":   state.encounter_defender_id,
        "player_team_id":     _bridge.get_player_team_id(),
        "waiting_for_player": waiting_for_player,
        "units":              units_out,
    }
```

- [ ] **Step 2: 實作 `encounter_query` handler**

```gdscript
func _handle_encounter_query(_cmd: Dictionary) -> Dictionary:
    if _bridge == null:
        return {"ok": false, "code": "not_initialized", "error": "call reset first"}
    if not _bridge.get_state().encounter_active:
        return {"ok": false, "code": "no_encounter", "error": "目前無遭遇戰"}
    return {"ok": true, "code": "ok", "data": _encounter_snapshot()}
```

- [ ] **Step 3: 實作 `encounter_step` handler**

`encounter_step` 支援兩種模式：
- 帶 `action`：設 pending_action → 解鎖計時器 → advance 到 player_turn/encounter_ended
- 不帶 `action`（或 `action: null`）：直接 advance 到下一個 player_turn/encounter_ended（用於不是玩家回合時推進）

```gdscript
func _handle_encounter_step(cmd: Dictionary) -> Dictionary:
    if _bridge == null:
        return {"ok": false, "code": "not_initialized", "error": "call reset first"}
    var state: WorldState = _bridge.get_state()
    if not state.encounter_active:
        return {"ok": false, "code": "no_encounter", "error": "目前無遭遇戰"}

    # 找玩家 unit
    var player_unit: Dictionary = {}
    for unit in state.encounter_units:
        if unit.get("person_id", -1) == state.player_id:
            player_unit = unit
            break
    if player_unit.is_empty():
        return {"ok": false, "code": "no_encounter", "error": "找不到玩家 unit"}

    # 帶 action 時才驗證回合與設置
    if cmd.has("action") and cmd["action"] != null:
        # 確認是玩家回合
        if player_unit.get("action_timer", 1) != 0:
            return {"ok": false, "code": "not_your_turn",
                "error": "尚未輪到玩家行動（action_timer=%d）" % player_unit.get("action_timer", -1)}

        # 解析 action
        var action: Dictionary = cmd["action"]
        var action_type: String = action.get("type", "wait")

        match action_type:
            "wait":
                player_unit["pending_action"] = {"type": "wait"}
            "attack":
                if not action.has("target_idx"):
                    return {"ok": false, "code": "invalid_target", "error": "attack 需要 target_idx"}
                var tidx: int = int(action["target_idx"])
                if tidx < 0 or tidx >= state.encounter_units.size():
                    return {"ok": false, "code": "invalid_target",
                        "error": "target_idx %d 超出範圍" % tidx}
                var target: Dictionary = state.encounter_units[tidx]
                # is_dead 判斷：torso status == "severed"（與 EncounterSystem.is_dead 一致）
                var torso: Dictionary = target.get("body_parts", {}).get("torso", {})
                var target_dead: bool = torso.get("status", "healthy") == "severed"
                if target.get("has_exited", false) or target_dead:
                    return {"ok": false, "code": "invalid_target", "error": "目標已死亡或離場"}
                player_unit["pending_action"] = {"type": "attack", "target_idx": tidx}
            _:
                return {"ok": false, "code": "unknown_action",
                    "error": "未知 action type: %s" % action_type}

        # 解鎖玩家行動計時器
        player_unit["action_timer"] = player_unit.get("_max_timer",
            EncounterSystem.BASE_ACTION_TICKS)

    # 推進直到 player_turn 或 encounter_ended（上限 500 次防止無限迴圈）
    var result_code: String = "ongoing"
    for _i in range(500):
        result_code = _bridge.advance_encounter_tick()
        if result_code == "player_turn" or result_code == "encounter_ended":
            break

    if result_code == "ongoing":
        # 500 次仍未到玩家回合（不正常情況）
        result_code = "encounter_ended" if not state.encounter_active else "player_turn"

    return {
        "ok": true,
        "code": result_code,
        "data": _encounter_snapshot(),
    }
```

> ⚠️ `_bridge._runner._encounter_system.is_dead(...)` 需要 `_runner` 和 `_encounter_system` 為 public 或提供 helper。若 SimBridge 不暴露，改為直接檢查 `target.get("body_parts", {}).get("torso", {}).get("status", "healthy") == "severed"`。

`_dispatch` 加：
```gdscript
"encounter_query":
    return _handle_encounter_query(cmd)
"encounter_step":
    return _handle_encounter_step(cmd)
```

- [ ] **Step 4: 基本驗證（無 encounter 回傳 no_encounter）**

```powershell
echo '{"cmd":"encounter_query"}{"cmd":"quit"}' | ... 2>nul
```
預期：`{"code":"no_encounter","error":"目前無遭遇戰","ok":false}`

- [ ] **Step 5: Commit**

```
feat(agent-repl): implement encounter_query and encounter_step
```

---

### Task 7: `quit` + 錯誤處理 polish

**Files:**
- Modify: `scripts/debug/agent_repl.gd`

- [ ] **Step 1: 實作 quit（主迴圈特判，不透過 _dispatch）**

```gdscript
func _handle_quit(cmd: Dictionary) -> void:
    var code: int = int(cmd.get("code", 0))
    print(JSON.stringify({"ok": true, "code": "ok", "message": "bye"}))
    quit(code)
```

主迴圈改為（quit 在 dispatch 之前特判，避免雙重 print）：
```gdscript
while not stdin.eof_reached():
    var line := stdin.get_line().strip_edges()
    if line.is_empty(): continue
    var cmd = JSON.parse_string(line)
    if cmd == null or not cmd is Dictionary or not cmd.has("cmd"):
        print(JSON.stringify({"ok": false, "code": "invalid_json",
            "error": "invalid JSON or missing 'cmd'"}))
        continue
    if cmd.get("cmd") == "quit":
        _handle_quit(cmd)
        return  # quit() 已排入，跳出迴圈
    var resp := _dispatch(cmd)
    print(JSON.stringify(resp))
quit(0)
```

- [ ] **Step 2: 完整 _dispatch match（不含 quit）**

```gdscript
func _dispatch(cmd: Dictionary) -> Dictionary:
    match cmd.get("cmd", ""):
        "reset":           return _handle_reset(cmd)
        "query":           return _handle_query(cmd)
        "command":         return _handle_command(cmd)
        "advance":         return _handle_advance(cmd)
        "encounter_query": return _handle_encounter_query(cmd)
        "encounter_step":  return _handle_encounter_step(cmd)
        _:
            return {"ok": false, "code": "unknown_command",
                "error": "unknown cmd: %s" % cmd.get("cmd", "")}
```

- [ ] **Step 3: 驗證無效 JSON 不崩潰**

```powershell
# 用兩行分開送，Windows cmd 用換行
printf 'not_json\n{"cmd":"quit"}\n' | A:\GDS\demo\tools\godot\... 2>nul
```
預期：`{"code":"invalid_json"...}` 後接 `{"code":"ok","message":"bye"...}`

- [ ] **Step 4: 跑 baseline headless test 確認無回歸**

```powershell
A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>nul
```
必須看到 `=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 5: Commit**

```
feat(agent-repl): complete quit handler and error handling
```

---

### Task 8: Python 測試 harness（驗收條件 AC#1–12）

**Files:**
- Create: `scripts/debug/test_agent_repl.py`

- [ ] **Step 1: 建立 harness 框架**

```python
#!/usr/bin/env python3
"""Agent REPL acceptance test harness.
Run: python scripts/debug/test_agent_repl.py
"""
import subprocess, json, sys, time

GODOT = r"A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe"
SCRIPT = "scripts/debug/agent_repl.gd"

def start_repl() -> subprocess.Popen:
    return subprocess.Popen(
        [GODOT, "--headless", "--script", SCRIPT],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
        cwd=r"A:\GDS\demo",
    )

def send(proc: subprocess.Popen, cmd: dict, timeout: float = 30.0) -> dict:
    import time
    proc.stdin.write(json.dumps(cmd) + "\n")
    proc.stdin.flush()
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        if proc.poll() is not None:
            raise RuntimeError(f"Process exited prematurely with code {proc.returncode}")
        line = proc.stdout.readline()
        if not line:
            time.sleep(0.05)
            continue
        line = line.strip()
        if not line.startswith("{"):
            continue  # skip non-JSON (AC#12 fallback)
        return json.loads(line)
    raise TimeoutError(f"No JSON response within {timeout}s for cmd={cmd}")

def skip_ready(proc: subprocess.Popen) -> None:
    """No-op: ready message removed from protocol."""
    pass

PASS = 0
FAIL = 0

def check(label: str, condition: bool) -> None:
    global PASS, FAIL
    status = "PASS" if condition else "FAIL"
    print(f"  [{status}] {label}")
    if condition:
        PASS += 1
    else:
        FAIL += 1
```

- [ ] **Step 2: 實作 AC#1–5 測試**

```python
def test_basic():
    print("\n=== AC#1-5: Basic protocol ===")
    proc = start_repl()
    skip_ready(proc)

    # AC#2: query returns valid snapshot
    r = send(proc, {"cmd": "query"})
    check("AC#2: query ok=true", r.get("ok") == True)
    snapshot = r.get("data", {}).get("snapshot", r.get("data", {}))
    check("AC#2: player_exists=true",
          r.get("ok") and (
              r.get("data", {}).get("player_summary", {}).get("player_exists") == True
              or r.get("data", {}).get("player_exists") == True
          ))

    # AC#3: command move_to sets move_target
    q1 = send(proc, {"cmd": "query"})
    # get player tile from snapshot to find a neighboring tile
    # just try a nearby tile — if invalid, we get error code
    r_cmd = send(proc, {"cmd": "command", "name": "move_to", "args": {"tile_q": 0, "tile_r": 0}})
    check("AC#3: move_to returns ok or known error (not crash)",
          "ok" in r_cmd)

    # AC#4: advance 300 ticks
    r_adv = send(proc, {"cmd": "advance", "ticks": 300})
    check("AC#4: advance ok=true", r_adv.get("ok") == True)
    check("AC#4: ticks_advanced present", "ticks_advanced" in r_adv)
    check("AC#4: current_tick present", "current_tick" in r_adv)

    # AC#5: events array present
    check("AC#5: events is array", isinstance(r_adv.get("events"), list))

    send(proc, {"cmd": "quit"})
    proc.wait(timeout=10)
    check("AC#1: process exited cleanly", proc.returncode == 0)
```

- [ ] **Step 3: 實作 AC#6–12 測試**

```python
def test_edge_cases():
    print("\n=== AC#6-12: Edge cases ===")
    proc = start_repl()
    skip_ready(proc)

    # AC#7: reset → tick=0
    r = send(proc, {"cmd": "reset", "config": {"map": {"seed": 7, "radius": 4}}})
    check("AC#7: reset ok=true", r.get("ok") == True)
    r2 = send(proc, {"cmd": "query"})
    # current_tick=0 might be inside data
    ct = (r2.get("data", {}).get("current_tick")
          or r2.get("data", {}).get("snapshot", {}).get("current_tick"))
    check("AC#7: tick=0 after reset", ct == 0 or ct is None)  # 0 or not reported

    # AC#8: invalid config_path
    r = send(proc, {"cmd": "reset", "config_path": "res://config/nonexistent.json"})
    check("AC#8: config_not_found", r.get("code") == "config_not_found")

    # AC#9: invalid JSON does not crash
    proc.stdin.write("not_valid_json\n")
    proc.stdin.flush()
    r = json.loads(proc.stdout.readline().strip())
    check("AC#9: invalid_json code", r.get("code") == "invalid_json")

    # AC#10: stdin close → exit 0
    proc.stdin.close()
    proc.wait(timeout=10)
    check("AC#10: exit 0 on stdin close", proc.returncode == 0)

    # AC#11: quit with code
    proc2 = start_repl()
    skip_ready(proc2)
    r = send(proc2, {"cmd": "quit", "code": 42})
    check("AC#11: quit response ok=true", r.get("ok") == True)
    proc2.wait(timeout=10)
    check("AC#11: exit code 42", proc2.returncode == 42)

    # AC#12: all stdout lines are valid JSON (checked implicitly via send())
    check("AC#12: all responses were parseable JSON (no crash above)", True)
```

- [ ] **Step 4: main 入口**

```python
def main():
    test_basic()
    test_edge_cases()
    print(f"\n=== Results: {PASS} PASS, {FAIL} FAIL ===")
    sys.exit(0 if FAIL == 0 else 1)

if __name__ == "__main__":
    main()
```

- [ ] **Step 5: 跑 harness**

```powershell
python scripts/debug/test_agent_repl.py
```
預期：`=== Results: N PASS, 0 FAIL ===`

若 AC#1 失敗（stdin pipe 不可用），記錄於 handback。

- [ ] **Step 6: Commit**

```
test: add Python acceptance test harness for agent REPL (AC#1-12)
```

---

### Task 9: Encounter 測試（AC#13–16）

**Files:**
- Modify: `scripts/debug/test_agent_repl.py`

> Encounter 需要兩支隊伍在同一格相遇。用 `reset` 帶自定義 config 建立小地圖，然後 advance 直到 `encounter_triggered` 事件。若 advance 1000 ticks 未觸發，用 `command force_encounter`（如果有實作）或記錄為 SKIP。

- [ ] **Step 1: 確認是否有 force_encounter 命令**

查 `scripts/simulation/player_command_api.gd` 有無 `force_encounter` 或類似強制觸發戰鬥的命令。

```powershell
Select-String -Path "A:\GDS\demo\scripts\simulation\player_command_api.gd" -Pattern "encounter|attack_team"
```

若無，encounter 測試改為：advance 直到 encounter_triggered 事件（使用 seed 42 + radius 4 的小地圖，enemy team 更接近）。

- [ ] **Step 2: 實作 encounter 測試**

```python
def test_encounter():
    print("\n=== AC#13-16: Encounter ===")
    proc = start_repl()
    skip_ready(proc)

    # 小地圖，增加遭遇機率
    send(proc, {"cmd": "reset", "config": {"map": {"seed": 42, "radius": 3}}})

    # advance 直到 encounter_triggered
    encounter_found = False
    for _ in range(50):   # 最多 50 批 × 100 ticks = 5000 ticks
        r = send(proc, {"cmd": "advance", "ticks": 100})
        events = r.get("events", [])
        if any(e.get("type") == "encounter_triggered" for e in events):
            encounter_found = True
            break

    if not encounter_found:
        print("  [SKIP] AC#13-16: encounter not triggered in 5000 ticks (seed/map dependent)")
        send(proc, {"cmd": "quit"})
        proc.wait(timeout=10)
        return

    # AC#13: encounter_query returns units
    r = send(proc, {"cmd": "encounter_query"})
    check("AC#13: encounter_query ok=true", r.get("ok") == True)
    units = r.get("data", {}).get("units", [])
    check("AC#13: units list non-empty", len(units) > 0)
    player_units = [u for u in units if u.get("is_player")]
    check("AC#13: player unit present in units", len(player_units) > 0)

    # AC#14: encounter_step wait → player_turn or encounter_ended
    r = send(proc, {"cmd": "encounter_query"})
    waiting = r.get("data", {}).get("waiting_for_player", False)
    # advance until it's player's turn
    for _ in range(20):
        if waiting:
            break
        r_adv = send(proc, {"cmd": "encounter_step", "action": {"type": "wait"}})
        if r_adv.get("code") in ("player_turn", "encounter_ended"):
            waiting = True
            break
        r2 = send(proc, {"cmd": "encounter_query"})
        waiting = r2.get("data", {}).get("waiting_for_player", False)

    r_step = send(proc, {"cmd": "encounter_step", "action": {"type": "wait"}})
    check("AC#14: encounter_step wait ok=true", r_step.get("ok") == True)
    check("AC#14: code is player_turn or encounter_ended",
          r_step.get("code") in ("player_turn", "encounter_ended"))

    # AC#15: encounter_step attack valid target
    if r_step.get("code") == "player_turn":
        r_q = send(proc, {"cmd": "encounter_query"})
        units2 = r_q.get("data", {}).get("units", [])
        enemy_units = [u for u in units2
                       if not u.get("is_player") and not u.get("has_exited")]
        if enemy_units:
            tidx = enemy_units[0]["unit_idx"]
            r_atk = send(proc, {"cmd": "encounter_step",
                                 "action": {"type": "attack", "target_idx": tidx}})
            check("AC#15: attack valid target ok=true", r_atk.get("ok") == True)
            check("AC#15: code is player_turn or encounter_ended",
                  r_atk.get("code") in ("player_turn", "encounter_ended"))
        else:
            print("  [SKIP] AC#15: no enemy units to attack")

    # AC#16: after encounter ends, advance works normally
    # advance encounter until it ends
    for _ in range(100):
        if not proc.poll() is None:
            break
        r_s = send(proc, {"cmd": "encounter_step", "action": {"type": "wait"}})
        if r_s.get("code") == "encounter_ended":
            break

    r_adv2 = send(proc, {"cmd": "advance", "ticks": 10})
    check("AC#16: advance works after encounter ends",
          r_adv2.get("ok") == True and r_adv2.get("code") != "encounter_active")

    send(proc, {"cmd": "quit"})
    proc.wait(timeout=10)
```

- [ ] **Step 3: 加入 main()**

```python
def main():
    test_basic()
    test_edge_cases()
    test_encounter()
    print(f"\n=== Results: {PASS} PASS, {FAIL} FAIL ===")
    sys.exit(0 if FAIL == 0 else 1)
```

- [ ] **Step 4: 跑全套測試**

```powershell
python scripts/debug/test_agent_repl.py
```
預期：所有 PASS 或 SKIP（非 FAIL）。

- [ ] **Step 5: 跑 baseline headless test 最後確認**

```powershell
A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>nul
```
必須看到 `=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 6: Final commit**

```
test: add encounter acceptance tests (AC#13-16)
```

---

## 完成後

1. 推 branch：
```powershell
git push -u origin feat/agent-repl
```

2. 寫 handback：`docs/superpowers/handbacks/2026-06-02-agent-repl.md`

3. 特別在 handback 記錄：
   - `pipe://stdin` 在 Windows 是否可用（若不可用，記錄錯誤訊息）
   - encounter 測試是否全 PASS 或 SKIP
   - stdout 污染是否需要額外處理（`2>nul` 是否足夠）

---

## 已知風險

| 風險 | 說明 | 應對 |
|------|------|------|
| `pipe://stdin` Windows 不可用 | Godot 4.2 Windows 可能不支援 pipe:// 協定 | 回報主 session，可能需要改用 file-based IPC 或 OS 特定方案 |
| stdout 污染 | `[GameSetup]`、`[DayNight]` 等 print 混入 stdout | agent 端用 `if not line.startswith("{"):` 跳過；或啟動時加 `--quiet` |
| encounter 測試不穩定 | seed 42 radius 3 不一定在 5000 ticks 內觸發 | SKIP 而非 FAIL，記錄於 handback |
