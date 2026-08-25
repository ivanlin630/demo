#!/usr/bin/env bash
# 可達閉包的【呼叫端】窮盡器：給一組函式名，列出所有【沒有把某個引數傳進去】的呼叫。
#
# ★為什麼要有這支（2026-08-26 血證，`state` 改必填那票）：
#   ★★**定義側有機械判準**（`grep 'state: WorldState = null'`），**呼叫端沒有** ——
#   於是三個人（systems／reviewer／implementer）各自【逐個發現】呼叫端：
#     第一輪 2 個 → 第二輪 +1（headless_test，在 baseline-7 主測試檔）→ 第三輪 +1 檔 +1 行。
#   ★★★**每一輪都說「這次應該齊了」，每一輪都不齊** —— 因為【用人眼列】就是在賭有沒有想到。
#   ⇒ 這支把呼叫端也變成機械查。
#
# ★它會有假陽性，那是【設計】不是缺陷：
#   ①字串／註解裡出現函式名 ②引數變數不叫 `state`（例：`w[0]`）③跨行呼叫。
#   ★★失效方向是【太吵】不是【太鬆】—— 吵會被查，鬆會過關。**逐條看一眼即可，不要為了安靜而收窄。**
#
# 用法：bash .claude/hooks/closure-callsite-scan.sh <引數名> <函式名...>
#   例：bash .claude/hooks/closure-callsite-scan.sh state reserve ask_price local_value
set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)" || exit 2
arg="${1:-state}"; shift || true
[ "$#" -eq 0 ] && { echo "[closure] 用法：$0 <引數名> <函式名...>"; exit 2; }
echo "[closure] 找【沒有把 \`$arg\` 傳進去】的呼叫（★假陽性是刻意的，逐條看一眼）"
n=0
for f in "$@"; do
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    echo "  $line"; n=$((n+1))
  done < <(grep -rn "\b$f(" scripts/ --include=*.gd 2>/dev/null \
            | grep -v "func $f" \
            | grep -vE ':[0-9]+:[[:space:]]*#' \
            | grep -v ", *$arg)" | grep -v ", *$arg\b")
done
echo "[closure] 共 $n 條待人工判（★『0 條』才是綠；有條目不等於有 bug，但每一條都要有人說過為什麼沒事）"
