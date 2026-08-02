---
from: blueprint
to: systems
status: consumed
topic: "[★記memory(你單寫者)用戶定2026-07-30 watchdog處置協議+worker API-error失效模式·①watchdog響→除非狀態=『等用戶裁』(真blocked在user)否則一律=看狀態+發信問卡住那站角色(主動ping resume),非『查完斷定沒事』(太鬆)亦非自己跳進去修/inline/收work(太過越lane)·②worker會因API error中途死、留WIP檔沒commit/handback=非沒做非永久死=該ping去resume(本次implementer 03:37做完3檔卻API error→5.5h靜默沒收尾;查worktree working-tree WIP才看得到,非committed HEAD)·③blueprint處置stall=看狀態+發信,不碰orchestration機制(worktree清理/派工/inline非藍圖lane)·併feedback_role_boundary_no_inline_cover與feedback_terminal_never_close家族(精化:終端從不關≠session不會API-error死;正解ping resume非誤判死重派也非當沒事)] 記memory用戶定watchdog協議:響→非等用戶裁則一律看狀態+發信問卡住角色resume(別太鬆斷定沒事、別太過跳進修)。worker API-error會留WIP沒收尾=ping resume。blueprint stall處置=看+問不碰機制。"
---

# ★記 memory：watchdog 處置協議 + worker API-error 失效模式（用戶定 2026-07-30）

## 協議（用戶定）
**watchdog 響 → 除非狀態 = 「等用戶裁」（真 blocked 在 user），否則一律：**
1. **看狀態**（查 git worktree working-tree WIP + commit + status + handback，不只 committed HEAD）。
2. **發信問**卡住那站的角色（主動 ping 去 resume）。

**兩個反面都錯**：
- 太鬆：「查一查就斷定沒事」（早幾輪 watchdog 我這樣）。
- 太過：自己跳進去 inline/收 work/派工（越 blueprint lane，orchestration 機制是 systems 的）。

## worker API-error 失效模式（本次坐實）
implementer 03:37 做完 3 檔（config/bed/liveness test）**卻遇 API error → 沒 commit、沒 handback → 5.5h 靜默**。
- **非「沒做」**（WIP 檔在 worktree working-tree，`git status` 看得到、committed HEAD 看不到）。
- **非「永久死」**（終端從不關）。
- = **該 ping 去 resume**（re-trigger 收尾既有 WIP，非誤判死重派丟 work、亦非當沒事空等）。

## blueprint lane
stall 處置 = **看狀態 + 發信問**，**不碰 orchestration 機制**（worktree 清理 / 派工 / inline 皆非藍圖 lane）。

## 家族
精化 [[feedback_terminal_never_close]]（終端從不關 ≠ session 不會 API-error 中途死；正解 ping resume，非誤判死、非當沒事）+ [[feedback_role_boundary_no_inline_cover]]（不越 lane）。建 `feedback_watchdog_check_and_ping` 或併現有。

## 現況
implementer API-error 後 systems 已 re-trigger 收尾既有 3 檔 → commit → 跑 bed → 4 問數回我。我盯 worktree commit + handback 真出現；若再 stall，我照協議「看狀態 + 發信問」（不跳進去修）。

## 溯源
用戶更正 2026-07-30（watchdog 協議 + 剛剛 implementer 是 API error）。
