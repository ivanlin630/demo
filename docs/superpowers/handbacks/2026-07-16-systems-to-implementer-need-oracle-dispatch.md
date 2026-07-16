---
from: systems
to: implementer
status: consumed
topic: "[DISPATCH·統一路線首塊大框 TDD] Arc1 need oracle v2——R①CLEAN+R²CLEAN(異質)全過。worktree feat/need-oracle@origin/main。★核心兩量:need_keep(自用+供應鏈)+demand(貿易),reader組合方向正確。TDD S1骨架+自用(退役延S4+fallback)→S2供應鏈gap→S3貿易demand→S4共讀兩量+per-recipe停產+TARGET_PER_POP退役→S5溢出落地雙sink+migrate。每slice Tier1。整arc完成handback to:systems(→measurer full-HD)。禁AskUserQuestion"
---

# [DISPATCH] Arc1 統一 need oracle v2（統一路線圖首塊）

> **[worker 守則] 卡住/授權不明/做不到/疑義 → handback `to:systems`（main mailbox 絕對路徑 `A:\GDS\demo\docs\superpowers\handbacks\`），status:open。**
> **★禁 `AskUserQuestion` 中斷用戶**。雙 handback=正式授權照做。卡住報 systems。

## 授權鏈（全綠）
R① CLEAN（6 前提 factcheck）+ R² round1 issues（異質框外審抓核心方向缺陷+7 項）→ v2 訂正 → R² round2 CLEAN（核心兩量+7 項逐字核對正確、死鎖驗算解除）。**gate 全過。**

## 工作區
- worktree `.worktrees/need-oracle`，branch `feat/need-oracle`（已建，base origin/main `c3c2fa34`，含 v2 spec）。
- **code 寫 worktree、handback 寫 main mailbox 絕對路徑**。arm inbox-watch。

## spec（唯一真相）
`docs/superpowers/specs/2026-07-16-arc1-unified-need-oracle.md`（v2）。

## ★核心架構（別踩回單標量）
**獨立新 module `NeedOracle`**（`NeedHierarchy` **零改動**——它是心理五層系統、不同概念）。出**兩量**：
- `need_keep(team,res)` = 自用(消耗率×人格buffer推導) + 供應鏈(gap傳導)。**保留向。**
- `demand(team,res)` = 貿易(非幽靈買單+野心+可載,綁deal側)。**流出向。**
- reader 組合：生產目標=`keep+demand`、可賣餘量=`holding−need_keep`、實際賣=`min(餘量,demand)`。**方向正確、死鎖解。**

## impl 序（TDD，★每 slice 至少 Tier1 sanity 防中間態盲飛）
1. **S1** NeedOracle 骨架 + 自用推導（新 module）。**★TARGET_PER_POP 退役延到 S4**；S1-S3 未實作分量 **fallback 舊常數**（防中間 target=0 全隊倒貨/價格鎖死）。wire facility deficit(food) proof。
2. **S2** 供應鏈傳導：`max(need_keep−holding,0)` **gap 非 raw** + **設施 gating**（無設施不背）+ **同 out 多配方**取可造那條/max 不重複。walk 有限層無循環。
3. **S3** 貿易 demand：**非幽靈視圖**（過期單僅履約排序不供產/停開關）+ 綁 deal 側。
4. **S4** 生產/商業共讀兩量 + **per-recipe 停產**（workshop 組 goods 滿≠tools/arrows 滿，逐配方 skip）+ **TARGET_PER_POP 正式退役**（雙宣告都切）+ `_reserve_factor` 液化落**可賣餘量→掛單量 轉換層**。**★SURVIVAL_CRUSH reconcile**：farming deficit 視野 vs food_security_target 對齊、**重驗生產框架 S2-gate crossover 手算**。
5. **S5** 溢出落地守恆：`_add_output` 溢出→`TileBank.pool_add`+tap/audit，**scope 限製造成品**；第二 sink `harvest_intake_vault`(PUBLIC_RESOURCES) 一併記帳或落地排除；migrate 剩餘 6 食物閾 reader 讀 oracle。

## ★關鍵非回歸（別踩回坑）
- **oracle 只統一 need 側；holding 側各 reader 保留自己 seam-aware 讀法**（★不改 effective_holding，否則重踩 `_facility_food_days` positional-seam 剛修好的 bug）。
- **NeedHierarchy 零改動**（§2 層獨立不變量）。世界物理常數不動（消耗率/RECIPE 係數/cap flat）。
- 食安無回歸、守恆（雙 sink 記帳 CoinAudit/InvariantAudit=0）、感知鐵律（need 讀自家/belief）、觀測 byte-identical（新 tap 禁耗 RNG/禁污染）。

## ★誠實紀律
「#1 閾打架真消失」「貿易 demand 綁 deal 使成交升」=**行為斷言待 measurer full-HD 坐實**，impl log 誠實標，別自宣「經濟已通」。

## 完成 → 交回
整 arc S1-S5 完成 + 每 slice Tier1 綠 + headless≥1000 tick 無崩 → **handback `to:systems`**（附各 slice Tier1 數字 + S4 crossover 重驗 + 誠實標待 measurer）→ systems 派 measurer 中性 full-HD → 綠才收 → Arc2。

## 溯源
spec v2 + R① CLEAN + R² round2 CLEAN（異質框外審）。
