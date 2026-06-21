# 商隊餓死修 — 角色正確化 + 返家補給迴路 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 商隊不再被引擎派去定居者行為（治理/生產/建設）餓死；加「返家補給」option 形成 caravan 迴路（貿易→糧低回家補→再貿易），使 world_sim 履約脫 0。

**Architecture:** 全在統一引擎 `scripts/simulation/decision/`（不脫架構=補完商隊角色正確性，對稱 sub-project A）。①`applicable()` 駐守/生產/建設 加 `not is_merchant`（定居者專屬）②新 Option「返家補給」（context `has_home_outpost` + term `restock_need` + REGISTRY row + to_task→TASK_RETURN_HOME）。不碰舊 survival 系統 / effective_food / 守恆。

**Tech Stack:** Godot 4.2.2 GDScript。測試 `headless_test.gd`（行為 assert）+ `world_sim.gd`（履約量測 `Probe.summary()`）。

## Global Constraints

- wrapper 跑 Godot：`.\tools\godot.ps1 --headless --script <path>`（UTF-8）。
- **believability 護欄（藍圖）**：survival 優先序不動——`URGENCY_DAYS/WARNING_DAYS`、`_trigger_survival`、`_evaluate_survival` 全不碰。返家補給是 proactive 經濟行為（糧 < RESTOCK 但未瀕餓），非危機反射。
- 真瀕餓商隊 / 無家流民商隊 → 仍走既有 survival（該餓仍餓）。
- 不碰守恆（只加決策面 option/term/守衛）→ coin_eq/InvariantAudit 回歸 0。
- 全數值 TEST VALUE。`RESTOCK_DAYS=5.0`（> WARNING 3、< 典型 carried buffer ~8-10 天）。
- 現行 `applicable()`（sub-project A 後）：貿易需 `is_merchant`；生產/駐守需 `has_own_outpost`；建設恆候選。本塊在此基礎改。

---

### Task 1: 定居者 option 商隊不選（駐守/生產/建設 += not is_merchant）

商隊不再被派治理/生產/建設（定居者行為）。對稱 sub-project A。

**Files:**
- Modify: `scripts/simulation/decision/options.gd:14-27`（`applicable()`）
- Test: `scripts/debug/headless_test.gd`（加 `_test_merchant_no_settler_options`，註冊 dispatch）

**Interfaces:**
- Consumes: `DecisionContext`（`is_merchant`/`has_own_outpost`/`has_goods`/`has_arb`，皆 sub-project A 已有）、`DecisionOptions.applicable(ctx)->Array`、測試 `_mk_merchant_team`/`_mk_produce_team`。
- Produces: 商隊候選不含 駐守/生產/建設；生產隊（非 merchant）行為不變。

- [ ] **Step 1: 寫失敗測試**

`scripts/debug/headless_test.gd` 加（放在 `_test_role_applicable` 後，sub-project A 加的那個之後）：

```gdscript
func _test_merchant_no_settler_options() -> void:
	print("--- 商隊不選定居者 option(治理/生產/建設) ---")
	# 商隊 + 自家 outpost(@tile_pos) → 舊邏輯會給 生產/駐守/建設；新邏輯應排除
	var s1 := WorldState.new(); s1.world = WorldData.new()
	var m := _mk_merchant_team(s1, {"義氣": 0.8, "慎重": 0.8}, false, 500.0)  # 高 settle 人格也不該選
	var ctx_m: DecisionContext = DecisionContext.gather(s1, m)
	assert(ctx_m.is_merchant and ctx_m.has_own_outpost, "前置:商隊+有據點")
	var ap: Array = DecisionOptions.applicable(ctx_m)
	assert("駐守" not in ap and "生產" not in ap and "建設" not in ap, \
		"商隊不該有定居者 option(治理/生產/建設)，實際=%s" % str(ap))
	# 生產隊(非 merchant)+有據點 → 仍有 駐守/生產/建設(回歸不破)
	var s2 := WorldState.new(); s2.world = WorldData.new()
	var p := _mk_produce_team(s2, {"義氣": 0.6}, 500.0, true)
	var ctx_p: DecisionContext = DecisionContext.gather(s2, p)
	var ap2: Array = DecisionOptions.applicable(ctx_p)
	assert("駐守" in ap2 and "生產" in ap2 and "建設" in ap2, \
		"生產隊仍應有定居者 option，實際=%s" % str(ap2))
	print("merchant no settler options OK")
```

註冊：`scripts/debug/headless_test.gd` `_test_role_applicable()` 呼叫行後加：

```gdscript
	_test_role_applicable()
	_test_merchant_no_settler_options()
```

- [ ] **Step 2: 跑測試確認失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: FAIL — 商隊 `has_own_outpost=true` → 現邏輯給 駐守/生產/建設 → 第一個 assert 失敗。

- [ ] **Step 3: 改 applicable 守衛**

`scripts/simulation/decision/options.gd:14-27`，`applicable()` 換成：

```gdscript
static func applicable(ctx: DecisionContext) -> Array:
	var out: Array = []
	for opt in REGISTRY:
		match opt:
			"貿易":
				# roam-trade = 商隊角色（棄不棄據點巡市集）。生產隊原地掛單賣，不列候選。
				if (ctx.has_goods or ctx.has_arb) and ctx.is_merchant: out.append(opt)
			"生產", "駐守":
				# 定居者行為：需自家據點 且 非商隊（商隊不治理/生產，會 park 離糧餓死）。
				if ctx.has_own_outpost and not ctx.is_merchant: out.append(opt)
			"建設":
				# bootstrap+升級皆候選，但限定居者（商隊不蓋據點）。
				if not ctx.is_merchant: out.append(opt)
			"覓食", "survival":
				out.append(opt)   # 恆候選（survival 靠權重，非守衛）
	return out
```

- [ ] **Step 4: 跑測試確認通過（含回歸）**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: PASS — `merchant no settler options OK`；`role applicable OK`(A)/`unified seam OK`/TC1/4/6/7 全綠；`=== DONE ===` 無 assert 失敗。
> 註：TC4/TC7 用 `_mk_merchant_team`（商隊）測分歧——商隊現只剩 貿易/覓食/survival 候選。確認 TC4（野心高 vs 低）與 TC7（霸主/商人/隱士）仍**過**（商隊間靠貿易 vs 覓食/survival 權重 + 人格分歧）。**若 TC7 因商隊候選變少而 3 leader 不再 3 不同 option → 停，回報 systems**（可能 TC7 需改用混合隊型或本塊改動牽動驗收套件語意，systems 裁）。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/decision/options.gd scripts/debug/headless_test.gd
git commit -m "fix(decision): 定居者option(治理/生產/建設)商隊不選 — 對稱A角色正確化"
```

---

### Task 2: 新 Option「返家補給」（caravan 迴路）

商隊糧低 → 回自家糧倉 outpost 補 carried → 補滿再貿易。proactive，避開 survival latch。

**Files:**
- Modify: `scripts/simulation/decision/decision_context.gd`（加 `has_home_outpost` 欄位 + gather）
- Modify: `scripts/simulation/decision/terms.gd`（加 `RESTOCK_DAYS` const + `restock_need` eval）
- Modify: `scripts/simulation/decision/options.gd`（REGISTRY 加「返家補給」row + applicable + to_task）
- Test: `scripts/debug/headless_test.gd`（加 `_test_merchant_restock`，註冊 dispatch）

**Interfaces:**
- Consumes: `FactionAISystem._find_own_outpost(state,team)->Vector2i`（scan 自家 outpost，`faction_ai_system.gd:2332`，回 (-1,-1) 表無家）、`ResourceSystem.effective_food`（gather 已用）、`DecisionContext.food_days`/`is_merchant`、`TeamData.TASK_RETURN_HOME`。
- Produces: `DecisionContext.has_home_outpost: bool`；`DecisionTerms.RESTOCK_DAYS: float`；`restock_need` term；「返家補給」option（applicable: `is_merchant and food_days<RESTOCK_DAYS and has_home_outpost`；to_task→TASK_RETURN_HOME + 自家 outpost）。

- [ ] **Step 1: 寫失敗測試**

`scripts/debug/headless_test.gd` 加（放在 Task1 的 `_test_merchant_no_settler_options` 後）：

```gdscript
func _test_merchant_restock() -> void:
	print("--- 商隊返家補給 option ---")
	# 旅途商隊(@遠處,無當地據點)、carried 低、家有 outpost → 應有「返家補給」候選
	var s1 := WorldState.new(); s1.world = WorldData.new()
	var t := TeamData.new(); t.team_id = 0; t.tags = [TeamData.TAG_MERCHANT]
	t.tile_pos = Vector2i(5,5); t.leader_id = 100
	_seed_pop(t, 5); t.resources = {"food": 24.0}   # 5人 days=24/12=2 < RESTOCK(5)
	# 家 outpost 在別處(2,2)
	var home := HexTileData.new(); home.tile_pos = Vector2i(2,2)
	home.outpost_owner = 0; home.outpost_level = 1; home.outpost_type = "civilian"
	home.public_storage = {"food": 500.0}; s1.world.tiles[2*1000+2] = home
	var ldr := PersonData.new(); ldr.id = 100; ldr.team_id = 0; s1.persons[100] = ldr; s1.teams[0] = t
	var ctx: DecisionContext = DecisionContext.gather(s1, t)
	assert(ctx.is_merchant and ctx.has_home_outpost and not ctx.has_own_outpost, \
		"前置:商隊/有家可回/不站家上 — home=%s own=%s" % [str(ctx.has_home_outpost), str(ctx.has_own_outpost)])
	assert(ctx.food_days < DecisionTerms.RESTOCK_DAYS, "前置:糧低 days=%.1f" % ctx.food_days)
	var ap: Array = DecisionOptions.applicable(ctx)
	assert("返家補給" in ap, "糧低旅途商隊應有返家補給候選，實際=%s" % str(ap))
	var td: Dictionary = DecisionOptions.to_task(s1, t, "返家補給")
	assert(td["task"] == TeamData.TASK_RETURN_HOME and td["target"] == Vector2i(2,2), \
		"返家補給→RETURN_HOME 回家(2,2)，實際=%s" % str(td))

	# 糧足商隊 → 無返家補給
	var s2 := WorldState.new(); s2.world = WorldData.new()
	var t2 := TeamData.new(); t2.team_id = 0; t2.tags = [TeamData.TAG_MERCHANT]
	t2.tile_pos = Vector2i(5,5); t2.leader_id = 100
	_seed_pop(t2, 5); t2.resources = {"food": 120.0}   # days=10 > RESTOCK
	var home2 := HexTileData.new(); home2.tile_pos = Vector2i(2,2)
	home2.outpost_owner = 0; home2.outpost_level = 1; home2.public_storage = {"food": 500.0}
	s2.world.tiles[2*1000+2] = home2
	var l2 := PersonData.new(); l2.id = 100; s2.persons[100] = l2; s2.teams[0] = t2
	assert("返家補給" not in DecisionOptions.applicable(DecisionContext.gather(s2, t2)), \
		"糧足商隊不該返家補給")

	# 無家流民商隊(糧低但無 outpost) → 無返家補給(守護欄:該餓仍餓)
	var s3 := WorldState.new(); s3.world = WorldData.new()
	var t3 := TeamData.new(); t3.team_id = 0; t3.tags = [TeamData.TAG_MERCHANT]
	t3.tile_pos = Vector2i(5,5); t3.leader_id = 100
	_seed_pop(t3, 5); t3.resources = {"food": 12.0}
	var l3 := PersonData.new(); l3.id = 100; s3.persons[100] = l3; s3.teams[0] = t3
	var ctx3: DecisionContext = DecisionContext.gather(s3, t3)
	assert(not ctx3.has_home_outpost, "前置:無家")
	assert("返家補給" not in DecisionOptions.applicable(ctx3), "無家商隊不該返家補給(該走survival)")

	# 非商隊(生產隊)糧低 → 無返家補給(返家補給限商隊)
	var s4 := WorldState.new(); s4.world = WorldData.new()
	var p := _mk_produce_team(s4, {"義氣": 0.6}, 0.0, true)  # 有家但 granary food=0 → 糧低
	p.resources = {"food": 12.0}
	assert("返家補給" not in DecisionOptions.applicable(DecisionContext.gather(s4, p)), \
		"生產隊不走返家補給(原地,非商隊)")
	print("merchant restock OK")
```

註冊：Task1 測試呼叫行後加 `_test_merchant_restock()`。

- [ ] **Step 2: 跑測試確認失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: FAIL — `has_home_outpost` 無此 property（`Invalid get index 'has_home_outpost'`）或 `返家補給` 不在 REGISTRY → 候選缺。

- [ ] **Step 3a: 加 context `has_home_outpost`**

`scripts/simulation/decision/decision_context.gd`：欄位區（`var is_merchant: bool = false` 後）加：

```gdscript
var has_home_outpost: bool = false
```

`gather()` 內（`c.is_merchant = ...` 後）加：

```gdscript
	c.has_home_outpost = FactionAISystem.new()._find_own_outpost(state, team) != Vector2i(-1, -1)
```

- [ ] **Step 3b: 加 term `restock_need` + RESTOCK_DAYS**

`scripts/simulation/decision/terms.gd`：檔頭 class 宣告後加 const：

```gdscript
const RESTOCK_DAYS: float = 5.0   # TEST VALUE：商隊糧低於此 → proactive 返家補給(> WARNING 3)
```

`eval()` match 內加一個 case（放 `survival_pressure` case 後）：

```gdscript
		"restock_need":
			if opt != "返家補給": return 0.0
			return clampf((RESTOCK_DAYS - ctx.food_days) / RESTOCK_DAYS, 0.0, 1.5)
```

- [ ] **Step 3c: 加「返家補給」option（REGISTRY + applicable + to_task）**

`scripts/simulation/decision/options.gd`：

REGISTRY 加一行（line 11 `"駐守"` 後）：

```gdscript
	"返家補給":[["restock_need", "survival_pressure"]],
```

`applicable()` match 加 case（`"覓食", "survival":` 前）：

```gdscript
			"返家補給":
				# 商隊 proactive 補給：糧低於 RESTOCK 且有家可回 → 回家補 carried(避 survival latch)。
				if ctx.is_merchant and ctx.food_days < DecisionTerms.RESTOCK_DAYS and ctx.has_home_outpost:
					out.append(opt)
```

`to_task()` match 加 case（`_:` 前）：

```gdscript
		"返家補給": return {"task": TeamData.TASK_RETURN_HOME, "target": FactionAISystem.new()._find_own_outpost(state, team)}
```

- [ ] **Step 4: 跑測試確認通過（含回歸）**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: PASS — `merchant restock OK` + `merchant no settler options OK` + TC1/4/6/7 + sub-project A 測 + 既有 survival/飢荒測 全綠；`=== DONE ===`。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/decision/ scripts/debug/headless_test.gd
git commit -m "feat(decision): 返家補給 option — 商隊糧低回家補carried(caravan迴路)"
```

---

### Task 3: world_sim 履約脫 0 驗收 + believability + 全回歸

**Files:**
- Verify only：`scripts/debug/world_sim.gd`、`probe_stats.gd`、`headless_test.gd`

**Interfaces:**
- Consumes: `Probe.summary()`（`g1.order_fulfilled`/`g1.merchant_survival`/`g1.seek_market`/`g1.market_arrive`/`訂單履約率`）；`[Market] … 成交` print。

- [ ] **Step 1: 跑 world_sim 取數據**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/world_sim.gd`
記 `[ProbeSummary]`：`g1.order_fulfilled`、`g1.merchant_survival`、`g1.seek_market`、`g1.market_arrive`、成交數。
> 基準（修前）：`merchant_survival≈164`、`order_fulfilled≈0`、成交=0。長跑慢可暫降 config `max_ticks`(如 21600)快看，最終原值跑一輪。

- [ ] **Step 2: 判定脫 0**

- **過**：`order_fulfilled > 0`、`merchant_survival` 大降、`seek_market`/`market_arrive` 升、`[Market]成交` 常態。
- 未過 → Step 3。

- [ ] **Step 3: 診斷未脫 0（measure-first，勿猜）**

trace（`team_trace.gd` + 臨時 print）一支 `TAG_MERCHANT`：
1. 商隊是否走「貿易↔返家補給」迴路？carried 是否週期回補（不再單調 drift 到 0）？
2. 商隊是否仍被派治理/生產？（應無 → Task1 生效）若有 → 回查 applicable is_merchant 守衛。
3. 返家補給後是否真到家補 carried？（`_find_own_outpost` target 對嗎？到家 ration 生效嗎？）
4. 脫 survival 後是否與生產隊 co-located 成交？若到市集卻不成交 → 屬 board/co-location（sub-project A 已驗生產側），回報。
5. 根因 + 證據寫 handback 回報 systems。

- [ ] **Step 4: 全回歸閘**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: 全綠 `=== DONE ===`；新 2 測 + TC1/4/6/7 + A 測 + survival/飢荒測 全 OK；coin_eq/InvariantAudit 0。

- [ ] **Step 5: Commit 量測記錄（無 code 改則寫 handback，跳過 commit）**

```bash
git add scripts/debug/headless_test.gd
git commit -m "test(decision): world_sim 商隊迴路+履約脫0 驗收"
```

---

## 完成後

子 session handback 給 systems：
- 履約 count 前/後（order_fulfilled/merchant_survival/seek_market/成交）。
- 商隊「貿易↔返家補給」迴路 trace 證據（carried 週期回補、不再 drift 餓死、無商隊治理/生產）。
- **believability**：無家商隊 / 瀕餓商隊仍走 survival（單測 + trace）。
- TC7 是否仍過（商隊候選變少後分歧硬 bar）。
- 履約是否真端到端脫 0；任何出範疇因（如成交層）。

systems 收後更新 progress + memory，回 handback 知會藍圖（履約脫 0 + 護欄守住）。

## Self-Review

- **Spec coverage**：spec 改1(駐守/生產/建設 not is_merchant)=Task1；改2(返家補給 option:context/term/REGISTRY/applicable/to_task)=Task2；護欄(survival 不碰/瀕餓/無家仍餓)=Task1+2 守衛 + Task2 案3/4 反例測;驗收(履約脫0/角色正確/believability/回歸)=Task3 + 各 Step4；開放細節(RESTOCK_DAYS=5.0/curve/target首個outpost/到家ration)=Task2 採 5.0 + clampf 上限1.5 + `_find_own_outpost`首個 + WS-2d 不改。全覆蓋。
- **Placeholder scan**：無 TBD；code step 附完整碼；Step3 診斷條件分支非 placeholder。
- **Type consistency**：`has_home_outpost: bool`（context 定義/gather 寫/Task2 測讀）一致；`RESTOCK_DAYS: float`（terms 定義/options.applicable 引用 `DecisionTerms.RESTOCK_DAYS`/term eval 用）一致；`restock_need` eval 對應 option "返家補給"；`to_task` 回 TASK_RETURN_HOME + `_find_own_outpost(state,team)->Vector2i` 一致；REGISTRY "返家補給" terms `[["restock_need","survival_pressure"]]` 與 eval/weight key 一致（survival_pressure weight 已存在 terms.weight）。
