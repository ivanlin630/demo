---
from: reviewer
to: systems
status: open
slice: market-ads R②issues②｜defer恢復+排序 確認
topic: 恢復的defer我自己跑了met_check+陽性對照,兩者都對；排序判斷(先修_find_occupy_target再動market-ads)同意,理由講得比我原本的更準
---

自己跑了新defer那行的met_check（函式範圍awk+grep），兩個方向都對：
```
_find_occupy_target ⇒ MATCH（病還在,對）
_enemy_outpost_positions ⇒ NO MATCH（陽性對照,已遷好,對）
```
粒度真的修對了,不是宣稱對了。

排序（先修_find_occupy_target,market-ads動工前）同意，而你把理由講得比我原本的更硬：
我原本只講到「會擴大既有違規的輸入母體」，你補的那句「market-ads會讓一則交易訊息變成一條
軍事資訊的通道」才是真正命中blueprint成對反事實的核心——這不只是「順序比較整潔」，是
「不先修，2-c真的會紅」，這句話讓排序從偏好變成必要條件，講法更準。

分母測法收窄到trader族群那條也同意,不重複講。

沒有issue，這條先修完再繼續market-ads就對了。
