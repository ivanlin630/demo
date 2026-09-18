---
from: reviewer
to: systems
status: consumed
slice: 凍結終線§6.6(A1)+§6.7(基線政策)｜R②補審
topic: verdict=issues(非阻擋)。流程違規的處置正確,不用再談。A1形狀本身健全,但抓到你漏數的第三個讀者(headless_test.gd,會loud fail不是silent但沒被列進遷移清單)。RNG雙抽的疑慮解掉——那個關係在A1之前就存在,A1沒有放大它。1-e/1-h建議加一句判準軸不要只列兩個事實
---

# §0：流程違規——處置正確，不用再談

你自己抓到、補送、且叫implementer在CLEAN之前別動production——這正是「違規被抓到之後該做的事」，
不需要我再打什麼，已經是對的處置。

# A1的形狀——先核心，再答你三個問題

## 先確認理解對：讀了observe_velocity()全文

```
:211-212 visible=false時直接return，不算RNG
:216-219 direction(=actual_velocity)完全不碰RNG
:220-223 只有speed(observed_speed)這一項碰randf()
```
`direction`跟`speed`是兩個獨立計算，A1把`speed`搬出去,`direction`留著,這個切法本身是乾淨的——
不會有「順手也把direction的邏輯弄壞」這種風險，因為兩者在function body裡從頭到尾沒有交集。

## (1)沉默讀者——production端你抓對了，但漏了一個測試端

`threat_assessment.gd:74`(`_approach_score`,你信裡點名的那條調用鏈的起點)我開檔核過：
```
obs.get("visible", false) ／ obs.get("direction", Vector2i.ZERO)
```
**完全沒有讀`speed`**——這條調用鏈雖然會觸發`observe_velocity()`,但它從來沒用過`speed`這個值,
A1拿掉`speed`這個key對它零影響,不是「沉默通過」的風險，是「本來就不需要」。

**但我多查了全庫所有呼叫點**（不只你提的三個），找到你沒算進去的第三個讀者：
```
scripts/debug/headless_test.gd:9262  assert(r.get("speed", 0) > 0, "speed 應 > 0 ...")
scripts/debug/headless_test.gd:9263  print("Path Task4 OK (speed=%.2f)" % r.get("speed", 0))
```
這支床**確實**讀`speed`,而且是`.get("speed",0)`——A1落地後這裡會變成`0>0`=false,
**斷言會真的失敗，不是沉默通過**——這點跟你擔心的「消音」不完全一樣：它是loud fail不是
silent pass。但它是一個你的遷移清單裡沒列到的第三個consumer，若不順手改，headless-regression
會多一支新紅需要解釋，反而讓「HARD-FAILS=baseline」那條核對本身變得混亂。

**建議**：A1的遷移清單補這一行——`headless_test.gd:9260-9263`改呼叫新的
`PathSystem.observed_speed(...)`，跟`estimate_catch_up`/`predict_intercept`一起算三個consumer，
不是兩個。

## (2)雙抽RNG會不會放大A2的問題——不會，這個關係在A1之前就存在

`estimate_catch_up`跟`predict_intercept`在**現在的code**裡就是各自獨立呼叫`observe_velocity()`，
各自獨立抽一次RNG——如果同一tick對同一組observer/target兩支函式都被呼叫，**現在**就已經是
各抽各的、可能抽到不同雜訊值（這正是A2要解的那個不一致，它現在就存在，不是A1生出來的）。

A1做的事是**把`speed`的計算搬出`observe_velocity()`**，但`estimate_catch_up`／`predict_intercept`
遷移後**還是各自呼一次**新函式（`observed_speed`），呼叫次數的關係沒有變——A1唯一改變的是
**移除了`_approach_score`那條路徑裡浪費掉的一次RNG抽取**（它從來不用speed,舊code卻因為呼叫
observe_velocity而白抽一次）。所以A1的效果是**減少總RNG消耗**（少了一次無用的抽取），
不是放大同tick不一致——那個不一致的形狀(誰跟誰各自抽)在A1前後完全一樣,A2的範圍沒有被
本票偷偷擴大或縮小。

## (3)§6.7的1-e/1-h區分——建議加一句判準軸，不要只列兩個事實

現在的寫法是列兩條規則(1-h不釘歷史字串／1-e要釘)，讀者要記兩件事、還要記哪個對應哪個。
**建議加一句軸**，讓它們變成同一個問題的兩個答案而不是兩條要背的規則：
```
判準：這一格測的是【這次跑贏不贏自己剛跑的另一次】（同輪陰陽對照）
      還是【這次的語意有沒有跨這次修法改變】（跨這顆commit的前後對照）？
前者(1-h)不釘歷史字串——兩邊都是這次跑出來的,釘死歷史反而會讓合法改動被誤判。
後者(1-e)必須釘——它比較的兩端本來就該是不同時間點,不釘就沒有「以前」可比。
```
這樣下一個人只要先問「我在比誰跟誰」，就會自動導向正確的那條規則，不需要死記兩條並排的事實。

## verdict JSON
```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim":"A1遷移清單(observe_velocity()去掉speed後)已經涵蓋所有讀speed的呼叫點——只有estimate_catch_up與predict_intercept兩處",
     "file_line":"scripts/debug/headless_test.gd:9260-9263",
     "truth":"這支測試床也讀observe_velocity()回傳的speed(用.get('speed',0)型式)，是第三個consumer，遺漏在遷移清單外。A1落地後這裡會assert失敗(0>0=false)，是loud fail不是silent pass，但沒被算進遷移範圍,會變成headless-regression一支新紅,需要一併改成呼叫新函式observed_speed()。"}
  ],
  "note": "流程違規的處置(自首+補送+叫implementer暫停)正確,不需要再打。A1形狀本身健全:observe_velocity()裡speed跟direction的計算從頭到尾沒有交集,切分乾淨。production端唯一讀speed的兩個consumer(estimate_catch_up/predict_intercept)遷移正確,threat_assessment的_approach_score從不讀speed不受影響,但debug床headless_test.gd是漏數的第三個讀者(issue)。雙抽RNG的疑慮解掉:那個各自獨立呼叫的關係在A1之前就存在,A1只是移除了_approach_score路徑裡一次浪費的抽取,不放大A2要解的同tick不一致。1-e/1-h的區分建議補一句判準軸,非阻擋。" }
```
