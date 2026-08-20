#!/usr/bin/env bash
# merge-verify.sh — 空 merge 偵測器（2026-08-21 立，實戰事故產出）。
#
# 病：Windows 上 git merge 會瞬鎖 index —— 半途 `MERGE_HEAD` 存在但【沒有任何 staged】，
#     此時 commit 出來的是一個【空 merge】：把 branch 記成「已合併」，但【一行改動都沒帶進來】。
# ★後果比丟改動更陰險：git 從此認為那條 branch 已 merged ⇒ 之後再 `git merge` 只會說 nothing to do，
#   而 code 根本不在樹上。症狀是「功能莫名其妙不見了」，而 log 看起來完全正常。
# 血證：4bdce7c1 把 feat/specimen-lineage-scope 記成已合併，但 HEAD 裡連 parent_team_id 都找不到。
#
# 判準：對每個 merge commit，若「相對第一父完全沒有變化」而第二父有內容 → 空 merge。
#
# 用法：
#   bash .claude/hooks/merge-verify.sh          # 掃最近 N 個 merge（預設 30）
#   bash .claude/hooks/merge-verify.sh <sha>    # 只驗一個
#   MERGE_SCAN_N=100 bash .claude/hooks/merge-verify.sh
# exit: 0=乾淨 / 1=發現空 merge
set -u
N="${MERGE_SCAN_N:-30}"
_MAIN="$(dirname "$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" 2>/dev/null)"
cd "${_MAIN:-.}" || exit 1

# 判準（★第一版判錯過，記在這裡）：不能問「這個 merge 整體有沒有變化」——
#   血證 4bdce7c1 同時帶了別的檔，整體【有】變化，只是【把 branch 的改動丟了】，所以整體判準抓不到。
#   要逐檔問：「branch 改過的每個檔，在 merge 結果裡拿的是誰的版本？」
check_one() {
  local sha="$1"
  git rev-parse -q --verify "${sha}^2" >/dev/null 2>&1 || return 0   # 非 merge
  local base; base=$(git merge-base "${sha}^1" "${sha}^2" 2>/dev/null) || return 0
  local total=0 dropped=0 list=""
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    total=$((total+1))
    local m p1 p2
    m=$(git rev-parse -q "${sha}:${f}" 2>/dev/null || echo "")
    p1=$(git rev-parse -q "${sha}^1:${f}" 2>/dev/null || echo "")
    p2=$(git rev-parse -q "${sha}^2:${f}" 2>/dev/null || echo "")
    # branch 版本沒被採用，而且結果等於第一父（或檔案根本不在）＝ branch 這個檔的改動被丟了
    if [ "$m" != "$p2" ] && { [ "$m" = "$p1" ] || [ -z "$m" ]; }; then
      dropped=$((dropped+1)); list="${list}
     - ${f}"
    fi
  done < <(git diff --name-only "$base" "${sha}^2" 2>/dev/null)

  [ "$total" -eq 0 ] && return 0
  [ "$dropped" -eq 0 ] && return 0
  if [ "$dropped" -eq "$total" ]; then
    echo "🔴 空 merge：$(git log -1 --format=%h%x20%s "$sha")"
    echo "   branch 改了 ${total} 個檔，merge 結果【一個都沒採用】＝改動全丟。"
  else
    echo "🟡 部分丟失：$(git log -1 --format=%h%x20%s "$sha")"
    echo "   branch 改了 ${total} 個檔，其中 ${dropped} 個在 merge 結果裡沒被採用。"
  fi
  echo "   被丟的檔：${list}"
  echo "   ★git 從此認為那條 branch 已 merged ⇒ 重跑 git merge 會說 nothing to do，而 code 不在樹上。"
  echo "   修法：從 branch 補一個新 commit（別重寫 history），逐檔 md5 對過再 commit。"
  echo "   （少數情況是刻意解衝突時保留 main 版本——那就在 merge 訊息裡寫明，別讓它看起來像事故。）"
  return 1
}

rc=0
if [ "$#" -gt 0 ]; then
  check_one "$1" || rc=1
else
  scanned=0
  while IFS= read -r sha; do
    scanned=$((scanned+1))
    check_one "$sha" || rc=1
  done < <(git log --merges --format=%H -n "$N")
  echo "[merge-verify] 掃了 ${scanned} 個 merge commit（最近 ${N}）"
fi
[ "$rc" -eq 0 ] && echo "✅ 無空 merge"
exit "$rc"
