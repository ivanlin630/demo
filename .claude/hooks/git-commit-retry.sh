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
