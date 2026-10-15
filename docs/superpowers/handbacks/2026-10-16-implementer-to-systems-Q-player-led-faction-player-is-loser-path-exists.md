---
from: implementer
to: systems
status: open
slice: 你領導的勢力不自動定目標＋收編要告訴你（spec 2026-10-15-player-led-faction-no-ai-goals-and-subjugate-tells-HOW）
topic: 前提不符一條：「玩家當敗方被 _try_subjugate」的路徑存在（三個投降動作）｜不擋主體，我照預設往下做；請裁兩件小事
---

# 前提不符

spec §事實「收編」末條與 §範圍外末條寫：**沒有找到敗方是玩家的路徑 ⇒ 本票不寫那一句**。

實際（worktree `.worktrees/plf`，base origin/main de6f25ca4）有三條，全是玩家投降被接受：

| 位置 | 動作 | 呼叫 |
|---|---|---|
| `scripts/simulation/player_command_system.gd:1472` | `_action_offer_surrender`（遭遇中向目標求降） | `_interaction.subjugate_team(state, target_id, pt_id)` |
| `scripts/simulation/player_command_system.gd:1492` | `_action_surrender_in_encounter`（戰中投降） | `_interaction.subjugate_team(state, enemy_id6, pt_id)` |
| `scripts/simulation/player_command_system.gd:1523` | `_action_surrender_pre_encounter`（預備遭遇時投降） | `_interaction.subjugate_team(state, atk_id, pt_id)` |

三條都走 InteractionSystem.subjugate_team → NpcCombatSystem.subjugate_team → `_try_subjugate(winner=NPC, loser=玩家, false)`。
spec 搜的是「`_try_subjugate` 的 NPC 呼叫點」，沒搜「玩家指令呼 subjugate_team 時玩家在第三參數」。

# 對本票的影響

1. **改法 6b 之後**：params 加 `loser_team` ⇒ subjects＝[勝方, 玩家隊] ⇒ 這則**會進玩家佇列**，而 `ADVANCE_STOP_KINDS` 加了 subjugate ⇒ **推進會停在它**。
   照 spec 的 describe 分支，玩家不是勝方 ⇒ 走旁觀句「Team{玩家} 臣服於 Team{winner}，加入勢力{f}」——玩家讀到自己被叫成第三人稱。
2. **同一個「列≠做」病也在這三條上**：`_try_subjugate` 的門（敗方已有勢力、勝方無統領 ⇒ 靜默 return）對玩家敗方一樣生效，而三條都回「投降被接受，已被收編」。

# 我的預設（不等回信，照做；你裁不同我再改）

- **(甲) describe 多一支**：敗方是玩家隊 ⇒「你臣服於 Team{winner}，加入勢力{f}」（停點照 spec 規則：subjects 含玩家 ⇒ 停）。理由：句子現在一定會進玩家佇列，不寫這支等於主動產出一句錯人稱的句子。
- **(乙) 三條投降的「列≠做」不在本票修**，只登 known_issues（修法同 6a 的做後驗：`_try_subjugate` 後驗玩家 faction_id 是否已等於勝方勢力）。理由：spec 改法 6a 的範圍是 `_action_subjugate_enemy`；三條投降動作的選單／precheck 不在本票盤點內。若你要併本票，回一句即可，改法照抄 6a 的驗結果那一層。

其餘（改法 1–5、6a、6c、7、8）不受影響，照 spec 做。
