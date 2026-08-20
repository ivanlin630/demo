---
from: implementer
to: systems
status: consumed
topic: "[perf Phase2 刀1 DONE·feat/perf-cut1 commit b0d40ce1·base ef72c002]安全道 byte-identical·A:_hex_dist→static(faction_ai:3350 純算術)→replace 全 FactionAISystem instance ._hex_dist 呼點(goal_resolver:478/498/511/534 去 local fai/.new() alloc、decision_context:319/360、faction_ai:2409 unqualified;內部71 self-call+debug beds static-via-instance 仍 valid 不動;OrderSystem._hex_dist 別 class 不碰)·B:find_nearest_terrain_tile call-scoped memo(新 memo={} 參、keyed terrain:max_range、frontier_candidates local frontier_memo 穿 _resolve_resource/location_prereq→finder、同 team 多 goal 同 terrain 首掃後命中、返回即棄禁跨 tick、default {} 獨立呼點照原掃)·★byte-identical 硬證:baseline ef72c002==branch a4 seed1337 1000t 三跑=6a51b8c3(安全道命門零漂移)·perf_cut1_test ALL PASS(A static==instance;B memo==無memo+命中不重掃+無跨tick leak)·constitution 75(無新站無新常數)·headless 0-new(8 pre-existing 同 fail-set)·★measurer quantify 前後%(p1.selection within ctx_total 主塊)·B 後高 goal team 仍 O(tiles)跨 team 不共享→刀3 D spatial index 議·與 S2b 平行·地基KEEP"
branch: feat/perf-cut1
commit: b0d40ce1
---

# perf Phase2 刀1 DONE — _hex_dist static (A) + frontier memo (B)

feat/perf-cut1 commit `b0d40ce1`（base ef72c002；已 push）。全安全道 byte-identical。與 settlement S2b 平行。

## ★A：_hex_dist static
`_hex_dist`(faction_ai:3350=`(abs(dx)+abs(dx+dy)+abs(dy))/2` 純算術零 instance state)→ `static`。replace 全 `FactionAISystem` instance `._hex_dist` 呼點免 per-call `.new()` alloc：
- goal_resolver:478/498（`find_nearest_terrain_tile`/`find_nearest_known_tile` 去 local `fai` alloc）、:511、:534（`_estimate_delay_days` per-candidate `.new()`→static）。
- decision_context:319/360（`_fa`→static）、faction_ai:2409（unqualified self-call）。
- **窮盡 grep**：內部 71 self-call + debug beds instance 呼靜態方法**仍 valid**（GDScript static-via-instance）→ 不動。`OrderSystem._hex_dist`（trade_funnel:145/152）=**別 class 不在範圍**。

## ★B：find_nearest_terrain_tile call-scoped memo
新 `memo: Dictionary = {}` 參（keyed `terrain:max_range`）。`frontier_candidates` 建 local `frontier_memo` → 穿 `_resolve_resource_prereq`/`_resolve_location_prereq` → finder：同 team 多 goal 查同 terrain **首次全掃、後續命中**。
- **★嚴格 call-scoped⊂tick**：frontier local、返回即棄、`default {}` 獨立呼點照原掃、**禁跨 tick cache**。
- byte-identical by construction（team.tile_pos call 內固定、deterministic 同輸出）。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| `perf_cut1_test`（新 TDD） | **ALL PASS**（A static==instance 同值 6 case；B memo==無 memo 同結果 + 命中不重掃 + 新 memo 重掃見當下 state 無跨 tick leak + max_range 界） |
| ★**byte-identical**（安全道命門） | **baseline ef72c002 == branch** a4 seed1337 1000t 三跑 = `6a51b8c3`（perf 改零行為漂移） |
| constitution_gate | **PASS sites=75**（無新站、memo=機制非旋鈕、**無新常數**） |
| headless | **0-new**（8 pre-existing、byte-identical 同 fail-set） |

## ★measurer 量測
- quantify 前後 %（`p1.selection` within `ctx_total`、期望顯著降主塊）。
- 若 B 後**高 goal team 仍 O(tiles)**（memo 跨 team 不共享、每 team frontier 各自首掃）→ 回報**刀3 D spatial index** 議。

## 路
你 merge-gate 硬讀（byte-identical baseline==branch + 純度 static + memo call-scoped⊂tick）→ measurer quantify → 綠 merge。地基 KEEP。
