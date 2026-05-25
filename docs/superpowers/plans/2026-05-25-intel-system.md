# IntelSystem Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 建立統一接觸分級情報系統（IntelSystem）：所有 team 對外界認知從「全知直讀」改為 `team_intel` 快照介面，依接觸層級（Tier 0/1/2）決定資訊量，快照在離開視野後持續保留。

**Architecture:** `WorldState` 加 `team_intel` 巢狀 dict（obs_id → tgt_id → snap dict）。`VisionSystem.tick_discovery` 寫 Tier 0（視野內）/ Tier 1（dist ≤ 1）快照。`InteractionSystem._try_interact` 寫 Tier 2（同格接觸）快照，含造假機制。`FactionAISystem.evaluate_all` 從 `team_intel` 橋接 `known_member_states`（移除原 `snapshot_faction_member` stub），`_find_trade_target` 改讀 `coin_est`，`_update_goals` 攻擊 goal 加 `armed_est` 實力比較。`team_discovered` 保留不動（日後統一清除）。

**Tech Stack:** Godot 4.2.2 GDScript；headless 測試（`scripts/debug/headless_test.gd`，print-based 驗證）

**Run tests:**
```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

---

## File Map

| 檔案 | 動作 |
|---|---|
| `scripts/data/world_state.gd` | 加 `team_intel: Dictionary = {}` 欄位 |
| `scripts/simulation/vision_system.gd` | `tick_discovery` 加 `_write_tier01` 呼叫；新增 `_write_tier01` |
| `scripts/simulation/interaction_system.gd` | `_try_interact` 加 `_write_tier2_intel` 呼叫；新增 `_write_tier2_intel` + `_calc_armed` |
| `scripts/simulation/faction_ai_system.gd` | `evaluate_all` 移除 stub，改 team_intel 橋接；`_richest_member` 讀 `food_est`；`_declare_established` 移除 stub；`_find_trade_target` 讀 `coin_est`；`_update_goals` 攻擊 goal 加實力檢查；新增 `_calc_own_armed` |
| `scripts/debug/headless_test.gd` | 更新 FactionKnownState 場景（預建 team_intel snap）；加 Tier 0/1、Tier 2、攻擊決策驗證場景 |
| `docs/progress.md` | 加入 IntelSystem 完成項目 |

---

### Task A: WorldState — 加 team_intel 欄位

**Files:**
- Modify: `scripts/data/world_state.gd`

- [ ] **Step 1: 確認現況**

讀 `scripts/data/world_state.gd`。確認第 8 行為 `var team_discovered: Dictionary = {}`，下方無 `team_intel`。

- [ ] **Step 2: 加 team_intel 欄位**

在 `scripts/data/world_state.gd` 第 8 行（`var team_discovered: Dictionary = {}`）之後插入：

```gdscript
var team_intel: Dictionary = {}
# { obs_id: int → { tgt_id: int → {
#   "tier":           int,       # 最高接觸層級：0/1/2
#   "population_est": int,       # 帶距離雜訊
#   "tile_pos":       Vector2i,
#   "last_tick":      int,
#   # tier ≥ 1: "resource_scale": int,   # 0缺乏/1勉強/2充裕/3豐盛（帶±1雜訊）
#   # tier 2: "faction_id", "tags", "current_task",
#   #          "food_est", "material_est", "coin_est", "goods_est", "armed_est"
# }}}
```

- [ ] **Step 3: 跑測試確認無誤**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "ERROR|SCRIPT ERROR|DONE"
```

預期：`=== DONE ===`，無 SCRIPT ERROR。

- [ ] **Step 4: Commit**

```powershell
git add scripts/data/world_state.gd
git commit -m "feat(intel): add team_intel field to WorldState"
```

---

### Task B: VisionSystem — Tier 0/1 快照寫入

**Files:**
- Modify: `scripts/simulation/vision_system.gd`
- Modify: `scripts/debug/headless_test.gd`

**Context:**
- `tick_discovery` 在 `if _can_detect(scout, eff_exp):` 分支中 call `_mark`，接著在此加 `_write_tier01` 呼叫。
- Tier 0：所有通過偵測的目標，寫 `population_est`（帶距離雜訊）、`tile_pos`、`last_tick`、`tier=0`（若舊 tier < 0）。
- Tier 1：dist ≤ 1，額外寫 `resource_scale`（所有 resource key 總和分 4 級，帶 ±1 雜訊），`tier` 升至 ≥ 1。
- 快照**不清除**：未偵測到目標時不動 team_intel，保留最後值。
- `vrange` 已在 `tick_discovery` 計算好，`dist_f` 也已有，傳入 `_write_tier01` 即可。

- [ ] **Step 1: 在 headless_test.gd 加 Tier 0/1 驗證場景**

讀 `scripts/debug/headless_test.gd`，找到第 516 行（`state.factions.erase(ks_fac)`）與第 518 行（`print("=== Sim Test: 200 Ticks ===")`）之間的空隙。在此插入：

```gdscript
	# ── IntelSystem Tier 0/1 驗證 ──
	var _it_vis := VisionSystem.new()
	# 觀察者 Team70（偵查=0，在 (0,0)，vrange=3）
	var _it_a := TeamData.new()
	_it_a.team_id = 70; _it_a.population = 5; _it_a.tile_pos = Vector2i(0, 0)
	state.teams[70] = _it_a; state.team_discovered[70] = []
	var _it_a_l := PersonData.new()
	_it_a_l.id = 70; _it_a_l.role = "leader"; _it_a_l.team_id = 70
	_it_a_l.skills["偵查"] = 0.0
	state.persons[70] = _it_a_l; _it_a.leader_id = 70

	# 目標 Team71（pop=20，在 (2,0)，dist=2，exposure 高）
	var _it_b := TeamData.new()
	_it_b.team_id = 71; _it_b.population = 20; _it_b.tile_pos = Vector2i(2, 0)
	_it_b.resources = {
		"food": 80.0, "material": 30.0, "coin": 0.0, "goods": 0.0, "gem": 0.0,
		"ore_gold": 0.0, "ore_silver": 0.0, "ore_iron": 0.0, "ore_steel": 0.0,
		"weapon_melee_low": 0.0, "weapon_melee_high": 0.0,
		"weapon_ranged_low": 0.0, "weapon_ranged_high": 0.0,
	}
	state.teams[71] = _it_b; state.team_discovered[71] = []
	var _it_b_l := PersonData.new()
	_it_b_l.id = 71; _it_b_l.role = "leader"; _it_b_l.team_id = 71
	state.persons[71] = _it_b_l; _it_b.leader_id = 71

	_it_vis.tick_discovery(state, [70, 71])
	print("=== IntelSystem Tier 0 驗證 ===")
	var _it_snap0: Dictionary = state.team_intel.get(70, {}).get(71, {})
	if _it_snap0.get("tier", -1) == 0:
		print("  [OK] tier=0")
	else:
		print("  [FAIL] tier=%s（預期 0）" % str(_it_snap0.get("tier", "missing")))
	var _pop_est: int = int(_it_snap0.get("population_est", -1))
	if _pop_est >= 10 and _pop_est <= 30:
		print("  [OK] population_est=%d（範圍 10–30）" % _pop_est)
	else:
		print("  [FAIL] population_est=%d（預期 10–30）" % _pop_est)

	# Tier 1：Team70 移到 (1,0)，dist=1；Team71 total_res=110 → bucket=1，±1 → 0–2
	_it_a.tile_pos = Vector2i(1, 0)
	_it_vis.tick_discovery(state, [70])
	print("=== IntelSystem Tier 1 驗證 ===")
	var _it_snap1: Dictionary = state.team_intel.get(70, {}).get(71, {})
	if _it_snap1.get("tier", -1) >= 1:
		print("  [OK] tier≥1（dist=1 近接觸）")
	else:
		print("  [FAIL] tier=%s（預期 ≥1）" % str(_it_snap1.get("tier", "missing")))
	var _rscale: int = int(_it_snap1.get("resource_scale", -1))
	if _rscale >= 0 and _rscale <= 2:
		print("  [OK] resource_scale=%d（預期 0–2，total=110→bucket1±1）" % _rscale)
	else:
		print("  [FAIL] resource_scale=%d（預期 0–2）" % _rscale)

	# 快照持久：Team71 移出視野（dist=10），team_intel 應仍保留舊值
	var _last_pop: int = int(state.team_intel.get(70, {}).get(71, {}).get("population_est", -1))
	_it_b.tile_pos = Vector2i(10, 0)
	_it_vis.tick_discovery(state, [70])
	var _it_snap_p: Dictionary = state.team_intel.get(70, {}).get(71, {})
	print("=== IntelSystem 快照持久 驗證 ===")
	if int(_it_snap_p.get("population_est", -1)) == _last_pop and _last_pop > 0:
		print("  [OK] 快照保留（population_est=%d 不變）" % _last_pop)
	else:
		print("  [FAIL] 快照被清除（got=%s）" % str(_it_snap_p.get("population_est", "missing")))

	# 清理
	state.teams.erase(70); state.teams.erase(71)
	state.team_discovered.erase(70); state.team_discovered.erase(71)
	state.persons.erase(70); state.persons.erase(71)
```

- [ ] **Step 2: 跑測試確認 [FAIL]**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "IntelSystem|FAIL|SCRIPT ERROR"
```

預期：`IntelSystem Tier 0` 場景出現 `[FAIL]`（`team_intel` 仍空）；`=== DONE ===` 仍出現（無崩潰）。

- [ ] **Step 3: 修改 vision_system.gd — 加 _write_tier01 呼叫與函數**

讀 `scripts/simulation/vision_system.gd`。

**3a:** 在 `tick_discovery` 的 `_mark(state, tid, other_id)` 那一行之後（`if is_new:` 之前）加一行：

```gdscript
				_write_tier01(state, tid, other_id, other, dist, dist_f)
```

修改後完整 `if _can_detect` 區塊如下（確認縮排正確）：

```gdscript
			if _can_detect(scout, eff_exp):
				var is_new: bool = not state.team_discovered[tid].has(other_id)
				_mark(state, tid, other_id)
				_write_tier01(state, tid, other_id, other, dist, dist_f)
				if is_new:
					_grow_skill(state, obs, "偵查", "智力", "體力")
			else:
				_grow_skill(state, other, "潛行", "體力", "毅力")
```

**3b:** 在檔案末尾（`_hex_dist` 函數之後）新增 `_write_tier01`：

```gdscript
func _write_tier01(state: WorldState, obs_id: int, tgt_id: int,
		tgt: TeamData, dist: int, dist_f: float) -> void:
	if not state.team_intel.has(obs_id):
		state.team_intel[obs_id] = {}
	var noise: float = 1.0 - dist_f  # TEST VALUE
	var pop_est: int = maxi(1, roundi(
		tgt.population * randf_range(1.0 - noise, 1.0 + noise)))
	var snap: Dictionary = state.team_intel[obs_id].get(tgt_id, {}).duplicate()
	snap["population_est"] = pop_est
	snap["tile_pos"]       = tgt.tile_pos
	snap["last_tick"]      = state.world.current_tick
	if not snap.has("tier"):
		snap["tier"] = 0
	if dist <= 1:
		if int(snap["tier"]) < 1:
			snap["tier"] = 1
		var total_res: float = 0.0
		for rk in tgt.resources:
			total_res += float(tgt.resources[rk])
		var scale: int = 0
		if   total_res >= 600.0: scale = 3
		elif total_res >= 200.0: scale = 2
		elif total_res >= 50.0:  scale = 1
		scale = clampi(scale + randi_range(-1, 1), 0, 3)
		snap["resource_scale"] = scale
	state.team_intel[obs_id][tgt_id] = snap
```

- [ ] **Step 4: 跑測試確認 [OK]**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "IntelSystem|FAIL|DONE|SCRIPT ERROR"
```

預期：Tier 0、Tier 1、快照持久均 `[OK]`；`=== DONE ===`；無 SCRIPT ERROR。

- [ ] **Step 5: Commit**

```powershell
git add scripts/simulation/vision_system.gd scripts/debug/headless_test.gd
git commit -m "feat(intel): VisionSystem writes Tier 0/1 snapshots to team_intel"
```

---

### Task C: InteractionSystem — Tier 2 快照寫入（含造假）

**Files:**
- Modify: `scripts/simulation/interaction_system.gd`
- Modify: `scripts/debug/headless_test.gd`

**Context:**
- `_try_interact` 第一行（line 163）呼叫 `_vision.reveal_encounter(state, id_a, id_b)`。在此之後加雙向 Tier 2 寫入。
- Tier 2 寫入：完整快照（faction_id、tags、current_task、food/material/coin/goods est、armed_est）。
- 造假機制（以目標 leader 為計算基礎）：
  - `deceive_chance = (1 - 信義) × 0.5 + 計謀 × 0.2`（TEST VALUE）
  - **偽裝平民**：tags 含「統領/軍隊/流亡/子團」且觸發 → armed_est × randf(0.2–0.4)；其他 est × randf(1.5–2.5)
  - **虛張聲勢**：（攻擊/掠奪 task 或 好戰>0.6 或 商隊+慎重>0.5）且 armed/pop < 0.6 且觸發 → armed_est × randf(2–4) cap at pop-1；其他 est × randf(0.3–0.7)
- `_calc_armed`：named NPC 武器欄非空的數量 + round(anon_pop × armed_anon_ratio)（不用 weapon pool，weapon 裝備後從 pool 扣除）
- `_write_tier2_intel` 設為 `func`（非 private），供 headless_test 直接呼叫驗證。

- [ ] **Step 1: 在 headless_test.gd 加 Tier 2 驗證場景**

在 Task B 清理程式碼（`state.persons.erase(71)`）之後、`print("=== Sim Test: 200 Ticks ===")` 之前插入：

```gdscript
	# ── IntelSystem Tier 2 驗證 ──
	var _it_inter := InteractionSystem.new()

	# 觀察者 Team72
	var _it_obs := TeamData.new()
	_it_obs.team_id = 72; _it_obs.population = 5; _it_obs.tile_pos = Vector2i(0, 0)
	state.teams[72] = _it_obs; state.team_discovered[72] = []
	var _it_obs_l := PersonData.new()
	_it_obs_l.id = 72; _it_obs_l.role = "leader"; _it_obs_l.team_id = 72
	state.persons[72] = _it_obs_l; _it_obs.leader_id = 72

	# 高信義 Team73（生產隊，幾乎不造假）
	var _it_hon := TeamData.new()
	_it_hon.team_id = 73; _it_hon.population = 10; _it_hon.tile_pos = Vector2i(0, 0)
	_it_hon.tags = ["生產"]
	_it_hon.resources = {
		"food": 100.0, "material": 0.0, "coin": 20.0, "goods": 0.0, "gem": 0.0,
		"ore_gold": 0.0, "ore_silver": 0.0, "ore_iron": 0.0, "ore_steel": 0.0,
		"weapon_melee_low": 4.0, "weapon_melee_high": 0.0,
		"weapon_ranged_low": 0.0, "weapon_ranged_high": 0.0,
	}
	_it_hon.armed_anon_ratio = 0.0
	state.teams[73] = _it_hon; state.team_discovered[73] = []
	var _it_hon_l := PersonData.new()
	_it_hon_l.id = 73; _it_hon_l.role = "leader"; _it_hon_l.team_id = 73
	_it_hon_l.values["信義"] = 0.95
	state.persons[73] = _it_hon_l; _it_hon.leader_id = 73

	_it_inter._write_tier2_intel(state, 72, 73)
	print("=== IntelSystem Tier 2（高信義）===")
	var _snap73: Dictionary = state.team_intel.get(72, {}).get(73, {})
	if _snap73.get("tier", -1) == 2:
		print("  [OK] tier=2")
	else:
		print("  [FAIL] tier=%s（預期 2）" % str(_snap73.get("tier", "missing")))
	var _food73: float = float(_snap73.get("food_est", -1.0))
	# 高信義不應高報 food（偽裝平民時 food × 1.5–2.5）；直接值應為 100.0
	if _food73 >= 80.0:
		print("  [OK] food_est=%.1f（高信義，接近實際 100）" % _food73)
	else:
		print("  [WARN] food_est=%.1f（可能觸發偽裝，但高信義概率極低）" % _food73)
	if _snap73.has("coin_est"):
		print("  [OK] coin_est=%.1f（Tier 2 欄位存在）" % float(_snap73.get("coin_est", 0.0)))
	else:
		print("  [FAIL] coin_est 欄位缺少")

	# 低信義軍隊 Team74（高 deceive_chance → 偽裝平民）
	var _it_low := TeamData.new()
	_it_low.team_id = 74; _it_low.population = 10; _it_low.tile_pos = Vector2i(0, 0)
	_it_low.tags = ["軍隊"]
	_it_low.resources = {
		"food": 50.0, "material": 0.0, "coin": 0.0, "goods": 0.0, "gem": 0.0,
		"ore_gold": 0.0, "ore_silver": 0.0, "ore_iron": 0.0, "ore_steel": 0.0,
		"weapon_melee_low": 0.0, "weapon_melee_high": 0.0,
		"weapon_ranged_low": 0.0, "weapon_ranged_high": 0.0,
	}
	_it_low.armed_anon_ratio = 0.8  # anon_pop=9 → actual_armed≈7
	state.teams[74] = _it_low; state.team_discovered[74] = []
	var _it_low_l := PersonData.new()
	_it_low_l.id = 74; _it_low_l.role = "leader"; _it_low_l.team_id = 74
	_it_low_l.values["信義"] = 0.05   # deceive_chance ≈ (0.95)×0.5 = 0.475
	_it_low_l.skills["計謀"] = 0.5    # + 0.5×0.2 = 0.1 → total ≈ 0.575
	state.persons[74] = _it_low_l; _it_low.leader_id = 74

	# 多次取樣（造假為機率事件），偽裝觸發 → armed_est < 4（實際≈7 × 0.2–0.4 = 1–3）
	var _deception_ok: bool = false
	for _i in range(20):
		_it_inter._write_tier2_intel(state, 72, 74)
		var _s74: Dictionary = state.team_intel.get(72, {}).get(74, {})
		if int(_s74.get("armed_est", 999)) < 4:
			_deception_ok = true; break
	print("=== IntelSystem Tier 2（低信義軍隊 偽裝平民）===")
	if _deception_ok:
		print("  [OK] 偽裝平民觸發（20次取樣中 armed_est 低報）")
	else:
		print("  [WARN] 20次取樣均未觸發（RNG 偶發，偵查概率=0.575 應多數觸發）")

	# 清理
	for _tid_t2 in [72, 73, 74]:
		state.teams.erase(_tid_t2)
		state.team_discovered.erase(_tid_t2)
		state.persons.erase(_tid_t2)
```

- [ ] **Step 2: 跑測試確認 [FAIL]（_write_tier2_intel 不存在）**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "Tier 2|FAIL|SCRIPT ERROR"
```

預期：SCRIPT ERROR（`_write_tier2_intel` method not found）或 `[FAIL]`。

- [ ] **Step 3a: 在 _try_interact 加雙向 Tier 2 呼叫**

讀 `scripts/simulation/interaction_system.gd`，找到 `_try_interact` 函數。第一行為 `_vision.reveal_encounter(state, id_a, id_b)`。在此行之後（`var a: TeamData = ...` 之前）插入：

```gdscript
	_write_tier2_intel(state, id_a, id_b)
	_write_tier2_intel(state, id_b, id_a)
```

- [ ] **Step 3b: 在 interaction_system.gd 末尾加 _write_tier2_intel 和 _calc_armed**

在檔案最後一個函數之後加：

```gdscript
func _write_tier2_intel(state: WorldState, obs_id: int, tgt_id: int) -> void:
	var tgt: TeamData = state.teams.get(tgt_id) as TeamData
	if tgt == null: return
	var tgt_leader: PersonData = state.persons.get(tgt.leader_id) as PersonData
	if not state.team_intel.has(obs_id):
		state.team_intel[obs_id] = {}
	var snap: Dictionary = state.team_intel[obs_id].get(tgt_id, {}).duplicate()
	snap["tier"]           = 2
	snap["tile_pos"]       = tgt.tile_pos
	snap["last_tick"]      = state.world.current_tick
	snap["population_est"] = tgt.population
	snap["faction_id"]     = tgt.faction_id
	snap["tags"]           = tgt.tags.duplicate()
	snap["current_task"]   = tgt.current_task
	snap["food_est"]       = float(tgt.resources.get("food",     0.0))
	snap["material_est"]   = float(tgt.resources.get("material", 0.0))
	snap["coin_est"]       = float(tgt.resources.get("coin",     0.0))
	snap["goods_est"]      = float(tgt.resources.get("goods",    0.0))
	var actual_armed: int  = _calc_armed(state, tgt)
	snap["armed_est"]      = actual_armed
	var honor: float   = float(tgt_leader.values.get("信義",  0.5)) if tgt_leader else 0.5
	var scheme: float  = float(tgt_leader.skills.get("計謀",  0.0)) if tgt_leader else 0.0
	var martial: float = float(tgt_leader.values.get("好戰",  0.5)) if tgt_leader else 0.5
	var caution: float = float(tgt_leader.values.get("慎重",  0.5)) if tgt_leader else 0.5
	var deceive_chance: float = (1.0 - honor) * 0.5 + scheme * 0.2  # TEST VALUE
	var disguise_tags: Array  = ["統領", "軍隊", "流亡", "子團"]
	var has_disguise_tag: bool = false
	for dtag in disguise_tags:
		if tgt.tags.has(dtag): has_disguise_tag = true; break
	if has_disguise_tag and randf() < deceive_chance:
		# 偽裝平民：低報武器，高報其他資源
		snap["armed_est"]    = roundi(actual_armed * randf_range(0.2, 0.4))
		snap["food_est"]     *= randf_range(1.5, 2.5)
		snap["material_est"] *= randf_range(1.5, 2.5)
		snap["goods_est"]    *= randf_range(1.5, 2.5)
	else:
		var is_bluff_task:     bool = tgt.current_task in ["攻擊", "掠奪"]
		var is_bluff_martial:  bool = martial > 0.6
		var is_bluff_merchant: bool = tgt.tags.has("商隊") and caution > 0.5
		var armed_ratio: float = float(actual_armed) / maxf(float(tgt.population), 1.0)
		if (is_bluff_task or is_bluff_martial or is_bluff_merchant) \
				and armed_ratio < 0.6 and randf() < deceive_chance:
			# 虛張聲勢：高報武器，低報其他資源
			var bluffed: int  = roundi(actual_armed * randf_range(2.0, 4.0))
			snap["armed_est"] = mini(bluffed, tgt.population - 1)
			snap["food_est"]     *= randf_range(0.3, 0.7)
			snap["material_est"] *= randf_range(0.3, 0.7)
			snap["goods_est"]    *= randf_range(0.3, 0.7)
	state.team_intel[obs_id][tgt_id] = snap

func _calc_armed(state: WorldState, team: TeamData) -> int:
	var named_armed: int = 0
	for pid in ([team.leader_id] as Array) + team.advisors + team.members:
		var p: PersonData = state.persons.get(pid) as PersonData
		if p and p.equipment.get("weapon", "") != "":
			named_armed += 1
	var named_count: int = 1 + team.advisors.size() + team.members.size()
	var anon_pop: int    = maxi(team.population - named_count, 0)
	return named_armed + roundi(float(anon_pop) * team.armed_anon_ratio)
```

- [ ] **Step 4: 跑測試確認 [OK]**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "IntelSystem|FAIL|DONE|SCRIPT ERROR"
```

預期：Tier 2 高信義 `[OK]`；偽裝平民取樣 `[OK]`（偶發 `[WARN]` 可接受）；`=== DONE ===`；無 SCRIPT ERROR。

- [ ] **Step 5: Commit**

```powershell
git add scripts/simulation/interaction_system.gd scripts/debug/headless_test.gd
git commit -m "feat(intel): InteractionSystem writes Tier 2 snapshots with deception to team_intel"
```

---

### Task D: FactionAISystem — 橋接 team_intel + trade + 攻擊實力估算

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

**Context（四處改動）：**

1. **`evaluate_all`**：移除 `state.snapshot_faction_member(mid, ...)` stub；改從 `state.team_intel.get(f.leader_team_id, {}).get(mid, {})` 橋接到 `f.known_member_states[mid]`。無快照 → 保留上次記憶（不動 known_member_states）。
2. **`_declare_established`**：移除 `state.snapshot_faction_member(mid, ...)` 呼叫（line 533）。立國後 known_member_states 由 IntelSystem 自然填充。
3. **`_richest_member`**：讀 `snap.get("food_est", 0.0)` 而非 `snap.get("food", 0.0)`（key 名稱因 team_intel 格式改變）。
4. **`_find_trade_target`**：讀 `state.team_intel.get(merchant.team_id, {}).get(tid, {}).get("coin_est", 0.0)` 而非 `t.resources.get("coin", 0)`。未互動（coin_est=0）→ 不選為貿易目標（設計意圖）。
5. **`_update_goals` 攻擊 goal**：加入 `armed_est` 實力比較（`tgt_armed` vs `own_armed + 已承諾攻擊成員`）；未知目標（無快照）視為強敵（armed_est=999）。
6. **`_calc_own_armed` helper**：新增，計算 leader team 的實際武裝人數（同 InteractionSystem._calc_armed 邏輯）。

**FactionKnownState 測試更新說明：**
`evaluate_all` 移除 stub 後，headless_test 的 FactionKnownState 場景需要先手動寫入 `state.team_intel[30][31/32]`，evaluate_all 才能橋接到 `known_member_states`。同時 `_richest_member` 讀 `food_est` 而非 `food`，測試驗證 key 也需更新。

- [ ] **Step 1: 更新 headless_test.gd — FactionKnownState 場景加 team_intel 預備**

讀 `scripts/debug/headless_test.gd`，找到 line 483（`var _ks_fai: Object = load(...)`）。在此行**之前**插入（在 FactionKnownState teams/persons 設定完成之後）：

```gdscript
	# 預建 team_intel snap（原由 VisionSystem 在 tick 中寫入，此處繞過以直接驗證橋接）
	state.team_intel[30] = {
		31: {
			"tier": 1, "population_est": 5, "tile_pos": Vector2i(1, -9),
			"last_tick": 0, "resource_scale": 1,
			"food_est": 50.0, "material_est": 0.0, "coin_est": 0.0, "goods_est": 0.0,
			"armed_est": 0, "faction_id": ks_fac, "tags": [], "current_task": "idle",
		},
		32: {
			"tier": 1, "population_est": 3, "tile_pos": Vector2i(2, -9),
			"last_tick": 0, "resource_scale": 0,
			"food_est": 30.0, "material_est": 0.0, "coin_est": 0.0, "goods_est": 0.0,
			"armed_est": 0, "faction_id": ks_fac, "tags": [], "current_task": "idle",
		},
	}
```

然後更新 FactionKnownState 場景 1 驗證（line 488–492）—改為讀 `food_est`：

```gdscript
	var _snap_b: Dictionary = state.factions[ks_fac].known_member_states.get(31, {})
	if _snap_b.get("food_est", -1.0) == 50.0:
		print("  [OK] known_member_states[31].food_est=50.0（bridge 正確）")
	else:
		print("  [FAIL] known_member_states[31].food_est=%s" % str(_snap_b.get("food_est", "missing")))
```

- [ ] **Step 2: 在 headless_test.gd 加攻擊決策驗證場景**

在 Tier 2 驗證場景清理程式碼之後、`print("=== Sim Test: 200 Ticks ===")` 之前插入：

```gdscript
	# ── IntelSystem 攻擊決策驗證 ──
	print("=== IntelSystem 攻擊決策 驗證 ===")
	var _ad_fid: int = state.create_faction(80)
	state.factions[_ad_fid].is_established = true
	var _ad_leader := TeamData.new()
	_ad_leader.team_id = 80; _ad_leader.population = 10
	_ad_leader.tile_pos = Vector2i(0, 1); _ad_leader.tags = ["統領"]
	_ad_leader.faction_id = _ad_fid; _ad_leader.readiness = 0.8
	_ad_leader.armed_anon_ratio = 0.0
	state.teams[80] = _ad_leader; state.team_discovered[80] = []
	var _ad_l_p := PersonData.new()
	_ad_l_p.id = 80; _ad_l_p.role = "leader"; _ad_l_p.team_id = 80
	_ad_l_p.values["野心"] = 0.8; _ad_l_p.values["好戰"] = 0.8
	_ad_l_p.values["義氣"] = 0.1; _ad_l_p.skills["統領"] = 0.5
	state.persons[80] = _ad_l_p; _ad_leader.leader_id = 80

	var _ad_tgt := TeamData.new()
	_ad_tgt.team_id = 81; _ad_tgt.population = 8; _ad_tgt.tile_pos = Vector2i(1, 1)
	_ad_tgt.faction_id = -1; _ad_tgt.armed_anon_ratio = 0.0
	state.teams[81] = _ad_tgt
	state.team_discovered[80].append(81)
	var _ad_tgt_p := PersonData.new()
	_ad_tgt_p.id = 81; _ad_tgt_p.role = "leader"; _ad_tgt_p.team_id = 81
	state.persons[81] = _ad_tgt_p; _ad_tgt.leader_id = 81

	var _ad_fai: Object = load("res://scripts/simulation/faction_ai_system.gd").new()

	# 場景 1：無 team_intel snap → armed_est=999 → 不應加入攻擊 goal
	_ad_fai._update_goals(state, state.factions[_ad_fid])
	if not state.factions[_ad_fid].goals.has("攻擊"):
		print("  [OK] 未知目標（armed_est=999）→ 無攻擊 goal")
	else:
		print("  [FAIL] 未知目標仍加入攻擊 goal（應檢查 _update_goals 實力比較邏輯）")

	# 場景 2：寫入弱目標 snap（armed_est=2）→ own_armed≥2×0.8=1.6 → 應加入攻擊 goal
	if not state.team_intel.has(80):
		state.team_intel[80] = {}
	state.team_intel[80][81] = {
		"tier": 0, "population_est": 8, "armed_est": 2,
		"tile_pos": Vector2i(1, 1), "last_tick": 0,
	}
	state.factions[_ad_fid].goals.clear()
	_ad_fai._update_goals(state, state.factions[_ad_fid])
	if state.factions[_ad_fid].goals.has("攻擊"):
		print("  [OK] 弱目標（armed_est=2）→ 加入攻擊 goal")
	else:
		print("  [FAIL] 弱目標未加入攻擊 goal")

	# 清理
	state.teams.erase(80); state.teams.erase(81)
	state.team_discovered.erase(80)
	state.persons.erase(80); state.persons.erase(81)
	state.factions.erase(_ad_fid)
	state.team_intel.erase(80)
```

- [ ] **Step 3: 跑測試確認 [FAIL]**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "攻擊決策|FactionKnownState|FAIL|SCRIPT ERROR"
```

預期：攻擊決策場景 `[FAIL]`（`_calc_own_armed` 不存在）或 FactionKnownState 場景 `[FAIL]`（bridge 尚未實作）。

- [ ] **Step 4a: 修改 evaluate_all — 移除 stub，改 team_intel 橋接**

讀 `scripts/simulation/faction_ai_system.gd`，找到 `evaluate_all`（line 29）。將整個 `for fid in state.factions:` 的迴圈體改為：

```gdscript
func evaluate_all(state: WorldState, _team_ids: Array) -> void:
	for fid in state.factions:
		var f = state.factions[fid]
		for mid in f.member_team_ids:
			var snap: Dictionary = state.team_intel.get(f.leader_team_id, {}).get(mid, {})
			if not snap.is_empty():
				f.known_member_states[mid] = snap
		_update_goals(state, f)
		_assign_tasks(state, f)

	var merge_queue: Array = []
	for tid in state.teams:
		var team: TeamData = state.teams[tid]
		if team.parent_team_id != -1:
			_evaluate_subteam(state, team, merge_queue)
		elif team.faction_id == -1:
			_evaluate_solo(state, team)

	var sub_sys := SubteamSystem.new()
	for sub_id in merge_queue:
		if not state.teams.has(sub_id):
			continue
		var sub: TeamData = state.teams[sub_id]
		if sub.parent_team_id == -1:
			continue
		var parent: TeamData = state.teams.get(sub.parent_team_id)
		if parent != null and parent.tile_pos == sub.tile_pos:
			sub_sys.try_merge_back(state, sub_id)
		else:
			sub.current_task = TeamData.TASK_IDLE
			if parent != null:
				sub.move_target = parent.tile_pos

	for tid in state.teams:
		if not state.teams.has(tid):
			continue
		_update_equip_order(state, state.teams[tid])
```

- [ ] **Step 4b: 修改 _declare_established — 移除 snapshot_faction_member 呼叫**

找到 `_declare_established`（line 528）。移除 `for mid in f.member_team_ids: state.snapshot_faction_member(mid, ...)` 整個迴圈（line 532–533）：

```gdscript
func _declare_established(state: WorldState, f, leader_team: TeamData) -> void:
	f.is_established = true
	f.faction_name   = "勢力%d" % f.faction_id
	f.goals.erase("立國")
	SimMessageSystem.new().emit_message(state, "faction_establish",
		"%s 正式立國（leader=Team%d，%d teams）" % [
			f.faction_name, f.leader_team_id, f.member_team_ids.size()],
		leader_team)
	print("[Faction] 立國：%s（leader=Team%d，%d teams）" % [
		f.faction_name, f.leader_team_id, f.member_team_ids.size()])
```

- [ ] **Step 4c: 修改 _richest_member — 讀 food_est**

找到 `_richest_member`（line 515）。將 `snap.get("food", 0.0)` 改為 `snap.get("food_est", 0.0)`：

```gdscript
func _richest_member(state: WorldState, f) -> int:
	var best_tid: int    = -1
	var best_food: float = 0.0
	for mid in f.member_team_ids:
		if mid == f.leader_team_id or not state.teams.has(mid):
			continue
		var snap: Dictionary = f.known_member_states.get(mid, {})
		var mfood: float = float(snap.get("food_est", 0.0))
		if mfood > best_food:
			best_food = mfood
			best_tid  = mid
	return best_tid
```

- [ ] **Step 4d: 修改 _find_trade_target — 讀 coin_est from team_intel**

找到 `_find_trade_target`（line 464）。將直讀 `t.resources.get("coin", 0)` 改為讀 team_intel 快照：

```gdscript
func _find_trade_target(state: WorldState, merchant: TeamData) -> int:
	var best_id: int = -1
	var best_d:  int = 999
	for tid in state.team_discovered.get(merchant.team_id, []):
		if tid == merchant.team_id or not state.teams.has(tid): continue
		var snap: Dictionary = state.team_intel.get(merchant.team_id, {}).get(tid, {})
		var coin_est: float  = float(snap.get("coin_est", 0.0))
		if coin_est < TRADE_MIN_COIN: continue
		var d: int = _hex_dist(merchant.tile_pos, state.teams[tid].tile_pos)
		if d < best_d:
			best_d  = d
			best_id = tid
	return best_id
```

- [ ] **Step 4e: 修改 _update_goals — 攻擊 goal 加 armed 實力比較**

找到 `_update_goals` 中攻擊 goal 判斷（line 135–140）。替換為：

```gdscript
	var attack_score: float = ambition * 0.4 + martial * 0.4 - honor * 0.4
	if f.is_established and attack_score > 0.3 \
			and leader_team.readiness >= 0.75 \
			and _has_independent(state, f.leader_team_id) \
			and _tag_weight(leader_team, "攻擊") > 0.0:
		var target_id: int = _nearest_independent(state, leader_team)
		if target_id != -1:
			var tgt_snap: Dictionary = state.team_intel.get(f.leader_team_id, {}).get(target_id, {})
			var tgt_armed: int = int(tgt_snap.get("armed_est", 999))  # 未知視為強敵
			var own_armed: int = _calc_own_armed(state, leader_team)
			for mid in f.known_member_states:
				if mid == f.leader_team_id: continue
				var ms: Dictionary = f.known_member_states[mid]
				if ms.get("current_task", "") == "攻擊":
					own_armed += int(ms.get("armed_est", 0))
			if float(own_armed) >= float(tgt_armed) * 0.8:
				f.goals.append("攻擊")
		else:
			f.goals.append("攻擊")
```

- [ ] **Step 4f: 加 _calc_own_armed helper**

在 `_hex_dist` 函數之前加：

```gdscript
func _calc_own_armed(state: WorldState, team: TeamData) -> int:
	var named_armed: int = 0
	for pid in ([team.leader_id] as Array) + team.advisors + team.members:
		var p: PersonData = state.persons.get(pid) as PersonData
		if p and p.equipment.get("weapon", "") != "":
			named_armed += 1
	var named_count: int = 1 + team.advisors.size() + team.members.size()
	var anon_pop: int    = maxi(team.population - named_count, 0)
	return named_armed + roundi(float(anon_pop) * team.armed_anon_ratio)
```

- [ ] **Step 5: 跑測試確認全 [OK]**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "IntelSystem|FactionKnownState|FAIL|DONE|SCRIPT ERROR"
```

預期：
- `IntelSystem Tier 0/1/持久/Tier 2/攻擊決策` 均 `[OK]`
- `FactionKnownState` 三場景均 `[OK]`（橋接正確，`food_est` key 匹配）
- `=== DONE ===`；無 SCRIPT ERROR

如有崩潰，檢查：
- `_calc_own_armed` 是否在 `_hex_dist` 之前（GDScript 不需要前向宣告，但確認函數名無拼寫錯誤）
- `food_est` vs `food` key：`_richest_member` 讀 `food_est`；headless_test 場景 1 也驗證 `food_est`

- [ ] **Step 6: Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(intel): FactionAI bridges team_intel, trade reads coin_est, attack checks armed_est"
```

---

### Task E: docs/progress.md 更新

**Files:**
- Modify: `docs/progress.md`

- [ ] **Step 1: 在 progress.md 已完成模擬系統層加 IntelSystem 項目**

讀 `docs/progress.md`，找到模擬系統層表格中 `faction_ai_system.gd`（快照層）那一行。在此行之後加：

```
| `vision_system.gd`（IntelSystem Tier 0/1） | `_write_tier01`：dist≤vrange 寫 population_est（距離雜訊）；dist≤1 寫 resource_scale（總資源量 0–3，帶±1雜訊） |
| `interaction_system.gd`（IntelSystem Tier 2） | `_write_tier2_intel`：同格接觸寫完整快照（faction_id/tags/task/各資源 est/armed_est）；造假：偽裝平民（低信義+統領軍隊流亡子團）或虛張聲勢（攻擊/掠奪/好戰/商隊慎重，armed<60%）；`_calc_armed`：named 武器欄 + round(anon×ratio) |
| `faction_ai_system.gd`（IntelSystem FactionAI） | `evaluate_all` 橋接 team_intel→known_member_states；`_find_trade_target` 讀 coin_est；`_update_goals` 攻擊 goal 加 armed_est 實力比較；`_calc_own_armed` helper |
```

在**待完成**的中優先表格中，將 FactionAI 快照層 stub 項目標為完成（加刪除線）並加說明。

- [ ] **Step 2: Commit**

```powershell
git add docs/progress.md
git commit -m "docs(progress): add IntelSystem to completed systems"
```

---

## ⚠️ 已知 TEST VALUE 與設計備忘

| 項目 | 說明 |
|---|---|
| `deceive_chance` 係數 | `(1-信義)×0.5 + 計謀×0.2`，平衡期調整 |
| 偽裝乘數 | armed×randf(0.2–0.4)、其他×randf(1.5–2.5)，TEST VALUE |
| 虛張乘數 | armed×randf(2–4)，其他×randf(0.3–0.7)，TEST VALUE |
| `attack_score` 門檻 | own_armed ≥ tgt_armed×0.8，TEST VALUE |
| 貿易保守 | coin_est 未互動=0 → 貿易 AI 保守，TEST VALUE 期觀察 |
| `team_discovered` 保留 | IntelSystem 成熟後統一清除雙結構 |
| `known_member_states` bridge | 格式已從 `food` → `food_est` 等 Tier 2 key；FactionData 的 comment 反映舊格式（可在 IntelSystem 成熟時更新） |
| 子團叛變 | snap current_task 可能過時，leader 不知情 → 設計意圖，後續追蹤 |
