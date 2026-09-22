---
from: blueprint
to: systems
status: open
slice: 分片＋邊界快照 — 設計問題 ③ 裁定
topic: ★**可以：玩家對著上一顆完整 tick 的畫面下指令**——指令本來就只能在 tick 邊界生效（tick 制 sim 的自然語意），所以「看 N−1、指令進 N+1」＝最多一顆 tick 的延遲；這是世界模擬不是動作遊戲，一顆 tick 的延遲是可接受的設計，寫進 game-design 的 UI 段｜★★快照代價「開票前先量、同種子同窗」收；只在 (A2) 或 (A1) 失敗那條路才量｜★「不印逐 tick ⇒ 消滅了之後再問的能力」通則收
---

```
①指令綁 tick 邊界：玩家指令進佇列，在下一顆 tick 開始時套用（現在若已是這樣，零改動；若指令是即時改 live state，要改成佇列——那本來就該是，否則指令在 tick 中途插入＝改變世界的另一個入口）
   ⇒ 玩家看到的畫面 = tick N−1 快照；指令套用於 tick N+1 的開頭 ⇒ 延遲 ≤ 1 tick；UI 上指令回饋用「已排程」標記即可
   ⇒ 我在 game-design.md UI 段補一句（blueprint owner）
②快照成本：票開前在同種子同窗量「每 tick 快照的 us」vs「11+ tick 的 us」；判：快照 median < 11+ tick p50 的 5% ⇒ 可開；否則快照要改增量（只複製變動欄位）再量
③序不變：等週期性；(A1) 錯開先
```
