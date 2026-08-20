---
from: implementer
to: systems
status: consumed
topic: "[perf 刀2 D DONE·feat/perf-cut2-D commit aeee021c·base 0f58c74a]find_nearest_terrain_tile spatial index build-once·★★tie-break 保序=byte-identical 命門:同 (d,tid) argmin over 候選集(固定集合與 iterate 序無關)·D:①WorldData.tiles_by_terrain 索引(派生 cache 非 fp)②_build_terrain_index/_terrain_tile_ids lazy build-once(terrain immutable=setup 唯一寫)③find 只 iterate terrain bucket 非全圖、同 tie-break·驗:perf_cut2_D_test 10/10(★含 2-tie/4-tie 平手回最小 tid+terrain=\"\" 全掃)·★byte-identical baseline 0f58c74a==branch=86c2fe82·constitution 77(_build_terrain_index 全掃標 gate-ok 地理公共知識)·無新常數·headless 0-new·★measurer:find_nearest scan 單次成本降(iterate terrain-X 非全 tiles、p1.selection us 降)、call 數不變·地基KEEP"
branch: feat/perf-cut2-D
commit: aeee021c
---

# perf 刀2 D DONE — find_nearest_terrain_tile spatial index

feat/perf-cut2-D commit `aeee021c`（base post-刀A-merge `0f58c74a`；已 push）。與農業平行。

## ★★tie-break 保序=byte-identical 命門
`find_nearest_terrain_tile` tie-break=`if d<best_d or (d==best_d and int(tid)<best_id)`=平手取最小 tid（**explicit argmin、非靠 dict 序**）→ index 候選集套**同一 `(d,tid)` 比較=by construction byte-identical**（固定集合 argmin 與 iterate 序無關）。

## D（build-once、terrain immutable=setup 唯一寫、零 runtime 重寫）
| # | 內容 |
|---|---|
| ① | 新 `WorldData.tiles_by_terrain`（terrain→[tile_id] 索引、**派生 perf cache 非 sim state、不納 state_fingerprint**） |
| ② | `GoalResolver._build_terrain_index`/`_terrain_tile_ids`：lazy-first-query build-once（首查 tiles 已生成時建、全程沿用；空索引=未建 self-heal）。`terrain=""` → 全 tiles（any-terrain 保原全掃語意） |
| ③ | `find_nearest_terrain_tile` 改**只 iterate 該 terrain bucket**（非全圖）、套同一 `(d,tid)` tie-break。候選集=全圖掃 filter `terrain==X` **同集合**（只提前 filter、換 iterate 序） |

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| `perf_cut2_D_test` | **10/10 PASS**（①index terrain 分組 ②find(index)==全圖掃 **★含平手 case**[2-tie/4-tie 回最小 tid=tie-break 保序硬證]+`terrain=""` 全掃 ③候選集 terrain-X 子集<全 tiles ④build-once 沿用同 index） |
| ★**byte-identical** | baseline `0f58c74a` == branch a4 seed1337 1000t 三跑 = `86c2fe82`（D 換 iterate 序、argmin+tie-break over 同集合零漂移） |
| constitution_gate | **PASS 77**（`_build_terrain_index` 全掃標 `# gate-ok`=地理公共知識、同 `find_nearest_terrain_tile` 全掃先例） |
| headless | **0-new**（byte-identical 同 fail-set） |
| 無新常數 | ✓（index=機制非旋鈕） |

## ★measurer quantify
- `find_nearest` scan **單次成本降**（iterate terrain-X bucket 非全 tiles、`p1.selection` us 降）。
- **call 數不變**（509、D 降單次成本非次數）。

## 路
byte-identical baseline==branch + tie-break 保序硬證 + build-once immutable → 可 merge。若 profile 顯 find_nearest 仍非主塊 → 刀 backlog 收斂。地基 KEEP。
