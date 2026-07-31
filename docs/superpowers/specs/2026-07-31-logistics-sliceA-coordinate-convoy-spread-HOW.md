---
type: spec
owner: systems
topic: 後勤 SLICE A flow-fix — convoy 協調散未填單（trickle→flow）HOW
status: ready-for-R2
---

# HOW spec：SLICE A flow-fix — convoy 協調散未填單

> **26% 真根 measure 定案（第一手 trajectory 親驗）**：全 porter 滿載到市場（loaded==delivered、源 100% 私產、無載 0/無 en-route 丟）；**多 convoy naive 全 targeting 同個 best/近 buy 單** → 前者填滿（rem=0）、後者 sell_no_surplus bail；**別的想要材料的買家沒車去**（T0/1/2 各 want ×64 ~192 總需 >> 45 fulfilled=真未滿足）。∴ **非 demand-limited、是 convoy 未協調**（blueprint 裁）。
> **fix = 協調 convoy targeting 散到未填 buy 單**（非全堆一單）→ fulfilled 45→toward 192。**憲法：util/需求秤（非 scripted round-robin）；realistic 分配給所有缺的買家非 dump 一個。**★**MEASURE-VERIFY 硬性**（禁假設「散了就升」，本 session 靜態斷言被 measure 駁 6-7 次）。

## 1. Fix：deliver candidate 目標排除 in-flight-claimed 買單
現 `goal_resolver._deliver_candidates`：iterate `received_buy_orders` 取 per-res 首單 → 多賣方全指同 best 單 → 堆。
- **in-flight guard**：加**convoy in-flight 認領登錄**——已有 in-flight convoy 目標的 buy order_id（+其 in-flight cargo 已認領量）→ 該單 deliver candidate **排除/扣減 remaining**。
  - 登錄源：掃 active convoy 子隊 `task_extra_data.order_id`（in-flight 認領）；或 `state` 級 registry（dispatch 時 +order_id、DELIVER/RETURN/dissolve 時 −）。★純狀態、無 RNG。
  - `effective_rem = order.qty_remaining − Σ(in-flight convoy 認領 to 此 order 的 cargo)`；`effective_rem <= 0` → 跳此單（已被在途 convoy 認領滿）。
- **散選**：deliver candidate 選 **effective_rem > 0 的 buy 單**（util/gain 秤 best，但排除已認領滿）→ 不同賣方散到不同未填單。
- ★**憲法**：util/需求秤選單（gain × reachable × effective_rem>0）**非 scripted round-robin**；realistic（每缺料買家有車去）。

## 2. 接點
- `_deliver_candidates`（goal_resolver:125）：`received_buy_orders` 迴圈加 `effective_rem` 計算（扣 in-flight 認領）→ 排除 effective_rem<=0。
- in-flight registry：`state` 級 dict（order_id → 在途 cargo）或掃 active convoy porters。dispatch convoy 時登錄、DELIVER 成交/RETURN/dissolve 時清（守 lifecycle 對齊，別漏清=幽靈認領永久佔單）。
- 感知鐵律：買單讀 belief（received_buy_orders 既有 belief-gate）不變。

## 3. ★★TDD + 驗（★★MEASURE-VERIFY 硬性，別假設散了就升）
- **★★fulfilled 真升 + 散到多買家（measured、blueprint 硬命）**：和平床 re-run，`g1.order_fulfilled` **45→顯著升 toward ~192**（不同 buy 單 fulfilled、散到 T0/1/2 多買家非堆 1-2 個）+ `sell_no_surplus` bail（rem=0）**降** + granary material 多買家 >0（非只 T0/T1）。★**別假設**——re-run 量真值（本 session 6-7 駁教訓）。
- unit：deliver candidate 排除 in-flight-claimed 單（in-flight registry mock → 認領滿的單不生 candidate、未填單生）+ registry lifecycle（dispatch+/DELIVER-RETURN- 清）。
- 不凍（seed1337 attrition 非→0）+ cargo/守恆 + 純算術零 RNG + determinism 三跑 byte-identical + constitution 74 + observability PASS + headless 0-new + convoy_delivery_test 仍綠。

## 4. 交付
→ R²（★異質：in-flight registry lifecycle 無漏清[幽靈認領]/effective_rem 計算對/散選 util 秤非 round-robin scripted/感知鐵律/★fulfilled 真升 measured 非假設/不凍）→ implementer（in-flight guard + 散選 + ★MEASURE-VERIFY TDD 附真值 dump）→ measurer（fulfilled 45→? + 散多買家 + 不凍，落地）→ QA。**★trickle→flow 真臨門、散了 fulfilled 真升才宣布經濟活。** SLICE B 並行。
