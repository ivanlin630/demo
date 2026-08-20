---
from: systems
to: implementer
status: consumed
topic: "[dispatch perf刀2=D(find_nearest_terrain_tile spatial index)·base post-刀A-merge main 0f58c74a·spec=2026-08-18-perf-phase2-cut2-D-spatial-index-HOW.md R²-CLEAN+build-once(terrain immutable親驗坐實)·★★tie-break保序=第一約束(blueprint硬點名byte-identical命門):現find_nearest_terrain_tile:481 tie-break=if d<best_d or(d==best_d and int(tid)<best_id)平手取最小tid、explicit非靠dict序→index候選集套同一(d,tid)比較=by construction byte-identical(reviewer證argmin+explicit tie-break over固定集合與迭代序無關)·★build-once(R²親驗terrain immutable=world_generator:67唯一寫零runtime重寫):tiles-by-terrain索引世界生成完成後建一次全程沿用、免per-tick·D:①建terrain→[tile_id...]索引(world生成後一次、可lazy-first-query build-once cache)②find_nearest_terrain_tile改只iterate該terrain的tiles(非全圖)、套同一(d,tid)tie-break回同一塊③候選集=全圖掃filter terrain==X同集合(只提前filter、換iterate序)·憲法gate硬:byte-identical 3跑機器證★含平手case逐一驗(多同距tile→回最小tid=tie-break保序硬證)+constitution+無新常數·TDD:①index建對terrain分組②find用index==全圖掃(含平手case)③scan單次成本降(iterate terrain-X非全tiles)④build-once immutable正確(terrain不變沿用)⑤constitution·★measurer quantify:find_nearest scan單次成本降(p1.selection us降)、509 call數不變(D降單次非次數)·worktree feat/perf-cut2-D·與農業平行·完→handback附measurer·地基KEEP"
---

# dispatch perf 刀2=D（find_nearest_terrain_tile spatial index）

spec=`docs/superpowers/specs/2026-08-18-perf-phase2-cut2-D-spatial-index-HOW.md`（**R²-CLEAN + build-once**）。base=post-刀A-merge main `0f58c74a`（含刀A _hex_dist static + strip-B）。

## ★★tie-break 保序=第一約束（blueprint 硬點名、byte-identical 命門）
現 `find_nearest_terrain_tile:481` tie-break=`if d < best_d or (d==best_d and int(tid)<best_id)`=**平手取最小 tid**（explicit 非靠 dict 序）→ **index 候選集套同一 `(d,tid)` 比較=by construction byte-identical**（reviewer 證 argmin+explicit tie-break over 固定集合與迭代序無關）。

## ★build-once（R² 親驗 terrain immutable=`world_generator:67` 唯一寫、零 runtime 重寫）
tiles-by-terrain 索引**世界生成完成後建一次、全程沿用**（免 per-tick）。
- ①建 `terrain→[tile_id...]` 索引（world 生成後一次、可 lazy-first-query build-once cache）。
- ②`find_nearest_terrain_tile` 改**只 iterate 該 terrain 的 tiles**（非全圖）、套同一 `(d,tid)` tie-break 回同一塊。
- ③候選集=全圖掃 filter `terrain==X` 同集合（只提前 filter、換 iterate 序）。

## 憲法 gate（硬）
byte-identical 3 跑機器證 **★含平手 case 逐一驗**（多同距 tile→回最小 tid=tie-break 保序硬證）+ constitution + 無新常數。

## TDD
①index 建對 terrain 分組 ②find 用 index==全圖掃（**含平手 case**）③scan 單次成本降（iterate terrain-X 非全 tiles）④build-once immutable 正確 ⑤constitution。

## measurer
quantify `find_nearest` scan 單次成本降（p1.selection us 降）；509 call 數不變（D 降單次非次數）。

worktree `feat/perf-cut2-D`。與農業平行。完 → handback 附 measurer。地基 KEEP。
