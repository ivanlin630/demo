#!/usr/bin/env bash
# Stop hook：implementer 收尾強制 nag。
# 01 判 task 完成 → 寫 to:implementer 且 topic 含 [DONE] 的信 → 本 hook 在 implementer turn 結束時
# 偵測到 → decision:block 逼 agent 做收尾(consume/cd 回主目錄/提醒用戶 /clear/重 arm)，忘不了。
# [REDO] 信不 nag（implementer 還 warm 直接改）。只對 implementer。防 loop：stop_hook_active。
# ★/clear 本身是用戶鍵入(agent/hook 不能自 issue)——hook 只提醒 agent 去提醒用戶。
set -u
case "${SESSION_ROLE:-}" in implementer|實作) ;; *) exit 0 ;; esac

IN=$(cat 2>/dev/null || echo '{}')
# 防 stop-hook 無限迴圈
active=$(printf '%s' "$IN" | python -c "import sys,json
try: print(json.load(sys.stdin).get('stop_hook_active',False))
except: print(False)" 2>/dev/null)
[ "$active" = "True" ] && exit 0

_MAIN="$(dirname "$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" 2>/dev/null)"
D="${_MAIN:-.}/docs/superpowers/handbacks"
[ -d "$D" ] || exit 0

# 找 to:implementer && status:open && topic 含 [DONE]
hit=$(awk '
  FNR==1{f=FILENAME}
  FNR<=10{
    l=tolower($0)
    if(l~"^to:[ \t]*implementer([ \t]|$)") to[f]=1
    if(l~"^status:[ \t]*open([ \t]|$)") st[f]=1
    if($0~/^[Tt]opic:.*\[DONE\]/) dn[f]=1
  }
  END{for(x in to) if(st[x]&&dn[x]){print x; break}}
' "$D"/*.md 2>/dev/null)
[ -z "$hit" ] && exit 0

bn=$(basename "$hit")

# ★worktree 自動拆（用戶拍板 2026-08-21，刀3；56GB 血案根治）
#   [DONE] ＝ 這條 slice 的活結束了 ⇒ 它的 worktree 不該繼續佔著磁碟。
#   ★機械驗：從該信的 slice: 欄推 worktree 路徑，還在就把「拆」寫進 nag（不自動刪——
#   刪東西要人看一眼，而且 worktree 裡可能還有沒 commit 的東西）。
_slice=$(head -12 "$hit" 2>/dev/null | grep -iE "^slice:" | head -1 | sed -e "s/^[Ss]lice:[[:space:]]*//" -e "s/[[:space:]]*<!--.*//" | tr -d " ")
_wt_msg=""
if [ -n "$_slice" ] && [ -d "${_MAIN}/.worktrees/${_slice}" ]; then
  _dirty=$(git -C "${_MAIN}/.worktrees/${_slice}" status --porcelain 2>/dev/null | head -3)
  if [ -n "$_dirty" ]; then
    _wt_msg=" ④★worktree .worktrees/${_slice} 還在【而且有未 commit 的東西】——先確認那些改動要不要留（別直接拆），處理完再 git worktree remove。"
  else
    _wt_msg=" ④★拆掉本 slice 的 worktree：git worktree remove .worktrees/${_slice}（乾淨、可安全拆；不拆會累積成磁碟黑洞——56GB 血案）。"
  fi
fi

MSG="★01 判 [DONE]（${bn}）→ 收尾 lifecycle（03_implementer §5）：①把該信 status:consumed ②cd 回主目錄 ${_MAIN} 確認在 main ③重 arm inbox-watch 待命下一 task。${_wt_msg}（ctx 不用手動清——滿了會自動 compact 並重載職責。）做完這幾步再結束。"
python -c "import json,sys; print(json.dumps({'decision':'block','reason':sys.argv[1]}))" "$MSG"
