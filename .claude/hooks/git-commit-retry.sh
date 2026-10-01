#!/usr/bin/env bash
# ★共用的 commit 退避重試包裝（blueprint 派 2026-09-22，systems 實作）
#
# ★★★為什麼需要它：六個 session 共用一個 main dir、每人 pathspec commit
#   ⇒ `.git/index.lock` 爭用是【常態成本】不是偶發：2026-09-22 一天三顆孤兒鎖
#     （21:29 size=0／22:47 size=1.5MB／22:51 size=0）。
#
# ★★而【手寫重試迴圈】今天已經造成一次真實傷害：implementer 用 `for i in 1 2 3` 重試、
#   第三次成功、★而卷面上沒有任何一個字提到它曾經失敗
#   ⇒ 一次真實的阻斷在紀錄上變成「一切正常」，
#   ⇒ ★★★而在另一頭，systems 差點把那段安靜讀成「他停工了」。
#   ⇒ 所以本包裝的硬規矩是：**重試要留痕**。成功了也要印「第 N 次才成功」。
#
# ★三種結果給三種離開碼（環境失敗不可以跟測試失敗混在一起）：
#   0  = commit 成功（★若重試過，stderr 會印「第 N 次才成功」）
#   3  = ★被鎖擋到放棄（環境問題，不是你的 commit 有問題）—— 呼叫端該報「被鎖擋」
#   其他 = git 自己的 rc 原樣回傳（hook 擋下、沒東西可 commit、訊息檔不存在…）
#         ★這一類【不重試】：重試一個會穩定失敗的東西只是把時間燒掉。
#
# 用法（引數原樣轉給 git commit）：
#   bash .claude/hooks/git-commit-retry.sh -F msg.txt -- path1 path2
#
# 環境變數：GCR_TRIES（預設 5）／GCR_MIN_S（預設 5）／GCR_MAX_S（預設 10）
set -u
TRIES="${GCR_TRIES:-5}"; MIN_S="${GCR_MIN_S:-5}"; MAX_S="${GCR_MAX_S:-10}"
_tmp="$(mktemp 2>/dev/null || echo "/tmp/gcr.$$")"
_attempt=0
while :; do
  _attempt=$((_attempt+1))
  git commit "$@" > "$_tmp" 2>&1
  _rc=$?
  if [ "$_rc" -eq 0 ]; then
    cat "$_tmp"
    if [ "$_attempt" -gt 1 ]; then
      # ★★★這一行是本包裝存在的理由：不印它，阻斷就會在卷面上消失
      echo "[gcr] ★第 ${_attempt} 次才成功（前 $((_attempt-1)) 次被 .git/index.lock 擋住）" >&2
    fi
    # ★★★★★2026-10-01（systems，藍圖提、我 owner 這支）：**commit 成功之後，把「要敲誰」印在眼前**
    #   ★病（今天第三次）：信**落地了**（寫檔＋commit）而**沒敲門** ⇒ 鏈空轉一小時
    #     —— 而「寄信＝寫檔＋commit＋敲門」三件缺一＝沒送到，★而第三件 shell 做不到（要我呼 SendMessage）
    #   ⇒ ★★所以這裡不做「自動敲」，只做**把那份名單變成會出現在眼前的輸出** ——
    #     ★★★而這正是我今天立過的那條：**不要靠「我會記得」，要讓它出現在我面前**。
    #   ★誠實限：它只認【這一次 commit 裡的】handback 檔；更早落地而沒敲的它看不到。
    for _f in "$@"; do
      case "$_f" in
        *docs/superpowers/handbacks/*.md)
          [ -f "$_f" ] || continue
          grep -q '^status: open' "$_f" 2>/dev/null || continue
          _to=$(sed -n 's/^to: *//p' "$_f" | head -1)
          [ -n "$_to" ] || continue
          [ "$_to" = "${SESSION_ROLE:-systems}" ] && continue
          _raw=$(bash "$(dirname "$0")/peers.sh" 2>/dev/null | awk -v r="$_to" '$1==r{print $3}' | head -1)
          # ★`peers.sh` 的 ADDR 欄會帶一個 `?`（它標「這個位址是推測的」）——
          #   ⇒ ★★剝掉它才敲得到；而**不要靜默剝**：剝了就要說它本來帶問號
          #     （否則我會把一個推測的位址當成確定的用）
          _addr=$(printf '%s' "$_raw" | sed 's/[^A-Za-z0-9_-]//g')
          _note=""
          [ "$_raw" != "$_addr" ] && _note="（★原本是 ${_raw} —— ADDR 推測，敲不到就跑 ListAgents）"
          echo "[gcr] ★要敲：${_to}=${_addr:-（peers.sh 查不到 ADDR）}${_note}　←　$(basename "$_f")" >&2
          ;;
      esac
    done
    rm -f "$_tmp"; exit 0
  fi
  # ★只對【鎖】重試。其餘 rc 原樣回傳,不重試。
  if ! grep -qE "index\.lock|Unable to create .*\.lock|File exists" "$_tmp"; then
    cat "$_tmp"
    rm -f "$_tmp"; exit "$_rc"
  fi
  if [ "$_attempt" -ge "$TRIES" ]; then
    cat "$_tmp"
    echo "[gcr] ★★被 .git/index.lock 擋了 ${TRIES} 次，放棄（離開碼 3 ＝【環境】不是你的 commit 有問題）" >&2
    echo "[gcr]   ⇒ 先跑 .claude/hooks/stale-lock-check.sh；判成孤兒才具名移除，★不要盲刪" >&2
    echo "[gcr]   ⇒ ★★而且要【講出來】：別人可能正把你這段安靜讀成你停工了" >&2
    rm -f "$_tmp"; exit 3
  fi
  _wait=$(( MIN_S + (RANDOM % (MAX_S - MIN_S + 1)) ))
  echo "[gcr] 第 ${_attempt} 次撞到 .git/index.lock ⇒ 等 ${_wait}s 再試（上限 ${TRIES} 次）" >&2
  sleep "$_wait"
done
