# 階段1 Plan 2b-2：野獸伏擊 + 偵測 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 隊伍經過有掠食者的 tile 會被偵測 roll 把關 — 高偵查/求生隊預先發現（預警可避），低的被野獸伏擊（玩家直接進遭遇戰、NPC 走 npc_combat 自動解算）。補獵勝 exp + 掠食者 infamy 計數。對稱、不破守恆。

**Architecture：**
- **偵測**復用 vision 模型：`AmbushSystem.detect()` = 隊伍 `偵查`(+`求生`) vs 掠食者 exposure（森林隱蔽）。每近/遠區 cadence 對 predator tile 上的隊 roll。
- **伏擊觸發**：未偵測到 + 低機率 → 從 tile predator 生成 beast（reuse `BeastSystem.build_beast_team`）發動攻擊：
  - **玩家隊** → **直接 `init_encounter(beast, player)`**（不走 pre_encounter — 投降給野獸無意義；玩家在戰鬥內可 retreat 逃）。
  - **NPC 隊** → `npc_combat_system.start_combat(beast, npc)`（**Bug9：NPC 獸戰不可走 EncounterSystem**）。
- **偵測到** → 玩家得預警訊息（可主動避/獵）、NPC 標記避開；雙方長 `偵查`/`求生`（reuse `_grow_skill` 模式）。
- **infamy**：beast 致死（殺人/勝）→ tile `predator_infamy` +1（輕量；持久惡獸實體屬任務系統 spec）。
- **獵勝 exp**（2b-1 遺留）：beast 戰勝方得戰鬥 exp。

**Tech Stack:** Godot 4.2.2 GDScript；headless 測試；`.\tools\godot.ps1` wrapper。

依據 spec：`docs/superpowers/specs/2026-06-14-stage1-survival-forage-hunt-design.md` §3 伏擊偵測 + 持久性丙（infamy hook）。

---

## 檔案結構

- `scripts/simulation/ambush_system.gd`（建）：`AmbushSystem` — `detect(state, team, tile)`（偵測 roll）；`check_ambush(state, team_ids)`（編排：偵測→預警/伏擊）。
- `scripts/data/tile_data.gd`（改）：`predator_infamy: int = 0` 欄位。
- `scripts/simulation/sim_runner.gd`（改）：near + far cadence 加 `_step_ambush_check`。
- `scripts/simulation/beast_system.gd`（改）：`reward_and_cleanup` / `_end` 路徑加獵勝 exp（呼叫 SkillSystem）+ beast 致死 → infamy。
- `scripts/simulation/faction_ai_system.gd`（改，輕量）：NPC 主動獵獸 — survival/idle 時若腳下 predator 且戰力足 → 發起 npc_combat 獵獸。
- `scripts/debug/headless_test.gd`（改）：註冊測試。

---

## Task 1: AmbushSystem.detect（偵測 roll）

**Files:**
- Create: `scripts/simulation/ambush_system.gd`
- Test: `scripts/debug/headless_test.gd`（新 `_test_ambush_detect`）

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_ambush_detect() -> void:
	print("--- 伏擊偵測 roll ---")
	var amb := AmbushSystem.new()
	# 高偵查隊 vs 低 predator → 多數偵測到
	var state := WorldState.new(); state.world = WorldData.new()
	var tile := HexTileData.new(); tile.terrain = "plains"; tile.resources = {"predator_density": 1}
	var hi := PersonData.new(); hi.id = 0; hi.team_id = 0; hi.skills = {"偵查": 0.9, "求生": 0.5}
	state.persons[0] = hi
	var t_hi := TeamData.new(); t_hi.team_id = 0; t_hi.leader_id = 0; t_hi.population = 3
	state.teams[0] = t_hi
	var hi_detect: int = 0
	for _i in range(50):
		if amb.detect(state, t_hi, tile): hi_detect += 1
	# 低偵查隊 → 少偵測
	var lo := PersonData.new(); lo.id = 1000; lo.team_id = 1; lo.skills = {"偵查": 0.0, "求生": 0.0}
	state.persons[1000] = lo
	var t_lo := TeamData.new(); t_lo.team_id = 1; t_lo.leader_id = 1000; t_lo.population = 3
	state.teams[1] = t_lo
	var lo_detect: int = 0
	for _i in range(50):
		if amb.detect(state, t_lo, tile): lo_detect += 1
	assert(hi_detect > lo_detect, "高偵查應比低偵查更常偵測：hi=%d lo=%d" % [hi_detect, lo_detect])
	print("ambush detect OK (hi=%d lo=%d)" % [hi_detect, lo_detect])
```

- [ ] **Step 2: 跑確認失敗** — `AmbushSystem` 不存在。

- [ ] **Step 3: 實作**

新建 `scripts/simulation/ambush_system.gd`：

```gdscript
class_name AmbushSystem

# 掠食者隱蔽：base 低（動物天生隱蔽），森林再砍半。
const PREDATOR_EXPOSURE_BASE: float = 0.3   # TEST VALUE
const TERRAIN_HIDE_MULT: Dictionary = { "plains": 1.0, "forest": 0.5, "mountain": 0.7 }
const AMBUSH_BASE_CHANCE: float = 0.15      # TEST VALUE — 未偵測時每次 check 的伏擊機率

# 偵測 roll：隊伍 偵查(+求生) vs 掠食者 exposure × 地形隱蔽。回傳 true=偵測到（預警）。
func detect(state: WorldState, team: TeamData, tile: HexTileData) -> bool:
	var skill: float = _avg_skill(state, team, "偵查") + _avg_skill(state, team, "求生") * 0.5
	var hide: float = float(TERRAIN_HIDE_MULT.get(tile.terrain, 1.0))
	var exposure: float = PREDATOR_EXPOSURE_BASE * hide
	# 復用 vision 風格門檻：exposure + skill*0.3 > 門檻 → 偵測（skill 高則易見）
	return (exposure + skill * 0.4) > 0.4

func _avg_skill(state: WorldState, team: TeamData, skill: String) -> float:
	var total: float = 0.0; var count: int = 0
	for pid in ([team.leader_id] as Array) + team.named_members:
		var p: PersonData = state.persons.get(pid)
		if p: total += float(p.skills.get(skill, 0.0)); count += 1
	return total / maxf(float(count), 1.0)
```

注意：`detect` 目前為確定性（同隊同 tile 結果固定）。測試靠 hi/lo 技能差分。若要隨機性可加 `randf()`，但確定性對「技能決定能否預警」語意更清晰，本 plan 採確定性。

- [ ] **Step 4: 重建快取 + 測試** — `--import` 後 `ambush detect OK`
- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/ambush_system.gd scripts/debug/headless_test.gd
git commit -m "feat: AmbushSystem.detect（偵查/求生 vs 掠食者隱蔽）"
```

---

## Task 2: tile predator_infamy 欄位 + check_ambush 編排

**Files:**
- Modify: `scripts/data/tile_data.gd`（`predator_infamy`）
- Modify: `scripts/simulation/ambush_system.gd`（`check_ambush`）
- Test: `scripts/debug/headless_test.gd`（新 `_test_ambush_player` + `_test_ambush_npc` + `_test_ambush_detected_no_fight`）

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _mk_ambush_state(detect_skill: float) -> Dictionary:
	var state := WorldState.new(); state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_id = 4*1000+4; tile.tile_pos = Vector2i(4,4); tile.terrain = "forest"
	tile.resources = {"predator_density": 2}
	state.world.tiles[tile.tile_id] = tile
	return { "state": state, "tile": tile }

func _test_ambush_player() -> void:
	print("--- 玩家被伏擊 → 直接 encounter ---")
	var d := _mk_ambush_state(0.0)
	var state: WorldState = d.state
	var leader := PersonData.new(); leader.id = 0; leader.team_id = 0
	leader.skills = {"偵查": 0.0, "求生": 0.0}   # 低偵查 → 必被伏擊
	state.persons[0] = leader; state.player_id = 0
	var pt := TeamData.new(); pt.team_id = 0; pt.leader_id = 0; pt.population = 4
	pt.tile_pos = Vector2i(4,4); pt.armed_anon_ratio = 1.0; pt.resources = {"weapon_melee_low": 4}
	state.teams[0] = pt
	var amb := AmbushSystem.new()
	# 強制伏擊（base chance 100%）測試用 override：跑多次至少一次觸發
	var triggered: bool = false
	for _i in range(50):
		amb.check_ambush(state, [0])
		if state.encounter_active:
			triggered = true; break
	assert(triggered, "低偵查玩家隊在 predator 格應曾被伏擊進 encounter")
	print("ambush player OK")

func _test_ambush_npc() -> void:
	print("--- NPC 被伏擊 → npc_combat（非 encounter）---")
	var d := _mk_ambush_state(0.0)
	var state: WorldState = d.state
	state.player_id = -999   # 無玩家
	var leader := PersonData.new(); leader.id = 100; leader.team_id = 1
	leader.skills = {"偵查": 0.0}
	state.persons[100] = leader
	var npc := TeamData.new(); npc.team_id = 1; npc.leader_id = 100; npc.population = 4
	npc.tile_pos = Vector2i(4,4); npc.readiness = 1.0; npc.resources = {"weapon_melee_low": 4}
	state.teams[1] = npc
	var amb := AmbushSystem.new()
	var combat_set: bool = false
	for _i in range(50):
		amb.check_ambush(state, [1])
		if npc.combat_target != -1 or not state.teams.has(1):
			combat_set = true; break
	assert(not state.encounter_active, "NPC 伏擊不可進 EncounterSystem（Bug9）")
	assert(combat_set, "NPC 應曾被野獸 npc_combat 攻擊")
	print("ambush npc OK")

func _test_ambush_detected_no_fight() -> void:
	print("--- 高偵查 → 偵測到、不被伏擊 ---")
	var d := _mk_ambush_state(0.0)
	var state: WorldState = d.state
	var leader := PersonData.new(); leader.id = 0; leader.team_id = 0
	leader.skills = {"偵查": 0.95, "求生": 0.9}   # 高 → 必偵測
	state.persons[0] = leader; state.player_id = 0
	var pt := TeamData.new(); pt.team_id = 0; pt.leader_id = 0; pt.population = 4
	pt.tile_pos = Vector2i(4,4); pt.resources = {}
	state.teams[0] = pt
	var amb := AmbushSystem.new()
	for _i in range(50):
		amb.check_ambush(state, [0])
	assert(not state.encounter_active, "高偵查隊應偵測到、不被伏擊")
	print("ambush detected-no-fight OK")
```

- [ ] **Step 2: 跑確認失敗** — `check_ambush` 未定義 / `predator_infamy` 缺。

- [ ] **Step 3: 實作**

`tile_data.gd`：加 `var predator_infamy: int = 0`。

`ambush_system.gd` 加：

```gdscript
# 對 team_ids 中位於 predator tile 的隊做伏擊把關。
func check_ambush(state: WorldState, team_ids: Array) -> void:
	for tid in team_ids:
		if not state.teams.has(tid):
			continue
		var team: TeamData = state.teams[tid]
		if team.beast_kind != "":
			continue   # 野獸不被伏擊
		if team.combat_target != -1 or state.encounter_active:
			continue
		var tile: HexTileData = state.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)
		if tile == null or int(tile.resources.get("predator_density", 0)) <= 0:
			continue
		if detect(state, team, tile):
			_on_detected(state, team, tile)   # 預警 + 長技能
			continue
		if randf() >= AMBUSH_BASE_CHANCE:
			continue   # 本次未觸發
		_trigger_ambush(state, team, tile)

func _on_detected(state: WorldState, team: TeamData, tile: HexTileData) -> void:
	# 長 偵查/求生（reuse 既有成長管道）
	_grow(state, team, "偵查"); _grow(state, team, "求生")
	# 玩家隊發預警訊息
	var leader = state.persons.get(team.leader_id)
	if leader != null and leader.id == state.player_id:
		print("[AmbushWarn] 玩家隊察覺 %s 有猛獸出沒" % tile.terrain)

func _trigger_ambush(state: WorldState, team: TeamData, tile: HexTileData) -> void:
	var kind: String = "bear" if tile.terrain == "mountain" else "boar"
	tile.resources["predator_density"] = int(tile.resources["predator_density"]) - 1
	var bs := BeastSystem.new()
	var bid: int = bs.build_beast_team(state, kind, team.tile_pos)
	var leader = state.persons.get(team.leader_id)
	if leader != null and leader.id == state.player_id:
		# 玩家：直接進遭遇戰（獸=attacker；不走 pre_encounter 投降）
		EncounterSystem.new().init_encounter(state, bid, team.team_id, "normal")
		print("[Ambush] 玩家 Team%d 被 %s 伏擊！" % [team.team_id, kind])
	else:
		# NPC：npc_combat 自動解算（Bug9：不走 encounter）
		NpcCombatSystem.new().start_combat(state, bid, team.team_id)
		print("[Ambush] NPC Team%d 被 %s 伏擊" % [team.team_id, kind])

func _grow(state: WorldState, team: TeamData, skill: String) -> void:
	for pid in ([team.leader_id] as Array) + team.named_members:
		var p: PersonData = state.persons.get(pid)
		if p: SkillSystem.cap_add(p, skill, 0.001)
```

注意：玩家伏擊用 `EncounterSystem.new()` 起 encounter — 確認與 sim_runner `_encounter_system` 實例的 `state` 一致（encounter 狀態存 state，非實例成員 → 安全）。若 sim_runner 需用自身實例推進，init 後由 `advance_tick` 既有 `state.encounter_active` 分支接管（已是）。`SkillSystem.cap_add` 簽名確認（2a/既有 vision 用過）。

- [ ] **Step 4: 重建快取 + 測試** — 三測試 OK
- [ ] **Step 5: Commit**

```bash
git add scripts/data/tile_data.gd scripts/simulation/ambush_system.gd scripts/debug/headless_test.gd
git commit -m "feat: 伏擊編排（玩家→encounter / NPC→npc_combat）+ predator_infamy 欄位"
```

---

## Task 3: sim_runner 接入伏擊把關

**Files:**
- Modify: `scripts/simulation/sim_runner.gd`（成員 + near/far step）
- Test: 由 Task 8 整合驗證覆蓋（sim 層接入）

- [ ] **Step 1: 加成員 + step**

`_init()` 加：`_ambush_system = AmbushSystem.new()`（宣告 `var _ambush_system: AmbushSystem`）。

新增：
```gdscript
func _step_ambush_check(state: WorldState, team_ids: Array) -> void:
	_ambush_system.check_ambush(state, team_ids)
```

近區（`_step4_resolve_interactions` 之後、`_step5_collect_resources` 之前）加：
```gdscript
		_step_ambush_check(state, near_teams)
		if state.encounter_active: return "player_turn"   # 伏擊起 encounter → 交還 bridge
```
遠區對應位置加 `_step_ambush_check(state, far_teams)`（far 無玩家 encounter，NPC 走 npc_combat 不阻塞，免 return）。

注意：近區若伏擊起玩家 encounter，須**比照既有玩家遭遇戰**交還 bridge（回傳非空字串讓 UI 進 encounter view）。讀 advance_tick 既有玩家 encounter 觸發如何回傳（line 68-73 的 `state.encounter_active` 分支模式），對齊回傳值。

- [ ] **Step 2: 跑既有測試無回歸**

Run: `.\tools\godot.ps1 --headless --import` + headless_test → 無新增 SCRIPT ERROR。

- [ ] **Step 3: Commit**

```bash
git add scripts/simulation/sim_runner.gd
git commit -m "feat: sim_runner near/far cadence 接入伏擊把關"
```

---

## Task 4: 獵勝 exp + beast 致死 infamy

**Files:**
- Modify: `scripts/simulation/beast_system.gd`（`reward_and_cleanup` 加勝方 exp；新 `record_infamy`）
- Modify: `scripts/simulation/encounter_system.gd` / `npc_combat_system.gd`（beast 致死 → infamy；惟若 beast 清除前記）
- Test: `scripts/debug/headless_test.gd`（新 `_test_beast_reward_exp` + `_test_predator_infamy`）

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_beast_reward_exp() -> void:
	print("--- 獵勝得 exp ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var leader := PersonData.new(); leader.id = 0; leader.team_id = 0
	leader.skills = {"戰鬥": 0.3}
	state.persons[0] = leader
	var winner := TeamData.new(); winner.team_id = 0; winner.leader_id = 0; winner.population = 5
	winner.resources = {"food": 0.0}
	state.teams[0] = winner
	var bs := BeastSystem.new()
	var bid: int = bs.build_beast_team(state, "boar", Vector2i(0,0))
	var before: float = float(leader.skills.get("戰鬥", 0))
	bs.reward_and_cleanup(state, 0, bid)
	assert(float(leader.skills.get("戰鬥", 0)) > before, "獵勝應長戰鬥 exp")
	print("beast reward exp OK")

func _test_predator_infamy() -> void:
	print("--- 掠食者 infamy 計數 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var tile := HexTileData.new(); tile.tile_id = 0; tile.tile_pos = Vector2i(0,0)
	state.world.tiles[0] = tile
	var amb := AmbushSystem.new()
	amb.record_infamy(state, Vector2i(0,0))
	amb.record_infamy(state, Vector2i(0,0))
	assert(tile.predator_infamy == 2, "infamy 應累加，實際=%d" % tile.predator_infamy)
	print("predator infamy OK")
```

- [ ] **Step 2: 跑確認失敗**

- [ ] **Step 3: 實作**

`beast_system.gd` `reward_and_cleanup`，得肉後加（勝方 leader/named 長戰鬥）：
```gdscript
		for pid in ([winner.leader_id] as Array) + winner.named_members:
			var p: PersonData = state.persons.get(pid)
			if p: SkillSystem.cap_add(p, "戰鬥", 0.003)   # TEST VALUE 獵勝 exp
```

`ambush_system.gd` 加：
```gdscript
# beast 致死（殺人/勝）→ tile predator_infamy +1（輕量；持久惡獸實體留任務系統 spec）
func record_infamy(state: WorldState, pos: Vector2i) -> void:
	var tile: HexTileData = state.world.tiles.get(pos.x * 1000 + pos.y)
	if tile != null:
		tile.predator_infamy += 1
```

接入：beast 戰勝（玩家敗 / NPC 敗）時呼叫 `record_infamy(state, beast_pos)`。在 `encounter_system.resolve_encounter_end` beast-win 分支 + `npc_combat_system._end_combat` beast-win 分支各加一行（beast 清除前用其 tile_pos）。

- [ ] **Step 4: 測試通過**
- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/beast_system.gd scripts/simulation/ambush_system.gd scripts/simulation/encounter_system.gd scripts/simulation/npc_combat_system.gd scripts/debug/headless_test.gd
git commit -m "feat: 獵勝得戰鬥 exp + 掠食者致死 infamy 計數"
```

---

## Task 5: NPC 主動獵獸（輕量）

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`（survival/idle 時腳下 predator + 戰力足 → 獵）
- Test: `scripts/debug/headless_test.gd`（新 `_test_npc_active_hunt`）

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_npc_active_hunt() -> void:
	print("--- NPC 主動獵獸 ---")
	var fai := FactionAISystem.new()
	var state := WorldState.new(); state.world = WorldData.new()
	var tile := HexTileData.new(); tile.tile_id = 4*1000+4; tile.tile_pos = Vector2i(4,4)
	tile.terrain = "forest"; tile.resources = {"predator_density": 1}
	state.world.tiles[tile.tile_id] = tile
	var leader := PersonData.new(); leader.id = 0; leader.team_id = 0
	leader.skills = {"戰鬥": 0.6}
	state.persons[0] = leader
	var band := TeamData.new(); band.team_id = 0; band.leader_id = 0; band.population = 15
	band.tile_pos = Vector2i(4,4); band.readiness = 1.0; band.resources = {"food": 0.0, "weapon_melee_low": 12}
	state.teams[0] = band
	var hunted: bool = fai.try_hunt_predator(state, band)
	assert(hunted, "戰力足的飢餓隊在 predator 格應主動獵")
	assert(state.teams.has(0), "獵發起後 band 仍在（npc_combat 解算）")
	print("npc active hunt OK")
```

- [ ] **Step 2: 跑確認失敗** — `try_hunt_predator` 未定義。

- [ ] **Step 3: 實作**

`faction_ai_system.gd` 新增（並在 survival cascade 適當處或 idle 評估呼叫；最小：survival forage path 前先試獵，或 idle 時試）：

```gdscript
# NPC 主動獵獸：腳下有 predator + 戰力足 + 缺糧 → npc_combat 起獵。回傳是否發起。
func try_hunt_predator(state: WorldState, team: TeamData) -> bool:
	if team.beast_kind != "" or team.combat_target != -1:
		return false
	var tile: HexTileData = state.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)
	if tile == null or int(tile.resources.get("predator_density", 0)) <= 0:
		return false
	var leader = state.persons.get(team.leader_id)
	var combat: float = float(leader.skills.get("戰鬥", 0.0)) if leader else 0.0
	# 戰力門檻（TEST VALUE）：人多 + 有戰技才獵，弱隊不送死
	if team.population < 8 or combat < 0.3:
		return false
	var kind: String = "bear" if tile.terrain == "mountain" else "boar"
	tile.resources["predator_density"] = int(tile.resources["predator_density"]) - 1
	var bid: int = BeastSystem.new().build_beast_team(state, kind, team.tile_pos)
	NpcCombatSystem.new().start_combat(state, team.team_id, bid)
	return true
```

接入點：`_trigger_survival` 飢餓 + 腳下 predator 時，於 forage path 之前 `if try_hunt_predator(state, team): return`（戰力足者獵獸優於覓食）。實作者擇一最小接入，勿大改 cascade。

- [ ] **Step 4: 測試通過**
- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat: NPC 主動獵獸（戰力足 + predator 格 + 缺糧）"
```

---

## Task 6: 註冊測試 + 整合驗證

**Files:**
- Modify: `scripts/debug/headless_test.gd`（`_initialize`）

- [ ] **Step 1: 註冊**

```gdscript
	_test_ambush_detect()
	_test_ambush_player()
	_test_ambush_npc()
	_test_ambush_detected_no_fight()
	_test_beast_reward_exp()
	_test_predator_infamy()
	_test_npc_active_hunt()
```

- [ ] **Step 2: 全測試** — `--import` 後跑，7 新測試 OK，無新增 SCRIPT ERROR（Bug8 baseline 可接受）。

- [ ] **Step 3: 2 年 multi**

```bash
$env:SIM_CONFIGS = "survival_start,tyrant,warzone"; .\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd *> godot_ambush_verify.log
iconv -f UTF-16LE -t UTF-8 godot_ambush_verify.log > godot_ambush_verify_u8.log
grep -a "CoinAudit\|SCRIPT ERROR\|多配置對比\|Ambush\|BeastHunt" godot_ambush_verify_u8.log
```

驗收：
- 三 config `died=no`、`coin_eq delta=0.00`、無新增 SCRIPT ERROR（特別**確認 Bug9 未觸發**：無玩家的 multi 中，NPC 被伏擊走 npc_combat，`encounter_active` 不應因 NPC 卡住）
- `[Ambush]` 出現（NPC 被獸伏擊）、可能 `[BeastHunt]`（NPC 主動獵）— 證明機制活
- beast 隊不殘留（負 id 不累積）

- [ ] **Step 4: handback** — `docs/superpowers/handbacks/2026-06-14-stage1-2b2-ambush.md`

---

## 注意事項（給實作者）

- **新 class（AmbushSystem）必先 `--import`**。
- **Bug9 鐵律**：NPC 遭遇野獸**只走 `npc_combat_system`**，玩家才走 `EncounterSystem`。`_trigger_ambush` 已分流，勿讓 NPC 進 encounter。
- **野獸不被伏擊也不互獵**：`check_ambush` / `try_hunt_predator` 對 `beast_kind != ""` 隊 skip。
- **守恆**：Task 6 coin_eq delta=0（infamy/exp/肉皆非 coin_eq）。
- **TEST VALUE**：偵測門檻 / `AMBUSH_BASE_CHANCE` / exp / 獵獸戰力門檻 → 連同 2b-1 BEAST_PROFILE 一起量測 tune。重點觀測：玩家被伏擊頻率是否惱人（太高調 AMBUSH_BASE_CHANCE / 偵測門檻）、NPC 是否大量送死獵獸。
- **encounter 回傳對齊**（Task 3）：伏擊起玩家 encounter 須比照既有玩家遭遇戰交還 bridge，勿自建生命週期。
- 持久惡獸實體 / bounty 任務 = 任務系統 spec（infamy 只是計數 hook，本 plan 不做惡獸遊蕩）。
