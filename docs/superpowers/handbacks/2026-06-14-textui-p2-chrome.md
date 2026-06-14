# Hand Back: 文字 UI 翻新 Phase 2 — chrome 重整

Branch: `feat/textui-chrome`
Plan: `docs/superpowers/plans/2026-06-14-textui-p2-chrome.md`

## 實作摘要

只動 `scripts/ui/` + `ui_logic_test`，經既有 P1 DTO，不改 sim/API。

- `scripts/ui/text_ui_main.gd`
  - 加 `class_name TextUiMain`（供 ui_logic_test 單元測 static helper）
  - 新增 5 個 static 純函數：`_member_health_line` / `_resource_trend` / `_mode_keymap`（+`MODE_KEYMAP` const）/ `_feedback_text` / `_feedback_color` / `_log_strip_text`
  - 新增 instance helper：`_current_mode_name`（依各 mode flag）、`_set_feedback`
  - `_ready` 動態建 3 新 Label（仿 `_alert_bar`，不改 .tscn）：插序 `…EventLabel → LogStrip → FeedbackLine → HintLine → AlertBar → InputBar`
  - `_build_state_str`：人口行後加「糧 X.X 天 + ⚠斷糧」+ 成員健康一行；資源「食/幣/材」附每日基準趨勢箭頭（`_res_baseline`/`_res_baseline_day` 日邊界刷新）
  - `_refresh`：不受 mode 分支影響處常駐設 `_hint_line`（當前模式鍵表）+ `_log_strip`（最新 3 條，與 panel 共存）
  - feedback 路由：所有玩家指令結果處加呼 `_set_feedback(ok, message)` — 移動 / 互動 / 強制互動 / 前哨(×2) / 貿易 / 打聽 / 勢力(設目標/徵收率/離開/背叛/解散/下令成員) / 子隊(派遣/下令/召回) / 遭遇(×2)
- `scripts/debug/ui_logic_test.gd`
  - 加 5 新測試（`_test_member_health_line` / `_test_resource_trend` / `_test_mode_keymap` / `_test_feedback_format` / `_test_log_strip`）並註冊於 `_initialize`

## 測試結果

- `ui_logic_test`：**全綠 errors: 0**（含 5 新測試 12 PASS）
- `team_ui_test`：`=== TEAM UI TEST DONE ===`，無 SCRIPT ERROR
- `headless_test`：跑抵 `=== DONE ===`

### ⚠ 既有失敗（非本次造成）
`headless_test` 在 `=== DONE ===` 後的 `CoinStorage Task11b` 之後出現：
```
SCRIPT ERROR: Assertion failed: food 應進公庫
```
已於 **main baseline 復現相同失敗** → 與本 plan（純 UI）無關，屬既有債。主 session 另案處理。

## 與 spec/plan 的差異

- 測試風格：plan 範例用 `assert`，實檔 `ui_logic_test.gd` 用 `_check(label, ok)` + `_errors` 計數 → 依「沿用該檔既有風格」改寫為 `_check`。
- Commit 粒度：plan 列每 Task 一 commit；因兩檔的各 Task 改動在同一區域交錯、`git add -p` 互動模式於本環境不可用，故合併為**單一 chrome-P2 commit**（commit body 逐 Task 列明）。
- keymap 對齊：`MODE_KEYMAP` 各行已照各 `_handle_*_mode` 實際鍵補正（注意：成員面板開關鍵為 `[P]` 非 plan 草稿的 `[M]`；`[M]` 是主模式的「移動到游標」）。

## 連動風險

- `sim` / `player_api`：**無**。只讀既有 DTO（`controlled_team.food_days/starving/members[].hp_status/resources`），未改任何 mapper。
- `.tscn`：**無**。3 新 Label 全動態建立。
- 邊界 invariant：維持只經 `_bridge`，未直存 WorldState。

## 待主 session 確認

1. **GUI run-verify 未做**（headless 測不到視覺佈局）。需主 session/用戶開 `TextUI.tscn` 確認：
   - status 區顯「糧 X 天 + 趨勢箭頭 + 成員傷摘要」
   - HintLine 切模式時更新
   - 進 panel（如 `O` 前哨）LogStrip 仍顯最新事件（驗共存）
   - 下指令後 FeedbackLine 成/敗著色
2. **`_current_mode_name_under_input()`**：輸入模式時暫回 `"main"` 鍵表（plan 未明確規定輸入子模式的 hint）。如需顯「輸入中」專屬提示，後續可補。
3. 既有 `CoinStorage` assertion 失敗（見上），建議另開 bug task。
4. 全動作覆蓋 / stage-1 互動渲染 = P3，不在本 plan。
