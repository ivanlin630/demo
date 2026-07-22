---
from: systems
to: implementer
status: consumed
topic: "[dispatch·tools-demand+weaponsmith cost70·R² CLEAN(2 建議已納)·新 branch feat/tools-demand·decisive] spec=2026-07-23-tools-demand-registration.md。兩 build 閘一起解(blueprint 要一輪組合驗 weaponsmith 真建成)。3 修:①need_oracle._construction_facility_need material→{material,tools}(CONSTRUCTION_COST_RES 白名單,cost_r=upgrade_cost().get(res,0) 泛化)+★★兩層遞迴守衛[(a)output-guard: if res in _facility_output_res(facility): continue (b)re-entrancy: static _construction_visiting Dict,入口 if visiting[res] return 0,設/清]②order_system _ORDER_ELIGIBLE_RES+買單 proxy(:121)加 tools ③outpost_system:87 FACILITY_DEF.weaponsmith.cost.material 80→70(僅 weaponsmith,armorsmith 不動)。TDD 6 型(★③人為造 material↔tools 環 fixture→有界回 0 硬驗 re-entrancy;⑥upgrade_cost(weaponsmith,1).material==70)。gate PASS/headless 0new/determinism 2 跑 byte-identical(無 RNG)。★★measure(→measurer,§④b samples+specimen→QA,長跑新規則):tools 全域產量>0/mil tools 買單/workshop tools-recipe 勝率/★weaponsmith 建成數>0(終驗)/material-need before-after(reviewer②耦合)/回歸 goods+doom+無餓死。★感知鐵律:demand(tools) 沿用 _trade_demand 讀 team_known(親聞,非 global),確認 tools 未繞道。做完→to:measurer(→QA 判故事:mil 想建→發 tools 需求→workshop 產→買齊→weaponsmith 建成 coherent)。task=systems+reviewer(merge-gate R² 複confirm 遞迴守衛 impl)。"
branch: feat/tools-demand
---

# dispatch：tools-demand 註冊 + weaponsmith cost70（兩 build 閘一起解）

spec：`docs/superpowers/specs/2026-07-23-tools-demand-registration.md`。R² **CLEAN**（`2026-07-23-reviewer-to-systems-R2-tools-demand-verdict.md`）+ 2 建議**已納 spec**。blueprint 裁②（cost 80→70）+ 要一輪組合驗 **weaponsmith 真建成**。

## ★★ branch
- **新 branch `feat/tools-demand`**（off LOCAL main HEAD，非 origin——push 過的近況見 [[feedback_worktree_stale_base]]，先確認 base 是 local main 798ac6ab）。

## 3 修
### ① `need_oracle._construction_facility_need`：material-only → {material, tools} + 兩層遞迴守衛
- `CONSTRUCTION_COST_RES = ["material","tools"]`；line 29 `if res != "material"` → `if not (res in CONSTRUCTION_COST_RES)`；`cost_mat`→`cost_r = upgrade_cost(facility,cur+1).get(res,0)` 泛化。
- **(a) output-guard**：迴圈內 `if res in _facility_output_res(facility): continue`（`_facility_output_res` 讀 `FACILITY_DEFICIT_DEF`/`RECIPE_GROUPS` outputs；workshop→[goods,tools,arrows]）。
- **(b) ★re-entrancy guard**（reviewer 建議 1，終結遞迴 hazard class）：`static var _construction_visiting: Dictionary = {}`；入口 `if _construction_visiting.get(res,false): return 0.0`；`_construction_visiting[res]=true` → 算 → 出口 `_construction_visiting[res]=false`。**graph-independent 切任何 material↔tools 環**（output-guard 足夠性 graph-依賴，未來 material-producer+costs tools 會破，ore 擴展計畫會踩→re-entrancy 一勞永逸）。內部控制流免 tap、無 RNG、同步同隊 tree 內設清不跨 tick。
- cap（`CONSTRUCTION_MATERIAL_NEED_CAP=100`，可 rename `_COST_NEED_CAP`）沿用。

### ② `order_system`：tools 納可交易 + 買單 proxy
- `:6` `_ORDER_ELIGIBLE_RES` 加 `"tools"`。
- `:121` 買單 proxy list 加 `"tools"`。

### ③ weaponsmith cost 80→70
- `outpost_system.gd:87` `FACILITY_DEF.weaponsmith.cost.material` **80→70**（**僅 weaponsmith**；armorsmith:93 不動、OUTPOST_COST 陣列不動）。

## TDD（6 型）
①mil weaponsmith-desire≥MIN→need_keep(tools) 含 3 capped ②civ 無 tools-cost facility→need_keep(tools)=self_use(pop×0.5) 不變 ③**★遞迴守衛**：output-guard 不呼 _facility_deficit(workshop)；**人為 fixture 造 material↔tools 環（某 facility output material + costs tools）→ 有界回 0 不無限遞迴**（硬驗 re-entrancy，非靠當前圖）④material path qualify（見 measure）⑤order_system reserve(tools)>holding→發 tools 買單 ⑥`upgrade_cost("weaponsmith",1).material==70`（armorsmith 80）。

## 閘 + measure
- **gate** PASS（憲法 site-freeze）/ **headless** 0 new fail / **determinism** 2 跑 byte-identical（無 RNG）。
- **★★measure（→measurer，§④b samples + specimen dump → QA；長跑新規則）**：tools 全域產量>0（哪隊/workshop 產、tool 數樣本）/ mil tools 買單數 / workshop tools-recipe 選中次數(vs goods 勝率) / **★weaponsmith 建成數>0（終驗，兩閘皆開）** / afford 通過率(avail≥105) / **material-need before/after**（reviewer② workshop 耦合，通常 goods 主導 invisible）/ 回歸 goods+doom-delta+無餓死。
- **★感知鐵律**：`demand(tools)` 沿用 `_trade_demand`（need_oracle:142 讀 `state.team_known` 親聞買單，belief-gated）——確認 tools 未繞道全域 order book。

## 完成判定 = systems + reviewer（merge-gate R² 複 confirm 遞迴守衛 impl）。做完 → to:measurer（→QA 判故事：mil 想建 weaponsmith → 發 tools 需求 → workshop 產 tools → tools 進經濟 → mil 買齊 material≥105+tools → **weaponsmith 真建成** coherent；若仍 0 = 診斷未盡）。
