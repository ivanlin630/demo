#!/usr/bin/env python3
# Telegram 進站輪詢 — Monitor 用。新訊息(濾 chat id)→ stdout 一行 → 喚醒 blueprint session。
# 契約:每行 stdout = 一次喚醒。只吐「你 chat id」的訊息。開場 baseline 跳過舊訊息。
# 機密走 env(Monitor 命令先 source config.local.sh)。stdlib only(urllib),零依賴。
import os, sys, json, time, urllib.request, urllib.parse

try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass

TOKEN = os.environ.get("TG_TOKEN", "")
CHAT  = str(os.environ.get("TG_CHAT_ID", ""))
if not TOKEN or not CHAT:
    print("[tg-poll] TG_TOKEN/TG_CHAT_ID 空 → 不啟動", flush=True)
    sys.exit(0)

DIR   = os.path.dirname(os.path.abspath(__file__))
STATE = os.path.join(DIR, ".tg_last_id")
LOCK  = os.path.join(DIR, ".tg_poll.lock")
API   = "https://api.telegram.org/bot%s/getUpdates" % TOKEN

# ★arm 搶佔式（2026-08-21，P5）——不比誰心跳新，比誰後 arm。
# 舊版病：lock 心跳新鮮就 exit ⇒ 舊 poller 只要活著，新的永遠 arm 不起來，唯一出路是手動殺。
# ★這支是最該修的一隻：getUpdates 是【帶 offset 的獨佔消費】——
#   一支「讀取端已死、但進程還在」的 poller 會把用戶的 Telegram 訊息吃掉並丟進虛空，而且不冒煙。
# 決策：同 session 且心跳新鮮 → 安靜退出（覆蓋仍在，已驗）；否則搶佔（新的當家）。
# 迴圈每輪重讀 lock，不是自己就讓位自退（孤兒自己清掉自己）。
STALE = 90
MYSID = os.environ.get("CLAUDE_CODE_SESSION_ID", "")

def read_lock():
    try:
        parts = open(LOCK).read().strip().split("	")
        return parts[0], (parts[1] if len(parts) > 1 else "")
    except Exception:
        return "", ""

_pid, _sid = read_lock()
_fresh = os.path.exists(LOCK) and (time.time() - os.path.getmtime(LOCK)) < STALE
if _fresh and MYSID and _sid and _sid == MYSID:
    print("[tg-poll] ✅ 覆蓋仍在（同 session，poller pid=%s 心跳新鮮，已驗）→ 本次不重複 arm" % _pid, flush=True)
    sys.exit(0)
open(LOCK, "w").write("%d	%s" % (os.getpid(), MYSID))
print("[tg-poll] ✅ ARMED pid=%d%s" % (
    os.getpid(),
    ("（前任 pid=%s 將於下輪自退）" % _pid) if _pid else "（無前任）"), flush=True)

def get_updates(offset, timeout):
    url = API + "?" + urllib.parse.urlencode({"offset": offset, "timeout": timeout})
    try:
        with urllib.request.urlopen(url, timeout=timeout + 10) as r:
            return json.load(r)
    except Exception:
        return None

def load_last():
    try:
        return int(open(STATE).read().strip())
    except Exception:
        return None

def save_last(v):
    try:
        open(STATE, "w").write(str(v))
    except Exception:
        pass

# 開場 baseline:記下當前最高 update_id、跳過舊訊息(如先前的 "Hi")。
if load_last() is None:
    data = get_updates(0, 0)
    mx = 0
    if data and data.get("ok"):
        for u in data["result"]:
            mx = max(mx, u["update_id"])
    save_last(mx)
    print("[tg-poll] armed, baseline=%d, 濾 chat %s(每則你的訊息喚醒 blueprint)" % (mx, CHAT), flush=True)

while True:
    # ★讓位：lock 不是我 → 有更新的 poller 當家，本實例退出（孤兒自己清自己）
    _cur, _ = read_lock()
    if _cur and _cur != str(os.getpid()):
        print("[tg-poll] ⛔ 讓位：有更新的 poller（pid=%s）→ 本實例退出" % _cur, flush=True)
        sys.exit(0)
    try:
        os.utime(LOCK, None)                  # 刷心跳(證本 poller 還活著)
    except Exception:
        pass
    last = load_last() or 0
    data = get_updates(last + 1, 25)          # long-poll:有新訊息或 25s 才回
    if not data or not data.get("ok"):
        time.sleep(3)
        continue
    for u in data["result"]:
        save_last(u["update_id"])
        msg  = u.get("message") or u.get("edited_message") or {}
        chat = str((msg.get("chat") or {}).get("id", ""))
        text = msg.get("text", "")
        if chat != CHAT or not text:           # 安全:只認你的 chat id
            continue
        print("📱 [Telegram] 用戶: %s" % text, flush=True)
