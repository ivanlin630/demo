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
tools/                 godot等工具
```

## 關鍵設計規則

- **不直接 script 結果**：所有行為從 NPC values/skills/stress/loyalty 計算產生
- **新功能前定義**：影響的世界狀態、資訊流動、時間消耗、受影響群體、二次後果

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
| 功能完整 | headless 至少1000 Tick 無崩潰，關鍵 print 出現 |
| 文件更新 | 相關 docs/*.md 反映新行為，紀錄已計畫但未完成項目，紀錄進度文件 |


## 文件位置

| 主題 | 檔案 |
|---|---|
| 人物/反應/values | `docs/person.md` |
| 團體/tags/tasks | `docs/team.md` |
| Tick 循環/世界 | `docs/world.md` |
| 事件系統 | `docs/event.md` |
| 訊息傳播 | `docs/message.md` |
| 開發進度 | `docs/progress.md` |

---

## 雙 Session 工作流

**主 session**（`A:\GDS\demo`，`main` branch）：brainstorm → spec → plan 設計，不實作。

**子 session**（`.worktrees/<feature>/`，`feat/<feature>` branch）：實作 plan。

### 子 session 標準流程

如果你在 `.worktrees/` 路徑下，你是實作 session。

**開始前：**
```powershell
# 確認 baseline 乾淨
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

**實作工具：** 使用 `superpowers:executing-plans` 或 `superpowers:subagent-driven-development`

**測試標準：**
- 每個 task 完成後跑 headless test
- 必須看到 `=== DONE ===`，無 `SCRIPT ERROR`
- 新功能加對應驗證 print

**Commit 規範：**
```
feat(系統): 功能描述
fix(系統): 修正描述
docs(主題): 文件更新
test: 測試新增/更新
```

**完成後：**

1. 推 branch：
```powershell
git push -u origin feat/<feature>
```

2. 寫 hand-back 文件到 `docs/superpowers/handbacks/YYYY-MM-DD-<feature>.md`：

```markdown
# Hand Back: <功能名稱>

## 實作摘要
- 改了哪些檔案（每檔一行說明）
- 與 spec 的差異（若有）

## 連動風險
列出其他系統可能受影響的部分，主 session 決定是否補修：
- `系統A`：說明為何可能受影響
- （無則寫「無已知連動風險」）

## 待主 session 確認
- 設計決策（實作中遇到 spec 未覆蓋的情況）
- 建議後續 task（發現的潛在問題或改進點）
```

3. Commit hand-back 文件，不要直接 merge 到 main，等主 session 確認。
