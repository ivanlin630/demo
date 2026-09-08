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


# 護欄③：殘留 index.lock（2026-09-06 兩次；★2026-09-07 改成【永遠說話】）
#   ★git 的錯誤訊息說「另一個 git process 在跑」——★★而實測三次都【沒有任何 git process】。
#   ★★★2026-09-07 缺口：舊版只在【鎖 >120 秒】才說話 ⇒ 鎖還年輕時它完全沉默，
#     而人就直接撞上原始錯誤訊息，★那訊息裡沒有處置程序 ⇒ 有人以為要去找用戶。
#   ⇒ 改成【只要鎖存在就說話】，但依年齡說【不同的話】。★仍然不自動刪：刪鎖是破壞性動作。
if printf '%s' "$_cmd" | grep -qE 'git[[:space:]]+(commit|add|merge|rebase|mv)'; then
  _lk=".git/index.lock"
  if [ -f "$_lk" ]; then
    _age=$(( $(date +%s) - $(stat -c %Y "$_lk" 2>/dev/null || echo 0) ))
    _sz=$(stat -c %s "$_lk" 2>/dev/null || echo 1)
    if [ "$_sz" -ne 0 ]; then
      _warn="${_warn}${_warn:+
}⚠ .git/index.lock 存在且【非 0 bytes】(${_sz}B, ${_age}s) —— ★這可能是【寫到一半的 index】，★★不要刪它，等或找人。"
    elif [ "$_age" -le 120 ] && [ "$_sz" -eq 0 ]; then
      _warn="${_warn}${_warn:+
}⚠ .git/index.lock 是 0 bytes 但【只放了 ${_age} 秒】—— ★可能真的有人正在 commit，先等 1-2 分鐘再試。★★若超過 120 秒仍在，本護欄會給你處置程序。"
    else
      _warn="${_warn}${_warn:+
}⚠ .git/index.lock【0 bytes 且已放了 ${_age} 秒】= ★可證的孤兒鎖候選（不是「另一個 git 在跑」）。
   ★★處置程序（三驗全過才刪，缺一不可 —— implementer 2026-09-07 實證）：
     ① git 程序數必須是 0：powershell -NoProfile -Command \"@(Get-CimInstance Win32_Process | Where-Object { \\$_.Name -match '^git' }).Count\"
        ★沒有這一格，刪鎖＝把別人正在寫的 index 砍掉
     ② 檔案大小 = 0 bytes（有內容的 lock 要另外處理，★不可刪）
     ③ 已經數分鐘沒有變動
   ⇒ 三驗全過 ⇒ rm -f .git/index.lock
   ★★★而「我做不到」有兩種：【權限不足】與【這個 session 的工具受限】——★兩者長得一樣。
     ⇒ 別替別人宣告做不到；★誰能做用【試】的，不要用【猜】的（血證 2026-09-07：
       systems 說「沒有權限」，implementer 同機同帳號一試就刪掉了）。"
    fi
  fi
fi



# 護欄⑤：寫廣播信（2026-09-07，blueprint 提；★而閘早就有了，缺的是【時機】）
#   ★`.claude/hooks/mailbox-broadcast-gate.sh` 已經會擋「to: all 且還開著」的信，
#     ★★但它只在【merge 時】跑 ⇒ 一封卡死的廣播會躺到有人跑閘為止。
#   ★★★真正的根因修不掉：一封廣播【只有一個 status 欄位】⇒ 第一個 consume 的人
#     讓其他所有人再也收不到（inbox-watch 要求 status: open）。
#   ⇒ 所以正解是【一人一封】，而這裡在【寫的當下】就講，不是等 merge。
if printf '%s' "$_cmd" | grep -qE '^to:[[:space:]]*all|to:[[:space:]]*all[[:space:]]*\(|to: all'; then
  _warn="${_warn}${_warn:+
}⚠ 你正在寫【to: all】的廣播信 —— ★一封廣播只有【一個 status 欄位】：第一個 consume 它的角色，
   會讓其他所有人【再也收不到】（inbox-watch 只叫醒 status: open 的）。
   ⇒ ★★正解＝【一人一封】（同內容分別寄給每個收件者），★★★而不是靠對方自律不要提早 consume。
   ⇒ 若確實要廣播（例如純公告、不需要每個人動作）⇒ 可以，但★請預期只有一個人會被叫醒。"
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
