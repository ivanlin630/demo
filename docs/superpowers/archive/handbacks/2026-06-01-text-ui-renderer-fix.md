# Hand Back: Text UI Renderer Fix & Real-time Refresh

## 實作摘要

- `scripts/ui/text_map_renderer.gd`：重寫 `render()`，移除 even/odd 子行邏輯，改為每 Y 一條線，奇數 Y 縮排 2 格（hex stagger）
- `scripts/ui/sim_bridge.gd`：新增 `_ticks_remaining` 變數與四個方法：`request_advance`、`cancel_advance`、`is_advancing`、`tick_step`
- `scripts/ui/text_ui_main.gd`：新增 `_process()`（非阻塞 tick 消費）；KEY_SPACE/KEY_ENTER 改為 `request_advance`；KEY_ESCAPE 加入 advance 取消；`_do_move_auto()` 的 `max_ticks` 從固定 1000 改為距離比例計算

與 spec 差異：無。`_do_move_auto()` fix 為用戶在子 session 執行中追加的需求，一併納入 Task 3 commit。

## 連動風險

- `text_ui_main.gd`：`_process()` 每 frame 呼叫 `_refresh()`，若 refresh 開銷大可能影響幀率。目前 TICKS_PER_HOUR=1（測試值），正式調大後每 frame 推進更多 tick，影響視覺刷新密度。
- `sim_bridge.gd`：`tick_step()` 遇事件停止推進的條件為 `events.size() > 0`；若事件系統產生大量小事件（非遭遇戰），推進會頻繁中止。

## 待主 session 確認

- `_do_move_auto()` max_ticks 公式：`dist * 720 * TICKS_PER_HOUR * 2`（目前 = dist * 1440）。用戶指定，但 720 為字面常數，如後續加入 `WorldState.TICKS_PER_MONTH` 常數可考慮替換。
- TextMapRenderer headless 測試輸出顯示 hex stagger 正確（每行縮排依 Y 奇偶變化），視覺排列建議手動啟動 `scenes/TextUI.tscn` 確認實際效果。
