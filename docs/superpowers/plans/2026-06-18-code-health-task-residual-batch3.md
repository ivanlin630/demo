# 代碼健康 批次3（殘留 task 常數收尾）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 補齊批次2 遺留的 7 個 task 字串常數（`治理/守城/遷徙/建造/升級/擴建` current_task、`tribute_offer` order_task）並轉引用，完成 TASK_* 單一真值源（零裸 task 字串）。

**Architecture:** 接續批次2，通用模型/單一真值源。TeamData TASK_* 為唯一 task 名權威。零行為變更。

**Tech Stack:** Godot 4.2.2 GDScript。閘 = `headless_test.gd`（`=== DONE ===`）+ `game_sim_multi.gd`（coin_eq=0、全 invariant 0、行為等價）。

> **代碼健康收尾**：批次1（常數去重）✅、批次2（TASK_* 主體）✅、**本批=殘留 task 常數**。ResourceKeys/get_res 判 YAGNI 緩（資源鍵無 value-drift、高 churn 低值）。

**前置（強制，依 `docs/process/03_implementer.md`）：**
```powershell
git worktree add .worktrees/code-health-b3 -b feat/code-health-b3
cd .worktrees/code-health-b3
```

**Baseline：** `headless_test.gd` → `=== DONE ===`。

---

## Task 1: 補殘留 task 常數 + 轉引用

**Files:** Modify `scripts/data/team_data.gd`（TASK_* 區）+ 用到這些字串的 `scripts/simulation/*.gd`

- [ ] **Step 1: 確認 + 補常數**

逐一 grep 確認下列確被賦值/比較於 task 欄位（`current_task`/`order_task`/`sub_task`/`player_commanded_task`：`(欄位)\s*[=!]=\s*"<字>"`）。**是 task 值才加**；非 task（event/tag/goal/kind/display）→ 不加不轉，hand-back 註明。

team_data.gd TASK_* 區補（命名對齊既有風格；逐一確認語意後定名）：
```gdscript
const TASK_GOVERN   := "治理"
const TASK_HOLD      := "守城"
const TASK_MIGRATE   := "遷徙"
const TASK_CONSTRUCT := "建造"
const TASK_UPGRADE   := "升級"
const TASK_EXPAND    := "擴建"
const TASK_TRIBUTE_OFFER := "tribute_offer"   # order_task（提供納貢），非 current_task
```
> 命名僅建議，實作可依語意微調（保持 TASK_<英文>）。`tribute_offer` 是 order_task 值，確認後納入。

- [ ] **Step 2: 轉引用**

grep 這 7 個字串在 task 欄位 context 的比較/賦值，全改 `TeamData.TASK_*`。**非 task 欄位的同字串不動**（如 `tags.has(...)`、`goals.append(...)`、display）。

- [ ] **Step 3: 重建快取 + headless**

```powershell
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`、無 `SCRIPT ERROR`。

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "refactor(task): 補殘留 task 常數(治理/守城/遷徙/建造/升級/擴建/tribute_offer)收尾單一源"
```

---

## Task 2: 回歸 + hand-back

- [ ] **Step 1: 全回歸**

```powershell
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd
```
Expected: headless `=== DONE ===`；multi coin_eq=0、全 invariant 0、無 `SCRIPT ERROR`、行為等價。

- [ ] **Step 2: hand-back** `docs/superpowers/handbacks/2026-06-18-code-health-task-residual-batch3.md`：
- 補的常數清單 + 轉換站 + 判為非 task 未轉者。
- 驗證：headless 綠、coin_eq=0、全 invariant 0、行為等價。
- 收尾聲明：TASK_* 單一源完成；ResourceKeys/get_res 判 YAGNI 緩（理由：資源鍵無 value-drift、高 churn 低值）。

- [ ] **Step 3: Commit + push + 回報**

```bash
git add -A
git commit -m "docs: 代碼健康 批次3 hand-back（TASK_* 單一源收尾）"
git push -u origin feat/code-health-b3
```
回報分支。

---

## Self-Review

**Spec coverage：** 完成審計「task 字串」項剩餘部分（批次2 遺留的 7 個）。ResourceKeys/get_res 明確判 YAGNI 緩並記理由。

**Placeholder scan：** 無 TBD。常數命名「實作可微調」附明確規則（保持 TASK_<英文>、確認 task 欄位 context），非 placeholder。

**Type consistency：** `TeamData.TASK_*` 唯一權威，新增常數命名對齊既有。零行為變更（字串值不變）。
