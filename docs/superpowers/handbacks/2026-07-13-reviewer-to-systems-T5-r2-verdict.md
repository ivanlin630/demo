---
from: reviewer
to: systems
status: consumed
topic: [R②verdict·T5] 層內base校+訓練eval-gate對齊 = CLEAN，applicable gate獨立確認阻擋over-select
---

# R② 審判 verdict — T5（層內base校 + 訓練eval-gate對齊）

## verdict: CLEAN

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "options.gd確認applicable gate（食物/威脅門檻）與eval公式完全分離、獨立存在——T5.1抬base只影響已進候選池的option品質分數，不繞過候選資格門檻。買糧/備戰spurious疑慮皆被此三層架構（gate/eval/coeff）解答。" }
```

## 逐項驗證（含file:line + 代入驗算）

1. **★優先序保全（最高風險，確認applicable gate獨立阻擋）**：
   - `options.gd:133-137` 確認 `買糧` applicable **獨立**要求 `ctx.food_days < DESPERATION_DAYS and has_food_market and has_specie`——與eval公式完全分離。不管T5.1把eval floor抬到`0.5+0.5×dist_disc`，不餓的隊（food_days≥DESPERATION_DAYS）根本不會進候選池，買糧option連被評分的機會都沒有。無spurious風險。
   - `options.gd:139-140` 確認 `備戰` applicable **獨立**要求 `ctx.threat_react >= ctx.threat_threshold`——同理，無威脅隊備戰不進候選池，不管eval公式怎麼改，無spurious風險。
   - 這正是你checklist#1提出的疑慮，答案是applicable gate確實足夠擋（gate=候選資格、eval=候選內品質、coeff=候選內優先權，三層分離架構，T5只動eval層，不繞過gate層）。

2. **人格梯度保（備戰）**：代入`慎·0.9+好·0.2`：謹慎隊(慎0.9,好0.2)=0.81+0.04=0.85；好戰隊(慎0.1,好0.9)=0.09+0.18=0.27。梯度確認保留，好戰隊仍低於謹慎隊，迎戰（好戰驅動）在好戰隊場景仍會贏備戰。符TDD斷言(>0.7 vs <0.4)。

3. **訓練eval-gate對齊**：drop rung限制後，FORCE+anon即可eval=0.5非零，但`訓練`affinity`[0,0.1,0,0.7,0.2]`重壓L_ESTEEM，而esteem raw urgency由`(cap-rung)/cap`計算——隊伍已達自己rung上限時ambition_gap=0→esteem urgency低→coeff(訓練)低，即使eval非零，util仍被coeff壓低。eval-gate（是否可能訓練）與coeff（是否該訓練）分工清楚，無over-train結構性風險。

4. **駐守vs生產野心臨界值（概算）**：代入`weight(ambition)=clampf(野心-0.2,0,1)×1.5`+`weight(settle)=義氣×0.5+慎重×0.5`，設同coeff近似消去，解得臨界野心值≈0.39——低於此駐守(0.9)贏，高於此生產（ambition_drive加成後）贏。0.39落在合理低-中野心區間，非明顯破防的臨界值，精確幅度留measurer校準。

5. **determinism/值域**：全clampf純算術，零randf，確認[0,1]。

CLEAN，dispatch implementer T5。
