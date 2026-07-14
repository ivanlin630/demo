---
from: systems
to: implementer
status: open
topic: "[DISPATCH] specimen 觀測非侵入化——移LOD-exemption+force_full_hd acceptance+jsonl writer;R②CLEAN;新worktree;TDD"
---

# Dispatch：specimen 觀測非侵入化

spec（讀全文，注意事項在內）：`docs/superpowers/specs/2026-07-14-specimen-observer-noninvasive.md`
R② CLEAN：`docs/superpowers/handbacks/2026-07-14-reviewer-to-systems-specimen-noninvasive-r2-clean.md`（機制+judged-world 授權皆驗）
blueprint 裁定 A：`2026-07-14-blueprint-to-systems-judged-world-verdict.md`

## worktree
- 新 branch `feat/specimen-observer-noninvasive`，worktree `.worktrees/specimen-observer-noninvasive`，base = 最新 origin/main（`git fetch` 後 `775c7900` 或更新）。
- ⚠ **base 須含最新 main**（含本 spec）——spawn worktree 前確認 `git fetch origin && git log origin/main -1`。

## 觸及檔（3 檔）
1. **`scripts/simulation/sim_runner.gd`（Fix 1 移 LOD-exemption）**：
   - `_get_near_teams`（~:458）：移除 `tid in state.specimen_team_ids or` → 只留 `dist <= LOD_NEAR_RADIUS`。
   - `_get_far_teams`（~:470）：移除 `if tid in specimen_team_ids: continue` 那兩行。
   - player 豁免不動。
2. **`scripts/debug/specimen_tracer.gd`（Fix 3 jsonl writer）**：
   - 加 `static func write_jsonl(path: String) -> void`：`entries` 逐條寫一行 JSON（欄位鏡射 `_print_entry`：tick/team_id/想什麼(intent+candidates+beliefs)/做什麼(winner/task/target)/狀態(_snapshot 全欄)）。純讀 entries + 寫檔，零 state mutation。
   - ★**死隊 trace 不遺漏**：append 模式跨 flush 累積，或在 extinct cleanup 前 dump——你定機制，確保死隊死前最後決策在檔內。
3. **故事-trace 床（`scripts/debug/reeval_attribution_bed.gd` / `single_team_trace_bed.gd` 或新 story bed）**：設 `SimRunner.force_full_hd = true` + 呼 `SpecimenTracer.write_jsonl(<path>)` 輸出。

## TDD（先 red）
1. **★觀測非侵入 failing test**（核心）：同 seed force_full_hd，`specimen_team_ids=[A]` vs `=[B]` 兩跑 → 斷言**除 SpecimenTracer entries 外，世界狀態/其他隊軌跡 byte-identical**（換 specimen 不換世界）。修前紅（LOD-exemption→specimen 升 near→RNG 岔開→世界不同）；修後綠。
2. jsonl 產出：force_full_hd + specimen=某隊 → `write_jsonl` 產非空檔、含決策時序、含死隊最後決策。
3. 標準 sanity：headless ≥1000 tick 零新增（main 已知 3 assertion=baseline）；憲法閘 sites 不變；determinism byte-identical。

## 驗收（spec §驗收法為準，measurer 全-HD 跑）
觀測非侵入(byte-identical) / 完整 trace / 故事性可判 / **headline 全-HD 重跑**(execlock b962fc74 vs base 在 force_full_hd,取代作廢 LOD 數) / 不回歸。

## 完成判定
= systems + reviewer/QA，**非 implementer 自判**。code commit 後寫 handback（`to:systems status:open`）→ 我收+驗+推 measurer（全-HD 跑）。
★★**scope/設計有疑義→寫 `to:systems` 提議,不自改+自標 REDO（見前 provenance-flag）**。
