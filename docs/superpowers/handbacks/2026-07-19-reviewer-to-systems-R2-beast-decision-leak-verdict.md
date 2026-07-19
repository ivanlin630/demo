---
from: reviewer
to: systems
status: consumed
topic: "[R² verdict·beast-decision-leak+id-collision spec] CLEAN → 可 dispatch implementer。兩 root 前提全 file:line 坐實(@35e9ee8f),5 審點過。附 1 非阻塞 watch-note(husk 殘留,已被 spec measure line43 涵蓋)。"
---

# R² verdict：野獸洩進決策迴圈 + id 碰撞 spec

**VERDICT: CLEAN** — 可 push main 35e9ee8f + dispatch implementer。`premise_contradiction: false`。

spec factcheck 對 base `35e9ee8f`（= 現 main HEAD 前身，crisis-override merge commit）。

## Root 前提坐實（factcheck，file:line）

- **Root 1 id 碰撞 = 真**：`beast_system.gd:16` `var _next_beast_id: int = -1000000`（instance var）+ `:22-23` `t.team_id = _next_beast_id; _next_beast_id -= 1`。全 4 spawn site 每次 `BeastSystem.new()` fresh 實例（`ambush_system.gd:57`/`encounter_system.gd:1232`/`faction_ai_system.gd:3328`/`player_command_system.gd:177`）→ instance var 每次重置 -1000000 → 每 beast 拿 `-1000000`。`world_state.gd:256` `teams[team.team_id] = team` 靜默覆寫。**碰撞根坐實**。（spec 引 faction_ai:3314 實 :3328，行號小漂非實質。）
- **Root 2 決策洩漏 = 真**：loop2 `elif team.faction_id == -1:`（beast faction_id=-1，`beast_system` set_team_faction -1）→ `_evaluate_independent_strategy`+`_evaluate_solo`+`_evaluate_independent_infrastructure`，無 beast guard。loop3 `:773 if team.leader_id == -1: EventSystem.new().on_leader_death` + `:777 AmbitionLadder.update`。**洩漏根坐實**。

## R² 審點（5 + 附加）

1. **id 碰撞真解 + per-seed 決定 → CLEAN**。counter 移 `WorldState.next_beast_id`（per-world fresh init）→ 唯一遞減 id + 同 seed 重跑計數器重置 = per-seed 決定性。**禁 static 判斷正確**：static 跨 sim run 同 process 不 reset → 多-run bed id 累積跨 run = 非決定（違 determinism 鐵律 + [[feedback_observer_no_global_rng]] 同族「跨 run 殘態」）。**無漏看別的 id 生成路**：encounter/ambush `team_id =` grep 空，`build_beast_team` 是唯一 beast-id 源。

2. **beast skip 無誤傷生命週期 → CLEAN**。beast spawn/combat/reward/cleanup 全在 encounter/npc_combat/beast_system，不經 evaluate_all 決策。全 5 combat exit 皆 `_cleanup`/`reward_and_cleanup`→erase（`npc_combat_system.gd:330-335` 結算三分支、`:491-492` retreat/pursue）。beast 是被動戰鬥 prop（`try_hunt_predator` 是**隊獵獸**非獸行動），移出決策秤不斷任何 beast 功能。

3. **loop3 skip 位置（`continue` 放頂）→ CLEAN，且為正確歸屬**。beast 死亡→erase 由 combat `_cleanup`（immediate `erase_team`）擁有，**非** loop3 generic `_on_team_extinct`（後者走 `teams_pending_erase` 延遲路）。beast 走 `_on_team_extinct` 反而**污染** extinct.* 死因探針（`:2314-2316` bump extinct.starve/combat 會把 beast 死計入真隊死因統計）。∴ loop3-top skip = 把 beast 排除出**不屬於它**的 generic extinct 路，是正確所有權切割非清理漏洞。beast 於 pop<=0 mid-tick pre-resolution 殘於 teams 的 husk 邊角**不可達**（casualty→resolution→cleanup 同一 npc_combat call 內完成，beast 不跨 tick 停在 pop<=0）。spec line32「另評」= 合理安全網。

4. **非 ambition-preempt 補丁 → CLEAN（de-patch）**。修 = 把 non-agent（野獸）**移出**決策迴圈（loop2/loop3 頂 skip），非在症狀（ambition@10 沒被 preempt）疊補償閘。教科書 de-patch，守決策模型「引擎=唯一的秤、非-agent 無腦不經秤」。合 `00_roles §診斷通則補丁閘優先查` + [[feedback_no_patch_on_settled_architecture]]。root（野獸不該有 task/ambition）非症狀（ambition preemption tuning），判斷正確。

5. **determinism 2-run byte-identical → CLEAN**。WorldState per-world fresh counter，無殘 static/global 狀態，同 seed 兩跑 id 序列一致。

- **附加·beast_kind discriminator 純淨性 → CLEAN**。`beast_kind` default `""`（`team_data.gd:87`），唯 `build_beast_team` 設非空（grep `beast_kind =` 除 beast_system 空）→ `beast_kind != ""` 窮盡且互斥（true ⟺ beast）。無非-beast 誤 skip、無 beast 漏 skip。

## 1 非阻塞 watch-note（measurer；已被 spec 涵蓋）

- **husk 殘留驗**：loop3-top skip 後理論上 beast 不經 `_on_team_extinct`。極端邊角（combat 沒清到的 beast husk）若存在會殘於 teams。**spec measure 驗收 line43「真隊 belief 不再含 -1000000 幻影條目」已涵蓋此**——measurer 順帶確認 seed1337/42/4201 跑後 `state.teams` 無 `beast_kind != "" && population<=0` 殘團即可。非 merge blocker。

CLEAN → 你 push main + dispatch implementer worktree（[[feedback_worktree_stale_base]]：先 push origin 避 stale-base revert）。TDD 驗收（3 beast 3 id / beast 不進決策 / 既有 beast combat 測續綠 headless_test:2202/2231/2262/2401）設計合理。
