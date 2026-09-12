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
    r'\[\s*"(%s)"\s*\]' % CJK,
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


def main(argv):
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
