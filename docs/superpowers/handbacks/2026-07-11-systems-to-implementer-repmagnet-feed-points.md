---
from: systems
to: implementer
status: open
topic: [§2 裁定] 選項3=呼叫端就地喂(映射歧義在呼叫端消失,team直接在手);確切2喂點
---

# 裁：§2 喂 protector_rep = 呼叫端就地喂（選項 3，我複核精修）

你卡對了（映射歧義真存在，別猜=對）。**但歧義只在 `_write_relation_edge` 內部**（它收 `subject_id: int` 無法判 person/team）——**呼叫端手上直接有 TeamData**（`winner`/`loser`/`escort` 都是 team object），不需 person→team resolve、不需 thread state。∴ **選項 3（呼叫端就地喂）正確**，且比你想的更乾淨（連 `state.persons[x].team_id` 都不用）。

## 確切 2 喂點（npc_combat，核心戰場保護信號，team 直接在手）
**1. `looted`（`npc_combat:~342` loot 記憶迴圈附近）→ 敗方對勝方 protector_rep 跌**（勝方是掠奪者=壞保護者）：
```gdscript
# 在 loot 記憶 for 迴圈後（team-level 喂一次，非 per-member）：
var loot_sev: float = 1.5 if maxi(loser.population - loser.wounded, 0) <= 1 else 1.0  # massacre 級跌更兇（對齊既有 sev_key）
loser.update_protector_rep(winner.team_id, -REP_LOSS * loot_sev)
```
**2. `aided_in_battle`（`npc_combat:~357` escort 迴圈內）→ 勝方對 escort protector_rep 漲**（escort 護我=好保護者，★核心磁鐵信號）：
```gdscript
# 在 escort 迴圈內（每個 aided escort 喂一次）：
winner.update_protector_rep(escort.team_id, REP_GAIN * 0.5)   # intensity 對齊既有 aided write_memory 0.5
```
- 常數：`REP_GAIN(~0.1)`/`REP_LOSS(~0.15)`（跌快於漲）——你照工單值先寫。
- **不碰 `_write_relation_edge`/`write_memory`**（那裡 subject-ambiguous 無 state；喂點移呼叫端解決）。
- **不喂 team-subject 事件**（begged_at_me/special_taxed——那些 `_write_relation_edge` 根本無 match case、不建 edge、與保護語意邊際；先跳過）。

## 為何這 2 點夠測磁鐵
protector_rep = 「值得投奔的保護傘」——**戰場被護(aided=+)/被劫(looted=-)是最強最清的保護信號**。這 2 點讓 protector_rep 脫離 0.5 有意義波動（護我的隊漲、劫我的隊跌）→ §3 磁鐵讀得到差。**足夠測「磁鐵動不動」**。若 measurer 見 protector_rep 太平（波動不足）→ 回報，再加 master/kindness 等次要源（次階段）。

## 續
- §1 field 已上 ✓、§3 決策讀照工單做（join_drive 磁鐵/finder/context）。
- §2 照上 2 喂點做 → 三段齊 → handback to:measurer 測磁鐵。
- 卡再 to:systems。**（你這次流程走對了——卡點標回 systems 非猜非問 user，讚。）**
