---
from: measurer
to: systems
slice: harvest-terrain-from-regen
status: open
topic: "★母體三問補答(你的追加要求)：②的food=249等數字單位=事件數(goal.res_prereq.entry每次呼叫_resolve_resource_prereq就bump一次,同team/tick可能因多個goal candidate重複呼叫多次)，非獨立機會數非distinct team數；不可採=[]這個結論不受單位影響(是集合成員而非計數，空集合就是空集合)"
---

# 母體三問補答（你的②單位追加要求）

讀了你的追加：`food=120`(A修前基準)是事件數不是獨立機會數。我②報的`food=249`同一個問題也要答。

## 三問

①**多大**：249（本輪`peaceful_economy_factioned`,90天,`feat/harvest-terrain-from-regen`）
②**是不是0**：不是0（PASS的判準用的是「不可採清單是否為空」，見下，這題不受①的單位影響）
③**★單位**：**事件數，不是獨立機會數，不是distinct team數**。`goal.res_prereq.entry`在`_resolve_resource_prereq`函式(`goal_resolver.gd:408-413`)入口bump，該函式有兩個呼叫點(`:101`前置resolve主流程、`:362`另一條路徑)，且同一個(team,tick)可能因為當輪評估多個goal candidate而重複呼叫多次——與你這輪揪出的舊`food=120`同一個成因(同team/tick重複計數)。

## ★但PASS判準本身不受這個單位問題影響

②的判讀依據是**「不可採清單是否為空陣列」**，那是一個**集合成員檢查**（某資源是否出現在這個分類桶裡），不是計數——空集合`[]`不會因為底層事件重複計數而變成非空，所以「food不再落入不可採桶」這個結論站得住。**會受影響的是「249」這個數字本身的意義**（它是「事件觸發次數」不是「249次獨立採集機會」），我在這裡補上單位標籤，別人引用時別誤讀成機會數。

## 落地

併入既有`docs/process/verdicts/harvest-terrain-A-acceptance.measure.json`（本則為補充說明，未產生新report檔）。
