#!/usr/bin/env bash
# ★★★2026-09-07（implementer 揭）：本檔原本用【固定 /tmp 檔名】。
#   ⇒ ★兩個角色同時跑閘時,後跑的會【蓋掉】先跑的中間檔
#   ⇒ ★★而結果是【無法解釋的紅或綠】—— 它不會報錯,它只是拿到別人的資料
#   ⇒ ★★★而共用 main dir + 六個角色 ⇒ 併跑是常態,不是例外
#   修法:每次呼叫用 mktemp,trap 清理。
_TMP_SW_WL="$(mktemp)"
_TMP_SW_FIELDS="$(mktemp)"
trap 'rm -f "$_TMP_SW_WL" "$_TMP_SW_FIELDS"' EXIT
# ★單寫者閘（systems 立 2026-09-02；接走 implementer A#27 驗收④）
#   ★病：「這個欄位只有一個地方會寫」是我們反覆做出的假設，而它反覆是假的。
#        血證 2026-09-02：`clear_team_faction` 被當成離團窄口，而 `world_state.gd` 勢力解散那個迴圈
#        【直寫 faction_id = -1】繞過整條 set/clear 路 ⇒ 掛在 wrapper 上會【靜默漏掉一整類】。
#   ★★判準：受管欄位的直寫點【必須全部在白名單裡】；多出一個就紅。
#   ★★★誠實限印在輸出上（見結尾）。
#   ★本檔請用 quoted heredoc 改，不要用 python 字串取代（今天兩次血證：\1 → 0x01、\r → 真 CR）。
set -u
export LC_ALL=C
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)" || exit 2
WL=docs/process/.single-writer-whitelist.tsv
[ -f "$WL" ] || { echo "[SINGLE-WRITER] ★FAIL：白名單不存在（$WL）"; exit 1; }

tr -d "" < "$WL" > "$_TMP_SW_WL"   # ★白名單正規化（漏了這行 ⇒ awk 讀不到檔 ⇒ 全部誤報成「不在白名單」）
fail=0; fields=0
while IFS=$'\t' read -r field _ _; do
  case "$field" in ''|'#'*) continue;; esac
  echo "$field"
done < <(tr -d '\r' < "$WL") | sort -u > "$_TMP_SW_FIELDS"

while IFS= read -r field; do
  [ -z "$field" ] && continue
  fields=$((fields+1))
  # 直寫 = `.<field> =` 但不是 `==`
  hits=$(grep -rnE "\.${field}[[:space:]]*=[^=]" scripts/simulation scripts/data 2>/dev/null | tr -d '\r')
  n=0; bad=0
  while IFS= read -r h; do
    [ -z "$h" ] && continue
    n=$((n+1))
    f=${h%%:*}; rest=${h#*:}; ln=${rest%%:*}; src=${rest#*:}
    src_trim=$(printf '%s' "$src" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
    # ★整行註解不是寫者：結構性排除，而不是把註解養進白名單（白名單會越養越大而沒人敢刪）
    case "$src_trim" in "#"*) n=$((n-1)); continue;; esac
    if ! awk -F'\t' -v fd="$field" -v ff="$f" -v ss="$src_trim" \
         '$1==fd && $2==ff && $3==ss {found=1} END{exit !found}' "$_TMP_SW_WL" 2>/dev/null; then
      echo "[SINGLE-WRITER] ★FAIL：$field 有【不在白名單】的直寫 ⇒ $f:$ln"
      echo "   ⇒ $src_trim"
      echo "   ⇒ ★若這是合法的第二個寫者：把它導回單一 setter（首選），或加進白名單並寫理由"
      bad=$((bad+1)); fail=$((fail+1))
    fi
  done <<EOF
$hits
EOF
  echo "[SINGLE-WRITER] $field：直寫 $n 處｜白名單外 $bad"
done < "$_TMP_SW_FIELDS"

echo "[SINGLE-WRITER] 受管欄位 $fields｜★白名單外總計 $fail"
echo '[SINGLE-WRITER] ★誠實限①：只掃 scripts/simulation 與 scripts/data。scripts/debug 的直寫【刻意不入母體】——床手工組世界合法，但這代表「床繞過 setter」本閘不管'
echo "[SINGLE-WRITER] ★誠實限②：只抓【字面直寫】—— 透過 set(\"field\", v) 之類的反射寫入本閘看不見"
echo '[SINGLE-WRITER] ★誠實限④：整行註解(開頭 #)不計 —— 註解裡的 .field = 不是寫者，但【被註解掉的真寫者】也就此隱形'
echo "[SINGLE-WRITER] ★誠實限③：白名單比對【整行原始碼】—— 改了縮排以外的字就會紅（保守方向）"
[ "$fail" -gt 0 ] && { echo "[SINGLE-WRITER] FAIL"; exit 1; }
echo "[SINGLE-WRITER] PASS"
