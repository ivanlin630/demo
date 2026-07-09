---
from: implementer
to: systems
status: consumed
topic: observer inspect 擴充完成——query 層 24/24 PASS；1 spec 假設修正（tile key）；GUI 手驗待用戶
---

# observer inspect 擴充 — 實作完成

新 worktree `feat/observer-inspect`（base origin/main a3db7c9）@ `a8d17eb`。並行 A2c-1 不同子系統。

## 做了什麼（照 spec 4 檔，全 read-only）

- **`observer_query_api.gd`**：`_nonzero_resources` helper + `RES_LABEL` 中文映射 + `res_label()`；`query_team` +`resources_nonzero`；`query_outpost`（type/level/擁有隊+勢力/駐軍/武器坊/資源/cap）；`_owner_faction_of` 雙 null guard。
- **`observer_bridge.gd`**：+`query_outpost` wrapper。
- **`observer_inspect_panel.gd`**：`_render_detail` +「資源持有」段（非零、中文標籤、隊排 food/coin 免重複、據點含 food 全露）；`select_tile` + `_render_outpost_detail`；**雙 sentinel 互斥契約**（`_selected` -1 / `_selected_tile` (-1,-1)，select_team/select_tile/_on_row 雙向清除，_render_detail 判序固定=據點優先）。
- **`observer_main.gd`**：接 `_map.tile_selected` → `_inspect.select_tile`（map input 未改）。

## ★spec 假設修正（1 處，需你知會）

spec D2a 寫 `state.world.tiles.get(tpos)`（假設 Vector2i key）。**實際 tiles 以 `tile_id = x*1000+y`(int) 為 key**（`world_generator.gd:60`，全庫慣例 `pos.x*1000+pos.y`，見 `ambush_system`/`faction_ai_system` 等 20+ 處）。直接用 Vector2i get **永遠 miss → 每個據點格印「此格無據點」**=silent GUI 失效。已改 `query_outpost` 轉 key（`tpos.x*1000+tpos.y`）。純技術對齊既有慣例，無語意變更。headless 測涵蓋（civ/mil/無主/非據點格全綠）故確認生效。

## 閘（全綠）

| 閘 | 結果 |
|---|---|
| `--headless --import` | 無 parse error |
| **query 層 headless 測**（`observer_inspect_test.gd`，新增） | **24/24 PASS**：team resources_nonzero（零項排除、food 在 DTO）；civ/mil outpost type/level/owner隊+勢力/駐軍/武器坊/resources；無主 owner=-1 null guard 不炸、owner_faction 空；非據點格 & off-map → `{}`；res_label 中文 |
| `constitution_gate` | `PASS (sites=30, removed=0)` |

## 待

- **GUI 手驗交用戶**（spec §驗收法 3）：ObserverMain 點隊→見完整非零資源；點據點格→據點詳情；點空非據點格→「此格無據點」；互斥切換不殘留。
- read-only：零 WorldState 寫，sim determinism 不受影響。

完成判定 systems + reviewer + 用戶手驗，非自判。
