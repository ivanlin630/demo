# 統一隊 survival 切片 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 讓 DecisionEngine 靠 util 量級擁有 unified 隊（商隊+生產隊）求生，退役 785 latch（僅 unified），使返家補給/覓食在糧危時真生效 → 商隊不旅途餓死、world_sim 履約脫 0。

**Architecture:** survival-class term 重標度（糧危時 util 量級碾壓 trade，純 argmax 贏，非 latch/tier）+ 切片邊界三處（unified 隊跳舊 `_evaluate_survival`、uses_unified hoist 到 member/solo 的 IDLE/survival gate 前）。非 unified 隊舊 survival 原樣。

**Tech Stack:** Godot 4.2.2 GDScript。測試 `headless_test.gd`（行為 assert）+ `world_sim.gd`（履約量測 `Probe.summary()`）。

## Global Constraints

- wrapper 跑 Godot：`.\tools\godot.ps1 --headless --script <path>`（UTF-8）。
- **believability 護欄（藍圖）**：survival 優先序靠**量級**（非洗平）：吃飽(food≥3)→survival util=0 照貿易；糧危(food<2.5)→survival util≥2 碾壓 trade（餓→停貿易）。不過早。
- **切片邊界**：只改 unified 隊路徑（`if uses_unified` 短路）；非 unified 隊 survival/latch/派工**零改**。
- 不碰守恆 → coin_eq/InvariantAudit 回歸 0。
- 全係數 TEST VALUE。trade util 域（驗算基準）≈ 0.5–1.5（economic 0.3+貪婪 × opp 0.8 + 承諾 0.3）。
- **切片缺口（接受）**：unified 隊暫失 loot/join/camp/beg/hunt（後續框架塊補，藍圖標記 loot/join 必還經濟隊=債）。

---

### Task 1: survival-class term 重標度 + survival 威脅化 + 覓食接真格

**Files:**
- Modify: `scripts/simulation/decision/terms.gd`（`survival_pressure`/`restock_need` eval 重標度 + 新 `threat_pressure`）
- Modify: `scripts/simulation/decision/options.gd`（`survival` REGISTRY 改 threat_pressure；`覓食` to_task 接 `_find_forage_tile`）
- Test: `scripts/debug/headless_test.gd`（加 `_test_survival_magnitude`，註冊 dispatch）

**Interfaces:**
- Consumes: `DecisionContext`（`food_days`/`threat`/`is_merchant`/`has_home_outpost`，皆已有）、`DecisionTerms.eval(term,ctx,opt)`、`DecisionOptions.applicable`/`to_task`、`DecisionEngine.decide`、`FactionAISystem._find_forage_tile(state,team)->Vector2i`(`faction_ai_system.gd:2309`)、測試 `_seed_pop`。
- Produces: 重標度後 survival_pressure（food≥3→0、food<3→4×(3−food)）、restock_need（1.5×(5−food)、無上限）、新 threat_pressure（=ctx.threat）；survival option = 威脅驅動；覓食 to_task → 真覓食格。

- [ ] **Step 1: 寫失敗測試**

`scripts/debug/headless_test.gd` 加（放 `_test_merchant_restock` 後）：

```gdscript
func _test_survival_magnitude() -> void:
	print("--- survival-class term 量級支配 ---")
	# eval 重標度驗算
	var c := DecisionContext.new()
	c.food_days = 4.0
	assert(DecisionTerms.eval("survival_pressure", c, "覓食") == 0.0, "food4(≥3)→survival_pressure 0")
	c.food_days = 2.0
	assert(abs(DecisionTerms.eval("survival_pressure", c, "覓食") - 4.0) < 0.01, "food2→survival_pressure 4.0")
	assert(abs(DecisionTerms.eval("restock_need", c, "返家補給") - 4.5) < 0.01, "food2→restock_need 4.5")
	c.threat = 0.0
	assert(DecisionTerms.eval("threat_pressure", c, "survival") == 0.0, "threat0→threat_pressure 0(休眠)")

	# decide：糧危無家商隊 → 覓食(survival_pressure 4.0 碾壓 trade)
	var s1 := WorldState.new(); s1.world = WorldData.new()
	var t := TeamData.new(); t.team_id = 0; t.tags = [TeamData.TAG_MERCHANT]
	t.tile_pos = Vector2i(5,5); t.leader_id = 100; t.current_option = ""
	_seed_pop(t, 5); t.resources = {"food": 24.0, "goods": 50.0}   # days=2、有貨
	var ldr := PersonData.new(); ldr.id = 100; ldr.values = {"貪婪": 0.5}
	s1.persons[100] = ldr; s1.teams[0] = t
	s1.team_known[0] = [_mk_order_msg("order_sell", "material", 20, 1, Vector2i(5,6))]  # 有 arb
	var opt1: String = DecisionEngine.decide(s1, t)
	assert(opt1 == "覓食", "糧危(food2)無家商隊應覓食(survival碾壓貿易)，實際=%s" % opt1)

	# decide：糧危有家商隊 → 返家補給(restock 4.5 > 覓食 4.0)
	var s2 := WorldState.new(); s2.world = WorldData.new()
	var t2 := TeamData.new(); t2.team_id = 0; t2.tags = [TeamData.TAG_MERCHANT]
	t2.tile_pos = Vector2i(5,5); t2.leader_id = 100; t2.current_option = ""
	_seed_pop(t2, 5); t2.resources = {"food": 24.0, "goods": 50.0}
	var home := HexTileData.new(); home.tile_pos = Vector2i(2,2); home.outpost_owner = 0
	home.outpost_level = 1; home.public_storage = {"food": 500.0}; s2.world.tiles[2*1000+2] = home
	var l2 := PersonData.new(); l2.id = 100; l2.values = {"貪婪": 0.5}; s2.persons[100] = l2; s2.teams[0] = t2
	var opt2: String = DecisionEngine.decide(s2, t2)
	assert(opt2 == "返家補給", "糧危(food2)有家商隊應返家補給(restock>覓食)，實際=%s" % opt2)

	# decide：吃飽商隊 → 貿易(survival 0、restock 不適用)
	var s3 := WorldState.new(); s3.world = WorldData.new()
	var t3 := TeamData.new(); t3.team_id = 0; t3.tags = [TeamData.TAG_MERCHANT]
	t3.tile_pos = Vector2i(5,5); t3.leader_id = 100; t3.current_option = ""
	_seed_pop(t3, 5); t3.resources = {"food": 240.0, "goods": 50.0}   # days=20
	var l3 := PersonData.new(); l3.id = 100; l3.values = {"貪婪": 0.5}; s3.persons[100] = l3; s3.teams[0] = t3
	s3.team_known[0] = [_mk_order_msg("order_sell", "material", 20, 1, Vector2i(5,6))]
	assert(DecisionEngine.decide(s3, t3) == "貿易", "吃飽商隊應貿易")
	print("survival magnitude OK")
```

註冊：`_test_merchant_restock()` 呼叫行後加 `_test_survival_magnitude()`。

- [ ] **Step 2: 跑測試確認失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: FAIL — 現 `survival_pressure(food2)=clampf((6-2)/6,0,1.5)=0.67`≠4.0；`threat_pressure` 無此 term→0 但 survival option 仍 survival_pressure→糧危無家商隊 decide 可能 survival 而非覓食。

- [ ] **Step 3a: 重標度 terms.gd**

`scripts/simulation/decision/terms.gd` `eval()`：`survival_pressure` case 換 + `restock_need` case 換 + 加 `threat_pressure` case：

```gdscript
		"survival_pressure":
			# 重標度：吃飽(≥WARNING 3)→0 不蓋過 trade；糧危陡升量級支配(food2→4/food0→12)。
			if ctx.food_days >= 3.0: return 0.0
			return 4.0 * (3.0 - ctx.food_days)
		"restock_need":
			if opt != "返家補給": return 0.0
			# proactive 回家：~food4 起、量級隨糧降攀升(無上限,壓過覓食使有家偏好回家)。
			return maxf(0.0, 1.5 * (RESTOCK_DAYS - ctx.food_days))
		"threat_pressure":
			# survival(FLEE)=威脅驅動(與 hunger 分離)；threat 目前 0=休眠,他域遷入補。
			return ctx.threat
```

- [ ] **Step 3b: options.gd — survival 威脅化 + 覓食接真格**

`scripts/simulation/decision/options.gd`：

REGISTRY `survival` 行改：
```gdscript
	"survival":[["threat_pressure", "survival_pressure"]],
```

`to_task()` `覓食` 行改：
```gdscript
		"覓食":   return {"task": TeamData.TASK_FORAGE, "target": FactionAISystem.new()._find_forage_tile(state, team)}
```

- [ ] **Step 4: 跑測試確認通過（含回歸）**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: PASS — `survival magnitude OK` + TC1/4/6/7 全綠（TC 用糧足隊 food≥80 → survival_pressure=0，零影響）+ `merchant restock OK`/`role applicable OK` + 既有 survival/飢荒測（非 unified 路徑，本 Task 未動 faction_ai）全綠；`=== DONE ===`。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/decision/ scripts/debug/headless_test.gd
git commit -m "feat(decision): survival-class term 量級重標度+survival威脅化+覓食接真格"
```

---

### Task 2: 切片邊界 — unified 隊求生改引擎（退 latch）+ 探針

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`（B1 `_evaluate_survival` 跳 unified；B2 member uses_unified hoist；B3 solo uses_unified hoist；探針）
- Test: `scripts/debug/headless_test.gd`（加 `_test_unified_survival_boundary`，註冊 dispatch）

**Interfaces:**
- Consumes: `uses_unified(team)`、`_decide_unified(state,team)`、`_evaluate_survival(state,team)`、`SURVIVAL_TASKS`、`Probe.bump`。
- Produces: unified 隊不走舊 `_evaluate_survival`（B1）；member/solo 派工對 unified 隊在 IDLE/survival gate **前**呼叫引擎（B2/B3，退 latch）；`g1.restock_chosen`/`g1.engine_survival` 探針。

- [ ] **Step 1: 寫失敗測試**

`scripts/debug/headless_test.gd` 加（放 `_test_survival_magnitude` 後）：

```gdscript
func _test_unified_survival_boundary() -> void:
	print("--- 統一隊 survival 切片邊界 ---")
	var fai := FactionAISystem.new()
	# B1：unified 隊(商隊)糧危 → _evaluate_survival 早退(不設舊 survival task)
	var s1 := WorldState.new(); s1.world = WorldData.new()
	var t := TeamData.new(); t.team_id = 0; t.tags = [TeamData.TAG_MERCHANT]
	t.tile_pos = Vector2i(5,5); t.leader_id = 100; t.current_task = TeamData.TASK_IDLE
	_seed_pop(t, 5); t.resources = {"food": 0.0}   # 絕糧
	var ldr := PersonData.new(); ldr.id = 100; s1.persons[100] = ldr; s1.teams[0] = t
	fai._evaluate_survival(s1, t)
	assert(t.current_task == TeamData.TASK_IDLE, "B1:unified 隊舊 survival 應早退(不設 task)，實際=%s" % t.current_task)
	# 非 unified 隊(軍隊)糧危 → 舊 survival 照觸發(離開 IDLE)
	var s2 := WorldState.new(); s2.world = WorldData.new()
	var t2 := TeamData.new(); t2.team_id = 0; t2.tags = [TeamData.TAG_MILITARY]
	t2.tile_pos = Vector2i(5,5); t2.leader_id = 100; t2.current_task = TeamData.TASK_IDLE
	_seed_pop(t2, 5); t2.resources = {"food": 0.0}
	var l2 := PersonData.new(); l2.id = 100; s2.persons[100] = l2; s2.teams[0] = t2
	fai._evaluate_survival(s2, t2)
	assert(t2.current_task != TeamData.TASK_IDLE, "非 unified 隊舊 survival 應觸發(離 IDLE)，實際=%s" % t2.current_task)
	print("unified survival boundary OK")
```

> 註：B2/B3（member/solo hoist 退 latch）涉及 faction 派工迴圈，單測 scaffolding 重 → 由 Task 3 world_sim 行為驗證（商隊脫 latch、restock_chosen>0）。本 Task 單測鎖 B1（最易隔離且最關鍵=不雙 owner）。

註冊：`_test_survival_magnitude()` 行後加 `_test_unified_survival_boundary()`。

- [ ] **Step 2: 跑測試確認失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: FAIL — B1 assert 失敗（現 `_evaluate_survival` 對 unified 隊照觸發 survival task → current_task 離開 IDLE）。

- [ ] **Step 3a: B1 — `_evaluate_survival` 開頭跳 unified**

`scripts/simulation/faction_ai_system.gd`，`func _evaluate_survival` 開頭（`if team.leader_id == state.player_id ...` 那段後、`var pop_eff` 前）加：

```gdscript
	if uses_unified(team):
		return   # unified 隊求生改由 DecisionEngine 決(切片);舊系統不雙觸發
```

- [ ] **Step 3b: B2 — member uses_unified hoist 到 gate 前**

`scripts/simulation/faction_ai_system.gd` `_assign_member_tasks` 迴圈，現 781-795 段。改成：combat/player 檢查保留全隊，uses_unified 提到 known_task/survival gate 前：

```gdscript
		var mt: TeamData = state.require_team(mid)
		if mt.combat_target != -1: continue          # 戰鬥覆蓋(全隊)
		if not mt.player_commanded_task.is_empty(): continue  # 玩家(全隊)
		if uses_unified(mt):                          # ← hoist:引擎每 cadence 重評(unified 退 latch)
			_decide_unified(state, mt); continue
		# ↓ 以下僅非 unified 隊(原邏輯原樣)
		var snap: Dictionary = f.known_member_states.get(mid, {})
		var known_task: String = snap.get("current_task", TeamData.TASK_IDLE)
		if mt.combat_target != -1 or known_task != TeamData.TASK_IDLE:
			continue
		if mt.current_task in SURVIVAL_TASKS:
			continue  # 生存 sticky(非 unified)：不蓋過 survival task
```
（原 785-790 的 `g1.merchant_survival` 探針移除——unified 隊已不到此；改在 B 探針側量。原 791-795 商隊分支刪除——已被頂部 hoist 取代。其後 `_find_absorber`/faction-goal/`_can_manufacture` 等非 unified 派工原樣保留。）

- [ ] **Step 3c: B3 — solo uses_unified hoist 到 IDLE gate 前**

`scripts/simulation/faction_ai_system.gd` `_evaluate_solo`，現 998-1009 段。把 uses_unified 提到 IDLE gate（`if team.current_task != IDLE and not _is_stuck: return`）前：

```gdscript
func _evaluate_solo(state: WorldState, team: TeamData) -> void:
	if team.leader_id == state.player_id: return
	if team.combat_target != -1: return
	var leader_p = state.persons.get(team.leader_id)
	if leader_p == null: return
	if uses_unified(team):                          # ← hoist 到 IDLE gate 前(unified 退 latch)
		_decide_unified(state, team); return
	# stuck 視為 idle，允許重評（以下非 unified 原樣）
	if team.current_task != TeamData.TASK_IDLE and not _is_stuck(team): return
	...(原 solo 計分邏輯原樣)
```
（原 1006 的 `if uses_unified: _decide_unified; return` 刪除——已上移。）

- [ ] **Step 3d: 探針（`_decide_unified` 內）**

`scripts/simulation/faction_ai_system.gd` `_decide_unified`，取得 `opt` 後加：

```gdscript
	if opt == "返家補給": Probe.bump("g1.restock_chosen")
	elif opt in ["覓食", "survival"]: Probe.bump("g1.engine_survival")
```

- [ ] **Step 4: 跑測試確認通過（含回歸）**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: PASS — `unified survival boundary OK` + Task1 測 + TC1/4/6/7 + 既有 survival/飢荒測（非 unified 路徑原樣）全綠；`=== DONE ===`、coin_eq=0、InvariantAudit 0。**若既有商隊/生產隊行為測因 hoist 改派工而紅 → 檢查是否預期變更（unified 隊現走引擎），記錄回報 systems，勿硬改測試掩蓋。**

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(decision): 統一隊 survival 切片邊界 — 退785 latch+引擎擁有unified求生+探針"
```

---

### Task 3: world_sim 履約脫 0 + believability + 全回歸

**Files:**
- Verify only：`scripts/debug/world_sim.gd`、`probe_stats.gd`、`headless_test.gd`

**Interfaces:**
- Consumes: `Probe.summary()`（`g1.order_fulfilled`/`g1.restock_chosen`/`g1.engine_survival`/`g1.merchant_survival`/`g1.market_arrive`/`訂單履約率`）；`[Market]成交` print；`team_trace.gd`。

- [ ] **Step 1: 跑 world_sim 取數據**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/world_sim.gd`
記 `[ProbeSummary]`：`g1.order_fulfilled`、`g1.restock_chosen`、`g1.engine_survival`、`g1.market_arrive`、成交數。
> 基準（修前）：`order_fulfilled≈0`、`restock_chosen=0`、`merchant_survival≈164`、成交≈0。

- [ ] **Step 2: 判定脫 0 + believability**

- **履約脫 0（主目標）**：`g1.order_fulfilled > 0` + `[Market]成交` 常態 + `g1.restock_chosen > 0`（返家補給真生效）。
- **believability（藍圖守則）**：trace 抽樣一支商隊 → 「貿易↔返家補給」迴路（carried 週期回補、不再 drift 餓死）、貿易占多數（無 mush）、危時(food<2.5)不貿易（走覓食/返家補給）。
- **標記 2（藍圖）**：trace 一支**無家經濟隊**（無 outpost+覓食失敗）→ 須 believably 退化（持續覓食/餓死 OK），**不卡 stuck/鬼打牆**（task 不凍在同格同 target 數十 tick 不動）。
- 未過 → Step 3。

- [ ] **Step 3: 診斷未脫 0 / 異常（measure-first，勿猜）**

trace 一支 `TAG_MERCHANT`：
1. `restock_chosen=0`？→ 返家補給仍選不上：檢查 food_days 是否落在適用窗、restock_need 量級是否如驗算（vs trade）。
2. 商隊脫 latch 了嗎？（B2/B3 生效 → 商隊 current_task 不再卡 survival 不動；應見 貿易/返家補給 切換）。
3. 到家補 carried 了嗎？（返家補給→RETURN_HOME→到家 WS-2d ration 補）。
4. 脫 survival 後與生產隊 co-located 成交？（否則屬成交層，sub-proj A 已驗生產側，回報）。
5. 標記 2：無家隊是否 stuck（同格同 target 凍住）？根因 + 證據寫 handback。

- [ ] **Step 4: 全回歸閘**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: 全綠 `=== DONE ===`；Task1/2 新測 + TC1/4/6/7 + sub-proj A 測 + 既有 survival/飢荒測 全 OK；coin_eq/InvariantAudit 0。

- [ ] **Step 5: Commit 量測記錄（無 code 改則寫 handback，跳過 commit）**

```bash
git add scripts/debug/headless_test.gd
git commit -m "test(decision): world_sim 統一隊survival切片+履約脫0驗收"
```

---

## 完成後

子 session handback 給 systems：
- 履約 count 前/後（order_fulfilled/restock_chosen/engine_survival/market_arrive/成交）。
- 商隊「貿易↔返家補給」迴路 trace（carried 週期回補、貿易占多數、危時不貿易）。
- **標記 2**：無家經濟隊 believably 退化（不 stuck）的 trace 結果。
- 非 unified 隊 survival 不變（既有測綠 + trace 確認 camp/beg/loot 路徑非 unified 隊照走）。
- 履約是否真端到端脫 0；任何出範疇因。

systems 收後更新 progress + memory，回 handback 知會藍圖（履約脫 0 + believability 量測 + 標記 2 結果）。

## Self-Review

- **Spec coverage**：spec §1 survival_pressure 重標度 / §2 restock_need / §3 survival 威脅化(threat_pressure) / §4 覓食 to_task = Task1；§B1/B2/B3 切片邊界 + 探針 = Task2；驗收(履約脫0/believability/標記2 無家隊/非unified不變/回歸) = Task3 + 各 Step4。全覆蓋。
- **Placeholder scan**：無 TBD；code step 附完整碼；Step3 診斷條件分支非 placeholder。
- **Type consistency**：`survival_pressure`/`restock_need`/`threat_pressure` eval 對應 option（survival REGISTRY 改 threat_pressure；覓食/survival 用 survival_pressure 與 threat_pressure）；weight key：survival REGISTRY `[["threat_pressure","survival_pressure"]]` → eval(threat_pressure) × weight("survival_pressure"=1.0)，一致；`_find_forage_tile(state,team)->Vector2i`、`uses_unified`/`_decide_unified` 簽名一致；B2/B3 保留 combat/player 全隊守衛 + 非 unified 原邏輯。RESTOCK_DAYS=5.0/WARNING 硬編 3.0（與 faction_ai WARNING_DAYS 對齊）。
