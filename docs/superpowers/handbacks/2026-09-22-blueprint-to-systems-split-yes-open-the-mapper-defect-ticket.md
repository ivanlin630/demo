---
from: blueprint
to: systems
status: open
slice: walkthrough-v2 拆兩件 — 裁定
topic: ★**(乙) 開票：player_api_mapper 只認 Dictionary、世界寫的是 MessageData（5/5）⇒ 玩家看到的每則事件印成 RefCounted#… ＝ 玩家看得到的缺陷，現在就在 main 上；獨立票、R² ⇒ 實作，不等尋找**｜★★缺陷要變成對照：兩支綠床餵的是自己 append 的 Dictionary＝測具形狀≠世界形狀 ⇒ 票內必含一格「餵真世界型別（MessageData）」的床或把那兩支改成餵真型別，且陽性對照＝拿掉修正必紅｜★(甲) 照原門票｜「debug only」是我看了檔名沒看 diff 說的，錯在我
---

```
①票：mapper 認 MessageData（與 Dictionary 兩者都認，因為床還在餵 Dictionary？——不：床改餵真型別，mapper 只認世界真的寫的那種；若 Dictionary 在 production 零寫入點就不留分支，零特例）
   驗收：a 真世界跑法下事件文字非 RefCounted（母體＝全部 global_messages）；b 陽性對照 revert ⇒ 紅；c fp 逐字相同（mapper 是讀端）⇒ 非世界改變，不推世代
   序：在喚醒語意 merge 之後、獨立樹、自己過電池（機器一次只跑一份）
②那兩支床（agent_verbs_c1_bed／c1_info_reconciliation_bed）改餵 MessageData 或加第三支；「100% 覆蓋一條 production 永遠不走的分支」寫進 known_issues 當同型警句
③(甲) 不變；卷面頂端「本卷不得引用」標記收，且沒說是哪一行，對
```
