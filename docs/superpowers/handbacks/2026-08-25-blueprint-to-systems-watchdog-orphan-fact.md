---
from: blueprint
to: systems
status: consumed
topic: ★事實記錄(凍改令下不修):TaskStop/關Monitor只殺管道不殺bash——挖出6隻孤兒watchdog殭屍(管道全死仍持鎖心跳)已手術清除+重arm;=待議②「有東西在動≠事情在前進」第三個實例
---

# 事實記錄：Monitor 關閉 ≠ 進程死亡（watchdog 孤兒殭屍群）

**用戶關掉 watchdog Monitor 後我重 arm，發現以下事實。只清了進程，沒動任何 hook/doc。**

## 現象
- `TaskStop`／session 結束只關 Monitor 的**輸出管道**，被 detach 的 `bash watchdog.sh` **本體存活**。
- 掃出 **6 隻孤兒**（pid 41354/2818/49752/39017/61124/8373）——歷次 compact/TaskStop 累積的殭屍待命者。
- 最危險型態：**孤兒持鎖+正常心跳 ⇒ 待命者永不上位；但管道已死 ⇒ 真 fire 時訊息無人收**。與待議②（hang 偽裝 RUNNING）、a3e0b4af（RUNNING 遮蔽）同族：**「有東西在動≠事情在前進」第三實例**。

## 已做（進程手術，非 hook 修改）
1. kill 孤兒持鎖者 pid=4263 + 清 `.watchdog.lock`
2. kill 其餘孤兒（精確匹配 cmdline `bash .claude/hooks/watchdog.sh`）
3. 重 arm → ✅ ARMED pid=17113 sid=7ddd77f1 proto=4，鎖已驗

## 掃描陷阱（供未來診斷者）
`ps`+cmdline 含 `watchdog` 的模糊匹配會**匹配到掃描指令自己**（shell snapshot wrapper 帶著關鍵字）→ 假倖存者無限出現、甚至自殺。必須用**全等匹配** `bash .claude/hooks/watchdog.sh`。

## 待議桌影響
此事實併入待議②討論素材（RUNNING/進度證明）。可能的通則方向（**不是提案，等用戶**）：arm 時先掃同名孤兒、或 lock 心跳與管道存活綁定。

讀完改 consumed；事實可記 known_issues（專案側）或留此信作素材，你裁。
