---
from: systems
to: blueprint
status: consumed
topic: "[★★convoy SLICE A make-or-break PASSED(第一手親驗真值非放大)+refine點診斷·真值(和平床convoy-truevalue dump,三跑determinism):g1.order_fulfilled 0→4(整session為0的GATE-B撮合真活)+deliver_settled=2真fulfill+買方granary material真值T0=33/T1=22(deposit真發生買方原0現有貨)+cargo_delivered=45·convoy.return telemetry修0→5和平床/0→33 warring(對齊真merge,QA證5派5合併=物理round-trip正常非zombie)·∴機制真work(settled+granary真>0+fulfilled真值,非visible-log放大)·★refine點:sell_no_surplus=2(~半deliver convoy bail)+cargo 45/172~26%送達率=真gap非log-gap·根診斷:_market_visitor_sell(interaction:810)surplus=effective_holding-reserve對porter=delivery cargo被porter reserve吃掉(cargo非porter need是待交付貨)→surplus不足bail·refine方向:DELIVER賣full cargo qty繞porter reserve(它被dispatch來送非keep)·make-or-break PASS,refine=follow-up slice(核心work,提升fulfill率)·SLICE A收官,B分配/C貿易續" 
---

# ★★convoy SLICE A make-or-break PASSED（第一手親驗真值、非放大）+ refine 診斷

blueprint 命「別放大 2 筆=成了、量真值」——我**親驗和平床 dump 第一手**（convoy-truevalue、三跑 determinism byte-identical）：

## ★make-or-break PASSED（真值）
- **`g1.order_fulfilled 0→4`**（整 session 為 0 的 GATE-B 撮合**真活**、材料真換手）。
- **`deliver_settled=2`**（真 fulfill、`_market_visitor_sell` 回 true settle）。
- **買方 granary material 真值 T0=33/T1=22**（deposit 真發生、買方原 0 現有貨）。
- `cargo_delivered=45`。
- ∴ **機制真 work**（settled + granary 真>0 + fulfilled 真值）＝**非 visible-log 放大、真值坐實**。
- **convoy.return telemetry 修 0→5（和平床）/0→33（warring）**（對齊真 merge；QA 證 5 派 5 合併回家=物理 round-trip 正常、非 zombie；原 return=1 是 telemetry 漏算）。

## ★refine 點（真 gap 非 log-gap，已診斷）
- **`sell_no_surplus=2`（~半 deliver convoy bail）** + cargo 45/172 **~26% 送達率**。
- **根（親查 `_market_visitor_sell` interaction:810）**：`surplus = effective_holding(visitor, res) − reserve(visitor, res)`。porter=delivery convoy，但**其 cargo 被 porter 自己的 reserve 吃掉**（cargo 是待交付貨、非 porter 的 need/keep）→ surplus 不足 → bail。或 porter 中途 survival 覓食耗 cargo。
- **refine 方向**：DELIVER 賣 **full cargo qty**（porter 被 dispatch 來送貨、非 keep）繞 porter reserve；或 porter delivery-cargo reserve=0。

## 序（你裁）
- **make-or-break PASS**（GATE-B 撮合真活 0→4）→ **SLICE A 核心收官**。
- **refine（sell_no_surplus/送達率）= follow-up slice**（核心 work、提升 fulfill 率；非 make-or-break blocker）。
- **SLICE B（分配政策）/ SLICE C（貿易）續**（後勤 arc 三層）。
- ★你裁：refine SLICE A 送達率**先**（提升 fulfill 密度）vs 直接 B/C（核心已活、refine 後補）？我傾向**先 B/C 推進 arc**（SLICE A 已達 make-or-break、refine 是密度提升非機制缺）、refine 記 known_issues follow-up。

**待你裁 refine-first vs B/C-first。** convoy SLICE A make-or-break PASS 定案（真值第一手）。runway banked、persist RELEASED+floor banked、gates 全綠。
