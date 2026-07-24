---
from: implementer
to: systems
status: consumed
topic: "[done·S3 REDO build-closure·material 缺口鏈閉環到採·must-fix②/tile-resolver/belief 未動·收+驗+S3 R² 完整] feat/means-end-s3-location 660a9506。只補 build-closure frontier(隊在 forest tile 未建→建 outpost 那裡 candidate→own.terrain==forest→採 satisfied 閉環)+防 d=0。TDD 10/10(+build-closure ②③)/headless 0-new/gate 74 removed=0(must-fix② 續守)/determinism 123c889b。whole-system-first:只補閉環。完成→收+驗+S3 R²(完整含閉環)→CLEAN merge→dispatch S4。"
branch: feat/means-end-s3-location
commit: 660a9506
spec: docs/superpowers/specs/2026-07-24-long-range-planning-means-end-HOW.md
---

# done：S3 REDO — material 缺口鏈補 build-closure frontier（閉環到採）

systems 收驗：must-fix②/tile-resolver/belief 全 PASS（**未動**）；material 缺口鏈未閉環（缺「到了建 outpost」frontier）→ REDO 只補 build-closure。

## 補一塊（其餘 PASS 未動）
`_resolve_resource_prereq` 採@地形手段加 **build-closure frontier**：
- 隊**已在**目標地形 tile（`team.tile_pos == forest tile` 且 `outpost_level == 0` 未建）→ 生「**建 outpost 那裡**」candidate
  （`to_task = TASK_BUILD, target=team.tile_pos` in-place build，label `maintain_material:facility`）。
- **+防 d=0**：移動 candidate 加 `pos != team.tile_pos`（不對自己 tile 生移動＝原卡住根）。
- → **湧現閉環**：缺料 → 移動到 forest（frontier1）→ 到了 → 建 outpost（frontier2，在 forest tile 才 applicable）→ `own.terrain==forest` → **採 satisfied**。

## unowned + 委派邊界
- **unowned**：目標格已被別隊占（`outpost_level > 0`）→ 不進 build-closure 支；真被占 `start_build` 自然擋。真需 unowned 優選=S4 精修（非 S3 blocker）。
- **委派**（派子隊 build）= S5 別提前，S3 隊自己 build。

## 驗（皆綠）
- TDD `means_end_s3_test` **10/10**（+build-closure：①隊在 forest tile 未建 → build-closure candidate `TASK_BUILD` in-place(7,7)
  ②建成 forest outpost（own.terrain==forest）→ 採 satisfied（無 material move/build candidate ＝**閉環完成**）；
  全 regression 綠：material 缺口鏈 move / tile-resolver 兩類分流 / belief 37<400 / bounded reachable）。
- headless 0-new（3 baseline）。
- **★gate PASS sites=74 removed=0**（must-fix② 續守 + build-closure `TASK_BUILD target=team.tile_pos` 純狀態，無新 god-view/RNG）。
- determinism seed1337×2mo×2 跑 byte-identical MD5 `123c889b`（build candidate 純狀態 tie-break 無 randf）。

## ★whole-system-first
只補 build-closure 閉環 material 缺口；facility 遞迴 build_<facility> subgoal / 子目標 / 折現 / 委派 = S4-S6 未提前。

## 完成判定 = systems + reviewer R²（★非自判）
請 systems 收 + 驗 + S3 R²（**完整含閉環**：build-closure 湧現順序[移動→建→採 satisfied] / d=0 防護 / unowned 自然擋 / must-fix② 續守 / whole-system-first）→ CLEAN merge → dispatch S4。
base=local main 3d11a506（含 S2）。
