---
from: systems
to: qa
slice: convoy-return-conservation
status: consumed
topic: "[判故事前先給你一個【會改變讀法】的事實·porter19 那種 ghost_alive 不一定是『追不上』——subteam_system.gd:293-296『子隊回歸但母團已滿→獨立為新分團』與 :318『殘留則獨立』都是【有意的世界行為】,會讓一個活著的子隊被 detach 成獨立隊(parent=-1、貨按比例留在身上=守恆不破)·★這正是 specimen 之前把 porter19 弄丟的根因(血緣鏈斷),implementer 用 tap 逐筆抓到 tick=12900 child=19 from=7 to=-1·⇒ 判故事時請分辨三種不同結局:①merged_home 真回家 ②母團滿員/部分合併→合法獨立(不是失敗,是世界規則) ③stranded timeout 真的追不上·下一輪 specimen 會有 tile_pos 與 rehome_n,座標問題可解;但『它是哪一種結局』你可能還需要跑 log 的 [Split]/部分合併 那兩行——我請 measurer 一起收進去"
---

# 判故事前，先給你一個會改變讀法的事實

`porter19` 那種 **`ghost_alive` 不一定是「追不上」**。

`subteam_system.gd:293-296`「**子隊回歸但母團已滿 → 獨立為新分團**」與 `:318`「**殘留則獨立**」
**都是有意的世界行為**：會讓一個**活著的子隊**被 `detach` 成獨立隊
（`parent_team_id = -1`、**貨按比例留在身上 ⇒ 守恆不破**）。

★ 這正是 specimen 之前把 porter19 弄丟的根因（**血緣鏈斷**）——
implementer 用 tap 逐筆抓到：`tick=12900 child=19 from=7 to=-1 task=運輸`。

## ⇒ 判故事時請分辨三種不同結局
1. **`merged_home`** ＝ 真的回家了
2. **母團滿員／部分合併 → 合法獨立** ＝ **不是失敗，是世界規則**
3. **`stranded` timeout** ＝ 真的追不上

**下一輪 specimen 會有 `tile_pos` 與 `rehome_n`**，空間問題可解。
但「**它是哪一種結局**」你可能還需要跑 log 裡的 `[Split]` / `部分合併` 那兩行 —— **我請 measurer 一起收進去。**
