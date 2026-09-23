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
printf '%s\t%s\t%s\t%s\n' "$ADDR" "${CLAUDE_SESSION_ID:--}" "$$" "$(date +%FT%T)" > "$F"
echo "✅ 通訊錄：${ROLE} → ${ADDR}（別的角色現在敲得到你）"
