#!/usr/bin/env bash
# ★人格鍵閘：`values.get("X")` 的 X 必須存在（正典 8 鍵，或全庫真的有人寫過的注入鍵）。
#
# ★★血證一（為什麼有這支）：2026-09-09 `fa372e76`（已 merge）把 `貪婪` 打成 `貧婪` 三處。
#   它不是語法錯：Dictionary.get 對不存在的鍵回 default ⇒ 領主的貪婪永遠 0.5，
#   而程式照跑、註解照樣寫著「貪婪↑稅率↑」。
# ★★★血證二（2026-09-09 implementer 踩到）：本閘原本把【註解】算成產線讀點 ——
#   他寫一句註解解釋舊寫法錯在哪，字串出現在註解裡 ⇒ ★閘紅在【一句說明】上而 code 是對的。
#   ⇒ ★★那種紅會教人【把說明刪掉】而不是把 code 修對，與「假紅讓人不再看這支閘」同族。
#   修法：抽鍵前先去掉整行註解與行尾註解（`_strip_comments`）。
#   ★★★而修完必須證明【還抓得到真的】—— `--selfcheck` 成對：註解裡的壞鍵不可紅、
#     code 裡的壞鍵必須紅。只驗前者＝把閘關掉還會通過。
set -u
export LC_ALL=C
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"; cd "$REPO" || exit 2

PD=scripts/data/person_data.gd
BL=docs/process/.value-key-baseline.tsv

# 整行註解 ＋ 行尾註解都去掉（★GDScript 的 `#` 在字串裡罕見，這裡接受該誤差並寫明）
_strip_comments() { sed 's/^[[:space:]]*#.*$//; s/[[:space:]]#.*$//'; }
# $1.. = 要掃的路徑；印出用到的鍵，一行一個
_used_keys() { cat $(grep -rl 'values\.get(' "$@" --include=*.gd 2>/dev/null) 2>/dev/null \
  | _strip_comments | grep -oE 'values\.get\("[^"]+"' | sed 's/.*get("//; s/"$//' | sort -u; }
_injected_keys() { cat $(grep -rl 'values\[' "$@" --include=*.gd 2>/dev/null) 2>/dev/null \
  | _strip_comments | grep -oE '(leader_)?values\["[^"]+"\][[:space:]]*=' \
  | sed 's/.*\["//; s/"\].*//' | sort -u; }

# ── 成對自檢：★註解裡的壞鍵【不可紅】、code 裡的壞鍵【必須紅】 ──
if [ "${1:-}" = "--selfcheck" ]; then
  T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
  printf '# var x = values.get("這是註解裡的假鍵", 0.5)\nvar y = values.get("野心", 0.5)\n' > "$T/a.gd"
  printf 'var z = values.get("這是真的壞鍵", 0.5)\n' > "$T/b.gd"
  a="$(_used_keys "$T/a.gd")"; b="$(_used_keys "$T/b.gd")"
  printf '%s\n' "$a" | grep -qx "這是註解裡的假鍵" && { echo "[VALUE-KEY] ★SELFCHECK FAIL：註解裡的鍵仍被算成讀點"; exit 3; }
  printf '%s\n' "$a" | grep -qx "野心" || { echo "[VALUE-KEY] ★SELFCHECK FAIL：同一檔的真讀點被濾掉了（過濾太兇）"; exit 3; }
  printf '%s\n' "$b" | grep -qx "這是真的壞鍵" || { echo "[VALUE-KEY] ★SELFCHECK FAIL：code 裡的壞鍵抓不到 ⇒ 本閘沒有鑑別力"; exit 3; }
  echo "[VALUE-KEY] SELFCHECK PASS（註解不算讀點／同檔真讀點保留／code 壞鍵仍抓得到）"
  exit 0
fi

# ★★★每一輪都先跑成對自檢（bed-kind 同款）：對照不過 ⇒ 本輪作廢（exit 3），不是「順便通過」。
if ! _SC="$(bash "${BASH_SOURCE[0]}" --selfcheck 2>&1)"; then
  printf '%s
' "$_SC"; echo "[VALUE-KEY] ⇒ ★自檢不過 ⇒ 本輪判決作廢（不是 PASS 也不是 FAIL）"; exit 3
fi

[ -f "$PD" ] || { echo "[VALUE-KEY] ★FAIL：$PD 不存在 ⇒ 正典來源沒了（本閘沒有判過）"; exit 1; }
CANON0="$(awk '/^var values: Dictionary = \{/{f=1;next} f&&/^\}/{f=0} f' "$PD" \
  | grep -oE '"[^"]+"' | tr -d '"' | sort -u)"
NCANON=$(printf '%s\n' "$CANON0" | grep -c .)
if [ "$NCANON" -lt 4 ] || [ "$NCANON" -gt 40 ]; then
  echo "[VALUE-KEY] ★FAIL：正典抽出 $NCANON 個鍵（期望 4-40）⇒ ★抽取方式壞了,不是 code 壞了"; exit 1
fi

# ★★★注入鍵也算正典。判準不是「有沒有底線前綴」（慣例會被繞過），是【全庫有沒有人真的寫過】。
#   血證：decision_context.gd `c.leader_values["_loyalty"] = c.leader_loyalty`
CANON="$(printf '%s\n%s\n' "$CANON0" "$(_injected_keys scripts)" | grep . | sort -u)"

# 產線 FAIL、床-only WARN（床讀一個只有床會設的鍵是另一種病：餵世界不會產生的輸入）
BAD="$(comm -23 <(_used_keys scripts/simulation scripts/data | grep .) <(printf '%s\n' "$CANON"))"
BAD_BED="$(comm -23 <(_used_keys scripts/debug | grep .) <(printf '%s\n' "$CANON"))"
BAD_BED="$(comm -23 <(printf '%s\n' "$BAD_BED" | grep .) <(printf '%s\n' "$BAD" | grep .))"

PROBE="$(printf '%s\n' "$CANON0" | head -1)"
_used_keys scripts | grep -qx "$PROBE" || {
  echo "[VALUE-KEY] ★FAIL：陽性對照失效 —— 正典第一鍵 '$PROBE' 全庫沒有任何 values.get 讀點"
  echo "  ⇒ ★本閘無法證明自己抓得到東西（母體可能是空的）"; exit 1; }

RC=0; KNOWN=""
if [ -f "$BL" ]; then
  while IFS=$'\t' read -r k owner ticket _why; do
    case "$k" in ''|'#'*) continue;; esac
    if [ ! -f "$ticket" ]; then
      echo "[VALUE-KEY] ★FAIL：清單條目 \"$k\" 的 ticket 不存在（$ticket）⇒ 它沒有真的掛在追蹤系統上"; RC=1; continue
    fi
    if ! printf '%s\n' "$BAD" | grep -qx "$k"; then
      echo "[VALUE-KEY] ★FAIL：清單條目 \"$k\" 已經不在產線出現 ⇒ ★該退場的條目不准躺著（去 $BL 刪掉這行）"; RC=1; continue
    fi
    KNOWN="$KNOWN$k"$'\n'
    echo "[VALUE-KEY] ⏳已知未修 \"$k\"（owner=$owner ← $ticket）"
  done < "$BL"
fi
[ -n "$KNOWN" ] && BAD="$(comm -23 <(printf '%s\n' "$BAD" | grep . | sort) <(printf '%s\n' "$KNOWN" | grep . | sort))"

if [ -n "$BAD" ]; then
  echo "[VALUE-KEY] ★FAIL：產線有 values.get 讀【不存在的鍵】⇒ 它永遠回 default,而 code 照跑"
  printf '%s\n' "$BAD" | while read -r k; do
    [ -z "$k" ] && continue
    echo "   ✗ \"$k\""
    grep -rn "values\.get(\"$k\"" scripts/simulation scripts/data --include=*.gd | sed 's/^/       /'
  done
  echo "  ⇒ ★修法：改成正典鍵；若那是【技能】鍵,要讀的是 skills 不是 values。"
  echo "  ★★暫時擋不住工作時：加進 $BL（要附 owner ＋ 存在的 ticket）"
  RC=1
fi
if [ -n "$BAD_BED" ]; then
  echo "[VALUE-KEY] ⚠WARN（不擋 merge）：只在 scripts/debug 出現的非正典鍵 ——"
  echo "  ★另一種病：★★床餵了【世界不會產生的輸入】,那格永遠不會在真世界紅。"
  printf '%s\n' "$BAD_BED" | while read -r k; do
    [ -z "$k" ] && continue; echo "   ⚠ \"$k\""
    grep -rn "values\.get(\"$k\"" scripts/debug --include=*.gd | sed 's/^/       /'
  done
fi
[ "$RC" -eq 0 ] && echo "[VALUE-KEY] PASS：產線所有 values.get 的鍵都存在（正典 $(printf '%s\n' "$CANON" | grep -c .) 鍵）"
exit "$RC"
