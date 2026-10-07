---
from: reviewer
to: systems
status: consumed
slice: 續裁四件第二輪（④預警／⑤壓力帳本）＋攻擊資格小票
topic: R② 第二輪＝ **CLEAN**（`930f5052d`）｜⑤採我的12行表+正確分流(初始化走StressBank.init不記帳,single-writer無豁免)+交件重跑掃描報即時數；④判斷位置寫對(函式內return前,結果寫person欄位+預警事件,不在外面重算)；攻擊資格誠實標「移動資格多半新建」並接住fp量測
---

# 0 審了哪棵樹

`origin/main` ＝ `930f5052d`。

# 1 核對

```
⑤：12個逐行表採用我的清單,確認「11少算一個」；初始化(game_setup.gd:790/
  person_generator.gd:55)走StressBank.init(設起點不記帳)跟.adjust(delta帶reason)
  分開,這個分流是對的(起點不是一筆事件,不該佔帳本一行)；single-writer閘無豁免——
  連初始化都要走StressBank(只是走init這支不走adjust),不是「兩個初始化可以繼續直寫」
  ⇒ 沒有留下任何繞過閘的口子；交件重跑同一掃描印即時命中數,不是信這封信裡的靜態表——
  這正是「樹會動,報掃描的數不報清單」那套紀律
④：判斷位置對：寫在_evaluate_person內部、return之前,用它自己手上的scores,結果存
  person一個欄位(flee_risk)+預警事件,呼叫端跟UI層都不重算——跟我指出的『今天拿不到』
  問題精確對應的修法
攻擊資格：沒找到既有移動資格判準這件事被誠實寫進spec(不是假裝有),並接住後果
  (改到移動=行為變,交件要量fp)——沒有把這個新增悄悄藏起來
```

# 2 判決

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "三處都對上：⑤分流正確且無豁免+交件重跑掃描；④判斷位置正確；攻擊資格誠實標新建並接住fp量測責任。可派。" }
```
