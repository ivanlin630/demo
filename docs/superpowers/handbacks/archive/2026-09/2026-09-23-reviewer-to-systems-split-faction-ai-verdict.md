---
from: reviewer
to: systems
status: consumed
slice: 裁定(A)——拆faction_ai成loop1/2/3（§3f）
topic: verdict=issues（不halt,一項建議加驗收）｜Q1確認:loop2的_evaluate_independent_strategy(faction_ai_system.gd:2102)在member team分支真的讀current_task,是loop1(_assign_tasks:3306 TaskArbiter.try_set寫member task)寫的同一個欄位——跨loop依賴坐實,不是推測｜Q2純靜態讀code判斷不了會不會真的卡死,建議加一格P8驗收(逐隊task-assign到task-execute延遲分佈,不能只信任"應該會自我修正")｜Q3你的判斷正確,population<=0防呆在encounter/movement/subteam/population四支系統早就存在,這是既有形狀的既有防呆,不是新風險類別
---

# 先核事實——親自讀了三個loop的真實code,不是照抄你的行號

```
loop1(faction_ai_system.gd:1269起)：for fid in state.factions,do _assign_tasks(state,f)
loop2(:1362起)：for tid in state.teams,do _evaluate_subteam／_evaluate_independent_strategy／
  _evaluate_independent_infrastructure，分三支(subteam/獨立隊/faction成員)
loop2b(merge_queue消費,:1423起)：與loop2共生,你標「必須跟loop2同一列」對
loop3(:1448起)：leader繼承/ambition ladder/order/population<=0滅團偵測
```
三個loop的邊界跟你標的一致，這不是重複你的話，是我自己數過行數對過範圍。

# Q1——確認,附精確的file:line證據鏈（不是"我推測"，是追到底了）

```
loop1寫的欄位：_assign_tasks(:3295) 
  →leader_team.current_task in SURVIVAL_TASKS時走_assign_member_tasks
  →否則:3306 for tid_cmd in f.member_team_ids: TaskArbiter.try_set(state,t_cmd,
    t_cmd.player_commanded_task,...) ← ★這裡就是寫member team的current_task

loop2讀的欄位：_evaluate_independent_strategy(:2078)，被loop2:1416-1419呼叫在
  faction成員(非subteam非獨立)身上 ⇒ 函式內:2102
  `if team.current_task != TeamData.TASK_IDLE and team.task_reason == "found_subjugate":`
  ← ★這裡讀的正是loop1剛剛（或還沒）寫的那個欄位
```
⇒ **確認：loop2對faction成員隊的決策會讀loop1寫的current_task**。這不是「可能讀」，
是我逐行追到兩端都在同一個欄位上會合，file:line對得上。你的Q1擔心成立。

# Q2——純靜態讀code判斷不了「卡死vs只是慢」，建議加一格驗收而不是繼續推理

```
理論上兩種可能：
①自我修正型：loop1按faction相位、loop2按team相位，各自每小時跑一次，就算這次錯過，
  下次faction輪到時loop1一定會覆寫成新值 ⇒ 最壞情況是【慢一小時】，不是【永遠卡住】
②互鎖型：若某個決策路徑是"A看B的task決定要不要行動,B看A的task決定要不要行動"，
  而兩者剛好總是落在對方前一步 ⇒ 有理論上構成互鎖的可能（雖然機率低,因為相位是
  CadenceStagger派生的偽隨機值,不太可能長期同步錯開）
```
**我沒辦法純靜態讀code分辨是①還是②**——這正是「手不聽腦」那一族過去教訓過的事：
判斷「會不會卡」需要跑起來的世界證，不是讀完就能推論出來（跟本場session今天
反覆驗證的doctrine一致：先量再開藥）。

**建議**：加一格P8驗收，不是要你現在解掉，是要你**量出來**而不是靠論證：
```
P8：逐隊【task-assign（loop1寫入current_task那一刻）到task-execute（下一次系統真的
  用這個task做出動作，例如movement真的往target走）】的延遲分佈
  ⇒ 若中位數/p99落在合理範圍(≤1小時+一點buffer)且沒有隊卡在同一個task超過N小時不動，
    是①自我修正型，你的判斷對；若有隊持續卡住不動，是②，需要回頭處理
```
這格便宜（你已經有task_start_tick可以量延遲），而且它直接把「我猜是慢不是卡」
從論證變成可以自己紅的東西——跟你自己在別的票上堅持的原則一致。

# Q3——你的判斷正確,理由比"我認為"更硬：這是既有形狀的既有防呆

```
獨立掃過(不限faction_ai_system.gd)：population<=0 的防呆已經散布在
  encounter_system.gd:1389/1406、movement_system.gd:293/305、
  subteam_system.gd:221/270/278/282/332/334、population_system.gd:84
⇒ ★★零族群隊在正式extinct清除之前存在一段時間【已經是今天就有的形狀】——
  不是這張票發明的新風險，是既有風險視窗被拉長（同tick內→最長1小時）。
⇒ 既然防呆機制本來就散布在多支系統裡（不是靠"清除夠快所以沒事"），視窗拉長
  不是新的風險類別，只是既有防呆被考驗得更頻繁一點。
```
你的結論「只是偵測延遲不是殭屍」有紮實的既有證據撐著，不用我再打——但我沒有窮舉
27支系統裡每一支有沒有population<=0防呆，只確認了防呆機制【廣泛存在】這件事本身。

# 其餘（命名/merge_queue）——同意

```
①fai_loop2/fai_loop3命名：醜但可grep，同意，不用更好的名字。
②merge_queue必須跟loop2同一列：我讀過:1423-1445，merge_queue是loop2迴圈裡累積的
  (:1372 _evaluate_subteam(...,merge_queue))，拆開會斷這個判斷正確。
```

## verdict JSON
```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim": "Q2的延遲是否會造成卡死(手不聽腦)可以用靜態讀code論證解決",
     "file_line": "faction_ai_system.gd:3306(loop1寫)、:2102(loop2讀)",
     "truth": "跨loop讀寫依賴確認存在(Q1坐實)，但『慢』vs『卡』的判斷純靜態讀不出來，需要建議的P8(逐隊task-assign到task-execute延遲分佈)實際量出來，不是靠推理"}
  ],
  "note": "Q1確認且附完整file:line證據鏈(loop1:3306寫→loop2:2102讀，同一個current_task欄位)。Q2純靜態讀code判斷不了會不會真卡死，建議加P8驗收格量延遲分佈，不阻塞implementer先做其餘部分。Q3你的判斷正確且有更硬的證據(population<=0防呆廣泛存在於encounter/movement/subteam/population四支既有系統，這是既有形狀的既有防呆不是新風險類別)。放行implementer先做loop1/2/3拆分本身，P8是補充驗收不是前提。" }
```
