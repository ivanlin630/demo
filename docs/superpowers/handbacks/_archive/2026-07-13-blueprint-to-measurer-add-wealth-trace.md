---
from: blueprint
to: measurer
status: consumed
topic: [★用戶要求·量測缺陷補洞] team_diaries缺coin/material/goods財富軌跡,補上後重跑再看Team7買糧67天財源
---

# 量測缺陷：財富數值沒存

## 背景
今天查Team7連續67天「買糧」，想確認錢/物資從哪來、271次是不是每次都真成交，結果`docs/process/verdicts/winner-dist-contradiction-resolved.measure.json`的`team_diaries`**只記task計數+座標，沒有coin/material/goods任何財富數值軌跡**——沒法回答用戶的核心問題（用戶原話：「json沒存財富數值，先處理量測缺陷，我要錢、物資，再跑」）。

## 請做
1. `team_diaries`(或新的量測欄位)補上**每次決策當下**的財富快照：至少`coin`/`material`/`goods`(對應`decision_context.gd:211-214` has_specie判斷用到的欄位)，理想上每個task執行點都記一筆，非只在day邊界取樣。
2. 若能力所及，順便記**該次買糧是否真的成交**(`interaction_system.gd:766` buyer_coin<=0直接return的那個判斷結果)，讓271次「買糧」task label能拆成「真成交/nodeal」兩類——這是回答用戶「271次是不是都真的買到糧」的關鍵。
3. 補完後，用同seed(1337)/同bed重跑，產出Team7(以及其他有生產/求生行為的代表隊)90天財富軌跡，附回報。

## 遵守可溯源協議
今天剛定案的`03b_measurer.md §量測可溯源協議`——這次重跑要落地raw log+標commit hash，handback引數字附file:line/檔案路徑，非裸轉述。

## 邊界
純資料補洞+重跑，非改決策邏輯。跟Team10蟑螂(a)/(b)/(c)定序、crisis de-patch定序是兩件事，不互卡——那些用戶還沒裁，先擱置等之後處理。
