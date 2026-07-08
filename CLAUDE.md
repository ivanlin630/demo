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

# 憲法 site-freeze 防閘（merge-gate：禁新增引擎外 task 指派；新增違憲=FAIL）——orchestrator merge 前跑
.\tools\godot.ps1 --headless --script scripts/debug/constitution_gate.gd
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
  game-design.md    遊戲設計理念
  glossary.md       術語表
  world.md          Tick 循環 / 世界
  person.md         人物 / values / 反應系統
  team.md           團體 / tags / tasks
  faction.md        勢力 / 外交
  event.md          事件系統
  message.md        訊息傳播
  tick_parameters.md  Tick 常數
  progress.md       開發進度
  known_issues.md   已知 bug / 待修清單
  process/          session 工作流（00_roles, 01_architect, 03_implementer）
  superpowers/      specs / plans / handbacks
```
---

## Session 工作流（多終端為主軌，2026-07-08 切回）

★預設 = **多終端信箱 relay**（各角色持久 session 平行開，git handback 信箱 + Monitor 主動觸發）。
langgraph 機器（`tools/orchestrator/`）**少用**，只大/並行活才上（機器誤判 A2a 假 reject + 燒錢 $27/slice 是動機）。
詳 `docs/process/00_roles.md`（角色/owner/邊界本體）+ `07_mailbox_trigger.md`（信箱）+ `08_machine_workflow_v2.md`（機器軌）。

**持久設計/驗收 session（`A:\GDS\demo` / `main`，平行開）**——啟動 `$env:SESSION_ROLE='<role>'; claude`：
- **藍圖**（WHAT）：願景/feature/平衡意圖。owner=`game-design.md`。
- **系統**（HOW）：seam/契約/invariant/流程。owner=`invariants.md`/流程 docs/`progress.md`/`CLAUDE.md`/`docs/process/*`。守 `01_architect.md`。
- **審查**（02 對抗）：factcheck/審 spec，skeptical/只信 file:line。守 `02_reviewer.md`。
- **QA 驗收官**：★獨立 adversarial 判決 + release gate（交用戶前 QA 綠=硬閘）。**留 main dir 讀 `git diff/show`+`.measure.json` 判、不 checkout**。守 `04_qa.md`/`05_acceptance.md`。
- **量測員**：maker 側產獨立數字餵 QA（≠QA≠implementer）。**留 main dir**，`godot --path .worktrees/<slice>` 對 branch code 跑 beds（★禁原地 checkout）。守 `03b_measurer.md`。
- 邊界：藍圖不碰架構、系統不改願景；越界呈報。喬不攏你裁。禁廢話恭維。

**worktree worker session**（`.worktrees/<feature>/` / `feat/<feature>`，別 dir、不 arm，走 plan/機器領活）：
- **實作**：照 plan 做+TDD+handback，守 `03_implementer.md`。（唯一真在 worktree 的角色——它改 code。）

**★信箱主動觸發（免人肉轉述）**：各持久角色開場 arm `Monitor(bash .claude/hooks/inbox-watch.sh, persistent)`
——別的角色寫 `to:<我> && status:open` 信 ~20s 內主動喚醒。寄件=Write handback（frontmatter from/to/status/topic），動完改 `status:consumed`。

- **git doc = 共享大腦**：handback + `game-design`/`invariants`/`progress` 持久狀態。owner 表語意不變。
- **auto-memory 單寫者 = 藍圖 session**（持久、看全局；別角色教訓走 handback → 藍圖提煉入 memory）。
- **憲法閘/融合驗/framework = merge 前跑**（綠才 merge）。
