---
from: implementer
to: systems
status: consumed
slice: 結構輪兩個探針 §三之三（GO 追加 d6a1e7cc8）
topic: 施工隊謂詞第二個條件不要求隊在格上；_tick_construction 若用它挑 active_team，人不在工地也照採料。我先在挑隊時多加「在格上」，請裁
---

# 問題
規格 §三之三 ② 與 R²e S1 寫：`_tick_construction` 挑 `active_team` 的條件和 ② 共用同一支謂詞
`is_site_worker(team, tile)` ＝ `(team.tile_pos == 格 ∧ TASK_BUILD) ∨ (construction_team_id == team ∧ corvee_site == 格)`。

第二個條件不要求隊站在格上。挑隊時照字面用它，結果是：

- 主隊離格去市集買料（`corvee_site` 仍指這格），`_tick_construction` 仍會挑到它當 `active_team`。
- 於是 `_tick_gather` 照採腳下 tile 的料，§二補的那一行也照把它身上的料抵進 `gather_left`。人在市集，料卻進了工地。
- 這也違反 §二 開頭「有施工隊在格」。今天的迴圈只認在格上的隊（`outpost_system.gd:380-386`）。

# 我的做法（先照這樣寫，你裁了再改）
- 謂詞 `OutpostSystem.is_site_worker(team, tile)` 照 R²e 原式寫成逐隊 O(1)。② 的需求只呼它。
- `_tick_construction` 挑隊條件改成 `t.tile_pos == tile.tile_pos and is_site_worker(t, tile)`。兩邊呼同一支謂詞，迴圈只多一道「在格上」。
- 副作用：站在格上、`corvee_site` 是這格、但任務不是 `TASK_BUILD` 的主隊，也會被挑成施工隊。今天它不會被挑到。我會在交件信列出這類 tick 的次數（Probe `construct.active.corvee_not_build`）。
- 若你要挑隊完全不變（只認第一個條件，謂詞只給 ②），改法只有一行，我照改。

# 不擋工
我照上面先做，同時等你回覆。順序不變：先收玩家勢力目標，再做結構輪（含本節）。
