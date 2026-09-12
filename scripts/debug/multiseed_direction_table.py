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

# ★★★【結構解】這一檔**不再有 import 期就成形的設定常數**。
#   ★理由：同一個檔已經犯過兩次（SCRATCH、EXPECT_SEEDS）——
#   ★★**第二次就不是失誤，是這個檔的結構在邀請它**（systems 2026-09-12）。
#   ⇒ 下面兩支**每次呼叫才解析**；想拿設定就只能經過它們。
#   ⇒ ★★★而它有一個會紅的證明：`--selftest` 的④ 格在 **import 之後**才改環境，
#     若哪天有人又把它寫回模組層常數，那一格會紅。

def _scratch():
    return os.environ.get("SCRATCH") or os.path.join(
        os.environ.get("TEMP", "."), "claude", "A--GDS-demo",
        "f32c580a-c82d-42ec-8bd1-74440a31cd93", "scratchpad")


def _expect_seeds():
    # ★驅動器真實的 seed 清單（讀 Win32_Process 命令列查證，不是猜）
    return [x for x in (os.environ.get("EXPECT_SEEDS") or "1337,4242,7").split(",") if x]


def _expect_arms():
    return [x for x in (os.environ.get("EXPECT_ARMS") or "gen2,gen4").split(",") if x]

# ★幅度地板（systems 裁 2026-09-12）：**相對極差 ＝（最大幅度 − 最小幅度）／中位幅度**
# ★★不用倍數比（max/min）：它對小數字過度敏感 —— −80%% vs −8%% 是 10 倍，
#   −8%% vs −0.8%% 也是 10 倍，而前者是「幾乎消失 vs 小幅下降」、後者是「兩個都幾乎沒動」。
# ★★★0.5 有意思：**不確定性達到效果本身的一半**。
#   ★預註冊於【六趟到齊之前】；若日後覺得不合適，**下一張票才改**且要寫明
#   「上一張票用的是 0.5」—— **不准回頭改這一張的判準**。
REL_RANGE_MAX = 0.5

# ★★★【宣告式母體】：預期跑哪幾個 seed 是**寫在這裡**的，不是從檔案推出來的。
#   ★若母體靠【發現】，那麼「第三個 seed 從頭到尾沒跑過」會被印成
#   「2 臂 x 2 seed，全部完成」—— **一張看起來很完整的半張表**。
#   ★★驅動器的 seed 清單：1337, 4242, 7（可用 EXPECT_SEEDS 覆蓋）。

METRICS = [("開打", r"開打 conq\.combat_entered\s*=\s*(\d+)"),
           ("結束", r"結束 combat\.ended_n\s*=\s*(\d+)"),
           ("滅團", r"滅團 合計\s*=\s*(\d+)"),
           ("勒索", r"勒索 raid\.extort\s*=\s*(\d+)")]


def read_run(path):
    txt = io.open(path, encoding="utf-8", errors="replace").read()
    tree, chash = "?", ""
    for ln in txt.splitlines():
        if "[TREE]" not in ln or "commit=" not in ln:
            continue
        mc = re.search(r"commit=(\w+)", ln)
        mk = re.search(r"clean=(\S+)", ln)
        mh = re.search(r"codehash=(\w+)", ln)
        tree = mc.group(1) + "/" + (mk.group(1) if mk else "?")
        # ★★★codehash 是 2026-09-12 11:09 才加的 ⇒ **在那之前跑完的趟次永遠拿不到**。
        #   ★所以「沒有 codehash」不是一種值，是【證據不存在】—— 兩者不可混。
        chash = mh.group(1) if mh else ""
        break
    if "[TEST-SUITE-COMPLETE]" not in txt:
        # ★沒有完成標記 = 本輪無結果（不是 0、不是紅）
        # ★★而【樹的身分】照樣要回：**污染與跑不跑得完無關**
        return {"tree": tree, "chash": chash, "done": False}
    out = {}
    for name, pat in METRICS:
        m = re.search(pat, txt)
        out[name] = int(m.group(1)) if m else None
    m = re.search(r"★fp = ([0-9a-f]+)", txt)
    out["fp"] = m.group(1) if m else "?"
    out["tree"] = tree
    out["chash"] = chash
    out["done"] = True
    return out


def _self_identity():
    """★分析器自報身分（★★跟【跑的時候那棵樹】同一個道理）。
    ★理由：systems 2026-09-12 把規則從【對象】改成【角色】：
      **量測進行中，被量的樹與量測器都不動** ——
    ★★而這支分析器就是量測鏈的一環（它只讀跑完的 log，碰不到那幾趟，
      而【碰不到】要是一句**可查證的宣告**，不是一句自述）。
    """
    import subprocess
    here = os.path.dirname(os.path.abspath(__file__))
    def _git(*a):
        try:
            return subprocess.check_output(("git",) + a, cwd=here,
                                           stderr=subprocess.DEVNULL).decode("utf-8", "replace").strip()
        except Exception:
            return "?"
    sha = _git("rev-parse", "--short", "HEAD")
    rel = "scripts/debug/" + os.path.basename(__file__)
    dirty = _git("status", "--porcelain", "--", rel)
    return sha, ("dirty" if dirty else "clean")


def main():
    runs = {}
    expect = _expect_seeds()
    expect_arms = _expect_arms()
    scratch = _scratch()
    for p in sorted(glob.glob(os.path.join(scratch, "cm_gen*_s*.log"))):
        m = re.search(r"cm_(gen\d)_s(\d+)\.log$", p.replace("\\", "/"))
        if not m:
            continue
        r = read_run(p)
        runs[(m.group(1), m.group(2))] = r

    arms = sorted(set(expect_arms) | {k[0] for k in runs})
    seeds = sorted(set(expect) | {k[1] for k in runs})
    # ★★★【宣告式母體】：掃到的少於宣告的 ⇒ **紅**（systems 要求成硬的）。
    #   ★發現式母體會把「沒發生」變成「不存在」，而**不存在的東西不會出現在表上**。
    absent = [(a, sd) for a in expect_arms for sd in expect if (a, sd) not in runs]
    unfinished = [k for k, v in runs.items() if not v["done"]]
    red = bool(absent) or bool(unfinished) or not runs   # ★實跑 0 格也是紅
    if absent:
        print("★★★【紅】宣告 %d 格，而其中 %d 格**連 log 都沒有**：%s" % (
            len(expect_arms) * len(expect), len(absent),
            ", ".join("%s/%s" % c for c in absent)))
        print("   ⇒ ★這不是「跑了沒變化」，是【根本還沒跑】—— 兩者在半張表上長得一模一樣")
        print("   ⇒ ★★而缺席的那一格不會自己跳出來，所以沒有人會發現它缺席")
    # ★★★通則（systems 立 2026-09-12）：**任何自檢／閘的輸出必須包含【實跑 N】，而 N ＝ 0 ⇒ 紅**。
    #   ★理由：**「一格也沒跑」與「全部通過」在畫面上長得一樣** —— 都是沒紅字 ＋ 回傳碼 0。
    _sha, _st = _self_identity()
    print("★分析器自報：%s @ %s/%s（★只讀跑完的 log，不參與任何一趟）" % (
        os.path.basename(__file__), _sha, _st))
    print("★【實跑】掃到並解析的 log：%d 格%s" % (
        len(runs), "" if runs else "  ★★★【紅】實跑 0 格 ⇒ 這不是「全過」，是【什麼都沒量】"))
    print("★母體：%d 臂 x %d seed = %d 格；★★而【實際完成】的格數才是分母" % (
        len(arms), len(seeds), len(arms) * len(seeds)))
    done = sum(1 for v in runs.values() if v["done"])
    print("   完成 %d 格／落地 %d 格 %s" % (
        done, len(runs), "" if done == len(arms) * len(seeds)
        else "★★★不足 ⇒ 下面的表【不可下結論】，只是進度"))
    for k in sorted(runs):
        v = runs[k]
        print("   %s/%s : %s" % (k[0], k[1], ("未完成（無結果） tree=" + v["tree"] + ("/" + v["chash"] if v["chash"] else "/無codehash")) if not v["done"] else
                                 " ".join("%s=%s" % (n, v[n]) for n, _ in METRICS)
                                 + " fp=" + v["fp"][:8] + " tree=" + v["tree"]
                                 + ("/" + v["chash"] if v["chash"] else "/無codehash")))

    # ★★★一臂之内【樹的身分】必須一致，否則這三趟**不是同一臂**。
    #   ★血證 2026-09-12：我在量測進行中往被量的 worktree commit 了 sim code，
    #   ★★而**兩趟都跑完、都有 fp、都印 DONE** —— 症狀是零。
    for a in arms:
        mine = [v for k, v in runs.items() if k[0] == a]
        hs = sorted({v["chash"] for v in mine if v["chash"]})
        if len(hs) > 1:
            red = True
            print("★★★【紅】臂 %s 的 codehash 不一致：%s（★直接證據）" % (a, " vs ".join(hs)))
        elif len(hs) < len(mine):
            print("★臂 %s 裡有 %d/%d 趟**沒有 codehash**（跑在它加進來之前）" % (
                a, len(mine) - len(hs), len(mine)))
            print("   ⇒ ★★那幾趟只能停在 sha 與 mtime 的【間接證據】，**追溯不回來**")
        ts = sorted({v["tree"] for v in mine})
        if len(ts) > 1:
            red = True
            print("★★★【紅】臂 %s 的各趟**不是同一棵樹**：%s" % (a, " vs ".join(ts)))
            print("   ⇒ ★這三趟不可合為一臂，除非用 fp 證明那次變動對世界無影響")
            print("   ⇒ ★★而【commit sha 相同】也不等於 code 相同：clean=NO 時樹是髒的")
    if len(arms) != 2:
        print("★臂數 != 2 ⇒ 方向表不可判（它的定義就是兩臂相比）")
        return 1
    a, b = arms
    print("")
    print("★★★方向表（%s → %s；★只印符號：↑ / ↓ / ＝ / 不可判）" % (a, b))
    for name, _ in METRICS:
        cells, signs, mags = [], [], []
        for s in seeds:
            ra, rb = runs.get((a, s)), runs.get((b, s))
            if not ra or not rb or not ra["done"] or not rb["done"] or ra[name] is None or rb[name] is None:
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
            km = sorted(m for m in mags if m is not None)
            lo, hi = km[0], km[-1]
            med = km[len(km) // 2] if len(km) % 2 else (km[len(km) // 2 - 1] + km[len(km) // 2]) / 2.0
            rel = (hi - lo) / med if med > 0.0 else 0.0
            if rel >= REL_RANGE_MAX:
                verdict = ("★★★趨勢成立【而幅度不可引用】（逐 seed 幅度 %s；"
                           "相對極差 %.2f ≥ %.2f —— 不確定性達到效果本身的一半）"
                           % (", ".join("%.2f" % m for m in km), rel, REL_RANGE_MAX))
            else:
                verdict = ("★真趨勢（符號同向；逐 seed 幅度 %s；相對極差 %.2f < %.2f）"
                           % (", ".join("%.2f" % m for m in km), rel, REL_RANGE_MAX))
        print("   %-4s %s ｜ %s" % (name, "  ".join(cells), verdict))
    print("")
    print("★★而「同向」只說【方向】在這幾個 seed 上穩，**不說原因** ——")
    print("   兩臂之間差的是【一整代 code】，不是一個開關 ⇒ 禁止寫單因歸因句。")
    if red:
        print("★★★【紅】宣告的格子沒到齊（缺 %d 格／未完成 %d 格）⇒ 這張表**不是結果**。" % (
            len(absent), len(unfinished)))
    return 1 if red else 0


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
        os.environ["EXPECT_SEEDS"] = "1,2,3"   # ★自檢的輸入要自己凍結，不從外面拿
        os.environ["EXPECT_ARMS"] = "gen2,gen4"
        buf = _io.StringIO()
        with contextlib.redirect_stdout(buf):
            rc = main()   # ★對照裡只能呼叫，不能 sys.exit（否則第一格就結束整個程序而 rc 還是 0）
        got = _verdict_of(buf.getvalue())
        return (expect_key in got), got
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def _case_post_import_env():
    """★★★結構解的【會紅的證明】（systems 2026-09-12 要求）：
    在 **import 之後** 才把宣告改成四個 seed，而磁碟上只有三個。
    ★若哪天有人又把設定寫回模組層常數，這一格會紅（改不動 ⇒ 看不到第四個）。
    ★★同時也是【宣告式母體】的對照：缺格必須具名、必須紅（回傳碼 1）。
    """
    import tempfile, shutil, io as _io, contextlib
    tmp = tempfile.mkdtemp(prefix="ms_pc_")
    try:
        for arm, v in (("gen2", 100), ("gen4", 150)):
            for sd in ("1", "2", "3"):
                _fixture(tmp, arm, sd, v)
        os.environ["SCRATCH"] = tmp
        os.environ["EXPECT_ARMS"] = "gen2,gen4"
        os.environ["EXPECT_SEEDS"] = "1,2,3,4"      # ★第四個磁碟上沒有
        buf = _io.StringIO()
        with contextlib.redirect_stdout(buf):
            rc = main()
        out = buf.getvalue()
        named = ("gen2/4" in out) and ("gen4/4" in out)
        return (rc == 1 and named), ("rc=%d｜有具名缺格=%s" % (rc, named))
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


# ★★★【字形相近的錯字】黑名單：鍵 = 錯的碼位，值 = 對的碼位。
#   ★理由：我今天在這一支檔裡把同一個字打錯 **五次**（U+8DA1 不等於 U+8D9F），
#   ★★而它在 CP950 主控台是亂碼 ⇒ **看不出來**，每次都是逐字比碼位才抓到。
#   ★★★所以把它從【靠記得】變成【表上一格】—— 同一族：覺／覓、滋團／滅團。
CONFUSABLES = {0x8DA1: 0x8D9F}


def _case_no_confusables():
    src = io.open(os.path.abspath(__file__), encoding="utf-8").read()
    hits = [(hex(bad), src.count(chr(bad))) for bad in CONFUSABLES if chr(bad) in src]
    return (not hits), ("本檔無黑名單字" if not hits else "中彈：%s" % hits)


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
        # ★①-b systems 同一封給的**不該紅**那組：−79%%／−70%%／−85%%
        #   ★★中位 0.79、極差 0.15 ⇒ 0.19 ⇒ 應判真趨勢（成對對照：會紅 ＋ 不會亂紅）
        ("①-b 不該紅", {("gen2", "1"): 100, ("gen4", "1"): 21,
                        ("gen2", "2"): 100, ("gen4", "2"): 30,
                        ("gen2", "3"): 100, ("gen4", "3"): 15}, "真趨勢"),
        # ★③ 直接用 systems 裁文裡的例子：−79%%／−12%%／−90%%
        #   ★★中位 0.79、極差 0.78 ⇒ 相對極差 0.99 ⇒ 應判第三種
        ("③幅度不可引用", {("gen2", "1"): 100, ("gen4", "1"): 21,
                            ("gen2", "2"): 100, ("gen4", "2"): 88,
                            ("gen2", "3"): 100, ("gen4", "3"): 10}, "幅度不可引用"),
    ]
    bad = 0
    ran = 0
    print("★★★逐結論陽性對照（每一種結論都要能亮一次）  判準：相對極差 ≥ %.2f ⇒ 幅度不可引用" % REL_RANGE_MAX)
    for name, rows, expect in cases:
        ok, got = _run_case(name, rows, expect)
        print("   %-14s %s  實得：%s" % (name, "[OK]" if ok else "[FAIL]", got))
        ran += 1
        if not ok:
            bad += 1

    ok6, got6 = _case_no_confusables()
    ran += 1
    if not ok6:
        bad += 1
    print("   %-14s %s  實得：%s" % ("⑥ 錯字碼位", "[OK]" if ok6 else "[FAIL]", got6))

    ok5, got5 = _case_post_import_env()
    ran += 1
    if not ok5:
        bad += 1
    print("   %-14s %s  實得：%s" % ("⑤ import 後改宣告", "[OK]" if ok5 else "[FAIL]", got5))

    # ★★★【對照本身的母體】：跑過的格數必須等於宣告的格數。
    #   ★血證：有一次對照因為裡面誤寫 `sys.exit` 而**第一格就結束整個程序**，
    #   ★★而它印了標題、一格也沒跑、**回傳碼還是 0** ⇒ 靜默 no-op 被讀成全綠。
    declared = len(cases) + 2
    if ran == 0:
        print("=== SELFTEST === ★★★【紅】實跑 0 組 ⇒ 對照什麼都沒測（而它看起來跟全綠一樣）")
        return 1
    if ran != declared:
        print("=== SELFTEST === ★★★【紅】宣告 %d 組，而實際跑了 %d 組 ⇒ 對照自己沒跑完" % (declared, ran))
        return 1
    print("=== SELFTEST === 【實跑】%d 組（宣告 %d，對得上）｜FAILS=%d" % (ran, declared, bad))
    return 1 if bad else 0


if __name__ == "__main__":
    if "--selftest" in sys.argv:
        sys.exit(selftest())
    sys.exit(main())
