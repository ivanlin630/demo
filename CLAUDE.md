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

## Session 工作流（全 pipeline，2026-07-06 切）

用戶只跟**藍圖 orchestrator**（持久人工 session）談 WHAT。藍圖裁定後 spawn subagent 執行下游。詳 `docs/process/06_pipeline_orchestration.md`（+ `00_roles`/`01_architect`/`03_implementer`/`04_qa`/`05_acceptance` 仍為角色職責/驗收本體）。

- **藍圖 orchestrator**（WHAT，人工）：與用戶談願景/平衡；一裁定→fan-out spawn 下游。owner = `game-design.md`。
- **系統 subagent**（HOW，ephemeral）：spec/plan（讀 `invariants`/`game-design`）。owner doc = `invariants.md`/流程 docs/`progress.md`/`CLAUDE.md`。
- **實作 subagent**（worktree，ephemeral）：建+測→handback。
- **QA subagent**（★獨立 adversarial，非藍圖自蓋自判）：判決。**用戶=最終驗收權威**（交用戶前 QA 綠=硬閘）。
- **git doc = 共享大腦**：handback + `game-design`/`invariants`/`progress` 持久狀態；ephemeral subagent 直讀 doc 得 context。owner 表語意不變，**寫手 = orchestrator 序列化（天然單寫，無並發）**。
- **auto-memory 單寫者 = 藍圖 orchestrator session**（持久、序列化、看全局）。
- **憲法閘/融合驗/framework = orchestrator merge-gate 步**（merge 前 spawn 跑，綠才 merge）；pre-commit site-freeze 閘已撤（arc-temporary）。
- 邊界：藍圖不碰架構細節、系統不改願景；越界呈報。禁廢話恭維。深架構 slice 餵厚 context（ephemeral 比老兵淺）。
