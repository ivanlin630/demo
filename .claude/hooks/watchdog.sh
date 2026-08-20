#!/usr/bin/env bash
# 5h watchdog v3 — 活動信號三合一(status.md + handbacks + git HEAD)連續 N 小時全無變化 → emit STALL。
# v2 病:只盯 status/*.status.md,但角色實際活動走 handback+commit,status 只大節點更新 → 假響不停。
# v3:任一信號動 = 活著。fire 時附「最後活動距今」供判斷。fire 後重置。
# 響了查現況:先看「在等誰」(open handback 收件者/用戶裁),等用戶裁=真stall要催。
set -u
STALL_H="${WATCHDOG_STALL_H:-5}"
POLL_S="${WATCHDOG_POLL_S:-300}"
_MAIN_REPO="$(dirname "$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" 2>/dev/null)"
ROOT="${_MAIN_REPO:-.}"
STATUS_DIR="$ROOT/docs/process/status"
HB_DIR="$ROOT/docs/superpowers/handbacks"

# 三合一活動快照:status 內容 + handback 檔名/mtime 列表 + 全 ref 最新 commit
snapshot() {
  {
    cat "$STATUS_DIR"/*.status.md 2>/dev/null
    ls -l --time-style=+%s "$HB_DIR"/*.md 2>/dev/null
    git -C "$ROOT" for-each-ref --sort=-committerdate --count=5 --format='%(objectname)' 2>/dev/null
  } | md5sum | cut -d' ' -f1
}

[ -d "$STATUS_DIR" ] || { echo "[watchdog] 無 $STATUS_DIR → 不啟動"; exit 0; }

# ★單例守衛:lock 心跳新鮮(<POLL+120s)=已有實例 → 退出。迴圈 touch 刷心跳。
LOCK="$ROOT/.claude/hooks/.watchdog.lock"
STALE=$(( POLL_S + 120 ))
if [ -f "$LOCK" ]; then
  age=$(( $(date +%s) - $(stat -c %Y "$LOCK" 2>/dev/null || echo 0) ))
  [ "$age" -lt "$STALE" ] && { echo "[watchdog] 已有實例在跑 → 退出(免重複)"; exit 0; }
fi
echo $$ > "$LOCK"
echo "[watchdog v3] 監看 status+handbacks+git 三合一（全靜 ${STALL_H}h 才喚醒；每 ${POLL_S}s 快照）"

last_hash="$(snapshot)"
last_change=$(date +%s)
while true; do
  touch "$LOCK" 2>/dev/null
  sleep "$POLL_S"
  h="$(snapshot)"
  now=$(date +%s)
  if [ "$h" != "$last_hash" ]; then
    last_hash="$h"; last_change=$now; continue
  fi
  elapsed_h=$(( (now - last_change) / 3600 ))
  if [ "$elapsed_h" -ge "$STALL_H" ]; then
    echo "[watchdog v3] STALL: status+handbacks+git 全靜 ${elapsed_h}h — 查在等誰(open信收件者/用戶裁);等用戶裁=真stall要催"
    last_change=$now
  fi
done
