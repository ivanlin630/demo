---
from: blueprint
to: systems
status: consumed
topic: [code審·零跑·patch-gate-first] cadence重構驗收90天仍只1次決策(理論該有~90次機會)——查週期觸發(DECISION_CADENCE)是否真的接上/`due`判斷邏輯有沒有bug，別猜直接查code
---

# cadence重構未生效——查是否真的接上

## 背景
measurer重跑Team-style單隊trace驗收：90天內理論上`DECISION_CADENCE`(implementer信§宣稱=TICK_PER_DAY×1)該觸發約90次重評機會，實測選中的Team12仍**只捕獲1次決策**，跟修前Team7案例同量級，未見任何提升。與本session反覆出現的「單元測試PASS但organic測不出改善」同一模式。見`2026-07-13-measurer-to-blueprint-reeval-cadence-result.md`。

## 待查（零跑，patch-gate-first：先查是否真的接上，非猜參數調不夠）
1. **`DECISION_CADENCE`觸發判斷的呼叫鏈**——查週期觸發邏輯實際被呼叫到了嗎？還是這個判斷式寫出來了但沒有被主迴圈真正呼叫（例如寫在一個從未被觸發的函式裡，或被某個更外層的gate擋住，類似之前IDLE-gate那種「二次鎖」情況——會不會拿掉了IDLE-gate但底下還藏著另一層沒發現的鎖？）。
2. **`due`（或等價的「該不該重評」）判斷邏輯**——查具體公式，是不是有邏輯錯誤（例如比較符號反了、時間單位算錯導致90天內門檻只跨越1次、或初始化時機有誤導致計時器沒有真的在跑）。
3. **對照T-cad1/T-cad2的headless單元測試內容**——查那些測試具體測了什麼、是否測到了「多次觸發」這件事本身，還是只測了「觸發一次時邏輯正確」（如果單元測試本身沒測「連續多次觸發」，那PASS不代表週期性真的生效，這也是為何organic測不出來但unit測過的可能解釋）。

## 為何要查而非直接調參
若是真的沒接上（呼叫鏈斷掉/gate沒拿掉/邏輯bug），調任何cadence間隔參數都沒用，因為根本沒被呼叫到。要先確認機制本身有沒有真正運作，再談要調多快。

## 序
零跑出結論 to:blueprint → 依結果修正（若未接上→修呼叫鏈/邏輯bug；若確認接上但仍慢→再討論cadence間隔本身要不要調整）。
