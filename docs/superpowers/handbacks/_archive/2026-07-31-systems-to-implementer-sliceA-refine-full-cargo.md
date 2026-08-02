---
from: systems
to: implementer
status: consumed
topic: "[實作·SLICE A refine DELIVER賣full cargo繞porter reserve(trickle→flow)·spec=2026-07-31-logistics-sliceA-refine-deliver-full-cargo-HOW.md(R²CLEAN)·根:_market_visitor_sell(interaction:807-829)surplus=holding-reserve對porter把delivery cargo當need reserve吃掉→sell_no_surplus bail半數·fix:_market_visitor_sell加optional deliver_cargo:float=-1.0(>=0 delivery convoy→sellable=deliver_cargo繞reserve/<0 normal→holding-reserve既有不變)+qty capping(:817 min order_rem/sellable/owner_coin保conservation airtight)+_resolve_market_at_outpost唯一call site(758)對convoy porter(task_extra_data convoy_phase)傳task_extra_data.cargo[res]·憲法cargo語意=待交付非holding非scripted·★TDD measure送達率真升(sell_no_surplus降+deliver_settled升+cargo_delivered/out 26%→顯著升+order_fulfilled>4)別假設+cargo守恆(賣+殘RETURN merge)+normal sell byte-identical不變+不凍] SLICE A refine DELIVER賣full cargo繞reserve。deliver_cargo param。★交付附measure送達率真升(別假設refine有效)。normal sell不變+守恆+不凍。"
branch: feat/logistics-sliceA-refine
---

# 實作：SLICE A refine — DELIVER 賣 full cargo（繞 porter reserve、trickle→flow）

R² CLEAN（reviewer 親讀 interaction:807-829 確認根因精準、唯一 call site 758 零遺漏、qty capping 817 保守恆 airtight）。**trickle→flow 臨門**（make-or-break PASS 但 26% 送達=trickle）。

## spec
`docs/superpowers/specs/2026-07-31-logistics-sliceA-refine-deliver-full-cargo-HOW.md`（讀它）。

## scope
- **`_market_visitor_sell`（interaction:805）加 `deliver_cargo: float = -1.0`**：
  - `deliver_cargo >= 0`（delivery convoy）→ `sellable = deliver_cargo`（cargo 待交付繞 reserve）。
  - `deliver_cargo < 0`（normal team sell）→ `sellable = effective_holding − reserve`（★既有不變、byte-identical）。
  - `qty = min(order_rem, sellable, owner_coin/bid)`（:817 capping 不動→守恆 airtight）。
- **`_resolve_market_at_outpost`（interaction:758 唯一 call site）**：對 convoy porter（`visitor.task_extra_data.has("convoy_phase")` deliver）→ 傳 `visitor.task_extra_data.cargo.get(res, 0.0)` 當 `deliver_cargo`；normal trade 不傳（default -1）。
- ★憲法：cargo 語意=待交付非 holding（非 scripted）。

## ★★TDD（★measure 送達率真升、別假設）
- **★送達率真升 measured（本 session 鐵律）**：和平床 re-run，`trade.market_bail.sell_no_surplus` 降 + `convoy.deliver_settled` 升 + **`cargo_delivered/cargo_out` 26%→顯著升** + `g1.order_fulfilled`>4。★**交付附真值 dump**（別假設 refine 有效）。
- unit：delivery convoy 賣 full cargo（deliver_cargo≥0 路）+ **normal team sell byte-identical 不變**（-1 路 holding−reserve）+ cargo 守恆（賣+殘 cargo RETURN merge 回=原 cargo）。
- 不凍（seed1337 attrition 非→0）+ determinism 三跑 byte-identical + constitution 74 + observability PASS + headless 0-new + **convoy_delivery_test 仍綠**。

## 交付
handback `to:systems`（★**附送達率真升 dump**：sell_no_surplus 降/deliver_settled 升/cargo_delivered-out 比率/fulfilled 數 + 三驗收線）→ R²（送達率 measured 真升 + normal sell 不變 + 守恆 + 不凍）→ measurer → QA。**★trickle→flow 臨門、經濟真活。** 卡住報 `to:systems`。
