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
    # 2026-09-06：beacon 契約從【檔內存一個 deadline epoch】改成【心跳 mtime】。
    #   ★改的理由不是形式：舊契約要人手寫，而稽核發現【一個 beacon 都沒被寫過】
    #     ⇒ 母體恆空 ⇒ 這道護欄從上線到現在【一次都沒響過】，而它防的事當天正在發生。
    #   ★★改成 godot.ps1 wrapper 自己蓋章＋每 10s 續期後，反向的壞處要一起擋掉：
    #     wrapper 被 kill ⇒ 清理不會跑 ⇒ 屍體 beacon 永久留著 ⇒ 從【永遠不響】變【永遠亂響】。
    #     ★★★而「清理」正好是被 kill 時唯一不會執行的東西 ⇒ 所以用【會自己過期】的心跳，
    #        不用「結束時刪掉」。60s 沒續期＝那個跑已經死了＝視同不存在。
    if [ -n "$(find "$f" -mmin -1 2>/dev/null)" ]; then _others="${_others} ${r}"; fi
  done
  if [ -n "$_others" ]; then
    _warn="${_warn}${_warn:+
}⚠ 偵測到要起 Godot，但【${_others# } 的 busy beacon 還在】—— 長跑吃滿 CPU，兩個角色同時跑會互相拖慢並污染 perf 量測。建議等對方跑完，或先問 blueprint 誰優先。"
  fi
fi


# 護欄③：殘留 index.lock（2026-09-06，同日兩次）
#   ★git 的錯誤訊息說「另一個 git process 在跑」——★★而實測兩次都【沒有任何 git process】：
#     0 bytes、放了 4~5 分鐘。多半是某個 git 被 timeout/kill 掉,鎖沒清。
#   ★★★而那句訊息會讓人去找一個【不存在的東西】,或去等一個【不會結束的東西】。
#   ⇒ 這裡只【說出診斷】,★不自動刪 —— 刪鎖是破壞性動作,而破壞性動作要人按。
if printf '%s' "$_cmd" | grep -qE 'git[[:space:]]+(commit|add|merge|rebase|mv)'; then
  _lk=".git/index.lock"
  if [ -f "$_lk" ]; then
    _age=$(( $(date +%s) - $(stat -c %Y "$_lk" 2>/dev/null || echo 0) ))
    _sz=$(stat -c %s "$_lk" 2>/dev/null || echo 1)
    if [ "$_age" -gt 120 ] && [ "$_sz" -eq 0 ]; then
      _warn="${_warn}${_warn:+
}⚠ .git/index.lock 是【0 bytes 且已放了 ${_age} 秒】—— ★這多半是【殘留鎖】不是「另一個 git 在跑」。★★git 的錯誤訊息會叫你去找一個不存在的 process。★★★先驗:powershell -NoProfile -Command \"Get-CimInstance Win32_Process | Where-Object { \$_.Name -eq 'git.exe' }\" —— 真的沒有 git.exe 才 rm -f .git/index.lock（★共用 main dir,不要沒驗就刪）。"
    fi
  fi
fi


# 護欄④：`git commit -m "..."` 訊息裡有反引號（2026-09-07，同日第三次）
#   ★雙引號裡的反引號會被 bash 當【命令替換】⇒ 那段文字【從訊息裡消失】,
#     而 commit 仍然成功 ⇒ ★★「訊息寫好了」與「訊息被吃掉一段」在卷面上分不出來
#     (今天三次:兩次吃掉整個片語、一次噴 "No such file or directory" 但 commit 照樣成立)
#   ★★★修法不是「記得別用反引號」——那已經被證偽三次了 ——
#     而是【改用 quoted heredoc】:`git commit -F - <<'MSG' ... MSG`(單引號界定符=零展開)
if printf '%s' "$_cmd" | grep -qE 'git[[:space:]]+commit' && printf '%s' "$_cmd" | grep -q '`'; then
  _warn="${_warn}${_warn:+
}⚠ commit 訊息裡有【反引號】—— ★雙引號中的反引號會被當成命令替換,那段文字會【從訊息裡消失】而 commit 仍然成功（今天已發生三次）。★★改用 quoted heredoc（git commit -F - 搭配單引號界定符 ＝ 零展開），或把反引號換成「」。"
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
