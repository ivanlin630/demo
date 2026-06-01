# Spec: Agent REPL — 外部 Agent 控制介面

**日期：** 2026-06-02  
**狀態：** 草稿

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
    stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True
)

def send(cmd: dict) -> dict:
    proc.stdin.write(json.dumps(cmd) + "\n")
    proc.stdin.flush()
    return json.loads(proc.stdout.readline())
```

## 協定：JSON Lines

每次互動：agent 寫一行 JSON → Godot 回一行 JSON。

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
{"ok": false, "error": "描述"}
```

`data` / `events` / `message` 依命令不同，可能為空。

## 支援命令

### `query`

取得玩家 snapshot（等同 `bridge.query_player(request)`）。

```json
{"cmd": "query"}
{"cmd": "query", "request": {"focus_team_id": 2}}
```

回傳：
```json
{"ok": true, "data": {"snapshot": {...}}}
```

`snapshot` 格式與 `PlayerQueryApi.get_player_snapshot()` 相同。

---

### `command`

對玩家下指令（等同 `bridge.command_player(name, args)`）。

```json
{"cmd": "command", "name": "move_to", "args": {"tile_q": 5, "tile_r": 4}}
```

回傳：
```json
{"ok": true, "message": "移動目標設為(5,4)"}
{"ok": false, "error": "目標格不存在"}
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
  "ticks_advanced": 240,
  "current_tick": 480,
  "events": [{"type": "new_team_spotted"}, ...]
}
```

`events` 為空陣列代表無事件。若遭遇戰觸發，`advance` 提前停止，`ticks_advanced < ticks`。

---

### `reset`

重建 WorldState，開始新遊戲。支援 inline config override 或指定 config 檔路徑，缺欄位 fallback 到 `default.json`。

```json
{"cmd": "reset"}
{"cmd": "reset", "config": {"seed": 99, "radius": 5}}
{"cmd": "reset", "config_path": "res://config/test_scenario.json"}
```

回傳：
```json
{"ok": true, "message": "重置完成 seed=99 radius=5"}
```

---

### `quit`

結束 Godot 程序。

```json
{"cmd": "quit"}
{"cmd": "quit", "code": 1}
```

exit code 預設 0，可透過 `code` 指定。

---

## 架構

```
scripts/debug/agent_repl.gd   # 唯一新增檔案
```

依賴現有系統（不修改）：
- `SimBridge` — query / command / advance_ticks
- `GameSetup` — config 載入與世界初始化
- `WorldState`, `SimRunner` — 模擬核心

### 主迴圈

```gdscript
extends SceneTree

func _initialize() -> void:
    var bridge := _setup_game({})
    var stdin := FileAccess.open("pipe://stdin", FileAccess.READ)
    while not stdin.eof_reached():
        var line := stdin.get_line().strip_edges()
        if line.is_empty(): continue
        var cmd = JSON.parse_string(line)
        if cmd == null:
            print(JSON.stringify({"ok": false, "error": "invalid JSON"}))
            continue
        var resp := _handle(bridge, cmd)
        print(JSON.stringify(resp))
    quit(0)
```

### 錯誤處理

- 無效 JSON → `{"ok": false, "error": "invalid JSON"}`
- 未知 cmd → `{"ok": false, "error": "unknown command: X"}`
- 內部例外 → `{"ok": false, "error": "internal: ..."}`
- 任何錯誤都不中斷迴圈，繼續接受下一個命令

## 驗收條件

1. `godot --headless --script agent_repl.gd` 啟動後等待 stdin 輸入
2. `query` 回傳有效 snapshot（含 `player_summary.player_exists`）
3. `command move_to` 後 `query` 確認 `move_target` 已設
4. `advance 300` 後玩家 team 位置改變（Bug 3 修復驗證）
5. `reset` 後 tick 歸零，位置回初始
6. 無效 JSON 不崩潰，繼續接受輸入
7. `quit` 正常退出，exit code 正確

## 範圍外

- encounter 戰鬥中的 `advance`（直接回傳 `encounter_active: true`，不處理戰鬥指令）
- 多玩家 / 多 agent 並發
- WebSocket / HTTP 協定（未來可擴充）
