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

# ★merge 前跑【全部】merge-gate —— 清單見註冊表 docs/process/merge-gates.tsv
#   ★這裡【只留這一行】（用戶裁「搬」2026-09-01）：新增閘往註冊表加一行，不要往本檔加。
#   ★而註冊表是給 runner 讀的，不是給人照著跑的 —— 要人照著跑的清單會長大然後沒人跑完整份。
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

★預設 ＝ **多終端信箱 relay**（各角色持久 session 平行開）。langgraph 機器（`tools/orchestrator/`）**少用**，只大／並行活才上。
本體：`docs/process/00_roles.md`（角色／owner／邊界／無斷點鏈／診斷通則）＋`07_mailbox_trigger.md`（信箱／看門狗）＋`08_machine_workflow_v2.md`（機器軌）。

**啟動**（持久 session 平行開在 `A:\GDS\demo` / `main`）：`$env:SESSION_ROLE='<role>'; claude`
★**藍圖＋實作端兩個終端啟動時多帶 `CLAUDE_CODE_DISABLE_BG_SHELL_PRESSURE_REAP=1`**（用戶裁 2026-10-07 擴到實作端）
⇒ 六個終端的逐字啟動指令在 **`README.md` §開六個角色終端**（開終端的是用戶，所以放用戶讀的那份）；理由 → `07_mailbox_trigger.md`。
★六個角色是誰、誰 owner 哪份檔、誰留 main dir 不 checkout ⇒ **`00_roles.md` §六角色**（那裡是唯一一份）。
★**worktree worker ＝ 實作**（唯一真在 worktree 的角色）：code 寫 worktree、**handback 寫唯一 main mailbox 的絕對路徑**。

**★信箱（2026-09-23 第二版，用戶裁）＝ 不掛任何 inbox watcher**：收信＝別人敲你（harness 推播）；
寄信＝**①Write handback ②commit ③立刻 SendMessage 敲收件人**（`to:` 填 `peers.sh` 的 ADDR 欄）
—— ★**三件缺一＝沒送到**。開場唯一要做的事＝`whoami.sh` 登記通訊錄。動完把該信改 `status:consumed`。
★看門狗照舊掛（`role-watch.sh watchdog`）。為什麼三代 watcher 全退、Telegram 進站退役 → `07_mailbox_trigger.md`。

- **git doc ＝ 共享大腦**：handback ＋ `game-design`／`invariants`／`progress` 是**持久狀態**（不是聊天紀錄）。
- **auto-memory 單寫者 ＝ 系統 session**；別角色的教訓走 handback → 系統提煉入 memory。