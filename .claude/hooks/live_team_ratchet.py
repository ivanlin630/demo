#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""棘輪：新寫的「state.teams.has( ＋ 之後對那支隊動作」要亮警。

★判準【不是重新發明的】——它就是 docs/process/teams-has-callsites.tsv 表頭寫的那套：
    守衛之後、同一函式內，那個 id 有沒有 ①被取出（state.teams[id] / .get(id)）
    ②被當參數派出去（f(... id ...)） ⇒ 有 ⇒ [L]（存活守衛）⇒ 該用 live_team()
  只比較／記帳 ⇒ [?]（★需要人看，不是通過）
  之後不再出現 ⇒ [G]（純存在問句）⇒ ★不亮警（本閘最容易做錯的就是把 G 也咬進去）

★★存量 86 處走 baseline 豁免（docs/process/teams-has-baseline.tsv），
  而 baseline 每列帶 owner ＋【觸發條件＝那一行被碰到時】——★★★不是日期：
  日期會過期而沒有人處理，觸發條件不會。

★★★而 R² 的免費補強也在這支裡：`live_team(x)` 之後【下一行】沒有判 null ⇒ 具名警。
"""
import io
import os
import re
import sys

SCAN_DIRS = ["scripts/simulation", "scripts/data"]
BASELINE = "docs/process/teams-has-baseline.tsv"


def strip_comment(line):
    i = line.find("#")
    return line if i < 0 else line[:i]


def func_ranges(lines):
    """回 [(start, end)]：以 `func ` 開頭到下一個同層 func 之前。"""
    starts = [i for i, l in enumerate(lines)
              if re.match(r"\s*(static )?func [A-Za-z0-9_]+", l)]
    out = []
    for n, s in enumerate(starts):
        e = starts[n + 1] if n + 1 < len(starts) else len(lines)
        out.append((s, e))
    return out


def classify_file(path, lines):
    """回 [(line_no, cls, arg, evidence)]"""
    rows = []
    ranges = func_ranges(lines)
    for i, raw in enumerate(lines):
        line = strip_comment(raw)
        if "state.teams.has(" not in line:
            continue
        m = re.search(r"state\.teams\.has\(([^)]*)\)", line)
        arg = m.group(1).strip() if m else ""
        # 同一運算式就讀它 ⇒ M（分類上屬 L：接著要用）
        if "state.teams[" in line or "state.teams.get(" in line:
            rows.append((i + 1, "M", arg, line.strip()[:70]))
            continue
        end = len(lines)
        for s, e in ranges:
            if s <= i < e:
                end = e
                break
        pat = re.escape(arg) if arg else None
        fetch = call = other = None
        for j in range(i + 1, end):
            nxt = strip_comment(lines[j])
            if not pat:
                break
            if "Probe." in nxt or "print(" in nxt:
                continue
            if not re.search(pat, nxt):
                continue
            if "state.teams[" in nxt or "state.teams.get(" in nxt:
                fetch = (j + 1, nxt.strip()[:70])
                break
            if re.search(r"\w+\([^)]*" + pat, nxt):
                call = call or (j + 1, nxt.strip()[:70])
            else:
                other = other or (j + 1, nxt.strip()[:70])
        if fetch:
            rows.append((i + 1, "L", arg, "取出那支隊 @%d %s" % fetch))
        elif call:
            rows.append((i + 1, "L", arg, "當參數派出去 @%d %s" % call))
        elif other:
            rows.append((i + 1, "?", arg, "只比較／記帳 @%d %s" % other))
        else:
            rows.append((i + 1, "G", arg, "之後不再出現"))
    return rows


def scan_live_team_null(path, lines):
    """R² 補強：live_team(x) 之後【下一行】沒判 null ⇒ 具名警。"""
    out = []
    for i, raw in enumerate(lines):
        line = strip_comment(raw)
        if "live_team(" not in line or "func live_team" in line:
            continue
        if "is_live_team(" in line:
            continue
        nxt = strip_comment(lines[i + 1]) if i + 1 < len(lines) else ""
        same = line
        if ("== null" in same or "!= null" in same or "if " in same and "null" in same):
            continue
        if "== null" in nxt or "!= null" in nxt or re.search(r"if\s+not\s+\w+", nxt):
            continue
        out.append((i + 1, line.strip()[:70]))
    return out


def gd_files(dirs):
    for d in dirs:
        for root, _dirs, files in os.walk(d):
            for f in sorted(files):
                if f.endswith(".gd"):
                    yield os.path.join(root, f).replace(os.sep, "/")


def load_baseline(path):
    got = set()
    if not os.path.exists(path):
        return got
    for l in io.open(path, encoding="utf-8"):
        if l.startswith("#") or not l.strip():
            continue
        cols = l.rstrip("\n").split("\t")
        if len(cols) >= 2:
            got.add("%s:%s" % (cols[0], cols[1]))
    return got


def run(dirs, baseline_path, emit_baseline=False):
    base = load_baseline(baseline_path)
    warns = []
    all_rows = []
    for p in gd_files(dirs):
        lines = io.open(p, encoding="utf-8", errors="replace").read().split("\n")
        for (ln, cls, arg, why) in classify_file(p, lines):
            all_rows.append((p, ln, cls, arg, why))
            if cls == "G":
                continue                      # ★純存在問句：本閘不咬（驗收④）
            key = "%s:%d" % (p, ln)
            if key in base:
                continue                      # 存量豁免
            label = "需要人看" if cls == "?" else "該用 live_team()"
            warns.append("[RATCHET] %s:%d  [%s] %s ⇒ %s" % (p, ln, cls, why, label))
        for (ln, txt) in scan_live_team_null(p, lines):
            key = "null:%s:%d" % (p, ln)
            if key in base:
                continue
            warns.append("[RATCHET] %s:%d  live_team() 之後沒有判 null ⇒ %s" % (p, ln, txt))
    if emit_baseline:
        # ★用 io.open 寫檔（不走 print）：★★Windows 終端把中文轉成 CP950 ⇒ 重導的檔案內容會壞
        out = [
            "# state.teams.has( 存量 baseline（棘輪閘豁免）",
            "# 判準來源：docs/process/teams-has-callsites.tsv 表頭那套（不是重新發明的）",
            "# ★每列帶 owner ＋【觸發條件】＝【那一行被碰到時】(on-touch)；",
            "#   ★★不是日期：日期會過期而沒有人處理，觸發條件不會。",
            "# ★★★[G]（純存在問句）不在本表：本閘本來就不咬它。",
            "site\tline\tclass\towner\ttrigger\treason",
        ]
        for (p, ln, cls, arg, why) in all_rows:
            if cls == "G":
                continue
            out.append("%s\t%d\t%s\tsystems\ton-touch:這一行被碰到時轉 live_team()\t%s" % (p, ln, cls, why))
        io.open(baseline_path, "w", encoding="utf-8", newline="\n").write("\n".join(out) + "\n")
        return 0
    for w in warns:
        print(w)
    print("[RATCHET] 母體 %d 處｜baseline %d 列｜新增未豁免 %d 處" % (len(all_rows), len(base), len(warns)))
    return 1 if warns else 0


if __name__ == "__main__":
    # ★★輸出強制 UTF-8：★Windows 主控台預設 CP950，印到「⇒」就整支 UnicodeEncodeError
    #   ⇒ ★★★而它的症狀是【閘吐 traceback、rc=1】—— 看起來跟「有發現」一模一樣。
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass
    args = sys.argv[1:]
    if args and args[0] == "--emit-baseline":
        sys.exit(run(SCAN_DIRS, BASELINE, emit_baseline=True))
    if args and args[0] == "--dirs":
        # ★給 selfcheck 用：對一個 fixture 目錄跑，baseline 空（所有命中都會亮）
        sys.exit(run([args[1]], "", False))
    sys.exit(run(SCAN_DIRS, BASELINE, False))
