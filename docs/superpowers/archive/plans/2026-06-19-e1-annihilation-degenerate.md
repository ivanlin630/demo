# E-1 結構免疫退化修 + 武裝下限 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 殺結構免疫——敗方損耗落整隊 pop（含未上場 anon），tier 加權存活（平民承重/訓練兵多生還），encounter 與 npc_combat 對稱；加武裝下限堵 0 武裝免疫 cheese。

**Architecture:** `kill_random` 加選用 survival-bias 權重（預設空=現行為，不破既有 caller）。encounter `resolve_encounter_end` 把上場陣亡率外推到 reserve anon；npc_combat `_end_combat` 補敗方 pop 損耗。`armed_anon_ratio` 在消費端（encounter spawn + npc 戰力）設下限，不覆寫推導值。

**Tech Stack:** Godot 4.2.2 GDScript；headless harness（`scripts/debug/headless_test.gd`，`_test_*` 註冊於 `_initialize()`，`assert` 失敗即中止）。

## Global Constraints

- 跑 wrapper：`.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`（UTF-8）。
- 新 `_test_*` 須在 `_initialize()` 加呼叫註冊。
- pop 變動只經 cohort API（`AnonTierSystem.kill_random` / `AnonCohort`），禁裸改 population getter（invariants anon 規則）。
- 數值全標 TEST VALUE；回歸閘：`=== DONE ===` + coin_eq=0 + InvariantAudit 0 + 1000 Tick 無崩潰；既有 encounter/anon-cohort 測試不破。
- spec 來源：`docs/superpowers/specs/2026-06-19-e1-annihilation-degenerate-design.md`；母 spec `2026-06-19-combat-unification-umbrella-design.md`。
- **不**做完整意志/人海/戰俘模型（移出 E-1）。繼承統一另 plan（`2026-06-19-leader-succession-single-source`）——本 plan 可獨立 land，但「打到死」滅團整鏈需繼承 plan 也合入。

---

### Task 1: `kill_random` 加 survival-bias 權重（向後相容）

**Files:**
- Modify: `scripts/simulation/anon_tier_system.gd`（`kill_random` 加選用參數 + `SURVIVAL_KILL_WEIGHT` const）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Produces: `AnonTierSystem.kill_random(team, count, _source, tier_weight: Dictionary = {}) -> Dictionary`。`tier_weight` 空 = 現行 count 比例（不破既有 caller）；非空 = 各 tier 抽中權重 ∝ `count × tier_weight[tier]`（偏向高權重 tier 多死）。`const SURVIVAL_KILL_WEIGHT = {"平民":1.0,"新兵":0.6,"老兵":0.3,"菁英":0.15}`（TEST VALUE，死亡可能性，存活反比）。

- [ ] **Step 1: 寫失敗測試**

加到 `scripts/debug/headless_test.gd`：

```gdscript
func _test_kill_random_survival_bias() -> void:
	print("--- kill_random survival-bias：平民死多於菁英 ---")
	var t := TeamData.new(); t.team_id = 1
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", 50)
	AnonCohort.add(t.anon_cohorts, "菁英", "healthy", 50)
	var killed: Dictionary = AnonTierSystem.kill_random(t, 40, "test", AnonTierSystem.SURVIVAL_KILL_WEIGHT)
	assert(killed.get("平民", 0) > killed.get("菁英", 0),
		"平民應死多於菁英（實際 平民=%d 菁英=%d）" % [killed.get("平民",0), killed.get("菁英",0)])
	# 空權重 = 現行為（約略均等，不偏）
	var t2 := TeamData.new(); t2.team_id = 2
	AnonCohort.add(t2.anon_cohorts, "平民", "healthy", 50)
	AnonCohort.add(t2.anon_cohorts, "菁英", "healthy", 50)
	var k2: Dictionary = AnonTierSystem.kill_random(t2, 40, "test")
	assert(k2.get("平民",0) + k2.get("菁英",0) == 40, "空權重應如常移除 40")
```

`_initialize()` 加 `_test_kill_random_survival_bias()`。

- [ ] **Step 2: 跑 harness 驗證失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: 在 `kill_random survival-bias` 處失敗（4th 參數/const 不存在）。

- [ ] **Step 3: 實作**

`scripts/simulation/anon_tier_system.gd`：加 const（與其他 const 並列）：

```gdscript
# 戰鬥敗方損耗的 tier 死亡權重（存活反比）。TEST VALUE。
const SURVIVAL_KILL_WEIGHT: Dictionary = {"平民": 1.0, "新兵": 0.6, "老兵": 0.3, "菁英": 0.15}
```

把 `kill_random`（:83-100）換成：

```gdscript
# weighted random 依各 tier count（× 選用 tier_weight）抽，不減 named。回 { tier: 死亡數 }
static func kill_random(team: TeamData, count: int, _source: String, tier_weight: Dictionary = {}) -> Dictionary:
	var killed: Dictionary = {}
	for tier in TIER_ORDER:
		killed[tier] = 0
	for _i in range(count):
		# 只移 healthy；按 healthy 桶 count×weight 加權
		var weighted: Array = []   # [[tier, w_float], ...]
		var total_w: float = 0.0
		for tier in TIER_ORDER:
			var c: int = int(team.anon_cohorts.get(AnonCohort._key(tier, "healthy"), 0))
			if c <= 0:
				continue
			var w: float = float(c) * float(tier_weight.get(tier, 1.0))
			if w <= 0.0:
				continue
			weighted.append([tier, w])
			total_w += w
		if total_w <= 0.0:
			break
		var roll: float = randf() * total_w
		var acc: float = 0.0
		for pair in weighted:
			acc += pair[1]
			if roll < acc:
				killed[pair[0]] += AnonCohort.remove(team.anon_cohorts, pair[0], "healthy", 1)
				break
	return killed
```

> 註：`AnonCohort.remove(team.anon_cohorts, tier, "healthy", 1)` 沿用原 :98 同簽名。

- [ ] **Step 4: 跑 harness 驗證通過**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `kill_random survival-bias` 過；既有 anon-cohort/encounter/force_occupy 相關測試不破（空權重路徑等價）。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/anon_tier_system.gd scripts/debug/headless_test.gd
git commit -m "feat(combat): kill_random 加選用 survival-bias 權重(向後相容)"
```

---

### Task 2: encounter 敗方 reserve 連坐（A，殺結構免疫）

**Files:**
- Modify: `scripts/simulation/encounter_system.gd:1186-1194`（on-field kill 後加 reserve casualty）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Consumes: `kill_random(..., tier_weight)`（Task 1）。
- Produces: encounter 結算時，敗方未上場 anon 按上場陣亡率連坐。`const RESERVE_CASUALTY_MULT := 1.0`（TEST VALUE）。

**背景**：encounter:1186-1194 現只 `kill_random(t, dead_anon, "combat")`（上場陣亡）。team.anon_cohorts 持全 anon；上場是抽樣子集。reserve = 全 anon − 上場 anon。

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_e1_encounter_reserve_casualty() -> void:
	print("--- E-1：encounter 敗方 reserve 連坐 ---")
	# 大隊 pop 遠超 ANON_UNIT_CAP → 多數 anon 未上場；模擬上場高陣亡 → reserve 應跟著減
	var enc := EncounterSystem.new()
	var s := WorldState.new(); s.world = WorldData.new()
	var loser := TeamData.new(); loser.team_id = 1
	AnonCohort.add(loser.anon_cohorts, "平民", "healthy", 100)
	s.teams[1] = loser
	var anon_before: int = AnonCohort.total(loser.anon_cohorts)
	# 模擬：上場 10 anon、陣亡 8（field_rate=0.8）→ reserve(90) 應折損 ~0.8×90
	enc._apply_reserve_casualty(s, 1, 10, 8)   # (state, team_id, onfield_anon, dead_anon)
	var anon_after: int = AnonCohort.total(loser.anon_cohorts)
	assert(anon_after < anon_before - 8,
		"reserve 應額外連坐（before=%d after=%d，僅扣 8 表免疫未修）" % [anon_before, anon_after])
```

`_initialize()` 加註冊。

- [ ] **Step 2: 跑 harness 驗證失敗**

Expected: `_apply_reserve_casualty` 不存在 → 失敗中止。

- [ ] **Step 3: 實作 helper + 接線**

`scripts/simulation/encounter_system.gd` 加 const（檔頭 const 區）+ helper：

```gdscript
const RESERVE_CASUALTY_MULT: float = 1.0   # TEST VALUE：reserve 連坐比例（1.0=與上場同命運）

# 敗方未上場 anon 按上場陣亡率連坐（殺結構免疫；tier 加權存活）
func _apply_reserve_casualty(state: WorldState, team_id: int, onfield_anon: int, dead_anon: int) -> void:
	var t: TeamData = state.teams.get(team_id)
	if t == null or onfield_anon <= 0 or dead_anon <= 0:
		return
	var field_rate: float = float(dead_anon) / float(onfield_anon)
	var total_anon: int = AnonCohort.total(t.anon_cohorts)
	var reserve: int = maxi(total_anon - (onfield_anon - dead_anon), 0)   # 全 anon 減「上場存活」≈ reserve+已死上場；已死上場由 1194 kill 處理，故扣存活上場
	# 修正：reserve = 全 anon − 上場總數（上場死/活皆已在 1194 前的 onfield 結算範圍）
	reserve = maxi(total_anon - onfield_anon, 0)
	var reserve_dead: int = roundi(field_rate * float(reserve) * RESERVE_CASUALTY_MULT)
	if reserve_dead <= 0:
		return
	AnonTierSystem.kill_random(t, reserve_dead, "combat_reserve", AnonTierSystem.SURVIVAL_KILL_WEIGHT)
	print("[E1Reserve] Team%d reserve 連坐 -%d（field_rate=%.2f reserve=%d）" % [team_id, reserve_dead, field_rate, reserve])
```

> 註：`total_anon` 須在 encounter:1194 那批 on-field `kill_random` **之前**量測；helper 內用 `onfield_anon`（上場 anon 總數）推 reserve。caller 提供 onfield_anon。

在 `resolve_encounter_end` 的 1186-1194 迴圈處改造：對 atk_id/def_id 各算上場 anon 總數與陣亡數，先量 `total_anon`，做原 on-field `kill_random`，**僅對敗方**呼 `_apply_reserve_casualty`。把 1186-1194：

```gdscript
	for team_id in [atk_id, def_id]:
		var dead_anon: int = 0
		for u in state.encounter_units:
			if u["team_id"] != team_id: continue
			if u["person_id"] != -1: continue
			if is_dead(u, state): dead_anon += 1
		var t: TeamData = state.teams.get(team_id)
		if t:
			AnonTierSystem.kill_random(t, dead_anon, "combat")   # cohort 唯一來源；population 為 getter
```

換成：

```gdscript
	var loser_for_reserve: int = -1
	if result == "attacker_win": loser_for_reserve = def_id
	elif result == "defender_win": loser_for_reserve = atk_id
	for team_id in [atk_id, def_id]:
		var dead_anon: int = 0
		var onfield_anon: int = 0
		for u in state.encounter_units:
			if u["team_id"] != team_id: continue
			if u["person_id"] != -1: continue
			onfield_anon += 1
			if is_dead(u, state): dead_anon += 1
		var t: TeamData = state.teams.get(team_id)
		if t:
			var reserve_args := [onfield_anon, dead_anon]   # 量在 on-field kill 前
			AnonTierSystem.kill_random(t, dead_anon, "combat")   # 上場陣亡（cohort 唯一來源）
			# 僅敗方 reserve 連坐（殺結構免疫）
			if team_id == loser_for_reserve:
				_apply_reserve_casualty(state, team_id, reserve_args[0], reserve_args[1])
```

> 此段在 beast/draw 早 return 之前，沿用既有位置（beast/draw 不會走到敗方 reserve，因 draw 無 loser、beast 另 return）。

- [ ] **Step 4: 跑 harness 驗證通過**

Run harness。Expected: `_test_e1_encounter_reserve_casualty` 過；既有 encounter 結算測試（`_enc*`）若因 reserve 連坐漂移 → 確認是預期行為變動（敗方大隊現會掉 reserve），調整既有測試斷言或標註。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/encounter_system.gd scripts/debug/headless_test.gd
git commit -m "feat(combat): encounter 敗方 reserve 連坐 tier 加權(殺結構免疫)"
```

---

### Task 3: npc_combat 敗方 pop 損耗（A，對稱）

**Files:**
- Modify: `scripts/simulation/npc_combat_system.gd`（`_end_combat` 加敗方 pop 損耗 + const）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Consumes: `kill_random(..., tier_weight)`（Task 1）。
- Produces: npc_combat `_end_combat(state, winner_id, loser_id)` 對 loser 施 `LOSER_CASUALTY_RATE` 比例 tier 加權 pop 損耗。`const LOSER_CASUALTY_RATE := 0.2`（TEST VALUE，複用 force_occupy 20% 量級）。

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_e1_npc_combat_loser_pop_loss() -> void:
	print("--- E-1：npc_combat 敗方 pop 損耗（對稱）---")
	var nc := NpcCombatSystem.new()
	var s := WorldState.new(); s.world = WorldData.new()
	var winner := TeamData.new(); winner.team_id = 1
	var wl := PersonData.new(); wl.id = 1000; wl.team_id = 1; wl.values = {"殘忍": 0.5}
	s.persons[wl.id] = winner_leader_set(s, winner, wl)
	var loser := TeamData.new(); loser.team_id = 2
	var ll := PersonData.new(); ll.id = 2000; ll.team_id = 2
	s.persons[ll.id] = ll; loser.leader_id = ll.id
	AnonCohort.add(loser.anon_cohorts, "平民", "healthy", 50)
	s.teams[1] = winner; s.teams[2] = loser
	winner.combat_target = 2; loser.combat_target = 1
	var anon_before: int = AnonCohort.total(loser.anon_cohorts)
	nc._end_combat(s, 1, 2)
	assert(AnonCohort.total(loser.anon_cohorts) < anon_before,
		"敗方 anon 應損耗（before=%d after=%d）" % [anon_before, AnonCohort.total(loser.anon_cohorts)])

func winner_leader_set(_s: WorldState, w: TeamData, wl: PersonData) -> PersonData:
	wl.team_id = w.team_id; w.leader_id = wl.id; return wl
```

> 若 helper 命名衝突，內聯設定即可（`winner.leader_id = wl.id`）。

`_initialize()` 加 `_test_e1_npc_combat_loser_pop_loss()`。

- [ ] **Step 2: 跑 harness 驗證失敗**

Expected: 敗方 anon 不變 → 斷言失敗。

- [ ] **Step 3: 實作**

`scripts/simulation/npc_combat_system.gd` 加 const（檔頭）：

```gdscript
const LOSER_CASUALTY_RATE: float = 0.2   # TEST VALUE：敗方 pop 損耗比例（複用 force_occupy 量級）
```

在 `_end_combat`（:205）的 loot/記憶結算後、`_try_subjugate` 前，加敗方 pop 損耗（人類隊才施，beast 已早 return）：

```gdscript
	# E-1：敗方 pop 損耗（對稱 encounter；tier 加權存活）
	var loser_anon: int = AnonCohort.total(loser.anon_cohorts)
	var loser_dead: int = roundi(float(loser_anon) * LOSER_CASUALTY_RATE)
	if loser_dead > 0:
		AnonTierSystem.kill_random(loser, loser_dead, "combat_defeat", AnonTierSystem.SURVIVAL_KILL_WEIGHT)
		print("[E1Defeat] Team%d 敗方 pop 損耗 -%d" % [loser_id, loser_dead])
```

> 放在 `loser` 仍存在（未被 subjugate/erase）的點；`_end_combat` 內 `loser` 已取得（:207）。確認位置在 beast early-return（:211-219）之後。

- [ ] **Step 4: 跑 harness 驗證通過**

Run harness。Expected: 測試過；1000 Tick sim 中 NPC 戰後敗方確實減員（log `[E1Defeat]`），coin_eq 守恆（pop 損耗不涉 coin）。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/npc_combat_system.gd scripts/debug/headless_test.gd
git commit -m "feat(combat): npc_combat 敗方 pop 損耗 tier 加權(對稱 encounter)"
```

---

### Task 4: 武裝下限（C，堵 0 武裝 cheese）

**Files:**
- Modify: `scripts/simulation/encounter_system.gd:247-248`（spawn anon 用 floored ratio）
- Modify: `scripts/simulation/npc_combat_system.gd:381`（_strength_raw anon 戰力用 floored ratio）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Produces: `const ARMED_RATIO_FLOOR := 0.1`（TEST VALUE）；消費端 `max(armed_anon_ratio, FLOOR)`，不覆寫 `team.armed_anon_ratio` 推導值。

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_e1_armed_floor() -> void:
	print("--- E-1：武裝下限 → 0 武裝隊仍 field anon ---")
	var enc := EncounterSystem.new()
	var s := WorldState.new(); s.world = WorldData.new()
	var atk := TeamData.new(); atk.team_id = 0; atk.tile_pos = Vector2i(0,0)
	var al := PersonData.new(); al.id = 0; al.team_id = 0; s.persons[0] = al; atk.leader_id = 0
	atk.armed_anon_ratio = 0.0
	AnonCohort.add(atk.anon_cohorts, "平民", "healthy", 50)
	var def := TeamData.new(); def.team_id = 1; def.tile_pos = Vector2i(0,0)
	var dl := PersonData.new(); dl.id = 1000; dl.team_id = 1; s.persons[1000] = dl; def.leader_id = 1000
	def.armed_anon_ratio = 1.0; AnonCohort.add(def.anon_cohorts, "平民", "healthy", 5)
	s.teams[0] = atk; s.teams[1] = def
	enc.init_encounter(s, 0, 1, "normal")
	var atk_anon_units: int = 0
	for u in s.encounter_units:
		if u["team_id"] == 0 and u["person_id"] == -1: atk_anon_units += 1
	assert(atk_anon_units > 0, "0 武裝隊應因 floor 仍 field anon，實際=%d" % atk_anon_units)
```

`_initialize()` 加註冊。

- [ ] **Step 2: 跑 harness 驗證失敗**

Expected: 0 武裝 → spawn 0 anon → 斷言失敗。

- [ ] **Step 3: 實作**

`scripts/simulation/encounter_system.gd` 加 const + 改 :247-248：

```gdscript
const ARMED_RATIO_FLOOR: float = 0.1   # TEST VALUE：最低參戰比，堵 0 武裝免疫
```

```gdscript
		var atk_ratio: float = maxf(atk.armed_anon_ratio, ARMED_RATIO_FLOOR)
		var def_ratio: float = maxf(def.armed_anon_ratio, ARMED_RATIO_FLOOR)
		var atk_anon: int = mini(int(float(atk.population) * atk_ratio), ANON_UNIT_CAP)
		var def_anon: int = mini(int(float(def.population) * def_ratio), ANON_UNIT_CAP)
```

`scripts/simulation/npc_combat_system.gd` `_strength_raw`:381（`melee_str += float(anon_pop) * team.armed_anon_ratio * tier_mult`）改：

```gdscript
	var floored_ratio: float = maxf(team.armed_anon_ratio, NpcCombatSystem.ARMED_RATIO_FLOOR)
	melee_str += float(anon_pop) * floored_ratio * tier_mult
```

並在 npc_combat 檔頭加 `const ARMED_RATIO_FLOOR: float = 0.1`（與 encounter 同值；或共用 config 鍵，MVP 各檔 const）。

- [ ] **Step 4: 跑 harness 驗證通過**

Run harness。Expected: `_test_e1_armed_floor` 過；既有 0 武裝相關測試（headless:8811/10248 等）若漂移 → 確認預期（0 武裝隊現有低戰力），調斷言。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/encounter_system.gd scripts/simulation/npc_combat_system.gd scripts/debug/headless_test.gd
git commit -m "feat(combat): 武裝下限 ARMED_RATIO_FLOOR 堵 0 武裝免疫 cheese"
```

---

### Task 5: 收斂整鏈測試 + invariant + known_issues + 全回歸

**Files:**
- Modify: `docs/invariants.md`（敗方損耗對稱不變量）
- Modify: `docs/known_issues.md`（E-1 結構免疫標退化修 done）
- Test: `scripts/debug/headless_test.gd`（整鏈收斂測試）

- [ ] **Step 1: 整鏈收斂測試**

> 需繼承統一 plan 已合入（anon→0 後 on_leader_death 滅團）。若繼承 plan 未合，本測試只驗 anon 趨減、不驗滅團，並標 TODO。

```gdscript
func _test_e1_converges() -> void:
	print("--- E-1：弱隊反覆被打 → anon 趨減（收斂）---")
	var nc := NpcCombatSystem.new()
	var s := WorldState.new(); s.world = WorldData.new()
	var strong := TeamData.new(); strong.team_id = 1
	var sl := PersonData.new(); sl.id = 1000; sl.team_id = 1; sl.values = {"殘忍":0.5}
	s.persons[1000] = sl; strong.leader_id = 1000
	var weak := TeamData.new(); weak.team_id = 2
	var wl := PersonData.new(); wl.id = 2000; wl.team_id = 2
	s.persons[2000] = wl; weak.leader_id = 2000
	AnonCohort.add(weak.anon_cohorts, "平民", "healthy", 30)
	s.teams[1] = strong; s.teams[2] = weak
	var before: int = AnonCohort.total(weak.anon_cohorts)
	for _i in range(5):
		nc._end_combat(s, 1, 2)   # 反覆敗北
	assert(AnonCohort.total(weak.anon_cohorts) < before / 2,
		"反覆敗北 anon 應大幅趨減（before=%d after=%d）" % [before, AnonCohort.total(weak.anon_cohorts)])
```

`_initialize()` 加註冊。跑 harness 驗證過。

- [ ] **Step 2: 加 invariant**

`docs/invariants.md` 加：

```markdown
### 敗方損耗對稱
- encounter 與 npc_combat 敗方結算皆對敗方整隊 anon pop（**含未上場 reserve**）施 tier 加權陣亡（`AnonTierSystem.kill_random` + `SURVIVAL_KILL_WEIGHT`），無玩家專屬豁免（game-design §對稱性）。
- pop 變動只經 cohort API。武裝下限 `ARMED_RATIO_FLOOR` 在消費端（encounter spawn / npc 戰力）套用，不覆寫 `armed_anon_ratio` 推導值。
```

- [ ] **Step 3: 更新 known_issues**

`docs/known_issues.md` E-1「結構免疫」標：退化修已實作（A 整隊 pop + B tier 存活 + C 武裝下限，spec `2026-06-19-e1-annihilation-degenerate`）；完整意志/人海模型仍待母 spec `combat-unification-umbrella` 後續子 spec。

- [ ] **Step 4: 全回歸閘**

```
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```

Expected: `=== DONE ===`、coin_eq=0、InvariantAudit 0、1000 Tick 無崩潰。

- [ ] **Step 5: Commit**

```bash
git add docs/invariants.md docs/known_issues.md scripts/debug/headless_test.gd
git commit -m "docs(combat): 敗方損耗對稱 invariant + E-1 結構免疫退化修標 done + 收斂整鏈測試"
```

---

## Self-Review 註記

- **spec 覆蓋**：A encounter reserve(Task2)、A npc_combat 對稱(Task3)、B tier 存活加權(Task1+用於2/3)、C 武裝下限(Task4)、invariant(Task5)、收斂整鏈(Task5)——皆有 task。
- **向後相容**：kill_random 4th 參數預設空 = 現行為；既有 caller（force_occupy:1425、encounter on-field:1194、饑荒）不傳 bias 不變。
- **跨 plan 依賴**：滅團整鏈需繼承統一 plan 合入（Task5 測試標 TODO 容忍）。兩 plan 各自可獨立 land，合則「打到死」完整。
- **TEST VALUE 待平衡**：RESERVE_CASUALTY_MULT/LOSER_CASUALTY_RATE/ARMED_RATIO_FLOOR/SURVIVAL_KILL_WEIGHT 全 TEST VALUE，正式平衡 pass 再調。
- **既有測試漂移**：Task2/4 可能使既有 encounter 平衡測試斷言變動（敗方大隊掉 reserve、0 武裝隊有戰力）——確認屬預期行為變更後調斷言，勿為過測試弱化修正。
