#!/usr/bin/env bash
# ★print-join 閘（systems 2026-09-04，血證：Godot 單次 print() 截在 16383 字元 = 2^14−1）
#   ★被截的輸出【看起來完全正常】：開頭在、結尾在、格式對，只是中間少了一塊，
#     而下一個 print 會黏在被切斷的那一行後面。
#   ⇒ 規則：不得把多行 join 成一包再 print；要逐行印。
#   ★★白名單需具名（docs/process/.print-join-whitelist.tsv：路徑<TAB>理由）。
set -uo pipefail
WL=docs/process/.print-join-whitelist.tsv
[ -f "$WL" ] || : > "$WL"
# ★★收窄:只抓【換行 join】—— 那才是「多行併成一包」的危險形狀。
#   ★單行內 join 幾個欄位(如 "｜".join(parts) 印一行摘要)【不危險】,抓它只會製造雜訊,
#   ★★而雜訊會讓人開始忽略警告(2026-09-04 第一版 19 筆全是這種,已收窄)。
HITS=$(grep -rn --include=*.gd -E 'print(_rich)?\(.*(\n|\\n)"\.join\(' scripts/ 2>/dev/null || true)
TOTAL=$(printf '%s' "$HITS" | grep -c . || true)
echo "[PRINT-JOIN] 掃到 print(...join(...)) 形狀＝${TOTAL}"
FAIL=0
if [ "$TOTAL" -gt 0 ]; then
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    f="${line%%:*}"
    if cut -f1 "$WL" 2>/dev/null | grep -Fxq "$f"; then
      echo "   ○ 白名單：$f"
    else
      echo "   ★$line"
      FAIL=$((FAIL+1))
    fi
  done <<< "$HITS"
fi
echo "[PRINT-JOIN] 白名單外＝${FAIL}"
if [ "$FAIL" -gt 0 ]; then
  echo "[PRINT-JOIN] ★★★FAIL：多行 join 成一包 print ⇒ 超過 16383 字元會【靜默截斷】,而輸出看起來完全正常"
  echo "[PRINT-JOIN] ⇒ 解法：逐行印；★真的必要就加白名單並寫理由（$WL）"
  echo "[PRINT-JOIN] FAIL"; exit 1
fi
echo "[PRINT-JOIN] ✓ 沒有白名單外的 join-then-print"
echo "[PRINT-JOIN] ★誠實限：本閘只認【字面上的 print(...join(...))】—— 先組成變數再 print 的形狀它看不到"
echo "[PRINT-JOIN] PASS"
