#!/usr/bin/env bash
# ★★★計算屬性直寫閘（implementer 立 2026-09-07）
#   ★病：TeamData 有五個【只有 getter】的計算屬性。對它們賦值【不報錯、不 warn、值不變】。
#     實測（Godot 4.2.2）：把 `set(_value): pass` 整個拿掉之後，賦值【仍然】是靜默 no-op
#     ⇒ ★★「拿掉 setter 讓它變成 parse error」這條路【不存在】——引擎不提供這個保護。
#   ★★★所以【唯一】會響的東西只有兩個：①runtime 的 push_error（要那行真的被執行到）
#     ②本閘（靜態，不需要執行）。⇒ 兩者互補：runtime 抓得到「真的在跑錯的世界」，
#     本閘抓得到「新加進來的站」——而後者是【預防】，前者是【考古】。
#   ★誠實限：本閘只認【`.prop =` 這個語法形狀】。`set("population", 5)`／反射寫入它看不到。
set -u
# ★★★【不】export LC_ALL=C ――血證 2026-09-07：它讓 `grep -P` 對這些 UTF-8 檔回【 0 筆】（58→0）。
#   ★而我那行是從 headless-regression.sh 抄來的，沒問它對我的 pattern 做了什麼。
#   ★★失效形狀：閘會宣稱【債務全清了】；若 baseline 也用同一個 locale 產，
#     兩邊都是空 ⇒ 閘印 PASS（0 vs 0）――★★★一支完全沒有鑑別力的閘。
#   ⇒ 只對【排序】固定 locale（下方 LC_ALL=C sort），不動 grep 的。
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)" || exit 2

PROPS='population|wounded|anon_tiers|anon_combat_skill|anon_wage'

# ★★★內建陽性對照：先確認【正則引擎本身會不會抓】，再去相信它抓到的 0。
#   ★沒有這四行，一個抓不到任何東西的閘與一個【真的沒債務】的閘長得一模一樣。
if ! printf 'x.population = 1
' | grep -qP "\.($PROPS)\s*=(?!=)"; then
  echo "[COMPUTED-PROP] ★ABORT：grep -P 連合成的陽性樣本都抓不到 ⇒ 本輪結果無效（不得讀成 PASS 也不得讀成 FAIL）"
  exit 2
fi
BASE_F=docs/process/.computed-prop-write-baseline.txt
[ -f "$BASE_F" ] || { echo "[COMPUTED-PROP] ★FAIL：baseline 不存在（$BASE_F）—— 沒有 baseline 就分不出「本來就有」與「新加的」"; exit 1; }

# ★裸掃：不加動詞白名單、不加目錄白名單。★★排除比較運算子（`==`/`!=`）——
#   血證 2026-09-07：兩個角色各自報了 107 與 56，兩個都把 `== 0` 算成了賦值。
NOW=$(grep -rnP "\.($PROPS)\s*=(?!=)" scripts/ 2>/dev/null | sed 's/:[0-9]*:.*//' | LC_ALL=C sort | uniq -c | awk '{print $2" "$1}' | LC_ALL=C sort)
BASE=$(grep -v '^#' "$BASE_F" | grep -v '^$' | LC_ALL=C sort)

if [ "$NOW" = "$BASE" ]; then
  N=$(printf '%s\n' "$NOW" | grep -c . || true)
  echo "[COMPUTED-PROP] ✓ 直寫站與 baseline 逐檔相同（$N 檔）"
  echo "[COMPUTED-PROP] PASS"
  exit 0
fi

echo "[COMPUTED-PROP] ★FAIL：直寫站與 baseline 不同"
echo "   ★★而【變少】也會紅 —— 那是好事，但要更新 baseline 並寫理由，"
echo "     否則下次它會遮住新加的站（同 headless-regression 的做法）。"
diff <(printf '%s\n' "$BASE") <(printf '%s\n' "$NOW") | sed 's/^/   /'
exit 1
