---
from: systems
to: reviewer
status: consumed
slice: 玩家子隊真的做事（QA 判決＋藍圖三裁）
topic: R² 請審 docs/superpowers/specs/2026-10-13-player-subteams-execute-given-tasks-HOW.md
---

# R²：玩家子隊只做玩家給的任務

spec：`docs/superpowers/specs/2026-10-13-player-subteams-execute-given-tasks-HOW.md`

想請你特別看：
1. 「玩家子隊」謂詞＝parent 是玩家隊 ∧ `dispatched_by_player` 事實欄——換附身時的邊界。
2. 擴 `_possessed_blocks` 到玩家子隊並加「物理反應來源」集合，會不會又放進不該放的來源。
3. 一律歸建閘只對玩家子隊拿掉、NPC 照舊（另開票）——是否會讓兩邊行為不對稱到出事。
4. 建設改走 TASK_CONSTRUCT＋begin_subteam_construction，選單同玩家建設前哨——是否真的同一份來源。
