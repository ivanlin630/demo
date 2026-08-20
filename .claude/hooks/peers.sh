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
# 三態判定（★不輸出「需要被解讀的狀態」，輸出「已判完的結果」）：
#   ALIVE      心跳新鮮（< STALE_S）             → 這角色的 watcher 正在跑
#   NO-WATCH   心跳過期，但 claude.exe 還活著     → 終端開著、watcher 掉了（re-arm 即可）
#   DEAD       心跳過期，且 claude_pid 不存活/未知 → 終端沒開（★只有用戶能開）
# ★誠實註記（階段 4 前）：舊格式 lock 沒有 claude_pid ⇒ NO-WATCH 永遠不會 fire，過期一律落 DEAD。
#   這是保守正確的：watcher 死了就沒人叫得醒該角色，本來就該推用戶。階段 4 換格式後 NO-WATCH 才會生效。
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

[ "$TSV" = "0" ] && printf "%-12s %-9s %-10s %-38s %-9s %s\n" ROLE STATE HEARTBEAT SESSION_ID CLAUDE_PID WATCHER_PID
for r in $ROLES; do
  lock="$HOOK_DIR/.inbox-watch.${r}.lock"
  if [ ! -f "$lock" ]; then
    state="DEAD"; age="-"; age_s=""; sid="-"; cpid="-"; wpid="-"   # ★age_s 必重置：否則沿用上一輪角色的值
  else
    mt=$(stat -c %Y "$lock" 2>/dev/null || echo 0)
    age_s=$(( NOW - mt ))
    IFS=$'\t' read -r wpid sid cpid < "$lock" 2>/dev/null
    wpid="${wpid:--}"; sid="${sid:--}"; cpid="${cpid:--}"
    if [ "$age_s" -lt "$STALE_S" ]; then
      state="ALIVE"
    else
      if _pid_alive "$cpid"; then state="NO-WATCH"; else state="DEAD"; fi
    fi
    if   [ "$age_s" -lt 90 ];   then age="${age_s}s"
    elif [ "$age_s" -lt 5400 ]; then age="$(( age_s / 60 ))m"
    else                             age="$(( age_s / 3600 ))h$(( (age_s % 3600) / 60 ))m"
    fi
  fi
  if [ "$TSV" = "1" ]; then
    printf "%s\t%s\t%s\t%s\t%s\t%s\n" "$r" "$state" "${age_s:--}" "$sid" "$cpid" "$wpid"
  else
    printf "%-12s %-9s %-10s %-38s %-9s %s\n" "$r" "$state" "$age" "$sid" "$cpid" "$wpid"
  fi
done
