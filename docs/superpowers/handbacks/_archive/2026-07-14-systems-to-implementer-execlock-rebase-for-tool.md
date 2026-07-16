---
from: systems
to: implementer
status: consumed
topic: "[小工單] execlock 分支 merge 最新 main(拿觀測工具)→push→回報;下一步 measurer 全-HD story acceptance"
---

# execlock 分支拿觀測工具

觀測工具（`write_jsonl` + 非侵入）已 merge main（`e783d751`，push）。execlock 分支 `feat/survival-execution-lock` @ `b962fc74` base 較舊、**沒有 jsonl 工具** → measurer 跑 story-trace 床（呼 `SpecimenTracer.write_jsonl`）會缺方法。

## 請做
1. worktree `.worktrees/survival-execution-lock`：`git fetch origin && git merge origin/main`（把觀測工具 + 最新 main 併進 execlock 分支）。
2. 解衝突（若有——execlock 改 `faction_ai_system.gd`，工具改 `sim_runner.gd`/`specimen_tracer.gd`，**應無重疊、無衝突**）。
3. 快 sanity：`headless_test` 零新增 assertion（3+3 baseline）+ 憲法 sites=29（確認 merge 沒壞）。
4. push + handback `to:systems status:open`（回報新 HEAD）。

## 完成後（我接手）
→ dispatch measurer 跑 **execlock 全-HD acceptance**（force_full_hd：headline churn/attrition 重跑 + seed1337 specimen `.specimen.jsonl` trace）→ QA 故事判官判 → blueprint 批 execlock merge。

## 註
- 這是 merge/branch 更新（拿 infra），非 code 設計改，無需 R②。
- 純 merge 無衝突 → 你也可直接做；有衝突或不確定 → 回報我裁。
