# Harness 功能基準（2026-09-17）——給「有啥新功能」做 diff 用

status: NOTE（盤點，非裁定）
from: 影子 blueprint session
用法: 下次用戶問「有啥新功能」，拿當下工具清單對這份，多出來的＝新。每次 diff 後更新日期與清單。

## 工具（本 session 看得到的）
| 類 | 工具 | 工作流有沒有在用 | 備註 |
|---|---|---|---|
| 跨 session | **SendMessage**（named pipe 直推）、ListAgents | 正藍圖已開始用（廣播式） | 可當門鈴取代 inbox-watch 送達；無紀錄、定址靠 session 名 |
| 排程 | **ScheduleWakeup**（一次性 60s～1h）、**CronCreate/List/Delete**（週期） | 沒用 | 每次醒＝一回合＝重讀 context；不適合取代安靜 bash 迴圈 |
| 常駐 | Monitor（persistent bash） | inbox-watch／watchdog／Telegram | 管道會斷（殭屍族 bug 來源） |
| 多 agent | Agent（fork／general／Explore／Plan／caveman 三型）、**Workflow**（腳本編排 pipeline/parallel） | langgraph 機器少用；Workflow 沒用 | Workflow 需用戶明說才可跑 |
| 對用戶 | **SendUserFile**（推檔到手機）、PushNotification、Artifact（可發佈頁、含 db/assets/comments） | SendUserFile 今天開始用 | Artifact 可做玩家介面原型／量測儀表板 |
| 遠端 | RemoteTrigger、/remote-control | 用戶今天開了 remote-control | |
| 其他 | DesignSync、EnterWorktree/ExitWorktree、ToolSearch（延遲載入工具）、SendFeedback、ReportFindings | worktree 手動管 | EnterWorktree 可替代手工 `.worktrees/` 流程 |

## 模型／環境
- Claude 5 家族：Fable 5.1（本 session）、Opus 5、Sonnet 5、Haiku 4.5。安全機制可能把 Fable 自動降 Opus（9/08 撞過，REPL/TCP 字眼）。
- prompt cache TTL 1h（session 級）。
- 記憶：auto-memory 目錄，單寫者＝systems（影子禁寫）。

## 今天討論過但「先不動」的
- 門鈴換 push（SendMessage 取代 inbox-watch 送達；信留 git）
- 沒寫信兩修法：Stop hook 查「宣告 vs 新檔」／`tools/handback.sh` 一指令寫信
- watchdog 分不出「沒送到」vs「送到但配額卡住」
- 水管／協議盤點＋退役條件
