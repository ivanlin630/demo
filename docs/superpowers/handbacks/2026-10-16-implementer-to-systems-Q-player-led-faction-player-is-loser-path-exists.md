---
from: implementer
to: systems
status: consumed
slice: 你領導的勢力不自動定目標＋收編要告訴你（spec 2026-10-15-player-led-faction-no-ai-goals-and-subjugate-tells-HOW）
topic: 前提不符兩條：①「玩家當敗方被 _try_subjugate」的路徑存在（三個投降動作）②玩家設的勢力目標詞彙（expand/defend/trade_net）沒有任何讀者認得 ⇒ F1b「成員讀到它」照字面做不到｜不擋主體，我照預設往下做
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

# 前提不符 ②（2026-10-16 補）：玩家設的勢力目標，成員讀不到

spec F1b：「玩家設『防禦』⇒ goals＝["防禦"] 恆定 30 天、成員 faction_stakes 讀到它」；改法 1：「玩家設了目標 ⇒ 成員照那一個加權」。

事實：
- 玩家能設的值：`scripts/simulation/player_command_system.gd:54` `FACTION_GOALS = ["expand", "defend", "trade_net"]`（:55 標籤 擴張／防守／貿易網），`_action_set_faction_goal` 非這三個就拒（:1774）。
- 成員讀法：`scripts/simulation/decision/decision_context.gd:1134-1135` 只收 `DecisionOptions.options_in_set("stakes")` 裡、又在 `f.goals` 裡的詞；stakes 集合＝「攻擊」「徵收」「外交」（options.gd:397／436／463 三列）。
- `f.goals` 其他讀者也只認中文詞：faction_ai :729、:3509「攻擊」，:3462「立國」。
- ⇒ `player_goal_override` 被 append 進 goals 之後，**沒有任何一個讀者認得它**。今天就是這樣（不是本票造成的）：玩家設目標對成員零作用，只改面板上那一行字。

我的預設（照做，你裁不同再改）：
- 本票不動詞彙（要對到哪個 stakes、「防守／貿易網」對成員該是什麼加權，是 WHAT）。
- F1b 改成兩半：「goals＝[override] 恆定 30 天」照斷言；「成員 faction_stakes 讀到它」改印**現況**（預期＝空）並標「已知缺陷，見 known_issues」，不當綠格也不當紅格。
- known_issues 登一條「玩家勢力目標的詞彙沒有讀者」。
- 面板：玩家領導時改印「目標：無（等你下令）」或「目標：{標籤}（你設的）」照 spec；清除那一項的標籤「清除（跟隨 AI）」改「清除（不設目標）」——玩家領導後 AI 不再接手，舊標籤就是錯的。
