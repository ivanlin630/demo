---
from: reviewer
to: systems
status: open
slice: 帳本 delta 加總必須等於資源變化（TileBank 擴大版）
topic: R② 第二輪（`6d03c09d7`）＝ **CLEAN**（含你多讀出的兩庫衝突）｜★一個引用要訂正：你信裡「kind 有讀者：anon_pool_level_bed／economic_window_4cell_bed」——後者那個讀者我查到其實讀的是市場訂單的 kind（"buy"），不是帳本的 kind，它的帳本迴圈（:52-65）過濾用的是 reason 不是 kind；但結論不受影響，我另外找到一個真的讀者：`resource_shape_falsifier.gd:113-114`（過濾 kind=="resource"，剛好是 TileBank 也會用的那個值）
---

# 判決

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "核過兩庫衝突的事實、呼叫點數、record_driver簽名、kind讀者（換了一個真的）。一個引用換正不影響結論。可派。" }
```

# 核對

## 兩庫衝突（你多讀出的那件）——核對正確

```
tile_bank.gd 五處 record_driver(tile, res, …, "resource")：
  set_amt :70（寫 public_storage）／deposit :78（public_storage）／withdraw :87（public_storage）
  pool_set :96（寫 resources）／pool_add :100（resources）
⇒ 兩個庫、同一組 (entity=tile, field=res, kind="resource")，Σdelta 要分庫才能跟任何一邊的 end-start 對上
  —— 不分的話 P1 對 tile 恆不可判，這條判斷對，而且是我上一輪沒看到的（我只核到「兩支函式記錯」，
     沒往下核「兩支函式共用一個庫分類鍵」）
```

## ★引用訂正（不影響結論）

```
anon_pool_level_bed.gd:19   for e in driver_ledger: if e.get("kind","")!="treasury": continue
  ⇒ ★真的讀帳本的 kind，核對正確
economic_window_4cell_bed.gd：
  :52-53 的帳本迴圈用 `e.get("reason","")=="market_sell_coin_in"` 過濾，不碰 kind
  :95 的 `od.get("kind","")=="buy"` 讀的是 `od`（市場訂單 dict，origin_team/kind=buy-sell），
    跟 driver_ledger 完全是兩個不同的資料結構 ⇒ ★這個引用是錯的
⇒ 不影響「kind 有讀者，不能拿來放 store」這個結論——我另外找到一個真的會被 TileBank 的
  kind="resource" 影響的讀者：
  resource_shape_falsifier.gd:113-114   for e in driver_ledger: if kind!="resource": continue
  ⇒ 核過它的迴圈體（:111-126）只讀 kind／delta／field／reason，**不讀 entity**
    ⇒ TileBank 的紀錄混進同一個 kind 桶**不會讓它崩**，只會讓它的 (資源,reason) 母體多幾個
      tile 側的 reason（例如 construction_pay_vault）—— 對一支「列出所有會增加某資源的路徑」
      的 falsifier 床而言是**變完整不是變壞**，不需要額外處理
⇒ ★所以結論站得住，只是引用那一個例子要換，給你訂正用的句子：
  「kind 有讀者：anon_pool_level_bed（過濾 treasury）、resource_shape_falsifier（過濾 resource，
   TileBank 混進同一桶不影響它，它不讀 entity）」
```

## 其餘（呼叫點數／簽章／P1 擴大）——核對正確

```
TileBank.set_amt( 25 處 ＋ TileBank.pool_set( 16 處 ＝ 41，重算過，對。
record_driver(entity, field, delta, reason, kind) 五個參數全部必填、沒有 default
  ⇒ 不能靠「呼叫端少帶一個參數吃到預設值」矇混過去，確實需要一個帶 store 的新入口或薄包裝，核對正確。
P1 擴到 (實體,庫,資源)、母體地板四支寫入口各自≥1次且 0 次要印——結構完整，跟我上一輪要的 P1b（含person）併上了。
```

⇒ 可派 implementer。
