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

live_sites() {   # 與普查表同一組過濾（子字串誤命中要排掉）
  grep -rn "in state\.teams" scripts/simulation scripts/data --include=*.gd \
    | grep -v "teams_on_tile" | grep -v "teams_by_tile" | grep -v "teams_pending_erase" \
    | cut -d: -f1,2 | sort -u
}
tsv_sites() { awk -F'\t' 'NR>1 && $1 ~ /^scripts\// {print $1}' "$TSV" | sort -u; }

[ -f "$TSV" ] || { echo "[FAIL] 找不到普查表 $TSV"; exit 1; }
N_LIVE=$(live_sites | wc -l); N_TSV=$(tsv_sites | wc -l)
# ★母體不得為空：空母體會讓下面兩個比對【全綠而毫無鑑別力】
if [ "$N_LIVE" -lt 30 ]; then
  echo "[FAIL] 母體只撈到 $N_LIVE 站 —— ★這比「有站點沒登記」更可疑：撈法自己壞了"
  exit 1
fi

MISSING=$(comm -23 <(live_sites) <(tsv_sites))
if [ -n "$MISSING" ]; then
  echo "$MISSING" | while read -r s; do
    echo "[FAIL] 新的 state.teams 迭代站點沒有登記：$s —— ★它需要活著的還是全部的？逐站判，別留白"
  done
  FAILS=1
fi
# ★反向：表上有、現場沒有 ⇒ 門牌指錯（行號漂了／站點被刪）——兩種都要紅，
#   ★★因為「錨指到別的地方」會讓這張表【看起來已經維護過】。
STALE=$(comm -13 <(live_sites) <(tsv_sites) | grep -v "observer_query_api.gd\|sim_runner.gd\|state_fingerprint.gd\|resource_system.gd\|faction_ai_system.gd:4416")
if [ -n "$STALE" ]; then
  echo "$STALE" | while read -r s; do
    echo "[FAIL] 普查表指向一個現在撈不到的站點：$s —— 行號漂了或站點已刪，★表要跟著改"
  done
  FAILS=1
fi
echo "母體 $N_LIVE 站（grep 命中）／表上 $N_TSV 列（含手動收錄的 5 類特殊寫法）"
if [ "$FAILS" -eq 0 ]; then echo "=== DONE === ALL PASS"; else echo "=== DONE === FAILS"; exit 1; fi
