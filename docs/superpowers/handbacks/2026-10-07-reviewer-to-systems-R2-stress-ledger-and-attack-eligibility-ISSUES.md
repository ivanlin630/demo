---
from: reviewer
to: systems
status: consumed
slice: 續裁四件第二輪（④預警／⑤壓力帳本）＋攻擊資格小票
topic: R② ＝ **ISSUES,兩列**｜★⑤你優先打的：git grep全repo逐一核對,算出來是**12個**不是11個(10個動態調整+2個初始化賦值),列出逐行證據請你對一次是哪一個沒被算進去｜★④你優先打的：「過0.2底線但沒贏」今天**拿不到**——`_evaluate_person`只回傳贏家的字串,算出來的scores字典是函式內的區域變數,呼叫端(:82)看不到;要拿到的話必須把判斷寫進函式內部(return之前),不能在外面讀
---

# 0 審了哪棵樹

`origin/main` ＝ `7c389a982`。

# 1 ★你優先打的⑤——git grep逐一核對,得12個不是11個

## 全repo逐行列出的stress賦值(排除_test/_bed)

```
動態調整(10個)：
  coin_treasury.gd:40        p.stress = minf(p.stress + stress_pen, 1.0)
  faction_ai_system.gd:2824  officer.stress = clampf(stress, 0.0, PROMOTE_STRESS_CAP)
  interaction_system.gd:755  p.stress = minf(p.stress + stress_gain, 1.0)
  interaction_system.gd:1802 p.stress = maxf(p.stress - 0.05, 0.0)
  reaction_system.gd:127     leader.stress = clampf(leader.stress + stress_delta, 0.0, 1.0)
  reaction_system.gd:418     person.stress = maxf(person.stress - 0.3, 0.0)
  resource_system.gd:588     p.stress = minf(p.stress + p_stress, 1.0)
  resource_system.gd:609     person.stress = minf(person.stress + (0.5 - value) * 0.2, 1.0)
  resource_system.gd:611     person.stress = maxf(person.stress - 0.05, 0.0)
  task_arbiter.gd:253        leader.stress = minf(leader.stress + 0.05, 1.0)
初始化賦值(2個,不是delta,是建人時設初值)：
  game_setup.gd:790          p.stress = float(p_cfg.get("stress", 0.0))
  person_generator.gd:55     p.stress = 0.0
⇒ 查法：`grep -rn "\.stress\s*=[^=]"`掃全部scripts/simulation/*.gd,排除==/!=/<=/>=比較,
  排除_test/_bed；另外查過compound assignment(+=/-=)跟dict鍵寫法([\"stress\"]=),
  零額外命中——這12個已經是這個查法能找到的全部
```

## 跟「11」對不上，請核對是哪一個被排除

```
若11是「10動態+1初始化」：那剩下那個初始化(game_setup.gd:790或person_generator.gd:55)
  要明確點名要不要收進single-writer閘——建人時設初值概念上不是「調整」,但如果閘擋的是
  「任何不經StressBank的.stress=都算違規」,這兩個初始化賦值字面上也會被擋到,要先決定
  它們算不算「寫入點」(若算,兩個都要包進11+2=12清單；若都不算,10個動態才是母體,
  跟11還是差1個)
⇒ 不管哪種讀法,目前的12個跟你說的11對不上,麻煩對一次是哪一行沒被你的清單算進去,
  免得implementer照著11那份清單去改,漏掉第12個,留下一個繞過StressBank的直寫
```

# 2 ★你優先打的④——今天拿不到,原因精確指到那一行

## _evaluate_person只回傳贏家字串，算出來的分數字典沒有洩漏出去

```
reaction_system.gd:159 `func _evaluate_person(state,person,team) -> String:`
  內部算出`var scores: Dictionary = {...}`(含N1_flee自己的分數)、挑argmax、
  `return best`——★回傳型別是String,scores整份字典是函式內的區域變數,函式結束就消失
reaction_system.gd:82（唯一呼叫點）：`var reaction: String = _evaluate_person(state,person,team)`
  ⇒ 呼叫端拿到的只有贏家的名字,完全看不到N1_flee那一輪算出來的原始分數是多少、
  有沒有過0.2——這個資訊今天【結構上】傳不出_evaluate_person這支函式
```

## 處置：判斷要寫在函式內部,不能在外面讀(不是功能做不到,是今天的介面不夠)

```
可行方向(不代裁HOW)：在_evaluate_person的`return best`之前,用它自己手上的scores字典
  判斷`scores["N1_flee"]>0.2 and best!="N1_flee"`,滿足就在這裡直接emit預警事件
  (跟描述裡「讀同一次評估的分數,不另抄門檦,不在UI重算」的精神完全一致——只是要點明
  「這段邏輯要寫在哪裡」：在_evaluate_person函式體內,不是在它的呼叫端或UI層)
  不建議改_evaluate_person的回傳型別去外洩scores(牽動所有既有呼叫端的型別假設),
  在函式內部直接處理範圍最小
```

# 3 攻擊資格小票——輕量核過，沒有疑慮

```
is_combat_capable(unit,state)確認存在於encounter_system.gd:105,跟spec引用一致
spec自己要求「先查移動資格今天怎麼判(若也看傷勢)」——我grep沒找到既有的「移動資格判準」
  函式(搜can_move/move.*capable等零命中)，移動今天可能沒有看傷勢的既有判準可共用，
  implementer落地時這句自查可能會得到「沒有,是這張票順便新建」的答案，不是我能代查的
  移動指令細節，標出來讓你們注意這句自查別被跳過
```

# 4 判決

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim": "⑤壓力的每一次寫入,今天11個寫入點,先列全",
     "file_line": "coin_treasury.gd:40／faction_ai_system.gd:2824／interaction_system.gd:755,1802／reaction_system.gd:127,418／resource_system.gd:588,609,611／task_arbiter.gd:253(10個動態)＋game_setup.gd:790／person_generator.gd:55(2個初始化)",
     "truth": "全repo逐行核對得12個不是11個;請確認哪一個被排除在你的11之外,並明確決定兩個初始化賦值算不算single-writer閘要管的寫入點,免得implementer照11那份清單漏掉第12個"},
    {"claim": "④讀同一次評估的分數,不另抄門檦——N1_flee過0.2底線但沒贏argmax時發預警",
     "file_line": "reaction_system.gd:159-186(_evaluate_person回傳型別只有String)；:82(唯一呼叫點,拿不到scores)",
     "truth": "今天_evaluate_person的scores字典是函式內區域變數,呼叫端完全看不到,『過底線但沒贏』這個判斷在今天的介面下拿不到;要落地的話判斷邏輯要寫進_evaluate_person函式內部(return之前),不能在外面的呼叫端或UI層讀,不是功能做不到是要點明寫在哪裡"}
  ],
  "note": "⑤的12 vs 11需要你核對一次缺口在哪。④確認方向對、可行,只是要把『在哪裡寫』講清楚。攻擊資格小票輕量核過沒有疑慮，附一句自查提醒。" }
```
