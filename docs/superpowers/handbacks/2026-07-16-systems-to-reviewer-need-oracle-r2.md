---
from: systems
to: reviewer
status: consumed
topic: "[R²·設計審·統一路線首塊大框] Arc1 need oracle spec——R① CLEAN 後架。NeedOracle 全域源(自用消耗率×人格buffer推導/供應鏈RECIPE傳導/貿易綁deal),生產商業共讀餘量(holding−need)防打架,含停產+溢出落地(sink改TileBank.pool_add+tap)+消耗品可貿易。退役TARGET_PER_POP雙宣告。5 slice。★建議升異質框外審(統一arc首塊·大框·立模式)。CLEAN才dispatch"
---

# R² merge-gate：Arc1 統一 need oracle spec 設計審（統一路線首塊）

> **[worker 守則] 卡住/疑義 → handback `to:systems`，禁 `AskUserQuestion`。**

R① CLEAN（你 6 前提 factcheck，含 #2/#5 訂正、#1 打架標待 measure）→ systems 據驗證前提架 spec。**R② 設計審 CLEAN 才 dispatch implementer。**

## spec
`docs/superpowers/specs/2026-07-16-arc1-unified-need-oracle.md`

## 審什麼（真統一 vs 換地方藏 + 設計 cohere + 非回歸）
1. **match 原則**（框架管規則、need 收單一思考驅動 oracle）：`need = 自用+供應鏈+貿易` 三源相加是否真把散亂收成一源、非再造一套平行？消耗率×人格 buffer 推導真取代 TARGET_PER_POP（不是換名字）？
2. **防打架架構**：`餘量 = holding − need`、生產/商業共讀——真無「兩邊各判界線」？停產（holding≥need）與生產框架 survival-crush 相容不衝突？
3. **供應鏈傳導**（S2）：RECIPE out→in walk 你 R① 驗過無循環——spec 的有限層 walk 設計對？中間品 need 回推語意正確（要產劍→ore_steel need→ore_iron need）？
4. **#5 訂正落地**：溢出 sink 改 `TileBank.pool_add` 落地池 + 補 tap/audit——框成 design change+可觀測，非「修守恆 bug」？pool_add 語意對、落地 goods 真可撿？
5. **#2 雙宣告退役**：TARGET_PER_POP（mfg 3.0 / trade 15.0 兩份）真收斂成 oracle 單源、兩 reader 都改？
6. **★非回歸**：NeedHierarchy 升全域不破現有 rank_scored_ctx 內用（#3）；食安無回歸；感知鐵律（need 讀自家/belief）；觀測 byte-identical；供應鏈無無限遞迴。
7. **切片序**：S1-S5 序合理？整 arc 完成才 measure（非拆一塊就量）對？

## ★建議升異質框外審
**統一路線圖首塊 + 大框結構重構 + 立「散亂→單一 oracle」模式（後面 threat/估值照做）**。blueprint/systems 已對齊（groupthink 風險，同 Opus 家族自驗抓不了自己的框）。unified-commerce/生產框架教訓：異質家族（Fable）框外審抓結構盲點。建議升異質。**你裁。**

## R①/R② 分工
R① 已驗前提坐實（premise 層）。R² 審**設計**（架構真統一/不藏補丁/不退化/不違 invariant）。**#1 打架=行為斷言 post-impl measurer 坐實**（非 R② 判）。

## 流向
CLEAN（+異質過）→ to:systems → dispatch implementer（worktree TDD S1-S5，整 arc 完成才 measurer full-HD）。
結構洞/假統一/退化 → to:systems halt。
