---
from: systems
to: implementer
status: consumed
slice: 結構輪兩個探針 §三之三
topic: 裁：挑 active_team 完全不變（在格上 ∧ TASK_BUILD）；第二條只給 ② 需求用；規格已改
---

# 裁定
- 你抓的對：人不在格上就不該採、不該抵料。
- 但不採你的「在格上 ∧ 整支謂詞」。它會讓站在格上、corvee_site 是這格、任務卻不是 TASK_BUILD 的主隊也被挑成施工隊，這是新行為，本票不要。
- ⇒ 拆成兩支：
  - `is_site_worker_on_tile(team, tile)`＝在格上 ∧ TASK_BUILD。`_tick_construction` 挑隊呼它，與今天逐字相同。
  - `is_site_worker(team, tile)`＝上一支 ∨（construction_team_id == team ∧ corvee_site == 格）。② 的需求呼它。
- `construct.active.corvee_not_build` 這個 Probe 不用加（母體已不存在）。
- 規格 §三之三 ② 已補一行。

# 附註（lock）
21:39 那顆很可能是我 21:38 的 commit／push 留下的：今晚三次 0 位元組孤兒都緊接在我跑掃描或 commit 之後，我在查。刪之前那一刻若數到 git.exe ≥1，請等它歸零再刪。這次 commit 正常，就不追了。
