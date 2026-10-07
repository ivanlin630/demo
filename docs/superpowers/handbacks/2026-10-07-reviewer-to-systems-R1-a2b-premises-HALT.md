---
from: reviewer
to: systems
status: consumed
slice: R① A2b 前提核對（任何 option 派出的貿易到場零成交都要學到）
topic: R① ＝ **premise_contradiction=true,建議halt重估②的範圍**｜(a)確認為真：decision_engine.gd:371當下只有opt字串+ctx,沒有候選target,②要改的不只一層；(b)「unmapped母體=這31筆」不成立,那支probe對任何未接線option全開,母體遠比這31筆大,是統計上不可從讀code驗證的claim；★(c)找到真的premise缺口：「買糧」與「囤貨」(31筆裡的1+3=4筆)★不經goal_resolver★,它們的target是在to_task(dispatch那一刻)才算出來,不是像goal_resolver那樣在候選生成階段就有——②現在的設計(候選路徑在goal_resolver產出、decision_engine.gd:371改傳候選target)結構上接不到這兩個option,若照現在的形狀鎖HOW,31筆裡會有4筆繼續學不到
---

# 0 審了哪棵樹

`origin/main`最新（你信裡cite的spec檔）；核對對象＝decision_engine.gd:300-375、
failure_memory.gd:189-204、options.gd(13-35「貿易」/35-57「領取」/477-493「買糧」/
497-514「買料」/534-556「囤貨」)。

# 1 (a)——確認為真，②要改幾層這個問題比表面看起來大

```
decision_engine.gd:310 `for opt in _applicable:`——_applicable是純String陣列,
  迴圈裡沒有任何dict/候選結構帶著target
:371 `FailureMemory.mult_for_option(state,team,opt,ctx)`——opt是字串、ctx是
  跨所有option共用的DecisionContext,這一行當下【沒有】任何per-option的dispatch
  target可以傳——跟spec前提逐字相符,不是推論是讀到的事實
⇒ ②要補的不只是「多傳一個參數」,是要先決定target從哪個結構流進這個迴圈——
  下面(c)會指出,這個「哪裡有target」的答案,不是單一一種形狀
```

# 2 (b)——「母體就是這31筆」這句話不成立，是統計claim不是code事實

```
failure_memory.gd:196-199：`if not OPTION_FAIL_KEY.has(option): Probe.bump
  ("failure.unmapped."+option); return 1.0`——這支probe對【任何】不在
  OPTION_FAIL_KEY裡的option名都會bump,不分那個option是不是在跑貿易task、
  是不是到場零成交——它數的是「這個option完全沒有折價機制接線」,範圍是全部
  option,不是「到場零成交」這個子集合
⇒ 「母體是否就是這31筆的那幾種」這句話讀code讀不出來——unmapped計數器的母體
  結構上比31筆大很多(任何非貿易/領取的option只要被評估過一次就會bump一次,
  跟它有沒有真的派去貿易、有沒有真的到場零成交完全無關)
⇒ 這一題不是「對」或「錯」,是【統計分布的claim】,要真的跑一輪battery讀
  failure.unmapped.*的distinct keys才能回答,靠讀code沒辦法驗證,我不替它背書
  也不建議假設它為真或假去鎖HOW
```

# 3 ★(c)——找到真的premise缺口：買糧/囤貨不經goal_resolver,target在dispatch才算

## 確認：買糧、囤貨都有自己的to_task，各自算target，完全不碰goal_resolver

```
options.gd:477-493「買糧」：
  "to_task": ... var mp=FactionAISystem.shared()._nearest_market_outpost(state,team)
             return {"task":TASK_TRADE,"target":mp}
options.gd:534-556「囤貨」(:548附近)：
  "to_task": ... hub=FactionAISystem.shared()._merchant_trade_target(state,team)
             return {"task":TASK_TRADE,"target":hub}
⇒ 兩者的target都是在★to_task★裡用各自的helper函式算出來的,完全沒有呼叫
  goal_resolver的任何函式——跟前提段cite的「goal_resolver.gd:971/981/1086資源目標
  的手段候選」是兩條完全不同的程式碼路徑
options.gd:497-514「買料」：同樣是自己的to_task呼_nearest_market_outpost_with,
  也不經goal_resolver(這個option今天沒出現在31筆裡,但結構上跟買糧/囤貨同類)
```

## 這不是次要的邊角案例——C2′ 測到的31筆裡，買糧(1)+囤貨(3)＝4筆正是這個形狀

```
票源那段逐字列的六類：maintain_tools:resource 11、maintain_food:resource 8、
  build_workshop:resource 4、囤貨3、混合4、買糧1
⇒ 前三類(maintain_*/build_workshop)名字的形狀(動態、帶冒號分類)match goal_resolver
  產生候選的命名慣例,合理假設它們走goal_resolver那條路(前提段對這些是對的)
⇒ 但【囤貨】【買糧】是這個表裡逐字出現的選項名,而我核過它們是options.gd裡【具名
  的、固定的】option entry,各自有自己的to_task——不是goal_resolver的動態輸出
⇒ 31筆裡有4筆(囤貨3+買糧1)的target計算時機跟goal_resolver那條路【完全不同】：
  goal_resolver的候選在【評估/排序階段】就有target可讀(所以②能設想「候選路徑在
  decision_engine.gd:371改傳候選target」)；而買糧/囤貨的target要等到【to_task被呼叫
  的那一刻】(也就是這個option已經贏了、要被派發時)才算得出來——在:371那個時間點,
  這兩個option【結構上沒有target可傳】,不是「還沒接線」，是「這個階段這個資料
  還不存在」
```

## 為什麼這值得halt重估，不是小修一行

```
②現在的形狀(候選路徑在goal_resolver產出、decision_engine.gd:371改傳候選的target)
  描述的機制只覆蓋「評估階段就有target」的那一類(maintain_*/build_workshop等)
  ⇒ 若照這個形狀把HOW鎖下去,買糧跟囤貨(31筆裡的4筆,接近13%)會被這次修法漏掉——
  而這張票的標題明文寫著「任何option派出的貿易task...都要學到」,買糧/囤貨被排除
  在外直接跟票名矛盾
⇒ 要覆蓋買糧/囤貨,需要另一種機制：在評估階段【提前呼叫】這些option自己的to_task
  去「偷看」target(而不是等它贏了才知道)——這是否安全(to_task有沒有side effect、
  提前呼叫會不會跟正式dispatch時的呼叫重複算出不同結果)是一個新的、premise段完全
  沒有觸及的問題,需要在鎖HOW之前先想清楚,不是implementer動手時才發現
```

# 4 判決

```json
{ "verdict": "issues",
  "premise_contradiction": true,
  "issues": [
    {"claim": "候選路徑(goal_resolver產出、帶dispatch target的)在decision_engine.gd:371改傳候選的target",
     "file_line": "options.gd:477-493(買糧的to_task呼_nearest_market_outpost,不經goal_resolver)；options.gd:534-556(囤貨的to_task呼_merchant_trade_target,不經goal_resolver)",
     "truth": "買糧與囤貨(31筆測量裡的1+3=4筆)的target在to_task(dispatch那一刻)才算出,不是goal_resolver式的評估階段候選;②現在的形狀結構上接不到這兩個option,若照現在描述鎖HOW,這4筆會繼續學不到,直接跟票名『任何option』矛盾,需要在鎖之前補一個機制(例如評估階段提前呼叫to_task偷看target)並評估它的安全性"}
  ],
  "note": "(a)確認為真,②要改的層數比表面看起來多。(b)『母體是這31筆』是統計claim,讀code驗證不了,需要實跑battery讀failure.unmapped.*的distinct keys才能回答，不建議假設真假去鎖HOW。(c)是本輪最重的發現：買糧/囤貨這兩個具名option的target計算時機結構性地跟goal_resolver候選不同,②的現有形狀覆蓋不到它們,建議在鎖HOW前先把這個缺口的解法想清楚。" }
```
