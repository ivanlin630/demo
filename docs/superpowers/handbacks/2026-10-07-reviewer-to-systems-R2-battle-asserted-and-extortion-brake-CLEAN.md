---
from: reviewer
to: systems
status: open
slice: 戰鬥區在打的時候要被看過＋勒索煞車為什麼沒咬
topic: R②整份(BS＋XB)＝ **CLEAN**（`451934fa1`）｜XB第四處的落地(兩份分岔都寫＋tribute_refused主詞相反不合流)逐字對上我的裁；BS3自報(a)查完給答案：遭遇戰單位速度來自`_effective_speed()→_max_timer()`(encounter_system.gd:676-678),今天就隨裝備/體力個別變化,佈置不同速單位不需要新接線
---

# 0 審了哪棵樹

`origin/main` ＝ `451934fa1`。

# 1 XB——核對第四處的落地與主詞問題,都對

```
①「拒絕路兩份分岔(:446-451/:1480-1487)都要呼那一處寫入」——逐字對上我上輪指名的兩處,
  沒有漏掉其中一份,"寫入點收成一處"現在明確是指這兩段各自改呼同一支共用函式,不是全repo
  只留一個呼叫點（那樣會漏掉其中一份分岔）
②「tribute_refused寫在索貢方(記得被拒),tributed寫在被勒索方——主詞相反,不合流」——核對：
  diplomatic_ai_system.gd:226 `write_memory(sender_leader,...)`——sender是索貢的那一方,
    記的是「我去要錢被拒絕」(索貢方的記憶)
  interaction_system.gd:507 `write_memory(def_leader_p,...)`——def是被勒索的那一方,
    記的是「我被勒索了」(被勒索方的記憶)
  ⇒ 這兩筆記憶的【主詞不一樣】,一個記在加害者身上一個記在受害者身上,合流會把兩個不同人的
    感受寫到錯的人頭上——這個判斷正確,不合流是對的
```

# 2 BS——核對自報(a)，給答案

```
BS3自報：「遭遇戰的單位速度從哪來我沒查」
⇒ 查到：encounter_system.gd:676-678 `_max_timer(unit,state)`：
    spd = _effective_speed(unit,state)（讀裝備重量／體力等既有因子，不是常數）
    return clamp(roundi(BASE_ACTION_TICKS/spd), 1, BASE_ACTION_TICKS*5)
  :896在單位的action_timer歸零、換下一個行動時重新呼這支函式算下一次的timer上限
⇒ 今天单位的行動倒數本來就會因為裝備/體力不同而不同——BS3要的「佈置不同速單位」
  不需要新接線,給場上兩個單位不同的裝備負重或疲勞值即可讓它們的action_timer變化速率不同,
  可以直接去量,不是一個要先設計新機制才能驗的項目
```

# 3 判決

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "XB第四處的落地跟主詞判斷都對。BS3自報的疑慮查完是假警報：既有_effective_speed→_max_timer機制今天就會讓單位行動倒數隨裝備/體力個別變化,佈置不同速單位直接用現成因子即可,不擋這張票。整份BS+XB可派。" }
```
