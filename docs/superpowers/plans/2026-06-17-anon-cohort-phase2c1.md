# Anon Cohort Phase 2c-1（來源補全：cohort == population 純量）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 補齊所有「動 `population` 純量卻漏搬 anon cohort」的缺口，並修「anon 死亡 population 雙重扣」，使 `anon_cohorts` 與 `population` 純量在每隊一致 —— **InvariantAudit population drift → 0**。`population` 仍是純量（2c-2 才轉 getter）。

**Architecture:** 增量、低風險。每處 type-b（裸 population 寫入無 cohort 來源）**補**對應 cohort 操作（`transfer_proportional` / `kill_random` / `add`），純量寫入**保留**。野獸群數 cohort 化（與純量並存）。修 `resolve_anon_units` 對死亡 anon 的多餘 `population -= 1`（保留 `continue`，死亡由 encounter kill_random 單一處理）。成功 = multi sanity 的 `[InvariantViolation] population drift` 歸零。

**Tech Stack:** Godot 4.2.2 GDScript。安全閘 = `game_sim_multi.gd` 的 `[InvariantSummary] population drift` 數量；回歸 = `headless_test.gd` 全綠。

> **藍圖**：Phase 1 ✅、2a ✅、2b ✅。**本 plan = 2c-1**（來源補全，純量保留）。下一步 2c-2（population→getter + 刪光純量寫入 + setup 直接 seed cohort）。Phase 4（cohort 自洽網 + docs + 存檔）。

**前置（強制，依 `docs/process/03_implementer.md`）：**
```powershell
git worktree add .worktrees/anon-cohort-phase2c1 -b feat/anon-cohort-phase2c1
cd .worktrees/anon-cohort-phase2c1
```

**Baseline 量測（記下各 config drift 數，當對照）：**
```powershell
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd   # 須 === DONE ===
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd  # 記 [InvariantSummary] 各 config drift 數
```

---

## File Structure

| 檔案 | 動作 | 缺口 |
|---|---|---|
| `scripts/simulation/subteam_system.gd:35,61` | Modify | dispatch 子隊漏搬 anon → 補 `transfer_proportional` |
| `scripts/simulation/population_system.gd:62,70` | Modify | overflow 流亡隊漏搬 anon → 補 `transfer_proportional` |
| `scripts/simulation/encounter_system.gd:1426` | Modify | 屠村 force_occupy 漏殺 anon → 補 `kill_random` |
| `scripts/simulation/health_system.gd:173-174` | Modify | 死亡 anon `population -= 1` 與 encounter kill_random 雙重扣 → 刪此處純量扣（保 `continue`） |
| `scripts/simulation/beast_system.gd:27,32` | Modify | 野獸群數 cohort 化（`AnonCohort.add(平民/healthy)`，純量並存） |

> type-a 點（reaction 死亡 / unrest_split / recruit / mature / famine / npc_combat named 死）**本 plan 不動** —— 旁已有 cohort 來源，純量與 cohort 已一致，留 2c-2 刪純量。本 plan 只補 type-b 缺口 + 修雙重扣。

---

## Task 1: subteam dispatch 補 anon 轉移

**Files:** Modify `scripts/simulation/subteam_system.gd`（dispatch，約 :48-62）

dispatch 把 `pop_count` 人派到子隊：搬了 named（leader + advisors）與 resources，但**沒搬 anon**（`sub.population = pop_count` / `parent.population -= pop_count` 只動純量）。補 anon 轉移。

- [ ] **Step 1: 補 transfer_proportional**

在 `parent.population -= pop_count`（:61）**之前**加（此時 `sub.named_members` 已含 advisors、`sub.leader_id` 已設）：
```gdscript
	# 補搬 anon：pop_count 扣掉已搬的 named（leader + advisors）= 應搬 anon 數
	var named_in_sub: int = sub.named_members.size() + (1 if sub.leader_id != -1 else 0)
	var anon_to_sub: int = maxi(pop_count - named_in_sub, 0)
	AnonTierSystem.transfer_proportional(parent, sub, anon_to_sub)
```
> 保留 `sub.population = pop_count`（:35）與 `parent.population -= pop_count`（:61）純量寫入（2c-2 才刪）。本 step 只確保 anon cohort 同步搬移。

- [ ] **Step 2: 跑 headless 確認無破**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 3: Commit**

```bash
git add scripts/simulation/subteam_system.gd
git commit -m "fix(anon): 2c-1 subteam dispatch 補 anon cohort 轉移"
```

---

## Task 2: overflow 流亡隊補 anon 轉移

**Files:** Modify `scripts/simulation/population_system.gd:56-79`（`_create_overflow_team`）

`_create_overflow_team` 設 `ot.population = overflow_pop`（:62）、`origin.population -= overflow_pop`（:70）、搬 resources，但**沒搬 anon**。

- [ ] **Step 1: 補 transfer_proportional**

在 `origin.population -= overflow_pop`（:70）**之後**加：
```gdscript
	AnonTierSystem.transfer_proportional(origin, ot, overflow_pop)
```
> overflow 的人全是 anon（leader 在 :74 之後另行 `PersonGenerator.generate_for_team` 生成，不從 origin 搬）→ 整批 `overflow_pop` 都該從 origin 的 anon 桶搬到 ot。純量寫入保留。

- [ ] **Step 2: 跑 headless**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 3: Commit**

```bash
git add scripts/simulation/population_system.gd
git commit -m "fix(anon): 2c-1 overflow 流亡隊補 anon cohort 轉移"
```

---

## Task 3: 屠村 force_occupy 補 anon 死亡

**Files:** Modify `scripts/simulation/encounter_system.gd:1423-1427`（`_force_occupy`）

`resident.population = int(resident.population * 0.8)`（:1426）殺 20% 居民但沒從 cohort 移除。

- [ ] **Step 1: 補 kill_random**

把 :1426 改成（先算死亡數、kill anon、再保留純量寫入）：
```gdscript
	var occ_dead: int = resident.population - int(float(resident.population) * 0.8)
	AnonTierSystem.kill_random(resident, occ_dead, "occupy")
	resident.population = int(float(resident.population) * 0.8)
```
> `kill_random` 只殺 healthy anon（2b 設計）；屠村死的是居民 anon，合理。純量寫入保留。若 `occ_dead` 超過 anon 數，kill_random 自然 clamp（回實際殺數），純量仍照 0.8 縮（2c-2 轉 getter 後自動一致；本 phase 純量為準）。

- [ ] **Step 2: 跑 headless**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 3: Commit**

```bash
git add scripts/simulation/encounter_system.gd
git commit -m "fix(anon): 2c-1 屠村 force_occupy 補 anon cohort 死亡"
```

---

## Task 4: 修 anon 死亡 population 雙重扣

**Files:** Modify `scripts/simulation/health_system.gd:173-175`（`resolve_anon_units`）

死亡 anon 被扣兩次：`resolve_anon_units`（:174 `population -= 1`，無 cohort 來源）+ encounter 結算（`encounter_system.gd:1195` `kill_random` + :1196 `population -= dead_anon`）。同一死亡 population 扣 2、cohort 扣 1 → drift。移除 `resolve_anon_units` 的純量扣，死亡由 encounter kill_random 路徑單一處理。

- [ ] **Step 1: 移除多餘 population 扣**

`scripts/simulation/health_system.gd`，把（:173-175）：
```gdscript
		if _is_unit_dead_bp(bp):
			team.population = maxi(team.population - 1, 0)
			continue
```
改成：
```gdscript
		if _is_unit_dead_bp(bp):
			continue   # 死亡 anon 由 encounter 結算 kill_random + population 扣統一處理（避免雙重扣）
```
> 保留 `continue`（死亡 unit 不再計入受傷）。死亡的 anon 數由 `encounter_system.gd:1187-1196` 的 `kill_random(t, dead_anon)` + `population -= dead_anon` 單一處理 —— cohort 與純量同步扣一次。

- [ ] **Step 2: 跑 headless**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 3: Commit**

```bash
git add scripts/simulation/health_system.gd
git commit -m "fix(anon): 2c-1 移除 resolve_anon_units 死亡 anon population 雙重扣"
```

---

## Task 5: 野獸群數 cohort 化

**Files:** Modify `scripts/simulation/beast_system.gd:27-34`（`build_beast_team`）

野獸 `population = count` 但 `anon_cohorts = {}` → 純量與 cohort 不一致（drift）。把獸群存進 cohort（純量並存）。

- [ ] **Step 1: cohort 化獸群**

`scripts/simulation/beast_system.gd`，把（:27,32）：
```gdscript
	t.population = int(prof["count"])
	...
	t.anon_cohorts = {}
```
改成（保留 `t.population` 純量，把獸群放進 cohort）：
```gdscript
	t.population = int(prof["count"])
	...
	t.anon_cohorts = {}
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", int(prof["count"]))
```
> 野獸無 leader/named → `expected = 0 + 0 + total_pop(cohort) = count = population` → 一致。野獸戰鬥 spawn 讀 `team.population`（純量）續用。野獸 combat 傷亡（kill_random/wound_random 經 cohort）現會作用於獸群 cohort —— 行為合理（獸群減員）。

- [ ] **Step 2: 跑 headless + 野獸相關**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `=== DONE ===`，無 `SCRIPT ERROR`。野獸測試（若有）綠。

- [ ] **Step 3: Commit**

```bash
git add scripts/simulation/beast_system.gd
git commit -m "fix(anon): 2c-1 野獸群數 cohort 化（平民/healthy）"
```

---

## Task 6: drift 歸零驗證 + 殘留追蹤

**Files:** （無 code，除非追到殘留缺口）

- [ ] **Step 1: multi sanity 量 drift**

```powershell
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd
```
比對 baseline：`[InvariantSummary] population drift` 各 config 數量應**大幅下降趨近 0**。`coin_eq` delta=0、無 `SCRIPT ERROR`。

- [ ] **Step 2: 追殘留 drift（若 > 0）**

若仍有 `population drift TeamN: 欄位=X 期望=Y`：drift 訊息含 `leader/named/anon` 拆解 → 比對該隊發生什麼（搜該情境的 population 寫入點）→ 找「動 population 純量卻漏對應 cohort 來源」或「動 cohort 漏 population」的點 → 補來源（transfer/kill/add）。重跑直到 drift→0（或記錄不可約殘留 + 原因）。
> 常見殘留源：建隊 setup（game_setup `population=N` 後 `_setup_anon_tiers` 應已 add anon，檢查順序）、新 exile solo team（reaction `_spawn_exile_or_join` `ot.population=1` 是 leader，無 anon → expected=1+0+0=1 一致，不該 drift）、reaction else 分支（256/272 若可達且無 kill_random → 補）。

- [ ] **Step 3: Commit（若有殘留修正）**

```bash
git add -A
git commit -m "fix(anon): 2c-1 補殘留 population drift 缺口"
```

---

## Task 7: hand-back

- [ ] **Step 1: 寫 hand-back** `docs/superpowers/handbacks/2026-06-17-anon-cohort-phase2c1.md`（依 03_implementer 格式）：
- 實作摘要：每檔一行（dispatch/overflow/force_occupy/雙重扣/beast + 殘留修正）。
- 驗證：baseline vs 修後各 config drift 數對照（證明趨近 0）；coin_eq delta=0；headless 綠。
- 與 spec 差異：採 two-step（2c-1 補來源純量保留 / 2c-2 flip getter），非 spec 原 Phase 3 一次 flip —— 說明降風險理由。
- 連動風險：`population` 仍純量（2c-2 轉 getter）；野獸 cohort 化後 combat 傷亡路徑作用於獸群（已驗無破）。
- 待主 session 確認：2c-2 啟動（population → getter + 刪光純量寫入 + setup seed cohort）。

- [ ] **Step 2: Commit + push + 回報**

```bash
git add docs/superpowers/handbacks/2026-06-17-anon-cohort-phase2c1.md
git commit -m "docs: anon cohort phase2c1 hand-back"
git push -u origin feat/anon-cohort-phase2c1
```
回報分支（finishing 選 Option 3，主 session merge）。

---

## Self-Review

**Spec coverage：** 對 spec Phase 3「審 population 寫入點分類」的 type-b（補來源）部分 + 雙重扣修正。type-a 刪純量、population→getter 屬 2c-2。two-step 拆分降風險已說明。

**Placeholder scan：** 無 TBD。Task 6 殘留追蹤是 audit-driven 除錯（有明確 drift 訊息可循 + 常見源提示），非 placeholder。

**Type consistency：** `AnonTierSystem.transfer_proportional(from,to,count)` / `kill_random(team,count,source)` / `AnonCohort.add(cohorts,tier,health,n)` 簽名對齊已 merge 版。所有純量寫入保留（本 phase 不轉 getter）。`anon_to_sub` / `occ_dead` / `named_in_sub` 為 task 內本地變數，無跨 task 依賴。
