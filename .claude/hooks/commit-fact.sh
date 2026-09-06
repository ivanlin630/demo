#!/usr/bin/env bash
# ★記錄【事實】：本 session 真的讓 HEAD 動了。PostToolUse(Bash|PowerShell)。
#
# ★★為什麼需要這支：`zero-output-warn` 原本用 `git log --author="$(git config user.name)"`
#   來問「我這回合有沒有 commit」——而★六個角色 session ＋ 影子 session【共用同一個 git 身分】
#   ⇒ `--author` 篩不掉任何人 ⇒ 它數的是【全 repo 20 分鐘內的所有 commit】
#   ⇒ ★★在這個專案「20 分鐘內有人 commit」幾乎是常態 ⇒ ★★★接近恆真的警告。
#   而一支天天喊狼的守衛，會在【真的斷鏈那次】被當噪音跳過——它吃掉的是原本那條規則的執行力。
#
# ★★★修法的形狀不是「換一個更好的篩選條件」（`--committer` 一樣共用，沒救），
#    是【不要再用代理訊號猜，改成把事實記下來】。
#
# ★而「有跑過 git commit」本身還不夠格當事實：commit 可能失敗（index.lock／空 staged／hook 擋）。
#   ⇒ 只在【HEAD 真的變了】時才記一筆 ⇒ 失敗的 commit 不會留下痕跡。
set -u
sid="${CLAUDE_CODE_SESSION_ID:-}"
[ -z "$sid" ] && exit 0
IN=$(cat 2>/dev/null || echo '{}')
printf '%s' "$IN" | grep -qE 'git[[:space:]]+commit' || exit 0
_gc=$(git rev-parse --git-common-dir 2>/dev/null) || exit 0
cd "$(cd "$(dirname "$_gc")" && pwd)" || exit 0
head=$(git rev-parse HEAD 2>/dev/null) || exit 0
f=".claude/hooks/.committed.${sid}"
last=$(tail -1 "$f" 2>/dev/null | awk '{print $2}')
[ "$head" = "$last" ] && exit 0
printf '%s %s\n' "$(date +%s)" "$head" >> "$f"
exit 0
