# -*- coding: utf-8 -*-
"""★查表位置的中文 key：掃出【全庫只出現一次】的那些。

★為什麼是這個母體（systems 裁 2026-09-12）：
  ·判準是**位置**不是內容 —— **打錯一個 print 訊息無害（人看得懂），
    打錯一個查表 key 會【靜默落到預設值】**，而 code 照跑。
★★而我把 systems 的「比較／查表位置」再收窄一格：**不含字典字面鍵 `"X":`**。
  ·理由：只寫不讀的字典鍵是**輸出標籤** ⇒ 打錯只是標籤難看。
  ·成本證據：含字面鍵 ⇒ 母體 165 種、單次 16 種（其中 15 種是標籤／資料定義）；
    只算讀取位置 ⇒ 母體 133 種、**單次 4 種**，而那 4 種裡有 1 個是真缺陷。
★★★為什麼叫「只出現一次」：**key 天生成對**（一次寫、一次讀）⇒
  只出現一次 ＝ 要嘛剛加還沒被讀，要嘛**它是打錯的那一半**。
"""
import collections
import glob
import io
import os
import re
import sys

CJK = r'[\u4e00-\u9fff][^"]*'
# ★只收【讀取／比較】位置；`"X":` 字面鍵刻意不收（見上）
READ_PATS = [
    r'[=!]=\s*"(%s)"' % CJK,
    r'\.get\(\s*"(%s)"' % CJK,
    # ★★★窄化（implementer 2026-09-23）：`["X"]` 有【兩種】長相，而正則只看得到一種形狀——
    #   ·字典索引 `d["X"]`／`d.skills["X"]`  ＝ 真·讀取（打錯 ⇒ 靜默落預設）
    #   ·陣列字面值 `var a = ["X"]`／`f(x, ["X"])` ＝ 只是【寫】一個一元素陣列
    #   ⇒ ★血證：`var _base: Array = ["糧食跑道（缺趨勢）"]` 被判成單次查表 key 而紅。
    #     ★★而它【之前不紅】——那個陣列本來有兩個元素，`]` 不緊接所以不匹配；
    #     拿掉第二個元素就開始咬 ⇒ 紅不紅取決於【同一行還有沒有別的東西】，不是取決於語意。
    #   ⇒ ★★★修法是【窄化】不是刪掉這一條：要求 `[` 前面是識別字／`)`／`]`（＝真的在索引某個東西）。
    #     刪掉的話所有字典索引讀取都不再掃 ＝ 往反方向製造一個恆過的空真。
    r'(?<=[A-Za-z0-9_\)\]])\[\s*"(%s)"\s*\]' % CJK,
    r'\.has\(\s*"(%s)"' % CJK,
    r'"(%s)"\s+in\b' % CJK,
    r'\.erase\(\s*"(%s)"' % CJK,
]


def _bodies(paths):
    for pat in paths:
        for f in sorted(glob.glob(pat, recursive=True)):
            s = io.open(f, encoding="utf-8", errors="replace").read()
            # ★整行註解與行尾註解都去掉：閘紅在【一句說明】上會教人刪說明而不是修 code
            yield f, "\n".join(ln.split("#")[0] for ln in s.split("\n"))


def scan(paths):
    reads = collections.Counter()
    where = collections.defaultdict(set)
    allc = collections.Counter()
    for f, body in _bodies(paths):
        for m in re.finditer(r'"(%s)"' % CJK, body):
            allc[m.group(1)] += 1
        for p in READ_PATS:
            for m in re.finditer(p, body):
                reads[m.group(1)] += 1
                where[m.group(1)].add(f)
    singles = sorted(k for k in reads if allc[k] == 1)
    return reads, singles, where


# ══════════════════════════════════════════════════════════════════════
# ★★★`--selfcheck`（systems 派工 2026-09-23）：釘住上面那個【窄化】。
#   ★為什麼一定要有：窄化落地之後【沒有任何東西釘住它】——
#     下一個人把 lookahead 拿掉，POP 從 131 變回 133，而卷面看起來一模一樣。
#   ★★★而且【兩個方向都要】：只驗「不再誤咬」的話，**把整條規則刪掉也會綠**。
#   ★樣本＝今天真正咬到的那一行（缺陷變成對照），不是我編的。
#   ★★它餵【真檔】給【真的 scan()】—— 不另寫一份正則比對
#     （手抄一份 ⇒ 兩份可以各自漂，而自檢會替漂掉的那一份背書）。
SELFCHECK_NEG = [
    # （寫入位置：一元素陣列字面值）—— 必須【不算】讀取
    ('var _base: Array = ["糧食跑道（缺趨勢）"]', "糧食跑道（缺趨勢）"),
    ('var tags = ["生產隊伍"]', "生產隊伍"),
    ('add_thing(m_id, ["攻擊指令"])', "攻擊指令"),
]
SELFCHECK_POS = [
    # （讀取位置：真的在索引某個東西）—— 必須【算】讀取
    ('var a = d["統領"]', "統領"),
    ('var b = x.skills["野心"]', "野心"),
    ('var c = f()["好戰"]', "好戰"),
    ('var e = arr[i]["忠心"]', "忠心"),
]


def selfcheck():
    import tempfile
    bad = 0
    tmp = tempfile.mkdtemp()
    path = os.path.join(tmp, "selfcheck_sample.gd")
    for line, key in SELFCHECK_NEG + SELFCHECK_POS:
        io.open(path, "w", encoding="utf-8").write(line + chr(10))
        reads, _singles, _where = scan([path])
        got = reads.get(key, 0)
        want = 0 if (line, key) in SELFCHECK_NEG else 1
        if got != want:
            bad = 1
            if want == 0:
                print("[SELFCHECK] ✗ 誤咬：`%s` 是【寫入】(陣列字面值)，卻被算成讀取 %d 次" % (line, got))
            else:
                print("[SELFCHECK] ✗ 漏咬：`%s` 是【讀取】(字典索引)，卻只算到 %d 次" % (line, got))
    os.remove(path)
    os.rmdir(tmp)
    if bad:
        print("[SELFCHECK] ★FAIL —— ★★兩個方向都要：只驗『不再誤咬』的話，把整條規則刪掉也會綠")
        return 3
    print("[SELFCHECK] PASS（誤咬 %d 例不中、真索引 %d 例全中）" % (
        len(SELFCHECK_NEG), len(SELFCHECK_POS)))
    return 0


def main(argv):
    if "--selfcheck" in argv[1:]:
        return selfcheck()
    paths = argv[1:] or ["scripts/**/*.gd"]
    reads, singles, where = scan(paths)
    # ★★★【實跑 N】（systems 立 2026-09-12）：N＝0 必須是紅 ——
    #   **「一個都沒掃到」與「全部通過」在畫面上長得一樣。**
    print("POP\t%d" % len(reads))
    for k in singles:
        print("HIT\t%s\t%s" % (k, ",".join(sorted(where[k])).replace("\\", "/")))
    return 0


if __name__ == "__main__":
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.exit(main(sys.argv))
