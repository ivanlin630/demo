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


# ── ★每 turn 閘（R7，warn-only / fail-open）────────────────────────────
# 病：信箱 watcher 掉了 → 你【失聰】，但要等好幾小時、等到有人問「你怎麼沒回」才會發現。
# 這道閘把「幾小時後才發現」變成「下一次你打字就知道」。
# ★★兩條紀律（不可妥協）：
#   ① 只警告，絕不阻擋——閘門自己有 bug 就 brick 六個 session。
#   ② fail-open——拿不到 session_id、或 lock 是舊格式讀不出 sid，就【退回現行行為】，
#      絕不因為「讀不到」就報警（讀不到 ≠ 壞了）。
GATE=""
if [ -n "${CLAUDE_CODE_SESSION_ID:-}" ]; then
  _LOCK="${HANDBACK_DIR%/docs/*}/.claude/hooks/.inbox-watch.${ROLE_KEY}.lock"
  _why=""
  if [ ! -f "$_LOCK" ]; then
    _why="lock 不存在"
  else
    IFS=$'\t' read -r _lpid _lsid _ < "$_LOCK" 2>/dev/null
    _age=$(( $(date +%s) - $(stat -c %Y "$_LOCK" 2>/dev/null || echo 0) ))
    if [ "$_age" -ge 140 ]; then
      _why="watcher 心跳停了 ${_age}s（>140s）"
    elif [ -n "${_lsid:-}" ] && [ "${_lsid}" != "$CLAUDE_CODE_SESSION_ID" ]; then
      _why="信箱被另一個 session 的 watcher 佔著（sid=${_lsid%%-*}…）"
    fi
    # ${_lsid} 空 = 舊格式 lock → ★fail-open，不報警
  fi
  [ -n "$_why" ] && GATE="⛔ 你的信箱 watcher 沒在跑（${_why}）→ 收不到主動喚醒，別人寫給你的信會石沉大海。請重 arm：Monitor(command=\"bash .claude/hooks/inbox-watch.sh\", persistent=true, description=\"${ROLE_KEY} 信箱\")"
fi
shopt -s nullglob
files=("$HANDBACK_DIR"/*.md)
[ "${#files[@]}" -eq 0 ] && files=()   # 空信箱不早退：閘警告仍要送出

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

# ★閘警告優先於「無未讀就靜默」：沒信也要說 watcher 掛了

out=""; n=0
while IFS=$'\t' read -r bn tp; do
  [ -z "$bn" ] && continue
  out="${out}
- ${bn}: ${tp}"
  n=$((n + 1))
done <<< "$matches"

# ★兩段可獨立存在：沒未讀信但 watcher 掛了，一樣要說
if [ "$n" -eq 0 ] && [ -z "$GATE" ]; then exit 0; fi

if [ "$n" -gt 0 ]; then
  CTX="📬 ${n} 封未讀 handback（to: ${ROLE_KEY} / status: open）——讀完消費後改 status: consumed：${out}"
else
  CTX=""
fi
[ -n "$GATE" ] && CTX="${GATE}${CTX:+

}${CTX}"
# ★JSON 逃逸（2026-08-21 修）：舊版 sed 版對 `"` 完全沒跳脫 → 只要注入內容含引號就吐出非法 JSON。
#   session-role 的 blueprint 專屬 context 本來就含 Monitor(command="…") ⇒ 那段一直是壞的。
#   awk 版一次處理反斜線／引號／換行三種。
json_str() {
  printf '%s' "$1" | awk '
BEGIN { ORS=""; printf "\"" }
  { gsub(/\\/, "\\\\"); gsub(/"/, "\\\""); if (NR > 1) printf "\\n"; printf "%s", $0 }
  END { printf "\"" }
  '
}
printf '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":%s}}' "$(json_str "$CTX")"
