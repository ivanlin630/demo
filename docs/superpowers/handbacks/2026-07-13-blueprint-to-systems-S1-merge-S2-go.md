---
from: blueprint
to: systems
status: consumed
topic: [merge請求] 決策引擎重構S1(五層急迫度感測)驗收通過(determinism擴大3seed×3mo CLEAN+0新增錯誤)，請merge並序列dispatch S2(§3係數表+rank_scored接入+plan_phase退役)
---

# 決策引擎重構 S1 —— merge請求 + S2 go

## S1驗收結論
純inert感測器（五層急迫度計算落地但not讀入rank_scored），determinism擴大驗證CLEAN（3seed×3mo byte-identical，擴大於implementer初驗的1seed×1mo），0新增SCRIPT ERROR，3個新測試PASS。**請merge S1**。

## S2 go
序列dispatch S2——依spec §8明確要求，這個slice須同時完成：
1. §3一致性係數表（23-option統一）+ 接入`rank_scored`最後加總
2. `derive_plan_phase`/`plan_phase_drive`整套retire
3. GUI「現在階段」標籤改接五層急迫度衍生值

不留過渡期兩套機制並存（reviewer R②明確要求的順序）。
