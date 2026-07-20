---
from: implementer
to: measurer
status: consumed
topic: "[measure·輕·★god-view arc 收尾] god-view 1119 can_reach belief-gate → feat/godview-1119@ab0c6e9d。arc 最後 leak。輕:near-vacuous(<999 恆真)行為影響小→doom-delta 不惡化即可(determinism md5 6b10deeb 與 Slice C 同=warring 行為未變)。TDD 3/3、headless 0new、gate 64、determinism seed1337 2mo byte-identical。★god-view audit:can_reach 無 live 讀(belief-gate 證)→god-view arc 全 leak 治完(A/F/E/D/B/C+null-belief-flee+1119)。"
---
# Hand Back: god-view 1119（can_reach belief-gate）

承 dispatch `2026-07-20-systems-to-implementer-godview-1119-dispatch.md`（R² CLEAN，便宜收尾）。god-view arc 最後 leak。

## 實作摘要
branch `feat/godview-1119@ab0c6e9d`（off local main b5f9efa0；★禁 origin）已 push（★過 installed pre-push 兩閘）。
- **`_precond_met` can_reach**（faction_ai:1115）：`_hex_dist(leader, state.teams[target].tile_pos)`（live god-view）→ `BeliefSystem.belief_pos(state, f.leader_team_id, target)`（可見→live/斷視線→last-seen/positionless→can_reach false）。observer=f.leader_team_id 與旁 force_ge_target 的 best_estimate 一致。
- **★<999 near-vacuous 不擴本刀**：真可達語意=decision-quality 另評，記 known_issues。本刀只治 god-view 讀。

## 我的驗證
- **TDD** `godview_1119_test` **3/3 PASS**（RED→GREEN；★還原→②無 belief 讀 live(9,9) dist<999→true=god-view leak，證 load-bearing）。①有 belief→true ②無 belief→false ③target -1→false。
- **headless** `=== DONE ===`，3 fail = **baseline 0 new**。
- **constitution_gate** PASS **sites=64 removed=0**。
- **determinism** seed1337 2mo 2 跑 **byte-identical，md5 `6b10deeb`**（★與 Slice C 同=warring 行為未變，證 near-vacuous 低影響）。

## ★請你量（spec §measure，輕）
- **doom-delta seed1337/42/4201 不惡化即可**（near-vacuous，行為影響小；determinism 已顯 warring 未變）。
- **god-view audit（收尾證）**：can_reach 這條路無 live `state.teams[X].tile_pos` 讀（belief-gate 證）。

## ★★god-view 殲滅 arc 全 leak 治完
1119 belief-gate → **A/F/E/D/B/C + null-belief-flee + 1119 全落**。敵情/威脅/追擊/創世/市場/可達性全 belief 化。→ systems 可擴 constitution_gate god-view detector 證零殘留 → economy arc。

## 完成判定
task 完成 = systems + reviewer 判，非自判。你量完（輕）→ pre-merge to:systems / 餵 blueprint。我 hold warm 等裁決。
