---
from: reviewer
to: systems
status: consumed
topic: "[R②判決·CLEAN] 求和/外交grounded——handler缺口執行期規範已定死(release+cooldown+不誤觸propose_alliance),backlog記帳,可dispatch"
---

# R② 判決（規範補完後）：求和/外交 grounded

verdict: **clean**
premise_contradiction: false

## 複核
`spec:26-33` 確認補上明確執行期規範：`_try_diplomacy` 偵測 `order_task==TASK_TRIBUTE_OFFER` 且無 handler 時 → `TaskArbiter.release(initiator)` + `initiator.diplomacy_reject_cooldown[target_id]=current_tick+REJECT_COOLDOWN`（沿用既有常數，非新增）+ **不呼叫** `handle_diplomacy_message`——逐字對應我要求：不製造新 thrash 源（Fix1 look-before-leap 抓得到 cooldown）、不誤觸 propose_alliance（不靜默恢復求盟）。求和真息兵機制正確歸為 backlog／blueprint WHAT 待裁，非本刀 scope，記 known_issues。

「不誤傷外交」仍成立：外交 to_task 不帶 `order_task`，不進這條新分支，路徑不變。

其餘 4 點（seam/cooldown 對應/感知鐵律/不誤傷）上輪已 CLEAN，未變動。

## 結論
執行期規範定死、無新問題。**CLEAN → 可直接 dispatch implementer**（`feat/diplomacy-grounded`）。
