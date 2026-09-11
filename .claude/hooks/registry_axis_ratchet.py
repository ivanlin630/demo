# -*- coding: utf-8 -*-
# 登記錨 ④a 棘輪：手寫的「這支隊在這座村算不算自己人」識別軸 ⇒ 具名紅。
#   ★病歷：同一個問題長出【四種軸】（is_resident_static／_team_works_tile／
#     _unload_excess_material／_faction_owns／_can_invite_settle），
#     而沒有任何一處寫著它們為什麼不同 —— ★★而它們的長法就是【每一處各自手寫一份】。
#   ⇒ 本閘咬的是那個【長法】，不是某一行。
# ★key 用【正規化 code 文字】不是行號（行號會漂，而漂掉的錨會讓表看起來已經維護過）。
#
# ★★★判準的形狀（先裸掃再分類）：裸掃 `outpost_owner ==` 全庫 33 處，
#   而其中大多數問的是【這格是不是我的】＝單純所有權，不是【這支隊算不算自己人】：
#   ①`owner == *.parent_team_id`（組織隸屬軸）⇒ 一律咬
#   ②`owner == *.team_id` 而【同一個函式體】裡又有 `faction_id ==` 比對
#     ⇒ 那正是「本人 or 同 faction」這個複合軸的形狀
#   ★單獨的 `owner == team_id` 不咬 —— 它是所有權問句；
#     ★★把它也咬進來 ＝ 33 筆偽陽 ⇒ baseline 會變成一份沒有人看的清單。
import io, os, re, sys
sys.stdout.reconfigure(encoding="utf-8")

ROOT = sys.argv[1] if len(sys.argv) > 1 else "."
BASELINE = os.path.join(ROOT, "docs/process/registry-axis-baseline.tsv")

PARENT_PAT = re.compile(r"outpost_owner\s*==\s*[\w.]*\bparent_team_id\b|\bparent_team_id\b\s*==\s*[\w.]*outpost_owner")
OWNER_PAT = re.compile(r"outpost_owner\s*==\s*[\w.]*\bteam_id\b")
FACTION_PAT = re.compile(r"\bfaction_id\s*==")
FUNC_PAT = re.compile(r"^(static\s+)?func\s")


def norm(line):
    s = line.split("#", 1)[0]              # ★註解自成一欄：改註解不得讓 key 變（同族教訓）
    return re.sub(r"\s+", " ", s).strip()


def scan(root):
    hits = []
    for base in ("scripts/simulation", "scripts/data"):
        for dirpath, _dirs, files in os.walk(os.path.join(root, base)):
            for fn in files:
                if not fn.endswith(".gd"):
                    continue
                p = os.path.join(dirpath, fn)
                rel = os.path.relpath(p, root).replace("\\", "/")
                lines = io.open(p, encoding="utf-8", errors="replace").read().split("\n")
                # ★函式體粒度：複合軸的第二半（faction 比對）常在下一行 ⇒ 逐行看不出形狀
                bounds = [i for i, l in enumerate(lines) if FUNC_PAT.match(l)] + [len(lines)]
                for bi in range(len(bounds) - 1):
                    a, b = bounds[bi], bounds[bi + 1]
                    body = [norm(l) for l in lines[a:b]]
                    has_faction = any(FACTION_PAT.search(l) for l in body)
                    for off, n in enumerate(body):
                        if not n:
                            continue
                        if PARENT_PAT.search(n):
                            hits.append(("parent-axis", rel, a + off + 1, n))
                        elif OWNER_PAT.search(n) and has_faction:
                            hits.append(("resident-axis", rel, a + off + 1, n))
    return hits


def load_baseline():
    keys = set()
    if not os.path.exists(BASELINE):
        return keys
    for line in io.open(BASELINE, encoding="utf-8").read().split("\n"):
        if not line.strip() or line.startswith("#"):
            continue
        cols = line.split("\t")
        if len(cols) >= 3:
            keys.add((cols[0].strip(), cols[2].strip()))
    return keys


def main():
    hits = scan(ROOT)
    base = load_baseline()
    if not hits and not base:
        print("[RATCHET] ★ABORT：母體 0 筆且 baseline 0 筆 ⇒ 撈法自己壞了，不判綠")
        return 2
    new = [h for h in hits if (h[0], h[3]) not in base]
    stale = base - {(h[0], h[3]) for h in hits}
    print("[RATCHET] 母體 %d 筆手寫識別軸／baseline %d 筆" % (len(hits), len(base)))
    rc = 0
    for axis, rel, i, n in new:
        print("[RATCHET] ★具名紅 %s:%d（%s）：%s" % (rel, i, axis, n))
        print("          ⇒ 改用 state.registered_at() / state.registered_or_parent_at(team, pos, ctx)")
        rc = 1
    if stale:
        for axis, n in sorted(stale):
            print("[RATCHET] ★baseline 有一列在 code 裡找不到了（%s）：%s" % (axis, n))
            print("          ⇒ 那一處已改寫或被刪 ⇒ 請把該列從 baseline 移除（存量只准變少）")
        rc = 1
    if rc == 0:
        print("[RATCHET] ✅ 無新增手寫識別軸")
    return rc


sys.exit(main())
