# Hand Back: Encounter Group D — Features

## 實作摘要

- 攻擊部位選擇：`attack_select` 模式用 ↑↓ 循環 6 個部位，Enter 確認。`encounter_view` 新增 `_selected_part` var + `BODY_PARTS` 常數 + `_do_attack_with_part()`。`encounter_system._decide_action` 使用 `pa.get("attack_part")` 優先。
- NPC 守衛邏輯：`encounter_system._find_guard_target()` 找需要守衛的失能敵人；`_decide_action` 最末端插入，只在 idle 時觸發，不影響進攻優先權。
- 俘虜視覺：`_draw()` 對 `is_prisoner` 單位畫橙色外環；死亡單位畫灰色遮罩。
- 俘虜訊息：`_check_prisoners` 輸出「X 被 Y 俘虜」，顯示 person.name 或 team leader 名稱。

## 連動風險

- `_do_attack_with_part` 取代 `_do_attack` 的 pending_action 格式，新增 `attack_part` 欄位。encounter_system 的 `_decide_action` 對玩家 pending_action 已更新，相容。
- NPC 守衛移動使用 `"move"` 類型，受 Group C BUG-15 佔位檢查保護，不會疊格。
- `_calc_next_step` 已在 Group C Task 2 加入，守衛邏輯相依已滿足。

## 待後續

- 俘虜管理系統（審訊、出售、釋放）
- 玩家失能後遭遇戰系統（玩家被俘虜後的流程）
