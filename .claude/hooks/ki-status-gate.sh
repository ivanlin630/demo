#!/usr/bin/env bash
# ★known_issues 狀態欄閘（systems 立 2026-09-02；blueprint 批「硬規則可加閘」）
#   規則：新條目必帶 `狀態：已知未修` 或 `狀態：未確認`，★且【未確認】的回訪只能是「量測窗」。
#
# ★★★為什麼要 baseline：存量 138 條的回填排在「清單清零」階段。
#      若閘對存量也紅 ⇒ 它會被關掉 ⇒ 等於沒有閘。
# ★★而若閘【只檢查有狀態欄的條目】⇒ 不寫狀態欄就過關 ⇒ 母體縮小＝閘變綠（本專案犯過）。
#      ⇒ 解法：baseline 快照存量標題；不在 baseline 裡的標題＝新條目＝硬要求。
#
# ★★★本檔請用 quoted heredoc 或編輯器改，【不要用 python 字串取代】——
#      今天兩次血證：python 把 `\1` 寫成 0x01、把 `\r` 寫成真 CR 字元，
#      而兩次的症狀都是【閘安靜地失去鑑別力】，不是報錯。
set -u
# ★LC_ALL=C：emoji 開頭的標題（4-byte UTF-8）在預設 locale 下 grep -Fx 比對不到 ⇒ 21 條舊條目被當成新條目
export LC_ALL=C
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)" || exit 2
KI=docs/known_issues.md
BASE=docs/process/.ki-status-baseline.txt
[ -f "$BASE" ] || { echo "[KI-STATUS] ★FAIL：baseline 不存在（$BASE）—— 沒有 baseline 就分不出新舊，本閘無效"; exit 1; }

fail=0; new=0; old=0; title=""; sect=""

check_sect() {
  [ -z "$title" ] && return 0
  if grep -Fxq "$title" "$BASE"; then old=$((old+1)); return 0; fi
  new=$((new+1))
  st=$(printf '%s' "$sect" | grep -oE '狀態：(已知未修|未確認)' | head -1)
  if [ -z "$st" ]; then
    echo "[KI-STATUS] ★FAIL：新條目缺【狀態】欄 ⇒ ${title:0:60}"
    echo "   ⇒ ★把【未確認】寫成【已知未修】是在考卷上說謊的溫和版；沒寫則是連問都沒問"
    fail=$((fail+1)); return 0
  fi
  if [ "$st" = "狀態：未確認" ] && ! printf '%s' "$sect" | grep -q '回訪：量測窗'; then
    echo "[KI-STATUS] ★FAIL：【未確認】條目的回訪不是「量測窗」⇒ ${title:0:60}"
    echo "   ⇒ ★能把「未確認」變成別的東西的只有量測；寫別的＝擱到沒人會去量它的地方"
    fail=$((fail+1)); return 0
  fi
  if ! printf '%s' "$sect" | grep -q '回訪：'; then
    echo "[KI-STATUS] ★FAIL：新條目缺【回訪條件】⇒ ${title:0:60}"; fail=$((fail+1))
  fi
}

# ★CRLF 在【輸入端】一次去掉（別在迴圈裡用跳脫序列處理，見檔頭血證）
while IFS= read -r line; do
  case "$line" in
    '### '*) check_sect; title="$line"; sect="" ;;
    *) sect="$sect
$line" ;;
  esac
done < <(tr -d '\r' < "$KI")
check_sect

echo "[KI-STATUS] 條目 $((new+old))｜baseline 內(存量,不擋) $old｜新條目(硬檢) $new｜★違規 $fail"
echo "[KI-STATUS] ★誠實限①：baseline 是【標題快照】—— 改標題的舊條目會被當成新條目（會紅，是保守方向）"
echo "[KI-STATUS] ★誠實限②：存量 $old 條【沒有被檢查】—— 回填排在「清單清零」階段，★本閘不代表它們合格"
[ "$fail" -gt 0 ] && { echo "[KI-STATUS] FAIL"; exit 1; }
echo "[KI-STATUS] PASS"
