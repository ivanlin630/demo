# 工作流 harness 改版提案（八項）

status: NOTE（非 owned doc；待藍圖排序 → 轉 systems 立案）
from: 用戶授意開的一個**影子 blueprint session**（不發信、不寫 memory、不消費信箱）
to: 正藍圖（讀 §1 → 排序 → 以 blueprint 名義發 handback 給 systems）
measured_at: 2026-08-21 02:34 / HEAD `ee5e879f` / clean
對照來源: `A:\GDS\evora-world\evora-world-main\`（`skills/{e,m,r,t}-init`、`flows/{game-dev,light}.yaml`）+ 該專案作者的三段口述

---

## §0 這份 note 是什麼、怎麼用

用戶今天開了一個**額外的 blueprint session**（明令：不發信、不寫記憶、不碰信箱 status），
專門做一件事：**拿 evora-world 那套 flow-contract 工作流對照我們的多終端信箱 relay，找出該偷什麼、該修什麼。**

**本 note 的每一條斷言都有量測或 file:line**，量測原始數據在 §3。沒量到的地方明標「未驗」。

**路由（重要）**：
`docs/process/*`、`CLAUDE.md`、`.claude/hooks/*` 的 owner 是 **systems**，不是 blueprint。
⇒ 正藍圖對本 note 的**合法動作 = 排優先序 + 轉 systems**，不是自己改。
§1 是給你（藍圖）判斷用的簡報；§2 是可以直接貼進 handback 給 systems 的工單草案。

**這份 note 的第一個 dogfood**：它自己遵守 §2.P2 要立的規則——每個數字都帶量測時間 + commit + 重跑指令。

---

# §1 給藍圖：簡報

## 1.1 一句話

我們的工作流有**三個正在流血的洞**（停滯偵測會在量測時假響、量測數字沒有保鮮期、出貨不寫信沒人看得見），
和**四個潛伏但便宜可補的設計缺陷**（角色身分無驗證、arm 守衛需要 agent 猜、無註冊表、狀態手寫腐爛）。
今天新驗出 CC 直接提供 `CLAUDE_CODE_SESSION_ID` / `CLAUDE_PID` / `transcript_path`，**後四項因此變得幾乎免費**。

## 1.2 三個正在流血的（建議優先做）

| 件 | 病 | 血證 |
|---|---|---|
| **R5 停滯偵測** | 現行 `watchdog.sh` 問「有沒有東西在動」→ **量測跑半天（全靜）必被誤判成停滯**。且只 blueprint arm、fire 後每 5h 重響 | `watchdog.sh:15-21` 三合一快照 md5；`:48` fire 後 `last_change=$now` |
| **R6 量測主張保鮮期** | 現行「量測可溯源鐵律」只管**寫進去那一刻**，不管**三天後還在被引用** | **D1**：`統領 0.08 → cap 6 → 村結構性小` 當初合規寫入，之後被當成世界的性質掛在清單上；今日實測 `AT_CAP=0.0%` / `eff_pop_cap median=15` / 統領實為 `0.600` → 整條因果鏈死掉，**差點買下一整個 arc** |
| **R4 出貨不寫信** | `main` 落地但沒人推下一站＝違反無斷點自動鏈，**現在沒有任何東西看得見**。更糟：那個 commit 還會**把停滯警報壓住一小時**（`watchdog.sh` 的 git 信號被重置） | `watchdog.sh:19` 取全 ref 最新 commit 當「有活動」 |

## 1.3 四個潛伏的（便宜，順手做）

| 件 | 病 | 現況 |
|---|---|---|
| **R7 身分無驗證** | `SESSION_ROLE` 是開窗打的字，**沒有任何東西驗過**。arm 守衛只印一句「已有實例在跑→退出」，**剩下交給 agent 猜** | 用戶觀察：同一句話，有時判「覆蓋仍在」不動，有時判「舊進程卡住」→ **殺掉一支健康的 watcher**。已驗：那些 watcher 全是健康的（§3.3）⇒ **誤殺是白做工** |
| **R2+R3 arm 守衛** | 只在開機判一次；舊進程活著就**永遠沒辦法合法重新 arm** | `inbox-watch.sh:36-43`、`watchdog.sh:25-33` |
| **R1 無註冊表** | 「誰在線」只能猜 | ★但 `.inbox-watch.<role>.lock`（pid + 每 20s touch）**本來就是租約**，只是沒人讀 |
| **O1 手寫狀態腐爛** | `status/*.status.md` 宣稱是「即時狀態快照」，實際兩個角色停更 7–16 天 | `03_implementer.status.md` 最後更新 **8/5**（16 天）、`04_qa.status.md` **8/14**（7 天） |

## 1.4 我原本以為的一個急病 —— 已量測推翻，記在這裡免得重犯

我一度推論「真重開終端 = 必失聰」（舊 watcher 佔著 lock，新的自退 → 新 session 收不到主動喚醒）。

**量測推翻**（§3.3）：8 支 `claude.exe` 有 7 支是 8/19 起、從沒死過，8 支 watcher bash 同齡一一對應。
⇒ 用戶說的「重開 session」在**行程層面沒有發生**，是 `/clear`·`/compact`（同一行程）。
⇒ **這種情況下「覆蓋仍在」是正確的，系統現在健康、無孤兒、無失聰。**

**保留的部分**：那個判斷**目前無法被機器做出**（bash 分不出 `/clear` 和真重開），所以只能由 agent 猜，而它猜錯過。
R7 把這個判斷變成可計算的，**不是因為現在壞了，是因為現在無法被證明沒壞**。

## 1.5 八項總表 + 建議優先序

| 序 | # | 件 | 性質 | 改哪裡 |
|---|---|---|---|---|
| 1 | **R5** | 停滯偵測 v4（分類器，5 類） | **止血** | `watchdog.sh` 重寫 + `03b`/`03` 加 beacon 兩行 |
| 2 | **R4** | `COMMIT-NO-LETTER` 分類 | **止血** | 併在 R5 腳本內 |
| 3 | **R6** | 量測主張保鮮期（只綁新寫的） | **止血** | 寫作規則 + `stale-claims.sh` |
| 4 | **R7** | `session_id` 綁定 + 每 turn 閘（warn-only / fail-open） | 預防 | `inbox-watch.sh` + `handback-inbox.sh` |
| 5 | **R2+R3** | arm 搶佔式 + `SEEN` 落地 | 預防 | `inbox-watch.sh` / `watchdog.sh` / `tg_poll.py` |
| 6 | **R1** | `peers.sh` 註冊表 | 預防 | 新檔（純讀） |
| 7 | **O1** | 廢 `status/*.status.md` | 選配 | 先停更新義務 → 觀察一週 → 刪 |
| 8 | **O2** | `expect_min` 地板 | 選配 | 掛 `constitution_gate` 或新小 gate |

**用戶已拍板的參數**（不要再問他）：
`POLL=15min` / `T_DEAD=15min` / `T_UNRESP=1h` / `T_IDLE=1h` / `T_MAX_RUN=8h` / `RE_ARM=4h`
**喚醒對象 = blueprint 先判**，blueprint 判斷後才決定要不要推用戶。
**R6 只綁新寫的**，舊清單/意圖帳不溯改。

## 1.6 三件**不要**抄 evora 的

1. **不要 20KB 的 boot skill。** 它四個角色共用一份 generic body + 頂端 Bindings，但 Bindings 已經腫成 body（整套 bake sweep / screen script / 30 分鐘掃全塞進去）。我們 `docs/process/*` 12 檔 1190 行已經在同一條路上，抄它等於加速撞牆。
2. **不要把論證寫進資料檔。** `game-dev.yaml` 730 行有 ~330 行是 baseline 名冊，註解:資料 ≈ 4:1，每次爭論原地追寫、什麼都不刪。他們明明有 `D-xxx` decision id 卻還是把整段論證抄進 YAML。
3. **不要 claim event（認領前蓋章）。** 他們需要是因為同角色可多 session 搶同一 item；**我們角色是單例，搶不起來**。而且我們真正需要的資訊（誰在做哪條 slice）可以**推導**（worktree 存不存在 + branch + 最後 commit）——手寫蓋章正是 `status/*.status.md` 腐爛的同一個錯。

## 1.7 值得偷的核心（一句話版）

evora 那套的真價值不在 YAML，在**「宣告 / 武裝 / baseline」三態誠實**：敢寫下「這條宣告了但沒有東西在執行」，而不是假裝有守。

★ 我們 `docs/process/*` 現在**全部讀起來都像已武裝**，實際幾乎全靠 agent 自律。
**如果只能學一樣，學這個**：每條流程規則標上「有沒有東西在檢查它」，沒有的就明寫 `declared, unenforced`。

---

# §2 給 systems：工單草案

## 2.0 共通事實（後面各項引用，不重述）

**今日新驗（§3.1/§3.2）——這三個以前不知道，它們讓 R7/R1/R5b 從「難」變成「幾乎免費」**：

| 事實 | 值 | 取得方式 |
|---|---|---|
| hook stdin 是 JSON，含 `session_id` | 頂層 12 key，見 §3.1 | 三支現役 hook 已在讀 stdin（`longrun-qa-gate.sh:7`、`layer-check.sh:4`、`implementer-cleanup.sh:10`） |
| **Bash 環境直接有 `CLAUDE_CODE_SESSION_ID`** | `d70ec270-…` | `env`。★Monitor 與 Bash 同環境 ⇒ watcher 腳本直接讀，**零 plumbing** |
| **`CLAUDE_PID` 從外部查得到** | `24544` → `claude.exe` | `tasklist //NH //FI "PID eq $CLAUDE_PID"` ⇒ 「這支 watcher 的主人還活著嗎」**是可查事實** |
| `transcript_path` | `~/.claude/projects/A--GDS-demo/<session_id>.jsonl` | 其 mtime = 該 session 上次真的動的時間 |

**現行 lock 語意**：`.claude/hooks/.inbox-watch.<role>.lock` 內容 = watcher bash pid，每 `POLL` touch 一次。
**改版 lock 語意**：`<watcher_pid>\t<session_id>\t<claude_pid>`（R7）。

---

## P1 — R5 停滯偵測 v4（止血 · 最高序）

### 病

`watchdog.sh` 問的是「有沒有東西在動」（`:15-21` 三合一快照 md5，`:42-44` hash 不變才累計）。
⇒ **量測跑半天＝全靜＝被判停滯**。這是分類錯誤，不是門檻問題。

附帶三個小病：
- `:48` fire 後 `last_change=$now` → **每 5h 重響**（半 level-triggered，非 edge）
- `:19` git 信號取**全 ref**最新 commit → **merge 到 main 卻沒寫信，反而把警報壓住 1h**（見 P3）
- 只 blueprint arm（`session-role.sh:87-88`）

### 改法：從「計時器」改成「分類器」

**核心**：停滯不是靜止。**停滯是「有人在等一個不會來的東西」。**

```
1. DEAD-ROLE       有 open 信 && 收件角色 lock 死 && open > T_DEAD
                   → 🔴 ★獨立於 RUNNING（信給沒開的角色，不管別人在不在忙都是 bug）
2. RUNNING         長工作在跑 → 靜默（不管多久，除非撞 3）
3. RUNAWAY         RUNNING 且已超過 T_MAX_RUN → 🟠 可能掛死
4. UNRESPONSIVE    有 open 信 && 收件角色活著 && open > T_UNRESP → 🟡
5. COMMIT-NO-LETTER  見 P3
6. CHAIN-BROKEN    無 open 信 && 無長工作 && 全靜 > T_IDLE → 🟡
7. OK              靜默
```

### 「長工作在跑」怎麼判（三來源，任一為真）

**(a) 進程**：`ps -W | grep -qi godot`，fallback `tasklist //NH //FI "IMAGENAME eq Godot*"`
⚠ **未驗**：`ps -W` 抓不抓得到 `godot-detach.ps1` 用 WMI 起的 Godot。上線前跑一次確認。

**(b) 檔案活動**：`scripts/`、`docs/measurements/`、`.worktrees/` 內 10 分鐘有 mtime 變動

**(c) ★beacon（宣告式）**：`.claude/hooks/.busy.<role>` 內容 = unix 死線時戳
```bash
# 長工作開跑前（measurer / implementer）
echo $(( $(date +%s) + 28800 )) > .claude/hooks/.busy.measurer
# 跑完
rm -f .claude/hooks/.busy.measurer
```

★★ **beacon 的紀律（要寫進 doc，這是設計重點不是實作細節）**：
**beacon 只能「壓下」警報，永遠不能「製造」警報**；且**帶死線、會自動過期**。
⇒ 忘了刪 → 8h 後自動失效 → 回到 derived 判斷。忘了寫 → 只是多響一次。**兩個方向的錯都不致命。**
⇒ 通則：**手寫狀態只准存在於「會過期」的形式**。這樣可以拿到宣告式的準確度，而躲開「手寫狀態會腐爛」的刀（對照 O1 的 `status/*.status.md`，那是不會過期的手寫狀態，所以腐爛了）。

`.gitignore` 加：`.claude/hooks/.busy.*`

### 訊息：bash 算完整，不留給 LLM 再查一輪

喚醒對象是 blueprint（＝現行機制：stdout 一行喚醒 arm 它的 session）。
**正因為喚醒的是 LLM，訊息更要算完整** —— 目標是 blueprint **一輪短回合就能判**。

```
🔴 STALL / DEAD-ROLE
  measurer 沒開，2 封信在等它
  最老：2026-08-21-implementer-to-measurer-convoy-bed.md (open 3h12m)
  活著：blueprint systems reviewer qa implementer
  長工作：無
  最後 commit：2h05m 前 — "convoy drop驗收: 六站全零..."
  → 處置準則見 07_mailbox_trigger §stall
```

### blueprint 收到後的處置準則（寫進 `07_mailbox_trigger.md`）

| 收到 | 動作 |
|---|---|
| `DEAD-ROLE` | **推用戶**——只有他能開終端。訊息帶 `$env:SESSION_ROLE='<role>'; claude` |
| `UNRESPONSIVE` | 信是給我自己的 → 自己動。不是 → 寫信催該角色，**不推用戶**。同一封第二次才推 |
| `COMMIT-NO-LETTER` | 查 commit 是誰的活 → 寫信要他補推下一站 |
| `CHAIN-BROKEN` | 查最後一封信在等誰。等用戶裁 → 推；等角色 → 補寫下一站信；查不出 → 推用戶 |
| `RUNAWAY` | 推用戶（可能要殺 godot） |

★ 原則：**只有「開終端／WHAT 裁決／授權」才推用戶**，角色間能解的 blueprint 自己推鏈。

### 完整腳本

```bash
#!/usr/bin/env bash
# watchdog v4 — 停滯「分類器」（非計時器）。用戶定案 2026-08-21。
#
# v3 病：問「有沒有東西在動」→ 量測跑半天（全靜）被誤判成停滯。
# v4  ：問「有沒有人在等一個不會來的東西」。長工作在跑 = RUNNING = 永不報。
#
# fire = stdout（多行 200ms 內批成一則）→ 喚醒 arm 它的 session（blueprint）。
# blueprint 依 07_mailbox_trigger §stall 判斷後，才決定要不要推用戶。
#
# ★單例守衛「每 tick 重搶」，不是開機判一次（舊版 exit 0 走人 = 舊進程活著就永遠無法重新 arm）。
set -u

POLL_S="${WATCHDOG_POLL_S:-900}"          # 15 min
T_DEAD="${WATCHDOG_T_DEAD:-900}"          # 15 min  信給沒開的角色
T_UNRESP="${WATCHDOG_T_UNRESP:-3600}"     # 1 h     收件人活著卻沒消費
T_IDLE="${WATCHDOG_T_IDLE:-3600}"         # 1 h     無信、無工作、無 commit
T_MAX_RUN="${WATCHDOG_T_MAX_RUN:-28800}"  # 8 h     長工作疑似掛死
RE_ARM="${WATCHDOG_RE_ARM:-14400}"        # 4 h     同狀態持續才重提醒
LOCK_FRESH="${WATCHDOG_LOCK_FRESH:-140}"  # inbox-watch poll 20s + 120s 寬限
ROLES="blueprint systems reviewer qa measurer implementer"

_MAIN="$(dirname "$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" 2>/dev/null)"
ROOT="${_MAIN:-.}"
HB="$ROOT/docs/superpowers/handbacks"
HOOKD="$ROOT/.claude/hooks"
LOCK="$HOOKD/.watchdog.lock"
MYSID="${CLAUDE_CODE_SESSION_ID:-unknown}"
MYCPID="${CLAUDE_PID:-0}"

[ -d "$HB" ] || { echo "[watchdog v4] 無 $HB → 不啟動"; exit 0; }

dur() { local s=${1:-0}
  if [ "$s" -lt 3600 ]; then echo "$((s/60))m"; else echo "$((s/3600))h$(((s%3600)/60))m"; fi; }

# ── 單例：搶佔式（見 P5）。搶不到不退出，下 tick 再搶 ──────────────
claim_lock() {
  local cur; cur="$(cut -f1 "$LOCK" 2>/dev/null)"
  [ -n "$cur" ] && [ "$cur" != "$$" ] && {
    local age=$(( $(date +%s) - $(stat -c %Y "$LOCK" 2>/dev/null || echo 0) ))
    [ "$age" -lt $(( POLL_S + 120 )) ] && return 1
  }
  printf '%s\t%s\t%s\n' "$$" "$MYSID" "$MYCPID" > "$LOCK" 2>/dev/null
}

# ── S1 哪些角色活著 ───────────────────────────────────────────────
alive_roles() {
  local now r f out=""; now=$(date +%s)
  for r in $ROLES; do
    f="$HOOKD/.inbox-watch.$r.lock"; [ -f "$f" ] || continue
    [ $(( now - $(stat -c %Y "$f" 2>/dev/null || echo 0) )) -lt "$LOCK_FRESH" ] && out="$out $r"
  done
  echo "${out# }"
}

# ── S2 open 信：「秒齡<TAB>收件人<TAB>檔名」，最老在前 ────────────
open_letters() {
  shopt -s nullglob
  local files=("$HB"/*.md) now; [ "${#files[@]}" -eq 0 ] && return
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

# ── S3 長工作在跑？beacon 只壓警報、不造警報，帶死線自動過期 ──────
long_running() {
  local now f dl hit; now=$(date +%s)
  shopt -s nullglob
  for f in "$HOOKD"/.busy.*; do
    dl=$(cat "$f" 2>/dev/null || echo 0)
    case "$dl" in (*[!0-9]*|'') dl=0 ;; esac
    [ "$dl" -gt "$now" ] && { echo "beacon:${f##*/.busy.}"; return; }
  done
  ps -W 2>/dev/null | grep -qi godot && { echo "godot-proc"; return; }
  command -v tasklist >/dev/null 2>&1 &&
    tasklist //NH //FI "IMAGENAME eq Godot*" 2>/dev/null | grep -qi godot &&
    { echo "godot-proc"; return; }
  hit=$(find "$ROOT/scripts" "$ROOT/docs/measurements" "$ROOT/.worktrees" \
          -type f -mmin -10 -not -path '*/.git/*' -not -path '*/.godot/*' \
          -print -quit 2>/dev/null)
  [ -n "$hit" ] && echo "file-activity"
}

echo "[watchdog v4] ✅ ARMED sid=${MYSID} pid=$$（poll $(dur $POLL_S) / DEAD $(dur $T_DEAD) / UNRESP $(dur $T_UNRESP) / IDLE $(dur $T_IDLE) / MAXRUN $(dur $T_MAX_RUN)）"

last_class="OK"; last_fire=0; run_since=0
while true; do
  if ! claim_lock; then sleep "$POLL_S"; continue; fi

  now=$(date +%s)
  alive="$(alive_roles)"
  letters="$(open_letters)"
  running="$(long_running)"
  if [ -n "$running" ]; then [ "$run_since" -eq 0 ] && run_since=$now; else run_since=0; fi

  # git：兩個信號，不可混用
  any_ct=$(git -C "$ROOT" for-each-ref --sort=-committerdate --count=1 --format='%(committerdate:unix)' 2>/dev/null || echo 0)
  main_ct=$(git -C "$ROOT" log -1 --format=%ct main 2>/dev/null || echo 0)
  main_subj=$(git -C "$ROOT" log -1 --format=%s main 2>/dev/null)
  any_age=$(( now - ${any_ct:-0} ))

  newest_hb="$(ls -t "$HB"/*.md 2>/dev/null | head -1)"
  hb_ct=$(stat -c %Y "$newest_hb" 2>/dev/null || echo 0)
  hb_age=$(( now - hb_ct ))

  class="OK"; detail=""

  # 1) DEAD-ROLE — 獨立於 RUNNING
  while IFS=$'\t' read -r age to bn; do
    [ -z "$to" ] && continue
    [ "$age" -lt "$T_DEAD" ] && continue
    case " $alive " in *" $to "*) continue ;; esac
    class="DEAD-ROLE"; detail="  ${to} 沒開，最老的信 open $(dur "$age")：${bn}"; break
  done <<< "$letters"

  if [ "$class" = "OK" ]; then
    if [ -n "$running" ] && [ $(( now - run_since )) -ge "$T_MAX_RUN" ]; then
      class="RUNAWAY"; detail="  長工作已跑 $(dur $(( now - run_since )))（來源 ${running}）—— 疑似掛死"
    elif [ -n "$running" ]; then
      class="OK"                                   # ★量測跑半天走這條
    else
      first="$(head -1 <<< "$letters")"
      if [ -n "$first" ]; then
        a="${first%%	*}"; rest="${first#*	}"; to="${rest%%	*}"; bn="${rest##*	}"
        [ "$a" -ge "$T_UNRESP" ] &&
          { class="UNRESPONSIVE"; detail="  ${to} 活著但 ${bn} 已 open $(dur "$a") 沒消費"; }
      fi
      # 2) COMMIT-NO-LETTER（P3）
      if [ "$class" = "OK" ] && [ "${main_ct:-0}" -gt 0 ] \
         && [ "$hb_ct" -le "$main_ct" ] && [ $(( now - main_ct )) -ge "$T_IDLE" ]; then
        class="COMMIT-NO-LETTER"
        detail="  main 已落地 $(dur $(( now - main_ct )))，之後沒有任何新 handback
  最後 commit：${main_subj}
  → 有人出貨沒推下一站（違反無斷點自動鏈），鏈斷在他肚子裡"
      fi
      # 3) CHAIN-BROKEN
      if [ "$class" = "OK" ] && [ "$hb_age" -ge "$T_IDLE" ] && [ "$any_age" -ge "$T_IDLE" ]; then
        class="CHAIN-BROKEN"
        detail="  無 open 信、無長工作、全靜 $(dur "$hb_age")
  最後一封：$(basename "${newest_hb:-無}") —— 該有人接手卻沒有"
      fi
    fi
  fi

  if [ "$class" = "OK" ]; then
    last_class="OK"
  elif [ "$class" != "$last_class" ] || [ $(( now - last_fire )) -ge "$RE_ARM" ]; then
    case "$class" in DEAD-ROLE) icon="🔴" ;; RUNAWAY) icon="🟠" ;; *) icon="🟡" ;; esac
    echo "${icon} STALL / ${class}"
    echo "$detail"
    echo "  活著：${alive:-（無）}"
    echo "  長工作：${running:-無}"
    echo "  最後 commit(main)：$(dur $(( now - ${main_ct:-now} ))) 前 — ${main_subj}"
    echo "  → 處置準則見 07_mailbox_trigger §stall。只有「開終端／WHAT 裁決／授權」才推用戶。"
    last_class="$class"; last_fire=$now
  fi

  touch "$LOCK" 2>/dev/null
  sleep "$POLL_S"
done
```

### R5b（R7 落地後的加強，可分開做）

R7 之後 lock 帶 `session_id` ⇒ 可推出該角色的 `transcript_path`
（`~/.claude/projects/A--GDS-demo/<session_id>.jsonl`）⇒ **stat 它的 mtime = 該 session 上次真的動的時間**。

⇒ `CHAIN-BROKEN` 的訊息從「全靜 47m」升級成「**systems 的 transcript 已 3h 沒動**」——直接指名。
（這正是 evora 的 `roles.sh` 用的判準：liveness 靠 session 自己的 transcript 新鮮度。）

### 驗收

- 起一個假長工作（`touch .busy.measurer` 帶死線）→ 讓全場靜 2h → **不得報 STALL**
- 刪 beacon、無 godot、無檔案活動 → 靜 1h → 必須報 `CHAIN-BROKEN`
- 寫一封 `to:` 一個沒開的角色的 open 信 → 15 分鐘內必須報 `DEAD-ROLE`（**即使同時有長工作在跑**）
- 同一 class 連續成立 → **4h 內只響一次**

---

## P2 — R6 量測主張保鮮期（止血）

### 病

`00_roles.md:129-131`「量測可溯源鐵律」已要求：原始輸出落地 + 引數字附來源檔:行 + 標 commit hash。
**但它管的是「寫進去那一刻」，不管「三天後還在被引用」。**

⇒ **D1 血證**：`統領 0.08` 當初**完全合規**寫入，之後被當成世界的性質掛在清單上數日，
今日實測 `AT_CAP=0.0%` / `eff_pop_cap median=15` / 統領 `0.600` → 因果鏈死掉，差點買下一整個 arc。

★ 這跟「狀態不准手寫、要推導」是**同一條規則升一層**：
手寫的 `status: done` 會過期 —— 這條我們懂。
**手寫的「量測數字」一樣會過期，而且更毒，因為它讀起來像事實不像狀態。**

（evora 自己也踩過同一隻：`game-dev.yaml` 的 `accept` 註解裡，同一個量一天內出現 213/212/217/220 四個數，
舊防線宣稱「測試會 print 所以不會偷偷過期」，實測測試根本沒斷言任何字面數。他們的結論是
**「PRINTING IS NOT NOTICING」**，然後**只修了那一格**、沒有推廣。）

### 主張分三級 —— 混級才是病

| 級 | 例 | 過期？ | 引用時必帶 |
|---|---|---|---|
| **結構** | 「這步存在／這角色 owner 它」 | 不會（重讀宣告即可驗） | 位置（file:line） |
| **量測** | 「統領 0.08」「71 筆」「AT_CAP 0.0%」 | **會** | **commit ＋ 日期 ＋ 重跑指令** |
| **裁定** | owner 拍板 | 不會，直到被新裁定推翻 | 日期 ＋ 原話 |

★★ **真正的毒是「裁定建立在量測上」**：裁定被標成不過期，但它的地基會過期，
**而這件事在檔面上完全看不見**。D1 就是——一個排程裁定（「它是長桿」）繼承了一個量測（0.08）的保鮮期。

### 改法（只綁新寫的，舊的不溯改）

**① 格式**：清單／意圖帳／spec 引用量測數字時：
```
AT_CAP=0.0% @ee5e879f 2026-08-21 · repro: `.\tools\godot.ps1 --headless --script scripts/debug/<bed>.gd`
```

**② 裁定要標地基**：
```
D1 降為非擋考 —— 裁定 2026-08-21，地基＝AT_CAP 量測 @ee5e879f
```
⇒ 地基過期 → 裁定自動進複查名單。

**③ `stale-claims.sh`**（新檔）：掃這些標記，印出 `> N 天` 或 `commit 已落後 main M 個 commit` 的。
接進 `09_exam_gate` 的開考前置閘：**考卷清單裡任何一項的地基過期 → 該項標「地基待重驗」**。

**④ 不溯改**：舊清單/意圖帳沒有標記 = 不掃。理由同 evora「回溯武裝一個不可能失敗的斷言是結構性空洞」——
以及更實際的：一次補 1293 handback + 142 spec 不可能且沒價值。

### 驗收
- `stale-claims.sh` 對今日新寫的 D1 條目能正確印出年齡
- 舊條目不噴任何噪音

---

## P3 — R4 `COMMIT-NO-LETTER`（止血，併在 P1 腳本內）

### 病（★這是我在寫 v4 時發現的，v3 也有）

`watchdog.sh:19` 取**全 ref** 最新 commit 當「有活動」。
⇒ 有人 merge 到 main 卻沒寫信（＝違反 `00_roles §無斷點自動鏈`，鏈斷了），
**git 信號被重置 → 警報被壓住一小時。出貨不寫信這件事，反而讓偵測器閉嘴。**

### 改法：git 信號拆兩個，用途不可混

| 信號 | 用途 |
|---|---|
| `any_ct`（全 ref 最新） | **活動證明** —— implementer 在 feat branch 逐步 commit ＝ 正在工作，壓 `CHAIN-BROKEN` ✅ 正確 |
| `main_ct`（只看 main） | **出貨事件** —— main 動了 ＝ 有東西落地 ＝ **必須有下一站的信** |

規則：`main` 動了 && 之後沒有任何新 handback && 超過 `T_IDLE` → `COMMIT-NO-LETTER`。

### ★為什麼不做「commit 喚醒全員」（evora 的作法）

evora 的 wake loop 監看 git HEAD，**commit 本身就是廣播**。但那套在我們這裡不成立：
1. 我們的鏈是**信驅動**的，commit 沒帶路由資訊（給誰、下一步做什麼），信才有。
2. 我們 implementer 是**逐步 commit** —— 每個 commit 喚醒 6 個 session ＝ 災難。

⇒ **零額外喚醒**（只在真違規時響），抓到的卻是我們流程裡最容易靜默發生的斷鏈。

---

## P4 — R7 `session_id` 綁定 + 每 turn 閘（預防）

### 病

`SESSION_ROLE` 是開窗時打的字，**沒有任何東西驗過**。
更實際的傷害：arm 守衛只印一句 `已有實例在跑 → 退出(免重複)`，**剩下交給 agent 猜**。

用戶觀察到的兩種結局（**同一則訊息，相反處置**）：

| 判讀 | 後果 |
|---|---|
| 「覆蓋仍在」→ 不動 | 若真是重開 → 靜默失聰 |
| 「舊進程卡住」→ 殺掉重 arm | **今日量測：那些 watcher 全是健康的 ⇒ 誤殺白做工** |

★ 病根：**把一個機器該做的判斷，外包給一個拿不到資料的 agent。**
正確答案取決於「這支 watcher 屬不屬於本 session」—— 而 bash 以前查不到。**現在查得到了。**

### 改法

lock 內容：`<watcher_pid>\t<session_id>\t<claude_pid>`（`$CLAUDE_CODE_SESSION_ID` / `$CLAUDE_PID` 直接讀，見 §2.0）

**arm 時的決策表**：

| lock 裡的 session_id | watcher pid 活著？ | 處置 | 訊息 |
|---|---|---|---|
| **== 我的** | 是 | **安靜退出** | `✅ 覆蓋仍在（同 session，watcher pid=X 存活，已驗）` |
| == 我的 | 否 | 接手 | `✅ ARMED（前任同 session 但已死）` |
| **≠ 我的** | — | **搶佔**（P5） | `✅ ARMED（前任屬 session <id> 之 watcher，將自退）` |

⇒ 三件事一次解決：
1. **「覆蓋仍在」從猜測變成可驗證的事實** —— 手動殺進程這件事消失
2. **`/clear`·`/compact` 不再需要搶佔** → P5 的 `SEEN` 重吐風暴根本不會發生
3. 真重開必定接手

**每 turn 閘**（掛進**已經在跑的** `handback-inbox.sh`，約 5 行）：
```
lock 不存在 / mtime 過舊 / session_id 不是我 → 注入：
⛔ 本 session 的信箱 watcher 沒在跑，你收不到主動喚醒。請重 arm。
```
⇒ 失聰從「幾小時後才發現」變成「下一次你打字就知道」。

### ★★兩條紀律（不可妥協）

1. **只警告，絕不阻擋。** evora 的閘會「在第三個 prompt 擋下」——**我們不要**。閘門自己有 bug 就 brick 六個 session。
2. **fail-open。** 拿不到 `CLAUDE_CODE_SESSION_ID` 就退回現行行為，**絕不因為讀不到就報警**。

### 驗收
- `/clear` 後重 arm → 印「覆蓋仍在（已驗）」，且**舊 watcher 不死**
- 手動 kill 舊 watcher 後重 arm → 印「ARMED（前任同 session 但已死）」
- 每 turn 閘：手動 kill watcher → 下一次打字必須看到 ⛔

---

## P5 — R2+R3 arm 搶佔式 + `SEEN` 落地（預防）

### 病

`inbox-watch.sh:36-43` / `watchdog.sh:25-33`：**開機判一次，`exit 0` 走人**。
舊進程每 20s（watchdog 300s）touch → **lock 永遠新鮮 → 只要舊進程活著，就永遠沒辦法合法重新 arm**。
唯一出路是手動殺（見 P4）。

### 改法：不比誰心跳新，比誰後 arm

```bash
# arm：無條件宣告當家（P4 的決策表先跑；同 session 且存活則不走這條）
prev="$(cut -f1 "$LOCK" 2>/dev/null || echo 無)"
printf '%s\t%s\t%s\n' "$$" "$MYSID" "$MYCPID" > "$LOCK"
echo "[inbox-watch] ✅ ARMED role=${ROLE_KEY} pid=$$ sid=${MYSID}（前任 pid=${prev}，下輪自退）"

while true; do
  cur="$(cut -f1 "$LOCK" 2>/dev/null)"
  if [ "$cur" != "$$" ]; then
    echo "[inbox-watch] ⛔ 讓位：有更新的 ${ROLE_KEY} watcher（pid=${cur}）→ 本實例退出"
    exit 0
  fi
  ... 原掃信邏輯不動 ...
  touch "$LOCK"; sleep "$POLL_S"
done
```

| | 舊（stale 判定） | 新（搶佔） |
|---|---|---|
| 重新 arm | 舊進程活著＝**永遠被拒** | **一定成功** |
| 孤兒 | 永遠佔著 lock | **自己清掉自己**（下一輪讀到不是自己就 exit） |
| 同角色雙開 | 後開的**靜默聾掉** | 後開的當家，**前一個印一行明說被取代** |
| stale 常數 | 要調（140s / 420s） | **整段刪掉** |
| 程式碼量 | — | **更短** |

★ 取捨要記下來：**新的一定贏**。若誤開第二個同角色 session，被踢的是舊的（可能才是正在工作的那個）。
但它會印出讓位訊息 → 看得見。比現行「新的靜默聾掉、什麼都不知道」好。
土法分辨：**5 分鐘內看到第二次「讓位」= 真的有另一個同角色 session 活著**。

### ★兩處配套（沒有這兩處，搶佔會製造新病）

**① `SEEN` 落地成檔**：`.claude/hooks/.inbox-seen.<role>`（gitignore）
新 watcher 開場先讀 → 繼承前任吐過什麼 → **重 arm 不重吐**。
每輪把檔重寫成「目前仍 open 的信」那一小撮 → 大小被 open 數綁住，不會長。

**② 刪掉 `first_pass` 的 `[開場既存]` 全量吐**（`inbox-watch.sh:63`）
那件事**本來就有人做了，而且做得更好**：
- `session-role.sh:54-59` → SessionStart 注入 📬 待辦清單
- `handback-inbox.sh` → **每 turn** 掃並注入

⇒ Monitor 吐開場 backlog 是**冗餘**。刪掉不損失覆蓋，還消滅重吐來源。
**改完後 Monitor 只做一件事：吐真正新到的信。**

（沒有這兩處的話，auto-compact → 重 arm → SEEN 空 → 全部 open 信重吐 → 每封一次喚醒 → ctx 又漲 → 再 compact … 會自我循環。）

### ③ 順手補一個 singleton 治不了的洞

`07_mailbox_trigger §status 所有權` 記載過：**寄件端誤寫 `consumed`** → 那封信永遠不會被吐，靜默漏看。
單例守衛完全擋不住。便宜補法 —— 過濾條件從
```
to:我 && status:open
```
改成
```
to:我 && ( status:open || mtime > 本 watcher 啟動時間 )
```
⇒ 啟動後才被寫成 consumed 的信仍會被吐一次（`SEEN` 保證不重吐）；1293 封歷史信不受影響。

### ④ `tg_poll.py` 同樣處理

**最該做的一支** —— `getUpdates` 是**帶 offset 的獨佔消費**：
一支讀取端已死的 poller 會把用戶的 Telegram 訊息吃掉並丟進虛空，而且不冒煙。
（evora 作者記錄過完全相同的事故：2026-07-27 router 鎖被孤兒佔住 → 訊息停止抵達 → 沒有任何東西在冒煙。）

---

## P6 — R1 `peers.sh` 註冊表（預防，純讀）

`.claude/hooks/.inbox-watch.<role>.lock`（pid + 每 20s touch）**本來就是租約**，只是沒人讀。

新增 `peers.sh`（~25 行，純讀零副作用）：對每個角色印
`role / watcher_pid / session_id / claude_pid / 心跳幾秒前 / claude.exe 是否存活`。

用途：
- `session-role.sh` 開場**append** 一段 peer 表（★只用 append，不動既有文字——這是唯一的六角色共用件）
- P1 的 `DEAD-ROLE` 分類吃同一份資料
- 你（用戶）隨時可查「現在誰在線」

---

## O1 —（選配）廢 `status/*.status.md`

**現況**：宣稱是「即時狀態快照」（`00_roles:94-95`），實際：

| 檔 | 大小 | 最後更新 |
|---|---|---|
| `02_reviewer` | 153 KB | 8/20 23:47 |
| `03b_measurer` | 76 KB | 8/21 00:34 |
| `00_blueprint` | 4 KB | 8/20 18:07 |
| `03_implementer` | 87 KB | **8/5（16 天）** |
| `04_qa` | 42 KB | **8/14（7 天）** |

frontmatter grep 還能跑，但**兩個角色的狀態不可信**，且檔案已從「快照」變成 append log。

★ 對照 P1 的 beacon 紀律：**這是「不會過期的手寫狀態」，所以腐爛了**。beacon 帶死線所以不會。

**建議**：先停更新義務 → 觀察一週沒人 miss → 刪。（v3 watchdog 的 snapshot 讀它，v4 已不讀，無連動。）

---

## O2 —（選配）`expect_min` 地板

evora 每個 glob 母體都帶下限，**glob 壞掉 → 母體塌到 0 → exit 2 紅燈，不是「0 violations = 綠」**。

這正是我們 memory `feedback_intent_ledger_negative_assertion` 那條血證的機械化解法
（`grep|head` 截斷成假窮盡、~10 處實際 47 站）—— **我們寫成紀律，他們做成 schema 欄位。**

掛在 `constitution_gate` 或新的小 gate：每個普查帶下限。

---

## 2.9 上線順序

**無痛的三個原理**：
1. **hook 改動只在新 session 生效** → 現行六個終端不用重開、不受影響。天然灰度。
2. 每步單檔、可獨立 revert。
3. 先做「純讀」和「刪」，後做「改行為」。

| 階段 | 動作 | 風險 | 備註 |
|---|---|---|---|
| 0 | **驗 `ps -W` 抓不抓得到 WMI-detach 的 Godot** | 零 | P1 唯一未驗項。抓不到就靠 beacon + file-activity（設計已容錯） |
| 1 | `peers.sh`（純讀，不接任何 hook） | 零 | 不改任何現有行為 |
| 2 | `watchdog.sh` → v4（含 `COMMIT-NO-LETTER`）+ beacon 兩行寫進 `03b`/`03` + `.gitignore` | 低 | 單檔、只 blueprint arm、壞了 revert |
| 3 | R6 保鮮期格式 + `stale-claims.sh` | 低 | 只綁新寫的 |
| 4 | `inbox-watch.sh` → P4 決策表 + P5 搶佔 + `SEEN` 落地 + 刪 `first_pass` | **中** | 一批改完，別拆 |
| 5 | `handback-inbox.sh` 加每 turn 閘（warn-only / fail-open） | 低 | |
| 6 | `session-role.sh` **append** peer 表 + `✅ ARMED` 自測指示 | 低 | ★唯一六角色共用件，只 append |
| 7 | `tg_poll.py` 搶佔 | 低 | |
| 8 | O1 停更 → 觀察一週 → 刪 | 低 | |
| 9 | O2 `expect_min` | 低 | |

**建議停損點**：做完 **0–3** 就治掉三個止血項。4–9 是預防，可以慢慢來。

⚠ **階段 4 因為 doc 和腳本必須同批改（`00_roles §生命週期`／`07 §status 所有權` 的語意會動），整包給 systems，不要拆。**

## 2.10 `session-role.sh` 要加的一句（配合 P4/P5）

> arm 完必須看到 `✅ ARMED role=<你> pid=<n>` 或 `✅ 覆蓋仍在（已驗）`。
> **沒看到那兩行之一就是沒 arm 成功** —— 不要自己解釋成「已有實例覆蓋」，那句話在真重開時不成立。

★ 通則（值得進 `docs/process/`）：
**守衛不要輸出「需要被解讀的狀態」，要輸出「已經處置完的結果」。**
`已有實例在跑 → 退出` 是狀態，agent 得猜下一步。
`✅ ARMED（前任將自退）` 是結果，沒有東西要猜。

---

# §3 附錄：量測原始數據

全部量於 **2026-08-21 02:34 / HEAD `ee5e879f` / clean**。

## 3.1 hook stdin payload（PostToolUse）

驗法：暫時在 `longrun-qa-gate.sh:7` `cmd=$(cat)` 之後加一行 dump 到暫存區 → 跑一個 Bash → 讀 → **立即還原**（`git diff` 已確認空）。

頂層 key：
```
cwd  duration_ms  effort  hook_event_name  permission_mode
prompt_id  session_id  tool_input  tool_name  tool_response  tool_use_id  transcript_path
```
```
session_id      = 'd70ec270-9219-4b08-9bd9-63cee13472a4'
transcript_path = 'C:\Users\I12\.claude\projects\A--GDS-demo\d70ec270-….jsonl'
cwd             = 'A:\GDS\demo'
```
★ 三支現役 hook 早就在讀 stdin：`longrun-qa-gate.sh:7`、`layer-check.sh:4`、`implementer-cleanup.sh:10-15`（後者用 python 解 JSON 讀 `stop_hook_active`）。

## 3.2 Bash 環境變數（★更好用，不必走 hook）

```
CLAUDE_CODE_SESSION_ID=d70ec270-9219-4b08-9bd9-63cee13472a4
CLAUDE_PID=24544
SESSION_ROLE=blueprint
CLAUDE_CODE_ENTRYPOINT=cli
```
`CLAUDE_PID` 外部可查：
```
$ tasklist //NH //FI "PID eq 24544"
claude.exe   24544  Console  1  517,092 K
```
Monitor 與 Bash 同環境 ⇒ watcher 腳本直接 `$CLAUDE_CODE_SESSION_ID` / `$CLAUDE_PID`。

## 3.3 行程盤點（★推翻「真重開必失聰」的那一組）

```
claude.exe      ：8 支 —— 7 支 Aug 19，1 支 02:34 當日（本影子 session）
watcher bash    ：8 支 —— 全部 Aug 19（6 角色 inbox-watch + watchdog + tg_poll）
lock 心跳       ：全部 < 20s（watchdog < 300s）
```
lock pid：`blueprint 8304 / systems 13265 / reviewer 11637 / qa 11819 / measurer 11940 / implementer 12069 / watchdog 8373 / tg_poll(python) 8789`

⇒ **7 個 CC 行程從 8/19 沒死過，watcher 一一對應同齡。無孤兒、無失聰。**
⇒ 用戶說的「今天重開 6 session」在行程層面沒發生 ＝ `/clear`·`/compact`。**該情況下「覆蓋仍在」正確。**

## 3.4 現行資產規模

```
handbacks : 1293 檔（扁平目錄，無 index、無 item id、無排序欄）
specs     :  142 檔
verdicts  :   60 檔
docs/process : 12 個 .md 共 1190 行（+ metrics.jsonl 198 行）
```

## 3.5 常數（現行）

| 腳本 | POLL | STALE 判定 |
|---|---|---|
| `inbox-watch.sh` | 20s (`:18`) | `POLL+120` = 140s (`:38`) |
| `watchdog.sh` | 300s (`:8`) | `POLL+120` = 420s (`:27`) |

⇒ 舊進程每 20s / 300s touch ⇒ **lock 永遠新鮮 ⇒ 重新 arm 永遠被拒**（P5 的病根）。

---

# §4 對照來源與「不抄」清單

## 4.1 evora-world 的真本事（三個）

1. **「印出來的 contract 贏過記憶」** —— 對 compact/失憶最硬的解法。我們是反過來：靠「開場重讀你那格 docs」＝靠人記得＋靠 doc 沒 drift。
2. **idle poller + 「correctly blocked 不是休息處」** —— 他們記了血案：2026-08-14/15 全角色阻塞、**每個阻塞單獨看都合法**、session 寫下「系統已收斂成等他」然後靜默四小時。★**個別判斷全對、總和是專案停擺。**
3. **狀態＝檔名 / 衍生欄位禁手寫** —— 消滅「兩個真相來源打架」。

## 4.2 但他們的 idle poller 對我們太貴（用戶明確否決）

**輪詢本身免費，貴的是「喚醒」** —— 每次喚醒＝一個持久 session 重讀全部 context。
他們 manager 還有一條**30 分鐘無條件推進掃**（不管有沒有事、照時鐘走六點走查）＝ 一天 48 輪全 context。

⇒ 我們的 R5 是它的**便宜版**：edge-triggered（一次停滯一次響）、只 blueprint arm、
bash 把判斷算完整、**長工作在跑就永不報**。

## 4.3 不抄清單（理由見 §1.6）

- ❌ 20KB boot skill（Bindings 已腫成 body）
- ❌ 把論證寫進資料檔（`game-dev.yaml` 730 行 / ~330 行是 baseline 名冊）
- ❌ claim event（我們角色單例，且狀態可推導）
- ❌ 會「擋下」的開機閘門（我們 warn-only / fail-open）

## 4.4 若只能學一樣

**「宣告 / 武裝 / baseline」三態誠實。**
`docs/process/*` 現在全部讀起來都像已武裝，實際幾乎全靠 agent 自律。
每條流程規則標上「有沒有東西在檢查它」，沒有的就明寫 **`declared, unenforced`**。
