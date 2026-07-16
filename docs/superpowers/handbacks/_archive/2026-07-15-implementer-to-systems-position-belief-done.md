---
from: implementer
to: systems
status: consumed
topic: "[完] 位置 belief 化主 arc — HEAD bd6f97d2;核心 A-E + 測試遷移(裁定 a)完;headless 回 baseline 3+3;憲法 sites=29;TDD 8綠;兩跑 bit-identical"
---
# Hand Back：位置感知 belief 化（god-view 位置根治，完成）

branch `feat/position-belief` @ `bd6f97d2`（已 push），base = origin/main `8427cc7b`。

## 核心 A-E（commit 3b12b092）
- **Fix A** `BeliefSystem.belief_pos`：通道分流（跨-faction→BeliefSystem last-seen / 同-faction→known_member_states）+ staleness gate(`BELIEF_STALE_TICKS`) + ★fallback (-1,-1) 禁退自身。
- **Fix B** options.gd to_task 8 分支（掠奪/攻擊/JOIN/MERGE/BEG/攻擊/徵收/外交）→ belief_pos（撲空→IDLE）；佔村→outpost tile 靜態真值（打村格）。
- **Fix C** movement:37-56 逐 tick 追 belief_pos（(-1,-1)→保持不退自身）。
- **Fix D** `_nearest_independent` 補 has_belief gate + belief_pos 距離。
- **Fix E**（defer）observe_velocity 幾何不對稱 spec 接受先行；未動→path_system SSSP 契約不受影響（belief_pos 只改移動目標，per-tick cache 仍有效）。

## 測試遷移（裁定 a，commit bd6f97d2）
belief_pos 需 claim 帶 tile_pos+last_tick（真 sim 由 vision `_write_tier01:113-114` / distortion_engine:52/58 注入；既有 faction_ai:291/309 已讀）。**9 失敗函數**（godot abort-at-first-assert 逐輪揭露：survival_decision_tree/stuck_allows_reeval/solo_commitment/solo_seek_home/p2b1_nonunified/p2a_survival_options/p2a_join_player/p4_stakes/`_mk_independent_target` helper）的 record_claim/known_member_states 測試注入補 tile_pos(target 位)+last_tick(=current_tick)。
- **守裁定**：禁 record_claim production 補預設（傳聞 claim 會 god-view 漏）；只改測試注入端。
- **78 latent**（缺位置但不 assert 位置故不 fail）= test-hygiene backlog → **建議記 known_issues**。

## 驗（TDD + sanity；log docs/measurements/*-bd6f97d2.log）
- **TDD 8/8 PASS**（`position_belief_test.gd`）：通道分流(跨 7,7/同 4,4)、staleness、fallback 禁自身、movement fallback 不退自身、to_task 撲空。
- **headless 回 baseline 3+3 零新增**：剩 3 SE = origin/main pre-existing（beg_join_social_resolve/p2a_survival_terms/strategic_reads_ladder，非本刀引入）。
- **憲法閘 sites=29 removed=0**（改位置資料來源，零新 try_set）。
- **determinism**：`seeded warring reproducible OK (seed=1337 ticks=1200)` 同 seed 兩跑 bit-identical（★非 baseline byte-identical——行為本就該變；本次 final 仍同 base，因真 sim belief 帶 tile_pos 近活值、1200 tick staleness 少觸；逃脫故事屬 measurer 中性驗）。

## 下一站需求（measurer 中性世界，逃脫故事）
1. **★逃脫故事（headline）**：斷視線+移動的隊→追兵撲空率 > 0（現=0）。specimen trace：追擊 move 到 last-seen、視野內刷新、斷視線→撲空。
2. **staleness 解 loop**：駐村隊對「曾現後永離」的敵→threat_react 隨 belief 過期歸零。
3. **不誤殺**：佔村打村格(outpost)、徵收找到同僚(known_member_states)、無 belief→撲空 release 不移向自身。
4. 同 seed 兩跑 bit-identical；HOB obey%；sanity 零新增。

## 待確認
- 78 latent 記 known_issues 請 systems 過目。完成判定 = systems + reviewer/QA + measurer 中性驗（逃脫故事）。context hold warm 等裁決信。
