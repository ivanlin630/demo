#!/usr/bin/env bash
# whoami.sh <demo-XX> —— ★★★通訊錄登記（systems 立 2026-09-23，新信箱第二版的配套）。
#
# ★為什麼需要這支：新信箱 = git handback（★定址單位＝【角色】）＋ SendMessage 敲門
#   （★★定址單位＝【session 名 `demo-XX`】）—— 兩套地址，而**中間沒有任何東西把它們接起來**。
#   ⇒ 我手上有 `reviewer` 這個名字，卻【不知道要敲誰】。
# ★★而 session 名只有【本人】看得到：`ListAgents` 在自己這邊會印
#   「This session is demo-XX」，在別人那邊只印 demo-XX 不印角色。
#   ⇒ ★★★所以這張表**只能由各角色自己登記**，沒有人能代填（代填＝猜）。
#
# 用法（每個角色開場，緊接在 ListAgents 之後）：
#   bash .claude/hooks/whoami.sh demo-95
# 讀：
#   bash .claude/hooks/peers.sh          （ADDR 欄）
#
# ★誠實限：本表記的是【登記當下】的名字。session 關掉重開會換名，而**舊的一行不會自己消失**
#   ⇒ 所以每行都帶時間戳，且 peers.sh 對超過 24h 的行標 `?`：★寧可標成可疑，不要靜靜給錯地址。
set -u
ADDR="${1:-}"
ROLE="${SESSION_ROLE:-}"
case "$ADDR" in
  "")        echo "⛔ whoami：要給 session 名（ListAgents 第一行的 demo-XX）"; exit 2 ;;
  demo-*)    : ;;
  *)         echo "⛔ whoami：'$ADDR' 不像 session 名（應為 demo-XX）"; exit 2 ;;
esac
[ -z "$ROLE" ] && { echo "⛔ whoami：SESSION_ROLE 沒設 ⇒ 不知道你是哪個角色，拒絕登記"; exit 2; }

_gc="$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)"
HOOKD="$(dirname "${_gc:-.git}")/.claude/hooks"
F="$HOOKD/.peer-addr.${ROLE}"
# ★★★2026-09-24：第三欄寫的是【claude 進程 pid】（env CLAUDE_PID），不是這支 bash 的 $$。
#   ★血證：blueprint 重開之後 .inbox-watch.blueprint.lock 的 claude_pid 仍是舊的 24004（已死），
#     而 peers.sh 把那一欄當成「終端還在不在」的判準 ⇒ 它把重開後的 blueprint 判成 DEAD。
#   ★★真因是我自己造的：我在【inbox watcher 退役】的同一天，把 peers.sh 的判準改成讀那一欄
#     ⇒ ★★★讀者還在、寫者沒了 ⇒ 那一欄從此【凍結在最後一次的值】。
#   ⇒ liveness 來源改成【每次開場都會被重寫的這個檔】；lock 的第三欄降級成 legacy 後備。
printf '%s	%s	%s	%s
' "$ADDR" "${CLAUDE_CODE_SESSION_ID:-${CLAUDE_SESSION_ID:--}}" "${CLAUDE_PID:--}" "$(date +%FT%T)" > "$F"
echo "✅ 通訊錄：${ROLE} → ${ADDR}（別的角色現在敲得到你）"
