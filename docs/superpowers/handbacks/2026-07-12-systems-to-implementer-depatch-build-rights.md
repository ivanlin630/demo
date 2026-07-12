---
from: systems
to: implementer
status: consumed
topic: [工單] de-patch建造權—faction迴圈→outpost-owner-team遍歷;spec+R²CLEAN;疊新worktree feat/depatch-build-rights
---

# 工單：de-patch 建造權（遍歷結構改）

spec：`docs/superpowers/specs/2026-07-12-depatch-build-rights-technical.md`（R² CLEAN）。絕境經濟死鎖結構根：獨立隊擁 outpost 卻無建造評估→無農場→餓死。真根=faction-leader-team-only。**新 worktree `feat/depatch-build-rights` 疊當前 main（已 push，base 新）。**

## 做（照 spec §1-§6）
1. **§1 遍歷改**：`faction_ai_system.gd _evaluate_all_body:641-642`——把 faction 迴圈內 `_evaluate_infrastructure(state, f)` 移出，改 INFRA cadence 建 owner→tiles 索引 → 遍歷擁 outpost 隊：
   ```
   if state.world.current_tick % INFRA_INTERVAL == 0:
       var owner_tiles := _build_owner_outpost_index(state)
       for owner_tid in owner_tiles.keys():   # ★見下 determinism
           var builder := state.teams.get(owner_tid)
           if builder == null: continue
           _evaluate_infrastructure(state, builder, owner_tiles[owner_tid])
   ```
2. **§2 `_evaluate_infrastructure(faction)` → `(builder_team, owned_tiles)`**：leader_team→builder_team;tile 掃改只走 owned_tiles;移除同-faction 跨隊評估段（原 :2741-2743 guard，reviewer 確認移除後覆蓋等價——原 :2748/2767 早用 owner_team 執行）;player skip 改判 builder_team.leader_id。labor 機制（resident/subteam 出工）保留。
3. **§3** `_build_owner_outpost_index(state)`：掃 `state.world.tiles`，`outpost_level>0 && outpost_owner!=-1` → `{owner:[tile]}`。無狀態每 INFRA 重建。**OutpostOwnerBank 不動。**

## ★兩個實作必守（reviewer 點出）
1. **determinism 顯式 sort**：`for owner_tid in owner_tiles.keys()` 前**必 `.sort()`**（team_id 升序）——spec §5 意圖已鎖,pseudocode 未顯示 sort,你要顯式加,否則 dict hash 序 → 非 byte-identical。tiles 累進走 `state.world.tiles` 既有固定 key 序（穩）。
2. **節流移除是 deliberate（別 re-throttle）**：舊 faction 迴圈的 `return`=每 INFRA tick 每 faction 最多 1 施工動作（全 member 共享節流）。新 per-owner-team 每隊獨立 evaluate→同 tick 同 faction 多隊可各派工。**這是預期行為變（spec §7 watch）**——`_evaluate_infrastructure` 內部各分支的 `return`（每隊自己最多 1 動作/tick）保留,但**別在遍歷迴圈外加全域 return/節流** re-throttle 回舊行為。

## 不動（spec §6）
成本/slot/地形/allowed_outpost（farming civilian-only 不變）/crude camp/is_military/INFRA_INTERVAL/選址（`_evaluate_new_outpost_location`）。martial 獨立隊 military 營 farming 禁本輪不修。

## TDD + 驗收
- 加 headless_test 斷言：獨立隊擁 civilian outpost + hungry → INFRA tick 後能 dispatch farming（farming_level 0→建造中/>0）;範圍鎖:隊不對非自有 outpost 動工。
- 完成 → handback **to:measurer**（驗收見 spec §驗收法：default.json 12mo 死鎖解/farming_level/established/determinism/perf/faction 不回歸/融合閘）。

## 註
- 這是絕境經濟 arc 結構根修,非只 world-gen。世界態改（獨立隊食物 bootstrap）。
- 卡點 → to:systems（別問 user）。
