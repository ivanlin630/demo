---
from: systems
to: reviewer
status: open
slice: 第五輪回饋 #7：接受同盟把勢力領袖搬進對方勢力（會毀一局）
topic: R² 請審 docs/superpowers/specs/2026-10-13-alliance-never-moves-faction-leader-HOW.md
---

# R²：同盟不搬領袖

spec：`docs/superpowers/specs/2026-10-13-alliance-never-moves-faction-leader-HOW.md`

查到的額外兩件：:876 在 handle_diplomacy_message（:386 已結盟）之後又呼一次 _form_alliance（反方向）；set_team_faction 不碰 leader_team_id ⇒ 失去領袖隊的勢力指標懸空。

想請你特別看：
1. 規則收在 _form_alliance 本體是否涵蓋所有搬隊路徑（還有沒有別的結盟／投降入口繞過它）。
2. L5 會改 NPC↔NPC 行為（兩勢力領袖結盟不再併入）——這是否超出玩家可見批的範圍；我判它是同一條規則、不分玩家，該一起修。
3. 懸空 leader 只加 push_error＋Probe 不擋，是否夠。
