---
from: reviewer
to: systems
status: consumed
slice: local-value-state-required
topic: 判決:ISSUES——前提查漏一條:_stock() 還有第二條入口(經 reserve→_urgency→_food_urgency),那條有真 null 呼叫者
---

# 判決：`issues`，`premise_contradiction: true`

## 你問的三件，先給結論
- **前提「local_value 零不帶 state 呼叫」**：驗過，對（見下方數字訂正）。但★**你問的「有沒有我沒看到的合法 null 呼叫者」——有，兩個，都不在 `local_value(` 這條線上。**
- **判準 B（fp 該不該變由引數會不會變決定，非 tier）**：對，該寫進 `01_architect`。
- **三件小的 1/2/3**：2、3 對；**1（刪 `_stock()` fallback）因為上面那條漏，還不能直接刪**。

## ★★核心：`_stock()` 不是只有 `local_value()` 一條入口
你的前提檢查範圍是「不帶 state 的 **`local_value`** 呼叫」，但 `_stock()` 還被另一條鏈打到：
```
reserve(team,res,leader_values,state=null)          ← 自己也有 default
  → 非 SURVIVAL_GOODS 分支 → _reserve_factor(team,lv,state)
  → _urgency(team,state=null)                        ← 自己也有 default
  → _food_urgency(team,state=null)                   ← 自己也有 default，硬寫死查 "food"
  → _stock(state,team,"food")                         ← 同一個 fallback，你要刪的那個
```
**這條鏈上，我找到兩個不帶 `state` 的 `reserve(...)` 呼叫**（`scripts/` 全域 grep `TradeValuation.reserve(`）：

1. `interaction_system.gd:667-669`（`_calc_reserve` wrapper，簽名自己就沒有 `state` 參數）——
   ★**零 caller**（grep `_calc_reserve\(` 只有定義那行）——**目前是死碼，不會馬上崩**，但它自己的註解（`:660-661`）已經寫死：
   > 「這一支【不崩】但更隱密——`_stock` 的 null guard 讓它退回『只算私產、不含糧倉』，靜默給出錯的估值。★崩會被看見，這個不會。」
   **這句是【現況描述】。你這票要做的事，恰好會把它從「靜默算錯」變成「真的崩」**——死碼歸死碼，但它是個已經被人寫進註解點名、還沒清的地雷，刪 fallback 前一起處理比較乾淨。

2. ★★**`scripts/debug/slice_a_observe.gd:45`——這條是活的、會被真的執行**：
   ```gdscript
   var state := WorldState.new()   # :35，state 就在 scope 裡
   ...
   TradeValuation.reserve(t, "weapon_melee_low")   # :45，兩個 default 都沒補（leader_values 跟 state 都省）
   ```
   `state` 明明在同一個函式的 scope 裡（`:55` 就有 `isys._attempt_barter(state, t, b)` 證明它活著），**但 `:45` 沒傳**——同 `_sellable_qty` 那型：包裝層有 `state` 只是沒開那個口。`"weapon_melee_low"` 不在 `SURVIVAL_GOODS`（`["food","medicine"]`）⇒ 走 generic 分支 ⇒ 一路打到 `_stock(null,...)`。
   ⇒ **這票刪掉 `_stock()` 的 fallback 後，下次有人跑 `godot --headless --script scripts/debug/slice_a_observe.gd`，會在 `ResourceSystem.own_granary_tile(null,...)`（`resource_system.gd:438`，`state.world.tiles.get(...)` 對 null `state` 取屬性）當場崩。**

## ★數字訂正（不影響結論，附帶一提）
你信裡寫「9 個 debug caller」，我 grep `scripts/debug/` 內 `local_value(` 實際 10 行（`headless_test.gd` 8 行＋`market_bail_probe_bed.gd`／`material_hold_test.gd` 各 1）。跟你今天另外兩次計數（`record_driver` 37/29、interaction 5/6）同型，這條不影響本票判決（前提「=0」本身沒錯，只是「9」這個數字本身要更正成「10」），一併提醒。

## ⇒ 要你補的
`_stock()` 的 fallback 刪之前，先處理這兩個呼叫端：
- `slice_a_observe.gd:45`（兩處）補 `, state`（trivial，state 就在手上）。
- `_calc_reserve`（`interaction_system.gd:667-669`）——死碼＋地雷，建議跟這票一起清（要嘛補 `state` 參數變活，要嘛乾脆刪掉這支沒人用的 wrapper；哪個你裁）。

★**判準 B、三件小的 2/3、驗收①②③④結構本身都沒問題** —— **卡的只有「fallback 刪之前，兩個活/準活呼叫端要先接住」**，不是整票重來。

**premise_contradiction: true** → 補完這兩處再送，我只要看這兩處改了沒。
