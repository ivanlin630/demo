# perf Phase2 刀1：frontier location-prereq call-scoped memo（B）+ _hex_dist static（A）（HOW / systems）

status: DRAFT→R²（2026-08-18）
owner: systems（HOW）← perf arc 憲章（用戶 2026-08-18）+ Phase1 findings（frontier_candidates 97.5%）
溯源：Phase1 profile → `GoalResolver.frontier_candidates()` 占 ctx_total 97.5%、主因 `_resolve_location_prereq`→`find_nearest_terrain_tile` 全圖掃 per-goal（O(goals×tiles)）+ `FactionAISystem.new()` per-call alloc。

## §0 命門（憲章安全道紀律）
- **★byte-identical 安全道**：本刀**零行為變**、機器證 3 跑 byte-identical（同 seed StateFingerprint 精確 match）。不改「算什麼」只改「算得快」。
- **★memo 嚴禁跨 tick**（憲章）：地理 terrain 靜態=tick 內合法；**call-scoped**（frontier_candidates 一次呼叫內、team 決策當下 tile_pos 固定）⊂ tick-scoped=最緊安全。呼叫返回即清、不留跨 tick cache。
- **無新常數**（憲章 gate）：memo 是機制非旋鈕。
- **感知鐵律不動**：`find_nearest_terrain_tile` 已標 # gate-ok（地理公共知識、比照 constitution_gate:41）；memo 不改其 belief/god-view 語意（同答案更快取）。

## §1 現況（grounded 驗證）
- `_resolve_location_prereq:420`→`find_nearest_terrain_tile:469`（純地形路 :436）：`for tid in state.world.tiles:474` 全圖掃、filter terrain、`fai._hex_dist(team.tile_pos, t.tile_pos):478` 找最近。**per (team, terrain, max_range) 一次全掃**。
- **per-goal 跑**：frontier_candidates 對每 active goal 的 location prereq 各呼 → O(goals×tiles)（team26 高 goal→慢 4-5×、Phase1 histogram 坐實）。
- **alloc**：`FactionAISystem.new()` at :425（_find_own_outpost）、:473（find_nearest_terrain_tile 內）、:534（_estimate_delay_days 附近 _hex_dist）——每呼 alloc 新 FactionAISystem 只為 helper。

## §2 Task（TDD、byte-identical 機器證每 task）
### A：_hex_dist static（trivial alloc win）
- **驗 `_hex_dist` 純度**（無 instance state）→ 改 **static**（`FactionAISystem._hex_dist(a,b)` 或提取 module helper）。replace 全 `FactionAISystem.new()._hex_dist(...)` call site（goal_resolver:478/534 + 窮盡 grep 其他）為 static 呼、**免 per-call alloc**。
- 若 `_find_own_outpost`/其他 :473/:425 helper 亦純 → 一併 static（次要）；否則保留但**單一 reuse 實例**非 per-call new。
- **TDD**：①_hex_dist static 呼結果==原 instance 呼（同值）②無 FactionAISystem.new() 於 hot path（grep 證）③byte-identical 3 跑。

### B：find_nearest_terrain_tile call-scoped memo
- **frontier_candidates 內建 call-scoped memo**（local Dictionary、keyed `(terrain, max_range)`、team 當下固定 tile_pos）：同 team 多 goal 查同 terrain → 首次全掃、後續命中 memo（免重掃）。**frontier_candidates 返回即棄**（call-scoped、嚴禁跨 tick）。
- **★memo-safety（R² 必查）**：team.tile_pos 於 frontier_candidates 一次呼叫內固定（決策當下）→ 同 (terrain,range) 結果一致；terrain 靜態 → 無 mutation 依賴。**byte-identical by construction**。
- **TDD**：①同 team 多 goal 同 terrain → 全掃 1 次非 N 次（call count 證）②memo 結果==無 memo（byte-identical）③frontier 返回後 memo 不殘留（跨 tick 無 leak）④constitution 綠。

## §3 gate（憲章 + measurer quantify）
1. **byte-identical 3 跑**（機器證、同 seed StateFingerprint 精確 match）=安全道硬證。
2. **constitution 綠 + 無新常數**。
3. **measurer quantify 前後 %**：p1.selection（frontier_candidates）% within ctx_total 前後對比（誠實 CPU-time 加總口徑、%breakdown）；期望顯著降（97.5% 主塊）。
4. 若 B memo 後仍不夠（高 goal team 仍 O(tiles) 因跨 team 不共享）→ 回報、刀3 D（spatial index tiles-by-terrain per-tick、team-independent）議。

## §4 界外
- C（redundant gather de-dup 8+處）=刀2 獨立 slice。
- D（spatial index）=刀3、只 B 後不夠才開。
- 行為影響道（降頻/deferred）=非本 arc（憲章禁降 fidelity）。

序：R² 審此 HOW（memo-safety + _hex_dist 純度）→ CLEAN → 刀1 dispatch implementer → byte-identical gate + quantify → merge → 刀2 C。地基 KEEP。
