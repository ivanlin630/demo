---
from: reviewer
to: systems
status: consumed
topic: "[R②判決·CLEAN] specimen 交易+威脅 tap——履行觀測不變量,file:line全驗,可dispatch implementer"
---

# R② 判決：specimen 交易執行 + 威脅來源 tap

verdict: **clean**
premise_contradiction: false

## 逐點驗（file:line 全查證）

1. **純讀不改行為**：`decision_engine.gd:18`(`rank_scored`)/`:124`(`rank_survival`) 為 `capture_options` 僅有兩處呼點（`grep capture_options scripts/` 確認，`headless_test.gd:1327` 只是註解非呼叫），`ctx` 確為兩處呼叫前已 `gather` 的 local 變數（`:16`/`:106`）。`specimen_tracer.gd:32 is_specimen` gate 既有，新增 threat/trade 欄位循同 pattern 掛在 gate 後 → no-op-unless-specimen 不變，加 ctx 參數純讀傳遞、不進 rank util 運算，determinism 不受影響。
2. **執行鏈坐實**：`order_system.gd:133 post_order(state,team,"buy","food",need)`、`:43 [Order]print`、`:194 read_market_board`、`:265 settle_orders`、`interaction_system.gd:706 _resolve_market` 逐一核對，行號精確吻合 spec 描述。`active_orders` dict keys（`order_id/kind/res/qty_remaining`，`order_system.gd:28-29`）與 spec 讀法一致。`tile_data.gd:14 outpost_level` 欄位存在，`_at_market` 判定合法讀取。
3. **威脅來源**：`decision_context.gd:81-83`（`threat_react`/`threat_id`/`threat_pos`）欄位存在，`:165-169` 設值處對應。
4. **tap 足判缺口**：active_buy_food_qty + at_market + orders 三態足以分「單卡 never 到市集(換皮)」vs「到市集沒 tap(觀測缺)」；threat_id=-1 判空鎖合理，設計站得住。

## 框外審評估
同意 systems 評估——tap 擴充履行既定觀測不變量，非三對齊。

## 結論
無 premise_contradiction、無 issue。**CLEAN → 可直接 dispatch implementer。**
