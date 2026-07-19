---
from: systems
to: implementer
status: open
topic: "[dispatch·god-view Slice E·R² CLEAN(scope 訂正 4 處)·★off LOCAL main db8b057d] spec=2026-07-20-godview-slice-E-parallel-dispatch.md。真 leak 4 處(R² 訂正,E4/E6 已 belief 化勿碰):E1 _commit_conquest_attack(:336 state.teams[prey_id].tile_pos)/E2 _try_join_target(:1830 state.teams[target_id].tile_pos)/E3 found_subjugate(:1278 live prey)/E5 strategic_ai _find_escape_dir(:207 e.tile_pos 突圍逃跑讀 live 敵位)。修=move_target/方向讀 BeliefSystem.belief_pos(範式 slice2/options.gd:194),無 belief→不 dispatch(禁 fallback-live,sentinel+guard 同 Slice F)。★E5 逃跑方向:讀 belief last-seen 敵位算逃向(敵脫視野→照最後見位逃,合理)。★★branch off LOCAL main db8b057d,禁 origin(8c88dd00 落後~55)。pre-push hook 已裝。TDD:leak 測(dispatch 移動跟 belief 非 live,E1/E2/E3/E5)+無 belief 不 dispatch。gate/headless 0new/determinism/measure(征服/JOIN/突圍 belief 化,敵脫視野可甩追=intended,doom-delta track 同 F)。task 完成=systems+reviewer。"
---

# dispatch：god-view Slice E（平行 dispatch 路，R² CLEAN scope 訂正）

spec：`docs/superpowers/specs/2026-07-20-godview-slice-E-parallel-dispatch.md`。

## ★★ branch base
- **off LOCAL main `db8b057d`**（禁 origin `8c88dd00` 落後 ~55）。pre-push hook 已裝（push 起兩閘）。

## 修 4 處（R² 訂正後真 leak，E4/E6 已 belief 化勿碰）
| # | site | 修 |
|---|---|---|
| E1 | `_commit_conquest_attack` `faction_ai:336` | `state.teams[prey_id].tile_pos` → `BeliefSystem.belief_pos(state, team, prey_id)` |
| E2 | `_try_join_target` `faction_ai:1830` | `state.teams[target_id].tile_pos` → belief_pos |
| E3 | found_subjugate `faction_ai:1278` | live prey 位 → belief_pos |
| E5 | `strategic_ai_system _find_escape_dir:207` | `e.tile_pos`（突圍逃跑讀 live 敵位）→ belief last-seen 敵位算逃向 |

- **無 belief 守衛**：無情報 → 不 dispatch（`continue`/return，**禁 fallback-live**，sentinel+guard 範式同 god-view Slice F F1）。
- **E5 逃跑方向**：讀 belief last-seen 敵位算逃向（敵脫視野→照最後見位逃，合理；非瞬鎖真敵位）。
- ★**E4 encirclement（strategic:137）+ E6 envoy（faction_ai:1396）前一 slice 已 belief 化，勿碰**（重改 regression 風險）。

## 驗收
- **TDD**：leak 測（真值≠belief 兩向：E1/E2/E3/E5 dispatch 移動目標/方向跟 belief 非 live）+ 無 belief→不 dispatch。
- **gate** PASS / **headless** 0 new(baseline 3) / **determinism** 2 跑 byte-identical。
- **measure（→measurer）**：seed1337/42/4201 征服/JOIN/突圍 belief 化——敵脫視野可甩掉追擊/逃向照最後見位（intended 深度非 regression），真隊無 regression（doom-delta track 同 Slice F）；grep 這 4 路無 live `state.teams[X].tile_pos`/`e.tile_pos` 作 move/方向（belief 化證）。

## 完成判定 = systems + reviewer/QA。做完 → to:measurer（doom-delta）or to:systems（pre-merge R²）。
