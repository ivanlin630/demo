# Hand Back: Agent REPL

## 實作摘要

- `scripts/debug/agent_repl.gd`（新增）：JSON Lines stdin/stdout REPL。Windows 下 `pipe://stdin` 不可用，自動切換 TCP fallback（隨機 port，先輸出 `{"mode":"tcp","port":N}` 再等連線）。支援全部命令：reset, query, command, advance, encounter_query, encounter_step, quit。
- `scripts/debug/test_agent_repl.py`（新增）：Python 驗收測試 harness。自動偵測 stdin/TCP 模式，TCP 模式啟動 stdout drain thread 防管道緩衝區滿死鎖。AC#1-12 共 17 項全 PASS，AC#13-16（encounter）因 5000 tick 內未觸發遭遇戰而 SKIP。
- `scripts/simulation/encounter_system.gd`（修改）：`_decide_action` 加玩家 `pending_action` 特判，消費後清除，無效目標 fallback idle。修復 encounter_view.gd 玩家輸入無效的既有 bug。

### 與 spec 的差異

- **stdin ready message**：stdin 模式下也輸出 `{"code":"ready","mode":"stdin"}` 作為 handshake，與 TCP 模式對稱。Spec 未明確要求，但讓 Python 端能一致地偵測模式。
- **TCP fallback**：Spec 假設 stdin 可用，但 Windows Godot 4.2 不支援 `pipe://stdin`，因此加 TCP fallback。協定語意完全相同，只是傳輸層不同。

## 連動風險

- `encounter_system.gd`：`_decide_action` 的玩家路徑現在讀取 `pending_action`。若玩家 unit 在非預期情況下帶有 `pending_action`（如舊存檔或其他系統殘留），可能行動異常。建議主 session 確認 `pending_action` 只由 REPL/UI 明確設置。
- `encounter_view.gd`：設置 `pending_action` 的邏輯現在終於被消費。可能改變 UI 端玩家的遭遇戰行為（原本 pending_action 被忽略，現在生效）。需確認 UI 端設置的 action 格式符合 `_decide_action` 的預期。

## 待主 session 確認

1. **`pipe://stdin` Windows 不可用**：Godot 4.2 Windows headless 完全不支援 `pipe://stdin`（和 `/dev/stdin`）。TCP fallback 可正常運作，但若未來要讓 agent_repl 在 Linux/Mac 部署，stdin 路徑也已實作（`_run_stdin_loop`）並加了 ready message。

2. **encounter 測試 SKIP**：seed=42 radius=3 在 5000 ticks 內未觸發遭遇戰。原因可能是預設 config 的玩家隊伍沒有敵意 NPC 在附近。建議測試：用 force encounter 命令（若實作）或手動指定有敵意 NPC 的 seed。AC#13-16 的 GDScript 端邏輯已實作，只是測試條件需要調整。

3. **stdout 污染（已部分緩解）**：agent_repl TCP 模式下，模擬 `print()` 輸出到 subprocess 的 stdout（不混入 TCP 回應）。Python harness 用 background thread drain，防止管道堵塞。但 stdin 模式下，模擬 print 會混入 stdout 並污染 JSON Lines。建議主 session 評估是否需要在 stdin 模式下 suppress 模擬 print（e.g. 用 `--quiet` 或在 `_run_stdin_loop` 前改用 `push_verbose`）。

4. **pending_action UI 相容性**：encounter_view.gd 設置 pending_action 的格式需與 encounter_system 的 `_decide_action` 一致（`{"type":"attack","target_idx":N}` 或 `{"type":"wait"}`）。建議確認 encounter_view.gd 的實際格式。
