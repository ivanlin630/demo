#!/usr/bin/env bash
# 登記錨 ④a 棘輪（本體 registry_axis_ratchet.py）。
#   ★成對自檢：會紅（新手寫 parent 軸）／不得亂紅（改用具名謂詞）／baseline 走味也紅。
#   ★★而 traceback 與「有發現」的 rc 一樣是 1 ⇒ 自檢要能分開（同族教訓：工具壞掉會偽裝成發現）。
set -u
cd "$(dirname "$0")/../.." || exit 2
PY=$(command -v python || command -v python3 || true)
[ -n "$PY" ] || { echo "[RATCHET] ★ABORT：找不到 python ⇒ 本輪結果無效（不得讀成 PASS）"; exit 2; }

run() { "$PY" .claude/hooks/registry_axis_ratchet.py "$1" 2>&1; }

if [ "${1:-}" = "--selfcheck" ]; then
  TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
  mkdir -p "$TMP/scripts/simulation" "$TMP/scripts/data" "$TMP/docs/process"
  cat > "$TMP/scripts/simulation/a_bad.gd" <<'A'
func f(state, team, tile):
	if tile.outpost_owner == team.parent_team_id and team.parent_team_id != -1:
		return true
A
  cat > "$TMP/scripts/simulation/b_ok.gd" <<'B'
func g(state, team, tile):
	return state.registered_or_parent_at(team, tile.tile_pos, "unload")
B
  printf '# axis	owner	norm-text
' > "$TMP/docs/process/registry-axis-baseline.tsv"
  OUT_A=$(run "$TMP"); RC_A=$?
  echo "$OUT_A" | grep -qE "Traceback|SyntaxError|IndentationError" && { echo "[SELFCHECK] ★ABORT：偵測器自己爆了"; echo "$OUT_A"; exit 2; }
  ok=0; bad=0
  if [ "$RC_A" = "1" ] && echo "$OUT_A" | grep -q "a_bad.gd:2"; then ok=$((ok+1)); else bad=$((bad+1)); echo "[SELFCHECK] ❌ (a) 新手寫 parent 軸應具名紅"; fi
  if ! echo "$OUT_A" | grep -q "b_ok.gd"; then ok=$((ok+1)); else bad=$((bad+1)); echo "[SELFCHECK] ❌ (b) 用具名謂詞不得亮"; fi
  # (c) 把它加進 baseline ⇒ 必須變綠
  printf 'parent-axis\ttest\tif tile.outpost_owner == team.parent_team_id and team.parent_team_id != -1:\n' >> "$TMP/docs/process/registry-axis-baseline.tsv"
  OUT_B=$(run "$TMP"); RC_B=$?
  if [ "$RC_B" = "0" ]; then ok=$((ok+1)); else bad=$((bad+1)); echo "[SELFCHECK] ❌ (c) 進 baseline 之後應綠"; echo "$OUT_B"; fi
  # (d) baseline 有一列 code 裡沒有 ⇒ 必須紅（存量只准變少）
  printf 'parent-axis\ttest\tif tile.outpost_owner == team.parent_team_id and 0:\n' >> "$TMP/docs/process/registry-axis-baseline.tsv"
  OUT_C=$(run "$TMP"); RC_C=$?
  if [ "$RC_C" = "1" ] && echo "$OUT_C" | grep -q "baseline 有一列"; then ok=$((ok+1)); else bad=$((bad+1)); echo "[SELFCHECK] ❌ (d) baseline 走味應紅"; fi
  echo "[SELFCHECK] $ok/4 格；壞 $bad 格"
  [ "$bad" = "0" ] && { echo "--selfcheck ✅ 全綠"; exit 0; } || exit 1
fi

OUT=$(run "."); RC=$?
echo "$OUT"
echo "$OUT" | grep -qE "Traceback|SyntaxError|IndentationError" && { echo "[RATCHET] ★ABORT：偵測器自己爆了（rc 與『有發現』一樣，別讀成發現）"; exit 2; }
exit $RC
