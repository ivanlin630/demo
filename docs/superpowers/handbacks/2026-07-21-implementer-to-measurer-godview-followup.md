---
from: implementer
to: measurer
status: consumed
topic: "[measure·enemy_outpost behavior-sensitive/jhost 輕] god-view follow-up 2 殘留 belief-gate → feat/godview-followup@9e965631。★enemy_outpost belief-gate 影響選址(outpost 分佈/衝突率/doom-delta seed1337/42)——determinism md5 變(4aa393b6)證行為變=預期(只避已知敵→更多衝突湧現,藍圖看數字)。jhost 輕(join 決策)。TDD 3/3、headless 0new、gate PASS(gv_teamstate removed=1/gv_mapscan tracked,baseline 未碰)、determinism seed1337 2mo byte-identical(無新 RNG)。"
---
# Hand Back: god-view follow-up（jhost + enemy_outpost belief-gate）

承 dispatch `2026-07-21-systems-to-implementer-godview-followup-dispatch.md`（detector v3 撿 2 殘留，reviewer R² 判真 leak+CLEAN）。

## 實作摘要
branch `feat/godview-followup@9e965631`（off local main 0f92cf21；★禁 origin）已 push（★過 installed pre-push 兩閘）。
- **① jhost（decision_context:373）**：`state.teams[_jhost].tile_pos`(live)→`belief_pos(team, _jhost)`（同 1119/Slice D）。無 belief→(-1,-1)→_reachable false。**移除 gv_teamstate fingerprint**。
- **② enemy_outpost（faction_ai:2912）**：全圖敵據點 loop 內加 belief filter `belief_pos(leader, owner.team_id) != -1`（store-free proxy：只避已知敵、未見不避）。**loop 結構保留**（hoist perf）→ gv_mapscan tracked（systems merge 改 baseline，我未碰）。

## 我的驗證
- **TDD** `godview_followup_test` **3/3 PASS**（RED→GREEN；★還原→②owner 無 belief 敵據點仍納=god-view leak，證 enemy_outpost gate load-bearing；jhost=1119-identical，1119 已 TDD 證）。
- **headless** `=== DONE ===`，3 fail = **baseline 0 new**。
- **constitution_gate** PASS **sites=75 removed=1**（gv_teamstate 由 jhost de-patch / gv_mapscan 保留 tracked for enemy_outpost）。★baseline.txt **未碰**（systems merge 時改：jhost 移除 + enemy_outpost re-label gate-ok belief-filtered）。
- **determinism** seed1337 2mo 2 跑 **byte-identical，md5 `4aa393b6`**（★無新 RNG；md5 較前 slice 變=enemy_outpost 選址行為變，behavior-sensitive）。

## ★請你量（spec §measure）
- **★enemy_outpost belief-gate behavior-sensitive**：影響選址→**outpost 分佈 / 衝突率 / doom-delta（seed1337/42）**。只避已知敵→有時建 near 未見敵→更多衝突湧現（**arguably 更好戲**，藍圖看數字）。doom-delta 惡化不明顯即 OK。
- **jhost 輕**：影響 join 決策（無 belief host→不算可達），行為影響小。
- **god-view audit（收尾證）**：這 2 路無 live `state.teams[X].tile_pos`/`tile_pos` 讀（belief-gate 證）。
- 你用 `godot --path .worktrees/godview-followup` 跑（★禁原地 checkout）。

## ★god-view arc 真收官
2 site + baseline 訂正（systems merge）→ **god-view detector 剩全 legit/gray + belief-filtered** → 真 zero-untracked-god-view-residual。arc 全 leak 治完（A/F/E/D/B/C+null-belief-flee+1119+followup 2）→ 敵情/威脅/追擊/創世/市場/可達性/join/選址全 belief 化。→ blueprint arc 收官 → economy arc（re-baseline）。

## 設計點（R² vet，供你判）
enemy_outpost 用 **belief-about-owner imperfect proxy**（belief_pos 給 owner last-seen 非據點位；owner 可 roam，見過 owner≠精確知據點位）。R² 判可接受（軟 penalty 容忍高 + 免建 team_outpost_known 大 store）。若 measurer 量到選址明顯失真（避到錯位/該避沒避過頭）→ flag，可能需真 store（過重，另評）。

## 完成判定
task 完成 = systems + reviewer 判，非自判。你量完 → pre-merge to:systems / 餵 blueprint。我 hold warm 等裁決。
