# P3 混合協調 seam Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:subagent-driven-development or executing-plans. Steps use checkbox (`- [ ]`).

**Goal:** 讓 unified 隊（merchant/produce）經引擎響應派系 stakes directive（混合協調）——加 `faction_duty` term（loyalty 加權=脫軌逃閥）+ 啟用 `攻擊` engine option（首個 live stakes option）。霸主決策步複用既有 `_update_goals`（已產攻擊 directive、readiness/belief gate）。

**Architecture:** `_update_goals`（faction_ai:632-712）已設 `f.goals` 攻擊（霸主決策，稀有蓄意吃 belief）。non-unified 已響應（802-827）。**unified 隊零讀 faction goals = 本塊補的縫**。加 `faction_duty` term 讓引擎讀派系 directive + 啟用 `攻擊` option（已半 scaffold：`feud_pull`/`attack` weight 在，缺 REGISTRY）。**只碰 `decision/` 三檔 + invariants.md + 測**（faction_ai 可能零改，複用 `_nearest_independent`/既有 combat_target 接線）。

**Tech Stack:** Godot 4.2.2 GDScript。測試 `scripts/debug/headless_test.gd`（`=== DONE ===` 無 `SCRIPT ERROR`）。

## Global Constraints

- **UTF-8 wrapper**：Godot 走 `.\tools\godot.ps1`（PowerShell）。worktree 子 session：每 Godot/git 前 `Set-Location` 進 worktree。
- **守恆**：攻擊走既有 combat 守恆，本 plan **不碰守恆數學**。coin_eq 0 + InvariantAudit 0。
- **scope guard（P0/P1/P2 教訓）**：**只 `攻擊` 一個 stakes option**（徵收/外交/立國/結盟/大徵收=後續）。**不碰 non-unified 802-827、不改 `_update_goals` 霸主決策、無新脫軌/叛變機制（逃閥=term 權重）。不新 TASK_*。不碰 daily-op options（貿易/掠奪/survival 無 faction_duty）。** 不加 exemption 鏈。
- **believability（ruling §1/§2）**：頂層決 WHETHER（`_update_goals` 攻擊 gate）+ 人格染 HOW（attack weight 好戰染色）+ 脫軌逃閥（faction_duty weight 受 loyalty 調，低忠誠高野心可不參戰）+ 危時 survival 碾壓 + 日常個體不變。
- 新常數 `# TEST VALUE`。
- baseline：開工前 `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd` 全綠。

---

### Task 1: `DecisionContext` faction 欄 + `faction_duty`/`attack_drive` term + `faction_duty` weight

**Files:**
- Modify: `scripts/simulation/decision/decision_context.gd`（faction 欄 + gather + loyalty 注入）
- Modify: `scripts/simulation/decision/terms.gd`（const + 2 eval + 1 weight）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Consumes: `team.faction_id`、`state.factions[fid].goals`（Array，stakes 子集）、`FactionAISystem.new()._nearest_independent(state,team)->int`、`ldr.loyalty`、`ctx.leader_values`。
- Produces: `ctx.faction_directive`/`faction_attack_target`/`faction_attack_target_pos`/`leader_loyalty`（+ `leader_values["_loyalty"]` 注入）；term `faction_duty`/`attack_drive` eval、weight key `faction_duty`。

- [ ] **Step 1: 讀 decision_context.gd gather + terms.gd eval/weight + faction_data.gd `goals` 欄 + `_nearest_independent`(1327) 簽名。**

- [ ] **Step 2: 寫 failing test**
```gdscript
func _test_p3_faction_duty_term() -> void:
	# faction_duty weight 脫軌逃閥：高忠誠→高、低忠誠+高野心→壓低
	var loyal := {"野心": 0.5, "_loyalty": 0.9}
	var rebel := {"野心": 0.9, "_loyalty": 0.2}
	var w_loyal: float = DecisionTerms.weight("faction_duty", loyal)
	var w_rebel: float = DecisionTerms.weight("faction_duty", rebel)
	assert(w_loyal > 0.8, "[p3] 忠誠 faction_duty weight 太低 %.2f" % w_loyal)     # 0.9-0=0.9
	assert(w_rebel < 0.3, "[p3] 叛逆 faction_duty weight 太高 %.2f" % w_rebel)     # 0.2-0.4=0(clamp)
	# faction_duty drive：directive=攻擊+有 target → >0；else 0
	var ctx_war := DecisionContext.new()
	ctx_war.faction_directive = "攻擊"; ctx_war.faction_attack_target = 5
	var ctx_peace := DecisionContext.new()
	assert(DecisionTerms.eval("faction_duty", ctx_war, "攻擊") > 0.0, "[p3] 戰時 faction_duty drive=0")
	assert(DecisionTerms.eval("faction_duty", ctx_peace, "攻擊") == 0.0, "[p3] 平時 faction_duty drive 非 0")
	assert(DecisionTerms.eval("faction_duty", ctx_war, "貿易") == 0.0, "[p3] faction_duty 染到非攻擊 option")
	print("[p3] faction_duty term OK loyal=%.2f rebel=%.2f" % [w_loyal, w_rebel])
```

- [ ] **Step 3: 跑測確認 FAIL**

- [ ] **Step 4: 實作**

`decision_context.gd` 加欄：
```gdscript
var faction_directive: String = ""
var faction_attack_target: int = -1
var faction_attack_target_pos: Vector2i = Vector2i(-1, -1)
var leader_loyalty: float = 0.5
```
gather（loyalty 注入 leader_values dict = 最小改 weight 簽名）：
```gdscript
	c.leader_loyalty = ldr.loyalty if ldr != null else 0.5
	c.leader_values["_loyalty"] = c.leader_loyalty   # weight("faction_duty") 讀（避擴簽名）
	# 派系 stakes directive（本塊只認 攻擊；後續擴徵收/外交/立國）
	c.faction_directive = ""
	if team.faction_id != -1:
		var f = state.factions.get(team.faction_id)
		if f != null and "攻擊" in f.goals:
			c.faction_directive = "攻擊"
	if c.faction_directive == "攻擊":
		var _at: int = _fa._nearest_independent(state, team)   # 複用既有 _fa（gather 內已 new）
		c.faction_attack_target = _at
		c.faction_attack_target_pos = state.teams[_at].tile_pos if _at != -1 else Vector2i(-1, -1)
```
> `_fa` = gather 內既有 `FactionAISystem.new()`（P2a 已共用）。`leader_values` 已 duplicate（注入 `_loyalty` 不污染 PersonData）。

`terms.gd` 加常數：
```gdscript
const FACTION_DUTY_DRIVE: float = 1.5   # TEST VALUE — stakes 協同量級（高壓日常 term，但 weight 受 loyalty 調=非無限）
const DEFECT_AMBITION_K: float = 1.0    # TEST VALUE — 野心折損 faction_duty 權重斜率（脫軌逃閥）
```
eval 加：
```gdscript
		"faction_duty":
			if opt == "攻擊" and ctx.faction_directive == "攻擊" and ctx.faction_attack_target != -1:
				return FACTION_DUTY_DRIVE
			return 0.0
		"attack_drive":
			if opt != "攻擊" or ctx.faction_directive != "攻擊": return 0.0
			return 0.3   # TEST VALUE — 個人參戰基值；× attack weight(好戰/殘忍)=染色 HOW
```
weight 加（脫軌逃閥）：
```gdscript
		"faction_duty":
			var loy: float = float(v.get("_loyalty", 0.5))
			var amb: float = float(v.get("野心", 0.5))
			return clampf(loy - maxf(0.0, amb - 0.5) * DEFECT_AMBITION_K, 0.0, 1.0)
```
（`attack` weight 既有 line ~57，不動。）

- [ ] **Step 5: 跑測 PASS + 既有全綠**（注意 leader_values 注入 `_loyalty` 不破既有 term 讀 values）

- [ ] **Step 6: Commit**
```
git add scripts/simulation/decision/decision_context.gd scripts/simulation/decision/terms.gd scripts/debug/headless_test.gd
git commit -m "feat(decision): faction_duty/attack_drive term + ctx faction directive 欄 + 脫軌逃閥 weight (P3)"
```

---

### Task 2: 啟用 `攻擊` option + invariants 混合協調段

**Files:**
- Modify: `scripts/simulation/decision/options.gd`（REGISTRY + applicable + to_task）
- Modify: `docs/invariants.md`（混合協調段）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Consumes: ctx faction 欄；`FactionAISystem.new()._nearest_independent(state,team)`；`TeamData.TASK_ATTACK`。
- Produces: `攻擊` option 可被 rank 選中 → TASK_ATTACK + target=敵位 + combat_target=敵 id。

- [ ] **Step 1: 讀 options.gd REGISTRY/applicable/to_task + `_decide_unified`(847-863, combat_target 接線在 860).**

- [ ] **Step 2: 寫 failing test**
```gdscript
func _test_p3_attack_option() -> void:
	var state := WorldState.new()
	var cfg := {"map": {"radius": 5, "resource_richness": 5}, "teams": []}
	GameSetup.setup(state, cfg)
	var fa := FactionAISystem.new()
	# 忠誠好戰 unified member（建 faction、directive=攻擊、有獨立 target）→ 選 攻擊
	var soldier := _mk_unified_faction_member(state, Vector2i(3,3), {"好戰":0.8,"_loyalty":0.9})  # helper:建 faction+goals=["攻擊"]+TAG_PRODUCE+鄰一獨立隊
	_mk_independent_target(state, Vector2i(4,3))
	fa._decide_unified(state, soldier)
	assert(soldier.current_task == TeamData.TASK_ATTACK, "[p3] 忠誠好戰 member 未響應派系攻擊 task=%s" % soldier.current_task)
	assert(soldier.combat_target != -1, "[p3] 攻擊未設 combat_target")
	# 脫軌逃閥：低忠誠高野心 member 同 directive → 不選攻擊（faction_duty weight 壓低）
	var rebel := _mk_unified_faction_member(state, Vector2i(3,3), {"野心":0.9,"_loyalty":0.15,"貪婪":0.8})
	rebel.resources["goods"] = 50   # 給貿易誘因（個人驅力蓋過 faction_duty）
	fa._decide_unified(state, rebel)
	assert(rebel.current_task != TeamData.TASK_ATTACK, "[p3] 叛逆 member 竟服從派系攻擊（逃閥失效）")
	# 無 directive → 不攻擊
	var peace := _mk_unified_faction_member(state, Vector2i(3,3), {"好戰":0.8,"_loyalty":0.9}, [])  # goals=[]
	fa._decide_unified(state, peace)
	assert(peace.current_task != TeamData.TASK_ATTACK, "[p3] 無 directive 竟攻擊")
	print("[p3] attack option OK")
```
> helper `_mk_unified_faction_member(state,pos,values,goals=["攻擊"])`：建 faction（leader_team=自身或另設）、`f.goals=goals`、team TAG_PRODUCE+faction_id、leader 給 values+loyalty。`_mk_independent_target`：faction_id=-1、可達、入 team_discovered（`_nearest_independent` 找得到）。注意 leader.loyalty 設定（PersonData.loyalty）。

- [ ] **Step 3: 跑測確認 FAIL**

- [ ] **Step 4: 實作**

`options.gd` REGISTRY 加：
```gdscript
	"攻擊": [["faction_duty", "faction_duty"], ["attack_drive", "attack"]],
```
applicable 加：
```gdscript
			"攻擊":
				if ctx.faction_directive == "攻擊" and ctx.faction_attack_target != -1: out.append(opt)
```
to_task 加：
```gdscript
		"攻擊":
			var atid: int = FactionAISystem.new()._nearest_independent(state, team)
			if atid == -1: return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
			return {"task": TeamData.TASK_ATTACK, "target": state.teams[atid].tile_pos, "combat_target": atid}
```
> combat_target 接線複用 `_decide_unified:860`（`if td.has("combat_target")`）零新接線。

`docs/invariants.md` 加「混合協調（他域 stakes）」段（接「隊目標單一 owner」後）：
```markdown
## 混合協調（faction stakes vs team 日常）
- **stakes-to-faction → 頂層協同；team 日常 op → 個體**（ruling §1）。stakes（攻擊；後續徵收/外交/立國/大徵收）由霸主 `_update_goals` 設 `f.goals`（readiness/belief gate=稀有蓄意）；unified 隊經 `faction_duty` term 響應。日常（貿易/掠奪/scout/survival）無 faction_duty=各隊個體決。
- **頂層決 WHETHER，人格染 HOW**：派系 directive 決定「要不要打」；member 經 `攻擊` option 的 `attack_drive×attack`(好戰/殘忍) 染色執行強度（好戰積極/慎重勉強）。協同≠同質。
- **脫軌逃閥**：`faction_duty` weight 受 loyalty 調（`loy − max(0,野心−0.5)×DEFECT_K`）→ 低忠誠+高野心 member 的個人驅力（survival/野心/貿易）可蓋過 faction_duty → 不參戰/自走=破framework脫軌。faction_duty 是**加權 term 非 hard override**（非 100% 服從，by construction）。
- **危時不為派系打仗**：survival-class term 危時量級碾壓 faction_duty（食物優先）。
```

- [ ] **Step 5: 跑測 PASS + 既有全綠**（TC1/4/6/7 原樣：無 directive 時 `攻擊` 不 applicable→零影響）

- [ ] **Step 6: Commit**
```
git add scripts/simulation/decision/options.gd docs/invariants.md scripts/debug/headless_test.gd
git commit -m "feat(decision): 啟用 攻擊 stakes option + invariants 混合協調段 (P3)"
```

---

### Task 3: believability 驗證 + world_sim over-war 量測

**Files:**
- Test: `scripts/debug/headless_test.gd`
- 量測: world_sim 2yr + framework + game_sim_multi

**Interfaces:** Consumes 全鏈。Produces 信心：人格染 HOW + 脫軌逃閥 + 危時不參戰 + non-unified 不變 + 多數不主動攻擊（ruling §3 feel）。

- [ ] **Step 1: 寫 believability 測**
```gdscript
func _test_p3_war_believability() -> void:
	var state := WorldState.new()
	var cfg := {"map": {"radius": 5, "resource_richness": 5}, "teams": []}
	GameSetup.setup(state, cfg)
	var fa := FactionAISystem.new()
	# (a) 人格染 HOW：同 directive+忠誠，好戰 vs 慎重溫和 → 攻擊 util 好戰 > 溫和
	var fierce := _mk_unified_faction_member(state, Vector2i(3,3), {"好戰":0.9,"殘忍":0.7,"_loyalty":0.8})
	var meek := _mk_unified_faction_member(state, Vector2i(3,3), {"好戰":0.2,"殘忍":0.1,"_loyalty":0.8})
	_mk_independent_target(state, Vector2i(4,3))
	var ctx_f := DecisionContext.gather(state, fierce)
	var ctx_m := DecisionContext.gather(state, meek)
	var u_f := DecisionTerms.weight("attack", ctx_f.leader_values) * DecisionTerms.eval("attack_drive", ctx_f, "攻擊")
	var u_m := DecisionTerms.weight("attack", ctx_m.leader_values) * DecisionTerms.eval("attack_drive", ctx_m, "攻擊")
	assert(u_f > u_m, "[p3] 好戰 member 攻擊染色未高於溫和")
	# (b) 危時不參戰：忠誠好戰 member 但糧危 → survival 贏（非攻擊）
	var starving := _mk_unified_faction_member(state, Vector2i(3,3), {"好戰":0.9,"_loyalty":0.9})
	starving.resources["food"] = 1.0   # food_days<1
	_mk_independent_target(state, Vector2i(4,3))
	fa._decide_unified(state, starving)
	assert(starving.current_task != TeamData.TASK_ATTACK, "[p3] 餓 member 竟為派系打仗 task=%s" % starving.current_task)
	print("[p3] war believability OK")
```

- [ ] **Step 2: 跑測 PASS**

- [ ] **Step 3: world_sim 2yr 量測**
```
$env:GODOT_TIMEOUT="900"; .\tools\godot.ps1 --headless --script scripts/debug/world_sim.gd
```
記數據：2yr 不全滅、InvariantViolation=0；派系 directive=攻擊 時 unified member 參戰 emergent（協同 war 可見，`faction_goal`/TASK_ATTACK on unified）；**多數派系多數時不主動攻擊**（ruling §3 feel——無 over-war，世界非全戰）；存活隊穩。unseeded→看機制非絕對閾。**若該 run 無派系觸發攻擊 directive**=機制 headless 證即可（rare tail，記）。

- [ ] **Step 4: framework + 守恆閘**
```
.\tools\godot.ps1 --headless --script scripts/debug/framework_validation.gd
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd
```
S1-S6 PASS、`[CoinAudit] delta`≈0、headless 全綠。

- [ ] **Step 5: Commit**
```
git add scripts/debug/headless_test.gd
git commit -m "test(p3): 混合協調 believability + world_sim over-war 量測 (P3)"
```

---

## 完成後（子 session）

1. push `git push -u origin feat/p3-hybrid-coordination`
2. handback `docs/superpowers/handbacks/2026-06-25-p3-hybrid-coordination.md`：改檔 + 與 spec/plan 差異 + world_sim 量測（攻擊 directive 觸發率、unified member 參戰否、是否 over-war、多數派系不攻擊否）+ **TC3 接線現況**（unified 有 `攻擊` option 後 feud→脫軌攻擊是否可接，或仍走 vendetta PRIO_VENDETTA）+ 連動風險（faction_duty 量級、脫軌逃閥太鬆/太緊、loyalty 注入 leader_values 副作用）+ 待確認（FACTION_DUTY_DRIVE/DEFECT_K 調否、徵收/外交/立國 後續 option 序）。
3. finishing-a-development-branch → Option 3，主 session merge。

## Self-Review（主 session）

- spec 範圍（只 攻擊、不碰 non-unified/霸主決策、無新脫軌機制、daily 無 faction_duty）→ 全 Task 對齊。
- **非 dormant** = `攻擊` option 有 live producer（`_update_goals` 攻擊 directive）→ Task 3 world_sim 驗 unified 真參戰。
- **脫軌逃閥**（invariant #2）= faction_duty weight loyalty 調 → Task 1 weight 測 + Task 2 rebel 不參戰測。
- **人格染 HOW**（invariant #1）= attack_drive×attack weight → Task 3 (a)。
- **危時 survival 碾壓** → Task 3 (b)。
- **daily 個體不變**（TC1/4/6/7）= 無 directive 時 攻擊 不 applicable → Task 2 Step 5。
- loyalty 注入 `leader_values["_loyalty"]` → 確認既有 term 讀 values 不被污染（`_` 前綴非人格值，term match 不誤讀）。
- combat_target 接線複用 `_decide_unified:860`（同 P1/P2a，零新接線）。
- 風險：over-war（FACTION_DUTY_DRIVE 1.5 量級）→ world_sim 量多數不攻擊；過頻調 TEST VALUE。
- TC3 接線存疑 → handback 報現況，不在本塊強接（避過早 scope）。
