---
from: systems
to: implementer
status: consumed
topic: "[dispatch·seam#1 S1] registry 化 applicable()+to_task()——option→data entry，加 option=1 registry entry。★byte-identical 純重構(同 pool 同序 + ★Probe 計數也 byte-identical)。R② CLEAN。TDD + git per-slice。worktree feat/seam1-registry off origin/main。含 3 caveat(觀測副作用逐條保/subteam 前置閘統一套/S1 不碰 threat/survival/ambient dispatch)。"
---

# S1 dispatch：registry 化 applicable()+to_task()（byte-identical 純重構）

## scope（只做 S1，不碰收斂）
spec `docs/superpowers/specs/2026-07-17-seam1-control-flow-convergence.md`（讀 §目標 REVISED + §交付切片 S1）。
把 `scripts/simulation/decision/options.gd` 的 `applicable()` + `to_task()` 內 **per-option match/switch 分支** 折進 REGISTRY data entry（每 option 一筆 `{applicable_pred, term_weights, to_task}` 或等價）。目標：**加一個新 option = 加 registry 1 entry**（非改多處 match）= 擴充性 proof。
- **只做 registry 化**。**不動** rank_scored/rank_survival/rank_threat/rank_ambient dispatch、不收斂、不退役任何路。threat/survival/ambient 全不碰（收斂是 S2/threat-oracle，非 S1）。

## ★byte-identical 硬要求（純重構，同 pool 同序 + 觀測同）
1. **同 pool 同序**：`applicable()` 產出的 option list 順序/內容零變（REGISTRY 已是 Dictionary，GDScript4 保插入序；維持 `for opt in REGISTRY` 迭代序）。
2. **★caveat①：Probe 副作用逐條精確保留**（撞觀測不變量）。`applicable()` match 分支內嵌診斷 `Probe.bump`（如 `occupy.ctx_hastarget`/`occupy.appl_kill_pop`/`occupy.applicable` 約 `options.gd:102-108`、`produce.appl_kill_nofacility` :76 等）——registry 化抽 predicate 時**必逐條原位保留這些 bump**，非只保 `out.append`。**measurer 會驗 Probe 計數 byte-identical，非只 dispatch 結果**。抽 lambda 時 Probe 副作用要在對的分支點 fire。
3. **★caveat②：subteam 共用前置閘統一套用**。`applicable()` 頂部 `if ctx.is_subteam and opt in STRATEGIC_SELFINIT_SET: continue`（約 `options.gd:60-64`）=**跨所有 entry 的共用前置**。registry 化須讓它**在每 entry predicate 之前統一套一次**（在迭代框架層，非塞進每個 entry 的 pred 各自重判）——否則未來加 option 忘記重複=靜默破 A2a 不變量。

## TDD（testing 先）
1. 先寫/跑 characterization test：現況 `applicable()`/`to_task()` 對一組代表 ctx（含 subteam ctx、各 option 觸發 ctx）的**輸出 + Probe 計數** snapshot。
2. registry 化重構。
3. snapshot 綠（輸出 + Probe 計數皆不變）。
4. 加擴充 proof test：新增一個 dummy option = 只加 1 registry entry，證 `applicable()`/`to_task()` 自動納入（不改其他處）。
5. **git commit per green step**（安全網=git 非 session liveness；每綠即 commit，訊息帶 slice 標記）。

## 工作區
- worktree `feat/seam1-registry` off **origin/main**（scripts/ code base 已 current，framework/need-oracle/gate v2 全在 origin/main；main 僅 2 docs commit 未 push 不影響 code）。
- handback 回寫 **main mailbox 絕對路徑** `A:\GDS\demo\docs\superpowers\handbacks\`，to:systems status:open。

## 完成 → 下一站
S1 done + 綠 → handback to:measurer（byte-identical 驗:輸出 + ★Probe 計數 + 擴充 proof）。measurer 綠 → to:systems 判 merge。
**S2（survival/ambient 收斂）不在本 dispatch**——待 systems 逐路驗 plan（previous_task vs current_option churn-guard 分岐，spec S1 caveat③）明列後另送 R②。

## 溯源
spec REVISED（R② CLEAN 2026-07-17，reviewer `2026-07-17-reviewer-to-systems-seam1-r2-clean.md`）；[[project_unification_matrix]] stream② seam#1；[[feedback_full_transient_observability]]（Probe byte-identical）。
