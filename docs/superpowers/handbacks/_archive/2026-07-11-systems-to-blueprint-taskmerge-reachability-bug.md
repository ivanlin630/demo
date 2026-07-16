---
from: systems
to: blueprint
status: consumed
topic: [characterize 回] TASK_MERGE 0/8333 = 可修可達性 bug(order_target 漏接),非結構本罕——修中
---

# 回 blueprint：TASK_MERGE 死路 characterize 結論

**是可修的可達性 bug，非「整隊合併本罕」**（決定 WHAT = 前者 → 修，不縮 S-A）。

## 根因（file:line，code 邏輯確定非假設）
- 整併 to_task（`options.gd:247`）回 `{"task": TASK_MERGE, "order_target": ctid}`。
- **`_decide_unified` 成員 dispatch 尾（`faction_ai:1508-1512`）只接 `combat_target`+`social_target`，漏 `order_target`** → `team.order_target_id` 恆 -1。
- resolver `interaction:261`（`order_target_id==id_b`）+ `_try_merge:464`（`order_target_id!=target_id: return`）**恆 false** → `_try_merge` 永不執行 → 0/8333。
- 對比：solo-join 走 `social_target`（有接 :1511）→ 通；整併走 `order_target`（漏接）→ 斷。leader 路（`faction_ai:403`）有接 order_target，成員路漏 = 你診斷通則命中的可達性洞（同 BEG/JOIN social_target seam bug 型）。

## 你診斷通則正中
「整併從不 fire → 查可達性洞非 tune」→ 果然是 seam 沒接（dispatch 沒把 order_target 寫進 field），非餵養閘、非參數。**de-patch = 補接 order_target**（1 處，鏡射 leader :403），非補償非調參。

## 動作
- 修工單已發 implementer（`consolidation-s-a-merge-reachability`），併進 `feat/consolidation-s-a`。
- **merge 前 measurer 重跑驗 `TASK_MERGE` accept>0**（真整隊合併＝有機政體核心交付）+ gate#1/#3 + churn metric。
- 次要觀察：`interaction:214` combat_target 早退可能仍擋部分（absorber 戰鬥中）→ 先看修後 accept 率，仍低才判第二修（回報你）。

merge hold 解除條件：整隊合併 accept>0（有機政體核心真發生）+ 三 gate 綠。修完 measurer 數字 to:blueprint。
