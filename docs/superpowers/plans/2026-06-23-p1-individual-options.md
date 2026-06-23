# P1 個體域 options（掠奪）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:subagent-driven-development or executing-plans. Steps use checkbox (`- [ ]`).

**Goal:** 給 unified 隊（merchant/produce）加人格加權 `掠奪` engine option → 殘忍/好戰/貪婪 leader 隊機會打劫弱者（湧現 raider 商隊），溫和隊仍貿易。解鎖 loot option（P2 前置）。

**Architecture:** 純加一個 engine option，複用既有 `_find_weakest_prey`（belief-read targeting）+ `_loot_pref` 公式 + TASK_LOOT + 既有 loot/extort interaction。non-unified 隊零改。**只碰 `scripts/simulation/decision/` 三檔 + 測試**（+ `_decide_unified` 設 combat_target 一處）。

**Tech Stack:** Godot 4.2.2 GDScript。測試 `scripts/debug/headless_test.gd`（`=== DONE ===` 無 `SCRIPT ERROR`）。

## Global Constraints

- **UTF-8 wrapper**：Godot 走 `.\tools\godot.ps1`（PowerShell）。
- **守恆**：loot 戰鬥/extort 走既有守恆路徑，本 plan **不碰守恆數學**。coin_eq delta=0 + InvariantAudit 0。
- **scope guard（P0 教訓）**：**只做 `掠奪`**（不做 scout）。**不碰 non-unified 路徑**（舊 faction_ai loot/survival 原樣）。不新 TASK_*。不改 targeting/interaction 機制。**不加 exemption 鏈**（unified loot 走既有 combat/interaction）。
- **believability**：weight 嚴（殘忍/好戰/貪婪 才贏 trade）；危時 survival-class 仍碾壓（P0 survival_pressure 不破）；只打弱獵物（belief 守衛，無情報不評估）。
- 新常數 `# TEST VALUE`。
- baseline：開工前 `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd` 確認全綠。

---

### Task 1: `loot_drive` term + `loot` weight + ctx 弱獵物欄

**Files:**
- Modify: `scripts/simulation/decision/terms.gd`（eval + weight）
- Modify: `scripts/simulation/decision/decision_context.gd`（gather 加 weak_prey 欄）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Consumes: `FactionAISystem.new()._find_weakest_prey(state, team) -> int`（prey_id，-1=無）；`ctx.leader_values`（Dict）；`state.teams[prey_id].tile_pos`。
- Produces: `ctx.has_weak_prey: bool`、`ctx.weak_prey_pos: Vector2i`；term `loot_drive` eval、weight key `loot`。

- [ ] **Step 1: 讀 decision_context.gd gather() + terms.gd eval/weight 結構**

確認 ctx 欄位 gather 法 + term eval `(term, ctx, opt)` 簽名 + weight `(term, leader_values)` 簽名（P0 spec 已記：terms.gd:11-46 eval、48-59 weight）。

- [ ] **Step 2: 寫 failing test**

```gdscript
func _test_p1_loot_term() -> void:
	# 殘忍 leader unified 隊鄰有弱獵物 → loot util 可觀；溫和 leader → loot util ~0
	var dt := DecisionTerms.new() if false else null  # terms 為 static，直接呼叫
	var cruel := {"殘忍": 0.9, "好戰": 0.8, "貪婪": 0.5}
	var meek := {"殘忍": 0.1, "好戰": 0.1, "貪婪": 0.2}
	var w_cruel: float = DecisionTerms.weight("loot", cruel)
	var w_meek: float = DecisionTerms.weight("loot", meek)
	assert(w_cruel > 0.6, "[p1] 殘忍 loot weight 太低 %.2f" % w_cruel)   # 0.9*0.5+0.8*0.3+0.5*0.2=0.79
	assert(w_meek < 0.2, "[p1] 溫和 loot weight 太高 %.2f" % w_meek)      # 0.1*0.5+0.1*0.3+0.2*0.2=0.12
	print("[p1] loot term/weight OK cruel=%.2f meek=%.2f" % [w_cruel, w_meek])
```

> `DecisionTerms` 實際 class/呼叫名依現有調整（P0 spec 記 `terms.gd::weight`）。

- [ ] **Step 3: 跑測確認 FAIL**（weight "loot" 未定義 → 回 0 或報錯）

- [ ] **Step 4: 實作**

`terms.gd` weight() 加：
```gdscript
		"loot": return leader_values.get("殘忍", 0.5) * 0.5 \
			+ leader_values.get("好戰", 0.5) * 0.3 + leader_values.get("貪婪", 0.5) * 0.2
```
（對齊 `_loot_pref` 公式。）

`terms.gd` eval() 加：
```gdscript
		"loot_drive":
			if opt != "掠奪": return 0.0
			return LOOT_DRIVE_BASE if ctx.has_weak_prey else 0.0   # TEST VALUE
```
加常數：`const LOOT_DRIVE_BASE: float = 1.0   # TEST VALUE — loot 驅力基值；× weight(loot 0..1) → loot util ≈ 0..1，危時不碾壓 survival(≥2)`

`decision_context.gd` gather() 加：
```gdscript
	var _prey: int = FactionAISystem.new()._find_weakest_prey(state, team)
	ctx.has_weak_prey = _prey != -1
	ctx.weak_prey_pos = state.teams[_prey].tile_pos if ctx.has_weak_prey else Vector2i(-1, -1)
```
+ 宣告 ctx 欄位 `var has_weak_prey: bool = false` / `var weak_prey_pos: Vector2i = Vector2i(-1,-1)`。

- [ ] **Step 5: 跑測 PASS + 既有全綠**

- [ ] **Step 6: Commit**
```
git add scripts/simulation/decision/terms.gd scripts/simulation/decision/decision_context.gd scripts/debug/headless_test.gd
git commit -m "feat(decision): loot_drive term + loot weight + ctx 弱獵物 (P1 掠奪)"
```

---

### Task 2: `掠奪` option（REGISTRY/applicable/to_task）+ combat_target 接線

**Files:**
- Modify: `scripts/simulation/decision/options.gd`（REGISTRY + applicable + to_task）
- Modify: `scripts/simulation/faction_ai_system.gd`（`_decide_unified` 為 loot 設 combat_target）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Consumes: ctx.has_weak_prey；`FactionAISystem.new()._find_weakest_prey(state, team)`；`TeamData.TASK_LOOT`。
- Produces: option `掠奪` 可被 rank 選中 → TASK_LOOT + target=獵物位 + `team.combat_target=prey_id`（交戰前提）。

- [ ] **Step 1: 讀 options.gd REGISTRY/applicable/to_task + `_decide_unified`（faction_ai ~845）task 套用法**

確認 `_decide_unified` 如何把 to_task 結果套到隊（`TaskArbiter.try_set(task, target)`）+ 是否設 combat_target。**關鍵**：TASK_LOOT 需 `team.combat_target=prey_id` 才會交戰（非只移動到格）——既有舊 loot 路徑 `team.combat_target = prey_id`（faction_ai ~2266）。

- [ ] **Step 2: 寫 failing test**

```gdscript
func _test_p1_loot_option() -> void:
	var state := WorldState.new()
	var cfg := {"map": {"radius": 4, "resource_richness": 5}, "teams": []}
	GameSetup.setup(state, cfg)
	# 殘忍 leader unified(merchant) 隊 + 鄰一弱獵物隊
	var raider := _mk_unified_cruel_team(state, Vector2i(2, 2))   # helper: TAG_MERCHANT, leader 殘忍0.9/好戰0.8
	var prey := _mk_weak_prey_team(state, Vector2i(3, 2))         # helper: 弱(低 pop)、有 belief、可達、獨立
	var fa := FactionAISystem.new()
	fa._decide_unified(state, raider)
	assert(raider.current_task == TeamData.TASK_LOOT, "[p1] 殘忍 unified 隊未選掠奪, task=%s" % raider.current_task)
	assert(raider.combat_target == prey.team_id, "[p1] 掠奪未設 combat_target")
	# 溫和 unified 隊同情境 → 不掠奪（選貿易/其他）
	var meek := _mk_unified_meek_team(state, Vector2i(2, 2))
	fa._decide_unified(state, meek)
	assert(meek.current_task != TeamData.TASK_LOOT, "[p1] 溫和 unified 隊竟掠奪")
	print("[p1] loot option OK")
```

> helper 仿既有 headless_test 造隊 helper。prey 須讓 `_find_weakest_prey` 找得到（在 raider 的 team_discovered + 有 belief + pop_est < raider.pop×0.7 + 可達）。

- [ ] **Step 3: 跑測確認 FAIL**

- [ ] **Step 4: 實作**

`options.gd` REGISTRY 加：
```gdscript
	"掠奪": [["loot_drive", "loot"]],
```
applicable() 加：
```gdscript
		"掠奪": return ctx.has_weak_prey
```
to_task() 加：
```gdscript
		"掠奪":
			var pid: int = FactionAISystem.new()._find_weakest_prey(state, team)
			if pid == -1: return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1, -1)}
			return {"task": TeamData.TASK_LOOT, "target": state.teams[pid].tile_pos, "combat_target": pid}
```

`_decide_unified`（faction_ai_system.gd）套用 to_task 結果處，加 combat_target 接線：
```gdscript
	# 掠奪 option：設 combat_target 才會交戰（非只移動）
	if td.has("combat_target"):
		team.combat_target = int(td["combat_target"])
```
（放在 `TaskArbiter.try_set(...)` 後。若 to_task 無 combat_target key 則不設。確認既有非-loot option 不帶此 key → 零影響。）

- [ ] **Step 5: 跑測 PASS + 既有全綠**

確認 TC1/4/6/7 + 既有 decision 測原樣（掠奪只在 has_weak_prey + 人格夠才起）。

- [ ] **Step 6: Commit**
```
git add scripts/simulation/decision/options.gd scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(decision): 掠奪 option + combat_target 接線 (P1)"
```

---

### Task 3: believability 驗證 + world_sim 量測

**Files:**
- Test: `scripts/debug/headless_test.gd`（believability 反例）
- 量測: world_sim 2yr

**Interfaces:** Consumes 全鏈。Produces 信心：unified 隊掠奪人格分歧 + 危時不亂掠奪 + non-unified 不變 + emergent 量。

- [ ] **Step 1: 寫 believability 測**

```gdscript
func _test_p1_loot_believability() -> void:
	var state := WorldState.new()
	var cfg := {"map": {"radius": 4, "resource_richness": 5}, "teams": []}
	GameSetup.setup(state, cfg)
	var fa := FactionAISystem.new()
	# (a) 危時：殘忍 unified 隊缺糧 + 鄰弱獵物 → survival-class 贏（非掠奪做日常；除非 loot=求生 P2 範疇）
	var hungry := _mk_unified_cruel_team(state, Vector2i(2, 2))
	hungry.resources["food"] = 5.0   # food_days < 2.5 → survival_pressure ≥2 碾壓 loot(~0.8)
	_mk_weak_prey_team(state, Vector2i(3, 2))
	fa._decide_unified(state, hungry)
	assert(hungry.current_task != TeamData.TASK_LOOT, "[p1] 餓隊竟做日常掠奪非求生, task=%s" % hungry.current_task)
	# (b) non-unified 殘忍隊（軍隊 tag）→ 走舊路徑不受本 option 影響（current_task 由舊邏輯決，非引擎）
	# （驗 uses_unified=false 隊不進 _decide_unified）
	print("[p1] loot believability OK")
```

- [ ] **Step 2: 跑測 PASS**

- [ ] **Step 3: world_sim 2yr 量測**
```
$env:GODOT_TIMEOUT="900"; .\tools\godot.ps1 --headless --script scripts/debug/world_sim.gd
```
觀察：2yr 不全滅、emergent 掠奪可見（殘忍 leader unified 隊有 TASK_LOOT / `[SurvivalLoot]` 或 loot 戰鬥）、**多數 unified 隊仍貿易/生產**（無 over-loot，經濟世界不崩）、InvariantViolation=0。記數據。unseeded → 看機制 fire（有掠奪發生）非絕對閾。

- [ ] **Step 4: 守恆閘**
```
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd
```
`[CoinAudit] delta` ≈ 0 + headless 全綠。

- [ ] **Step 5: Commit**
```
git add scripts/debug/headless_test.gd
git commit -m "test(p1): 掠奪 believability + world_sim 量測 (P1)"
```

---

## 完成後（子 session）

1. push `git push -u origin feat/p1-individual-options`
2. handback `docs/superpowers/handbacks/2026-06-23-p1-individual-options.md`：改檔 + 與 spec 差異 + world_sim 量測（掠奪 fire 率 / 是否 over-loot / 經濟是否仍健康）+ 連動風險（loot 對經濟世界、combat_target 接線對其他 option）+ 待確認（loot weight 係數是否需調 / scout 是否補做）。
3. finishing-a-development-branch → Option 3，主 session merge。

## Self-Review（主 session）

- spec 範圍（只掠奪、不 scout、non-unified 零改）→ 全 Task 對齊。
- combat_target 接線（Task 2）= 唯一碰 decision/ 外的改（faction_ai `_decide_unified` 一處）→ 確認既有 option 不帶 combat_target key → 零影響。
- 危時 survival 碾壓 loot（believability）→ Task 3 (a) 驗。
- helper 名跨 Task 一致（`_mk_unified_cruel_team`/`_mk_unified_meek_team`/`_mk_weak_prey_team`）。
- 風險：loot 量級（LOOT_DRIVE_BASE 1.0 × weight ≤~0.8 → loot util ≤~0.8，不碾壓 survival≥2、可與 trade 0.5-1.35 競）→ world_sim 量 over-loot 調 BASE。
