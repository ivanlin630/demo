#!/usr/bin/env bash
# role-watch.sh —— ★★★取代 Monitor 掛 inbox-watch 的那個用法（systems 立 2026-09-23，用戶裁）。
#
# ★用戶原話：「如果這東西不能用了 就找別的工具 我不要一直重掛」
#   ⇒ Monitor 這一版【30 分鐘硬到期】（實測：timeout_ms 最大只收 3600000，
#     而即使傳 3600000，它仍回「expires in 30m」⇒ ★那個上限不是那個參數決定的、我拿不到更長的）
#   ⇒ ★★所以不是把重掛做得更漂亮，是【換一個不會到期的機制】。
#
# ★★機制：背景 Bash 任務【結束時】會把 session 叫醒（且不受 timeout 參數綁 ——
#   實測同日一支 timeout=900000 的背景電池跑了 1225 秒）。
#   ⇒ 本支的形狀是：**沒事就一直等（不輸出、不結束）；一有【可行動事件】就印出來並結束**。
#   ⇒ ★★★於是「喚醒」與「重掛」合併成同一個動作：我被叫醒、處理完、再掛一次 —— 而那一次
#     本來就是我要做的事。沒有「每 30 分鐘一次的空重掛」。
#
# ★★★噪音（blueprint 同日要求，票：monitor-token-cost）：
#   stdout 只放【可行動】的：📬 收信／🟡🔴 停滯／📱 Telegram／⛔ 真錯誤
#   ARMED／讓位／普查／CLEAN 一律進 log，不進 stdout ——
#   ★理由：每一行 stdout 都是一個 turn；六個角色 × 每半小時數行 ＝ 原本要省的 token 被工具雜訊吃掉。
#
# 用法（角色 session 開場一次）：
#   Bash(command="bash .claude/hooks/role-watch.sh", run_in_background=true)
#   ⇒ 它結束時你會被叫醒，stdout 就是那件事；處理完【再掛一次】。
#
# ★誠實限：
#   ①本支【不改】inbox-watch.sh 的語意（lock／換血／SEEN 都是它的）——
#     它只是把它當子行程跑，並在第一個可行動事件出現時把它收掉。
#   ②★★所以「同角色只留最新一支」這件事仍然由 inbox-watch 的換血負責，本支不另外判。
#   ③★★★若 inbox-watch 自己死了（不是因為事件），本支也會結束並在 stdout 說明 ——
#     那是【要人看的】，不是靜默重啟。
set -u
_gc="$(git rev-parse --git-common-dir 2>/dev/null || echo .git)"
ROOT="$(cd "$(dirname "$_gc")" && pwd)"
cd "$ROOT" || exit 2
ROLE="${SESSION_ROLE:-unknown}"
LOG="$ROOT/.claude/hooks/.role-watch.${ROLE}.log"
: > "$LOG" 2>/dev/null || true

_ts() { date +%FT%T; }
echo "[role-watch $(_ts)] start role=$ROLE pid=$$" >> "$LOG"

# 子行程：inbox-watch（它自己做 lock／換血／SEEN）
exec 3< <(bash "$ROOT/.claude/hooks/inbox-watch.sh" 2>>"$LOG")
CHILD=$!
trap 'kill "$CHILD" 2>/dev/null; exec 3<&-' EXIT

while IFS= read -r line <&3; do
  case "$line" in
    *📬*|*🟡*|*🔴*|*📱*)
      # ★可行動：印出來並結束 ⇒ 背景任務結束 ⇒ session 被叫醒
      printf '%s\n' "$line"
      echo "[role-watch $(_ts)] actionable ⇒ exit：$line" >> "$LOG"
      exit 0
      ;;
    *⛔*)
      case "$line" in
        *讓位*)
          # ★讓位＝有更新的同角色 watcher 接手 ⇒ 這是【正常換血】不是事件
          echo "[role-watch $(_ts)] 讓位（正常換血，不喚醒）：$line" >> "$LOG"
          exit 0
          ;;
        *)
          printf '%s\n' "$line"
          echo "[role-watch $(_ts)] error ⇒ exit：$line" >> "$LOG"
          exit 0
          ;;
      esac
      ;;
    *)
      # ARMED／普查／CLEAN／其餘一律進 log
      echo "[role-watch $(_ts)] (quiet) $line" >> "$LOG"
      ;;
  esac
done

# 走到這裡 ＝ 子行程自己結束了，而不是因為事件
echo "[role-watch $(_ts)] child ended without an actionable event" >> "$LOG"
echo "⛔ role-watch：inbox-watch 自己結束了（不是因為收信）⇒ ★看 ${LOG#$ROOT/} 再決定要不要重掛"
exit 1
