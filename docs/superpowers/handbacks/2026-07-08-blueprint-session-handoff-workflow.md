---
from: blueprint
to: blueprint
status: open
topic: 交接——A2a merged(perf誤判翻案)+工作流兩軌信箱觸發全建好+A2b設計走查到#1;重開後續走 A2b #2
---

# 交接：A2a 收 + 工作流升級（2026-07-08，重開前）

## 先做這 3 件（重開後）
1. **arm 信箱**：這窗（blueprint）第一句打「arm 信箱待命」→ Monitor 上線接信。
2. **確認狀態列**：頂部應見 `[藍圖 WHAT]` 徽章（全域 statusline，已補 reviewer）。
3. 讀本信 → 消費（改 status: consumed）。

## ✅ 本 session 做完（全 committed + pushed，origin/main 平）
- **A2a merged main `06e10a0`**：子隊決策納統一 DecisionEngine（D7）。**②reject 是誤判、measure-first 翻案**——「360s perf 迴歸」實為 HOB bed 跑 4×warring≈500s 超 wrapper 360s（main 自身也 392s）；A2a 每 tick ≤main 無迴歸；subteam_bypass 11→0 達標。詳 progress「A2a」段 + memory [[project_orchestrator_machine]]。
- **工作流兩軌（用戶定案）**：見 memory [[feedback_mailbox_trigger]] + `docs/process/07_mailbox_trigger.md`。
  - 輕軌=信箱 relay（持久 session + Monitor 主動觸發，`inbox-watch.sh`）；重軌=langgraph 機器。
  - 持久角色 bp/systems/qa/**reviewer**(02 對抗)；implementer 例外(worktree)不 arm。
  - 全域狀態列 `~/.claude/statusline-command.ps1` 補了 reviewer 徽章。
  - ★所有 hook/statusline 在 `.claude/`+`~/.claude/`＝本地單機不進版控（同既有 hook）。

## ★下一步：A2b（Leader 併入引擎）設計走查——被工作流討論打斷，續走 #2
A2 本體剩 A2b(leader)+A2c(平行權威)，見 `docs/superpowers/specs/2026-07-07-reverse-findings.md` line 37。brainstorm skill 進行中：
- **#1 已定＝征服稀有性「湧現自秤」**：刪 FA3 @30/@50 硬優先；征服 util = 野心×機會×readiness×belief敵弱 − 遠征代價，多數 tick 經濟勝→稀有湧現（用戶選）。
- **#2 待定（續此）＝intent/AmbitionLadder(FA2 第二 scorer)怎麼接**：退役融進主引擎 vs **比照 A2a「母團命令當 directive 複用 faction_duty」把 leader intent 當 self-directive 餵 term**（我判大概率照抄 A2a pattern，但要用戶拍板）。我當時正讀 `faction_ai_system.gd:864 select_strategic_intent` 確認語意。
- **#3＝A2c 哪些併秤/哪些降輸入**：依 A2b 定調，序在後。
- 完 3 決策 → spec A2b（走信箱：blueprint 寫方向 → systems 寫 spec → reviewer 審 → 回 blueprint）。

## Follow-up backlog（memory [[project_future_improvements]] / known_issues）
- join-consent-consolidation（3 條 join-player 路 guard/fallthrough bug，A2a scope B 沒碰）。
- HOB/team_trace bed 對 360s gate 太慢（升 timeout 或砍到 2 run，防再誤判）。
- `near.faction_ai` O(N²) 60隊 warring pre-existing → 歸時間統一 wave [[project_time_scale_wave]]。
- 子隊完整抗命（A2a 移了 mid-mission 投機叛逃，藍圖明示接受，完整版延後）。

## Loose ends
- `feat/machine-A2a` 分支 + `.worktrees/machine-A2a` 已 merged，**可清**（低優先，未清）。
- 工作樹 `docs/game-design.md` M = session 開頭既存無關改動（沒碰、沒 commit）；A2a.scope.json M + 若干 verdicts raw txt 是機器產物，未 commit。
