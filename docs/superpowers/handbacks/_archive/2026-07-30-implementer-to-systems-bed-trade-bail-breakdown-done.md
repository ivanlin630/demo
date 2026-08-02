---
from: implementer
to: systems
status: consumed
topic: "[done·bed trade-bail dump·pin GATE-B sub-gap·帶 breakdown] feat/peaceful-economy-bed a28808f6。Q3 補印 market_bail breakdown+seek/arrive/fill funnel(純多印 Probe.counts,零數字變)。★funnel:order_placed=1833→seek_market=5→arrive=40→trade.meet=6→fulfilled=0(seek 段巨落差:1833 單只 5 次真去 seek market)。賣方 bail=sell_no_surplus=13(全);買方 bail=buy_no_stock=7/buy_no_want=9/buy_carry_full=4。dump 落地 docs/measurements/2026-07-30-peaceful-econ-bed-tradebail-a28808f6.txt。bed exit0。"
branch: feat/peaceful-economy-bed
commit: a28808f6
base: 613d763d (local main HEAD)
measurement: docs/measurements/2026-07-30-peaceful-econ-bed-tradebail-a28808f6.txt
---

# done：bed trade-bail dump（pin GATE-B co-location 失敗 sub-gap）

照補。Q3 純多 print `Probe.counts` 既有欄（多數 bail key 不在 PROBE_KEYS subset）→ 零 sim 改、零行為變、**零數字變**。

## ★bail breakdown（中性讀，機制判給 systems）
**seek→arrive→fill funnel**：
```
g1.order_placed=1833  g1.order_fulfilled=0
g1.seek_market=5  g1.market_arrive=40  trade.arrive=6  trade.meet=6  trade.timeout=36
```
**market_bail 賣方端**：
```
sell_no_surplus=13  sell_ownerless=0  sell_no_price=0  sell_zero_qty=0
sell_storage_full=0  sell_owner_no_coin=0  sell_owner_cant_afford=0  no_board_order=0
```
**market_bail 買方端**：
```
buy_no_stock=7  buy_no_want=9  buy_cant_afford=0  buy_carry_full=4
buy_no_coin=0  buy_no_price=0  buy_withdraw_empty=0
```

## 樣本指向（事實層，非設計裁定）
- **巨落差在 seek 段**：`order_placed=1833` 但 `seek_market=5`——1833 買單掛出，卻只 **5 次**真去 seek market（≈0.3%）。撮合失敗主因不在 meet 端 bail（賣/買 bail 總數才 ~50），而在**幾乎沒隊去 market**（order 掛了但 seek 動作沒 fire）。
- **meet 端 bail 少量兩端都有**：賣方到了沒 surplus（sell_no_surplus=13）、買方到了 granary 空（buy_no_stock=7）/ 不想要（buy_no_want=9）/ 載滿（buy_carry_full=4）。量小（meet 只 6 次）。
- **timeout 主導**：trade.timeout=36 vs arrive=6 → 多數貿易 intent 逾時未達 market。
- ∴ **GATE-B sub-gap 主體在「order→seek」段**（1833→5），非「meet→fill」bail 端（那量小）。賣/買端 bail 都非主導、config 市集非空（有 arrive/meet）。systems 讀全 dump 定 seek 段為何不 fire（order 掛了但 seek_market 動作沒觸發＝上游 GATE-B co-location/seek 決策問題）。

## 交付
- dump **落地** `docs/measurements/2026-07-30-peaceful-econ-bed-tradebail-a28808f6.txt`（已驗存在；含 funnel + 15 bail 因 + 逐隊月故事）。
- bed exit0；observability/constitution 不受影響（bed 純 print、無 marker/seed/RNG；last green 957cde14）。需要我 re-run 兩閘確認可說。

## 待
systems 讀 breakdown pin GATE-B sub-gap（樣本指向 order→seek 段 1833→5 巨落差，非 meet-bail）→ 待用戶 vision 定 slice scope（vision-independent 撮合 fix）。★卡住/需完整 dump 特定段再抓，報 to:systems。
