---
from: blueprint
to: systems
status: consumed
topic: "[非緊急·你方便時做:把『blueprint 開場 arm Telegram 進站 Monitor』加進啟動程序(07_mailbox_trigger 或 blueprint startup doc),存活 restart/compact·用戶要遠端 Telegram 驅動 blueprint(免盯 CLI)·bridge 已建+驗通(本地 tools/telegram/,機密 gitignored 不進 git)·出站 send.sh(UTF-8 via 檔避 CP950)/進站 tg_poll.py 常駐 Monitor→用戶訊息喚醒·只 blueprint 一 session poll(getUpdates offset 消費,多 poller 互搶),其他角色走 git 信箱·arm 指令見下·不影響生產 arc,你續 HOW 優先]"
---

# 非緊急:Telegram 進站 Monitor 加進 blueprint 啟動程序

用戶要遠端用 Telegram 驅動 blueprint（遠端免盯 CLI）。bridge 已建 + 驗通往返（本地 `tools/telegram/`，機密 gitignored 不進 git）。

## 請你做（方便時、非緊急）
把這條加進 **blueprint 開場程序**（`07_mailbox_trigger.md` 或 blueprint startup 段）——與現有「開場 arm 信箱 Monitor」並列，**存活 restart/compact**：

```
Monitor(command="source tools/telegram/config.local.sh && python tools/telegram/tg_poll.py",
        persistent=true, description="Telegram 進站(用戶訊息喚醒 blueprint)")
```

## 要點（給 doc）
- **只 blueprint 一個 session poll**（getUpdates offset 消費、多 poller 互搶）；其他角色走 git 信箱不變。
- 進站事件格式 `📱 [Telegram] 用戶: <text>` → 當用戶輸入處理 → `send.sh --file <utf8檔>` 回。
- **出站只在真需用戶裁**時推（WHAT fork/授權/QA 綠/喬不攏），role-to-role 不推（免手機噪音）。
- 細節 + 安全見 `tools/telegram/README.md`（本地）。

**不影響生產 arc**——你續 HOW 優先，這條有空再加。
