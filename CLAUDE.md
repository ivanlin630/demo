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

# 憲法 site-freeze 防閘（arc 期間防新增引擎外 task 指派；新增違憲=FAIL）
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

## Session 工作流

角色與分工（WHAT/HOW 雙設計腦 + 實作）詳見 `docs/process/00_roles.md`，**每 session 開頭讀**。

**設計 session**（`A:\GDS\demo`，`main` branch，兩個並存）：
- **藍圖**（WHAT）：遊戲願景 / feature / 平衡意圖。owner = `game-design.md`。
- **系統**（HOW）：seam / 契約 / invariant / 流程。owner = `invariants.md` / 流程 docs / `progress.md` / `CLAUDE.md` / **auto-memory 單寫者**。嚴格遵守 `docs/process/01_architect.md`。
- 邊界：藍圖不碰架構、系統不改願景；越界呈報對方。喬不攏你裁。
- 禁止廢話與恭維用語。

**子 session**（`.worktrees/<feature>/`，`feat/<feature>` branch）：
- 如果你在 `.worktrees/` 路徑下，你是實作 session
- 嚴格遵守`docs/process/03_implementer.md`

**auto-memory：只有系統 session 寫；藍圖 / 實作只讀（開頭自動注入），教訓走 handback 呈報系統。**
