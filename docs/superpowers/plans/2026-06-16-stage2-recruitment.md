# 階段2 招人成幫 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 玩家從孤身生存進到招募同伴成小隊：投靠（NPC 絕境主動來→食物收留）+ 招募（玩家主動去→coin 挖角,現成）+ 能力 legibility + tutorial onboarding。

**Architecture:** 接玩家到既有活世界流民動態,非新招募系統。投靠 reuse `subteam_system.merge_teams`（整團併入）+ 食物成本;觸發接既有 forced_interaction（U19 自動進場）;部署 emergent（既有 pop/技能聚合）;能力讀數暴露成 DTO（按真聚合算,非假數字）;tutorial 疊在投靠流程上。

**Tech Stack:** Godot 4.2.2 GDScript；headless + ui_flow；`.\tools\godot.ps1`（殺孤兒 godot 後單實例跑,避免 import lock 死鎖）。

依據 spec：`docs/superpowers/specs/2026-06-16-stage2-recruitment-design.md`。

**既有可用（不重寫）**：
- `subteam_system.merge_teams(state, absorber_id, absorbed_id)`（無額外參數 → `_merge_into` 整團併入:named append + `AnonTierSystem.transfer_proportional` + treasury merge + 統領 cap 檢查）。
- `_recruit_anon_internal`/`_recruit_named_internal`（coin 軌挖角,守恆,P3 已 emit 到互動選單）。
- forced 路徑:`PlayerApiMapper.map_forced_interaction`（產 responses）、`PlayerCommandSystem.respond_to_forced(state, response)`（match `fe.action` 分派 + 清 event）、`get_forced_response_options`;text_ui forced 模式（U19 `_process` 自動進場）。
- `PlayerApiMapper.map_controlled_team`（隊 DTO,含 food_days/armed_count/_armed_count/_food_days）。
- `HuntSystem.hunt_small_game` 公式（`chance = ACTIVE_BASE_CHANCE + avg求生×0.4`、`yield = FOOD_PER_GAME×(1+avg求生×0.3)`,`_avg_survival` = named[leader+named] 求生平均）。
- `AnonTierSystem.total_pop(t)`;`FOOD_PER_PERSON_PER_DAY=2.4`。

---

## 檔案結構

- `scripts/simulation/hunt_system.gd`（改）：`hunt_preview(state, team)` dry-run（回 {survival, chance, yield}）+ 公開 `_avg_survival`。
- `scripts/simulation/player_api_mapper.gd`（改）：`map_controlled_team` 加 `capabilities` 區塊。
- `scripts/simulation/player_command_system.gd`（改）：`_accept_join_request` + `respond_to_forced` 加 join_request 分派 + `get_forced_response_options`。
- `scripts/simulation/player_api_mapper.gd`（改）：`map_forced_interaction` 加 join_request branch。
- `scripts/simulation/faction_ai_system.gd`（改）：SurvivalJoin 對玩家 → 寫 join_request forced_event（非自動 merge）。
- `scripts/simulation/recruit_tutorial.gd`（新）：tutorial onboarding（閾值 → spawn + join_request + flag）。
- `scripts/simulation/sim_runner.gd`（改）：每 tick 呼 tutorial check。
- `scripts/ui/text_ui_main.gd`（改）：status 顯 capabilities + 招募 delta feedback。
- `scripts/debug/headless_test.gd` / `ui_flow_test.gd`（改）：測試。

**常數（TEST VALUE,放 player_command_system.gd 頂）**：
```gdscript
const JOIN_ONBOARD_MEAL: float = 0.8       # 一餐 ≈ FOOD_PER_PERSON_PER_DAY/3
const TUTORIAL_FOOD_THRESHOLD: float = 60.0  # 玩家食物盈餘觸發 tutorial
```

---

## Task 1: 能力 DTO + legibility

**Files:**
- Modify: `scripts/simulation/hunt_system.gd`
- Modify: `scripts/simulation/player_api_mapper.gd`
- Modify: `scripts/ui/text_ui_main.gd`
- Test: `scripts/debug/headless_test.gd`, `scripts/debug/ui_flow_test.gd`

- [ ] **Step 1: 寫失敗測試（DTO capabilities）** — `headless_test.gd`

```gdscript
func _test_team_capabilities_dto() -> void:
	print("--- 隊能力 DTO ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var leader := PersonData.new(); leader.id = 0; leader.team_id = 0
	leader.skills = {"求生": 0.5, "戰鬥": 0.4}
	state.persons[0] = leader; state.player_id = 0
	var pt := TeamData.new(); pt.team_id = 0; pt.leader_id = 0; pt.population = 4
	pt.tile_pos = Vector2i(4,4); pt.resources = {"food": 40.0}
	state.teams[0] = pt
	var d: Dictionary = PlayerApiMapper.map_controlled_team(state)
	var cap: Dictionary = d.get("capabilities", {})
	assert(cap.has("hunt_chance") and cap.has("hunt_yield"), "獵率/產出")
	assert(cap.has("combat_power"), "戰力")
	assert(abs(cap.get("food_burn_per_day", 0.0) - 4 * 2.4) < 0.01, "日耗 pop×2.4")
	assert(cap.get("hunt_survival", 0.0) > 0.4, "求生平均反映 leader 求生")
	print("隊能力 DTO OK")
```

- [ ] **Step 2: 跑確認失敗** — `capabilities` 不存在。

- [ ] **Step 3: 實作**

`hunt_system.gd`（dry-run preview + 公開求生平均,DRY 共用公式）：
```gdscript
# dry-run:不消耗,回隊狩獵能力（按真公式 chance/yield）。能力讀數 legibility 用。
func hunt_preview(state: WorldState, team: TeamData) -> Dictionary:
	var survival: float = _avg_survival(state, team)
	return {
		"survival": survival,
		"chance":   clampf(ACTIVE_BASE_CHANCE + survival * 0.4, 0.0, 0.95),
		"yield":    FOOD_PER_GAME * (1.0 + survival * 0.3),
	}
```
（`_avg_survival` 既有,保留;`hunt_preview` 為新 public dry-run。）

`player_api_mapper.gd` `map_controlled_team` return 區塊加（在 `"task_summary"` 後）：
```gdscript
		"task_summary": t.current_task,
		"capabilities": _team_capabilities(state, t),
	}

# 隊級能力讀數（按真技能聚合算,非假數字）：狩獵=named avg求生、戰力=武裝+named戰鬥、日耗=pop×2.4
static func _team_capabilities(state: WorldState, t: TeamData) -> Dictionary:
	var hp: Dictionary = load("res://scripts/simulation/hunt_system.gd").new().hunt_preview(state, t)
	var combat: float = float(_armed_count(t))
	for mid in ([t.leader_id] as Array) + t.named_members:
		var m: PersonData = state.persons.get(mid)
		if m != null: combat += float(m.skills.get("戰鬥", 0.0))
	return {
		"hunt_survival":     hp["survival"],
		"hunt_chance":       hp["chance"],
		"hunt_yield":        hp["yield"],
		"combat_power":      combat,             # proxy:武裝數 + named 戰鬥技能和（與遭遇戰上場概念對齊）
		"food_burn_per_day": float(t.population) * FOOD_PER_PERSON_PER_DAY,
	}
```

- [ ] **Step 4: 跑確認通過** — `隊能力 DTO OK`

- [ ] **Step 5: 寫失敗測試（UI 顯示）** — `ui_flow_test.gd`

```gdscript
func _test_capabilities_shown() -> void:
	print("\n── 隊能力讀數顯示 ──")
	var node = await _make_ui()
	# status label 應含能力讀數關鍵字
	var s: String = node._state_label.text
	_check("status 含獵率", s.contains("獵") or s.contains("狩獵"))
	_check("status 含戰力", s.contains("戰力"))
	_check("status 含日耗", s.contains("日耗") or s.contains("耗"))
	await _free_ui(node)
```

- [ ] **Step 6: 跑確認失敗**

- [ ] **Step 7: 實作 UI** — `text_ui_main.gd` status 組字處（`_build_status`/`_state_label` 更新處）加一行讀 `controlled_team.capabilities`：
```gdscript
	var cap: Dictionary = ct.get("capabilities", {})
	status_lines.append("狩獵 %d%%/%.0f糧  戰力 %.0f  日耗 %.1f食(撐%.0f天)" % [
		int(float(cap.get("hunt_chance", 0.0)) * 100), float(cap.get("hunt_yield", 0.0)),
		float(cap.get("combat_power", 0.0)), float(cap.get("food_burn_per_day", 0.0)),
		float(ct.get("food_days", 0.0))])
```
（對齊現行 status 組字位置與 `ct` 變數名;`ct` = `_bridge.query_controlled_team()` 或既有 status DTO 取得處。）

- [ ] **Step 8: 跑確認通過** — `隊能力讀數顯示` PASS
- [ ] **Step 9: Commit**

```bash
git add scripts/simulation/hunt_system.gd scripts/simulation/player_api_mapper.gd scripts/ui/text_ui_main.gd scripts/debug/headless_test.gd scripts/debug/ui_flow_test.gd
git commit -m "feat(stage2): 隊能力讀數 DTO + status 顯示（按真技能聚合,emergent legibility）"
```

---

## Task 2: 投靠核心（食物軌整團併入）

**Files:**
- Modify: `scripts/simulation/player_command_system.gd`
- Test: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_accept_join_request() -> void:
	print("--- 投靠核心(食物併入) ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var leader := PersonData.new(); leader.id = 0; leader.team_id = 0
	leader.skills = {"統領": 0.5}   # 撐 pop cap
	state.persons[0] = leader; state.player_id = 0
	var pt := TeamData.new(); pt.team_id = 0; pt.leader_id = 0; pt.population = 2
	pt.tile_pos = Vector2i(4,4); pt.resources = {"food": 50.0, "coin": 10}
	state.teams[0] = pt
	# 絕境流民團(3 anon)
	var ds := TeamData.new(); ds.team_id = 1; ds.population = 3; ds.tile_pos = Vector2i(4,4)
	ds.resources = {"coin": 5}; ds.anon_treasury = 6.0
	state.teams[1] = ds
	var coin_before: float = float(pt.resources.get("coin",0)) + pt.anon_treasury \
		+ float(ds.resources.get("coin",0)) + ds.anon_treasury
	var cs := PlayerCommandSystem.new()
	var r: Dictionary = cs._accept_join_request(state, 1)
	assert(r.get("ok", false), "投靠應成功:%s" % str(r))
	assert(pt.population == 5, "玩家 pop 2→5,實際=%d" % pt.population)
	# 食物扣 = MEAL × 3
	assert(abs(float(pt.resources.get("food",0)) - (50.0 - PlayerCommandSystem.JOIN_ONBOARD_MEAL * 3)) < 0.01, "扣 onboarding 食物")
	# coin 守恆:併入後玩家 coin = 原玩家 + 流民(merge_teams 帶 treasury/coin),總額不變
	var coin_after: float = float(pt.resources.get("coin",0)) + pt.anon_treasury
	assert(abs(coin_after - coin_before) < 0.01, "coin 守恆,before=%.1f after=%.1f" % [coin_before, coin_after])
	print("投靠核心 OK")
```

- [ ] **Step 2: 跑確認失敗** — `_accept_join_request` 未定義。

- [ ] **Step 3: 實作** — `player_command_system.gd`：

```gdscript
const JOIN_ONBOARD_MEAL: float = 0.8   # 一餐 ≈ FOOD_PER_PERSON_PER_DAY/3 (TEST VALUE)

# 投靠收留:扣 onboarding 食物（MEAL×對方人數,被吃掉=合法消耗）+ 整團併入（reuse merge_teams,守恆）
func _accept_join_request(state: WorldState, from_id: int) -> Dictionary:
	var pt: TeamData = _get_player_team(state)
	var from_team: TeamData = state.teams.get(from_id)
	if pt == null or from_team == null:
		return { "ok": false, "msg": "對象不存在" }
	if pt.tile_pos != from_team.tile_pos:
		return { "ok": false, "msg": "需同格才能收留" }
	var cost: float = JOIN_ONBOARD_MEAL * float(from_team.population)
	if float(pt.resources.get("food", 0)) < cost:
		return { "ok": false, "msg": "食物不足收留（需%.1f）" % cost }
	var joined: int = from_team.population
	pt.resources["food"] = float(pt.resources.get("food", 0)) - cost   # 餵他們進來:吃掉,食物非守恆
	SubteamSystem.new().merge_teams(state, pt.team_id, from_id)         # 整團併入:pop/named/tier/treasury 守恆
	return { "ok": true, "msg": "收留 %d 人（食物 -%.1f）" % [joined, cost],
		"payload": {"joined": joined, "food_cost": cost} }
```
（確認 `SubteamSystem` class_name 與檔名;merge_teams 無額外參數 → 整團併入 `_merge_into`。)

- [ ] **Step 4: 跑確認通過** — `投靠核心 OK`
- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/player_command_system.gd scripts/debug/headless_test.gd
git commit -m "feat(stage2): 投靠核心 _accept_join_request（食物 onboarding + reuse merge_teams 整團併入,守恆）"
```

---

## Task 3: 觸發流程（NPC join_request forced + 玩家招 coin）

**Files:**
- Modify: `scripts/simulation/player_command_system.gd`（respond_to_forced + options）
- Modify: `scripts/simulation/player_api_mapper.gd`（map_forced_interaction join_request branch）
- Modify: `scripts/simulation/faction_ai_system.gd`（NPC SurvivalJoin 對玩家 → forced）
- Test: `scripts/debug/headless_test.gd`, `scripts/debug/ui_flow_test.gd`

- [ ] **Step 1: 寫失敗測試（NPC 觸發 + 回應）** — `headless_test.gd`

```gdscript
func _test_join_request_trigger_and_respond() -> void:
	print("--- join_request 觸發+回應 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var leader := PersonData.new(); leader.id = 0; leader.team_id = 0; leader.skills = {"統領": 0.5}
	state.persons[0] = leader; state.player_id = 0
	var pt := TeamData.new(); pt.team_id = 0; pt.leader_id = 0; pt.population = 2
	pt.tile_pos = Vector2i(4,4); pt.resources = {"food": 50.0}
	state.teams[0] = pt
	# 絕境流民同格(food_days 低 → 應發投靠)
	var ds := TeamData.new(); ds.team_id = 1; ds.population = 3; ds.tile_pos = Vector2i(4,4)
	ds.resources = {"food": 0.0}; ds.current_task = "乞食"
	state.teams[1] = ds
	var fai := FactionAISystem.new()
	fai._maybe_request_join_player(state, ds)   # 絕境同格 → 寫 forced_event
	assert(state.player_forced_event.get("action", "") == "join_request", "應發 join_request")
	assert(int(state.player_forced_event.get("from_id", -1)) == 1, "from_id=1")
	# 回應 accept → 併入
	var cs := PlayerCommandSystem.new()
	var r: Dictionary = cs.respond_to_forced(state, "accept")
	assert(r.get("ok", false) and pt.population == 5, "accept 收留 pop→5")
	assert(state.player_forced_event.is_empty(), "event 已清")
	print("join_request 觸發+回應 OK")
```

- [ ] **Step 2: 跑確認失敗**

- [ ] **Step 3: 實作**

`faction_ai_system.gd`：在 SurvivalJoin 決策處（`[SurvivalJoin]` print 附近,team 選定 投靠 target 時），若 target 為玩家隊則改寫 forced_event：
```gdscript
# 絕境團投靠對象是玩家 → 不自動 merge,寫 forced_event 讓玩家決定（對稱:NPC 投靠 NPC 仍自動）
func _maybe_request_join_player(state: WorldState, team: TeamData) -> bool:
	var pp: PersonData = state.persons.get(state.player_id) if state.player_id != -1 else null
	if pp == null: return false
	var ptid: int = pp.team_id
	var ppt: TeamData = state.teams.get(ptid)
	if ppt == null or ppt.tile_pos != team.tile_pos: return false   # 同格才求
	if not state.player_forced_event.is_empty(): return false        # 已有待處理 event
	state.player_forced_event = { "action": "join_request", "from_id": team.team_id }
	state.player_forced_event_id = str(randi())
	print("[JoinRequest] 流民 Team%d 求投靠玩家 Team%d" % [team.team_id, ptid])
	return true
```
在既有 SurvivalJoin 邏輯:選定 ally_id == 玩家隊時 → 呼 `_maybe_request_join_player` 取代自動 merge（NPC→NPC 維持自動）。

`player_command_system.gd` `respond_to_forced` match 加：
```gdscript
		"join_request":
			if response == "accept":
				result = _accept_join_request(state, fe.get("from_id", -1))
			else:
				result = { "ok": true, "msg": "婉拒收留" }
```
`get_forced_response_options` 加：`"join_request": return ["accept", "refuse"]`。

`player_api_mapper.gd` `map_forced_interaction` 加 branch（仿既有 diplomacy）：
```gdscript
		"join_request":
			var fid: int = int(evt.get("from_id", -1))
			var ft: TeamData = state.teams.get(fid)
			var n: int = ft.population if ft != null else 0
			responses = [
				{ "response_id": "accept", "label": "收留（食物 -%.1f,+%d 人）" % [
					PlayerCommandSystem.JOIN_ONBOARD_MEAL * n, n],
				  "command_args": {"interaction_id": iid, "response_id": "accept"} },
				{ "response_id": "refuse", "label": "✗ 婉拒",
				  "command_args": {"interaction_id": iid, "response_id": "refuse"} },
			]
```
（對齊既有 responses 組法 + `resolve_forced_response` 把 response_id 導到 `respond_to_forced`。確認 forced response command 路徑:UI 送 response_id → resolve_forced_response/respond_to_forced。）

- [ ] **Step 4: 跑確認通過** — `join_request 觸發+回應 OK`

- [ ] **Step 5: ui_flow 測（forced 收留流程）**

```gdscript
func _test_join_request_ui() -> void:
	print("\n── join_request 收留 UI ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var ptid: int = st.persons[st.player_id].team_id
	st.teams[ptid].resources["food"] = 50.0
	var ppos = st.teams[ptid].tile_pos
	var ds := TeamData.new(); ds.team_id = 8888; ds.population = 3; ds.tile_pos = ppos
	st.teams[8888] = ds
	st.player_forced_event = {"action": "join_request", "from_id": 8888}
	st.player_forced_event_id = "t1"
	node._process(0.1)   # U19 自動進 forced 模式
	var s: String = node._event_label.text
	_check("forced 顯收留選項", s.contains("收留") or s.contains("投靠") or s.contains("婉拒"))
	await _free_ui(node)
```

- [ ] **Step 6: 跑確認通過** — `join_request 收留 UI` PASS
- [ ] **Step 7: Commit**

```bash
git add scripts/simulation/player_command_system.gd scripts/simulation/player_api_mapper.gd scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd scripts/debug/ui_flow_test.gd
git commit -m "feat(stage2): 投靠觸發流程（NPC 絕境同格→join_request forced + 收留/婉拒回應）"
```

> 玩家主動招（coin 軌）= 既有 recruit_anon（P3 已 emit 到互動選單）,**本 task 不改**,僅確認互動選單對同格隊仍可付 coin 招募。

---

## Task 4: tutorial onboarding

**Files:**
- Create: `scripts/simulation/recruit_tutorial.gd`
- Modify: `scripts/simulation/sim_runner.gd`
- Test: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_recruit_tutorial() -> void:
	print("--- tutorial onboarding ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var leader := PersonData.new(); leader.id = 0; leader.team_id = 0; leader.skills = {"統領": 0.5}
	state.persons[0] = leader; state.player_id = 0
	var pt := TeamData.new(); pt.team_id = 0; pt.leader_id = 0; pt.population = 1
	pt.tile_pos = Vector2i(4,4); pt.resources = {"food": 100.0}   # 盈餘 > 閾值
	state.teams[0] = pt
	var tut := RecruitTutorial.new()
	tut.check(state)
	assert(state.get("recruit_tutorial_fired") == null or true, "")  # flag 存 player_state
	assert(bool(state.player_state.get("recruit_tutorial_fired", false)), "tutorial 應觸發設 flag")
	assert(state.player_forced_event.get("action", "") == "join_request", "送 join_request")
	var tid: int = int(state.player_forced_event.get("from_id", -1))
	var tut_team: TeamData = state.teams.get(tid)
	assert(tut_team != null and tut_team.population == 4, "1 named+3 anon=4")
	assert(tut_team.leader_id != -1, "有堪用 named")
	# 二次呼不重複
	state.player_forced_event = {}
	tut.check(state)
	assert(state.player_forced_event.is_empty(), "一次性:不再觸發")
	print("tutorial onboarding OK")
```

- [ ] **Step 2: 跑確認失敗** — `RecruitTutorial` 不存在。

- [ ] **Step 3: 實作** — `scripts/simulation/recruit_tutorial.gd`：

```gdscript
class_name RecruitTutorial

const FOOD_THRESHOLD: float = 60.0   # TEST VALUE

# 一次性:玩家食物盈餘到閾值 → 旁生 1 堪用 named + 3 tier0 anon 流民團 + 發 join_request
func check(state: WorldState) -> void:
	if bool(state.player_state.get("recruit_tutorial_fired", false)): return
	var pp: PersonData = state.persons.get(state.player_id) if state.player_id != -1 else null
	if pp == null: return
	var pt: TeamData = state.teams.get(pp.team_id)
	if pt == null or float(pt.resources.get("food", 0)) < FOOD_THRESHOLD: return
	if not state.player_forced_event.is_empty(): return
	# 生 tutorial 流民團
	var tid: int = _next_team_id(state)
	var team := TeamData.new(); team.team_id = tid; team.tile_pos = pt.tile_pos
	team.current_task = "投靠"
	var nl := PersonData.new(); nl.id = _next_person_id(state)
	nl.team_id = tid; nl.person_name = "投奔者"; nl.role = "leader"
	nl.skills = {"狩獵": 0.5, "求生": 0.5, "戰鬥": 0.4}   # 略偏堪用
	nl.loyalty = 0.9                                       # 忠誠偏高
	state.persons[nl.id] = nl; team.leader_id = nl.id
	team.population = 4                                     # 1 named + 3 tier0 anon
	AnonTierSystem.set_tier_pop(team, 0, 3)                # 3 白丁(確認 API 名;否則直接設 population + tier dict)
	state.teams[tid] = team
	state.player_forced_event = { "action": "join_request", "from_id": tid }
	state.player_forced_event_id = str(randi())
	state.player_state["recruit_tutorial_fired"] = true
	print("[Tutorial] 投奔者小隊 Team%d 求投靠玩家" % tid)

func _next_team_id(state: WorldState) -> int:
	var m: int = 0
	for k in state.teams: m = maxi(m, int(k))
	return m + 1

func _next_person_id(state: WorldState) -> int:
	var m: int = 0
	for k in state.persons: m = maxi(m, int(k))
	return m + 1
```
（確認 `AnonTierSystem` 設 tier 人口的 API 實名;若無 `set_tier_pop`,改用既有 tier 初始化方式設 3 個 tier0。`_next_team_id`/`_next_person_id` 若 population_system 已有等價 helper 可 reuse。）

`sim_runner.gd`：tick 流程末（player 相關處理段）加：
```gdscript
	RecruitTutorial.new().check(state)
```
（放在 advance_tick 內,encounter/forced 處理之後;確認不與既有 forced_event 衝突——check 內已守 `forced_event 非空則跳過`。）

- [ ] **Step 4: 跑確認通過** — `tutorial onboarding OK`
- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/recruit_tutorial.gd scripts/simulation/sim_runner.gd scripts/debug/headless_test.gd
git commit -m "feat(stage2): tutorial onboarding（閾值一次性送 1堪用named+3 tier0 anon→join_request）"
```

---

## Task 5: 註冊 + 守恆/flow 整合

- [ ] **Step 1: 註冊** headless：`_test_team_capabilities_dto`、`_test_accept_join_request`、`_test_join_request_trigger_and_respond`、`_test_recruit_tutorial`;ui_flow：`_test_capabilities_shown`、`_test_join_request_ui`。
- [ ] **Step 2: 守恆整合測**（headless `_test_join_conservation`）：投靠收留前後 coin_eq（coin+treasury+ore）**不變**（食物非 coin_eq,只驗 coin/ore 守恆);food 確實減 onboarding 量。
- [ ] **Step 3: 全跑** — 殺孤兒 godot → `.\tools\godot.ps1 --headless --import` → headless / ui_logic / ui_flow 無新 SCRIPT ERROR、新測全綠。
- [ ] **Step 4: 短 sanity** — survival_start 2yr multi（`SIM_CONFIGS=survival_start`）:died=no、coin_eq delta=0、`[JoinRequest]`/`[Tutorial]` 出現（玩家自驅有限,至少 NPC join 路徑或 tutorial flag 觸發可見）。
- [ ] **Step 5: handback** — `docs/superpowers/handbacks/2026-06-16-stage2-recruitment.md`。真視覺（status 能力讀數版面、forced 收留選單觀感、招募 delta feedback）標待人工 run-verify。

---

## 注意事項（給實作者）

- **DRY**：投靠併入 reuse `merge_teams`(整團)、能力 hunt reuse `hunt_preview`、coin 軌 reuse `_recruit_anon_internal`。勿複製。
- **守恆**：食物 = 消耗品（onboarding 扣 = 吃掉,合法,不在 coin_eq）;coin/treasury 經 merge_teams 轉移守恆。Task 5 驗 coin_eq delta=0。
- **成本按觸發分流**：投靠（NPC 來）→食物;招募（玩家去）→coin（既有）。**投靠路徑無 coin、招募路徑無食物**。
- **emergent 部署**：不做每人任務指派 UI（YAGNI）。能力讀數按**真技能聚合**算（求生 named 平均 / 戰鬥逐個體 / 統領商業 leader-only）,combat_power 為對齊遭遇戰概念的 proxy,勿假造。
- **對稱性**：NPC→NPC 投靠維持自動 merge;只有投靠對象為玩家時改走 forced_event。
- **specialist→子隊** = 既有 `dispatch_subteam`,本 plan 不碰,只是招募餵得進去。
- **名稱核對**：`SubteamSystem`/`RecruitTutorial`/`AnonTierSystem` class_name、forced response command 路徑（resolve_forced_response→respond_to_forced）、status 組字位置（`ct`/`_state_label`）以現碼為準。
- godot 跑前殺孤兒進程（避免 import lock 死鎖）；headless `assert` 勿擋在 `quit()` 前無條件路徑（會 idle 卡死）。
- baseline Bug8 已修;勿引入新守恆破口。
