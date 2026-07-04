# P4 頂層 stakes options（徵收/外交）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:subagent-driven-development or executing-plans. Steps use checkbox (`- [ ]`).

**Goal:** unified 隊（merchant/produce）經引擎響應派系 `徵收`/`外交` stakes directive（mirror P3 攻擊）。泛化 P3 的 `faction_directive`(單攻擊)→`faction_stakes`(多 stakes)。霸主決策步複用既有 `_update_goals`。達 unified 隊全響應 stakes（攻擊 P3 + 徵收/外交 P4）。

**Architecture:** P3 建了 faction_duty seam（loyalty 脫軌逃閥 + 攻擊 option）。P4 泛化 directive 為 stakes 集合 + 加 `徵收`(TASK_TRIBUTE→`_richest_member`)/`外交`(TASK_DIPLOMACY→`_nearest_independent`) option，全複用 faction_duty 機制 + 人格染色（mirror attack_drive）。**立國=leader-level 不做、結盟⊂外交、大徵收=徵收**。只碰 decision/ 三檔 + invariants + 測（+ P3 test/scenario 同步 faction_directive→faction_stakes）。

**Tech Stack:** Godot 4.2.2 GDScript。測試 `scripts/debug/headless_test.gd`（`=== DONE ===` 無 `SCRIPT ERROR`）。

## Global Constraints
- **UTF-8 wrapper**：Godot 走 `.\tools\godot.ps1`（PowerShell）。worktree：每 Godot/git 前 `Set-Location` 進 worktree。
- **守恆**：徵收/外交 走既有 interaction 守恆，不碰守恆數學。coin_eq 0 + InvariantAudit 0。
- **scope guard**：**只徵收/外交**。**立國/結盟/大徵收不做**。**不碰 non-unified 802-827、不改 `_update_goals` 霸主決策、不改 `攻擊` option 語意（只泛化共用 ctx/eval）。A 強協同擴充 3 軸不做（願景債）。** 不新 TASK_*。
- **P3 不回歸（最高風險）**：`faction_directive`→`faction_stakes` 泛化必須讓攻擊行為**等價**。驗：P3 測 + `p3_war_scenario.gd` 跟戰 3/4 重跑不變。
- **believability**：頂層決 WHETHER/人格染 HOW（徵收=貪婪/好戰、外交=義氣/計謀染色）+ 脫軌逃閥（共用 `_duty_factor`）+ 危時 survival 碾壓 + 日常個體不變（守 ruling A 強協同）。
- 新常數 `# TEST VALUE`。baseline：開工前 headless 全綠 + `p3_war_scenario` 記跟戰 3/4。

---

### Task 1: faction_directive→faction_stakes 泛化 + 徵收/外交 ctx target + 人格染色 term

**Files:**
- Modify: `scripts/simulation/decision/decision_context.gd`（泛化 + 徵收/外交 target）
- Modify: `scripts/simulation/decision/terms.gd`（faction_duty eval 泛化 + levy/diplo drive+weight）
- Modify: `scripts/debug/headless_test.gd`（P3 測 `faction_directive`→`faction_stakes` 同步 + 新測）
- Modify: `scripts/debug/p3_war_scenario.gd`（diag print 同步）

**Interfaces:**
- Consumes: `f.goals`、`FactionAISystem.new()._richest_member(state,f)`/`._nearest_independent(state,team)`、`ldr.loyalty`/values。
- Produces: ctx `faction_stakes: Array` + `faction_tribute_target(_pos)`/`faction_diplo_target(_pos)`（攻擊 target 保留）；term `faction_duty`(泛化)/`levy_drive`/`diplo_drive` eval + `levy`/`diplo` weight。

- [ ] **Step 1: 讀 decision_context.gd(P3 faction_directive 93-94)+ terms.gd(faction_duty 71/attack_drive 76)+ `_richest_member`(排除 leader 但**未排自身**)+ `_nearest_independent`。**

- [ ] **Step 2: 寫 failing test**
```gdscript
func _test_p4_stakes_terms() -> void:
	# faction_duty 泛化：攻擊/徵收/外交 各匹配 stakes + target
	var ctx_levy := DecisionContext.new()
	ctx_levy.faction_stakes = ["徵收"]; ctx_levy.faction_tribute_target = 5
	assert(DecisionTerms.eval("faction_duty", ctx_levy, "徵收") > 0.0, "[p4] 徵收 faction_duty=0")
	assert(DecisionTerms.eval("faction_duty", ctx_levy, "攻擊") == 0.0, "[p4] 無攻擊 stake 竟 faction_duty>0")
	var ctx_dip := DecisionContext.new()
	ctx_dip.faction_stakes = ["外交"]; ctx_dip.faction_diplo_target = 5
	assert(DecisionTerms.eval("faction_duty", ctx_dip, "外交") > 0.0, "[p4] 外交 faction_duty=0")
	# 人格染色：貪婪 member 徵收 weight > 溫和；義氣 member 外交 weight > 寡情
	assert(DecisionTerms.weight("levy", {"貪婪":0.9,"好戰":0.7}) > DecisionTerms.weight("levy", {"貪婪":0.1,"好戰":0.1}), "[p4] 貪婪徵收 weight 未較高")
	assert(DecisionTerms.weight("diplo", {"義氣":0.9,"計謀":0.7}) > DecisionTerms.weight("diplo", {"義氣":0.1,"計謀":0.1}), "[p4] 義氣外交 weight 未較高")
	# P3 攻擊不回歸：faction_stakes=["攻擊"]+target → faction_duty 仍 fire
	var ctx_war := DecisionContext.new()
	ctx_war.faction_stakes = ["攻擊"]; ctx_war.faction_attack_target = 5
	assert(DecisionTerms.eval("faction_duty", ctx_war, "攻擊") > 0.0, "[p4] P3 攻擊回歸")
	print("[p4] stakes terms OK")
```

- [ ] **Step 3: 跑測確認 FAIL**

- [ ] **Step 4: 實作**

`decision_context.gd`：**移除** `faction_directive: String`，**加**：
```gdscript
const STAKES_SET: Array = ["攻擊", "徵收", "外交"]   # 立國=leader-level 不納;掠奪=日常個體不納
var faction_stakes: Array = []
# faction_attack_target(_pos) P3 保留
var faction_tribute_target: int = -1
var faction_tribute_target_pos: Vector2i = Vector2i(-1, -1)
var faction_diplo_target: int = -1
var faction_diplo_target_pos: Vector2i = Vector2i(-1, -1)
```
gather（取代 P3 的 faction_directive 段）：
```gdscript
	if team.faction_id != -1:
		var f = state.factions.get(team.faction_id)
		if f != null:
			for g in STAKES_SET:
				if g in f.goals: c.faction_stakes.append(g)
			if "攻擊" in c.faction_stakes:
				var _at: int = _fa._nearest_independent(state, team)
				c.faction_attack_target = _at
				c.faction_attack_target_pos = state.teams[_at].tile_pos if _at != -1 else Vector2i(-1,-1)
			if "徵收" in c.faction_stakes:
				var _rt: int = _fa._richest_member(state, f)
				if _rt == team.team_id: _rt = -1   # 不對自己徵收（_richest_member 未排自身）
				c.faction_tribute_target = _rt
				c.faction_tribute_target_pos = state.teams[_rt].tile_pos if _rt != -1 else Vector2i(-1,-1)
			if "外交" in c.faction_stakes:
				var _dt: int = _fa._nearest_independent(state, team)
				c.faction_diplo_target = _dt
				c.faction_diplo_target_pos = state.teams[_dt].tile_pos if _dt != -1 else Vector2i(-1,-1)
```
> `STAKES_SET` 放 DecisionContext const（gather + 測共用）。

`terms.gd`：const `STAKES_DRIVE_BASE`（沿用 `ATTACK_DRIVE_BASE` 0.3 值，獨立常數便調）。`faction_duty` eval 泛化（取代 P3 攻擊-only）：
```gdscript
		"faction_duty":
			match opt:
				"攻擊": return FACTION_DUTY_DRIVE if ("攻擊" in ctx.faction_stakes and ctx.faction_attack_target != -1) else 0.0
				"徵收": return FACTION_DUTY_DRIVE if ("徵收" in ctx.faction_stakes and ctx.faction_tribute_target != -1) else 0.0
				"外交": return FACTION_DUTY_DRIVE if ("外交" in ctx.faction_stakes and ctx.faction_diplo_target != -1) else 0.0
			return 0.0
```
`attack_drive` eval：把 P3 的 `ctx.faction_directive != "攻擊"` 改 `"攻擊" not in ctx.faction_stakes`（等價）。加：
```gdscript
		"levy_drive":
			if opt != "徵收" or "徵收" not in ctx.faction_stakes: return 0.0
			return STAKES_DRIVE_BASE * _duty_factor(float(ctx.leader_values.get("_loyalty",0.5)), float(ctx.leader_values.get("野心",0.5)))
		"diplo_drive":
			if opt != "外交" or "外交" not in ctx.faction_stakes: return 0.0
			return STAKES_DRIVE_BASE * _duty_factor(float(ctx.leader_values.get("_loyalty",0.5)), float(ctx.leader_values.get("野心",0.5)))
```
weight 加：
```gdscript
		"levy":  return 0.2 + float(v.get("貪婪",0.5))*0.5 + float(v.get("好戰",0.5))*0.3
		"diplo": return 0.2 + float(v.get("義氣",0.5))*0.5 + float(v.get("計謀",0.5))*0.3
```

`headless_test.gd` P3 測（13684）+ `p3_war_scenario.gd`（140）：`ctx.faction_directive = "攻擊"` → `ctx.faction_stakes = ["攻擊"]`；diag print `ctx.faction_directive` → `str(ctx.faction_stakes)`。

- [ ] **Step 5: 跑測 PASS + 既有全綠 + P3 測綠**（重點：P3 攻擊測不破）

- [ ] **Step 6: Commit**
```
git add scripts/simulation/decision/decision_context.gd scripts/simulation/decision/terms.gd scripts/debug/headless_test.gd scripts/debug/p3_war_scenario.gd
git commit -m "feat(decision): faction_stakes 泛化(多 stakes) + 徵收/外交 ctx target + levy/diplo 染色 term (P4)"
```

---

### Task 2: 徵收 + 外交 option + invariants 更新

**Files:**
- Modify: `scripts/simulation/decision/options.gd`（REGISTRY + applicable + to_task；攻擊 applicable 同步 faction_stakes）
- Modify: `docs/invariants.md`（混合協調段 stakes 集合）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Consumes: ctx faction_stakes/targets；`_richest_member`/`_nearest_independent`；`TASK_TRIBUTE`/`TASK_DIPLOMACY`。
- Produces: `徵收`/`外交` option 可被 rank 選中 → 對應 TASK + target。

- [ ] **Step 1: 讀 options.gd（攻擊 applicable 59 用 faction_directive → 改 faction_stakes）+ to_task 直呼 finder 風格。**

- [ ] **Step 2: 寫 failing test**
```gdscript
func _test_p4_stakes_options() -> void:
	var state := WorldState.new()
	var cfg := {"map":{"radius":5,"resource_richness":5},"teams":[]}
	GameSetup.setup(state, cfg)
	var fa := FactionAISystem.new()
	# 派系 directive=徵收（有更富 member）→ 忠誠 unified member 選 徵收
	var levier := _mk_unified_faction_member(state, Vector2i(3,3), {"貪婪":0.8,"_loyalty":0.9}, ["徵收"])  # helper 擴 goals 參數
	_mk_richer_member(state, Vector2i(4,3), levier)   # 同 faction、更富、非 leader
	fa._decide_unified(state, levier)
	assert(levier.current_task == TeamData.TASK_TRIBUTE, "[p4] 忠誠 member 未響應徵收 task=%s" % levier.current_task)
	# 外交：directive=外交 + 獨立鄰 → TASK_DIPLOMACY
	var envoy := _mk_unified_faction_member(state, Vector2i(3,3), {"義氣":0.8,"_loyalty":0.9}, ["外交"])
	_mk_independent_target(state, Vector2i(4,3))
	fa._decide_unified(state, envoy)
	assert(envoy.current_task == TeamData.TASK_DIPLOMACY, "[p4] 忠誠 member 未響應外交 task=%s" % envoy.current_task)
	# 脫軌逃閥：低忠+高野 member 派系徵收 → 不參與
	var rebel := _mk_unified_faction_member(state, Vector2i(3,3), {"野心":0.9,"_loyalty":0.15,"貪婪":0.8}, ["徵收"])
	rebel.resources["goods"] = 50
	_mk_richer_member(state, Vector2i(4,3), rebel)
	fa._decide_unified(state, rebel)
	assert(rebel.current_task != TeamData.TASK_TRIBUTE, "[p4] 叛逆 member 竟服從徵收")
	print("[p4] stakes options OK")
```
> helper：`_mk_unified_faction_member` 擴第 4 參 `goals`（建 faction f.goals=goals）。`_mk_richer_member`：同 faction、food_est 更高（known_member_states）、非 leader、非自身。複用 P3 `_mk_independent_target`。

- [ ] **Step 3: 跑測確認 FAIL**

- [ ] **Step 4: 實作**

`options.gd` 攻擊 applicable（59）同步：`ctx.faction_directive == "攻擊"` → `"攻擊" in ctx.faction_stakes`。REGISTRY 加：
```gdscript
	"徵收": [["faction_duty", "faction_duty"], ["levy_drive", "levy"]],
	"外交": [["faction_duty", "faction_duty"], ["diplo_drive", "diplo"]],
```
applicable：
```gdscript
			"徵收":
				if "徵收" in ctx.faction_stakes and ctx.faction_tribute_target != -1: out.append(opt)
			"外交":
				if "外交" in ctx.faction_stakes and ctx.faction_diplo_target != -1: out.append(opt)
```
to_task（取 faction 算 target，無 ctx）：
```gdscript
		"徵收":
			var f4 = state.factions.get(team.faction_id)
			if f4 == null: return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
			var rt: int = FactionAISystem.new()._richest_member(state, f4)
			if rt == -1 or rt == team.team_id: return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
			return {"task": TeamData.TASK_TRIBUTE, "target": state.teams[rt].tile_pos}
		"外交":
			var dt: int = FactionAISystem.new()._nearest_independent(state, team)
			if dt == -1: return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
			return {"task": TeamData.TASK_DIPLOMACY, "target": state.teams[dt].tile_pos}
```
> 徵收/外交 不設 combat_target（非戰）。

`docs/invariants.md` 混合協調段更新（P3 寫的段）：stakes 集合 = **攻擊/徵收/外交**（`DecisionContext.STAKES_SET`）；立國=leader-level（`_declare_established`，非 member option）；掠奪=日常個體（非 stakes）。徵收染色=貪婪/好戰、外交染色=義氣/計謀。

- [ ] **Step 5: 跑測 PASS + 既有全綠 + P3 攻擊測綠**

- [ ] **Step 6: Commit**
```
git add scripts/simulation/decision/options.gd docs/invariants.md scripts/debug/headless_test.gd
git commit -m "feat(decision): 徵收/外交 stakes option + invariants stakes 集合 (P4)"
```

---

### Task 3: believability + P3 回歸 + world_sim

**Files:**
- Test: `scripts/debug/headless_test.gd`
- 量測: `p3_war_scenario`（P3 回歸）+ world_sim + framework + game_sim_multi

**Interfaces:** Consumes 全鏈。Produces 信心：人格染色 + 危時不參與 + 多 stakes 共存 + P3 攻擊不回歸 + non-unified 不變。

- [ ] **Step 1: 寫 believability 測**
```gdscript
func _test_p4_stakes_believability() -> void:
	var state := WorldState.new()
	var cfg := {"map":{"radius":5,"resource_richness":5},"teams":[]}
	GameSetup.setup(state, cfg)
	var fa := FactionAISystem.new()
	# 人格染色：貪婪 member 徵收 util > 溫和（同 directive+忠誠）
	var greedy := _mk_unified_faction_member(state, Vector2i(3,3), {"貪婪":0.9,"好戰":0.6,"_loyalty":0.8}, ["徵收"])
	var mild := _mk_unified_faction_member(state, Vector2i(3,3), {"貪婪":0.1,"好戰":0.1,"_loyalty":0.8}, ["徵收"])
	_mk_richer_member(state, Vector2i(4,3), greedy)
	var cg := DecisionContext.gather(state, greedy)
	var cm := DecisionContext.gather(state, mild)
	var ug := DecisionTerms.weight("levy", cg.leader_values) * DecisionTerms.eval("levy_drive", cg, "徵收")
	var um := DecisionTerms.weight("levy", cm.leader_values) * DecisionTerms.eval("levy_drive", cm, "徵收")
	assert(ug > um, "[p4] 貪婪徵收染色未高於溫和")
	# 危時不參與：糧危 member 派系徵收 → survival 贏
	var starving := _mk_unified_faction_member(state, Vector2i(3,3), {"貪婪":0.8,"_loyalty":0.9}, ["徵收"])
	starving.resources["food"] = 1.0
	_mk_richer_member(state, Vector2i(4,3), starving)
	fa._decide_unified(state, starving)
	assert(starving.current_task != TeamData.TASK_TRIBUTE, "[p4] 餓 member 竟為派系徵收")
	print("[p4] stakes believability OK")
```

- [ ] **Step 2: 跑測 PASS**

- [ ] **Step 3: P3 回歸 — war_scenario 重跑**
```
.\tools\godot.ps1 --headless --script scripts/debug/p3_war_scenario.gd
```
確認**跟戰仍 3/4**、染色（忠誠好戰 1.70 > 溫和 1.44）、不 over-war、脫軌叛離 — P3 攻擊行為**等價不變**（泛化 faction_stakes 後）。

- [ ] **Step 4: world_sim + framework + 守恆**
```
$env:GODOT_TIMEOUT="900"; .\tools\godot.ps1 --headless --script scripts/debug/world_sim.gd
.\tools\godot.ps1 --headless --script scripts/debug/framework_validation.gd
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd
```
記：2yr 不崩、stakes 協同 emergent（徵收/外交 directive 時 unified member 響應）、**經濟隊多數時照生產/貿易**（無 over-coordination）、S1-S6 PASS、coin_eq 0、InvariantViolation 0。**既有 + P3 + P2 測全綠**。

- [ ] **Step 5: Commit**
```
git add scripts/debug/headless_test.gd
git commit -m "test(p4): stakes believability + P3 回歸 + world_sim (P4)"
```

---

## 完成後（子 session）
1. push `git push -u origin feat/p4-faction-stakes-options`
2. handback `docs/superpowers/handbacks/2026-06-27-p4-faction-stakes-options.md`：改檔 + 與 spec/plan 差異 + **P3 攻擊回歸驗證（war_scenario 跟戰 3/4 不變）** + world_sim（徵收/外交 emergent、over-coordination 否）+ 連動風險（faction_stakes 重構、徵收對自身排除、多 stakes 排序抖動）+ 待確認（levy/diplo 量級、立國/結盟/大徵收後續否）。
3. finishing-a-development-branch → Option 3，主 session merge。

## Self-Review（主 session）
- spec 範圍（只徵收/外交、立國/結盟/大徵收不做、不碰 non-unified/霸主決策、A 擴充軸不做）→ 全 Task 對齊。
- **P3 攻擊不回歸**（最高風險）= faction_directive→faction_stakes 等價重構 → Task 1 P3 測 + Task 3 war_scenario 跟戰 3/4 重跑。
- **徵收對自身**：gather + to_task 雙重排除 `== team.team_id`（_richest_member 未排自身）→ Task 1/2。
- **人格染色**（invariant #1）= levy/diplo weight → Task 3 (a)。
- **脫軌逃閥**（共用 _duty_factor）= Task 2 rebel 測。
- **危時 survival 碾壓** → Task 3 (b)。
- **daily 個體不變**（TC1/4/6/7）= 無 stakes directive 時 option 不 applicable → Task 2 Step 5。
- 風險：over-coordination（經濟隊被拉徵收/外交）→ world_sim 量多數照生產；directive 稀有（霸主 gate）。
