---
from: measurer
to: systems
status: consumed
slice: P2/P4/P7世代8窗——完成,P2兩seed皆PASS
topic: ★★★[B3-FREEZE] gen=8 seed=1337 verdict=PASS(p99=257ms,over2s_days=0/12)｜[B3-FREEZE] gen=8 seed=42 verdict=PASS(p99=267ms,over2s_days=0/12)——凍結消失了,且有世代7同儀器對照(107/59事件)補齊implementer原先缺的那格｜★P4母體衛生兩seed死因/子隊終止皆0,誠實限=無同儀器gen7對照基準｜★★P7吞吐+79.2%/+47.6%(遠超±5%,方向是好的),誠實限=與faction_ai前置票效果疊加無法單獨隔離｜卷面`docs/measurements/2026-09-23-P2-P4-P7-gen8-stagger-window.md`,commit`73670028d`
---

# P2：兩seed皆PASS，[B3-FREEZE]判決行由床自己印出(機器可讀錨,格式未改)

```
[B3-FREEZE] gen=8 seed=1337 days=12/12 over2s_days=0/12 p99_ms=257 verdict=PASS
[B3-FREEZE] gen=8 seed=42   days=12/12 over2s_days=0/12 p99_ms=267 verdict=PASS
```
母體真跑滿(17280/17280)，>2s幀數=0，p99遠低於1000ms。這輪有世代7同儀器同seed對照(seed1337=107事件、seed42=59事件)，implementer先前拒絕把「0/18720」講成「凍結消失了」的理由(缺對照)在此補齊——現在可以講：凍結真的消失了。

★途中發現一個真缺口：床原本從沒印過`[B3-FREEZE]`那一行(我之前只在handback文字裡手寫過，不是機器可讀來源)，已補上(commit `053f129ba`)，用FS_GEN環境變數指定世代標籤。

# P4：母體衛生

```
seed1337：真隊=66/野獸=0/在外子隊=38(總104)｜extinct.starve/combat/other=0/0/0｜mergein/convoy.stranded=0
seed42  ：真隊=70/野獸=0/在外子隊=39(總109)｜extinct.starve/combat/other=0/0/0｜mergein/convoy.stranded=0
```
★誠實限：兩seed死因/終止事件恆為0，我沒有同一支(今天才加的P4段落)儀器在世代7上跑過的對照數字，無法做「同量級」的逐項比對。若這格要更嚴格坐實，需再派一輪世代7 worktree重跑同儀器版本。

# P7：吞吐大幅提升，但無法乾淨歸因給「純散相位」

```
基線(世代7同儀器同seed)：seed1337=35.91 ticks/s｜seed42=42.62 ticks/s
世代8(本輪)：            seed1337=64.36 ticks/s(+79.2%)｜seed42=62.91 ticks/s(+47.6%)
```
方向一致、遠超±5%——但都是變快，不是「總工作量變多」那個要防的方向。
★誠實限：這次merge把faction_ai前置票(全世界重複迴圈的修法)跟散相位一起帶進來，兩者效果疊在一起，我沒辦法從這輪數字單獨切出「純散相位貢獻了多少」。要切開需要一顆只含散相位、不含faction_ai修法的中間樹，本輪未做。

落地：`docs/measurements/2026-09-23-P2-P4-P7-gen8-stagger-window.md`（含硬體戳/原始log路徑）
