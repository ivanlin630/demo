---
from: implementer
to: systems
status: consumed
topic: [卡點·spec-flagged] same-need-first 把併入(belonging-affinity)降級到survival-affinity之後→破desperate投靠;擴spec待裁
---
# 卡點：same-need-first 降級 併入 → 破 desperate 投靠（spec §驗收已 flag）

reorder + 2 wire 實作完，`_test_reorder_same_need` PASS。但 headless 新破 2 p2a 測——**正是 spec §驗收「掠奪/併入 排除殘留…若顯需納回報,擴 spec」的情境**，停下呈報。

## 現象（file:line）
- `_test_p2a_survival_options:15621`：無家深危 + 義氣0.9 隊（+強鄰）→ 期望 `TASK_JOIN`（投靠/併入），**實際 = 紮營(CAMP)**。
- `_test_p2a_join_player_forced:15665`：同格玩家 + 義氣隊 → 期望寫 join_request forced_event，**實際 = 未寫**（npc 未選投靠）。

## 機制（confirmed）
- **併入** 在 `SURVIVAL_OPTION_SET`（絕境求生 repertoire）**但 AFFINITY main-layer = belonging(0.6)**（`need_hierarchy.gd`）。
- desperate 義氣隊 rank：survival-affinity option（覓食/紮營…）為 rank[0]層，`reorder_same_need_first` 把**同 survival-affinity** 全提前、**併入(belonging) 推到 rest 尾**。
- → walk 先試 survival-affinity 的 紮營（義氣隊 desperate + farmable → 可派）→ 紮營 dispatched，永不 walk 到併入 → **投靠路徑被 same-need-first 埋掉**。
- ∴ 同 need-first（按 affinity 層）與「併入=survival-repertoire 但 belonging-affinity」衝突：desperate 忠義隊的 **投靠(belonging 求生策略) 被 survival-affinity option 壓掉**。

## 需裁決（spec 已預告擴，不猜）
**A. 併入(及掠奪?) 在 reorder 視為 survival-layer**：same-need-first partition 時，`SURVIVAL_OPTION_SET` 成員一律歸「survival 求生層」（不看 affinity），使餓隊 fallthrough 涵蓋 覓食/買糧/紮營/**併入**/掠奪/乞食 同組 → 保投靠路徑。最貼 spec 意圖（「餓隊覓食失敗→試…非落生產」，併入本是絕境 option）。
**B. main_layer_of 特例**：`main_layer_of(併入)` 在 fallthrough 情境回 survival（或 SURVIVAL_OPTION_SET 成員回 rank[0] 層）。同 A 但改點在 main_layer_of。
**C. 併入 affinity 重估**（belonging→加 survival 分量）：動 AFFINITY 表=measure-first 敏感，且改決策 coeff（非只 dispatch 序）→ blast radius 大，不建議。
**D. 放寬 2 p2a 測**（desperate→紮營亦絕境求生，投靠非唯一）：但「義氣隊投靠」是刻意 loyalty 求生策略，放寬恐掩真行為損失。

我傾向 **A**（partition 用 SURVIVAL_OPTION_SET 成員資格，非 affinity 層——絕境 fallthrough 本應涵蓋全 survival repertoire 含併入/掠奪；affinity 層是「決策優先」用途，dispatch fallthrough 用「同求生 repertoire」語意更對）。但這改 reorder 語意（affinity-layer → survival-set membership）——**擴 spec 你裁**。

## 附
- reorder + wire code + `_test_reorder_same_need`（綠）在工作區未 commit（等擴 spec 定 partition 準則）。
- 其餘 headless = 3 pre-existing（p2a_survival_terms/beg_join/strategic）。
- determinism/融合閘待裁定後跑。standby，不自改 reorder 語意/AFFINITY、不問 user。
