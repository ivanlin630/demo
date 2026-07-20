---
from: implementer
to: measurer
status: consumed
topic: "[measure] god-view Slice E(4 dispatch leak→belief_pos)→ feat/godview-e@62697e6c。seed1337/42/4201 征服(E1)/JOIN(E2)/建國吞併(E3)/突圍(E5)行為:敵脫視野可甩掉追擊=intended(doom-delta track 同 F),真隊無 regression。TDD 10/10、headless 0new(baseline3,4 stale fixture 補 belief tile_pos 透明報)、gate 64、determinism seed1337 2mo byte-identical(md5 c6259497)。★flag systems:faction_ai:1119 out-of-scope 疑似 leak。"
---
# Hand Back: god-view Slice E（4 dispatch 路 live→belief_pos）

承 dispatch `2026-07-20-systems-to-implementer-godview-slice-E-dispatch.md`（spec R² CLEAN scope 訂正 4 處）。

## 實作摘要
branch `feat/godview-e@62697e6c`（off local main 8146c4a2；★禁 origin 落後~55）已 push（★過 installed pre-push 兩閘）。4 真 leak 改 `state.teams[X].tile_pos`(live)→`BeliefSystem.belief_pos(state, self, X)`(last-seen)，無 belief→不 dispatch(sentinel+guard，禁 fallback live)：
- **E1** `_commit_conquest_attack`（faction_ai）攻擊 move_target → belief_pos(prey)；無 belief→return false。（scout 路 F1 已 gate；此 confident→攻擊路是殘留 live 讀。）
- **E2** `_try_join_target`（faction_ai）JOIN move_target → belief_pos(target)；無 belief→false。
- **E3** found_subjugate（faction_ai）建國吞併攻擊 move_target → belief_pos(prey)；無 belief→skip。
- **E5** strategic breakout（`_assign_breakout`/`_find_escape_dir`）逃向+鄰敵 gate 讀 live 敵位 → 逐敵 belief_pos（無 belief 敵略過）；`_find_escape_dir` 簽名改收 Vector2i positions array。敵脫視野→照 last-seen 逃。
- **E4/E6 不碰**（前 slice 已 belief 化，R² 訂正勿改）。

## 我的驗證
- **TDD** `godview_e_test` **10/10 PASS**（RED→GREEN；★還原 faction_ai→5 FAIL[E1/E2 move_target=live god-view]，證 leak 測 load-bearing）。E1 攻擊跟 belief(3,3)非 live(9,9)/E2 JOIN 跟 belief/E2 無 belief→不 JOIN/E5 突圍無 belief→不設 assignment/E5 _find_escape_dir 用傳入 belief 位。
- **headless** `=== DONE ===`，3 fail = **baseline 0 new**。
- **constitution_gate** PASS **sites=64 removed=0**。
- **determinism** seed1337 2mo 2 跑 **byte-identical，md5 `c6259497`**。

## ★透明 flag：4 stale test fixture 修（同 slice2/F 款，非 masking）
headless `_test_attack_gate C`(1025)/scout-convergence(1291)/`Prosperity Task3`(9139)/`breakout distance-guard`(9885) 舊靠 god-view live 位到達 attack/breakout dispatch——其 belief claim **漏 tile_pos**（F1 只補 scout 路 claim；attack 路當時讀 live 故沒補）。補 tile_pos（對齊各 prey/敵位）→ 測改走真 belief-gated 行為，assertion 仍成立。**戰鬥/突圍憑 live god-view 追=正是修掉的病→fixture 需 belief 位=正確**，非掩蓋 regression。

## ★★flag systems（out-of-scope，非我 scope 自改）
grep-audit 揭 `faction_ai:1119` 殘 `_hex_dist(leader_team.tile_pos, state.teams[target_id].tile_pos) < 999` = 讀 live 他隊位算距離 gate。**不在 spec R²-scoped 4-site（E1/E2/E3/E5）內**——可能是 leak（決策憑 live 距離），也可能 legit reachability。**我不越 scope 自改**（R²-scoped dispatch），呈報 systems 評估要不要另 slice 收（若 leak，歸下批 god-view audit）。

## ★請你量（spec §measure）
- **seed1337/42/4201 征服(E1)/JOIN(E2)/建國吞併(E3)/突圍(E5) 行為**：敵脫視野→可甩掉追擊/JOIN 追 last-seen（**intended 深度=伏擊/佯動，勿當 regression**，同 Slice F/attack evasion）。
- **真隊無 regression**（doom-delta track，同 Slice F；starve/pop/teams）。
- **無「跨圖瞬鎖 live 位」殘留**：這 4 路 grep 無 live `state.teams[X].tile_pos` 作 move_target（belief 化證，我已初步 grep faction_ai leak site CLEAN，1119 距離 gate 另議）。
- 你用 `godot --path .worktrees/godview-e` 跑（★禁原地 checkout）。

## 完成判定
task 完成 = systems + reviewer 判，非自判。你量完 → .qa.json/餵 blueprint 或 pre-merge to:systems。我 hold warm 等裁決。
