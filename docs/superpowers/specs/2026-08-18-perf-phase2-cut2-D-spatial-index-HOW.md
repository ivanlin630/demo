# perf Phase2 刀2=D：find_nearest_terrain_tile spatial index（HOW / systems）

status: DRAFT→R²（2026-08-18）
owner: systems（HOW）← perf 憲章 + Phase1（frontier 97.5%）+ 刀1 quantify（509 次 O(tiles) 全圖掃跨 team 不共享、刀B memo 0 命中=正交、D 才降 509 單次成本）
溯源：刀1 quantify → `find_nearest_terrain_tile:469` 每呼 `for tid in state.world.tiles` **全圖掃 O(tiles)**、509 次/3 天窗、跨 team 不共享（memo 沒解）。D=**降每次掃的單次成本**（O(tiles)→O(terrain-X tiles)）。

## §0 命門（憲章安全道 + blueprint 點名風險）
- **★★tie-break 保序=第一約束（blueprint 硬點名、byte-identical 命門）**：現 `find_nearest_terrain_tile:481` tie-break=`if d < best_d or (d == best_d and int(tid) < best_id)`=**平手取最小 tile_id**（explicit tid、iteration-order-independent）。**spatial index 必回完全同一塊**=保此精確 `(d, tid)` 比較（平手最小 tid）。**設計時就把 tie-break 保序當第一約束、非靠 gate 3 跑碰運氣**。★好消息：現 code 已 explicit tid tie-break（非靠 dict 迭代序）→ index 只要對候選集**套同一 `(d,tid)` 比較**即 byte-identical（與迭代序無關）。
- **★byte-identical 安全道**：零行為變、機器證 3 跑（同 seed StateFingerprint 精確 match）。
- **無新常數**（index=機制非旋鈕）。
- **感知鐵律不動**：find_nearest_terrain_tile 已 # gate-ok（地理公共知識）；index 只是同查詢更快、不改 god-view 語意。

## §1 現況（grounded）
- `find_nearest_terrain_tile:469`：`var best_id=1<<30`；`for tid in state.world.tiles:474`（全圖掃）；filter `t.terrain != terrain` skip；`d = _hex_dist(team.tile_pos, t.tile_pos)`；`if d>max_range: continue`；`if d < best_d or (d==best_d and int(tid)<best_id): best_d=d; best_id=tid; best=t.tile_pos`。
- 刀A 已 merge 後 `_hex_dist` static（本 slice base 含刀A）。
- terrain=靜態物理地理（`_resolve_location_prereq:435` 註「純地形」、tile.terrain 世界生成定）。

## §2 Task（TDD、byte-identical 機器證每 task）
### D：tiles-by-terrain 空間索引
- **建索引**：`terrain → [tile_id...]`（或 (tile_id, tile_pos)）。★**生命週期**（R² 議、safest 優先）：**per-tick 重建 or lazy-first-query-per-tick**（tick-stamp 自動失效）——避 terrain 可變性假設、per-tick 一建 vs 509 查=淨贏；★若 R²/implementer 坐實 **terrain 全程 immutable**（世界生成後不變、無 terraform/event 改 terrain）則可升 **build-once cache**（免每 tick 重建、更省；此 cross-tick cache **合法**=terrain 免疫非 team-relative、異於刀B memo 的 team.tile_pos-relative 須 per-tick）。**先 per-tick safe、immutable 坐實才 build-once**。
- **查詢**：find_nearest_terrain_tile 改為**只 iterate 索引裡該 terrain 的 tiles**（非全圖）、套**同一 `(d, tid)` tie-break**（平手最小 tid、逐字保 :481 比較）→ 回同一塊。
- **★tie-break 保序驗**：索引候選集套 `(d, tid)` 比較 = 與全圖掃同結果（explicit tid、order-independent）。
- **TDD**：①index 建對（terrain→tiles 正確分組）②find_nearest_terrain_tile 用 index 結果==全圖掃結果（**含平手 case 逐一驗**：多同距 tile→回最小 tid、byte-identical 命門）③scan 成本降（iterate terrain-X tiles 非全 tiles、call 數同 509 但單次 O(terrain-X)）④per-tick 失效正確（跨 tick 不用 stale index）or immutable build-once 正確⑤constitution 綠。

## §3 gate（憲章 + measurer quantify）
1. **★byte-identical 3 跑**（機器證、含平手 case=tie-break 保序硬證）=安全道命門。
2. **constitution 綠 + 無新常數**。
3. **measurer quantify 前後**：find_nearest_terrain scan 單次成本降（p1.selection us 降）；509 call 數不變（D 降單次非次數、與刀B 正交）。
4. per-tick 重建 overhead vs 全圖掃節省=淨贏確認（若 per-tick 重建自身太貴+terrain immutable 坐實→build-once）。

## §4 界外
- C（gather de-dup 8+處）=刀3、D 後。
- 刀B memo=已 strip（YAGNI、0 命中）。

序：R² 審此 HOW（★tie-break 保序 by construction + index 生命週期 per-tick vs immutable build-once）→ CLEAN → dispatch（base post-刀A-merge main）→ byte-identical gate + quantify → merge → C。地基 KEEP。
