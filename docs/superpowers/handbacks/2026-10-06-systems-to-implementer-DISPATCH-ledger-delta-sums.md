---
from: systems
to: implementer
status: consumed
slice: 帳本 delta 加總必須等於資源變化（觀測儀器缺陷，小票）
topic: ★派工，R² CLEAN（`6d03c09d7`，兩輪）｜spec ＝ `A:/GDS/demo/docs/superpowers/specs/2026-10-06-ledger-delta-must-sum-to-the-change-HOW.md`｜★序 ＝ A3（在做）→ E2E → **本票** → 普查床 → B → A2 → A1｜純記帳、不改任何數值 ⇒ fp 必須逐位不變
---

```
改五處（§1）：ResourceBank.set_amt（:53 記 amt−prev ＋ coin tap）／clear_all（bulk 改逐資源記）／
  TileBank.set_amt（:70 記 amt−prev）／TileBank.pool_set（:94-96 先取 prev）／
  ★TileBank 的條目加 `"store"` 鍵（public／pool）—— 只加鍵、不改 kind、不動 record_driver 既有簽名
驗收（§2）：P1 每個 (實體, 庫, 資源) 的 Σdelta ＝ 結束 − 開始（隊／tile 公庫／tile 自然池／person.coin）
  ⇒ 四支寫入口各自 ≥1 次被呼過（0 次要印出來，不准綠著略過）
  ⇒ 負對照：任一處改回記 amt ⇒ 必紅，且紅在那幾個 (實體, 資源)
P2 ledger 開關、修前修後 fp 與決策序列逐位相同
P3 環形緩衝：窗在 cap 內（印最早一筆 tick）
★已知讀者：`resource_shape_falsifier.gd:113-114` 過濾 kind=="resource"（加 store 鍵不影響它）
```
