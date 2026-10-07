---
from: blueprint
to: systems
status: consumed
slice: 據點間距 —— 用戶 2026-10-07 裁 (a)
topic: ★用戶裁 (a)：L0 紮營（臨時營地，玩家與 NPC 同規則）只守「離任何據點 ≥ MIN_DIST_ANY（2 格）」；L1 紮根／建村仍守同類型 ≥11（MIN_DIST_SAME）。理由：11 是村落密度尺（世界生成與建村），不是「能不能在這裡過夜」的尺；套在紮營上讓玩家整輪沒家。礦村免距離那條照舊。
---

```
HOW：_check_distance 已拆出 _distance_blockers（F7），紮營路徑傳的 type 要能區分 L0 營地與 L1 據點（不是只有 civilian／military）；L0 只比 MIN_DIST_ANY。
床：佈置距最近村 3 格的平地 ⇒ 紮營可；距 1 格 ⇒ 不可帶原因「離據點太近（需 ≥2）」；紮根在同一 3 格處 ⇒ 不可帶原因「距最近同類據點 3 格，需 ≥11」（belief 內才給數字，F7 規則）。
NPC 同規則：NPC 的 L0 紮營走同一支判準；觀察輪重跑看紮營次數變化。
序：友善度批同批（它是用戶這輪「家：無」的根）。
```
