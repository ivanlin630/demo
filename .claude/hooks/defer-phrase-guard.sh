#!/usr/bin/env bash
# defer-phrase-guard —— ★新出現的【延後語】必須有對應的 defer token（systems 立 2026-09-06）
#
# ★病：`defer-open` 閘只能追蹤【已經進表的】裁定。而【裁定寫在散文裡、從沒進表】它看不見。
#   —— 那正是「零 LOD 排最後」躺 16 天的原形，★★而它【不會】被 defer-open 抓到。
# ★★本閘不判斷「這是不是一個裁定」（機器判不出來），它只做一件事：
#   【新出現的延後語 ⇒ 停下來回答一次】：是裁定 ⇒ 去 defers.tsv 加一行（含 met_check）；
#   不是 ⇒ 加進 baseline 並在 commit message 說明。
# ★★★沿用 bare-tick 的形狀：★只擋【新出現而沒人判過】的，不擋存量。
set -uo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)" || exit 2
BASE="docs/process/.defer-phrase-baseline.txt"
PAT='排最後|排在[^,，。]{0,8}之後|之後再[做開處]|暫緩|待[^,，。]{0,6}之後|排批後|下一批再'
FILES="docs/progress.md docs/invariants.md docs/known_issues.md"
for f in docs/process/*.md; do FILES="$FILES $f"; done

# ★★★2026-09-06 修錨:baseline 原本用【file:行號:詞】—— 而【行號會位移】
#   ⇒ 在檔案上方插一段文字,下方所有既有條目【全部看起來像新出現的】(今天真的發生了)
#   ⇒ ★★而這個專案早就學過同一條(ki-anchor:錨要用【符號】不用行號)——我蓋這道閘時沒套用
#   ⇒ ★★★改用【file<TAB>詞<TAB>次數】:位移不影響,而【真的多一筆】才會被看見
CUR="$(grep -rEo "$PAT" $FILES 2>/dev/null | sort | uniq -c | awk '{c=$1; $1=""; sub(/^ /,""); print $0"	"c}' | sort)"
[ -f "$BASE" ] || { printf '%s\n' "$CUR" > "$BASE"; echo "[DEFER-PHRASE] baseline 建立（$(printf '%s\n' "$CUR" | grep -c . ) 筆）"; }

NEW="$(comm -13 <(sort "$BASE") <(printf '%s\n' "$CUR"))"
N_CUR=$(printf '%s\n' "$CUR" | grep -c .)
N_NEW=$(printf '%s\n' "$NEW" | grep -c .)
echo "[DEFER-PHRASE] 延後語 $N_CUR 筆｜baseline 內（存量，不擋）$(( N_CUR - N_NEW ))｜★新出現 $N_NEW"
if [ "$N_NEW" -gt 0 ]; then
  printf '%s\n' "$NEW" | sed 's/^/    /'
  echo "[DEFER-PHRASE] ★★這是不是一個【延後裁定】？"
  echo "    ★分界（blueprint 立 2026-09-06）："
  echo "      「歸某 arc／歸某 backlog」 ⇒ ★【合法的家】—— roadmap 是用戶駕駛的，不需要 token"
  echo "      「排某事件之後／排最後／等 X 再做」 ⇒ ★★【要 token】—— 它綁的是一個事件，而事件會過去而沒有人回頭"
  echo "    是 ⇒ 去 docs/process/defers.tsv 加一行（★含可執行的 met_check）"
  echo "    否 ⇒ 把它加進 $BASE 並在 commit message 說明為什麼不是"
  echo "[DEFER-PHRASE] ★★★而【不要】把它悄悄留在散文裡 —— 那正是「排最後」躺 16 天的原形"
  echo "[DEFER-PHRASE] FAIL"; exit 1
fi
echo "[DEFER-PHRASE] PASS"
