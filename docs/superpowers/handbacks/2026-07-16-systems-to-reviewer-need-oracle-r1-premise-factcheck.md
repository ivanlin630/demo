---
from: systems
to: reviewer
status: open
topic: "[R①·前提 factcheck·大框先驗] Arc1 統一 need oracle——blueprint 明令『判斷層已被獨立查證推翻7次,大框前提務必先驗』。refute 向 factcheck 6 前提:①食物need真散≥7處各算各(不同閾10 vs 14天)?②TARGET_PER_POP=flat常數當need-proxy?③NeedHierarchy現僅引擎內部乘子非全域?④供應鏈傳導(RECIPE_GROUPS支援劍→回推鐵鋼)?⑤_add_output溢出丟回傳值蒸發違守恆?⑥goods只貿易need無自用?premise_contradiction→回systems修再spec"
---

# R① 前提 factcheck：Arc1 統一 need oracle（大框，spec 前必驗）

> **[worker 守則] 卡住/疑義 → handback `to:systems`，禁 `AskUserQuestion`。**

blueprint 啟動統一路線圖 Arc1（need oracle，用戶定「照路線架」）。**大框 + 前提含未驗 code 斷言 + blueprint 明令「判斷層已被獨立查證推翻 7 次（6 measure+1 R①），大框前提務必先驗」→ R① 先於 spec。**

## 為何 R①（不臆斷、不重蹈）
本 arc 前提是**稽核 count/詮釋斷言**（「散 7 處」「各算各的」「蒸發」）——`file:line 坐實 code 在那行 ≠ 坐實「真散/真打架/真蒸發」`。我**不自己臆斷**，請 reviewer（factcheck 權威）refute 向獨立 enumerate+verify。R① CLEAN → systems 在坐實地基架 spec。

## 6 前提（refute 向 factcheck，file:line 坐實 + 詮釋成立）
1. **食物 need 真散 ≥7 處、各算各的、閾不一致**？blueprint 列候選：`_check_food_shortage`(10 天)、`_calc_team_need`(14 天)、`_facility_deficit` farming、diplomatic aid need、order buy need、faction need「第 4 棵樹」+ 其他。**驗**：真有這些獨立 need 計算？閾真不一致（10 vs 14 天=真矛盾）？還是有的已共用/非 need？precise count 幾處？
2. **`TARGET_PER_POP` = flat 常數當 need-proxy**（非消耗率推導）？**驗**：哪些 reader 用它當 need？真是 flat 常數（vs 已某處人格/情境調變）？
3. **`NeedHierarchy` 現僅「引擎內部 coeff 乘子」、非全域 need 源**？**驗**：現在誰讀 NeedHierarchy？升成全域 oracle 與現用**衝突**嗎（現有 caller 語意會不會被破）？
4. **供應鏈傳導前提**：中間品 need 可由下游生產回推（要做劍→回推鐵/鋼）？**驗**：`RECIPE_GROUPS`/`FACILITY_DEF` 的 input→output 映射**結構上支援**transitivity 回推？有無循環/多路徑歧義破壞回推？
5. **`_add_output` 溢出丟回傳值→蒸發違守恆**？**驗**：`manufacturing_system.gd _add_output` 真的溢出（超 cap）時丟棄→物質消失？`TileBank.pool_add`（溢出落地目標）存在且語意對？
6. **goods 只有貿易 need、無自用消耗**？**驗**：goods 真無消費 use（純貿易品）？其他資源分類（food 自用+貿易/ore-steel 供應鏈+貿易/軍備自用+貿易）的 need 來源結構屬實？

## 流向
- **CLEAN（前提坐實）→ to:systems** → systems 據**驗證後的** site 清單 + 分類架 spec → R② 審設計。
- **premise_contradiction（某前提被 refute，如「其實只散 3 處」「NeedHierarchy 升級破現有 caller」「_add_output 沒蒸發」）→ to:systems halt** 修前提再 spec。
- 純靜態難定的行為斷言（如「7 套閾真造成打架」）→ 標「需 measurer」，systems 據此決定 spec 前是否先 measure。

## 溯源
blueprint `unification-roadmap-arc1-need-oracle`（用戶定照路線架）。前提務必先驗＝ [[feedback_fileline_vs_interpretation]] 制度化（本 arc 判斷層 7 次被推翻）。
