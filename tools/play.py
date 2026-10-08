#!/usr/bin/env python3
"""交玩的那一行：`python tools/play.py`

spec：`docs/superpowers/specs/2026-10-06-one-line-to-play-the-terminal-HOW.md`（刀 1）

★它是一支**薄客戶端**，而「薄」是刻意的：它不組畫面、不解讀按鍵、不知道遊戲規則。
  它只做四件 ①起一支 headless Godot 跑 `scripts/ui/player_repl.gd`
  ②從它的 stdout 讀那一行 `port=`（★那一行留在 stdout —— 它不是畫面，是握手）
  ③把人打的每一行丟進 socket、從 socket 讀**整屏到框尾為止**，印出來
  ④離開時把子行程收掉

★★為什麼回程走 socket 不走 stdout（刀 0 已做）：**sim 無條件灌 stdout**
  ⇒ 讀 stdout 會收到混著 log 的畫面，而那時「印出東西了」與「印出一屏亂碼」
  在卷面上**都是綠的**。socket 那一條還順便解掉 Windows 的 CP950 編碼洞。

★★★而 debug 走法照藍圖裁定：`TEXTUI_DEBUG_PANE=1 python tools/play.py`
  —— 沒有「跑起來之後打 debug on」那種指令（那會是第二份開關）。
"""

import os
import re
import socket
import subprocess
import sys
import threading
import time
from pathlib import Path

# ══ ★★★★★★【客戶端自己的 stdout 也要強制 UTF-8】═════════════════════════════
# ★這張票治的那個 CP950 洞**咬到了它自己**：第一次跑的時候，連「找不到 Godot」
#   那一句錯誤訊息都印不出來 —— 它死在 `UnicodeEncodeError: 'cp950' codec can't encode '✗'`
#   ⇒ ★★一個**連錯誤訊息都印不出來**的客戶端，它的失敗長相是一個 traceback，
#     而真正的原因（找不到執行檔）被埋在那個 traceback 底下。
# ⇒ 所以在**任何輸出之前**就把 stdout 換成 UTF-8。
#   ★★★而這與 server 那一側是**同一個病的兩面**：那邊的修法是「畫面別走 stdout」，
#     這邊的修法是「我自己的 stdout 要能印中文」—— 兩個都要做，少一個就會有一條路是花的。
try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

# ★框尾與 server 端是**同一個位元組**（server 在送出點把它從內容裡剝掉
#   ⇒ 「內容裡出現框尾」在結構上不可能發生 —— 理由寫在 `player_repl.gd` 的 `FRAME_END` 旁邊）
FRAME_END = "\u0004"
QUIT_TOKEN = ":quit"
PORT_RE = re.compile(r"port=(\d+)")
# ★★等 `port=` 那一行的上限：起一個世界要跑 `GameSetup`（實測數秒）⇒ 給它寬裕但有限
PORT_WAIT_SEC = 90.0


def repo_root() -> Path:
    """★用 git 問，不要從 `__file__` 往上猜幾層（猜的那種在 worktree 裡會指錯）。"""
    try:
        out = subprocess.run(
            ["git", "rev-parse", "--show-toplevel"],
            capture_output=True, text=True, timeout=10,
            cwd=str(Path(__file__).resolve().parent),
        )
        if out.returncode == 0 and out.stdout.strip():
            return Path(out.stdout.strip())
    except Exception:
        pass
    return Path(__file__).resolve().parent.parent


# ★執行檔的位置**照 `tools/godot.ps1:38-40` 那兩行**，而那裡有一句關鍵註解（`:16` 逐字）：
#   「Worktree note: tools/godot/*.exe is gitignored (absent in worktrees)
#     -> fallback to main repo path.」
#   ⇒ ★★所以在 worktree 裡**第一條路一定找不到**，必須退回主 repo 的絕對路徑 ——
#     ★而我第一版漏了這一條（我用 glob 猜檔名而沒有那個 fallback）⇒ 實測它找不到。
#   ⇒ ★★★判準：**抄一個既有形狀的時候要連它的 fallback 一起抄** ——
#     那個 fallback 存在的理由（gitignored）寫在它旁邊，而我只抄了「主路徑」那一半。
GODOT_REL = Path("tools") / "godot" / "Godot_v4.2.2-stable_win64_console.exe"
GODOT_MAIN_REPO = Path("A:/GDS/demo") / GODOT_REL


def godot_exe(root: Path) -> str:
    """找 Godot 執行檔 —— ★形狀沿用 `tools/godot.ps1` 找的那一支，不另開一份清單。"""
    env = os.environ.get("GODOT_BIN", "").strip()
    if env:
        return env
    for cand in (root / GODOT_REL, GODOT_MAIN_REPO):
        if cand.exists():
            return str(cand)
    # ★找不到 ⇒ **說出來**，不要讓它變成一句 FileNotFoundError
    #   （「找不到 Godot」與「Godot 起不來」是兩句不同的話）
    print("[play] ✗ 找不到 Godot 執行檔。請設 GODOT_BIN=<路徑> 再跑一次。")
    sys.exit(2)


def write_beacon(root: Path, pid: int) -> Path | None:
    """★★★信標必落（systems 定 2026-10-06）：`.claude/hooks/.godot-pids/<pid>.txt`

    ·格式照 `tools/godot.ps1:320-326`（`pid=… wrapper=… tree=… since=…`）＋ `by=play.py`
    ·★為什麼非做不可：`machine-busy.sh` 會把**沒有信標**的 Godot 記成
      「**不知道是誰的**」，而那一格的處置逐字是「**不准殺 ⇒ 去問**」
      ⇒ 電池那條「開跑前 Godot 數必須 0」會卡住，**而且查不出是誰**。
    ·★★而它也是為了**我們自己**：那支 reader 死掉的信標會順手清，活的會逐行印出來。
    """
    try:
        bdir = root / ".claude" / "hooks" / ".godot-pids"
        bdir.mkdir(parents=True, exist_ok=True)
        beacon = bdir / ("%d.txt" % pid)
        beacon.write_text(
            "pid=%d wrapper=%d tree=%s since=%s by=play.py"
            % (pid, os.getpid(), root, time.strftime("%Y-%m-%dT%H:%M:%S")),
            encoding="utf-8")
        return beacon
    except Exception as e:
        # ★落不了信標 ⇒ **說出來**（它不是致命，但它會讓別人查不出這支是誰的）
        print("[play] ⚠ 信標落不下去（%s）⇒ machine-busy 會把這支記成「不知道是誰的」" % e)
        return None


# ★★★★★【server 的輸出要留得住 —— 否則「卡住」與「死了」分不開】（實測抓到）
#   第一次跑的時候客戶端只吐一個 `TimeoutError: timed out`，而真因是
#   **第一屏被送到 stdout 去了**（server 那一側的時機錯）⇒ 那個 traceback
#   與「server 根本沒起來」「server 當掉了」**三種情形長得一模一樣**。
#   ⇒ 所以把 server 的輸出收在一個共享 list 裡，**每一條錯誤路徑都把它的尾巴印出來**。
_SRV_LINES: list[str] = []


def srv_tail(n: int = 20) -> None:
    print("[play] ── server 的輸出（最後 %d 行）──" % n)
    if not _SRV_LINES:
        print("    （它一行都沒印 —— 那本身就是線索：它可能連啟動都沒到）")
    for l in _SRV_LINES[-n:]:
        print("    " + l)


def start_server(root: Path) -> tuple[subprocess.Popen, int, Path | None]:
    exe = godot_exe(root)
    cmd = [exe, "--headless", "--path", str(root),
           "--script", "scripts/ui/player_repl.gd"]
    proc = subprocess.Popen(
        cmd, cwd=str(root), stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
        text=True, encoding="utf-8", errors="replace", bufsize=1)
    beacon = write_beacon(root, proc.pid)
    print("[play] 起了一支 Godot（pid=%d）—— 正在造世界，請等幾秒…" % proc.pid)

    port: list[int] = []

    def pump() -> None:
        # ★把 server 的 stdout 一直抽乾：①找 `port=` ②★**不抽的話那支會在管道滿的時候卡住**
        for line in proc.stdout:  # type: ignore[union-attr]
            _SRV_LINES.append(line.rstrip("\n"))
            if not port:
                m = PORT_RE.search(line)
                if m:
                    port.append(int(m.group(1)))

    t = threading.Thread(target=pump, daemon=True)
    t.start()
    deadline = time.time() + PORT_WAIT_SEC
    while not port and time.time() < deadline:
        if proc.poll() is not None:
            print("[play] ✗ Godot 在握手之前就結束了（離開碼 %s）。" % proc.returncode)
            srv_tail()
            sys.exit(1)
        time.sleep(0.05)
    if not port:
        print("[play] ✗ %.0f 秒內沒讀到 `port=`。" % PORT_WAIT_SEC)
        srv_tail()
        proc.terminate()
        sys.exit(1)
    return proc, port[0], beacon


# ══ ★★★★★【P4：為什麼【不】與 `scripts/debug/test_agent_repl.py` 共用 socket 迴圈】═══
# spec §4 P4 逐字：「若各自寫一份 socket 迴圈 ⇒ 抽共用**或明寫為什麼不共用**」。
# ★我核了那一支的協定（不憑印象）：
#   ·`test_agent_repl.py` ／ `agent_repl.gd` ＝ **一行一則 JSON**（`_read_json_line`）
#   ·`play.py` ／ `player_repl.gd`       ＝ **多行原始畫面，以 EOT（`0x04`）結尾**
#   ⇒ ★★兩者的 **framing 不同**（換行切 vs 框尾切）—— 而 framing 就是 socket 迴圈的全部內容
#     ⇒ 抽一支共用的 ＝ 把其中一種切法**強加**給另一種：
#       ·用換行切畫面 ⇒ 一屏 30 行會變成 30 則訊息（而客戶端分不出哪幾則是同一屏）
#       ·用框尾切 JSON ⇒ agent 那一側要改協定（而它不是這張票的範圍）
#   ⇒ ★★★那正是 spec §8① 警告的「**那樣逼的是錯抽象**」。
# ⇒ 所以**不共用**，而**真正共用的那一層是對的那一層**：
#   本檔的 `start_server`／`read_frame` 被 `tools/play_selfcheck.py` **直接 import**
#   ⇒ 「玩家那一行走的路」與「自驗走的路」**是同一條**（那才是 P4 想要的同源）。
def read_frame(sock: socket.socket) -> str:
    """從 socket 讀**整屏到框尾為止** —— ★而不是「讀到沒有新資料就算一屏」。

    ★為什麼：後者在慢機器上會把**半屏**當成整屏，而那時畫面看起來只是「被截斷」
      ⇒ 它與「版面真的壞了」在人眼裡一模一樣。框尾讓那個差別變成**位元組層的事實**。
    """
    buf = bytearray()
    while True:
        chunk = sock.recv(65536)
        if not chunk:
            # ★對方關了 ⇒ 把已經收到的交出去（不要假裝收到一整屏）
            return buf.decode("utf-8", errors="replace")
        buf += chunk
        if FRAME_END.encode("utf-8") in bytes(buf):
            text = buf.decode("utf-8", errors="replace")
            return text.split(FRAME_END)[0]


# ══ ★F5（spec 2026-10-07 round5-friendliness §F5，用戶：「什麼都要打字，連 Esc 都要打 e-s-c 加 Enter」）══════
# ★一個按鍵 ⇒ 一個 token。token 名稱＝`player_repl.gd` NAMED_KEYS 的鍵名（同一份；這裡不另發明名字）
# ★純函式：吃「一次按鍵讀到的原始字元」（一般鍵 1 個字元；方向鍵 2 個：\xe0 或 \x00 前綴＋H/P/K/M）
#   ⇒ 回 token；Ctrl+C ⇒ QUIT_TOKEN（走既有離開路，同 q 那支，不另開一條）；認不得的特殊鍵 ⇒ ""（不送）
ARROW_SUFFIX = {"H": "up", "P": "down", "K": "left", "M": "right"}
SPECIAL_PREFIX = ("\xe0", "\x00")
CTRL_C = "\x03"
SINGLE_CHAR_TOKEN = {"\x1b": "esc", "\r": "enter", "\t": "tab", " ": "space", "\x08": "backspace"}


def key_token(chars: str) -> str:
    if not chars:
        return ""
    c0 = chars[0]
    if c0 in SPECIAL_PREFIX:
        return ARROW_SUFFIX.get(chars[1:2], "")
    if c0 == CTRL_C:
        return QUIT_TOKEN
    if c0 in SINGLE_CHAR_TOKEN:
        return SINGLE_CHAR_TOKEN[c0]
    if c0.isprintable():
        return c0
    return ""


# ★對照表本身的自驗（不起 Godot）：`python tools/play.py --selfcheck`
KEY_TOKEN_CASES = [
    ("x", "x"), ("G", "G"), ("3", "3"), (",", ","), ("\x1b", "esc"), ("\r", "enter"), ("\t", "tab"),
    (" ", "space"), ("\x08", "backspace"),
    ("\xe0H", "up"), ("\xe0P", "down"), ("\xe0K", "left"), ("\xe0M", "right"),
    ("\x00H", "up"), ("\x00P", "down"), ("\x00K", "left"), ("\x00M", "right"),
    ("\x03", QUIT_TOKEN), ("\x00;", ""),
]


def selfcheck() -> int:
    bad = 0
    for raw, want in KEY_TOKEN_CASES:
        got = key_token(raw)
        ok = got == want
        bad += 0 if ok else 1
        print("  %s key_token(%r) = %r（應 %r）" % ("PASS" if ok else "FAIL", raw, got, want))
    print("=== play key_token selfcheck DONE === errors: %d" % bad)
    return 1 if bad else 0


def _single_key_mode() -> bool:
    """stdin 是 tty 且有 msvcrt（Windows）⇒ 單鍵模式；否則（管道、床、藍圖餵鍵）退回逐行，行為逐字不變。"""
    if not sys.stdin.isatty():
        return False
    try:
        import msvcrt  # noqa: F401
    except ImportError:
        return False
    return True


def _read_key() -> str:
    import msvcrt
    c = msvcrt.getwch()
    if c in SPECIAL_PREFIX:
        c += msvcrt.getwch()
    return c


CLEAR_SCREEN = "\x1b[2J\x1b[H"


def main() -> int:
    if "--selfcheck" in sys.argv[1:]:
        return selfcheck()
    single = _single_key_mode()
    root = repo_root()
    proc, port, beacon = start_server(root)
    sock = socket.create_connection(("127.0.0.1", port), timeout=30)
    sock.settimeout(120)
    try:
        try:
            first = read_frame(sock)        # 第一屏
            if single:
                print(CLEAR_SCREEN + first)
                print("[play] 直接按鍵，不用 Enter（q 或 Ctrl+C 離開）")
            else:
                print(first)
        except (TimeoutError, socket.timeout):
            # ★逾時 ⇒ 把 server 的尾巴印出來（它會說出是「沒送」還是「死了」）
            print("[play] ✗ 接上了，但等不到第一屏（socket 逾時）。")
            srv_tail()
            raise
        while True:
            if single:
                # ★單鍵：一鍵一 token；認不得的特殊鍵不送（"" ⇒ 再讀下一鍵）
                line = key_token(_read_key())
                if line == "":
                    continue
            else:
                try:
                    line = input("> ")
                except (EOFError, KeyboardInterrupt):
                    line = QUIT_TOKEN
            if line.strip().lower() in ("q", "quit", QUIT_TOKEN):
                # ★★`q` 是**遊戲裡**的離開鍵，而 `:quit` 是離開這支 harness ——
                #   ★這裡把 `q` 也當成「我要離開」，因為在一支**只為了玩**的客戶端上
                #   那兩件事對人來說是同一件；而 server 那一側仍然分得開（它收到的是 `:quit`）。
                sock.sendall((QUIT_TOKEN + "\n").encode("utf-8"))
                break
            sock.sendall((line + "\n").encode("utf-8"))
            frame = read_frame(sock)
            # ★單鍵模式：清屏再印，畫面不往上捲；逐行模式照舊
            print(CLEAR_SCREEN + frame if single else frame)
    finally:
        try:
            sock.close()
        except Exception:
            pass
        # ★收子行程：先給它自己退的機會，再硬收（★而硬收之後也要清信標 ——
        #   一個活著的信標指向一個死掉的 pid 會讓 reader 把它當成「我們的」）
        try:
            proc.wait(timeout=10)
        except subprocess.TimeoutExpired:
            proc.terminate()
            try:
                proc.wait(timeout=10)
            except subprocess.TimeoutExpired:
                proc.kill()
        if beacon is not None:
            try:
                beacon.unlink(missing_ok=True)
            except Exception:
                pass
        print("[play] 收掉了（Godot pid=%d 離開碼 %s）" % (proc.pid, proc.returncode))
    return 0


if __name__ == "__main__":
    sys.exit(main())
