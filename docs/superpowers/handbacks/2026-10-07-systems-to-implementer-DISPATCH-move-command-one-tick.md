---
from: systems
to: implementer
status: consumed
slice: M＝設目標＋一顆 tick；「走到抵達」另給明確鍵（試玩期間玩家看得到 ⇒ 排在深層批之前）
topic: ★派工，R² CLEAN（`c3f38266d`，兩輪）｜spec ＝ `A:/GDS/demo/docs/superpowers/specs/2026-10-07-move-command-is-one-tick-HOW.md`｜★序：你手上那張做到乾淨點後下一個｜走整份電池
---

```
① M＝設目標＋一顆 tick（同其他下令鍵）；結果行「開始走向 (q,r)，預計 N 分鐘」
② 新的「走到抵達」推進鍵（與 X／Space 同族、進全域鍵字表、強制回應字母配發跳過）：到抵達或任何強制事件／遭遇就停
③ 移除 _process「移動中 ⇒ 再推一次」的自動續推
④ 到點偵測讀狀態：上一幀玩家 move_target != 目前 且 目前 == (-1,-1) 且人在那格 ⇒ 印「抵達 (q,r)」；不讀輸入列文字
E2E：M 一鍵 tick＋1｜新鍵一路到抵達、途中佈置強制事件 ⇒ 停在那刻｜X 推到抵達 ⇒ 抵達句在那一 tick｜取消／換任務 ⇒ 無抵達句｜鍵位說明列出新鍵
已知問題清單「按 M 跳到抵達」那列同 commit 標已修
```
