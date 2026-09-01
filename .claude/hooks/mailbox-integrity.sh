#!/usr/bin/env bash
# ★★★信箱完整性閘 —— 防的是【靜默】的兩種失效，而它們都不會留下「沒收到」的痕跡。
#
# ★病（2026-09-01 血證）：
#   ①★consume 標記被別 session 的 commit 掃入 → 那顆 commit 被 revert → 標記【跟著回退】
#      ⇒ 信變回 open ⇒ 幽靈喚醒（blueprint 側實測同一封 ≥5 次）
#   ②★★整封信被 revert【刪掉】⇒ 收件人【從來沒收到】
#      ⇒ ★★★而這一類完全看不見：沒收到的信不會留下痕跡，只有翻 git 歷史才撈得到
#
# ★★為什麼要做成閘而不是紀律：
#   ★「commit 之前先看掃了誰」是【對的紀律】，而執行它的人與受害的人不是同一個
#   ⇒ ★★受害者沒有管道發現，加害者沒有動機檢查 ⇒ ★★★只有機械檢查會發現
#
# 用法：bash tools/gates/mailbox-integrity.sh [ref] [window]
#   ref    ＝ 掃到哪個 commit 為止（預設 HEAD）★可指定舊 ref 當【陽性對照】
#   window ＝ 往回掃幾顆 commit（預設 300）
set -u
REF="${1:-HEAD}"
WIN="${2:-300}"
MB="docs/superpowers/handbacks"
fail=0

echo "=== 信箱完整性閘｜ref=$REF 窗=$WIN 顆 commit｜母體=$MB｜比對面=整個 repo 樹（封存在 docs/superpowers/archive/handbacks/，不在 $MB 底下）==="

# ── ①consumed → open 的【回退】────────────────────────────────────────────
# ★判準：同一個 hunk 裡 `-status: consumed` 緊接 `+status: open`
#   ★★而【現在仍是 open】才算未結案（事後有人重新 consume ⇒ 自動清掉，不留假警報）
rev_hits=$(git log -n "$WIN" --format='@@C %h %s' -p -U0 "$REF" -- "$MB" 2>/dev/null | awk '
/^@@C/       { c=$0 }
/^\+\+\+ b\// { f=substr($0,7) }
/^-status: consumed/ { p=1; next }
/^\+status: open/    { if(p){ print f "\t" c } p=0; next }
                     { if($0 !~ /^[-+]/) p=0 }
')
rev_open=""
if [ -n "$rev_hits" ]; then
  while IFS=$'\t' read -r f c; do
    [ -z "$f" ] && continue
    cur=$(git show "$REF:$f" 2>/dev/null | grep -m1 '^status:' | tr -d '\r')
    case "$cur" in
      *open*) rev_open="${rev_open}   ★ $f  ←  $c"$'\n' ;;
    esac
  done <<< "$rev_hits"
fi
n_rev=$(printf '%s' "$rev_hits" | grep -c . || true)
if [ -n "$rev_open" ]; then
  echo "[MAILBOX-GATE] ★FAIL：consumed→open 的回退，★★且【現在仍是 open】⇒ 收件人會被幽靈喚醒"
  printf '%s' "$rev_open"
  fail=1
else
  echo "[MAILBOX-GATE] ①回退：窗內 $n_rev 次 consumed→open，★現在【都不是 open】⇒ 已結案"
fi

# ── ②被刪掉的信（★★最嚴重：收件人從來沒收到）──────────────────────────
# ★「刪除」的絕大多數是【封存搬家】（handbacks/ → docs/superpowers/archive/handbacks/）
#   ⇒ ★★所以判準【不能】只看 $MB：要看【整個 repo 樹】還有沒有同檔名
#   ⇒ ★★★第一版我只查 $MB ⇒ 一次噴 200+ 假陽性（封存全被當成失蹤）——
#     而那正是「搜尋樣式從不宣告自己漏了什麼」的反面：它宣告了它【多抓】了什麼。
ALL_BASENAMES="$(mktemp)"
git ls-tree -r --name-only "$REF" 2>/dev/null | awk -F/ '{print $NF}' | sort -u > "$ALL_BASENAMES"
del=$(git log -n "$WIN" -M --diff-filter=D --format='@@C %h %s' --name-only "$REF" -- "$MB" 2>/dev/null | awk '
/^@@C/ { c=$0; next }
/\.md$/ { print $0 "	" c }
')
lost=""
if [ -n "$del" ]; then
  while IFS=$'	' read -r f c; do
    [ -z "$f" ] && continue
    base=$(basename "$f")
    # ★整棵樹（含 archive／改路徑）都找不到同檔名 ⇒ 真失蹤
    if ! grep -qxF "$base" "$ALL_BASENAMES"; then
      lost="${lost}   ★ $base  ←  $c"$'
'
    fi
  done <<< "$del"
fi
rm -f "$ALL_BASENAMES"
if [ -n "$lost" ]; then
  echo "[MAILBOX-GATE] ★★★FAIL：信被刪除且【現在整棵樹都找不到】⇒ 收件人從來沒收到"
  printf '%s' "$lost"
  echo "   ★處置＝從那顆 commit 還原（git show <c>^:<path>），★★不是重寫一封"
  echo "   ★★★而【誰刪的】通常不知道自己刪了：revert 的粒度是 commit 不是意圖"
  fail=1
else
  echo "[MAILBOX-GATE] ②刪除：窗內沒有【至今找不回】的信（★封存搬家不算，已比對整棵樹）"
fi

# ── ③誠實限（★印在使用的當下，不是只寫在檔裡）────────────────────────
echo "[MAILBOX-GATE] ★誠實限：①只掃最近 $WIN 顆 commit —— 更早的失蹤【看不見】"
echo "   ★★②只認 frontmatter 的 \`status:\` 第一行；手改成別的寫法本閘讀不到"
echo "   ★★★③【從來沒被 commit 過】的信本閘看不見 —— 那種失蹤 git 裡沒有痕跡"

exit $fail
