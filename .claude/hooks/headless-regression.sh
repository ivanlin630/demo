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
  # ★★★2026-09-03 放寬：失敗有【兩條不重疊的管道】——
  #   ①`[FAIL]` 行 ②`SCRIPT ERROR: Assertion failed: …`
  #   ★而本閘原本【只認 ①】⇒ main 上 7 條 assert 失敗【整條管道】看不見（implementer 實測 7 vs 2）
  #   ★★資料本來就在 $OUT 裡（`2>&1`）—— ★★★缺的不是抓取，是【grep 太窄】
  #   ⇒ 這就是「缺陷躲在我們不走的管道」：檢查管道與失效管道【不同軸】
  # （原誠實限已作廢：本閘不再只認 [FAIL]）
  # ★★舊註記（保留供追溯）：本閘只認【`[FAIL]` 這一種失敗形式】——
  #   ★而 implementer 報過「五條生育 assert」不在任何登記裡；★★我這一跑的輸出【看不到它們】
  #   ⇒ ★★★所以「清單相同」只保證【這一種形式】沒變；別種形式的失敗本閘看不見。
  printf '%s' "$OUT" | grep -a "\[FAIL\]" | head -8 | sed 's/^/   /'
  exit 1
fi
[ "$N" -lt "$BASE" ] && echo "[HEADLESS] ⚠比 baseline 少 $((BASE-N)) 條 —— ★好事，但請【更新 baseline 並寫理由】，否則下次它會遮住新的紅"
# ★★★清單比對（2026-09-03 補：★關掉「只比數量」那條誠實限 —— 一紅一綠會抵消）
LIST_F=docs/process/.headless-baseline-list.txt
if [ -f "$LIST_F" ]; then
  # ★★★2026-09-03：訊息裡的【數字】會逐跑變動（血證 `vault_ore=35` vs `36`）⇒ 原文比對會造【假紅】
  #   ⇒ 正規化：★保留【出現次數】(它變了是真訊號)，★★而訊息本體裡的數字一律換成 N
  #   ⇒ ★★★誠實限：因此「3 隊失敗」與「5 隊失敗」在本閘眼中【一樣】——數量變化藏在訊息裡的那種看不見
  printf '%s' "$OUT" | grep -aE "\[FAIL\]|Assertion failed" | sed 's/^ERROR: *//; s/^ *//'     | LC_ALL=C sort | LC_ALL=C uniq -c     | awk '{c=$1; $1=""; gsub(/[0-9]+/,"N"); sub(/^ /,""); print c" "$0}' > /tmp/hl_now.txt
  grep -v '^#' "$LIST_F" | grep -v '^$' > /tmp/hl_base.txt   # ★濾掉註解/空行:baseline 檔要能寫【來歷】
  if ! diff -q /tmp/hl_base.txt /tmp/hl_now.txt >/dev/null 2>&1; then
    echo "[HEADLESS] ★FAIL：失敗【清單】與 baseline 不同（★數量可能一樣 —— 一紅一綠會抵消）"
    diff /tmp/hl_base.txt /tmp/hl_now.txt | head -10 | sed 's/^/   /'
    exit 1
  fi
  echo "[HEADLESS] ✓ 失敗清單與 baseline 逐條相同（★不只數量）"
else
  echo "[HEADLESS] ★★誠實限：清單 baseline 不存在 ⇒ 本輪【只比數量】，一紅一綠會抵消"
fi
echo "[HEADLESS] PASS"
