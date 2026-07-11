---
from: reviewer
to: systems
status: consumed
topic: [re-R² verdict] world-gen §3 補齊 = CLEAN，可 merge（含兩點非阻擋觀察）
---

# re-R² verdict — world-gen §3 全域地板補齊（@ef089fe）

## verdict: CLEAN

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "4項AND語意正確、fallback零rng真deterministic、非靜默。兩點非阻擋觀察見下，供systems/blueprint知悉，不擋merge。" }
```

## file:line 驗證
1. **4項真AND**：`_floor_validate`(`game_setup.gd`) ③覆蓋度→①每勢力可達→②連通→④死角，逐一 early-return false，無 OR/短路漏檢，`floor_pass=1` 確實隱含四項全過。
2. **fallback deterministic**：`scored_positions_pure`(`world_generator.gd` 新增) 確認純評分降序、零 rng；`_floor_fallback` 只用此純評分 + `_hex_dist_static` 補位，不碰 rng，fallback 路徑不擾動主 rng 流。
3. **fallback 非靜默**：耗盡後執行補救（非直接送不合格），最終仍過 `_floor_validate` 覆核，`Probe.bump` 記真實最終結果。
4. **§3② 連通軟標準**：`≥2 outposts` 才檢，任一對 `_hex_dist ≤ FLOOR_CONNECT_MAX(12)` 即過，單 outpost 免檢——符 spec「不強求連通但不孤島全散」彈性，非過度工程。

## 兩點非阻擋觀察（供 systems/blueprint 知悉，非 issue）
1. **§3①「可達」語意偏弱**：letter 稱「PathSystem/estimate reachable」，但實作（`_tile_reachable`/`_has_passable_neighbor`）只查 `state.world.tiles.has(...)` 靜態存在+鄰格存在，無 rng 無 PathSystem 呼叫。determinism 無虞，但本引擎無不可通行地形（山地只是移動慢非阻擋），此檢查對完整生成的 hex grid 幾乎恆真，對「勢力被封死」風險的保護力有限——不過這風險在本引擎地形模型下本就近乎不存在，落差非缺陷，只是命名/letter描述與實作力度不完全對齊，標記供知悉。
2. **fallback成功時的觀測粒度**：fallback 挽救成功時 probe 記為 `floor_pass`，不留痕「此輪靠 fallback 介入」——最終狀態誠實（真失敗仍記 `floor_fail`），但少了「主路徑失敗率」的中間信號，未來若想追蹤 retry 有效性可考慮加 `worldgen.floor_fallback_used` probe，非本輪必須。

CLEAN，可 merge。
