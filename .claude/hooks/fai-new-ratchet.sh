#!/usr/bin/env bash
# 棘輪：production 不得再出現 `FactionAISystem.new()`（★七千行 class，每次決策配置一支）。
#   ★存量 42 處已一次換成 `FactionAISystem.shared()`；★★新增 ⇒ 具名紅。
#   ★★★debug/床【不在範圍】：那裡本來就該各自 new（各自的去重記憶互不污染）。
#   ★唯一豁免：`shared()` 工廠自己那一行。
set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)" || exit 2

scan() {
  grep -rn "FactionAISystem\.new()" "$1/scripts/simulation" "$1/scripts/data" --include=*.gd 2>/dev/null \
    | grep -v "_shared_fai = FactionAISystem.new()"
}

if [ "${1:-}" = "--selfcheck" ]; then
  TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
  mkdir -p "$TMP/scripts/simulation" "$TMP/scripts/data" "$TMP/scripts/debug"
  printf 'func f():\n\tvar x = FactionAISystem.new()\n' > "$TMP/scripts/simulation/bad.gd"
  printf 'func g():\n\tvar x = FactionAISystem.shared()\n' > "$TMP/scripts/simulation/ok.gd"
  printf 'func h():\n\tvar x = FactionAISystem.new()\n' > "$TMP/scripts/debug/bed.gd"
  printf 'static func shared():\n\t_shared_fai = FactionAISystem.new()\n' > "$TMP/scripts/simulation/factory.gd"
  OUT=$(scan "$TMP"); ok=0; bad=0
  echo "$OUT" | grep -q "bad.gd" && ok=$((ok+1)) || { bad=$((bad+1)); echo "[SELFCHECK] ❌ (a) production 的 new() 應被抓到"; }
  echo "$OUT" | grep -q "ok.gd"  && { bad=$((bad+1)); echo "[SELFCHECK] ❌ (b) shared() 不得亂紅"; } || ok=$((ok+1))
  echo "$OUT" | grep -q "bed.gd" && { bad=$((bad+1)); echo "[SELFCHECK] ❌ (c) debug/床不在範圍"; } || ok=$((ok+1))
  echo "$OUT" | grep -q "factory.gd" && { bad=$((bad+1)); echo "[SELFCHECK] ❌ (d) 工廠自己那一行要豁免"; } || ok=$((ok+1))
  echo "[SELFCHECK] $ok/4 格；壞 $bad 格"
  [ "$bad" = "0" ] && { echo "--selfcheck ✅ 全綠"; exit 0; } || exit 1
fi

HITS=$(scan ".")
if [ -n "$HITS" ]; then
  echo "[FAI-RATCHET] ★具名紅：production 出現 FactionAISystem.new()"
  echo "$HITS" | sed 's/^/  /'
  echo "  ⇒ 改用 FactionAISystem.shared()（★七千行 class，每次決策配置一支；★★而它的兩顆去重記憶要共享才會生效）"
  exit 1
fi
echo "[FAI-RATCHET] ✅ production 無 FactionAISystem.new()（存量 42 處已換）"
exit 0
