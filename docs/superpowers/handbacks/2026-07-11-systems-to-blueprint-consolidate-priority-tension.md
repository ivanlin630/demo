---
from: systems
to: blueprint
status: consumed
topic: [語意 flag] 食壓驅併 vs survival-sticky 互斥（29/53 set_fail）——consolidate=絕境併 or 預防性併?
---

# flag blueprint：consolidate priority 張力（WHAT 語意）

TASK_MERGE 到達硬牆（pair_seen=0）真根 = movement 靜態快照追不上移動 absorber → 我已發實作修（A 到達重追蹤 `merge-arrival-retrack`，systems seam，治 24 set_ok 的到達）。**但漏斗另揭一個 WHAT 語意張力，非我單方能定：**

## 張力（漏斗 29/53 set_fail）
- S-A `consolidate_drive` 食壓 scaled（HOW-1）= **只餓才驅併**。
- 但**餓也觸 survival-sticky**（`PRIO_SURVIVAL` > `PRIO_DISPATCH`）→ `try_set(TASK_MERGE, PRIO_DISPATCH)` 被擋（29/53 fail）。
- ∴ **食壓驅併與絕境 survival 結構互斥**：想併的時機（餓）正是被 survival latch 鎖住的時機 → consolidate 天生半癱。

## WHAT 問題（你裁）
consolidate 的語意是哪種？
- **(a) 絕境併**：真的快死才併（現狀，但被 survival-sticky 擋→幾乎併不成）。
- **(b) 預防性併**：中度食壓（未到 survival latch 前）就併＝「看苗頭不對先抱團」。這語意上更像有機政體（勢力在壓力下聚合，非死到臨頭才併）。
- 若 (b)：HOW 上讓 consolidate 在中度食壓窗口 fire（食壓 term 曲線前移／或 priority 讓 consolidate 不被 survival 全 pre-empt）——我可實作，但**語意方向你定**。

## 現況/序
- A（到達重追蹤）先修，治已 dispatch（24 set_ok）的到達 → 先看 merge_accept 能否 >0。
- 這 C（priority 張力）是**放大 dispatch 量**的第二層（讓更多想併的隊真能 dispatch）——A 若已交付 accept>0（有機政體核心可見），C 可後續調；A 若不夠（24 太少），C 變必要。
- **待你**：consolidate = 絕境併(a) 還是 預防性併(b)？定了我才知要不要 + 怎麼鬆 priority/食壓窗。非急（A 先），但影響 S-A 最終形。

measurer 驗 A 後（pair_seen>0 + merge_accept）數字到齊，連這 C 一起判。
