# Observer GUI Slice Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 觀測 GUI 輕 slice — 事件 ticker + 隊伍 inspect + 速度控制 + god-view 地圖 + 截圖 harness，玩家路徑零 diff、RNG 流零擾。

**Architecture:** 新 ObserverBridge（獨立 driver，不動 sim_bridge）+ ObserverQueryApi（god-view read-only DTO，pattern 沿 PlayerQueryApi）+ ObserverMain scene（main scene 不換，跑法 `godot.ps1 res://scenes/ObserverMain.tscn`）。Task 0 補事件洞走新 `emit_ambient`（只進 global_messages、不進 team_known → 不進 propagate 交換迴圈 → 零 randf 消耗）。

**Tech Stack:** Godot 4.2.2 GDScript。測試 = headless_test.gd 增測 + seeded_warring_bed WARRING_OUT/WARRING_BASELINE 逐點對照 + 截圖 harness 自驗。

## Global Constraints

- 玩家路徑零 diff：`text_ui_main.gd` / `sim_bridge.gd` / `player_query_api.gd` / `player_api_mapper.gd` 不改。
- Observer 全 read-only（query snapshot）；唯一寫 = Task 0 emit（append-only，單寫者格局不變）。
- **RNG 流神聖**：新 emit 不得含任何 randf/RNG 消耗，且不得改變既有 randf 呼叫次數（新訊息不可進 `team_known` → 否則 `_exchange_one_way` 逐訊息 randf 會被擾動）。證據 = seeded_warring_bed 逐點 diff `total_diffs=0` + headless `seeded warring reproducible OK` 行的 final 值不變（baseline：`teams=47 factions=8 established=1 pop=380 probe_capture=0`）。
- 三件（ticker/inspect/速度）不可砍；品質 bar 硬。
- LOD 錨點 = headless bed 同策略（`Vector2i(-1,-1)` 無玩家）→ sim 行為與二考 assets 一致。
- 勿碰 `interaction_system.gd`、RelationGraph、belief（平行軌領地）。
- 每 task 完成後跑 headless（`.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`），須見 `=== DONE ===`、無 `SCRIPT ERROR`、僅 1 pre-existing FAIL（`[FAIL] 弱目標未加入攻擊 goal`）。
- 新增 class_name 檔後必跑 `.\tools\godot.ps1 --headless --import`。
- baseline 檔已在 worktree 根：`baseline_headless.txt` / `baseline_framework.txt` / `baseline_warring.txt` / `baseline_warring.json`（勿 commit，最後刪）。

## 系統事實（偵察已確認，實作直接引用）

- `SimMessageSystem.emit_message`（`message_system.gd:26`）寫 `global_messages` + `team_known[origin]`；`team_known` 進 `_exchange_one_way`（:61）逐訊息 `_decide_propagation_mode` 消耗 randf → **新事件絕不可走 emit_message**。
- `global_messages` 會被 prune（`message_system.gd:297-304`，TTL 表 :7-19）→ `msg.id = size()` 非唯一；ticker 增量消費用 **origin_tick 水位**非 id。
- `sim_runner.advance_tick` 內 `state.world.current_tick += 1` 在 systems 跑之前（實作時再驗一次：grep `current_tick += 1` sim_runner.gd）→ tick T 的訊息 origin_tick=T，watermark = 消費後 current_tick，比較用 `>`。若驗出相反順序改 `>=` + 去重。
- Task 0 落點：`manpower_system.gd` `[P1Assim]`(:134) / `[P1Revolt]`(:159) / `[P1Flee]`(:174)；`npc_combat_system.gd` `[P1Absorb]`(:301) / `[Capture]`(:351)。
- WarringHarness（`warring_harness.gd:36-79`）= observer boot 樣板：`seed(world_seed)` + `config["seed"]=world_seed` + `GameSetup.setup` + `advance_tick(state, Vector2i(-1,-1))` + encounter>800 強制 draw 護欄。observer 不開 Probe。
- 時間換算：`WorldState.TICKS_PER_MONTH=7200`、`TICKS_PER_DAY=240`、`TICKS_PER_HOUR=10`。月 = tick/7200+1、日 = (tick%7200)/240+1。
- 隊名素材：`PersonData.person_name`、`FactionData.faction_name`、`TeamData.ambition_archetype`（武力/商業/定居）、`beast_kind`。
- 俘虜數：`AnonTierSystem.total_captives(team)`；pop 分解：leader+named=`named_members.size()+1`、anon=`AnonTierSystem.total_pop`、`minor_population`、captive。
- cmdline user args：Godot 4.2 `OS.get_cmdline_user_args()`（`--` 之後）。
- 主 config：observer 預設 `res://config/warring_states.json`（bar 場景 = warring seed 1337/2674）。
- main scene = `res://scenes/TextUI.tscn`（`project.godot:14`）不換。

---

### Task 0: 事件源補洞（emit_ambient + 5 落點 + TTL key）

**Files:**
- Modify: `scripts/simulation/message_system.gd`（TTL 表 + `emit_ambient`）
- Modify: `scripts/simulation/manpower_system.gd`（3 emit）
- Modify: `scripts/simulation/npc_combat_system.gd`（2 emit）
- Test: `scripts/debug/headless_test.gd`（`_test_observer_ambient_events`）

**Interfaces:**
- Produces: `SimMessageSystem.emit_ambient(state, type, description, team, params) -> MessageData`；新 type：`assim_complete` / `revolt` / `flee` / `captives_taken`。params 一律含 `"origin"`（str team_id）+ 數字欄。

- [ ] **Step 1: message_system.gd 加 TTL key + emit_ambient**

TTL 表（:19 `"outpost_built"` 行後）加：

```gdscript
	"captives_taken":    MSG_TTL_LONG,
	"assim_complete":    MSG_TTL_MEDIUM,
	"revolt":            MSG_TTL_LONG,
	"flee":              MSG_TTL_MEDIUM,
```

`emit_message` 函數後加：

```gdscript
# 觀測事件（observer slice Task0 補洞）：只進 global_messages（ticker 消費），
# 不進 team_known → 不進 propagate 交換迴圈（_exchange_one_way 逐訊息 randf）
# → 零 RNG 消耗、seeded warring 流不擾。append-only，單寫者格局不變。
func emit_ambient(state: WorldState, type: String, description: String,
		team: TeamData, params: Dictionary = {}) -> MessageData:
	var msg := MessageData.new()
	msg.id = state.global_messages.size()
	msg.type = type
	msg.description = description
	msg.source_pos = team.tile_pos
	msg.origin_team_id = team.team_id
	msg.origin_tick = state.world.current_tick
	msg.strength = 1.0
	msg.params = params
	state.global_messages.append(msg)
	return msg
```

- [ ] **Step 2: manpower_system.gd 三處 print 後加 emit（print 不動）**

`[P1Assim]`（`_check_trajectory` 同化分支，print 後）：

```gdscript
			SimMessageSystem.new().emit_ambient(state, "assim_complete",
				"Team%d 同化俘虜 %d 人" % [holder.team_id, n], holder,
				{"origin": str(holder.team_id), "count": n})
```

`[P1Revolt]`（`_revolt` print 後）：

```gdscript
	SimMessageSystem.new().emit_ambient(state, "revolt",
		"Team%d 俘虜暴動 脫離%d 鎮壓亡%d" % [holder.team_id, total, slain], holder,
		{"origin": str(holder.team_id), "total": total, "slain": slain, "escaped": escaped})
```

`[P1Flee]`（`_flee` print 後）：

```gdscript
	SimMessageSystem.new().emit_ambient(state, "flee",
		"Team%d 俘虜%s %d人" % [holder.team_id, reason, total], holder,
		{"origin": str(holder.team_id), "count": total, "reason": reason})
```

- [ ] **Step 3: npc_combat_system.gd 兩處 capture emit**

`[P1Absorb]`（:301 print 後、`_probe_capture_by_task` 前）：

```gdscript
		_msg.emit_ambient(state, "captives_taken",
			"Team%d 俘獲 Team%d %d人" % [winner_id, loser_id, _captured], winner,
			{"origin": str(winner_id), "loser": str(loser_id), "count": _captured})
```

`[Capture]`（:351 print 後）：

```gdscript
			_msg.emit_ambient(state, "captives_taken",
				"Team%d 俘獲 Team%d 潰逃殘部 %d人" % [pursuer_id, retreater_id, _cap],
				state.teams[pursuer_id],
				{"origin": str(pursuer_id), "loser": str(retreater_id), "count": _cap})
```

- [ ] **Step 4: headless 測試**

`headless_test.gd` `_initialize` 測試清單（:523 `_test_seeded_warring_reproducible()` 附近）加 `_test_observer_ambient_events()` 呼叫；檔尾加：

```gdscript
# observer slice Task0：emit_ambient 進 global_messages、不進 team_known（RNG 隔離前提）
func _test_observer_ambient_events() -> void:
	print("--- observer Task0：emit_ambient 隔離 ---")
	var state := WorldState.new()
	var t := TeamData.new()
	t.team_id = 7
	t.tile_pos = Vector2i(3, 3)
	state.teams[7] = t
	var before_known: int = state.team_known.get(7, []).size() if state.team_known.has(7) else 0
	var m: MessageData = SimMessageSystem.new().emit_ambient(state, "captives_taken",
		"Team7 俘獲 Team8 5人", t, {"origin": "7", "loser": "8", "count": 5})
	assert(state.global_messages.size() == 1, "emit_ambient 未進 global_messages")
	assert(m.type == "captives_taken" and m.params["count"] == 5, "emit_ambient 欄位錯")
	var after_known: int = state.team_known.get(7, []).size() if state.team_known.has(7) else 0
	assert(after_known == before_known, "emit_ambient 竟進 team_known（會擾 RNG 流）")
	assert(SimMessageSystem.MSG_TTL_BY_TYPE.has("assim_complete")
		and SimMessageSystem.MSG_TTL_BY_TYPE.has("revolt")
		and SimMessageSystem.MSG_TTL_BY_TYPE.has("flee")
		and SimMessageSystem.MSG_TTL_BY_TYPE.has("captives_taken"), "TTL key 缺")
	print("observer ambient events OK")
```

- [ ] **Step 5: 跑 headless + RNG 零擾證**

```powershell
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
# 期待：=== DONE ===、無 SCRIPT ERROR、僅 1 pre-existing FAIL、
#   `seeded warring reproducible OK (seed=1337 ticks=1200 final={ "teams": 47, "factions": 8, "established": 1, "pop": 380 } probe_capture=0)` 一字不差、
#   `observer ambient events OK`
$env:WARRING_BASELINE='A:\GDS\demo\.worktrees\observer-gui-slice\baseline_warring.json'
.\tools\godot.ps1 --headless --script scripts/debug/seeded_warring_bed.gd
# 期待：`=== 對照結束：total_diffs=0（0=零行為變證）===`
Remove-Item Env:WARRING_BASELINE
```

- [ ] **Step 6: Commit** `feat(message): observer 事件補洞 — emit_ambient 零 RNG 路徑 + 同化/暴動/逃/俘獲 4 型`

---

### Task 1: ObserverQueryApi + ObserverBridge（observer driver，不動玩家路徑）

**Files:**
- Create: `scripts/simulation/observer_query_api.gd`（DTO 層，與 player_query_api.gd 同層）
- Create: `scripts/ui/observer_bridge.gd`
- Test: `scripts/debug/headless_test.gd`（`_test_observer_query_and_bridge`）

**Interfaces:**
- Produces:
  - `ObserverQueryApi.team_label(state, tid) -> String`（「李霸隊(19)」/「隊19」/「隊19(已滅)」）
  - `ObserverQueryApi.faction_label(state, fid) -> String`（faction_name 或 ""）
  - `ObserverQueryApi.query_all_teams(state) -> Array[Dictionary]`（id 升冪；{id,label,pop,rung,archetype,task,faction_id,tile_pos,is_beast}）
  - `ObserverQueryApi.query_team(state, tid) -> Dictionary`（詳情全欄，見 code）
  - `ObserverQueryApi.query_map_teams(state) -> Array`、`query_map_tiles(state) -> Dictionary`
  - `ObserverBridge.new(runner, state)`；`tick_step(max_ticks, budget_ms=12.0) -> int`；`consume_messages(since_tick) -> Array[MessageData]`；`current_tick() -> int`；query 轉呼 api。

- [ ] **Step 1: observer_query_api.gd**

```gdscript
class_name ObserverQueryApi

# 觀測 god-view read-only DTO 層（pattern 沿 PlayerQueryApi，不碰玩家耦合欄）。
# 全 static、對 WorldState 零寫入。觀測=無迷霧（spec 裁），不經 belief。

static func team_label(state: WorldState, tid: int) -> String:
	var t: TeamData = state.teams.get(tid)
	if t == null:
		return "隊%d(已滅)" % tid
	var leader: PersonData = state.persons.get(t.leader_id)
	if leader != null and leader.person_name != "":
		return "%s隊(%d)" % [leader.person_name, tid]
	return "隊%d" % tid

static func faction_label(state: WorldState, fid: int) -> String:
	if fid == -1:
		return ""
	var f: FactionData = state.factions.get(fid)
	if f == null:
		return "勢力%d" % fid
	return f.faction_name if f.faction_name != "" else "勢力%d" % fid

static func query_all_teams(state: WorldState) -> Array:
	var out: Array = []
	var ids: Array = state.teams.keys()
	ids.sort()
	for tid in ids:
		var t: TeamData = state.teams[tid]
		out.append({
			"id": tid, "label": team_label(state, tid),
			"pop": t.population, "rung": t.ambition_rung,
			"archetype": t.ambition_archetype, "task": t.current_task,
			"faction_id": t.faction_id, "tile_pos": t.tile_pos,
			"is_beast": t.beast_kind != "",
		})
	return out

static func query_team(state: WorldState, tid: int) -> Dictionary:
	var t: TeamData = state.teams.get(tid)
	if t == null:
		return {}
	var leader: PersonData = state.persons.get(t.leader_id)
	return {
		"id": tid,
		"label": team_label(state, tid),
		"leader_name": leader.person_name if leader != null else "(無)",
		"pop": t.population,
		"pop_named": t.named_members.size() + (1 if t.leader_id != -1 else 0),
		"pop_anon": AnonTierSystem.total_pop(t),
		"pop_minor": t.minor_population,
		"pop_captive": AnonTierSystem.total_captives(t),
		"food": float(t.resources.get("food", 0.0)),
		"food_flow": t.food_flow_avg,
		"coin": int(t.resources.get("coin", 0)),
		"rung": t.ambition_rung, "rung_cap": t.ambition_cap,
		"archetype": t.ambition_archetype,
		"faction_id": t.faction_id,
		"faction": faction_label(state, t.faction_id),
		"task": t.current_task,
		"task_reason": t.task_reason,
		"solo_intent": String(t.solo_intent.get("type", "")) if t.solo_intent is Dictionary else "",
		"readiness": t.readiness,
		"fatigue": t.fatigue,
		"wounded": t.wounded,
		"tile_pos": t.tile_pos,
		"tags": t.tags.duplicate(),
		"is_beast": t.beast_kind != "",
	}

# 地圖渲染 DTO：全隊真位（god-view）
static func query_map_teams(state: WorldState) -> Array:
	var out: Array = []
	var ids: Array = state.teams.keys()
	ids.sort()
	for tid in ids:
		var t: TeamData = state.teams[tid]
		out.append({"id": tid, "tile_pos": t.tile_pos, "faction_id": t.faction_id,
			"archetype": t.ambition_archetype, "is_beast": t.beast_kind != "",
			"pop": t.population})
	return out

# shape 對齊 sim_bridge.query_world_tiles（world_map_view 吃同型）
static func query_map_tiles(state: WorldState) -> Dictionary:
	var result: Dictionary = {}
	for key in state.world.tiles:
		var tile: HexTileData = state.world.tiles[key]
		result[key] = {
			"tile_pos":       tile.tile_pos,
			"terrain":        tile.terrain,
			"harvest_factor": tile.harvest_factor,
			"outpost_type":   tile.outpost_type,
			"outpost_level":  tile.outpost_level,
			"outpost_owner":  tile.outpost_owner,
		}
	return result
```

- [ ] **Step 2: observer_bridge.gd**

```gdscript
# scripts/ui/observer_bridge.gd
class_name ObserverBridge

# 觀測 driver（玩家 sim_bridge 零 diff 另立）：不因事件中斷、frame 時間預算攤 spike。
# LOD 錨點 = headless bed 同策略（無玩家 (-1,-1)）→ sim 行為與二考 assets 一致。

const NO_PLAYER := Vector2i(-1, -1)
const FRAME_BUDGET_MS: float = 12.0
const ENCOUNTER_STUCK_TICKS: int = 800   # mirror WarringHarness 護欄

var _runner: SimRunner
var _state: WorldState

func _init(runner: SimRunner, state: WorldState) -> void:
	_runner = runner
	_state = state

func get_state() -> WorldState:
	return _state

func current_tick() -> int:
	return _state.world.current_tick

# 每 frame 呼叫：推進至多 max_ticks，預算到頂即停（剩餘留下一 frame → spike 攤平非凍結）。
# 回實推 tick 數。單 tick 不可分割 → 單 tick spike 仍會超預算一次，但不累積。
func tick_step(max_ticks: int, budget_ms: float = FRAME_BUDGET_MS) -> int:
	var t0: int = Time.get_ticks_usec()
	var done: int = 0
	while done < max_ticks:
		_runner.advance_tick(_state, NO_PLAYER)
		if _state.encounter_active and _state.encounter_tick > ENCOUNTER_STUCK_TICKS:
			_runner._encounter_system.resolve_encounter_end(_state, "draw")
		done += 1
		if float(Time.get_ticks_usec() - t0) / 1000.0 >= budget_ms:
			break
	return done

# 全量增量消費：origin_tick 水位（global_messages 會 prune、id 非唯一 → 不用 id）。
# 呼叫節奏 = frame 邊界（tick 已完整），TTL 最短 7 天 >> 單 frame 推進量 → 不漏。
func consume_messages(since_tick: int) -> Array:
	var out: Array = []
	var msgs: Array = _state.global_messages
	for i in range(msgs.size() - 1, -1, -1):
		if msgs[i].origin_tick <= since_tick:
			break
		out.append(msgs[i])
	out.reverse()
	return out

func query_team(tid: int) -> Dictionary:
	return ObserverQueryApi.query_team(_state, tid)

func query_all_teams() -> Array:
	return ObserverQueryApi.query_all_teams(_state)

func query_map_teams() -> Array:
	return ObserverQueryApi.query_map_teams(_state)

func query_map_tiles() -> Dictionary:
	return ObserverQueryApi.query_map_tiles(_state)
```

注意：consume 水位比較符號依 sim_runner tick 增量順序驗證（`current_tick += 1` 在 systems 前 → 訊息 origin_tick = 增後值 → `<=` break 正確）。實作時 grep 驗，若相反改法並記 handback。

- [ ] **Step 3: `--import` 重建 class 快取**

```powershell
.\tools\godot.ps1 --headless --import
```

- [ ] **Step 4: headless 測試**

`_initialize` 加 `_test_observer_query_and_bridge()`；檔尾加：

```gdscript
# observer slice Task1：god-view DTO + bridge 推進/增量消費
func _test_observer_query_and_bridge() -> void:
	print("--- observer Task1：query api + bridge ---")
	var r: Dictionary = WarringHarness.run(1337, 240)   # 1 天小跑，state 真實
	assert(not r.is_empty(), "harness 跑失敗")
	# 重建同 seed state 給 bridge（harness 不回 state → 自建小世界驗 API 型）
	seed(1337)
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/warring_states.json")
	config["seed"] = 1337
	GameSetup.setup(state, config)
	var bridge := ObserverBridge.new(runner, state)
	var t0: int = bridge.current_tick()
	var did: int = bridge.tick_step(240, 100000.0)   # 預算放大：一口氣 240 tick
	assert(did == 240, "tick_step 未推滿 240（did=%d）" % did)
	assert(bridge.current_tick() == t0 + 240, "current_tick 未同步")
	# 預算截斷：0.001ms 預算 → 只推得動 1 tick
	var did2: int = bridge.tick_step(100, 0.001)
	assert(did2 == 1, "預算截斷失效（did2=%d）" % did2)
	# DTO 欄位齊
	var all_teams: Array = bridge.query_all_teams()
	assert(all_teams.size() > 0, "query_all_teams 空")
	var first: Dictionary = all_teams[0]
	for k in ["id", "label", "pop", "rung", "archetype", "task", "faction_id", "tile_pos"]:
		assert(first.has(k), "all_teams 缺欄 %s" % k)
	var detail: Dictionary = bridge.query_team(int(first["id"]))
	for k in ["leader_name", "pop_named", "pop_anon", "pop_minor", "pop_captive",
			"food", "food_flow", "rung", "archetype", "faction", "task",
			"solo_intent", "readiness", "fatigue"]:
		assert(detail.has(k), "query_team 缺欄 %s" % k)
	assert(bridge.query_team(999999).is_empty(), "不存在隊該回空 dict")
	# 增量消費：水位後只回新訊息
	var wm: int = bridge.current_tick()
	var t: TeamData = state.teams[state.teams.keys()[0]]
	SimMessageSystem.new().emit_ambient(state, "captives_taken", "x", t, {"origin": "0", "count": 1})
	# 手動把 origin_tick 推到水位後（模擬下一 tick 發生）
	state.global_messages[-1].origin_tick = wm + 1
	var got: Array = bridge.consume_messages(wm)
	assert(got.size() == 1 and got[0].type == "captives_taken", "consume_messages 增量錯")
	assert(bridge.consume_messages(wm + 1).is_empty(), "水位後該空")
	print("observer query+bridge OK")
```

- [ ] **Step 5: 跑 headless，期待 `observer query+bridge OK` + DONE + reproducible OK 不變**

- [ ] **Step 6: Commit** `feat(observer): ObserverQueryApi + ObserverBridge — god-view driver，玩家路徑零 diff`

---

### Task 2a: world_map_view god-view 模式 + ObserverMain 骨架 + 速度控制

**Files:**
- Modify: `scripts/ui/world_map_view.gd`（observer 分支；player 分支零行為變）
- Create: `scripts/ui/observer_main.gd`
- Create: `scenes/ObserverMain.tscn`

**Interfaces:**
- Consumes: `ObserverBridge`（Task 1 全 API）
- Produces:
  - `world_map_view.setup_observer(ob: ObserverBridge)`；signal `team_picked(tid: int)`；`select_team(tid: int)`（外部同步選中+follow 目標）；`set_follow(on: bool)`
  - `observer_main.gd`：速度四檔（pause/1×=240tps/4×=960tps/max）、時間 label、`_bridge`、`_refresh_ui()`。

- [ ] **Step 1: world_map_view.gd 加 observer 模式**

頂部 var 區加：

```gdscript
# ── observer god-view 模式（ObserverMain 用；player 路徑零行為變）──
var _obridge: ObserverBridge = null
var _observer: bool = false
var _selected_team: int = -1
var _follow: bool = false

const ARCHETYPE_COLOR: Dictionary = {
	"武力": Color(0.85, 0.25, 0.2),
	"商業": Color(0.9, 0.75, 0.2),
	"定居": Color(0.3, 0.7, 0.35),
}
const FACTION_PALETTE: Array = [
	Color(0.2, 0.5, 0.9), Color(0.9, 0.4, 0.1), Color(0.6, 0.2, 0.8),
	Color(0.1, 0.7, 0.7), Color(0.85, 0.2, 0.5), Color(0.5, 0.65, 0.1),
	Color(0.7, 0.45, 0.25), Color(0.35, 0.35, 0.85),
]
signal team_picked(tid: int)
```

setup 區加：

```gdscript
func setup_observer(ob: ObserverBridge) -> void:
	_obridge = ob
	_observer = true
	_refresh_cache()
	_center_on_map()
	queue_redraw()

func _center_on_map() -> void:
	var mid := Vector2.ZERO
	var n: int = 0
	for key in _cached_tiles:
		var tpos: Vector2i = _cached_tiles[key].get("tile_pos", Vector2i.ZERO)
		mid += _hex_center(tpos.x, tpos.y)
		n += 1
	if n > 0:
		mid /= float(n)
	_camera = get_viewport_rect().size * 0.5 - mid * _zoom

func select_team(tid: int) -> void:
	_selected_team = tid
	queue_redraw()

func set_follow(on: bool) -> void:
	_follow = on
```

`_refresh_cache` 改成分支（player 路徑原樣）：

```gdscript
func _refresh_cache() -> void:
	if _observer:
		if _obridge == null: return
		_cached_tiles = _obridge.query_map_tiles()
		_cached_teams = _obridge.query_map_teams()
		_render_ctx = {}
		if _follow and _selected_team != -1:
			for td in _cached_teams:
				if int(td["id"]) == _selected_team:
					var wc: Vector2 = _hex_center(td["tile_pos"].x, td["tile_pos"].y)
					_camera = get_viewport_rect().size * 0.5 - wc * _zoom
					break
		return
	if _bridge == null: return
	_cached_tiles = _bridge.query_world_tiles()
	_cached_teams = _bridge.query_visible_teams_render()
	_render_ctx   = _bridge.query_render_context()
```

`_draw` 改：fog 段 guard `if not _observer and not _is_tile_visible(...)`；tile 迴圈內加 outpost 標記（fog guard 前）：

```gdscript
		if _observer and tile_data.get("outpost_type", "") != "":
			var oc: Color = Color(0.45, 0.3, 0.15) if tile_data["outpost_type"] == "civilian" else Color(0.25, 0.25, 0.3)
			var s: float = (4.0 + 2.0 * float(tile_data.get("outpost_level", 0))) * _zoom
			draw_rect(Rect2(center - Vector2(s, s) * 0.5, Vector2(s, s)), oc)
```

team 繪製段開頭插 observer 分支（player 段原樣走 else）：

```gdscript
	if _observer:
		for td in _cached_teams:
			var tp: Vector2i = td["tile_pos"]
			var c: Vector2 = _world_to_screen(_hex_center(tp.x, tp.y))
			if td.get("is_beast", false):
				draw_circle(c, 4.0 * _zoom, Color(0.15, 0.1, 0.05))
				continue
			var fid: int = int(td.get("faction_id", -1))
			var ring: Color = FACTION_PALETTE[fid % FACTION_PALETTE.size()] if fid >= 0 else Color(0.45, 0.45, 0.45)
			var fill: Color = ARCHETYPE_COLOR.get(td.get("archetype", ""), Color(0.7, 0.7, 0.7))
			draw_circle(c, 9.0 * _zoom, ring)
			draw_circle(c, 6.0 * _zoom, fill)
			if int(td["id"]) == _selected_team:
				draw_arc(c, 13.0 * _zoom, 0.0, TAU, 24, Color.WHITE, 2.0)
	else:
		# （既有 player team 繪製整段原樣縮排進 else）
```

`_unhandled_input` 左鍵分支加 observer pick（同格多隊循環選）：

```gdscript
			if _observer:
				var hex_o: Vector2i = pixel_to_hex(get_local_mouse_position())
				var here: Array = []
				for td in _cached_teams:
					if (td["tile_pos"] as Vector2i) == hex_o:
						here.append(int(td["id"]))
				if here.is_empty():
					_selected = hex_o
					queue_redraw()
					tile_selected.emit(hex_o)
					return
				var idx: int = here.find(_selected_team)
				_selected_team = here[(idx + 1) % here.size()]
				_selected = Vector2i(-1, -1)
				queue_redraw()
				team_picked.emit(_selected_team)
				return
```

- [ ] **Step 2: observer_main.gd（骨架 + 速度控制 + 時間 label）**

```gdscript
# scripts/ui/observer_main.gd — 觀測 GUI 根（三件：ticker/inspect/速度）。
# 玩家路徑零 diff：main scene 不換，跑法 godot.ps1 res://scenes/ObserverMain.tscn
extends Control

const SPEED_LABELS: Array = ["⏸ 暫停", "1×", "4×", "MAX"]
const SPEED_TPS: Array = [0.0, 240.0, 960.0, -1.0]   # -1 = 預算內盡量
const UI_REFRESH_SEC: float = 0.25   # 面板/地圖重繪節流（sim 推進不受此限）

var _runner: SimRunner
var _state: WorldState
var _bridge: ObserverBridge
var _speed_idx: int = 0
var _tick_carry: float = 0.0
var _ui_accum: float = 0.0
var _speed_btns: Array = []
var _time_label: Label
var _map: Node2D
# Task4 hitch 量測
var _hitch_max_ms: float = 0.0
var _hitch_over150: int = 0
var _frames: int = 0

func _ready() -> void:
	var args: Dictionary = _parse_obs_args()
	var world_seed: int = int(args.get("obs-seed", 1337))
	seed(world_seed)   # 同 WarringHarness：播 global RNG → 與 headless bed 同流
	_state = WorldState.new()
	_runner = SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/warring_states.json")
	config["seed"] = world_seed
	GameSetup.setup(_state, config)
	_bridge = ObserverBridge.new(_runner, _state)
	_build_ui()
	_refresh_ui()
	print("[Observer] ready seed=%d teams=%d" % [world_seed, _state.teams.size()])

func _parse_obs_args() -> Dictionary:
	var out: Dictionary = {}
	for a in OS.get_cmdline_user_args():
		var s: String = a
		if s.begins_with("--"):
			s = s.substr(2)
		var eq: int = s.find("=")
		if eq > 0:
			out[s.substr(0, eq)] = s.substr(eq + 1)
	return out

func _build_ui() -> void:
	_map = load("res://scripts/ui/world_map_view.gd").new()
	_map.name = "MapView"
	add_child(_map)
	_map.setup_observer(_bridge)
	# 頂部速度列
	var top := HBoxContainer.new()
	top.name = "TopBar"
	top.position = Vector2(8, 8)
	add_child(top)
	for i in range(SPEED_LABELS.size()):
		var b := Button.new()
		b.text = SPEED_LABELS[i]
		b.toggle_mode = true
		b.button_pressed = (i == _speed_idx)
		b.pressed.connect(_on_speed.bind(i))
		top.add_child(b)
		_speed_btns.append(b)
	_time_label = Label.new()
	_time_label.text = ""
	top.add_child(_time_label)

func _on_speed(idx: int) -> void:
	_speed_idx = idx
	_tick_carry = 0.0
	for i in range(_speed_btns.size()):
		_speed_btns[i].button_pressed = (i == idx)

func _process(delta: float) -> void:
	_frames += 1
	var ms: float = delta * 1000.0
	if ms > _hitch_max_ms: _hitch_max_ms = ms
	if ms > 150.0: _hitch_over150 += 1
	var tps: float = SPEED_TPS[_speed_idx]
	var did: int = 0
	if tps < 0.0:
		did = _bridge.tick_step(1000000)
	elif tps > 0.0:
		_tick_carry = minf(_tick_carry + tps * delta, tps)   # backlog 上限 1 秒量
		var want: int = int(_tick_carry)
		if want > 0:
			did = _bridge.tick_step(want)
			_tick_carry -= float(did)
	_ui_accum += delta
	if did > 0 and _ui_accum >= UI_REFRESH_SEC:
		_ui_accum = 0.0
		_refresh_ui()

func _refresh_ui() -> void:
	var tick: int = _bridge.current_tick()
	var month: int = tick / WorldState.TICKS_PER_MONTH + 1
	var day: int = (tick % WorldState.TICKS_PER_MONTH) / WorldState.TICKS_PER_DAY + 1
	_time_label.text = "  月%d 日%d（tick %d）  hitch max %.0fms" % [month, day, tick, _hitch_max_ms]
	_map.refresh()
```

- [ ] **Step 3: scenes/ObserverMain.tscn**

```
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/ui/observer_main.gd" id="1"]

[node name="ObserverMain" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
script = ExtResource("1")
```

- [ ] **Step 4: 驗證（headless 迴歸 + windowed 冒煙）**

```powershell
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd   # DONE、無 SCRIPT ERROR
$env:GODOT_TIMEOUT='30'
.\tools\godot.ps1 res://scenes/ObserverMain.tscn    # 30s 後 wrapper kill；輸出見 [Observer] ready、無 SCRIPT ERROR
Remove-Item Env:GODOT_TIMEOUT
```

- [ ] **Step 5: Commit** `feat(observer): god-view 地圖 + ObserverMain 骨架 + 速度四檔`

---

### Task 2b: 事件 ticker（人話 formatter + 隊過濾 + 500 條歷史）

**Files:**
- Create: `scripts/ui/observer_event_text.gd`（formatter，static → headless 可測）
- Create: `scripts/ui/observer_ticker_panel.gd`
- Modify: `scripts/ui/observer_main.gd`（掛 panel + poll）
- Test: `scripts/debug/headless_test.gd`（`_test_observer_event_text`）

**Interfaces:**
- Produces:
  - `ObserverEventText.render(state, msg: MessageData) -> String`（`[月X日Y] 中文句子`）
  - `ObserverEventText.related_teams(msg) -> Array[int]`（隊過濾 match 集）
  - `ObserverTickerPanel.setup(bridge)`；`poll()`；`set_filter_team(tid)`（-1=全)；scroll 歷史上限 500。

- [ ] **Step 1: observer_event_text.gd**

逐 type 走查（全 emit 落點盤點過：combat_start/combat_end/subjugate/faction_establish/faction_defect/outpost_built/extortion/tribute/diplomacy/order_delivered/aid_given/aid_refused/trade_done/famine_warning/split/replace/order_buy/order_sell + Task0 四型）：

```gdscript
# scripts/ui/observer_event_text.gd — 事件人話 formatter（UI 層）。
# type→中文模板，填 leader 人名/隊名/數字（帶單位）；probe 味 description UI 層改寫，
# 已人話者直用；未知 type fallback description。read-only。
class_name ObserverEventText

const RES_NAMES: Dictionary = {
	"food": "糧食", "material": "木料", "coin": "錢", "goods": "貨品", "gem": "寶石",
	"ore_iron": "鐵礦", "ore_steel": "鋼", "ore_gold": "金礦", "ore_silver": "銀礦",
	"weapon_melee_low": "粗製近戰武器", "weapon_melee_high": "精製近戰武器",
	"weapon_ranged_low": "粗製遠程武器", "weapon_ranged_high": "精製遠程武器",
	"mounts": "馬匹", "wagons": "貨車", "arrows": "箭矢", "medicine": "藥品",
	"tools": "工具", "armor_low": "粗製甲", "armor_high": "精製甲",
}

static func stamp(msg: MessageData) -> String:
	var month: int = msg.origin_tick / WorldState.TICKS_PER_MONTH + 1
	var day: int = (msg.origin_tick % WorldState.TICKS_PER_MONTH) / WorldState.TICKS_PER_DAY + 1
	return "[月%d日%d]" % [month, day]

static func render(state: WorldState, msg: MessageData) -> String:
	return "%s %s" % [stamp(msg), _body(state, msg)]

# 隊過濾 match 集：origin_team_id + params 內 team id 欄
static func related_teams(msg: MessageData) -> Array:
	var ids: Dictionary = {msg.origin_team_id: true}
	for k in ["origin", "target", "loser", "origin_team"]:
		if msg.params.has(k) and str(msg.params[k]).is_valid_int():
			ids[int(str(msg.params[k]))] = true
	return ids.keys()

static func _tl(state: WorldState, raw) -> String:
	return ObserverQueryApi.team_label(state, int(str(raw)))

static func _body(state: WorldState, msg: MessageData) -> String:
	var p: Dictionary = msg.params
	var org = p.get("origin", msg.origin_team_id)
	match msg.type:
		"combat_start":
			return "%s 向 %s 宣戰" % [_tl(state, org), _tl(state, p.get("target", -1))]
		"combat_end":
			return "%s 擊潰 %s" % [_tl(state, org), _tl(state, p.get("loser", -1))]
		"subjugate":
			var fl: String = ObserverQueryApi.faction_label(state, int(str(p.get("faction", "-1"))))
			if fl == "":
				return "%s 收服 %s" % [_tl(state, org), _tl(state, p.get("loser", -1))]
			return "%s 收服 %s，納入%s" % [_tl(state, org), _tl(state, p.get("loser", -1)), fl]
		"captives_taken":
			return "%s 俘獲 %s 部眾 %d 人" % [_tl(state, org), _tl(state, p.get("loser", -1)), int(p.get("count", 0))]
		"assim_complete":
			return "%s 同化俘虜 %d 人，收為己用" % [_tl(state, org), int(p.get("count", 0))]
		"revolt":
			return "%s 俘虜暴動：%d 人脫離（鎮壓亡 %d 人）" % [_tl(state, org), int(p.get("total", 0)), int(p.get("slain", 0))]
		"flee":
			if String(p.get("reason", "")) == "released":
				return "%s 無力供養，釋放俘虜 %d 人" % [_tl(state, org), int(p.get("count", 0))]
			return "%s 俘虜 %d 人趁隙逃亡" % [_tl(state, org), int(p.get("count", 0))]
		"faction_establish":
			var nm: String = String(p.get("name", ""))
			if nm == "":
				return "%s 立國" % _tl(state, org)
			return "%s 立國，號「%s」" % [_tl(state, org), nm]
		"faction_defect":
			return "%s 脫離所屬勢力" % _tl(state, org)
		"outpost_built":
			return "%s 在(%s,%s)建成%s" % [_tl(state, org), str(p.get("x", "?")), str(p.get("y", "?")), String(p.get("name", "據點"))]
		"extortion":
			return "%s 向 %s 強收過路費" % [_tl(state, org), _tl(state, p.get("target", -1))]
		"tribute":
			return "%s 向 %s 徵收（稅率 %s）" % [_tl(state, org), _tl(state, p.get("target", -1)), str(p.get("rate", "?"))]
		"diplomacy":
			return "%s 與 %s 締盟" % [_tl(state, org), _tl(state, p.get("target", -1))]
		"order_delivered":
			return "%s 傳令 %s：%s" % [_tl(state, org), _tl(state, p.get("target", -1)), str(p.get("task", "?"))]
		"aid_given":
			return "%s 援助 %s %s 糧" % [_tl(state, org), _tl(state, p.get("target", -1)), str(p.get("amount", "?"))]
		"aid_refused":
			return "%s 拒絕援助 %s" % [_tl(state, org), _tl(state, p.get("target", -1))]
		"trade_done":
			return "%s 完成一筆貿易" % _tl(state, org)
		"famine_warning":
			return "%s 轄地歉收，糧食吃緊" % _tl(state, org)
		"split":
			return "%s 內部分裂，出走者自立" % _tl(state, org)
		"replace":
			return "%s 領袖遭替換" % _tl(state, org)
		"order_buy", "order_sell":
			var res_n: String = RES_NAMES.get(String(p.get("res", "")), String(p.get("res", "?")))
			var verb: String = "收購" if msg.type == "order_buy" else "出售"
			return "%s 張貼%s%s×%d 訂單" % [_tl(state, org), verb, res_n, int(p.get("qty", 0))]
		_:
			return msg.description
```

- [ ] **Step 2: observer_ticker_panel.gd**

```gdscript
# scripts/ui/observer_ticker_panel.gd — 事件 ticker（三件之一）。
# 吃 bridge.consume_messages 全量增量；人話 formatter；隊過濾；歷史 500 條。
extends VBoxContainer
class_name ObserverTickerPanel

const MAX_ENTRIES: int = 500

var _bridge: ObserverBridge
var _since_tick: int = -1
var _entries: Array = []   # {text: String, teams: Array}
var _filter_tid: int = -1
var _filter_check: CheckBox
var _log: RichTextLabel

func setup(bridge: ObserverBridge) -> void:
	_bridge = bridge
	var head := HBoxContainer.new()
	var title := Label.new()
	title.text = "事件"
	head.add_child(title)
	_filter_check = CheckBox.new()
	_filter_check.text = "只看選中隊"
	_filter_check.disabled = true
	_filter_check.toggled.connect(func(_on): _render())
	head.add_child(_filter_check)
	add_child(head)
	_log = RichTextLabel.new()
	_log.scroll_following = true
	_log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_log.fit_content = false
	add_child(_log)

# 選中隊變更（inspect/地圖同步呼）。tid=-1 清除。
func set_filter_team(tid: int) -> void:
	_filter_tid = tid
	_filter_check.disabled = (tid == -1)
	if tid == -1:
		_filter_check.button_pressed = false
	_render()

func poll() -> void:
	var state: WorldState = _bridge.get_state()
	var fresh: Array = _bridge.consume_messages(_since_tick)
	_since_tick = _bridge.current_tick()
	if fresh.is_empty():
		return
	for msg in fresh:
		_entries.append({
			"text": ObserverEventText.render(state, msg),
			"teams": ObserverEventText.related_teams(msg),
		})
	if _entries.size() > MAX_ENTRIES:
		_entries = _entries.slice(_entries.size() - MAX_ENTRIES)
	_render()

func _render() -> void:
	var lines: Array = []
	var filtering: bool = _filter_check.button_pressed and _filter_tid != -1
	for e in _entries:
		if filtering and not (e["teams"] as Array).has(_filter_tid):
			continue
		lines.append(e["text"])
	_log.text = "\n".join(lines)
```

- [ ] **Step 3: observer_main.gd 掛 ticker**

`_build_ui` 尾加右側欄容器 + ticker；`_refresh_ui` 尾加 `_ticker.poll()`：

```gdscript
	# 右側欄（inspect 上 / ticker 下）
	var right := VBoxContainer.new()
	right.name = "RightPanel"
	right.anchor_left = 1.0
	right.anchor_right = 1.0
	right.anchor_bottom = 1.0
	right.offset_left = -420.0
	right.offset_top = 44.0
	add_child(right)
	_ticker = ObserverTickerPanel.new()
	_ticker.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(_ticker)
	_ticker.setup(_bridge)
```

（var 區加 `var _ticker: ObserverTickerPanel`、`var _right: VBoxContainer`。）

- [ ] **Step 4: headless formatter 測試**

`_initialize` 加 `_test_observer_event_text()`；檔尾加：

```gdscript
# observer slice Task2b：formatter 人話（無 probe dump）、隊過濾集
func _test_observer_event_text() -> void:
	print("--- observer Task2b：event formatter ---")
	var state := WorldState.new()
	var t := TeamData.new()
	t.team_id = 19
	state.teams[19] = t
	var lead := PersonData.new()
	lead.id = 5
	lead.person_name = "李霸"
	state.persons[5] = lead
	t.leader_id = 5
	var m := MessageData.new()
	m.type = "captives_taken"
	m.origin_team_id = 19
	m.origin_tick = WorldState.TICKS_PER_MONTH + WorldState.TICKS_PER_DAY * 3   # 月2日4
	m.params = {"origin": "19", "loser": "3", "count": 4}
	var s: String = ObserverEventText.render(state, m)
	assert(s.begins_with("[月2日4]"), "時間戳錯：%s" % s)
	assert("李霸" in s and "4 人" in s, "人話缺人名/數字：%s" % s)
	assert(not ("Team19" in s), "probe 味未改寫：%s" % s)
	var rel: Array = ObserverEventText.related_teams(m)
	assert(19 in rel and 3 in rel, "隊過濾集錯：%s" % str(rel))
	# 未知 type fallback description
	var m2 := MessageData.new()
	m2.type = "weird_type"
	m2.origin_team_id = 19
	m2.description = "某事發生"
	assert("某事發生" in ObserverEventText.render(state, m2), "fallback 失效")
	print("observer event text OK")
```

- [ ] **Step 5: `--import` → headless 跑過 → windowed 冒煙（1× 跑 30s，ticker 出中文句）**

- [ ] **Step 6: Commit** `feat(observer): 事件 ticker — 人話 formatter 逐 type + 隊過濾 + 500 條歷史`

---

### Task 2c: 隊伍 inspect panel + 地圖雙向同步

**Files:**
- Create: `scripts/ui/observer_inspect_panel.gd`
- Modify: `scripts/ui/observer_main.gd`（掛 panel + 三方同步接線）

**Interfaces:**
- Produces: `ObserverInspectPanel.setup(bridge)`；signal `team_selected(tid: int)`；`select_team(tid)`（外部同步入口）；`refresh()`（清單+詳情重拉）。
- 同步契約：地圖 `team_picked` → inspect.select_team + ticker.set_filter_team；inspect `team_selected` → map.select_team + ticker.set_filter_team。follow toggle 按鈕在 inspect 詳情區。

- [ ] **Step 1: observer_inspect_panel.gd**

```gdscript
# scripts/ui/observer_inspect_panel.gd — 隊伍 inspect（三件之一）。
# 全隊清單（一行摘要）→ 點選詳情；與地圖 click pick 雙向同步。read-only。
extends VBoxContainer
class_name ObserverInspectPanel

signal team_selected(tid: int)
signal follow_toggled(on: bool)

var _bridge: ObserverBridge
var _list: ItemList
var _detail: RichTextLabel
var _follow_btn: CheckBox
var _selected: int = -1
var _row_tids: Array = []

func setup(bridge: ObserverBridge) -> void:
	_bridge = bridge
	var head := HBoxContainer.new()
	var title := Label.new()
	title.text = "隊伍"
	head.add_child(title)
	_follow_btn = CheckBox.new()
	_follow_btn.text = "鏡頭跟隨"
	_follow_btn.toggled.connect(func(on): follow_toggled.emit(on))
	head.add_child(_follow_btn)
	add_child(head)
	_list = ItemList.new()
	_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_list.item_selected.connect(_on_row)
	add_child(_list)
	_detail = RichTextLabel.new()
	_detail.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_detail.fit_content = false
	add_child(_detail)
	refresh()

func _on_row(idx: int) -> void:
	if idx < 0 or idx >= _row_tids.size():
		return
	_selected = _row_tids[idx]
	_render_detail()
	team_selected.emit(_selected)

# 外部同步（地圖 pick）：選中 + 詳情，不回發 signal（防循環）
func select_team(tid: int) -> void:
	_selected = tid
	var idx: int = _row_tids.find(tid)
	if idx >= 0:
		_list.select(idx)
		_list.ensure_current_is_visible()
	_render_detail()

func refresh() -> void:
	var rows: Array = _bridge.query_all_teams()
	_list.clear()
	_row_tids.clear()
	for r in rows:
		if r.get("is_beast", false):
			continue
		_row_tids.append(int(r["id"]))
		_list.add_item("%s  %d人 階%d %s" % [r["label"], int(r["pop"]), int(r["rung"]), str(r["task"])])
	var idx: int = _row_tids.find(_selected)
	if idx >= 0:
		_list.select(idx)
	_render_detail()

func _render_detail() -> void:
	if _selected == -1:
		_detail.text = "（點地圖或清單選隊）"
		return
	var d: Dictionary = _bridge.query_team(_selected)
	if d.is_empty():
		_detail.text = "（隊%d 已不存在）" % _selected
		return
	var lines: Array = [
		"[b]%s[/b]" % d["label"],
		"領袖：%s" % d["leader_name"],
		"人口：%d（記名%d／匿名%d／未成年%d／俘虜%d）" % [
			int(d["pop"]), int(d["pop_named"]), int(d["pop_anon"]),
			int(d["pop_minor"]), int(d["pop_captive"])],
		"糧食：%.0f（日流 %+.1f）  錢：%d" % [float(d["food"]), float(d["food_flow"]), int(d["coin"])],
		"野心：階%d／上限%d（%s）" % [int(d["rung"]), int(d["rung_cap"]), str(d["archetype"])],
		"勢力：%s" % (str(d["faction"]) if str(d["faction"]) != "" else "（獨立）"),
		"任務：%s（%s）" % [str(d["task"]), str(d["task_reason"])],
		"戰略意圖：%s" % (str(d["solo_intent"]) if str(d["solo_intent"]) != "" else "（無）"),
		"戰備：%.2f  疲勞：%.2f  傷兵：%d" % [float(d["readiness"]), float(d["fatigue"]), int(d["wounded"])],
		"位置：(%d,%d)" % [d["tile_pos"].x, d["tile_pos"].y],
	]
	_detail.bbcode_enabled = true
	_detail.text = "\n".join(lines)
```

- [ ] **Step 2: observer_main.gd 接線**

`_build_ui` right panel 段改為（inspect 上、ticker 下）+ 同步接線：

```gdscript
	_inspect = ObserverInspectPanel.new()
	_inspect.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(_inspect)
	_inspect.setup(_bridge)
	_ticker = ObserverTickerPanel.new()
	_ticker.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(_ticker)
	_ticker.setup(_bridge)
	# 三方同步：map ↔ inspect ↔ ticker filter
	_map.team_picked.connect(func(tid: int):
		_inspect.select_team(tid)
		_ticker.set_filter_team(tid))
	_inspect.team_selected.connect(func(tid: int):
		_map.select_team(tid)
		_ticker.set_filter_team(tid))
	_inspect.follow_toggled.connect(func(on: bool): _map.set_follow(on))
```

`_refresh_ui` 尾加 `_inspect.refresh()`。map `team_picked` 時也要 `_map.select_team(tid)`（自身高亮已在 pick 內設，確認即可）。

- [ ] **Step 3: 驗證 — headless 迴歸 + windowed 冒煙（點隊→詳情+過濾+follow）**

- [ ] **Step 4: Commit** `feat(observer): 隊伍 inspect panel + 地圖/ticker 三方同步`

---

### Task 3: 截圖 harness（--obs-seed / --obs-run-months / --obs-shots / --obs-out）

**Files:**
- Modify: `scripts/ui/observer_main.gd`

**Interfaces:**
- Produces: cmdline `godot.ps1 res://scenes/ObserverMain.tscn -- --obs-seed=N --obs-run-months=M --obs-shots=t1,t2 --obs-out=dir`
  - 跑到各 shot tick 截 `obs_s<seed>_t<tick>.png`；跑滿 M 月印 hitch 統計後 quit。
  - 無 `--obs-shots`/`--obs-run-months` = 互動模式（現行為）。

- [ ] **Step 1: observer_main.gd 加 harness 狀態機**

var 區加：

```gdscript
# 截圖 harness（bar 第 5 條依賴）
var _harness: bool = false
var _shots: Array = []        # 升冪 tick
var _shot_idx: int = 0
var _end_tick: int = 0
var _out_dir: String = "."
var _obs_seed: int = 1337
var _capturing: bool = false
```

`_ready` 尾（`_refresh_ui()` 後）加：

```gdscript
	if args.has("obs-shots") or args.has("obs-run-months"):
		_harness = true
		_obs_seed = world_seed
		_out_dir = String(args.get("obs-out", "."))
		DirAccess.make_dir_recursive_absolute(_out_dir)
		for tok in String(args.get("obs-shots", "")).split(",", false):
			if tok.strip_edges().is_valid_int():
				_shots.append(int(tok.strip_edges()))
		_shots.sort()
		var months: int = int(args.get("obs-run-months", 0))
		_end_tick = months * WorldState.TICKS_PER_MONTH
		if _end_tick == 0 and not _shots.is_empty():
			_end_tick = _shots[-1]
		_on_speed(3)   # max
		print("[Observer] harness shots=%s end=%d out=%s" % [str(_shots), _end_tick, _out_dir])
```

`_process` 開頭加 harness 分支（取代常規推進）：

```gdscript
	if _harness:
		if _capturing:
			return
		_harness_step()
		return
```

harness 步進 + 截圖：

```gdscript
func _harness_step() -> void:
	var now: int = _bridge.current_tick()
	var next_stop: int = _end_tick
	if _shot_idx < _shots.size():
		next_stop = mini(_shots[_shot_idx], _end_tick)
	if now < next_stop:
		_bridge.tick_step(next_stop - now)   # 不 overshoot；預算內推
		_refresh_ui()
		return
	if _shot_idx < _shots.size() and now >= _shots[_shot_idx]:
		_capture(_shots[_shot_idx])
		_shot_idx += 1
		return
	if now >= _end_tick:
		print("[Observer] harness done tick=%d frames=%d hitch_max=%.0fms over150=%d" % [
			now, _frames, _hitch_max_ms, _hitch_over150])
		get_tree().quit()

func _capture(tick: int) -> void:
	_capturing = true
	_refresh_ui()
	await get_tree().process_frame
	await get_tree().process_frame
	var img: Image = get_viewport().get_texture().get_image()
	var path: String = _out_dir.path_join("obs_s%d_t%d.png" % [_obs_seed, tick])
	var err: int = img.save_png(path)
	print("[Observer] shot t=%d → %s (err=%d)" % [tick, path, err])
	_capturing = false
```

注意 `_process` hitch 量測段在 harness 分支前照跑（Task 4 數據來源）。

- [ ] **Step 2: 實測一張**

```powershell
$env:GODOT_TIMEOUT='120'
.\tools\godot.ps1 res://scenes/ObserverMain.tscn -- --obs-seed=1337 --obs-run-months=1 --obs-shots=3600,7200 --obs-out=A:\GDS\demo\.worktrees\observer-gui-slice\shots
Remove-Item Env:GODOT_TIMEOUT
```

期待：印 2 行 `[Observer] shot`（err=0）+ `harness done`；Read 兩張 PNG 確認畫面（地圖有色塊+隊圖示、右欄有字、無黑圖）。

- [ ] **Step 3: Commit** `feat(observer): 截圖 harness — obs-seed/run-months/shots/out + 自動 quit`

---

### Task 4: bar 場景實測 + cadence spike 裁決 + handback

**Files:**
- Create: `docs/superpowers/handbacks/2026-07-04-observer-gui-slice.md`
- Modify: `docs/progress.md`（進度一行）＋ 需要時 `docs/known_issues.md`

- [ ] **Step 1: bar 場景兩 seed 各 6 月截圖序列**

```powershell
$env:GODOT_TIMEOUT='600'
.\tools\godot.ps1 res://scenes/ObserverMain.tscn -- --obs-seed=1337 --obs-run-months=6 --obs-shots=7200,14400,21600,28800,36000,43200 --obs-out=A:\GDS\demo\.worktrees\observer-gui-slice\shots
.\tools\godot.ps1 res://scenes/ObserverMain.tscn -- --obs-seed=2674 --obs-run-months=6 --obs-shots=7200,14400,21600,28800,36000,43200 --obs-out=A:\GDS\demo\.worktrees\observer-gui-slice\shots
Remove-Item Env:GODOT_TIMEOUT
```

驗收：兩跑皆 `harness done` 無 SCRIPT ERROR（= max 6 月不崩）；Read 各張截圖自驗（ticker 中文成句、inspect 欄位齊、地圖隊 icon/村標記可辨）。狼弧：從 ticker 訊息序列（combat→captives_taken→assim/revolt→subjugate/faction_establish 或轉糧）確認事件鏈看得懂；harness 只有全量 ticker → 狼弧追蹤截圖用「選中隊過濾」需互動 — 以 headless probe + 截圖裡 ticker 內容佐證，過濾功能以冒煙錄驗，限制記 handback。

- [ ] **Step 2: hitch 裁決**

兩跑 `hitch_max` / `over150`：
- `over150` 偶發（≤ 每月 1-2 次）→ 收，記數據進 handback。
- `over150` 常態 → 本 slice 內收 far.total top violator（cadence-aware accumulation，向 = `cadence-spike-fix` handback 既有 design；動 sim 前先呈報主 session — 動 sim 檔=RNG 擾動風險，須重跑 warring baseline 對照）。

- [ ] **Step 3: 全迴歸**

```powershell
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd    # DONE、1 FAIL、reproducible OK 原值
.\tools\godot.ps1 --headless --script scripts/debug/framework_validation.gd   # PASS=7 DORMANT=0
$env:WARRING_BASELINE='A:\GDS\demo\.worktrees\observer-gui-slice\baseline_warring.json'
.\tools\godot.ps1 --headless --script scripts/debug/seeded_warring_bed.gd     # total_diffs=0
Remove-Item Env:WARRING_BASELINE
git diff origin/main --stat   # 確認玩家路徑檔零 diff：text_ui_main/sim_bridge/player_query_api/player_api_mapper 不在列
```

- [ ] **Step 4: 清 baseline 暫存檔（不 commit）、docs 更新、handback**

`docs/progress.md` 加一行進度。handback 含：實作摘要（每檔一行）、與 spec 差異（turn_controls 未改用自建速度列；observer_query_api 放 scripts/simulation/；emit_ambient 不進 team_known 的 RNG 隔離設計）、截圖 assets 路徑、hitch 數據、連動風險、待確認。

- [ ] **Step 5: push + commit handback**

```powershell
git push -u origin feat/observer-gui-slice
```

- [ ] **Step 6: finishing-a-development-branch → Option 3（Keep as-is），回報分支**
