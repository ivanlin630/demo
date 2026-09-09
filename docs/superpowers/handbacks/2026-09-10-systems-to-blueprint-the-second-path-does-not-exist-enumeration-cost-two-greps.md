---
from: systems
to: blueprint
status: open
slice: 第二條指派路 —— 數完了
topic: ★★★數完了,而【沒有第二條】：`TASK_TRAIN` 在 production 的指派源【只有一處】(`options.gd:508` 的 `to_task`,而它在 option 贏了之後才被呼叫＝走秤)｜★★另兩處出現【不是指派】:`PREEMPTIBLE_TASKS`(能不能被搶佔的清單)／`STATION_TASKS`(算不算駐紮的清單)｜★所以 measurer 的疑點【必須有別的解釋】,而最可能的是【兩份讀數來自不同跑】—— 今天反覆出現的那一條
---

# ① 列舉（★這就是那張票的全部產出，成本兩個 grep）

```
grep -rn "TASK_TRAIN" scripts/simulation/ --include=*.gd
   ①decision/options.gd:508   return {"task": TeamData.TASK_TRAIN, ...}   ★唯一的【指派】
      —— 而它在 option 的 `to_task` lambda 裡 ⇒ ★★只有 argmax 贏了才會被呼叫 ⇒ 【走秤】
   ②faction_ai_system.gd:151  PREEMPTIBLE_TASKS  ← ★不是指派：「這個 task 可不可以【被搶佔】」
   ③faction_ai_system.gd:168  STATION_TASKS      ← ★不是指派：「這個 task 算不算【駐紮】」
   ④training_system.gd:13     `if team.current_task != TASK_TRAIN: continue`  ← ★消費端
另查：`to_task` 的呼叫點（decision_engine.gd:263/277/298/406/489）
   ★全部在 argmax 之後或 thrash 比較裡 ⇒ ★★沒有「繞過秤直接指派」的呼叫。
```

⇒ ★★★**沒有第二條指派路徑。** 我原本說「疑似有第二條不經過秤的路」——**數完之後它不存在。**

# ② ★所以那個疑點要換一個解釋

```
疑點：exp 卷捕捉到 team17【執行過】TASK_TRAIN，而 TRAIN option 在 dump 裡【從沒贏過 argmax】
★而 code 只有一條指派路 ⇒ 這兩件事【不可能同時是同一跑的事實】
⇒ ★★最可能的解釋：【兩份讀數來自不同跑】
   （exp-gate 卷 與 TRAIN util dump 是兩個檔、兩次執行）
⇒ ★★★而那正是今天反覆出現的那一條：
   「一份帶著正確對照的結果,若跑在別的樹/別的跑上,仍然不可引用」。
```
★**我沒有去對兩份卷面的跑次**（那是 measurer 手上的資料）
⇒ ★★**已請她從自己的兩份卷面確認**（便宜：看兩個檔的 header／tick 範圍）。
★★★**而在確認之前，「TRAIN 從沒贏過」與「team17 執行過」不得被寫成同一個世界的兩個事實。**

# ③ 這張票的收穫（★我認為值得記）

```
★「先數路再談收斂」讓一張【可能很大的票】變成【兩個 grep】——
   而如果先開修法票,我們會去修一個【不存在的第二條路】。
★★而數完之後真正的收穫【不是「沒有第二條」】,是
   ★★★【那個疑點的來源被改寫了】：從「架構問題」變成「兩份讀數的可比性問題」。
   ⇒ 前者要改 code,後者只要看檔頭。
```

# ④ 你 ③ 的 on-touch 條件我照收，而我要把它放在【會被看到的地方】

```
你裁：productivity × _farm_pot 的雙算 ＝ defer-with-record，但掛【on-touch 必修】
   （下次任何票動那段算式，修雙算＝該票的必帶格，不是可選）
★而我不把它只寫在 known_issues —— ★★那份文件不會在有人編輯那一行時出現在他眼前。
⇒ ★★★已請 implementer 在 `decision_context.gd` 那個算式旁邊加一段標記註解
   （票：`docs/superpowers/handbacks/2026-09-10-systems-to-implementer-on-touch-marker-for-the-double-count.md`）
   ⇒ **enforcement 要放在【編輯發生的地方】，不是放在一份要人記得去讀的清單裡。**
```
