---
from: blueprint
to: blueprint
status: consumed
topic: 現狀交接——多終端工作流全重建+A2b待量測守衛;本session非法(無role)已關,重開00接
---

# 現狀（2026-07-09，重開 00 接）

> 上一個 session 是無 SESSION_ROLE 的遺留 session（de-facto 幹藍圖活），已關。你是正式 00。先 `arm 信箱待命`。

## ★立刻要做（A2b 卡在這）
A2b（leader 併入引擎）core impl **done**（`feat/A2b`，leader_bypass→0）。**卡在守衛量測**：
- 量測員只產了標準數字（HOB/const/sanity），**把 spec §驗收法守衛 A/B（leader_conquest_count、tribute_treasury_delta）推給 QA**→ QA 已寫 `to:measurer` 退回（信箱有 `qa-to-measurer-A2b-verification-gap.md`）。
- **下一步**：measurer（**不是 QA**）跑守衛 A/B 的 seeded sim 產 count/delta → QA 判門檻（A:征服稀有非零 / B:遠距貢賦>0）→ merge。
- A2b 在 `feat/A2b` + `origin/feat/A2b` 備份。續驗要 `git worktree add .worktrees/A2b feat/A2b`（★別在主目錄 checkout）。

## 待你裁的設計
- **ctx 汙染三角**（零鍵入/warm-redo/零汙染 三選二）：現狀=warm+零鍵入(auto-compact 封頂,汙染有限因每task重讀plan)。替代=subagent-per-task(零汙染但redo輕冷啟)。**先跑現狀觀察,真串味再換。**
- A2b 完後：續 A2c（5 平行權威）或別的。A2b/A2c 定義見 memory [[project_reverse_engineering_arc]]。

## 工作流本 session 全重建（都 committed main + memory [[feedback_mailbox_trigger]]）
- **統一 main mailbox**：唯一實體資料夾 `<main-repo>/docs/superpowers/handbacks/`，可見性靠實體共享**與 branch 無關**。hook 用 git-common-dir 指 main-repo → **6 角色全 arm、worktree implementer 也 watch 同一 mailbox → 每站自動讀**。
- **6 角色**：bp/systems/reviewer/qa/measurer（留 main dir）+ implementer（worktree 改 code）。**全 handback X-to-Y frontmatter**（無 to: 掃不到）。
- **measurer/QA 留 main dir 不 checkout**：measurer `godot --path .worktrees/<slice>`、QA `git diff/show`。
- **implementer lifecycle**：主目錄 standby(恆 main)→進 worktree 做→handback→**hold warm 等 01 裁決**（完成判定歸 01 非自判）→ `[DONE]`收尾(Stop-hook 逼 consume/cd/arm，ctx 靠 auto-compact 不手動清) / `[REDO]`warm 直接改。
- **★事故教訓**：共用工作樹原地 `git checkout` 會換掉所有共用 session 的 branch → commit 落錯支。**鐵律：別在主目錄 checkout**。本 session 已把誤落 feat/A2b 的 workflow commit 搬回 main。
- **haiku 約束**：QA/measurer=haiku 當不了自主終端 → **下游(implementer→measure→qa) 走 LG `--from-impl`**、上游(spec/plan) 走信箱。見 memory。

## 環境
- 主目錄現在 = main（乾淨）。舊 handback 已封存 archive（active mailbox 起跑乾淨）。
- 你關掉本 session 後：`$env:SESSION_ROLE='blueprint'; claude` 重開，第一句 `arm 信箱待命`。
