---
from: systems
to: reviewer
status: consumed
topic: [R② 框內+冗餘lens] 名聲磁鐵 slice spec——新protector_rep軸(β)+事件喂+決策讀;驗二軸語意分
---

# 對抗② 審：名聲磁鐵 slice（`specs/2026-07-11-reputation-magnet-slice.md`）

blueprint 裁 β 分軸 + 分階段（閉環 3+2，gossip defer）。R①免（前提 file:line 坐實=characterize 表）。**R② 審設計 + 框架內冗餘 lens（β 的核心=兩軸語意須真分）。**

## 改什麼
新 `protector_rep`（道德/保護名聲，per-observer）+ 道德事件（protect/gratitude→漲、feud/killed→跌）喂 + `join_drive` × 名聲加成 + 投靠 finder 偏好高名聲。繞征服死結（弱隊自願投奔名聲好保護傘）。

## ★冗餘 lens（重點，β 的理由）
`protector_rep` vs 既有 `known_reputations`——**是不是換皮冗餘**？systems 主張非冗餘，請驗：
- `known_reputations` = **情報信任**（intel 準不準 `belief:209` + diplomatic 行為）——「這隊給的情報可不可信」。
- `protector_rep` = **道德/保護名聲**——「這隊值不值得託付/投奔」。
- 不同語意（好情報源≠好保護者）、不同更新源（intel-accuracy/diplomacy vs protect/gratitude/betray 道德事件）、不同讀者（belief/diplomatic vs join_drive 歸附）。**若你判仍冗餘→refute，該共用一軸。**

## refute 靶
1. **二軸語意真分**（上）？還是 protector_rep 該併 known_reputations（省欄）？
2. **subject→team 映射**：relation_edges 在 person、protector_rep 在 team——spec 標「build 時確認 subject 型別」，這 punt 給 implementer 合理，還是 spec 該先定死？
3. **join_drive × (1+rep×W) 乘法加成**：會不會高名聲 host 讓投靠氾濫（每個弱隊都投奔同一仁君=mega-blob）？防過度守在哪？
4. **FLEE vs 投靠 可達性**：spec 標「投靠/FLEE 可能不同 rank 集，build 確認可達」——這是真風險還是 spec 該先解？（磁鐵靠投靠 util 升過 FLEE，若兩者不同競秤場則升了也沒用）。
5. **不動征服平衡**：名聲只加成投靠，不碰攻擊/征服 util——spec 有守？
6. judge 盤點：複用 relation_edges/known_reputations 結構，無新平行物？

verdict to:systems。CLEAN → dispatch implementer。
