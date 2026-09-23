#!/usr/bin/env bash
# peers.sh — 角色註冊表（★純讀、零副作用，不接任何 hook）。
#
# 資料來源 = `.claude/hooks/.inbox-watch.<role>.lock`（本來就是租約：內容 pid + 每 POLL touch 一次），
# 只是以前沒人讀。這支把它讀出來。
#
# 用法：
#   bash .claude/hooks/peers.sh          # 表格
#   bash .claude/hooks/peers.sh --tsv    # 機器讀（watchdog 的 DEAD-ROLE 分類吃同一份）
#
# lock 格式（★前向相容兩種）：
#   舊：<watcher_pid>
#   新：<watcher_pid>\t<session_id>\t<claude_pid>     ← P4/階段4 之後
#
# ★★★2026-09-23 第二次改（新信箱第二版，用戶裁「不掛 watcher」）：
#   ★本支原本的 ALIVE 靠【watcher 每 20s touch lock】—— ★★而 watcher 已經整個退役
#   ⇒ 若原樣不動，這張表會【永遠六個 DEAD】。
#   ⇒ ★★★而「永遠給同一個答案的守衛」＝ 沒有守衛，還更糟：它看起來在回答。
#   所以狀態改判在【終端本身】（claude_pid 還在不在），心跳降級成一個純資訊欄：
#     OPEN  終端開著（敲得到；★敲 = SendMessage 到 ADDR 欄）
#     DEAD  終端沒開（★只有用戶能開）
#     ?     lock 是舊格式、沒有 claude_pid ⇒ ★判不出來就說判不出來
#
# ADDR 欄 = `.peer-addr.<role>`，由各角色開場自己用 whoami.sh 登記（★別人代填＝猜）。
#   `-`  還沒登記 ⇒ ★**敲不到**（要先請它登記；git handback 照樣寫得進去，只是它不會醒）
#   `?`  登記超過 24h ⇒ 可能已經換 session，地址可疑
set -u
STALE_S="${PEERS_STALE_S:-140}"     # = inbox-watch POLL(20) + 120
ROLES="blueprint systems reviewer qa measurer implementer"

_MAIN_REPO="$(dirname "$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" 2>/dev/null)"
HOOK_DIR="${_MAIN_REPO:-${CLAUDE_PROJECT_DIR:-.}}/.claude/hooks"
NOW=$(date +%s)
TSV=0; [ "${1:-}" = "--tsv" ] && TSV=1

# claude_pid 是不是還活著（Windows 行程，走 tasklist；查不到 → 未知）
_pid_alive() {
  [ -z "${1:-}" ] || [ "$1" = "-" ] && return 2
  tasklist //NH //FI "PID eq $1" 2>/dev/null | grep -qi 'claude\|node' && return 0
  return 1
}

[ "$TSV" = "0" ] && printf "%-12s %-6s %-9s %-9s %-38s %s
" ROLE STATE ADDR HEARTBEAT SESSION_ID CLAUDE_PID
for r in $ROLES; do
  lock="$HOOK_DIR/.inbox-watch.${r}.lock"
  if [ ! -f "$lock" ]; then
    state="DEAD"; age="-"; age_s=""; sid="-"; cpid="-"; wpid="-"   # ★age_s 必重置：否則沿用上一輪角色的值
  else
    mt=$(stat -c %Y "$lock" 2>/dev/null || echo 0)
    age_s=$(( NOW - mt ))
    IFS=$'\t' read -r wpid sid cpid _rest < "$lock"   # ★第4欄 proto=2 必須有地方接，否則它會黏在 cpid 後面（本檔 2026-09-23 血證：CLAUDE_PID 印成 "24004	proto=2" ⇒ tasklist 查無 ⇒ 六個角色全誤判 DEAD） 2>/dev/null
    wpid="${wpid:--}"; sid="${sid:--}"; cpid="${cpid:--}"
    # ★狀態改判在【終端】而非 watcher 心跳（watcher 已退役，見抬頭）
    if   [ "$cpid" = "-" ]; then state="?"
    elif _pid_alive "$cpid"; then state="OPEN"
    else state="DEAD"; fi
    if   [ "$age_s" -lt 90 ];   then age="${age_s}s"
    elif [ "$age_s" -lt 5400 ]; then age="$(( age_s / 60 ))m"
    else                             age="$(( age_s / 3600 ))h$(( (age_s % 3600) / 60 ))m"
    fi
  fi
  # ADDR：通訊錄（各角色開場自己用 whoami.sh 登記）
  af="$HOOK_DIR/.peer-addr.${r}"; addr="-"
  if [ -f "$af" ]; then
    IFS=$'	' read -r addr _asid _apid _ats < "$af" 2>/dev/null
    addr="${addr:--}"
    amt=$(stat -c %Y "$af" 2>/dev/null || echo 0)
    [ $(( NOW - amt )) -gt 86400 ] && addr="${addr}?"   # ★超過一天＝可能已換 session
  fi
  if [ "$TSV" = "1" ]; then
    printf "%s	%s	%s	%s	%s	%s
" "$r" "$state" "$addr" "${age_s:--}" "$sid" "$cpid"
  else
    printf "%-12s %-6s %-9s %-9s %-38s %s
" "$r" "$state" "$addr" "$age" "$sid" "$cpid"
  fi
done
