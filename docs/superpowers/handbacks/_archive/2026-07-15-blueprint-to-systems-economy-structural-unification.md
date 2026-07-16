---
from: blueprint
to: systems
status: consumed
topic: "[經濟修向大反轉·結構非threat] 靜態稽核破死法二:主根=結構沒統一非threat。修向定:主刀=引入effective_holding accessor收斂5讀點(非3,新增trade_valuation:87 local_value+decision_context:138 has_goods)+order_system讀它讀人格+雙resolver收斂;死法二(meet_nodeal)候選根=accessor第4縫local_value誤估→賣方自以為短缺拒賣 & 訂單≠成交;死法一(387半路跑)threat照樣動態坐實掉因定B該修多少。先量再spec不變,但靜態已指結構根"
---

# 經濟修向：結構統一（不是調 threat）——靜態稽核破死法二

我派了靜態結構稽核（整個商業系統 vs 統一框架），**判決:沒統一,三層裸。而且它可能已破死法二真根**(動態還沒 root 的那個)。用戶核准把經濟修定成**結構統一重構**,非點修 threat。

## 靜態稽核硬證（file:line，稽核員給的）

### 三層沒統一
**① 資料層:accessor 縫 5 個（不是 3）**——根本無通用 `effective_holding` accessor,只 food 有 `effective_food`。決策讀 raw `team.resources`、執行讀 absorb 後（`interaction_system.gd:724-725` `_absorb_public_storage`）完整持有 → **決策-執行語意不對稱**。讀點:
| # | file:line | 讀哪欄 | 語意 |
|---|---|---|---|
| 1 | `order_system.gd:110` | `team.resources.get(res,0)` | 餘量賣單發布（非food）|
| 2 | `order_system.gd:118` | `team.resources.get(res,0)` | 短缺買單發布 |
| 3 | `order_system.gd:252` | `merchant.resources.get(o.res,0)` | arb 有無貨可賣 |
| **4新** | `trade_valuation.gd:87` | `team.resources.get(res,0)` | **`local_value` 估值→餵 arb gain(:243/:256)+ask/bid(:805-806)** ★最深遠 |
| **5新** | `decision_context.gd:138` | `resources.get("goods",0)>=10` | **`has_goods` gate 決定「貿易」option 能否上榜** |
- 你之前收 1-3；**4、5 是漏點**。第4縫最傷:local_value 估值錯 → 汙染挑單+定價全鏈。

**② 撮合層:雙 resolver 沒收斂**——訂單看板（決定去哪:`tick_team_orders:91`/`best_arbitrage_order:233`/`_merchant_trade_target:2044`）vs 同格 ask/bid+barter（決定實際成交啥:`_attempt_trade_direction:776`/`_attempt_barter:822`）是**兩套並存**,`settle_orders:265` 只事後 delta 對帳。**訂單非被執行物——隊照看板旅行,真成交是到場機會性 ask/bid,跟看板無關。** 另 `_find_trade_target:2078`(peer belief 估值差) 與 `best_arbitrage_order`(看板) 是兩條並存「跟誰交易」路徑,該收斂。

**③ 掛單層:人格全盲 + 死常數叢**——`order_system` 整檔零讀 `leader/values/skills`,~13 flat 死常數。**自我矛盾:同「該留多少糧」,`food_security_target(leader_values)`(`terms.gd:30-34`) 一份人格化、`FOOD_SELL_RESERVE_RATIO`/`FOOD_BUY_DAYS` 一份死常數並存。** 孤兒常數 `SURPLUS_RESERVE_MULT`(`order_system.gd:5` 宣告從未引用)。

**④ 引擎接入部分**——高層「貿易vs逃vs戰」走 `DecisionEngine.rank_scored`(`faction_ai:1479`)✔乾淨;但 target 選(`options.gd:178`→`_merchant_trade_target` if/else三層fallback)+ 成交執行 + 掛單層全在引擎外硬碼。

**⑤ 觀測盲點（違憲）**——accessor 縫**本身不可觀測**:躲 public_storage 的貨對決策 tap 隱形,A 縫無法從 tap 抓(違反全量暫態可觀測性)。另 `_find_trade_target` 整條零 tap、ask/bid 未成交無專屬 tap（只聚合 `meet_nodeal` 分不出「沒貨/價差/撲空」）。

## ★靜態破死法二（meet_nodeal 12/14，動態原本全黑）
到場談崩的結構候選根:
- **accessor 第4縫**:賣方貨囤 public_storage → `local_value` 讀 raw 看不到 → **自以為短缺→拒賣/甚至想買** → 談崩。
- **雙 resolver**:買方照看板走到賣方,到場成交走機會性 ask/bid（跟當初那張單無關）→ 供需窗對不上 → nodeal。
**= 結構 bug,非死常數、非 threat。**

## 修向（用戶核准，結構統一非調 threat）

| 死法 | 根 | 性質 | 修 |
|---|---|---|---|
| 一（半路跑 96%）| threat preempt（**待動態坐實掉因**）| 行為/願景 | B threat 韌性（該修多少待量定）|
| 二（談崩 86%）| accessor第4縫 + 雙resolver | **結構** | effective_holding 統一 + resolver 收斂 |

**主刀（結構統一，你要的統一框架式）：**
1. **引入 `effective_holding(state,team,res)` accessor**，收斂 5 讀點（1-5），廢掉 absorb/spill 臨時搬運 dance。**這次真收全,別留第6點。**
2. **`order_system` 掛單層讀它 + 讀人格**（發買賣單門檻人格化,消 B★不一致:食物留底統一走 `food_security_target`,廢 `FOOD_SELL_RESERVE_RATIO`/`FOOD_BUY_DAYS` 死常數;清孤兒 `SURPLUS_RESERVE_MULT`）。
3. **雙 resolver 收斂**：訂單看板與到場撮合對齊（到場成交該認當初旅行的那張單,非另起機會性 ask/bid），`_find_trade_target` 與 `best_arbitrage_order` 收斂成單一「跟誰交易」路徑。
4. **補 accessor 縫 tap**（重構前先讓縫可觀測——躲 public_storage 的貨要能從 tap 抓,守全量暫態可觀測性不變量）。

**第二刀（死法一，附帶）：** 動態坐實 387 掉因分佈（切threat?過期?timeout?目標消失?）→ 確認 threat 真是那 96% 的解 → 定 B threat 韌性該修多少（商隊 threat 門檻人格化,`PRIO_THREAT` vs `TASK_TRADE` 別 flat 平權）。**這刀待量,別先動。**

## 紀律（不變）
- **先量再 spec 仍成立**:主刀結構根靜態已強證,但 spec 前 **死法二 hypothesis（local_value 誤估→賣方拒賣）值得動態抽一筆確認**（賣方到場時 local_value 真的誤判短缺?）——別重犯純從 code 推。死法一掉因**必動態坐實**才定 B。
- **reviewer R②**:主刀是大框結構重構,spec 鎖後 dispatch/merge 前必過 reviewer（大改 accessor+resolver+掛單三層,升審設計對齊）。
- **line 252 已在此 5 讀點收斂內**（不再單獨正交收,併主刀一次收全）。

## 下一站
系統:①動態坐實死法一掉因 + 抽驗死法二 local_value hypothesis → ②spec 結構統一主刀（effective_holding + order_system 人格 + resolver 收斂 + tap）→ ③reviewer R② → ④impl → ⑤measurer 中性 full-HD（arrive%升 + deal真發生 + meet_nodeal降 + coin三池動 + 掛單噪音降）→ ⑥我批。
**經濟一次做成統一框架,不點修。死法二結構根、死法一 threat 願景(B),兩刀分明。**
