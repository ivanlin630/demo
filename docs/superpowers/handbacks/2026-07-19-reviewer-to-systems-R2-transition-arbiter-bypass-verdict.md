---
from: reviewer
to: systems
status: consumed
topic: "[R² verdict·transition-arbiter-bypass·BLOCKING] emergency guard(≥70)誤傷 survival-resolution 降級轉換:beggar-restore×3 確認被擋(BEG@80→restore@50→previous_task 永失),settle/zombie 疑同。根缺陷=guard 無法分『外部打斷 active emergency』vs『survival task 自身 resolution 降級回常工』。root 診斷正確但修法過粗→回設計。"
---

# R² verdict：transition-arbiter-bypass（arbiter 核心，HIGH）

**VERDICT: issues（BLOCKING）** — root 診斷正確、方向對（transition 補 arbiter 紀律），但 **emergency guard 的 ≥PRIO_THREAT 二元分界系統性誤傷「survival task 自身 resolution handler 降級」型合法轉換**。`premise_contradiction: false`（root 前提坐實），但 spec §design-principle + R²審點1 的核心安全宣稱「合法轉換全在 <THREAT 區」= **被 factcheck 打臉**。

factcheck 對 base `899865f6`。

## Root 前提坐實（factcheck CLEAN）
- `task_arbiter.gd:108-113` transition raw 覆寫 current_task/task_priority/task_reason/task_start_tick，**零 guard**（無 combat/免疫/priority 檢查）。坐實。
- team16 血證：`faction_ai_system.gd:3884` defection `transition("等待新領主", PRIO_AMBIENT)` → 可 clobber survival@80 + 繞免疫 + 重設 task_start_tick(`:113`)→ `_famine_crisis` baseline 恆重置 → crisis 永不 fire。坐實。手不聽腦後門 = 真 root。
- 三 guard 方向（combat lock / crisis-免疫 / emergency-respect）對付 team16 的 defection-stomp（AMBIENT 10 vs survival 80）**有效**：那是「外部低 prio 打斷 active emergency」=該擋。

## ★BLOCKING 發現：guard 誤傷 survival-resolution 降級轉換

priority 梯（`task_arbiter.gd:7-14`）：COMBAT100/SURVIVAL80/THREAT70/PLAYER60/VENDETTA55/DISPATCH50/FACTION30/AMBIENT10。
emergency guard = `if team.task_priority >= 70 and priority < team.task_priority: return`。

**BEG 是 survival option → 派發 @PRIO_SURVIVAL(80)**（`decision/options.gd:346-347` `priority_for`：`opt in SURVIVAL_OPTION_SET → PRIO_SURVIVAL`；BEG∈SURVIVAL_TASKS `faction_ai:79`）。∴ 乞討中 `beggar.current_task = BEG @ 80`。

### 確認被擋（3 caller，鐵證）：beggar-restore
`_clear_aid_task`（`interaction_system.gd:1245-1253`，從 BEG resolution handler `:1121/1128/1141` 呼叫，此刻 beggar 確在 BEG@80）：
```
TaskArbiter.transition(state, beggar, previous_task, PRIO_DISPATCH(50))   # 恢復乞討前原 task
...
beggar.previous_task = ""
```
guard：`task_priority(80) >= 70 且 priority(50) < 80` → **return（擋）**。結果：previous_task **未恢復** + 隨後 `previous_task=""` **永久清空** → beggar 卡 BEG@80、restore 意圖丟失。
- 三處全中：`interaction_system.gd:1249`、`player_command_system.gd:1017`、`sim_runner.gd:259`（NPC 乞討路 BEG 必 @80；player 路視入 BEG 途徑，NPC 路已足以坐實）。
- 非永凍（aid 後食物回升 → 下 survival cadence release BEG），但 **(a) 丟失 previous_task「resume 原工」語意（改從頭 re-rank）(b) 1-cadence 卡窗 + 可能 re-beg churn**。**直接違反 spec 驗收「逐 13 caller guard 後仍達原意圖」**（TDD② 只測 安頓50→生產10，漏掉 BEG80→restore50 這型）。

### 高疑被擋（需 impl/measure 確認現任 priority）
- **settle**（`interaction_system.gd:1264` `_execute_settlement` → 生產@AMBIENT 10）：被安頓的流亡隊現任多為 survival task（RETURN_HOME/CAMP/FORAGE @80，流亡隊常在求生態才接受安頓）→ guard 擋(80≥70,10<80) → **安頓設不了「生產」**，隊卡舊 survival task 卻已被 tag PRODUCE + 入 faction = 不一致態。（`:1289` convert_resident 同型。）
- **at_site_stuck 復工**（`faction_ai_system.gd:2646` → BUILD@DISPATCH 50）：zombie 現任 RETURN_HOME（survival@80）→ guard 擋 → 「殭屍復工」recovery 被廢（`days_left≥3` gate `:2629` 降嚴重度，但若該 zombie 仍持 @80 則復工失敗）。

### 低風險（現任通常 <70，measure 確認即可）
- outpost 建設/BUILD ×6（`outpost:384/406/447/461/566/602` @DISPATCH 50）：建設隊非緊急，現任常 IDLE(0)/<70 → guard 不 fire。
- 2638 非-zombie 候選（現任 MANUFACTURE/TRADE，`interruptible` set `:2620` 全 <70）。

## 根缺陷（why blocking）
emergency guard 的二元 `現任≥70 && new<70` **無法區分兩種語意相反的轉換**：
- **(a) 外部低 prio 打斷 active emergency**（team16 defection stomp survival）→ **該擋**（修的目標）。
- **(b) survival/emergency task 自身的 resolution handler 把它降級回常工**（乞討結束 resume / 流亡安頓 / zombie 復工）→ **不該擋**（是 emergency 正當退場）。

兩者都呈現 `現任≥70, new<70`。guard 一刀切 → 治好 (a) 同時打壞 (b)。spec §design-principle「合法轉換發生在 <THREAT 區」的前提**只對 安頓50→生產10 這種 non-survival→non-survival 成立，對 survival-resolution 降級（80→低）不成立**——而後者恰是多個 caller 的本職。

## 修向（reviewer 提向，systems 設計；不代設計）
1. **release-first 慣例**：resolve emergency 的 caller（beggar-restore/settle/zombie-revive）改先 `TaskArbiter.release(team)`（release 無此 guard，是引擎正當「emergency 退場」出口）再 try_set/dispatch 新 task；transition 的 emergency guard 專防「外部 in-place stomp」。→ 語意分離乾淨（release=自身退場，guard=外部打斷）。
2. 或 **窄化 guard 只針對 team16 pattern**（defection「等待新領主」這條）而非全 ≥70 blanket——但易變 pre-existing 特判補丁，不推薦。
3. 或 **transition 加「resolution/self-downgrade」旗標**參數，caller 明示「我在解自己的 emergency」豁免 guard——比 (1) 多改介面，(1) 較乾淨。

**傾向 (1)**：與現有 release/try_set 家族一致，且 crisis-override/② 已建立「release→re-rank」正典路。

## 同意 out-of-scope
team64/68 idle-latch、seed1337 fragile 不綁本 spec。

## 回覆
issues（blocking）→ 請 systems 據上收斂修法（重點 beggar-restore/settle 的 survival-resolution 降級路），改好回 R²。不 dispatch implementer（避白建被擋的 caller 才發現）。

——不變量新增（`in-place 轉換不得 stomp emergency task`）本身**方向對、值得進 invariants.md**，但需補一句「emergency 自身 resolution handler 的降級退場走 release 而非被 guard 誤擋」的配套，否則不變量字面會反噬合法退場。
