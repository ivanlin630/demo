---
from: systems
to: implementer
status: consumed
topic: "[dispatch 繼承-lite(勢力領袖團死→最強成員接位)·spec=2026-08-20-faction-succession-lite-HOW.md(含 §5 R²delta 訂正)·R²=CLEAN+1 必查項(已定案、在下)·用戶 2026-08-15 裁定簡易版(爭位/內戰=王朝 arc 界外)·★T1 單一 owner:新增 WorldState.succeed_or_disband_faction(state?, faction_id, dead_leader_tid, also_dead:Dictionary={})——候選=f.member_team_ids 中【存活且非死者且不在 also_dead】、無候選→disband_faction(現行為)、有候選→選最強:統領(該隊 leader skills['統領']、無 leader 視 0)降序→平手 population 大→再平手 team_id 小(全序 determinism);f.leader_team_id=勝者;bookkeeping 只需清 known_member_states[死者](R² 親查 FactionData 全欄位:只有它是 team-id-keyed、其餘 goals/goal_drivers/intent/strategy/relations/directive_change_tick 皆 faction 層級屬性、不需搬動);print [Succession] 勢力%d 領袖團 %d 死→%d 接位·★★必查項(dispatch 前定案、三處接線時一併做、非事後補):候選存活判定【不能只信 teams.has(cid)】——erase_teams 批次迴圈期間 state.teams 仍完整持有全部 dead_list 隊(真 erase 在迴圈後)、member_team_ids.erase(tid) 只清當前那隊→領袖隊若在陣列順序先處理、同批死亡隊友此刻仍 teams.has()=true→會選出【這 tick 稍後就被同一次 erase_teams 清掉的死人繼任者】·修法零新結構:erase_teams 呼叫點傳自己已建好的 dead 集合(:287-292);faction_ai:3482 與 npc_combat:733 傳既有 state.teams_pending_erase(本 tick 已判死尚未 erase=正好要排除的集合)·★T2 觀測:Probe.bump('faction.succession')/('faction.disband_no_heir')·★三處改呼此函式(world_state.erase_teams:309-310 / faction_ai:3482-3483 / npc_combat:733-734)·TDD:①有成員→繼承 fire、faction 續存②無成員→仍 disband③tie-break 全序 determinism④★同一波死亡(領袖+隊友、領袖先處理)→繼任者不得是同批死者(選真正存活第三隊、無則 disband)⑤繼承後 _update_goals/_assign_tasks 不炸(R² 已驗:~50 處 leader_team_id 全即時讀、零快取殘留)·gate:繼承 fire+無成員仍 disband+繼承後運作+determinism 三跑+constitution 不回升+headless 0-new+fp intended-change·worktree feat/faction-succession-lite·完→handback to:systems·地基KEEP"
---

# dispatch 繼承-lite（勢力領袖團死→最強成員接位）

spec=`docs/superpowers/specs/2026-08-20-faction-succession-lite-HOW.md`（含 §5 R²delta 訂正）。R²=**CLEAN + 1 必查項**（已定案、在下）。用戶 2026-08-15 裁定簡易版（爭位/內戰=**王朝 arc 界外**）。

## ★T1 單一 owner
新增 `WorldState.succeed_or_disband_faction(faction_id, dead_leader_tid, also_dead: Dictionary = {})`：
- 候選=`f.member_team_ids` 中**存活 且 非死者 且 不在 `also_dead`**。
- **無候選 → `disband_faction`**（現行為）。
- **有候選 → 選最強**：`統領`（該隊 leader `skills["統領"]`、無 leader 視 0）**降序** → 平手 **population 大** → 再平手 **team_id 小**（全序 determinism）→ `f.leader_team_id = 勝者`。
- **bookkeeping 只需清 `known_member_states[死者]`**（R² 親查 `FactionData` 全欄位：**只有它是 team-id-keyed**；其餘 `goals`/`goal_drivers`/`intent`/`strategy`/`relations`/`directive_change_tick` 皆 faction 層級屬性、**不需搬動**）。
- `print("[Succession] 勢力%d 領袖團 %d 死 → %d 接位")`。

## ★★必查項（三處接線時**一併做**、非事後補）
候選存活判定**不能只信 `teams.has(cid)`**——`erase_teams` 批次迴圈期間 `state.teams` **仍完整持有全部 dead_list 隊**（真 erase 在迴圈後）、`member_team_ids.erase(tid)` 只清當前那隊 → **領袖隊若在陣列順序先處理**，同批死亡隊友此刻仍 `teams.has()==true` → 會選出**這 tick 稍後就被同一次 `erase_teams` 清掉的死人繼任者**。
**修法（零新結構）**：`erase_teams` 呼叫點傳**自己已建好的 `dead` 集合**（:287-292）；`faction_ai:3482` 與 `npc_combat:733` 傳**既有 `state.teams_pending_erase`**（本 tick 已判死、尚未 erase=**正好要排除的集合**）。

## ★T2 觀測
`Probe.bump("faction.succession")` / `("faction.disband_no_heir")`。
**三處改呼此函式**：`world_state.erase_teams:309-310` / `faction_ai:3482-3483` / `npc_combat:733-734`。

## TDD
①有成員→繼承 fire、faction 續存 ②無成員→仍 disband ③tie-break 全序 determinism **④★同一波死亡（領袖+隊友、領袖先處理）→ 繼任者不得是同批死者**（選真正存活的第三隊；無則 disband）⑤繼承後 `_update_goals`/`_assign_tasks` 不炸（R² 已驗：~50 處 `leader_team_id` 全即時讀、零快取殘留）。

## gate
繼承 fire + 無成員仍 disband + 繼承後運作 + determinism 三跑 + constitution 不回升 + headless 0-new + fp intended-change。

worktree `feat/faction-succession-lite`。完 → handback to:systems。地基 KEEP。
