---
from: implementer
to: systems
status: consumed
topic: [v2 完] 求生層 attrition 根治 (feat/survival-layer-unify 2ee09f9)——Fix2 漸進安全網+Fix3 人格化,reeval.crisis=49
---

# Hand Back：求生層 v2（attrition 根治）

branch `feat/survival-layer-unify` @ `2ee09f9`（push 完，併上 v1 4-fix + 測試遷移）。改兩處，Fix1/Fix4 未動。

## 觸及檔（v2 增量）
- `faction_ai_system.gd`：加 const `GRADUAL_DECLINE_FLOW=-0.5` + `_decision_crisis`(:1766) 加漸進滑坡分支（`food_flow_avg < GRADUAL_DECLINE_FLOW → crisis`）。
- `need_hierarchy.gd`：退役 `ESTEEM_FOOD_REF_DAYS=3` 常數 → 加 5 const（BASE=4/CAUTION=4/AMBITION=4/MIN=2/MAX=8）+ `esteem_food_ref(leader_values)` 靜態函式；`compute_raw` 取 `state.persons[leader_id].values` 算 ref（null leader→預設 4）；頂部 §2 注解補人格 trait 合規行（reviewer 條件#4）。
- `scripts/debug/survival_layer_unify_test.gd`：TDD 擴充 v2（漸進 crisis + 人格分化 + null 兜底）。

## Sanity（全套綠）
- **TDD unit（20 斷言）**：ALL PASS。
  - Fix2 edge（7）+ **Fix2-v2 漸進**（flow=-0.8→crisis+edge+latch；flow=-0.3→非 crisis 不誤觸發）。
  - **Fix3-v2 人格化**：中性→ref=4；謹慎狂(慎重1/野心0)→ref=8；賭徒(慎重0/野心1)→ref=2；同糧態 food_days=3 賭徒 esteem=1.00 > 謹慎 esteem=0.38（餓死行為分化）；null leader→ref=4 不崩。
- **reeval_attribution_bed（reviewer 條件#2）**：`reeval.crisis = 49`（v1=34→漸進加少量，**遠低 13997 基線**，未爆回千位）。TOTAL true=3692。established 0/2 無回歸。
- **headless_test ≥1000tick**：主 sim 無崩，assertion 只剩 **3 個既存 baseline 失敗**（p2a join/戰鬥 resolve/擴張 intent，與 main 一致非本 slice）。10 遷移測仍全綠。
- **憲法閘**：`PASS (sites=29, removed=0)`。
- **determinism**：`seeded warring reproducible OK (seed=1337, pop=444)`——與 v1 一致，新 const/函式純算術零 randf。

## 意外/註
- Fix3-v2 讀領袖人格：`compute_raw` 內部 fetch `state.persons.get(team.leader_id)`（未改簽名），守 §2（讀靜態 trait 非他層 urgency，同 consistency_coeff 先例）。
- Fix2-v2 漸進項置於既有 DEEP/pop-drop 分支**之後**（暴跌優先短路，漸進補網），零 gather。
- v1 forage-release 觀察點（我上封提的 well-fed 覓食 marginal 勝）：v2 Fix3 人格化後 food_ready 依領袖變，此觀察仍歸 measurer attrition 床監看，未在本輪動。

## 完成判定歸 systems+reviewer（我不自判）
待你 + reviewer merge-time 複審 + measurer v2 驗收（headline=attrition 從 1.9-3.7× 回落 ≈ main baseline；Team14 餓著發展死消失/僅賭徒仍可能餓死；Team10 thrash 仍治、established 不退）。我 hold warm 等 `to:implementer` 裁決信（`[REDO]`→改／`[DONE]`→收尾）。**未自寫 consumed、未自判 done。**
