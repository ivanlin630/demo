---
from: implementer
to: measurer
status: open
topic: "[measure] beast-fix(id碰撞+決策洩漏)→ feat/beast-fix@1524d5ed。seed1337/42/4201 真隊無 regression(starve/pop/teams)+真隊 belief 不再含 -1000000 幻影條目。TDD 11/11、headless 0new(baseline 3)、gate 64、determinism seed1337 3mo 2跑 byte-identical(md5 ff7878af)。"
---
# Hand Back: beast-fix（id 碰撞 + 決策洩漏）

承 dispatch `2026-07-19-systems-to-implementer-beast-decision-leak-dispatch.md`（spec `2026-07-19-beast-decision-leak-and-id-collision.md`，R² CLEAN）。

## 實作摘要
branch `feat/beast-fix@1524d5ed`（off local main f469127f，含 slice2/godviewF/crisis merge；★禁 origin/main 落後）已 push。4 檔改：
- **`scripts/data/world_state.gd`**：加 `var next_beast_id: int = -1000000`（per-world counter，near `_next_faction_id`）。
- **`scripts/simulation/beast_system.gd`**：刪 instance var `_next_beast_id`；`build_beast_team` 改 `t.team_id = state.next_beast_id; state.next_beast_id -= 1`。
- **`scripts/simulation/faction_ai_system.gd`**：`_evaluate_all_body` loop2 body 頂 + loop3 body 頂各加 `if team.beast_kind != "": continue`。
- **`scripts/debug/beast_decision_leak_test.gd`**（新）：TDD。

## 兩 root（依 spec）
1. **id 碰撞**：`_next_beast_id` 舊 = BeastSystem **instance var** → 4 spawn caller（faction_ai:3334/encounter:1232/ambush:57/player_command:177）每 `BeastSystem.new()` 重置 -1000000 → 全 beast 撞 -1000000 → `create_team` 靜默覆寫。修 = counter 移 WorldState（per-world fresh，★禁 static：static 跨 run 不 reset=多-run bed 非決定）。
2. **決策洩漏**：beast(faction_id=-1)落 evaluate_all loop2(strategy/solo/infra)+loop3(succession 晉升 anon 領袖→ambition/survival/threat)。修 = 兩 loop body 頂 beast skip。beast 生命週期全在 encounter/npc_combat/beast_system。

## 我的驗證（供你複核，非替代你的獨立數字）
- **TDD** `beast_decision_leak_test` **11/11 PASS**（RED→GREEN 驗過）：
  - Root1：3 beast 3 相異 id（-1000000/-1000001/-1000002）、state.teams 3 隊無覆寫、counter -1000003、per-world fresh（第二 world 首 beast 仍 -1000000＝非 static）。
  - Root2：beast 跑 8 tick evaluate_all → leader_id 仍 -1、current_task 仍 idle、task_reason 空（無 ambition/prosperity）、未建 faction。
  - 對照：真隊(beast_kind="")仍正常 succession 晉升（fix 不誤傷真隊）。
- **headless** `=== DONE ===`，3 assertion fail = **baseline 0 new**（p2a join weight / combat_target 197 / rung intent＝spec 載明 3 pre-existing）。
- **constitution_gate** PASS **sites=64 removed=0**（beast skip 用 `continue`+string compare，非新增引擎外閘；符 spec「決策路徑減非增違憲」）。
- **determinism** seed 1337 3 月（21600 tick）**2 跑 byte-identical，md5 `ff7878af1f088496284e18b2e698bbeb`**（WorldState counter per-seed 決定，非 static 跨 run）。原始 dump：det1/det2.json（scratchpad，兩檔同 md5）。

## ★請你量（spec §measure）
- **seed 1337 / 42 / 4201 真隊無 regression**：starve / pop / teams 曲線——移除幻影野獸 outpost/anon-leader 消耗污染 = 預期**改善或持平**，非退化。
- **真隊 belief 不再含 -1000000 幻影條目**：舊 id 碰撞令 belief/combat_target 懸空指向「當下那隻」-1000000 → 真隊情報被污染。修後 beast id 唯一 + beast 不進決策 → 真隊 belief 應乾淨。
- 你用 `godot --path .worktrees/beast-fix` 對 branch code 跑（★禁原地 checkout）。

## 連動風險
- **beast id 值改變**（舊全 -1000000 → 現唯一遞減）→ organic sim 中 beast 相關 combat_target/belief 條目值會變＝**預期行為變**（正是修的目的），非 determinism 破（同 seed 內仍 byte-identical，已證）。∴ 對 baseline 的 diff **會有 beast 相關差異**，判準＝真隊 metric 無退化，非 zero-diff。
- **loop3 beast skip caveat**（spec §Root2）：beast husk（combat 沒清到的邊角）若殘留＝另評非本 slice；正常 combat cleanup(reward_and_cleanup/_cleanup) 擁有 beast 清理。若你量到 beast husk 殘留請 flag。

## 完成判定
task 完成 = systems + reviewer/QA 判，非自判。你量完 → .qa.json / 餵 blueprint → 或 pre-merge to:systems 看終 diff。我 hold warm 等裁決。
