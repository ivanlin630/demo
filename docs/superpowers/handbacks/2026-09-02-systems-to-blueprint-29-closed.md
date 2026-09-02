---
from: systems
to: blueprint
status: consumed
slice: 族④ #29 收案
topic: ★#29 CLOSE:warring 30d 完整跑完(自然 DONE 非 timeout)、機會母體 275、SCRIPT ERROR 0、null-caller 床 ALL PASS(我親跑);★★而我收案前多做一件:複核【那 275 次機會走的是不是被修的那條鏈】——修的兩行在 _attempt_barter 內,而 trade.meet 正是該分支計數 ⇒ 對得上;★★★族④至此 CLOSE(#6 修完 + #29 驗完)
---

# ①#29 **CLOSE**
```
warring_states 30d ★完整跑完（自然 === DONE ===，非 timeout）
  機會母體 proxy trade.meet ＝ 275 ｜ barter_deal ＝ 88 ｜ ★SCRIPT ERROR ＝ 0
own_granary_null_caller_test.gd ＝ ALL PASS（★我親跑）
peaceful 腿 trade.meet ＝ 1 ⇒ ★★我裁【不算證據】（母體 1 ＝ 幾乎沒母體，不是「驗過了」）
```
★**條目原標題兩處都 stale**：「fix in branch」（★早在 2026-08-15 就 merge 了）、
「pending 12mo confirm」（★★而依統一後的判準⑨，crash-check **不需要 12mo**，只需母體非零）。

# ★★②我收案前多做的一件事
```
★問題：275 次機會，走的是【被修的那條鏈】嗎？——★★這正是我今天自己踩過的坑（dump 母體不對）
★複核：e8ad1cb8 改的兩行是 interaction_system.gd 裡 `TradeValuation.reserve(a, …)` 補傳 state，
   ★★而那兩行在 `_attempt_barter` 內；`trade.meet` 就是該分支的計數
⇒ ★★★對得上 —— 275 次走的就是被修的那條路，不是別條
```
★**若對不上，275 就跟 peaceful 的 1 一樣沒有意義** —— **母體大小與母體正確是兩件事。**

# ★★★③判準⑨的統一形式已落地（measurer 論證，我推廣）
> **真問題不是窗長，是【機會母體】**——「窗 ≥ 一週期」只是**週期型**取得非空母體的手段；
> ★**latch**（無週期）問「窗內有幾次進入 latch 的機會」；★★**crash-check**（當場現形）**只需母體非零**。
> ⇒ ★★★**任何型的「命中 0」都必須與機會母體同印**；**而母體＝1 是「幾乎沒母體」不是「驗過了」。**

# ④族④ CLOSE
**#6**（market_orders：真根是 owner 驅動的生命週期 ＋ `erase_teams` 不清死隊的單）**修完**、
**#29 驗完** ⇒ ★**族④ CLOSE**。
★★**誠實限照原文帶著**：`trade.meet` 是上界 proxy 非精確計數；**275 是抽樣不是窮舉，極低機率邊界 case 無法排除。**
