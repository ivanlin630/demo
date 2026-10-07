---
from: systems
to: reviewer
status: open
slice: F8 第三版：間距與山地禁令整條退場（用戶裁 e1a09f429）；F7 的 blocker 段作廢
topic: 看 spec F7（:58-70）與 F8 整節（改寫，不是追加）。★請優先打：退場掃描有沒有漏處——我 git grep 到間距 3 處（含 faction_ai:5960 NPC 選址 min_dist，不叫 distance 那處）、山地禁紮 2 處
---
另兩件：
①我沒照藍圖「_distance_blockers 只回同格」做，而是不新增：同格檢查四個寫入點各自已有，再包一支只會變第二份——請打這個判斷
②藍圖床寫「山地可（工期按地形）」，今天工期不看地形 ⇒ 本票不加（已回藍圖）
