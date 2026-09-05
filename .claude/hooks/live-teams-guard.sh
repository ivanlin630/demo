#!/usr/bin/env bash
# ★★★禁【新的】裸 `for ... in state.teams`（spec 2026-09-05-erase-merge-corpse §8③）
#   ★形狀照 print-join 那道的模子：機械 grep 抓字面 / allowlist 具名放行 / 新出現一律 FAIL。
#   ★★為什麼要這道：★★★裸迴圈與「刻意要看到墓碑」在字面上【分不出來】——
#     而「改迭代來源」這個修法的價值全在【下一個人寫新迴圈時會被擋下來】。
#   ★誠實限：本閘只看 `scripts/simulation/` 與 `scripts/data/`（世界路徑）；
#     ★★debug/ 床不納管（它們本來就是觀察者）。
set -u
ALLOW="docs/process/live-teams-allowlist.txt"
PAT='for [A-Za-z_][A-Za-z0-9_]* in state\.teams\b'
PAT2='for [A-Za-z_][A-Za-z0-9_]* in teams\b'
HITS=$( { grep -rnE "$PAT" scripts/simulation/ --include=*.gd 2>/dev/null; \
          grep -rnE "$PAT2" scripts/data/world_state.gd 2>/dev/null; } | sort )
TOTAL=$(printf '%s' "$HITS" | grep -c . || true)
if [ ! -f "$ALLOW" ]; then
  echo "[LIVE-TEAMS] ★★★FAIL：allowlist 檔不存在（$ALLOW）—— ★而沒有它，本閘會把【全部既有站點】判成新的"
  echo "[LIVE-TEAMS] FAIL"; exit 1
fi
NEW=""
while IFS= read -r line; do
  [ -z "$line" ] && continue
  key="${line%%:*}:$(printf '%s' "$line" | cut -d: -f2)"
  if ! grep -qxF "$key" "$ALLOW"; then NEW="${NEW}${line}"$'\n'; fi
done <<< "$HITS"
NEWN=$(printf '%s' "$NEW" | grep -c . || true)
ALLOWN=$(grep -cvE '^\s*(#|$)' "$ALLOW" || true)
echo "[LIVE-TEAMS] 站點 $TOTAL ｜ allowlist $ALLOWN ｜ ★新出現 $NEWN"
echo "[LIVE-TEAMS] ★誠實限①：allowlist 是【存量快照】—— ★★存量【沒有被逐站複核過】，本閘不代表它們合格"
echo "[LIVE-TEAMS] ★★誠實限②：本閘只看 scripts/simulation 與 scripts/data；debug/ 床不納管"
if [ "$NEWN" -gt 0 ]; then
  echo "[LIVE-TEAMS] ★★★FAIL：出現【新的】裸迭代 —— ★改用 state.live_teams()（決策/執行）或 state.all_teams()（感知/稽核）"
  printf '%s' "$NEW" | sed 's/^/[LIVE-TEAMS]    ★/'
  echo "[LIVE-TEAMS] ⇒ ★★判準（R²）：只讀觀察 → all_teams()／採取動作或當合法對象 → live_teams()"
  echo "[LIVE-TEAMS] ⇒ ★★★兩件都做 ⇒ 【拆兩輪】（先 all 觀察、篩完再對活隊子集動作），不是猜一邊"
  echo "[LIVE-TEAMS] FAIL"; exit 1
fi
echo "[LIVE-TEAMS] PASS"
