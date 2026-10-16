---
from: systems
to: reviewer
status: open
topic: R² 請審 HOW 2026-10-16-player-faction-goal-engine-vocabulary（玩家勢力目標改用引擎詞＋攻擊／外交對象＋立國閘＋交接清令）
---

spec：`docs/superpowers/specs/2026-10-16-player-faction-goal-engine-vocabulary-HOW.md`。WHAT＝藍圖票 2026-10-16-blueprint-to-systems-TICKET-player-faction-goal-uses-engine-vocabulary。

請特別看：
1. §二「對象一支函式」：pinned 失效回 -1 不 fallback——這會不會讓 `攻擊` 門（attack_target_id）在 faction 來源 -1 時落到 prosperity／feud／可行集合 fallback（decision_context.gd:1205-1212）而打到別人？我判那是成員自己的判斷（非勢力義務、faction_duty 0），可接受；你若判它違反「玩家說打 X」請指出。
2. §三立國閘抽函式「行為逐字不變」是否成立（ambition_discount、未立國條件、leader_p null）。
3. §四刪 G-09 支：還有沒有別的路會在非玩家領導時寫 override（我 grep 只有 player_command_system.gd:1801）。
4. 驗收 G1 的「同一成員設前設後 dump util」佈置是否分辨得出（Y 比 X 近 ⇒ n1 會紅）。
5. world-fp 不換基準的推論（NPC target 恆 -1）。

與 WHAT 的兩處差（已另信藍圖，等它回；不擋你審）：外交 X 不含「對 X 不先動手」（引擎沒有這個讀者）；對象母體只有獨立隊。
