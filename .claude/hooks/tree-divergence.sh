#!/usr/bin/env bash
# ★main ↔ 工作 branch 的【production 樹差】(systems 立 2026-09-02)
#   ★★為什麼是 WARN 不是 FAIL：branch 上【永遠有合法 WIP】⇒ 硬閘會永久紅，或逼人把 WIP 提早 merge
#   ★★★為什麼要有：一路用 cherry-pick 搬東西進 main ⇒ 【所有以 commit 為單位的對帳工具都失效】
#        血證 2026-09-02：同一個問題三個工具三個答案 —— HEAD..branch=114／git cherry=72／樹比對=20 檔
#        ⇒ 只有樹比對在答「內容到了沒」，而我搬了十幾顆【從沒做過一次】
#   ★本閘只印數字，不判對錯：處置走「樹對帳專段」(逐檔三分：該在 main／WIP 留 branch／不該在)
set -u
export LC_ALL=C
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)" || exit 2
BR="${TREE_DIV_BRANCH:-origin/feat/old-growth-forest}"
if ! git rev-parse --verify -q "$BR" >/dev/null; then
  echo "[TREE-DIV] 跳過：branch $BR 不存在（★這不是綠，是【沒量】）"
  echo "[TREE-DIV] PASS"; exit 0
fi
STAT=$(git diff HEAD "$BR" --shortstat -- scripts/simulation scripts/data 2>/dev/null)
NF=$(git diff HEAD "$BR" --name-only -- scripts/simulation scripts/data 2>/dev/null | grep -c . || true)
if [ "$NF" = "0" ]; then
  echo "[TREE-DIV] ✓ production 樹差 ＝ 0（main 與 $BR 一致）"
else
  echo "[TREE-DIV] ⚠WARN：main ↔ $BR 的 production 樹差 ＝ ${NF} 檔｜$STAT"
  echo "   ⇒ ★這【不一定是問題】：branch 上的 WIP 也長這樣"
  echo "   ⇒ ★★問題在【沒有人知道哪些是 WIP、哪些是「帳上記 landed 而樹上沒有」】"
  echo "   ⇒ ★★★處置＝樹對帳專段（逐檔三分），不是在別的刀裡順手撿"
  git diff HEAD "$BR" --name-only -- scripts/simulation scripts/data 2>/dev/null | sed 's/^/   ⚠ /' | head -25
fi
echo "[TREE-DIV] ★誠實限①：只比 scripts/simulation 與 scripts/data —— docs／debug 床的差【不在母體】"
echo "[TREE-DIV] ★誠實限②：只比【一個】branch（$BR）；別的 branch 有沒有東西，本閘看不見"
echo "[TREE-DIV] ★★★誠實限③：本閘【只印不判】—— 數字變大不會讓任何閘變紅，靠人看"
echo "[TREE-DIV] PASS"
