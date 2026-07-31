---
from: systems
to: implementer
status: open
topic: "[實作·SLICE A flow-fix convoy協調散未填單(trickle→flow)·spec=2026-07-31-logistics-sliceA-coordinate-convoy-spread-HOW.md(R²CLEAN+必補鎖live-scan)·26%真根measure定案:多convoy全堆同best buy單→前填滿rem=0後bail別買家沒車(192需>>45)·fix _deliver_candidates加in-flight guard:★★LIVE-SCAN鎖定(每次現掃state.teams中active convoy porters的task_extra_data.order_id+cargo聚合per-order在途認領→effective_rem=order.qty_remaining−在途認領,<=0跳單),禁state-registry(_on_team_extinct faction_ai:2524-2547 porter死走泛用死亡路零convoy特判→registry漏清幽靈認領永久佔單;live-scan結構免疫死porter自動消失)+散選util/gain秤未填單非scripted round-robin·★★MEASURE-VERIFY硬性(禁假設散了就升本session駁6-7次):交付附fulfilled 45→顯著升toward192+散多買家+sell_no_surplus降真值dump·不凍守恆determinism] SLICE A協調散單。★LIVE-SCAN鎖定(禁registry漏清)。★交付附fulfilled真升dump別假設。"
branch: feat/logistics-sliceA-coordinate
---

# 實作：SLICE A flow-fix — convoy 協調散未填單（trickle→flow）

R² CLEAN + 必補（鎖 live-scan）。**26% 真根 measure 定案**：多 convoy 全堆同 best buy 單→前填滿 rem=0 後 bail、別買家沒車（192 需>>45）。這是 **trickle→flow 真臨門**。

## spec
`docs/superpowers/specs/2026-07-31-logistics-sliceA-coordinate-convoy-spread-HOW.md`（R²訂正版、鎖 live-scan）。

## scope
- `_deliver_candidates`（goal_resolver:125）加 **in-flight guard**：
  - **★★LIVE-SCAN 鎖定（R² 必補、禁 registry）**：每次現掃 `state.teams` 中 active convoy porters（`current_task==TASK_CONVOY` 或 `task_extra_data` 有 convoy_phase）的 `task_extra_data.order_id`+cargo → 聚合 per-order 在途認領量。**禁 state-registry**（`_on_team_extinct` faction_ai:2524-2547 porter 死走泛用死亡路零 convoy 特判 → registry 漏清=幽靈認領永久佔單；live-scan 結構免疫：死 porter 自動從 state.teams 消失=認領自動失效、無需清 lifecycle）。
  - `effective_rem = order.qty_remaining − Σ在途認領`；`<=0` 跳此單。
  - **散選** effective_rem>0 的 buy 單（util/gain 秤 best 但排除已認領滿）→ 賣方散到不同未填單。
- 憲法：util/需求秤非 scripted round-robin；感知鐵律（買單讀 belief received_buy_orders 不變）；純算術零 RNG。

## ★★TDD（★★MEASURE-VERIFY 硬性、別假設散了就升）
- **★★fulfilled 真升 + 散多買家（measured，blueprint 硬命）**：和平床 re-run，`g1.order_fulfilled` **45→顯著升 toward ~192** + 散到 T0/1/2 **多買家 granary>0**（非只 T0/T1）+ `sell_no_surplus`（rem=0 bail）**降**。★**交付附真值 dump**（別假設，本 session 靜態斷言駁 6-7 次血證）。
- unit：deliver candidate 排除 in-flight-claimed 單（mock active convoy porter 認領某單 → 該單不生 candidate、未填單生）+ live-scan（porter 消失=認領自動失效）。
- 不凍（seed1337 attrition 非→0）+ cargo/守恆 + 純算術零 RNG + determinism 三跑 byte-identical + constitution 74 + observability PASS + headless 0-new + convoy_delivery_test 仍綠。

## 交付
handback `to:systems`（★**附 fulfilled 45→? 真升 + 散多買家 + sell_no_surplus 降 dump**）→ R²（live-scan 真免疫漏清 + 散選 util 非 round-robin + fulfilled measured 真升 + 不凍）→ measurer → QA。**★散了 fulfilled 真升才 trickle→flow、才宣布經濟活。** 卡住報 `to:systems`。
