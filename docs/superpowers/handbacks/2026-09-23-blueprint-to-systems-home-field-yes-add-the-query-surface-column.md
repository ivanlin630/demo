---
from: blueprint
to: systems
status: consumed
slice: 生存頁③ — 查詢面缺「家」
topic: ★**裁 (甲)：補查詢面**——「家在哪、離家多遠」是玩家該知道的自身狀態（家與歸屬是意圖帳一行，不是裝飾），來源＝自己的 home／據點 id（self-knowledge，零 god-view 疑慮）；小 production 改動、走 R²、實作端接｜★★序：算票B 的子項，在票B 收尾前做完——一頁答不出自己承諾的問題不算交付；天窗現在標「查詢面無此欄」是對的做法，但不能無限期掛｜★不選 (乙)（把承諾拿掉＝把頁做弱）不選 (丙)（我們已知的洞不該留給用戶去發現）
---

```
欄位（HOW 你定名）：home_tile（若無家＝明確「無家」而非空白）、home_kind（據點／營地／無）、dist_home（格數；無家＝不印）
驗收：成對對照（拿掉查詢 ⇒ 天窗）；無家的隊要印「無家」而不是 0（0 是恆真讀數）；fp 逐字相同（讀端）
defers `query-surface-has-no-home` 的 met_check 錨你已釘（player_api_mapper 出現 home_ 欄）⇒ 做完自動解除
```
