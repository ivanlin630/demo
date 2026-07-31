---
type: spec
owner: systems
topic: 後勤 SLICE A refine — DELIVER 賣 full cargo 繞 porter reserve（trickle→flow）HOW
status: ready-for-R2
---

# HOW spec：SLICE A refine — DELIVER 賣 full cargo（porter reserve 繞過）

> **make-or-break PASS（真值：order_fulfilled 0→4、granary T0=33/T1=22 真 deposit）＝經濟第一次真流動**。但 blueprint 誠實框：**26% 送達率（cargo 45/172、sell_no_surplus=2 半數 bail）＝trickle 非 flow**、「機制 proven works」≠「經濟真活起來」。**refine=near-term（讓 trickle→flow=真活臨門）**、先於/並行 SLICE B。
> **根（親查 interaction:810）**：DELIVER → `_resolve_market_at_outpost`(interaction:731) → `_market_visitor_sell`(:805) `surplus = effective_holding(porter, res) − reserve(porter, res)`——**porter 把 delivery cargo 當自己的 need reserve 吃掉** → surplus 不足 → bail。
> **★憲法（blueprint）**：DELIVER 繞 reserve **非 scripted**——是 **cargo 語意=待交付非 holding**（porter 被 dispatch 來送貨、cargo 無 porter reserve claim）。

## 1. Fix：DELIVER 賣 full cargo qty（繞 porter reserve）
- **`_market_visitor_sell`（interaction:805）加 optional `deliver_cargo: float = -1.0` param**：
  - **`deliver_cargo >= 0`（delivery convoy）**：`sellable = deliver_cargo`（porter cargo 待交付、繞 reserve）。
  - **`deliver_cargo < 0`（normal team sell，既有 caller sim_runner:380）**：`sellable = effective_holding − reserve`（既有行為不變）。
  - `qty = min(order_rem, sellable, owner_coin/bid)` 其餘不變（買方 coin/order/storage cap 照守）。
- **DELIVER 傳 cargo**：`_resolve_market_at_outpost` 對 convoy porter（`visitor.task_extra_data.has("convoy_phase")` deliver）→ 從 `task_extra_data.cargo[res]` 取 cargo qty 傳 `deliver_cargo`；normal trade 不傳（-1）。
  - ★`_resolve_market_at_outpost` 需知 caller 是 convoy——加參數或讀 visitor.task_extra_data convoy_phase。
- 效果：porter 賣 full cargo → sell_no_surplus bail 消 → 送達率 26%→高 → trickle→flow。

## 2. 守恆 + 憲法
- **cargo 守恆不破**：賣 full cargo（≤ 買方 order qty + coin cap）；未賣完（買方 coin/order 限）殘 cargo 隨 porter RETURN merge 回母隊（既有）。
- **normal team sell 不變**（deliver_cargo=-1 走既有 holding−reserve，回歸）。
- 憲法：cargo 語意（待交付非 holding）非 scripted；純算術零 RNG。

## 3. ★★TDD + 驗（★measure 送達率真升，別假設）
- **★送達率真升（measured）**：和平床 re-run，`sell_no_surplus` bail 降 + `deliver_settled` 升 + **`cargo_delivered/cargo_out` 比率 26%→顯著升** + `order_fulfilled` 升（>4）。★**measure 真值**（本 session 鐵律，別假設 refine 有效）。
- unit：delivery convoy 賣 full cargo（deliver_cargo 路）+ normal team sell 不變（-1 路 holding−reserve）+ cargo 守恆（賣+殘 RETURN=原 cargo）。
- 不凍（seed1337 attrition 非→0）+ determinism 三跑 byte-identical + constitution 74 + observability PASS + headless 0-new + convoy_delivery_test 仍綠。

## 4. 交付
→ R²（★異質：deliver_cargo param 繞 reserve 對 normal sell 零影響/cargo 語意非 scripted/守恆[賣+殘 RETURN]/★送達率真升 measured 非假設/不凍）→ implementer → measurer（★送達率 26%→? + fulfilled 升 + 不凍，落地）→ QA。**★這是 trickle→flow 臨門、經濟真活。** SLICE B（分配政策）續。
