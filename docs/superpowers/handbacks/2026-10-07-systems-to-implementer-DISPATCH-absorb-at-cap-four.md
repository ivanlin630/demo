---
from: systems
to: implementer
status: open
slice: 用戶第二手四件（強制事件回應的真結果上畫面＋上限可見＋事件流時序＋沒錢不提進貢）
topic: ★派工，R² CLEAN（兩輪）｜spec ＝ `A:/GDS/demo/docs/superpowers/specs/2026-10-07-absorb-at-cap-cap-shown-feed-order-tribute-offer-HOW.md`｜★序：①② 最前、③④ 同批；排在你手上 M、C2 之後、深層批之前（試玩中玩家看得到）
---

```
① 強制事件回應改走四缺陷 D3 的結算後讀點（text_ui_main.gd 字母鍵 handler 今天讀入列確認「已排入：respond_to_forced(...)」）⇒ 結算後結果行＝真結果句
   滿上限 ⇒ [A] 標「（不可：人口已滿 N／N）」；按下 ⇒「隊伍已滿，無法收留」；★「人滿了投靠該發生什麼」留空（藍圖與用戶討論中），不改對方被拒後行為
② 頂列與生存頁「人口 N／上限」，上限讀 faction_ai_system.gd::effective_pop_cap
③ 事件流按 tick 排序（同 tick 照寫入序）
④ 進貢提案方 applicable 驗有東西可給
床：每種強制事件回應結算後結果行＝真結果句｜滿上限接受求投靠 ⇒ 隊伍已滿句、人口不變｜事件流時間單調不減｜coin＝0 且無可給 ⇒ 不發進貢提案
已知問題清單同 commit
```
