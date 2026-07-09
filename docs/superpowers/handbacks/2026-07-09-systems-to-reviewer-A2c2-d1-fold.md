---
from: systems
to: reviewer
status: open
topic: 審 A2c-2 D1 折入定案（候選 A + 防禦式 gate）——D0 數據齊,審 fold correctness
---

# 請審：A2c-2 D1 折入定案

spec：`docs/superpowers/specs/2026-07-09-A2c2-strategic-move-into-arbiter.md`（§D0 結論 + §D1 定案已補）

## D0 結論（決定 D1）
overlay 非死路：三 seed sa_move_dispatch 有火、關則 breakout 暴增+seed1337 征服接觸崩(member_atk_eligible 416→0)。**折入須保移動執行不塌**。

## D1 定案 = 候選 A + 你抓的 2 gate（防禦式，不靠那 2 探針數值）
implementer D0 **沒測 dual_key/nonidle_empty 兩探針**（撿了工單更新前版本）。我改**防禦式設計**繞過需求：
1. **顯式 move_target-gate**（複製 `movement:71` `==-1,-1 or ==tile_pos`）→ 保觸發顆粒度、不錯位成 task==IDLE（接住你的 TASK_TRADE-抵達反例）。
2. **突圍優先**（`has(-1)` 鏡射 `movement:67-70`）→ D0 breakout_assigned 巨量=雙鍵常見，顯式保。
3. 新 `PRIO_STRATEGIC`（<PRIO_DISPATCH，>IDLE）。

## 請對抗審
1. **防禦式 gate 是否真繞過需求**：顯式 move_target-gate 讓 nonidle_empty 率無關（不管多少都對）——這推論成立嗎？有無 gate 沒接住的觸發態？
2. **候選 A 把「不改 task」變「TASK_MARCH」的語意副作用**：隊本保持 IDLE 只移動 → 現變 current_task=戰略移動 task。這改 task 類別會不會被別的讀 current_task 的邏輯誤判（如 threat/survival scaffolding 看 current_task）？需列 current_task 的下游讀者驗。
3. **PRIO_STRATEGIC 退讓語意**：被真 task 中斷時，strategic march task 讓位——但下 tick 顯式 gate 又會重試（move_target 若空）→ 會不會抖動（march↔真task 反覆）？現行 overlay 是「填空不搶」無 task 身分故無此抖動。
4. **expand_reached 不塌驗收**：D1 後 acceptance full_probe 需驗 expand_reached/member_atk_eligible(seed1337) ≈ baseline overlay-on，這條硬線夠不夠證「移動執行保住」？

無異議即鎖 D2 觸及檔排 implementer。回信 to:systems。
