# spec：TaskArbiter.transition 繞過 arbiter 後門根治（手不聽腦）

> 層級：L1（arbiter 核心不變量修，13 caller 面）。off main 899865f6（beast-fix merged 後）。優先 HIGH（blueprint 核准 2026-07-19，絕境經濟核心 quality bar：「沒有隊伍能坐著/掙扎落空地餓死」）。
> 來源：team16 QA 撿 → systems patch-gate 查坐實。known_issues「TaskArbiter.transition 後門」+「crisis-immunity 覆蓋不全」。

## 病象 + root（file:line 坐實）
`TaskArbiter.transition`（`task_arbiter.gd:108-112`）無條件 raw 覆寫 `current_task/task_priority/task_start_tick`——**不檢查 combat lock、不檢查 crisis-免疫、不檢查現任 priority**。13 caller（`faction_ai:2638/3876`、`interaction:1249/1264/1289`、`outpost:384/406/447/461/566/602`、`player_command:1017`、`sim_runner:259`）全繞過。
- **血證 team16**：defection path A（`faction_ai:3876`）`transition("等待新領主", AMBIENT)` → ①可 clobber 引擎剛派的 survival@80（無 priority 檢查）②繞過免疫（免疫只在 try_set:45-47）③重設 task_start_tick(112) → `_famine_crisis` baseline（`faction_ai:3462`）恆重置 → crisis 永不 fire → team16 famine `would_succeed=true` 凍死 300 tick。
- = **手不聽腦後門**（機械 override pre-empt 引擎 survival 決策=補丁閘家族）。

## 修（arbiter 不變量：in-place 轉換不得 stomp emergency task）

### 設計原則
transition 正當用途 = **同工作線就地轉換**（安頓 DISPATCH(50)→生產 AMBIENT(10)＝合法降級，team 已完安頓轉生產）。∴ **不能用「禁降級」guard**（會打壞 安頓→生產）。分界 = **emergency task（survival/threat/combat，priority ≥ PRIO_THREAT=70）是引擎緊急態，任何 in-place 轉換不得 stomp**；合法轉換發生在 <THREAT（DISPATCH/AMBIENT）區，不受影響。

### transition 加三 guard（鏡射 try_set 絕對鎖 + emergency-respect）
```gdscript
static func transition(state, team, new_task, priority, _source="transition"):
    if team.combat_target != -1:
        return   # combat lock 絕對（同 try_set:40 / set_strategic_move:27）
    # crisis-免疫：剛 crisis-released 的 task 窗內禁 transition 重鎖（補 transition 洩漏；同 try_set:45-47 精神）
    if new_task == team.crisis_released_task and team.crisis_released_task != "" \
            and state.world.current_tick < team.crisis_released_until:
        return
    # emergency 現任不被 in-place 轉換 stomp：survival/threat/combat(≥PRIO_THREAT) 活著時，
    # 低於它的 in-place 轉換 yield（合法轉換在 <THREAT 區不受影響：安頓50→生產10 仍過，因 50<70）
    if team.task_priority >= PRIO_THREAT and priority < team.task_priority:
        return
    team.current_task = new_task
    team.task_priority = priority
    team.task_reason = _source
    team.task_start_tick = state.world.current_tick
```

### 為何治 team16
- team16 若 survival 已派（task_priority=80）→ defection transition(AMBIENT 10) 被 emergency guard 擋（80≥70 且 10<80）→ survival 留 → 覓食接住。
- team16 若 survival 未派時 transition 設 等待新領主(AMBIENT) → survival try_set(80>10) 正常 preempt；下 cadence defection 再 transition → 此時 survival 活(80) → guard 擋 → 自我校正。
- crisis-released 的 等待新領主 窗內 → transition 重鎖被免疫 guard 擋 → crisis re-rank 生效。
- transition 被擋 → 不再每 cadence 重設 task_start_tick → `_famine_crisis` baseline 可累積 → crisis 正常 fire（若走到）。

## ★team64/68 idle-latch = 另案，本 spec 不預設同根（QA/blueprint 提醒 2026-07-19）
team64/68 = `would_succeed=true` idle-latch（food-ok，非 famine）。**機制未定**（可能 release-無-redispatch / arbiter latch / 另條 transition）。本 spec 治 team16 的 transition-bypass；**team64/68 待本 spec 落地後 measure 看是否一併解**（emergency guard 可能也接住它們，也可能不）——**若沒解=獨立查根因，別綁本 spec**。

## 不變量（新增/強化，invariants.md）
- **in-place 轉換（transition）不得 stomp emergency task（≥PRIO_THREAT）**：arbiter 的絕對鎖（combat + crisis-免疫）+ emergency-respect 適用**所有** current_task 寫入路（try_set 已守，transition 補齊）。手不聽腦 = 任何繞過 arbiter 的 raw task 寫入。

## 驗收
- **TDD**：①emergency guard——survival(80) 活時 transition(AMBIENT) 被擋、survival 留；②合法轉換不破——安頓(DISPATCH 50)→生產(AMBIENT 10) transition 仍成（50<THREAT）；③combat lock——combat_target≠-1 時 transition 被擋；④crisis-免疫——crisis_released task 窗內 transition 重鎖被擋；⑤team16 型——leaderless famine + survival would-succeed → survival 接住不凍死。
- **★逐 caller measure 不破（13 caller）**：建設/生產/BUILD/beggar-restore/defection 各自的 transition 在 guard 後仍達原意圖（多在 <THREAT 或非-emergency 情境，應不受影響）——measurer 驗每條 caller 行為不退化。
- **gate**：constitution_gate PASS（transition 加 guard = 收緊非新增引擎外閘，應不增違憲 site；反而 de-patch 手不聽腦）。
- **headless**：0 new（baseline 3）。
- **determinism**：同 seed 2 跑 byte-identical。
- **measure**：seed1337 team16 不再凍死（broken 3→減）；42/4201 無 regression；team64/68 看是否一併解（記錄）。

## 排序
HIGH（blueprint 核准）。off main 899865f6。R② 必過（arbiter 核心，異質框外審可考慮=大框改控制流）→ dispatch。
