# resources banker Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans. Steps use checkbox (`- [ ]`).

**Goal:** resources 設單一 owner（ResourceBank add/remove/set_amt/clear_all，簡 wrapper 保原數學），148 寫/23 檔路由，coin_eq 必綠（清 Pattern B 第五池=最後一池）。

**Architecture:** 簡 wrapper banker，每 site 數學不變（守恆 by construction）。按檔分組增量 commit（partial 可存）。

**Tech Stack:** Godot 4.2.2 GDScript。測試 `headless_test.gd` + `world_sim.gd`。

## Global Constraints
- wrapper 跑 Godot（UTF-8）；每次 Godot run 前 `Set-Location` 進 worktree。
- **coin 守恆硬閘**：coin_eq/CoinAudit/InvariantAudit 必綠不變（148 site 任一算錯即紅）。
- **逐 site 保原數學**：`+=`→add；`-=`→（原 clamp→remove；原無 clamp 可負→add(-amt)）；`=`→set_amt；dict clear→clear_all。
- 每組後跑 headless 驗綠再下一組（增量安全）。

---

### Task 1: ResourceBank foundation + 單測

**Files:** Create `scripts/simulation/resource_bank.gd`；Test `headless_test.gd`。

- [ ] **Step 1: 寫失敗測試**
```gdscript
func _test_resource_bank() -> void:
	print("--- ResourceBank ---")
	var t := TeamData.new(); t.resources = {}
	ResourceBank.add(t, "food", 50.0, "test")
	assert(float(t.resources.get("food",0)) == 50.0, "add →50")
	var got: float = ResourceBank.remove(t, "food", 20.0, "test")
	assert(got == 20.0 and float(t.resources["food"]) == 30.0, "remove 20 →30")
	got = ResourceBank.remove(t, "food", 999.0, "test")
	assert(got == 30.0 and float(t.resources["food"]) == 0.0, "remove 不透支 →clamp")
	ResourceBank.set_amt(t, "coin", 100.0, "test")
	assert(float(t.resources["coin"]) == 100.0, "set_amt →100")
	ResourceBank.clear_all(t, "test")
	assert(t.resources.is_empty(), "clear_all →空")
	print("resource bank OK")
```
註冊。

- [ ] **Step 2: 跑確認失敗** — `ResourceBank` 不存在。

- [ ] **Step 3: 建 ResourceBank**
```gdscript
class_name ResourceBank

# Pattern B 所有權 banker：team.resources 單一 owner(簡 wrapper 保原數學=守恆 by construction)。
static func add(team: TeamData, res: String, amt: float, reason: String = "") -> void:
	team.resources[res] = float(team.resources.get(res, 0.0)) + amt

static func remove(team: TeamData, res: String, amt: float, reason: String = "") -> float:
	var have: float = float(team.resources.get(res, 0.0))
	var m: float = clampf(amt, 0.0, have)
	team.resources[res] = have - m
	return m

static func set_amt(team: TeamData, res: String, amt: float, reason: String = "") -> void:
	team.resources[res] = amt

static func clear_all(team: TeamData, reason: String = "") -> void:
	team.resources.clear()
```

- [ ] **Step 4: 跑確認通過** — `resource bank OK`。

- [ ] **Step 5: Commit** — `git commit -m "feat(state): ResourceBank foundation(Pattern B 第五池)"`

---

### Task 2-5: 按檔組路由（每組 grep 定位、保原數學、組後跑 coin_eq、commit）

> 通則：grep `resources\[[^]]*\]\s*(=|\+=|-=)`（排除 `==`/`!=`/headless_test fixture）+ `resources\s*=\s*{`/`.clear()` 定位每 site。逐 site 對齊原運算（見 Global Constraints）。**注意 RMW 中的讀**（`r[k] = r.get(k,0) + x` → add(t,k,x)；`r[k] = maxf(r.get(k,0)-x,0)` → remove(t,k,x)；複雜運算如 `r[k] = some_expr` → set_amt(t,k,some_expr)）。每組改完跑 headless 驗綠再下一組。

- [ ] **Task 2: 生產/消費組**（harvest_system/manufacturing_system/hunt_system/beast_system/health_system/population_system/salary_system/reaction_system/resource_system/anon_tier_system，~30 site）→ 路由 → 跑 headless（coin_eq/飢荒/manufacture/harvest 測綠）→ commit `feat(state): resources路由 生產消費組`。

- [ ] **Task 3: 交易/轉移組**（interaction_system/player_trade_system/encounter_system/subteam_system，~50 site，**守恆密集:trade 買賣/掠奪/分隊**）→ 路由（配對 add+remove 各端路由,sum 守恆）→ 跑 headless（**coin_eq/trade/屠村/subteam 守恆測綠**）→ commit `feat(state): resources路由 交易轉移組`。

- [ ] **Task 4: 初始/世界組**（world_generator/game_setup/outpost_system，~23 site，多 init set_amt）→ 路由 → 跑 headless → commit `feat(state): resources路由 初始世界組`。

- [ ] **Task 5: 玩家/派系/雜組**（player_command_system/player_system/faction_ai_system/equipment_system/npc_combat_system/ambush_system，~40 site）→ 路由 → 跑 headless → commit `feat(state): resources路由 玩家派系組`。

每 Task：改完跑 `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`，Expected `=== DONE ===` + **coin_eq/CoinAudit/InvariantAudit 全綠**。**任一守恆測紅 → 該組某 site 算錯（add/remove/set 對錯 or clamp 差異）→ 修對，勿放寬守恆斷言。**

---

### Task 6: 2 年 world_sim + grep 收尾 + 全回歸

- [ ] **Step 1: grep 驗無裸寫** — scripts/simulation/** 無殘留裸 `resources[k] =/+=/-=` 或 `resources = {}`/`.clear()`（除 resource_bank.gd）。漏網 → 路由 + 跑。
- [ ] **Step 2: 2 年 world_sim** — `.\tools\godot.ps1 --headless --script scripts/debug/world_sim.gd`：**CoinAudit delta=0**、resource 流動正常、`=== DONE ===`、InvariantAudit 0。
- [ ] **Step 3: 全回歸閘** — headless 全綠、**coin_eq/CoinAudit/InvariantAudit 0**。
- [ ] **Step 4: handback** — ResourceBank API、各組路由 site 數、clamp 變異處理、coin 守恆證(coin_eq+2yr CoinAudit)、grep 驗、回歸。標 **Pattern B 5/5 池完成**。

---

## 完成後
子 session handback：ResourceBank、4 組路由（site 數/檔）、coin 守恆證、2 年 world_sim、回歸、**Pattern B 完成（5 池全 banker）**。

## Self-Review
- Spec coverage：ResourceBank=Task1；148 路由按組=Task2-5；coin 守恆驗=每組+Task6；grep=Task6。全覆蓋。
- Placeholder：無（grep 定位 + 逐 site 對齊原數學=方法非 placeholder）。
- Type consistency：add/remove/set_amt/clear_all 簽名一致；remove 回 float+clamp 不透支；逐 site 保原數學。
