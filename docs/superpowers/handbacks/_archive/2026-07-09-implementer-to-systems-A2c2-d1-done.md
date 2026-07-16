---
from: implementer
to: systems
status: consumed
topic: A2c-2 D1 折入完成（候選 C）——byte-identical 驗證：行為全 0 diff，唯 expand_reached 探針定義精化
---

# A2c-2 D1 FA6 折入 arbiter（候選 C）— 完成

worktree `feat/machine-A2c2` @ `015b7b1`（接 D0 @280f0e2）。

## 做了什麼（候選 C，task 不變）
- **`task_arbiter.gd`** +`set_strategic_move(team, pos)`：純移動覆蓋（move_target 空/抵達才寫），**內建戰鬥鎖+FLEE 2 guard**，不碰 current_task/task_priority。`sa_move_dispatch` bump 搬此。
- **`movement_system.gd`**：拆 `:66-77` 直讀 strategic_assignments 分支；**保留居民鎖/戰鬥 `continue`**（查明=通用移動 guard 非 strategic-only，blame 顯 predate overlay；移除會讓 combat 隊 stale move_target 漂移=破 byte-identical）；`expand_reached` 改 `old_target ∈ strategic_assignments.values()`。
- **`sim_runner.gd`** +`_step2a_strategic_move(state, teams)`：於 `_step2_move_teams` **前**跑（= 舊 movement 讀 strategic_assignments 的同一 read-point → byte-identical timing）；居民鎖 guard 留 call-site（需 `_is_resident_team`）→ 突圍優先 tie-break → `set_strategic_move`。near + far 兩分支各接。

## ★byte-identical 驗證（核心，pointwise diff vs D0@280f0e2，3 seed 1337/42/7）
用 `seeded_warring_bed` WARRING_BASELINE 逐點對照（stash D1→跑 D0 baseline→pop→跑 D1 diff）：

| 結果 | |
|---|---|
| `sa_move_dispatch` | **0 diff**（move_target dispatch 逐位元同） |
| curve/intent/final/`member_atk_eligible`/`capture`/`breakout_assigned`/`encircle_assigned` 及**其餘全部** | **0 diff** |
| `strat.expand_reached` | **唯一 diff**：1337 21→25 / 42 42→54 / 7 41→45 |

**expand_reached +Δ = 探針定義精化，非行為變**：D0 用 `sa_set` local flag，**僅計「同一 movement window 內 dispatch+arrival」**；隊跨多 window 旅程（第 N 窗派、第 N+3 窗到）D0 **漏計**（中途 move_target 非空→sa_set 不重設）。D1 用 `values()` 成員判 → **計真到達（含多窗程）**=更正確。sim 行為逐位元同（sa_move_dispatch + 全行為 metric 0 diff 為證）。

## 驗收線對照（spec §驗收線）
1. **移動軌跡等價（byte-identical 目標）**：✅ sa_move_dispatch/member_atk_eligible/其餘全 0 diff。expand_reached +Δ 為探針定義非行為。
2. **interaction:253 自發併隊不塌**：✅ task 全不動（保 IDLE），且 pointwise 全 metric 0 diff（併隊相關 join/merge 探針無偏移）。
3. **arbiter 一致**：✅ strategic move_target 現經單一 `TaskArbiter.set_strategic_move` owned path（D11/V3 收 bypass）。
4. **憲法/sanity**：✅ constitution PASS(30,0)、`game_sim_multi` 0 SCRIPT ERROR/invariants=0。
7. **3 guard 保**：✅ 結構（set_strategic_move 內建 combat+FLEE、call-site 居民鎖）+ 實證（該三類隊 byte-identical 於 D0-有-guard，全 0 diff）。

## byte-identical 判定
候選 C 目標達成——**sim 行為逐位元不變**（唯一差異=diagnostic 探針 expand_reached 定義精化）。∴ **無 player-visible 變、無需 blueprint sign-off**（spec 驗收線6）。expand_reached 定義變若你要嚴格 0-diff 我可還原 sa_set 版（但需犧牲多窗到達計數正確性），請示。

## 待
- measurer 正式 acceptance full_probe（3 seed 更長窗）+ 覆核 byte-identical（我這份=implementer 1-month pointwise，快速鐵證；measurer 可跑 3-month 確認）。
- 完成判定 systems + measurer/blueprint。
