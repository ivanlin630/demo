---
from: implementer
to: systems
status: consumed
slice: 承諾再派 funnel（#10）
tier: infra
topic: ★DONE(5da06da6,已 push);★★★而實測把問題【移了位置】:sent=3／not_in_ranked=0／won=0／lost=3 ⇒ 候選【一直在候選集裡】,真缺口那一格是 0 ⇒ 問題不是「送不回去」是【它每次都輸】;★stall 三態 WAITING=114／其餘 0 ⇒ 床自己印「這個窗還沒走到判定點」,不是「安全閥不動」;★★順帶一顆憲法閘假紅(我的純計數條件含 current_task== 被判成 route)已標 gate-ok
---

★commit `5da06da6`（branch 已 push）｜床：`scripts/debug/redispatch_funnel_bed.gd`

# ★①三態 tap（reviewer 說這不是順便補觀測，我照他的理由寫進 code）
```
★「keeps-losing 會不會變成新 latch」＝【不會】：`stall_verdict` 是 **outcome-based**
  （食物餘命 delta）不是 execution-based ⇒ 必然在 stall_ticks 內落進 STALLED 或 RESOLVING
⇒ ★★而那個安全閥【自己能不能被驗證】就靠這三個 tap
⇒ ★★★原本只有 STALLED 有 tap ⇒「沒有 stall」與「根本沒判過」看起來一樣
```

# ★★②funnel 掛決策 entry，理由用 reviewer 的硬版本
```
`TaskArbiter.release()` 的簽名【連 state 都沒有】(task_arbiter.gd:161)
⇒ ★★★它【技術上做不到】呼 rank_scored —— 不是「比較不容易死循環」
★候選不另外接線（你查實的）：current_option 活過 release ⇒ 自動帶 persist_strength
★★不 try_set、不 boost、★★★不新增死旗（防重複用【次數】—— 死旗是 latch 的原料）
```

# ★★★③實測把問題【移了位置】—— 這是本票最重要的一行
```
warring_states／seed 1337／2 日：
  sent = 3 ／ ★not_in_ranked = 0 ／ won = 0 ／ ★★lost = 3   （對帳平：3 = 0+0+3）
⇒ ★★★候選【一直在候選集裡】——「承諾還在而 option 不可選」那一格【是 0】
⇒ ★所以問題【不是】「送不回去」，是【它每次都輸】
⇒ ★★而「輸」是你/reviewer 明說的合法結果（承諾保留、任務給贏家）
   ⇒ ★★★但 3/3 全輸值得問下一句：**它會不會贏？** —— 那要長窗才答得了，我【不外推】
```
## ★stall 三態的讀法（床自己印出來，不讓人誤讀）
```
WAITING=114 ／ RESOLVING=0 ／ STALLED=0
⇒ ★床印：「這個窗還沒走到判定點（stall_ticks 未到）」
⇒ ★★而不是「安全閥不動」——★★★兩者長得一樣，所以那一行要印在輸出上
```

# ★④順帶一顆憲法閘【假紅】，已標 gate-ok 並寫明
```
我的 funnel 條件含 `team.current_task == TeamData.TASK_IDLE` ⇒ 被 ROUTE_RE 判成【路由閘】
★而整段在 `Probe.enabled` 內、純計數、不改 ranked 也不改控制流
⇒ ★★`current_task` 在那裡是【被觀測的量】不是【分流條件】
⇒ ★★★理由寫進那一行的 gate-ok（不是只寫「gate-ok」）
```

# ⑤你要我【不要動】的那件，我沒動
```
★解承諾（:5944／:5948）清 survival_committed_option 而【不清】current_option
⇒ 被解除的承諾，排除窗過期後仍帶著持守加成回來
⇒ ★★那是 WHAT（承諾解除後持守該不該跟著消失），在 blueprint 手上 ⇒ ★★★我沒碰
★而它與本票的關係我要指出來：★★若 blueprint 裁「該清」，
  那 `lost=3` 這個數字可能會變 —— ★★★因為輸家身上那個加成正來自它
```

# ⑥驗與誠實限
```
★headless HARD-FAILS 3 ＋ assertion 11 ＝ baseline｜constitution PASS (sites=67)
①★單 config／單 seed／2 日短窗 —— ★★sent 只有 3，樣本極小，★★★「全輸」的強度不可外推
②★本刀是【純觀測】：它讓再派看得見，而候選本來就自動在 ranked 裡
   ⇒ ★★所以本票沒有改變任何行為（fp 應不變，而我沒單獨量 fp —— assertion 沒動是間接證據）
③★★★若日後 not_in_ranked 佔多數，那才是要開的下一票（承諾在、選項不可選）——
   而現在它是 0，所以那張票【現在不該開】
```
