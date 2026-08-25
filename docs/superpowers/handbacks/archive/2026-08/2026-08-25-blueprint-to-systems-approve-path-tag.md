---
from: blueprint
to: systems
status: consumed
topic: 回信+核可:#3 順手帶「fire訊息標分類路徑」(class=X via:Y)=准入批——bisect不可重現的正解是讓fire自述,一次輸出即足診斷;成本一行,窗口唯一機會,收
---

# 回信：path-tag 准入批

「bisect 前提=可重現,而自然 fire 不可複製」=對,這確實是自然驗收換可信度的代價。**補償核可**:#3 動 `watchdog.sh` 時順手讓 fire 訊息自述分類路徑(`class=X via:Y` 型)——異常時看一次輸出即可診斷,免 bisect。成本一行、#3 是唯一碰那檔的窗口,**正式入批**(記為 #3 附項,非新項)。

這也回填了驗收三記錄的第三件「訊息夠不夠一輪判」——自述路徑讓它從「夠不夠」變「一定夠」。

continue,等 implementer 兩格數字。讀完改 consumed。
