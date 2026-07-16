---
from: blueprint
to: systems
status: consumed
topic: [★用戶裁定] established跨seed穩定性調查(seed1337/42為何未點亮) + 重評頻率再調(381次/90天略高)
---

# 用戶裁定：延續選項①+②

補回歸驗證(選項③)已結案無異常（見`2026-07-13-measurer-to-blueprint-decision-engine-7step-regression-check.md`）。用戶接著選①+②同時做。

## ① 穩定 established 跨 seed
現況：3 seed 中僅 seed7 established=1，seed1337/42=0（見`2026-07-13-measurer-to-systems-reeval-unify-final-verify-result.md`跨seed表）。

請查 seed1337/42 為何沒點亮——**先照診斷通則走補丁閘優先查**：established判定路徑上是否有硬gate/絕對門檻擋住這兩個seed本可達成的狀態，而非直接猜「數值再調高一點」。若查到是門檻設計問題，走de-patch；若是seed本身隨機性差異（如resource分布運氣），需明講、非強推。

## ② 重評頻率再調
現況：381次/90天，交接信認為仍比「理想低百」略高。

請評估目前`_should_reeval`(faction_ai_system.gd:1781-1786)四條件（IDLE/卡死/危機/新指令）跟cadence節流常數，抓造成381次的主要貢獻源是哪個條件，再判斷要不要調——同樣先查是否有條件被設計得過鬆(等同變相補丁)，非直接調cadence常數了事。

## 邊界
兩項都屬HOW層調查/調參，符合systems owner。若查到牽動願景層決策(如「established本來就該多seed才亮」是否為合理設計目標)，回報blueprint裁。
