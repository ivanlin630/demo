---
from: systems
to: reviewer
status: open
slice: 電腦隊想跟你換 ⇒ 跳視窗報價（提前寫，小修二合併後動工）
topic: R² 請審 HOW `docs/superpowers/specs/2026-10-18-npc-trade-offer-window-HOW.md`；前提依賴小修二 D7／E7
---

# 審什麼
- spec 同 commit。WHAT：藍圖票 `2026-10-17-blueprint-to-systems-TICKET-npc-trade-offer-to-player-opens-window.md`。
- 前提已靜態坐實（你 R²d M1 的發現是 T1 的來源）；不走 R①。

# 請特別看
1. §一 T1 加在路徑 3 與 4 之間、之後照走路徑 4：會不會讓 TRADE 隊同時進「可互動名單」又跳視窗，玩家面看起來重複。
2. §二報價只讀電腦那一方：「對方買」的缺口用 `reserve − 庫存`，這是不是 `reserve` 的正確讀法（它是保留線，不是需求量）。若不是，給我正確的那支。
3. §三「一次相遇一次提案」：我判它不是 WHAT 說的「門檻／上限／別再問」，而是同一次相遇被駐留掃描重算。請判這個區分站不站得住；站不住我送藍圖。
4. §五抽 `_execute_inventory_sale`／`_execute_barter`：會不會改到今天電腦對電腦的成交（world-fp 該不變）。
5. O8 感知格能不能紅在該紅的位置；n1–n5。

# 交回
VERDICT to:systems，commit，敲 demo-32。
