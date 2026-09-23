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
    # ★★★2026-09-24：claude_pid 優先取自【通訊錄】而不是 lock。
    #   ★lock 的第三欄由 inbox-watch 寫，而 inbox-watch 已退役 ⇒ ★★**讀者還在、寫者沒了**
    #     ⇒ 那一欄凍結在最後一次的值。血證：blueprint 重開後 lock 仍是舊 pid 24004（已死）
    #     ⇒ 這支把它判成 DEAD，而它其實開著。
    #   ★★★通訊錄每次開場都會被重寫（whoami.sh），所以它是【有寫者】的那一個。
    #   ★★★而【舊格式的記錄不能信】：2026-09-24 之前 whoami.sh 第三欄寫的是【bash 的 $$】
    #     ⇒ 那是一個早就死掉的 pid，★而 Windows 會回收 pid ⇒ 它可能【剛好對上別的進程】
    #     ⇒ **舊記錄會產生假 OPEN**（實測：五個角色一起變成 OPEN，而它們的第三欄是 9 小時前的 bash pid）
    #   ⇒ 判準：**舊格式的 session_id 欄是 `-`**（舊碼讀的是不存在的 CLAUDE_SESSION_ID）
    #     ⇒ 只有第二欄【不是 `-`】的記錄，它的 pid 才採信。
    if [ -n "${_apid:-}" ] && [ "${_apid}" != "-" ] && [ -n "${_asid:-}" ] && [ "${_asid}" != "-" ]; then
      cpid="$_apid"
      # ★同一個理由，SESSION_ID 欄也要跟著走通訊錄 —— 否則它會印【重開之前】那個 session
      #   ⇒ ★★一欄新一欄舊，而讀的人不會知道哪一欄是舊的（blueprint 重開後實際發生）
      sid="$_asid"
    fi
  fi
  # ★★★狀態判定【必須在通訊錄覆寫之後】（2026-09-24 blueprint 抓到）：
  #   ★第一版把它留在 lock 區塊裡 ⇒ **印出來的 pid 是新的、判的是舊的**
  #   ⇒ ★★同一行的兩欄自相矛盾（CLAUDE_PID=9740 而 STATE=DEAD）——
  #     而那正是我自己記過的抓法：**把兩個數印在同一行，矛盾就看得見**。
  #   ⇒ ★★★通則：**改了一個值的來源，就要去看【誰在它之前就已經用過它】。**
  if   [ "${cpid:--}" = "-" ]; then state="?"
  elif _pid_alive "$cpid";    then state="OPEN"
  else                             state="DEAD"; fi
  if [ "$TSV" = "1" ]; then
    printf "%s	%s	%s	%s	%s	%s
" "$r" "$state" "$addr" "${age_s:--}" "$sid" "$cpid"
  else
    printf "%-12s %-6s %-9s %-9s %-38s %s
" "$r" "$state" "$addr" "$age" "$sid" "$cpid"
  fi
done
