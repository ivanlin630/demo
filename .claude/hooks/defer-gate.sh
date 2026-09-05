#!/usr/bin/env bash
# defer-gate —— ★延後裁定：條件達成卻還躺著 ⇒ 紅（systems 立 2026-09-05）
#
# ★病：裁定「排最後／排 X 之後」寫在散文裡 ⇒ 依賴解除時【沒有人回頭】。
#   血證：2026-08-20「零 LOD 排最後」，兩個理由都消滅後仍躺了 16 天，
#   期間造成薪資相位病 ＋ B 議程整包證據作廢。
# ★★所以本閘不是「提醒清單」，是【條件達成即紅】—— 提醒清單會被讀過就忘。
set -uo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)" || exit 2
REG="docs/process/defers.tsv"
[ -f "$REG" ] || { echo "[DEFER-GATE] FAIL：註冊表不存在 $REG"; exit 1; }

FAILED=0; N=0
while IFS=$'\t' read -r token summary until_cond met_check; do
  case "${token:-}" in ''|'#'*) continue ;; esac
  [ "$token" = "token" ] && continue
  N=$((N+1))
  if [ -z "${met_check:-}" ]; then
    echo "[DEFER-GATE] ✗ $token —— ★沒有 met_check：不能有「沒有判準也算過」的路徑"
    FAILED=1; continue
  fi
  if bash -c "$met_check" >/dev/null 2>&1; then
    echo "[DEFER-GATE] ✗ $token —— ★★【解除條件已達成】而它還躺在表上"
    echo "    裁定：$summary"
    echo "    條件：$until_cond"
    echo "    ⇒ ★做它，或重新裁定並更新 defer_until —— ★★不要把 met_check 改鬆"
    FAILED=1
  else
    echo "[DEFER-GATE] ✓ $token（條件未達成：$until_cond）"
  fi
done < "$REG"

echo "[DEFER-GATE] 延後裁定 $N 筆"
if [ "$FAILED" = "1" ]; then echo "[DEFER-GATE] FAIL"; exit 1; fi
echo "[DEFER-GATE] PASS"
