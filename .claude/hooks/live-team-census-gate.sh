#!/usr/bin/env bash
# 閘：state.teams 迭代站點普查表【不得靜默過期】
#   母體＝現在真的存在的迭代站點；判準＝每一站【剛好】出現在 docs/process/live-team-census.tsv 一列。
#   ★這張表的失效是【靜默】的：新加一個迴圈站點，表不會變紅、它只是【沒有那一列】
#     ⇒ 而「沒有那一列」跟「這個站點不存在」在表上長得一模一樣。
#   ★★誠實限：本閘只驗【母體有沒有漏】，★★★不驗 class 分得對不對（那是語意，機器判不了）。
set -u
cd "$(dirname "$0")/../.." || exit 2
TSV=docs/process/live-team-census.tsv
FAILS=0

live_sites() {   # ★錨＝【檔名 ＋ 包著它的 func 名】，**不是行號** —— 行號會漂（systems 2026-09-10）。
  #   ★★而 func 名本來就在普查表的第二欄：錨用已經在那裡的、不會漂的那一個。
  for f in $(grep -rl "in state\.teams" scripts/simulation scripts/data --include=*.gd); do
    awk -v F="$f" '
      /^[[:space:]]*(static )?func [A-Za-z0-9_]+/ {
        fn=$0; sub(/^[[:space:]]*(static )?func /,"",fn); sub(/\(.*/,"",fn)
      }
      /in state\.teams/ {
        if ($0 ~ /teams_on_tile|teams_by_tile|teams_pending_erase/) next
        if ($0 ~ /^[[:space:]]*#/) next
        print F "	" fn
      }' "$f"
  done | sort
}
tsv_sites() { awk -F'\t' 'NR>1 && $1 ~ /^scripts\// { f=$1; sub(/:.*/,"",f); print f "\t" $2 }' "$TSV" | sort; }

[ -f "$TSV" ] || { echo "[FAIL] 找不到普查表 $TSV"; exit 1; }
N_LIVE=$(live_sites | wc -l); N_TSV=$(tsv_sites | wc -l)
# ★母體不得為空：空母體會讓下面兩個比對【全綠而毫無鑑別力】
if [ "$N_LIVE" -lt 30 ]; then
  echo "[FAIL] 母體只撈到 $N_LIVE 站 —— ★這比「有站點沒登記」更可疑：撈法自己壞了"
  exit 1
fi

MISSING=$(comm -23 <(live_sites | uniq) <(tsv_sites | uniq))
if [ -n "$MISSING" ]; then
  echo "$MISSING" | while read -r s; do
    echo "[FAIL] 新的 state.teams 迭代站點沒有登記：$s —— ★它需要活著的還是全部的？逐站判，別留白"
  done
  FAILS=1
fi
# ★反向：表上有、現場沒有 ⇒ 門牌指錯（行號漂了／站點被刪）——兩種都要紅，
#   ★★因為「錨指到別的地方」會讓這張表【看起來已經維護過】。
STALE=$(comm -13 <(live_sites | uniq) <(tsv_sites | uniq) | grep -v "observer_query_api.gd\|sim_runner.gd\|state_fingerprint.gd\|resource_system.gd\|cleanup_extinct_teams")
if [ -n "$STALE" ]; then
  echo "$STALE" | while read -r s; do
    echo "[FAIL] 普查表指向一個現在撈不到的站點：$s —— 行號漂了或站點已刪，★表要跟著改"
  done
  FAILS=1
fi
echo "母體 $N_LIVE 站（grep 命中）／表上 $N_TSV 列（含手動收錄的 5 類特殊寫法）"
if [ "$FAILS" -eq 0 ]; then echo "=== DONE === ALL PASS"; else echo "=== DONE === FAILS"; exit 1; fi
