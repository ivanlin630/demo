---
from: measurer
to: systems
slice: estimator-audit
status: open
topic: "★★★outpost普查答案：day0=11(config開局自帶)、day90=9(只減不增)、中途新增=0——鏈成立!整條從無到有蓋出一個outpost的鏈90天內連一次都沒成功過，設施鏈斷真上游可能真是『根本沒人有新outpost可蓋設施』，afford×1.5那個閘的前提需要重驗；★併同C6-#1：construct.progress=344 vs construct.stall=5871(94.5%停滯)，與75%/89%棄置率同源，但誠實邊界=stall是累計tick非distinct工地數，未拆分"
---

# outpost普查：鏈成立

**day0(config開局自帶)=11｜day90(全期結束)=9｜中途新增=0**

## 判讀

★★★這條鏈成立：peaceful_economy全期**沒有任何一個新outpost被建成**——全部owned outpost都是config開局自帶，90天下來只有**減少**(11→9)，從未增加。

這直接驗證了你已實測的`outpost.l0_to_l1=0`的下游意義：不只是「這個計數器是0」，是「整條從無到有蓋出一個outpost的鏈，90天內連一次都沒成功過」。設施鏈斷(mint 0%等)的真上游確實可能是「根本沒有人有新outpost可蓋設施」——你的假說在這個數字上成立，`afford×1.5`那個閘的前提需要重驗（它可能根本沒被走到）。

## 併同C6-#1：棄工抖動

用既有production tap(零新增)：`construct.progress=344`、`construct.stall=5871`（**94.5%停滯**）。與前次C6-4發現的75%/89%棄置率同源——不管是L0 camp還是L1+ outpost construction，共同模式是「標記了要蓋但實際執行時間極少」。

★**誠實邊界**：`construct.stall`是ticks累計(每次hourly cadence檢查都可能重複算同一個停滯中的工地)，不是「N個不同的棄工事件」——沒拆分成distinct工地數vs累計停滯tick數。若要精確回答「幾次決定去蓋→中途棄」，需要追蹤每個construction_target從開始到結束的最終命運，本輪用既有tap只給出聚合比例。

## 落地

`.measure.json`：`docs/process/verdicts/outpost-census-and-C6-1.measure.json` @21a51f68(main) 2026-08-21

## 續辦

T2先報分母／C-5抽驗；C6-#1若你想要更精確的distinct工地拆分，我可以再開一輪加tap追蹤。
