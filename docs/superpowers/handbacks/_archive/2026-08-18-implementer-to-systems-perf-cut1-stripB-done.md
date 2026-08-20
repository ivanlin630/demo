---
from: implementer
to: systems
status: consumed
topic: "[perf cut1 strip 刀B 保刀A DONE·feat/perf-cut1 commit 5d400c08]blueprint 裁 memo 0 命中 YAGNI 出局·strip①find_nearest_terrain_tile 移除 memo param+內查寫→純掃(保刀A FactionAISystem._hex_dist static)②_resolve_resource/location_prereq 移除 memo param③frontier_candidates 移除 frontier_memo+穿參·保留刀A 全部(_hex_dist static+全呼點去 alloc、4× FactionAISystem._hex_dist)·驗:perf_cut1_test ALL PASS(A static==instance+find 純掃正確、B memo 測刪)·★byte-identical branch(刀A-only)==baseline ef72c002=6a51b8c3(刀B 0 效果移除不改行為)·constitution 75·headless 0-new(byte-identical 同 fail-set)·可 merge 刀A·地基KEEP"
branch: feat/perf-cut1
commit: 5d400c08
---

# perf cut1 strip 刀B 保刀A DONE

feat/perf-cut1 commit `5d400c08`（續 base ef72c002；已 push）。

## blueprint 裁
measurer quantify 證 `find_nearest_terrain_tile` call-scoped memo **0 命中**（509 scan=509、warring frontier 每 goal 查不同 terrain、無同 team 多 goal 撞同 terrain）=**死重量 YAGNI 出局**。刀A（`_hex_dist` static、8-13% 真 gain）**保留**。

## strip（刀B 全撤、刀A 全留）
1. `find_nearest_terrain_tile`：移除 memo 6th param + 內 memo 查/寫 → **純掃回歸**（★保刀A `FactionAISystem._hex_dist` static 呼）。
2. `_resolve_resource_prereq`/`_resolve_location_prereq`：移除 memo param 傳遞。
3. `frontier_candidates`：移除 `frontier_memo` local dict + 穿參。
- **保留刀A**：`_hex_dist` static + 全呼點 replace 去 `.new()` alloc（goal_resolver:478/498/511/534、decision_context:319/360、faction_ai:2409、4× `FactionAISystem._hex_dist`）。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| `perf_cut1_test` | **ALL PASS**（A `static==instance` 同值 6 case + `find_nearest_terrain_tile` 純掃正確/移除 forest 重掃見當下 state/max_range 界；B memo 測隨 strip 刪） |
| ★**byte-identical** | branch(刀A-only) a4 seed1337 1000t 三跑 = `6a51b8c3` **== baseline ef72c002**（刀B 本 0 效果、移除不改行為；刀A 純算術零漂移） |
| constitution_gate | **PASS 75** |
| headless | **0-new**（byte-identical → 同 fail-set，同 baseline） |

## 路
刀A（_hex_dist static、8-13% gain）淨保留、byte-identical baseline==branch → **可 merge 刀A**。刀3（D spatial index，跨 team 共享 terrain 查）=後續議（若 profile 顯 O(tiles) 仍主塊）。地基 KEEP。
