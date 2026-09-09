#!/usr/bin/env bash
# 失敗反饋涵蓋率閘 —— spec: docs/superpowers/specs/2026-09-09-failure-feedback-structural-enumeration-HOW.md
#
# ★病：28 個 option 裡只有 2 個有失敗反饋，★★而【缺席是靜默的】——
#   `mult_for_option` 對沒列到的 option 回 1.0，跟「決定它不需要」長得一模一樣。
# ★★★本閘要的不是「都接上」，是【每一個缺席都必須是有人決定的】：
#   兩份表（OPTION_FAIL_KEY / NO_FAILURE_FEEDBACK）互補且互斥，合起來涵蓋全部 option。
#
# ★抽取用 awk 不用 grep：grep 的 ERE 不認 \t ⇒ 第一版母體恆空，
#   ★★而【自檢當場抓到】——那正是「母體為空」該有的下場：不是印 0 支通過，是本輪作廢。
set -u
export LC_ALL=C
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO" || exit 2

OPT_DEFAULT="scripts/simulation/decision/options.gd"
FM_DEFAULT="scripts/simulation/decision/failure_memory.gd"

_opt_names() {   # $1 = options.gd
  awk '/^\t"[^"]+"[ \t]*:[ \t]*\{/ { s = $0; sub(/^\t"/, "", s); sub(/"[ \t]*:.*$/, "", s); print s }' "$1"
}

_dict_keys() {   # $1 = failure_memory.gd, $2 = dict 名
  awk -v d="const $2: Dictionary = {" '
    index($0, d) == 1 { inb = 1; next }
    inb && /^}/ { inb = 0 }
    inb && /^\t"[^"]+"/ { s = $0; sub(/^\t"/, "", s); sub(/".*$/, "", s); print s }' "$1"
}

_bad_reasons() { # $1 = failure_memory.gd —— 理由不得是空話
  awk -v d="const NO_FAILURE_FEEDBACK: Dictionary = {" '
    index($0, d) == 1 { inb = 1; next }
    inb && /^}/ { inb = 0 }
    inb && /^\t"/ { print }' "$1" \
  | grep -v '①\|②\|③\|已有等價機制\|TODO:' \
  | awk '{ s = $0; sub(/^\t"/, "", s); sub(/".*$/, "", s); print s }'
}

# ★★★「已有等價機制」是一個【會腐爛的斷言】：機制被刪掉之後這行字還在，
#   而它會讓下一個人以為這個 option 有失敗反饋。⇒ 要求它指名一個符號,並【驗那個符號還在】。
#   （systems 加 2026-09-09,收第三格的條件。同族：任何「已經有了」的宣稱都要能被證偽。）
_dead_equivalents() { # $1 = failure_memory.gd —— 印出「宣稱有等價機制但符號不存在」的 option
  awk -v d="const NO_FAILURE_FEEDBACK: Dictionary = {" '
    index($0, d) == 1 { inb = 1; next }
    inb && /^}/ { inb = 0 }
    inb && /^	"/ && /已有等價機制/ { print }' "$1"   | { _prev_sym=""
    while IFS= read -r line; do
      opt="$(printf '%s' "$line" | sed 's/^	"//; s/".*$//')"
      # 抓理由裡第一個 Xxx.yyy 形式的符號
      sym="$(printf '%s' "$line" | grep -oE '[A-Z][A-Za-z0-9_]*\.[a-z_][A-Za-z0-9_]*' | head -1)"
      # ★「同上」是合法簡寫,但它【自己會腐爛】(前一條改了它就默默指向別處)
      #   ⇒ 允許它,而【繼承來的符號一樣要被驗】。繼承不到 ⇒ 紅。
      if [ -z "$sym" ] && printf '%s' "$line" | grep -q '同上'; then sym="$_prev_sym"; fi
      if [ -n "$sym" ]; then _prev_sym="$sym"; fi
      if [ -z "$sym" ]; then echo "$opt(理由沒有指名任何 Symbol.method,也繼承不到「同上」的來源)"; continue; fi
      grep -rqF "$sym" scripts/ --include=*.gd || echo "$opt(宣稱的 $sym 在全庫找不到)"
    done; }
}

# 回一行：OK 或紅因（★單一判斷點：陽性對照與真檢查走同一個函式）
check_pair() {
  optf="$1"; fmf="$2"; out=""
  opts="$(_opt_names "$optf")"
  mapped="$(_dict_keys "$fmf" OPTION_FAIL_KEY)"
  nofb="$(_dict_keys "$fmf" NO_FAILURE_FEEDBACK)"
  if [ -z "${opts//[[:space:]]/}" ]; then
    echo "母體為空：$optf 抽不出任何 option（★抽取壞了，不是 code 壞了）"; return
  fi
  while IFS= read -r o; do
    [ -n "$o" ] || continue
    in_m=0; in_n=0
    printf '%s\n' "$mapped" | grep -qxF "$o" && in_m=1
    printf '%s\n' "$nofb" | grep -qxF "$o" && in_n=1
    if [ "$in_m" = "0" ] && [ "$in_n" = "0" ]; then
      out="$out 兩邊都沒有:$o"
    elif [ "$in_m" = "1" ] && [ "$in_n" = "1" ]; then
      out="$out 兩邊都有:$o"
    fi
  done <<EOF
$opts
EOF
  badreason="$(_bad_reasons "$fmf")"
  deadeq="$(_dead_equivalents "$fmf")"
  if [ -n "${deadeq//[[:space:]]/}" ]; then
    out="$out 宣稱已有等價機制但符號不在:$(printf '%s' "$deadeq" | tr '
' ',')"
  fi
  if [ -n "${badreason//[[:space:]]/}" ]; then
    out="$out 理由是空話:$(printf '%s' "$badreason" | tr '\n' ',')"
  fi
  todo_path="$(grep -oE 'const TODO_TICKET: String = "[^"]+"' "$fmf" | sed 's/.*"\(.*\)"/\1/')"
  if grep -q 'TODO:' "$fmf"; then
    if [ -z "$todo_path" ]; then
      out="$out TODO沒有票路徑"
    elif [ ! -f "$todo_path" ]; then
      out="$out TODO指的票不存在:$todo_path"
    fi
  fi
  if [ -n "${out//[[:space:]]/}" ]; then echo "$out"; else echo "OK"; fi
}

# ── 陽性對照（★每輪先跑；★★成對：會紅 + 不會亂紅）──────────────
selftest() {
  bad=0
  d="$(mktemp -d)"
  cp "$OPT_DEFAULT" "$d/opt.gd"; cp "$FM_DEFAULT" "$d/fm.gd"
  r="$(check_pair "$d/opt.gd" "$d/fm.gd")"
  if [ "$r" != "OK" ]; then echo "[FFC] ★對照失準：乾淨的一對被判紅（$r）"; bad=1; fi
  printf '\t"假選項ZZ": {\n' >> "$d/opt.gd"
  r="$(check_pair "$d/opt.gd" "$d/fm.gd")"
  case "$r" in *"兩邊都沒有:假選項ZZ"*) ;; *) echo "[FFC] ★對照失準：加了假 option 卻沒紅/沒具名（$r）"; bad=1;; esac
  cp "$OPT_DEFAULT" "$d/opt.gd"
  awk '{ print } /^const NO_FAILURE_FEEDBACK: Dictionary = \{/ { print "\t\"買糧\": \"①不成立: 對照用\"," }' "$FM_DEFAULT" > "$d/fm2.gd"
  r="$(check_pair "$d/opt.gd" "$d/fm2.gd")"
  case "$r" in *"兩邊都有:買糧"*) ;; *) echo "[FFC] ★對照失準：同一 option 同時在兩份表卻沒紅（$r）"; bad=1;; esac
  rm -rf "$d"
  [ "$bad" = "0" ]
}

if ! selftest; then
  echo "[FFC] ★ABORT：陽性對照沒過 ⇒ 本輪作廢（不得讀成任何結果）"; exit 3
fi
echo "[FFC] 陽性對照通過（乾淨⇒綠｜假 option⇒具名紅｜同時在兩表⇒紅）"

R="$(check_pair "$OPT_DEFAULT" "$FM_DEFAULT")"
N_OPT="$(_opt_names "$OPT_DEFAULT" | grep -c .)"
N_MAP="$(_dict_keys "$FM_DEFAULT" OPTION_FAIL_KEY | grep -c .)"
N_NO="$(_dict_keys "$FM_DEFAULT" NO_FAILURE_FEEDBACK | grep -c .)"
echo "[FFC] option $N_OPT｜有失敗反饋 $N_MAP｜已決定不需要/待接 $N_NO"
if [ "$R" != "OK" ]; then
  echo "[FFC] ★FAIL：$R"
  echo "  ⇒ 每一個 option 必須【剛好】在一份表裡；理由要指名 ①②③ 之一，或 TODO:<存在的票>"
  exit 1
fi
echo "[FFC] PASS"
