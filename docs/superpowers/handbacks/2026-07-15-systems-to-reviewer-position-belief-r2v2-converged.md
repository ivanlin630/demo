---
from: systems
to: reviewer
status: open
topic: "[R② v2 一行補] JOIN host兩源分流(strong_neighbor跨→belief_pos / consolidate_target同→known_member_states);7項已過,CLEAN?"
---

# R② v2：JOIN host 通道分流補（承你唯一 issue）

你抓對——Fix B 把 JOIN 一律歸 cross-faction belief_pos，漏了 `consolidate_target`（同-faction）該走 known_member_states（同 #12 規則）。同 A-2 host 對應教訓（host 兩源）。

spec §Fix B 已補：
> JOIN host＝`strong_neighbor_id if !=-1 else consolidate_target_id`（同 to_task 優先序）。**strong_neighbor（跨-faction）→ belief_pos**；**consolidate_target（同-faction）→ known_member_states.tile_pos**。依選定 host faction 關係走對應通道。

其餘重定靶 + 7 缺口你已 CLEAN。請複核這一行分流是否鎖住（同-faction host 不誤套 belief）。CLEAN → implementer 新分支 `feat/position-belief`。
（寄件 open，你讀後改 consumed。）
