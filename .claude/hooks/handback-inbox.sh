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

# ── ★承諾即檔名(機械版):我在信裡說「已請/已派 <角色>」,但沒有寄給該角色的信 ──
#   血證 2026-08-25:systems 兩封信寫「已請 measurer 補一輪」,信根本沒發 ⇒ 該站永遠收不到工單。
#   這是 P7「承諾即檔名」從 prose 升級成機械檢查(只掃自己今天寄出的信,零成本)。
#   ★已知界限(P7 📜 declared):只掃「今天」——跨日承諾(昨天說要寄、今天仍沒寄)抓不到。
#   刻意不擴大:掃全歷史會把已完成的舊承諾一起翻出來當雜訊,反而讓人開始忽略這個警告。
_promise_check() {
  local d="docs/superpowers/handbacks" me="${SESSION_ROLE:-systems}" today
  today="$(date +%Y-%m-%d)"
  [ -d "$d" ] || return 0
  local f role hit miss=0
  for f in "$d"/${today}-${me}-to-*.md; do
    [ -f "$f" ] || continue
    for role in blueprint systems implementer measurer reviewer qa; do
      [ "$role" = "$me" ] && continue
      grep -qE "(已請|已派|已寄|已轉)[^。]{0,6}${role}" "$f" 2>/dev/null || continue
      hit=$(ls "$d"/${today}-${me}-to-${role}-*.md 2>/dev/null | head -1)
      [ -n "$hit" ] && continue
      echo "  ⚠ $(basename "$f") 宣稱已通知 ${role}，但今天沒有 ${me}-to-${role} 的信"
      miss=$((miss+1))
    done
  done
  [ "$miss" -gt 0 ] && echo "  ⇒ ★承諾即檔名:把信補上,或把那句話改掉(別讓下游永遠等一封不存在的信)"
  return 0
}
_promise_check

# ── ★★裸承諾檢查(2026-09-04 第三次同型後補):「已派」【不帶角色名】⇒ 上面那道掃不到 ──
#   血證:2026-09-04-systems-to-blueprint-guard-fired-line-reopens.md:15
#        原文「已派:那兩次【哪一階都不 applicable】、為什麼(逐階條件名,禁猜)」
#        ★沒有角色名 ⇒ _promise_check 的 `[^。]{0,6}${role}` 從來沒命中 ⇒ 票不存在而下游照著它排隊。
#   ★判準換軸:從【收件人】換成【兌現物】—— 同一行要有一個【真的存在的】handback 路徑。
#   ★★兩個排除(都是陽性對照撞出來的,不是預想的):
#      ①code fence 內的行 —— 在【展示】這個 pattern,不是在承諾(本閘的說明信自己踩到)
#      ②動詞【前面緊貼開引號】—— 是在引述那句話,而收尾引號可能離很遠 ⇒ 配對式抓不到
#   ★★★寧可漏一點也不要吵:雜訊會讓人開始忽略警告(同上面那道的已知界限)。
_promise_bare_check() {
  local d="docs/superpowers/handbacks" me="${SESSION_ROLE:-systems}" today
  today="$(date +%Y-%m-%d)"
  [ -d "$d" ] || return 0
  local f line path miss=0 checked=0
  for f in "$d"/${today}-${me}-to-*.md; do
    [ -f "$f" ] || continue
    # ★fence 狀態必須逐行推進 ⇒ 用 awk 過濾,不能先 grep(grep 會把行序與 fence 上下文丟掉)
    while IFS= read -r line; do
      checked=$((checked+1))
      # ★同一段落(到下一個空行為止)裡有【存在的】票路徑 ⇒ 承諾已兌現
      _lno=${line%%:*}; _txt=${line#*:}
      _para=$(awk -v n="$_lno" 'NR>=n { if (NR>n && $0 ~ /^[[:space:]]*$/) exit; print }' "$f")
      path=$(printf '%s' "$_para" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}-[a-z]+-to-[a-z]+-[a-z0-9-]+\.md' | head -1)
      [ -n "$path" ] && [ -f "$d/$path" ] && continue
      line="$_txt"
      # ★★★「同時送/一併送/也寄 X」型:有角色名【也不放行】(2026-09-04 血證,blueprint 指出)
      #   ★上面那道(_promise_check)查的是「今天有沒有寄信給該角色」,而我今天寄了幾十封 ⇒ 一定通過
      #   ⇒ ★★而這型承諾的兌現物是【那一封特定的信存在】,不是「有寄過信給他」
      #   ⇒ ★★★所以這型【必須】在同段落附票路徑,才算兌現
      if printf '%s' "$line" | grep -qE '(同時|一併|另外|順便|也)[^。]{0,6}(送|寄|發)'; then
        :   # 落到下面的段落路徑檢查,不因角色名而放行
      else
        printf '%s' "$line" | grep -qE '(blueprint|systems|implementer|measurer|reviewer|qa)' && continue
      fi
      echo "  ⚠ $(basename "$f"): 裸承諾「$(printf '%s' "$line" | cut -c1-40)…」——同一行沒有【存在的】票路徑"
      miss=$((miss+1))
    done < <(awk '
      /^```/ { fence = !fence; next }
      fence { next }
      /^(#|topic:|slice:|from:|to:|status:|tier:|touches:)/ { next }
      # ★這行【引用過】這個詞 ⇒ 整行當在討論規則(血證那行沒有引用,仍會響)
      /[「『](已請|已派|已寄|已轉)/ { next }
      # ★★判準從【同一行】放寬到【同一段落】(到下一個空行為止)——★不是放水,是從代理特徵改到本體:
      #   要求的本體是「下游驗不驗得到這個承諾」,而同段落的票路徑【一樣驗得到】;
      #   ★★同一行只是那個要求的代理特徵,而它讓閘每回合對同幾封已寄出的信重複告警
      #   ⇒ ★★★雜訊會讓人開始忽略警告 —— 那比漏抓更貴(2026-09-04,被自己的閘教會)
      { para[NR] = $0 }
      # ★★★2026-09-04:「同時送 X／一併寄 X」也是承諾,而它【沒有「已」字】⇒ 舊偵測層掃不到
      /(已請|已派|已寄|已轉)|((同時|一併|另外|順便)[^。]*(送|寄|發))/ {
        line = $0
        gsub(/[「『](已請|已派|已寄|已轉)/, "", line)   # ★開引號緊貼動詞 = 引述,剝掉
        if (line ~ /(已請|已派|已寄|已轉)|((同時|一併|另外|順便)[^。]*(送|寄|發))/) print NR":"$0
      }
    ' "$f")
  done
  # ★★★已宣告的盲區(2026-09-04,第八輪後【停止調校】):
  #   ①code fence 內的承諾【抓不到】—— fence 排除是為了不誤報「示範 pattern」的行,
  #     而我的信大量用 fence 當強調區塊 ⇒ ★寫在 fence 裡的「同時送 X」逃得掉(血證:conflict-dissolves 那封)
  #   ②先組成變數再 print／先寫成別的字再寄 —— 同理抓不到
  #   ⇒ ★★停止調校的理由:第八輪了,而每一輪的邊際收益在掉、假陽性風險在升
  #      ⇒ ★★★盲區【明寫】比【再修一輪】誠實:它讓讀的人知道這支閘保證了什麼、沒保證什麼
  # ★偵測器的證據力是單向的:checked=0 時不得讀成「全部合格」,直接 return 不印綠
  [ "$checked" -eq 0 ] && return 0
  [ "$miss" -gt 0 ] && echo "  ⇒ ★★寫「已派」同一句必須附票的 exact path,否則改寫成「將派」(⏳在飛 vs 🅿️未派下一步動作相反)"
  return 0
}
_promise_bare_check
