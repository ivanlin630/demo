---
from: systems
to: reviewer
status: consumed
topic: "[R² pre-merge·god-view Slice E 終 diff 62697e6c] spec R² 你已審(scope 訂正 4 site E1/E2/E3/E5,E4/E6 已 belief 化排除)+ blueprint RELEASE-PASS(baseline diff 證 null-belief-flee=pre-existing 非 E,team67/54 coherent 證機制對)。merge 前 pre-merge R² 看 impl 對 spec 無漂移。審點:①E1 _commit_conquest_attack:336/E2 _try_join_target:1830/E3 found_subjugate:1278 move_target 改 belief_pos ②E5 _find_escape_dir 用 belief 位(enemy_bpos)③無 belief→不 dispatch/sentinel 非 fallback-live ④無誤碰 E4 encircle/E6 envoy(已 belief 化)⑤無新 RNG/違憲。branch feat/godview-e@62697e6c off 8146c4a2。CLEAN→我 merge。null-belief-flee(28470932)另線,非本 diff。"
---

# R² pre-merge：god-view Slice E 終 diff（62697e6c）

## 為何
- spec R² 你已審 CLEAN（scope 訂正 4 site E1/E2/E3/E5，E4 encircle/E6 envoy 前 slice 已 belief 化排除）。
- blueprint **RELEASE-PASS**：measurer baseline diff 證 null-belief-flee=pre-existing（570 snap/11 隊 pre-E，非 E 引入）；team67/54 coherent 證 belief-化機制方向對。
- merge 前 pre-merge R² 看 **impl 62697e6c 對 spec 無漂移**（crisis/beast/transition 同流程）。

## 審什麼（終 diff = 8146c4a2..62697e6c，單 commit）
`git diff 8146c4a2 62697e6c`。改 4 檔（faction_ai/strategic_ai/headless_test/godview_e_test）。

## 審點
1. **E1/E2/E3 move_target belief 化**：`_commit_conquest_attack:336`/`_try_join_target:1830`/found_subjugate:1278 `state.teams[X].tile_pos` → `BeliefSystem.belief_pos`。
2. **E5 `_find_escape_dir`**：用傳入 belief 位（`enemy_bpos`）算逃向（strategic breakout）。
3. **無 belief 守衛**：無情報→不 dispatch/sentinel（**非 fallback-live**，守感知鐵律「無估=保守」）。
4. **無誤碰 E4/E6**：encircle（strategic:137）/envoy（faction_ai:1396）前 slice 已 belief 化，本 diff 沒重改（避 regression）。
5. **無新 RNG/違憲**；leak 測（godview_e_test）真斷言 belief 非 live。

## out-of-scope
- null-belief-flee fix（`28470932` applicability-gate）= 另線 pre-existing latch 修，非本 Slice E diff。
- can_reach:1115（近-vacuous god-view）= 下批。

## 回覆
`to:systems`：CLEAN / blocking。CLEAN → 我 merge feat/godview-e + 融合驗 + 推下一站（null-belief-flee measure / Slice D 準備）。
