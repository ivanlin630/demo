#!/usr/bin/env bash
# inbox-watch.sh v2 — Monitor 用的常駐信箱輪詢（主動觸發：新信 → 事件 → 喚醒本 session）。
# 補 handback-inbox.sh（UserPromptSubmit hook 只在「人打字」才掃）的缺口：
#   角色 session idle 掛著時，別的角色寫信也能主動喚醒，免人肉轉述。
#
# 用法（各角色 session 開場 arm 一次）：
#   Monitor(command="bash .claude/hooks/inbox-watch.sh", persistent=true, description="<role> 信箱")
#
# ══ v2 改了什麼（2026-08-21 用戶定案，R2+R3+R7）══════════════════════════
# ① ★arm 改「搶佔式」：不比誰心跳新，比誰後 arm。
#    v1 病：開機判一次、`exit 0` 走人；舊進程每 20s touch ⇒ lock 永遠新鮮 ⇒
#           只要舊進程活著就【永遠沒辦法合法重新 arm】，唯一出路是手動殺進程。
#    v2：新的一定贏；舊的下一輪讀到 lock 不是自己 → 印一行讓位訊息後自退（孤兒自己清自己）。
#    ★取捨：誤開第二個同角色 session，被踢的是舊的（可能才是正在工作的那個）。
#      但它會【印出來】，看得見。比 v1「新的靜默聾掉」好。
#      土法分辨：5 分鐘內看到第二次「讓位」＝ 真的有另一個同角色 session 活著。
#
# ② ★session_id 綁定（R7）：lock = `<watcher_pid>\t<session_id>\t<claude_pid>`。
#    v1 病：只印「已有實例在跑 → 退出」＝【把機器該做的判斷外包給一個拿不到資料的 agent】。
#           同一則訊息兩種相反處置：判「覆蓋仍在」→ 真重開就靜默失聰；
#           判「舊進程卡住」→ 殺掉重 arm，而實測那些 watcher 全是健康的 ⇒ 誤殺白做工。
#    v3（2026-08-25 HOLD 批 #1，用戶定）：★刪掉「同 session ＋ watcher 存活 → 安靜退出」那條分支，一律搶佔。
#      ★病：compact 後 session_id 不變、bash pid 還在跑 → 判「覆蓋仍在」→ 不 arm；
#          ★★而那支的 stdout 管道可能在 compact 當下就斷了（殭屍：lock 格式正確、pid 存活、心跳新鮮，
#          三個「它活著」的證據全在，唯獨叫不醒任何人）。實測一次清出 6 隻歷代 orphan。
#      ★★★能證明管道活著的只有一件事：【成功寫過 stdout】。沒有便宜的偵測法——
#          主動 emit 心跳＝定期喚醒 session（太貴）；challenge/response 殭屍照樣答得出來（它的 bash 迴圈還在跑）。
#      ⇒ ★與其偵測，不如【每次 arm 都換血】：新起的一定活著。
#      ★原本保留那條的理由是「避免 SEEN 空掉重吐」，而 SEEN 已落地成檔（見 ③）⇒ 那條分支現在是【純負債】。
#    ⇒ ★/clear·/compact 與真重開【一律搶佔】：不再區分，因為區分得出「同一個 session」，區分不出「管道還通」。
#
# ③ ★SEEN 落地成檔（.inbox-seen.<role>）：新 watcher 繼承前任吐過什麼 → 重 arm 不重吐。
#    沒有這條的話：auto-compact → 重 arm → SEEN 空 → 全部 open 信重吐 → ctx 又漲 → 再 compact…自我循環。
#
# ④ ★刪掉 v1 的 `[開場既存]` 全量吐：那件事本來就有人做、而且做得更好
#    （session-role.sh SessionStart 注入待辦、handback-inbox.sh 每 turn 掃）。
#    ⇒ Monitor 現在【只做一件事：吐真正新到的信】。
#
# ⑤ ★過濾條件放寬，補一個 singleton 治不了的洞：
#    `to:我 && status:open`  →  `to:我 && ( status:open || mtime > 本 watcher 啟動時間 )`
#    因為【寄件端誤寫 consumed】的信永遠不會被吐、靜默漏看（07 §status 所有權記載過）。
#    啟動後才被改成 consumed 的信仍會被吐一次；1293 封歷史信不受影響。
#
# ★★兩條紀律（不可妥協）：只警告絕不阻擋；fail-open（拿不到 session_id 就退回舊行為，不因讀不到而報警）。
#
# 契約：
#   - stdout 每行 = 一個事件（喚醒本 session）。
#   - 純輪詢無新信 = 零 stdout = 零 token；有新信才進對話。
#   - revise 重開（同檔 mtime 變）→ 重新吐（key 含 mtime）。
#   - 角色 = $SESSION_ROLE（開窗設）；fallback 到 $1。
set -u
POLL_S="${INBOX_POLL_S:-20}"
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

HOOKD="${HANDBACK_DIR%/docs/*}/.claude/hooks"
LOCK="$HOOKD/.inbox-watch.${ROLE_KEY}.lock"
SEEN_F="$HOOKD/.inbox-seen.${ROLE_KEY}"
MYSID="${CLAUDE_CODE_SESSION_ID:-}"
MYCPID="${CLAUDE_PID:-0}"
START_TS=$(date +%s)

# ── arm 決策表（R7）────────────────────────────────────────────────
# lock 的 session_id ＝ 我的 ＋ watcher 活著 → 安靜退出（★可驗證的事實，不是猜測）
# lock 的 session_id ＝ 我的 ＋ watcher 死了 → 接手
# lock 的 session_id ≠ 我的（或讀不到）    → 搶佔（P5：新的一定贏）
prev_pid=""; prev_sid=""
if [ -f "$LOCK" ]; then IFS=$'\t' read -r prev_pid prev_sid _ < "$LOCK" 2>/dev/null; fi
prev_pid="${prev_pid:-}"; prev_sid="${prev_sid:-}"
# ★跨代偵測（同 watchdog v4，用戶 2026-08-25 抓到的縫）：
#   「前任將於下輪自退」只有在【前任也跑新版】時成立。舊版 watcher 不讀 lock 歸屬、永不讓位
#   ⇒ 新舊並存、同一封信吐兩次。★機械判代：本版寫 3 欄（pid/sid/cpid），欄數 < 3 ＝ 舊代。
LOCK_FIELDS_CUR=3
prev_fields=0
[ -f "$LOCK" ] && prev_fields="$(awk -F'\t' 'NR==1{print NF; exit}' "$LOCK" 2>/dev/null || echo 0)"
prev_fields="${prev_fields:-0}"

_watcher_alive() { [ -n "${1:-}" ] && kill -0 "$1" 2>/dev/null; }


# ★第 4 欄 proto 戳（同 watchdog）：向後相容——偵測是「欄數 < 3 ＝ 舊代」，4 欄仍判同代，不誤報
printf '%s\t%s\t%s\tproto=2\n' "$$" "$MYSID" "$MYCPID" > "$LOCK" 2>/dev/null
if [ -n "$MYSID" ] && [ -n "$prev_sid" ] && [ "$prev_sid" = "$MYSID" ]; then
  echo "[inbox-watch] ✅ ARMED role=${ROLE_KEY} pid=$$（前任同 session ⇒ 一律換血接手（不問死活））"
elif [ -n "$prev_pid" ] && [ "$prev_fields" -lt "$LOCK_FIELDS_CUR" ] 2>/dev/null; then
  # ★舊代前任：它【不會】自退 ⇒ 不可輸出「將於下輪自退」那句安撫話（那是跨代下的假話）
  echo "[inbox-watch] ✅ ARMED role=${ROLE_KEY} pid=$$（已接管 lock）"
  echo "[inbox-watch] 🔺 但需人工介入：前任 pid=${prev_pid} 是【舊版 watcher】（欄數 ${prev_fields} < ${LOCK_FIELDS_CUR}）"
  echo "               舊版不讀 lock 歸屬、永不讓位 ⇒ 新舊並存、同一封信會吐兩次。"
  echo "               處置：TaskStop 那個舊 Monitor task（pid=${prev_pid}）。"
elif [ -n "$prev_pid" ]; then
  echo "[inbox-watch] ✅ ARMED role=${ROLE_KEY} pid=$$（前任 pid=${prev_pid}${prev_sid:+ sid=${prev_sid%%-*}…} 將於下輪自退）"
else
  echo "[inbox-watch] ✅ ARMED role=${ROLE_KEY} pid=$$（無前任）"
fi

# ── SEEN 繼承（★重 arm 不重吐）────────────────────────────────────
# SEEN 檔有兩種行（★兩種語意不可合併）：
#   K<TAB><path>@<mtime> ＝ 這個「版本」吐過了 → 同檔 revise(mtime 變) 會再吐一次（要的）
#   P<TAB><path>         ＝ 這封信「露過面」了 → 用來區分下面兩件事：
#     (a) 天生就被寄件端寫成 consumed 的信（從沒露過面）→ 該吐一次
#     (b) 我自己剛把它改成 consumed（露過面了）→ ★不可再吐，否則我一消費就把自己叫醒＝自我通知迴圈
declare -A SEEN=() SEEN_PATH=()
if [ -f "$SEEN_F" ]; then
  while IFS=$'\t' read -r kind val; do
    [ -z "${val:-}" ] && continue
    case "$kind" in K) SEEN["$val"]=1 ;; P) SEEN_PATH["$val"]=1 ;; esac
  done < "$SEEN_F"
fi

# ── ★開場 priming（2026-08-21 恢復日實測補）───────────────────────────
# 病：任何【批次改 mtime】的操作（git checkout/pull/stash）會讓剛 arm 的 watcher 把所有被碰到的
#     to:我 舊信各吐一次——SEEN_PATH 是空的，而放寬過濾又把「啟動後動過」算進來。239 封信可以爆一串。
# 解：arm 當下把「已存在且非 open」的信全部視為【已露過面】。語意上正確：
#     ⑤ 那條洞針對的是【啟動後才到】的誤寫 consumed 信；arm 之前就存在的 consumed 信，
#     本來就已由 SessionStart 注入／handback-inbox 每 turn 掃處理過了。
while IFS= read -r _p; do [ -n "$_p" ] && SEEN_PATH["$_p"]=1; done < <(
  shopt -s nullglob; _f=("$HANDBACK_DIR"/*.md)
  [ "${#_f[@]}" -gt 0 ] && awk -v role="$ROLE_KEY" '
    FNR<=10 {
      low=tolower($0)
      if (low ~ ("^to:[ \t]*" role "([ \t]|$)")) to[FILENAME]=1
      if (low ~ "^status:[ \t]*open([ \t]|$)")   st[FILENAME]=1
    }
    END { for (f in to) if (!(f in st)) print f }
  ' "${_f[@]}"
)

# ★★★未消費重提醒（systems 立 2026-09-01，血證：兩封 open 信擱置 90h）
#   ★病：喚醒是【一次性】的 —— SEEN[path@mtime] 喊過就不再喊；錯過那一個 turn ＝ 永眠。
#   ★★而修法【不是固定間隔洗版】：那會變成噪音，而噪音會被靜音（＝比沒有更糟）。
#   ★★★退避階梯 15m → 1h → 4h → 12h（之後每 12h），★訊息帶【已擱置多久】：
#     「有一封未讀」不可行動，「已擱置 90h」才可行動。
declare -A FIRST_TS LAST_REMIND
INBOX_REMIND_FAST="${INBOX_REMIND_FAST:-0}"   # ★陽性對照用：階梯縮成秒級
_remind_gap() {   # $1=age(秒) → 下一次提醒該隔多久
  local a="$1"
  if [ "$INBOX_REMIND_FAST" = "1" ]; then
    if   [ "$a" -lt 4 ]; then echo 2; elif [ "$a" -lt 8 ]; then echo 4; else echo 8; fi
    return
  fi
  if   [ "$a" -lt 3600 ];  then echo 900
  elif [ "$a" -lt 14400 ]; then echo 3600
  elif [ "$a" -lt 43200 ]; then echo 14400
  else echo 43200; fi
}
_fmt_age() {      # 秒 → 人看得懂（★不可行動的「有信」與可行動的「擱置 90h」差在這）
  local a="$1"
  if   [ "$a" -lt 3600 ];  then echo "$((a/60)) 分"
  elif [ "$a" -lt 86400 ]; then echo "$((a/3600)) 小時"
  else echo "$((a/86400)) 天 $(( (a%86400)/3600 )) 小時"; fi
}

while true; do
  # ★讓位檢查：lock 不是我 → 有更新的 watcher 當家，本實例自退（孤兒自己清自己）
  cur="$(cut -f1 "$LOCK" 2>/dev/null)"
  if [ -n "$cur" ] && [ "$cur" != "$$" ]; then
    echo "[inbox-watch] ⛔ 讓位：有更新的 ${ROLE_KEY} watcher（pid=${cur}）→ 本實例退出"
    exit 0
  fi

  shopt -s nullglob
  files=("$HANDBACK_DIR"/*.md)
  live_keys=()
  if [ "${#files[@]}" -gt 0 ]; then
    while IFS=$'\t' read -r isopen fpath topic; do
      [ -z "$fpath" ] && continue
      mtime=$(stat -c %Y "$fpath" 2>/dev/null || echo 0)
      key="${fpath}@${mtime}"
      [ "$isopen" = "1" ] && live_keys+=("$key")
      emit=0
      if [ "$isopen" = "1" ]; then
        # open 信：同版本沒吐過就吐（revise 換 mtime ⇒ 會再吐一次，這是要的）
        [ -z "${SEEN[$key]:-}" ] && emit=1
      else
        # 非 open 但啟動後動過：★只在「這封信從沒露過面」時吐（＝寄件端誤寫 consumed 的洞）
        [ -z "${SEEN_PATH[$fpath]:-}" ] && emit=1
      fi
      if [ "$emit" = "1" ]; then
        SEEN[$key]=1
        FIRST_TS[$key]=$(date +%s); LAST_REMIND[$key]=$(date +%s)
        echo "📬 收信 → ${ROLE_KEY}: $(basename "$fpath") | ${topic} —— 讀信+動工，完後改 status: consumed"
      fi
      # ★★重提醒：open 且【已經喊過】⇒ 依退避階梯再喊，訊息帶年齡
      #   ★退出條件只有一個：status 變 consumed（那時 isopen=0，這段不會進來）
      if [ "$isopen" = "1" ] && [ "$emit" != "1" ] && [ -n "${FIRST_TS[$key]:-}" ]; then
        _now=$(date +%s); _age=$(( _now - ${FIRST_TS[$key]} ))
        _since=$(( _now - ${LAST_REMIND[$key]:-${FIRST_TS[$key]}} ))
        if [ "$_since" -ge "$(_remind_gap "$_age")" ]; then
          LAST_REMIND[$key]=$_now
          echo "⏰ 未消費 → ${ROLE_KEY}: $(basename "$fpath") | ★已擱置 $(_fmt_age "$_age") | ${topic} —— 它不會自己消失，讀完改 status: consumed"
        fi
      fi
      SEEN_PATH[$fpath]=1
    done < <(
      # ★放寬過濾的成本控制：不在 awk 裡對每封信 spawn stat（歷史信上百封 × 每 20s ＝ 災難），
      #   改成每輪【一次】find -newermt 取「啟動後動過的檔」，再和 to:me 集合取交集。
      recent=""
      if [ "$START_TS" -gt 0 ]; then
        recent=$(find "$HANDBACK_DIR" -maxdepth 1 -name '*.md' -newermt "@$START_TS" -print 2>/dev/null)
      fi
      awk -v role="$ROLE_KEY" -v recent="$recent" '
        BEGIN { n=split(recent, R, "\n"); for (i=1;i<=n;i++) if (R[i] != "") REC[R[i]]=1 }
        FNR<=10 {
          low=tolower($0)
          if (low ~ ("^to:[ \t]*" role "([ \t]|$)"))  to[FILENAME]=1
          if (low ~ "^status:[ \t]*open([ \t]|$)")     st[FILENAME]=1
          if ($0 ~ /^[Tt]opic:/) { t=$0; sub(/^[Tt]opic:[ \t]*/,"",t); tp[FILENAME]=t }
        }
        END {
          for (f in to) {
            # ★寄件端誤寫 consumed 的洞：啟動後才動過的信也吐一次（SEEN 保證不重吐）
            if ((f in st) || (f in REC))
              printf "%s\t%s\t%s\n", ((f in st) ? "1" : "0"), f, (tp[f] ? tp[f] : "(無 topic)")
          }
        }
      ' "${files[@]}"
    )
  fi

  # SEEN 落地：只留「目前仍在母體內」那一小撮 → 大小被 open 數綁住，不會長
  {
    for k in "${live_keys[@]:-}"; do [ -n "$k" ] && printf 'K\t%s\n' "$k"; done
    # P 行只留「檔案還在、且 30 天內動過」的 → 大小有界，不會無限長大
    for pth in "${!SEEN_PATH[@]}"; do
      [ -f "$pth" ] || continue
      pm=$(stat -c %Y "$pth" 2>/dev/null || echo 0)
      [ $(( $(date +%s) - pm )) -le 2592000 ] && printf 'P\t%s\n' "$pth"
    done
  } > "$SEEN_F" 2>/dev/null

  touch "$LOCK" 2>/dev/null
  sleep "$POLL_S"
done
