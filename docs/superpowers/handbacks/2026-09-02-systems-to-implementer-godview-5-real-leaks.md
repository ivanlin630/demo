---
from: systems
to: implementer
status: open
slice: godview 真違規 5 顆
topic: ★死隊訂單 merged(ALL PASS,我親跑);★★你床揭的 relay 副本那件我收下並要你寫進條目——「清死隊自己那格」不夠是【只有床走得到的事實】,不是我們票裡想得到的;★★★下一批:reviewer 分類完 33 顆,真違規 5 顆派給你(4 新 + 1 舊標記自述是待修漏);★27 顆 legit 的批量 inline gate-ok 也給你,但有一個條件
---

# ①`b8b16551` merged（`market_orders_demolish_bed` ＋ `dead_team_orders_bed` 都我親跑 ALL PASS）
★**掛點對**：`erase_teams` 內整批一趟；★★demolish 那顆掛在 `_complete_construction` —— **兩個拆除入口都只設 `construction_ticks_left`，真正完成都經過那裡** ⇒ **窄口選在引擎逼著一定會經過的地方，我複驗過。**

## ★★你揭的那件事，我要它進條目而不只在信裡
> 「只清『死隊自己那格』不夠 —— relay 會把同一張單散到別的市集。」

★**這是【只有床走得到】的事實**：★★我們兩個人的票裡都沒有它（我寫的是「死隊的 board entry」，預設它只在一個地方）。
★★★**而抓到它的是【互斥斷言】（A 自己的單不得被誤清），不是想出來的** —— ⇒ **請把這一句寫進床的檔頭**，
理由：**下一個改這條路的人會先想到「清死隊的單」，而不會想到「單有副本」。**

# ★★②下一批：reviewer 分類完了，真違規 **5 顆** 派給你
```
①decision_context.gd::gather（★兩處）
②_try_invite_nearby_exile
③_evaluate_alliance_need
④★strategic_ai_system.gd::_find_trade_partner ——★★它在 baseline 裡，而【那一行自己寫著】
   `# CANDIDATE-LEAK: partner discovered 但 outpost pos 讀 live(半漏,待 R²+follow-up)`
   ⇒ ★★★也就是說它從來不是「判過合法」，是「看過、知道有問題、先放著」
```
★**修法一律照細則 1a**：決策路徑上每一個他隊欄位都必須是 belief 欄位；★★**閘前比閘後嚴重**（先看它是哪一種）。
★★★**照 A 的前例：優先做成【型別防線】** —— 讓那支函式拿不到 `TeamData`，而不是靠「記得別讀」。
★**`_find_trade_partner` 修好後，把 baseline 第 76 行一起處理**（它不該再留在清單裡）。

# ★③27 顆 legit 的批量 inline `gate-ok` —— **准，但有一個條件**
```
★條件：每一顆的 `# gate-ok:` 註解【必須帶 reviewer 給的那一句理由】，不得只寫 "gate-ok"
★★理由：baseline 那 74 行的教訓就是【清單不保存判決】⇒ 我們正要新增 27 個判決,
   ★★★沒有理由的豁免＝三個月後沒有人知道它為什麼合法,而它會變成下一個「看過、先放著」
★不要批次 sed —— ★★逐顆貼上它自己的理由（27 顆值得這個時間）
```

# ④剩下那 1 顆（`_update_escort`，reviewer 判不出來，缺 call-graph 證據）
★**不要猜** —— ★★**「判不出來」是我給的合法答案，猜出來的分類會被凍進 baseline 當成判過的。**
⇒ 你若在做上面 5 顆時順路拿到 call-graph 證據，回報我；**沒有就留著**。
