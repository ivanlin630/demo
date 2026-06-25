# P2b-1 survival 選擇統一 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:subagent-driven-development or executing-plans. Steps use checkbox (`- [ ]`).

**Goal:** non-unified 隊 `_trigger_survival` 的**動作選擇**改委派 engine survival-option rank（單一 owner = `DecisionTerms`/`DecisionOptions`），刪手寫 `desperation×values` branch + `*_GATE` const + `_loot_pref`/`_join_pref`/`_camp_pref` helper（消雙 owner）。保 `_evaluate_survival` gate + `_trigger_survival` entry + `PRIO_SURVIVAL`。

**Architecture:** survival 選擇本在兩處（unified=engine term、non-unified=手寫 pref branch，公式重複）。本塊把 non-unified 也接 engine 子集 rank。**保熱路徑**（1037 return_home：`返家補給` applicable generalize 給非商隊絕境）。**不全退 entry 函數（P2b-2）、不碰 unified 路徑、不碰 `_evaluate_solo`**。

**Tech Stack:** Godot 4.2.2 GDScript。測試 `scripts/debug/headless_test.gd`（`=== DONE ===` 無 `SCRIPT ERROR`）。

## Global Constraints

- **UTF-8 wrapper**：Godot 走 `.\tools\godot.ps1`（PowerShell）。worktree 子 session：每 Godot/git 前 `Set-Location` 進 worktree。
- **守恆**：loot/join/camp/beg/return 走既有守恆路徑，本 plan **不碰守恆數學**。coin_eq 0 + InvariantAudit 0。
- **scope guard（P0/P1/P2a 教訓）**：**不全退** `_evaluate_survival`/`_trigger_survival` entry。**不碰 unified `_decide_unified`/P2a options、不碰 `_evaluate_solo`、hunt 不 option 化（留 wrapper fallback）。不新平衡值**（weight/term 公式 P2a 已定，沿用）。不加 exemption 鏈。
- **measure-first 熱路徑硬閘**：先寫「有家絕境隊→TASK_RETURN_HOME」測再改；world_sim died 不暴增 vs P2a baseline。
- **~20 test 直呼點**：assertion 對不上 → 確認新「人格→動作」同義才調（**非盲放寬**）；新舊分歧揭真退化 → 停呈報。
- baseline：開工前 `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd` 全綠 + world_sim 2yr 記 died 數當 baseline。

---

### Task 1: `SURVIVAL_OPTION_SET` + `返家補給` generalize + `rank_survival`

**Files:**
- Modify: `scripts/simulation/decision/options.gd`（const + applicable generalize）
- Modify: `scripts/simulation/decision/decision_engine.gd`（`rank_survival`）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Consumes: `DecisionContext.gather`、`DecisionOptions.applicable`/`terms_of`/`to_task`、`DecisionTerms.weight`/`eval`、`ctx.is_merchant`/`has_home_outpost`/`food_days`。
- Produces: `DecisionOptions.SURVIVAL_OPTION_SET`、`返家補給` 對非商隊絕境 applicable、`DecisionEngine.rank_survival(state,team)->Array`（survival 子集降序）。

- [ ] **Step 1: 讀 options.gd applicable（返家補給 現 `is_merchant` gate）+ decision_engine.gd rank（複製改子集）。**

- [ ] **Step 2: 寫 failing test**
```gdscript
func _test_p2b1_rank_survival() -> void:
	var state := WorldState.new()
	var cfg := {"map": {"radius": 5, "resource_richness": 5}, "teams": []}
	GameSetup.setup(state, cfg)
	# (a) 返家補給 generalize：非商隊（軍隊 tag）有家 + 絕境 → 返家補給 applicable
	var soldier := _mk_homed_desperate_team(state, Vector2i(3,3), ["軍隊"], {"好戰":0.7})  # 有 home outpost、food_days<3、非 merchant
	var ranked: Array = DecisionEngine.rank_survival(state, soldier)
	assert("返家補給" in ranked, "[p2b1] 非商隊絕境無返家補給 option")
	# rank_survival 只回 survival 子集（無 貿易/生產/建設/駐守）
	for o in ranked:
		assert(o in DecisionOptions.SURVIVAL_OPTION_SET, "[p2b1] rank_survival 含非 survival option %s" % o)
	# (b) 有家絕境隊：返家補給 量級支配（restock_need 碾壓 loot）
	assert(ranked[0] == "返家補給", "[p2b1] 有家絕境隊首選非返家補給 = %s" % ranked[0])
	print("[p2b1] rank_survival OK top=%s n=%d" % [ranked[0], ranked.size()])
```

- [ ] **Step 3: 跑測確認 FAIL**（rank_survival 未定義 / 返家補給 is_merchant gate 擋軍隊）

- [ ] **Step 4: 實作**

`options.gd` 加 const（REGISTRY 後）：
```gdscript
const SURVIVAL_OPTION_SET: Array = ["返家補給", "覓食", "掠奪", "投靠", "紮營", "乞食"]
```
`返家補給` applicable 改 generalize：
```gdscript
			"返家補給":
				if ctx.has_home_outpost and ( \
						(ctx.is_merchant and ctx.food_days < DecisionTerms.RESTOCK_DAYS) \
						or ctx.food_days < DecisionTerms.DESPERATION_DAYS):
					out.append(opt)
```
`覓食` applicable 加 viable-pop 守衛（對齊舊 homeless forage 限 pop≤15；spec 開放細節定案=移入 applicable，unified 同受惠）：
```gdscript
			"覓食":
				if FactionAISystem.FORAGE_VIABLE_POP <= 0 or true: pass  # 見下，需 ctx.population
```
> **註**：`覓食` 現為恆候選（`survival` 同行）。加 pop 守衛需 ctx 有 population——**plan 決定**：`DecisionContext` 加 `var population: int`（gather `c.population = team.population`），`覓食` applicable 改 `if ctx.population <= FactionAISystem.FORAGE_VIABLE_POP: out.append(opt)`。`survival`(FLEE) 維持恆候選不動。確認 unified 大軍加此守衛不破既有測（unified 隊多小，影響小）。

`decision_engine.gd` 加 `rank_survival`（spec §2 全碼）：複製 `rank` 結構，applicable 後 `if opt not in DecisionOptions.SURVIVAL_OPTION_SET: continue`，**不寫 `team.current_option`**，承諾比對用 `team.current_task`（`DecisionOptions.to_task(state,team,opt).get("task") == team.current_task`）。

- [ ] **Step 5: 跑測 PASS + 既有全綠**（注意 `覓食` 加 pop 守衛 → 跑既有 unified/TC 測確認不破）

- [ ] **Step 6: Commit**
```
git add scripts/simulation/decision/options.gd scripts/simulation/decision/decision_engine.gd scripts/simulation/decision/decision_context.gd scripts/debug/headless_test.gd
git commit -m "feat(decision): rank_survival 子集 + 返家補給 generalize 非商隊絕境 + 覓食 pop 守衛 (P2b-1)"
```

---

### Task 2: `_trigger_survival` 委派改寫 + 刪手寫 branch/GATE/pref helper

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`（`_trigger_survival` 改寫；刪 `LOOT_GATE`/`JOIN_GATE`/`CAMP_GATE`；刪 `_loot_pref`/`_join_pref`/`_camp_pref`）
- Test: `scripts/debug/headless_test.gd`（pref 序測改斷言 weight；新 homeless 分流測）

**Interfaces:**
- Consumes: `DecisionEngine.rank_survival`、`DecisionOptions.to_task`、`_maybe_request_join_player`、`try_hunt_predator`、`TaskArbiter.try_set(...,PRIO_SURVIVAL,...)`。
- Produces: non-unified 絕境隊 task 由 rank_survival 單一 owner 決（殘忍→掠奪/義氣→投靠/野心→紮營/有家→返家/可覓→覓食/墊底→乞食/全不可派→hunt→release）。

- [ ] **Step 1: 讀 `_trigger_survival`（2373-2472 全段）+ 確認刪除邊界（保 leader 檢查/previous_task/TASK_BUILD 農田不中斷；刪 home-path 手寫 loot 分支 + desperation×values branch + fallback forage/beg）。grep 確認 `*_GATE`/`_*_pref` 無其他生產 reader（僅 test 5202-5204）。**

- [ ] **Step 2: 寫 failing test**
```gdscript
func _test_p2b1_nonunified_survival_delegation() -> void:
	var state := WorldState.new()
	var cfg := {"map": {"radius": 5, "resource_richness": 5}, "teams": []}
	GameSetup.setup(state, cfg)
	var fa := FactionAISystem.new()
	# (a) 熱路徑：非 unified 有家絕境隊 → TASK_RETURN_HOME（返家補給）
	var homed := _mk_homed_desperate_team(state, Vector2i(3,3), ["軍隊"], {"好戰":0.5})
	fa._trigger_survival(state, homed, "urgent")
	assert(homed.current_task == TeamData.TASK_RETURN_HOME, "[p2b1] 有家絕境隊未返家 task=%s" % homed.current_task)
	# (b) homeless 分流：殘忍 non-unified 隊 + 弱獵物 → 掠奪
	var raider := _mk_homeless_desperate_team(state, Vector2i(1,1), ["軍隊"], {"殘忍":0.9,"好戰":0.8})
	_mk_weak_prey_team(state, Vector2i(2,1), raider)
	fa._trigger_survival(state, raider, "urgent")
	assert(raider.current_task == TeamData.TASK_LOOT, "[p2b1] 殘忍 homeless 隊未掠奪 task=%s" % raider.current_task)
	# (c) 義氣 homeless + 強鄰 → 投靠
	var joiner := _mk_homeless_desperate_team(state, Vector2i(7,7), ["軍隊"], {"義氣":0.9,"信義":0.8,"求生欲":0.8})
	_mk_strong_neighbor_team(state, Vector2i(8,7), joiner)
	fa._trigger_survival(state, joiner, "urgent")
	assert(joiner.current_task == TeamData.TASK_JOIN, "[p2b1] 義氣 homeless 隊未投靠 task=%s" % joiner.current_task)
	print("[p2b1] non-unified survival delegation OK")
```
> helper 仿 P2a（manual WorldState 風格）：`_mk_homed_desperate_team(state,pos,tags,values)`（給 own outpost + food 低）、`_mk_homeless_desperate_team`（無 outpost + food 低）。複用 P2a 既有 `_mk_strong_neighbor_team`/`_mk_weak_prey_team`。

- [ ] **Step 3: 跑測確認 FAIL**

- [ ] **Step 4: 實作**

`_trigger_survival` 改寫（spec §3）：保留前段（leader 檢查/`previous_task`/TASK_BUILD 農田不中斷 2375-2381）；**刪** own-outpost 手寫 loot 分支（2391-2402，return_home 改由 rank_survival 的 `返家補給`）+ desperation×values branch（2410-2451）+ fallback forage/beg（2457-2468）；改為：
```gdscript
	for opt in DecisionEngine.rank_survival(state, team):
		var td: Dictionary = DecisionOptions.to_task(state, team, opt)
		var tgt: Vector2i = td["target"]
		if tgt == Vector2i(-1, -1) and td["task"] != TeamData.TASK_FLEE:
			continue
		if opt == "投靠" and td.has("combat_target"):
			var pp: PersonData = state.persons.get(state.player_id) if state.player_id != -1 else null
			if pp != null and int(td["combat_target"]) == pp.team_id:
				if _maybe_request_join_player(state, team): return
		if TaskArbiter.try_set(state, team, td["task"], tgt, TaskArbiter.PRIO_SURVIVAL, "survival"):
			if td.has("combat_target"): team.combat_target = int(td["combat_target"])
			return
	# 全不可派 → hunt fallback（無 TASK option）→ release
	if try_hunt_predator(state, team):
		print("[BeastHunt] team=Team%d 主動獵腳下掠食者" % team.team_id)
		return
	TaskArbiter.release(team)
	team.previous_task = ""
```
**刪** const `LOOT_GATE`/`JOIN_GATE`/`CAMP_GATE`（34-36）+ func `_loot_pref`/`_join_pref`/`_camp_pref`（2320-2333）（grep 證僅 test 用）。

`headless_test.gd` pref 序測（5202-5204）改斷言 weight 序（單一 owner）：
```gdscript
	assert(DecisionTerms.weight("loot", ferocious) > DecisionTerms.weight("loot", honorable), "兇者掠奪 weight 較高")
	assert(DecisionTerms.weight("join", honorable) > DecisionTerms.weight("join", ferocious), "義氣者投靠 weight 較高")
	assert(DecisionTerms.weight("camp", ambitious) > DecisionTerms.weight("camp", ferocious), "野心者紮營 weight 較高")
```
> `ferocious`/`honorable`/`ambitious` 在該測為 PersonData → 改傳 `.values`（weight 收 Dict）。

- [ ] **Step 5: 跑測 PASS + 既有全綠（重點：~20 直呼點）**

跑全套，逐一檢視因委派 fail 的 assert（多在 `_trigger_survival`/`_evaluate_survival` 直呼測）。確認新「人格→動作」與舊同義才調（記錄調了哪些 + 原因）。新舊分歧揭真退化 → 停呈報。

- [ ] **Step 6: Commit**
```
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "refactor(faction_ai): _trigger_survival 委派 rank_survival + 刪手寫 branch/GATE/pref helper (P2b-1)"
```

---

### Task 3: 熱路徑回歸量測 + framework + 守恆

**Files:** 量測 only（+ 必要時補測）

**Interfaces:** Consumes 全鏈。Produces 信心：1037 熱路徑保、無 mass starvation、homeless 分流 emergent、單一 owner。

- [ ] **Step 1: world_sim 2yr 量測**
```
$env:GODOT_TIMEOUT="900"; .\tools\godot.ps1 --headless --script scripts/debug/world_sim.gd
```
比 baseline（開工前記的 died 數）：
- **died 不暴增**（熱路徑 return_home 保 = 有家隊不因失返家而餓死）。
- `[Survival]` return_home 仍為主、homeless 分流（`[SurvivalLoot]`/`SurvivalJoin`/`SurvivalCamp`）emergent。
- 存活隊數穩、InvariantViolation=0。unseeded → 看機制非絕對閾。
- **輕飢不亂掠奪**：非絕境隊（food≥WARNING）不進 survival（entry gate）→ 確認 over-loot 沒爆。

- [ ] **Step 2: framework + 守恆閘**
```
.\tools\godot.ps1 --headless --script scripts/debug/framework_validation.gd
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd
```
S1-S6 PASS、`[CoinAudit] delta`≈0、headless 全綠。

- [ ] **Step 3: 單一 owner 證**
grep `_trigger_survival` 不再含 `LOOT_GATE`/`gate_min`/`sort_custom`；`_loot_pref`/`_join_pref`/`_camp_pref`/`*_GATE` 全刪（無 production reader）。

- [ ] **Step 4: Commit**（若有補測/調整）
```
git add scripts/debug/headless_test.gd
git commit -m "test(p2b-1): 熱路徑回歸 + world_sim 量測 (P2b-1)"
```

---

## 完成後（子 session）

1. push `git push -u origin feat/p2b1-survival-selection-unify`
2. handback `docs/superpowers/handbacks/2026-06-25-p2b1-survival-selection-unify.md`：改檔 + 與 spec/plan 差異 + world_sim 量測（died vs baseline、return_home 是否仍主、homeless 分流 emergent、輕飢 over-loot 否）+ **哪些 ~20 直呼點 assertion 調了 + 原因**（同義 vs 退化）+ 連動風險（返家補給 generalize 對 unified produce、距離 nuance 丟失、severity gate 簡化）+ 待確認（P2b-2 全退 entry 起點、`_evaluate_solo` survival scoring 仍雙 owner）。
3. finishing-a-development-branch → Option 3，主 session merge。

## Self-Review（主 session）

- spec 範圍（委派非全退、不碰 unified/solo、hunt 留 fallback、不新平衡值）→ 全 Task 對齊。
- **熱路徑（1037 return_home）** = 最大回歸風險 → `返家補給` generalize（Task 1）+ 熱路徑測（Task 2 (a)）+ world_sim died 閘（Task 3）三重驗。
- **單一 owner** = 刪 pref helper + GATE + 手寫 branch（Task 2）+ grep 證（Task 3 Step 3）。
- **~20 直呼點** = Task 2 Step 5 逐一檢視，同義才調，退化呈報。
- 距離 nuance（far-ferocious-loot）丟失 = 已知可接受行為變（loot 稀有），handback 記、backlog「restock_need 距離衰減」。
- 風險：`覓食` 加 pop 守衛影響 unified → Task 1 Step 5 跑既有 unified/TC 測確認不破。
