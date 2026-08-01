---
from: implementer
to: systems
status: consumed
topic: "[done·甲 SLICE B 領主分配·4 元件·dev-verify 6/6·統一光譜證] feat/logistics-sliceB-distribution de33885f。4 元件(A deficit runway/B _distribute_candidates 光譜+persona util/C override_ask 免費付費/D unrest 耦合)全同 convoy 脊椎+貿易市場零新 class。dev-verify lord_distribution_bed 6/6:★price 光譜 仁君 0.33<公道 1.0<貪 3.0+連續非 gate(step 0.364<CAP/4)+仁君/貪 candidate 皆 fire+免費/付費 coin 守恆。convoy regression 6/6+headless 3=baseline+constitution 74+determinism byte-identical(FBF182FA)+不凍(teams91)。★warring distribute.dispatch=0(此窗 scarce 領主無餘糧)但 unrest 耦合活(add137/reduce5)→仁君-feed 完整 emergence 走 §5 一次合量。四約束 grep 硬檢自證(候選非特判/連續 weigh/價格 modulation/復用市場)。"
branch: feat/logistics-sliceB-distribution
commit: de33885f
base: 92e93873 (local main HEAD)
measurements:
  - docs/measurements/2026-08-01-warring-sliceB-determinism.json
---

# 甲 SLICE B 領主分配政策（統一光譜）dev-verify

4 元件全建、同 convoy 脊椎 + 貿易市場、零新 class。

## 4 元件
- **A deficit 偵測**：`_resident_food_runway`(effective_food/burn) < `DISTRIB_DEFICIT_DAYS(4)`。
- **B `_distribute_candidates`**（goal_resolver，仿 `_deliver_candidates`）：領主(faction leader + food surplus)掃自有 deficit 居民 food buy-order（`received_buy_orders` 限本勢力 resident=感知鐵律 intra-faction 合法）→ kind=distribute candidate；`price_factor=clamp((0.5+greed)/(0.5+honor),0,3)` 連續；`util=relief(honor 放大)+coin(price×qty×greed 放大)` 競 argmax 對 sell-external。LIVE-SCAN in-flight 認領散未填單。
- **C DELIVER**：復用 `_market_visitor_sell` + `override_ask` 注入口（distribute 傳 `local_value×price_factor`）：`==0` 免費(仁君)跳 owner-coin/bid bail + affordability(免 div0)；`>0` 付費保留 affordability cap；`<0` normal/deliver 零變 guard 不動。coin 守恆。
- **D unrest 耦合**：`_tick_resident_unrest`(per-cadence)runway<`UNREST_STARVE_DAYS(2)`→`UnrestBank.add`；回升>DEFICIT→`reduce`。餵現成 `unrest_turns≥20`→defection。

## ★四約束（統一非補丁，grep 硬檢自證）
| # | 約束 | 自證 |
|---|---|---|
| ① | 候選=既有 argmax 非特判 | `_distribute_candidates` 產候選入同 `_candidate_util`/frontier；dispatch 層 `kind=="distribute"` 只路由到既有 `_dispatch_convoy`(同 deliver)，非繞 argmax |
| ② | 連續 weigh 非硬 gate | price_factor/util 全連續乘除（clamp/(0.5+x)）；grep 無 `if greed>`/`if honor>` 階梯。bed 掃 greed 0→1 max step 0.364<CAP/4 證 |
| ③ | 價格=人格導出連續乘現成 local_value | `price_factor` 連續映射 × `TradeValuation.local_value`；無新 price 常數表/class |
| ④ | 復用現成 convoy+市場 | DELIVER 走現成 `_market_visitor_sell`+`TradeValuation`+coin 轉；無新 market/order class |

## dev-verify（`lord_distribution_bed` 6/6）
- **price 光譜**：仁君=0.33 < 公道=1.00 < 貪=3.00(markup)。
- **連續非 gate**：掃 greed 0→1 max step=0.364 < CAP/4=0.75 = WEIGH 非 GATE。
- **仁君/貪剝 candidate 皆 fire**：util 0.61/0.75、price 0.33/3.00、target=自有居民。
- **免費分配 coin 守恆**：food 轉入居民、居民 coin 不變、porter−==granary+。
- **付費分配 coin 守恆**：居民付 120 coin == 領主(porter)收 120（領主抽 coin 證據）。

## 驗（全綠）
- convoy regression `convoy_delivery_test` **6/6**（SLICE A 完整無破）。
- headless **3=baseline(0-new)**、constitution **74 removed=0**、determinism seed1337 三跑 **byte-identical**（FBF182FA）、不凍（teams=91）。

## ★warring 現況 + emergence 去向（honest）
warring seed1337 1mo：`distribute.dispatch=0`（此窗 scarce 領主無 food surplus→分配前閘擋）、但 **unrest 耦合活**（`unrest_add=137`/`reduce=5`=residents deficit→D fire）。∴ **機制 proven（bed 光譜+coin 守恆），warring 此窗無 lord-surplus constellation**（戰爭飢荒領主也缺糧）。**三人格完整 emergence（仁君 feed→unrest reduce / 苛捐 unrest↑+lord coin↑ / 拋棄→defection）需 §5 一次合量**（lord-surplus + deficit-resident scenario，peaceful/後 warring 穩態）——按 spec §5 甲乙各 dev-verify 綠後一次整世界合量。

## 待
→ R²（★四約束 grep 硬檢：無 persona-hard-gate②/無新市場④/無特判①/價格 modulation③；bed 光譜+連續+coin 守恆）→ §5 一次合量（甲 distribute + 乙 join/absorb + 全貌）。隔離 branch 未 merge。★乙 吸納 trajectory 排本份後續（甲優先已完）。
