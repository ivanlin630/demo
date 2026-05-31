# Player Commands & Interaction Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 實裝 PlayerCommandSystem 後端接口，讓玩家能主動發起互動（貿易/外交/攻擊/勒索）並回應 NPC 強制非戰互動（外交提案/勒索）。

**Architecture:** WorldState 增加兩個 pending 欄位（`player_pending_targets`、`player_forced_event`）。InteractionSystem 的玩家分支改為三路非阻塞寫入，新增兩個公開 direct 函式供 PlayerCommandSystem 呼叫。PlayerCommandSystem 是新建的薄包裝層，不含 AI 決策邏輯。SimRunner 負責超時清除與移動時清除 pending。

**Tech Stack:** Godot 4.2.2 GDScript，無外部依賴，所有功能在現有 class 架構內實裝。

---

## 檔案清單

| 檔案 | 動作 |
|---|---|
| `scripts/data/world_state.gd` | 新增 `player_pending_targets`、`player_forced_event` |
| `scripts/simulation/interaction_system.gd` | 替換玩家分支；新增 `resolve_trade_direct()`、`resolve_extortion_direct()` |
| `scripts/simulation/player_command_system.gd` | **新建** |
| `scripts/simulation/sim_runner.gd` | 新增 `_player_cmd` member；forced_event 超時清除；移動時清除 pending |
| `scripts/debug/headless_test.gd` | 新增 PlayerCommandSystem 測試區段 |

---

## Task 1: WorldState — 新增 player pending 欄位

**Files:**
- Modify: `scripts/data/world_state.gd`

### 背景

`WorldState` 是所有系統共享的狀態物件。玩家互動使用兩個新欄位：
- `player_pending_targets` — 同格、無敵意 NPC 的 team_id 清單，玩家可選擇要不要互動
- `player_forced_event` — NPC 強制非戰互動（外交提案/勒索），空 Dict 代表無待處理事件

- [ ] **Step 1: 在 world_state.gd 加欄位**

在 `var player_hostile_teams: Array = []` 那行之後加兩行：

```gdscript
var player_pending_targets: Array = []
# Array[int] — 同格、無敵意 NPC team_ids，等玩家選擇互動類型或忽略
# 玩家 team 移動到新格子時清除；玩家執行任意行動後對應 id 移除

var player_forced_event: Dictionary = {}
# NPC 強制非戰互動，格式：
# { "from_id": int, "action": String, ... }
# action = "diplomacy" → { ..., "proposal": String }  非阻塞，下一 tick 未回應自動拒絕
# action = "extort"    → { ..., "from_id": int }       非阻塞，下一 tick 未回應自動拒絕
# 空 Dict = 無待處理強制事件
```

- [ ] **Step 2: 跑 baseline 確認無錯誤**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 3: Commit**

```
git add scripts/data/world_state.gd
git commit -m "feat(data): add player_pending_targets and player_forced_event to WorldState"
```

---

## Task 2: InteractionSystem — 新增 resolve_trade_direct 和 resolve_extortion_direct

**Files:**
- Modify: `scripts/simulation/interaction_system.gd`

### 背景

這兩個函式是公開包裝，供 PlayerCommandSystem 呼叫，繞過 `current_task` 檢查，直接執行貿易或勒索的資源轉移邏輯。它們複用現有的 `_resolve_trade()` 和 `_resolve_extortion()`。

`_resolve_trade(state, seller, buyer)` — seller 有貨賣，buyer 用 coin 買，成功後設 seller.current_task = idle（對 NPC 賣方是預期行為）。

`_resolve_extortion(state, atk_id, def_id)` — atk 從 def 取走 food/goods/coin 的 `TRIBUTE_RATE` 比例。

- [ ] **Step 1: 在 interaction_system.gd 末尾（`_calc_armed` 函式之後）加兩個函式**

在檔案最後一行（`}` 後面）加：

```gdscript
# ──────── 玩家直接呼叫接口（繞過 current_task 檢查）────────

# 供 PlayerCommandSystem 呼叫：不需要 seller 有 TASK_TRADE
# 先嘗試 target 賣 player 買；若無成交再試 player 賣 target 買
# 返回 { "ok": bool, "msg": String }
func resolve_trade_direct(state: WorldState, initiator_id: int, target_id: int) -> Dictionary:
	var pt: TeamData  = state.teams.get(initiator_id)
	var tgt: TeamData = state.teams.get(target_id)
	if pt == null or tgt == null:
		return { "ok": false, "msg": "隊伍不存在" }
	# 嘗試 target 賣、initiator 買
	var tgt_coin_before: float = float(tgt.resources.get("coin", 0.0))
	_resolve_trade(state, tgt, pt)
	if float(tgt.resources.get("coin", 0.0)) != tgt_coin_before:
		return { "ok": true, "msg": "貿易成功" }
	# 若無成交，嘗試 initiator 賣、target 買
	var pt_coin_before: float = float(pt.resources.get("coin", 0.0))
	_resolve_trade(state, pt, tgt)
	if float(pt.resources.get("coin", 0.0)) != pt_coin_before:
		return { "ok": true, "msg": "貿易成功" }
	return { "ok": false, "msg": "無可交易資源" }

# 供 PlayerCommandSystem 呼叫：不需要 aggressor 有 TASK_LOOT
# 直接執行勒索資源轉移（food/goods/coin × TRIBUTE_RATE）
# 返回 { "ok": bool, "msg": String }
func resolve_extortion_direct(state: WorldState, aggressor_id: int, target_id: int) -> Dictionary:
	var tgt: TeamData = state.teams.get(target_id)
	if tgt == null:
		return { "ok": false, "msg": "目標不存在" }
	_resolve_extortion(state, aggressor_id, target_id)
	return { "ok": true, "msg": "勒索完成" }
```

- [ ] **Step 2: 跑測試**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`=== DONE ===`，無新增 `SCRIPT ERROR`。

- [ ] **Step 3: Commit**

```
git add scripts/simulation/interaction_system.gd
git commit -m "feat(interaction): add resolve_trade_direct and resolve_extortion_direct"
```

---

## Task 3: InteractionSystem — 替換玩家分支邏輯

**Files:**
- Modify: `scripts/simulation/interaction_system.gd`

### 背景

現有玩家分支（`_try_interact` 中 `if state.player_id != -1:` 區塊）對所有非同陣營遭遇一律觸發 EncounterSystem。新設計分三路：

| 路徑 | 條件 | 行為 |
|---|---|---|
| 路徑 1 | NPC `combat_target` = 玩家 | 觸發 EncounterSystem（維持現有） |
| 路徑 2 | NPC `current_task` = TASK_DIPLOMACY | 寫入 `player_forced_event` (diplomacy) |
| 路徑 3 | NPC `current_task` = TASK_LOOT | 寫入 `player_forced_event` (extort) |
| 路徑 4 | 其他 | 寫入 `player_pending_targets` |

同陣營（same_faction）：不 return，讓後面 NPC-NPC 邏輯處理（徵收/合併等）。

**現有要替換的程式碼**（interaction_system.gd 約 168–188 行）：

```gdscript
	if state.player_id != -1:
		var player_person: PersonData = state.persons.get(state.player_id)
		if player_person != null:
			var player_tid: int = player_person.team_id
			if (id_a == player_tid or id_b == player_tid):
				var other_tid: int = id_b if id_a == player_tid else id_a
				var player_team: TeamData = state.teams.get(player_tid)
				var other_team: TeamData  = state.teams.get(other_tid)
				var same_faction: bool = player_team != null and other_team != null \
					and player_team.faction_id != -1 \
					and player_team.faction_id == other_team.faction_id
				if not same_faction:
					state.encounter_attacker_id = id_a
					state.encounter_defender_id = id_b
					state.encounter_active = true
					# Mark attacker as hostile to player if applicable
					var attacker_id: int = state.encounter_attacker_id
					if player_tid >= 0 and attacker_id != player_tid and not state.player_hostile_teams.has(attacker_id):
						state.player_hostile_teams.append(attacker_id)
					print("[Encounter] 玩家遭遇戰觸發 Team%d vs Team%d" % [id_a, id_b])
					return
```

- [ ] **Step 1: 替換玩家分支**

將上面整個區塊（`if state.player_id != -1:` 到最後的 `return`，共 21 行）替換為：

```gdscript
	if state.player_id != -1:
		var player_person: PersonData = state.persons.get(state.player_id)
		if player_person != null:
			var player_team_id: int = player_person.team_id
			var is_a_player: bool = (id_a == player_team_id)
			var is_b_player: bool = (id_b == player_team_id)
			if is_a_player or is_b_player:
				var npc_id: int      = id_b if is_a_player else id_a
				var npc: TeamData    = state.teams.get(npc_id)
				var pt: TeamData     = state.teams.get(player_team_id)
				if npc == null or pt == null:
					return

				# 路徑 1：NPC 攻擊玩家 → 直接 EncounterSystem（維持原有邏輯）
				if npc.combat_target == player_team_id:
					state.encounter_attacker_id = npc_id
					state.encounter_defender_id = player_team_id
					state.encounter_active      = true
					if not state.player_hostile_teams.has(npc_id):
						state.player_hostile_teams.append(npc_id)
					print("[Encounter] 玩家遭遇戰觸發 Team%d vs Team%d" % [npc_id, player_team_id])
					return

				# 同陣營：不 return，讓後面 NPC-NPC 邏輯處理（徵收/合併等）
				var same_faction: bool = pt.faction_id != -1 \
					and pt.faction_id == npc.faction_id
				if same_faction:
					pass   # 繼續執行到 NPC-NPC 邏輯
				# 路徑 2：NPC 外交提案
				elif npc.current_task == TeamData.TASK_DIPLOMACY:
					if state.player_forced_event.is_empty():   # 不覆蓋現有強制事件
						state.player_forced_event = {
							"from_id":  npc_id,
							"action":   "diplomacy",
							"proposal": npc.order_task if npc.order_task != "" else "alliance"
						}
					return
				# 路徑 3：NPC 勒索
				elif npc.current_task == TeamData.TASK_LOOT:
					if state.player_forced_event.is_empty():
						state.player_forced_event = { "from_id": npc_id, "action": "extort" }
					return
				# 路徑 4：NPC 無敵意 → 玩家可主動選擇互動
				else:
					if not state.player_pending_targets.has(npc_id):
						state.player_pending_targets.append(npc_id)
					return
```

- [ ] **Step 2: 跑測試**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`=== DONE ===`，無 `SCRIPT ERROR`。遭遇戰相關 print 仍出現。

- [ ] **Step 3: Commit**

```
git add scripts/simulation/interaction_system.gd
git commit -m "feat(interaction): replace player branch with 3-path non-blocking logic"
```

---

## Task 4: PlayerCommandSystem — 新建

**Files:**
- Create: `scripts/simulation/player_command_system.gd`

### 背景

PlayerCommandSystem 是玩家互動的薄包裝層。它不做 AI 決策，只是：
1. 查詢對某 target 可用的行動清單（`get_available_actions`）
2. 執行玩家選擇的行動（`execute_action`）
3. 查詢強制事件的回應選項（`get_forced_response_options`）
4. 執行玩家對強制事件的回應（`respond_to_forced`）
5. 移動時清除 pending（`clear_pending_targets`）

`recruit` action 是接口預留（STUB），實際邏輯後續再加。

`handle_diplomacy_message(state, self_team, sender_team, action)` 的 action 字串：
- "propose_alliance" — 同盟提案
- "demand_tribute" — 納貢要求

- [ ] **Step 1: 建立新檔案**

建立 `scripts/simulation/player_command_system.gd`，內容：

```gdscript
# scripts/simulation/player_command_system.gd
class_name PlayerCommandSystem

var _interaction: InteractionSystem = InteractionSystem.new()
var _diplomatic:  DiplomaticAiSystem = DiplomaticAiSystem.new()

# ── 主動互動 ────────────────────────────────────────────────

# 查詢對 target_id 可用的行動（已過濾條件）
# 返回 Array[String]，子集合自：
#   "ignore"           → 永遠可選
#   "attack"           → 永遠可選
#   "trade"            → target 有 coin OR 玩家有 coin
#   "propose_alliance" → target 非同勢力
#   "demand_tribute"   → 玩家 population > target.population × 1.5
#   "extort"           → 玩家 readiness >= 0.7
#   "recruit"          → 永遠可選（STUB — 招募邏輯尚未實裝）
func get_available_actions(state: WorldState, target_id: int) -> Array[String]:
	var actions: Array[String] = ["ignore", "attack"]
	var pt: TeamData  = _get_player_team(state)
	var tgt: TeamData = state.teams.get(target_id)
	if pt == null or tgt == null:
		return actions
	if _can_trade(state, pt, tgt):
		actions.append("trade")
	if tgt.faction_id != pt.faction_id:
		actions.append("propose_alliance")
	if pt.population > int(tgt.population * 1.5):
		actions.append("demand_tribute")
	if pt.readiness >= 0.7:
		actions.append("extort")
	actions.append("recruit")   # STUB
	return actions

# 執行玩家主動行動
# 返回 { "ok": bool, "msg": String }
func execute_action(state: WorldState, target_id: int, action: String) -> Dictionary:
	var pt: TeamData = _get_player_team(state)
	var pt_id: int   = _get_player_team_id(state)
	if pt == null:
		return { "ok": false, "msg": "找不到玩家 team" }
	match action:
		"trade":
			var result := _interaction.resolve_trade_direct(state, pt_id, target_id)
			state.player_pending_targets.erase(target_id)
			return result
		"propose_alliance":
			var tgt: TeamData = state.teams.get(target_id)
			if tgt == null:
				return { "ok": false, "msg": "目標不存在" }
			var resp: String = _diplomatic.handle_diplomacy_message(
				state, tgt, pt, "propose_alliance")
			state.player_pending_targets.erase(target_id)
			return { "ok": resp == "accept", "msg": "外交結果: %s" % resp }
		"demand_tribute":
			var tgt: TeamData = state.teams.get(target_id)
			if tgt == null:
				return { "ok": false, "msg": "目標不存在" }
			var resp: String = _diplomatic.handle_diplomacy_message(
				state, tgt, pt, "demand_tribute")
			state.player_pending_targets.erase(target_id)
			return { "ok": resp == "accept", "msg": "納貢結果: %s" % resp }
		"attack":
			var tgt: TeamData = state.teams.get(target_id)
			if tgt == null:
				return { "ok": false, "msg": "目標不存在" }
			state.encounter_attacker_id = pt_id
			state.encounter_defender_id = target_id
			state.encounter_active      = true
			if not state.player_hostile_teams.has(target_id):
				state.player_hostile_teams.append(target_id)
			state.player_pending_targets.erase(target_id)
			print("[PlayerCmd] 玩家發起攻擊 Team%d → Team%d" % [pt_id, target_id])
			return { "ok": true, "msg": "發起攻擊" }
		"extort":
			var result := _interaction.resolve_extortion_direct(state, pt_id, target_id)
			state.player_pending_targets.erase(target_id)
			return result
		"recruit":
			# STUB — 招募邏輯尚未實裝（說服/付費/目標成員選擇）
			state.player_pending_targets.erase(target_id)
			return { "ok": false, "msg": "招募功能尚未實裝" }
		"ignore":
			state.player_pending_targets.erase(target_id)
			return { "ok": true, "msg": "忽略" }
	return { "ok": false, "msg": "未知行動: %s" % action }

# ── 被動回應（NPC 強制非戰互動）────────────────────────────

# 查詢 forced_event 的回應選項
# "diplomacy" → ["accept", "refuse"]
# "extort"    → ["pay", "refuse"]
func get_forced_response_options(state: WorldState) -> Array[String]:
	match state.player_forced_event.get("action", ""):
		"diplomacy": return ["accept", "refuse"]
		"extort":    return ["pay", "refuse"]
	return []

# 回應強制互動，清除 forced_event
# 返回 { "ok": bool, "msg": String }
func respond_to_forced(state: WorldState, response: String) -> Dictionary:
	var fe: Dictionary = state.player_forced_event
	if fe.is_empty():
		return { "ok": false, "msg": "無待處理強制事件" }
	var result: Dictionary
	match fe.get("action", ""):
		"diplomacy":
			if response == "accept":
				result = _accept_diplomacy(state,
					fe.get("from_id", -1), fe.get("proposal", "alliance"))
			else:
				result = { "ok": true, "msg": "拒絕外交提案" }
		"extort":
			if response == "pay":
				result = _pay_extortion(state, fe.get("from_id", -1))
			else:
				result = { "ok": true, "msg": "拒絕勒索" }
		_:
			result = { "ok": false, "msg": "未知強制事件類型" }
	state.player_forced_event = {}
	return result

# ── 清除 pending ─────────────────────────────────────────────

# 玩家 team 格子改變時呼叫（SimRunner 負責呼叫）
# player_forced_event 不清除（NPC 外交/勒索不因移動取消）
func clear_pending_targets(state: WorldState) -> void:
	state.player_pending_targets.clear()

# ── 內部 helper ──────────────────────────────────────────────

func _get_player_team(state: WorldState) -> TeamData:
	var p: PersonData = state.persons.get(state.player_id)
	if p == null:
		return null
	return state.teams.get(p.team_id)

func _get_player_team_id(state: WorldState) -> int:
	var p: PersonData = state.persons.get(state.player_id)
	return p.team_id if p != null else -1

func _can_trade(state: WorldState, pt: TeamData, tgt: TeamData) -> bool:
	# 雙方任一有 coin 即可嘗試貿易（細節由 resolve_trade_direct 判定）
	return float(pt.resources.get("coin", 0)) > 0.0 \
		or float(tgt.resources.get("coin", 0)) > 0.0

func _accept_diplomacy(state: WorldState, from_id: int, proposal: String) -> Dictionary:
	# STUB — 接受 NPC 外交提案，具體邏輯留後續實裝
	# 完整實裝應依 proposal 類型呼叫 DiplomaticAiSystem 對應方法
	var pt: TeamData  = _get_player_team(state)
	var npc: TeamData = state.teams.get(from_id)
	if pt == null or npc == null:
		return { "ok": false, "msg": "隊伍不存在" }
	print("[PlayerCmd] 玩家接受 Team%d 的 %s 提案（STUB）" % [from_id, proposal])
	return { "ok": true, "msg": "接受：%s" % proposal }

func _pay_extortion(state: WorldState, from_id: int) -> Dictionary:
	# 轉移資源給 from_id（金額由 _resolve_extortion 計算）
	var pt_id: int = _get_player_team_id(state)
	if pt_id == -1:
		return { "ok": false, "msg": "找不到玩家 team" }
	_interaction.resolve_extortion_direct(state, from_id, pt_id)
	return { "ok": true, "msg": "支付勒索" }
```

- [ ] **Step 2: import 確認（新建 class_name 必須重新 import）**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

- [ ] **Step 3: 跑測試**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 4: Commit**

```
git add scripts/simulation/player_command_system.gd
git commit -m "feat(simulation): add PlayerCommandSystem"
```

---

## Task 5: SimRunner — _player_cmd member、forced_event 超時、移動清除

**Files:**
- Modify: `scripts/simulation/sim_runner.gd`

### 背景

SimRunner 需要做三件事：
1. 持有 `PlayerCommandSystem` 實例（供外部 UI 直接取用）
2. 在近區每次執行開始時，清除上一 tick 殘留的 `player_forced_event`（超時自動拒絕）
3. 在近區 `_step2_move_teams` 後，若玩家格子改變則清除 `player_pending_targets`

**近區 tick block 結構（修改後）：**

```
if state.world.current_tick % WorldState.TICKS_PER_HOUR == 0:
    # [新增] 1. forced_event 超時清除
    # 2. _step1b_update_vision
    # ...
    # [新增] 3. 取玩家舊位置
    # 4. _step2_move_teams → arrived_near
    # [新增] 5. 玩家位置若改變 → clear_pending_targets
    # 6. _step3_propagate_messages
    # ...
```

- [ ] **Step 1: 在 sim_runner.gd 的 member 宣告區加入 _player_cmd**

找到 `var _encounter_system: EncounterSystem` 那行，在其後加：

```gdscript
var _player_cmd: PlayerCommandSystem
```

- [ ] **Step 2: 在 _init() 加初始化**

找到 `_encounter_system = EncounterSystem.new()` 那行，在其後加：

```gdscript
	_player_cmd = PlayerCommandSystem.new()
```

- [ ] **Step 3: 在近區 tick block 開頭加 forced_event 超時清除**

找到近區 `if state.world.current_tick % WorldState.TICKS_PER_HOUR == 0:` 區塊，在 `_step1b_update_vision(state, near_teams, time_vision_mult)` 之前加：

```gdscript
		# player_forced_event 超時自動拒絕：上一 hour-tick 寫入，本 tick 未回應即清除
		if not state.player_forced_event.is_empty():
			print("[PlayerCmd] forced_event 超時自動拒絕: %s" % str(state.player_forced_event))
			state.player_forced_event = {}
```

- [ ] **Step 4: 在近區 _step2_move_teams 前後加玩家移動偵測**

找到近區 `var arrived_near := _step2_move_teams(state, near_teams, time_speed_mult)` 那行，在其前後改為：

```gdscript
		var _player_old_pos: Vector2i = _get_player_tile_pos(state)
		var arrived_near := _step2_move_teams(state, near_teams, time_speed_mult)
		if _get_player_tile_pos(state) != _player_old_pos:
			_player_cmd.clear_pending_targets(state)
```

- [ ] **Step 5: 在 sim_runner.gd 末尾加 _get_player_tile_pos helper**

在檔案最後一個函式之後加：

```gdscript
func _get_player_tile_pos(state: WorldState) -> Vector2i:
	var p: PersonData = state.persons.get(state.player_id)
	if p == null:
		return Vector2i(-1, -1)
	var t: TeamData = state.teams.get(p.team_id)
	return t.tile_pos if t != null else Vector2i(-1, -1)
```

- [ ] **Step 6: 跑測試**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 7: Commit**

```
git add scripts/simulation/sim_runner.gd
git commit -m "feat(runner): add PlayerCommandSystem, forced_event timeout, pending clear on move"
```

---

## Task 6: headless_test — PlayerCommandSystem 驗證

**Files:**
- Modify: `scripts/debug/headless_test.gd`

### 背景

在現有 `print("=== DONE ===")` 之前插入 PlayerCommandSystem 測試區段。

測試前置條件：
- `state.player_id` 在 EncounterSystem 測試中已設為 0
- Person 0 的 team_id = 0（Team0）
- Team 0 tile_pos = Vector2i(4, 4)（預設初始位置）
- `state.player_pending_targets` 和 `state.player_forced_event` 是新欄位

測試涵蓋：
1. `get_available_actions` — ignore/attack 永遠存在
2. `execute_action("ignore")` — pending 清除
3. `get_forced_response_options` / `respond_to_forced("refuse")` — forced_event 清除
4. `respond_to_forced("pay")` — extort forced_event 正確執行
5. `get_available_actions` 條件篩選

- [ ] **Step 1: 找插入位置**

搜尋 `print("=== DONE ===")` 這行，在其正上方插入：

```gdscript
	# ────────── PlayerCommandSystem 測試 ──────────
	print("--- PlayerCommandSystem Tests ---")
	# 確保 encounter 狀態乾淨
	state.encounter_active = false
	state.encounter_units.clear()
	state.player_pending_targets.clear()
	state.player_forced_event = {}

	state.player_id = 0   # 安全設定，確保 player_id 有效
	var _cmd := PlayerCommandSystem.new()
	var _pt_id: int = state.persons.get(state.player_id).team_id   # = 0

	# ── 測試 1：get_available_actions（ignore/attack 永遠可選）──
	state.player_pending_targets.append(1)
	var _actions := _cmd.get_available_actions(state, 1)
	assert(_actions.has("ignore"), "ignore 永遠可選")
	assert(_actions.has("attack"), "attack 永遠可選")
	assert(_actions.has("recruit"), "recruit STUB 永遠可選")
	print("  [OK] get_available_actions: %s" % str(_actions))

	# ── 測試 2：execute_action("ignore") → pending 清除 ──
	var _r_ignore := _cmd.execute_action(state, 1, "ignore")
	assert(_r_ignore.get("ok"), "ignore 應成功")
	assert(not state.player_pending_targets.has(1), "ignore 後 pending 清除")
	print("  [OK] execute_action ignore: %s" % _r_ignore.get("msg", ""))

	# ── 測試 3：forced_event diplomacy → refuse ──
	state.player_forced_event = { "from_id": 2, "action": "diplomacy", "proposal": "alliance" }
	var _opts_d := _cmd.get_forced_response_options(state)
	assert(_opts_d.has("accept") and _opts_d.has("refuse"), "diplomacy 選項應有 accept/refuse")
	var _r_refuse := _cmd.respond_to_forced(state, "refuse")
	assert(_r_refuse.get("ok"), "refuse 應成功")
	assert(state.player_forced_event.is_empty(), "refuse 後 forced_event 清除")
	print("  [OK] forced diplomacy refuse: %s" % _r_refuse.get("msg", ""))

	# ── 測試 4：forced_event extort → pay ──
	# Team2 勒索 Team0（玩家）
	state.player_forced_event = { "from_id": 2, "action": "extort" }
	var _r_pay := _cmd.respond_to_forced(state, "pay")
	assert(_r_pay.get("ok"), "pay 應成功")
	assert(state.player_forced_event.is_empty(), "pay 後 forced_event 清除")
	print("  [OK] forced extort pay: %s" % _r_pay.get("msg", ""))

	# ── 測試 5：respond_to_forced 空事件 ──
	var _r_empty := _cmd.respond_to_forced(state, "refuse")
	assert(not _r_empty.get("ok"), "空 forced_event 應返回 ok=false")
	print("  [OK] empty forced_event handled correctly")

	# ── 測試 6：execute_action("attack") → encounter_active ──
	state.player_pending_targets.append(1)
	state.encounter_active = false
	var _r_atk := _cmd.execute_action(state, 1, "attack")
	assert(_r_atk.get("ok"), "attack 應成功")
	assert(state.encounter_active, "attack 後 encounter_active 應為 true")
	assert(state.encounter_attacker_id == _pt_id, "attacker 應為玩家")
	assert(state.encounter_defender_id == 1, "defender 應為 Team1")
	assert(not state.player_pending_targets.has(1), "attack 後 pending 清除")
	print("  [OK] execute_action attack: encounter triggered, attacker=%d defender=%d" % [
		state.encounter_attacker_id, state.encounter_defender_id])
	state.encounter_active = false
	state.encounter_units.clear()

	# ── 測試 7：clear_pending_targets ──
	state.player_pending_targets = [1, 2, 3]
	state.player_forced_event = { "from_id": 2, "action": "extort" }
	_cmd.clear_pending_targets(state)
	assert(state.player_pending_targets.is_empty(), "clear_pending_targets 應清空 pending")
	assert(not state.player_forced_event.is_empty(), "clear_pending_targets 不影響 forced_event")
	state.player_forced_event = {}
	print("  [OK] clear_pending_targets 只清 pending，保留 forced_event")

	print("--- PlayerCommandSystem Tests PASSED ---")
	# ────────────────────────────────────────────
```

- [ ] **Step 2: 跑測試**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期輸出包含：
```
--- PlayerCommandSystem Tests ---
  [OK] get_available_actions: [...]
  [OK] execute_action ignore: 忽略
  [OK] forced diplomacy refuse: 拒絕外交提案
  [OK] forced extort pay: 支付勒索
  [OK] empty forced_event handled correctly
  [OK] execute_action attack: encounter triggered, attacker=0 defender=1
  [OK] clear_pending_targets 只清 pending，保留 forced_event
--- PlayerCommandSystem Tests PASSED ---
=== DONE ===
```

無 `SCRIPT ERROR`，無 `assert` 失敗。

- [ ] **Step 3: Commit**

```
git add scripts/debug/headless_test.gd
git commit -m "test: add PlayerCommandSystem headless tests"
```

---

## 完成後

跑完整 headless test 一次確認：

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

確認：
- `=== DONE ===` 出現
- `--- PlayerCommandSystem Tests PASSED ---` 出現
- `[Encounter] 玩家遭遇戰觸發` 仍出現（路徑 1 維持運作）
- `[Trade]` 仍出現（NPC 貿易正常）
- 無 `SCRIPT ERROR`

然後推 branch 並寫 hand-back。

---

## ⚠️ 注意事項

### _resolve_trade 的 current_task 副作用

`_resolve_trade` 在成功時會設 `seller.current_task = TeamData.TASK_IDLE`。對玩家（initiator）當 seller：玩家本來就是 idle，無影響。對 NPC 當 seller：會把 NPC 的 task 改為 idle，這是預期行為（貿易完成後 NPC 閒置）。

### forced_event 超時視窗

forced_event 的超時是「下一個 TICKS_PER_HOUR（= 10 ticks）」，不是下一個 tick。UI 必須在同一個 hour-tick 內讀取並讓玩家回應。若需更長視窗，改為計數器（目前設計不做）。

### same_faction 的 pass

GDScript 的 `pass` 在 `if same_faction: pass` 後面讓執行繼續到函式剩餘邏輯。`_try_interact` 的 if-player 區塊沒有顯式 return for same_faction，因此會繼續到 NPC-NPC 邏輯（`var a: TeamData = state.teams[id_a]` 之後）。這是正確行為（讓 faction 徵收/合併正常作用於玩家 team）。

### init_encounter vs 直接設欄位

`execute_action("attack")` 直接設 `state.encounter_*` 欄位，與現有 interaction_system 玩家遭遇戰觸發方式一致，不呼叫 `init_encounter`（init_encounter 需要 encounter_units 初始化，留給 EncounterSystem 自己在 advance_encounter_tick 時處理）。
