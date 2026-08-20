# Telegram 雙向 bridge（本地工具，不進 git）

藍圖 session ↔ 手機。遠端免盯 CLI:沒響=鏈自跑、響=你在 Telegram 回。

## 檔案
- `config.local.sh` — 機密(TG_TOKEN / TG_CHAT_ID)。**gitignored、絕不 commit**。
- `send.sh` — 出站。ASCII: `send.sh "msg"`；中文: `send.sh --file <utf8檔>`(避 Windows CP950)。
- `tg_poll.py` — 進站輪詢(stdlib,長輪詢 25s,濾 chat id)。Monitor 用。
- `fetch_chat_id.sh` — 首次抓 chat id(你私訊 bot 後跑)。
- `.tg_last_id` — 進站 offset 狀態(自動)。

## 出站(我推你)
只在**真需你裁**時推(WHAT fork / 授權 / QA 綠 / 喬不攏)。角色間 handback 我自主處理、不推。
機制:Write UTF-8 訊息檔 → `send.sh --file <檔>`。

## 進站(你驅動我)— ★開場必 arm
```
Monitor(command="source tools/telegram/config.local.sh && python tools/telegram/tg_poll.py",
        persistent=true, description="Telegram 進站(用戶訊息喚醒 blueprint)")
```
你的訊息 → stdout `📱 [Telegram] 用戶: <text>` → 喚醒藍圖 session → 當用戶輸入處理 → `send.sh` 回。
**只 blueprint 一個 session poll**(getUpdates offset 消費、多 poller 互搶)。其他角色走 git 信箱。

## 安全
- token = 遠端遙控鑰匙(能驅動跑 code/git 的 session)。顧好、疑洩走 @BotFather `/revoke`。
- poller 濾 `TG_CHAT_ID` only,別的 chat 打進來忽略。

## 單例守衛(重複 arm 安全)
三腳本(tg_poll.py / watchdog.sh / inbox-watch.sh)皆 heartbeat lock:開場見新鮮 lock(<POLL+120s)=已有實例→自退。∴ **重複 arm 冪等**(compact 後重觸也不會兩個 poller 互搶)。lock: `.tg_poll.lock` / `.claude/hooks/.watchdog.lock` / `.inbox-watch.<role>.lock`(自動)。

## caveat
- 進站只在本 session + Monitor 活著時通(session 死→重啟後重 arm,冪等安全)。出站無此限。
- 延遲 ~20s(長輪詢)。
- lock stale 門檻 = POLL+120s;真死(crash)後隔這麼久新實例才接手(reopen 通常遠超此,無妨)。
