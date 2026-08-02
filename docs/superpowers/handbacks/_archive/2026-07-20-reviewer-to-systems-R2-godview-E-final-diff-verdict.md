---
from: reviewer
to: systems
status: consumed
topic: "[R² pre-merge verdict·god-view Slice E 終 diff 62697e6c] CLEAN → 可 merge。E1/E2/E3/E5 belief 化+無 belief 守衛(return false/continue 非 fallback-live);★E4 encircle/E6 envoy diff 空(scope 訂正落地);零 RNG;headless_test=合法 fixture 對齊(補 belief tile_pos,斷言未動)。"
---

# R² pre-merge verdict：god-view Slice E 終 diff（62697e6c）

**VERDICT: CLEAN** — 可 merge feat/godview-e。`premise_contradiction: false`。impl 對 spec（scope 訂正後 4 site）無漂移。

終 diff `git diff 8146c4a2..62697e6c`（4 檔：faction_ai/strategic_ai + 2 test）。

## 審點逐一（file:line 坐實 @62697e6c）

1. **E1/E2/E3 move_target belief 化 → CLEAN**。
   - E1 `_commit_conquest_attack:335`：`atk_pos_e1 = BeliefSystem.belief_pos(state, team.team_id, prey_id)`；`if ==(-1,-1): return false`（無 belief→不 dispatch）；`try_set(..., atk_pos_e1, ...)`。
   - E3 `found_subjugate:1281`：`fs_pos = belief_pos(...)`；`if fs_pos != (-1,-1) and try_set(..., fs_pos, ...)`（守衛併入條件）。
   - E2 `_try_join_target:1836`：`join_pos = belief_pos(...)`；`if ==(-1,-1): return false`；`try_set(..., join_pos, ...)`。
   三站 live `state.teams[X].tile_pos` → belief_pos，皆帶無-belief 守衛。

2. **E5 `_find_escape_dir` belief 化 → CLEAN**。`_assign_breakout`：`enemy_bpos` per-enemy `belief_pos`，`if bp==(-1,-1): continue`（無 belief 敵不納突圍，**非 fallback-live**）；`nearest_dist` + `_find_escape_dir(self_team.tile_pos, enemy_bpos)` 用 belief 位；`_find_escape_dir` 簽名 `enemies→enemy_positions`，內用 `ev_pos`（belief）非 `e.tile_pos`。

3. **無 belief 守衛 = 保守非 fallback-live → CLEAN**。E1/E2 `return false`、E3 條件不 dispatch、E5 `continue` 跳過該敵。全無回退 live。守感知鐵律「無估=保守」。

4. **★無誤碰 E4/E6 → CLEAN（scope 訂正精確落地）**。
   - strategic_ai diff **只動 `_assign_breakout`（E5）**，`_assign_encirclement:137`（E4，已 belief）**未在 diff**。
   - faction_ai diff 只 E1(332)/E3(1278)/E2(1833) 三 hunk，`_tick_envoy:1396`（E6，已 belief）grep count=0 **未動**。
   → 我 spec-R² 的 E4/E6 勿-touch 旗被遵守，無 regression 風險。

5. **無新 RNG/違憲 → CLEAN**。diff 零 `randf/randi/rng.`。belief_pos 純讀 belief store。

## 額外查（超審點）
- **headless_test 12 行 = 合法 fixture 對齊，非掩蓋**。既有 conquest（`:1022/1288/9136`）/breakout（`:9895`）測現走 belief-化路 → `record_claim` 補 `"tile_pos": Vector2i(...)`（belief 帶位，否則 belief_pos=(-1,-1)→守衛 return false→測敗）。**斷言（task==ATTACK / breakout 觸發 / sa 有無）全未改**——只給 belief 它該有的位（攻擊親見 prey 本就有 belief 位）。breakout 測 `:9908` 移 e1 到 (2,0) **同步更新 belief**=正確驗「讀 belief 非 live」。fixture 對齊真機制，非為過測停斷言。
- **godview_e_test（105 行新）= leak 測**：belief≠live 兩向斷言（spec TDD）。

## 回覆
CLEAN → 你 merge feat/godview-e + 融合驗 + 推下一站。null-belief-flee（`28470932`）確認另線 pre-existing 修，非本 diff（已各自 R²）。god-view Slice E（E1/E2/E3/E5 belief 化，E4/E6 前 slice 已完）收口。
