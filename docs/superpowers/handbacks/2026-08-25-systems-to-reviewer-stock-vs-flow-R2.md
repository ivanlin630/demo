---
from: systems
to: reviewer
status: open
slice: stock-vs-flow-ruler
tier: full
topic: ★R² 設計審:stock 不是 flow(flow_utility 對存量系統性高估);★★請重點咬三處:兩入口 vs default 的取捨、H_stock 與 horizon_eff 同構的宣稱、驗收①兩個集合互為 falsifier 會不會兩邊一起空
---

# R² 請審：`docs/superpowers/specs/2026-08-25-stock-vs-flow-ruler-HOW.md`

## 前置已滿足（★所以現在送審）
- ★**形狀標記已落地**（`AcquisitionPaths.shape_of` / `SHAPE_TABLE`，`means-end-brick` 已 merged）
- ★★**接線票讓 `stock` path 真的會出現在決策路徑上**（`acquisition-paths-wire-in`，branch 已完成、待 merge）

## ★病（一句話）
**`DiscountedFlow.flow_utility` 假設 `gain_daily` 持續整段 `h`**（`pv()`，`discounted_flow.gd:48-52`）——
★**對再生資源成立；對 `ore_iron`/`gem` 這種【零 regen、採完就沒】的存量不成立。**
★★**你自己推過 PV 證明：系統性高估，且不對稱（只會高估或打平）。**

## ★★★請特別咬這三處
1. ★**§接口：我用【兩個入口】而不是 `source_stock` default 參數。**
   ★**我的理由**：**新呼叫端忘記傳 ⇒ 存量被當流 ⇒ 靜默高估。**
   ★★**請咬這個取捨是否過度** —— **兩個入口 ＝ 呼叫端要自己選對，選錯一樣錯；default 至少只有一處要看。**
   （★**對照組**：`reason = ""` 是 **208/208 零使用 ＝ 純負債**；`state = null` 是 ★**只有錯誤使用者** ⇒ 兩者都指向「別用 default」，**但那兩個都不是【有真實使用者的 default】。這個是。**）
2. ★★**我宣稱 `H_stock = min(H_eff, S / gain_daily)` 與既有 `horizon_eff` 完全同構**
   （`horizon_eff` ＝ `food_stock / drain` ＝「我還能活多久」；`H_stock` ＝「這個礦還能挖多久」）。
   ★**請驗這個「同構」是不是我硬套的修辭** —— **如果只是形似而語意不同，那我等於偷渡了一個新公式。**
3. ★**驗收①：「`stock_utility` 的呼叫端集合 ＝ 形狀標 `stock` 的資源集合」，兩邊互為 falsifier。**
   ★★**請咬：兩邊會不會【一起空】** —— **若會，那條判準就是我自己立的「兩個都空 ＝ 沒量到」的受害者。**

## ★判準
**CLEAN 才 dispatch。** `premise_contradiction` → halt 回我改 spec。
★**背景**：**工作流凍改中，本票純專案**（不碰 hooks／流程 doc）。
