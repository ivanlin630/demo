# Session 交接（2026-06-19 #3，系統 session）

> 給重開後新 session（**用 `$env:SESSION_ROLE='systems'; claude` 開**）。承接 #2（`2026-06-19-session-handoff-2.md`）。
> 本 session 無 game code 改動，只建**角色分工機制** + 框架債診斷。main @ `34c5877`，全綠。

## 你是誰

**系統(Systems, HOW) session。** 開頭 SessionStart hook 會注入角色 + statusline 顯 `🔧 系統`。
先讀 `docs/process/00_roles.md`（角色憲法）。

- 你 owner：`invariants.md` / 流程 docs / `progress.md` / `known_issues.md` / `CLAUDE.md` / `docs/process/*` / **auto-memory（單寫者）**。
- 不碰 `game-design.md`（藍圖 owner）。
- 你管 HOW：seam / 契約 / 所有權圖 / invariant / tick pipeline / 行政流程。

## 本 session 做了什麼（全已 commit `34c5877`）

1. **診斷瓶頸**：「討論>>實作」根因 = 加東西=大改（核心缺擴充縫）+ build-first-decide-later（dormant code）。非流程太重。詳 memory `[[project_framework_seams]]`。
2. **建雙設計腦角色分工**（藍圖 WHAT / 系統 HOW），解「同目錄兩個 01 建築師撞檔 + 定不一致 invariant」。`docs/process/00_roles.md` + `CLAUDE.md` 更新。
3. **身分綁定機制**（`.claude/` 本地、gitignore 未進版控）：
   - `.claude/hooks/session-role.sh`：SessionStart 依 `$SESSION_ROLE` 注入角色 context
   - `.claude/hooks/session-role-statusline.sh`：statusline 顯角色 + dir/branch/model
   - `.claude/settings.json`：+SessionStart +statusLine（原 PreToolUse layer-check 保留）
   - 開窗：`$env:SESSION_ROLE='systems'`（或 `blueprint`）`; claude`
4. **memory 寫 2 條**（我=單寫者）：`feedback_session_roles`、`project_framework_seams`。

## 框架債（系統領域 backlog，排序）

來自 `[[project_framework_seams]]`，**先因後果：框架修好 → 行政流程自動變輕**。

1. **清 dormant**（最快）：`_check_night_raid`(interaction_system) + `get_goal_task_override`(NpcAiSystem) 實作完無 caller。鐵則=不准 land 沒 caller 的函數 → 接或刪（git 留著要時撿）。progress.md:211-212 有記。
2. **anon 2c-2 收尾**：唯一有完成線的在飛統一。`anon_exp`(team_data:125) 仍舊 scalar dict 未 cohort 化 → team_data:117-141 shim 拆不掉。做完=刪 3 個 getter shim。見 `[[project_anon_cohort_refactor]]`。
3. **寫資料所有權圖**：每概念單一 owner（value→TradeValuation、anon→AnonCohort 已有；population/reputation/intel 缺明文）。砍最多未來討論。
4. **補 sim_runner pipeline 縫**：加 system 現要改 5 處 + near/far 雙軌漂移。改宣告式 `{phase,cadence}` pipeline。

## #2 交接的功能 backlog（仍有效）

完整 14 條在 `2026-06-19-session-handoff-2.md`。系統 session 可直接動的孤立 bug：
- **#4 B-1 收留撞 pop_cap 守恆破**（`player_command_system:757/760/763`）：先用意圖值算 cost/joined 再 merge，capacity<=0 時食物憑空蒸發 + msg 謊報。修：merge 後量 delta，或 merge 前驗容量。孤立，直接修。
- **#5 A-1 記名招募 TextUI 死路**：recruit menu 在停用的 main.gd，`text_ui_main.gd` 916-977 不消費。修：把 menu 消費搬進 text_ui_main。孤立，直接修。

P6 遭遇戰(#1)、trade offer-board(#3)、戰俘(#2) 等是 spec 級，需 brainstorm。**#1 next step = 先挖 npc_combat vs encounter 分叉定 E-1 範圍**（見 #2 交接 line 49）。

## 起手建議

先 **#4/#5 孤立 bug 直接修**（油門類，純執行，最快見效、卡可玩性），或 **dormant 清理**（框架第一步）。
回歸閘：headless + coin_eq（非 multi drift）。L3 主 session 可直改；L1/L2 走 spec/plan→worktree。

## 未提交
- 本交接 doc。
- `scripts/debug/qa_probe.gd` 仍 untracked（QA 暫時工具，#2 起就在）。

## 工作流提醒（memory 已存）
- 別問技術微決策；用戶戳破假設就停止理論化；ctx ~90% 才提醒交接。
- auto-memory 只你（系統）寫；藍圖/實作走 handback 呈報。
