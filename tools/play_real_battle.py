#!/usr/bin/env python3
"""BS 真打一場（spec 2026-10-07 battle-screen-asserted-and-extortion-brake §票 BS「另：play.py 真打一場」）

★走玩家那一行的同一條路：import `play.py` 的 `start_server`／`read_frame`（同 `play_selfcheck.py`）
  ⇒ 起 headless Godot 跑 player_repl、從 socket 讀整屏 —— 不是床、不碰世界狀態
★策略只看畫面：推進一天 → 按 T 看有沒有同格可互動目標 → 有就選它、按畫面印的「攻擊」鍵；
  途中若畫面直接變成戰鬥區（被伏擊）就照打
★打法：待機／移動／待機 三拍之後一直待機到分出勝負，戰後按任意鍵離開
★逐鍵整屏落檔（給藍圖讀）：`python tools/play_real_battle.py <輸出檔>`
"""
import re
import socket
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import play  # noqa: E402

BATTLE_TITLE = "─ 戰鬥（接管畫面）"
NO_TARGET = "（無可互動目標）"
MAX_HOURS = 24 * 20
PRE_KEEP = 40
MAX_BATTLE_KEYS = 80


# 地圖上的游標 `[X]` 與最近一個數字（看得到的隊伍）：回傳下一個游標鍵；游標已在數字上 ⇒ ""；沒有數字 ⇒ None
#   ★不算座標（方括號會擠字元位置，第一版換算差一格）⇒ 每按一鍵重讀畫面、逐步逼近
def _next_cursor_key(scr: str):
    rows = [l.split("│")[1] if l.count("│") >= 2 else "" for l in scr.split("\n")]
    cur = None
    digits = []
    for ri, row in enumerate(rows):
        m = re.search(r"\[(.)\]", row)
        if m:
            cur = (ri, m.start() + 1, m.group(1))
        for d in re.finditer(r"(?<![\[\d])(\d)(?![\d?\]])", row):
            digits.append((ri, d.start()))
    if cur is not None and cur[2].isdigit():
        return ""
    if cur is None or not digits:
        return None
    best = min(digits, key=lambda d: abs(d[0] - cur[0]) * 4 + abs(d[1] - cur[1]))
    if best[0] < cur[0]:
        return "w"
    if best[0] > cur[0]:
        return "s"
    return "a" if best[1] < cur[1] else "d"


def main() -> int:
    out_path = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("play_real_battle.txt")
    root = play.repo_root()
    proc, port, beacon = play.start_server(root)
    sock = socket.create_connection(("127.0.0.1", port), timeout=30)
    sock.settimeout(180)
    log: list[str] = []
    keys_sent: list[str] = []

    def press(k: str) -> str:
        sock.sendall((k + "\n").encode("utf-8"))
        scr = play.read_frame(sock)
        keys_sent.append(k)
        log.append("\n════ 第 %d 鍵：按 %s ════\n%s" % (len(keys_sent), k, scr))
        # ★戰前只留最後 PRE_KEEP 屏（追人那一段可能上千屏；藍圖要讀的是戰鬥那一段）
        if BATTLE_TITLE not in scr and len(log) > PRE_KEEP:
            del log[0]
        return scr

    try:
        scr = play.read_frame(sock)
        first = scr
        in_battle = False
        for _hour in range(MAX_HOURS):
            scr = press("x")
            if BATTLE_TITLE in scr:
                in_battle = True
                break
            # ★地圖上的數字＝看得到的隊伍 ⇒ 游標移過去、按 M 走過去（每小時重瞄：對方會走）
            k = _next_cursor_key(scr)
            steps = 0
            while k and steps < 16:
                scr = press(k)
                k = _next_cursor_key(scr)
                steps += 1
            if k == "":
                scr = press("m")
                if BATTLE_TITLE in scr:
                    in_battle = True
                    break
            scr = press("t")
            if NO_TARGET not in scr:
                if "◀ 數字鍵在這一側" not in scr.split("── 可互動目標")[-1].split("\n")[0]:
                    scr = press("tab")
                scr = press("1")
                m = re.search(r"\[(\d)\]攻擊", scr)
                if m:
                    scr = press(m.group(1))
                    if BATTLE_TITLE in scr:
                        in_battle = True
                        break
            scr = press("esc")
            scr = press("esc")
        log.insert(0, "════ 第一屏 ════\n%s\n\n★（中間省略：只留戰前最後 %d 屏；總共按了 %d 鍵）" % (first, PRE_KEEP, len(keys_sent)))
        if not in_battle:
            log.append("\n★%d 小時內沒有遇到可以打的對象，也沒有被伏擊" % MAX_HOURS)
        else:
            n = 0
            # ★BS v2：照畫面打 —— 目標欄寫「本拍打得到：<代號>」⇒ 按 R（立刻攻擊目標欄的目標）；否則先移動一拍再待機
            for k in ["space", "w", "space"] + ["auto"] * MAX_BATTLE_KEYS:
                if BATTLE_TITLE not in scr:
                    break
                if k == "auto":
                    m_hit = re.search(r"本拍打得到：([A-Z])", scr)
                    k = "r" if m_hit else "space"
                scr = press(k)
                n += 1
            if BATTLE_TITLE in scr:
                scr = press("space")   # 戰後「按任意鍵離開」
            log.append("\n★戰鬥中按了 %d 鍵；最後一屏%s戰鬥區" % (n, "仍是" if BATTLE_TITLE in scr else "已離開"))
        sock.sendall((play.QUIT_TOKEN + "\n").encode("utf-8"))
    finally:
        try:
            sock.close()
        except Exception:
            pass
        try:
            proc.wait(timeout=15)
        except Exception:
            proc.terminate()
        if beacon is not None:
            try:
                beacon.unlink()
            except Exception:
                pass
        out_path.write_text("\n".join(log), encoding="utf-8")
        print("[play_real_battle] 落檔 %s（%d 屏）" % (out_path, len(log)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
