# 代碼健康 批次2（TASK_* enum 單一真值源）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** task 名統一走 `TeamData.TASK_*` 常數單一真值源——補齊缺的 task 常數，並把散落的裸 task 字串（含已有 const 卻用字面的）全改引用，消除「typo 即 silent false」。

**Architecture:** 通用模型/單一真值源（非東修西補）。TeamData 的 TASK_* 區為唯一 task 名權威；任何 `current_task/order_task/sub_task/player_commanded_task/solo_intent` 的比較與賦值都走常數，零裸字串。行為等價（值不變）。

**Tech Stack:** Godot 4.2.2 GDScript。閘 = `headless_test.gd`（`=== DONE ===`）+ `game_sim_multi.gd`（coin_eq=0、全 invariant 0、行為等價）。

> **藍圖**：代碼健康。批次1（常數去重）✅。**本 plan = 批次2（TASK_* enum）**。批次3（ResourceKeys 鍵權威）後續可選。

**前置（強制，依 `docs/process/03_implementer.md`）：**
```powershell
git worktree add .worktrees/code-health-b2 -b feat/code-health-b2
cd .worktrees/code-health-b2
```

**Baseline：** `headless_test.gd` → `=== DONE ===`；`game_sim_multi.gd` coin_eq=0、全 invariant 0。

---

## 現況（研究確認）

`team_data.gd:3-22` 已有 20 個 `TASK_*` const（idle/徵收/偵查/信使/攻擊/掠奪/外交/護衛/逃跑/生產/製造/貿易/巡邏/建設/合併/訓練/迎戰/備戰/覓食/紮營）。

**問題 A — 缺 const**（裸字串但無對應常數）：`安頓`(6)、`安撫`(2)、`乞食`(2)、`投靠`、`起義`、`return_home`、`rest` 等。
**問題 B — 有 const 卻用字面**：`護衛`(5)、`逃跑`(3)、`徵收`(3)、`idle`(3)、`攻擊`(2)、`掠奪`(2)、`外交`(2)、`信使`(2)、`生產`、`建設` 等散在比較/賦值。

---

## File Structure

| 檔案 | 動作 |
|---|---|
| `scripts/data/team_data.gd` | 權威源 | TASK_* 區補缺常數 |
| `scripts/simulation/*.gd`（faction_ai / interaction / movement / player_command / reaction / subteam / strategic_ai / events/* 等）| Modify | 裸 task 字串 → TASK_* 引用 |
| `scripts/debug/*.gd`（測試 setup 若用裸 task 字串）| Modify | 同步改引用（或保留——見 Task 3） |

---

## Task 1: 補齊缺的 TASK_* 常數

**Files:** Modify `scripts/data/team_data.gd`（TASK_* 區，:3-22 後）

- [ ] **Step 1: 確認候選是 task 值 + 補常數**

逐一**確認**下列字串確實被賦值給 `current_task`/`order_task`/`sub_task`/`player_commanded_task`（grep `(current_task|order_task|sub_task|player_commanded_task)\s*=\s*"<字>"`）。**是 task 值才加常數**；若某字其實是 event 名/person 狀態/其他語意（如 `"rest"`/`"起義"` 可能非 team task）→ **不加、Task 2 也不轉**，於 hand-back 註明。

確認後在 TASK_* 區補（命名對齊既有風格）：
```gdscript
const TASK_SETTLE      := "安頓"
const TASK_PACIFY      := "安撫"
const TASK_BEG         := "乞食"
const TASK_JOIN        := "投靠"
const TASK_RETURN_HOME := "return_home"
```
> `起義`/`rest`：**先確認語意**。若 `起義` 是 reaction/event 而非 team current_task → 不納入。`rest` 同理（可能是 unit/person 狀態）。只納真 team task。

- [ ] **Step 2: 跑 headless**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 3: Commit**

```bash
git add scripts/data/team_data.gd
git commit -m "feat(task): 補齊 TASK_* 常數（安頓/安撫/乞食/投靠/return_home 等確認為 task 值者）"
```

---

## Task 2: 裸 task 字串 → TASK_* 引用（production）

**Files:** Modify `scripts/simulation/*.gd`

把 task 欄位（`current_task`/`order_task`/`sub_task`/`player_commanded_task`/`solo_intent`）的**比較與賦值**中的裸中文/字串改 `TeamData.TASK_*`。

- [ ] **Step 1: 全面轉換**

grep 定位（兩類都要）：
```
比較：(current_task|order_task|sub_task|player_commanded_task|solo_intent)\s*[=!]=\s*"..."
賦值：(current_task|order_task|sub_task|player_commanded_task|solo_intent)\s*=\s*"..."
陣列/集合：如 faction_ai SURVIVAL_TASKS 內混用 const 與字面 → 全改 const
```
規則：
- 字串是 task 名（對應某 `TASK_*`）→ 改 `TeamData.TASK_*`（含 Task 1 新增的）。
- `faction_ai_system.gd:30 SURVIVAL_TASKS` 把字面（`"乞食"`/`"投靠"`）改對應 const，與既有 `TeamData.TASK_FORAGE` 一致。
- **逐站確認是 task 欄位 context**（非同字的 tag/event/其他語意）。Task 1 判為「非 task」的字串**不轉**。

> 涉及檔案（grep 命中）：`faction_ai_system` / `interaction_system` / `movement_system` / `player_command_system` / `reaction_system` / `subteam_system` / `strategic_ai_system` / `events/*.gd` 等。**逐檔 grep 上述 pattern 改盡**。

- [ ] **Step 2: 重建 class 快取 + 跑 headless**

```powershell
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`、無 `SCRIPT ERROR`、task/faction/survival 相關測試綠。

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "refactor(task): production 裸 task 字串 → TeamData.TASK_* 引用"
```

---

## Task 3: 測試檔 task 字串對齊 + 回歸 + hand-back

**Files:** Modify `scripts/debug/*.gd`（若用裸 task 字串斷言/setup）

- [ ] **Step 1: 測試檔 task 字串**

grep `scripts/debug/*.gd` 的 task 欄位裸字串（setup 設 `current_task = "..."` 或斷言 `== "..."`）。改 `TeamData.TASK_*`（與 production 一致；裸字串斷言若 typo 也是 silent，統一走常數）。
> 若某斷言**刻意**驗字面值（驗序列化/外部介面），保留並註記。

- [ ] **Step 2: 全回歸**

```powershell
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd
```
Expected: headless `=== DONE ===`；multi coin_eq=0、全 invariant 0、無 `SCRIPT ERROR`。**行為等價**（task 名值不變）。

- [ ] **Step 3: hand-back** `docs/superpowers/handbacks/2026-06-18-code-health-task-enum-batch2.md`：
- 實作摘要：補的常數清單 + 轉換檔（每檔一行）+ **判為「非 task」未轉的字串清單**（如 起義/rest 若排除）。
- 驗證：headless 綠、coin_eq=0、全 invariant 0、行為等價。
- 待主 session：批次3（ResourceKeys 鍵權威 + resources.get helper，中/低優先，可選）。

- [ ] **Step 4: Commit + push + 回報**

```bash
git add -A
git commit -m "docs: 代碼健康 批次2 hand-back"
git push -u origin feat/code-health-b2
```
回報分支（finishing 選 Option 3，主 session merge）。

---

## Self-Review

**Spec coverage：** 涵蓋審計「task 字串無 TASK_* const」高/中項（補缺常數 + 85 const vs 33 字面不一致收斂）。ResourceKeys/get_res 屬批次3。

**Placeholder scan：** 無 TBD。Task 1 候選字串、Task 2/3 逐站附「確認是 task 欄位 context、非 task 不轉」明確判準，非 placeholder。

**Type consistency：** `TeamData.TASK_*` 為唯一 task 名權威，比較/賦值跨檔引用一致。新增常數命名對齊既有（TASK_<英文語意>）。零行為變更（task 名字串值不變）。
