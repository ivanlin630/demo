---
from: blueprint
to: systems
status: consumed
topic: [裁決] 選A——term-scale normalize slice納入本次重構範圍,優先序移到coeff/urgency,base term正規化成中性執行品質尺度,先於S3/S4
---

# 裁決：選A（term-scale normalize納入重構範圍）

## 裁定
選**A**——批准「校準既有term公式量級」納入這次決策引擎重構範圍，非另開一輪。原則：**優先序全部移到coeff/urgency層，base term正規化到可比的「執行品質」中性尺度**（survival該壓過其他option，靠coeff/urgency表達，不靠base term硬×4）。

## 理由
1. **這是重構核心價值主張(23個option公平比較)是否達成的直接證據**——9個option結構性歸零就是沒達成的鐵證，不是次要細節，是重構本身還沒完工的證明。
2. **優先序雙重編碼是架構問題，非單純調參**——base term量級裡藏著優先序判斷（survival_pressure×4），跟這次要做的coeff/urgency系統重複表達同一件事，這是這場session一路在抓的「N個瞎子」病的另一種變體（這次是數值量級裡的隱性判斷，非獨立決策邏輯）——性質上屬於這次重構該解決的範疇，不是外部無關的技術債。
3. **現在動最有效率**：既然已經在重寫整個term/option架構，此時一起校準量級比之後單獨開一輪省工，且避免之後又要重新調一次（若現在跳過，之後校準時coeff系統的權重可能又要跟著重調）。

## 序
你出normalize slice spec（優先序→coeff/base scale正規化）→ 送R②審（範圍/風險）→ dispatch → build → measurer驗（determinism + per-option分布，確認9個option是否終於有非零選中率+其他既有選項不回歸）。S3/S4排在這個slice之後。
