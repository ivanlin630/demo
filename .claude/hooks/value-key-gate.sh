#!/usr/bin/env bash
# ★人格鍵閘：`values.get("X")` 的 X 必須真的存在（正典 8 鍵，或全庫真的有人寫入過的注入鍵）。
#
# ★★為什麼要有：2026-09-09 血證 —— `fa372e76`（已 merge）把 `貪婪` 打成 `貧婪` 三處
#   （`salary_system.gd:94/106/156`）。★它不是語法錯：Dictionary.get 對不存在的鍵回 default
#   ⇒ 領主的貪婪【永遠是 0.5】，而程式照跑、註解照樣寫著「貪婪↑稅率↑」。
#   ★★同族第二種：`values.get("計謀")`／`values.get("統領")` —— 那兩個是【技能】鍵不是價值鍵
#   ⇒ `advisor_system.gd:25` 的 `> 0.7` 分支【永遠不會 fire】。
#
# ★★★判準是【正典比對】不是【拼字檢查】：正典從 `person_data.gd` 的 `var values` 區塊【讀出來】，
#   不抄一份清單在這裡 —— 抄一份就會 drift，而 drift 的方向剛好是放行。
set -u
export LC_ALL=C
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"; cd "$REPO" || exit 2

PD=scripts/data/person_data.gd
[ -f "$PD" ] || { echo "[VALUE-KEY] ★FAIL：$PD 不存在 ⇒ 正典來源沒了（本閘沒有判過）"; exit 1; }

CANON0="$(awk '/^var values: Dictionary = \{/{f=1;next} f&&/^\}/{f=0} f' "$PD" \
  | grep -oE '"[^"]+"' | tr -d '"' | sort -u)"
NCANON=$(printf '%s\n' "$CANON0" | grep -c .)
# ★母體健全性：正典空掉或大得離譜 ⇒ 抽取壞了，不是 code 壞了
if [ "$NCANON" -lt 4 ] || [ "$NCANON" -gt 40 ]; then
  echo "[VALUE-KEY] ★FAIL：正典抽出 $NCANON 個鍵（期望 4-40）⇒ ★抽取方式壞了,不是 code 壞了"
  exit 1
fi

# ★★★注入鍵也算正典。判準不是「有沒有底線前綴」（慣例會被繞過），
#   是【全庫有沒有人真的寫過這個鍵】。血證：decision_context.gd:581
#   `c.leader_values["_loyalty"] = c.leader_loyalty`
INJECTED="$(grep -rhoE '(leader_)?values\["[^"]+"\][[:space:]]*=' scripts/ --include=*.gd 2>/dev/null \
  | sed 's/.*\["//; s/"\].*//' | sort -u)"
CANON="$(printf '%s\n%s\n' "$CANON0" "$INJECTED" | grep . | sort -u)"

# ★產線與床分開判：床自己造世界，床讀一個只有床會設的鍵是【另一種病】
#   （餵了世界不會產生的輸入 ⇒ 那格永遠不會在真世界紅）⇒ WARN 不擋 merge。
USED_PROD="$(grep -rhoE 'values\.get\("[^"]+"' scripts/simulation scripts/data --include=*.gd 2>/dev/null \
  | sed 's/.*get("//; s/"$//' | sort -u)"
USED_BED="$(grep -rhoE 'values\.get\("[^"]+"' scripts/debug --include=*.gd 2>/dev/null \
  | sed 's/.*get("//; s/"$//' | sort -u)"
BAD="$(comm -23 <(printf '%s\n' "$USED_PROD" | grep .) <(printf '%s\n' "$CANON"))"
BAD_BED="$(comm -23 <(printf '%s\n' "$USED_BED" | grep .) <(printf '%s\n' "$CANON"))"
BAD_BED="$(comm -23 <(printf '%s\n' "$BAD_BED" | grep .) <(printf '%s\n' "$BAD" | grep .))"

# ★★陽性對照：正典第一鍵必須真的有用點，否則本閘證明不了自己抓得到東西
PROBE="$(printf '%s\n' "$CANON0" | head -1)"
grep -rqE "values\.get\(\"$PROBE\"" scripts/ --include=*.gd || {
  echo "[VALUE-KEY] ★FAIL：陽性對照失效 —— 正典第一鍵 '$PROBE' 全庫沒有任何 values.get 用點"
  echo "  ⇒ ★本閘無法證明自己抓得到東西（母體可能是空的）"; exit 1; }

# ★★★已知未修清單（帶到期條件）——見 docs/process/.value-key-baseline.tsv 檔頭。
#   ★它【只會縮短】：ticket 檔不存在 ⇒ 紅；key 已經不在產線而條目還在 ⇒ 紅。
BL=docs/process/.value-key-baseline.tsv
KNOWN=""
RC=0
if [ -f "$BL" ]; then
  while IFS=$'	' read -r k owner ticket _why; do
    case "$k" in ''|'#'*) continue;; esac
    if [ ! -f "$ticket" ]; then
      echo "[VALUE-KEY] ★FAIL：清單條目 \"$k\" 的 ticket 不存在（$ticket）⇒ 它沒有真的掛在追蹤系統上"
      RC=1; continue
    fi
    if ! printf '%s
' "$BAD" | grep -qx "$k"; then
      echo "[VALUE-KEY] ★FAIL：清單條目 \"$k\" 已經不在產線出現 ⇒ ★該退場的條目不准躺著（去 $BL 刪掉這行）"
      RC=1; continue
    fi
    KNOWN="$KNOWN$k"$'
'
    echo "[VALUE-KEY] ⏳已知未修 \"$k\"（owner=$owner ← $ticket）"
  done < "$BL"
fi
# 從 BAD 扣掉已知條目 ⇒ 剩下的才是【新的】
if [ -n "$KNOWN" ]; then
  BAD="$(comm -23 <(printf '%s
' "$BAD" | grep . | sort) <(printf '%s
' "$KNOWN" | grep . | sort))"
fi
if [ -n "$BAD" ]; then
  echo "[VALUE-KEY] ★FAIL：產線有 values.get 讀【不存在的鍵】⇒ 它永遠回 default,而 code 照跑"
  printf '%s\n' "$BAD" | while read -r k; do
    [ -z "$k" ] && continue
    echo "   ✗ \"$k\""
    grep -rn "values\.get(\"$k\"" scripts/simulation scripts/data --include=*.gd | sed 's/^/       /'
  done
  echo "  ⇒ ★修法：改成正典鍵；若那是【技能】鍵,要讀的是 skills 不是 values。"
  echo "  ★★暫時擋不住工作時：加進 docs/process/.value-key-baseline.tsv（要附 owner + 存在的 ticket）"
  echo "  ★★正典（$PD 的 $NCANON 鍵 + 全庫寫入過的注入鍵）：$(printf '%s ' $CANON)"
  RC=1
fi
if [ -n "$BAD_BED" ]; then
  echo "[VALUE-KEY] ⚠WARN（不擋 merge）：只在 scripts/debug 出現的非正典鍵 ——"
  echo "  ★另一種病：★★床餵了【世界不會產生的輸入】,那格永遠不會在真世界紅。"
  printf '%s\n' "$BAD_BED" | while read -r k; do
    [ -z "$k" ] && continue
    echo "   ⚠ \"$k\""
    grep -rn "values\.get(\"$k\"" scripts/debug --include=*.gd | sed 's/^/       /'
  done
fi
[ "$RC" -eq 0 ] && echo "[VALUE-KEY] PASS：產線所有 values.get 的鍵都存在（正典 $(printf '%s\n' "$CANON" | grep -c .) 鍵）"
exit "$RC"
