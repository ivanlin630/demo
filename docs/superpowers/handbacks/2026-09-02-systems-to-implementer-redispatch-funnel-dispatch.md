---
from: systems
to: implementer
status: consumed
slice: 承諾再派 funnel（#10 修法）
topic: ★R② 過(issues 小,皆已答);★★reviewer 問的「重派進 rank_scored 吃不吃得到 persist_strength」我查實了:【自動吃得到】——current_option 也活過 release(grep 命中 0),而 rank_scored 比的就是它 ⇒ 不用另外接線、沒有灰色地帶;★★★而查的過程撈到一件要你【不要動】的:解承諾之後 current_option 不清 ⇒ 被解除的承諾仍拿得到持守加成,那是 WHAT 已呈 blueprint
---

# ★①先做這一件：**讓護欄③可驗**（不是修法）
```
faction_ai_system.gd:5942-5949 _detect_survival_stall 三態：
   STALL_RESOLVING → ★零 tap（reviewer 與我各自查實）
   STALL_STALLED   → 有 Probe.bump("survival.stall_exclude")
   STALL_WAITING   → ★零 tap
⇒ 補齊三態 tap。★★reviewer 點出這【不是順便補觀測】：
   ★★★「keeps-losing 會不會變成新 latch」的答案是【不會】，因為 stall_verdict 是 outcome-based
      （food_days delta）非 execution-based ⇒ 必然在 stall_ticks 內落進 STALLED 或 RESOLVING
   ⇒ ★而那個安全閥【本身能不能被驗證】，就靠這三個 tap
```

# ★★②再派 funnel（掛決策 entry）
```
掛點：決策 entry（_decide_unified，:2782-2789，_detect_survival_stall 已在那裡）
★reviewer 給了比我更硬的理由：release() 的簽名【連 state 都沒有】(task_arbiter.gd:161)
   ⇒ ★★它結構上不可能呼 rank_scored/DecisionEngine —— 不是「比較不容易死循環」，是【技術上做不到】
   ⇒ ★我原本寫的理由較弱，以他的為準
做法：current_task == IDLE 且 survival_committed_option != "" ⇒ 把該 option 當【候選】送回 rank_scored
★★不是 try_set 它、不是給 boost（界線＝既有「util 必=真值禁 crank」同一把尺）
★★★它【輸掉】是合法結果：承諾保留、任務給贏家
```

## ★★★③reviewer 問的那件我查實了：**自動吃得到 `persist_strength`，不用接線**
```
decision_engine.gd:96   if opt == current_option: u += _persist
faction_ai_system.gd:2884  team.current_option = opt   # 註解「承諾追蹤實際派出」＝與蓋章同一條路
task_arbiter.gd:161-181    release() 【不清】current_option（grep 命中 0）
⇒ ★current_option 也活過 release ⇒ ★★重派的候選【自動】帶著持守加成
⇒ ★★★所以【不要另外接線】—— 接了才會踩進「這算不算強推」的灰色地帶
```

# ★④要你【不要動】的一件（已呈 blueprint，是 WHAT）
```
解承諾（:5944／:5948）清 survival_committed_option，★而【不清】current_option
⇒ 被明確解除承諾的 option，排除窗過期後【帶著持守加成回來】
★★這是「承諾被解除之後，持守加成該不該跟著消失」＝ WHAT，不是漏 ⇒ ★★★blueprint 未回前不要碰
```

# ⑤驗收（照 spec，重申兩條硬的）
```
①★漏斗每段有數：候選被送回幾次／贏幾次／輸幾次 —— ★★「輸」必須看得見，否則跟「沒送回」長得一樣
②★★★禁死旗：不得新增「已再派過」的布林旗；要防重複用【次數】不用【旗】
   —— 死旗是 latch 的原料，而我們正在修 latch
③三態 tap 齊全 ④fp 會變 ⇒ 差在哪要說得出來；命中的 213／219 修後應有可觀察變化
```
