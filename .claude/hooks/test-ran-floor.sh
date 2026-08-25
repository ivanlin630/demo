#!/usr/bin/env bash
# ★兩個【正交】的問題，分開問、分開判 —— 混在一起就兩個都答不了。
#   Q1 跑完了嗎？   → 結尾標記（只有跑到最後才印得出來）
#   Q2 有沒有新失敗？→ 與 baseline 比對（★不是「非零即紅」）
# 血證 2026-08-25：
#   ①headless 因 parse error 沒跑，輸出 FAIL=0 —— 跟全綠長得一模一樣。
#     ★「FAIL=0」只說【沒有失敗的】，沒說【有跑過】。
#   ②我的前一版把 Q1/Q2 混在一起 ⇒ baseline 有 8 個已知失敗 ⇒ 閘【永遠紅】。
#     ★★永遠紅的閘 ＝ 沒有閘（恆假式，跟恆真式一樣沒有資訊量）。
#   ③我第一版只 grep 'Assertion failed'，實測失敗有【三類共 16 行】，閘只看到 5。
#     ★★★病根同型：我列舉了【錯誤】的形式，而錯誤形式會發散。
#     ⇒ 改為列舉【正常輸出前綴】（收斂、由我們自己控制），其餘一律進 baseline 比對。
# 用法：bash .claude/hooks/test-ran-floor.sh <實跑輸出檔> [baseline檔]
set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)" || exit 2
out="${1:-}"; base="${2:-docs/test-baseline-failures.txt}"; marker='[TEST-SUITE-COMPLETE]'
[ -z "$out" ] || [ ! -f "$out" ] && { echo "[test-floor] ★FAIL 沒給實跑輸出檔"; exit 2; }
rc=0

# ---- Q1：跑完了嗎（★這題的答案不受 Q2 影響）----
if grep -qF "$marker" "$out" 2>/dev/null; then
  echo "[test-floor] Q1 跑完了嗎 → ★YES（見結尾標記）"
else
  echo "[test-floor] Q1 跑完了嗎 → ★NO（無結尾標記）⇒ 這份輸出【沒有資格談綠不綠】"
  echo "[test-floor]    ★注意：這不是「測試失敗」，是「不知道跑了多少」。"
  rc=1
fi

# ---- Q2：有沒有【新】失敗（★與 baseline 比，不是與 0 比）----
# ★不列舉【錯誤】的形式（發散：Godot 能吐任何錯，實測三類 16 行，只掃 assert 只看到 5）
# ★改列舉【正常】的形式（收斂：都是我們自己寫的 print 前綴）—— 其餘一律視為可疑。
cur="$(mktemp)"
grep -vE '^[[:space:]]*($|\[TEST\]|\[OK\]|\[bed\]|\[PopMgmt\]|\[CONSTITUTION|\[dormant|\[test-floor|---|===|Godot Engine|--- Debug|Using |[0-9]+ PASS)' "$out" 2>/dev/null   | sed 's/[[:space:]]*$//' | grep -v '^$' | sort -u > "$cur"
n_cur="$(wc -l < "$cur" | tr -d ' ')"
if [ ! -f "$base" ]; then
  echo "[test-floor] Q2 → ★無 baseline（$base）⇒ 無法分辨【已知】與【新增】"
  echo "[test-floor]    ★現況失敗 $n_cur 條。請用實跑輸出生成 baseline，★不要憑印象手寫。"
  rm -f "$cur"; exit 2
fi
n_base="$(grep -cv '^[[:space:]]*#' "$base" 2>/dev/null || echo 0)"
newf="$(comm -23 "$cur" <(grep -v '^[[:space:]]*#' "$base" | sed 's/[[:space:]]*$//' | sort -u))"
gone="$(comm -13 "$cur" <(grep -v '^[[:space:]]*#' "$base" | sed 's/[[:space:]]*$//' | sort -u))"
echo "[test-floor] Q2 新失敗？ → baseline=$n_base 實測=$n_cur"
[ -n "$newf" ] && { echo "[test-floor] ★FAIL 新增失敗："; printf '%s\n' "$newf" | sed 's/^/      + /'; rc=1; }
# ★baseline falsifier：登記了卻沒出現 ⇒ 條目 stale（修好了或測試改名），表會悄悄腐爛
[ -n "$gone" ] && { echo "[test-floor] ★baseline stale（登記了但沒出現，請刪或查）："; printf '%s\n' "$gone" | sed 's/^/      - /'; }
rm -f "$cur"
[ "$rc" = 0 ] && echo "[test-floor] ★PASS 跑完 ＋ 無新增失敗"
exit $rc
