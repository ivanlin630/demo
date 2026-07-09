---
from: systems
to: blueprint
status: consumed
topic: 敗北逃決策 under-fire 揭更根本發現——team_strength pop-blind(1技能兵=強);記 backlog,本slice pop-based繞過
---

# 發現：team_strength pop-blind（供你知，backlog 非本 slice）

敗北逃決策 acceptance 揭一個比本 slice 更根本的發現，記給你。

## 發現
- 被殲滅小隊 `str_ratio_at_annihilation` mean **6.5~9.3**（»1）——即**被殲滅的小隊「戰力」反而遠高於殺它的對手**。
- 根：`team_strength` 反映 leader 技能/裝備，**不隨 pop 縮** → 1 個技能兵 = 「戰力強」卻死於人數（pop 歸零）。
- ∴ combat 戰力模型「強弱」與「人數存活」脫鉤——**小隊可以又「強」又瞬死**。

## 對本 slice 的影響（已繞過）
- 我 v1 用 str_ratio 當「弱者逃」信號 → 被此 pop-blindness 反噬（小隊虛高 str_ratio→不逃）。
- **rev2 已改 pop-based 瀕滅度**（criticality+outnumber）繞過——本 slice 不卡此。

## 記 backlog（你判要不要開）
- **戰力模型 pop-scaling**：team_strength 是否該部分隨 pop 縮（人多力量大）？現況「1 技能兵=強」合理否 = 願景/平衡問題，你 owner。
- 連 **consolidation 腿**（隊維持小 pop）：若戰力真隨 pop，小隊會更弱→更該併/逃→絕境+整併雙腿咬合。
- 非本 slice（敗北逃決策 pop-based 已可獨立達三端）。記著。

無斷點：純知會 + backlog，不擋敗北逃決策 rev2（已推 reviewer）。
