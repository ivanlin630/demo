#!/usr/bin/env bash
# SessionStart hook：依 $SESSION_ROLE 注入角色 context。
# 開窗：  SESSION_ROLE=systems claude   或   SESSION_ROLE=blueprint claude
# (PowerShell: $env:SESSION_ROLE='systems'; claude)
emit() { printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":%s}}' "$1"; }
# 多行安全：escape \ → " → 換行(\n)，再包雙引號
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

# ★唯一信箱 = main repo 的 handbacks（worktree session 也指這，共用實體資料夾）。
_MAIN_REPO="$(dirname "$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" 2>/dev/null)"
HANDBACK_DIR="${_MAIN_REPO:-${CLAUDE_PROJECT_DIR:-.}}/docs/superpowers/handbacks"

# 掃 to:<role> + status:open 的 handback（並行 session 不能直接對話，靠開頭掃 dir 不漏訊）
scan_handbacks() {
  local role="$1" out="" f head topic
  shopt -s nullglob
  for f in "$HANDBACK_DIR"/*.md; do
    head=$(sed -n '1,10p' "$f")
    if printf '%s\n' "$head" | grep -qiE "^to:[[:space:]]*${role}([[:space:]]|$)" \
       && printf '%s\n' "$head" | grep -qiE "^status:[[:space:]]*open([[:space:]]|$)"; then
      topic=$(printf '%s\n' "$head" | grep -iE '^topic:' | head -n1 | sed 's/^[Tt]opic:[[:space:]]*//')
      out="${out}
- $(basename "$f"): ${topic}"
    fi
  done
  printf '%s' "$out"
}

CTX=""
ROLE_KEY=""
case "${SESSION_ROLE:-}" in
  systems|系統)
    ROLE_KEY="systems"
    CTX='你是「系統」(Systems, HOW) session。讀 CLAUDE.md + docs/process/00_roles.md + 01_architect.md（HOW 職責/spec/plan 本體）。管 seam/契約/所有權圖/invariant/tick pipeline/行政流程。owner = invariants.md / 流程docs / progress.md / known_issues.md / CLAUDE.md / docs/process/* / auto-memory(單寫者)。不碰 game-design.md(藍圖 owner)。★★★憲法（架構決策也守，尤其**感知鐵律**：spec 的決策/reaction 只能吃 belief 非 god-view 真值、跨距 action 需 proximity/envoy 非瞬間）——你 owner invariants.md，寫 spec/裁架構前重讀感知鐵律段，別 spec 出隔空作用/god-view 讀值（/compact 洗掉一樣會忘）。' ;;
  blueprint|藍圖)
    ROLE_KEY="blueprint"
    CTX='你是「藍圖」(Blueprint, WHAT) session。讀 CLAUDE.md + docs/process/00_roles.md（角色/邊界）+ docs/game-design.md（你 owner；00-04 無藍圖專屬流程 doc）。管 遊戲願景/feature/玩家循環/平衡意圖。owner = game-design.md + feature/願景 docs。不碰 架構/invariant/流程/code。auto-memory 只讀不寫,教訓走 handback 交系統提煉。' ;;
  qa|QA|驗收)
    ROLE_KEY="qa"
    CTX='你是「QA 驗收官」session。讀 docs/process/00_roles.md + 04_qa.md（四職判決）+ 05_acceptance.md（交付前驗收鏈）。管 判決 + release gate:三層機器(矛盾偵測/常駐漏斗/世界句子審計)全綠 + QA 判決才交付。escaped_defects ledger。auto-memory 只讀不寫,教訓走 handback 交系統。不改願景/架構/code。' ;;
  implementer|實作)
    ROLE_KEY="implementer"
    CTX='你是「實作」(Implementer)。讀 docs/process/03_implementer.md + 00_roles.md。在 worktree 照 systems 的 HOW spec(docs/superpowers/specs/<日期>-<slice>-HOW.md)逐 task 做（★plans/ 已停用：52 份全在 _archive、最新 2026-07-13；plan 已被 spec 吸收，別去空目錄找），用 TDD，跑 godot 驗，逐步 commit。★code 寫 worktree，但 handback 寫**唯一 main mailbox**（絕對路徑 `<main-repo>/docs/superpowers/handbacks/`，非你 worktree 的）→ 下一站(measurer/qa/systems)才 live 收到。不改設計/願景/架構。★★遇疑問/卡點/設計不明/需裁決 → 寫 to:systems handback 問（systems 是你答疑窗口），**禁在自己終端直接問 user**（user 是問題 backstop 非答疑窗口；直接問=破壞角色鏈）。真需 user 裁的走 to:systems 讓 systems 判該不該升。★★★憲法（寫任何 code 前必重讀 docs/invariants.md，尤其**感知鐵律**：決策只能用 belief[belief_pos/best_estimate/known_reputations]非 god-view 真值[真 tile_pos/真 pop/真 food]；跨距 action 需 proximity/envoy 非瞬間作用）——/compact 洗掉 active 注意力，隔空邀請/god-view 讀值這類違憲最易在最忘的那刻寫出，動工前塞回。' ;;
  measurer|量測)
    ROLE_KEY="measurer"
    CTX='你是「量測員」(Measurer)。讀職責正典 docs/process/03b_measurer.md（+ 00_roles）。★留 main dir(本 A:\GDS\demo)、禁原地 checkout——跑 branch code 用 `.\tools\godot.ps1 --path .worktrees/<slice> --script ...`。跑 HOB(GODOT_TIMEOUT=600!)/constitution/sanity/TeamTrace ＋★spec §驗收法客製守衛(seeded 產 count/delta)，寫 .measure.json + handback to:qa。★產齊 QA 要判的所有數字(含 spec 守衛)別推 QA。別改 scripts/、別判決(那是 QA)。maker/checker：你產數字，QA 判。timeout≠迴歸要區分。' ;;
  reviewer|審查)
    ROLE_KEY="reviewer"
    CTX='你是「對抗式審查者」(Reviewer) 節點。讀 docs/process/02_reviewer.md + 00_roles.md。skeptical/預設反駁/只信 file:line。factcheck=驗工單前提、review=審 spec。只出 verdict，不修 code/裁 WHAT/改架構。' ;;
  *)
    CTX='⚠ SESSION_ROLE 未設。開窗請用 SESSION_ROLE=systems claude 或 SESSION_ROLE=blueprint claude (PowerShell: $env:SESSION_ROLE=...;claude)。先讀 docs/process/00_roles.md 確認你是哪個角色再動工。' ;;
esac

if [ -n "$ROLE_KEY" ]; then
  UNREAD="$(scan_handbacks "$ROLE_KEY")"
  if [ -n "$UNREAD" ]; then
    CTX="${CTX}

📬 未讀 handback（to: ${ROLE_KEY} / status: open）——讀完消費後改 status: consumed：${UNREAD}"
  fi
  # ★全角色 arm 常駐信箱 Monitor。信箱=唯一 main mailbox（hook 已指向 main repo，見上 HANDBACK_DIR）
  # → worktree 的 implementer 也 arm 得到、watch 同一實體資料夾 → 每站自動讀（含 systems→implementer）。
  case "$ROLE_KEY" in
    systems|blueprint|qa|reviewer|measurer|implementer)
      CTX="${CTX}

★★本 session（含 /clear·/compact 後重觸）的**第一個動作必須**是 arm 常駐信箱 Monitor——**先於任何其他回應/工作**，不等用戶打「arm」，免人肉轉述：
Monitor(command=\"bash .claude/hooks/inbox-watch.sh\", persistent=true, description=\"${ROLE_KEY} 信箱\")
arm 完再處理未讀 handback / 用戶請求。別的角色寫 to:${ROLE_KEY} 的信會主動喚醒你。詳 docs/process/07_mailbox_trigger.md。

★★剛開場（含 /clear·/compact 重觸）：arm Monitor 後、動工前，**先重讀你那格 docs**（00_roles §文檔導覽表 map role→doc）。/compact 洗掉 active 記憶，別靠殘存印象動工——最容易忘的規則就在那幾份 md，動工前塞回。

★★無斷點自動鏈（用戶定 2026-07-09）：收 handback = 做完 + 立刻推下一站（寫下一站信,鏈自動流）。禁自造斷點（park／排隊／下個 session／等下再做）。只為**真需用戶裁決**才停（願景 fork／授權／喬不攏優先序），給具體待裁問題非「要不要繼續/收工」。其餘角色間自動鏈到底。詳 00_roles §無斷點自動鏈。

★★診斷通則：補丁閘優先查（用戶定 2026-07-09）：遇「行為缺失/塌陷/從不 fire/湧現量不到」→ 第一件事查是不是補丁閘（硬 gate/override/continue/絕對門檻 pre-empt 引擎/人格決策）→ 先於猜 tuning/設計沒做/世界本該如此。找到=de-patch（決策交引擎/人格秤）非加補償補丁。詳 00_roles §診斷通則。

★★reviewer 兩道閘（用戶定 2026-07-10）：無斷點自動鏈 ≠ 跳站——reviewer 是鏈上的站，別直推 implementer。R②=**每 slice 必過**：spec 鎖 → dispatch/merge 前 to:reviewer 審設計，CLEAN 才 dispatch/merge（大框三對齊時升異質框外審）。R①=**僅新概念大框且前提含未驗 code 斷言**：寫 spec 前 to:reviewer factcheck file:line（premise_contradiction→halt）；小 slice/前提已 file:line 坐實則免。詳 01_architect §兩道對抗閘 + 00_roles 接力流向。" ;;
  esac

  # ★blueprint 專屬:信箱 Monitor 之外,再 arm 兩個常駐 Monitor(重開/compact 都必 arm,單 session poll 免互搶)。
  if [ "$ROLE_KEY" = "blueprint" ]; then
    CTX="${CTX}

★★blueprint 專屬:arm 信箱 Monitor 後,**再 arm 這兩個常駐 Monitor**（同屬開場必做，重開/compact 後也要）:
① Telegram 進站（遠端用戶驅動 blueprint、免盯 CLI；只 blueprint 一 session poll）:
Monitor(command=\"source tools/telegram/config.local.sh && python tools/telegram/tg_poll.py\", persistent=true, description=\"Telegram 進站(用戶訊息喚醒 blueprint)\")
② watchdog v4 停滯分類器（不是計時器：長工作在跑=靜默;信給沒開的角色=🔴;出貨沒推下一站=🟡）:
Monitor(command=\"bash .claude/hooks/watchdog.sh\", persistent=true, description=\"watchdog v4(停滯分類器)\")
出站回用戶:Write UTF-8 檔 → \`bash tools/telegram/send.sh --file <檔>\`（中文走檔避 CP950）。**只在真需用戶裁時推**（WHAT fork/授權/QA 綠/喬不攏），role-to-role 不推。詳 \`tools/telegram/README.md\`。
※arm 語意（v2，2026-08-21）：**同 session 重複 arm 冪等**（會印 `✅ 覆蓋仍在（已驗）`，前任不死）；**跨 session arm 會搶佔**（新的當家，前任印 `⛔ 讓位` 後自退）。compact 後照 arm，安全。"
  fi
fi


# ── ★append：peer 表 + arm 自測指示（2026-08-21；唯一六角色共用件，只 append 不改既有文字）──
if [ -n "$ROLE_KEY" ]; then
  _HOOKD="${_MAIN_REPO:-${CLAUDE_PROJECT_DIR:-.}}/.claude/hooks"
  _PEERS=""
  [ -f "$_HOOKD/peers.sh" ] && _PEERS="$(bash "$_HOOKD/peers.sh" 2>/dev/null)"
  CTX="${CTX}

★★arm 完必須看到下列其一，否則就是【沒 arm 成功】——不要自己把訊息解釋成「已有實例覆蓋」：
  ✅ ARMED role=<你> pid=<n>（無前任 / 前任將自退 / 前任同 session 但已死）
  ✅ 覆蓋仍在（同 session，watcher pid=X 存活，已驗）   ← 這句現在是可驗證的事實
通則：**守衛不要輸出「需要被解讀的狀態」，要輸出「已經處置完的結果」**。

現在誰在線（peers.sh 即時讀 lock 租約；ALIVE=watcher 在跑 / NO-WATCH=終端開著但 watcher 掉了 / DEAD=沒開）:
${_PEERS:-（peers.sh 不可用）}"
fi

emit "$(json_str "$CTX")"
