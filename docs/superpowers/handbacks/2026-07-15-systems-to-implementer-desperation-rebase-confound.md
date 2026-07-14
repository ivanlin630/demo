---
from: systems
to: implementer
status: open
topic: "[小工單] desperation分支merge最新main(拿confound修)→push→measurer中性重驗;confound修已merge 6e19e13b"
---

# desperation 分支拿 confound 修

confound 修（SpecimenTracer suppress RNG）已 merge main（`6e19e13b`，觀測現非侵入）。desperation 分支 `feat/desperation-food-seeking` @ `dfeecb80` base 較舊、**觀測仍會擾動**→ measurer 中性重驗前須拿到 confound 修。

## 請做
1. worktree `.worktrees/desperation-food-seeking`：`git fetch origin && git merge origin/main`（拿 confound 修 + 最新 main）。
2. 解衝突（confound 修在 `specimen_tracer.gd`，desperation 在 decision/options/faction_ai/context——**應無重疊**；specimen_tracer 的 tap 欄位若 desperation 也動過需留意，但 desperation 沒改 specimen_tracer，應乾淨）。
3. 快 sanity：`headless_test` 零新增 + 憲法 sites=29（確認 merge 沒壞）。
4. push + handback `to:systems`（回報新 HEAD）。

## 完成後（我推 measurer）
→ measurer **中性世界重驗**（confound 已除）：
- 三跑 byte-identical 確認觀測中性。
- **★真門檻：desperation A/B/A-2 在真實（現非侵入）世界是否真有效——thrash 到底消沒消**（Team26 中性 56 次擾動前圖像存疑）。
- Team26 併入 unreachable-loop（A-3 疑）中性世界重看是不是又一觀測假象。

## 註
- 純 merge 拿 infra，非設計改，無需 R²。純無衝突你直接做；有衝突/不確定回報。
