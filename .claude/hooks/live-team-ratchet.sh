#!/usr/bin/env bash
# 棘輪閘：新寫的「state.teams.has( ＋ 之後對那支隊動作」要亮警（存量走 baseline）。
#   ★判準【不是重新發明的】—— 它就是 docs/process/teams-has-callsites.tsv 表頭那套，
#     只是包成可重跑的腳本（R² 指出：那份 86 列的表就是這個判準的產出）。
#   ★★而 [G]（純存在問句）本閘【不咬】—— 這是最容易做錯的一格。
#   ★★★偽陽的處置是【加進 baseline 並寫理由】，不是放寬判準。
set -u
cd "$(dirname "$0")/../.." || exit 2
PY=$(command -v python || command -v python3 || true)
[ -n "$PY" ] || { echo "[RATCHET] ★ABORT：找不到 python ⇒ 本輪結果無效（不得讀成 PASS）"; exit 2; }

if [ "${1:-}" = "--selfcheck" ]; then
  TMP=$(mktemp -d)
  trap 'rm -rf "$TMP"' EXIT
  mkdir -p "$TMP/fix"
  # (a) L 形狀：守衛之後把它取出來用 ⇒ 必須亮
  cat > "$TMP/fix/a_l.gd" <<'A'
func f(state, tid):
	if not state.teams.has(tid):
		return
	var t = state.teams[tid]
	t.population += 1
A
  # (b) G 形狀：守衛之後不再碰那支隊 ⇒ ★不得亮
  cat > "$TMP/fix/b_g.gd" <<'B'
func g(state, tid):
	if not state.teams.has(tid):
		team.parent_team_id = -1
		return
	return
B
  # (c) live_team 之後沒判 null ⇒ 必須亮
  cat > "$TMP/fix/c_null.gd" <<'C'
func h(state, tid):
	var t = state.live_team(tid)
	t.population += 1
C
  # (d) live_team 之後有判 null ⇒ ★不得亮
  cat > "$TMP/fix/d_ok.gd" <<'D'
func k(state, tid):
	var t = state.live_team(tid)
	if t == null:
		return
	t.population += 1
D
  OUT=$("$PY" .claude/hooks/live_team_ratchet.py --dirs "$TMP/fix" 2>&1)
  RC=$?
  FAIL=0
  echo "$OUT" | grep -q "a_l.gd" || { echo "❌ (a) L 形狀沒亮 —— 閘沒有鑑別力"; FAIL=1; }
  echo "$OUT" | grep -q "b_g.gd"  && { echo "❌ (b) G 形狀亮了 —— ★純存在守衛被誤咬（驗收④）"; FAIL=1; }
  echo "$OUT" | grep -q "c_null.gd" || { echo "❌ (c) live_team 沒判 null 沒亮"; FAIL=1; }
  echo "$OUT" | grep -q "d_ok.gd" && { echo "❌ (d) 判了 null 還亮 —— 亂咬"; FAIL=1; }
  [ "$RC" -le 1 ] || { echo "❌ 腳本自己出錯 rc=$RC"; FAIL=1; }
  # ★★而「腳本爆了」與「有發現」在 rc 上長得一樣（都可能是 1）⇒ 另外認 traceback
  echo "$OUT" | grep -q "Traceback" && { echo "❌ 腳本 traceback ⇒ 本輪不可判（不是有發現）"; FAIL=1; }
  if [ "$FAIL" -eq 0 ]; then echo "[RATCHET] --selfcheck ✅ 全綠（會紅兩格／不得亂紅兩格）"; exit 0; fi
  echo "[RATCHET] --selfcheck ❌"; exit 1
fi

OUT=$("$PY" .claude/hooks/live_team_ratchet.py 2>&1)
RC=$?
echo "$OUT"
echo "$OUT" | grep -q "Traceback" && { echo "[RATCHET] ★腳本 traceback ⇒ 不可判（★★它與「有發現」的 rc 一樣，所以要另外認）"; exit 2; }
[ "$RC" -eq 2 ] && { echo "[RATCHET] ★腳本自己爆了 ⇒ 不可判"; exit 2; }
if [ "$RC" -ne 0 ]; then echo "=== DONE === FAILS"; exit 1; fi
echo "=== DONE === ALL PASS"
