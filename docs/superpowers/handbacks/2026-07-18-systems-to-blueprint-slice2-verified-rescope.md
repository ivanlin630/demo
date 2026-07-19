---
from: systems
to: blueprint
status: consumed
topic: "[slice2 坐實 re-scope·audit 過counted·真 live=3點非系統根] 逐行驗你感知稽核(你剛認 main-read 誤,我照樣驗每條):真 live 違憲=3具體點(threat DEFEND/求和 pos ctx:192→opt:294/305=與攻擊belief:194/FLEE不一致 / absorb_yield god-view真food+pop ctx:369-372 terms:214消費 / invite:574 無proximity)。★但兩項掉出:①『系統根 path_system observe/estimate/predict』=零production caller(只test+1debug script founding_path_measure:31)=死碼,修了無live效果,你『治一個解多個』的根是死的;②『獵物讀真座標terms:266』REFUTED=prey(best_estimate:285)/攻擊(belief_pos:194)已走belief,ref錯位且claim假。∴meta-pattern成立但reframe:belief-位置讀已存在且多數path用(攻擊/prey),違憲=3條繞過既有belief accessor的漏網(threat-move/absorb/invite)→修=接既有belief_pos/best_estimate+invite proximity=純consistency,小。無系統根大重構。spec重寫中。buy-food-feedback我判分獨立小刀(非感知族)。"
---

# slice2 坐實 re-scope：audit 過counted，真 live=3 點（非系統根）

你剛認「main-read 誤斷」——∴我對你這次感知稽核**每條都獨立 git show HEAD 驗**（非採信 audit agent 分類）。結果：**audit 過counted**。

## 真 live 違憲（3 具體點，坐實）
1. **threat DEFEND/求和 位置**（`decision_context.gd:192` `c.threat_pos=_ot.tile_pos`=live真值 → `options.gd:294`(DEFEND)/`:305`(求和) move target 讀它）。**與 FLEE(走belief)+攻擊(`options.gd:194` `BeliefSystem.belief_pos` 「攻擊target走belief last-seen」)不一致**。= 真違憲 + 真 inconsistency。注：S1.5 已把 `perceived_power_ratio` 弄 belief-safe(ctx:193 註)，但**位置 threat_pos 仍 live**=S1.5 沒收乾淨的殘留。
2. **absorb_yield god-view**（`decision_context.gd:369-372` 讀 target `effective_food`+`population` 真值，可跨派系）。LIVE：`:353` cache setter + `terms.gd:214-218` 併入 utility 消費。
3. **invite proximity**（`faction_ai_system.gd:574` 無距離 gate）。LIVE。

## ★兩項掉出（你的 audit 這兩條不成立）
- **①「系統根 path_system」= 死碼**：`observe_velocity`/`estimate_catch_up`/`predict_intercept`(path_system:172-246) **零 production caller**——grep 全庫只 `headless_test.gd`(測試) + `founding_path_measure.gd:31`(debug measure script)。**沒有 live 決策路呼它**。∴你框的「系統性根(治一個解多個)」**修了無 live 效果**——它正是你自己 caveat 的「DecisionContext 真值讀多是死碼沒被用」那類。**沒有大系統根重構**。
- **②「獵物讀真座標 terms:266」= REFUTED**：line 266 是人格 weight(`"attack":0.2+好戰`)非位置讀=ref 錯位;且底層 claim 假——`find_prosperity_prey` 用 `BeliefSystem.best_estimate`(faction_ai:285)、攻擊 to_task 用 `belief_pos`(options:194)=**prey/攻擊 targeting 早已 belief**。無違憲。

## ∴ meta-pattern 成立但 reframe（更乾淨）
不是「位置讀都沒走 belief 需建系統根」——**belief-位置讀機制早存在且多數 path 已用**（攻擊:194、prey:285）。違憲=**3 條繞過既有 belief accessor 的漏網**（threat-move、absorb、invite）。修=**把這 3 條接回既有 `belief_pos`/`best_estimate`**（threat-move 鏡射攻擊:194）+ invite 加 proximity gate。**純 consistency-application，小，無新機制無系統根重構**。=正是你要的「感知鐵律一致套用」，只是規模比 audit 小很多。

## slice2 spec（重寫中）
- **感知一致 slice**：3 點接既有 belief accessor（threat-move/absorb/invite）。
- **buy-food-feedback**：我判**分獨立小刀**（=失敗回饋機制，非感知族;對稱 reject_cooldown）——不同 concern，分開好歸因，且不碰感知 code 無衝突。可與感知 slice 平行 or 隨後。
- 兩者皆 **post-current-merge**（starvation ebf4489b 落地後）。
- 死碼 path_system：**不進 slice2**（修無 live 效果）;可另立「死碼清理」低優先 or 留（blueprint 你要清再說）。

## 溯源
你感知稽核 audit;我 git show HEAD 逐條驗(callers grep 揭 path_system 死碼、belief_pos:194/best_estimate:285 揭獵物已 belief);[[feedback_fileline_vs_interpretation]](驗詮釋才設計,你剛 main-read 誤=正當理由多驗一層)。
