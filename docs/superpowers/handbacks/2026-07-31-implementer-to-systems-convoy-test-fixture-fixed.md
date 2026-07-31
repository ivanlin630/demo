---
from: implementer
to: systems
status: consumed
topic: "[done·convoy test fixture 修·4/4 綠] feat/peaceful-economy-bed 5dba26d3。_mk_seller_state 補 AnonCohort 5 平民(pop=6≥CONVOY_MIN_PARENT_POP 4)過 perf 前閘。convoy_delivery_test 4/4 綠+headless 3=baseline(0-new)。純 test fixture 修(函式對,和平床 fulfilled 0→5 證)。persist_strength 未動(floor banked 待 blueprint 裁)。"
branch: feat/peaceful-economy-bed
commit: 5dba26d3
base: 613d763d (local main HEAD)
---

# done：convoy_delivery_test fixture 修（4/4 綠）

照修。你親查對：**test fixture bug 非函式 bug**。`_mk_seller_state` 沒設 population（TeamData.population=getter leader+named+anon，default leader-only=1）< `CONVOY_MIN_PARENT_POP(4)` → 我加的 perf 前閘（`_deliver_candidates:129`）擋 → cands=0 → FAIL。函式對（和平床 `order_fulfilled 0→5` 證，那裡隊有 pop）。

## 修
`_mk_seller_state` 加 `AnonCohort.add(team.anon_cohorts, "平民", "healthy", 5)` → pop=leader1+anon5=**6** ≥ 4 過閘。

## 驗
- `convoy_delivery_test` **4/4 綠**：cargo topup/excess 守恆 + **deliver_material candidate 生成**(surplus=400 過閘) + 無 surplus(material=2)不派空車。
- headless **3=baseline(0-new)**。
- ★**persist_strength.gd 未動**（CONSTRUCTION_ACTIVE_FLOOR floor 誤 banked、待 blueprint 裁 bank/revert，非本 fix 範圍）。

★教訓收：merge 前該跑該 slice unit test on merged result（我第一次 convoy commit 沒驗 merged-main unit → 你接住）。純 test fixture 修，convoy 函式/三驗收線不變。
