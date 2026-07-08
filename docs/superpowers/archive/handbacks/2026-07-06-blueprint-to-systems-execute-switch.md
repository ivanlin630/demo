---
from: blueprint
to: systems
status: consumed
topic: ★執行 pipeline 切換(用戶催「工作流改了沒」)——combat_decisive 改當第一個pipeline dogfood(非舊流程)→「在飛的零」滿足→立刻執行06 checklist;這是你最後一個舊流程動作,做完setup交棒orchestrator;CLAUDE.md段用戶已核准照落
---

# 執行 pipeline 切換（現在）

用戶催「工作流改了沒」。我們在切點了。**combat_decisive 重定為第一個 pipeline dogfood（非舊流程任務）** → 切換 checklist「在飛的零」滿足 → 立刻執行。

## 你的最後一個舊流程動作：執行 06 切換 checklist
- [ ] process-doc（`00_roles`/`01_architect`/`03_implementer`）更新指向 orchestrator 模型；`06_pipeline_orchestration` 由草案轉生效。
- [ ] **落 CLAUDE.md「Session 工作流」段**（用戶已核准照落，無改字——見 06 doc 附錄）。
- [ ] auto-memory 單寫者改**藍圖 orchestrator session**（`00_roles §auto-memory` 改）。
- [ ] 撤 `.git/hooks/pre-commit` → 憲法閘+融合驗+framework 併 orchestrator merge-gate 步。
- [ ] progress.md 記憲法 arc 完成 + pipeline 切換。
- 做完＝交棒。持久系統 session 功成身退（用戶不再開該終端）。

## 切換後
- 用戶只跟藍圖 orchestrator 談 WHAT。
- **第一個 pipeline dogfood = combat_decisive 根因診斷**（小/安全，驗流程）→ 然後脊椎②戰力欄。
- 我 spawn 系統/實作/QA subagent，git doc=共享大腦，不再人肉轉 handback。

## 確認回我
執行完 checklist 回一封（consumed 本 handback + 列已落項）。之後我接手 orchestrate。若 checklist 任何項卡住（如某 doc 需我 WHAT 確認）回報。

## 保留（切換不破）
QA 獨立 adversarial / 用戶最終驗收 / 深工附厚 context / doc audit trail / 單一 owner（orchestrator 序列化）。

## ★併入 06 doc：context 模型（用戶問「工作全擠 orchestrator context 嗎」，記下防未來忘）
落 checklist 時把這段加進 `06_pipeline_orchestration.md`（設計 rationale）：

> **為何 orchestrator context 不爆：**
> 1. **subagent 工作 context 隔離**：subagent 讀檔/跑測/iterate 全在**它自己 context**，orchestrator 只收**最終 result**（一則 return）→ 重活不進 orchestrator context。這是 orchestration 省 context 的核心（vs 全 inline 一個 session）。
> 2. **git doc = 真相持久層，非 orchestrator context**：game-design/invariants/progress/handback 是狀態所在。orchestrator context 長→harness summarize；被壓縮/重置**不 lossy**，re-read doc 復原。
> 3. ∴ **docs-as-brain 是 context 抗壓機制、非附帶**：任何單一 context（含 orchestrator）滿了都不致命，真相在檔。orchestrator 某種程度也可替換。
> 4. **真成本點 = 深 review**（拉 diff/細節進 orchestrator 驗 QA subagent）→ 聚焦管理：subagent 回傳要求**精簡結構化**（不 dump）、狀態勤 offload doc、重活丟 subagent。長 arc = 一段段做+勤寫 doc+週期瘦身。
