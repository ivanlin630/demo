#!/usr/bin/env bash
# ★★★merge-gate runner —— 讀 docs/process/merge-gates.tsv，逐支跑，彙總。
#   ★用戶裁「搬」2026-09-01；★★而「搬完要可執行」是 systems 的 HOW 裁。
#   ★★★2026-09-01 補正（implementer 揭）：原版【沒有執行註冊表的判準欄】
#     ⇒ 一支「跑了、exit 0、什麼都不斷言」的閘會拿到 ✓ ⇒ ★那是假綠。
#     ⇒ 現在：★★exit code 通過【還不夠】，輸出必須命中 expect；★★★沒寫 expect 的行直接 FAIL。
#   ★誠實限：runner 讓「跑」變便宜，但【跑得久】仍會讓人跳過 ⇒ 報每支耗時與總時。
set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)" || exit 2
REG="docs/process/merge-gates.tsv"

# ★★★註冊表新鮮度（2026-09-03，implementer 提、systems 實作）——★病：閘自己會印 PASS，而它【不知道自己少了幾支】。
#   ★血證同型兩次（同一天）：branch 上只有 10 支卻連報四次「全部通過」；後來 12 支 vs main 14 支。
#   ★★「以後記得先 fetch」防不到 —— **忘記的時候沒有任何東西會響**（失效是靜默的）。
#   ⇒ 做法：跟 origin/main 比【閘名集合】，少了就把結論印成 `PASS（12/14）★註冊表落後 main：缺 X, Y`。
#   ★不擋（離線／刻意分叉是合法的），★★但【不准它印出一個看起來完整的 PASS】。
#   ★★★關掉：`MG_NO_FETCH=1`（離線）。
STALE_NOTE=""
if [ "${MG_NO_FETCH:-0}" != "1" ]; then
  git fetch -q origin 2>/dev/null || true
  UP=$(git show origin/main:docs/process/merge-gates.tsv 2>/dev/null | grep -v '^#' | cut -f1 | sed '/^$/d' | LC_ALL=C sort)
  LOC=$(grep -v '^#' "$REG" 2>/dev/null | cut -f1 | sed '/^$/d' | LC_ALL=C sort)
  if [ -n "$UP" ]; then
    MISSING=$(comm -23 <(printf '%s
' "$UP") <(printf '%s
' "$LOC") | tr '
' ' ' | sed 's/ *$//')
    EXTRA=$(comm -13 <(printf '%s
' "$UP") <(printf '%s
' "$LOC") | tr '
' ' ' | sed 's/ *$//')
    UPN=$(printf '%s
' "$UP" | grep -c .)
    # ★★★分開兩種:【缺】才是警報,【多】只是分叉(本地新註冊還沒 push)——
    #   ★血證 2026-09-03:第一版把兩者混成同一句 ⇒ 本地只多一支時,它印出「缺的那幾支沒有跑過」
    #   ⇒ ★★守衛自己說了一句【不是事實】的話,而那比沒有守衛更糟。
    [ -n "$MISSING" ] && STALE_NOTE="★註冊表落後 origin/main：缺 $MISSING"
    [ -n "$EXTRA" ] && FORK_NOTE="★本地多出（分叉，非缺失；多半是還沒 push 的新閘）：$EXTRA"
    UPSTREAM_N="$UPN"
  fi
fi
[ -f "$REG" ] || { echo "[MERGE-GATES] FAIL：註冊表不存在 $REG"; exit 1; }
FAILED=(); TOTAL0=$SECONDS; N=0
while IFS=$'	' read -r id cmd purpose expect; do
  case "$id" in ''|'#'*) continue;; esac
  N=$((N+1)); T0=$SECONDS
  if [ -z "${expect:-}" ]; then
    echo "[MERGE-GATES] ✗ $id —— ★沒有 expect 欄：不能有「沒有判準也算過」的路徑"
    FAILED+=("$id(no-expect)"); continue
  fi
  OUT=$(eval "$cmd" 2>&1); RC=$?
  DT=$((SECONDS-T0))
  # ★★★2026-09-02 修假紅（implementer 揭）：原本這裡還 grep 輸出裡的 "FAIL"
  #   ⇒ ★而閘【自己的說明文字】裡就有那個字（例：bare-tick 檔頭解釋什麼情況會 FAIL）
  #   ⇒ ★★於是一支 exit 0、且印了 PASS 的閘被判 ✗ —— ★★★「談論一個字」與「用它下判決」在文字上不可分
  #   ⇒ 修法：★只信【exit code】＋【expect 命中】—— 兩者都是【結構化位置】，不是正文。
  if [ $RC -ne 0 ]; then
    echo "[MERGE-GATES] ✗ $id （${DT}s）—— $purpose"; printf '%s
' "$OUT" | tail -5; FAILED+=("$id")
  elif ! printf '%s' "$OUT" | grep -qE "$expect"; then
    echo "[MERGE-GATES] ✗ $id （${DT}s）—— ★★跑完了但【沒有印出它該印的結論】"
    echo "    expect: $expect"; printf '%s
' "$OUT" | tail -3
    FAILED+=("$id(no-verdict)")
  else
    echo "[MERGE-GATES] ✓ $id （${DT}s）"
  fi
done < "$REG"
echo "───────────────────────────────"
echo "[MERGE-GATES] 註冊表 $N 支｜總時 $((SECONDS-TOTAL0))s"
if [ ${#FAILED[@]} -gt 0 ]; then
  echo "[MERGE-GATES] FAIL：${FAILED[*]}"
  echo "★註冊表在 $REG —— ★★新增閘＝往那裡加一行（★★★含 expect，否則直接 FAIL）"
  exit 1
fi
if [ -n "${STALE_NOTE:-}" ]; then
  echo "[MERGE-GATES] PASS（$N/${UPSTREAM_N:-?}）—— $STALE_NOTE"
  echo "[MERGE-GATES] ★★這【不是】「全部通過」：★★★缺的那幾支【沒有跑過】，而它們正是最新加的（多半在守你剛做的東西）"
elif [ -n "${FORK_NOTE:-}" ]; then
  echo "[MERGE-GATES] PASS：本地這 $N 支全部通過｜${FORK_NOTE}"
else
  echo "[MERGE-GATES] PASS：全部通過（★每一支都印出了它該印的結論）"
fi
