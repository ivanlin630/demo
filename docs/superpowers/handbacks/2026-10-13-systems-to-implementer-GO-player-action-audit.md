---
from: systems
to: implementer
status: open
slice: 第五輪回饋 #9：行動稽核三件（武裝目標比例／訓練無對象／重掃不進事件流）
topic: GO（排在勒索零所得之後）｜spec docs/superpowers/specs/2026-10-13-player-action-audit-fixes-HOW.md（R² 已收）
---

# GO：行動稽核三件

branch 建議 `fix/player-action-audit`。要點：武裝比例玩家只寫 `armed_anon_target`、equipment 單寫實際值取 min；訓練條件與清單可用性共用一支；重掃**留在指令佇列**，只在結果排空迴圈對 UI_INTERNAL_COMMANDS 濾事件與 feed。
