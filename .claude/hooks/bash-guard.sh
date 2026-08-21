#!/usr/bin/env bash
# bash-guard.sh — PreToolUse(Bash|PowerShell) 兩道 warn-only 護欄（用戶拍板 2026-08-21，刀2）。
#
# ★★兩條紀律不可妥協（同每 turn 閘）：**只警告、絕不阻擋**；**fail-open**（讀不到就放行，不因讀不到而擋）。
#   閘門自己有 bug 就 brick 六個 session——今天已經因為這個理由把每 turn 閘寫成 warn-only。
#
# 護欄①：`git add -A` / `git add .` —— 共用 main working tree 禁全量 add。
#   血證 memory feedback_concurrent_session_wip_sweep / feedback_windows_git_merge_lock 的 commit 衛生段：
#   main dir 是多角色共用，全量 add 會把【別角色未 commit 的活】掃進我的 commit（provenance 錯亂）。
#   今日實證：implementer 建 worktree 時把 measurer 未 commit 的 temp tap 一起複製走並 commit。
#
# 護欄②：起 Godot 長跑前，若存在【別人的】busy beacon → 提醒不要起（兼職互斥）。
#   理由：長跑吃滿 CPU，兩個角色同時起 Godot 會互相拖慢並污染 perf 量測。
#   ★beacon 只壓警報不造警報的紀律不變——這裡是【提醒人別起】，不是自動擋。
set -u
_in=$(cat 2>/dev/null || echo "")
_cmd=$(printf '%s' "$_in" | grep -oE '"command"[[:space:]]*:[[:space:]]*"([^"\]|\.)*"' | head -1)
[ -z "$_cmd" ] && exit 0        # fail-open：撈不到指令就放行

_warn=""

# ① 全量 add
if printf '%s' "$_cmd" | grep -qE 'git[[:space:]]+add[[:space:]]+(-A|--all|\.)([[:space:]]|\\"|$)'; then
  _warn="⚠ 偵測到 git add -A / git add . —— ★共用 main working tree 禁全量 add：會把【別角色未 commit 的活】掃進你的 commit（provenance 錯亂，今日已實證一次）。請改成逐一列出你這輪真改的檔。"
fi

# ② 起 Godot 但別人的 beacon 還在
if printf '%s' "$_cmd" | grep -qiE 'godot(\.ps1|-detach)?|--headless'; then
  _me="${SESSION_ROLE:-}"
  _hookd="$(dirname "${BASH_SOURCE[0]}")"
  shopt -s nullglob
  _others=""
  for f in "$_hookd"/.busy.*; do
    r="${f##*/.busy.}"
    [ "$r" = "$_me" ] && continue
    dl=$(cat "$f" 2>/dev/null || echo 0)
    case "$dl" in (*[!0-9]*|'') dl=0 ;; esac
    [ "$dl" -gt "$(date +%s)" ] && _others="${_others} ${r}"
  done
  if [ -n "$_others" ]; then
    _warn="${_warn}${_warn:+
}⚠ 偵測到要起 Godot，但【${_others# } 的 busy beacon 還在】—— 長跑吃滿 CPU，兩個角色同時跑會互相拖慢並污染 perf 量測。建議等對方跑完，或先問 blueprint 誰優先。"
  fi
fi

[ -z "$_warn" ] && exit 0

json_str() {
  printf '%s' "$1" | awk '
BEGIN { ORS=""; printf "\"" }
  { gsub(/\\/, "\\\\"); gsub(/"/, "\\\""); if (NR > 1) printf "\\n"; printf "%s", $0 }
  END { printf "\"" }
  '
}
printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":%s}}' "$(json_str "$_warn")"
exit 0
