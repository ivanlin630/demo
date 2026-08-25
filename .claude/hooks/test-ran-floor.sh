#!/usr/bin/env bash
# ★測試框架自身的陽性對照 —— 回答「有沒有跑完」，不是「有沒有失敗」。
# 血證 2026-08-25：headless 因 parse error 沒跑，輸出 FAIL=0 —— 跟全綠長得一模一樣。
#   ★「FAIL=0」只說【沒有失敗的】，沒說【有跑過】。
# ★為什麼不數 PASS 行：headless_test 有 2043 個 assert，但只有 40 條 [TEST] print
#   ⇒ 數印出來的行＝數冰山露出水面的部分，會隨測試增減而 drift。
#   ⇒ 唯一穩健的是【結尾標記】：跑到最後一行才印得出來。
# 用法：bash .claude/hooks/test-ran-floor.sh <實跑輸出檔> [結尾標記]
set -u
out="${1:-}"; marker="${2:-[TEST-SUITE-COMPLETE]}"
[ -z "$out" ] || [ ! -f "$out" ] && { echo "[test-floor] ★FAIL 沒給實跑輸出檔"; exit 2; }
errs="$(grep -c 'SCRIPT ERROR\|Parse Error\|Assertion failed' "$out" 2>/dev/null || echo 0)"
done_n="$(grep -cF "$marker" "$out" 2>/dev/null || echo 0)"
echo "[test-floor] 錯誤行=$errs  結尾標記=$done_n"
[ "$errs" -gt 0 ] && { echo "[test-floor] ★FAIL 有 $errs 行錯誤/assert"; grep -m5 'SCRIPT ERROR\|Assertion failed' "$out"; exit 1; }
[ "$done_n" -eq 0 ] && {
  echo "[test-floor] ★FAIL 沒有結尾標記 '$marker' ⇒ 【無法證明跑完】"
  echo "[test-floor]   ★這【不是】「測試失敗」，是「這份輸出沒有資格說它綠」。"
  echo "[test-floor]   ★若標記尚未實作 ⇒ 該補 code，不是放寬這個閘。"; exit 1; }
echo "[test-floor] ★PASS 跑完且零錯誤"
