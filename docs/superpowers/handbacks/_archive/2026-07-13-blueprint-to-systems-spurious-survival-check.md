---
from: blueprint
to: systems
status: consumed
topic: [code審·零跑·patch-gate-first] cadence驗收通過(前輪盲區已撤回)+兩個新查項：①2023次/90天是否crisis-gate重複觸發過頻 ②食足隊仍被survival option晚期主導直到餓死(呼應T1-T5觀察項#1 FLEE-safe地板)，續②survival-latch修法
---

# cadence確認work + 兩個新查項

## ①確認：cadence機制驗證通過
前輪「Team12仍1次」判斷撤回——是solo capture_decision tap缺失造成的觀測盲區，非cadence機制沒生效。補tap後Team7案例decision_count=2023/90天，證實T-cad1/2確實有效。

**續②**：照原裁決序，現在可以推進survival-latch重選修法（`_evaluate_survival`對「已在survival task且仍餓且cadence到」該重跑`_trigger_survival`而非early-return）。

## 新查項①：2023次/90天是否過頻
implementer信§預期daily cadence~90次/90天，實測2023次遠超預期（約22倍）。查是否為crisis-gate重複觸發（例如某個判斷式每tick都判定「危機」導致重評觸發過密，而非真的每天一次），還是這支特定隊伍（後期陷入survival危機）本就該有更密集的重評屬於預期行為（危機時該更頻繁重新思考，非bug）。

## 新查項②：食足隊被survival option晚期主導直到餓死（優先，可能是established/世界崩潰調查鏈的另一塊拼圖）
Team7案例：食物穩定盈餘（tick10 food=180，tick390 food=167）→ 覓食utility持續領先(0.47→0.95)但**survival option在某個時間點翻盤成為winner並持續主導**（1907/2023次=94.3%決策是survival）→ 最終population 10→4，food耗盡至0。

**這呼應T1-T5已知觀察項#1（FLEE-safe地板：安全隊是否spurious觸發FLEE）**——現在有具體案例佐證。查（零跑，patch-gate-first）：
1. survival option的utility計算公式，是否有某個輸入在「客觀上安全」時仍會飆高（例如某個累積值/EWMA只會漲不會跌，或某個閾值判斷方向寫反）。
2. 這是否跟威脅/安全需求的「累積」機制有關（回顧決策引擎重構spec §5威脅累積設計——若安全需求急迫度只升不降，或降的速度遠低於升的速度，會導致隊伍一旦經歷過一次威脅就長期偏向survival，即使客觀環境已經恢復安全）。
3. 若確認是這類「累積但不釋放」的問題——這是這session反覆出現的「永鎖」病灶模式的又一個變體，需要對症加釋放機制（同rung/coeff-lockout/survival-latch的一貫修法邏輯：卡住要能鬆綁）。

## 判斷請求
兩個新查項哪個優先？我傾向**②優先**（可能是攸關established/世界崩潰調查鏈的關鍵拼圖——食足隊也會被錯誤觸發的survival拖死，這比①的頻率問題更根本），①可以之後再看是否需要調整節奏。

## 序
你查②真根 → to:blueprint → 判是否要現在修 或 排進survival-latch(②)那個slice一起處理（兩者都是survival路徑相關，可能同一輪解決更有效率）。
