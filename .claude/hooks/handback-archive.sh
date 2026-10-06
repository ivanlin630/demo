#!/usr/bin/env bash
# 信箱歸檔：consumed 且【不是今天】的信 → docs/superpowers/handbacks/archive/YYYY-MM/
#
# ★為什麼要有這支（blueprint 授權 2026-08-26）：
#   熱目錄長到 911 封 ⇒ SessionStart hook 的掃描 >2 分鐘 ⇒ 被殺 ⇒
#   ★★所有角色開場【靜默】失去角色 context 與未讀清單（沒有任何錯誤訊息）。
#   掃描本身已改成單次 awk（2.0s），★但「沒有人負責讓東西變少」這件事沒解 —— 這支就是解它的。
#
# ★★三條不可妥協的規則：
#   ① `status: open` 一律不動（不管多舊）——未完成的事不該從視野消失。
#   ② ★【今天】的信一律不動 —— `handback-inbox.sh` 的 `_promise_check` 掃
#      `${today}-${me}-to-*.md` 判「宣稱已通知但沒寄信」；今天的信被搬走 ⇒ 那道檢查失效。
#   ③ 用 `git mv`（保 history）。四個 glob 那個目錄的東西都是 `dir/*.md` maxdepth-1，
#      搬進子目錄它們就看不到 —— 這正是目的，不是副作用。
#
# 用法：bash .claude/hooks/handback-archive.sh [--dry-run]
set -u
# ★★★worktree-safe 信箱解析（systems 修 2026-08-27，implementer 揭）：
#   `--show-toplevel` 在 worktree 裡回傳【worktree 根】⇒ 解到一個【空的】handbacks 目錄，
#   而唯一的信箱在 main。★zero-output-warn 因此對 worktree 角色【恆誤報】(他兩回合都寄了信卻都被判零產出)。
#   ★★`--git-common-dir` 在 worktree 裡回傳【main 的 .git】(`--git-dir` 不行，那是 worktree 私有的)
#   ⇒ 其父目錄＝main 工作樹根；★★★在 main 裡跑同樣正確 ⇒ 一份程式碼兩邊都對，不需角色分支。
_gc=$(git rev-parse --git-common-dir 2>/dev/null) || exit 2
cd "$(cd "$(dirname "$_gc")" && pwd)" || exit 2
HB="docs/superpowers/handbacks"
[ -d "$HB" ] || { echo "[archive] 無 $HB"; exit 0; }
DRY=0; [ "${1:-}" = "--dry-run" ] && DRY=1
today="$(date +%Y-%m-%d)"
_ARCH_LIST=$(mktemp); trap 'rm -f "$_ARCH_LIST"' EXIT   # ★本輪搬了誰（每行一個路徑：舊、新交替）
moved=0; kept_open=0; kept_today=0
shopt -s nullglob
for f in "$HB"/*.md; do
  bn="$(basename "$f")"
  # 檔名日期前綴；沒有日期前綴的一律不動（不猜）
  case "$bn" in
    [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-*) d="${bn:0:10}" ;;
    *) continue ;;
  esac
  [ "$d" = "$today" ] && { kept_today=$((kept_today+1)); continue; }
  # ★★列舉【open】，不列舉「完成的各種說法」——2026-08-26 血證：
  #   第一版只認 `consumed`，實測信箱有【五種】status：
  #     consumed / open / superseded / superseded-by-qa / withdrawn
  #   ★「完成」的講法會長大（誰都能發明一個新的）；★★「還要動作」的講法只有一個：`open`。
  #   ⇒ 列舉不會長大的那一邊。同 `test-ran-floor` 換軸那條。
  grep -qE '^status:[[:space:]]*open[[:space:]]*$' "$f" && { kept_open=$((kept_open+1)); continue; }
  dest="$HB/archive/${d:0:7}"
  if [ "$DRY" = 1 ]; then echo "  would move $bn -> ${dest#$HB/}"; else
    mkdir -p "$dest"
    git mv "$f" "$dest/$bn" 2>/dev/null || mv "$f" "$dest/$bn"
    printf '%s
%s
' "$f" "$dest/$bn" >> "$_ARCH_LIST"   # ★搬了誰就記誰（下面只 commit 這份清單）
  fi
  moved=$((moved+1))
done
echo "[archive] 歸檔 ${moved} 封｜保留：open ${kept_open} 封、今天 ${kept_today} 封"

# ★★★【搬完就自己 commit】（systems 2026-10-06 補，血證見下）
#   ★舊版只 `git mv`、零個 commit ⇒ 277 筆 rename 躺在【共用 main dir 的索引】裡
#     ⇒ pathspec commit 不會吃到它，★★但 `git merge` 會（merge 不吃 pathspec）
#     ⇒ 2026-10-06 我差一步就把 277 封歸檔夾帶進一張無關票的 merge commit（a93ff745d 代為落地）。
#   ⇒ 本體是【搬的人】，它就該是【commit 的人】—— 不留給下一個碰索引的人。
#   ★只 commit 清單裡的路徑（--pathspec-from-file）⇒ 別人 staged 的東西進不來。
#   ★走共用的 retry 包裝（鎖爭用是常態；包裝會印「第 N 次才成功」）。
_commit_rc="skip"
if [ "$DRY" != 1 ] && [ "$moved" -gt 0 ] && [ -s "$_ARCH_LIST" ]; then
  git add -A --pathspec-from-file="$_ARCH_LIST" 2>/dev/null   # ★`|| mv` 那條（非 git mv）也要進索引
  _msg=$(mktemp)
  printf '信箱歸檔（自動）：%s 封 consumed 且非今日的信 → archive/<月>

熱目錄剩 %s 封｜保留 open %s 封、今天 %s 封
本 commit 由 handback-archive.sh 自己做（只含它搬的路徑）
'     "$moved" "$(ls "$HB"/*.md 2>/dev/null | wc -l | tr -d ' ')" "$kept_open" "$kept_today" > "$_msg"
  bash .claude/hooks/git-commit-retry.sh -q -F "$_msg" --pathspec-from-file="$_ARCH_LIST"
  _commit_rc=$?
  rm -f "$_msg"
  if [ "$_commit_rc" != 0 ]; then
    echo "[archive] ★★★FAIL：搬了 ${moved} 封而 commit 失敗（rc=${_commit_rc}）⇒ 那批 rename 留在共用索引裡"
    echo "[archive]   ⇒ ★下一個跑 git merge 的人會把它夾帶進去 —— 先單獨 commit 它（清單：${_ARCH_LIST}）"
  fi
fi
echo "[archive] 熱目錄剩 $(ls "$HB"/*.md 2>/dev/null | wc -l | tr -d ' ') 封"

# ★寫下【它有在跑】的正面證據（2026-09-06）。
#   ★★這一步不是裝飾：歸檔本體從 2026-08-27 建好起【一次都沒被觸發過】，
#     而「它沒跑」這件事【完全沒有症狀】—— 直到熱目錄長到 1997 封、
#     SessionStart 掃描超時被殺、所有角色【靜默】失去角色 context。
#   ★★★而這個檔只證明【它跑過】；證明【它沒停下來】的是 merge gate `mailbox-size`（>600 就紅）。
#     兩層缺一層都會再靜默長回去。
_hot=$(ls "$HB"/*.md 2>/dev/null | wc -l | tr -d ' ')
printf '%s 搬=%s 熱目錄剩=%s 時間=%s commit_rc=%s
' "$(date +%s)" "${moved}" "${_hot}" "$(date +%FT%T)" "${_commit_rc}" > .claude/hooks/.archive-last
