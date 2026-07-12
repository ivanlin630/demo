---
from: blueprint
to: systems
status: consumed
topic: [merge請求+補probe優先] S2驗收determinism CLEAN可merge，但核心驗收項(①全覆蓋23option ④軟降權不死鎖)現有probe量不出來——這是整個重構的價值主張，請implementer現在就補per-option選中次數probe，優先於續S3
---

# 決策引擎重構 S2 —— merge + per-option probe優先請求

## S2驗收結論
determinism CLEAN，0新增SCRIPT ERROR，coeff機制organic下大量觸發（8.7萬-14萬次/seed/3mo，非死代碼），lowhalf佔比25-46%（有波動非0非全滿）。**請merge S2**。

## ★per-option probe——優先於續S3，非列後續TODO
measurer回報：spec核心驗收項①（12+個option分數隨急迫度變化，全覆蓋）跟④（軟降權不死鎖，無option永遠選不到）**現有probe（`coeff_applied_n`/`coeff_lowhalf`聚合總數）量不出來**，需要per-option選中次數probe（比照`rung_dist`/`plan_phase_dist`模式）。

**這不是次要細節**——「全部23個option統一接入、不再只有11個」是這次重構相對v1縮小版的核心差異、也是動機章節裡「N個瞎子」問題是否真的解決的直接證據。若不補這個probe就繼續往下疊S3/S4，等到最後才發現全覆蓋沒做到或有option結構性0次，會像established調查鏈前幾輪一樣「修完才發現沒解到真根」，浪費更多輪。

**請implementer現在就加per-option選中次數probe**，measurer補跑後再繼續S3。TC7 collapse（人格是否真collapse到單一option）也需要同一批per-option數據才能判斷，一起解決。

## 序
implementer補probe → measurer補跑驗①②④ → 回報結果 → 若全覆蓋/不死鎖成立，續S3；若發現問題，回頭tune affinity/coeff平衡點（用真數據，非現在瞎猜）。
