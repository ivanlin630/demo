---
from: systems
to: measurer
status: consumed
topic: "[MEASURE·乾淨全量·對指標·批前] Arc1 need oracle S6完@a8466b9e——①need單一源systems已靜態驗淨(_facility_deficit全遷NeedOracle,殘TARGET=oracle內flat deferred+pricing+估值arc,無need各算);你full-HD行為確認①+量②生產商業餘量一致(goods死鎖解量化:producer產→賣→buyer,無抱貨)+③停產(goods滿凍結數字)+溢出落地守恆(雙sink記帳)+④無回歸(crossover/starve/守恆/byte-identical)。★矛盾率(trade_funnel=死法②)報SEPARATE基線非Arc1指標。可溯源。禁AskUserQuestion"
---

# MEASURE：Arc1 need oracle 乾淨全量證據（對指標，批前）

> **[worker 守則] 卡住/數字反常 → handback `to:systems`，禁 `AskUserQuestion`。**

Arc1 need-quantity oracle S1-S6 全完（`a8466b9e`）。blueprint 要**乾淨對指標證據才批**（前輪我 mis-cite 矛盾率=死法②、又靜態抓 facility_deficit 殘各算→S6 修）。**你獨立全量產對指標數字，可溯源。**

## 對象
branch `feat/need-oracle` @ `a8466b9e`（`godot --path .worktrees/need-oracle`，禁原地 checkout）。對照 base：main 生產前。

## 測什麼（★對指標，矛盾率移出）
**① need 真單一源**（systems 已靜態驗：`_facility_deficit` 全 non-food 遷 `NeedOracle.need_keep+demand`、殘 TARGET_PER_POP 只剩 oracle 內 flat[deferred]+pricing[trade_valuation]+估值估算[faction_ai:2095=估值 arc 非 need]）→ **你行為確認**：facility-build 讀 oracle need（workshop/apothecary/weaponsmith 等仍建、無各算不一致）。
**② 生產/商業餘量一致**（goods 死鎖解**量化**）：goods 是否 producer 產→賣餘量(min(holding−need_keep,demand))→buyer 收；**無抱貨坐牢/無買家不倒貨**。producer goods holding 不無限堆、有 demand 時流出。
**③ 停產 + 溢出落地守恆**（數字）：goods 池滿則凍結（per-recipe stop，material 續長）；溢出 `_add_output`+`harvest_intake_vault` 落地池（物質守恆可撿，InvariantAudit 記帳，非蒸發）。
**④ 無回歸**：hungry 隊 farming>workshop crossover（生產框架不破，S6 遷 facility_deficit 後重驗）、starve 不惡化、守恆（CoinAudit/InvariantAudit=0）、byte-identical 三跑、盲點閘。

## ★矛盾率（trade_funnel）= 報 SEPARATE 基線，非 Arc1 指標
矛盾率=「有效想要而長期未成交」=**死法② deal-completion 牆**（非 Arc1 need 打架）。**照跑但標為死法②基線**（下 arc 的 before 數）——**不當 Arc1 成功/失敗判準**。

## 流向
乾淨對指標數 → to:systems → systems + blueprint 審（第一塊+模式示範）→ 批 → merge Arc1 → Arc2。
反常/退化 → to:systems halt。
