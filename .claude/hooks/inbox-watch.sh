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
#    v2：同 session 且 watcher 存活 → 安靜退出並【明說已驗】；否則接手。
#    ⇒ /clear·/compact 不再需要搶佔（同 session 認得出來），真重開必定接手。
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

_watcher_alive() { [ -n "${1:-}" ] && kill -0 "$1" 2>/dev/null; }

if [ -n "$MYSID" ] && [ -n "$prev_sid" ] && [ "$prev_sid" = "$MYSID" ] && _watcher_alive "$prev_pid"; then
  # ★輸出「已處置完的結果」，不是「需要被解讀的狀態」——agent 不必猜下一步。
  echo "[inbox-watch] ✅ 覆蓋仍在（同 session，watcher pid=${prev_pid} 存活，已驗）→ 本次不重複 arm"
  exit 0
fi

printf '%s\t%s\t%s\n' "$$" "$MYSID" "$MYCPID" > "$LOCK" 2>/dev/null
if [ -n "$MYSID" ] && [ -n "$prev_sid" ] && [ "$prev_sid" = "$MYSID" ]; then
  echo "[inbox-watch] ✅ ARMED role=${ROLE_KEY} pid=$$（前任同 session 但已死，已接手）"
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
        echo "📬 收信 → ${ROLE_KEY}: $(basename "$fpath") | ${topic} —— 讀信+動工，完後改 status: consumed"
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
