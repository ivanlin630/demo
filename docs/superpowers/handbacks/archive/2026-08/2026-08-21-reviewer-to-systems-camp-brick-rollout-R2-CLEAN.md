---
from: reviewer
to: systems
slice: camp-access
status: consumed
topic: "[R②判決=折現磚world-layer裁定(camp-stay-brick-rollout)CLEAN、三顆承重點親驗全部撐住(①opt-term映射直接查表非猜對、②hold latch風險親算persist_strength._progress的fallback機制確認真會累積+camp無自然release=latch風險真實存在你的駁回正確、③假說已正確標記交measurer非當結論用不需我再驗)(`2026-08-21-reviewer-to-systems-camp-brick-rollout-R2-CLEAN.md`)]"
---

# R② 判決：折現磚 world-layer 裁定（`camp-stay-brick-rollout`）

**判決 = CLEAN**。你標的三顆承重點,我逐一親查——**全部撐住,沒有一顆垮**。這輪是確認你的自我懷疑是多慮,不是找到新問題。

## ①「survival_pressure=覓食估值」：直接查opt-term映射表證實，非你自己講的「用猜的」
親讀 `options.gd:51-53`「覓食」entry：`"terms": [["survival_pressure","survival_pressure"]]`——**直接從映射表讀到**,不是從comment推的。`terms.gd:107-113` `eval("survival_pressure",...)` 逐字確認公式=`clampf((2×SLACK_COMFORT_DAYS−food_days)/SLACK_COMFORT_DAYS,0,1)`——**只吃 `ctx.food_days` 一個輸入,零地力/零腳下tile品質讀取**。你「覓食估值位置盲」的診斷**坐實,非詮釋**。這條承重點沒有垮,反而比你自己估計的更硬（你原本擔心是從comment推的間接證據,親查後是table直查的一手證據）。

## ②「TASK_CAMP進hold list=永久latch」：親算persist_strength機制，你的駁回判斷正確
親讀 `establish_crude_camp`(faction_ai:4918+)comment確認**紮營瞬間完成、不設`construction_ticks_left`**——沒有任何「進度」可讀。親讀 `PersistStrength._progress`(persist_strength.gd:107-117)確認：**只有 `current_task==TASK_BUILD` 才讀真施工進度**,其餘任何task(若把TASK_CAMP加進hold list、它就會落在這個「其餘」分支)一律走 **`elapsed/COMMIT_HORIZON_DAYS` 這個純時間流逝的fallback proxy**——**persist_strength會隨紮營隊待著不動的時間單調爬升,跟這個camp到底有沒有在往哪裡進展完全無關**。

**你自己不確定的那件事（hold會不會自己因為task變更而解除)——答案是不會**：沒有任何自然機制在「camp效果不好、該考慮投靠了」這個情境下釋放task（不像CONVOY有抵達merge、不像BUILD有construction_ticks歸零)。**唯一的解套是survival/threat級別的搶班（≥PRIO_THREAT)**,但那要求真危機,不是「重新評估發現有更好選項」這種正常決策層級的重新考慮——一旦persist_strength爬過`PERSIST_HOLD_THRESHOLD`,團隊會被鎖在一個**沒有真實進度支撐的承諾態**,這正是latch的定義。**你原本駁回implementer選項(a)的判斷是對的,我這輪親算只是把「為什麼對」的機制坐實,沒有推翻它**。

## ③cap saturation假說：交measurer的處理方式正確，不需要我這輪驗
你自己已經標成假說、要求measurer用`discount.*` tap報saturation率才算數——這正是`fileline_vs_interpretation`鐵律的正確應用（有行號/有結構性理由≠坐實因果),不需要我這輪代勞驗證運行時數據（那本來就不是code-read能回答的東西)。這個處理方式本身沒有問題,不阻塞。

## 附帶：其餘可查項親驗
- `PROGRESSIVE_HOLD_TASKS`全repo唯一定義體=`task_arbiter.gd:22`——親確認,你「窮盡」的宣稱這次是對的（跟你們這幾輪反覆栽的「以為只有一處」不同,這次真的只有一處)。
- 沒有動cap/沒有動δ/沒有碰測試斷言——親讀spec§3「本刀不動cap」+§4「禁調參掩蓋」文字確認,紀律延續。

## 結論
**CLEAN → 可轉 implementer 動工**。三顆承重點親驗全部站得住,①比你想的更硬（一手證據非二手推論)、②你的latch駁回判斷正確且我補上了機制層級的坐實、③正確交給measurer非我這輪該驗。無premise_contradiction,不需要halt。

地基 KEEP。
