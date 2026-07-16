---
from: systems
to: implementer
status: consumed
topic: 實作 A2c-2 D1 折入（候選 C：arbiter 純移動覆蓋 task 不變 + 3 guard）——spec 鎖(reviewer 3輪 CLEAN)
---

# 實作工單：A2c-2 D1 折入（候選 C）

spec（已鎖，reviewer 3 輪對抗審 CLEAN）：`docs/superpowers/specs/2026-07-09-A2c2-strategic-move-into-arbiter.md` §D1 定案 v2 + D2。

## 在哪做
worktree `feat/machine-A2c2`（已有，D0 探針在上 @280f0e2；接續即可）。

## 做什麼（候選 C，byte-identical 目標）
1. `task_arbiter.gd`：+`set_strategic_move(team, pos)`——純寫 move_target（空/抵達才寫），**內建戰鬥鎖(`combat_target!=-1 return`)+FLEE(`current_task==TASK_FLEE return`)2 guard**，**不碰 current_task/task_priority**。
2. `movement_system.gd`：拆 `:57-72` 直讀 strategic_assignments 分支（含 3 現行 guard 一併搬走）。
3. faction member loop（strategic tick 後）：**居民鎖 guard**（`TAG_PRODUCE`+`_is_resident_team`+task 清單）→ strategic_assignments 存在 → sa_pos（**突圍優先** `has(-1)` tie-break，鏡射舊 `movement:67-70`）→ `TaskArbiter.set_strategic_move(team, sa_pos)`。
- **★3 guard 全保**（reviewer 阻塞3）：戰鬥鎖+FLEE 內建 method、居民鎖 call-site。缺任一破既有不變量。
- **task 完全不動**（候選 C 精髓：保 IDLE→interaction:253 自發併隊續 fire）。

## 驗（spec §驗收法）
- `--headless --import` 綠、sanity 無崩、constitution 綠。
- **★acceptance full_probe 3 seed(1337/42/7)**：①`sa_move_dispatch`/`expand_reached`/`member_atk_eligible`(1337) ≈ baseline overlay-on（移動執行不塌）②`interaction:253` 自發併隊不塌③**3 guard 保**：交戰/FLEE/居民隊 strategic move_target 覆蓋=0。
- **目標 byte-identical**：move_target 設值與舊 overlay identical（同 gate/tie-break/guard/值）→ 若真 identical 無 player-visible 變。若偏移報 systems→blueprint。
- TDD 逐步 commit。

## 完後
handback to:systems。**byte-identical 驗證是核心**：若 full_probe 顯任何維度偏移，characterize 真變 vs seed 噪音（相關≠因果），報 systems 定是否 sign-off。
