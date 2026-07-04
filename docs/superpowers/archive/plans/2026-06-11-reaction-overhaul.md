# Reaction 職責收斂 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Reaction 收斂為純心理層：P2 改 work_morale 係數、P3 刪除、P5 綁糧食盈餘、N1 三修、N3 不 ghost、N5 守恆、print diff-only。

**Architecture:**
- `reaction_system._apply_reaction` 各 case 改寫
- `team.work_morale` 新欄位，reaction 統計寫入，resource/harvest 消費
- `_spawn_exile_or_join` 新 helper（離團者去處）
- ReactionBridge 用 `ThreatAssessment` 找真威脅才設逃跑

**Spec:** `docs/superpowers/specs/2026-06-11-reaction-overhaul-design.md`

**Verified facts（plan 對齊）:**
- class names: `ReactionSystem` / `AnonTierSystem` / `ThreatAssessment` / `PersonGenerator` / `FactionAISystem`
- `PersonData` id 欄位 = `id`（非 person_id）；已有 `coin` 欄位；無 `last_reaction`（需加）
- `TeamData` 無 `work_morale`（需加）
- `_flee_target(state, team, threat)` 在 `faction_ai_system.gd:261`（instance method）— reaction_system 不能直接呼叫，plan 改為複製簡版到 reaction_system（或抽 static；見 Task 6）
- `AnonTierSystem.kill_random(team, count, source)` static 存在
- `FOOD_PER_PERSON_PER_DAY = 2.4` 在 `resource_system.gd:3`（reaction_system 引用時用 `ResourceSystem.FOOD_PER_PERSON_PER_DAY`）
- 流亡 team 建立模式參考 `population_system._create_overflow_team`（tags=["流亡"], faction=-1, team_known/team_discovered 初始化）
- `_collect_from_tile` 在 `resource_system.gd:106`；P2 印 food 在 `reaction_system.gd:205-212`

---

## 檔案結構

| 檔案 | 變更 |
|---|---|
| `scripts/data/team_data.gd` | 加 `work_morale: float = 1.0` |
| `scripts/data/person_data.gd` | 加 `last_reaction: String = ""` |
| `scripts/simulation/reaction_system.gd` | 主改：P2/P3/P5/N1/N3/N5 + bridge + work_morale 統計 + diff print + `_spawn_exile_or_join` |
| `scripts/simulation/resource_system.gd` | `_collect_from_tile` gain 乘 work_morale |
| `scripts/simulation/harvest_system.gd` | 若有 team 產出路徑也乘（grep 確認）|
| `scripts/debug/headless_test.gd` | ~11 測試 + 修既有 P3 相關測試 |

## 測試命令

```powershell
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_test.gd
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd
```

---

## Task 1: 欄位 + P3 刪除

**Files:**
- Modify: `scripts/data/team_data.gd`, `scripts/data/person_data.gd`
- Modify: `scripts/simulation/reaction_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_reaction_fields() -> void:
	var t := TeamData.new()
	assert(abs(t.work_morale - 1.0) < 0.001)
	var p := PersonData.new()
	assert(p.last_reaction == "")
	print("Reaction Task1a OK")

func _test_p3_removed() -> void:
	# P3_recruit 不在 scores dict → 任何 person 評估不會回 P3_recruit
	var rs := ReactionSystem.new()
	var team := TeamData.new(); team.team_id = 0; team.population = 5
	var p := PersonData.new(); p.id = 1; p.team_id = 0
	p.values = { "野心": 0.9, "貪婪": 0.9 }   # 舊 P3 高分個性
	var r: String = rs._evaluate_person(p, team)
	assert(r != "P3_recruit", "P3 應已刪除，實際=%s" % r)
	print("Reaction Task1b OK")
```

- [ ] **Step 2: 加欄位**

`team_data.gd`：
```gdscript
var work_morale: float = 1.0   # 工作態度係數 [0.5,1.5]，reaction 統計寫入，產出系統消費
```

`person_data.gd`：
```gdscript
var last_reaction: String = ""   # diff print 用
```

- [ ] **Step 3: 刪 P3**

`reaction_system.gd`：
- scores dict 刪 `"P3_recruit": _score_recruit(person, team),`（line ~91）
- 刪 `_score_recruit` 函數
- `_apply_reaction` 刪 `"P3_recruit":` case
- line ~123/124 的 bonus 判斷把 `"P3_recruit"` 從 array 移除（保留 P4_expand）

- [ ] **Step 4: 修既有測試**

```powershell
grep -n "P3_recruit" scripts/debug/headless_test.gd scripts/debug/game_sim_test.gd
```
找到的 P3 相關 assert 改掉或刪除（如 reaction 測試期望 P3 者改期望其他反應）。

- [ ] **Step 5: 跑 + Commit**

```powershell
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
git add scripts/data/team_data.gd scripts/data/person_data.gd scripts/simulation/reaction_system.gd scripts/debug/headless_test.gd
git commit -m "feat(reaction): 加 work_morale/last_reaction 欄位 + 刪 P3_recruit (Task 1)"
```

---

## Task 2: P2 → work_morale（不印 food）

**Files:**
- Modify: `scripts/simulation/reaction_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_p2_no_food() -> void:
	var state := WorldState.new(); state.world = WorldData.new()
	var team := TeamData.new(); team.team_id = 0; team.population = 5
	team.resources = { "food": 100.0 }
	state.teams[0] = team
	var p := PersonData.new(); p.id = 1; p.team_id = 0
	state.persons[1] = p
	var rs := ReactionSystem.new()
	rs._apply_reaction(state, p, team, "P2_produce")
	assert(abs(float(team.resources["food"]) - 100.0) < 0.001, "P2 不應加 food")
	print("Reaction Task2a OK")

func _test_work_morale_shift() -> void:
	# 全員 P2 → morale 上升趨向 1.5；全員 N4 → 下降趨向 0.5
	var state := WorldState.new(); state.world = WorldData.new()
	var team := TeamData.new(); team.team_id = 0; team.population = 3
	team.tags = ["生產"]
	state.teams[0] = team
	# 3 個高生產 named
	for i in range(3):
		var p := PersonData.new(); p.id = 10 + i; p.team_id = 0
		p.skills = { "生產": 0.9 }; p.values = { "慎重": 0.8 }
		p.loyalty = 0.9
		state.persons[10 + i] = p
		if i == 0: team.leader_id = p.id
		else: team.named_members.append(p.id)
	var rs := ReactionSystem.new()
	for _i in range(50):
		rs.evaluate_all(state, [0])
	assert(team.work_morale > 1.0, "勤奮村 morale 應 > 1.0，實際=%.2f" % team.work_morale)
	print("Reaction Task2b OK (morale=%.2f)" % team.work_morale)
```

- [ ] **Step 2: 改 _apply_reaction P2 case + evaluate_all 統計**

`_apply_reaction` P2 case 改為空效果（心理上想工作，效果由 morale 體現）：
```gdscript
"P2_produce":
	pass   # 效果改由 work_morale 係數體現（evaluate_all 統計）
```

`evaluate_all` per-team loop 加統計（在 person loop 內累積，loop 後更新）：
```gdscript
# person loop 前
var morale_acc: float = 0.0
var morale_n: int = 0
# person loop 內（取得 reaction 後）
match reaction:
	"P2_produce": morale_acc += 1.0; morale_n += 1
	"N4_shirk":   morale_acc -= 1.0; morale_n += 1
	"none":       pass
	_:            morale_n += 1   # 其他 reaction 中性計入
# person loop 後（flee bridge 前）
if morale_n > 0:
	var target_morale: float = clampf(1.0 + (morale_acc / float(morale_n)) * 0.5, 0.5, 1.5)
	team.work_morale = clampf(lerpf(team.work_morale, target_morale, 0.1), 0.5, 1.5)
```

- [ ] **Step 3: 跑 + Commit**

```powershell
git add scripts/simulation/reaction_system.gd scripts/debug/headless_test.gd
git commit -m "feat(reaction): P2 不印 food，改 work_morale 統計 (Task 2)"
```

---

## Task 3: 產出消費 work_morale

**Files:**
- Modify: `scripts/simulation/resource_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_collect_uses_morale() -> void:
	# 同條件 team，morale 0.5 vs 1.5 → 採集 gain 差 3 倍
	# Setup tile resources + outpost，跑 _collect_from_tile，比 food 增量
	# ...
	print("Reaction Task3 OK")
```

- [ ] **Step 2: 改 `_collect_from_tile`**

`resource_system.gd:106` gain 計算後加：

```gdscript
gain *= team.work_morale
```

放在 `gain *= outpost_mult * pop_mult` 之後。

- [ ] **Step 3: grep harvest_system 是否有 team 產出路徑**

```powershell
grep -n "team.resources\[" scripts/simulation/harvest_system.gd
```
有 team 產出則同樣乘 morale；只有 tile 再生則不動。

- [ ] **Step 4: 跑 + Commit**

```powershell
git add scripts/simulation/resource_system.gd scripts/debug/headless_test.gd
git commit -m "feat(resource): 採集產出乘 work_morale (Task 3)"
```

---

## Task 4: P5 糧食盈餘條件 + N5 守恆

**Files:**
- Modify: `scripts/simulation/reaction_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_p5_needs_surplus() -> void:
	# food < pop*2.4*7 → 不生；足夠 → minor +1
	var state := WorldState.new(); state.world = WorldData.new()
	var team := TeamData.new(); team.team_id = 0; team.population = 10
	team.resources = { "food": 50.0 }   # 50 < 10*2.4*7=168
	var p := PersonData.new(); p.id = 1; p.team_id = 0
	var rs := ReactionSystem.new()
	rs._apply_reaction(state, p, team, "P5_breed")
	assert(team.minor_population == 0, "糧不足不生")
	team.resources["food"] = 200.0
	rs._apply_reaction(state, p, team, "P5_breed")
	assert(team.minor_population == 1, "盈餘該生")
	print("Reaction Task4a OK")

func _test_n5_coin_conserved() -> void:
	var state := WorldState.new(); state.world = WorldData.new()
	var team := TeamData.new(); team.team_id = 0; team.population = 5
	team.resources = { "coin": 100.0 }
	var p := PersonData.new(); p.id = 1; p.team_id = 0
	var rs := ReactionSystem.new()
	var before: float = float(team.resources["coin"]) + p.coin
	rs._apply_reaction(state, p, team, "N5_extort")
	var after: float = float(team.resources["coin"]) + p.coin
	assert(abs(before - after) < 0.001, "coin 總和守恆")
	assert(p.coin > 0, "偷的錢進 person.coin")
	print("Reaction Task4b OK")
```

- [ ] **Step 2: 改 case**

```gdscript
"P5_breed":
	var surplus_ok: bool = float(team.resources.get("food", 0)) \
		> float(team.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY * 7.0
	if surplus_ok:
		var cap: int = int(team.population * 0.2)
		if team.minor_population < cap:
			team.minor_population += 1
"N5_extort":
	var money: float = float(team.resources.get("coin", 0))
	var steal: float = minf(money, 5.0)
	team.resources["coin"] = money - steal
	person.coin += steal   # 守恆：偷進私囊
```

- [ ] **Step 3: 跑 + Commit**

```powershell
git add scripts/simulation/reaction_system.gd scripts/debug/headless_test.gd
git commit -m "feat(reaction): P5 糧食盈餘條件 + N5 coin 守恆 (Task 4)"
```

---

## Task 5: N1 三修 + N3 + `_spawn_exile_or_join`

**Files:**
- Modify: `scripts/simulation/reaction_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_n1_solo_skip() -> void:
	# pop=1 leader flee → 無變化、stress 不減
	# ...
	print("Reaction Task5a OK")

func _test_n1_leader_tier_sync() -> void:
	# pop=5 leader flee → pop 4 + anon_tiers 總和 同步 -1
	# ...
	print("Reaction Task5b OK")

func _test_n1_named_spawns_exile() -> void:
	# named flee → 同格無流亡 → 新建 1 人流亡 team，person 為 leader
	# ...
	print("Reaction Task5c OK")

func _test_n3_joins_existing_exile() -> void:
	# named defect + 同格已有流亡 team → 加入該 team
	# ...
	print("Reaction Task5d OK")
```

- [ ] **Step 2: 改 N1/N3 case + helper**

```gdscript
"N1_flee":
	if team.population <= 1 and person.id == team.leader_id:
		return   # solo 無處可逃：不變化、stress 不洩壓（持續高壓餵 N2/N3）
	team.population = maxi(team.population - 1, 1)
	person.stress = maxf(person.stress - 0.3, 0.0)
	if team.named_members.has(person.id):
		team.named_members.erase(person.id)
		person.team_id = -1
		_spawn_exile_or_join(state, person, team.tile_pos)
	elif person.id == team.leader_id:
		AnonTierSystem.kill_random(team, 1, "flee")   # leader 留下，實際走的是 anon
"N3_defect":
	if team.population <= 1 and person.id == team.leader_id:
		return   # solo leader 無從叛逃自己
	team.population = maxi(team.population - 1, 1)
	person.loyalty = 0.0
	if team.named_members.has(person.id):
		team.named_members.erase(person.id)
		person.team_id = -1
		_spawn_exile_or_join(state, person, team.tile_pos)
	elif person.id == team.leader_id:
		AnonTierSystem.kill_random(team, 1, "defect")
```

helper（仿 `population_system._create_overflow_team`）：

```gdscript
func _spawn_exile_or_join(state: WorldState, person: PersonData, pos: Vector2i) -> void:
	# 同格流亡 team → 加入
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.tile_pos != pos: continue
		if not ("流亡" in t.tags): continue
		t.named_members.append(person.id)
		t.population += 1
		person.team_id = t.team_id
		return
	# 無 → 新建 1 人流亡 team
	var ot := TeamData.new()
	ot.team_id = _next_team_id(state)
	ot.tile_pos = pos
	ot.faction_id = -1
	ot.tags = ["流亡"]
	ot.population = 1
	ot.current_task = TeamData.TASK_IDLE
	ot.leader_id = person.id
	person.team_id = ot.team_id
	person.role = "leader"
	state.teams[ot.team_id] = ot
	state.team_known[ot.team_id] = []
	state.team_discovered[ot.team_id] = []
	print("[Reaction] Person%d 離團自立流亡 Team%d at (%d,%d)" % [
		person.id, ot.team_id, pos.x, pos.y])

func _next_team_id(state: WorldState) -> int:
	var max_id: int = -1
	for tid in state.teams:
		if tid > max_id: max_id = tid
	return max_id + 1
```

注意：`_spawn_exile_or_join` 在 `evaluate_all` 的 person loop 中被呼叫，會在迭代 `state.persons` 時加 `state.teams` entry — 加 team 安全（迭代的是 persons），但 reaction loop 外層 `for tid in team_ids`（複製的 id array）不受影響。確認不在 `for tid in state.teams` 迭代內呼叫。

- [ ] **Step 3: 跑 + Commit**

```powershell
git add scripts/simulation/reaction_system.gd scripts/debug/headless_test.gd
git commit -m "feat(reaction): N1 三修 + N3 tier 同步 + 離團組流亡 team (Task 5)"
```

---

## Task 6: ReactionBridge 逃跑修（真威脅 + 真目的地）

**Files:**
- Modify: `scripts/simulation/reaction_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_bridge_no_threat_no_hijack() -> void:
	# flee_ratio >= 0.3 但視野無威脅 → task 不變
	# ...
	print("Reaction Task6a OK")

func _test_bridge_with_threat_flees() -> void:
	# 視野內有高 threat team → task=逃跑 + move_target 反方向 in-map
	# ...
	print("Reaction Task6b OK")
```

- [ ] **Step 2: 改 bridge**

`evaluate_all` 內 flee bridge（line ~31-35）改：

```gdscript
if flee_count > 0 and float(flee_count) / maxf(team.population, 1) >= 0.3:
	if team.current_task not in ["逃跑", "護衛"]:
		var threat_id: int = _find_top_threat(state, team)
		if threat_id != -1:
			var threat: TeamData = state.teams[threat_id]
			team.current_task = "逃跑"
			team.move_target = _flee_target_simple(state, team, threat)
			print("[ReactionBridge] Team%d 逃跑（%d/%d 人）← threat Team%d" % [
				tid, flee_count, team.population, threat_id])
		# 無威脅 → 不劫持 task（內心恐慌但無處可逃）

func _find_top_threat(state: WorldState, team: TeamData) -> int:
	var best_id: int = -1
	var best: float = ThreatAssessment.THREAT_BASE_THRESHOLD
	for tid in state.team_discovered.get(team.team_id, []):
		var other: TeamData = state.teams.get(tid)
		if other == null: continue
		var s: float = ThreatAssessment.score(state, team, other)
		if s > best:
			best = s
			best_id = tid
	return best_id

# 朝威脅反方向 3 hex（in-map check；仿 faction_ai._flee_target）
func _flee_target_simple(state: WorldState, team: TeamData, threat: TeamData) -> Vector2i:
	var dir: Vector2i = team.tile_pos - threat.tile_pos
	var pos: Vector2i = team.tile_pos + Vector2i(signi(dir.x), signi(dir.y)) * 3
	if state.world.tiles.has(pos.x * 1000 + pos.y):
		return pos
	return team.tile_pos
```

- [ ] **Step 3: 跑 + Commit**

```powershell
git add scripts/simulation/reaction_system.gd scripts/debug/headless_test.gd
git commit -m "feat(reaction): bridge 逃跑需真威脅 + 真目的地 (Task 6)"
```

---

## Task 7: diff-only print

**Files:**
- Modify: `scripts/simulation/reaction_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 改 print**

`_apply_reaction` 結尾 print 改：

```gdscript
if reaction != person.last_reaction:
	print("[Tick %d] Person %d (%s/team%d) → %s | stress=%.2f loyalty=%.2f" % [
		state.world.current_tick, person.id, person.role, person.team_id,
		reaction, person.stress, person.loyalty])
person.last_reaction = reaction
```

- [ ] **Step 2: 驗 log 縮減**

```powershell
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_test.gd > godot_test.log 2>&1
(Get-Content godot_test.log | Measure-Object -Line).Lines
```
對比改前行數（預期大幅下降）。

- [ ] **Step 3: Commit**

```powershell
git add scripts/simulation/reaction_system.gd
git commit -m "feat(reaction): per-person print diff-only (Task 7)"
```

---

## Task 8: 整合驗證 + handback

**Files:**
- Create: `docs/superpowers/handbacks/2026-06-11-reaction-overhaul.md`

- [ ] **Step 1: 跑全測試 + multi**

```powershell
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_test.gd > godot_test.log 2>&1
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd > godot_multi.log 2>&1
Get-Content godot_multi.log | Select-String "return_home|乞食|掠奪|SurvivalLoot|餓|work_morale|流亡" | Group-Object | Select-Object Count, Name | Sort-Object Count -Descending | Select-Object -First 20
(Get-Content godot_multi.log | Measure-Object -Line).Lines
```

關鍵驗證：
- survival 鏈是否復活（return_home / 乞食 / 掠奪 出現）
- 人口是否崩潰過快（P2/P3 水龍頭關掉後）— 記錄各 config 末態 pop
- log 行數對比（spam 縮減）
- ALL INVARIANTS PASSED

- [ ] **Step 2: handback**

```markdown
# Hand Back: Reaction 職責收斂

## 實作摘要
[各檔變更]

## 行為變化
- P2/P3 水龍頭關閉 → 經濟全靠 harvest/outpost
- work_morale 係數 [0.5,1.5] 乘產出
- survival 鏈觸發情況：[數據]
- 人口趨勢：[各 config 末態 vs 初始]
- log 行數：[before/after]

## 驗證
[headless N/N + invariants + multi]

## 待主 session 確認
- 飢餓程度是否需 tune config 初始糧 / harvest 參數
- work_morale lerp 0.1 / ±0.5 幅度
- 人口淨萎縮速度（known_issue：minor 長大）
```

- [ ] **Step 3: Commit**

```powershell
git add docs/superpowers/handbacks/2026-06-11-reaction-overhaul.md
git commit -m "docs: reaction overhaul handback (Task 8)"
```
