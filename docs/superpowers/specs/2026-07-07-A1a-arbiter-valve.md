# A1a — 拆閥（arbiter equal-priority latch + 四 no-release task），精確 spec

母 spec：`2026-07-07-A1-pipeline-collapse.md`（總綱閉迴路 + 藍圖裁3/裁5）。
工單：`docs/superpowers/handbacks/2026-07-07-blueprint-to-systems-A1a-工單.md`。
本 slice 只做兩件事，不碰 subset 層（A1b）、不碰 side-effect atomicity（A1c）。

## 改點 1：`scripts/simulation/task_arbiter.gd:24` — source-gated equal-priority self-replace

**現況**：`try_set` 用 `priority > team.task_priority` 嚴格大於——引擎每 cadence 重排的
rank[0] 在同層（PRIO_DISPATCH=50 vs 50）被靜默丟 = arbiter latch（bed `arbiter_latch` 桶）。

**改法**（實作裁量：source 白名單，非分兩 API——現有 `_source` 參數已在）：

- 新 const `ENGINE_SOURCES: Array = ["unified", "solo"]`——引擎主 rank 的兩個 dispatch 面：
  - `faction_ai_system.gd:1511` `_decide_unified`（source="unified"，unified/member 隊）
  - `faction_ai_system.gd:1747` `_evaluate_solo`（source="solo"，非 unified solo 隊）
  - **不含** `"scout"`/`"prosperity"`（`faction_ai:296/307` conquest scout-verify scaffolding
    ——該處自帶 release-then-set 換手 + `SCOUT_TIMEOUT` 生命週期，放進白名單=允許主 rank
    中途 stomp 在途斥候，破 G3d-2 收斂迴路。保守排除）。
  - **不含** `"ambition"`（PRIO_AMBIENT=10，DISPATCH 50>10 嚴格大於已能換，無需放行）。
- `try_set` 首段（idle / 嚴格大於）後插入 equal-priority 分支：
  `priority == PRIO_DISPATCH and team.task_priority == PRIO_DISPATCH
   and _source in ENGINE_SOURCES and team.task_reason.trim_prefix("defy_") in ENGINE_SOURCES`
  → 換 task（蓋 current_task/move_target/task_priority/task_reason/task_start_tick，回 true）。
  - incumbent 也要求 engine-owned（`task_reason` 檢查）＝工單「只放行引擎換**自己的** task」：
    herald_order/merchant_order/scout 等同層現任不被 stomp。
  - `defy_unified`/`defy_solo`（抗命贏來的引擎 task）視同 engine-owned（trim_prefix）。
- **同 task 重申 = no-op return true**：`new_task == team.current_task` 時不重蓋章——
  保 `task_start_tick` 起算單源（W2 TRADE timeout 不被每 cadence 重申歸零 → zombie 防護不破）。
- TRADE 在途被搶的 Probe（`trade.preempt.*`）在新分支鏡射（觀測 parity）。

**護欄（不動）**：combat 物理鎖 `task_arbiter.gd:22-23`；PLAYER@60 天花板（equal 分支要求
兩側==50，PLAYER incumbent 不可能進入）；抗命窗口 `:36-49` 原樣；外部子系統
（strategic/diplomatic/herald/player_command）source 不在白名單 → 仍嚴格大於。

## 改點 2：四 no-release task 加 timeout release

**現況**：`TASK_TRAIN / TASK_MANUFACTURE / TASK_GOVERN / TASK_PRODUCE` 無任何
`TaskArbiter.release` 路徑（factcheck 證）＝永久 latch（bed `no_release_latch` 桶）。

**改法**（仿 W2 TRADE_TIMEOUT 樣板 `faction_ai_system.gd:744-750`）：

- `faction_ai_system.gd` 常數區（`TRADE_TIMEOUT` :114 附近）加：
  - `STATION_TASKS: Array = [TASK_TRAIN, TASK_MANUFACTURE, TASK_GOVERN, TASK_PRODUCE]`
  - `STATION_TIMEOUT: int = TimeScale.TICK_PER_DAY * 4`（TEST VALUE，照妖鏡債，裁5；
    駐地原地 task 無距離項 → 純 base，不需 per-hex 項）。
- loop3 TRADE timeout 塊（:744-750）後加對應塊：
  `current_task in STATION_TASKS and task_priority < PRIO_PLAYER
   and tick - task_start_tick > STATION_TIMEOUT`
  → `Probe.bump("station.timeout")` + `TaskArbiter.release(team)`。
  PLAYER@60 現任豁免（護欄：引擎 timeout 不得清玩家命令；四 task 現無 player command
  入口，guard 防未來）。
  release 回 idle → 下 cadence 重新競爭（腦仍最想做→重派同 task；不是→rank[0] 換手＝閉迴路）。

**連動修（timeout 正確性前提）**：`TaskArbiter.transition` 不蓋 `task_start_tick`——
TASK_PRODUCE 經 `interaction_system.gd:1065/1090` transition 進場拿 stale 起算 → 派出即被
timeout 秒殺（W2 漏斗定罪過同型 bug，`faction_ai:740-742` 註解）。修法：`transition` 加
`state` 參數蓋 `task_start_tick`（與 try_set 同源）。呼叫點全改（14 處）：
`faction_ai:2407,3391`、`outpost_system:384,406,447,461,566,602`、
`player_command_system:1017`、`sim_runner:175`、`interaction_system:1050,1065,1090`、
`headless_test:10939`。簽名變不動呼叫點位置 → constitution gate 指紋（relpath::func）不變。

**已知行為副作用（接受，記 handback）**：beggar 恢復 previous_task（transition 路徑）
現在重新起算 timeout——比舊 stale 起算（恢復即可能秒殺）更正確。

## 驗收（main 現有工具，工單 5 條）

1. `.\tools\godot.ps1 --headless --import` 乾淨（無 GDScript 錯誤）。
2. `.\tools\godot.ps1 --headless --script scripts/debug/hand_obeys_brain_bed.gd` 跑完
   無 SCRIPT ERROR、無 timeout。
3. `.\tools\godot.ps1 --headless --script scripts/debug/constitution_gate.gd` 不 FAIL
   （本 slice 不增 try_set/transition 呼叫點；簽名變不動指紋）。
4. 非退化：headless_test ≥1000 tick 無崩、關鍵 print 在。
5. 方向：bed `arbiter_latch`/`no_release_latch` 桶對 HEAD 基線**減少**（母 spec :27 閘校正：
   跨版本 aggregate=噪音，只驗方向不追精確數字；精確單點驗收=別的 slice）。

## 明確不做

- A1b subset 折疊（survival@80/threat@70 前置 dispatch）、A1c side-effect atomicity
  （`faction_ai:1517` `_set_ok` gate）。
- 非 unified solo 隊的 idle-gate（`faction_ai:1714` busy skip）＝bed arbiter_latch 桶另一半，
  屬 A1b 重排範圍，本 slice 不碰（改點 2 的 release 已讓其定期回 idle 重評，間接鬆綁）。
- 不引用 HandBrainProbe / 單點 bed（未 merge）。
