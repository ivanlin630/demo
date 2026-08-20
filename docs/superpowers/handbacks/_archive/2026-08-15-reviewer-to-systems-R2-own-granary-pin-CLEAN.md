---
from: reviewer
to: systems
status: consumed
topic: "[R②判決=CLEAN+1輕量必查項] own_granary null-caller pin投機-slice HOW審——①exhaustive caller claim親grep own_granary_tile全scripts/確認production(scripts/simulation/)7處call site(decision_context.gd:186/508、faction_ai_system.gd:3418、resource_system.gd:132/183/415/428)+def(:398)逐字對得上,親自追過一條plausible替代假說(specimen_tracer.gd:216經capture_options鏈是否可能是隱藏null-state來源,因為這是debug目錄但live simulation呼叫的觀測工具)——追到底發現capture_options(state:WorldState,...)跟_snapshot(state:WorldState,...)的state參數皆非optional/無default,state從rank_scored自己的必要參數一路傳下來、不會獨立引入新的null注入點,這個替代假說親驗不成立,誠實回報『查過沒找到』非略過;確認exhaustive claim準確,7處production caller都傳state變數零literal-null,靜態掃不到根因,需要T1 runtime trace定位這個判斷正確;②pin-root非盲guard設計sound,呼應這session已建立的症狀vs根因doctrine(feedback_symptom_vs_root),盲guard會遮掉effective_food靜默少算这個更隱蔽的問題,方向正確;★③(輕量必查項)T2若根修結果是改某caller的gating(非只是state threading參數補傳)=改『何時跑』=行為變,要求§3 gate item4『determinism seed1337三跑byte-identical』明確措辭成『新code(post-fix)自身三跑byte-identical』非『vs pre-fix baseline byte-identical』,避免gating類根修被誤判成『非byte-identical=退回』(那樣會卡死一個合法的行為修正);④T3 tap byte-identical claim(純記錄無RNG無mutation)結構上必然成立,呼應F0/feedback_observer_no_global_rng已驗證過的同款方法論;判決=CLEAN+1輕量必查項(③gate措辭澄清,防止合法根修被誤判)→hold dispatch到S1綠"
---

# R②判決：own_granary null-caller pin 投機-slice HOW — CLEAN + 1輕量必查項

## ①exhaustive caller claim——親自追一條替代假說到底，誠實回報沒找到

親 grep `own_granary_tile` 全 `scripts/` 確認 production（`scripts/simulation/`）**7 處** call site（`decision_context.gd:186/508`、`faction_ai_system.gd:3418`、`resource_system.gd:132/183/415/428`）+ def（`:398`）逐字對得上。

沒有照單全收，親自追了一條 plausible 替代假說：`specimen_tracer.gd:216`（雖在 `scripts/debug/` 但透過 `capture_options` 從 `rank_scored`**live simulation** 呼叫，非孤立單元測試）會不會是隱藏的 null-state 來源？追到底發現 `capture_options(state: WorldState, ...)` 跟 `_snapshot(state: WorldState, ...)` 的 `state` 參數皆**非 optional、無 default**——`state` 從 `rank_scored` 自己的必要參數一路傳下來，不會獨立引入新的 null 注入點。這個替代假說**親驗不成立**——誠實回報「查過沒找到」，不是略過不提。

確認 exhaustive claim 準確：7 處 production caller 都傳 `state` **變數**、零 literal-null，靜態掃不到根因，需要 T1 runtime trace 定位——這個判斷正確。

## ②pin-root 非盲 guard——sound

呼應這 session 已經建立的症狀 vs 根因 doctrine（`feedback_symptom_vs_root`）——盲 guard 會遮掉 `effective_food` 靜默少算這個更隱蔽的問題（崩潰至少可見，靜默少算不可見），方向正確。

## ★③（輕量必查項）T2 若根修涉及 gating 改動，gate 措辭需澄清

T2 明講可能的根修方式包含「該 caller 本不該在 null-state 期跑則修其 gating」——若結果真是改某 caller 的 gating（非只是補傳 state 參數），這是「改何時跑」=**行為變**，非純 mechanical fix。**要求** §3 gate item 4「determinism seed1337 三跑 byte-identical」明確措辭成「**新 code（post-fix）自身三跑 byte-identical**」，非「vs pre-fix baseline byte-identical」——避免 gating 類根修被誤判成「非 byte-identical=退回」（那樣會卡死一個合法的行為修正，跟 bug 本身的性質矛盾：修 bug 本來就該讓行為變得不同於帶 bug 的舊版）。這條不阻擋這輪 CLEAN，是要求 gate 描述精確化，避免 T2 結果出來時卡在文字歧義上。

## ④T3 tap byte-identical——結構上必然成立

純記錄 tap（無 RNG、無 state mutation）不可能破壞 determinism，呼應 F0/`feedback_observer_no_global_rng` 已驗證過的同款方法論，成立。

## 判決
**CLEAN + 1輕量必查項（③gate 措辭澄清，防止合法根修被文字歧義卡住）→ hold dispatch 到 S1 綠。**
