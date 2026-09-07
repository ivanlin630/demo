# -*- coding: utf-8 -*-
"""列出【對 TeamData 計算屬性的直寫站】—— 重點是它【認接收者的宣告型別】。

★病史（2026-09-07 同一天四個數字）：107 / 58 / 56 / 53 / 52 —— 全是純 grep 的產物，混進了
   ①比較運算子 == ②註解 ③字串字面值 ④★DecisionContext 的【合法】寫入（c.population 是真欄位）
   ⇒ ★★真數是 32（31 TeamData + 1 UNKNOWN）。前四個不是「比較不精確」，它們量的是別的東西。

★誠實限（印在這裡，因為讀輸出的人要看得到）：
   ①型別靠【同檔內的宣告】推；推不出來記 UNKNOWN，★不併進 TeamData 也不丟掉
   ②set("population", v) 這種反射寫入本工具看不到
"""
import io
import re
import sys
import glob
import collections

# Windows 的 python 預設印 CRLF，而 baseline 存的是 LF ⇒ 內容相同卻每一行都 diff。
sys.stdout.reconfigure(newline=chr(10))

PROPS = r'(population|wounded|anon_tiers|anon_combat_skill|anon_wage)'
PAT = re.compile(r'\b([A-Za-z_][A-Za-z_0-9]*)\.' + PROPS + r'\s*=(?!=)')


def strip(line):
    return re.sub(r'"[^"]*"', '', line).split('#')[0]


def decls(src):
    d = {}
    for m in re.finditer(r'\bvar\s+([A-Za-z_][A-Za-z_0-9]*)\s*:?=\s*([A-Za-z_][A-Za-z_0-9]*)\.new\(\)', src):
        d[m.group(1)] = m.group(2)
    for m in re.finditer(r'\bvar\s+([A-Za-z_][A-Za-z_0-9]*)\s*:\s*([A-Za-z_][A-Za-z_0-9]*)', src):
        d.setdefault(m.group(1), m.group(2))
    for m in re.finditer(r'[(,]\s*([A-Za-z_][A-Za-z_0-9]*)\s*:\s*([A-Za-z_][A-Za-z_0-9]*)', src):
        d.setdefault(m.group(1), m.group(2))
    return d


def main():
    # ★★★內建陽性對照：先確認【這支工具自己抓得到】，再去相信它抓到的 0。
    probe = 'var t := TeamData.new()' + chr(10) + 't.population = 5'
    hits = [m for l in probe.split(chr(10)) for m in PAT.finditer(strip(l))]
    if not hits or decls(probe).get('t') != 'TeamData':
        sys.stderr.write('[COMPUTED-PROP] ABORT: 合成陽性樣本沒被抓到 => 本輪結果無效' + chr(10))
        return 2

    rows = []
    kinds = collections.Counter()
    for f in sorted(glob.glob('scripts/**/*.gd', recursive=True)):
        src = io.open(f, encoding='utf-8').read()
        d = decls(src)
        for n, line in enumerate(src.split(chr(10)), 1):
            for m in PAT.finditer(strip(line)):
                t = d.get(m.group(1), 'UNKNOWN')
                kinds[t] += 1
                if t in ('TeamData', 'UNKNOWN'):
                    rows.append('%s %s %s.%s' % (f.replace(chr(92), '/'), t, m.group(1), m.group(2)))

    for k, c in sorted(kinds.items()):
        sys.stderr.write('   %-16s %d%s' % (k, c, chr(10)))

    # ★★★空清單是【要被宣告的事件】，不是可以靜默通過的狀態。
    #   血證 2026-09-07：工具當場 SyntaxError => 空輸出 => 而 baseline 也是同一條壞管線產的
    #   => 閘印 PASS(0 vs 0)。而我內建的陽性對照【根本沒執行】——那個檔連 parse 都沒過。
    #   => 通則：陽性對照必須放在【它所驗證的那個產物之外】。
    if not rows and not int(sys.argv[1] if len(sys.argv) > 1 else 0):
        sys.stderr.write('[COMPUTED-PROP] ABORT: 一站都沒掃到 => 極可能是工具壞了而不是債務清光了' + chr(10))
        sys.stderr.write('                 若真的清光，用 `computed_prop_sites.py 1` 明示允許空清單' + chr(10))
        return 2

    sys.stdout.write(chr(10).join(rows))
    if rows:
        sys.stdout.write(chr(10))
    return 0


sys.exit(main())
