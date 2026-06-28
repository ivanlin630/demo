# 統一統領決策 v2（means-end）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:subagent-driven-development or executing-plans. Steps use checkbox (`- [ ]`).

**Goal:** refactor `_update_goals` 從多閾值並行 append → **means-end 意圖驅動**（意圖 predicate→子需求現算→真 affordance 匹配，深度1，每令帶 driver，意圖 hysteresis，viability）。殺統領層多閾值病=統一 arc 真根最後一處。**只真 affordance**（欺敵=anchored-pre-player 後續 arc）。

**Architecture:** 小意圖集 `{征服X,致富,防衛,守成}` + 小行動集 `{攻擊,結盟,徵收,貿易,建設}`（schema 帶前提+真 affordance）。統領 utility 選主意圖(人格×belief×viability×hysteresis)→分解主行動未滿足前提(深度1)→匹配真 affordance filler 補肢→f.goals(每令 driver)。成員側 P3/P4 不動。

**Tech Stack:** Godot 4.2.2 GDScript。測試 `scripts/debug/headless_test.gd`（`=== DONE ===` 無 `SCRIPT ERROR`）。

## Global Constraints
- **UTF-8 wrapper**：`.\tools\godot.ps1`（PowerShell）。worktree：每 Godot/git 前 `Set-Location` 進 worktree。
- **守恆**：行動走既有 interaction 守恆，不碰守恆數學。coin_eq 0 + InvariantAudit 0。
- **scope guard（藍圖最強調，前兩輪白做教訓）**：**死守小集 + 深度1 + 只真 affordance**（意圖 4/行動 5/affordance 每行動 1-2 條）。**不掛孤兒**（欺敵/貿易戰/城防…）。不碰成員 P3/P4 option、不碰 strategic_ai、不做並行多意圖、不做階層 planner、不新 TASK_*。緊急徵收=survival override 保留。立國=既有分離 gate。
- **驗收=可解釋+viability，非跟戰數**（藍圖明令）：每令 driver→意圖通 + 征服真有實打力(輔助肢從餘裕抽)。
- 新常數 `# TEST VALUE`。baseline：開工前 headless 全綠 + `commander_directive_measure`（記同發 4/2 無因令）。

---

### Task 1: 意圖/行動 schema + faction_data driver 欄 + 意圖選擇（resource-aware + hysteresis）

**Files:**
- Modify: `scripts/data/faction_data.gd`（`intent`/`goal_drivers` 欄）
- Modify: `scripts/simulation/faction_ai_system.gd`（INTENTS/ACTIONS const + `_select_intent`）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Consumes: leader values、`f.is_established`、readiness、`BeliefSystem.best_estimate`（敵力）、`_nearest_independent`/`_richest_member`/既有 attack readiness/strength gate（viability）。
- Produces: `INTENTS`/`ACTIONS` const dict；`f.intent={type,target_id,why}`；`_select_intent(state,f)->Dictionary`（人格×belief×viability×hysteresis argmax）。

- [ ] **Step 1: 讀 `_update_goals`(632-712) + spec 的 INTENTS/ACTIONS schema + 既有 attack_score/readiness/strength gate（viability 複用）+ `commander_directive_measure` 構造。**

- [ ] **Step 2: 寫 failing test**
```gdscript
func _test_cmd_intent_select() -> void:
	# 好戰霸主+可打弱敵 → 征服；商業貪婪 → 致富；溫和慎重 → 守成/防衛
	var i_war: Dictionary = _select_intent_for({"野心":0.9,"好戰":0.9,"義氣":0.1}, true, true)  # helper: values, established, weak_enemy_belief
	assert(i_war.get("type") == "征服", "[cmd] 好戰霸主未選征服 %s" % str(i_war))
	var i_rich: Dictionary = _select_intent_for({"貪婪":0.9,"好戰":0.2,"野心":0.5}, true, false)
	assert(i_rich.get("type") == "致富", "[cmd] 貪婪未選致富 %s" % str(i_rich))
	# viability：好戰但敵 belief 顯強(湊不出力) → 不選征服(退守成/致富)
	var i_weak: Dictionary = _select_intent_for({"野心":0.9,"好戰":0.9}, true, false)  # strong_enemy
	assert(i_weak.get("type") != "征服", "[cmd] 打不贏仍選征服(viability 失效)")
	print("[cmd] intent select OK")
```

- [ ] **Step 3: 跑測確認 FAIL**

- [ ] **Step 4: 實作**
`faction_data.gd`：`var intent: Dictionary = {}` + `var goal_drivers: Dictionary = {}`。
`faction_ai_system.gd`：加 `const INTENTS`/`const ACTIONS`（spec schema）+ `_select_intent`：
- 各候選意圖 score = 人格適性（征服←野心.4+好戰.4-義氣.4 既有 attack_score / 致富←貪婪 / 防衛←慎重+威脅 / 守成←base）× viability（征服=既有 readiness+strength gate 過 + belief 敵力可打贏；湊不出→score 壓低）。
- 承諾 hysteresis：== f.intent.type 加 `COMMANDER_COMMITMENT_BONUS`（TEST VALUE）。
- argmax → 回 {type,target_id(征服=_nearest_independent),why}。
（先只 `_select_intent` 回意圖，不改 _update_goals 主體；Task 2 接線。）

- [ ] **Step 5: 跑測 PASS + 既有全綠**

- [ ] **Step 6: Commit**
```
git add scripts/data/faction_data.gd scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(faction_ai): INTENTS/ACTIONS schema + _select_intent(人格×belief×viability×hysteresis) (commander-v2)"
```

---

### Task 2: 子需求分解(深度1) + filler 匹配 + emit driver → `_update_goals` 接線 + war-priority revert

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`（`_decompose_needs`/`_match_fillers`/`_emit_goal` + `_update_goals` 重構接線）
- Modify: `scripts/simulation/decision/terms.gd`（revert `FACTION_DUTY_DRIVE_LESSER`）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Consumes: `_select_intent`(Task1)、INTENTS/ACTIONS、前提 check（force_ge_target/can_reach/has_richer_member/has_market 複用既有 gate）。
- Produces: `f.goals=[主行動+補肢]` 每令 `f.goal_drivers[goal]={intent,why,mode}`；`_update_goals` means-end 全接。

- [ ] **Step 1: 讀 Task1 schema + 消費端(leader dispatch 739-771/member 802-827/unified faction_stakes 讀 X in f.goals 不變)。**

- [ ] **Step 2: 寫 failing test**
```gdscript
func _test_cmd_means_end_emit() -> void:
	var state := WorldState.new(); var cfg := {"map":{"radius":5},"teams":[]}; GameSetup.setup(state, cfg)
	var fai := FactionAISystem.new()
	# 征服意圖 + 我軍力不足 → 主令攻擊 + 補力肢(結盟/徵收)，每令有 driver 連回征服
	var f = _setup_conquer_faction(state, force_deficit=true)   # helper
	fai._update_goals(state, f)
	assert("攻擊" in f.goals, "[cmd] 征服未發主令攻擊")
	assert(f.goal_drivers.get("攻擊", {}).get("intent") == "征服", "[cmd] 攻擊令無 driver 連回征服")
	# 軍力不足 → 有補力肢(結盟 or 徵收)，driver why=補力
	var has_boost := false
	for g in f.goals:
		if f.goal_drivers.get(g, {}).get("why", "").contains("補力"): has_boost = true
	assert(has_boost, "[cmd] 軍力不足未開補力肢")
	# 無無因令：每令都有 driver
	for g in f.goals:
		assert(f.goal_drivers.has(g), "[cmd] 無因令 %s(無 driver)" % g)
	print("[cmd] means-end emit OK goals=%s" % str(f.goals))
```

- [ ] **Step 3: 跑測確認 FAIL**

- [ ] **Step 4: 實作**
`_update_goals` 重構（spec 5 步）：player override/緊急徵收 override/立國 gate（保留）→ `_select_intent` → `_decompose_needs`（主行動未滿足前提，深度1）→ `_match_fillers`（util=affordance∩需求×人格適性×viable，從餘裕抽補肢）→ `_emit_goal`（f.goals.append + goal_drivers[goal]={intent,why,mode}）。viability：主手段湊不出→退更小意圖/守成。**刪 707-712 掠奪 append**（孤兒/team P1）。
`terms.gd`：revert `FACTION_DUTY_DRIVE_LESSER`→`FACTION_DUTY_DRIVE`（徵收/外交 drive 回 1.5），刪 LESSER const。

- [ ] **Step 5: 跑測 PASS + 既有全綠**

- [ ] **Step 6: Commit**
```
git add scripts/simulation/faction_ai_system.gd scripts/simulation/decision/terms.gd scripts/debug/headless_test.gd
git commit -m "feat(faction_ai): 子需求分解(深度1)+filler 匹配+driver emit + war-priority revert (commander-v2)"
```

---

### Task 3: viability/hysteresis 驗 + measure 擴 driver + P3/P4 回歸 + world_sim + invariants

**Files:**
- Test: `scripts/debug/headless_test.gd`
- Modify: `scripts/debug/commander_directive_measure.gd`（擴印 driver）、`docs/invariants.md`
- 量測: measure + p3_war_scenario + world_sim + framework + game_sim_multi

- [ ] **Step 1: 寫 viability + hysteresis 測**
```gdscript
func _test_cmd_viability_hysteresis() -> void:
	# viability：征服打不贏→退守成(不發打不贏攻擊令)
	# hysteresis：committed 征服連續 cadence 不翻(情勢不變)
	# 緊急徵收 override：food<emergency→["徵收"]driver=survival
	# （三段 assert，helper 構造）
	print("[cmd] viability/hysteresis OK")
```

- [ ] **Step 2: measure 擴 driver + 重跑**
`commander_directive_measure.gd` 擴：每令印 `intent+why+mode`，斷言**無無因令**（每 goal 有 goal_drivers）。重跑——各 persona：好戰→征服[攻擊+補肢]、貪婪→致富[徵收/貿易]、溫和→守成[]。**同發令有 driver、無矛盾**。

- [ ] **Step 3: P3/P4 回歸 + 既有**
```
.\tools\godot.ps1 --headless --script scripts/debug/p3_war_scenario.gd
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
P3/P4 headless 全綠（成員在統領單意圖子命令下響應攻擊/徵收/外交）。**war_scenario：不數跟戰，看「征服意圖→真實打 + 成員選擇可解釋」**（若 leader 構造為征服→主令攻擊，成員按人格分配=可解釋 viable）。

- [ ] **Step 4: world_sim + framework + 守恆**
```
$env:GODOT_TIMEOUT="900"; .\tools\godot.ps1 --headless --script scripts/debug/world_sim.gd
.\tools\godot.ps1 --headless --script scripts/debug/framework_validation.gd
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd
```
記：2yr 不崩、派系下協同令（有 driver、無矛盾無因令）、意圖穩定（無反覆）、征服稀有（多數致富/守成）、**無發打不贏的攻擊**、S1 立國/S2 feud fire、coin_eq 0、InvariantViolation 0。既有+P2/P3/P4 全綠。

- [ ] **Step 5: invariants + Commit**
`docs/invariants.md`「隊目標單一 owner」段補：統領 `_update_goals` = means-end（意圖 predicate→子需求現算→真 affordance 匹配，深度1，每令帶 driver，意圖 hysteresis，viability；非並行閾值/非收斂單一）；掠奪=team option 非統領令。
```
git add scripts/debug/headless_test.gd scripts/debug/commander_directive_measure.gd docs/invariants.md
git commit -m "test(commander-v2): viability/hysteresis + measure driver-complete + P3/P4 回歸 + invariants (commander-v2)"
```

---

## 完成後（子 session）
1. push `git push -u origin feat/commander-decision-unify-v2`
2. handback `...-commander-decision-unify-v2.md`：改檔 + 與 plan 差異 + **measure 重跑(無因令→每令有 driver+intent)** + viability(征服真實打、輔助從餘裕) + 意圖穩定度 + P3/P4 不回歸 + world_sim(征服稀有/無打不贏令) + 連動風險(掠奪移除/緊急徵收邊界/war-priority 移除) + 待確認(viability 量級/COMMANDER_COMMITMENT_BONUS/欺敵孤兒洞).
3. finishing-a-development-branch → Option 3，主 session merge。

## Self-Review（主 session）
- spec 範圍（小集/深度1/只真 affordance/不碰成員 option·strategic_ai·孤兒）→ 全 Task 對齊。
- **驗收=可解釋(driver→意圖)+viability(intent realized)**，非跟戰數（Task 2 driver 測 + Task 3 viability 測 + measure 無因令）。
- **means-end 真跑**（非查表）= 子需求現算 + filler 匹配（Task 2）。
- **意圖 hysteresis + resource-aware**（Task 1/3）。
- **war-priority 移除**（單意圖後 moot，Task 2）。
- 風險：boil ocean（死守小集深度1）；viability 量化（複用 attack gate）；欺敵孤兒洞（無真 filler→不開，標 anchored-pre-player）。
