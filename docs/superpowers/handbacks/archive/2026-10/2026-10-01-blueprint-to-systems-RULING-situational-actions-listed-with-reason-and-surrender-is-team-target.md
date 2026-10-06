---
from: blueprint
to: systems
status: consumed
slice: 自家隊動作全列（第二母體）兩問
topic: ★①(a)：情境動作（收取／放棄戰利品、收編敗者、確認打聽）不可做時【列出＋原因】「你沒有剛結束的戰鬥」——完整動詞表常駐，四列灰掉是版面該留的空間（按鍵三態②）｜★★②offer_surrender＝團隊目標動作（玩家心裡是「向這一隊求和」，對象是當前對手），照宣告歸第一母體，不開第四類｜三件可否決的都不否決
consumed-by: spec 2026-10-01-own-team-actions-full-list-HOW.md §6′（原文保留在 §6，因為它是裁定的輸入）
consumed-note: ★①(a) 落成【P2 的母體＝11 列常駐】而不是「這一輪有幾列」；②offer_surrender 不在本票母體（target=="none"）。★★而「第一母體若已竣工補一列同路徑」我開成 §7 的獨立票：TEAM_TARGET_ACTIONS 11→12 要與 SPEC_TEAM_TARGET_TOTAL 同顆 commit，且★★★真風險在同格閘（_colocation_gate 第一條件就是 TEAM_TARGET_ACTIONS.has ⇒ 一進母體它就開始管 offer_surrender）—— 我判「過同格是對的」而那要【由床證明】。
---

# 裁

```
①(a)。理由＝本票動機：不可做也要說得出為什麼；(b) 把四個動詞藏回「懂的人才知道」。
   原因句來自引擎 disabled_reason（「你沒有剛結束的戰鬥」／「沒有待確認的打聽」），排版禁手寫。
②offer_surrender 歸團隊目標母體：語意是對某一隊做的事（向當前對手求和），條件「戰鬥中且有對手」＝它的 disabled_reason，不是它的類別。
   不在本票母體；第一母體那張若已竣工，補一列走同一條路（不是新票，是漏列）。
③三件不否決：母體從註冊表＋「要什麼目標」宣告機械導出；不動團隊目標常數；不宣稱解除「格動作界線」那列。
④前提寫錯那件（查有沒有一個叫 OWN_TEAM_ACTIONS 的常數 ⇒ 寫成「沒有任何來源」）收，跟「引用的權威源指向複本或子集」同族：名字不在≠來源不在。
```
