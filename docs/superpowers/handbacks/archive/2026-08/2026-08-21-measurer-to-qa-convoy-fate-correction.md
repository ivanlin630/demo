---
from: measurer
to: qa
slice: convoy-return-conservation
status: consumed
topic: "★★訂正：porter_12第二趟merged_into_stranger(併入Team1非原parent Team5)——欄位級獨立重現你抓到的log行發現，且找到更深儀器bug(床只追蹤每porter第一趟，第二趟原本完全隱形)"
---

# ★★訂正：你的merge log發現，我用欄位級數據獨立重現了

你交叉merge log抓到`Team1 ← Team12`（porter_12第二趟沒回母隊Team5，是瀕死投靠被無關Team1收留）——**這個發現是對的**，我先前specimen v2附的verdict裡「3隻porter全部乾淨merged_home」這句話**不完整**（不是誤讀已有數據，是儀器結構性只追蹤每個porter的第一趟，第二趟完全隱形不在我當時看得到的資料裡）。

## 修正後的欄位級獨立重現

修床(加多趟追蹤+fate分類器：比對消失前最後已知`parent_team_id`跟dispatch當下parent)後重跑同seed(1337)同75天窗：

**porter_12第二趟**：`dispatch@7300 parent=Team5 → 脫離@7700 task=投靠 phase=RETURN → 結局=merged_into_stranger(併入陌生隊Team1非原parent Team5)`，結案tick=8200（3.8日）。**欄位級數據，非log行推論，跟你的發現完全吻合**。

完整下場分佈（75天窗，6趟trip）：`{merged_home: 4, merged_into_stranger: 1, ghost_alive: 1}`（porter_22第二趟到75天窗結束仍未終局，正在延長窗到150天看它是否被T3絕對上限收掉，另外會補一封）。

## 落地

- `docs/measurements/convoy-return/convoy-t3budget-75d-v2.txt`（修正後75天報告）
- `docs/process/verdicts/convoy-fate-classifier-fix.measure.json`
- specimen determinism確認未變（1810 entries/221非空convoy_phase，跟修分類器前完全一致——只是量測工具變精確，世界本身未受影響）

## 交你裁

這份訂正供你更新故事稽核判讀（原本以為3隻porter都乾淨回家，實際是4乾淨+1投靠陌生隊+1仍在途）。地基KEEP。
