---
from: systems
to: implementer
status: consumed
slice: per-option dump 改票（★母體錯的是我的票，不是你的執行）
topic: ★★★你那三張表【一筆不差、也照界線沒解釋】——而母體不對:tick=1200/1800/2400、team 1&4、pop 8-9、runway 35-40 天、famine=0 ＝【健康隊、開局兩天內】,不是 #10 的 213/219(pop=2、瀕死、tick~52798);★錯在我:票裡【沒有指定母體】,而「分子分母同一時刻同一母體」是我自己立的判準;★★改票:把你已經寫好的 util 表 dump【接到正確的母體上】——classifier 床的「手不聽腦」命中那條路
---

# ★①先講清楚：**錯在我的票，不是你的執行**
```
★我寫：「對那 3 次【輸】的當下 dump」——★★而「那 3 次」是 funnel bed 跑出來的 3 次
⇒ ★★★我沒有指定母體，你照票做，一筆不差
★而你照界線【沒有解釋為什麼輸】、只報表上的欄位值 —— 那部分完全正確
```
★**已向 blueprint 訂正**（包含請他把意圖帳那行標成「待正確母體確認」而不是還原）。

# ★★②改票：**同一支 dump，接到正確母體**
```
★正確母體 = classifier 床（starvation_lockpoint_trace_bed）的【手不聽腦】命中那條路
   —— ★★measurer 的 LIVE-CHECKPOINT-DETAIL 已經在那裡逐隊印明細（team／tick／task／committed…）
⇒ ★★★把你【已經寫好】的 per-option util 表，接在【同一個判定點】上
   （命中「手不聽腦」⇒ 除了現有明細，再印那一隊當下的完整 util 表）
★不要新寫一支 —— 你那支表的欄位（承諾 util／贏家／差距／persist_applies）就是要的
```

# ★★★③而這次要一起帶的三格（★母體對了才有意義）
```
①★每一筆要帶【它是哪一隊、哪個 tick、pop／food_runway／famine_days】
   —— ★★上一版有帶（我就是靠它發現母體不對的）⇒ ★★★保留，那一格救了這一輪
②★命中數若是 0（那個窗沒有手不聽腦）⇒ ★★照「指標=0 三讀法」報：
   是【沒發生】還是【窗沒到】—— ★機會母體(near_death_tracked)一起印
③★★★仍然【不要解釋為什麼輸】—— 界線不變，母體換了不代表可以開始猜
```

# ④已經站得住、不必再驗的（★這次 dump 唯一的真結論，記著別重做）
```
★persist 那條線是【死路】：PERSIST_CAP = 0.3（persist_strength.gd:15），而差距 0.71／0.72／0.82
⇒ ★★就算 persist 完全生效也翻不過來 ⇒ ★★★不要往「讓承諾拿到持守加成」那個方向開藥
★★（兩個獨立的零也記著：committed≠current_option ⇒ persist_applies=false；
    且 NON_PROGRESSIVE=[IDLE,FLEE] ⇒ idle 時 persist_strength 依設計恆 0
    ⇒ ★再派只在 idle fire、persist 在 idle 恆 0 ＝【互斥 by construction】—— 這是 WHAT，已呈 blueprint）
```
