# G3a belief accessor seam Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 包 `BeliefSystem` 單一讀 accessor 於 `team_intel`，遷所有**決策讀者**走它。**行為完全保留**（accessor 暫回現單 entry 語義）。de-risk G3b 的 multi-claim schema 改（屆時只改 accessor 內部，讀者零動）。

**Architecture:** `team_intel[obs][tgt]` 現 single dict，被 ~8 檔決策讀者直讀（`.get(obs,{}).get(tgt,{}).get(field,…)`）。G3a 抽 `BeliefSystem.best_estimate(state,obs,tgt)->Dictionary`（回該 entry），讀者改 `BeliefSystem.best_estimate(...).get(field,…)`。寫者（message/vision/interaction 觀察記錄）**本 plan 不動**（G3b 改 storage 時一起）。

**Tech Stack:** Godot 4.2.2 GDScript；新 `class_name BeliefSystem` → `--import`；headless harness。

## Global Constraints

- wrapper 跑；新 class_name 後 `--import`；新 `_test_*` 註冊。
- **行為完全保留**：accessor 回現語義（`team_intel.get(obs,{}).get(tgt,{})`）。回歸須與改前**零行為變**（既有測試 0 變動）→ 漂移即 bug，停查。
- WHAT/HOW 來源：`specs/2026-06-19-g3-info-decision-design`（§3）、`...-how-design`（§2 G3a）。
- 回歸閘：`=== DONE ===` + 0 assert fail + coin_eq=0 + InvariantAudit 0 + 1000 Tick。
- **OUT**：multi-claim 儲存(G3b)、寫者遷移(G3b)、可信度/技能(G3c)、決策改讀 uncertainty(G3d)。本 plan 只讀 accessor + 讀者遷移。

## File Structure

- `scripts/simulation/belief_system.gd`（新，static 讀 accessor）。
- 讀者遷移：`diplomatic_ai_system.gd` / `strategic_ai_system.gd` / `threat_assessment.gd` / `faction_ai_system.gd` / `player_api_mapper.gd` / `inquiry_system.gd`。
- `scripts/debug/headless_test.gd`、`docs/invariants.md`。

---

### Task 1: BeliefSystem 讀 accessor

**Files:**
- Create: `scripts/simulation/belief_system.gd`
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- `BeliefSystem.best_estimate(state, obs_id:int, tgt_id:int) -> Dictionary`：回 `state.team_intel.get(obs_id,{}).get(tgt_id,{})`（現語義；G3b 換多 claim 聚合）。
- `BeliefSystem.has_belief(state, obs_id, tgt_id) -> bool`。
- `BeliefSystem.uncertainty(state, obs_id, tgt_id) -> float`：G3a stub = `1.0 - confidence`（無資料回 1.0）；G3b 換 claim 分歧。

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_belief_accessor() -> void:
	print("--- G3a：BeliefSystem 讀 accessor（行為保留）---")
	var s := WorldState.new(); s.world = WorldData.new()
	s.team_intel = {1: {2: {"population_est": 50, "confidence": 0.8, "last_pos": Vector2i(3,3)}}}
	var be: Dictionary = BeliefSystem.best_estimate(s, 1, 2)
	assert(be.get("population_est", -1) == 50, "accessor 回現 entry")
	assert(BeliefSystem.has_belief(s, 1, 2), "有 belief")
	assert(not BeliefSystem.has_belief(s, 1, 99), "無 belief")
	assert(BeliefSystem.best_estimate(s, 9, 9).is_empty(), "查無回 {}")
	assert(abs(BeliefSystem.uncertainty(s, 1, 2) - 0.2) < 0.01, "uncertainty=1-conf=0.2")
	assert(abs(BeliefSystem.uncertainty(s, 9, 9) - 1.0) < 0.01, "無資料 uncertainty=1")
	print("belief accessor OK")
```

`_initialize()` 加。

- [ ] **Step 2: 跑 harness 驗證失敗**

Expected: `BeliefSystem` 不存在 → parse fail。

- [ ] **Step 3: 建 BeliefSystem**

建 `scripts/simulation/belief_system.gd`：

```gdscript
class_name BeliefSystem

# team_intel 單一讀 accessor。G3a 回現單 entry 語義；G3b 換 multi-claim 聚合（讀者零動）。
# 禁直讀 state.team_intel（決策讀者一律走此）。

static func best_estimate(state: WorldState, obs_id: int, tgt_id: int) -> Dictionary:
	return state.team_intel.get(obs_id, {}).get(tgt_id, {})

static func has_belief(state: WorldState, obs_id: int, tgt_id: int) -> bool:
	return not best_estimate(state, obs_id, tgt_id).is_empty()

static func uncertainty(state: WorldState, obs_id: int, tgt_id: int) -> float:
	var e: Dictionary = best_estimate(state, obs_id, tgt_id)
	if e.is_empty():
		return 1.0
	return clampf(1.0 - float(e.get("confidence", 1.0)), 0.0, 1.0)
```

- [ ] **Step 4: --import + 跑 harness 驗證通過**

Expected: `belief accessor OK`、`=== DONE ===`。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/belief_system.gd scripts/debug/headless_test.gd
git commit -m "feat(g3a): BeliefSystem 讀 accessor(行為保留;G3b 換 multi-claim 內部)"
```

---

### Task 2: 遷決策讀者走 BeliefSystem（行為保留）

**Files:**
- Modify: `diplomatic_ai_system.gd:9` / `strategic_ai_system.gd:105,137,200` / `threat_assessment.gd:41` / `faction_ai_system.gd:187,452,652,1160,2461` / `player_api_mapper.gd:174,833` / `inquiry_system.gd:45,60,63,89`

**Interfaces:**
- Consumes: `BeliefSystem.best_estimate`（Task1）。
- 每處 `state.team_intel.get(obs,{}).get(tgt,{})` → `BeliefSystem.best_estimate(state, obs, tgt)`（後續 `.get(field,…)` 不變）。**純讀者遷移，行為等價**。

- [ ] **Step 1: 逐檔遷移（機械替換，行為等價）**

各檔把 `state.team_intel.get(<obs>, {}).get(<tgt>, {})` 換 `BeliefSystem.best_estimate(state, <obs>, <tgt>)`。範例：

`diplomatic_ai_system.gd:9`：
```gdscript
	return BeliefSystem.best_estimate(state, obs_id, tgt_id).get("population_est", fallback)
```
`strategic_ai_system.gd:105`：
```gdscript
    return BeliefSystem.best_estimate(state, obs_id, tgt_id).get("population_est", fallback)
```
`threat_assessment.gd:41`、`faction_ai_system.gd:187/452/652/1160/2461`、`player_api_mapper.gd:174/833`、`strategic_ai_system.gd:137/200`、`inquiry_system.gd:45/60/63/89` 同模式（`.get(obs,{}).get(tgt,{})` → `best_estimate`）。

> **不動寫者**：`message_system:215-229`、`interaction_system:657-701`、`vision_system:87-110`（觀察記錄/傳播 = 寫端，G3b 改）。`team_intel.has(...)` / 寫 `team_intel[x][y]=...` 留。
> inquiry_system 若多處迭代 `team_intel[team]` 的 keys（:60 `for tid in team_intel.get(...)`）→ 該迴圈讀「某 obs 對所有 tgt」，可保留迭代 keys，但取 entry 改 `best_estimate`。

- [ ] **Step 2: 跑 harness 驗證通過（行為零變）**

```
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`、**既有測試全 0 變動**（行為等價）、coin_eq=0、InvariantAudit 0、1000 Tick。若任何既有 assert 變 → 遷移改了語義，停查。

- [ ] **Step 3: 確認無遺漏直讀（決策端）**

```bash
grep -rn "team_intel.get(" scripts/simulation/ | grep -v "belief_system.gd"
```
Expected: 剩餘只在**寫者**（message/vision/interaction）+ `team_intel.has`/寫入。決策讀者應全走 BeliefSystem。列出剩餘確認皆為寫端（G3b 範圍）。

- [ ] **Step 4: Commit**

```bash
git add scripts/simulation/*.gd scripts/debug/headless_test.gd
git commit -m "refactor(g3a): 決策讀者遷 BeliefSystem.best_estimate(行為保留)"
```

---

### Task 3: invariant + 回歸

**Files:**
- Modify: `docs/invariants.md`、`docs/known_issues.md`

- [ ] **Step 1: invariant（占位，G3b 補完）**

`docs/invariants.md` Information 段補：

```markdown
## belief 單一 accessor
- 決策讀 `team_intel` 一律經 `BeliefSystem`（`best_estimate`/`uncertainty`/`has_belief`），**禁決策端直讀 `state.team_intel`**。
- G3a：accessor 回現單 entry（行為保留）。G3b：內部換 multi-claim 聚合 + uncertainty（讀者零動）。寫端（觀察/傳播）G3b 遷。
```

- [ ] **Step 2: known_issues 註記**

G3 進度：G3a accessor seam ✅（讀者遷移、行為保留、de-risk）。G3b multi-claim 儲存 / G3c 可信度+trust+技能 / G3d 決策+查證 = 待。

- [ ] **Step 3: 全回歸**

```
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`、coin_eq=0、InvariantAudit 0、1000 Tick。

- [ ] **Step 4: Commit**

```bash
git add docs/invariants.md docs/known_issues.md
git commit -m "docs(g3a): belief accessor invariant + G3 進度"
```

---

## Self-Review 註記

- **行為保留**：accessor 回現單 entry 語義；讀者遷移純機械等價。既有測試 0 變動 = 正確性閘。
- **de-risk 目的**：G3b 換 multi-claim 只改 BeliefSystem 內部，~8 讀者零動。
- **OUT**：寫者遷移（message/vision/interaction → G3b）、multi-claim/uncertainty 實質（G3b）、可信度/技能(G3c)、決策讀 uncertainty(G3d)。
- **執行確認**：Step3 grep 確認決策讀者全遷、剩餘只寫端；inquiry 迭代 keys 的迴圈小心（讀「對所有 tgt」非單 tgt）；新 class_name → `--import`。
- **不波及寫端**：`team_intel.has`/寫入留（G3b 動），本 plan 只讀。
