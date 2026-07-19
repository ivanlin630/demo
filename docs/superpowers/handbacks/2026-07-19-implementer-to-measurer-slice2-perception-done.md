---
from: implementer
to: measurer
status: consumed
topic: "[slice2 感知鐵律一致 done·待 sim measure] A1 threat-move→belief_pos / A2 absorb→belief-gate(降級 pop_est proxy) / A3 invite 距離 gate 用 belief_pos。Part C path_system landmine 純註。TDD slice2_perception_test ALL PASS,gate 64 removed=0,headless base(bb1e75ff)-vs-mine 逐條 IDENTICAL(0 new)。branch feat/slice2-perception@8da63525 off local main bb1e75ff(②含,diff 對 local main=純 slice2)。measure:seed1337 team19 不再跨圖 settle + 跨派系 absorb 收斂 + threat 不再瞬追 live 位。★A2 降級 caveat:驗併入 known-target 仍 fire(保守可能降率,別完全不 fire)。is_sim=true+seed1337/42/4201→.qa.json。"
---

# slice2 感知鐵律一致 done（待 sim measure）

## 3 fix（皆 god-view→belief last-seen，感知鐵律強化）
- **A1 threat DEFEND/求和 move → belief_pos**：`decision_context threat_pos = BeliefSystem.belief_pos(...)`（非 live `_ot.tile_pos`）。threat_pos 無其他消費者（只 options:294/305）→ 全域改此源；鏡射攻擊 options:194。= 敵脫視追 last-seen 非瞬鎖真位。
- **A2 absorb yield → belief-gate（降級）**：禁 god-view 直讀 target `effective_food`/`population`。belief schema 無 food_est → `has_belief` gate（無→yield 0）；有→`population_est` proxy（`pop_est/YIELD_NORM + land`）。
- **A3 invite 距離 gate 用 belief_pos**：`_try_invite_nearby_exile` 加 `hex_dist(self, belief_pos(tid)) <= INVITE_RANGE(5 TEST)`；無 belief/過期→belief_pos(-1,-1)→擋。禁 live t.tile_pos（cosmetic）。
- **Part C**：path_system observe_velocity/estimate_catch_up/predict_intercept 頂加 god-view landmine 註（零 production caller，純註解無邏輯變）。

## 驗（我側）
- TDD `slice2_perception_test.gd` **ALL PASS**：
  - A1：threat_pos = belief(1,1) 非 live(3,0)
  - A2：無 belief → absorb_yield=0（不 god-view 直讀 effective_food）；有 belief → >0（pop_est proxy，仍 fire）
  - A3：遠 belief(25,0)>RANGE → 擋（未達 cooldown-write）；近 belief(2,0) → 處理達 diplomacy
- `constitution_gate` PASS（sites=64, removed=0）
- **headless base(bb1e75ff)-vs-mine `diff` IDENTICAL**（同 3 pre-existing，0 new）

## ★需你 sim measure（branch@8da63525）
- `is_sim=true` + **seed1337/42/4201** → `.qa.json`
- 驗點：
  - **seed1337 team19 不再跨圖 settle**（A3 主靶：belief 距離 gate 擋跨圖邀）
  - **跨派系 absorb 收斂**（A2：不再 god-view 遠吸；known-target 仍 fire）
  - **threat 不再瞬追 live 位**（A1：脫視追 last-seen）
  - **★A2 降級 caveat**：併入/absorb 在 known-target 情境**仍 fire**（保守可能降率=可接受，但確認沒完全不 fire→若歸零報我，proxy 需調）
  - 世界 sustain（無新塌）

## 溯源
dispatch `2026-07-18-systems-to-implementer-slice2-perception.md`；spec Part A/C；[[invariants]] 感知鐵律位置語義（belief last-seen）；既有 belief_pos(options:194)/best_estimate pattern。
