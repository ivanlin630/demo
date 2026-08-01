---
from: systems
to: implementer
status: consumed
topic: "[★convoy_delivery_test在merged main FAIL(1)·test fixture bug非函式bug·_mk_seller_state(convoy_delivery_test.gd:87)沒設team.population→default 0 < CONVOY_MIN_PARENT_POP(4,faction_ai:2916)→_deliver_candidates:129 perf前閘擋→cands=0→FAIL·函式對(和平床order_fulfilled 0→5證,那裡隊有pop)·修:_mk_seller_state加team.population=6(≥4過閘)·跑convoy_delivery_test確認4/4綠+headless 0-new+commit·★另:floor誤banked待blueprint裁別動persist_strength] convoy test fixture漏population→加team.population=6過CONVOY_MIN_PARENT_POP閘。跑test 4/4綠+commit。floor別動(待blueprint裁)。"
branch: feat/peaceful-economy-bed
---

# ★convoy_delivery_test 在 merged main FAIL — test fixture bug（非函式）

merged main 跑 `convoy_delivery_test.gd` → **1 FAIL**：`deliver_material candidate 未生成(cands=0)`。

## 根因（我親查，test fixture bug 非函式）
- `_mk_seller_state`（convoy_delivery_test.gd:87）建 seller team **沒設 `team.population`** → default 0。
- `_deliver_candidates`（goal_resolver:129）perf 前閘：`if team.population < FactionAISystem.CONVOY_MIN_PARENT_POP(4): return out`（子隊/太小隊不派 convoy）。
- 0 < 4 → 前閘擋 → cands=0 → FAIL。
- **★函式對**：和平床 `order_fulfilled 0→5`/`cargo_delivered=69` 證 convoy 真運作（那裡隊有 population）。**只是 unit test fixture 漏設 population**。

## 修（test fixture）
`_mk_seller_state` 加 `team.population = 6`（≥CONVOY_MIN_PARENT_POP 4 過閘；candidate-gen case 需真 pop）。★兩個 case 都確認（surplus=400 過閘生 candidate、surplus=2 仍無 candidate）。

## 驗 + 交付
- 跑 `convoy_delivery_test.gd` → **4/4 綠**。
- headless 0-new + constitution 74 + observability PASS。
- commit + handback `to:systems`。
- ★**別動 `persist_strength.gd`**（CONSTRUCTION_ACTIVE_FLOOR floor 誤 banked、待 blueprint 裁 bank/revert，非本 fix 範圍）。

★這是我 merge 太快沒驗 merged-main unit test 之過（教訓：merge 前跑該 slice unit test on merged result）。純 test fixture 修。卡住報 `to:systems`。
