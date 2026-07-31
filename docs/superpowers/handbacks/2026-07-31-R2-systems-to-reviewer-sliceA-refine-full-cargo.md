---
from: systems
to: reviewer
status: open
topic: "[R²·SLICE A refine DELIVER賣full cargo繞porter reserve(trickle→flow)·spec=2026-07-31-logistics-sliceA-refine-deliver-full-cargo-HOW.md·make-or-break PASS但26%送達=trickle,blueprint裁refine near-term·根:_market_visitor_sell(interaction:810)surplus=holding-reserve對porter把delivery cargo當need reserve吃掉→sell_no_surplus bail·fix:_market_visitor_sell加optional deliver_cargo param(>=0=delivery convoy sellable=cargo繞reserve/-1=normal holding-reserve既有不變)+_resolve_market_at_outpost對convoy porter(task_extra_data convoy_phase)傳cargo qty·憲法cargo語意=待交付非holding非scripted·★TDD measure送達率真升(sell_no_surplus降+deliver_settled升+cargo_delivered/out 26%→顯著升+fulfilled>4,別假設)+cargo守恆(賣+殘RETURN)+normal sell不變+不凍·審deliver_cargo對normal sell零影響+守恆+送達率measured真升+cargo語意非scripted" 
---

# R²：SLICE A refine — DELIVER 賣 full cargo（繞 porter reserve、trickle→flow）

## spec
`docs/superpowers/specs/2026-07-31-logistics-sliceA-refine-deliver-full-cargo-HOW.md`。make-or-break PASS（fulfilled 0→4 真值）但 **26% 送達=trickle**，blueprint 裁 **refine near-term**（trickle→flow 臨門）。

## 根（親查）
`_market_visitor_sell`（interaction:810）`surplus=effective_holding(porter)−reserve(porter)`——porter 把 **delivery cargo 當自己 need reserve 吃掉** → sell_no_surplus bail（半數 convoy）。

## fix
- `_market_visitor_sell` 加 optional `deliver_cargo: float = -1.0`：`>=0`（delivery convoy）→ `sellable=deliver_cargo`（cargo 待交付繞 reserve）；`-1`（normal team sell，既有 sim_runner:380 caller）→ `sellable=holding−reserve`（**不變**）。
- `_resolve_market_at_outpost` 對 convoy porter（`task_extra_data` convoy_phase）→ 傳 `task_extra_data.cargo[res]` 的 cargo qty。
- ★憲法：cargo 語意=待交付非 holding（非 scripted）。

## ★reviewer focus（異質 refute）
1. **deliver_cargo param 對 normal team sell 零影響**：`-1` 路確保既有 holding−reserve 行為 byte-identical（normal trade 回歸）？
2. **cargo 語意=待交付非 holding 非 scripted 否**（繞 reserve 是正確語意、非硬 override）？
3. **守恆**：賣 full cargo（≤ 買方 order+coin cap）+ 未賣殘 cargo 隨 porter RETURN merge 回母隊 = cargo 守恆不破？
4. **★送達率真升 measured 非假設**（本 session 鐵律）：spec TDD 要求 re-run 量 sell_no_surplus 降 + deliver_settled 升 + cargo_delivered/out 26%→顯著升 + fulfilled>4——**這條夠不夠（別又假設 refine 有效、要 measured）**？
5. **不凍** + convoy_delivery_test 仍綠？

## 判
CLEAN → implementer（deliver_cargo param + convoy 傳 cargo + ★TDD measure 送達率真升）→ measurer（送達率 26%→? + fulfilled 升 + 不凍，落地）→ QA。有洞（尤其 1 normal sell 影響 / 4 送達率 measured）→ 回 `to:systems`。**★trickle→flow 臨門、經濟真活。** SLICE B 續。
