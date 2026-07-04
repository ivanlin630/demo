# P2a survival options（投靠/紮營/乞食）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:subagent-driven-development or executing-plans. Steps use checkbox (`- [ ]`).

**Goal:** 給 unified 隊（merchant/produce）加三個絕境 engine option（`投靠`/`紮營`/`乞食`），補齊 survival repertoire。無家深危 unified 隊按 leader 人格分流（義氣→投靠、野心→紮營、墊底→乞食），不再餓死。**閉藍圖標記1債之 join（敗商隊投靠=經濟↔衝突橋）**。

**Architecture:** 純加三個 engine option，複用既有 `_find_strong_neighbor`/`_find_unowned_farmable_tile`/`_find_aid_target`（target finder）+ `_join_pref`/`_camp_pref` 公式 + 既有 `TASK_JOIN`/`TASK_CAMP`/`TASK_BEG`（皆在 `SURVIVAL_TASKS`）。**non-unified 隊零改、不退役舊 `_evaluate_survival`/`_trigger_survival`（=P2b）、不動 ~20 test 直呼點**。只碰 `decision/` 三檔 + 測試 + `faction_ai` 兩處 wrinkle（camp-arrival hoist + player-join guard）。

**Tech Stack:** Godot 4.2.2 GDScript。測試 `scripts/debug/headless_test.gd`（`=== DONE ===` 無 `SCRIPT ERROR`）。

## Global Constraints

- **UTF-8 wrapper**：Godot 走 `.\tools\godot.ps1`（PowerShell）。worktree 子 session：每 Godot/git 前 `Set-Location` 進 worktree。
- **守恆**：join(`merge_teams`)/camp(立營免建材)/beg(施捨消耗品) 走既有守恆，本 plan **不碰守恆數學**。coin_eq delta=0 + InvariantAudit 0。
- **scope guard（P0/P1 教訓）**：**只做三 option（join/camp/beg）**。**不做 hunt**（無 TASK、P2b）。**不退役雙 owner、不碰 non-unified 路徑、不動 test 直呼 `_evaluate_survival`/`_trigger_survival` 點**。不新 TASK_*。不改 finder/crude-camp/forced-join 機制。**不加 exemption 鏈**。
- **believability**：三 option 由 applicable food_days gate（健康隊不入榜）→ TC1/4/6/7 零影響；危時序對齊舊行為（有家→返家補給、可覓食→覓食、無家無覓→人格分流 join/camp/beg）。
- 新常數 `# TEST VALUE`。
- baseline：開工前 `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd` 確認全綠。

---

### Task 1: 三 drive term + weight + DecisionContext 絕境目標欄

**Files:**
- Modify: `scripts/simulation/decision/terms.gd`（const + eval + weight）
- Modify: `scripts/simulation/decision/decision_context.gd`（新欄 + gather）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Consumes: `FactionAISystem.new()._find_strong_neighbor(state,team)->int`、`._find_unowned_farmable_tile(state,team)->Vector2i`、`._find_aid_target(state,team)->int`；`ctx.food_days`、`ctx.leader_values`、`ctx.has_own_outpost`。
- Produces: ctx 欄 `has_strong_neighbor`/`strong_neighbor_id`/`strong_neighbor_pos`/`has_farmable_tile`/`farmable_pos`/`has_aid_target`/`aid_target_id`/`aid_target_pos`；term `join_drive`/`camp_drive`/`beg_drive` eval、weight key `join`/`camp`/`beg`。

- [ ] **Step 1: 讀 terms.gd（eval `(term,ctx,opt)` / weight `(term,leader_values)`，既有 survival_pressure 重標度法）+ decision_context.gd gather() 既有 `_find_weakest_prey` 呼叫風格。**

- [ ] **Step 2: 寫 failing test**
```gdscript
func _test_p2a_survival_terms() -> void:
	# weight 人格分流（複用 _join_pref/_camp_pref 公式）
	var loyal := {"義氣": 0.9, "信義": 0.8, "求生欲": 0.7}
	var ambitious := {"野心": 0.9, "統領": 0.8, "求生欲": 0.7}
	var w_join: float = DecisionTerms.weight("join", loyal)
	var w_camp: float = DecisionTerms.weight("camp", ambitious)
	assert(w_join > 0.7, "[p2a] join weight 太低 %.2f" % w_join)    # 0.9*0.4+0.8*0.3+0.7*0.3=0.81
	assert(w_camp > 0.7, "[p2a] camp weight 太低 %.2f" % w_camp)    # 0.9*0.4+0.8*0.3+0.7*0.3=0.81
	# drive：吃飽→0（健康隊不選）、危時>0
	var ctx_full := DecisionContext.new()
	ctx_full.food_days = 5.0; ctx_full.has_strong_neighbor = true
	var ctx_crisis := DecisionContext.new()
	ctx_crisis.food_days = 0.5; ctx_crisis.has_strong_neighbor = true
	assert(DecisionTerms.eval("join_drive", ctx_full, "投靠") == 0.0, "[p2a] 健康隊 join_drive 非 0")
	assert(DecisionTerms.eval("join_drive", ctx_crisis, "投靠") > 0.0, "[p2a] 危時 join_drive=0")
	# beg < join（墊底）同 ctx
	ctx_crisis.has_aid_target = true
	assert(DecisionTerms.eval("beg_drive", ctx_crisis, "乞食") \
		< DecisionTerms.eval("join_drive", ctx_crisis, "投靠"), "[p2a] beg 未低於 join")
	print("[p2a] survival terms OK join_w=%.2f camp_w=%.2f" % [w_join, w_camp])
```

- [ ] **Step 3: 跑測確認 FAIL**（weight/eval 未定義 → 回 0/0.5 預設 → assert fail）

- [ ] **Step 4: 實作**

`terms.gd` 加常數：
```gdscript
const DESPERATION_DAYS: float = 3.0    # TEST VALUE — 食物低於此才入絕境 option（對齊 WARNING_DAYS）
const DESPERATION_SCALE: float = 1.2   # TEST VALUE — 絕境 drive 量級（對齊 survival-class 域，不�is碾壓 forage/restock）
const BEG_FLOOR_FACTOR: float = 0.5    # TEST VALUE — 乞食墊底（drive 略低於 join/camp）
```
eval() 加（共用 desperation magnitude）：
```gdscript
		"join_drive":
			if opt != "投靠" or not ctx.has_strong_neighbor: return 0.0
			return DESPERATION_SCALE * maxf(0.0, DESPERATION_DAYS - ctx.food_days)
		"camp_drive":
			if opt != "紮營" or not ctx.has_farmable_tile: return 0.0
			return DESPERATION_SCALE * maxf(0.0, DESPERATION_DAYS - ctx.food_days)
		"beg_drive":
			if opt != "乞食" or not ctx.has_aid_target: return 0.0
			return DESPERATION_SCALE * BEG_FLOOR_FACTOR * maxf(0.0, DESPERATION_DAYS - ctx.food_days)
```
weight() 加（對齊 `_join_pref`/`_camp_pref`）：
```gdscript
		"join": return float(v.get("義氣", 0.5)) * 0.4 \
			+ float(v.get("信義", 0.5)) * 0.3 + float(v.get("求生欲", 0.5)) * 0.3
		"camp": return float(v.get("野心", 0.5)) * 0.4 \
			+ float(v.get("統領", 0.0)) * 0.3 + float(v.get("求生欲", 0.5)) * 0.3
		"beg":  return float(v.get("求生欲", 0.5))   # 人人可乞，墊底由 drive×BEG_FLOOR 壓低
```

`decision_context.gd` 宣告新欄：
```gdscript
var has_strong_neighbor: bool = false
var strong_neighbor_id: int = -1
var strong_neighbor_pos: Vector2i = Vector2i(-1, -1)
var has_farmable_tile: bool = false
var farmable_pos: Vector2i = Vector2i(-1, -1)
var has_aid_target: bool = false
var aid_target_id: int = -1
var aid_target_pos: Vector2i = Vector2i(-1, -1)
```
gather() 加（複用 finder，仿既有 `_find_weakest_prey` 風格）：
```gdscript
	var _fa := FactionAISystem.new()
	var _sn: int = _fa._find_strong_neighbor(state, team)
	c.has_strong_neighbor = _sn != -1
	c.strong_neighbor_id = _sn
	c.strong_neighbor_pos = state.teams[_sn].tile_pos if _sn != -1 else Vector2i(-1, -1)
	var _ft: Vector2i = _fa._find_unowned_farmable_tile(state, team)
	c.has_farmable_tile = _ft != Vector2i(-1, -1)
	c.farmable_pos = _ft
	var _aid: int = _fa._find_aid_target(state, team)
	c.has_aid_target = _aid != -1
	c.aid_target_id = _aid
	c.aid_target_pos = state.teams[_aid].tile_pos if _aid != -1 else Vector2i(-1, -1)
```
> 註：gather 已 new 多個 FactionAISystem 呼 finder；可共用一個 `_fa` 局部變數（既有亦 `FactionAISystem.new()` 多次，效能非本塊關注，但共用較淨）。

- [ ] **Step 5: 跑測 PASS + 既有全綠**

- [ ] **Step 6: Commit**
```
git add scripts/simulation/decision/terms.gd scripts/simulation/decision/decision_context.gd scripts/debug/headless_test.gd
git commit -m "feat(decision): 投靠/紮營/乞食 drive term + weight + ctx 絕境目標欄 (P2a)"
```

---

### Task 2: 三 option（REGISTRY/applicable/to_task）+ W1 camp-arrival hoist + W2 player-join guard

**Files:**
- Modify: `scripts/simulation/decision/options.gd`（REGISTRY + applicable + to_task）
- Modify: `scripts/simulation/faction_ai_system.gd`（W1 camp-arrival hoist、W2 `_decide_unified` player-join guard）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Consumes: ctx 絕境欄（Task 1）；`TeamData.TASK_JOIN`/`TASK_CAMP`/`TASK_BEG`；`_maybe_request_join_player`、`establish_crude_camp`（既有）。
- Produces: option `投靠`/`紮營`/`乞食` 可被 rank 選中 → 對應 TASK + target + combat_target；unified 隊選 `紮營` 到達能立營；投靠玩家走 forced_event。

- [ ] **Step 1: 讀 options.gd（applicable match、to_task）+ faction_ai `_evaluate_survival`(2234-2293, 確認 camp-arrival 2263-2275 / unified gate 2237 / player early-return 2235) + `_decide_unified`(847-863) + `_maybe_request_join_player`(2531).**

- [ ] **Step 2: 寫 failing test**
```gdscript
func _test_p2a_survival_options() -> void:
	var state := WorldState.new()
	var cfg := {"map": {"radius": 5, "resource_richness": 5}, "teams": []}
	GameSetup.setup(state, cfg)
	var fa := FactionAISystem.new()
	# (a) 無家深危 + 義氣高 unified 隊 + 鄰強鄰 → 投靠
	var joiner := _mk_unified_desperate_team(state, Vector2i(2,2), {"義氣":0.9,"信義":0.8,"求生欲":0.8})
	_mk_strong_neighbor_team(state, Vector2i(3,2), joiner)   # pop>1.5×、可達、rep>0.3、非同 faction、入 team_discovered
	fa._decide_unified(state, joiner)
	assert(joiner.current_task == TeamData.TASK_JOIN, "[p2a] 義氣隊未投靠 task=%s" % joiner.current_task)
	assert(joiner.combat_target != -1, "[p2a] 投靠未設 combat_target")
	# (b) 無家深危 + 野心高 + 鄰有無主可農地 → 紮營
	var camper := _mk_unified_desperate_team(state, Vector2i(6,6), {"野心":0.9,"統領":0.8,"求生欲":0.8})
	# (6,6) 鄰需有無主可農 plains（GameSetup 預設地形；必要時 _mk 設 tile）
	fa._decide_unified(state, camper)
	assert(camper.current_task == TeamData.TASK_CAMP, "[p2a] 野心隊未紮營 task=%s" % camper.current_task)
	# (c) 健康 unified 隊（food 足）+ 同情境 → 不選絕境 option
	var healthy := _mk_unified_desperate_team(state, Vector2i(2,2), {"義氣":0.9})
	healthy.resources["food"] = 9999.0   # food_days >> DESPERATION
	_mk_strong_neighbor_team(state, Vector2i(3,2), healthy)
	fa._decide_unified(state, healthy)
	assert(healthy.current_task != TeamData.TASK_JOIN, "[p2a] 健康隊竟投靠")
	print("[p2a] survival options OK")

func _test_p2a_camp_arrival() -> void:
	# W1: unified 隊持 TASK_CAMP 站在無主可農地 → _evaluate_survival 立營（hoist 到 unified gate 前）
	var state := WorldState.new()
	var cfg := {"map": {"radius": 4, "resource_richness": 5}, "teams": []}
	GameSetup.setup(state, cfg)
	var fa := FactionAISystem.new()
	var t := _mk_unified_desperate_team(state, Vector2i(1,1), {"野心":0.9})
	# 確保 (1,1) 為無主可農 plains（必要時設 tile.terrain/outpost_owner）
	t.current_task = TeamData.TASK_CAMP
	t.move_target = Vector2i(1,1)
	t.task_priority = TaskArbiter.PRIO_DISPATCH
	fa._evaluate_survival(state, t)
	var tile: HexTileData = state.world.tiles.get(1*1000 + 1)
	assert(tile.outpost_owner == t.team_id, "[p2a] unified 隊 camp 到達未立營（W1 hoist 失敗）")
	print("[p2a] camp arrival hoist OK")

func _test_p2a_join_player_forced() -> void:
	# W2: unified NPC 同格玩家投靠 → forced_event 非自動 merge
	var state := WorldState.new()
	var cfg := {"map": {"radius": 4, "resource_richness": 5}, "teams": []}
	GameSetup.setup(state, cfg)
	var fa := FactionAISystem.new()
	# 造玩家隊 @ (2,2) 設 strong + player_id；造 unified 絕境 NPC 同格義氣高
	var pteam := _mk_player_strong_team(state, Vector2i(2,2))
	var npc := _mk_unified_desperate_team(state, Vector2i(2,2), {"義氣":0.9,"信義":0.8,"求生欲":0.8})
	# 確保 _find_strong_neighbor(npc) == pteam（pop/rep/可達/discovered）
	fa._decide_unified(state, npc)
	assert(not state.player_forced_event.is_empty(), "[p2a] 投靠玩家未寫 forced_event（W2）")
	assert(state.player_forced_event.get("action") == "join_request", "[p2a] forced_event 非 join_request")
	print("[p2a] join player forced OK")
```
> helper（仿既有造隊 helper）：`_mk_unified_desperate_team(state,pos,values)`（TAG_MERCHANT、leader 給 values、food 設低使 food_days<DESPERATION、無 own outpost）、`_mk_strong_neighbor_team`（pop>1.5×目標、入目標 team_discovered、rep 0.5、可達、獨立 faction）、`_mk_player_strong_team`（設 state.player_id + leader_id=player + strong）。camp 測須確保腳下/鄰格無主可農 plains（非山）。

- [ ] **Step 3: 跑測確認 FAIL**

- [ ] **Step 4: 實作**

`options.gd` REGISTRY 加：
```gdscript
	"投靠": [["join_drive", "join"]],
	"紮營": [["camp_drive", "camp"]],
	"乞食": [["beg_drive",  "beg"]],
```
applicable() match 加：
```gdscript
			"投靠":
				if ctx.food_days < DecisionTerms.DESPERATION_DAYS and ctx.has_strong_neighbor: out.append(opt)
			"紮營":
				if ctx.food_days < DecisionTerms.DESPERATION_DAYS and ctx.has_farmable_tile \
						and not ctx.has_own_outpost: out.append(opt)
			"乞食":
				if ctx.food_days < DecisionTerms.DESPERATION_DAYS and ctx.has_aid_target: out.append(opt)
```
to_task() match 加（簽名 `(state,team,opt)` 無 ctx → 直呼 finder，與既有 `掠奪`/`覓食` 一致）：
```gdscript
		"投靠":
			var sn: int = FactionAISystem.new()._find_strong_neighbor(state, team)
			if sn == -1: return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
			return {"task": TeamData.TASK_JOIN, "target": state.teams[sn].tile_pos, "combat_target": sn}
		"紮營":
			var ft: Vector2i = FactionAISystem.new()._find_unowned_farmable_tile(state, team)
			if ft == Vector2i(-1,-1): return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
			return {"task": TeamData.TASK_CAMP, "target": ft}
		"乞食":
			var aid: int = FactionAISystem.new()._find_aid_target(state, team)
			if aid == -1: return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
			return {"task": TeamData.TASK_BEG, "target": state.teams[aid].tile_pos, "combat_target": aid}
```

`faction_ai_system.gd` **W1 camp-arrival hoist**：把現 2263-2275 的 camp-arrival block（`if team.current_task == TeamData.TASK_CAMP: ... establish_crude_camp ... release`）**整段移到 line 2237 unified gate 之前**（player early-return 2235 之後、unified gate 之前）。移後該 block 不依賴 `days_left`（在食物計算前），對所有持 TASK_CAMP 隊成立。非 unified 隊行為不變（原走到此）。**留意**：移走後原位（2263）刪除，避免雙存在。

`faction_ai_system.gd` **W2 `_decide_unified` player-join guard**：在 to_task 後、`TaskArbiter.try_set` 前，對 `投靠` 加：
```gdscript
		# 投靠玩家：走 forced_event（玩家決定收留），不自動 merge（對稱 + UX）
		if opt == "投靠" and td.has("combat_target"):
			var pp: PersonData = state.persons.get(state.player_id) if state.player_id != -1 else null
			if pp != null and int(td["combat_target"]) == pp.team_id:
				if _maybe_request_join_player(state, team):
					return
```
（放在 `var td := ...` 之後、`team.current_option = opt` 前後皆可，但須在 try_set 前 return；對齊既有 dispatch 結構。）

- [ ] **Step 5: 跑測 PASS + 既有全綠**

確認 TC1/4/6/7 + 既有 decision/絕境/camp/beg/join/飢餓測原樣。non-unified 路徑零改。

- [ ] **Step 6: Commit**
```
git add scripts/simulation/decision/options.gd scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(decision): 投靠/紮營/乞食 option + camp-arrival hoist + player-join guard (P2a)"
```

---

### Task 3: believability 驗序 + world_sim 量測

**Files:**
- Test: `scripts/debug/headless_test.gd`
- 量測: world_sim 2yr + game_sim_multi 守恆

**Interfaces:** Consumes 全鏈。Produces 信心：危時序對齊（有家→返家、可覓食→覓食、無家無覓→人格分流）、敗商隊投靠 emergent、non-unified 不變、無 over-camp/join。

- [ ] **Step 1: 寫 believability 驗序測**
```gdscript
func _test_p2a_survival_priority() -> void:
	var state := WorldState.new()
	var cfg := {"map": {"radius": 5, "resource_richness": 5}, "teams": []}
	GameSetup.setup(state, cfg)
	var fa := FactionAISystem.new()
	# (a) 有家深危 unified 隊 → 返家補給量級支配（非 join/camp）
	var homed := _mk_unified_desperate_team(state, Vector2i(2,2), {"義氣":0.9})
	# 給 homed 一個遠 own outpost（has_home_outpost=true、has_own_outpost 視距離）→ restock 應贏
	_give_home_outpost(state, homed, Vector2i(0,0))
	_mk_strong_neighbor_team(state, Vector2i(3,2), homed)
	fa._decide_unified(state, homed)
	assert(homed.current_task == TeamData.TASK_RETURN_HOME, "[p2a] 有家危隊未返家補給 task=%s" % homed.current_task)
	# (b) 無家深危 + 可覓食（pop 小）+ 弱人格 → 覓食贏 join/camp（覓食量級）
	#   或：若設計讓 join 與 forage 同域，至少驗「無 over-camp」——擇一明確 assert
	print("[p2a] survival priority OK")
```
> 序對齊以 spec 為準：restock（有家）量級最高、forage（可覓食）次、join/camp/beg（無家無覓的人格分流）。若量測顯量級需調，動 `DESPERATION_SCALE`（TEST VALUE）+ 記 plan 偏差。

- [ ] **Step 2: 跑測 PASS**

- [ ] **Step 3: world_sim 2yr 量測**
```
$env:GODOT_TIMEOUT="900"; .\tools\godot.ps1 --headless --script scripts/debug/world_sim.gd
```
觀察並記數據：2yr 不全滅、InvariantViolation=0；無家深危 unified 隊有 `[SurvivalJoin]`/`[CrudeCamp]`/`TASK_BEG` emergent（**非全餓死**=標記1債閉）；**無 over-camp/join**（健康 unified 隊照貿易/生產，世界不塌成全定居）。unseeded → 看機制 fire 非絕對閾（[[reference_multi_sanity_unseeded]]）。**若 RNG 該 run 無無家深危 unified 隊**=機制 headless 證即可（如 P1，記為 rare tail 非 dormant）。

- [ ] **Step 4: framework + 守恆閘**
```
.\tools\godot.ps1 --headless --script scripts/debug/framework_validation.gd
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd
```
framework S1-S6 PASS、`[CoinAudit] delta` ≈ 0 + headless 全綠。

- [ ] **Step 5: Commit**
```
git add scripts/debug/headless_test.gd
git commit -m "test(p2a): 絕境 option 驗序 + world_sim 量測 (P2a)"
```

---

## 完成後（子 session）

1. push `git push -u origin feat/p2a-survival-options`
2. handback `docs/superpowers/handbacks/2026-06-23-p2a-survival-options.md`：改檔 + 與 spec/plan 差異 + world_sim 量測（join/camp/beg fire 率、是否 over-camp、敗商隊投靠是否 emergent、經濟世界是否仍健康）+ 連動風險（W1 hoist 對 non-unified camp 行為、W2 對玩家 UX、DESPERATION_SCALE 量級）+ 待確認（係數調否、P2b 退役雙 owner 起點）。
3. finishing-a-development-branch → Option 3，主 session merge。

## Self-Review（主 session）

- spec 範圍（只 join/camp/beg、不 hunt、不退役、non-unified 零改、不動 test 直呼點）→ 全 Task 對齊。
- **W1 camp-arrival hoist** = 唯一結構移動 → 確認移後 non-unified 行為不變（原走到此）+ unified 隊 camp 立營 fire（`_test_p2a_camp_arrival`）。
- **W2 player-join guard** = `_decide_unified` 一處 → 確認對齊舊 `_maybe_request_join_player`（同格 + 無 pending event）。
- 健康隊 applicable gate（food_days<DESPERATION）→ TC1/4/6/7 零影響（Task 2 (c) 驗）。
- 危時序對齊舊行為（restock>forage>人格分流）→ Task 3 (a) 驗；量級調 `DESPERATION_SCALE`。
- helper 名跨 Task 一致（`_mk_unified_desperate_team`/`_mk_strong_neighbor_team`/`_mk_player_strong_team`/`_give_home_outpost`）。
- combat_target 接線：投靠/乞食帶 combat_target（同 P1 掠奪既有 `td.has("combat_target")` 接線，零新接線）。**確認 P1 已有的 `if td.has("combat_target"): team.combat_target=...`（`_decide_unified:860`）涵蓋投靠/乞食**（投靠玩家除外，走 W2 guard 先 return）。
- 風險：絕境 option 量級（DESPERATION_SCALE 1.2 × weight ≤~0.85 → drive util ≤~1.0+，對齊但不超 forage/restock）→ world_sim 量序調係數。
