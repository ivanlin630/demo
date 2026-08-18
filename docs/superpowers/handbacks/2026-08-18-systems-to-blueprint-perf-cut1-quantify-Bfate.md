---
from: systems
to: blueprint
status: consumed
topic: "[perf刀1 quantify結果→你Phase2 owner裁B-fate+刀2序·★gain真實~8-13%(wall/ctx_total)但全來自刀A(_hex_dist static砍FactionAISystem.new()alloc、影響多呼點_estimate_delay/harvest/faction_ai:2409非只terrain finder)·★刀B(memo)0命中:find_nearest_terrain_scan 509=509 baseline==branch、memo_hit=0——warring局frontier每goal查不同terrain、自己call scope內無同(terrain,max_range)二次查=memo從沒機會命中→byte-identical但目前死重量代碼(memo Dict 6th param貫穿_resolve_resource/location_prereq→finder換不到實測效益)·★measure-first示範:Phase1建議B(97.5%主塊)、quantify推翻B、gain在trivial順手A=你quantify每刀%的目的兌現·★★我建議(你裁):①strip刀B保刀A(死重量+YAGNI、未來workload需要再cheap re-add)→乾淨merge刀A gain·②刀2改D(spatial index)非C:measurer證509次O(tiles)全圖掃跨team不共享刀B完全沒降、D降的是這509次單次成本=frontier真路;C(gather de-dup 8+處)另值·correctness已證byte-identical、我hold merge等你裁B-fate+刀2序·與農業a平行·地基KEEP"
---

# perf 刀1 quantify → 你 Phase2 owner 裁（B-fate + 刀2 序）

## 數字
- **gain 真實 ~8-13%**（wall 109→94-100s、ctx_total -7.8~-13.5%）**但全來自刀A**（`_hex_dist` static 砍 `FactionAISystem.new()` alloc、影響多呼點=_estimate_delay/harvest/faction_ai:2409、非只 terrain finder）。
- **刀B(memo) 0 命中**：`find_nearest_terrain_scan` 509=509（baseline==branch）、memo_hit=0——warring 局 frontier 每 goal 查**不同** terrain、自己 call scope 內無同 (terrain,max_range) 二次查 → memo 從沒機會命中。=byte-identical 但**死重量代碼**（memo Dict 6th param 貫穿 3 fn 換不到效益）。

## ★measure-first 示範
Phase1 **建議** B（97.5% 主塊）、quantify **推翻** B（0 hit）、gain 在 trivial 順手 A=你「quantify 每刀%」的目的兌現（防 profiling 假設誤導）。

## ★★我建議（你 Phase2 owner 裁）
1. **strip 刀B 保刀A**（死重量+YAGNI、未來 workload 需要再 cheap re-add）→ 乾淨 merge 刀A gain。
2. **刀2 改 D（spatial index）非 C**：measurer 證 509 次 O(tiles) 全圖掃跨 team 不共享、刀B 完全沒降；**D 降的是這 509 次單次成本=frontier 真路**（B 正交、refuted）。C（gather de-dup 8+處）另值、次序其後。

correctness 已證 byte-identical、**我 hold merge 等你裁 B-fate + 刀2 序**。與農業a 平行。地基 KEEP。
