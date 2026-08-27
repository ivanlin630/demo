#!/usr/bin/env bash
# ★★★rebase 護欄（systems 立 2026-08-27，血證：merge 完 S2 之後反射性 `git pull --rebase`）
#   ★病：rebase 會把【被 merge 進來的每一顆 commit】逐顆重放
#     ⇒ merge 結構被壓平成一串 cherry-pick ＝「造出上游從未存在過的中間狀態」
#     ⇒ ★★而症狀是【衝突突然冒出來】,很容易被誤讀成「這次 merge 有問題」
#   ★★不硬擋：deliberate rebase 仍可做 —— 帶 ALLOW_REBASE_WITH_MERGES=1
#   ★★★判準是【這次 rebase 會不會重放 merge commit】,不是「你有沒有 merge 過」
set -u
upstream="${1:-}"
[ -z "$upstream" ] && exit 0
branch="${2:-HEAD}"
n=$(git rev-list --merges --count "$branch" "^$upstream" 2>/dev/null || echo 0)
[ "$n" -eq 0 ] && exit 0
if [ "${ALLOW_REBASE_WITH_MERGES:-0}" = "1" ]; then
  echo "[pre-rebase] ⚠ 這次 rebase 會重放 $n 顆 merge commit —— 你已用 ALLOW_REBASE_WITH_MERGES=1 明示,放行。"
  exit 0
fi
cat >&2 <<'MSG'
[pre-rebase] ⛔ 擋下：這次 rebase 會【重放 merge commit】。
  ★rebase 會把被 merge 進來的每一顆 commit 逐顆重放 ⇒ merge 結構壓平成一串 cherry-pick
    ＝「造出上游從未存在過的中間狀態」,而症狀是【衝突突然冒出來】,很像「這次 merge 有問題」。
  ★★merge 之後要推送：
       git fetch origin
       origin 沒前進 ⇒ git push            （★不要 pull）
       origin 有前進 ⇒ git pull --no-rebase （再 merge 一次）
  ★★★真的要 rebase（例如整理自己那條 feature 線）：ALLOW_REBASE_WITH_MERGES=1 git rebase ...
MSG
exit 1
