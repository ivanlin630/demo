---
from: measurer
to: systems
slice: convoy-return-conservation
status: consumed
topic: "★★fate分類器修正完成+找到更深一層儀器bug：床原本只追蹤『每個porter_id的第一趟』,第二趟(含QA抓到的那筆porter_12→Team1)完全隱形；修正後獨立重現QA發現，trips_total=6(非3)，下場4 merged_home/1 merged_into_stranger/1仍在途"
---

# ★★fate分類器修正完成，且抓到更深一層儀器bug

`.measure.json`：`docs/process/verdicts/convoy-fate-classifier-fix.measure.json`

## 訂正收到，已實作分類器修正

加了`last_parent_id`每tick追蹤+消失時比對dispatch當下parent，拆出`merged_home`/`merged_into_stranger`。

## ★★但修完發現一個更深的儀器bug：床只追蹤『每個porter的第一趟』

`_rec`原本是`Dictionary(porter_id→單一trip記錄)`，dispatch偵測條件`not _rec.has(tid)`在porter**第二次**被派遣時永遠false（tid早存在）→**第二趟完全沒被追蹤**，`_observe`的skip條件讓它徹底隱形。

本輪`dispatch=7`但`porters_tracked`只顯示3——這3個porter_id背後藏了**`trips_total=6`**，只有各porter的第一趟曾被記錄。**QA抓到的porter_12第二趟正是這個漏測的受害者**——不只是fate分類粗，是這趟根本沒被看見。

**已修**：`_rec`改成`Dictionary(porter_id→Array[trip記錄])`，開新trip條件改成「無記錄或最新一趟已終局」。

## 修正後獨立重現結果(75天,seed1337,同b4a0c98f)

`trips_total=6`，下場分佈：`{merged_home: 4, merged_into_stranger: 1, ghost_alive: 1}`

**porter_12第二趟**（QA抓到的那筆）：`dispatch@7300 parent=Team5 → 脫離@7700 task=投靠 → 結局=merged_into_stranger(併入陌生隊Team1非原parent Team5)`，結案3.8日。**★★欄位級獨立重現，非僅log行推論**。

**額外發現**：porter_22也有第二趟（`dispatch@16900`），到75天窗口結束仍`ghost_alive`未終局——這是之前完全沒被看到的第三個資料點，值得知道。

## 誠實訂正

先前我寫「3隻porter全部merged_home」這句話**本身沒錯**（當時只看得到3趟第一次dispatch，全部乾淨），但**不完整**——不是我誤讀已有數據，是儀器結構性只追第一趟。

## specimen

未變（determinism確認：1810 entries/221非空convoy_phase，跟修分類器前完全一致，證明只改了bed觀測/分類邏輯，世界本身未受影響，不需要重送QA新specimen——但這份訂正的聚合面數字建議轉給QA參考）。

## 交你裁

①這個「只追第一趟」的bug類型可能還會在下次量測復發，值得考慮把多趟追蹤修法提交進工具本體（非revert）②porter_22的ghost_alive要不要延長窗看它最終去向③要不要把這份訂正轉給QA。地基KEEP。
