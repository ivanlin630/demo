# Leader 繼承單一真值源 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把 leader 繼承邏輯收斂成單一 owner（`EventSystem.on_leader_death`），消除 encounter/faction_ai/npc_combat 三路徑分叉導致的「named 全滅隊永久 leaderless anon blob」bug。

**Architecture:** `on_leader_death` 成唯一繼承邏輯（掃 named_members、無統領門檻、anon fallback、晉升後 overflow 檢查、player 分支內聚）。`faction_ai` 每-tick 安全網（`leader_id==-1`→呼 owner）為唯一偵測點；npc_combat 戰中即時呼為捷徑。encounter 不動（維持裸置 leader_id=-1，由安全網次 tick 補位）。刪除 `_promote_successor` + `_handle_player_leader_death`（邏輯內聚）。`get_player_team_id` 抽到 WorldState 單一源。

**Tech Stack:** Godot 4.2.2 GDScript；headless 測試 harness（`scripts/debug/headless_test.gd`，`_test_*` 函數於 `_initialize()` 註冊，`assert(cond, msg)` 失敗即中止）。

## Global Constraints

- 一律用 wrapper 跑：`.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`（強制 UTF-8，避免 CP950 亂碼）。
- 新增 `_test_*` 函數須在 `_initialize()`（headless_test.gd:16 起）加一行呼叫註冊，否則不會跑。
- harness 跑全部測試；assert 失敗即中止整輪 → 「驗證失敗」= 跑 harness 看在新測試處中止；「驗證通過」= 整輪到 `=== DONE ===`。
- 行為保留原則：除「繼承無統領門檻」（用戶 2026-06-19 裁定）外，不改任何玩法。
- 回歸閘：headless `=== DONE ===` 全綠 + coin_eq=0 + InvariantAudit 0 違反 + 1000 Tick 無崩潰。**不**用 multi drift 當閘。
- 不碰 `game-design.md`、不做殲滅模型（藍圖 WHAT，另案）、不碰 E-2/E-3/anon 2c-2。
- spec 來源：`docs/superpowers/specs/2026-06-19-leader-succession-single-source-design.md`。

---

### Task 1: `WorldState.get_player_team_id()` 單一源

**Files:**
- Modify: `scripts/data/world_state.gd`（加 method）
- Modify: `scripts/simulation/faction_ai_system.gd:1038-1048`（`_get_player_team_id` 改 delegate）
- Modify: `scripts/simulation/player_command_system.gd:1085`（`_get_player_team_id` 改 delegate）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Produces: `WorldState.get_player_team_id() -> int`（player 在世→回其 team_id；player 已死（persons 無）→ 反查 leader_id==player_id 或 player_id∈named_members 的 team；無→ -1）。

- [ ] **Step 1: 寫失敗測試**

加到 `scripts/debug/headless_test.gd`（檔末附近，與其他 `_test_` 並列）：

```gdscript
func _test_world_get_player_team_id() -> void:
	print("--- WorldState.get_player_team_id 單一源 ---")
	var s := WorldState.new()
	s.world = WorldData.new()
	var t := TeamData.new(); t.team_id = 7
	var p := PersonData.new(); p.id = 7000; p.team_id = 7
	s.persons[p.id] = p
	t.leader_id = p.id
	s.teams[7] = t
	s.player_id = p.id
	assert(s.get_player_team_id() == 7, "player 在世 → team 7，實際=%d" % s.get_player_team_id())
	# player 死亡（persons 移除），仍掛在 named_members → 反查
	s.persons.erase(p.id)
	t.leader_id = -1
	t.named_members = [p.id]
	assert(s.get_player_team_id() == 7, "player 死但掛 named → 反查 team 7，實際=%d" % s.get_player_team_id())
	# 完全找不到 → -1
	t.named_members = []
	assert(s.get_player_team_id() == -1, "查無 → -1，實際=%d" % s.get_player_team_id())
	print("get_player_team_id OK")
```

在 `_initialize()`（headless_test.gd:16 起的呼叫清單）加一行：

```gdscript
	_test_world_get_player_team_id()
```

- [ ] **Step 2: 跑 harness 驗證失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: 在 `get_player_team_id 單一源` 處報錯中止（method 不存在 / assert 失敗）。

- [ ] **Step 3: 實作 WorldState method**

加到 `scripts/data/world_state.gd`（與其他 func 並列）：

```gdscript
# Leader 繼承等用：player 所屬 team_id 單一源（player 死亡時反查掛載 team）。
func get_player_team_id() -> int:
	if player_id == -1:
		return -1
	var p = persons.get(player_id)
	if p == null:
		for tid in teams:
			var t = teams[tid]
			if t.leader_id == player_id or player_id in t.named_members:
				return tid
		return -1
	return p.team_id
```

- [ ] **Step 4: 既有 2 份改 delegate**

`scripts/simulation/faction_ai_system.gd` 的 `_get_player_team_id`（:1038-1048）整個函數體換成：

```gdscript
func _get_player_team_id(state: WorldState) -> int:
	return state.get_player_team_id()
```

`scripts/simulation/player_command_system.gd` 的 `_get_player_team_id`（:1085 起）同樣換成：

```gdscript
func _get_player_team_id(state: WorldState) -> int:
	return state.get_player_team_id()
```

- [ ] **Step 5: 跑 harness 驗證通過 + 無回歸**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `get_player_team_id OK` 印出，整輪到 `=== DONE ===`，無新增 assert 失敗。

- [ ] **Step 6: Commit**

```bash
git add scripts/data/world_state.gd scripts/simulation/faction_ai_system.gd scripts/simulation/player_command_system.gd scripts/debug/headless_test.gd
git commit -m "refactor(succession): get_player_team_id 抽到 WorldState 單一源"
```

---

### Task 2: `on_leader_death` NPC 路徑重寫（named 掃描 / 無門檻 / anon fallback / overflow）

**Files:**
- Modify: `scripts/simulation/event_system.gd`（`on_leader_death` 重寫 NPC 段；刪 `COMMAND_SKILL_MIN` const :3）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Consumes: 無（本 task 只改 NPC 段；player 分支 Task 3 補）。
- Produces: `EventSystem.on_leader_death(state, team) -> bool`：NPC 隊掃 `team.named_members` 取統領最高者晉升（無門檻、晉升後從 named_members erase）；無 named → `PersonGenerator.generate_for_team(state, team, "member")` 晉升 anon；皆無 → false。任一晉升成功後呼 `PopulationSystem.new().check_overflow_for_team(state, team.team_id)`。

- [ ] **Step 1: 寫失敗測試**

加到 `scripts/debug/headless_test.gd`：

```gdscript
func _mk_succession_team(tid: int, named_cmds: Array, anon_n: int) -> Array:
	# 回 [state, team]；named_cmds = 每個 named 的統領值（leader 另設）；anon_n = 平民 anon 數
	var s := WorldState.new()
	s.world = WorldData.new()
	var t := TeamData.new(); t.team_id = tid; t.tile_pos = Vector2i(4, 4)
	var leader := PersonData.new(); leader.id = tid * 1000; leader.team_id = tid
	leader.skills = {"統領": 0.5}
	s.persons[leader.id] = leader
	t.leader_id = leader.id
	var nidx: int = 1
	for cmd in named_cmds:
		var n := PersonData.new(); n.id = tid * 1000 + nidx; n.team_id = tid
		n.skills = {"統領": float(cmd)}
		s.persons[n.id] = n
		t.named_members.append(n.id)
		nidx += 1
	if anon_n > 0:
		AnonCohort.add(t.anon_cohorts, "平民", "healthy", anon_n)
	s.teams[tid] = t
	return [s, t]

func _test_succession_npc_best_named() -> void:
	print("--- 繼承：NPC 晉升 best named（無門檻）---")
	var r := _mk_succession_team(1, [0.1, 0.7, 0.3], 0)  # 三 named，最高 0.7
	var s: WorldState = r[0]; var t: TeamData = r[1]
	s.persons.erase(t.leader_id); t.leader_id = -1   # 模擬 leader 死
	var ok: bool = EventSystem.new().on_leader_death(s, t)
	assert(ok, "有 named 應繼承成功")
	assert(t.leader_id == 1 * 1000 + 2, "應選統領最高(0.7)的 named，實際 leader=%d" % t.leader_id)
	assert(not t.named_members.has(t.leader_id), "新 leader 應從 named_members 移除")

func _test_succession_low_named_no_threshold() -> void:
	print("--- 繼承：低統領 named 仍硬上位（無門檻）---")
	var r := _mk_succession_team(2, [0.05], 0)   # 唯一 named 統領僅 0.05
	var s: WorldState = r[0]; var t: TeamData = r[1]
	s.persons.erase(t.leader_id); t.leader_id = -1
	var ok: bool = EventSystem.new().on_leader_death(s, t)
	assert(ok and t.leader_id == 2 * 1000 + 1, "低統領 named 應硬上位，實際 leader=%d" % t.leader_id)

func _test_succession_anon_fallback() -> void:
	print("--- 繼承：無 named → anon 晉升 ---")
	var r := _mk_succession_team(3, [], 4)   # 0 named，4 anon
	var s: WorldState = r[0]; var t: TeamData = r[1]
	s.persons.erase(t.leader_id); t.leader_id = -1
	var ok: bool = EventSystem.new().on_leader_death(s, t)
	assert(ok, "有 anon 應晉升成功")
	assert(t.leader_id != -1 and s.persons.has(t.leader_id), "anon 晉升出新 named leader")

func _test_succession_anon_exhausted() -> void:
	print("--- 繼承：無 named 無 anon → 滅團(false) ---")
	var r := _mk_succession_team(4, [], 0)   # 0 named，0 anon
	var s: WorldState = r[0]; var t: TeamData = r[1]
	s.persons.erase(t.leader_id); t.leader_id = -1
	var ok: bool = EventSystem.new().on_leader_death(s, t)
	assert(not ok, "無繼承人應回 false")
```

`_initialize()` 加：

```gdscript
	_test_succession_npc_best_named()
	_test_succession_low_named_no_threshold()
	_test_succession_anon_fallback()
	_test_succession_anon_exhausted()
```

- [ ] **Step 2: 跑 harness 驗證失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: 在 `繼承：NPC 晉升 best named` 處 assert 失敗中止（舊 on_leader_death 掃 state.persons + 有 0.3 門檻 → 行為不符）。

- [ ] **Step 3: 重寫 on_leader_death（NPC 段）+ 刪 const**

刪 `scripts/simulation/event_system.gd:3` 的 `const COMMAND_SKILL_MIN: float = 0.3`。

把 `on_leader_death`（:26-55 整個函數）換成（**player 分支本 task 暫留 TODO，Task 3 補**）：

```gdscript
# 由外部呼叫（Leader 死亡/失效後繼承）。繼承邏輯單一 owner。
func on_leader_death(state: WorldState, team: TeamData) -> bool:
	# TODO(Task3): player team → _handle_player_succession
	# NPC: best named 無門檻晉升
	var best_successor: PersonData = null
	var best_command: float = -1.0
	for pid in team.named_members:
		var p: PersonData = state.persons.get(pid)
		if p == null:
			continue
		var cmd: float = float(p.skills.get("統領", 0.0))
		if cmd > best_command:
			best_command = cmd
			best_successor = p
	if best_successor != null:
		team.leader_id = best_successor.id
		best_successor.role = "leader"
		team.named_members.erase(best_successor.id)
		print("[Succession] Team %d 新 leader: P%d（統領=%.2f）" % [
			team.team_id, best_successor.id, best_command])
		PopulationSystem.new().check_overflow_for_team(state, team.team_id)
		return true
	# 無 named → 從 anon 晉升
	var promoted := PersonGenerator.generate_for_team(state, team, "member")
	if promoted != null:
		team.leader_id = promoted.id
		promoted.role = "leader"
		print("[Succession] Team %d 從匿名晉升新領袖 P%d（統領=%.2f）" % [
			team.team_id, promoted.id, float(promoted.skills.get("統領", 0.0))])
		PopulationSystem.new().check_overflow_for_team(state, team.team_id)
		return true
	print("[Succession] Team %d 無繼承人，崩潰中（無匿名人口）" % team.team_id)
	return false
```

- [ ] **Step 4: 跑 harness 驗證通過**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: 四個繼承測試印出 OK，整輪到 `=== DONE ===`，無新 assert 失敗。

- [ ] **Step 5: 加弱 leader overflow 回饋測試**

加到 `scripts/debug/headless_test.gd`：

```gdscript
func _test_succession_weak_leader_overflow() -> void:
	print("--- 繼承：弱 leader → pop_cap 溢出回饋 ---")
	# 低統領 named 繼任 → pop_cap_from_leadership 低 → check_overflow 應觸發（pop > cap）
	var r := _mk_succession_team(5, [0.05], 30)  # 1 弱 named + 30 anon，pop=32
	var s: WorldState = r[0]; var t: TeamData = r[1]
	# 加一格 tile 供 overflow 流亡隊落腳
	var tile := HexTileData.new(); tile.tile_id = 4*1000+4; tile.tile_pos = Vector2i(4,4)
	tile.terrain = "plains"; s.world.tiles[tile.tile_id] = tile
	s.persons.erase(t.leader_id); t.leader_id = -1
	var cap: int = TeamData.pop_cap_from_leadership(0.05)
	var teams_before: int = s.teams.size()
	var ok: bool = EventSystem.new().on_leader_death(s, t)
	assert(ok, "弱 named 應繼承")
	# pop(32) > cap(弱統領) → overflow → dispatch 或 _create_overflow_team
	assert(t.population <= cap or s.teams.size() > teams_before,
		"溢出應減員或生流亡隊（cap=%d pop=%d teams=%d→%d）" % [cap, t.population, teams_before, s.teams.size()])
	print("weak leader overflow OK")
```

`_initialize()` 加 `_test_succession_weak_leader_overflow()`。

- [ ] **Step 6: 跑 harness 驗證通過**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `weak leader overflow OK`，整輪 `=== DONE ===`。

> 註：若 `check_overflow_for_team` 對無 advisor 的隊走 `_create_overflow_team` 需 `PersonGenerator`，已在同 path 用過，無額外依賴。若該測試因 cap 公式使 pop 不溢出，調高 anon_n 至確定 > cap。

- [ ] **Step 7: Commit**

```bash
git add scripts/simulation/event_system.gd scripts/debug/headless_test.gd
git commit -m "feat(succession): on_leader_death NPC 路徑無門檻+named掃描+anon fallback+overflow"
```

---

### Task 3: `on_leader_death` player 分支內聚 + 冪等

**Files:**
- Modify: `scripts/simulation/event_system.gd`（補 player 分支 + 私有 `_handle_player_succession`）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Consumes: `WorldState.get_player_team_id()`（Task 1）；`on_leader_death`（Task 2）。
- Produces: `on_leader_death` 開頭判 player team → `_handle_player_succession(state, team) -> bool`：已有本 team choose_heir pending → 直接 true（冪等不重設）；named 空 → `game_over` + 回 false；否則設 `state.player_forced_event = {action:"choose_heir", team_id, candidates}` + `player_forced_event_id` → 回 true。

- [ ] **Step 1: 寫失敗測試**

加到 `scripts/debug/headless_test.gd`：

```gdscript
func _test_succession_player_choose_heir() -> void:
	print("--- 繼承：player team → choose_heir forced ---")
	var r := _mk_succession_team(6, [0.2, 0.4], 0)
	var s: WorldState = r[0]; var t: TeamData = r[1]
	s.player_id = t.leader_id          # 玩家是 leader
	s.persons.erase(t.leader_id); t.leader_id = -1   # 玩家 leader 死
	var ok: bool = EventSystem.new().on_leader_death(s, t)
	assert(ok, "player 有 named → pending(true)")
	assert(s.player_forced_event.get("action", "") == "choose_heir", "應發 choose_heir forced")
	assert(s.player_forced_event.get("team_id", -1) == 6, "forced team_id=6")
	assert(s.player_forced_event.get("candidates", []).size() == 2, "2 候選")
	# 冪等：再呼一次不應改變/重設
	var fe_id_before = s.player_forced_event_id
	var ok2: bool = EventSystem.new().on_leader_death(s, t)
	assert(ok2 and s.player_forced_event_id == fe_id_before, "冪等：pending 時不重設 forced")

func _test_succession_player_extinct() -> void:
	print("--- 繼承：player named 空 → game_over ---")
	var r := _mk_succession_team(8, [], 5)   # player 隊 0 named（只 anon）
	var s: WorldState = r[0]; var t: TeamData = r[1]
	s.player_id = t.leader_id
	s.persons.erase(t.leader_id); t.leader_id = -1
	var ok: bool = EventSystem.new().on_leader_death(s, t)
	assert(not ok, "player 絕後 → false")
	assert(s.game_over, "應設 game_over")
```

`_initialize()` 加兩行 `_test_succession_player_choose_heir()` / `_test_succession_player_extinct()`。

- [ ] **Step 2: 跑 harness 驗證失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: 在 `player team → choose_heir` 處失敗（現 on_leader_death 對 player 隊走 NPC 晉升，不發 forced）。

- [ ] **Step 3: 補 player 分支 + helper**

`scripts/simulation/event_system.gd` 的 `on_leader_death` 把 Task 2 的 `# TODO(Task3)` 那行換成：

```gdscript
	# player team → choose_heir forced（凍世界）／絕後 game_over
	if state.player_id != -1 and team.team_id == state.get_player_team_id():
		return _handle_player_succession(state, team)
```

並在 event_system.gd 加私有 helper：

```gdscript
func _handle_player_succession(state: WorldState, team: TeamData) -> bool:
	# 冪等：已有本 team 的 choose_heir pending → 不重設
	if state.player_forced_event is Dictionary \
			and state.player_forced_event.get("action", "") == "choose_heir" \
			and int(state.player_forced_event.get("team_id", -1)) == team.team_id:
		return true
	team.leader_id = -1
	if team.named_members.is_empty():
		state.game_over = true
		state.game_over_reason = "玩家絕後（Team%d 無繼承人）" % team.team_id
		print("[GameOver] %s" % state.game_over_reason)
		return false
	state.player_forced_event = {
		"action": "choose_heir",
		"team_id": team.team_id,
		"candidates": team.named_members.duplicate(),
	}
	state.player_forced_event_id = "heir_%d" % state.world.current_tick
	print("[Heir] 玩家 leader 死亡，等待選繼承人 (Team%d, %d 候選)" % [
		team.team_id, team.named_members.size()])
	return true
```

- [ ] **Step 4: 跑 harness 驗證通過**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: 兩個 player 測試 OK，整輪 `=== DONE ===`，既有 choose_heir/forced 測試（`_test_recruit_tutorial`、`_test_forced_*` 等）不破。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/event_system.gd scripts/debug/headless_test.gd
git commit -m "feat(succession): on_leader_death 內聚 player choose_heir 分支+冪等"
```

---

### Task 4: faction_ai 偵測網收斂 + 刪舊繼承碼

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd:502-503`（偵測點改呼 on_leader_death、拿掉 named gate）
- Modify: `scripts/simulation/faction_ai_system.gd`（刪 `_promote_successor` :1066-1093、刪 `_handle_player_leader_death` :1050-1064）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Consumes: `EventSystem.on_leader_death`（Task 2/3）。
- Produces: faction_ai 主迴圈每 tick 對 `leader_id==-1` 的隊呼 `on_leader_death`（唯一偵測點，捕捉 encounter 裸置/饑荒/任何 leaderless）。

- [ ] **Step 1: 確認無其他 caller**

Run（grep 確認刪前無漏）：

```bash
grep -rn "_promote_successor\|_handle_player_leader_death" scripts/
```

Expected: 只剩 faction_ai 內部引用（:503 呼 _promote_successor、_promote_successor:1070 呼 _handle_player_leader_death）。若有 faction_ai 外 caller → 停，回報（spec 假設不成立）。

- [ ] **Step 2: 寫失敗測試**

加到 `scripts/debug/headless_test.gd`：

```gdscript
func _test_succession_detection_net() -> void:
	print("--- 繼承：faction_ai 安全網捕捉 leaderless（named 全滅）---")
	# 複現 E-1：encounter 打到 named 全滅但 anon 在 → leader_id=-1, named 空
	var r := _mk_succession_team(9, [], 6)   # 0 named, 6 anon
	var s: WorldState = r[0]; var t: TeamData = r[1]
	var tile := HexTileData.new(); tile.tile_id = 4*1000+4; tile.tile_pos = Vector2i(4,4)
	tile.terrain = "plains"; s.world.tiles[tile.tile_id] = tile
	s.persons.erase(t.leader_id); t.leader_id = -1   # encounter 裸置後狀態
	var fai := FactionAISystem.new()
	# 直呼偵測點等價邏輯：主迴圈會對 leader_id==-1 呼 on_leader_death
	if t.leader_id == -1:
		EventSystem.new().on_leader_death(s, t)
	assert(t.leader_id != -1, "安全網應從 anon 晉升新 leader，非永久 leaderless blob")

func _test_succession_player_net_extinct() -> void:
	print("--- 繼承：player leaderless + named 空 → 安全網 game_over（修 latent）---")
	var r := _mk_succession_team(11, [], 4)
	var s: WorldState = r[0]; var t: TeamData = r[1]
	s.player_id = t.leader_id
	s.persons.erase(t.leader_id); t.leader_id = -1
	if t.leader_id == -1:
		EventSystem.new().on_leader_death(s, t)
	assert(s.game_over, "player 絕後經安全網應 game_over（原 gate 漏此 case）")
```

`_initialize()` 加兩行註冊。

- [ ] **Step 3: 跑 harness 驗證（這兩測現應已過）**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: 兩測 OK（因 Task 2/3 已使 on_leader_death 正確）。本 task 重點是改 faction_ai 真正接上安全網 + 刪舊碼，下步驗整合不破。

- [ ] **Step 4: 改偵測點 + 刪舊碼**

`scripts/simulation/faction_ai_system.gd` 把 :502-503：

```gdscript
		# S11: leader 死亡自動繼承（無 leader 但有 named members）
		if team.leader_id == -1 and not team.named_members.is_empty():
			_promote_successor(state, team)
```

換成：

```gdscript
		# leader 失效 → 繼承單一 owner（含 anon fallback / player choose_heir）。唯一偵測點。
		if team.leader_id == -1:
			EventSystem.new().on_leader_death(state, team)
```

刪除整個 `_promote_successor` 函數（:1066-1093）與 `_handle_player_leader_death` 函數（:1050-1064）。

- [ ] **Step 5: 跑 harness + 1000 Tick 整合驗證**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: 全測試 `=== DONE ===`、coin_eq=0、InvariantAudit 0、1000 Tick 無崩潰。特別確認既有 leader-death/choose_heir 相關測試（recruit_tutorial、forced_*、sim 主迴圈）全綠。

- [ ] **Step 6: Commit**

```bash
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "refactor(succession): faction_ai 偵測網改呼 on_leader_death + 刪 _promote_successor/_handle_player_leader_death"
```

---

### Task 5: invariant 落檔 + known_issues 更新 + 全回歸

**Files:**
- Modify: `docs/invariants.md`（加繼承單一 owner 條，所有權圖第一條）
- Modify: `docs/known_issues.md`（E-1 繼承分叉標已修）
- 無 code 改動（純 doc + 回歸閘）

- [ ] **Step 1: 加 invariant**

於 `docs/invariants.md` 適當區段（所有權/單一源類）加：

```markdown
### Leader 繼承單一 owner
- **繼承邏輯單一 owner = `EventSystem.on_leader_death(state, team) -> bool`。** 偵測單一點 = `faction_ai` 每-tick 安全網（`leader_id==-1` → 呼 owner）；`npc_combat._kill_named_npc` 戰中即時呼為效能捷徑（非另一 owner）。
- 禁止在 `on_leader_death` 外自行決定繼承人 / promote。裸置 `leader_id = -1` 僅允許作 transient（須由安全網次 tick 補位）。
- 分派：player → forced `choose_heir`（named 空則 `game_over`）；NPC → best named 無門檻晉升 → 無 named 則 anon 晉升 → 皆無回 `false` 滅團。晉升成功後呼 `PopulationSystem.check_overflow_for_team`（弱 leader → pop_cap 溢出回饋）。
- 回傳：`true`=已處理（含 player pending）；`false`=無繼承人 → caller 滅團/faction 解散。
```

- [ ] **Step 2: 更新 known_issues**

於 `docs/known_issues.md` E-1 段「繼承分叉」相關處標註：繼承分叉已由 spec `2026-06-19-leader-succession-single-source-design.md` + plan 修（單一 owner + 安全網 gate 拿掉 + 無門檻 + overflow 回饋）；結構免疫（殲滅模型）仍待藍圖。

- [ ] **Step 3: 全回歸閘**

Run（兩條）：

```
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```

Expected: `=== DONE ===`、coin_eq=0、InvariantAudit 0 違反、1000 Tick 無崩潰。

- [ ] **Step 4: Commit**

```bash
git add docs/invariants.md docs/known_issues.md
git commit -m "docs(succession): 繼承單一 owner invariant + known_issues E-1 繼承分叉標已修"
```

---

## Self-Review 註記

- **spec 覆蓋**：roster 掃描修正(Task2)、無門檻(Task2)、anon fallback(Task2)、overflow(Task2)、player 分支內聚+冪等(Task3)、偵測網 gate 拿掉+刪舊碼(Task4)、get_player_team_id 單一源(Task1)、invariant(Task5)、latent game_over 修(Task4 測試覆蓋)——皆有對應 task。
- **encounter 不碰**：spec 已論證（死者 persons 未 erase + 戰中 forced 時序風險）→ 靠安全網。本 plan 無 encounter task，符合。
- **型別一致**：`on_leader_death(state, team)->bool`、`get_player_team_id()->int`、`_handle_player_succession(state,team)->bool`、`check_overflow_for_team(state, tid)` 全 task 一致。
- **殘留待確認（執行時）**：Task2 Step6 註記的 overflow cap 公式臨界——若測試未溢出，調 anon_n。Task4 Step1 grep 若發現 faction_ai 外 caller → 停報。
