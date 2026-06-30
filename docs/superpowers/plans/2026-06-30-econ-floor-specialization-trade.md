# 經濟底 — 閉特化-交易-換糧環 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:subagent-driven-development or executing-plans. Steps use checkbox (`- [ ]`).

**Goal:** 閉「特化-交易-換糧」環——forest/mountain 隊（食物窮、特產富）**賣特產換糧**活下來（糧倉填得起、餬口有盈餘），不再返空家乾耗餓死。= 久掛 🟡 經濟底真正關閉。**不 nerf 地形特化**（forest regen 仍 3）。

**Architecture:** 診斷確定（measured+碼）：①`返家補給` 不檢家糧倉空 → forest 返空家乾耗 ②`買糧` 需 has_specie(coin/goods) → forest 有 material 卻無 specie → 進不了換糧。修兩處 + 量級。複用既有 `_resolve_market` barter（material→food），不新交易機制。只碰 `decision/` 三檔 + 測。

**Tech Stack:** Godot 4.2.2 GDScript。測試 `scripts/debug/headless_test.gd`。

## Global Constraints
- **UTF-8 wrapper**：`.\tools\godot.ps1`。worktree：每 Godot/git 前 `Set-Location`。
- **★ 硬 guard（藍圖）：不 nerf 地形特化**。**不碰 `resource_system.gd` REGEN_RATE**（forest food 仍 3）。修的是交換閉環，非讓 forest 自己長糧。
- **守恆**：barter/trade 走既有 `_resolve_market`（守恆），不新交易數學。coin_eq 0、pop 守恆、InvariantViolation 0。
- **scope guard**：只 `decision/` 三檔（返家 home-empty gate + has_specie 納 material + 量級）+ 測。不碰戰鬥/P1/strategic_ai/REGEN_RATE。不新交易 option（複用 買糧 TASK_TRADE barter，先驗夠不夠）。
- baseline：開工前 headless 全綠 + `food_ledger_diagnose`（記 forest granary=0/餬口）+ `warring_states_seed`（記非 plains 餓）。

---

### Task 1: `返家補給` home-empty gate + `has_specie` 納 material

**Files:**
- Modify: `scripts/simulation/decision/decision_context.gd`（`home_food` 欄 + gather；`has_specie` 廣義）
- Modify: `scripts/simulation/decision/options.gd`（返家補給 applicable + home_food gate）
- Modify: `scripts/simulation/decision/terms.gd`（常數 `RESTOCK_MIN`/`MATERIAL_TRADE_MIN`；可選 restock_need 縮放）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Consumes: `ResourceSystem.own_granary_tile`/granary food、`team.resources`（material/ore/coin/goods）、`_find_own_outpost`。
- Produces: `ctx.home_food: float`；`has_specie` = coin>0 or goods≥10 or material≥MATERIAL_TRADE_MIN；`返家補給` applicable 要 home_food≥RESTOCK_MIN。

- [ ] **Step 1: 讀 decision_context.gd(has_home_outpost/has_specie/own_granary 65/has_specie 行) + options.gd(返家補給 applicable 37-42、買糧 applicable) + ResourceSystem.own_granary_tile(回家 tile 取 granary food)。**

- [ ] **Step 2: 寫 failing test**
```gdscript
func _test_econ_empty_home_no_return() -> void:
	# forest 隊 food危 + 家糧倉空 + 有 material + 鄰市集 → 不返空家、選買糧(換糧)
	var state := WorldState.new(); var cfg := {"map":{"radius":5},"teams":[]}; GameSetup.setup(state, cfg)
	var fa := FactionAISystem.new()
	var forester := _mk_forest_team_empty_home(state, Vector2i(2,2))  # helper: food<3, 家 granary=0, material 充, 無 coin/goods, 鄰市集
	var ctx := DecisionContext.gather(state, forester)
	assert(ctx.home_food < 1.0, "[econ] 前置:家糧倉非空")
	assert(ctx.has_specie, "[econ] material 充卻 has_specie=false(未納特產)")
	var applic := DecisionOptions.applicable(ctx)
	assert("返家補給" not in applic, "[econ] 空家仍 offer 返家補給(該 gate 掉)")
	assert("買糧" in applic, "[econ] 有 material+市集卻不能買糧")
	fa._decide_unified(state, forester)
	assert(forester.current_task == TeamData.TASK_TRADE, "[econ] forest 隊未去換糧 task=%s" % forester.current_task)
	# 對照:家有糧 → 返家補給 仍 applicable
	var homed := _mk_forest_team_full_home(state, Vector2i(2,2))  # 家 granary 足
	assert("返家補給" in DecisionOptions.applicable(DecisionContext.gather(state, homed)), "[econ] 家有糧竟不返")
	print("[econ] empty-home gate + material specie OK")
```

- [ ] **Step 3: 跑測 FAIL**

- [ ] **Step 4: 實作**
`decision_context.gd`：
```gdscript
var home_food: float = 0.0
# gather：自家糧倉 food（空家判定）
var _gt: HexTileData = ResourceSystem.own_granary_tile(state, team)
c.home_food = float(_gt.public_storage.get("food", 0)) if _gt != null else 0.0
# has_specie 廣義納特產（material/ore = forest/mountain 換糧籌碼）
c.has_specie = float(team.resources.get("coin",0)) > 0.0 \
	or float(team.resources.get("goods",0)) >= 10.0 \
	or float(team.resources.get("material",0)) >= DecisionTerms.MATERIAL_TRADE_MIN \
	or float(team.resources.get("ore_iron",0)) + float(team.resources.get("ore_gold",0)) >= DecisionTerms.MATERIAL_TRADE_MIN
```
`options.gd` 返家補給 applicable 加 home_food gate：
```gdscript
			"返家補給":
				if ctx.has_home_outpost and ctx.home_food >= DecisionTerms.RESTOCK_MIN and ( \
						(ctx.is_merchant and ctx.food_days < DecisionTerms.RESTOCK_DAYS) \
						or ctx.food_days < DecisionTerms.DESPERATION_DAYS):
					out.append(opt)
```
`terms.gd`：`const RESTOCK_MIN: float = 10.0`（家至少這麼多糧才值得返，TEST VALUE）+ `const MATERIAL_TRADE_MIN: float = 20.0`（特產夠換糧的量，TEST VALUE）。

- [ ] **Step 5: 跑測 PASS + 既有全綠**（注意：返家 gate 影響既有有家 survival 隊——家有糧者不變）

- [ ] **Step 6: Commit**
```
git add scripts/simulation/decision/ scripts/debug/headless_test.gd
git commit -m "feat(econ): 返家補給 home-empty gate + has_specie 納特產(material/ore) — 閉特化換糧環 (econ-floor)"
```

---

### Task 2: 量級校 + believability + 戰國 seed (a)/經濟底 驗收

**Files:**
- Modify: `scripts/simulation/decision/terms.gd`（buyfood weight 視需提）
- Test: `scripts/debug/headless_test.gd`
- 量測: food_ledger_diagnose + warring_states_seed 重跑

- [ ] **Step 1: 寫 believability 測**（forest 隊賣 material→換糧→糧倉填、餬口盈餘；plains 隊家有糧→仍返家非 over-buy；無 material 無 coin 真窮→落乞食非買糧）。

- [ ] **Step 2: 跑測 PASS。**

- [ ] **Step 3: food_ledger 重跑（核心驗）**
```
GODOT_TIMEOUT=2000 ... food_ledger_diagnose.gd  （背景）
```
驗：forest 能人（T18 型）granary **0→正**、income/d **> burn/d（net>0 盈餘）**、不卡 return_home（去 TASK_TRADE 換糧）。若仍餬口無盈餘 → 提 buyfood weight 或查 barter 量（material→food 換得夠否）。

- [ ] **Step 4: warring_states + 守恆/framework**
```
GODOT_TIMEOUT=3000 ... warring_states_seed.gd  （背景）
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd
.\tools\godot.ps1 --headless --script scripts/debug/framework_validation.gd
```
驗：非 plains 隊**不餓死潮、pop 能長**（攀爬累積段通）；plains/forest 互市可見（TASK_TRADE 換糧）；coin_eq 0、InvariantViolation 0、S1-S6 PASS。**確認 REGEN_RATE 未改（forest 仍 3）**。
- [ ] **Step 5: Commit。**

---

## 完成後（子 session）
1. push `feat/econ-floor-specialization-trade`。
2. handback：改檔 + 與 plan 差異 + **食物收支重跑（forest granary 0→正/net>0 否）** + 戰國 seed（非 plains 餓死潮消否/pop 長否）+ 守恆 + **確認沒 nerf 地形（REGEN_RATE 未動）** + 連動風險（返家 gate 對既有有家 survival 隊、has_specie 納 material 對 plains 隊、barter 換糧量足否）+ 待確認（RESTOCK_MIN/MATERIAL_TRADE_MIN/buyfood weight 量級）。
3. finishing → Option 3，主 session merge。

## Self-Review（主 session）
- 藍圖 guard（不 nerf 地形）→ REGEN_RATE 未碰（Task 4 確認）。
- 閉環 = 返家空家 gate（forester 不乾耗）+ has_specie 納特產（material 可換）+ barter 複用（_resolve_market）→ Task 1 測 + Task 3 food_ledger granary 0→正。
- believability = forest 靠賣木買糧活（非自己長糧）；plains 家有糧仍返（不 over-buy）。
- 守恆 = barter 走既有 _resolve_market（不新數學）→ coin_eq 0。
- 風險：返家 gate 誤傷既有有家隊（家有糧者 home_food≥RESTOCK_MIN 仍 applicable，不變）；量級（買糧 vs 覓食 forest）→ seed 校。
