---
from: implementer
to: systems
status: open
date: 2026-06-21
feature: economy-ws2b-market-visibility
branch: feat/economy-ws2b-market-visibility
---

# Hand Back: 經濟 WS-2b 市集訂單可見性（破死鎖）

## 一句話結論

WS-2b 機制（看板登錄 + 抵達親讀 + 商隊巡市集）**已實作並在確定性整鏈測試驗證成交**
（fulfilled=1）。但 **world_sim 履約率仍 0%**，root 已 measure-first 鎖定：商隊被
**chronic survival 壓制**（`g1.merchant_survival=18837`），永不出門到市集 → 機制無法被
exercise。此即 plan 預告的「次要旗標（本 WS 範圍外）」，未硬修，量測數據呈報如下。

## 實作摘要（改了哪些檔案）

- `scripts/data/tile_data.gd`：加 `market_orders: Array` 欄位（市集看板；active_orders 的
  可見性鏡像，權威仍在 active_orders）。
- `scripts/simulation/order_system.gd`：
  - `_register_on_board`：post_order 時於發起隊最近自家市集 outpost tile 登錄 board entry。
    漫遊隊（無自家 outpost）不登錄 → 回退既有碰面傳播。
  - `read_market_board`：隊抵達市集 outpost tile → 把看板**非自己**的單轉 honest
    （`is_distorted=false`）order_buy/sell message 注入 team_known（去重 by order_id）。
  - `_sync_board`：tick_team_orders 過期清理段同步——過期/已滿足(qty≤0)/已從 active_orders
    移除的本隊 entry 從看板清（不留幽靈單）；他隊 entry 不碰。
- `scripts/simulation/sim_runner.gd`：`_step3c_read_market_board`（near/far 區 _step3b 後），
  對 arrived_ids（走到 move_target 的隊）呼 read_market_board。
- `scripts/simulation/faction_ai_system.gd`：
  - `_merchant_trade_target` 無 arb → `_nearest_market_outpost`（非自家、outpost_level>0）巡市集。
  - **faction member 路徑（_evaluate_member_goals, line ~788）同步放寬**：原本卡
    `best_arbitrage_order` 非空才 dispatch TASK_TRADE = 同一死鎖的 member 變體（商隊永不出門
    →永不碰看板→永無 arb）。改為 `_can_trade` 即經 `_merchant_trade_target` dispatch
    （含無 arb 巡市集）。
  - 留 `g1.merchant_survival` 探針（量測旗，供下一個 measure-first WS）。
- `scripts/debug/headless_test.gd`：四新測（見下）。

### 守 G3 / 守恆（用戶關切）
- **firsthand 親讀 = honest 不失真**：read_market_board 注入 `is_distorted=false`，origin_pos=
  市集 tile。**轉述他隊仍走既有 `propagate_on_arrival` 失真，零改**。
- **無全域/無在場可見**：read_market_board 守 `outpost_level>0` 且讀的是 `team.tile_pos`
  的 tile → 沒站到市集 tile 就讀不到（測試 `_test_market_board_read` 含此斷言）。
- **守恆**：純資訊（team_known/board 登錄）+ 派工，不碰 resources/coin。成交走既有
  `_resolve_market`/`settle_orders`。board 過期/滿足同步清（_sync_board）。world_sim
  不變量違反累計=0。

## 回歸閘（headless，全綠）

```
market board register OK
market board read OK
merchant seek market OK
market trade chain OK (fulfilled=1)
=== DONE ===
投靠守恆整合 OK            （coin_eq）
InvariantAudit population OK
InvariantAudit faction 雙向 OK
InvariantAudit subteam 雙向 OK
```
0 SCRIPT ERROR、0 Assertion failed。

## world_sim 權威量測對照（本 WS 成敗關鍵）

| 指標 | 前次(plan 診斷) | 本 WS（3 跑一致範圍） |
|---|---|---|
| 訂單履約率 | 0% | **0.0%**（未改善） |
| [Market]成交 (g1.arb_hit) | 0 | 0（n/a） |
| g1.order_placed | ~ | 4961–4990 |
| g1.board_register（新）| n/a | **4831–4834**（看板登錄正常運作）|
| g1.seek_market（新）| n/a | 2 → **113–123**（放寬 member gate 後商隊大量巡市集）|
| g1.market_arrive（隊抵市集）| n/a | **0** |
| g1.merchant_survival（新探針）| n/a | **18837**（商隊卡 survival）|

3 跑數字穩定一致（world_sim unseeded 但此差異是結構性，非 RNG drift）。

### 解讀（measure-first 鏈路逐環驗證）
1. **看板登錄 ✅**：board_register 4831 → 賣家訂單確實上看板。
2. **巡市集意圖 ✅**：放寬 member gate 後 seek_market 2→113，商隊**大量設定**市集為 move_target。
3. **抵達 ✗ root**：market_arrive=0、merchant 在 2 年內只完成 1 次任何 journey
   （診斷探針 merchant_arrive=1，已移除）。商隊設了市集目標卻**從不抵達**。
4. **真因 = survival 壓制**：merchant_survival=18837 — 商隊在絕大多數 faction-eval tick 卡在
   SURVIVAL_TASKS（return_home/forage/...，line 783 sticky skip）→ 永遠在家覓食/回家，
   TASK_TRADE 永遠搶不到手 → 永不出門 → 機制三環缺第三環。

> 即 plan §Self-Review「次要旗標」：「全隊卡 return_home[survival]（有糧仍 survival）可能
> 壓制商隊出門 → 別在本 WS 硬修」。本 WS 嚴守此界線，未動 survival 邏輯。

## 是否被 survival 壓制？

**是，這是 world_sim 仍 0 交易的決定性原因。** 機制本身正確（確定性整鏈測試 fulfilled=1
證明：賣家掛單→登錄看板→商隊巡市集→抵達親讀→取得跨隊 arb→co-locate 成交→沖單→board 同步清
全鏈通）。world_sim 商隊因 chronic food survival 永不離家，無法走完此鏈。

## 連動風險

- `faction_ai _evaluate_member_goals`：放寬了 merchant trade gate（不再要求 arb 非空）。
  軍隊/生產 tag 不受影響（守 `tags.has(TAG_MERCHANT)`）。無 arb 的商隊現在會去巡市集
  而非做徵收/外交 —— 對「友軍商隊」是預期行為（本來就該去市集）。若 systems 認為商隊也該
  分擔 faction 徵收/外交，可加 cadence 分流（非本 WS）。
- `_step3c_read_market_board` 每 tick 對 arrived_ids 跑（near 每 tick / far 每 FAR_ZONE_INTERVAL）：
  read 內有 outpost 守衛 + 去重，無在場零成本。效能可忽略。

## 待主 session（systems）確認 / 建議後續 WS

1. **下一個 measure-first WS（高優先）= 商隊 survival 壓制**。`g1.merchant_survival=18837`
   是直接證據。需查：商隊（pop 6，無生產 outpost）食物為何長期 days_left < WARNING_DAYS →
   恆觸發 survival。可能 ① 商隊無糧來源（不採集不生產，只靠貿易進食，但貿易又被 survival 鎖
   = 二階死鎖）② SURVIVAL_RECOVER_DAYS 門檻 / hysteresis 對商隊不適用。
   **建議**：商隊 survival 釋放條件或商隊基礎口糧路徑（讓商隊能短暫出門再回補），是讓 WS-2b
   機制真正生效的前置。
2. **留存探針**：`g1.board_register`、`g1.seek_market`、`g1.market_arrive`、`g1.merchant_survival`
   為永久觀測點（Probe-gated，零生產成本）。下一 WS 修 survival 後，看 market_arrive 是否
   由 0 → 正、履約率是否脫 0，即驗收信號。
3. **本 WS 機制視為 done-but-dormant**：碼正確、單測綠、確定性鏈成交；待上游 survival 解鎖
   後 world_sim 履約即應脫 0（無需再改本 WS 碼）。
