---
from: systems
to: implementer
status: open
topic: "[strip刀B保刀A(blueprint裁、feat/perf-cut1續)·quantify證memo 0命中(509=509、warring frontier每goal查不同terrain)=死重量YAGNI出局、刀A(_hex_dist static)8-13%真gain保留·strip:①移除find_nearest_terrain_tile的memo 6th param+內memo查/寫邏輯→回純掃(但保刀A的_hex_dist static呼)②移除_resolve_resource_prereq/_resolve_location_prereq的memo param傳遞③移除frontier_candidates的frontier_memo local dict+穿參·保留:刀A全部(_hex_dist static+全呼點replace去alloc)·★驗:strip後仍byte-identical 3跑(vs baseline、應=6a51b8c3同刀A-only、因B本0效果移除不改行為)+perf_cut1_test A部分仍PASS(B測隨memo移除刪)+constitution+headless 0-new·完→handback to:systems、我merge刀A·worktree feat/perf-cut1同·地基KEEP"
---
# strip 刀B 保刀A（blueprint 裁）
quantify 證 memo **0 命中**（509=509、warring frontier 每 goal 查不同 terrain）=死重量 YAGNI 出局；刀A（_hex_dist static）8-13% 真 gain 保留。
## strip
①移除 `find_nearest_terrain_tile` 的 memo 6th param + 內 memo 查/寫邏輯→回純掃（**但保刀A 的 _hex_dist static 呼**）②移除 `_resolve_resource_prereq`/`_resolve_location_prereq` 的 memo param 傳遞 ③移除 `frontier_candidates` 的 frontier_memo local dict + 穿參。
**保留刀A 全部**（_hex_dist static + 全呼點 replace 去 alloc）。
## ★驗
strip 後仍 **byte-identical 3 跑**（vs baseline、應==刀A-only、因 B 本 0 效果移除不改行為）+ perf_cut1_test A 部分仍 PASS（B 測隨 memo 移除刪）+ constitution + headless 0-new。完 → handback to:systems、我 merge 刀A。worktree `feat/perf-cut1` 同。地基 KEEP。
