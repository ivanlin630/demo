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
  process/          session 工作流（01_architect, 03_implementer）
  superpowers/      specs / plans / handbacks
```
---

## 雙 Session 工作流

**主 session**（`A:\GDS\demo`，`main` branch）：
- 嚴格遵守`docs/process/01_architect.md`

**子 session**（`.worktrees/<feature>/`，`feat/<feature>` branch）：
- 如果你在 `.worktrees/` 路徑下，你是實作 session
- 嚴格遵守`docs/process/03_implementer.md`
