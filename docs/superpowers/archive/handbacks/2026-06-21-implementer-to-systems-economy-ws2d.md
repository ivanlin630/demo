---
from: implementer
to: systems
status: consumed
date: 2026-06-21
feature: economy-ws2d-provisions
branch: feat/economy-ws2d-provisions
---

# Hand Back: 經濟 WS-2d — 旅途乾糧（解糧倉拴住商隊）

## TL;DR（本 arc 總驗收信號）

**糧倉拴住已解：board_read 0→10~15、order_fulfilled 0→1（run1）。** 但 **[Market]成交仍 0、訂單履約率仍 ~0%**。
卡點已從「商隊出不了門（survival 拽回家）」**前移**到「商隊到市集+讀板了，但同格 interaction trade 不結算」。
下一環 = `_resolve_market` / 同格 trade 條件（measure-first，**未硬調**，照 plan「若仍 0」分支）。

## 實作摘要

- `scripts/simulation/resource_system.gd`：
  - 加 `const PROVISION_DAYS: float = 10.0`（TEST VALUE）。
  - `resolve_consumption` 每隊消耗 block **後**加旅途乾糧：隊在自家 outpost(`own_granary_tile` 非 null)→ 從糧倉補 `team.resources["food"]` 到 `(pop+minor)×FOOD_PER_PERSON_PER_DAY×PROVISION_DAYS` buffer。糧倉→team **同隊轉移（守恆，非生成）**。
- `scripts/debug/headless_test.gd`：
  - `_test_travel_provisions()`：補 buffer + **守恆斷言**（糧倉+carried = 原-當日消耗）。
  - `_test_provisioned_merchant_not_tethered()`：居家補乾糧→移到非自家格→`effective_food`=carried→`_evaluate_survival` 不誤觸 return_home。
  - 兩測註冊於 WS-2c 區塊後。

與 plan 無差異（PROVISION_DAYS=10、補給點在消耗 block 後、守恆路由如 plan Step3）。

## 新測結果（headless 回歸全綠）

- `travel provisions OK (carried=120.0 糧倉剩=868.0)` — 5人×2.4×10=120 buffer，守恆通過。
- `provisioned merchant not tethered OK (carried=120.0)` — 離家不被 return_home 拴回。
- 既有閘全綠：`food granary cap OK (糧倉=2000/cap=2000)`（**WS-1 殺囤未破**，buffer 小）、`consume from granary OK`、`true desperation still survival OK`（**真絕境仍 survival**）、`survival reads granary OK`、`solo trade not starved OK`、Famine Task1a~3c 全 OK、`投靠守恆整合 OK`(coin_eq)、InvariantAudit population/faction/subteam 雙向 OK。
- **0 SCRIPT ERROR、0 Assertion failed、`=== DONE ===`**。

## world_sim 權威量測（3 跑，對照前次 0%/0/≈0）

world_sim 無 seed（drift 數字不可重現，看趨勢）：

| 指標 | 前次(WS-2c 後) | run1 | run2 | run3 |
|---|---|---|---|---|
| 訂單履約率 | 0% | 0.0%(1/4932) | 0.0%(0) | 0.0% |
| g1.order_fulfilled | 0 | **1** | 0 | 0 |
| [Market]…成交 print | 0 | **0** | **0** | **0** |
| g1.market_arrive | ~100+(plan 述) | 66 | 60 | 64 |
| g1.board_read | ≈0 | **10** | **10** | **15** |
| g1.seek_market | — | 148 | 113 | 113 |
| g1.merchant_survival | 高(拴住) | 低(未進前幾名,前次 survival 拴回消失) | 低 | 低 |

**讀數**：
- `board_read` 0→10~15 = **乾糧解拴生效**：商隊終於以 trade 意圖到市集且**讀到看板**（survival 不再每 tick 拽回家）。`merchant_survival` 不再霸榜（前次拴回元兇消失）。
- `order_fulfilled` run1 出現 1 次（前次恆 0）→ 履約管線**首次有貫穿**，但偶發、量微。
- **[Market]成交恆 0**：同格 merchant↔resident 的 `interaction_system._resolve_market` trade 未結算。market_arrive(60+)+board_read(10+) 高但成交 0 → 卡點**前移到 co-location/trade 條件**（plan Self-Review 預判的「若仍 0」分支）。

**世界健康**：無過餓崩潰（run1 存活穩、提早全滅未觸發）；囤糧未回升（WS-1 cap 仍封頂，buffer 小）。

## 卡在哪環（measure-first，未硬調）

履約 0 的**新**瓶頸（非本 WS 範圍）：商隊**到了**市集(market_arrive)、**讀了**板(board_read 0→正)，但：
1. `[Market]成交`=0 → 同格 merchant↔resident 的 `_resolve_market`/interaction trade 不觸發或條件不滿足（co-location 對齊、雙方 surplus/need 匹配、`best_arbitrage_order` 撲空等待查）。
2. `order_fulfilled` 偶發 1 但無對應 `[Market]成交` print → 履約記帳(`settle_orders` 淨持有沖銷)與實際同格 trade 之間可能脫鉤，或 fulfilled 來自非 market 路徑的單次淨變化。

建議下一 WS（**待系統定**，本 session 未碰）：探 `interaction_system._resolve_market` 為何 merchant 到市集後不與居民成交 —— 是 co-location 時序（讀板 tick 與 mover 同格掃描錯開）？還是 arb 選單後 `received_*_orders` 撲空（殘缺情報過期）？還是 trade 條件(雙方 local_value glut/need)不匹配？先量再開藥。

## 連動風險

- `interaction_system` / `order_system`：履約最後一哩在這兩者的 trade 結算，**非本 WS 改動**，但下一 WS 主戰場。
- `faction_ai` survival/solo/produce/build 等 8 處已讀 `effective_food`（WS-2c 既鋪），本 WS 只在消耗端補 carried，不改決策讀者。乾糧 buffer 拉高出門隊 effective_food → 已驗不誤觸 survival；對 build/produce gate（食物充裕→不過建農）方向一致，無新風險。

## 待主 session（系統）確認

1. **world_sim 履約仍 ~0、[Market]成交 0**：本 WS 達成「解糧倉拴住」子目標（board_read 0→正、survival 拴回消失），但經濟 arc 總驗收（履約脫 0）**未達**——卡點前移到同格 trade 結算。是否開 WS-2e 探 `_resolve_market`？（已 measure-first 定位，**未硬調任何常數**。）
2. **PROVISION_DAYS=10** 為 TEST VALUE，正式平衡待調。
3. **world_sim 長跑 InvariantAudit 違反（runs 2/3 出現 known_reputations 含死 Team）**：與本 WS **無關**（我只動 food；不碰 reputation/erase_team）。屬既有長跑 dangling-ref（`known_reputations` int 鍵在 team 死後被某 setter 回塞 stale id，`world_state.erase_team` 的 `.erase(tid)` 清了當下但下個 cadence 又塞）。headless `_test_invariant_audit`（clean state）仍綠。**呈報供系統決定是否另開修**（疑似 faction_ai 寫 known_reputations 路徑未驗存在），非本 WS 範圍。
