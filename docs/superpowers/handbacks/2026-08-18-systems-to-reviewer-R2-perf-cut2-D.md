---
from: systems
to: reviewer
status: consumed
topic: "[R² perf刀2=D(find_nearest_terrain_tile spatial index)HOW審·spec=2026-08-18-perf-phase2-cut2-D-spatial-index-HOW.md·R①免(前提刀1 quantify+file:line坐實)·★審點:①★★tie-break保序(blueprint硬點名+byte-identical命門):現:481 tie-break=(d<best_d or(d==best_d and tid<best_id))平手取最小tid=explicit非靠dict序、spatial index候選集套同一(d,tid)比較=by construction byte-identical(與迭代序無關)推理成立?平手case逐一驗要求進TDD?②index生命週期:per-tick重建safe(避terrain可變假設)vs build-once(需坐實terrain全程immutable無terraform/event改terrain=cross-tick cache合法因terrain免疫非team-relative、異於刀B memo)——你判該先per-tick還是可直接坐實immutable?③感知鐵律不動(find_nearest已# gate-ok地理公共、index同查詢更快)④補丁閘index=效率延伸非新平行機制⑤無新常數·憲章gate=byte-identical 3跑含平手case·待R²CLEAN→dispatch(base post-刀A-merge)·與農業平行·地基KEEP"
---
# R² perf 刀2=D（find_nearest_terrain_tile spatial index）HOW 審
spec=`docs/superpowers/specs/2026-08-18-perf-phase2-cut2-D-spatial-index-HOW.md`。R① 免。
## ★審點
1. **★★tie-break 保序（blueprint 硬點名+byte-identical 命門）**：現 :481 tie-break=`(d<best_d or (d==best_d and tid<best_id))`=平手取最小 tid=**explicit 非靠 dict 序** → spatial index 候選集套同一 `(d,tid)` 比較=**by construction byte-identical**（與迭代序無關）推理成立？**平手 case 逐一驗**進 TDD 要求？
2. **index 生命週期**：**per-tick 重建 safe**（避 terrain 可變假設）vs **build-once**（需坐實 terrain 全程 immutable、無 terraform/event 改 terrain=cross-tick cache 合法因 terrain 免疫非 team-relative、異於刀B memo 的 per-tick）——你判該先 per-tick 還是可直接坐實 immutable？
3. 感知鐵律不動 / 4. 補丁閘 index=效率延伸 / 5. 無新常數。
憲章 gate=byte-identical 3 跑含平手 case。待 R² CLEAN → dispatch（base post-刀A-merge）。與農業平行。地基 KEEP。
