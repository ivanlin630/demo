---
type: spec
owner: systems
topic: 後勤統一 SLICE A（供給-delivery convoy = GATE-B 撮合物理送貨）HOW
status: ready-for-R2
---

# HOW spec：後勤 SLICE A — 供給-delivery convoy（GATE-B 撮合物理送貨）

> **measure 定案（賣方 dump e6a9d31b 第一手）**：GATE-B 撮合 0 成交真 gap＝**供給 holder 菜單根本沒「把貨搬到交易點」option**（Team3 surplus=400 但 applicable 無 deliver option、`ever_moved=false`、`granary material=0` sell 單從不 deposit→material 物理從不離賣方→買方 order 永不 fulfilled）。**非 argmax 輸、非 spatial——是 option 不存在**（決策層 fire 正常已 measured）。
> **blueprint reframe + 背書**：logistics arc＝execution/delivery 層；SLICE A＝供給-delivery convoy（後勤 arc 物理送貨第一刀）。**★驗收線（WHAT 鎖）**：①deliver convoy 真派真到真 deposit granary ②★`fulfilled>0`（材料第一次真換手）③貨物理真離開賣方。

## 1. scope（兩塊：新 deliver option + convoy 生命週期）
- **(A) 新 deliver 決策 option**（菜單缺這個＝根）：surplus holder 有 res X surplus + 知有市場 demand → 生「deliver X 到市場」candidate，**走 util 秤入既有 argmax**（非 scripted；economy 決策本 fire 正常、只缺這 option）。
- **(B) convoy 生命週期物理送貨**（②③④ plumbing）：porter 把 X 物理搬到市場 granary。
- 兩塊一體＝「賣方送貨去買方 demand 市場」。DELIVER 呼 `_market_visitor_sell` 直接 settle 買方 buy 單 → fulfill。

## 2. (A) deliver 決策 option（新）
> **★R² 後訂正（implementer 建前抓、systems 親驗坐實 2026-07-31）**：原 spec 名 `_nearest_market_outpost_with`（=找有 STOCK 的市場、for 買方）+ `_market_visitor_buy`（買方拿貨）＝**對「賣方送貨去 demand 市場」語意反向**。正確積木：**demand finder=`OrderSystem.best_arbitrage_order`（order_system:233，掃 `received_buy_orders`→回下 buy 單隊市集 pos+res+order_id，belief-gated）**；**fulfill hook=`_market_visitor_sell`（interaction:805，賣方 deposit X 入 buyer tile granary+`_settle_owner_order` settle buy 單→`order_fulfilled++`+得 coin）**。且 measure 證買方 seek_market=5 幾乎不 visit → 「賣方 deposit 自家 granary 等買方 visitor_buy」雙跳**不會 fulfill**；**只有賣方直達 buyer 市場 visitor_sell 這條路能達驗收線②**。
- **觸發**：隊有 res X surplus（`effective_holding(X) > TradeValuation.reserve(X) + margin`）**AND `best_arbitrage_order` 找到 known 買方市場掛 buy X order**（belief-gated via `received_buy_orders`；★感知鐵律讀 belief 非 god-view）。★**不 gate ARCHETYPE_TRADE**（任何 surplus holder 皆可 deliver，非只商隊——Team3 生產隊菜單缺這個=根）。
- **生 candidate**：`{task: TASK_CONVOY, target: 買方市場 pos, cargo: {X: deliver_qty}, kind: "deliver", order_id}` 入 rank 池。deliver_qty = min(surplus−reserve, 買方 order qty, 載重上限)。
- **util（util 秤非 scripted）**：`payoff = 賣 X coin gain（deliver_qty × 市場 bid 價）`正規化 → 走既有 `_candidate_util`（payoff×dev_coeff×discount）。economy 決策 fire 正常 → 這 option 加了 when surplus+demand 會 fire。
- **★measured 驗（本 session 鐵律：決策問題先 dump per-option util）**：加 option 後 **dump 賣方（Team3）per-option util 驗此 candidate 真 fire**（贏 argmax when surplus+demand），**非假設**。

## 3. (B) convoy 生命週期（物理送貨，②③④ plumbing）
- **② 新 `TASK_CONVOY`**（team_data.gd 加常數；加進相關 arrays 如需 sticky 則列 active-transit，★但④：非 IDLE active task 本 sticky，不需 persist-hold）。
- **porter subteam dispatch**（複用底盤 subteam_system）：抽 pop + **FETCH cargo**（從母隊 vault/inventory withdraw X，複用 `_fund_subteam_from_vault` 撥款樣式 + 載重上限 cap）。
- **③ convoy 各階段專屬 `_evaluate_subteam` early-return 分支**（比照 TASK_BUILD/SETTLE `faction_ai:1719-1760`，防 generic fallback `:1753-1755` 攔截半路棄貨）：
  - `FETCH`：取貨（源=母隊 tile vault/私產）→ 掛 OUTBOUND。
  - `OUTBOUND`：travel 到市場（move_target=市場 pos）。
  - `DELIVER`：到**買方市場** → 呼 **`_market_visitor_sell`**（賣方=visitor、buyer=owner）→ deposit X 入 buyer tile granary + `_settle_owner_order`（settle buy 單→`order_fulfilled++`）+ coin 換手。★**這步就是 fulfill**（非「deposit 自家 granary 等買方 visitor_buy」雙跳，measure 證雙跳不 fulfill）。
  - `RETURN`：travel 回母隊 → 到家**釋放抽出 pop**（★非 `_convert_to_resident` settle、非 `try_merge_back` 整隊併入消失——完整返航釋放 pop）。
- **④ 撤 persist-hold**（子隊非 IDLE 本 sticky `faction_ai:1758-1760`「duty 壓制投機」）→ 防護靠③專屬分支、非 persist。

## 4. 接既有撮合（GATE-B 活）
DELIVER 步的 `_market_visitor_sell` **直接 settle 買方 buy 單** → **`order_fulfilled>0`**（材料第一次真換手，賣方直達買方市場成交、非等買方來）。

## 5. 憲法對齊
- deliver option **util 秤入既有 argmax**（非 scripted）；**感知鐵律**（demand 讀 belief/known 市場非 god-view）。
- convoy **純算術零 RNG**；tap：`convoy.dispatch/fetch/deliver/return` + cargo 量 + deliver option fire（禁 RNG）。
- **cargo 守恆**：賣方 vault − / porter carry / 市場 granary + 全程守恆。

## 6. ★★TDD + 驗（blueprint 三驗收線 + 第一驗收 execution-verified）
- **★①deliver convoy 真派真到真 deposit**：seeded 場景（賣方 surplus X + 買方 demand X + 市場）→ deliver convoy `convoy.dispatch>0` → FETCH（賣方 vault X 減）→ DELIVER（市場 granary X 從 0 升）→ RETURN（pop 回）。
- **★★②`order_fulfilled>0`**：和平床 re-run，material `order_fulfilled` 從 0 起來（買方真買到 delivered material）。
- **★③貨物理真離開賣方**：賣方 material 真到市場倉（`ever_moved=true`、material 真離 inventory 到 granary、非留家）。
- **★deliver option 真 fire（measured）**：dump 賣方 per-option util，deliver candidate 贏 argmax（本 session 鐵律：別假設決策 fire）。
- **不凍**（seed1337 attrition 非→0，convoy 只抽少數 porter）+ cargo 守恆 + 純算術零 RNG + determinism 三跑 + constitution 74 + observability + headless 0-new。

## 7. 交付
→ R²（★異質：deliver option util 秤真 fire[measured 非假設]/convoy 生命週期不被既有 settle/merge 攔[③專屬分支]/cargo 守恆/感知鐵律 demand 讀 belief/不凍）→ implementer → measurer（★三驗收線：真派真 deposit + fulfilled>0 + 貨真離賣方）→ QA。**★這是後勤 arc 物理送貨第一刀、GATE-B 撮合真 fix、measure 定案 grounded。** 分配 B/貿易 C 照舊。
