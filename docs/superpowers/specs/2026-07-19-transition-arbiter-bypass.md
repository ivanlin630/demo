# spec：TaskArbiter.transition 繞過 arbiter 後門根治（手不聽腦）

> 層級：L1（arbiter 核心不變量修，13 caller 面）。off main 899865f6+（beast merged 後）。優先 HIGH（blueprint 核准 2026-07-19，絕境經濟核心 quality bar：「沒有隊伍能坐著/掙扎落空地餓死」）。
> 來源：team16 QA 撿 → systems patch-gate 查坐實。known_issues「TaskArbiter.transition 後門」+「crisis-immunity 覆蓋不全」。
> **★v2 重設計（reviewer R² BLOCKING 2026-07-19 後）**：v1 的 blanket emergency guard 誤傷 survival-resolution 降級（beggar-restore×3/settle/zombie-revive）→ 採 reviewer 推薦 (1) **release-first 慣例**分離語意。

## 病象 + root（file:line 坐實，reviewer factcheck CLEAN）
`TaskArbiter.transition`（`task_arbiter.gd:108-113`）無條件 raw 覆寫 `current_task/task_priority/task_reason/task_start_tick`——**零 guard**（無 combat/免疫/priority 檢查）。13 caller 全繞過。
- **血證 team16**：defection path A（`faction_ai:3884`）`transition("等待新領主", AMBIENT)` → clobber 引擎剛派的 survival@80 + 繞免疫 + 重設 task_start_tick → `_famine_crisis`(`faction_ai:3462`) baseline 恆重置 → crisis 永不 fire → team16 famine `would_succeed=true` 凍死 300 tick。= 手不聽腦後門（機械 override pre-empt 引擎 survival 決策）。

## ★核心設計洞（reviewer 揭）：兩種語意相反的「≥70→<70」降級
priority 梯：COMBAT100/SURVIVAL80/THREAT70/…/DISPATCH50/AMBIENT10。**兩種轉換都呈現「現任≥70，new<70」但語意相反**：
- **(a) 外部低 prio 打斷 active emergency**（defection stomp survival：team16）→ **該擋**。
- **(b) emergency task 自身的 resolution handler 把它降級回常工**（乞討結束 resume / 流亡安頓 / zombie 復工）→ **該放**（emergency 正當退場）。

∴ **不能用「現任≥70 擋降級」blanket guard**（v1 錯誤，誤傷 (b)）。分離靠 **release-first 慣例**：(b) 的 caller 先 `release`（引擎正當退場出口，本就無 guard），guard 專防 (a) 的外部 in-place stomp。

## 修（v2：guard 防外部 stomp + resolution caller release-first）

### Part 1：transition 加 guard（防外部 in-place stomp）
```gdscript
static func transition(state, team, new_task, priority, _source="transition"):
    if team.combat_target != -1: return                       # combat lock 絕對（同 try_set:40）
    if new_task == team.crisis_released_task and team.crisis_released_task != "" \
            and state.world.current_tick < team.crisis_released_until:
        return                                                # crisis-免疫（補 transition 洩漏）
    if team.task_priority >= PRIO_THREAT and priority < team.task_priority:
        return                                                # emergency-respect：擋外部低prio stomp
    team.current_task = new_task; team.task_priority = priority
    team.task_reason = _source; team.task_start_tick = state.world.current_tick
```
- 此 guard **只擋 (a)**：team16 defection 在 survival@80 活時 transition(AMBIENT 10) 被擋 → survival 留 → 覓食接住。**resolution caller 因 Part 2 先 release → 現任=IDLE@0 → guard 不 fire（0 不≥70）→ 正常轉換**，不誤傷。

### Part 2：resolution caller 改 release-first（emergency 自身退場，語意 (b)）
把「解自己 emergency 後降級回常工」的 caller 改：**先 `TaskArbiter.release(team)`（清 emergency→IDLE@0，無 guard）→ 再 set 新 task**（release 後現任=IDLE，transition/try_set 均通過 guard）。逐 caller：
- **beggar-restore ×3**（`interaction_system.gd:1249`、`player_command_system.gd:1017`、`sim_runner.gd:259`）：BEG@80 resolution handler。改 `release(beggar)` → `try_set(previous_task, DISPATCH)`（或 release 後 transition，post-release 現任 IDLE 過 guard）。★保留「restore previous_task」語意，別讓 previous_task 永失。
- **settle**（`interaction_system.gd:1264` `_execute_settlement` + `:1289` convert_resident）：流亡隊常在 survival@80 接受安頓。改 `release(t)` → transition「生產」@AMBIENT。避「tag PRODUCE+入 faction 卻卡舊 survival task」不一致態。
- **zombie-revive**（`faction_ai_system.gd:2646` at_site_stuck 復工 → BUILD@DISPATCH）：zombie 現任若 RETURN_HOME survival@80。改 `release` → set BUILD。（`:2638` 非-zombie 現任 <70 者不需改，measure 確認。）

### Part 3：外部 imposition caller 保持 guarded transition（不改）
- **defection 3884**（等待新領主@AMBIENT）：**保持 transition**——guard 擋它 stomp survival（team16 修）。原意圖註本就寫「AMBIENT 可被高層蓋」→ guard 擋 stomp 正合意圖。team 非 emergency 時（<70）transition 過，設 standby，合理。
- **outpost 建設/BUILD ×6**（`outpost:384/406/447/461/566/602` @DISPATCH）：現任常 IDLE/<70 → guard 不 fire → 照過。**measure 確認**無 caller 在現任≥70 情境（若有→歸 Part 2 release-first）。

## 不變量（invariants.md，含 reviewer 要求的配套句）
- **in-place 轉換（transition）不得 stomp active emergency task（≥PRIO_THREAT）**：arbiter 絕對鎖（combat + crisis-免疫）+ emergency-respect 適用所有 current_task 寫入路（try_set 已守，transition 補齊）。
- **★配套句（reviewer 要求，否則不變量反噬合法退場）**：**emergency task 自身的 resolution/退場走 `release`（→re-rank/re-set）非靠 transition 降級**；被 guard 擋的只有「外部 in-place stomp」，非「emergency 正當退場」。release 是引擎認可的 emergency 退場出口（同 crisis-override/② 的 release→re-rank 正典）。

## ★team64/68 idle-latch = 另案（out-of-scope，reviewer 同意）
idle-latch（food-ok would_succeed=true）本 spec 不預設同根，落地後 measure 看是否一併解，沒解=另案獨立查。

## 驗收
- **TDD**：
  - ①**beggar-restore（v1 漏測型）**：beggar BEG@80 → resolution → release-first → previous_task **恢復成功**（guard 不誤擋）+ previous_task 未被永失。
  - ②**defection stomp（team16）**：survival@80 活 → defection transition(AMBIENT) **被擋** → survival 留 → 不凍死。
  - ③**settle from survival**：流亡隊 survival@80 → release-first → 「生產」set 成 + 態一致（PRODUCE tag ↔ task）。
  - ④**zombie-revive**：zombie RETURN_HOME@80 → release-first → BUILD set 成。
  - ⑤合法非-emergency 轉換不破：安頓/build 現任<70 transition 照過。
  - ⑥combat lock：combat_target≠-1 transition 被擋。⑦crisis-免疫：crisis_released task 窗內 transition 重鎖被擋。
- **★逐 13 caller measure 不破**：每條 caller guard/release-first 後仍達原意圖（reviewer 已分類：beggar/settle/zombie=release-first；defection=guarded；outpost/2638=measure 確認 <70 不受影響）。
- **gate** constitution PASS / **headless** 0 new(baseline 3) / **determinism** 2 跑 byte-identical。
- **measure**：seed1337 team16 不再凍死（broken 3→減）；beggar/settle/zombie 隊行為不退化；42/4201 無 regression；team64/68 看是否一併解（記錄）。

## 排序
HIGH。off main（beast merged 後 HEAD）。R² v2 必過（重點審 release-first 分離是否乾淨、有無漏的 resolution caller）→ dispatch。
