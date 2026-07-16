# Spec：Arc 1 統一 need oracle v2（散亂 need → 單一思考驅動源）

> 統一路線圖 Arc 1（用戶定「照路線架」）。**R① CLEAN + R② round1 issues（異質框外審抓核心方向缺陷+7 項）→ 本 v2 訂正 → 待 re-R²。**
> **原則**：框架管規則（世界物理/機制），思考驅動決策；同一概念收成單一思考驅動 oracle，所有子系統讀它。

## R② round1 訂正摘要（異質框外審，全採納）
- **★核心缺陷（#1）**：`need=自用+供應鏈+貿易` 單標量**混方向相反分量**（自用/供應鏈=保留向、貿易=流出向）→ 餘量=holding−need 方向反轉（goods 買家在時死守、走了倒貨、必死鎖）。**修=oracle 出兩量**（見架構）。
- 7 項 spec 級訂正全納入（見各 §）。

## 根（R① 坐實 + 訂正）
- **#1 食物 need 散 ≥6 閾**（CONFIRMED）：`URGENCY_DAYS=1`/`WARNING=3`/`DESPERATION=3`/`SURVIVAL_RECOVER=7`/`SLACK_COMFORT=7`/farming deficit `×14`/restock `RECOVER+14`。部分 comment-based 對齊=脆弱耦合。「閾真打架」=**行為斷言 → post-impl measurer**。
- **#2 TARGET_PER_POP 雙宣告不一致**：`manufacturing:30`(goods=3.0) vs `trade_valuation:30`(goods=15.0)=同名兩義。trade 側 `reserve()` 已乘 `_reserve_factor`（人格化）、mfg 側 flat。
- **#3 NeedHierarchy 現僅引擎內乘子 + §2 層獨立不變量**（`need_hierarchy.gd:1-7` 禁讀他層 urgency）→ **是 Maslow 心理急迫度系統，與 NeedOracle 不同概念**。
- **#4 供應鏈傳導結構支援**（RECIPE out→in 無循環）但需 new code。
- **#5 _add_output 溢出=明文設計 sink**（非蒸發）→ 改落地池 + 補 tap。**+ 第二 sink（#4 issue）：`resource_system` harvest `harvest_intake_vault` 亦 capped drop sink（PUBLIC_RESOURCES 落地撿回滿倉又蒸發）。**
- **#6 goods 純貿易品**（無自用消費 sink）。

## 架構：NeedOracle（★獨立新 module，出兩量）
**新獨立 module `NeedOracle`**（R② #3：強制新 module，`NeedHierarchy` **零改動**——它是心理五層系統，NeedOracle 是資源數量系統，不同概念不借殼）。對任 `(team, resource)` 出**兩量**（★核心修 #1）：
```
need_keep(team, res) = 自用 + 供應鏈        # 保留向：我要留住多少
demand(team, res)    = 貿易                  # 流出向：外部想從我這拿走多少
```
- **自用**（消耗品）：`消耗率 × pop × 人格 buffer 天數` 推導（food=`FOOD_PER_PERSON_PER_DAY×pop×food_security_target(_lvals)`；武器/tools/藥/armor=戰耗/造耗/傷耗率×buffer）。**消耗率=世界物理 flat；buffer 天數人格化。** 取代 TARGET_PER_POP。
- **供應鏈**（中間品，R② #2 三坑修）：下游 **gap** 傳導——`傳導量 = Σ 下游 max(need_keep−holding,0) × 配方係數`（**用未滿缺口非 raw need**，防已持成品仍要原料囤爆）；**設施 gating**（無該製造設施的隊不背此供應鏈 need）；**同 out 多配方**（goods :44/:47）取「該隊設施可造的那條」，多條皆可造則取 max 係數（不重複加總）。walk 有限層無循環（#4 已驗）。
- **貿易 demand**（全資源，綁 deal 側）：市場**有效買單**（R② #1-issue：produce-decision 讀**非幽靈**視圖——過期單僅供履約排序不供產/停開關）+ 致富野心 + 商隊可載。goods 只有此量（need_keep=0）。

### reader 怎麼組合（一真值源、方向正確）
- **生產目標** = `need_keep + demand`（貿易驅動生產 ✓，保留自用/供應鏈）。**per-recipe 停產**（R② #1-issue：workshop 組 goods 滿≠tools/arrows 滿，逐配方 skip 非整設施 stop）：某 out 的 `holding ≥ need_keep+demand` → 該 recipe 停。
- **可賣餘量** = `holding − need_keep`（純保留向，方向正確）。
- **實際賣量** = `min(可賣餘量, demand)`。**`_reserve_factor` 人格液化落此轉換層**（R② #7：可賣餘量→實際掛單量 乘液化，貪婪守貨/絕境鬆手安全網保留）。
- **買** = `need_keep > holding` → 買缺口。
- goods：need_keep=0 → 可賣餘量=holding → 賣 min(holding, demand)（有買家才賣、無買家不倒貨——**方向對，死鎖解**）。

## 含（本 arc 一起收）
- **停產接需求**：per-recipe（上）。demand 讀非幽靈視圖。
- **溢出落地守恆**（R② #4 修）：`_add_output` 溢出→`TileBank.pool_add` 落地池+tap/audit。**★scope 明文限定「製造成品」**（防 food/material 日後擴用撞 `regenerate_tiles` cap-clamp）；**第二 sink `harvest_intake_vault`（PUBLIC_RESOURCES）一併記帳或落地排除**（S5 閘對此資源不假）。
- **消耗品可貿易**：demand 對全資源。

## 資源分類（need 來源的結果）
food(自用+貿易) / ore·steel(供應鏈+貿易) / goods(只貿易 demand) / 軍備(自用+貿易)。

## 交付切片（TDD；★R② #5 修中間態盲飛）
- **S1 NeedOracle 骨架 + 自用推導**（新 module）。**★TARGET_PER_POP 退役延到 S4**（三分量齊才切 reader）；S1-S3 期間未實作分量 **fallback 舊常數**（防中間態 target=0 全隊倒貨/價格鎖死）。wire facility deficit(food) proof。
- **S2 供應鏈傳導**（gap+設施 gating+多配方，#2 三坑）。
- **S3 貿易 demand**（非幽靈視圖+綁 deal 側）。
- **S4 生產/商業共讀兩量 + per-recipe 停產 + TARGET_PER_POP 正式退役**（三分量齊，reader 全切 oracle）；`_reserve_factor` 落轉換層。
- **S5 溢出落地守恆 + 雙 sink 記帳 + tap + migrate 剩餘 6 食物閾 reader**。
- **★每 slice 至少 Tier1 sanity**（R② #5：中間崩潰要即時看見、可歸因）；整 arc 完成才 measurer full-HD。

## 非回歸（R② #6 三坑明處理）
- **oracle 只統一 need 側；holding 側各 reader 保留自己 seam-aware 讀法**（★不把 holding 改 effective_holding，否則重踩 `_facility_food_days` positional-seam 剛修好的 bug）。
- **SURVIVAL_CRUSH 相容**：farming deficit 視野（14 天）vs food_security_target（2-8 天 clamp）=量級差，**S4 切 reader 時明確 reconcile**（farming need_keep 天數對齊、不破生產框架 survival-crush crossover，切後重驗 S2-gate 手算）；deficit 與 `_facility_food_urgency` 撞形→重校 crossover。
- **世界物理常數不動**（消耗率/RECIPE 係數/cap flat）；`NeedHierarchy` 零改動（#3）。
- 食安無回歸、守恆（雙 sink 記帳、CoinAudit/InvariantAudit=0）、感知鐵律（need 讀自家/belief）、觀測 byte-identical（新 tap 禁耗 RNG/禁污染）、供應鏈無限遞迴防護。

## 閘
- **R① CLEAN**（前提）。**R② round1 issues→本 v2 訂正→re-R²**（異質框外審 round1 已做，v2 是訂正非新概念，收斂即可，除非引入新大框）。
- **measurer full-HD**（arc 完）：need 收斂一套、生產/商業共讀無打架（#1 打架斷言 post-impl 坐實 + 兩量方向正確無死鎖）、TARGET_PER_POP 退役、供應鏈 need 動、貿易 demand 綁 deal（成交升?）、per-recipe 停產（不燒 material）、雙 sink 溢出落地記帳、守恆、byte-identical、無回歸（食安/生產框架 crossover/holding-seam）。

## 溯源
blueprint `unification-roadmap-arc1-need-oracle`；R① `need-oracle-r1-clean`（6 前提+#2/#5 訂正）；R② round1 `need-oracle-r2-issues`（異質框外審：核心兩量方向缺陷+7 項）。前提先驗＝ [[feedback_fileline_vs_interpretation]] 制度化。
