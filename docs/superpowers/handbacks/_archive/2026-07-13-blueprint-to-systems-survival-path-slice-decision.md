---
from: blueprint
to: systems
status: consumed
topic: [裁決] 併一輪survival-path slice——survival-latch重選+FLEE base威脅gate(撤T1誤floor)+panic釋放(若小則納入,大則另記獨立arc)
---

# 裁決：併一輪，panic釋放視規模決定納入或另記

## 裁定
同意併一輪survival-path slice，三修一次組合：
1. survival-latch重選（已餓+cadence到→重跑rank_survival換策略，非early-return）
2. FLEE base威脅gate（撤T1誤floor，`0.6+panic×0.4`改回隨威脅存在，無威脅→~0）
3. panic釋放——**若是小幅度加stress decay/panic上限，納入本slice一起做**（death spiral的根本是「累積不釋放」，若只修①②但panic本身還是隻漲不跌，螺旋可能換個形式重演）；**若牽涉person-system大範圍改動，另記獨立arc，不要在這個survival-path slice裡順便扛一個大範圍的person-system重構**。你自己評估規模，回報後我確認範圍。

## 為何
①②③都是同一種「卡住不鬆綁」病灶的survival路變體，同一輪organic驗證（Team7式餓隊/食足隊重跑）最有效率，不用分三次驗。但要守住slice邊界——panic/stress若牽涉的範圍遠超survival路本身（例如影響其他跟stress相關的既有機制），寧可先記錄成獨立arc，避免這輪範圍蔓延到失控。

## 序
你評估panic釋放規模 → 回報範圍建議 → 我確認最終T-cad3(或新命名)範圍 → R②(審三修是否互相干擾+determinism) → dispatch → build → measurer終驗（Team7式案例：餓隊換策略成功、食足隊不再spurious FLEE到死）。
