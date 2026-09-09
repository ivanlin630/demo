#!/usr/bin/env bash
# ctx 覆蓋率閘 —— spec: docs/superpowers/specs/2026-09-10-observer-inspect-depth-HOW.md
#
# ★病：「玩家看不到引擎在看什麼」而【缺席是靜默的】——沒有人會因為少一欄而紅。
# ★★母體＝decision_context.gd 的 var 欄位；每一欄必須【剛好】出現在 ctx-exposure.tsv 一次。
# ★★★而豁免的腐爛【方向與 failure-feedback 那支相反】（R² 指出）：
#   那支驗的是「宣稱引用的符號消失了」；★這裡的腐爛是【欄位開始被別的消費者讀走】——
#   理由沒變、欄位沒被刪，而它已經被某支查詢動詞接上了 ⇒ 豁免前提不成立，
#   ★★而清單那一行【完全不會顯示任何變化】⇒ 必須【反向查】：豁免欄位不得出現在玩家可見查詢面。
set -u
export LC_ALL=C
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO" || exit 2

CTX="scripts/simulation/decision/decision_context.gd"
TSV="${CTX_EXPOSURE_TSV:-docs/process/ctx-exposure.tsv}"
SUP="${CTX_SUPPLEMENT_TSV:-docs/process/ctx-supplement.tsv}"
# ★玩家可見查詢面（腐爛反向查的母體）
SURFACES="scripts/simulation/player_query_api.gd scripts/simulation/player_api_mapper.gd scripts/simulation/observer_query_api.gd"

_ctx_fields() {   # $1 = decision_context.gd
  awk '/^var [A-Za-z_][A-Za-z0-9_]*/ { s = $2; sub(/:.*$/, "", s); sub(/=.*$/, "", s); print s }' "$1"
}

_rows() {         # $1 = tsv ⇒ 印 "field<TAB>status<TAB>pages<TAB>who"
  awk -F'\t' 'NF >= 4 && $1 !~ /^#/ && $1 != "field" { print $1 "\t" $2 "\t" $3 "\t" $4 }' "$1"
}

# 回一行：OK 或紅因（★真檢查與陽性對照走同一個函式）
check_pair() {
  ctxf="$1"; tsvf="$2"; surfaces="$3"; out=""
  fields="$(_ctx_fields "$ctxf")"
  if [ -z "${fields//[[:space:]]/}" ]; then
    echo "母體為空：$ctxf 抽不出任何 var 欄位（★抽取壞了，不是 code 壞了）"; return
  fi
  rows="$(_rows "$tsvf")"
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    n="$(printf '%s\n' "$rows" | awk -F'\t' -v k="$f" '$1==k{c++} END{print c+0}')"
    if [ "$n" = "0" ]; then out="$out 表裡沒有:$f"
    elif [ "$n" != "1" ]; then out="$out 表裡出現 $n 次:$f"; fi
  done <<EOF
$fields
EOF
  # 表裡有、而母體沒有的（欄位被刪或打錯字）
  while IFS=$'\t' read -r f st pg who; do
    [ -n "$f" ] || continue
    printf '%s\n' "$fields" | grep -qxF "$f" || out="$out 母體沒有這一欄:$f"
    case "$st" in
      exposed)
        [ -n "${who//[[:space:]]/}" ] || out="$out exposed 沒寫 who:$f" ;;
      exempt)
        [ -n "${who//[[:space:]]/}" ] || out="$out exempt 沒寫理由:$f"
        # ★★★腐爛反向查：豁免欄位【不得】出現在任何玩家可見查詢面
        for sf in $surfaces; do
          [ -f "$sf" ] || continue
          if grep -qF "\"$f\"" "$sf"; then
            out="$out 豁免已腐爛(被$sf讀走):$f"
          fi
        done ;;
      todo)
        case "$who" in
          TODO:*) tp="${who#TODO:}"
                  [ -f "$tp" ] || out="$out todo 指的票不存在:$f($tp)" ;;
          *) out="$out todo 沒有票路徑:$f" ;;
        esac ;;
      *) out="$out status 不在三選一裡:$f($st)" ;;
    esac
    [ -n "${pg//[[:space:]]/}" ] || out="$out 沒有 pages:$f"
  done <<EOF
$rows
EOF
  if [ -n "${out//[[:space:]]/}" ]; then echo "$out"; else echo "OK"; fi
}

# ── 陽性對照（★每輪先跑；★★成對：會紅 ＋ 不會亂紅）──────────────
selftest() {
  bad=0; d="$(mktemp -d)"
  cp "$CTX" "$d/ctx.gd"; cp "$TSV" "$d/t.tsv"
  r="$(check_pair "$d/ctx.gd" "$d/t.tsv" "$SURFACES")"
  [ "$r" = "OK" ] || { echo "[CTX-COV] ★對照失準：乾淨的一對被判紅（$r）"; bad=1; }
  # ①母體多一欄而表裡沒有 ⇒ 具名紅
  # ★對照樣本用【真實欄位的字元集】（ASCII）：第一版我用中文名，而抽取器只認 ASCII
  #   ⇒ 對照本身沒被偵測器看見 ⇒ ★對照失準的原因是【我的樣本不像真的】，不是閘壞了
  printf 'var fake_field_zz: int = 0
' >> "$d/ctx.gd"
  r="$(check_pair "$d/ctx.gd" "$d/t.tsv" "$SURFACES")"
  case "$r" in *"表裡沒有:fake_field_zz"*) ;; *) echo "[CTX-COV] ★對照失準：新欄位沒被具名（$r）"; bad=1;; esac
  # ②同一欄出現兩次 ⇒ 紅
  cp "$CTX" "$d/ctx.gd"
  { cat "$TSV"; printf 'food_days\ttodo\t生存\tTODO:%s\n' "docs/superpowers/specs/2026-09-10-observer-inspect-depth-HOW.md"; } > "$d/t2.tsv"
  r="$(check_pair "$d/ctx.gd" "$d/t2.tsv" "$SURFACES")"
  case "$r" in *"表裡出現 2 次:food_days"*) ;; *) echo "[CTX-COV] ★對照失準：重複欄位沒紅（$r）"; bad=1;; esac
  # ③★★★腐爛對照：把一個【真的被查詢面讀到】的欄位標成 exempt ⇒ 必須紅
  awk -F'\t' -v OFS='\t' '$1=="food_days"{ $2="exempt"; $4="（對照）宣稱零語意" } { print }' "$TSV" > "$d/t3.tsv"
  r="$(check_pair "$d/ctx.gd" "$d/t3.tsv" "$SURFACES")"
  case "$r" in *"豁免已腐爛"*) ;; *) echo "[CTX-COV] ★對照失準：腐爛的豁免沒被抓到（$r）"; bad=1;; esac
  rm -rf "$d"
  [ "$bad" = "0" ]
}

if ! selftest; then
  echo "[CTX-COV] ★ABORT：陽性對照沒過 ⇒ 本輪作廢（不得讀成任何結果）"; exit 3
fi
echo "[CTX-COV] 陽性對照通過（乾淨⇒綠｜新欄位⇒具名紅｜重複⇒紅｜★腐爛的豁免⇒紅）"

N_FIELD="$(_ctx_fields "$CTX" | grep -c .)"
N_EXP="$(_rows "$TSV" | awk -F'\t' '$2=="exposed"{c++} END{print c+0}')"
N_EXM="$(_rows "$TSV" | awk -F'\t' '$2=="exempt"{c++} END{print c+0}')"
N_TODO="$(_rows "$TSV" | awk -F'\t' '$2=="todo"{c++} END{print c+0}')"
N_NOPAGE="$(_rows "$TSV" | awk -F'\t' '$3=="未分頁"{c++} END{print c+0}')"
echo "[CTX-COV] ctx 欄位 $N_FIELD｜已接出 $N_EXP｜具名豁免 $N_EXM｜待接 $N_TODO｜★未分頁 $N_NOPAGE"
# 補充母體表（單位不同、分開列，同樣受約束）
SUP_BAD="$(awk -F'\t' 'NF>=3 && $1 !~ /^#/ && $1 != "item" && $3 == "" { print $1 }' "$SUP")"
N_SUP="$(awk -F'\t' 'NF>=3 && $1 !~ /^#/ && $1 != "item"{c++} END{print c+0}' "$SUP")"
N_SUP_TODO="$(awk -F'\t' '$3 ~ /^todo:/{c++} END{print c+0}' "$SUP")"
echo "[CTX-COV] 補充母體 $N_SUP 項｜其中待接 $N_SUP_TODO（★兩張表都綠才算完成）"

R="$(check_pair "$CTX" "$TSV" "$SURFACES")"
if [ "$R" != "OK" ] || [ -n "${SUP_BAD//[[:space:]]/}" ]; then
  echo "[CTX-COV] ★FAIL：$R $SUP_BAD"
  echo "  ⇒ 每一欄要【剛好】在表裡一次；exposed 要寫 who；exempt 要寫理由【且不得已被查詢面讀走】；todo 要指存在的票"
  exit 1
fi
echo "[CTX-COV] PASS"
