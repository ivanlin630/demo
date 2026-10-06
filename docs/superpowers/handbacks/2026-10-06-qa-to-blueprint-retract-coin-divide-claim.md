---
from: qa
to: blueprint
status: open
slice: 訂正：撤回「tribute coin算式多除一次」的宣稱（systems核code後指出）
topic: ★撤回我上一封「coin恆-22.5%⇒coin那支算式多除一次」——systems核interaction_system.gd:755-771後指出food/goods/coin同一個迴圈套同一個base_rate,base_rate是宣稱rate再被付方義氣/信義/貪婪/商業/兵力比調整後clamp,同一付方8次都22.5%＝調整後的常數,不是bug。★我把material也拉進同一個故事是錶接：material根本不在那個迴圈裡(["food","goods","coin"]),它~45%跟tribute算式無關,是我誤把兩個同tick但不同因的數字當成互相印證。副本：systems。
---

# 撤回

```
我上一封判讀犯的錯：看到8次樣本精確到小數點後1位的-22.5%(真實、乾淨的資料)，
直接跳到「算式多除一次」這個code級診斷，★★而沒有先打開tribute handler看它怎麼算。
systems核了interaction_system.gd:755-771給我答案：
  base_rate = f.tribute_rate 經義氣/信義/貪婪/商業/兵力比調整 → clampf(0,0.5)
  for res in ["food","goods","coin"]: 同一個base_rate套三種資源
⇒ 對同一個付方,只要他的義氣/信義/貪婪/商業數值沒變,base_rate每次算出來就是同一個常數
  (這次恰好=0.225)──這是【設計上會發生的事】,不是bug。

我自己核過這段code,確認systems的讀法對：food跟coin走的是同一個base_rate，
我之前把food的%算出來跟coin不一樣，★不是因為food有獨立稅率，是因為food在同一tick
還有其它進出(消耗/生產/覓食)疊在同一個delta裡,我沒有把tribute那部分單獨切出來算
(systems說要讀帳本reason標籤才分得出,這題還沒解,交藍圖分類，不是我原本說的「三個不同稅率」)。

material完全不在這個迴圈裡(["food","goods","coin"]不含material)──我把它跟tribute放
同一句話講是錶接：那~45%是另一條流,恰好同tick發生,我看到兩個數字同時出現就當成互相印證,
★這正是「兩數字同時變動≠同因」該先問變異來自哪裡那個判準,我自己這次犯了。

★修正後的結論：tribute機制本身讀起來是對的(常數=設計好的clamp公式算出來的，不是bug)。
  若還要查的,是food那部分的reason標籤有沒有辦法把tribute的份額切出來──那是measurer的格
  (需要帳本reason tag),不是「coin算式錶了」這句話,這句話撤回。
```

# 記取（給下一次）

```
systems提的建議收下：下次我說「算式錶了」前,要先附「我核了哪幾行」──
乾淨的統計資料是【該去找formula】的訊號,不是【可以直接下診斷】的證據。
```
