#!/usr/bin/env bash
# ★★★跨 run static 檢查 —— 「有人新加了一個沒清的 static」這一格，runtime 看不見。
#   ★血證 2026-09-03：`PathSystem._path_cache`（鍵只有座標、新鮮度靠 tick 值，而 tick 跨 run 歸零）
#     ⇒ 第二輪吃第一輪的路徑，連【不同世界】也吃；`NpcCombatSystem._cas_carry` 第二輪清掉 4 筆
#     ⇒ ★★舊世界的傷亡餘量會流進新世界的同號隊 —— 那是 production 後果，不只是量測污染。
#   ★★★而床上的 `[diag] cross-run` 行【只印它知道的那些】：沒註冊的 static 它永遠不會提到
#     ⇒ 動態抓【殘留】、靜態（本閘）抓【漏註冊】—— 兩條軸，兩個工具。
#
# ★涵蓋率（量過，不是估的）：本閘看得到 `^\s*static var` 這個宣告形式 —— 目前 34 個 / 12 檔。
# ★★誠實限（三條，必印）：
#   ①`const` 裡藏可變容器、autoload 單例的成員、`var r = REGISTRY; r[...]=…` 這種【別名改寫】——本閘看不見
#   ②它只檢查「名字有沒有出現在 `_reset_cross_run` 裡」，★不保證那一行真的清乾淨（那由床的 ★RESIDUE 行抓）
#   ③旗標（bool/int）★刻意【不要求清除】——世界 setup 清旗標會殺掉【床自己剛設的】；它們由 `[diag]` 行印出來
set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)" || exit 2
WL="docs/process/.cross-run-static-whitelist.tsv"
DIRS="scripts/simulation scripts/data"

is_wl() { grep -v '^#' "$WL" 2>/dev/null | awk -F'\t' -v f="$1" -v v="$2" '$1==f && $2==v {found=1} END{exit found?0:1}'; }

TOTAL=0; COVERED=0; WLC=0; FLAGS=0; MISS=""
for f in $(grep -rlE "^[[:space:]]*static var " $DIRS --include=*.gd | sort); do
  body=$(awk '/static func _reset_cross_run/{on=1} on{print} on && /^$/{c++; if(c>0 && NF==0) {}}' "$f")
  while IFS= read -r line; do
    v=$(printf '%s' "$line" | sed -E 's/^[[:space:]]*static var ([A-Za-z_][A-Za-z0-9_]*).*/\1/')
    [ -z "$v" ] && continue
    TOTAL=$((TOTAL+1))
    # 旗標型（bool/int/float 純量）：刻意不要求清除，見誠實限③
    if printf '%s' "$line" | grep -qE ":[[:space:]]*(bool|int|float)[[:space:]]*="; then FLAGS=$((FLAGS+1)); continue; fi
    if printf '%s' "$body" | grep -qF "$v"; then COVERED=$((COVERED+1)); continue; fi
    if is_wl "$f" "$v"; then WLC=$((WLC+1)); continue; fi
    MISS="$MISS
  · $f :: $v"
  done < <(grep -E "^[[:space:]]*static var " "$f")
done

if [ "${1:-}" = "--self-test" ]; then
  # ★陽性對照：已知被清的必須算 covered；不存在的名字必須算不到
  a=$(grep -c "_path_cache" scripts/simulation/path_system.gd)
  b=$(awk '/static func _reset_cross_run/{on=1} on{print}' scripts/simulation/path_system.gd | grep -c "_path_cache")
  if [ "$a" -ge 1 ] && [ "$b" -ge 1 ]; then echo "[CROSS-RUN-STATIC] SELF-TEST PASS（_path_cache 宣告=$a／出現在 reset 內=$b）"; exit 0; fi
  echo "[CROSS-RUN-STATIC] SELF-TEST FAIL（宣告=$a reset內=$b）——★先查是不是它被改名/搬走了，再查本閘"; exit 1
fi

echo "[CROSS-RUN-STATIC] static var 總數 $TOTAL｜有清除點 $COVERED｜白名單 $WLC｜旗標(不要求清) $FLAGS"
if [ -n "$MISS" ]; then
  echo "[CROSS-RUN-STATIC] ★★★下列 static 既沒有出現在 _reset_cross_run 裡，也不在白名單：$MISS"
  echo "[CROSS-RUN-STATIC] ⇒ 修法二選一：①在該檔的 _reset_cross_run 裡清它 ②加進 $WL 並寫【可查的根據】"
  echo "[CROSS-RUN-STATIC] FAIL"
  exit 1
fi
echo "[CROSS-RUN-STATIC] ★誠實限①：const 藏可變容器／autoload 成員／別名改寫（var r = REGISTRY）——本閘看不見"
echo "[CROSS-RUN-STATIC] ★誠實限②：只檢查【名字有沒有出現在 reset 裡】，不保證清乾淨（那由床的 ★RESIDUE 行抓）"
echo "[CROSS-RUN-STATIC] ★誠實限③：旗標(bool/int/float)刻意不要求清——清它會殺掉床自己剛設的；由 [diag] 行印出來"
echo "[CROSS-RUN-STATIC] PASS"
