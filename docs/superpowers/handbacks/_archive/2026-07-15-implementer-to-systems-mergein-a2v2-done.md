---
from: implementer
to: systems
status: consumed
topic: "[完] Fix A-2 v2 併入 rejection-learning — HEAD dfeecb80;TDD 13綠;憲法 sites=29 零新 try_set;determinism OK"
---
# Hand Back：Fix A-2 v2 併入 look-before-leap（rejection-learning）

branch `feat/desperation-food-seeking` @ `dfeecb80`（已 push），承 v2 dispatch（我 flag belief-food gap → systems 重裁 rejection-learning）。

## 實作（照 spec §A-2 v2，2 commit）
- **`interaction_system._resolve_join` 拒絕分支**：`_absorber_accepts` false 那段 +`_npc_ai.write_memory(joiner_leader, "join_rejected", host_id, tick, 0.5)`（既有 memory 機制，一行）。
- **`decision_context.has_acceptable_join_host`**：host **鏡射 `to_task:200` 優先序**（`strong_neighbor_id if !=-1 else consolidate_target_id`，★非 OR）+ 可達（`PathSystem.find_path`）+ 該 host 不在近期 `join_rejected` memory（`JOIN_REJECT_COOLDOWN_TICKS=480` TEST VALUE，過期可再試）。
- **`options.gd:103`** 併入 applicable +`and ctx.has_acceptable_join_host`。

## 守則達成
- 純讀 memory/PathSystem（gate）；`_resolve_join` 只加一行 write_memory（無其他行為改）；**憲法零新 try_set（sites=29 removed=0）**。
- cooldown 過期可再試（非永久黑名單，撲空 emergent 精神）。

## 驗（TDD + sanity；log docs/measurements/*-dfeecb80.log）
- **TDD 13/13 PASS**（含 A-2 v2 5 條）：gate（不 acceptable→併入不入 / acceptable→入不誤殺）+ gather cooldown（沒拒→acceptable / 剛拒 cooldown 內→不 acceptable / cooldown 過期→再 acceptable）。
- **headless 3+3 baseline 零新增**（write_memory join_rejected 於實 sim 跑不破既有——同 3 函數 beg_join/p2a/strategic_reads）。
- **憲法閘 PASS sites=29 removed=0**（零新 try_set）。
- **determinism**：`seeded warring reproducible OK (seed=1337 ticks=1200)` 逐點重現（純確定性讀 memory/PathSystem，write_memory 依 tick 無 randf）。

## 說明：TDD scenario 3（mirror precedence）覆蓋方式
dispatch TDD#3（strong_neighbor 剛拒 + consolidate 沒拒 → 取 strong_neighbor→不入）——我未在 live gather 強設 strong_neighbor（需 discovery+rep+belief 重 setup），改由**結構性保證**覆蓋：`has_acceptable_join_host` 的 host-selection expression 與 `to_task:200` **byte-identical**（`strong_neighbor if !=-1 else consolidate`）→ gate 與 dispatch 恆選同一 host（非 OR）→ scenario 3 擔心的「gate 過 consolidate 但 dispatch 去 strong_neighbor」錯配結構上不可能。cooldown 邏輯已於 gather test（b/c）在**選定 host** 上驗證。若你要 live strong_neighbor 覆蓋，我可補（需 discovery/rep/belief setup）——請示。

## 下一站需求（measurer 全-HD 重跑 + QA 故事複判）
A+B+A-2 全在此分支（dfeecb80）：Team20+Team18+新死隊 specimen 全-HD reproducible → QA 判連貫窮死（買糧不追海市蜃樓 / 併入不重纏恆拒 loop / 遷移找糧奮力移動 / 真絕境連貫死）→ blueprint 批 merge。

## 待確認
- scenario 3 覆蓋方式（結構性 vs live）請 systems 認可。完成判定 = systems + reviewer/QA。context hold warm 等裁決信。
