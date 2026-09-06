#!/usr/bin/env bash
# ★★★TeamData 計算屬性直寫閘（implementer 立 2026-09-07）
#   ★病：TeamData 有五個【只有 getter】的計算屬性。對它們賦值【不報錯、不 warn、值不變】。
#     實測 Godot 4.2.2：把 `set(_value): pass` 整段拿掉，賦值【仍然】是靜默 no-op
#     ⇒ ★★「拿掉 setter 讓它變成 parse error」這條路【不存在】——引擎不給這個保護。
#   ★★★本閘【不用 grep 判】。同一天四個數字的血證：107 / 58 / 56 / 53 / 52，
#     它們混進了①比較運算子 ②註解 ③字串字面值 ④★DecisionContext 的【合法】寫入
#     （c.population 是它的真欄位）⇒ 真數是 32（31 TeamData + 1 UNKNOWN）。
#     ⇒ ★★前四個數字不是「比較不精確」，它們量的是【別的東西】。
#     ⇒ 判準必須【認接收者的宣告型別】⇒ 交給 .claude/hooks/computed_prop_sites.py。
#   ★CRLF：兩邊都過 `tr -d '\r'`。血證＝內容完全相同卻【每一行都 diff】，
#     而那看起來像「有人全面改寫了這個檔」。
set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)" || exit 2

BASE_F=docs/process/.computed-prop-write-baseline.txt
[ -f "$BASE_F" ] || { echo "[COMPUTED-PROP] ★FAIL：baseline 不存在（$BASE_F）"; exit 1; }

PY=$(command -v python || command -v python3 || true)
[ -n "$PY" ] || { echo "[COMPUTED-PROP] ★ABORT：找不到 python ⇒ 本輪結果無效（不得讀成 PASS）"; exit 2; }

# ★★★不要用管線取狀態：`X | tr` 的 $? 是【tr 的】――
#   血證 2026-09-07：python 當場 SyntaxError，而閘看到 rc=0 + 空輸出 ⇒ 印 PASS(0 vs 0)。
#   ⇒ 先單獨取 python 的狀態，再做 CRLF 正規化。
RAW=$("$PY" .claude/hooks/computed_prop_sites.py 2>/dev/null)
RC=$?
NOW=$(printf %s "$RAW" | tr -d '')
if [ "$RC" -ne 0 ]; then
  echo "[COMPUTED-PROP] ★ABORT：列舉工具非零退出（rc=$RC；2＝它自己的陽性對照失敗）⇒ 本輪結果無效"
  exit 2
fi

BASE=$(grep -v '^#' "$BASE_F" | grep -v '^$' | tr -d '\r')
N_NOW=$(printf '%s\n' "$NOW" | grep -c . || true)
N_BASE=$(printf '%s\n' "$BASE" | grep -c . || true)

if [ "$NOW" = "$BASE" ]; then
  echo "[COMPUTED-PROP] ✓ TeamData 直寫站與 baseline 逐行相同（$N_NOW 站）"
  echo "[COMPUTED-PROP] PASS"
  exit 0
fi
echo "[COMPUTED-PROP] ★FAIL：TeamData 直寫站與 baseline 不同（baseline $N_BASE → 現在 $N_NOW）"
echo "   ★★【變少】也會紅 —— 那是好事，但要更新 baseline 並寫理由，"
echo "     否則下次它會遮住新加的站（同 headless-regression 的做法）。"
diff <(printf '%s\n' "$BASE") <(printf '%s\n' "$NOW") | sed 's/^/   /'
exit 1
