# -*- coding: utf-8 -*-
"""多 seed 方向表：兩臂 x N seed，★只出【符號】不出幅度。

★★為什麼只出符號：兩臂之間換了一整代的 code（gen2 = 攻擊門之前、gen4 = 機會項之後）
   ⇒ 絕對值跨代不可比（同一個世界前後加 tap 就能讓「>2s 幀數」+64%）。
★★★而三個結論只有三種，事先寫死在這裡，不是看到數字才挑：
     ①真趨勢     = 每一個 seed 的符號都同向
     ②蝴蝶       = 符號不同向（seed 之間就翻了 ⇒ 這條軸講不出因果）
     ③趨勢成立而幅度不可引用 = 符號同向，而 seed 間幅度差一個量級以上
   ★注意：本檔【不寫】「因為加了 X 所以 Y」這種單因歸因句 —— 兩臂差的是一整代。
"""
import io, os, re, sys, glob

# ★強制 UTF-8 輸出：否則 Windows 主控台是 CP950 ⇒ 中文/箭頭直接丟例外（而那會看起來像「腳本壞了」）
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

SCRATCH = os.environ.get("SCRATCH") or os.path.join(
    os.environ.get("TEMP", "."), "claude", "A--GDS-demo",
    "f32c580a-c82d-42ec-8bd1-74440a31cd93", "scratchpad")

# ★幅度地板：逐 seed 的相對變化最大／最小 >= 它，就判【幅度不可引用】。
# ★★它是在看到數字【之前】定的 —— 看到數字才決定「這個差距算大」那叫挑。
MAG_SPREAD_MAX = 10

METRICS = [("開打", r"開打 conq\.combat_entered\s*=\s*(\d+)"),
           ("結束", r"結束 combat\.ended_n\s*=\s*(\d+)"),
           ("滅團", r"滅團 合計\s*=\s*(\d+)"),
           ("勒索", r"勒索 raid\.extort\s*=\s*(\d+)")]


def read_run(path):
    txt = io.open(path, encoding="utf-8", errors="replace").read()
    if "[TEST-SUITE-COMPLETE]" not in txt:
        return None                      # ★沒有完成標記 = 本輪無結果（不是 0、不是紅）
    out = {}
    for name, pat in METRICS:
        m = re.search(pat, txt)
        out[name] = int(m.group(1)) if m else None
    m = re.search(r"★fp = ([0-9a-f]+)", txt)
    out["fp"] = m.group(1) if m else "?"
    return out


def main():
    runs = {}
    for p in sorted(glob.glob(os.path.join(SCRATCH, "cm_gen*_s*.log"))):
        m = re.search(r"cm_(gen\d)_s(\d+)\.log$", p.replace("\\", "/"))
        if not m:
            continue
        r = read_run(p)
        runs[(m.group(1), m.group(2))] = r        # None = 未完成

    arms = sorted({k[0] for k in runs})
    seeds = sorted({k[1] for k in runs})
    print("★母體：%d 臂 x %d seed = %d 格；★★而【實際完成】的格數才是分母" % (
        len(arms), len(seeds), len(arms) * len(seeds)))
    done = sum(1 for v in runs.values() if v)
    print("   完成 %d 格／落地 %d 格 %s" % (
        done, len(runs), "" if done == len(arms) * len(seeds)
        else "★★★不足 ⇒ 下面的表【不可下結論】，只是進度"))
    for k in sorted(runs):
        v = runs[k]
        print("   %s/%s : %s" % (k[0], k[1], "未完成（無結果）" if not v else
                                 " ".join("%s=%s" % (n, v[n]) for n, _ in METRICS) + " fp=" + v["fp"][:8]))

    if len(arms) != 2:
        print("★臂數 != 2 ⇒ 方向表不可判（它的定義就是兩臂相比）")
        return
    a, b = arms
    print("")
    print("★★★方向表（%s → %s；★只印符號：↑ / ↓ / ＝ / 不可判）" % (a, b))
    for name, _ in METRICS:
        cells, signs, mags = [], [], []
        for s in seeds:
            ra, rb = runs.get((a, s)), runs.get((b, s))
            if not ra or not rb or ra[name] is None or rb[name] is None:
                cells.append("%s:不可判" % s); signs.append(None); mags.append(None); continue
            d = rb[name] - ra[name]
            sg = "＝" if d == 0 else ("↑" if d > 0 else "↓")
            cells.append("%s:%s" % (s, sg)); signs.append(sg)
            # ★幅度用【相對變化】，因為兩臂的絕對母體本來就不同
            mags.append(abs(d) / float(max(ra[name], 1)))
        known = [x for x in signs if x]
        if not known:
            verdict = "★母體 0 ⇒ 不可判"
        elif len(known) < len(seeds):
            verdict = "★只有 %d/%d 個 seed ⇒ 先不判（缺格不是同向的證據）" % (len(known), len(seeds))
        elif len(set(known)) > 1:
            verdict = "★★蝴蝶（seed 之間符號就翻了 ⇒ 這條軸講不出因果）"
        else:
            km = [m for m in mags if m is not None]
            lo, hi = min(km), max(km)
            if hi > 0.0 and lo > 0.0 and hi / lo >= MAG_SPREAD_MAX:
                verdict = ("★★★趨勢成立【而幅度不可引用】（逐 seed 相對變化 %.2f ~ %.2f，"
                           "差 %.1f 倍 ≥ %d）" % (lo, hi, hi / lo, MAG_SPREAD_MAX))
            else:
                verdict = "★真趨勢（符號同向，且逐 seed 幅度 %.2f ~ %.2f 未跨量級）" % (lo, hi)
        print("   %-4s %s ｜ %s" % (name, "  ".join(cells), verdict))
    print("")
    print("★★而「同向」只說【方向】在這幾個 seed 上穩，**不說原因** ——")
    print("   兩臂之間差的是【一整代 code】，不是一個開關 ⇒ 禁止寫單因歸因句。")


if __name__ == "__main__":
    main()
