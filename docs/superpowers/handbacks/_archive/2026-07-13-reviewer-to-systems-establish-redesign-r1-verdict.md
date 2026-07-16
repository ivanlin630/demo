---
from: reviewer
to: systems
status: consumed
topic: [R①verdict] 立國redesign premise坐實+框外挑框過 = CLEAN
---

# R① factcheck+框外 verdict — 立國 redesign

## verdict: CLEAN

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "四項premise皆file:line精確坐實。框外量級試算(disposition_scores基準對比_establish_intent_score公式代入)支持'非0非爆滿'窗確實存在，非空想宣稱。層次接線(phase→intent非phase→option)跟既有建國(獨立隊)precedent一致。" }
```

## premise坐實（file:line）
1. **立國純機械非argmax**：`faction_ai_system.gd:974-979`四條件AND閘確認（B1 members≥2/B2統領/B3野心/B4readiness）；`:1378 if "立國" in f.goals: _declare_established(...)`確認（spec行號精確）；`_declare_established`實際在`:3358`（spec寫3350，差8行同函式區塊，不影響判斷）。**關鍵佐證**：`:1377`comment明寫「立國=結構性lifecycle gate（非戰術option，不入引擎）」——code自陳現況設計刻意排除argmax外，精確坐實。
2. **建國A門有argmax pattern**：`select_strategic_intent:870` + `:876 scores["建國"]=found_score`確認；`_select_intent(state,f):902` → `:927 return select_strategic_intent(...)`確認是faction版argmax入口，claim精確。
3. **ESTABLISH phase零偏置**：`decision_context.gd _phase_option_bias` match只列PHASE_SEEK_FOOD/GROW/GATHER三支，PHASE_ESTABLISH無顯式case落到`return {}`，確認零偏置。**附帶發現**：plan-layer implementer已依reviewer上輪verdict把「投靠/整併」改「併入」，並進一步移除「貿易」化解intent_fit雙偏置疑慮——比原verdict要求更完整，非本次審查對象但值得記錄。
4. **B2/B3/B4門檻值**：`faction_ai_system.gd:11-13`（ESTABLISH_COMMAND=0.4/AMBITION=0.7/READINESS=0.7）確認精確。

## 框外挑框（大框，量級試算）
**#6（關鍵：軟門雙面風險）**：代入既有`disposition_scores`(`ambition_ladder.gd:28-39`)量級基準——守成=flat 0.25；征服≈0.02~0.38（outlier至0.8）；致富≈0.245~0.455；防衛≈0.21~0.39；擴張≈0.405~0.495。`_establish_intent_score`代入：`統領`是skill非value——`person_generator.gd:67-70`生成公式leader base=`randf(0,0.3)+0.1`，早期統領約0.1~0.4遠低於value的0.35~0.65帶。base=amb*.4+cmd*.4≈0.18~0.42，乘`rdy_mod∈[0.5,1.0]`後≈0.09~0.42——**與其他intent同量級，非恆贏恆輸**。無bonus時偏低端（早期低統領+低戰備隊立國score輸多數對手=軟門生效，非人人立國）；高野心+統領累積(command-tenure)+爬到ESTABLISH phase三項加成疊加（上限≈0.75）可逼近征服outlier峰值（0.8），真能贏＝非沒人立國。**數字支持「非0非爆滿」的窗確實存在**，非純文字宣稱。

**#5（真統一框架）**：立國從獨立硬AND閘搬進`_intent_scores`延伸池，跟既有征服自身「weak_enemy/established」門檻折入軟秤同款pattern一致，非另立影子機制。

**#7（phase→intent層次）**：接線跟既有「建國」（獨立隊）的intent-goal層次完全一致，非新創先例，選A取捨正確。

## 結論
CLEAN，可續 R②（設計審）→ dispatch。
