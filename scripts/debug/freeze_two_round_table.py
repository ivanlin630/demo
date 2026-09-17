# -*- coding: utf-8 -*-
"""兩輪凍結取樣對照表產生器。

★這支存在的理由：我先前兩次把數字【從印出來的桶子裡用手推導】，兩次都錯
  （84/94、−86/−87.2%）。⇒ 對照表必須由【解析原始輸出】產生，不是由我讀表相加。
★★它同時是一個前提檢查器：兩份輸出若不是同一支床（[TREE] HEAD 不同）就直接喊停 ——
  兩輪之間唯一可以不同的東西是 seed。
用法：python two_round_table.py <roundA.txt> <roundB.txt>
"""
import io
import re
import sys

RE_TREE = re.compile(r"\[TREE\] HEAD=(\S+) scripts-dirty=(\d+)")
RE_HDR = re.compile(r"config=(\S+) days=(\d+) seed=(\d+)")
RE_POP = re.compile(
    r"跑過 (\d+) 幀（(\d+) 天）.*?＝ (\d+) 幀（([\d.]+)%）.*?最後隊數 (\d+)")
RE_SELF = re.compile(r"^\s{2,}(\S+)\s+self=\s*([\d.]+)s\s+total=\s*([\d.]+)s\s*$")
RE_MULTI = re.compile(r"^\s{2,}(\S+)\s+total=\s*([\d.]+)s\s*$")


def parse(path):
    txt = io.open(path, encoding="utf-8", errors="replace").read()
    d = {"path": path, "self": {}, "tot": {}, "multi": {}, "frames": []}
    m = RE_TREE.search(txt)
    d["head"], d["dirty"] = (m.group(1), int(m.group(2))) if m else ("UNKNOWN", -1)
    m = RE_HDR.search(txt)
    d["cfg"], d["days"], d["seed"] = (m.group(1), int(m.group(2)), int(m.group(3))) if m else ("?", 0, -1)
    m = RE_POP.search(txt)
    if m:
        d["total_frames"] = int(m.group(1))
        d["hit_frames"] = int(m.group(3))
        d["hit_pct"] = float(m.group(4))
        d["teams"] = int(m.group(5))
    else:
        d["total_frames"] = d["hit_frames"] = d["teams"] = 0
        d["hit_pct"] = 0.0
    section = None
    for line in txt.splitlines():
        if "self_us 排行" in line:
            section = "rank"; continue
        if "multi 列" in line:
            section = "multi"; continue
        if line.startswith("  [OK]") or line.startswith("[★★候選") or "候選對比" in line or "目標候選表" in line:
            section = None; continue
        if section == "rank":
            m = RE_SELF.match(line)
            if m:
                d["self"][m.group(1)] = float(m.group(2))
                d["tot"][m.group(1)] = float(m.group(3))
        elif section == "multi":
            m = RE_MULTI.match(line)
            if m:
                d["multi"][m.group(1)] = float(m.group(2))
        m = re.match(r"\s+tick=(\d+) dt=([\d.]+)s teams=(\d+)", line)
        if m:
            d["frames"].append((int(m.group(1)), float(m.group(2)), int(m.group(3))))
    return d


def main():
    a, b = parse(sys.argv[1]), parse(sys.argv[2])
    out = []
    P = out.append

    P("=== 兩輪凍結取樣對照（★由原始輸出解析產生，不是手算）===")
    P("A: seed=%d  %s" % (a["seed"], a["path"]))
    P("B: seed=%d  %s" % (b["seed"], b["path"]))
    P("")
    P("[前提檢查]")
    same_bed = a["head"] == b["head"] and a["dirty"] == 0 and b["dirty"] == 0
    P("  床（tree HEAD）：A=%s(dirty=%d)  B=%s(dirty=%d)  ⇒ %s" % (
        a["head"], a["dirty"], b["head"], b["dirty"],
        "✅ 同一支床" if same_bed else "❌★兩輪不是同一支床／有未 commit 改動 ⇒ 差異不可歸因於 seed"))
    P("  窗口：A=%s %d天  B=%s %d天 ⇒ %s" % (
        a["cfg"], a["days"], b["cfg"], b["days"],
        "✅ 同窗口" if (a["cfg"], a["days"]) == (b["cfg"], b["days"]) else "❌不同窗口"))
    P("  ★唯一該不同的：seed（%d vs %d）⇒ %s" % (
        a["seed"], b["seed"], "✅" if a["seed"] != b["seed"] else "❌兩輪 seed 相同"))
    P("")
    P("[母體]")
    P("  %-6s %-9s %-14s %-10s %s" % ("輪", "總幀", ">2s 幀", "比例", "最後隊數"))
    for r, t in ((a, "A"), (b, "B")):
        P("  %-6s %-9d %-14d %-10s %d" % (
            "%s(%d)" % (t, r["seed"]), r["total_frames"], r["hit_frames"],
            "%.2f%%" % r["hit_pct"], r["teams"]))
    if a["frames"] and b["frames"]:
        P("  ★凍結幀 dt 最大（印出來的前 12 筆內）：A=%.2fs  B=%.2fs"
          % (max(f[1] for f in a["frames"]), max(f[1] for f in b["frames"])))
        P("     ★★這是【印出來的前 12 筆】的最大值，不是全部 %d／%d 幀的最大值 —— 床只印前 12 筆。"
          % (a["hit_frames"], b["hit_frames"]))
    P("")

    P("[★self_us 排行：兩輪並排]（★單位秒；★★只含 >2s 的幀）")
    names = list(a["self"].keys())
    for n in b["self"]:
        if n not in names:
            names.append(n)
    names.sort(key=lambda n: -max(a["self"].get(n, 0.0), b["self"].get(n, 0.0)))
    rank_a = {n: i + 1 for i, n in enumerate(sorted(a["self"], key=lambda x: -a["self"][x]))}
    rank_b = {n: i + 1 for i, n in enumerate(sorted(b["self"], key=lambda x: -b["self"][x]))}
    P("  %-32s %10s %10s %9s   %s" % ("相位", "A self", "B self", "B/A", "名次 A→B"))
    for n in names:
        va, vb = a["self"].get(n), b["self"].get(n)
        ratio = ("%.2f×" % (vb / va)) if (va and vb) else "—"
        ra = str(rank_a.get(n, "—")); rb = str(rank_b.get(n, "—"))
        flag = ""
        if ra.isdigit() and rb.isdigit() and ra != rb:
            flag = "  ★換位"
        if (va is None) != (vb is None):
            flag = "  ★★只出現在一輪（另一輪沒印到／沒進前 N）"
        P("  %-32s %10s %10s %9s   %s→%s%s" % (
            n, "%.3f" % va if va is not None else "—",
            "%.3f" % vb if vb is not None else "—", ratio, ra, rb, flag))
    P("  ★誠實限：床只印【前 8 名】⇒ 一個相位在某輪缺席，可能是【掉出前 8】不是【沒有時間】。")
    P("")

    P("[★`*multi` 列：兩輪並排]（★它們不參與淨值減法 ⇒ 永遠不會出現在上面那張排行裡）")
    mnames = list(a["multi"].keys())
    for n in b["multi"]:
        if n not in mnames:
            mnames.append(n)
    mnames.sort(key=lambda n: -max(a["multi"].get(n, 0.0), b["multi"].get(n, 0.0)))
    P("  %-32s %10s %10s %9s" % ("相位", "A total", "B total", "B/A"))
    for n in mnames:
        va, vb = a["multi"].get(n), b["multi"].get(n)
        ratio = ("%.2f×" % (vb / va)) if (va and vb) else "—"
        P("  %-32s %10s %10s %9s" % (
            n, "%.3f" % va if va is not None else "—",
            "%.3f" % vb if vb is not None else "—", ratio))
    P("")

    P("[★★★目標候選表（三行並排；blueprint 2026-09-18 硬要求）]")
    P("  %-26s %14s %14s %9s" % ("候選塊", "A(seed %d)" % a["seed"], "B(seed %d)" % b["seed"], "B/A"))
    rowspec = []
    for r in (a, b):
        top = max(r["self"].items(), key=lambda kv: kv[1]) if r["self"] else ("—", 0.0)
        sub = max(r["tot"].items(), key=lambda kv: kv[1]) if r["tot"] else ("—", 0.0)
        rowspec.append((top, sub, sum(r["multi"].values()), len(r["multi"])))
    (ta, sa, ma, mca), (tb, sb, mb, mcb) = rowspec

    def line(label, x, y, extra=""):
        ratio = ("%.2f×" % (y / x)) if x else "—"
        P("  %-26s %14.3f %14.3f %9s %s" % (label, x, y, ratio, extra))

    line("① 排行第一(self)", ta[1], tb[1], "A=%s B=%s" % (ta[0], tb[0]))
    line("② 父子合計最大(total)", sa[1], sb[1], "A=%s B=%s" % (sa[0], sb[0]))
    line("③ ★*multi 合計", ma, mb, "A=%d列 B=%d列" % (mca, mcb))
    # ★★★【每一個凍結幀平均】——兩輪的凍結幀數不同（%d vs %d）⇒ 絕對秒數【天生不可比】：
    #   一輪多 34%% 的幀，每一塊都會大約多 34%%。⇒ 要比「誰大」必須先把母體除掉。
    fa = float(a["hit_frames"]) or 1.0
    fb = float(b["hit_frames"]) or 1.0
    P("")
    P("  ★同一張表【除以各自的凍結幀數】（A %d 幀／B %d 幀）⇒ 單位：秒／凍結幀" % (
        a["hit_frames"], b["hit_frames"]))
    P("  %-26s %14s %14s %9s" % ("候選塊", "A 每幀", "B 每幀", "B/A"))
    for label, x, y in (("① 排行第一", ta[1], tb[1]), ("② 父子合計最大", sa[1], sb[1]),
                        ("③ ★*multi 合計", ma, mb)):
        xa, yb = x / fa, y / fb
        P("  %-26s %14.4f %14.4f %9s" % (label, xa, yb, "%.2f×" % (yb / xa) if xa else "—"))
    P("  ⇒ ③／① ＝ A %.2f×　B %.2f×" % (ma / ta[1] if ta[1] else 0, mb / tb[1] if tb[1] else 0))
    P("  ⇒ ③／② ＝ A %.2f×　B %.2f×" % (ma / sa[1] if sa[1] else 0, mb / sb[1] if sb[1] else 0))
    P("  ★這三行【並排比】的理由：③ 不參與減法 ⇒ 它永遠不會排第一，而它可能是最大的一塊。")
    P("")
    P("[穩定性判讀（★機械算，不是我的印象）]")
    top_same = ta[0] == tb[0]
    P("  排行第一是否同一個相位：%s（A=%s／B=%s）" % ("✅ 是" if top_same else "❌ 否", ta[0], tb[0]))
    order_a = [n for n in sorted(a["self"], key=lambda x: -a["self"][x])][:5]
    order_b = [n for n in sorted(b["self"], key=lambda x: -b["self"][x])][:5]
    P("  前五名集合是否相同：%s" % ("✅ 相同" if set(order_a) == set(order_b) else "❌ 不同"))
    P("    A 前五：%s" % " > ".join(order_a))
    P("    B 前五：%s" % " > ".join(order_b))
    P("  前五名【順序】是否相同：%s" % ("✅ 相同" if order_a == order_b else "❌ 不同（★順序不穩 ⇒ 只用一輪挑目標會挑錯）"))
    biggest = []
    for label, x, y in (("①", ta[1], tb[1]), ("②", sa[1], sb[1]), ("③", ma, mb)):
        biggest.append((label, x, y))
    win_a = max(biggest, key=lambda t: t[1])[0]
    win_b = max(biggest, key=lambda t: t[2])[0]
    P("  ★★兩輪各自【最大的那一塊】：A=%s　B=%s ⇒ %s" % (
        win_a, win_b, "✅ 同一塊" if win_a == win_b else "❌★不同塊 ⇒ 目標不可由單輪決定"))
    txt = "\n".join(out)
    sys.stdout.write(txt + "\n")


main()
