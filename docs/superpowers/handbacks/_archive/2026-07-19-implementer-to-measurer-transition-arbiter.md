---
from: implementer
to: measurer
status: consumed
topic: "[measure] transition-arbiter-bypass(手不聽腦後門根治)→ feat/transition-arbiter@93966d15。seed1337 team16 不再凍死(broken 3→減)+beggar/settle/zombie 隊不退化+42/4201 無 regression+team64/68 看是否一併解。TDD 12/12、headless 0new(baseline 3,含 stale fixture 修透明報)、gate 64、determinism seed1337 2mo byte-identical(md5 19321b58)。★outpost caller ≥70 情境請驗。"
---
# Hand Back: transition-arbiter-bypass（手不聽腦後門根治）

承 dispatch `2026-07-19-systems-to-implementer-transition-arbiter-bypass-dispatch.md`（spec `2026-07-19-transition-arbiter-bypass.md`，v2 release-first，R² 三輪 CLEAN）。

## 實作摘要
branch `feat/transition-arbiter@93966d15`（off local main 649f7070，含 crisis/beast/hook 全批；★禁 origin 落後30）已 push。

**Part 1 — transition 加 3 guard**（`task_arbiter.gd`，對齊 try_set 的 current_task 寫入不變量）：combat lock / crisis-免疫窗 / emergency-respect（`task_priority≥PRIO_THREAT and priority<current → return`）。擋外部 in-place stomp active emergency。

**Part 2 — resolution caller 改 release-first**（emergency 自身正當退場，現任先 release→IDLE@0→guard 不 fire→set）：
- **beggar-restore ×3**（`interaction:_clear_aid_task` / `player_command:1017` / `sim_runner:259`）：★**move_target 存/還**（release 清 -1，resume previous_task 需原目的地）——存 `saved`→release→`try_set(previous_task, saved, DISPATCH)`。reviewer R²v2 抓的洞。
- **settle ×2**（`interaction:_execute_settlement` / `_convert_to_resident`）：release→transition 生產@AMBIENT。
- **zombie-revive**（`faction_ai:2646` at_site_stuck）：release→transition BUILD@DISPATCH（move_target 隨後顯設）。

**Part 3 — 不改**（guarded transition）：defection 3884（guard 擋其 stomp survival=team16 修）+ outpost BUILD ×6（現任常<70→過）。

## 我的驗證
- **TDD** `transition_arbiter_bypass_test` **12/12 PASS**（RED→GREEN；★還原 task_arbiter guard → 5 FAIL[②defection stomp survival→凍死 / ⑥combat / ⑦crisis-免疫]，證 guard load-bearing）。涵蓋 7 型（②defection stomp/⑤非-emergency 過/⑥combat/⑦crisis/③④release-first-from-emergency/①beggar move_target 還原）。
- **headless** `=== DONE ===`，3 fail = **baseline 0 new**。
- **constitution_gate** PASS **sites=64 removed=0**（release/try_set 換 transition 同 func 內，taskarbiter 指紋不變）。
- **determinism** seed1337 2mo 2 跑 **byte-identical，md5 `19321b58`**（無 RNG）。

## ★透明 flag（stale test fixture 修，非 masking regression）
headless `_test_aid_resolve_npc_accept`/`_refuse` 舊設 begging 隊 `combat_target=1` 存乞討目標——但 **BEG 現走 `social_target`**（`options.gd:173` return `social_target`；`interaction:228` resolver 讀 social_target），**不設 combat_target**。begging 隊設 combat_target=1 語意矛盾（乞討≠戰鬥中）= stale fixture（BEG 遷 social_target 前舊寫法）。改 `combat_target→social_target`（對齊現 BEG 語意）。**戰鬥中不 restore previous_task=正確行為**（combat 優先）——∴ 我的 combat guard 對、fixture 錯。此改零掩蓋真 regression。

## ★請你量（spec §measure）
- **seed1337 team16 不再凍死**（broken 3→減；主靶）。
- **beggar/settle/zombie 隊行為不退化**（release-first 後仍達原意圖：乞討完回原工帶原目的地 / 安頓變生產 / 復工 BUILD）。
- **42/4201 無 regression**（starve/pop/teams）。
- **★outpost caller ≥70 情境驗**（spec Part 3）：outpost BUILD ×6 + `faction_ai:2638` 非-zombie 我假設現任<70→guard 不 fire。若你量到某 outpost caller 在現任≥70 情境被 guard 擋（BUILD 沒 fire）→ 該 caller 應歸 Part 2 release-first，flag 我改。
- **team64/68 idle-latch**（out-of-scope）：落地後看是否一併解，沒解=另案獨立查（記錄即可）。
- 你用 `godot --path .worktrees/transition-arbiter` 跑（★禁原地 checkout）。

## 連動風險
- **defection「等待新領主」現被 guard 擋**（team survival 活時）→ organic sim 中 defection stomp 消失=**預期行為變**（team16 修），非退化。對 baseline diff 會有 team16/defection 相關差異，判準=真隊不凍死 + 無新塌陷。
- beggar-restore 若 previous_task 恰為 crisis_released_task 窗內 → try_set 免疫擋→beggar 留 IDLE（survival re-rank 接）=正確（免疫本該擋），罕見 edge。

## 完成判定
task 完成 = systems + reviewer 判，非自判。你量完 → .qa.json/餵 blueprint 或 pre-merge to:systems 看終 diff（L1 arbiter 核心，建議 systems pre-merge R² 看終 impl diff）。我 hold warm 等裁決。
