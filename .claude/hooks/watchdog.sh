#!/usr/bin/env bash
# watchdog v4 — 停滯「分類器」（非計時器）。用戶定案 2026-08-21。
#
# v3 病：問「有沒有東西在動」→ 量測跑半天（全靜）被誤判成停滯。
# v4  ：問「有沒有人在等一個不會來的東西」。長工作在跑 = RUNNING = 永不報。
#
# fire = stdout（多行 200ms 內批成一則）→ 喚醒 arm 它的 session（blueprint）。
# blueprint 依 07_mailbox_trigger §stall 判斷後，才決定要不要推用戶。
#
# ★單例守衛「每 tick 重搶」，不是開機判一次
#   （v3 病：exit 0 走人 = 舊進程活著就永遠無法重新 arm；且舊進程死掉也沒人接手）。
#
# ★systems 審草案時改掉的三處（2026-08-21，皆有實測/理由）：
#   ① file-activity 的 find 分層 + timeout 護欄
#      —— 草案寫法（`-not -path` 不剪枝）實測 **>90s 未完成**：71 個 worktree × ~340 檔，
#         `-not -path` 只過濾輸出、照樣爬進 .git/.godot 物件樹。改成
#         beacon → ps → main 兩處(0.2s) → worktrees(有界 + `timeout`)。
#   ② alive_roles 改呼叫 peers.sh --tsv（單一事實來源，免兩份實作 drift）。
#   ③ 最老信的欄位解析改 `IFS=$'\t' read`（草案用字面 TAB 做 ${var%%...}，複製貼上易壞）。
set -u

POLL_S="${WATCHDOG_POLL_S:-900}"          # 15 min
T_DEAD="${WATCHDOG_T_DEAD:-900}"          # 15 min  信給沒開的角色
T_UNRESP="${WATCHDOG_T_UNRESP:-3600}"     # 1 h     收件人活著卻沒消費
T_IDLE="${WATCHDOG_T_IDLE:-3600}"         # 1 h     無信、無工作、無 commit
T_MAX_RUN="${WATCHDOG_T_MAX_RUN:-28800}"  # 8 h     長工作疑似掛死
RE_ARM="${WATCHDOG_RE_ARM:-14400}"        # 4 h     同狀態持續才重提醒
WT_TIMEOUT="${WATCHDOG_WT_TIMEOUT:-20}"   # worktree 掃描上限秒數（超過＝放棄該層，不阻塞迴圈）
ONCE="${WATCHDOG_ONCE:-0}"                # 1＝跑一趟就退出（自測用；正常運行永遠是 0）

_MAIN="$(dirname "$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" 2>/dev/null)"
ROOT="${_MAIN:-.}"
HB="$ROOT/docs/superpowers/handbacks"
HOOKD="$ROOT/.claude/hooks"
LOCK="$HOOKD/.watchdog.lock"
MYSID="${CLAUDE_CODE_SESSION_ID:-unknown}"
MYCPID="${CLAUDE_PID:-0}"

[ -d "$HB" ] || { echo "[watchdog v4] 無 $HB → 不啟動"; exit 0; }

dur() { local s=${1:-0}
  [ "$s" -lt 0 ] 2>/dev/null && s=0
  if [ "$s" -lt 3600 ] 2>/dev/null; then echo "$((s/60))m"; else echo "$((s/3600))h$(((s%3600)/60))m"; fi; }

# ── 單例：每 tick 重搶。搶不到不退出（下 tick 再搶）⇒ 前任死掉會自動接手 ────
# 回傳：0=搶到 / 1=同代持有(它會自退) / 2=★舊代持有(它【不會】自退，需人工 TaskStop)
#
# ★跨代縫（用戶 2026-08-25 抓到，額度斷電四天期間曝光）：
#   v4「新的一定贏」的前提 ＝ 舊方也跑 v4、會讀 lock 歸屬而自退。
#   跨代時舊方是 v3（compact 前 Monitor 起的常駐舊碼）：不讀 lock 歸屬、永不讓位、每 poll 還 touch
#   ⇒ lock 永遠新鮮 ⇒ v4 永遠停在「待命」，而 v3 照舊每 5h 響 14 連發。
#   ⇒ 這是【對稱升級假設】的失敗 —— 跨代才是常態，不是例外。
# ★機械判代訊號：v4 寫【3 欄】pid/sid/cpid；欄數 < 3 ＝ 舊代。
#   （優於「等 N 輪逾時」：不必等，當場判得出來。）
LOCK_FIELDS_V4=3
claim_lock() {
  local cur age nf
  cur="$(cut -f1 "$LOCK" 2>/dev/null)"
  if [ -n "$cur" ] && [ "$cur" != "$$" ]; then
    age=$(( $(date +%s) - $(stat -c %Y "$LOCK" 2>/dev/null || echo 0) ))
    if [ "$age" -lt $(( POLL_S + 120 )) ]; then
      nf="$(awk -F'\t' 'NR==1{print NF; exit}' "$LOCK" 2>/dev/null)"
      [ -n "$nf" ] && [ "$nf" -lt "$LOCK_FIELDS_V4" ] 2>/dev/null && return 2
      return 1
    fi
  fi
  # ★第 4 欄 proto 戳：讓【下一代】也能被機械判出（欄數判代只認得出「比現行少欄」的）
  printf '%s\t%s\t%s\tproto=4\n' "$$" "$MYSID" "$MYCPID" > "$LOCK" 2>/dev/null
  return 0
}

# ── S1 哪些角色活著（★單一事實來源＝peers.sh）────────────────────
alive_roles() {
  bash "$HOOKD/peers.sh" --tsv 2>/dev/null | awk -F'\t' '$2=="ALIVE"{printf "%s ", $1}' | sed 's/ $//'
}

# ── S2 open 信：「秒齡<TAB>收件人<TAB>檔名」，最老在前 ────────────
open_letters() {
  shopt -s nullglob
  local files=("$HB"/*.md) now
  [ "${#files[@]}" -eq 0 ] && return
  now=$(date +%s)
  awk '
    FNR<=10 {
      low=tolower($0)
      if (low ~ /^to:[ \t]*[a-z]/)             { t=low; sub(/^to:[ \t]*/,"",t); sub(/[ \t].*$/,"",t); TO[FILENAME]=t }
      if (low ~ /^status:[ \t]*open([ \t]|$)/) ST[FILENAME]=1
    }
    END { for (f in ST) if (TO[f] != "") print TO[f] "\t" f }
  ' "${files[@]}" | while IFS=$'\t' read -r to f; do
      m=$(stat -c %Y "$f" 2>/dev/null || echo "$now")
      printf '%s\t%s\t%s\n' "$(( now - m ))" "$to" "$(basename "$f")"
    done | sort -rn
}

# ── ★★★RUNNING 豁免清單（2026-08-25 HOLD 批 #3，用戶定）★預設【不豁免】 ─────────────
#   ★只有 `CHAIN-BROKEN` 被 `RUNNING` 無條件豁免 —— 它的語意就是「全靜」，有人在跑就不成立。
#   ★`UNRESPONSIVE` 只有【精準豁免】：`running` ＝ `beacon:<R>` 且未消費的信正是給 R。
#   ★`DEAD-ROLE` / `COMMIT-NO-LETTER` / `RUNAWAY`：★★不豁免（它們是【已完成的事實】或【上限】，
#     跟誰在不在忙無關）。
#   ★★★新增分類【預設不豁免】—— 要豁免必須在這張表上寫明並附理由。
#     （血證 2026-08-25：`COMMIT-NO-LETTER` 被 `elif [ -n "$running" ]` 默默吞掉，
#      而它是唯一能抓「出貨沒推鏈」的分類 ⇒ 鏈斷了四小時沒人知道。）
#   ★fire 訊息帶 `via:<路徑>` ⇒ 異常時【一次輸出即足診斷】，不必重現（自然事件重現不了）。

# ── S3 長工作在跑？（★分層：便宜的先問，貴的最後且有 timeout 護欄）──
#    beacon 只壓警報、不造警報，帶死線自動過期（忘了刪 → 8h 後失效；忘了寫 → 只多響一次）。
long_running() {
  local now f dl hit; now=$(date +%s)
  shopt -s nullglob
  for f in "$HOOKD"/.busy.*; do
    dl=$(cat "$f" 2>/dev/null || echo 0)
    case "$dl" in (*[!0-9]*|'') dl=0 ;; esac
    [ "$dl" -gt "$now" ] && { echo "beacon:${f##*/.busy.}"; return; }
  done
  # ps -W ★必須帶 -W：實測不帶抓不到 WMI-detach 起的 Godot（2026-08-21 階段0 驗）
  ps -W 2>/dev/null | grep -qi godot && { echo "godot-proc"; return; }
  command -v tasklist >/dev/null 2>&1 &&
    tasklist //NH //FI "IMAGENAME eq Godot*" 2>/dev/null | grep -qi godot &&
    { echo "godot-proc"; return; }
  # main 兩處：實測 0.2s
  hit=$(find "$ROOT/scripts" "$ROOT/docs/measurements" -type f -mmin -10 -print -quit 2>/dev/null)
  [ -n "$hit" ] && { echo "file-activity"; return; }
  # worktrees：有界 glob（不碰 .git/.godot）+ timeout。逾時＝放棄本層（回報無），不阻塞迴圈。
  # ★★母體塌陷防線：上面 `shopt -s nullglob`（beacon 需要）會外洩到這裡——glob 無匹配時
  #   路徑參數會整個消失，`find -maxdepth 6 …` 就變成「掃當前工作目錄」→ 撈到剛改的檔 → 假 RUNNING。
  #   （2026-08-21 fixture 實測踩到：fixture 無 .worktrees，卻回報 file-activity-wt。）
  #   ⇒ 先收進陣列、母體為 0 就不跑 find。這與 O2 `expect_min` 是同一型病的機械解。
  local wt=("$ROOT"/.worktrees/*/scripts)
  [ "${#wt[@]}" -eq 0 ] && return
  hit=$(timeout "$WT_TIMEOUT" find "${wt[@]}" -maxdepth 6 -type f -mmin -10 -print -quit 2>/dev/null)
  [ -n "$hit" ] && echo "file-activity-wt"
}

# ★ARMED 只在真的搶到 lock 之後才印（草案在搶之前就印 = 說謊：沒搶到也顯示 ARMED）。
armed=0
announce() {
  [ "$armed" = "1" ] && return
  armed=1
  echo "[watchdog v4] ✅ ARMED sid=${MYSID} pid=$$（poll $(dur $POLL_S) / DEAD $(dur $T_DEAD) / UNRESP $(dur $T_UNRESP) / IDLE $(dur $T_IDLE) / MAXRUN $(dur $T_MAX_RUN)）"
}

# ★待命升級參數（跨代不必等、當場判；同代久不讓位才逾時升級）
STANDBY_MAX_ROUNDS="${STANDBY_MAX_ROUNDS:-8}"   # 8 × POLL ≈ 2h
ESCALATE_EVERY="${ESCALATE_EVERY:-8}"           # 升級訊息複述間隔（輪）——說一次會被錯過
last_class="OK"; last_fire=0; run_since=0; standby_said=0; standby_rounds=0; claim_rc=0; holder=""
while true; do
  claim_lock; claim_rc=$?
  if [ "$claim_rc" != "0" ]; then
    # ★ONCE 模式搶不到必須退出（草案 bug：ONCE 只在成功那趟結尾才判 ⇒ 搶不到就無窮迴圈）
    [ "$ONCE" = "1" ] && { echo "[watchdog v4] 另一實例持有 lock（rc=$claim_rc）→ 本趟不判"; exit 0; }
    holder="$(cut -f1 "$LOCK" 2>/dev/null)"
    standby_rounds=$(( standby_rounds + 1 ))
    if [ "$claim_rc" = "2" ]; then
      # ★舊代持有：它不會自退 ⇒ 這【不是】可以等的狀態，必須說出「人要做什麼」；且要複述（說一次會被錯過）
      if [ "$standby_said" = "0" ] || [ $(( standby_rounds % ESCALATE_EVERY )) -eq 0 ]; then
        standby_said=1
        echo "[watchdog v4] 🔺 需人工介入：lock 由【舊版 watcher】持有 pid=${holder}（欄數 < ${LOCK_FIELDS_V4}）"
        echo "               舊版不讀 lock 歸屬、永不讓位 ⇒ 本進程【不會】自動接手。"
        echo "               處置：TaskStop 那個舊 Monitor task（pid=${holder}）→ 本進程下一輪自動上位。"
      fi
    else
      if [ "$standby_said" = "0" ]; then
        standby_said=1
        echo "[watchdog v4] ⏳ 待命 pid=$$（同代 pid=${holder} 持有；前任退場後本進程自動接手，無須人工介入）"
      elif [ "$standby_rounds" -ge "$STANDBY_MAX_ROUNDS" ] && [ $(( standby_rounds % ESCALATE_EVERY )) -eq 0 ]; then
        echo "[watchdog v4] 🔺 需人工介入：同代 pid=${holder} 持有 lock 已逾 $(dur $(( standby_rounds * POLL_S ))) 仍不讓位"
        echo "               （疑似卡住或非預期版本）處置：TaskStop 該 task → 本進程下一輪自動上位。"
      fi
    fi
    sleep "$POLL_S"; continue
  fi
  standby_said=0; standby_rounds=0
  announce

  now=$(date +%s)
  alive="$(alive_roles)"
  letters="$(open_letters)"
  running="$(long_running)"
  if [ -n "$running" ]; then [ "$run_since" -eq 0 ] && run_since=$now; else run_since=0; fi

  # git：兩個信號，用途不可混（★v3 病：取全 ref 最新 commit ⇒ merge 到 main 沒寫信反而把警報壓住）
  any_ct=$(git -C "$ROOT" for-each-ref --sort=-committerdate --count=1 --format='%(committerdate:unix)' 2>/dev/null || echo 0)
  main_ct=$(git -C "$ROOT" log -1 --format=%ct main 2>/dev/null || echo 0)
  main_subj=$(git -C "$ROOT" log -1 --format=%s main 2>/dev/null)
  # ★lane 掃（implementer 建議、blueprint 背書 2026-08-27）：cherry-pick／feat lane 工作流下，
  #   ★★「main 沒有新 commit」不等於「那個人沒在動」——已誤報兩次。
  #   ★★★而它【只進報告不進判準】：v3 的病正是拿全 ref 活動去【壓住】警報（見上一行註解）。
  #   ⇒ 我們要的是「讓讀警報的人看見他在別的 lane 動」，不是「因為他在動就不報」。
  lane_line=$(git -C "$ROOT" log --all --since="2 hours ago" --not main                   --pretty='%h %ad %s' --date=format:'%H:%M' 2>/dev/null | head -1)
  case "${any_ct:-0}"  in (*[!0-9]*|'') any_ct=0 ;;  esac
  case "${main_ct:-0}" in (*[!0-9]*|'') main_ct=0 ;; esac
  any_age=$(( now - any_ct ))

  newest_hb="$(ls -t "$HB"/*.md 2>/dev/null | head -1)"
  hb_ct=$(stat -c %Y "$newest_hb" 2>/dev/null || echo 0)
  hb_age=$(( now - hb_ct ))

  class="OK"; via=""; detail=""

  # 1) DEAD-ROLE — ★獨立於 RUNNING（信給沒開的角色，不管別人在不在忙都是 bug）
  if [ -n "$letters" ]; then
    while IFS=$'\t' read -r age to bn; do
      [ -z "${to:-}" ] && continue
      case "${age:-}" in (*[!0-9]*|'') continue ;; esac
      [ "$age" -lt "$T_DEAD" ] && continue
      case " $alive " in *" $to "*) continue ;; esac
      class="DEAD-ROLE"; via="pre-RUNNING"; detail="  ${to} 沒開，最老的信 open $(dur "$age")：${bn}"; break
    done <<< "$letters"
  fi

  # 2) COMMIT-NO-LETTER — ★獨立於 RUNNING（2026-08-25 血證，用戶問「怎麼還會停頓」才挖出）
  #   病：下面的 `elif [ -n "$running" ]; then class="OK"` 把本類連同 UNRESPONSIVE/CHAIN-BROKEN 一起跳過。
  #   實況：implementer 在跑 headless/憲法/det 背景 job（running 非空）★同時★ commit 了卻沒發信
  #   ⇒ watchdog 判 OK 保持靜默，而鏈確實斷了。
  #   ★根因：RUNNING 只證明【有人在忙】，不證明【鏈沒斷】—— 兩者可以同時為真。
  #   ★判準同 DEAD-ROLE：「出貨了沒推鏈」是【已完成的事實】，跟他現在忙不忙無關。
  #   （T_IDLE 門檻保留 ⇒ 跑 job 期間剛 commit 還沒寫信的正常中間態不會誤報。）
  if [ "$class" = "OK" ] && [ "$main_ct" -gt 0 ] \
     && [ "$hb_ct" -le "$main_ct" ] && [ $(( now - main_ct )) -ge "$T_IDLE" ]; then
    class="COMMIT-NO-LETTER"; via="pre-RUNNING"
    detail="  main 已落地 $(dur $(( now - main_ct )))，之後沒有任何新 handback
  最後 commit：${main_subj}
  → 有人出貨沒推下一站（違反無斷點自動鏈），鏈斷在他肚子裡
  ★本類獨立於 RUNNING：他可能正在跑東西，但出貨沒推鏈已經是事實"
  fi

  # 3) UNRESPONSIVE — ★獨立於 RUNNING，但保留【精準豁免】（2026-08-25 HOLD 批 #2）
  #   ★病：原本它跟 CHAIN-BROKEN 一起被 `elif [ -n "$running" ]; then class="OK"` 吞掉
  #        ⇒ ★★【任何人】在跑長工，就能讓【另一個人】的未回信被豁免。
  #   ★★★正解不是「不豁免」，是【只豁免該豁免的那一個】：
  #        只有 `running` ＝ `beacon:<R>` 且【那封沒被消費的信正是給 R】時才靜默
  #        —— 那才是「他在忙所以還沒回」的唯一合法解釋。
  #        （`godot-proc` / `file-activity` / `beacon:<別人>` 都不算：它們證明不了「R 在忙」。）
  if [ "$class" = "OK" ] && [ -n "$letters" ]; then
    IFS=$'	' read -r a to bn <<< "$(head -1 <<< "$letters")"
    case "${a:-}" in (*[!0-9]*|'') a=0 ;; esac
    if [ "$a" -ge "$T_UNRESP" ]; then
      _busy_role=""
      case "${running:-}" in beacon:*) _busy_role="${running#beacon:}" ;; esac
      if [ -n "$_busy_role" ] && [ "$_busy_role" = "$to" ]; then
        :   # ★該角色自己掛了 beacon 且信正是給他 ⇒ 合法豁免，靜默
      else
        class="UNRESPONSIVE"; via="pre-RUNNING/beacon-exempt-checked"
        detail="  ${to} 活著但 ${bn} 已 open $(dur "$a") 沒消費"
        [ -n "${running:-}" ] && detail="${detail}
  ★有長工作在跑（${running}），但它不是 ${to} 的 beacon ⇒ 不構成豁免"
      fi
    fi
  fi

  if [ "$class" = "OK" ]; then
    if [ -n "$running" ] && [ "$run_since" -ne 0 ] && [ $(( now - run_since )) -ge "$T_MAX_RUN" ]; then
      class="RUNAWAY"; via="running-maxrun"; detail="  長工作已跑 $(dur $(( now - run_since )))（來源 ${running}）—— 疑似掛死"
    elif [ -n "$running" ]; then
      class="OK"                                   # ★量測跑半天走這條
    else
      # 3) CHAIN-BROKEN
      if [ "$class" = "OK" ] && [ "$hb_age" -ge "$T_IDLE" ] && [ "$any_age" -ge "$T_IDLE" ]; then
        class="CHAIN-BROKEN"; via="post-RUNNING(唯一被豁免者)"
        detail="  無 open 信、無長工作、全靜 $(dur "$hb_age")
  最後一封：$(basename "${newest_hb:-無}") —— 該有人接手卻沒有"
      fi
    fi
  fi

  if [ "$class" = "OK" ]; then
    last_class="OK"
  elif [ "$class" != "$last_class" ] || [ $(( now - last_fire )) -ge "$RE_ARM" ]; then
    case "$class" in DEAD-ROLE) icon="🔴" ;; RUNAWAY) icon="🟠" ;; *) icon="🟡" ;; esac
    echo "${icon} STALL / ${class}${via:+ via:${via}}"
    echo "$detail"
    echo "  活著：${alive:-（無）}"
    echo "  長工作：${running:-無}"
    if [ "$main_ct" -gt 0 ]; then
      echo "  最後 commit(main)：$(dur $(( now - main_ct ))) 前 — ${main_subj}"
    fi
    if [ -n "$lane_line" ]; then
      echo "  ★feat lane（近 2h，不在 main 上）：${lane_line}"
      echo "    ⇒ ★★他【有】在動，只是沒進 main／沒寫信 —— 判準不因此放行，但別把它讀成「人不見了」。"
    else
      echo "  ★feat lane（近 2h，不在 main 上）：無"
    fi
    echo "  → 處置準則見 07_mailbox_trigger §stall。只有「開終端／WHAT 裁決／授權」才推用戶。"
    last_class="$class"; last_fire=$now
  fi

  # ★★只准 touch【自己的】lock（blueprint 現場抓到「替屍體保溫死鎖」2026-08-25）：
  #   若非持有者也 touch ⇒ 死 holder 的 lock 被外人保鮮 ⇒ 「lock stale」永不成立
  #   ⇒ 全體永遠待命、升級訊息每 2h 空響。
  #   ★本檔的控制流【本來】就只有持有者走到這裡（待命分支在上面 continue 了），
  #   但把不變量做成【局部檢查】而不是「靠控制流保證」—— 日後有人搬動這行也不會復發。
  #   ★注意三支常駐單例的風險不對稱：inbox-watch / tg_poll 的非持有者是【直接 exit】，
  #   碰不到 touch；只有 watchdog 的非持有者【留在待命迴圈】⇒ 它是唯一會出事的那個。
  [ "$(cut -f1 "$LOCK" 2>/dev/null)" = "$$" ] && touch "$LOCK" 2>/dev/null
  [ "$ONCE" = "1" ] && exit 0
  sleep "$POLL_S"
done
