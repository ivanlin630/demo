# CLAUDE.md — 專案工作指引

## 專案定位

Godot 4.2.2 GDScript 世界模擬器。重點：NPC 決策/互動/因果生成。**禁止直接 script 結果**，所有事件必須從 NPC 模型和團體狀態出發產生。

## 常用指令

```powershell
# 重建 class 快取（新增 class_name 檔案後必跑）
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import

# 跑 headless 測試
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

## 架構

```
scripts/data/          資料結構（PersonData, TeamData, TileData, WorldData, FactionData, MessageData）
scripts/simulation/    模擬系統（sim_runner, resource, reaction, skill, interaction, movement, event, faction_ai, message, subteam, world_generator）
scripts/simulation/events/  事件（base_event + 各 event_*.gd）
scripts/debug/         headless 測試
docs/                  設計文件
```

## Tick 循環順序（sim_runner.gd）

step1 時間 → step2 移動 → step3 訊息 → step4 互動 → step5 收集 → step6 消耗 → step6b FactionAI → step7 反應 → step8 事件 → step9 emit_messages

LOD：近區（dist≤3）每 Tick；遠區每 10 Tick（跳過人物反應）。

## 關鍵設計規則

- **不直接 script 結果**：所有行為從 NPC values/skills/stress/loyalty 計算產生
- **新功能前定義**：影響的世界狀態、資訊流動、時間消耗、受影響群體、二次後果
- **Tag 過濾 Task**：`_tag_weight(team, task)` 決定 team 能否執行某 task
- **FactionAI 兩層**：勢力目標（step 6b）→ leader/成員 task；獨立 team 用 SoloTeamAI
- **子團**：tags=["子團"]，parent_team_id≠-1，不受 faction tribute 徵收

## Values 系統

| value | 主要影響系統 |
|---|---|
| 野心 | FactionAI 立國/外交門檻、攻擊 goal |
| 求生欲 | FactionAI 緊急徵收門檻、SoloAI 逃跑 |
| 義氣 | 叛離事件、外交接受、tribute 率 |
| 貪婪 | FactionAI 徵收週期、勒索分數 |
| **慎重** | **跨系統關鍵字**，壓低所有風險行為 |
| 好戰 | _should_attack 加權、FactionAI 攻擊 goal |
| 殘忍 | loot rate、傷兵惡化、暴動/勒索傾向 |
| 信義 | 外交接受率、tribute 率、叛離條件 |

## 交付標準

| 項目 | 標準 |
|---|---|
| 可執行 | 無 GDScript 錯誤 |
| 功能完整 | headless 200 Tick 無崩潰，關鍵 print 出現 |
| 文件更新 | 相關 docs/*.md 反映新行為 |

## 文件位置

| 主題 | 檔案 |
|---|---|
| 人物/反應/values | `docs/person.md` |
| 團體/tags/tasks | `docs/team.md` |
| Tick 循環/世界 | `docs/world.md` |
| 事件系統 | `docs/event.md` |
| 訊息傳播 | `docs/message.md` |
| 開發進度 | `docs/progress.md` |
