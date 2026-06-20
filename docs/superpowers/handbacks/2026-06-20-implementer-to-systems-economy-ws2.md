---
from: implementer
to: systems
status: consumed
date: 2026-06-20
feature: economy-ws2-marketplace
branch: feat/economy-ws2-marketplace
plan: docs/superpowers/plans/2026-06-20-economy-ws2-marketplace.md
---

# Hand Back: 經濟 WS-2 市集節點 + 解角色卡死

## 實作摘要

三病三修全數落地，純決策/派工/order pos routing，**未碰 resources/coin 數值**（成交仍走既有 `_resolve_market` 守恆交易）。

- `scripts/simulation/order_system.gd`：
  - 新增 `_market_pos(state, team)` helper：掃 `state.world.tiles` 找下單隊**自家** `outpost_owner==team_id && outpost_level>0` 最近者；無→fallback `team.tile_pos`。
  - `post_order` 的傳播副本 `origin_pos` 改用 `_market_pos`（固定會合市集）。`active_orders` 內部記帳與 `settle_orders` 不動。
- `scripts/simulation/faction_ai_system.gd`：
  - 新增 const `MERCHANT_TRADE_BONUS = 0.5`（TEST VALUE）。
  - `_evaluate_solo`：商隊-tag 隊 `_can_trade` 分支內 `scores[TASK_TRADE] += MERCHANT_TRADE_BONUS`。FLEE（`food_pc<2.0`）分數不動 → 絕境仍優先逃。
  - `_assign_member_tasks`：survival-sticky guard 後、徵收/外交/攻擊 elif 鏈**前** hoist 商隊-tag member 貿易意圖（須 `_can_trade` 且 `best_arbitrage_order` 非空才搶先，否則落回原鏈）。`PRIO_DISPATCH`，僅商隊 tag。
- `scripts/debug/headless_test.gd`：三新測試 + `_mk_order_msg`/`_merchant_inv_qty` helper，註冊於 `_initialize` 尾。

## 回歸閘結果（全綠）

- `=== DONE ===` ✅
- 0 SCRIPT ERROR / 0 Parse Error / 0 Assertion failed（全 run 計數 = 0）✅
- coin_eq 守恆 assertion 通過（`_test_join_conservation` 等）✅
- InvariantAudit population / faction 雙向 / subteam 雙向 OK ✅
- **三新測試**：
  - `order market routing OK`（sell 單 origin_pos route 到 outpost(3,3) 而非隊位(9,9)；無 outpost fallback 隊位）✅
  - `merchant trade dispatch OK`（獨立商隊 surplus+arb+非絕境 → 派 TASK_TRADE）✅
  - `trade chain end-to-end OK (fulfilled=1)`（確定性 2 隊：賣家發 sell 單 route 到 outpost → co-locate `_resolve_market` 成交 → `settle_orders` 沖 sell 單 → `g1.order_fulfilled` bump；賣家 goods 減、買家 goods 增，守恆）✅

## world_sim 煙霧（非確定，僅趨勢）

| 指標 | 前次基線 | 本次 |
|---|---|---|
| `[Market]成交` | 2 年 5 次 | `game_sim_multi`(~21600 tick≈2.5 年/config) **8 次**；`game_sim_test`(短跑) 1 次 |
| 訂單履約率 | 0% | `game_sim_test` **1.5%**（order_fulfilled=2 / placed=131）；arb_hit=1 |

- **商隊確被派貿易**：world_sim 出現多筆 `[Market] TeamX <-> TeamY 成交（公庫接入）`，dispatch 鏈通了（前次幾乎不 fire）。
- **無 over-trade 跡象**：多數隊照常 PopMgmt/leader comply/覓食/長大；無「隊棄守全去貿易」。pop_final 各 config 隊存活，未崩。
- 履約率仍低（1.5%）= 短缺買單(shortage_buy=102)海量但商隊載量/co-location 機率有限；屬 WS-3(carry cap)/後續 throughput 議題，非本 WS dispatch 正確性問題。dispatch+routing+settle 整鏈已證通（確定性測試）。

## 連動風險 / 待主 session 確認

1. **`MERCHANT_TRADE_BONUS=0.5` 與 hoist 條件 = TEST VALUE**。目前 world_sim 未見 over-trade，但長跑/高商隊密度下若見隊棄守，請調降 bonus 或收緊 hoist arb 門檻。本實作保守（僅商隊 tag、member 須真 arb 單才搶先），blast radius 受限。
2. **`game_sim_multi` 的 `[InvariantViolation] known_reputations 含死 Team`**：屬**既有** B-class 單欄位 target 瞬時懸空（`known_reputations` G3c 信譽圖，invariants.md「team reference 契約 B」描述），**與本 WS 無關**（本 WS 未碰 reputation/erase 路徑）。registered `InvariantAudit.check`（headless）仍全 OK。提報供知悉，非本 branch 引入。
3. **履約率提升幅度受 throughput 限**：market 解了 co-location、角色卡死解了 dispatch，但「一次能搬多少貨」未動（WS-3 carry cap + 馬車）。藍圖驗收「履約率 >> 0」方向成立（0→正），絕對值待 WS-3/WS-1 餵滿信號後再放大。

## 偏離 plan

無功能偏離。唯一微調：end-to-end 測試的 sell 單 qty 由示意值改為 30（< 本次成交量 66）以確保整單沖銷觸發 `g1.order_fulfilled` bump（該 Probe 只在 `qty_remaining<=0` 時 bump，部分履約不 bump）——符合 plan「fulfilled>0」斷言意圖。
