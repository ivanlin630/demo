#!/usr/bin/env bash
# role-watch.sh <kind> —— ★★★背景常駐監視器的【統一外殼】（systems 立 2026-09-23，用戶裁）。
#
# ★用戶要的四件（逐字）：
#   1.真有信才叫的信箱  2.真停工一段時間才叫的看門狗  3.TG收信  4.以上監視器永久跑 沒事不叫
#
# ★★為什麼不用 Monitor：這一版沒有 persistent、**30 分鐘硬到期**（實測：timeout_ms 上限 3600000，
#   而即使傳 3600000 它仍回「expires in 30m」⇒ 那個上限不是參數決定的）
#   ⇒ 每半小時一次【空重掛】＋每次 ARMED 雜訊 ＝ 閒置也在燒 token。
#
# ★★★形狀：背景 Bash 任務【結束時】會喚醒 session ⇒ 所以
#   ・閒置：一直跑、**一個字都不輸出**（滿足 4）
#   ・有事：把那一行印出來並結束 ⇒ 你被叫醒（滿足 1/2/3）
#   ・而「重掛」只發生在【真的有事】之後，夾在你本來就要處理它的那一輪裡。
#
# ★判準（三支共用，而且是它們自己的慣例，不是我發明的）：
#   ・`[…]` 開頭 ＝ 狀態噪音（ARMED／換血／讓位／普查／CLEAN）⇒ 進 log，不喚醒
#   ・其餘 ＝ 事件（📬 收信／🟡🔴 STALL／Telegram 訊息本文）⇒ 印出來並結束
#   ⇒ ★★三支腳本的狀態行【都】以 `[` 開頭，而三種事件行【都】不是（已逐支核過）
#
# 用法（每個角色開場，一種掛一支；★不要為了防掛掉再加任何輪詢／重掛迴圈）：
#   Bash(command="SESSION_ROLE=<role> bash .claude/hooks/role-watch.sh inbox",    run_in_background=true)
#   Bash(command="SESSION_ROLE=<role> bash .claude/hooks/role-watch.sh watchdog", run_in_background=true)
#   Bash(command="SESSION_ROLE=blueprint bash .claude/hooks/role-watch.sh tg",    run_in_background=true)  # 只 blueprint
#
# ★誠實限：
#   ①本支【不改】內層三支的語意（lock／換血／SEEN／baseline 都是它們的）。
#   ②★★內層自己死掉（不是因為事件）⇒ 本支會印一行【⛔】並結束 —— 那是要人看的，不靜默重啟。
#   ③★★★「永久」的界線是【這個 session】：session 結束它就沒了。沒有跨 session 的常駐。
set -u
KIND="${1:-inbox}"
_gc="$(git rev-parse --git-common-dir 2>/dev/null || echo .git)"
ROOT="$(cd "$(dirname "$_gc")" && pwd)"
cd "$ROOT" || exit 2
ROLE="${SESSION_ROLE:-unknown}"
HOOKD="$ROOT/.claude/hooks"
LOG="$HOOKD/.role-watch.${ROLE}.${KIND}.log"
: > "$LOG" 2>/dev/null || true
_ts() { date +%FT%T; }

case "$KIND" in
  inbox)    INNER=(bash "$HOOKD/inbox-watch.sh") ;;
  watchdog) INNER=(bash "$HOOKD/watchdog.sh") ;;
  tg)       INNER=(bash -c "source \"$ROOT/tools/telegram/config.local.sh\" && python \"$ROOT/tools/telegram/tg_poll.py\"") ;;
  *) echo "⛔ role-watch：不認得的 kind='$KIND'（只收 inbox／watchdog／tg）"; exit 2 ;;
esac

echo "[role-watch $(_ts)] start kind=$KIND role=$ROLE pid=$$" >> "$LOG"
exec 3< <("${INNER[@]}" 2>>"$LOG")
CHILD=$!
trap 'kill "$CHILD" 2>/dev/null; exec 3<&- 2>/dev/null' EXIT

while IFS= read -r line <&3; do
  case "$line" in
    "["*)
      # 狀態噪音：ARMED／換血／讓位／普查／CLEAN ⇒ 只進 log
      echo "[role-watch $(_ts)] (quiet) $line" >> "$LOG"
      ;;
    "")
      : ;;
    *)
      # ★事件：印出來並結束 ⇒ 背景任務結束 ⇒ session 被喚醒
      printf '%s\n' "$line"
      echo "[role-watch $(_ts)] EVENT ⇒ exit：$line" >> "$LOG"
      exit 0
      ;;
  esac
done

echo "[role-watch $(_ts)] child ended without an event" >> "$LOG"
echo "⛔ role-watch[$KIND]：內層自己結束了（不是因為事件）⇒ ★看 ${LOG#$ROOT/} 再決定要不要重掛"
exit 1
