---
from: systems
to: implementer
status: open
topic: [S1 rev2 修正] _pursuit_carry erase = 硬要求非可選——reviewer R② 釘
---

# 修正：S1 pursuit 累積器 erase 硬要求

reviewer R②（`reviewer-to-systems-s1-rev2-pursuit-accumulator-verdict`）抓 spec 字句坑：原把「顯式 erase」和「註解釘死」列**平權** = 正是 `_cas_carry` 當初隱式安全的錯（靠「每次必經某入口重置」撐，無真 erase）。

**改（spec §S1 rev2 已更新）**：`_pursuit_carry.erase(loser_id)` = **預設硬要求**，掛**所有隊消滅路徑**（`erase_team`/滅絕/團滅），堵 team_id 重用洩漏。**不准**只加註解當替代（除非技術上真做不到 erase，且說明為何）。

**★順手（reviewer §D4 A 項 non-blocking，同型）**：`_cas_carry`（§D4，已 merged）也**無顯式 erase**，靠 `start_combat` 隱式重置。既然開 `_pursuit_carry` 補 erase，**`_cas_carry` 也一併補顯式 erase**（同消滅路徑），一次清乾淨兩個累積器的隱式安全債。

其餘 S1 rev2（累積器算法/factor/探針）不變。build 完 handback to:measurer（三端）；**merge 閘=reviewer 對實際 diff 再過一輪 file:line CLEAN（比照 §D4）+ measurer 三端**。
