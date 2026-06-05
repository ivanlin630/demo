# Hand Back: Diplomatic System Fixes

## 實作摘要

- `scripts/simulation/diplomatic_ai_system.gd`
  - `_execute_betrayal`：在清除 `self_team.faction_id` 前先讀取 faction，呼叫 `f.member_team_ids.erase(self_team.team_id)` 修正孤立成員 bug
  - `_send_diplomacy_message`：`demand_tribute` + "refuse" 分支：寫入 `tribute_refused` 記憶到 sender leader、`_update_reputation` 雙向 -0.1/-0.05
- `scripts/debug/headless_test.gd`：新增背叛孤立測試 + 進貢拒絕回應格式測試

與 spec 無差異。

## 連動風險

- `PlayerTradeSystem.evaluate_offer` 已讀 `"tribute_refused"` reaction（+0.10 threshold）— 格式一致，無需改動。
- `_execute_betrayal` 現在修改 `FactionData.member_team_ids`；FactionAI 在同 tick 迭代 `f.member_team_ids` 時若有背叛，迭代中修改 Array 可能不安全。現行 `consider_betrayal` 在 `for tid in f.member_team_ids` 迴圈內調用，GDScript Array 迭代中 erase 可能跳過元素。建議主 session 確認。

## 待主 session 確認

- `for tid in f.member_team_ids` 迴圈中呼叫 `consider_betrayal` → `_execute_betrayal` → `f.member_team_ids.erase(...)` 是否安全？（GDScript Array iteration 修改安全性）
