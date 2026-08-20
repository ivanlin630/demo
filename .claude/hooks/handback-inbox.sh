#!/usr/bin/env bash
# UserPromptSubmit hook：每 turn 掃未讀 handback（frontmatter to:<role> status:open）→ 注入 📬。
# 補 SessionStart(session-role.sh) 只掃一次的缺口——session 中途別的角色寫的 handback 也提醒，
# 消滅人肉轉述。掃 frontmatter = 讀真值源，免 QUEUE.md drift。空則靜默（免每 turn 噪）。
# 角色 = $SESSION_ROLE（systems|blueprint），開窗時設。
#
# ★2026-07-05 perf 修：舊版每檔 spawn sed+2grep（3 進程/檔）→ 326 檔=~1000 進程/turn→
#   Windows Git-Bash fork 慢=33s 撞 30s timeout。改單次 awk（1 進程，掃全檔前 10 行，檔數無關）。
# ★唯一信箱 = main repo 的 handbacks（worktree session 也指這，共用實體資料夾）。
_MAIN_REPO="$(dirname "$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" 2>/dev/null)"
HANDBACK_DIR="${_MAIN_REPO:-${CLAUDE_PROJECT_DIR:-.}}/docs/superpowers/handbacks"

case "${SESSION_ROLE:-}" in
  systems|系統)   ROLE_KEY="systems" ;;
  blueprint|藍圖) ROLE_KEY="blueprint" ;;
  qa|驗收)        ROLE_KEY="qa" ;;
  reviewer|審查)  ROLE_KEY="reviewer" ;;
  measurer|量測)  ROLE_KEY="measurer" ;;
  implementer|實作) ROLE_KEY="implementer" ;;
  *) exit 0 ;;   # 無角色 → 不掃（不打擾）
esac
[ -d "$HANDBACK_DIR" ] || exit 0

shopt -s nullglob
files=("$HANDBACK_DIR"/*.md)
[ "${#files[@]}" -eq 0 ] && exit 0

# 單次 awk：每檔前 10 行抓 to/status/topic，END 印 open+to:本角色 的（tab 分隔 basename<TAB>topic）。
matches=$(awk -v role="$ROLE_KEY" '
  FNR==1 { fname=FILENAME; sub(/.*\//,"",fname) }
  FNR<=10 {
    low=tolower($0)
    if (low ~ ("^to:[ \t]*" role "([ \t]|$)"))      to[FILENAME]=1
    if (low ~ "^status:[ \t]*open([ \t]|$)")        st[FILENAME]=1
    if ($0 ~ /^[Tt]opic:/) { t=$0; sub(/^[Tt]opic:[ \t]*/,"",t); tp[FILENAME]=t; bn[FILENAME]=fname }
  }
  END { for (f in to) if (st[f]) printf "%s\t%s\n", bn[f], tp[f] }
' "${files[@]}")

[ -z "$matches" ] && exit 0   # 無未讀 → 靜默

out=""; n=0
while IFS=$'\t' read -r bn tp; do
  [ -z "$bn" ] && continue
  out="${out}
- ${bn}: ${tp}"
  n=$((n + 1))
done <<< "$matches"

[ "$n" -eq 0 ] && exit 0

CTX="📬 ${n} 封未讀 handback（to: ${ROLE_KEY} / status: open）——讀完消費後改 status: consumed：${out}"
json_str() { printf '%s' "$1" | sed ':a;N;$!ba;s/\\/\\\\/g; s/"/\\"/g; s/\n/\\n/g' | awk 'BEGIN{printf "\""} {printf "%s",$0} END{printf "\""}'; }
printf '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":%s}}' "$(json_str "$CTX")"
