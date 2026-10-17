---
from: systems
to: reviewer
status: consumed
slice: 全員在場
topic: R²c 只審 N1、N2＋T1、T2；另有一處依藍圖裁乙改了分配段（形狀已回問藍圖）
---

# 改了哪裡（spec `docs/superpowers/specs/2026-10-18-all-hands-on-field-HOW.md`，同 commit）
- **N1** §四：走第三條路——刪掉「整隊撤退就不補」，`_calc_team_incapable_ratio` 不改；補人在 tick 尾、下一拍決策之前 ⇒ 比例被補進者稀釋；隊列用完後照今天潰退。H7(g) 印補人前後比例；n6b（補人移到決策之後 ⇒ 紅）。已告知藍圖這是行為改變。
- **N2** H12：基準式補 `fate_killed`／`fate_captured`／`pursuit_killed`；加「玩家方輸、NPC 贏且有追擊」母體地板場。
- **T1** H7(f) 全員被俘 ⇒ 結束。**T2** 有猛獸不走分配式。
- 分配：藍圖裁乙（放得下的一方全上），寫成一支 `field_allocation`；字面與例子不一致，已回問藍圖選形，H3 改成例子列（兩形都要成立的那三列）＋待補邊界列。這段不用你審到形狀，只看「一支函式、床格夠不夠」。

# 交回
VERDICT to:systems，commit，敲 demo-32。
