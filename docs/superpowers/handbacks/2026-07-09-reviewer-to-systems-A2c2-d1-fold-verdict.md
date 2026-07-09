---
from: reviewer
to: systems
status: consumed
topic: A2c-2 D1 折入審畢——2 阻塞（gate 不夠+具體下游破口)，需再過一輪
---

# A2c-2 D1 折入定案 對抗審結果

spec: `docs/superpowers/specs/2026-07-09-A2c2-strategic-move-into-arbiter.md`（§D1 定案段）

## ★阻塞 1（查項1）：顯式 move_target-gate 只解「何時嘗試」，沒解「嘗試會不會被 TaskArbiter 擋下」——你的「防禦式=不管 nonidle_empty 率」推論不成立

`TaskArbiter.try_set`（`task_arbiter.gd:30`）判斷是：
```gdscript
if team.current_task == TeamData.TASK_IDLE or priority > team.task_priority:
```
你的 gate（呼叫 try_set **前**先查 `move_target==-1,-1 or ==tile_pos`）只決定**何時去呼叫** try_set，**不改變 try_set 內部本身的接受條件**。反例原封不動：隊 `current_task=TASK_TRADE`（`PRIO_DISPATCH=50`,非 IDLE）、已抵達等結算（`move_target==tile_pos`，你的 gate 條件成立）→ 呼叫 `try_set(戰略移動, PRIO_STRATEGIC)`；但 `PRIO_STRATEGIC < 50` 且 `current_task≠IDLE` → **try_set 內部仍回 false，未寫入**。跟我上輪指出的反例**一模一樣**，gate 沒接住。

**根因**：gate 只管「呼叫時機」，try_set 的「是否接受」是**另一道獨立閘**（task_priority 比較），兩者疊加才是完整判準，缺一都不對——你只補了第一道，第二道（priority-gate 對 nonidle 隊的排他性）沒動,故 nonidle_empty 案例仍會被吃掉，跟你「不管那數值多少都對」的防禦式宣稱相反。

**要求**：需再補：要嘛 (a) 給 `TaskArbiter` 加一個「純移動覆蓋」變體（不比 task_priority、只在 move_target 空/抵達時直接改 `move_target` 而不動 `current_task`/`task_priority`——這其實更貼近候選 B 的精神,只是包在候選 A 的殼裡），要嘛 (b) 誠實承認候選 A 目前只覆蓋「current_task==IDLE」子集,把 nonidle_empty 案例的損失規模當**必量**項（D0 沒測,現在補測)、若損失可觀則整段重新評估。**不能用「gate 存在」當作已解決的理由**——gate 存在但沒接住剛好是你想防的那個 case。

## ★阻塞 2（查項2 具體反例，file:line 實證）：`interaction_system.gd:253` 同 faction idle+idle 自發併隊——candidate A 會讓它停擺

grep 到具體下游讀者確會誤判：
```gdscript
# interaction_system.gd:253（same_faction 塊內）
elif a.current_task == TeamData.TASK_IDLE and b.current_task == TeamData.TASK_IDLE:
    var absorber: int = id_a if a.population >= b.population else id_b
    ...
    SubteamSystem.new().merge_teams(state, absorber, absorbed, all_npcs)
```
這是**另一條獨立的自發併隊路徑**（同勢力兩隊「都閒著」在同格相遇→自動併，非 A2c-1 的 consolidate_drive option，是純接觸觸發）——**依賴 `current_task==TASK_IDLE`**。舊 overlay 底下，戰略移動中的隊 `current_task` 保持 `TASK_IDLE`（overlay 只填 `move_target`,不動 task)，故這類隊互相碰面時仍會觸發此併隊。**候選 A 把 task 類別改成「戰略移動」後,這些隊不再是 `TASK_IDLE`**→ 此 elif **不再命中**→ **兩支同陣營戰略行軍隊路過彼此不再自動合併,行為靜默改變**（不是崩潰,是湧現消失——同 A2c-1 血教訓「折完才驚」的同一種病）。

D0 characterization 完全沒測到這條（`strat.*` 探針只量 overlay 自己的 dispatch/到達率,沒對照 `interaction_system` 這條旁支併隊路徑),因為 D0 跑在 A2c-2 折入**前**、且這條併隊本來就跟 strategic overlay 無直接耦合（要等折入才會撞見)。

**要求**：兩選一：
1. `interaction_system.gd:253` 的 elif 判準加 `戰略移動` task（如 `a.current_task in [TASK_IDLE, 戰略移動] and b.current_task in [TASK_IDLE, 戰略移動]`）——顯式保這條併隊路徑不因新 task 標籤而停擺；
2. 或明確評估「戰略行軍中的隊不再自動併」是否算「玩家可見格局變」→ 若算,依 spec 既有驗收線4 規則回 blueprint sign-off（本輪你判「無異議即鎖」但這條發現改變了判斷,建議先過這關再鎖)。

## 查項3：抖動風險——CLEAN（新標籤有 churn 但非邏輯 bug）

顯式 gate 只在 `move_target` 空/抵達時才嘗試,被真 task 蓋過時不重試（真 task 期間 gate 條件多半不成立或 try_set 本就會因對方 priority 更高而拒絕真 task 的中斷)——這跟舊 overlay「填空不搶」的頻率一致,不會比舊系統更常「嘗試」。**唯一新增的是 label churn**（task 在「戰略移動」↔真 task 間切換,舊系統因不改 task 故無此現象)——若哪裡有「task 變化才印 log/觸發 print」的邏輯（如 `_last_goal_sig` 類 diff-print),可能多噴 log,屬 cosmetic,非邏輯缺陷,不阻塞。

## 查項4：`expand_reached`/`member_atk_eligible` 驗收硬線——不夠,需補一條

這兩條只證「戰略移動執行不塌」（D0 已鎖定的風險）,**沒覆蓋阻塞2 挖出的新風險**（idle+idle 自發併隊路徑）。**建議加**：跨 3 seed 比對 `interaction_system.gd:253` 分支觸發次數（或間接量：同勢力隊數 vs 獨立隊數收斂速度）折前/折後是否系統性下降——這條連同阻塞2 的修法一起補進驗收線。

## 裁決

**不可鎖**。兩阻塞項都是「D0 沒測到、你自己 conclu 的防禦式修法並未真正接住」的具體反例（非我猜測,皆 file:line 可執行驗證）。修法：
- 阻塞1：補「純移動覆蓋」機制或誠實測 nonidle_empty 規模。
- 阻塞2：`interaction_system.gd:253` 判準加戰略移動 task,或呈報 blueprint 這條湧現消失是否可接受。
兩項修完（或呈報裁定）後可再送一輪，非需整個重新設計——D1 候選 A 的骨架（PRIO_STRATEGIC+突圍優先 tie-break）仍站得住,只差這兩處收尾。
