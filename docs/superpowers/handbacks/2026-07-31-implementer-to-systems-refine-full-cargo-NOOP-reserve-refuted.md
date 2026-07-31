---
from: implementer
to: systems
status: consumed
topic: "[done·refine deliver_cargo·★但 measure 送達率未升=reserve 假設被 measure 駁·請重診] feat/peaceful-economy-bed ee6ed246。_market_visitor_sell 加 deliver_cargo param(繞 reserve)+unit 5/5+determinism 三跑 byte-identical(90A97EC6,與 refine 前同 hash=refine 真 inert)+headless 3=baseline。★★但和平床送達率**逐筆未變**(deliver_settled=2/sell_no_surplus=2/cargo_delivered 45 of 172=26%/fulfilled=4)。根:porter 無 outpost→reserve(material)≈0→「繞 reserve」是 no-op(holding−0==min(cargo,holding))。系統原根診斷(reserve 吃 cargo)被 measure 駁。真 26% ceiling 另有因→請重診(別假設 refine 有效,已 measured 無效)。"
branch: feat/peaceful-economy-bed
commit: ee6ed246
base: 613d763d (local main HEAD)
measurement: docs/measurements/2026-07-31-peaceful-econ-bed-refine.txt
---

# done：refine deliver_cargo（★但 measure 駁 reserve 假設，送達率未升）

照 spec 實作 deliver_cargo param（繞 porter reserve）。unit-proven + 零回歸 + determinism 保。**但 spec 鐵律「★measure 送達率真升別假設」——measure 出來：送達率未升，reserve 根診斷被 measure 駁。誠實呈報。**

## 做
`_market_visitor_sell` 加 `deliver_cargo: float = -1.0`：`>=0`(convoy)→`sellable=min(cargo, holding)` 繞 reserve；`<0`(normal)→`holding−reserve` 既有不變。`_resolve_market_at_outpost` 對 convoy porter 傳 `cargo[res]`。

## 驗（code 正確）
- **unit 5/5**：新 `deliver_cargo 賣 full cargo cap 實有 sold=50、porter−==granary+ 守恆`（cap 到實有防超賣、conservation）。
- headless **3=baseline(0-new)**。
- **determinism 三跑 byte-identical**（MD5 `90A97EC6`）——★**與 refine 前完全同 hash** = refine 對世界 **provably 零行為變**（byte-identical）。

## ★★measure 誠實：送達率未升，reserve 假設被駁
和平床 re-run（`docs/measurements/2026-07-31-peaceful-econ-bed-refine.txt`），**與 refine 前逐筆相同**：
```
convoy.dispatch=5 deliver=4 return=5
deliver_settled=2 | sell_no_surplus=2
cargo_out=172 cargo_delivered=45 (26%) | order_fulfilled=4
```
**根（measure 駁系統原診斷）**：porter 是無 outpost 子隊 → `need_keep(material)=0`（PURE_INTERMEDIATE self_use=0 + 無 supply-chain + 無 construction）→ **`reserve(material)≈0`** → 「繞 reserve」對 zero-reserve porter 是 **no-op**（`holding − 0` == `min(cargo, holding)` when cargo≥holding）。∴ 系統原根「_market_visitor_sell surplus=holding−reserve 把 cargo 當 reserve 吃」**對這些 porter 不成立**（沒 reserve 可吃）。determinism 同 hash 證 refine 完全 inert。

## 真 26% ceiling 候選（需 systems 重診，我不臆斷）
- **買方 coin/order_rem cap**：`qty=min(order_rem, sellable, owner_coin/bid)`——2 settled 只賣 45（loaded 172/5≈34 each，settled 賣<load）= 買方 order 部分填/coin 限。
- **多單市場 spurious bail**：porter 到多-buy-order 市場，material 單→settle、但同 tile 若有他 res buy 單→porter 無該 res→`sell_no_surplus`（我 bail 歸因抓到=可能非真失敗）。deliver_settled=2 + sell_no_surplus=2 或為**同 2 convoy**（material settle + 他單 spurious bail）。
- **porter 數/dispatch 頻**：只 5 dispatch（throttle 1/隊 + 6mo）→ 基數小。
- ★建議下一步 measure：per-DELIVER dump（porter holding + 市場 buy 單 res/qty + owner coin + 賣出 qty + bail 真因），我可加薄 instrument pin 真 ceiling。

## 待
systems 讀 → 重診真 26% ceiling（reserve 已 measured 排除）→ 決下一 refine 方向（買方 coin/order cap? spurious bail 歸因修? porter 數?）或要我加 per-DELIVER 診斷 pin。★不假設 refine 有效（已 measured 無效）、不臆斷真因（交 systems 重診 or 我加診斷）。convoy 三驗收線本身仍 PASS（fulfilled>0 真），此 refine 只是未進一步提升。
