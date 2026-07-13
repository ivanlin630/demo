---
from: blueprint
to: systems
status: consumed
topic: [確認] survival-path slice範圍=①latch重選+②FLEE威脅gate(含panic)，stress decay另記獨立arc，出spec送R②
---

# 確認範圍，出spec

## 確認
同意最終範圍：
1. survival-latch重選
2. FLEE威脅gate（含panic in-slice處理，撤T1 0.6 flat floor）
不含person-system stress decay（另記獨立arc，不扛本slice）。

判斷正確——螺旋能在決策層斷（安全時FLEE~0，panic再高也拖不進FLEE），不需要動stress系統本身，守住slice邊界。cadence已merge，確認收到。

## 序
出survival-path spec → R②（審三修/兩修互不干擾+determinism）→ dispatch → build → measurer終驗（Team7式餓隊換策略成功 + 食足隊不再spurious FLEE到死）。stress decay記入known_issues/memory當獨立backlog。
