#!/usr/bin/env bash
# 估算器血統掃描（用戶立法 2026-08-21「估算器禁手抄物理」）
#
# 血統 ①讀真實狀態/同源推導 / ②手抄物理死常數(禁) / ③純設計尺度(合法)
# 規則1 抓「寫死字面值的物理量樣常數」⇒ 須在 docs/estimator-ledger.md 標血統。
#        RHS 是符號引用(Foo.BAR)＝同源推導＝血統① ⇒ 自動過（法條直接編碼進閘）。
# 規則2 抓「工期物理」的域外手抄換算 ⇒ 須走 OutpostSystem 單一真相源。
# 掃不到的（公式型手抄）走 P7 📜 declared — 見 ledger §E。
#
# exit 0 = 綠 / 1 = 有違反 / 2 = 環境壞
set -u
cd "$(dirname "$0")/../.." || exit 2
LEDGER="docs/estimator-ledger.md"
[ -f "$LEDGER" ] || { echo "FAIL 找不到 $LEDGER"; exit 2; }

DOMAIN="scripts/simulation/decision scripts/simulation/marginal_economy.gd scripts/simulation/trade_valuation.gd"
fail=0

echo "── 規則1：寫死字面值的物理量樣常數須標血統"
cands=$(grep -rhoE "^const [A-Z][A-Z0-9_]*(_PER_DAY|_PER_HEX|_PER_TICK|_DAYS|_DAYS_EST|_TICKS|_SPEED|_RATE|_YIELD)\b" $DOMAIN 2>/dev/null \
        | awk '{print $2}' | sort -u)
n_cand=$(printf '%s\n' "$cands" | grep -c .)
if [ "$n_cand" -lt 5 ]; then
  echo "  FAIL 母體塌陷：候選只有 $n_cand 顆（expect_min=5）── regex/路徑壞了，不是真的乾淨"
  fail=1
fi
missing=0; derived=0
for c in $cands; do
  if grep -rhE "^const $c[^=]*= *[A-Za-z_][A-Za-z0-9_]*\." $DOMAIN >/dev/null 2>&1; then
    derived=$((derived+1)); continue
  fi
  if ! grep -qF "$c" "$LEDGER"; then
    echo "  ✗ $c 未在總帳標血統"
    grep -rn "^const $c" $DOMAIN | head -1 | sed 's|^|      |'
    missing=$((missing+1))
  fi
done
echo "  候選 $n_cand 顆：同源推導(血統①免標) $derived 顆、未標註 $missing 顆"
[ "$missing" -gt 0 ] && fail=1

echo "── 規則2：工期換算單一真相源"
viol=$(grep -rnE "(construction_ticks_left|BUILD_TICKS\[)[^;]*/" scripts/simulation --include=*.gd \
       | grep -vF "scripts/simulation/outpost_system.gd" \
       | grep -E "/[^;]*(population|pop|TICKS_PER_DAY|TICKS_PER_HOUR)" || true)
if [ -n "$viol" ]; then
  printf '%s\n' "$viol" | sed 's|^scripts/simulation/|  ✗ |'
  echo "  ⇒ 工期換算須呼叫 OutpostSystem.build_eta_days()（分母由施工 cadence 同源推導）"
  fail=1
else
  echo "  OK 無域外手抄換算"
fi

if [ "$fail" -eq 0 ]; then echo "★PASS 估算器血統掃描"; else echo "★FAIL 估算器血統掃描（見上）"; fi
exit $fail
