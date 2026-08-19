---
from: systems
to: reviewer
status: open
topic: "[R² delta 審 繼承-lite(勢力領袖團死→最強成員接位)·spec=2026-08-20-faction-succession-lite-HOW.md·用戶 2026-08-15 裁定的簡易版(考古 batch1 開放問題②:暫行斬首解散→簡易繼承先行、爭位=王朝 arc 疊加)·R①免(前提=結構事實窮盡:disband 三觸發點 world_state.erase_teams:305-310 主 chokepoint/faction_ai:3482-3483/npc_combat:733-734;leader_team_id 賦值只有 world_state:122 create_faction+game_setup:396、無任何 reassign 路=零繼承坐實)·★審點:①單一 owner 收斂(三處各自 disband→收成 WorldState.succeed_or_disband_faction)是延伸統一還是我把三個【語境不同】的死亡路徑硬塞同一函式?(erase_teams=通用消滅 chokepoint、faction_ai:3482=?、npc_combat:733=戰死;三者呼叫時機/已完成的清理狀態可能不同、合併會不會有前提差)②繼承後 bookkeeping 夠不夠:我只寫『清 known_member_states[死者]+保留 goals/directive』——還有什麼跟著 leader_team 走的狀態沒處理?(例如 f.goal_drivers 綁舊領袖團 id?外交關係/協議綁團?directive_change_tick?)請你 grep FactionData 全欄位幫我補③tie-break 全序夠不夠(統領降序→pop→team_id 升序)=determinism 無 RNG④【最強=統領】這個選法會不會有隱性 god-view(讀別團 leader 的 skills=自家勢力成員、我判 self-knowledge 合法、你判)⑤繼承 fire 後勢力續運作:_update_goals/_assign_tasks 對『換了 leader_team 的 faction』有沒有隱含假設(例如快取綁舊 id、或某處假設 leader_team 從不變)·gate:繼承 fire+無成員仍 disband+繼承後運作+determinism+12mo 大考宏觀興衰觀察·CLEAN→我 dispatch·地基KEEP"
---
# R² delta 審：繼承-lite（勢力領袖團死→最強成員接位）
spec=`docs/superpowers/specs/2026-08-20-faction-succession-lite-HOW.md`。用戶 2026-08-15 裁定簡易版。R① 免（前提=結構事實窮盡）。
## ★審點
1. **單一 owner 收斂**：三處各自 disband → 收成 `WorldState.succeed_or_disband_faction` **是延伸統一、還是我把三個語境不同的死亡路徑硬塞同一函式**？（`erase_teams`=通用消滅 chokepoint／`faction_ai:3482`=?／`npc_combat:733`=戰死；三者**呼叫時機/已完成的清理狀態可能不同**、合併會不會有前提差？）
2. **繼承後 bookkeeping 夠不夠**：我只寫「清 `known_member_states[死者]` + 保留 goals/directive」——**還有什麼跟著 leader_team 走的狀態沒處理**？（`f.goal_drivers` 綁舊領袖團 id？外交關係/協議綁團？`directive_change_tick`？）**請你 grep `FactionData` 全欄位幫我補**。
3. **tie-break 全序夠不夠**（統領降序→pop→team_id 升序）=determinism 無 RNG。
4. **「最強=統領」選法有無隱性 god-view**（讀別團 leader 的 `skills`=自家勢力成員；**我判 self-knowledge 合法**、你判）。
5. **繼承 fire 後勢力續運作**：`_update_goals`/`_assign_tasks` 對「換了 leader_team 的 faction」有沒有**隱含假設**（快取綁舊 id、或某處假設 leader_team 從不變）？
gate：繼承 fire + 無成員仍 disband + 繼承後運作 + determinism + 12mo 大考宏觀興衰觀察。CLEAN → 我 dispatch。地基 KEEP。
