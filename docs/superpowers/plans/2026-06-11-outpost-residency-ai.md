# Outpost 居民派駐 AI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** NPC 主動派駐居民填充 outpost：派子隊或 invite 流亡（個性決定）。流民駐紮後子隊 try_merge_back 回母團。

**Architecture:**
- `faction_ai_system._evaluate_outpost_residency` cadence 3 天
- 個性選派 subteam（既有 SubteamSystem.dispatch）或 invite 流亡（既有 DiplomaticAiSystem）
- 子隊安頓 → SUBTEAM+PRODUCE dual tag
- 流民駐紮 → 既有子隊 try_merge_back

**Spec:** `docs/superpowers/specs/2026-06-11-outpost-residency-ai-design.md`

**Class names verified**：`FactionAISystem` / `SubteamSystem` / `DiplomaticAiSystem` / `PersonGenerator`

**SubteamSystem.dispatch signature**：`(state, parent_id, sub_leader_id, pop_count, task, move_target, order_target_id=-1, order_task="", extra_advisor_ids=[]) -> int`

---

## 檔案結構

| 檔案 | 變更 |
|---|---|
| `scripts/data/team_data.gd` | 加 `residency_eval_next_tick` / `invite_cooldown` 欄位 |
| `scripts/simulation/faction_ai_system.gd` | 加 `_evaluate_outpost_residency` + `_dispatch_subteam_settle` + `_try_invite_nearby_exile` + `_has_resident_team_on_tile` |
| `scripts/simulation/interaction_system.gd` | `_convert_to_resident` 結尾 trigger 既有子隊 try_merge_back |
| `scripts/debug/headless_test.gd` | ~6 個測試 |

---

## Task 1: TeamData 欄位

- [ ] **Step 1: 測試**

```gdscript
func _test_residency_team_fields() -> void:
	var t := TeamData.new()
	assert(t.residency_eval_next_tick == 0)
	assert(t.invite_cooldown is Dictionary and t.invite_cooldown.size() == 0)
	print("Residency Task1 OK")
```

- [ ] **Step 2: 加欄位**

```gdscript
var residency_eval_next_tick: int = 0
var invite_cooldown: Dictionary = {}   # { tid: tick_until }
```

- [ ] **Step 3: Commit**

```powershell
git add scripts/data/team_data.gd scripts/debug/headless_test.gd
git commit -m "feat(team): residency fields (Task 1)"
```

---

## Task 2: `_has_resident_team_on_tile` + `_evaluate_outpost_residency`

- [ ] **Step 1: 測試**

```gdscript
func _test_has_resident_team_check() -> void:
	# Setup: tile with PRODUCE team on it → has_resident=true
	# 無 PRODUCE team → false
	# ...
	print("Residency Task2 OK")
```

- [ ] **Step 2: 加 helper + cadence 評估**

```gdscript
const RESIDENCY_CADENCE: int = 720    # 3 天
const RESIDENCY_COOLDOWN: int = 1680  # 7 天

func _has_resident_team_on_tile(state: WorldState, tile: HexTileData) -> bool:
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.tile_pos != tile.tile_pos: continue
		if "生產" in t.tags: return true
	return false

func _evaluate_outpost_residency(state: WorldState, team: TeamData) -> void:
	if state.world.current_tick < team.residency_eval_next_tick: return
	team.residency_eval_next_tick = state.world.current_tick + RESIDENCY_CADENCE
	var leader: PersonData = state.persons.get(team.leader_id)
	if leader == null: return
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.outpost_owner != team.team_id: continue
		if _has_resident_team_on_tile(state, tile): continue
		_try_dispatch_or_invite(state, team, tile, leader)
```

`evaluate_all` per-team loop 加 call。

- [ ] **Step 3: Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(faction_ai): _evaluate_outpost_residency cadence + 偵測 (Task 2)"
```

---

## Task 3: 個性選派管道 `_try_dispatch_or_invite`

- [ ] **Step 1: 測試**

```gdscript
func _test_dispatch_high_ambition() -> void:
	# leader 野心 0.9 → 走 dispatch path
	# ...
	print("Residency Task3a OK")

func _test_invite_high_commerce() -> void:
	# leader 商業/慎重高 → 走 invite path
	# ...
	print("Residency Task3b OK")
```

- [ ] **Step 2: 加分派函數**

```gdscript
func _try_dispatch_or_invite(state, team, tile, leader) -> void:
	var ambition: float = float(leader.values.get("野心", 0.5))
	var military: float = float(leader.values.get("好戰", 0.5))
	var commerce: float = float(leader.skills.get("商業", 0.0))
	var caution: float = float(leader.values.get("慎重", 0.5))
	var dispatch_score: float = ambition * 0.5 + military * 0.3
	var invite_score: float = commerce * 0.4 + caution * 0.3
	if dispatch_score > invite_score and team.population >= 8:
		_dispatch_subteam_settle(state, team, tile)
	else:
		_try_invite_nearby_exile(state, team, tile)
```

- [ ] **Step 3: Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(faction_ai): _try_dispatch_or_invite 個性分派 (Task 3)"
```

---

## Task 4: `_dispatch_subteam_settle`

- [ ] **Step 1: 測試**

```gdscript
func _test_dispatch_subteam_creates_subteam() -> void:
	# Setup: owner team pop=20, leader 野心高, outpost
	# Expected: subteam 創建, tags=[子團], task=安頓, move_target=outpost tile
	# settler_count = clamp(20/4, 2, 5) = 5
	# ...
	print("Residency Task4 OK")
```

- [ ] **Step 2: 實作**

```gdscript
func _dispatch_subteam_settle(state, owner: TeamData, tile: HexTileData) -> void:
	var settler_count: int = clampi(owner.population / 4, 2, 5)
	if owner.population < settler_count + 1: return   # 至少留 1 人
	# leader 來源
	var sub_leader_id: int = -1
	if owner.named_members.size() > 2:
		sub_leader_id = int(owner.named_members[0])
	else:
		var new_leader: PersonData = PersonGenerator.generate_for_team(
			state, owner, "member")
		if new_leader != null:
			sub_leader_id = new_leader.id
	if sub_leader_id == -1: return
	var subteam_id: int = SubteamSystem.new().dispatch(
		state, owner.team_id, sub_leader_id, settler_count, "安頓", tile.tile_pos)
	if subteam_id == -1: return
	print("[Residency] Team%d 派子隊 Team%d 安頓 outpost (%d,%d) pop=%d" % [
		owner.team_id, subteam_id, tile.tile_pos.x, tile.tile_pos.y, settler_count])
```

子隊抵達 outpost tile → `_try_interact` 既有 `"安頓"` task handler → `_convert_to_resident` 加 PRODUCE tag。

- [ ] **Step 3: Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(faction_ai): _dispatch_subteam_settle 派子隊安頓 (Task 4)"
```

---

## Task 5: `_try_invite_nearby_exile` + cooldown

- [ ] **Step 1: 測試**

```gdscript
func _test_invite_exile_accept() -> void:
	# Setup: 視野內流亡 team + diplomatic accept → task=安頓
	# ...
	print("Residency Task5a OK")

func _test_invite_exile_reject_cooldown() -> void:
	# reject → invite_cooldown 設 7 天
	# ...
	print("Residency Task5b OK")
```

- [ ] **Step 2: 實作**

```gdscript
func _try_invite_nearby_exile(state, team: TeamData, tile: HexTileData) -> void:
	for tid in state.team_discovered.get(team.team_id, []):
		var t: TeamData = state.teams.get(tid)
		if t == null: continue
		if not ("流亡" in t.tags): continue
		if state.world.current_tick < int(team.invite_cooldown.get(tid, 0)): continue
		var dipl := DiplomaticAiSystem.new()
		var resp: String = dipl.handle_diplomacy_message(
			state, t, team, "invite_settle")
		if resp == "accept":
			t.current_task = "安頓"
			t.move_target = tile.tile_pos
			print("[Residency] Team%d 邀請 Team%d 安頓 outpost (%d,%d)" % [
				team.team_id, tid, tile.tile_pos.x, tile.tile_pos.y])
			return
		team.invite_cooldown[tid] = state.world.current_tick + RESIDENCY_COOLDOWN
```

- [ ] **Step 3: Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(faction_ai): _try_invite_nearby_exile + cooldown (Task 5)"
```

---

## Task 6: 流民駐紮 → 子隊 try_merge_back

- [ ] **Step 1: 測試**

```gdscript
func _test_settle_triggers_subteam_merge_back() -> void:
	# Setup: tile 已有 SUBTEAM+PRODUCE 子隊, 流民 _convert_to_resident
	# Expected: 子隊 try_merge_back 觸發（回母團）
	# ...
	print("Residency Task6 OK")
```

- [ ] **Step 2: 改 `_convert_to_resident`**

於 `interaction_system._convert_to_resident` 結尾加：

```gdscript
# 流民變居民後，若同 tile 有 SUBTEAM+PRODUCE 子隊（暫派駐居民），觸發回母團
for tid in state.teams:
	var t: TeamData = state.teams.get(tid)
	if t == null: continue
	if t.tile_pos != subteam.tile_pos: continue
	if t.team_id == subteam.team_id: continue
	if "子團" in t.tags and "生產" in t.tags:
		SubteamSystem.new().try_merge_back(state, t.team_id)
```

注意：try_merge_back 可能因 distance 失敗（母團太遠），則子隊留在 outpost 跟流民共處。

- [ ] **Step 3: Commit**

```powershell
git add scripts/simulation/interaction_system.gd scripts/debug/headless_test.gd
git commit -m "feat(interaction): 流民駐紮 trigger 子隊 try_merge_back (Task 6)"
```

---

## Task 7: 整合驗證 + handback

- [ ] **Step 1: 跑全測試 + multi**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_multi.gd > godot_multi.log 2>&1
Get-Content godot_multi.log -Encoding UTF8 | Select-String "Residency|Market.*成交|Settle" | Group-Object | Select-Object Count, Name | Sort-Object Count -Descending
```

預期：Residency 派駐事件 > 0，trade 成交 > 0（居民團 absorb 公庫）。

- [ ] **Step 2: 寫 handback + Commit**

`docs/superpowers/handbacks/2026-06-11-outpost-residency-ai.md`：

```markdown
# Hand Back: Outpost 居民派駐 AI

## 實作摘要
- _evaluate_outpost_residency + _has_resident_team_on_tile
- 個性分派 dispatch / invite
- _dispatch_subteam_settle (subteam_system dispatch)
- _try_invite_nearby_exile (diplomatic_ai)
- 流民駐紮 → 子隊 try_merge_back

## 驗證
- headless: N/N
- multi: trade 成交 [數據], Residency 派駐 [數據]

## 待主 session
- 派子隊掏空母團風險
- (iii) leader 個性決定留/回 → known_issues
```

```powershell
git add docs/superpowers/handbacks/2026-06-11-outpost-residency-ai.md
git commit -m "docs: residency AI handback (Task 7)"
```
