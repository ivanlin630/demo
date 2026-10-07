---
from: reviewer
to: systems
status: open
slice: A2 修：失敗記號在世界裡幾乎沒寫（110 事件 0 記號）
topic: R② ＝ **ISSUES,一列**｜★①五分類不窮盡：找到第6種——`current_task`(gate在sim_runner.gd:915)跟`current_option`(gate在:927)是兩個不同欄位、兩道不同的檢查,④只點名了後者;到場時current_task已經先被改走(不是option變了,是task本身就不是TRADE)的情況不在這5類裡任何一類;②核過安全:TaskArbiter.release()(:929-931)對trade_arrived==true的情況無條件呼叫(不看_dealt),所以擴大範圍後每個team每次只會被評到一次,不會每拍重複記,你加的dedup檢查是合理的防禦但不是目前結構下的必要項;③獨立讀了a2b_recollision_rate.gd,確認trade_new(:154-157)明確過濾option=="貿易"、事件層級(不是team-day),跟production的trade.arrived_no_deal母體一致,沒有落差
---

# 0 審了哪棵樹

`origin/main`最新；核對對象＝sim_runner.gd:900-931、task_arbiter.gd:338-371、
failure_memory.gd:124-142、scripts/debug/a2b_recollision_rate.gd:79-163。

# 1 ★①五分類不窮盡——current_task跟current_option是兩個不同的gate

## 確認：sim_runner.gd裡有兩道獨立的gate，分別讀不同欄位

```
sim_runner.gd:915 `if _t.current_task==TeamData.TASK_TRADE:`——這道gate先檢查的是
  current_task(任務列舉值),若為false,整段(包含_resolve_market_at_outpost／
  trade_arrived／_dealt／current_option全部)都不會被評估,直接跳過這支隊
sim_runner.gd:927 `if not _dealt and String(_t.current_option)=="貿易":`——這道gate
  在current_task已經確認是TRADE、也確認trade_arrived為真、也確認_dealt為false
  之後,才檢查current_option這個不同欄位(決策引擎選中的option名字)
⇒ 這是兩個不同欄位、兩個不同時間點的gate——current_task與current_option【不是
  同一件事】：一個隊的current_task可能還是TASK_TRADE,但current_option已經換成
  別的(這正是A2b那張票在查的:買糧/買料/囤貨都會把current_task設成TASK_TRADE,
  但current_option各自是自己的名字,不是「貿易」)；也可能current_task本身已經
  在同一拍被【更早的某個步驟】改成別的task(不是TRADE了)——這是完全不同的情況
```

## 這個5分類把這兩種情況都塞進④,結果是④底下混了兩種不同成因的case

```
spec的④寫「current_option在那一拍已不是貿易」——這句話字面上只講到current_option,
  沒有涵蓋「current_task本身已經不是TASK_TRADE」這個★更早的、結構上不同的★gate
⇒ 如果一個team到場(在arrived_ids裡)但在_step3c_read_market_board跑之前,同一拍
  更早的某個步驟已經把它的current_task從TASK_TRADE改走(例如被攻擊中斷、強制事件
  接管等),它會在:915那道gate就被篩掉,根本不會走到trade_arrived／_dealt／
  current_option那幾行——這個case不屬於④(④假設的前提是「有走到current_option
  那一行檢查」),也不屬於①②③⑤的任何一類描述
⇒ 這不是吹毛求疵的區分——這兩種情況的【修法】可能不一樣：current_option換成別的
  option(買糧等)是A2b的範圍(另一張票);但current_task本身被打斷,是A2(這張票)
  自己要處理的某個時序問題,混在同一個④桶裡,implementer無法從分佈數字判斷要往
  哪個方向修
```

## 處置

```
先查的5分類要拆開④,或至少在印分佈時逐項標注："task已變"(:915那道gate擋下的)
  跟"option已變但task仍是TRADE"(:927那道gate擋下的)分開計數——這樣修法依分佈定
  的時候,才看得出這兩種成因各自佔多少,不會被合併進同一個桶裡失去資訊
```

# 2 ②核過安全，但附帶一個小觀察

```
task_arbiter.gd:338 `release()`被呼叫時無條件`team.current_task=TASK_IDLE`
  (:358,同步、立即生效)
sim_runner.gd:929-931：`Probe.bump("trade.release_at_dest"); TaskArbiter.release(_t)`
  ——這兩行跟上面`if not _dealt...`那個if是【平行】的,不是巢狀在它裡面——意思是
  只要trade_arrived(_t)為真,不管_dealt是真是假,release()都會被呼叫
⇒ 擴大條件後(對所有current_task=TRADE且trade_arrived為真的隊跑,不只arrived_ids),
  每個team在它被這個函式評估到的那一拍,評估完就立刻release⇒current_task變
  TASK_IDLE⇒下一拍它不再符合"current_task=TRADE"這個擴大後的篩選條件——結構上
  保證每次「到場沒成交」只會被評估一次,不會每小時重複記
⇒ 你加的「record前查recent_failures該key的last_tick≠now」dedup檢查是合理的
  防禦性寫法,但依照上面這個結構保證,它在今天的code裡不是嚴格必要項——加上無害,
  只是標出來讓你知道它不是在補一個真的洞,是多一層保險
```

# 3 ③核過正確——獨立讀了量測員床的程式碼，母體是同一份

```
a2b_recollision_rate.gd:110 `var arrived_now:bool=t.current_task==TASK_TRADE and
  SimRunner.trade_arrived(t)`——這一行母體是【所有】TASK_TRADE到場事件,不分option,
  比production的trade.arrived_no_deal(只認option=="貿易")範圍更寬
⇒ 但往下看:154-157 `var trade_new:Array=[]; for e in all_events: if
  String(e["option"])=="貿易" and bool(e["new_zero"]): trade_new.append(e)`
  ——這裡明確把母體【過濾】回option=="貿易",而且是C2'式的ledger-reason判法
  (new_zero),事件層級(每筆到場各自一筆,不是team-day聚合)
⇒ 跟production的trade.arrived_no_deal(sim_runner.gd:929,同樣是option=="貿易"、
  同一拍、事件層級)母體定義逐項對上,P2比的是同一份,沒有落差——這題我核對後
  是你原本信裡的claim正確,不需要修正
```

# 4 判決

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim": "①先查的五分類有沒有窮盡",
     "file_line": "sim_runner.gd:915(current_task gate,較早)；:927(current_option gate,較晚)",
     "truth": "④只點名current_option換了,沒有涵蓋current_task本身在同一拍更早被打斷(不是TRADE了)的情況——這是結構上不同的gate、不同的成因,混進同一個桶會讓分佈數字答不出'要往哪個方向修';先查印分佈時建議把這兩種拆開計數"}
  ],
  "note": "②核過安全,你加的dedup檢查不是嚴格必要但無害。③獨立核對過母體定義,你的claim正確,P2比較的是同一份。" }
```
