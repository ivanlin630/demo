# CLAUDE.md — 專案工作指引

## 專案定位

Godot 4.2.2 GDScript 世界模擬器。

## 常用指令

**用 wrapper（強制 UTF-8 output，避免 CP950 亂碼）**：

```powershell
# 重建 class 快取（新增 class_name 檔案後必跑）
.\tools\godot.ps1 --headless --import

# 跑 headless 測試
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd

# 跑 multi sanity
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd

# ★★★merge 前跑【全部】merge-gate —— ★清單見註冊表 docs/process/merge-gates.tsv
#   ★★這裡【只留這一行】（用戶裁「搬」2026-09-01）：新增閘往註冊表加一行，不要往本檔加。
#   ★★★而註冊表是給 runner 讀的，不是給人照著跑的 —— 要人照著跑的清單會長大然後沒人跑完整份。
bash .claude/hooks/merge-gates.sh
```

不用 wrapper 直接呼叫 Godot exe 的 print 輸出會是 CP950 → grep 中文亂碼。

## 架構

```
scripts/data/          資料結構（PersonData, TeamData, TileData, WorldData, FactionData, MessageData）
scripts/simulation/    模擬系統（sim_runner, resource, reaction, skill, interaction, movement, event, faction_ai, message, subteam, world_generator）
scripts/simulation/events/  事件（base_event + 各 event_*.gd）
scripts/debug/         headless 測試
docs/                  設計文件
tools/                 godot等工具
```


## 交付標準

| 項目 | 標準 |
|---|---|
| 可執行 | 無 GDScript 錯誤 |
| 功能完整 | headless 至少1000 Tick 無崩潰，關鍵 print 出現 |
| 文件更新 | 相關 docs/*.md 反映新行為，紀錄已計畫但未完成項目，紀錄進度文件 |


## 文件位置（按需讀，勿一次全讀）

```
docs/
  invariants.md     ★ 跨系統規則（每 session 開頭讀一次）
  mechanism-intents.md ★ 機制意圖帳（WHAT 權威:code 服從表、表只服從用戶;改機制先查）
  game-design.md    遊戲設計理念
  glossary.md       術語表
  world.md          Tick 循環 / 世界
  person.md         人物 / values / 反應系統
  team.md           團體 / tags / tasks
  event.md          事件系統
  message.md        訊息傳播
  tick_parameters.md  Tick 常數
  progress.md       開發進度
  known_issues.md   已知 bug / 待修清單
  process/          session 工作流（00_roles, 01_architect, 03_implementer）
  process/09_exam_gate.md  ★長考閘：驗收考/診斷考的開考前置閘（半成品禁跑驗收考）
  superpowers/      specs / plans / handbacks
```
---

## Session 工作流（多終端為主軌，2026-07-08 切回）

★預設 = **多終端信箱 relay**（各角色持久 session 平行開，git handback 信箱 + 寄件端 SendMessage 敲門）。
langgraph 機器（`tools/orchestrator/`）**少用**，只大/並行活才上（機器誤判 A2a 假 reject + 燒錢 $27/slice 是動機）。
詳 `docs/process/00_roles.md`（角色/owner/邊界本體）+ `07_mailbox_trigger.md`（信箱）+ `08_machine_workflow_v2.md`（機器軌）。

**持久設計/驗收 session（`A:\GDS\demo` / `main`，平行開）**——啟動 `$env:SESSION_ROLE='<role>'; claude`：
★**藍圖那個終端多帶一個**：`$env:CLAUDE_CODE_DISABLE_BG_SHELL_PRESSURE_REAP='1'; $env:SESSION_ROLE='blueprint'; claude`
（用戶裁 2026-09-24，逐字：**「會死掉的看門狗 不是合格的看門狗」**——看門狗當天被 harness 的記憶體收割兩次。
★★**只有藍圖那個終端要設**：跑 Godot／跑電池的 session【不要】，那些才是真的會吃記憶體的。
★★★量：藍圖那個 session 不跑 Godot，唯一的背景 shell 就是看門狗＝一支睡著的 bash，幾 MB ⇒ 收割它省不到記憶體。
★而 shell 裡設無效，只能在啟動 claude 時設。）
- **藍圖**（WHAT）：願景/feature/平衡意圖。owner=`game-design.md`。
- **系統**（HOW）：seam/契約/invariant/流程。owner=`invariants.md`/流程 docs/`progress.md`/`CLAUDE.md`/`docs/process/*`。守 `01_architect.md`。
- **審查**（02 對抗）：factcheck/審 spec，skeptical/只信 file:line。守 `02_reviewer.md`。
- **QA 驗收官**：★獨立 adversarial 判決 + release gate（交用戶前 QA 綠=硬閘）。**留 main dir 讀 `git diff/show`+`.measure.json` 判、不 checkout**。守 `04_qa.md`/`05_acceptance.md`。
- **量測員**：maker 側產獨立數字餵 QA（≠QA≠implementer）。**留 main dir**，`godot --path .worktrees/<slice>` 對 branch code 跑 beds（★禁原地 checkout）。守 `03b_measurer.md`。
- 邊界：藍圖不碰架構、系統不改願景；越界呈報。喬不攏你裁。禁廢話恭維。

**worktree worker session**（`.worktrees/<feature>/` / `feat/<feature>`，唯一真在 worktree 的角色——它改 code）：
- **實作**：照 plan 做+TDD，守 `03_implementer.md`。**code 寫 worktree、handback 寫唯一 main mailbox 絕對路徑**（`<main-repo>/docs/superpowers/handbacks/`）→ 下一站 live 收。也登記通訊錄（`whoami.sh`）→ systems 寫給 implementer 的信會敲到你。

**★信箱（2026-09-23 第二版，用戶裁）＝ git handback ＋ SendMessage 敲門，★不掛任何 inbox watcher**：
收信＝別人寄完信會敲你（harness 推播，直接叫醒你）；寄信＝①Write handback（frontmatter from/to/status/topic）
②★**立刻 SendMessage 敲收件人**（`to:` 填 `bash .claude/hooks/peers.sh` 的 ADDR 欄）——★★**沒敲＝沒送到**。
開場唯一要做的事＝登記通訊錄：`ListAgents` 看自己的名字 → `SESSION_ROLE=<role> bash .claude/hooks/whoami.sh demo-XX`。
★★★為什麼不掛 watcher：Monitor 30 分鐘硬到期、背景 watcher 印完就結束 ⇒ **兩者都要重掛**；
而敲門是推播 —— 零 watcher、零重掛、閒置零 token。★看門狗**照舊掛**（它偵測「沒有事發生」，
那件事沒有人會來敲你 ⇒ 輪詢是它唯一可能的形狀）：`role-watch.sh watchdog`。
★★Telegram 進站已退役（改 Remote Control），出站 `send.sh` 留。
動完把該信改 `status:consumed`。詳 `docs/process/07_mailbox_trigger.md`。

- **git doc = 共享大腦**：handback + `game-design`/`invariants`/`progress` 持久狀態。owner 表語意不變。
- **auto-memory 單寫者 = 系統 session**（HOW owner，持久、序列化天然單寫；別角色教訓走 handback → 系統提煉入 memory）。
- **憲法閘/融合驗/framework = merge 前跑**（綠才 merge）。
