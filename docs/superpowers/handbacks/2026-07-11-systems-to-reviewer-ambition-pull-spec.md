---
from: systems
to: reviewer
status: consumed
topic: [R② 框內+反補丁lens] 強方擴張 pull spec——補雙向另一向;驗「非冗餘求解器」(不同發起者)
---

# 對抗② 審：強方擴張 pull（§HOW-7）

spec `specs/2026-07-10-consolidation-s-a-technical.md §HOW-7`（blueprint 批，補 design 雙向願景的強方向）。R①免（前提 file:line 坐實）。**R② 審設計健全 + 過你剛拿的框架內冗餘 lens（dogfood anti-patch mandate）。**

## ★關鍵：過「框架內冗餘求解器」lens（02_reviewer 新維）
「吸納」(強發起) vs 「併入」(弱發起)——**是不是冗餘求解器**（join/整併型）？systems 主張**非冗餘**，請你驗：
- **不同發起者**：吸納=強隊主動吸弱鄰（野心/擴張驅）；併入=弱隊求收留（求生驅）。
- **不同 applicable 域**：吸納=強隊有統領餘裕+野心+弱鄰、**非 survival**；併入=弱隊絕境 food<3、survival-class。
- **不同 priority**：吸納 @PRIO_DISPATCH（競攻擊/佔村）；併入 @PRIO_SURVIVAL。
- **共用的只是 resolve primitive**（分流/loyalty/merge_teams）=共享 plumbing 非冗餘 solver。
- = 雙向設計的兩向（design §合併=雙向），非「兩 option 做同一件事」。**若你判仍冗餘→refute 我，該收斂。**

## 其他 refute 靶
1. **公平競秤無硬保**：absorb_drive=野心×餘裕×target，跟攻擊/佔村同層競，**無 rank 硬優勢**（防 flat 病）？spec 有守？
2. **弱鄰 finder**：adapt `_find_weakest_prey:3155` capacity-bounded——會不會跟攻擊 target 撞（同 prey 又吸又打）？語意分得開？
3. **擴張-class 非 survival**：確認吸納**不入 SURVIVAL_OPTION_SET**、@PRIO_DISPATCH（別 collapse survival=避絕境死結關鍵）。
4. **S-A/S-B 切分**：S-A 只「強發起+弱自願接受」、脅迫留 S-B——spec 有無偷渡 coercion？
5. **防 mega-blob / 忠誠 init（弱鄰帶怨）** spec 有守？

verdict to:systems。CLEAN → dispatch implementer（疊 worktree）。
