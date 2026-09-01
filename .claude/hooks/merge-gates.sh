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
  if [ $RC -ne 0 ] || printf '%s' "$OUT" | grep -qE "FAIL|Parse Error|Failed to load"; then
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
echo "[MERGE-GATES] PASS：全部通過（★每一支都印出了它該印的結論）"
