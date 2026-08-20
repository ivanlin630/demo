#!/usr/bin/env bash
# inbox-watch.sh — Monitor tool 用的常駐信箱輪詢（主動觸發：新信 → 事件 → 喚醒本 session）。
# 補 handback-inbox.sh（UserPromptSubmit hook 只在「人打字」才掃）的缺口：
#   角色 session idle 掛著時，別的角色寫信也能主動喚醒，免人肉轉述。
#
# 用法（各角色 session 開場 arm 一次）：
#   Monitor(command="bash .claude/hooks/inbox-watch.sh", persistent=true, description="<role> 信箱")
#
# 契約：
#   - stdout 每行 = 一個事件（喚醒本 session）。emit-once（seen-set keyed by path+mtime）→ 同信不重觸。
#   - 只吐 to:<我角色> && status:open 的信；status 改 consumed → 下輪不再吐。
#   - revise 重開（同檔 mtime 變）→ 重新吐（key 含 mtime）。
#   - 純輪詢無新信 = 零 stdout = 零 token；有新信才進對話。
#   - 角色 = $SESSION_ROLE（開窗設）；fallback 到 $1。
#
# ★別讓它變吵：只 emit 真新信。太吵 Monitor 會被自動停。
set -u
POLL_S="${INBOX_POLL_S:-20}"
# ★唯一信箱 = main repo 的 handbacks（不管本 session 在 main dir 還 worktree，都看同一個實體資料夾）。
# 從 worktree 也能算出 main repo：git-common-dir 指向共用 .git。
_MAIN_REPO="$(dirname "$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" 2>/dev/null)"
HANDBACK_DIR="${_MAIN_REPO:-${CLAUDE_PROJECT_DIR:-.}}/docs/superpowers/handbacks"

ROLE_RAW="${SESSION_ROLE:-${1:-}}"
case "$ROLE_RAW" in
  systems|系統)   ROLE_KEY="systems" ;;
  blueprint|藍圖) ROLE_KEY="blueprint" ;;
  qa|驗收)        ROLE_KEY="qa" ;;
  reviewer|審查)  ROLE_KEY="reviewer" ;;
  measurer|量測)  ROLE_KEY="measurer" ;;
  implementer|實作) ROLE_KEY="implementer" ;;
  *) echo "[inbox-watch] 無 SESSION_ROLE（systems|blueprint|qa|reviewer|measurer|implementer）→ 不啟動"; exit 0 ;;
esac

[ -d "$HANDBACK_DIR" ] || { echo "[inbox-watch] 無信箱目錄 $HANDBACK_DIR → 不啟動"; exit 0; }
# ★單例守衛(per-role):lock 心跳新鮮(<POLL+120s)=同角色已有 watcher 在跑 → 退出(免重複喚醒)。
LOCK="${HANDBACK_DIR%/docs/*}/.claude/hooks/.inbox-watch.${ROLE_KEY}.lock"
STALE=$(( POLL_S + 120 ))
if [ -f "$LOCK" ]; then
  age=$(( $(date +%s) - $(stat -c %Y "$LOCK" 2>/dev/null || echo 0) ))
  [ "$age" -lt "$STALE" ] && { echo "[inbox-watch] to:${ROLE_KEY} 已有實例在跑 → 退出(免重複)"; exit 0; }
fi
echo $$ > "$LOCK" 2>/dev/null

echo "[inbox-watch] 監看 to:${ROLE_KEY} 的 open 信（每 ${POLL_S}s；新信主動喚醒）"

declare -A SEEN
first_pass=1

while true; do
  # 單次 awk：抓 to:本角色 && status:open 的檔，印「fullpath<TAB>topic」。
  shopt -s nullglob
  files=("$HANDBACK_DIR"/*.md)
  if [ "${#files[@]}" -gt 0 ]; then
    while IFS=$'\t' read -r fpath topic; do
      [ -z "$fpath" ] && continue
      mtime=$(stat -c %Y "$fpath" 2>/dev/null || echo 0)
      key="${fpath}@${mtime}"
      if [ -z "${SEEN[$key]:-}" ]; then
        SEEN[$key]=1
        bn=$(basename "$fpath")
        # 開場既有的 open 信也吐一次（讓剛開的 session 知道待辦），標 [startup]。
        tag=""; [ "$first_pass" = "1" ] && tag=" [開場既存]"
        echo "📬 收信 → ${ROLE_KEY}${tag}: ${bn} | ${topic} —— 讀信+動工，完後改 status: consumed"
      fi
    done < <(awk -v role="$ROLE_KEY" '
      FNR==1 { fname=FILENAME }
      FNR<=10 {
        low=tolower($0)
        if (low ~ ("^to:[ \t]*" role "([ \t]|$)"))  to[FILENAME]=1
        if (low ~ "^status:[ \t]*open([ \t]|$)")     st[FILENAME]=1
        if ($0 ~ /^[Tt]opic:/) { t=$0; sub(/^[Tt]opic:[ \t]*/,"",t); tp[FILENAME]=t }
      }
      END { for (f in to) if (st[f]) printf "%s\t%s\n", f, (tp[f] ? tp[f] : "(無 topic)") }
    ' "${files[@]}")
  fi
  first_pass=0
  touch "$LOCK" 2>/dev/null   # 刷心跳
  sleep "$POLL_S"
done
