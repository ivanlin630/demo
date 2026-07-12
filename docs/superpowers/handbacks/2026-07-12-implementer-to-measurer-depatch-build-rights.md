---
from: implementer
to: measurer
status: consumed
topic: de-patch建造權 實作交付 — faction-leader-team-only→outpost-owner-team遍歷;branch feat/depatch-build-rights已push,待驗收
---
# Hand Back: de-patch 建造權

branch `feat/depatch-build-rights`（已 push，疊 origin/main base b6ac5b5）。spec `docs/superpowers/specs/2026-07-12-depatch-build-rights-technical.md`。

## 實作摘要
- `scripts/simulation/faction_ai_system.gd`：
  - `_evaluate_all_body`：移除 faction 迴圈內 per-leader-team infra call（原 :641-642）；faction 迴圈後新增 INFRA cadence 區塊——建 owner→tiles 索引 → **`owner_ids.sort()`（team_id 升序，顯式 determinism）** → 遍歷擁 outpost 的 team 各評自有 infra。
  - `_build_owner_outpost_index(state)`：掃 `state.world.tiles` 一趟建 `{owner:[HexTileData]}`，`outpost_level>0 && outpost_owner!=-1`；無狀態每 INFRA 重建。OutpostOwnerBank 不動。
  - `_evaluate_infrastructure(state, faction)` → `(state, builder_team, owned_tiles)`：`leader_team`→`builder_team`；(1)(2) tile 掃改只走 `owned_tiles`；(2) **移除同-faction 跨隊代評段**（原 :2741-2743），owner_team=builder_team；player skip 改判 builder_team.leader_id。labor 機制（resident/subteam 出工）保留。節流未 re-throttle（spec §2 守則2：per-owner-team 各自 max 1 動作/tick）。
- `scripts/debug/headless_test.gd`：3 呼叫端更新新簽名（用 `_build_owner_outpost_index(state).get(tid,[])`）；+2 新 test：
  - `_test_depatch_independent_team_builds_farm`：獨立隊(faction_id=-1,不在任何 faction) 擁 civilian outpost + 飢餓 → evaluate_all(INFRA tick) → farming 施工啟動（tile.outpost_level=3 隔離升級路徑）。
  - `_test_depatch_scope_lock_no_foreign_build`：team0 無自有 outpost → 不對 team9 outpost 動工。
  - 兩者 PASS。

## 我方自驗（非驗收，供參）
- headless `=== DONE ===`，**新增 0 SCRIPT ERROR**。3 個 pre-existing assert（`_test_p2a_survival_terms` join weight / combat_target≠-1 197隊 / rung 展可）在 **origin/main baseline 亦完全相同**（我起 `_baseline_main` worktree 對照跑，3=3 同集）→ **非本 slice 回歸**，請驗收時排除。
- constitution_gate PASS（sites=29，removed=0，不增）。

## 待驗收（spec §驗收法，全你產數字）
1. **死鎖解**：default.json 12mo 深度——獨立隊 farming_level 恆0→有隊>0；established 恆0→有隊立國；attrition 降、終局 pop 升（對照 `worldgen_deep_reference.json` pre-depatch baseline）。
2. **corroborate**（平行 pre-build，若未做）：pre-depatch 獨立隊 farming_level 恆0 vs faction 隊 >0。
3. **determinism**：同 seed byte-identical（含新遍歷 sort）。
4. **perf**：infra phase 計時 ≤ 原級（§4；超標則 systems 加 §4 stagger）。
5. **faction 不回歸**：據點發展數/established 不塌不暴增（§7 行為變 watch，非 bug）。
6. **融合閘**：coin/framework/sanity 綠（constitution 我已跑綠）。

## 連動風險
- `outpost proliferation`（§7）：任何擁 outpost 隊可蓋第二個 → 驗 outpost 總數不失控（OUTPOST_DENSITY_CAP 仍守）。
- `infra phase 尖峰`：隊數增（獨立隊納入）同 INFRA tick 全評 → 若尖峰超標，systems 加 stagger（spec §4 SHOULD，我本輪未加，等你量）。
- martial 獨立隊 military 營 farming 禁本輪不修（spec §WHAT#3，留下輪）。
