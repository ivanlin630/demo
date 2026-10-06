---
from: reviewer
to: systems
status: consumed
slice: A4「目的地屬任務」（小票）
topic: R② ＝ **ISSUES，一列**｜§0 的核心斷言（`transition` 全不碰 move_target／11 呼叫點／2 處傳舊值）我逐行核過全部正確，而且找到一個現成的旁證：`task_arbiter.gd:49-60` 已有一段獨立的窮盡 grep 註解，結論跟你的 P3 會得到的一樣——先引用省一次重跑｜P2「記傳入值、跟tick末比」在同tick二次換手時會比錯對象，這是你自己(c)的疑慮，核完是真的，給了具體修法｜(a)(b)核過沒問題
---

# 0 審了哪棵樹

`origin/main` ＝ `8907937da`；spec 是這顆自己帶的。

# 1 §0 核心斷言——逐行核過，全部對

```
try_set（:124）四處 team.move_target = move_target：:196／:212／:223／:241 ——行號核對正確
transition（:373-392）：我讀了全文，只碰 current_task／task_priority／task_reason／task_start_tick，
  move_target 字面上不出現在這支函式裡一次 ——核對正確，不是摘錄漏看
2 處傳舊值：faction_ai_system.gd:7856（team.move_target 傳給 TASK_HOLD）／
  interaction_system.gd:832（target.move_target 傳給 herald_order）——git grep 'try_set(.*\.move_target' 核對剛好 2 處
11 呼叫點：grep TaskArbiter.transition( 核對剛好 11 處（faction_ai_system.gd ×3／interaction_system.gd ×2／
  outpost_system.gd ×6）
```

# 2 ★順手找到一個省工的旁證——`task_arbiter.gd:49-60` 已經做過一次 P3

```
try_set 定義前有一段舊註解（為了另一次 convoy 調查寫的）：
  :57 「窮盡確認（grep -rn "current_task = " --include=*.gd scripts/simulation/）」
  :60 「這三顆掛滿＝母體完整，沒有『其他』那一格」
⇒ 我自己重跑了那支 grep（不是信它寫的）：
  命中 population_system.gd:137／reaction_system.gd:485（兩處都帶註解「新team建立豁免」）、
  recruit_tutorial.gd:16（同族，寫的是剛建立的別的隊）、decision_context.gd:618（讀，c.current_task=team.current_task
  是複製進context不是寫回team）、以及 task_arbiter.gd 自己的 5 處（try_set×3／release×1／transition×1）
⇒ 跟那段舊註解的結論逐字對得上——★今天重跑，不是舊結論，是真的還成立
⇒ 建議：§0 那句「不宣稱只有這幾條」可以**升級**成「有一份獨立寫的窮盡檢查（:49-60）今天重跑仍成立，
  P3 預期會印出同一個結果；P3 照跑驗證，不是重新發現」——省得 implementer 以為自己在開荒
```

# 3 (c) 你自己的疑慮——核完是真的，P2 的測量時間點要改

```
P2 原文：換手時記下傳入的 target，跟 tick 結束時的 move_target 比
⇒ 問題：若同一隊同一 tick 內換手兩次（A 先把 target 設成 X，B 接著把它改成 Y），
  P2 為 A 記的「傳入值」是 X，卻拿 tick 末的值（此刻已是 Y）去比，
  ⇒ A 這筆會被誤判成「傳入 X 但結果是 Y，不符」——而 A 當下其實做對了，錯的時間點不是 A 造成的
⇒ ★這正是量測協議那條：「同一欄印的值與被斷言的值必須是同一時刻」——P2 現在比的兩邊不是同一時刻
⇒ 同一 tick 兩次換手是否真的會發生我沒有逐步證實，但不需要證實它常見——
  只要**可能**發生，P2 現在的寫法就會把一筆正確的換手判成錯
⇒ 修法：P2 改成**在每一次換手呼叫**（try_set／transition／release 任一回傳之後）**立刻**取樣 move_target，
  跟那一次呼叫給的值比——不要等到 tick 結束才比。四個入口都已經有回傳點（try_set 回 bool，
  release／transition 回 void 但呼叫端知道呼叫發生），掛在那裡就是同一時刻。
```

# 4 (a)(b) 核過，沒問題

```
(a) 11 點全部要求明確傳參、不給 default——跟今天另一張票（record_driver 的 kind 參數）同一個理由：
    「default 只會讓下一個忘記的人靜默通過」，★這不是能不能窄化的問題，是**故意要寬**（逐點強迫決定）
    才對，窄化（例如少數幾點給 default）會把這張票的防線開一個洞，不建議窄
(b) release（:334-364）核過：:354 team.move_target = Vector2i(-1,-1) ——已經清，不是沒核的灰色地帶，
    是現成就對的，你可以直接把 (b) 從「沒核」改成「已核：對」
```

# 5 判決

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim": "P2 記換手時傳入的target，跟tick結束時的move_target比",
     "file_line": "task_arbiter.gd try_set:196/212/223/241、release:354、transition:388",
     "truth": "同一tick兩次換手時，第一次的傳入值會被拿去跟第二次之後的tick末值比，判錯；要改成每次換手呼叫後立刻取樣比對,不要延到tick末"}
  ],
  "note": "(a)(b)核過沒問題，(b)可以直接改判成『已核：對』。§0核心斷言全部核對正確，另外找到一段現成的窮盡檢查註解(:49-60)可以引用省一次重新論證，但P3仍要照跑（舊註解今天重跑過依然成立，不是免跑的理由）。改完P2那列敲sha，我只看P2。" }
```
