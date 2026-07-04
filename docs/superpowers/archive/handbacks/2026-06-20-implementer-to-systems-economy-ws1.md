---
from: implementer
to: systems
status: consumed
topic: 經濟 WS-1 食物糧倉 route + 硬上限 + 滿了賣決策 — 囤糧崩 + food sell 單 fire
---

# Hand Back: 經濟 WS-1 食物糧倉

plan `2026-06-20-economy-ws1-granary.md` 全 Task 完成。branch `feat/economy-ws1-granary`。

## 實作摘要（改了哪些檔）

- `scripts/simulation/outpost_system.gd`：新增 `FOOD_STORAGE_CAP`（food 主糧 staple 專屬 per-level cap，civilian `[2000,6000,18000]`/military `[1500,4500,12000]`，比通用大避免定居隊數天餓死）；`_get_storage_cap` 加 food 分支。全 TEST VALUE。
- `scripts/simulation/resource_system.gd`：
  - `_collect_from_tile`：food 從 else（uncapped 入 team.resources，4-5萬幽靈囤）改走 outpost public_storage capped 路徑（與礦同 `if res in PUBLIC_RESOURCES or res == "food"`），over-cap drop = food sink。無 outpost fallback 仍進 team 並記 `gained`（小隊 food 仍走一般稅）。
  - `resolve_consumption`：消耗改從「team.resources + 自家糧倉」合併池吃（先扣 team 後扣糧倉）；池耗盡才雙歸零。新增 `_own_granary_tile`（team 站自家 outpost tile → 回該 tile）。飢荒判定（famine_days/satisfaction）用合併池 available，邏輯不變。mount/horse 草料維持只扣 team.resources（量小，TEST VALUE）。
- `scripts/simulation/order_system.gd`：`food` 入 `_ORDER_ELIGIBLE_RES`；`tick_team_orders` 賣盤段對 food 走新 `_tick_food_granary_sell`（讀自家糧倉 food，> `cap×FOOD_SELL_RESERVE_RATIO(0.5)` → 發 food sell 單，賣超量一半）。**未碰** `post_order`/`settle_orders`/`best_arbitrage_order`（WS-2 領域）。
- `scripts/debug/headless_test.gd`：3 新測（`_test_food_granary_cap`/`_test_consume_from_granary`/`_test_food_surplus_sell`，已註冊）；更新 4 個既有測反映新 food 行為（見下「一般稅坑 + 連動」）。

## 回歸閘結果

headless 全綠：
- `=== DONE ===` 出現、**0 SCRIPT ERROR、0 Assertion failed**（coin_eq 為 inline assert，無失敗 = 守恆成立）。
- 三新測：`food granary cap OK (糧倉=2000/cap=2000)`、`consume from granary OK (糧倉剩=476.0)`、`food surplus sell OK`。
- **既有飢荒/絕境測試全綠**（最大風險，已守住）：Famine Task1a–3c 全 OK、`Cadence Task2 OK`（食物消耗總量）、`Mount Task2 OK`、survival/desperation 系列無 SCRIPT ERROR。定居隊 food 移糧倉後不誤餓。
- `InvariantAudit population/faction雙向/subteam雙向 OK`。
- `order cadence/expire OK`（我動了賣盤段，未破既有 order 行為）。

## world_sim 煙霧（非閘，unseeded）

- 4 配置全跑無 SCRIPT ERROR。
- **food sell 單大量 fire**：單跑 227 筆 `[Order] TeamN sell food ×M`（例 Team1 ×499、Team6 ×487）。糧倉「滿」信號 → 賣決策 fire = 鐵則達標。
- **囤糧峰值崩（對照前次 4-5萬）**：food 不再進 team.resources uncapped；`[FoodLedger]` 各定居隊 `team food=0`（food 已全在糧倉，capped ≤18000）。幽靈囤已殺。
- **世界沒過餓（存活隊對照）**：warzone pop 135→103、tyrant 92→54、merchant 51→52；`[FoodLedger]` 所有定居隊 `days=0.0 income/day==burn/day` = 餵飽平衡，無飢荒崩。food 進糧倉未誤餓定居隊。
- `[CoinAudit] coin_eq init=1280 final=1280 delta=-0.00`（coin 守恆，未碰）。

## 一般稅坑（Task1 Step3）+ 既有測連動（待 systems 確認）

food 原走 else 入 `gained` → 課一般稅 split 入村庫；改進糧倉後 food **不再進 gained**（定居隊 food 進糧倉 = 等義「採集者即 owner→自存村庫」，不重複課）。此為**刻意行為變更**，連動 4 個既有測，我已更新（食物=sink 無守恆問題；**未放寬任何斷言**，只改 fixture/期望反映新行為）：

1. `_test_normal_tax_to_vault/_owner_vault/_vault_cap`（Fief Task1a/b/c）：原用 food 驗一般稅 split。food 已不走 split → 改用 `material`（仍 `NORMAL_TAX_RES`、仍走 gained，機制與舊 food 路徑完全相同，gain 數字相同 5.0）。**一般稅 split 機制本身未變，覆蓋率保留。**
2. `_test_storage_cap`（CoinStorage Task2）：原斷 food cap=200/1500/800（通用值）。改為 material 驗通用 cap + food 驗新 FOOD_STORAGE_CAP（2000/18000/4500）。
3. `_test_collect_ore_to_storage`（CoinStorage Task3）：原斷「food 應進 team」。改斷「food 應進公庫（糧倉）、不進 team」。
4. `_test_spill_back_with_cap_overflow`（TradePublic Task1c）：原用 food 200 cap 驗 spill 溢出留 team。food cap 改 2000 → 數字改 1980 預存/2080 trade 後/溢 80 留 team。spill 機制未變。

→ **一般稅行為對 food 確實變了**（food 整批進村庫，不再 split private/public）。對 material/goods 一般稅 split 不變。請 systems 確認此 food 稅語意變更是否符合設計（spec WS-1 守恆段稱「food route=私↔公轉移」，實作上定居隊採集 food = 直接入自家村庫，無 private 中介）。

## 連動風險（systems 決定是否補修）

- `FoodLedger`/UI 讀 `team.resources["food"]`：定居隊 food 現在 0（在糧倉）→ 若 UI/告警用 team food 判斷定居隊存糧會誤判「沒糧」。本 plan 未要求改 UI；消耗合併池已正確不誤餓，但**面板顯示**可能需 systems 排後續（讀合併池）。
- food **買單側**未做（plan 標後續）：定居隊只發 sell，飢荒隊買 food 走 `shortage_buy` 未加 food（food 不在 step3 買單 gate）。WS-2 市集通 + 買側補上才完整成交鏈。
- 實際成交靠 WS-2 市集（本 WS 只證 sell 決策 fire，已驗）。

## 待主 session 確認

- food 一般稅語意變更（上「一般稅坑」第 4 段）——是否 ack。
- world_sim `[InvariantViolation] known_reputations 含死 Team`（單跑 4 筆）：**與 WS-1 無關**（diff 無 reputation 字樣，純死團 reputation 懸空引用，pre-existing）；headless 確定性 InvariantAudit 閘 OK。記此一筆供 systems 知悉，非本 WS 引入。
- 全 cap/門檻 TEST VALUE（FOOD_STORAGE_CAP / FOOD_SELL_RESERVE_RATIO=0.5），待平衡。WS-4 糧倉設施再拉 cap。

## 偏離 plan

- 無功能偏離。plan 列「既有稅測試不破」——實作確認 food 稅語意必變（plan 自己標的坑），故更新 4 個既有測 fixture/期望（非放寬斷言，機制覆蓋保留）。commit 分 3（Task1 拆 outpost/resource 兩 commit + Task3 order+tests 一 commit）。
