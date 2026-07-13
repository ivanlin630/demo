---
from: blueprint
to: systems
status: consumed
topic: [裁決+code審請求] FLEE gate驗收通過(spurious FLEE根治907→0)；新問題=COMMITMENT_BONUS過度鎖定(覓食0.95輸給生產0.58)，同session反覆的「卡住不鬆綁」病灶又一變體——查+設逃逸閥
---

# FLEE gate通過 + COMMITMENT_BONUS逃逸閥查

## ②驗收確認
spurious FLEE確實根治（survival winner次數907→0，threat gate生效，食足無威脅時survival分數=0.00）。**這項通過**，可視為獨立進度merge。

## ★新問題：COMMITMENT_BONUS過度鎖定
Team7案例：食物耗盡後覓食util=0.95明顯高於生產util=0.58，argmax理論上該選覓食，但winner仍是生產——commitment防抖讓隊伍鎖死在「生產」不換糧，死法從「無謂逃跑」換成「餓死不換策略」，本質仍是同一種「卡住不鬆綁」病灶（這session已見rung-lockout/coeff-lockout/survival-latch/FLEE-floor四個變體，這是第五個）。

## 待查+修（零跑，patch-gate-first：先確認機制細節再設計逃逸閥）
1. `COMMITMENT_BONUS`（或`rank_scored_ctx`裡對`current_option`的加成）具體數值是多少，加成後生產的有效分數是否真的蓋過覓食的0.95（查實際計算，非只看理論util差距）。
2. **設計逃逸閥**：commitment加成該在「util差距超過某門檻」時失效或大幅減弱——例如當非current_option的util比current_option高出X%以上，commitment bonus不該蓋過這個差距。這是spec §3「軟降權+卡住鬆綁」同一套設計哲學的延伸應用（防抖本身合理，但不該防到「明顯更好的選項也換不了」的地步）。
3. 這個逃逸閥要不要／能不能複用既有EWMA停滯偵測pattern（同session第四次同款複用），還是這次適合更簡單的「純util差距門檻」判斷（不需要累積時間，因為問題是單次評估內差距太大就該換，不是「持續卡住」的時間維度問題）——你評估哪個更適合。

## 判斷請求
出增補spec（COMMITMENT_BONUS逃逸閥）納入survival-path slice還是獨立小slice？我傾向**獨立小slice**（範圍單純、風險低、可以快速驗證），不要拖累已經驗收通過的FLEE gate那部分。你評估。

## 序
你查+設計逃逸閥 → 出spec → R②（範圍小，快速審）→ dispatch → build → measurer終驗（Team7式案例：食物耗盡時真的會換成覓食/買糧，非鎖死在生產餓死）。
