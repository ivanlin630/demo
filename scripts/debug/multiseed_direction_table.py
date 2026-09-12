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
    scratch = os.environ.get("SCRATCH") or SCRATCH   # ★每次呼叫重讀：否則對照會掃到真的 scratchpad
    for p in sorted(glob.glob(os.path.join(scratch, "cm_gen*_s*.log"))):
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


# ────────────────────────────────────────────────────────────────────────
# ★★★逐結論陽性對照（systems 2026-09-12 加的驗收格）
#   ★規矩：**每一種結論，都要有一組能讓它亮一次的輸入** ——
#   ★★因為「從來沒亮過」與「這次不該亮」在畫面上長得一模一樣。
#   ★★★而它留在檔案裡，不是跑過就算：**下次有人改這支彙整器，這三組是唯一會攔住他的東西。**
#   跑法：python scripts/debug/multiseed_direction_table.py --selftest
# ────────────────────────────────────────────────────────────────────────

def _fixture(tmp, arm, seed, v):
    # ★換行用 chr(10) 不用跳脫字元：編輯工具會把它靜默展開成真的換行（本檔已中過兩次）
    NL = chr(10)
    body = NL.join([
        "   開打 conq.combat_entered = %d" % v,
        "   結束 combat.ended_n      = %d" % v,
        "   滅團 合計                = 0",
        "   勒索 raid.extort         = %d" % v,
        "★fp = deadbeef",
        "[TEST-SUITE-COMPLETE]", ""])
    io.open(os.path.join(tmp, "cm_%s_s%s.log" % (arm, seed)), "w", encoding="utf-8").write(body)


def _verdict_of(cells, metric="開打"):
    for ln in cells.splitlines():
        if ln.strip().startswith(metric):
            return ln.split("｜")[-1].strip()
    return "(沒印出這一列)"


def _run_case(name, rows, expect_key):
    """rows = {(arm, seed): value}；回傳 (通過?, 實得判詞)"""
    import tempfile, shutil, io as _io, contextlib
    tmp = tempfile.mkdtemp(prefix="ms_pc_")
    try:
        for (arm, seed), v in rows.items():
            _fixture(tmp, arm, seed, v)
        os.environ["SCRATCH"] = tmp
        buf = _io.StringIO()
        with contextlib.redirect_stdout(buf):
            main()
        got = _verdict_of(buf.getvalue())
        return (expect_key in got), got
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def selftest():
    cases = [
        # ①真趨勢：三 seed 同向、幅度相近
        ("①真趨勢", {("gen2", "1"): 100, ("gen4", "1"): 150,
                      ("gen2", "2"): 100, ("gen4", "2"): 160,
                      ("gen2", "3"): 100, ("gen4", "3"): 140}, "真趨勢（符號同向"),
        # ②蝴蝶：方向不一致
        ("②蝴蝶", {("gen2", "1"): 100, ("gen4", "1"): 150,
                    ("gen2", "2"): 100, ("gen4", "2"):  50,
                    ("gen2", "3"): 100, ("gen4", "3"): 140}, "蝴蝶"),
        # ③幅度不可引用：同向而幅度跨量級（★這裡刻意取【明顯高於地板】的一組，
        #   因為這一格要證的是【接線通不通】，不是地板定在哪）
        ("③幅度不可引用", {("gen2", "1"): 100, ("gen4", "1"): 105,
                            ("gen2", "2"): 100, ("gen4", "2"): 200,
                            ("gen2", "3"): 100, ("gen4", "3"): 300}, "幅度不可引用"),
    ]
    bad = 0
    print("★★★逐結論陽性對照（每一種結論都要能亮一次）  地板 MAG_SPREAD_MAX=%d" % MAG_SPREAD_MAX)
    for name, rows, expect in cases:
        ok, got = _run_case(name, rows, expect)
        print("   %-14s %s  實得：%s" % (name, "[OK]" if ok else "[FAIL]", got))
        if not ok:
            bad += 1

    # ★★地板校準（★這一格不是對照，是把【歧異】攤開）：
    #   systems 舉的例子是 −79%／−12%／−90% ⇒ 幅度比 0.90／0.12 ＝ 7.5 倍。
    #   ⇒ 它在現行地板（10）下判不出第三種。**地板該定多少是 systems 的裁決**，不是我看資料挑的。
    _, got = _run_case("地板校準", {("gen2", "1"): 100, ("gen4", "1"): 21,
                                     ("gen2", "2"): 100, ("gen4", "2"): 88,
                                     ("gen2", "3"): 100, ("gen4", "3"): 10}, "@@never@@")
    print("   ★地板校準：systems 的例子（−79%%／−12%%／−90%%，幅度比 7.5 倍）在地板 %d 下判成：" % MAG_SPREAD_MAX)
    print("      %s" % got)
    print("      ⇒ ★這【不是】對照的紅綠，是一個**待裁**：地板要 10 還是 ≤7.5，歸 systems。")

    print("=== SELFTEST === 對照 %d 組｜FAILS=%d" % (len(cases), bad))
    return 1 if bad else 0


if __name__ == "__main__":
    if "--selftest" in sys.argv:
        sys.exit(selftest())
    main()
