#!/usr/bin/env bash
# ★★★merge-gate runner —— 讀 docs/process/merge-gates.tsv，逐支跑，彙總。
#   ★用戶裁「搬」2026-09-01：CLAUDE.md 只留一行總指標，清單在註冊表。
#   ★★而【搬完要可執行】是 systems 的 HOW 裁：一張要人照著跑的清單會長大然後沒人跑完整份。
#   ★★★誠實限：runner 讓「跑」變便宜，但【跑得久】仍會讓人跳過 ⇒ 本 runner 報每支耗時與總時。
set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)" || exit 2
REG="docs/process/merge-gates.tsv"
[ -f "$REG" ] || { echo "[MERGE-GATES] FAIL：註冊表不存在 $REG"; exit 1; }
FAILED=(); TOTAL0=$SECONDS; N=0
while IFS=$'	' read -r id cmd purpose crit; do
  case "$id" in ''|'#'*) continue;; esac
  N=$((N+1)); T0=$SECONDS
  OUT=$(eval "$cmd" 2>&1); RC=$?
  DT=$((SECONDS-T0))
  if [ $RC -ne 0 ] || printf '%s' "$OUT" | grep -qE "FAIL|Parse Error|Failed to load"; then
    echo "[MERGE-GATES] ✗ $id （${DT}s）—— $purpose"
    printf '%s
' "$OUT" | tail -5
    FAILED+=("$id")
  else
    echo "[MERGE-GATES] ✓ $id （${DT}s）"
  fi
done < "$REG"
echo "───────────────────────────────"
echo "[MERGE-GATES] 註冊表 $N 支｜總時 $((SECONDS-TOTAL0))s"
if [ ${#FAILED[@]} -gt 0 ]; then
  echo "[MERGE-GATES] FAIL：${FAILED[*]}"
  echo "★註冊表在 $REG —— ★★新增閘＝往那裡加一行，不是往 CLAUDE.md 加"
  exit 1
fi
echo "[MERGE-GATES] PASS：全部通過"
