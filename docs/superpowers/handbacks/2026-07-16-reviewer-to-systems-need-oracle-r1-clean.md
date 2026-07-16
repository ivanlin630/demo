---
from: reviewer
to: systems
status: consumed
topic: "[R①判決] Arc1統一need oracle——6前提逐一refute向factcheck:1/3/4/6 CONFIRMED、2部分訂正(TARGET_PER_POP已有情境調變非純flat)、5措辭有誤(溢出丟棄是明文設計sink非意外蒸發);無premise_contradiction可寫spec，但#5措辭要訂正、#1要標「打架」是行為斷言待measure"
---

# R① factcheck 判決：Arc1 統一 need oracle

verdict: **clean（一項措辭需訂正，一項行為斷言需標 measure）**
premise_contradiction: false

## 逐條 refute-向 factcheck（自己 grep+read，非臆斷）

### 1. 「食物 need 真散 ≥7 處、各算各的、閾不一致」— **CONFIRMED**
獨立找到的食物天數門檻（不同 file:line，非同一常數引用）：
- `faction_ai_system.gd:92 URGENCY_DAYS=1.0`
- `faction_ai_system.gd:93 WARNING_DAYS=3.0`
- `decision/terms.gd:6 DESPERATION_DAYS=3.0`（註解自承「對齊 WARNING_DAYS」——**部分有意識對齊**，非全散）
- `faction_ai_system.gd:94 SURVIVAL_RECOVER_DAYS=7.0`
- `decision_context.gd:22 SLACK_COMFORT_DAYS=7.0`（註解「=SURVIVAL_RECOVER_DAYS」——同上，comment-based 對齊非共用常數，仍是**脆弱耦合**：改一處另一處不會跟著動）
- `faction_ai_system.gd` farming `_facility_deficit` target = pop×0.8×14（14 天）
- `faction_ai_system.gd:2479` 補貨到 `SURVIVAL_RECOVER_DAYS+14`（另一 14 天用法）
- `food_security_target(leader_values)`（人格化，`decision/terms.gd`，reserve/CRUSH 項用）——**這條是唯一真正人格化、非死常數的**

精確計數：至少 **6 個不同數值**（1/3/3/7/7/14 天）+ 1 個人格函式，分散在 ≥4 個不同函式脈絡（threat/survival entry-exit、facility deficit、restock target、trade reserve）。「各算各的」屬實但要修正你的措辭：**部分已有 comment-based 對齊**（WARNING_DAYS↔DESPERATION_DAYS、SURVIVAL_RECOVER_DAYS↔SLACK_COMFORT_DAYS），不是每對都毫無關聯——但這種靠註解手動同步、非共用常數/函式的對齊本身就是統一 arc 該收的脆弱點（改一邊會忘改另一邊）。
**「閾真造成打架」（行為斷言）**：標**需 measurer**——是否真的在同一隻隊身上同時出現不一致判定（例如同一 tick 某系統判「安全」另一系統判「警戒」），純靜態讀不出，需要 measurer 跑一輪看會不會真撞見矛盾判定。

### 2. 「TARGET_PER_POP = flat 常數當 need-proxy」— **部分 REFUTED，需訂正**
`manufacturing_system.gd:30` 與 `trade_valuation.gd:30` **各自宣告一份 TARGET_PER_POP**（兩份數值不同，如 `goods`：manufacturing 版=3.0、trade_valuation 版=15.0——**這本身就是統一 arc 該收的第二個「同名兩義」洞**，比你原前提更嚴重）。
但 `trade_valuation.gd:96 reserve()` 讀它時**已經**乘上 `_reserve_factor(team, leader_values, state)`（今天早些的 market-liquidize 那輪 CLEAN 過的人格化液化係數）——**非全部 reader 都是純 flat**，trade 側 reserve 用途已情境/人格調變，manufacturing 側（`:145`）用它算配方排序目標仍是純 flat。**要求訂正**：spec 前提應寫成「TARGET_PER_POP 現有兩份宣告（manufacturing/trade_valuation 數值不一致）+ 兩種用法（trade 側已人格化、manufacturing 側仍 flat）」，不是單純「flat 常數當 need-proxy」——這個更精確的前提會讓 spec 多抓一個真洞（雙宣告不一致）。

### 3. 「NeedHierarchy 現僅引擎內部 coeff 乘子、非全域 need 源」— **CONFIRMED**
`decision_context.gd:385-386`：`NeedHierarchy.compute_raw`/`ewma_update` 填 `team.need_urgency`；唯一消費端 `decision_engine.gd:32/40/54/61-62/79`（`consistency_coeff`/`main_layer_of`，都在同一個 `rank_scored_ctx` 內部用來調變 term 權重）。**全 codebase 搜尋，order_system/faction_ai facility deficit/trade_valuation 皆不讀 NeedHierarchy**——它目前確實只是 DecisionEngine 內部的一個係數調變器，非跨系統可查詢的 need oracle。**升級為全域 oracle 不會破壞現有 caller**（現有讀法窄且封閉在 decision_engine 內，升級是純擴增不是改寫既有語意）。

### 4. 「供應鏈傳導：中間品 need 可由下游生產回推」— **CONFIRMED（結構支援，需新程式碼非現成）**
`manufacturing_system.gd:42-67 RECIPE_GROUPS` 全讀：`weaponsmith`（`weapon_melee_high` 需 `ore_steel`+`material`）→ `smelter`（`ore_steel` 需 `ore_iron`+`material`）——這是一條乾淨的兩層鏈，`ore_iron` 是原始（非任何配方的 out）。**掃全部 6 組配方，無循環**（每組 out 不會出現在會導致環路的位置），資料結構是純 flat dict（`{out, in:{...}}`），沒有現成的「回推」程式碼，但資料模型本身足夠支援新寫一個 transitivity 走訪（out→in 逐層展開）。前提「結構上支援」屬實；「已經有回推能力」不屬實（需 new code，非既有）——這個區分 spec 要寫清楚。

### 5. 「`_add_output` 溢出丟回傳值→蒸發違守恆」— **REFUTED（措辭有誤，非隱藏 bug）**
`manufacturing_system.gd:125-129 _add_output`：`TileBank.deposit(tile,res,amt,...)` **不接**回傳值。`tile_bank.gd:46-51 deposit`：`newv=minf(cur+amt,cap(...))`，回傳 `newv-cur`（實際存入量）——超過 cap 的部分確實被丟棄，**但 `_add_output:127` 那行原始碼註解白紙黑字寫著「capped add，溢出 drop = sink」**——這是**明文承認、刻意設計的資源沉降（sink）**，不是意外蒸發的隱藏 bug。**要求訂正前提措辭**：不是「違反守恆被隱藏」，是「有一個已知、有意的 sink 沒有被計入任何資源審計（`InvariantAudit` 是否把這個 sink 算進去需另查，若沒算入，遺漏的是『可觀測性』不是『守恆本身』——守恆的定義本來就允許有意的 sink，前提是要被記帳）」。這個修正後的前提對 spec 更有用：**真正該收的是「這個 sink 該不該進 tap/audit」，非「這裡憑空生滅破壞世界規則」**。

### 6. 「goods 只有貿易 need、無自用消耗」— **CONFIRMED**
`manufacturing_system.gd:42-67` 全部 6 組配方的 `"in"` 欄位逐一核對：`goods` 從未出現在任何配方的輸入端（只在 `:44/:47` 當 `"out"`）。全 codebase 搜尋 `"goods"` 出現的其他位置（稅收/貿易/掠奪/估值/玩家介面）皆是轉移（tax/trade/loot）而非消耗（沒有任何「goods -= x」式的使用扣除）。相對地 `material`/`ore_iron` 等資源明確是其他配方的 `"in"`（有消耗端）、`food` 有 `FOOD_PER_PERSON_PER_DAY` 消耗。**goods 確實是純可貿易/可囤積商品、無自身消費 sink**，前提屬實。

## 結論
6 個前提**無 premise_contradiction**（無一被推翻到「其實根本不存在」的程度），systems 可以在此地基上架 spec。但兩處要求訂正措辭/精度後才交給 spec 引用：
- **#2 訂正**：TARGET_PER_POP 是「雙宣告數值不一致 + 兩種調變程度」，不只是「純 flat」——這個更精確的前提讓 spec 多抓一個真洞。
- **#5 訂正**：`_add_output` 溢出是「已知有意 sink 未必被 audit 計入」，不是「隱藏蒸發違守恆」——用詞會誤導 spec 寫成「修 bug」而非「補觀測」，兩者對症下藥的手法不同。

**#1 的「打架」行為斷言標記需 measurer**——你原文已預期這點，我同意，靜態查不到「真的同時矛盾」，只能坐實「數值確實不同、部分靠註解手動對齊」。

## 下一站
CLEAN（含上述兩處措辭訂正）→ 你據驗證後的精確前提架 spec → R②（審設計）。
