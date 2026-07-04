# 買糧 求生 option（Phase 1）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:subagent-driven-development or executing-plans. Steps use checkbox (`- [ ]`).

**Goal:** 補 `買糧` engine survival option（distance-discounted），閉「有錢商隊缺糧卻紮營/乞食不買糧」對稱缺口（measure 證 `buyfood_measure`）。`掠奪`/`返家補給`/`覓食` 暫不動（Phase 2 才距離折扣全套）。

**Architecture:** 複用 `_nearest_market_outpost`(WS-2b 市集巡訪)+ `TASK_TRADE` 到場 `_resolve_market` 買糧（餓隊 food local_value 高→買 food）。`買糧` 入 `SURVIVAL_OPTION_SET` → P2b-1 委派 rank_survival 自動全隊化。**只碰 decision/ 三檔 + 測**。

**Tech Stack:** Godot 4.2.2 GDScript。測試 `scripts/debug/headless_test.gd`（`=== DONE ===` 無 `SCRIPT ERROR`）。

## Global Constraints
- **UTF-8 wrapper**：Godot 走 `.\tools\godot.ps1`（PowerShell）。worktree：每 Godot/git 前 `Set-Location` 進 worktree。
- **守恆**：買糧走既有 `_resolve_market` 守恆，不碰守恆數學。coin_eq 0 + InvariantAudit 0。
- **scope guard**：**只 `買糧`（Phase 1）**。**不碰 `掠奪`/`返家補給`/`覓食`/`投靠`/`紮營`/`乞食` 既有 term/weight**（Phase 2 才距離折扣）。不新 TASK_*。不改市集/order/trade 執行。
- **believability**：role=權重非 gate（商隊高/他隊低能買，守 tc7）；無錢不 applicable（乞食真語意=無錢才乞）；危時量級對齊 survival-class + 旅費折扣。
- 新常數 `# TEST VALUE`。baseline：開工前 headless 全綠 + 重跑 `buyfood_measure`（現首選紮營，改後應買糧）。

---

### Task 1: 市集 ctx 欄 + `buyfood_drive`/`buyfood` term + `買糧` option

**Files:**
- Modify: `scripts/simulation/decision/decision_context.gd`（市集欄 + gather + `_is_merchant` 注入）
- Modify: `scripts/simulation/decision/terms.gd`（const + eval + weight）
- Modify: `scripts/simulation/decision/options.gd`（REGISTRY + SURVIVAL_OPTION_SET + applicable + to_task）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Consumes: `FactionAISystem.new()._nearest_market_outpost(state,team)->Vector2i`、`_hex_dist`、`team.resources` coin/goods、`ctx.food_days`/`is_merchant`、`TeamData.TASK_TRADE`。
- Produces: ctx `has_food_market`/`food_market_pos`/`food_market_dist`/`has_specie`（+`leader_values["_is_merchant"]` 注入）；term `buyfood_drive` eval + weight `buyfood`；option `買糧`（applicable/to_task）+ 入 `SURVIVAL_OPTION_SET`。

- [ ] **Step 1: 讀 decision_context.gd gather（P3 `_loyalty` 注入法 + `_fa` 共用）+ terms.gd（DESPERATION_SCALE/DAYS、NON_MERCHANT_TRADE_FACTOR）+ options.gd（SURVIVAL_OPTION_SET、applicable/to_task 直呼 finder 風格）+ `_nearest_market_outpost`(faction_ai:1255).**

- [ ] **Step 2: 寫 failing test**
```gdscript
func _test_buyfood_term_and_option() -> void:
	# (a) buyfood_drive：餓+有市集+有 specie → >0；無 specie → 0；近市集 util > 遠市集
	var near := DecisionContext.new()
	near.food_days = 0.5; near.has_food_market = true; near.has_specie = true; near.food_market_dist = 1
	var far := DecisionContext.new()
	far.food_days = 0.5; far.has_food_market = true; far.has_specie = true; far.food_market_dist = 20
	var poor := DecisionContext.new()
	poor.food_days = 0.5; poor.has_food_market = true; poor.has_specie = false; poor.food_market_dist = 1
	assert(DecisionTerms.eval("buyfood_drive", near, "買糧") > DecisionTerms.eval("buyfood_drive", far, "買糧"), \
		"[buyfood] 近市集 util 未高於遠（旅費折扣失效）")
	assert(DecisionTerms.eval("buyfood_drive", poor, "買糧") == 0.0, "[buyfood] 無錢竟買糧 drive>0")
	# (b) weight：商隊 > 非商隊
	assert(DecisionTerms.weight("buyfood", {"_is_merchant": true}) > DecisionTerms.weight("buyfood", {"_is_merchant": false}), \
		"[buyfood] 商隊買糧 weight 未高於非商隊")
	# (c) 買糧 in SURVIVAL_OPTION_SET（全隊化）
	assert("買糧" in DecisionOptions.SURVIVAL_OPTION_SET, "[buyfood] 買糧未入 survival 子集")
	print("[buyfood] term/option OK")
```

- [ ] **Step 3: 跑測確認 FAIL**

- [ ] **Step 4: 實作**

`decision_context.gd` 欄 + gather：
```gdscript
var has_food_market: bool = false
var food_market_pos: Vector2i = Vector2i(-1, -1)
var food_market_dist: int = -1
var has_specie: bool = false
```
gather（複用 `_fa`；`_is_merchant` 注入同 `_loyalty`）：
```gdscript
	c.leader_values["_is_merchant"] = c.is_merchant
	var _mkt: Vector2i = _fa._nearest_market_outpost(state, team)
	c.has_food_market = _mkt != Vector2i(-1, -1)
	c.food_market_pos = _mkt
	c.food_market_dist = _fa._hex_dist(team.tile_pos, _mkt) if c.has_food_market else -1
	c.has_specie = float(team.resources.get("coin", 0)) > 0.0 or float(team.resources.get("goods", 0)) >= 10.0
```
> `_hex_dist` 若為 FactionAISystem private → 確認可呼（同 _nearest_market_outpost）。否則 ctx 內聯 hex 距離。

`terms.gd` const + eval + weight：
```gdscript
const BUYFOOD_DIST_FULL: float = 6.0   # TEST VALUE — 旅費折扣基準距離
```
```gdscript
		"buyfood_drive":
			if opt != "買糧" or not ctx.has_food_market or not ctx.has_specie: return 0.0
			var hunger: float = DESPERATION_SCALE * maxf(0.0, DESPERATION_DAYS - ctx.food_days)
			var dist_disc: float = BUYFOOD_DIST_FULL / maxf(float(ctx.food_market_dist), BUYFOOD_DIST_FULL)
			return hunger * dist_disc
```
```gdscript
		"buyfood":
			return 1.0 if bool(leader_values.get("_is_merchant", false)) else NON_MERCHANT_TRADE_FACTOR
```

`options.gd` REGISTRY + 子集 + applicable + to_task：
```gdscript
	"買糧": [["buyfood_drive", "buyfood"]],
```
```gdscript
const SURVIVAL_OPTION_SET: Array = ["返家補給", "覓食", "掠奪", "投靠", "紮營", "乞食", "買糧"]
```
```gdscript
			"買糧":
				if ctx.food_days < DecisionTerms.DESPERATION_DAYS and ctx.has_food_market and ctx.has_specie:
					out.append(opt)
```
```gdscript
		"買糧":
			var mp: Vector2i = FactionAISystem.new()._nearest_market_outpost(state, team)
			if mp == Vector2i(-1, -1): return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
			return {"task": TeamData.TASK_TRADE, "target": mp}
```

- [ ] **Step 5: 跑測 PASS + 既有全綠**（注意 `_is_merchant` 注入不破既有 term；SURVIVAL_OPTION_SET 加項不破 rank_survival）

- [ ] **Step 6: Commit**
```
git add scripts/simulation/decision/ scripts/debug/headless_test.gd
git commit -m "feat(decision): 買糧 survival option + buyfood_drive 旅費折扣 + 市集 ctx 欄 (買糧 Phase1)"
```

---

### Task 2: 整合驗證 + measure 重現 + world_sim

**Files:**
- Test: `scripts/debug/headless_test.gd`
- 量測: `buyfood_measure`（重現）+ world_sim 2yr + framework + game_sim_multi

**Interfaces:** Consumes 全鏈。Produces 信心：餓商隊買糧（非紮營）、無錢落乞、non-unified 全隊化、既有不回歸。

- [ ] **Step 1: 寫整合測**
```gdscript
func _test_buyfood_integration() -> void:
	var state := WorldState.new()
	var cfg := {"map": {"radius": 4, "resource_richness": 5}, "teams": []}
	GameSetup.setup(state, cfg)
	var fa := FactionAISystem.new()
	# (a) 餓商隊 + coin + 鄰市集 → 買糧（非紮營）
	var rich := _mk_starving_merchant(state, Vector2i(0,0), 500.0)  # food<3, coin500, merchant, pop>15
	_mk_market_outpost(state, Vector2i(1,0))   # 鄰市集 outpost(level>0,非自家)
	fa._decide_unified(state, rich)
	assert(rich.current_task == TeamData.TASK_TRADE, "[buyfood] 餓商隊有錢未買糧 task=%s" % rich.current_task)
	# (b) 無錢餓商隊 + 鄰市集 → 非買糧（落乞食/紮營）
	var broke := _mk_starving_merchant(state, Vector2i(0,0), 0.0)   # coin0, goods少
	_mk_market_outpost(state, Vector2i(1,0))
	fa._decide_unified(state, broke)
	assert(broke.current_task != TeamData.TASK_TRADE, "[buyfood] 無錢隊竟買糧")
	print("[buyfood] integration OK")
```
> helper `_mk_starving_merchant(state,pos,coin)`：TAG_MERCHANT、food 低使 food_days<3、pop>15(排覓食)、無 home、coin 參數。`_mk_market_outpost`：tile outpost_level≥1 + 非該隊 owner。

- [ ] **Step 2: 跑測 PASS + 重現 measure**
```
.\tools\godot.ps1 --headless --script scripts/debug/buyfood_measure.gd
```
確認改後**首選 = 買糧**（非紮營；measure script 不改，看 rank 變）。

- [ ] **Step 3: world_sim 2yr + framework + 守恆**
```
$env:GODOT_TIMEOUT="900"; .\tools\godot.ps1 --headless --script scripts/debug/world_sim.gd
.\tools\godot.ps1 --headless --script scripts/debug/framework_validation.gd
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd
```
記：2yr 不崩、餓商隊買糧 emergent（TASK_TRADE 求生情境）、無 mass starvation、撲空率（市集無糧）合理、S1-S6 PASS、coin_eq 0、InvariantViolation 0。**既有絕境/飢荒/P2a/P2b-1 測全綠**（買糧加項不破既有 survival）。

- [ ] **Step 4: Commit**
```
git add scripts/debug/headless_test.gd
git commit -m "test(buyfood): 餓商隊買糧整合 + measure 重現 + world_sim (買糧 Phase1)"
```

---

## 完成後（子 session）
1. push `git push -u origin feat/buyfood-survival-option`
2. handback `docs/superpowers/handbacks/2026-06-26-buyfood-survival-option.md`：改檔 + 與 spec/plan 差異 + measure 重現（首選紮營→買糧）+ world_sim（買糧率/撲空率/無 starvation）+ 連動風險（撲空、TASK_TRADE 到場買成別的、量級）+ 待確認（撲空容忍 vs _nearest_food_market、Phase 2 距離折扣全 options 序）。
3. finishing-a-development-branch → Option 3，主 session merge。

## Self-Review（主 session）
- spec 範圍（只 買糧、不碰既有 option term、Phase 2 延）→ 全 Task 對齊。
- **核心 gap 閉** = measure 重現（紮營→買糧，Task 2 Step 2）。
- **role 權重非 gate**（tc7）= 商隊高/非商隊低能買（Task 1 weight 測）。
- **無錢真語意** = has_specie gate（Task 2 (b)）。
- **全隊化** = SURVIVAL_OPTION_SET 加項（non-unified 委派受惠）。
- **既有不回歸** = 不碰既有 option term + 既有 survival 測綠（Task 2 Step 3）。
- 風險：撲空（市集無糧）→ world_sim 量撲空率，過頻 `_nearest_food_market` refinement；TASK_TRADE 到場買 food（local_value）→ headless 確認。
