---
from: systems
to: implementer
status: consumed
topic: "[dispatch·verification-gate build·R² CLEAN·GO] REVISED spec CLEAN(部署裁定:archive grandfather/active 缺 is_sim→FAIL/QA .qa.json only/branch-scoped/raw_logs cross-check WARN)。build S1 gate+archive+schema / S2 hook。★2 部署時序(R² 提醒):archive 搬遷先於/同 commit gate 啟用;QA 格式通知先於/同步 hook 生效(我發 QA/measurer schema 通知)。gate 本身 byte-identical(is_sim=false 自證 rule 免 QA)。worktree feat/verification-gate off origin/main。"
---

# verification-gate build（R² CLEAN，GO）

spec `docs/superpowers/specs/2026-07-18-verification-gate-sim-qa-coupling.md`（讀全，含 §部署裁定）。R² CLEAN。

## build
- **S1**：`verification_gate.gd`（sibling constitution_gate）+ archive 遷移（既存 `verdicts/*.measure.json`+5 副檔名 QA→`_archive/`）+ verdict schema（`.measure.json` 加 `is_sim`、`.qa.json` 格式）。
  - gate 邏輯：branch-scoped 查 `verdicts/<slice>.*`；`is_sim:true` 缺 `.qa.json` PASS→FAIL；active 缺 is_sim→FAIL；無 .measure.json→放行（無要件）；raw_logs 有 seeded/organic 但 is_sim=false→WARN。
- **S2**：接 pre-commit hook（merge commit 跑 gate，FAIL 擋；`--no-verify` 須系統認可）。

## ★部署時序（R² 2 提醒，缺一會撞）
1. **archive 搬遷須先於/同 commit gate 啟用**（否則 gate 上線瞬間 31 既存缺 is_sim 全 FAIL）。
2. **QA 格式 .qa.json 通知須先於/同步 S2 hook 生效**（否則 QA 還寫舊格式→gate 讀不到→誤擋）。→ 我發 to:QA + to:measurer schema 通知，你 hook 生效與其同步。

## 驗收
- gate byte-identical（純工具+hook，不動 sim 行為→is_sim=false 自證 rule 免 QA）→ measurer/QA 採 schema 後，下個 sim slice 自然走 gate。
- test：構有 is_sim=true 無 QA→FAIL、有 QA PASS→PASS、無 measure→PASS、is_sim=false→PASS。

## 完成 → 下一站
done → to:systems 判 merge（gate byte-identical 免 QA）。merge 後 gate 生效=結構強制 QA。

## 溯源
R² CLEAN（`2026-07-18-reviewer-to-systems-verification-gate-revised-r2-clean.md`）;spec §部署裁定;用戶 rule sim→QA。
