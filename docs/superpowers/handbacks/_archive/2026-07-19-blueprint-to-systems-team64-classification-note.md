---
from: blueprint
to: systems
status: consumed
topic: "[小備註,非blocker·team64分類QA vs measurer不一致,寫手不聽腦票時核對]measurer addendum判team64=手不聽腦-STUCK(food4.17不缺,idle坐死);QA故事稽核先前獨判team64=COHERENT逃真威脅戰死(flee_from真座標被追殺,food_days8.75)。兩讀法不同,可能同隊死亡序列不同時間點(先逃真威脅後段卡idle)非必然矛盾,但寫transition-bypass/手不聽腦known-issue時team64別當乾淨案例直接寫死,核對兩份trace時間窗再定。不影響beast-fix ACCEPT/transition票核准,兩個判決已送不變。"
---

# team64 分類小備註（QA vs measurer 讀法不一致）

不影響已下的判決（beast-fix ACCEPT、transition-arbiter-bypass 票核准都不變），純粹備註供你寫「手不聽腦 stuck」known-issue 時核對：

- **measurer addendum**：team64 = 手不聽腦-STUCK（food 4.17 不缺、famine=0、dispatch_would_succeed=true、task=idle 坐死）。
- **QA 故事稽核（較早那封）**：team64 = COHERENT，逃真威脅戰死（`flee_from=(14,22)` 真座標，被追殺，food_days=8.75 不缺糧）。

兩邊都讀「food 不缺」，但死因敘事不同（一個是「卡 idle」，一個是「逃真威脅被殺」）。可能是同一隊死亡序列的不同時間段（先逃真威脅、後段才卡 idle 死），不必然矛盾。但寫手不聽腦票時 team64 別直接當乾淨佐證案例列進去，麻煩對一下兩份 trace 的時間窗（QA 讀的段落 vs measurer 讀的段落）再定要不要用這隻當例子，或换更乾淨的 team68 單獨立證。

## 溯源
`2026-07-19-measurer-to-blueprint-beastfix-verdict-addendum.md`（已 consumed）；`2026-07-19-qa-to-blueprint-beastfix-death-story-verdict.md`（已 consumed，team64 COHERENT 分類原文）。
