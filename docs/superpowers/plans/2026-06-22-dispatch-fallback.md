# 引擎 dispatch-fallback Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `_decide_unified` 選最高 util 的「可派」option（非選了無效 target 就放棄），修 unified 經濟隊深危覓食無格→凍死缺口（藍圖標記 2）。

**Architecture:** `DecisionEngine` 加 `rank()`（options 依 util 降序，index tiebreak 保與現 argmax 首勝一致）；`decide` 改 = `rank()[0]`（行為不變）；`_decide_unified` 迭代 rank 取首個可派 option。

**Tech Stack:** Godot 4.2.2 GDScript。測試 `headless_test.gd` + `world_sim.gd`。

## Global Constraints

- wrapper 跑 Godot：`.\tools\godot.ps1 --headless --script <path>`（UTF-8）。
- **decide 行為不變**：`decide`=`rank()[0]`，rank 用 index tiebreak（util 相等→applicable 順序在前者勝，同現 argmax strict `>`）→ TC1/4/6/7 原樣。
- **believability（藍圖標記 2）**：危機隊不凍死（持續嘗試/餓死 OK）。survival 量級支配不變（危時 survival-class util 最高、優先嘗試）。
- 不碰守恆 / survival term 量級 → coin_eq/InvariantAudit 0。
- 切片缺口（loot/join/camp/beg 還經濟隊）= 藍圖標記 1 債，非本塊。

---

### Task 1: `DecisionEngine.rank` + `decide` 改用 rank

**Files:**
- Modify: `scripts/simulation/decision/decision_engine.gd`
- Test: `scripts/debug/headless_test.gd`（加 `_test_engine_rank`，註冊）

**Interfaces:**
- Consumes: `DecisionContext.gather`、`DecisionOptions.applicable`/`terms_of`、`DecisionTerms.weight`/`eval`、`COMMITMENT_BONUS`。
- Produces: `DecisionEngine.rank(state, team) -> Array`（options util 降序，index tiebreak）；`decide` = `rank()[0]`（回 best、設 current_option，簽名/行為不變）。

- [ ] **Step 1: 寫失敗測試**

`scripts/debug/headless_test.gd` 加（放 `_test_unified_seam` 附近，決策測群內）：

```gdscript
func _test_engine_rank() -> void:
	print("--- 決策引擎 rank 降序 + decide=rank[0] ---")
	var state := WorldState.new(); state.world = WorldData.new()
	# 吃飽商隊有貨+arb → 貿易應 rank 首；rank 回 Array 且首=decide
	var t := _mk_merchant_team(state, {"貪婪": 0.6}, true, 500.0)
	t.current_option = ""
	var ranked: Array = DecisionEngine.rank(state, t)
	assert(ranked.size() >= 1, "rank 應回非空")
	assert(ranked[0] == "貿易", "吃飽有貨商隊 rank 首應貿易，實際=%s" % str(ranked))
	# decide == rank[0]（行為不變）
	var t2 := _mk_merchant_team(WorldState.new(), {"貪婪": 0.6}, true, 500.0)
	# 重建乾淨 state 給 decide
	var s2 := WorldState.new(); s2.world = WorldData.new()
	var t3 := _mk_merchant_team(s2, {"貪婪": 0.6}, true, 500.0); t3.current_option = ""
	var r0: String = DecisionEngine.rank(s2, t3)[0]
	t3.current_option = ""
	assert(DecisionEngine.decide(s2, t3) == r0, "decide 應 == rank[0]")
	print("engine rank OK")
```

註冊：`_test_unified_seam()` 呼叫行後加 `_test_engine_rank()`。

- [ ] **Step 2: 跑測試確認失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: FAIL — `DecisionEngine.rank` 不存在（`Invalid call ... 'rank'`）。

- [ ] **Step 3: 實作 rank + decide 改用 rank**

`scripts/simulation/decision/decision_engine.gd` 換 `decide` + 加 `rank`：

```gdscript
# options 依 util 降序（index tiebreak：util 相等→applicable 順序在前者勝，同 argmax strict >）。
static func rank(state: WorldState, team: TeamData) -> Array:
	var ctx: DecisionContext = DecisionContext.gather(state, team)
	var scored: Array = []
	var idx: int = 0
	for opt in DecisionOptions.applicable(ctx):
		var u: float = 0.0
		for tw in DecisionOptions.terms_of(opt):
			u += DecisionTerms.weight(tw[1], ctx.leader_values) * DecisionTerms.eval(tw[0], ctx, opt)
		if opt == team.current_option:
			u += COMMITMENT_BONUS
		scored.append({"u": u, "i": idx, "opt": opt})
		idx += 1
	scored.sort_custom(func(a, b):
		if a["u"] != b["u"]: return a["u"] > b["u"]
		return a["i"] < b["i"])   # tiebreak：applicable 順序
	var out: Array = []
	for e in scored: out.append(e["opt"])
	return out

static func decide(state: WorldState, team: TeamData) -> String:
	var r: Array = rank(state, team)
	if r.is_empty(): return team.current_option
	team.current_option = r[0]
	return r[0]
```

- [ ] **Step 4: 跑測試確認通過（含回歸）**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: PASS — `engine rank OK` + TC1/4/6/7 全綠（decide=rank[0] 行為不變）+ 既有決策測綠；`=== DONE ===`。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/decision/decision_engine.gd scripts/debug/headless_test.gd
git commit -m "feat(decision): DecisionEngine.rank(util降序+tiebreak) + decide改用rank"
```

---

### Task 2: `_decide_unified` 退次佳可派 option

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`（`_decide_unified`）
- Test: `scripts/debug/headless_test.gd`（加 `_test_dispatch_fallback`，註冊）

**Interfaces:**
- Consumes: `DecisionEngine.rank(state,team)->Array`（Task 1）、`DecisionOptions.to_task`、`TaskArbiter.try_set`、`Probe.bump`。
- Produces: `_decide_unified` 迭代 rank 取首個可派（target 有效或 FLEE）→ 設 current_option=實際派出 + dispatch；全不可派 → no-op。

- [ ] **Step 1: 寫失敗測試**

`scripts/debug/headless_test.gd` 加（放 `_test_unified_survival_boundary` 後）：

```gdscript
func _test_dispatch_fallback() -> void:
	print("--- _decide_unified 退次佳可派(覓食無格→返家補給) ---")
	var fai := FactionAISystem.new()
	# 深危有家商隊@遠處、無覓食格(世界空,無wild_game) → argmax 覓食(無格)→應退返家補給
	var s := WorldState.new(); s.world = WorldData.new()
	var t := TeamData.new(); t.team_id = 0; t.tags = [TeamData.TAG_MERCHANT]
	t.tile_pos = Vector2i(5,5); t.leader_id = 100; t.current_task = TeamData.TASK_IDLE; t.current_option = ""
	_seed_pop(t, 5); t.resources = {"food": 12.0}   # days=1,深危
	var home := HexTileData.new(); home.tile_pos = Vector2i(2,2); home.outpost_owner = 0
	home.outpost_level = 1; home.public_storage = {"food": 500.0}; s.world.tiles[2*1000+2] = home
	var ldr := PersonData.new(); ldr.id = 100; s.persons[100] = ldr; s.teams[0] = t
	# 確認 argmax 首選覓食(無格,untargetable)
	var ranked: Array = DecisionEngine.rank(s, t)
	assert(DecisionOptions.to_task(s, t, ranked[0])["target"] == Vector2i(-1,-1) or ranked[0] == "覓食", \
		"前置:rank 首應覓食且無格(untargetable)，rank=%s" % str(ranked))
	fai._decide_unified(s, t)
	assert(t.current_task == TeamData.TASK_RETURN_HOME, \
		"覓食無格 → 應退返家補給(RETURN_HOME)不凍，實際=%s" % t.current_task)
	assert(t.current_option == "返家補給", "current_option 應追蹤實際派出=返家補給，實際=%s" % t.current_option)
	print("dispatch fallback OK")
```

註冊：`_test_unified_survival_boundary()` 行後加 `_test_dispatch_fallback()`。

- [ ] **Step 2: 跑測試確認失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: FAIL — 現 `_decide_unified` 覓食無格 → `return` 不設 task → current_task 留 IDLE（≠RETURN_HOME）。

- [ ] **Step 3: 改 `_decide_unified` 退次佳可派**

`scripts/simulation/faction_ai_system.gd` `_decide_unified` 換成（保留 survival sticky 註解 + 探針）：

```gdscript
func _decide_unified(state: WorldState, team: TeamData) -> void:
	for opt in DecisionEngine.rank(state, team):
		var td: Dictionary = DecisionOptions.to_task(state, team, opt)
		var tgt: Vector2i = td["target"]
		if tgt == Vector2i(-1, -1) and td["task"] != TeamData.TASK_FLEE:
			continue   # 不可派 → 試次佳(修凍死)
		team.current_option = opt   # 承諾追蹤實際派出
		if opt == "返家補給": Probe.bump("g1.restock_chosen")
		elif opt in ["覓食", "survival"]: Probe.bump("g1.engine_survival")
		TaskArbiter.try_set(state, team, td["task"], tgt, TaskArbiter.PRIO_DISPATCH, "unified")
		return
	# 全不可派 → 保持現行(no-op)
```

- [ ] **Step 4: 跑測試確認通過（含回歸）**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: PASS — `dispatch fallback OK` + Task1 測 + TC1/4/6/7 + survival magnitude/boundary + merchant restock + 既有 survival/飢荒測 全綠；`=== DONE ===`、coin_eq/InvariantAudit 0。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "fix(decision): _decide_unified 退次佳可派 — 修unified經濟隊覓食無格凍死(標記2)"
```

---

### Task 3: world_sim 驗無凍死 + 履約不退 + 全回歸

**Files:**
- Verify only：`world_sim.gd`、`team_trace.gd`、`probe_stats.gd`、`headless_test.gd`

**Interfaces:**
- Consumes: `Probe.summary()`（`order_fulfilled`/`restock_chosen`/`engine_survival`）；`team_trace.gd` trace 單隊。

- [ ] **Step 1: 跑 world_sim**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/world_sim.gd`
記 `order_fulfilled`、`restock_chosen`、成交數。

- [ ] **Step 2: 判定無凍死 + 履約不退**

- **無凍死（標記 2）**：trace 一支 unified 經濟隊（尤其無家/深危）→ 不再同格同 task 凍 ~20+ 日；task 隨情境切換（覓食/返家補給/建設/貿易/移動）。深危無家隊最終餓死 = OK（believable），但**過程有動作**非凍結。
- **履約不退**：`order_fulfilled ≥ 5`（切片後值）、`restock_chosen` 維持、成交常態。
- 未過 → Step 3。

- [ ] **Step 3: 診斷（僅未過時，measure-first）**

trace 先前凍死隊：
1. 仍凍？→ 檢查 rank 是否回多 option、to_task 是否有可派者被 fallback 取到。
2. 履約退？→ 比對 restock_chosen/order_fulfilled vs 切片後基準，查 fallback 是否誤改正常決策。
3. 根因 + 證據寫 handback。

- [ ] **Step 4: 全回歸閘**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: 全綠 `=== DONE ===`；Task1/2 新測 + TC1/4/6/7 + survival 切片測 + sub-proj A 測 + 既有 survival/飢荒測 全 OK；coin_eq/InvariantAudit 0。

- [ ] **Step 5: Commit 量測記錄（無 code 改則寫 handback，跳過 commit）**

```bash
git add scripts/debug/headless_test.gd
git commit -m "test(decision): world_sim dispatch-fallback 無凍死+履約不退驗收"
```

---

## 完成後

子 session handback 給 systems：
- 無凍死 trace 證據（先前凍死隊現有動作/不凍）。
- 履約 count（order_fulfilled/restock_chosen 維持或升）。
- 回歸全綠。
- 任何出範疇因（如無家隊仍餓死=接受,屬 camp/beg 債）。

systems 收後更新 progress + memory，回 handback 知會藍圖（標記 2 達標：無凍死 believable 退化）。

## Self-Review

- **Spec coverage**：spec §1 rank=Task1；§2 decide 改用 rank=Task1；§3 _decide_unified 退次佳=Task2；驗收(無凍死/履約不退/回歸/單測)=Task1+2 單測 + Task3。全覆蓋。
- **Placeholder scan**：無 TBD；code step 附完整碼；Step3 診斷條件分支非 placeholder。
- **Type consistency**：`rank(state,team)->Array`（Task1 定義 / Task2 _decide_unified 用 / 測讀）一致；`decide`=rank[0] 簽名不變；`to_task`回 Dictionary{task,target}；`team.current_option` 設為實際派出 opt；探針 key `g1.restock_chosen`/`g1.engine_survival` 與切片一致。
