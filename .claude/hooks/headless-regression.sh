#!/usr/bin/env bash
# ★headless_test 回歸閘（systems 立 2026-09-03）
#   ★★★為什麼今天才有：2026-09-03 implementer 發現【兩顆已 merge 的 slice 各弄紅了 fixture，
#      而 merge-gates 十支全綠】—— 因為 headless_test【不在註冊表裡】（bed-parse 只解析不執行）。
#   ★而 CLAUDE.md 叫人「merge 前跑【全部】merge-gate，清單見註冊表」
#      ⇒ ★★註冊表被當成【完整的】，而它不是 —— 這是【檢查管道與失效管道不同軸】的又一次。
#   ★★★判準：HARD-FAILS 數【不得超過】baseline（baseline 存 docs/process/.headless-baseline.txt，含理由）
set -u
export LC_ALL=C
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)" || exit 2
BASE_F=docs/process/.headless-baseline.txt
[ -f "$BASE_F" ] || { echo "[HEADLESS] ★FAIL：baseline 不存在（$BASE_F）—— 沒有 baseline 就分不出「本來就紅」與「新弄紅」"; exit 1; }
BASE=$(grep -oE '^[0-9]+' "$BASE_F" | head -1)
OUT=$(powershell -NoProfile -File ./tools/godot.ps1 --headless --script scripts/debug/headless_test.gd 2>&1)
N=$(printf '%s' "$OUT" | grep -aoE 'TEST-SUITE-HARD-FAILS\] [0-9]+' | grep -oE '[0-9]+' | tail -1)
if [ -z "$N" ]; then
  echo "[HEADLESS] ★FAIL：抓不到 HARD-FAILS 那一行 —— ★★這是【儀器沒跑到】不是【沒有失敗】"
  printf '%s\n' "$OUT" | tail -3
  exit 1
fi
echo "[HEADLESS] HARD-FAILS ＝ $N ｜ baseline ＝ $BASE"
if [ "$N" -gt "$BASE" ]; then
  echo "[HEADLESS] ★FAIL：比 baseline 多 $((N-BASE)) 條 ⇒ 有東西被這次改動弄紅了"
  printf '%s' "$OUT" | grep -a "\[FAIL\]" | head -8 | sed 's/^/   /'
  exit 1
fi
[ "$N" -lt "$BASE" ] && echo "[HEADLESS] ⚠比 baseline 少 $((BASE-N)) 條 —— ★好事，但請【更新 baseline 並寫理由】，否則下次它會遮住新的紅"
# ★★★清單比對（2026-09-03 補：★關掉「只比數量」那條誠實限 —— 一紅一綠會抵消）
LIST_F=docs/process/.headless-baseline-list.txt
if [ -f "$LIST_F" ]; then
  printf '%s' "$OUT" | grep -a "\[FAIL\]" | sed 's/^ERROR: *//; s/^ *//' | LC_ALL=C sort | LC_ALL=C uniq -c | sed 's/^ *//' > /tmp/hl_now.txt
  if ! diff -q "$LIST_F" /tmp/hl_now.txt >/dev/null 2>&1; then
    echo "[HEADLESS] ★FAIL：失敗【清單】與 baseline 不同（★數量可能一樣 —— 一紅一綠會抵消）"
    diff "$LIST_F" /tmp/hl_now.txt | head -10 | sed 's/^/   /'
    exit 1
  fi
  echo "[HEADLESS] ✓ 失敗清單與 baseline 逐條相同（★不只數量）"
else
  echo "[HEADLESS] ★★誠實限：清單 baseline 不存在 ⇒ 本輪【只比數量】，一紅一綠會抵消"
fi
echo "[HEADLESS] PASS"
