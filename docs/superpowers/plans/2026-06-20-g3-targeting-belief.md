# G3-targeting 攻擊目標選擇讀 belief Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 補 WHAT §8「攻擊目標改讀 belief 內容」的漏網——攻擊**目標選擇** `find_prosperity_prey` / `_find_weakest_prey` 現讀 `prey.population`/`prey.resources` **實際值(上帝視角)** → 改讀 `BeliefSystem.best_estimate`。**讓偽裝(interaction 低報 armed_est)/假情報誘殺真生**：信對方弱才去打 → 假弱（偽裝/失真）→ 誘入陷阱。

**Architecture:** G3a/b 遷的是「本就讀 team_intel 的決策 reader」；這兩個選擇器**本來直讀 prey 真值** → G3 漏網（G3d-2 揭）。G3d-1 gate 只調「commit 把握」(uncertainty)，不調「選誰」(value)。本 plan 補 value 面：weakness/richness 從 belief 估。**誘殺 = 選擇讀假 belief**（gate 是把握層、selection 是價值層，兩層齊才完整）。

**Tech Stack:** Godot 4.2.2 GDScript；`faction_ai_system`（兩選擇器）；`BeliefSystem.best_estimate`/`has_belief`（既有）；headless harness。

## Global Constraints

- wrapper 跑；改後 `--import`。
- WHAT/HOW 來源：`specs/2026-06-19-g3-info-decision-design`（§8 攻擊目標讀 belief、§7 誘殺）。
- 回歸閘：`=== DONE ===` + 0 assert fail + coin_eq=0 + InvariantAudit 0 + 1000 Tick。**仍有攻擊（不凍結）**。不用 multi drift。
- **行為允許變**（目標選擇改吃 belief，偽裝/失真影響選擇）；閘 = 不崩+守恆+不凍結。
- **OUT**：威脅(防禦)uncertainty-gate（§8，post-measure）、team_known claim 化（§3，post-measure）、情報戰 C。本 plan 只攻擊**選擇**的真值→belief 遷移。

## 鎖定設計決策（實作者勿再設計）

- **禁讀敵真值**：`find_prosperity_prey`/`_find_weakest_prey` 對 prey 的 population/resources/armed **一律走 `BeliefSystem.best_estimate(state, team.team_id, tid)`**，不讀 `prey.population`/`prey.resources`。自身真值(team.population)照讀（自己不靠情報）。
- **無 belief = 不評估目標**（非 god-view fallback）：候選 `if not BeliefSystem.has_belief(state, team.team_id, tid): continue`。發現(team_discovered)即在視野→通常有親見 belief；無 belief 的不該被當目標（不知道的打不了）。**禁 fallback 回真值**（否則 god-view 回潮，違 §「team_discovered 僅可見性不作真值」）。
- **weakness 吃 armed_est（偽裝載體）**：`weakness = clamp(1 − armed_est / max(team.population,1), 0, 1)`，`armed_est = bel.get("armed_est", pop_est)`（tier2 有 armed→偽裝低報在此咬；tier0/1 無 armed→退 pop_est）。`pop_est = bel.get("population_est", 0)`。
- **richness 吃 belief 估**：tier2 有 → `(coin_est+food_est+material_est)/100`；無 tier2 但有 `resource_scale`(0-3,tier0/1 粗估) → 用 `float(resource_scale)`；皆無 → 0。粗細混排，僅作候選相對排序（TEST VALUE）。
- **survival `_find_weakest_prey` 同遷**：`pop_est = bel.population_est`、food 門檻改 `bel.get("food_est", -1)`（無 tier2 食物估 → 視為不知→該門檻不擋或保守跳過，見 Task2）。catch_up reachability（PathSystem）讀真位置不變（移動是物理非情報，OUT）。
- **誘殺 emergent**：選擇讀假弱 belief（偽裝/relay 低報）→ 選假弱目標 → 派攻 → 戰鬥按**真**實力結算 → 攻方踢鐵板。慎重者先 scout(G3d-2)→親見壓假→看穿真強→不選(score 變)→避誘殺；莽者照選照衝→誘殺。

## File Structure

- `scripts/simulation/faction_ai_system.gd`（`find_prosperity_prey` + `_find_weakest_prey` 遷 belief）。
- `scripts/debug/headless_test.gd`、`docs/invariants.md`、`docs/known_issues.md`、`docs/progress.md`。

---

### Task 1: find_prosperity_prey 讀 belief

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`（`find_prosperity_prey`）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- 候選迴圈內：`has_belief` 守衛 + richness/weakness 從 `best_estimate` 估。

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_prey_select_reads_belief() -> void:
	print("--- G3-targeting：攻擊選擇讀 belief ---")
	# team(強) + prey 真實強(armed 高) 但 belief 偽裝弱(armed_est 低) → 被選為 prey（誘殺 setup）
	#   構造 prey 真 population 高；team 對 prey 的 belief armed_est 低（偽裝）
	#   find_prosperity_prey 應選中 prey（基於假弱 belief，非真強）
	# 另案：team 對 candidate 無 belief → 不選（has_belief 守衛）
	# 另案：belief 顯示 prey 強(armed_est 高) → weakness 低 → 不選（看穿→避誘殺）
	print("prey select belief OK")
```

- [ ] **Step 2: 跑 harness 驗證失敗**（現讀真值，偽裝 belief 不影響選擇）

- [ ] **Step 3: 實作遷移**

`find_prosperity_prey` 候選迴圈，取代 `prey.population`/`prey.resources` 真值讀：
```gdscript
	for tid in state.team_discovered.get(team.team_id, []):
		if tid == team.team_id: continue
		var prey: TeamData = state.teams.get(tid)
		if prey == null: continue
		if prey.faction_id != -1 and prey.faction_id == team.faction_id: continue
		# G3-targeting：無情報 → 不評估（禁 god-view；不知道的打不了）
		if not BeliefSystem.has_belief(state, team.team_id, tid): continue
		var catch_result: Dictionary = PathSystem.estimate_catch_up(state, team, tid)
		if not catch_result.reachable: continue
		# 價值/弱點從 belief 估（偽裝低報 armed → 看似弱 → 誘殺載體）
		var bel: Dictionary = BeliefSystem.best_estimate(state, team.team_id, tid)
		var pop_est: float = float(bel.get("population_est", 0.0))
		var armed_est: float = float(bel.get("armed_est", pop_est))
		var richness: float = _belief_richness(bel)
		var weakness: float = clampf(1.0 - armed_est / maxf(float(team.population), 1.0), 0.0, 1.0)
		var border: float = 1.0 if _is_border_adjacent(team, prey) else 0.3
		var eta_days: float = maxf(float(catch_result.eta) / 240.0, 1.0)
		var score: float = (richness * greed + weakness * cruelty + border * ambition) / eta_days
		if score > best_score:
			best_score = score
			best_id = tid
	return best_id

# belief 財富估：tier2 有資源估 → sum/100；tier0/1 只有 resource_scale(0-3) → 粗估；皆無 → 0。TEST VALUE。
static func _belief_richness(bel: Dictionary) -> float:
	if bel.has("coin_est") or bel.has("food_est") or bel.has("material_est"):
		return (float(bel.get("coin_est", 0.0)) + float(bel.get("food_est", 0.0)) + float(bel.get("material_est", 0.0))) / 100.0
	if bel.has("resource_scale"):
		return float(bel.get("resource_scale", 0))
	return 0.0
```
> `_is_border_adjacent` 讀真位置不變（位置是可見性 team_discovered 已過濾，且移動物理非情報範疇）。

- [ ] **Step 4: --import + 回歸**；Expected `prey select belief OK`、`=== DONE ===`、coin_eq=0、1000 Tick、仍有 `[ProsperityAttack]`。

- [ ] **Step 5: Commit**
```bash
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(g3-targeting): find_prosperity_prey 讀 belief(偽裝/假情報誘殺載體,禁 god-view)"
```

---

### Task 2: _find_weakest_prey（survival loot）讀 belief

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`（`_find_weakest_prey`）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- 同模式：has_belief 守衛 + pop/food 從 belief。

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_survival_prey_reads_belief() -> void:
	print("--- G3-targeting：survival 掠食選擇讀 belief ---")
	# 絕境 team；candidate belief pop_est 低(看似弱)→被選；無 belief→跳過
	print("survival prey belief OK")
```

- [ ] **Step 2: 跑 harness 驗證失敗**

- [ ] **Step 3: 實作遷移**

```gdscript
func _find_weakest_prey(state: WorldState, team: TeamData) -> int:
	var best_id: int = -1
	var best_pop: float = 999999.0
	for tid in state.team_discovered.get(team.team_id, []):
		if tid == team.team_id: continue
		var t: TeamData = state.teams.get(tid)
		if t == null: continue
		if not BeliefSystem.has_belief(state, team.team_id, tid): continue   # 無情報→不選
		if not PathSystem.estimate_catch_up(state, team, tid).reachable: continue
		var bel: Dictionary = BeliefSystem.best_estimate(state, team.team_id, tid)
		var pop_est: float = float(bel.get("population_est", 0.0))
		if pop_est >= float(team.population) * 0.7: continue   # belief 看似不夠弱→跳
		# 食物門檻：tier2 有 food_est 才據；無估 → 不以食物擋（不知道→不排除，由 pop 弱點決定）
		if bel.has("food_est") and float(bel.get("food_est", 0.0)) < 20.0: continue
		if pop_est < best_pop:
			best_pop = pop_est
			best_id = tid
	return best_id
```
> food 門檻原意「掠到的值得」；belief 無 food 估時不擋（保留候選），避免因情報缺失反而更激進/保守失衡——以 pop 弱點為主，TEST VALUE。

- [ ] **Step 4: --import + 回歸**；Expected `survival prey belief OK`、`=== DONE ===`、仍有 `[SurvivalLoot]`、1000 Tick。

- [ ] **Step 5: Commit**
```bash
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(g3-targeting): _find_weakest_prey 讀 belief(survival 掠食禁 god-view)"
```

---

### Task 3: invariant + progress + 回歸

**Files:**
- Modify: `docs/invariants.md`、`docs/known_issues.md`、`docs/progress.md`

- [ ] **Step 1: invariant 補**

`docs/invariants.md` belief 段補：
```markdown
- **攻擊目標選擇讀 belief**：`find_prosperity_prey`/`_find_weakest_prey` 的 prey 價值/弱點一律經 `BeliefSystem.best_estimate`；無 belief 不評估（禁讀 prey 真 population/resources/armed）。偽裝(低報 armed_est)/失真 → 假弱 → 誘殺載體。位置/reachability 屬可見性物理，不在此限。
```

- [ ] **Step 2: progress / known_issues**

- progress：G3-targeting ✅ → **誘殺脊椎閉環**（選擇讀假 belief + gate 把握 + scout 查證 + 戰鬥按真實力結算）。G3 核心迴路真整條落地。
- known_issues：G3d-2 揭的 find_prosperity_prey god-view 缺口 **已補**。延 post-measure：威脅 uncertainty、team_known claim 化、情報戰 C。
- TEST VALUE：_belief_richness 粗細混排、survival food 門檻處理。

- [ ] **Step 3: 全回歸**
```
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`、coin_eq=0、InvariantAudit 0、1000 Tick、`[ProsperityAttack]`+`[SurvivalLoot]`+`[Scout]` 並見。

- [ ] **Step 4: Commit**
```bash
git add docs/invariants.md docs/known_issues.md docs/progress.md
git commit -m "docs(g3-targeting): 攻擊選擇讀 belief invariant + 誘殺閉環 + 進度"
```

---

## Self-Review 註記

- **誘殺閉環**：本 plan 補最後一塊——選擇層讀假 belief。閉環 = 偽裝/失真(G3c)→選假弱目標(本 plan)→gate 把握(G3d-1)→scout 查證或莽者照衝(G3d-2)→戰鬥按真實力結算→慎重者避/莽者踢鐵板。
- **禁 god-view fallback**：無 belief→不評估（非退回真值）。發現即視野通常有親見 belief→正常目標保留；regression 驗仍攻擊。
- **偽裝在 armed_est 咬**：weakness 用 armed_est(tier2 偽裝載體)，tier0/1 退 pop_est。偽裝只在攻方有 tier2 belief 時生效（合理：需近距互動才有 armed 情報，偽裝騙的正是它）。
- **自身真值照讀**：team.population（自己不靠情報）。只敵方走 belief。
- **行為非保留**：選擇吃 belief→偽裝/失真改變誰被打。閘 = 不崩+守恆+不凍結。
- **survival food 門檻**：belief 無 food 估時不擋（情報缺失不該反致激進/保守失衡），以 pop 弱點為主。TEST VALUE。
- **執行確認**：`has_belief` 守衛勿漏（god-view 回潮）；自身真值 vs 敵 belief 分清；`_belief_richness` tier2/tier0-1/無 三態；1000 Tick 驗仍攻擊；位置讀真值（物理）不算違規。
