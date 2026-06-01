# Spec: Agent REPL — 外部 Agent 控制介面

**日期：** 2026-06-02  
**狀態：** 已審查

## 目的

提供一個 headless CLI 入口，讓外部 agent（Python、Copilot 等）透過 stdin/stdout 的 JSON Lines 協定操控遊戲模擬。支援：

- 自動化測試（驗證 API 行為）
- Bug 重現與驗證（e.g. 移動到達確認）
- AI agent 自適應任務（查詢中間狀態後決定下一步）

## 執行方式

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/agent_repl.gd
```

stdin/stdout 透過 pipe 傳遞：

```python
import subprocess, json

proc = subprocess.Popen(
    ["godot", "--headless", "--script", "scripts/debug/agent_repl.gd"],
    stdin=subprocess.PIPE, stdout=subprocess.PIPE,
    stderr=subprocess.DEVNULL,  # 模擬系統 print 導向 stderr，不污染 stdout
    text=True
)

def send(cmd: dict) -> dict:
    proc.stdin.write(json.dumps(cmd) + "\n")
    proc.stdin.flush()
    return json.loads(proc.stdout.readline())
```

## 協定：JSON Lines

每次互動：agent 寫一行 JSON → Godot 回一行 JSON。

**stdout 傳輸純淨保證：** `agent_repl.gd` 只用 `print()` 輸出 REPL JSON 回應。所有模擬系統內部 print（`[DayNight]`、`[Move]`、`[Faction]` 等）導向 `stderr`（透過 `print_verbose` 或不輸出）。不修改現有模擬 print 本身，而是在 REPL 模式下將 Godot 的 print 重定向：使用 `--quiet` flag 抑制 engine log，模擬 print 改用 `print_rich` 或在 REPL script 中做 suppress（待實作確認可行方案）。

### Input（stdin）

```json
{"cmd": "<command>", ...args}
```

### Output（stdout）

成功：
```json
{"ok": true, "data": {...}, "events": [...], "message": "..."}
```

失敗：
```json
{"ok": false, "code": "ERROR_CODE", "error": "描述"}
```

`data` / `events` / `message` 依命令不同，可能為空。  
`code` 用於程式判斷錯誤類型（見各命令定義）。

## 支援命令

### `query`

取得玩家 snapshot（等同 `bridge.query_player(request)`）。

```json
{"cmd": "query"}
{"cmd": "query", "request": {"focus_team_id": 2}}
```

回傳（直接 pass-through bridge 回傳）：
```json
{"ok": true, "code": "ok", "data": {"snapshot": {...}}, "message": ""}
```

`snapshot` 格式與 `PlayerQueryApi.get_player_snapshot()` 相同。

---

### `command`

對玩家下指令（等同 `bridge.command_player(name, args)`）。

```json
{"cmd": "command", "name": "move_to", "args": {"tile_q": 5, "tile_r": 4}}
```

回傳（直接 pass-through bridge 回傳）：
```json
{"ok": true, "code": "ok", "message": "移動目標設為(5,4)", "payload": {...}}
{"ok": false, "code": "invalid_target", "message": "目標格不存在", "payload": {}}
```

---

### `advance`

推進 N world ticks（等同 `bridge.advance_ticks(n)`）。

```json
{"cmd": "advance", "ticks": 240}
```

回傳：
```json
{
  "ok": true,
  "code": "ok",
  "ticks_advanced": 240,
  "current_tick": 480,
  "events": [{"type": "new_team_spotted"}, ...]
}
```

`events` 為空陣列代表無事件。  
若遭遇戰觸發，**在呼叫 advance 前短路**回傳：
```json
{"ok": false, "code": "encounter_active", "message": "遭遇戰進行中，無法推進世界時間"}
```
（不進入 `bridge.advance_ticks`；session 須用 `reset` 脫離）

---

### `reset`

重建 WorldState，開始新遊戲。config 優先順序：`config` inline > `config_path` 指定檔 > `default.json`（深度合併）。若 `config` 和 `config_path` 同時存在，`config` inline 覆蓋 `config_path` 的對應欄位。

config 欄位對應 `default.json` 結構：
```json
{"cmd": "reset"}
{"cmd": "reset", "config": {"map": {"seed": 99, "radius": 5}}}
{"cmd": "reset", "config_path": "res://config/test_scenario.json"}
{"cmd": "reset", "config_path": "res://config/test_scenario.json", "config": {"map": {"seed": 1}}}
```

回傳：
```json
{"ok": true, "code": "ok", "message": "重置完成 tick=0", "data": {"current_tick": 0}}
```

`config_path` 不存在時：
```json
{"ok": false, "code": "config_not_found", "message": "config_path 不存在: ..."}
```

---

### `encounter_query`

查詢當前遭遇戰狀態。僅在 `encounter_active == true` 時有效。

```json
{"cmd": "encounter_query"}
```

回傳：
```json
{
  "ok": true,
  "code": "ok",
  "data": {
    "encounter_active": true,
    "attacker_team_id": 3,
    "defender_team_id": 0,
    "player_team_id": 0,
    "waiting_for_player": true,
    "units": [
      {
        "unit_idx": 0,
        "person_id": 1,
        "team_id": 0,
        "is_player": true,
        "pos": {"x": 2, "y": 3},
        "stamina": 0.9,
        "has_exited": false,
        "body_parts": {
          "head":  {"hp": 20, "max_hp": 20, "status": "healthy"},
          "torso": {"hp": 50, "max_hp": 50, "status": "healthy"}
        }
      }
    ]
  }
}
```

若 `encounter_active == false`：
```json
{"ok": false, "code": "no_encounter", "error": "目前無遭遇戰"}
```

`waiting_for_player: true` 代表玩家 unit 的 `action_timer == 0`，可以行動。

---

### `encounter_step`

設定玩家行動並推進遭遇戰，直到下一次 `player_turn` 或 `encounter_ended`。

支援 action type：
- `wait` — 待機
- `attack` — 攻擊指定 unit（`target_idx` = units 陣列索引）

```json
{"cmd": "encounter_step", "action": {"type": "wait"}}
{"cmd": "encounter_step", "action": {"type": "attack", "target_idx": 2}}
```

實作流程：
1. 找到玩家 unit（`person_id == player_id`）
2. 設 `unit["pending_action"] = action`
3. 設 `unit["action_timer"] = unit.get("_max_timer", BASE_ACTION_TICKS)`（解鎖行動）
4. 迴圈呼叫 `bridge.advance_encounter_tick()` 直到回傳 `"player_turn"` 或 `"encounter_ended"`
5. 回傳最新 encounter 狀態

回傳（戰鬥繼續）：
```json
{
  "ok": true,
  "code": "player_turn",
  "data": { /* 同 encounter_query 的 data */ }
}
```

回傳（戰鬥結束）：
```json
{
  "ok": true,
  "code": "encounter_ended",
  "data": { "encounter_active": false, "units": [] }
}
```

錯誤情況：
```json
{"ok": false, "code": "no_encounter",    "error": "目前無遭遇戰"}
{"ok": false, "code": "not_your_turn",   "error": "尚未輪到玩家行動"}
{"ok": false, "code": "invalid_target",  "error": "target_idx 超出範圍或目標已死亡"}
{"ok": false, "code": "unknown_action",  "error": "未知 action type"}
```

---

### `quit`

結束 Godot 程序。回傳後立即 flush stdout 再呼叫 `quit(code)`。

```json
{"cmd": "quit"}
{"cmd": "quit", "code": 1}
```

回傳（flush 後退出）：
```json
{"ok": true, "code": "ok", "message": "bye"}
```

exit code 預設 0，可透過 `code` 指定。

---

## 架構

```
scripts/debug/agent_repl.gd   # 唯一新增檔案
```

依賴現有系統（不修改）：
- `SimBridge` — query / command / advance_ticks / advance_encounter_tick
- `GameSetup` — config 載入與世界初始化
- `WorldState`, `SimRunner` — 模擬核心

### 主迴圈

```gdscript
extends SceneTree

func _initialize() -> void:
    var bridge := _setup_game({})
    var stdin := FileAccess.open("pipe://stdin", FileAccess.READ)
    if stdin == null:
        push_error("agent_repl: 無法開啟 stdin")
        quit(1)
        return
    while not stdin.eof_reached():
        var line := stdin.get_line().strip_edges()
        if line.is_empty(): continue
        var cmd = JSON.parse_string(line)
        if cmd == null or not cmd is Dictionary or not cmd.has("cmd"):
            print(JSON.stringify({"ok": false, "code": "invalid_json", "error": "invalid JSON or missing 'cmd'"}))
            continue
        var resp := _handle(bridge, cmd)
        print(JSON.stringify(resp))
    quit(0)
```

### stdout 純淨方案

模擬系統大量 `print()` 會污染 stdout，破壞 JSON Lines 協定。實作時選用：

**方案（優先）：** `--quiet` flag + Godot engine log suppression  
執行時加 `2>nul`（Windows）或 `2>/dev/null` 將 Godot engine output 導向 stderr。

**若不夠：** 在 `agent_repl.gd` 的 `_setup_game` 前後加 suppress hook（GDScript 不支援 monkeypatching，須評估 Godot `OS.set_use_file_access_save_and_swap()` 等機制是否可用）。

**最壞情況備案：** agent 解析時跳過非 `{` 開頭的行（非 JSON 行忽略），降低對純淨 stdout 的依賴。

### 錯誤處理

| 情況 | 回傳 | 繼續？ |
|------|------|--------|
| 無效 JSON / 缺 `cmd` | `{"ok":false,"code":"invalid_json"}` | ✅ |
| 未知 cmd | `{"ok":false,"code":"unknown_command"}` | ✅ |
| stdin 開啟失敗 | `push_error` → `quit(1)` | ❌ |
| stdin EOF | — | `quit(0)` |
| encounter_active + advance | `{"ok":false,"code":"encounter_active"}` | ✅ |
| encounter_query / encounter_step，無遭遇戰 | `{"ok":false,"code":"no_encounter"}` | ✅ |
| encounter_step，未輪到玩家 | `{"ok":false,"code":"not_your_turn"}` | ✅ |
| encounter_step，target_idx 無效 | `{"ok":false,"code":"invalid_target"}` | ✅ |
| config_path 不存在 | `{"ok":false,"code":"config_not_found"}` | ✅ |

## 驗收條件

1. Windows 上以 pipe 啟動，stdin/stdout 可交換 JSON Lines（parent process 測試，非手動 console）
2. `query` 回傳有效 snapshot（`ok:true`，含 `player_summary.player_exists:true`）
3. `command move_to` 後 `query` 確認 `move_target` 已設為目標座標
4. `advance 300` 後 `query` 確認玩家 team 位置改變（Bug 3 修復驗證）；`ticks_advanced` 正確回傳
5. `advance` 返回 `events` 陣列（空或含 event type）
6. `encounter_active` 時 `advance` 回傳 `code:"encounter_active"`，不崩潰
7. `reset` 後 `query` 確認 tick=0、位置回初始
8. `reset` 帶無效 `config_path` 回傳 `code:"config_not_found"`
9. 無效 JSON 輸入不崩潰，繼續接受下一行
10. stdin 關閉（EOF）後 Godot 正常退出 exit=0
11. `quit` 回傳 `{"ok":true}` 後退出，exit code 正確
12. stdout 只含 JSON Lines（agent 能無錯誤 `json.loads` 每一行）

13. `encounter_query` 在 encounter_active 時回傳 units 列表含 player unit
14. `encounter_step` 執行 `wait` → 回傳 `player_turn` 或 `encounter_ended`，不崩潰
15. `encounter_step` 執行 `attack` 有效 target → 回傳正確 code
16. encounter 結束後 `advance` 恢復正常（不再回傳 `encounter_active`）

## 範圍外

- 多玩家 / 多 agent 並發
- WebSocket / HTTP 協定（未來可擴充）
