---
from: systems
to: qa
status: consumed
topic: "[slice2-perception 故事稽核·seed-swap 模式(同 ladder)·verification-gate is_sim] measurer organic:seed1337 5→2 改善、seed4201 3→0 大幅改善(ladder 的 28% doom 被 slice2 治好回基線 2.62%)、★seed42 從健康 0→8/21.53% 惡化。measurer 判『非單純修好=問題 seed 搬家/RNG-cascade』(god-view fix 改決策輸入→belief≠live→世界岔→絕境 cluster 移 seed)。headless 獨立重驗 6/6 0 new。★你判(中性,我不預設):①god-view 移除有沒有達到目的?—讀 seed1337 team19 死隊 trace:invite 現用 belief 距離→team19 還跨圖 settle 嗎(這是 slice2 A3 主目的)?threat 現能 evade 嗎?②seed42 8 死故事:proper 窮死(階梯用盡,同 ladder seed4201)vs god-view fix 真 broke 什麼?③這是 intrinsic doom 搬家(同 ladder,total 跨 seed 相近)還是 slice2 引入新 attrition?寫 .qa.json。"
---

# slice2-perception 故事稽核（seed-swap 模式）

## 為何到你（verification-gate is_sim + seed-swap 需故事判）
slice2 有 organic sim 量測（is_sim）→ verification-gate 需 `.qa.json` PASS。且 seed-swap（seed42 惡化）需你讀 trace 判是「god-view 移除的預期世界分岔（doom 搬家）」還是「fix 真 broke」。

## measure（measurer，bb1e75ff baseline vs slice2）
- **seed1337**：starve 5→2（改善）。
- **seed4201**：starve **3→0**（大幅改善——**ladder 的 28% doom 被 slice2 治好，回近原始基線 2.62%**）。
- **★seed42**：從健康 control **0→8 starve、2.08%→21.53%**（惡化）。
- **measurer 判**：**非單純修好，是問題 seed 搬家/RNG-cascade**（god-view fix 改決策輸入 belief≠live 位 → 世界分岔 → 絕境 cluster 移 seed）。**同 desperation-ladder sweep 的 seed-swap 型**（blueprint 已裁 ladder 版=attrition 內在）。
- headless **獨立重驗** 6/6 0 new（python decode 雙格式，非信 implementer 自報）。

## ★你判（中性——我不預設答案，我本 arc 6 次 state/framing 錯，這次只給 raw + 問題）
1. **god-view 移除達到目的了嗎**（slice2 的**主目的**，非附帶 attrition）？
   - **A3 invite**：現用 belief 距離 → 讀 seed1337 team19（原跨圖 settle 餓死源）：**team19 還跨圖 settle 嗎**？belief 距離 gate 擋住了嗎？（這是 slice2 最直接可驗的成功指標）
   - **A1 threat**：threat 現能 evade 嗎（敵脫視→隊追 last-seen 非瞬鎖）？
   - **A2 absorb**：跨派系 absorb 現走 belief 了嗎？
2. **seed42 8 死故事**：proper 窮死（階梯用盡才死，同 ladder seed4201 那批）vs **god-view fix 真 broke 什麼**（belief-based 決策導致隊做錯事餓死）？讀 seed42 死隊 trace。
3. **intrinsic doom 搬家 vs 新 attrition**：這是「總 doom 跨 3 seed 相近、只是 cluster 移 seed」（同 ladder=intrinsic economy doom）還是「slice2 淨增 attrition」？（可看 3 seed total starve 前後。）

## 判準
- **god-view 移除成功 + seed42=proper 窮死/doom 搬家 → PASS**（slice2 達成 framework god-view 殲滅目的，attrition 是 economy 內在隨 fix 重分布=正是 blueprint 改序要先修 god-view 的理由）。
- **god-view 沒真移除 OR seed42=fix 真 broke → FAIL**（回 systems 我修）。

## 寫 .qa.json
`verdicts/slice2-perception.qa.json`：`{verdict, story_audit:{team19_cross_map_settle_gone, seed42_death_cause, doom_redistribution_vs_new}, note}`。

## 溯源
measurer slice2 organic（seed-swap）;verification-gate is_sim→QA;ladder seed-swap 先例(blueprint 裁 intrinsic);slice2 3 god-view fix 目的;[[feedback_qa_inversion]] 中性故事稽核。
