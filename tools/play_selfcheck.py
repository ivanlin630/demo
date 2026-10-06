#!/usr/bin/env python3
"""`tools/play.py` 的自驗（spec §4 的 P 表）

spec：`docs/superpowers/specs/2026-10-06-one-line-to-play-the-terminal-HOW.md`

★★它**重用 `play.py` 的函式**（`start_server`／`read_frame`）而不另寫一份 socket 迴圈
  ⇒ 「玩家那一行走的路」與「自驗走的路」是**同一條**（P4 的精神：單一 transport 形狀）。

★★★每一條「＝ 0」都配一條【同一個判準在另一個走法上必須 > 0】（終端那張票的通則）：
  ·P3 玩家走法 debug 識別字 ＝ 0 ⇔ `TEXTUI_DEBUG_PANE=1` 之下**必須 > 0**
  ·P1 sim log 混進畫面 ＝ 0 ⇔ 那些 log **真的有印**（在 server 的 stdout 裡）
"""

import os
import socket
import subprocess
import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import play  # noqa: E402  ★同源：玩家那一行與自驗走同一條路

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

# ★指名的中文字面（P1 逐字要求：否則「印出東西了」與「印出一屏亂碼」在卷面上都是綠的）
P1_MUST_CONTAIN = ["第 1 天", "─ 動作（", "─ 事件（", " 鍵："]
# ★sim log 的特徵（它們走 stdout ⇒ 刀 0 之後**不得**出現在 socket 那一屏裡）
SIM_LOG_MARKERS = ["[GameSetup]", "[MoneyGenesis]", "[player-repl]", "[Sub]"]
# ★debug 識別字 —— 與 `scripts/debug/terminal_selfcheck_bed.gd` 的 `DEBUG_TOKENS` **同一份語意**
#   （★而它是**手抄的第二份** —— 那支是 GDScript 這支是 Python，跨語言無法共用一個常數；
#     ⇒ 誠實限：兩份會漂 ⇒ 本腳本**印出它用的那一份**，讀的人看得見兩邊是否一致）
DEBUG_TOKENS = ["真值·debug", "tile_id", "outpost_level", "收成係數", "格上隊伍", "非附身者所知"]
# ★server 自己退的等待上限（P2b）——刀 2 的連線逾時／斷線即退都應該在這之內
SELF_EXIT_WAIT_SEC = 30.0

_errors = 0


def check(msg: str, cond: bool) -> None:
    global _errors
    if cond:
        print("  PASS: " + msg)
    else:
        _errors += 1
        print("  FAIL: " + msg)


def godot_count() -> int:
    """全機 Godot 行程數（★systems 要的「兩個 Godot 行程數」就是這個前／後）"""
    try:
        out = subprocess.run(["tasklist", "/FI", "IMAGENAME eq Godot*", "/NH"],
                             capture_output=True, text=True, timeout=15)
        return sum(1 for l in out.stdout.splitlines() if l.strip().lower().startswith("godot"))
    except Exception:
        return -1


def first_frame(env_extra: dict | None = None) -> tuple[subprocess.Popen, socket.socket, str, object]:
    old_env = dict(os.environ)
    if env_extra:
        os.environ.update(env_extra)
    try:
        root = play.repo_root()
        proc, port, beacon = play.start_server(root)
    finally:
        os.environ.clear()
        os.environ.update(old_env)
    sock = socket.create_connection(("127.0.0.1", port), timeout=30)
    sock.settimeout(120)
    frame = play.read_frame(sock)
    return proc, sock, frame, beacon


def quit_cleanly(proc, sock, beacon) -> int | None:
    try:
        sock.sendall((play.QUIT_TOKEN + "\n").encode("utf-8"))
    except Exception:
        pass
    try:
        sock.close()
    except Exception:
        pass
    try:
        proc.wait(timeout=20)
    except subprocess.TimeoutExpired:
        proc.kill()
        proc.wait(timeout=10)
    if beacon is not None:
        try:
            beacon.unlink(missing_ok=True)
        except Exception:
            pass
    return proc.returncode


# ══ P1 一行可玩：完整第一屏、端到端中文字面、沒有混進 sim log ══════════════════════
def p1_and_p2a() -> None:
    print("\n── P1／P2a 一行可玩 ＋ 常態收得掉 ──")
    before = godot_count()
    proc, sock, frame, beacon = first_frame()
    print("   第一屏 %d 字（前 2 行）：" % len(frame))
    for l in frame.splitlines()[:2]:
        print("     " + l[:100])
    check("★母體地板：真的收到一屏（%d 字；0 ⇒ 下面每一條都恆綠）" % len(frame), len(frame) > 0)
    missing = [s for s in P1_MUST_CONTAIN if s not in frame]
    check("★★★★★P1：第一屏含指名的中文字面 %s（缺：%s）" % (P1_MUST_CONTAIN, missing),
          not missing)
    leaked = [m for m in SIM_LOG_MARKERS if m in frame]
    check("★★★★★P1：畫面裡**沒有混進** sim log（命中：%s）" % leaked, not leaked)
    # ★反向對照：那些 log **真的有印**（在 server 的 stdout 裡）—— 否則「沒混進」是因為它們根本不存在
    printed = [m for m in SIM_LOG_MARKERS if any(m in l for l in play._SRV_LINES)]
    check("★★【反向對照】那些 log 真的有印、只是在 stdout 不在畫面（命中 %d 個：%s）"
          % (len(printed), printed), len(printed) > 0)
    rc = quit_cleanly(proc, sock, beacon)
    after = godot_count()
    print("   Godot 行程數：前 %d ／ 後 %d｜這一支的離開碼 ＝ %s" % (before, after, rc))
    check("★★★★★P2a：`:quit` 之後那一支 Godot 自己退了（離開碼 %s）" % rc, rc is not None)
    check("★★★★★P2a：沒有殘留的 Godot 行程（前 %d ＝ 後 %d）" % (before, after),
          after == before)


# ══ P2b 異常收得掉：不送 `:quit`、直接關 socket ⇒ server 必須自己退 ══════════════
# ★★這一格**不是 play.py 的責任**（spec 逐字）：client 被殺的時候只有 server 還在跑。
# ★★★而 spec 說它**今天必紅** —— 照規矩**先跑紅再修**（先修就把負對照吃掉了）。
def p2b() -> None:
    print("\n── P2b 異常收得掉：關 socket 不送 :quit ⇒ server 必須自己退 ──")
    before = godot_count()
    proc, sock, frame, beacon = first_frame()
    check("★母體地板：真的接上而且收到第一屏（%d 字）" % len(frame), len(frame) > 0)
    sock.close()   # ★不送 `:quit` —— 模擬 client 被殺
    t0 = time.time()
    while proc.poll() is None and time.time() - t0 < SELF_EXIT_WAIT_SEC:
        time.sleep(0.2)
    alive = proc.poll() is None
    waited = time.time() - t0
    print("   關 socket 之後 %.1f 秒：那一支 Godot 還活著 ＝ %s（離開碼 %s）"
          % (waited, alive, proc.returncode))
    check("★★★★★★P2b：server 在 %.0f 秒內自己退了（還活著 ＝ %s）" % (SELF_EXIT_WAIT_SEC, alive),
          not alive)
    if alive:
        # ★這一格紅了 ⇒ **自己收掉**，不要留一支孤兒給下一個人
        proc.kill()
        proc.wait(timeout=10)
    if beacon is not None:
        try:
            beacon.unlink(missing_ok=True)
        except Exception:
            pass
    after = godot_count()
    print("   Godot 行程數：前 %d ／ 後 %d（★紅的時候是本腳本自己收的）" % (before, after))


# ══ P3 debug 預設關 ＋ 反向走法 ═══════════════════════════════════════════════════
def p3() -> None:
    print("\n── P3 玩家走法不含 debug 識別字 ＋ 反向走法 ──")
    print("   DEBUG_TOKENS（本腳本用的那一份）＝ %s" % DEBUG_TOKENS)
    proc, sock, frame, beacon = first_frame()
    hits = [t for t in DEBUG_TOKENS if t in frame]
    quit_cleanly(proc, sock, beacon)
    print("   玩家走法命中 ＝ %s" % hits)
    check("★★★★★P3：玩家走法的第一屏**不含** debug 識別字（命中：%s）" % hits, not hits)
    # ★★★反向走法：`TEXTUI_DEBUG_PANE=1` 之下**必須出現** —— 否則那個走法是死的
    proc2, sock2, frame2, beacon2 = first_frame({"TEXTUI_DEBUG_PANE": "1"})
    hits2 = [t for t in DEBUG_TOKENS if t in frame2]
    quit_cleanly(proc2, sock2, beacon2)
    print("   debug 走法命中 ＝ %s" % hits2)
    check("★★★★★★P3【反向走法】`TEXTUI_DEBUG_PANE=1` 之下 debug 識別字**必須出現**（%d 個）"
          % len(hits2), len(hits2) > 0)


def main() -> int:
    print("=== play_selfcheck：一行可玩的自驗 ===")
    p1_and_p2a()
    p2b()
    p3()
    print("\n=== play_selfcheck DONE === errors: %d" % _errors)
    return 1 if _errors else 0


if __name__ == "__main__":
    sys.exit(main())
