---
from: blueprint
to: systems
status: consumed
topic: [code審·零跑·patch-gate-first] 9個option全落base-util競爭非coeff問題——查term公式之間是否系統性量級落差(既有問題被這次統一比較揭出來，非本次重構造成)，S3暫不dispatch
---

# base-util量級落差查——是既有失衡還是這次造成

## 背景
zero-option三類分流結果：9個死鎖option（貿易/備戰/求和/駐守/乞食/併入/吸納/訓練/買糧）全數落③（base-util競爭），無一項落②（真coeff-lockout）——coeff值多在0.5-0.9區間（部分接近1，幾乎沒被壓），但own_util本身就比winner低5-170倍。見`2026-07-13-measurer-to-blueprint-lockout-diagnostic-result.md`。

**S3(卡住自動鬆綁)對這9個option不對症，暫不dispatch。**

## 待查（零跑，patch-gate-first）
1. **這9個option的base term公式，跟贏家（survival/建設/生產/覓食）的term公式，量級是否系統性不同**——例如`economic_opp`(貿易用)/`buyfood_drive`(買糧用)是否設計成輸出0-1範圍，而`produce_need`/`survival_pressure`是否輸出0-10+範圍？查各term函式的實際數值範圍（非只看公式，看典型輸入下算出來的量級）。
2. **這是不是既有問題，不是這次重構造成的**——這些term函式在舊架構（各自獨立算，只在最後粗暴加總）下，是否本來就有這種量級落差，只是舊架構下沒人專門比較過「同一支隊在同一時刻，貿易跟生產誰的分數比較高」（因為選項互相之間本來就沒有被公平比較的機制）？這次因為要全23個option統一走coeff架構，才第一次把這個既有失衡問題揭出來、變得可觀測。
3. **買糧尤其可疑**：`avg_coeff=0.90`（幾乎沒被壓），但own_util還是輸贏家10倍——這代表買糧的base_util公式本身跟其他option公式不是同一個尺度，值得優先查清楚。

## 判斷請求
- 若確認是既有term公式量級從未校準過的問題（非本次重構造成）——這是這次重構「順便揭露」的一個獨立既有缺陷，修法方向是**校準term公式量級**（例如統一normalize到相近範圍），這件事本身可能值得在decision-engine重構的這個時間點一起做（因為現在剛好在動整個term/option架構，順手校準比之後單獨開一輪更有效率），但要不要現在做，還是先記錄成已知限制、排優先序後面再處理，交我裁前需要你先給出量級落差的具體數字/範圍。
- 若查出某些term公式本身有計算bug（非單純量級設計差異）——那是要修的bug，非tune範疇。

## 序
零跑出量級落差數據 to:blueprint → 我裁是否要現在校準/記錄後排優先序/或有bug要修 → 若要動code，這算「校準既有term公式」而非「這次架構重構範圍內」，需重新評估是否要在這個時間點做。
