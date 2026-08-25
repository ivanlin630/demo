#!/usr/bin/env bash
# ★兩個【正交】的問題，分開問、分開判 —— 混在一起就兩個都答不了。
#   Q1 跑完了嗎？   → 結尾標記（只有跑到最後才印得出來）
#   Q2 有沒有新失敗？→ 與 baseline 比對（★不是「非零即紅」）
# 用法：bash .claude/hooks/test-ran-floor.sh <實跑輸出檔> [baseline檔]
#
# ── 血證（同一個病，四次化身）────────────────────────────────────────────
#   ①headless 因 parse error 沒跑，輸出 FAIL=0 —— 跟全綠長得一模一樣。
#     ★「FAIL=0」只說【沒有失敗的】，沒說【有跑過】。          → 拆出 Q1
#   ②Q1/Q2 混在一起 ⇒ baseline 有已知失敗 ⇒ 閘【永遠紅】。
#     ★★永遠紅的閘 ＝ 沒有閘（恆假式，跟恆真式一樣零資訊）。   → 拆出 Q2
#   ③只 grep 'Assertion failed'，實測失敗有三類共 16 行，閘只看到 5。
#     ⇒ 當時的結論是「改列舉【正常】的形式（收斂）」。
#   ④★★★而那個結論【是錯的】（2026-08-26 實測打臉）：列舉正常前綴 ⇒ 721 條假陽性。
#     ★根因：我把「收斂」掛在【訊息文字】上，而**兩邊的訊息文字都發散**
#       （錯誤訊息任意；正常 print 也任意，多數是無前綴的縮排內容行）。
#     ★★真正收斂的軸是【通道】，不是【文字】：Godot 的錯誤一律走固定的
#       severity 前綴（SCRIPT ERROR / ERROR / USER ERROR / FATAL），
#       ★★★那組前綴不由訊息內容決定，由引擎決定 ⇒ 有限、且不會因為我們寫了新測試而變多。
#     ⇒ 列舉軸改成 severity 前綴。實測：721 假陽性 → 7 條真失敗。
#
# ★編碼：Godot win console 吐 CP950。輸出檔若不是合法 UTF-8 → 先轉碼再比，
#   否則中文失敗訊息永遠對不上 UTF-8 的 baseline ＝ 每條都被判「新增」（假紅）。
set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)" || exit 2
out="${1:-}"; base="${2:-docs/test-baseline-failures.txt}"; marker='[TEST-SUITE-COMPLETE]'
# ★--gen-baseline：從【實跑輸出】生成 baseline（2026-08-26 加）
#   ★動機：baseline 機制原本只服務 headless_test 一張床；其他床沒有 baseline ⇒
#   ★★它們的紅【不可判讀】，每次都要有人手動跑 main 對照一次（implementer 本輪真的做了一次）。
#   ★★★工具本來就是床無關的（吃「輸出檔＋baseline 檔」兩參數），缺的只是「怎麼生第一份」。
#   ★生成的每一條類別一律標 `unjudged` —— **標 unjudged 不等於允許它紅**，
#     只是「還沒有人判過它是 stale-test 還是 real-regression」。★沒有類別的 baseline ＝垃圾桶。
GEN=0; [ "${3:-}" = "--gen-baseline" ] && GEN=1
{ [ -z "$out" ] || [ ! -f "$out" ]; } && { echo "[test-floor] ★FAIL 沒給實跑輸出檔"; exit 2; }
rc=0

# ---- 編碼正規化（★不是可有可無：編碼錯 ⇒ Q2 全紅）----
work="$(mktemp)"
if iconv -f UTF-8 -t UTF-8 "$out" >/dev/null 2>&1; then
  cat "$out" > "$work"
else
  echo "[test-floor] ★輸出檔非 UTF-8 ⇒ 以 CP950 轉碼後比對（Godot win console 預設）"
  iconv -f CP950 -t UTF-8 "$out" > "$work" 2>/dev/null || cat "$out" > "$work"
fi

# ---- Q1：跑完了嗎（★這題的答案不受 Q2 影響）----
if grep -qaF "$marker" "$work" 2>/dev/null; then
  echo "[test-floor] Q1 跑完了嗎 → ★YES（見結尾標記）"
else
  echo "[test-floor] Q1 跑完了嗎 → ★NO（無結尾標記）⇒ 這份輸出【沒有資格談綠不綠】"
  echo "[test-floor]    ★注意：這不是「測試失敗」，是「不知道跑了多少」。"
  rc=1
fi

# ---- Q2：有沒有【新】失敗（★與 baseline 比，不是與 0 比）----
# 列舉軸＝severity 通道（引擎決定、有限），非訊息文字（兩邊都發散）。
# WARNING 不算失敗（引擎噪音）；'   at: ' 是接續行，不是獨立失敗。
cur="$(mktemp)"
grep -aE '^(SCRIPT ERROR|ERROR|USER ERROR|USER SCRIPT ERROR|FATAL):' "$work" 2>/dev/null \
  | sed -e 's/^USER //' -e 's/^ERROR: *//' -e 's/^SCRIPT ERROR: Assertion failed: //' \
        -e 's/^SCRIPT ERROR: *//' -e 's/[[:space:]]*$//' \
  | grep -v '^$' | sort -u > "$cur"
n_cur="$(wc -l < "$cur" | tr -d ' ')"
if [ "$GEN" = 1 ]; then
  { echo "# 由 test-ran-floor.sh --gen-baseline 從【實跑輸出】生成，★不要手寫。"
    echo "# 來源：$out"
    echo "# 格式：<類別>	<原文>[	<註>]  類別＝stale-test / real-regression / unjudged"
    echo "# ★每一條都是 unjudged ＝【還沒有人判過】，不是【允許它紅】。判過就把類別改掉。"
    echo ""
    sed 's/^/unjudged	/' "$cur"
  } > "$base"
  echo "[test-floor] ★已生成 baseline：$base（$n_cur 條，全部 unjudged）"
  echo "[test-floor] ★★下一步是【判】那 $n_cur 條，不是把它當綠燈。"
  rm -f "$cur" "$work"; exit 0
fi
if [ ! -f "$base" ]; then
  echo "[test-floor] Q2 → ★無 baseline（$base）⇒ 無法分辨【已知】與【新增】"
  echo "[test-floor]    ★現況失敗 $n_cur 條。請用實跑輸出生成 baseline，★不要憑印象手寫。"
  rm -f "$cur" "$work"; exit 2
fi
# baseline 格式：<類別>\t<原文>[\t<註>]  —— ★註必須自成一欄，
#   黏在原文尾巴會讓那條【永遠對不上】＝ 一條 stale + 一條假新增（實際發生過）。
bl="$(mktemp)"
grep -v '^[[:space:]]*#' "$base" | grep -v '^[[:space:]]*$' \
  | cut -f2 | sed 's/[[:space:]]*$//' | sort -u > "$bl"
n_base="$(wc -l < "$bl" | tr -d ' ')"
newf="$(comm -23 "$cur" "$bl")"
gone="$(comm -13 "$cur" "$bl")"
echo "[test-floor] Q2 新失敗？ → baseline=$n_base 實測=$n_cur"
[ -n "$newf" ] && { echo "[test-floor] ★FAIL 新增失敗："; printf '%s\n' "$newf" | sed 's/^/      + /'; rc=1; }
# ★baseline falsifier：登記了卻沒出現 ⇒ 條目 stale（修好了或測試改名），表會悄悄腐爛
[ -n "$gone" ] && { echo "[test-floor] ★baseline stale（登記了但沒出現，請刪或查）："; printf '%s\n' "$gone" | sed 's/^/      - /'; }
rm -f "$cur" "$work" "$bl"
[ "$rc" = 0 ] && echo "[test-floor] ★PASS 跑完 ＋ 無新增失敗"
exit $rc
