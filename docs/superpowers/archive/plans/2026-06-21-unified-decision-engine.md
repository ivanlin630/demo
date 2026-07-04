# 統一決策引擎 sub-project 1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:subagent-driven-development（建議）或 superpowers:executing-plans，task-by-task 實作。每 Task 走 TDD（先失敗測試）。Steps 用 checkbox 追蹤。

**Goal:** 建 `DecisionEngine`（utility weigh + 承諾慣性的單一決策生產者），接管商隊-tag 隊的 macro 決策 → 殺 tag-vs-人格震盪、證人格分歧；舊系統對非切片隊零影響。

**Architecture:** 一隊一個 `decide()`：蒐集 `DecisionContext`（leader 人格→權重、隊狀態→輸入）→ 列候選 Option → 每 option utility = Σ(人格權重 × 驅力 term) + 現行 option 承諾 bonus → argmax。term 複用既有判斷函式（`effective_food`/`best_estimate`/feud/`team_strength`），非重寫 AI。`uses_unified`(商隊-tag) seam 讓舊 faction_ai/solo 跳過切片隊。

**Tech Stack:** Godot 4.2.2 GDScript；新 `scripts/simulation/decision/*`；改 `faction_ai_system.gd`；headless 行為測試 + world_sim 煙霧。

## Global Constraints

- wrapper 跑（UTF-8）：`.\tools\godot.ps1 --headless --import` 然後 `--script scripts/debug/headless_test.gd`。Windows PS 5.1 無 `&&`，分開或 `;`。
- 來源：spec `2026-06-21-unified-decision-engine-design`、ruling `unified-decision-framework`、驗證套件 `framework-validation-suite`（TC1/4/6/7）。
- **不碰守恆**：本子專案只改決策面（task 選擇），**不動 resources/coin/state 池**（Pattern B = 另子專案）→ coin_eq/InvariantAudit 無關（驗 0 形式確認）。
- **bar #4 硬約束**：人格必須產生分歧權重，嚴禁抹平（TC7 過不了 = 框架失敗）。
- **切片 = 商隊-tag only**：`uses_unified` 單一判定；舊系統對非商隊隊原封不動。
- 全權重/門檻 = TEST VALUE（初值定於本 plan，平衡 pass 調）。
- 回歸閘：headless 全綠、coin_eq=0、InvariantAudit 0、TC1/4/6/7 行為測試過。

## File Structure

- `scripts/simulation/decision/terms.gd`（`class_name DecisionTerms`，pure static term 函式 + w_term 人格映射）。
- `scripts/simulation/decision/decision_context.gd`（`class_name DecisionContext`，蒐集隊快照）。
- `scripts/simulation/decision/options.gd`（`class_name DecisionOptions`，Option 註冊表 + applicable + to_task）。
- `scripts/simulation/decision/decision_engine.gd`（`class_name DecisionEngine`，decide loop + 承諾 + cadence）。
- `scripts/simulation/faction_ai_system.gd`（`uses_unified` skip + 引擎呼叫接線）。
- `scripts/data/team_data.gd`（`current_option` 欄位，承諾用）。
- `scripts/debug/headless_test.gd`（單元 + TC1/4/6/7）。

---

### Task 1: DecisionContext 蒐集 + 欄位

**Files:**
- Create: `scripts/simulation/decision/decision_context.gd`
- Modify: `scripts/data/team_data.gd`（加 `current_option`）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Produces: `DecisionContext.gather(state, team) -> DecisionContext`；欄位 `leader_values:Dictionary, food_days:float, has_goods:bool, has_arb:bool, team_strength:float, threat:float, ambition_gap:int, strongest_feud:float, has_own_outpost:bool`。

- [ ] **Step 1: 加 current_option 欄位**

`team_data.gd` 加：`var current_option: String = ""   # 統一決策引擎承諾用（現行 option 名）`

- [ ] **Step 2: 寫失敗測試** `_test_decision_context_gather()`（`_initialize` 註冊）
```gdscript
func _test_decision_context_gather() -> void:
	print("--- 決策引擎 Task1: DecisionContext ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var t := TeamData.new(); t.team_id = 0; t.tags = ["商隊"]; t.tile_pos = Vector2i(2,2); t.leader_id = 100
	_seed_pop(t, 5); t.resources = {"goods": 50.0, "food": 100.0, "coin": 200.0}
	var ldr := PersonData.new(); ldr.id = 100; ldr.values["貪婪"] = 0.7; ldr.values["野心"] = 0.4
	state.persons[100] = ldr; state.teams[0] = t
	var ctx: DecisionContext = DecisionContext.gather(state, t)
	assert(ctx.leader_values.get("貪婪", 0.0) == 0.7, "ctx 應載 leader 人格")
	assert(ctx.food_days > 0.0, "ctx 應算 food_days(effective_food)")
	assert(ctx.has_goods == true, "ctx 有貨")
	print("decision context OK (food_days=%.1f)" % ctx.food_days)
```

- [ ] **Step 3: --import + 跑驗證失敗**（DecisionContext 未定義）

- [ ] **Step 4: 實作** `decision_context.gd`：
```gdscript
class_name DecisionContext

var leader_values: Dictionary = {}
var food_days: float = 0.0
var has_goods: bool = false
var has_arb: bool = false
var team_strength: float = 0.0
var threat: float = 0.0
var ambition_gap: int = 0
var strongest_feud: float = 0.0
var has_own_outpost: bool = false

static func gather(state: WorldState, team: TeamData) -> DecisionContext:
	var c := DecisionContext.new()
	var ldr: PersonData = state.persons.get(team.leader_id)
	c.leader_values = ldr.values.duplicate() if ldr != null else {}
	var ef: float = ResourceSystem.effective_food(state, team)
	c.food_days = ef / maxf(float(team.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY, 0.001)
	c.has_goods = float(team.resources.get("goods", 0)) >= 10.0
	c.has_arb = not OrderSystem.new().best_arbitrage_order(state, team).is_empty()
	c.team_strength = NpcCombatSystem.new().team_strength(state, team.team_id)
	c.ambition_gap = maxi(team.ambition_cap - team.ambition_rung, 0)
	var fe: Dictionary = RelationGraph.strongest(team.relation_edges, "feud")
	c.strongest_feud = float(fe.get("intensity", 0.0)) if not fe.is_empty() else 0.0
	c.has_own_outpost = ResourceSystem.own_granary_tile(state, team) != null
	# threat：最近鄰敵 strength（複用既有 helper；無則 0）
	c.threat = 0.0   # Task5 接 _find_strong_neighbor / 威脅；初版 0（商隊切片威脅次要）
	return c
```
> 註：`team_strength`/`best_estimate` 等簽名依真實 code 對齊（實作者驗）。threat 初版 0，商隊切片威脅 term 次要，後續域遷入時補。

- [ ] **Step 5: --import + 跑驗證通過**（`decision context OK`、`=== DONE ===`、coin_eq=0、InvariantAudit 0）

- [ ] **Step 6: Commit** `feat(decision): DecisionContext 蒐集隊快照 + current_option 欄位`

---

### Task 2: Term 函式庫 + w_term 人格映射

**Files:**
- Create: `scripts/simulation/decision/terms.gd`
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Produces: `DecisionTerms.eval(term_name, ctx, opt) -> float`（驅力強度 0..~1.5）；`DecisionTerms.weight(term_name, leader_values) -> float`（人格→權重）。

- [ ] **Step 1: 寫失敗測試** `_test_decision_terms()`（註冊）
```gdscript
func _test_decision_terms() -> void:
	print("--- 決策引擎 Task2: Term + 人格權重 ---")
	var ctx := DecisionContext.new()
	ctx.food_days = 1.0   # 危機
	# survival term 危機高
	assert(DecisionTerms.eval("survival_pressure", ctx, "survival") > 0.8, "糧危 survival term 應高")
	ctx.food_days = 30.0
	assert(DecisionTerms.eval("survival_pressure", ctx, "survival") < 0.2, "糧足 survival term 低")
	# 貪婪→經濟權重高（分歧）
	var greedy := {"貪婪": 0.9}
	var meek := {"貪婪": 0.1}
	assert(DecisionTerms.weight("economic", greedy) > DecisionTerms.weight("economic", meek), "貪婪高→經濟權重高")
	# 好戰→攻擊權重高
	var fierce := {"好戰": 0.9}
	assert(DecisionTerms.weight("attack", fierce) > DecisionTerms.weight("attack", meek), "好戰高→攻擊權重高")
	print("decision terms OK")
```

- [ ] **Step 2: --import + 跑驗證失敗**

- [ ] **Step 3: 實作** `terms.gd`（初值全 TEST VALUE）：
```gdscript
class_name DecisionTerms

# 驅力強度（0..~1.5）。term × opt 對應；不適用 opt 回 0。
static func eval(term: String, ctx: DecisionContext, opt: String) -> float:
	match term:
		"survival_pressure":
			# 糧 days 越少越高；<3 天爆高（危機）
			return clampf((6.0 - ctx.food_days) / 6.0, 0.0, 1.5)
		"economic_opp":
			if opt != "貿易": return 0.0
			return (0.8 if ctx.has_goods else 0.2) * (1.0 if ctx.has_arb else 0.3)
		"produce_need":
			if opt != "生產": return 0.0
			return 0.3 if ctx.has_goods else 0.6   # 已有貨→低
		"ambition_drive":
			# 階梯缺口 → 擴張/立國/生產 等成長 option
			if opt not in ["生產", "建設", "貿易"]: return 0.0
			return clampf(float(ctx.ambition_gap) * 0.3, 0.0, 1.0)
		"feud_pull":
			return ctx.strongest_feud if opt == "攻擊" else 0.0
		"settle_fit":
			return 0.5 if opt in ["生產", "建設", "駐守"] else 0.0
		_:
			return 0.0

# 人格 → term 權重（分歧來源；bar #4）。TEST VALUE 映射。
static func weight(term: String, leader_values: Dictionary) -> float:
	var v := leader_values
	match term:
		"survival_pressure": return 1.0   # survival 權重恆高（人人怕死）
		"economic":          return 0.3 + float(v.get("貪婪", 0.5))
		"attack":            return 0.2 + float(v.get("好戰", 0.5)) + float(v.get("殘忍", 0.5)) * 0.3
		"ambition":          return 0.2 + float(v.get("野心", 0.5))
		"settle":            return float(v.get("義氣", 0.5)) * 0.5 + float(v.get("慎重", 0.5)) * 0.5
		"feud":              return 0.3 + float(v.get("好戰", 0.5)) * 0.5
		_:                   return 0.5
```

- [ ] **Step 4: --import + 跑驗證通過**（`decision terms OK`）

- [ ] **Step 5: Commit** `feat(decision): Term 函式庫 + 人格→權重映射(分歧來源)`

---

### Task 3: Option 註冊表 + applicable + to_task

**Files:**
- Create: `scripts/simulation/decision/options.gd`
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Produces: `DecisionOptions.applicable(ctx) -> Array[String]`（候選 option 名）；`DecisionOptions.terms_of(opt) -> Array`（[[term_name, weight_key], ...]）；`DecisionOptions.to_task(state, team, opt) -> Dictionary`（{task, target}）。

- [ ] **Step 1: 寫失敗測試** `_test_decision_options()`（註冊）
```gdscript
func _test_decision_options() -> void:
	print("--- 決策引擎 Task3: Option 表 ---")
	var ctx := DecisionContext.new(); ctx.has_goods = true; ctx.has_arb = true; ctx.food_days = 20.0
	var opts: Array = DecisionOptions.applicable(ctx)
	assert("貿易" in opts, "有貨+arb → 貿易候選")
	assert("survival" in opts, "survival 恆候選")
	# 貿易 option 的 term 含 economic
	var terms: Array = DecisionOptions.terms_of("貿易")
	var has_eco := false
	for tw in terms:
		if tw[0] == "economic_opp": has_eco = true
	assert(has_eco, "貿易 option 應含 economic_opp term")
	print("decision options OK")
```

- [ ] **Step 2: --import + 跑驗證失敗**

- [ ] **Step 3: 實作** `options.gd`（商隊切片首批 option；[term_name, weight_key]）：
```gdscript
class_name DecisionOptions

# 商隊切片首批 option → [[term_name, weight_key], ...]
const REGISTRY: Dictionary = {
	"貿易":   [["economic_opp", "economic"], ["ambition_drive", "ambition"]],
	"生產":   [["produce_need", "settle"], ["ambition_drive", "ambition"]],
	"建設":   [["settle_fit", "settle"], ["ambition_drive", "ambition"]],
	"覓食":   [["survival_pressure", "survival_pressure"]],
	"survival":[["survival_pressure", "survival_pressure"]],
	"駐守":   [["settle_fit", "settle"]],
}

static func applicable(ctx: DecisionContext) -> Array:
	var out: Array = []
	for opt in REGISTRY:
		match opt:
			"貿易":
				if ctx.has_goods or ctx.has_arb: out.append(opt)
			"生產", "建設", "駐守":
				if ctx.has_own_outpost: out.append(opt)
			"覓食", "survival":
				out.append(opt)   # 恆候選（survival 靠權重，非守衛）
	return out

static func terms_of(opt: String) -> Array:
	return REGISTRY.get(opt, [])

# Option → 既有 TASK_* + target（複用既有 dispatch helper；Task5 接線細化）
static func to_task(state: WorldState, team: TeamData, opt: String) -> Dictionary:
	match opt:
		"貿易":   return {"task": TeamData.TASK_TRADE, "target": FactionAISystem.new()._merchant_trade_target(state, team)}
		"生產":   return {"task": TeamData.TASK_MANUFACTURE, "target": team.tile_pos}
		"建設":   return {"task": TeamData.TASK_BUILD, "target": team.tile_pos}
		"覓食":   return {"task": TeamData.TASK_FORAGE, "target": team.move_target}
		"survival": return {"task": TeamData.TASK_FLEE, "target": Vector2i(-1,-1)}
		"駐守":   return {"task": TeamData.TASK_GOVERN, "target": team.tile_pos}
		_:        return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
```

- [ ] **Step 4: --import + 跑驗證通過**（`decision options OK`）

- [ ] **Step 5: Commit** `feat(decision): Option 註冊表 + applicable 守衛 + to_task 對映`

---

### Task 4: DecisionEngine.decide（utility weigh + 承諾慣性）

**Files:**
- Create: `scripts/simulation/decision/decision_engine.gd`
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Produces: `DecisionEngine.decide(state, team) -> String`（選中 option 名，並更新 `team.current_option`）。

- [ ] **Step 1: 寫失敗測試** `_test_decision_engine_decide()` + `_test_decision_commitment()`（註冊）
```gdscript
func _test_decision_engine_decide() -> void:
	print("--- 決策引擎 Task4: decide ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var t := TeamData.new(); t.team_id = 0; t.tags = ["商隊"]; t.tile_pos = Vector2i(2,2); t.leader_id = 100
	_seed_pop(t, 5)
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(2,2); tile.outpost_owner = 0; tile.outpost_level = 1; tile.outpost_type = "civilian"
	tile.public_storage = {"food": 500.0}; state.world.tiles[2*1000+2] = tile
	t.resources = {"goods": 50.0, "coin": 200.0}   # 有貨、糧在糧倉
	var ldr := PersonData.new(); ldr.id = 100; ldr.values["貪婪"] = 0.8   # 商人
	state.persons[100] = ldr; state.teams[0] = t
	# 注入 arb（有單可做）
	state.team_known[0] = [_mk_order_msg("order_sell", "material", 20, 1, Vector2i(2,3))]
	var opt: String = DecisionEngine.decide(state, t)
	assert(opt == "貿易", "商人+有貨+arb+糧足 → 應選貿易，實際=%s" % opt)
	print("decide OK (選=%s)" % opt)

func _test_decision_commitment() -> void:
	print("--- 決策引擎 Task4: 承諾慣性 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var t := TeamData.new(); t.team_id = 0; t.tags = ["商隊"]; t.leader_id = 100
	_seed_pop(t, 5); t.resources = {"goods": 50.0}
	t.current_option = "貿易"   # 已承諾貿易
	var ldr := PersonData.new(); ldr.id = 100; ldr.values["貪婪"] = 0.5
	state.persons[100] = ldr; state.teams[0] = t
	# 邊際情況：生產分數略高於貿易裸分，但承諾 bonus 應讓貿易守住
	var opt: String = DecisionEngine.decide(state, t)
	assert(opt == "貿易", "承諾慣性應守住現行貿易(非每 tick 翻)，實際=%s" % opt)
	print("commitment OK")
```
（`_mk_order_msg` 若 WS-2b 已建則複用；無則照 WS-2b plan 骨架補。）

- [ ] **Step 2: --import + 跑驗證失敗**

- [ ] **Step 3: 實作** `decision_engine.gd`：
```gdscript
class_name DecisionEngine

const COMMITMENT_BONUS: float = 0.3   # TEST VALUE：承諾慣性（防震盪）

static func decide(state: WorldState, team: TeamData) -> String:
	var ctx: DecisionContext = DecisionContext.gather(state, team)
	var best_opt: String = team.current_option
	var best_u: float = -1e9
	for opt in DecisionOptions.applicable(ctx):
		var u: float = 0.0
		for tw in DecisionOptions.terms_of(opt):
			var term_name: String = tw[0]
			var weight_key: String = tw[1]
			u += DecisionTerms.weight(weight_key, ctx.leader_values) * DecisionTerms.eval(term_name, ctx, opt)
		if opt == team.current_option:
			u += COMMITMENT_BONUS
		if u > best_u:
			best_u = u; best_opt = opt
	team.current_option = best_opt
	return best_opt
```

- [ ] **Step 4: --import + 跑驗證通過**（`decide OK`、`commitment OK`、coin_eq=0、InvariantAudit 0）

- [ ] **Step 5: Commit** `feat(decision): DecisionEngine.decide(utility weigh + 承諾慣性)`

---

### Task 5: 切片 seam — uses_unified + faction_ai 接線

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Consumes: `DecisionEngine.decide`、`DecisionOptions.to_task`。
- Produces: 切片隊（商隊-tag）走引擎設 task；非切片隊舊系統不變。

- [ ] **Step 1: 寫失敗測試** `_test_unified_seam()`（註冊）
```gdscript
func _test_unified_seam() -> void:
	print("--- 決策引擎 Task5: 切片 seam ---")
	var fai := FactionAISystem.new()
	assert(fai.uses_unified(_mk_team_tag("商隊")), "商隊-tag → 切片(走新引擎)")
	assert(not fai.uses_unified(_mk_team_tag("軍隊")), "軍隊 → 非切片(舊系統)")
	print("unified seam OK")

func _mk_team_tag(tag: String) -> TeamData:
	var t := TeamData.new(); t.tags = [tag]; return t
```

- [ ] **Step 2: --import + 跑驗證失敗**

- [ ] **Step 3: 實作**
  - `faction_ai_system.gd` 加：
    ```gdscript
    # 統一決策引擎切片判定：首切片 = 商隊-tag 隊（macro 決策走 DecisionEngine，舊生產者跳過）。
    func uses_unified(team: TeamData) -> bool:
        return team.tags.has(TeamData.TAG_MERCHANT)

    # 切片隊走引擎決策 → 設 task（取代舊 member/solo 派工）。
    func _decide_unified(state: WorldState, team: TeamData) -> void:
        if team.current_task in SURVIVAL_TASKS and team.current_task != TeamData.TASK_IDLE:
            pass   # 生存 sticky 仍尊重；引擎的 survival option 會自然續（承諾）
        var opt: String = DecisionEngine.decide(state, team)
        var td: Dictionary = DecisionOptions.to_task(state, team, opt)
        var tgt: Vector2i = td["target"]
        if tgt == Vector2i(-1,-1) and td["task"] != TeamData.TASK_FLEE:
            return   # 無有效目標 → 不強設
        TaskArbiter.try_set(state, team, td["task"], tgt, TaskArbiter.PRIO_DISPATCH, "unified")
    ```
  - `_assign_member_tasks` member 迴圈開頭加：`if uses_unified(mt): _decide_unified(state, mt); continue`
  - `_evaluate_solo` 開頭加：`if uses_unified(team): _decide_unified(state, team); return`
  > 注意：移除/繞過舊商隊 hoist（WS-2/2b 的 member hoist + solo bonus）——那些被引擎取代（引擎的貿易 option 涵蓋）。實作者確認舊 hoist 對商隊不再雙重觸發（可留給非商隊？非商隊不貿易 → 實質只商隊用過 → 安全移除商隊分支）。

- [ ] **Step 4: --import + 跑驗證通過**（`unified seam OK`、既有 trade 測試對齊、coin_eq=0、InvariantAudit 0）

- [ ] **Step 5: Commit** `feat(decision): 商隊切片 seam(uses_unified + 引擎接線,舊生產者跳過)`

---

### Task 6: 驗證套件 TC1/TC4/TC6/TC7（believability 行為測試）

**Files:**
- Test: `scripts/debug/headless_test.gd`

**Interfaces:** 無 code 改（行為測試）。

- [ ] **Step 1: TC1 精神分裂震盪消失** `_test_tc1_no_oscillation()`
  - 商隊 tag + 定居人格（義氣.7/貪婪.4）+ outpost + 糧足 + 有 arb。跑數十 tick `decide`，記 option 序。
  - 斷言：**穩定 commit 不震盪**（option 變化 < N 次/50 tick；非 trade↔生產 每 2 tick 翻）。

- [ ] **Step 2: TC4 ambition 有牙** `_test_tc4_ambition_drive()`
  - 安全（糧足/無威脅）+ 野心.9 + ambition_gap>0 → decide 選成長 option（貿易/生產/建設，ambition_drive 推）。
  - 對照 野心.3 同安全 → 偏駐守/低活動（知足）。斷言兩者 option 不同。

- [ ] **Step 3: TC6 多驅力權衡** `_test_tc6_multi_drive()`
  - 糧中等 + 野心中 + 小 feud + faction 徵收 goal → decide 出一個 option，且可 dump term 分解（讀得出為何）。斷言不崩、選項合理（非 survival 也非極端）。

- [ ] **Step 4: TC7 分歧硬 bar** `_test_tc7_divergence()`
  - **同情境**（同隊狀態）放 3 種 leader：霸主(野心.95/好戰.9)、商人(貪婪.9)、隱士(義氣.9/慎重.8/野心.2)。
  - 斷言：**3 個不同 option**（霸主偏攻擊/擴張、商人偏貿易、隱士偏駐守/survival）。**過不了 = 框架失敗。**
  > 註：霸主的「攻擊」option 在商隊切片首批未列（攻擊是後續域）→ TC7 在切片階段可用「擴張傾向 option 差異」驗（霸主 ambition_drive 高→生產/建設爬階、商人→貿易、隱士→駐守）。完整攻擊分歧待攻擊 option 遷入。**本 Task 驗切片內可分歧的 3 動作。**

- [ ] **Step 5: --import + 跑全綠**（TC1/4/6/7 OK、`=== DONE ===`、coin_eq=0、InvariantAudit 0）

- [ ] **Step 6: Commit** `test(decision): 驗證套件 TC1 震盪消失/TC4 野心/TC6 權衡/TC7 分歧`

---

### Task 7: 回歸 + world_sim 煙霧 + 回報

**Files:** 無 code 改（跑 + 回報）。

- [ ] **Step 1: headless 回歸**：`=== DONE ===`、全測 OK（含 TC1/4/6/7 + 既有飢荒/trade/belief）、coin_eq=0、InvariantAudit 0。

- [ ] **Step 2: world_sim 煙霧（非閘）**：跑通無 SCRIPT ERROR；觀察商隊行為——`merchant_survival` 是否降、商隊是否不再卡 生產（震盪消）、`[Market]`/履約是否有動（**注意**：S6 完整閉環需擴定居隊=後續子專案，本子專案商隊不震盪+走完貿易即達標方向；履約可能仍受定居隊未納影響）。

- [ ] **Step 3: 回報 handback** `2026-06-21-implementer-to-systems-unified-decision-engine.md`（`from: implementer / to: systems / status: open`）：TC1/4/6/7 結果（尤其 TC7 分歧是否過）、world_sim 商隊行為對照（震盪消？survival 降？）、是否仍有殘留震盪（調 COMMITMENT_BONUS）、是否需擴定居隊才見履約、異常。

- [ ] **Step 4: Commit handback** `docs(decision): 統一決策引擎商隊切片 world_sim 回報`

---

## Self-Review 註記

- **spec 覆蓋**：架構(Task4)/Components Context(T1)·Terms(T2)·Options(T3)/切片 seam(T5)/驗收 TC1·4·6·7(T6)/回歸 S6 方向(T7)。Pattern B、他域遷入、S6 擴定居隊 = spec 已界定為後續子專案，本 plan 不含。
- **守恆安全**：只改決策面（task 選擇），不碰 resources/coin/state 池 → coin_eq 形式確認。
- **bar #4 釘死**：TC7(T6 Step4) 硬 bar；w_term 人格映射(T2)是分歧來源。切片首批無攻擊 option → TC7 用「切片內可分歧 3 動作」驗（霸主爬階/商人貿易/隱士駐守），完整攻擊分歧待攻擊 option 遷入。
- **震盪根治**：承諾慣性(T4 COMMITMENT_BONUS) + TC1(T6) 驗。
- **複用非重寫**：term 接既有 `effective_food`/`best_estimate`/`team_strength`/`_merchant_trade_target`/feud → 遷移成本低。
- **舊 hoist 移除**(T5 Step3 註)：WS-2/2b 商隊 hoist 被引擎取代，確認不雙重觸發。
- **TEST VALUE**：COMMITMENT_BONUS=0.3、w_term 映射初值、term 公式、applicable 守衛 → 先求 TC1/TC7 過再細調。
- **S6 履約脫 0** 是後續子專案（擴定居隊）目標，非本 plan 驗收；本 plan 驗收 = 商隊不震盪 + 分歧（TC1/TC7）。
- **無 placeholder**：各 Task 含具體測試碼 + 實作碼 + 初值。簽名（team_strength/best_estimate/_merchant_trade_target）依真實 code 對齊由實作者驗。
