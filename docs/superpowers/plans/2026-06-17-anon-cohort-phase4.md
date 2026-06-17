# Anon Cohort Phase 4（cohort 自洽審計網 + 文件收尾）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 為 anon cohort 加 InvariantAudit 自洽網（防 cohort 結構腐化），並更新 `invariants.md` 反映 cohort 模型 + 資料模型不變量規則。收尾整個重構。

**Architecture:** 純加檢查 + 文件，零行為變更。存檔遷移 **N/A**（專案無 save/load 系統，`FileAccess` 僅讀 config JSON）。

**Tech Stack:** Godot 4.2.2 GDScript。閘 = `headless_test.gd`（`=== DONE ===`、新 cohort audit 測試綠）+ `game_sim_multi.gd`（coin_eq=0、population drift=0 維持）。

> **藍圖**：Phase 1/2a/2b/2c-1/2c-2 ✅ + coin fix ✅（population getter、drift=0、coin_eq=0）。**本 plan = Phase 4（收尾）**。完成 = anon 統一 cohort 模型全竣。

**前置（強制，依 `docs/process/03_implementer.md`）：**
```powershell
git worktree add .worktrees/anon-cohort-phase4 -b feat/anon-cohort-phase4
cd .worktrees/anon-cohort-phase4
```

**Baseline：** `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd` → `=== DONE ===` 無 `SCRIPT ERROR`。

---

## File Structure

| 檔案 | 動作 |
|---|---|
| `scripts/simulation/invariant_audit.gd` | Modify | 加 `_check_anon_cohort`（每桶 count≥0、鍵合法、total 自洽）並註冊進 `check()` |
| `scripts/debug/headless_test.gd` | Modify | 加 `_test_invariant_anon_cohort`（正常 cohort 過、腐化 cohort 被抓） |
| `docs/invariants.md` | Modify | anon 段（:69-72）改 cohort 模型 + 新增「資料模型不變量規則」節 |

---

## Task 1: InvariantAudit cohort 自洽網

**Files:** Modify `scripts/simulation/invariant_audit.gd`

- [ ] **Step 1: 加 _check_anon_cohort + 註冊**

在 `check()` 加呼叫：
```gdscript
static func check(state: WorldState) -> Array[String]:
	var violations: Array[String] = []
	_check_population(state, violations)
	_check_faction_bidir(state, violations)
	_check_subteam_bidir(state, violations)
	_check_anon_cohort(state, violations)
	return violations
```

在檔末加：
```gdscript
# anon cohort 自洽：每桶 count>0、鍵合法（tier ∈ TIER_ORDER、health ∈ {healthy,wounded}）。
# count<0 或非法鍵 = AnonCohort 入口被繞過或腐化。population getter 已是恆等式（total_pop），
# 故 _check_population 對 anon 部分恆綠；此網守的是 cohort 內部結構。
static func _check_anon_cohort(state: WorldState, out: Array[String]) -> void:
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		for key in t.anon_cohorts:
			var parts: Array = AnonCohort._parse(key)
			if parts.size() != 2 or parts[0] not in AnonCohort.TIER_ORDER \
					or parts[1] not in AnonCohort.HEALTH_ORDER:
				out.append("cohort 非法鍵 Team%d: '%s'" % [tid, key])
			if int(t.anon_cohorts[key]) <= 0:
				out.append("cohort 桶非正 Team%d: '%s'=%d（稀疏應刪零桶）" % [tid, key, int(t.anon_cohorts[key])])
```

- [ ] **Step 2: 跑 headless**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `=== DONE ===`、`InvariantAudit population OK` 等既有綠、無 `SCRIPT ERROR`。

- [ ] **Step 3: Commit**

```bash
git add scripts/simulation/invariant_audit.gd
git commit -m "feat(audit): InvariantAudit 加 anon cohort 自洽網"
```

---

## Task 2: cohort 自洽網單元測試

**Files:** Modify `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加測試 + 註冊**

```gdscript
func _test_invariant_anon_cohort() -> void:
	var st := WorldState.new()
	var t := TeamData.new(); t.team_id = 0
	t.anon_cohorts = {}
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", 3)
	AnonCohort.add(t.anon_cohorts, "老兵", "wounded", 1)
	st.teams[0] = t
	assert(not _contains_substr(InvariantAudit.check(st), "cohort"), "正常 cohort 不該有 cohort 違反")
	# 腐化：非法鍵
	t.anon_cohorts["平民|sick"] = 2
	var v: Array = InvariantAudit.check(st)
	assert(_contains_substr(v, "cohort 非法鍵"), "非法鍵應被抓")
	t.anon_cohorts.erase("平民|sick")
	# 腐化：負桶
	t.anon_cohorts["新兵|healthy"] = -1
	var v2: Array = InvariantAudit.check(st)
	assert(_contains_substr(v2, "cohort 桶非正"), "負桶應被抓")
	print("[OK] _test_invariant_anon_cohort")

func _contains_substr(arr: Array, sub: String) -> bool:
	for s in arr:
		if String(s).findn(sub) != -1:
			return true
	return false
```
> 若 `_contains_substr` 已存在於 headless_test 則複用、勿重複定義（先 grep 確認）。

註冊於 `_initialize()`（接在既有 anon cohort 測試後）：
```gdscript
	_test_invariant_anon_cohort()
```

- [ ] **Step 2: 跑 headless**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `[OK] _test_invariant_anon_cohort`、`=== DONE ===`、無 `SCRIPT ERROR`。

- [ ] **Step 3: Commit**

```bash
git add scripts/debug/headless_test.gd
git commit -m "test: anon cohort 自洽網單元測試"
```

---

## Task 3: invariants.md 文件更新

**Files:** Modify `docs/invariants.md`

- [ ] **Step 1: 改 anon 段（:69-72 區）**

把現述 `anon_tiers` 4 scalar 的段落改為 cohort 模型：
```markdown
- anon 是 team-level 抽象集體，**無個體 entity**
- 統一儲存於 `team.anon_cohorts`（稀疏 dict，鍵 `"tier|health"`→count；tier ∈ 平民/新兵/老兵/菁英，health ∈ healthy/wounded）
- 變動只透過 `AnonCohort`（add/move/remove）或 `AnonTierSystem`（add_anon/remove_anon/kill_random/wound_random/heal_random/kill_wounded/transfer_proportional/try_promote）
- `population` / `wounded` / `anon_combat_skill` / `anon_wage` 為 computed getter（投影自 cohort，**不可直接寫**，舊 set no-op）
- 入團時保留來源 tier（戰俘 / 投靠 帶原 tier 進入）；受傷 = move healthy→wounded；晉升 named/leader 從 anon 桶移除 1
```

- [ ] **Step 2: 新增「資料模型不變量規則」節**

在 invariants.md 適當位置（跨系統規則區）加：
```markdown
## 資料模型不變量規則（防散落純量 drift）

1. **可衍生聚合 → computed getter，不存可變欄位**。任何 `= f(權威來源)` 的值用唯讀 getter（範本 `team_data.population` / `wounded` / `anon_combat_skill`）。物理上不可 drift；加人必須動真來源（named_members / anon_cohorts），不能偷改數字。
2. **來源/雙向關係走單一入口**。anon 改動走 `AnonCohort`/`AnonTierSystem` 入口；勿直接 `anon_cohorts[k] = ...`。
3. **不可衍生的真存量 / 不變量 → 註冊進 `InvariantAudit.check`**。真存守恆量（coin_eq）、cohort 自洽、faction/subteam 雙向等靠 audit 守。加新不變量 = 加一個 `_check_*` 並在 `check()` 呼叫。
4. **改資料模型前讀本節。**
```

- [ ] **Step 3: Commit**

```bash
git add docs/invariants.md
git commit -m "docs(invariants): anon cohort 模型 + 資料模型不變量規則"
```

---

## Task 4: 回歸 + hand-back

- [ ] **Step 1: 全回歸**

```powershell
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd
```
Expected: headless `=== DONE ===`、cohort 測試綠；multi `coin_eq delta=0` 全 config、`population drift=0`（cohort 自洽網 0 違反；殘留只 pre-existing `faction 反向破`）、無 `SCRIPT ERROR`。

- [ ] **Step 2: hand-back** `docs/superpowers/handbacks/2026-06-17-anon-cohort-phase4.md`：
- 實作摘要：cohort 自洽網 + 測試 + invariants.md。
- 驗證：headless 綠、coin_eq=0、population/cohort drift=0。
- 連動風險：存檔遷移 N/A（無 save 系統）。旁註 `faction 反向破` pre-existing（獨立 known issue，建議後續開）。
- 收尾聲明：anon 統一 cohort 模型重構完成（Phase 1→4 + coin fix）。

- [ ] **Step 3: Commit + push + 回報**

```bash
git add docs/superpowers/handbacks/2026-06-17-anon-cohort-phase4.md
git commit -m "docs: anon cohort phase4 hand-back（重構收尾）"
git push -u origin feat/anon-cohort-phase4
```
回報分支（finishing 選 Option 3，主 session merge）。

---

## Self-Review

**Spec coverage：** 完成 spec Phase 5「掃殘餘 + InvariantAudit cohort 網 + invariants.md 文件化」。存檔遷移 spec 列為條件項，專案無 save → N/A。

**Placeholder scan：** 無 TBD。Task 2 的 `_contains_substr` / `_has_no_cohort_violation` 已附明確「用 check() 過濾、勿重複定義」指示。

**Type consistency：** `AnonCohort._parse`（回 Array[String]）/`TIER_ORDER`/`HEALTH_ORDER` 對齊已 merge 版。`_check_anon_cohort(state, out)` 簽名對齊既有 `_check_*` 模式。`InvariantAudit.check(state)->Array[String]` 不變。
