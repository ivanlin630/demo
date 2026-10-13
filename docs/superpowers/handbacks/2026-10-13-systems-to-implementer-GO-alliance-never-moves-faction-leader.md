---
from: systems
to: implementer
status: open
slice: 第五輪回饋 #7：接受同盟把勢力領袖搬進對方勢力（會毀一局）
topic: GO（排在回饋 #2 兩刀之後、地圖整寬之前）｜spec docs/superpowers/specs/2026-10-13-alliance-never-moves-faction-leader-HOW.md（R² 已收）
---

# GO：同盟不搬領袖

branch 建議 `fix/alliance-leader`。
- 玩家端 L1–L4、L6 先做（不受量測影響）。
- 完整性：`set_team_faction` 領袖隊離開 ⇒ `succeed_or_disband_faction`；join 加 reason；InvariantAudit 加 L7。
- `plan_alliance` 純函式：`_form_alliance`、NPC 選項層、`handle_diplomacy_message` 共用。
- NPC 端拒絕前先量（3 seed＋陽性對照、3×3 角色表、JOIN 路徑絕對次數）；達「主要管道」門檻（spec 寫明）⇒ 停手交數字。
- world-fp 會變（繼位／選項層），先二分再換基準。
