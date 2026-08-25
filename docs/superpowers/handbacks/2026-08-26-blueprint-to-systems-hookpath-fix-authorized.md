---
from: blueprint
to: systems
status: open
topic: ★授權執行(用戶親交hash 9aba7278+審後「發」):hook路徑修——settings.json 7處+session-role.sh三條Monitor arm指令改$CLAUDE_PROJECT_DIR絕對路徑;診斷三點blueprint全實測驗過;注意9aba7278只落了note,實檔還沒改
---

# 授權:hook 路徑修(9aba7278 案)

**授權鏈**:影子 session 落地診斷 note `docs/notes/2026-08-26-hook-path-and-worktree-skew.md` @9aba7278 → 用戶交我審 → 我實測驗過 → 用戶裁「發」。**注意:那顆 commit 只有 note,`settings.json` 實檔仍 7 處相對路徑(我驗過),修還沒做。**

## 我驗過的三點(全屬實)
1. settings.json 8 支只 1 支絕對——worktree session 裡 bash-guard/layer-check 整段失效(File not found)。
2. worktree hooks=checkout 快照:workshop-followthrough 14/20 支,其 inbox-watch grep「換血/一律搶佔」=0 命中=舊版=在那裡 arm 就是殭屍製造機;HOLD 批 #1 只修了 main 份。
3. session-role.sh:77/95/97 三條 Monitor arm 指令也相對——settings 修了只堵一半。

## 執行(照 note 原案,~10 行)
- settings.json 7 處 → `bash "$CLAUDE_PROJECT_DIR/.claude/hooks/xxx.sh"`
- session-role.sh 三條 arm 指令 → 同樣絕對化(inbox-watch/tg_poll+config.local/watchdog;tg 那條連 `tools/telegram/` 路徑一起)
- 效果=永遠跑 main 那份,worktree 快照歪斜源頭消滅,不用同步各 worktree。
- 驗法:worktree cwd 下模擬跑一次 bash-guard 路徑解析+看 implementer 下次開場 arm 輸出是不是新碼「一律換血」句。

小改動不開暫停窗,改完各角色**下次** arm/重觸自然吃到;implementer 現役 session 若在 worktree 已 arm 舊版,改完通知他重 arm 一次換血。完成回信。讀完改 consumed。
