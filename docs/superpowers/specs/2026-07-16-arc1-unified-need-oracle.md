# Spec：Arc 1 統一 need oracle（散亂 need → 單一思考驅動源）

> 統一路線圖 Arc 1（用戶定「照路線架」）。**R① CLEAN**（6 前提 refute-factcheck，無 premise_contradiction，含 #2/#5 訂正、#1 打架標待 measure）。
> **原則**：框架管規則（世界物理/機制），思考驅動決策；同一概念收成單一思考驅動 oracle，所有子系統讀它，不各養一套。

## 根（R① 坐實 + 訂正）
- **#1 食物 need 散 ≥6 閾**（CONFIRMED）：`URGENCY_DAYS=1`/`WARNING_DAYS=3`/`DESPERATION_DAYS=3`/`SURVIVAL_RECOVER_DAYS=7`/`SLACK_COMFORT_DAYS=7`/farming deficit `×14`/restock `RECOVER+14`，≥4 脈絡。部分 **comment-based 對齊**（WARNING↔DESPERATION、RECOVER↔SLACK）=**脆弱耦合**（改一處另一處不跟）。`food_security_target(_lvals)`=唯一真人格化。**「閾真打架」=行為斷言 → 待 post-impl measurer**（靜態查不到同時矛盾判定）。
- **#2 TARGET_PER_POP 雙宣告不一致**（訂正，比原前提更嚴重）：`manufacturing_system:30` 與 `trade_valuation:30` **各宣告一份、數值不同**（goods：mfg=3.0 vs trade=15.0=**同名兩義**）。trade 側 `reserve()` 已乘 `_reserve_factor`（人格化）；mfg 側 `:145` 配方排序仍純 flat。
- **#3 NeedHierarchy 現僅引擎內乘子**（CONFIRMED）：`decision_context:385-386` 填 `need_urgency`，唯一消費 `decision_engine` rank 內部；order/facility/trade 皆不讀 → **升全域 oracle=純擴增不破現有 caller**。
- **#4 供應鏈傳導結構支援**（CONFIRMED，需 new code）：`RECIPE_GROUPS:42-67` out→in 兩層乾淨鏈（weaponsmith→ore_steel→smelter→ore_iron）、**無循環**、純 flat dict → 支援新寫 transitivity 走訪，但**無現成回推碼**。
- **#5 _add_output 溢出=明文設計 sink**（訂正，非隱藏蒸發）：`:127` 註解自陳「capped add，溢出 drop=sink」→ 真該收=**此 sink 未進 tap/audit（可觀測性缺，非守恆破壞）** + blueprint「溢出落地」=**改 sink 為 `TileBank.pool_add` 落地池（design change，物質留圖塊可撿）**。
- **#6 goods 純貿易品**（CONFIRMED）：6 配方 goods 從不在 `in`，全 codebase 無 `goods -= x` 消費，只 tax/trade/loot 轉移。

## 架構：NeedOracle（全域 need 源，思考驅動非常數）
`NeedHierarchy` 升成全域 `NeedOracle.need(state, team, resource) -> float`（或平行新 module），所有子系統唯一 need 查詢點。
```
need(team, res) = self_use(team, res) + supply_chain(team, res) + trade(team, res)
```
- **自用**（消耗品）：**消耗率 × pop × 人格 buffer 天數推導**，非 TARGET_PER_POP：
  - food = `FOOD_PER_PERSON_PER_DAY × pop × food_security_target(_lvals)` 天。
  - 武器/tools/藥/armor = 各自戰耗/造耗/傷耗率 × buffer（沿用既有 rate 常數=世界物理 flat；buffer 天數人格化）。
- **供應鏈**（中間品）：**下游 need × 配方係數傳導**（RECIPE_GROUPS out→in 走訪）——要產劍（weaponsmith need>0）→ 回推 ore_steel need → 回推 ore_iron need。新寫 transitivity walk（有限層、無循環已驗）。
- **貿易**（全資源）：市場買單 + 致富野心 + 商隊可載，**綁 deal 側（能賣掉才算餘量可賣）**。goods 只有此源。**消耗品也適用（非互斥桶）**。

## 生產/商業共讀一個 need（防打架架構）
**餘量 = holding − need(team, res)**，一真值源兩邊讀：
- **生產**（規則機制）：`need > holding 且 can_make` → 產；`holding ≥ need`（全滿）→ **停產**（個別設施各停，別燒 material 換蒸發 goods）。
- **商業**（規則機制）：`need > holding` → 買；`holding > need`（餘量）→ 賣。
- 餘量定義天然一致 → 無「兩邊各判界線」→ 無打架。加資源/系統只加進 need 定義，兩邊自動接。

## 含（本 arc 一起收）
- **停產接需求**：manufacturing produce-decision 查 oracle need，滿則停。
- **溢出落地守恆**（#5 訂正框架）：`_add_output` 溢出改 `TileBank.pool_add`（落圖塊自然池、可撿）取代 drop-sink；**並補 tap/audit**（溢出量入 Probe + InvariantAudit 記帳）——落地是 design change，補 tap 是可觀測性。
- **消耗品可貿易**：trade need 對全資源。

## 資源分類（need 來源的結果，非預貼標籤）
food(自用+貿易) / ore·steel(供應鏈+貿易) / goods(只貿易) / 軍備(自用+貿易)。分類自然掉出。

## 交付切片（impl TDD）
- **S1 NeedOracle 骨架 + 自用推導**：`need()` 自用項（消耗率×人格 buffer 推導），**退役 TARGET_PER_POP 雙宣告**（mfg+trade 都改讀 oracle）。wire facility deficit(food) 當 proof reader。
- **S2 供應鏈傳導**：RECIPE_GROUPS out→in transitivity walk → 中間品 need。
- **S3 貿易 need（綁 deal 側）**：market 買單+野心+可載，能賣才算餘量可賣。
- **S4 生產/商業共讀 + 停產**：manufacturing produce + order/trade buy-sell 全改讀 oracle 餘量；滿則停產。
- **S5 溢出落地守恆 + tap + migrate 剩餘食物閾 reader**：`_add_output`→`TileBank.pool_add`+tap/audit；6 閾 reader 收斂讀 oracle。
- ★整 arc 完成才 measurer full-HD（非拆一塊就量）。

## 非回歸
- **世界物理常數不動**（消耗率/FOOD_PER_PERSON_PER_DAY/RECIPE 係數/cap=flat）；只 need 判斷層改。
- **NeedHierarchy 現有引擎內用途不破**（#3：純擴增，rank_scored_ctx 既有讀法保留）。
- **食安無回歸**（need 收斂後餓隊仍優先食物、生產框架 survival-crush 相容）、守恆（溢出落地+記帳、CoinAudit/InvariantAudit=0）、感知鐵律（need 讀自家/belief 非 god-view）、觀測（新 tap 禁耗 RNG/禁污染 byte-identical）。
- **供應鏈 walk 有限層無循環**（#4 已驗）→ 無無限遞迴。

## 閘
- **R① CLEAN**（本文根=驗證後前提，含 #2/#5 訂正）。
- **R② 必過**（大框設計審）。可能升異質框外審（統一 arc 首塊、大框，blueprint/systems 對齊）——reviewer 裁。
- **measurer full-HD**（arc 完）：need 收斂成一套、生產/商業共讀無打架（#1 打架斷言 post-impl 坐實：threshold 矛盾判定消失）、TARGET_PER_POP 退役、供應鏈 need 動、貿易 need 綁 deal（成交是否升）、停產（不燒 material 換蒸發）、溢出落地（物質守恆+可撿）、守恆、byte-identical、無回歸。

## 溯源
blueprint `unification-roadmap-arc1-need-oracle`（用戶定照路線架）；R① `reviewer-to-systems-need-oracle-r1-clean`（6 前提 factcheck + #2/#5 訂正 + #1 打架待 measure）。前提先驗＝ [[feedback_fileline_vs_interpretation]] 制度化。
