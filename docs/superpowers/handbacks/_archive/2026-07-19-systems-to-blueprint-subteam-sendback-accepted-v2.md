---
from: systems
to: blueprint
status: consumed
topic: "[接受 SEND-BACK·你對·v2 供給環設計中·非 net 進步坐實] 接受你(+measurer)判:1 行修=換位置錯誤(thrash-死→hoard 卡+母團餓死),terminal-sticky=真 blocker 非 WHAT-flag。root2 坐實:1727 即時 merge 其實扛(粗糙)交糧機制(覓食 collect_resources 累積→merge try_merge_back 交糧回母團=供給環),我 v1 盲拆=拆供給環。v2:1727 對 survival-work 改『食足 or 母團缺糧才 merge 交糧,否則留 tile 覓食』閉合供給環。已 HOLD implementer(036fc42c 別 merge)+re-R² v2 中,CLEAN→redirect extend。訂正 reviewer/我 non-blocker 誤判+記 memory(症狀vs根補充2:load-bearing 補丁別盲拆+net-progress check)。驗收:seed42 famine 回 0+囤糧消+無 re-thrash。"
---

# 接受 SEND-BACK：你對，v2 供給環治本

## 你(+measurer)判斷全對，我接受
- 1 行修 = **換位置錯誤**：治好 thrash-死但引入 hoard 卡+母團餓死，**非 net 進步**。
- terminal-sticky = **真 blocker 非 WHAT-flag**：measurer 清楚因果鏈（forager-detach→母團失覓食貢獻→餓死，seed42 0→10）——不是模糊聚合，是機制坐實。
- 我 v1 盲拆了 load-bearing 機制：1727 即時 merge 看似 lifecycle 補丁，**實在扛「交糧回母團」供給環**（覓食 `collect_resources` 累積→歸建 `try_merge_back` 交糧）。拆了=拆供給環。

## v2 修（供給環閉合，spec 已更新）
1727 對 survival-work 改**條件 merge**：
- 未食足+母團不缺 → 留 tile 覓食（`collect_resources` 累積，不即時 merge=不 thrash）。
- **食足 or 母團缺糧 → 歸建 merge（`try_merge_back` 交糧給母團=閉合供給環）**。
- gate：`_forager_sated`（sub food ≥ FORAGE_SATED_DAYS）/`_parent_needs_food`（parent food < PARENT_LOW_DAYS），TEST VALUE。

## 已做
1. **HOLD implementer**（036fc42c 別 merge/自 extend，等我 re-R² CLEAN 信號）。
2. **re-R² v2** 送 reviewer（供給環設計 + sated-gate 不 re-thrash 審點）。
3. **訂正** reviewer/我的 non-blocker 誤判（spec 標 + memory [[feedback_symptom_vs_root_retry]] 補充2：load-bearing 補丁別盲拆 + net-progress check + 自己 flag 的疑點別判太輕）。

## WHAT 確認
你 SEND-BACK 定調 = **接受 subteam 獨立覓食，但要求交糧回母團**（供給環閉合）非禁覓食。v2 正是此意。若 FORAGE_SATED/PARENT_LOW 閾值涉玩家體感（forager 多久回交一次的節奏）你要調，measure 後我報數你裁；否則我 TEST VALUE + measure tune。

## 序
re-R² CLEAN → redirect implementer extend 036fc42c → measure（seed42 famine 回 0 + 囤糧消 + 無 re-thrash + 6 隊解）→ 你/QA 判 → merge。
