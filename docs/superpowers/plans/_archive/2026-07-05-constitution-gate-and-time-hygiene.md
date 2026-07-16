# 序0：憲法防閘 + 時間 hygiene（3 機械修）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 為 tick-60 解析度切換與憲法溶入 arc 鋪路——把 10 個裸時間常數與 near/far 計算搬到骨架/gate（零行為變 hygiene），並立一道機械防閘鎖死當前引擎外 task 指派面（防 arc 期間新增違憲）。

**Architecture:** 四個獨立 Task，全部**零 sim 行為變**（現行根 `TICKS_PER_DAY=240` 下所有導出值等於原硬編值）。Task 1–3 = 時間 hygiene（純機械/校正），Task 4 = 新增 `constitution_gate.gd` 靜態掃描腳本 + 自動產生的 baseline manifest。全程回歸閘 = seeded warring 不變（46/8/1/380）+ framework PASS=7 DORMANT=0。

**Tech Stack:** Godot 4.2.2 GDScript；headless SceneTree 腳本；`tools/godot.ps1` wrapper（強制 UTF-8）。

## Global Constraints

- **零行為變鐵律**：Task 1–3 完成後 `headless_test.gd` 的 seeded 行必須仍是 `teams=46 factions=8 established=1 pop=380`（seed=1337 ticks=1200）；`framework_validation.gd` 必須仍 `PASS=7 DORMANT=0`。任一偏移 = 該 Task 引入了非預期行為變，退回重查，**不得放行**。
- **不動時間根**：本 plan **不改** `TICKS_PER_DAY`（仍 240）。60 根切換綁 A2，非本 slice。本 slice 只讓常數**導出就位**，值不變。
- **跑測試用 wrapper**：一律 `.\tools\godot.ps1 --headless ...`（直呼 exe 中文輸出 CP950 亂碼）。新增 `class_name` 檔後先 `.\tools\godot.ps1 --headless --import`。
- **PowerShell `>` 重導向 = UTF-16**：落檔後篩用 `Select-String`（grep 撞 null byte）。
- **單向依賴**：`TimeScale → {WorldState, EncounterSystem}`，反向禁（循環）。`faction_ai_system.gd` 引用 `TimeScale.days()/hours()` 合法（單向下游）。

---

## File Structure

- `scripts/simulation/sim_runner.gd`（Modify）— Task 1：hoist near/far 計算進各自 gate。
- `scripts/simulation/faction_ai_system.gd`（Modify）— Task 2：10 常數導出 `TimeScale`；Task 3：eta 除數導出。
- `scripts/debug/time_const_check.gd`（Create）— Task 2/3：導出值等於預期整數的斷言腳本。
- `scripts/debug/constitution_gate.gd`（Create）— Task 4：引擎外 task 指派面靜態掃描防閘。
- `scripts/debug/constitution_baseline.txt`（Create）— Task 4：凍結的 mutation call-site 指紋 manifest（自動產生 + 8 known 標序）。

---

### Task 1: 修1 — near/far 計算 hoist 進 gate

**Files:**
- Modify: `scripts/simulation/sim_runner.gd:152-153`（移除無條件計算）、`:156`（near gate 內插入）、`:237`（far gate 內插入）
- Test（回歸）: `scripts/debug/headless_test.gd`（seeded 行）、`scripts/debug/framework_validation.gd`

**Interfaces:**
- Consumes: `_get_near_teams(state, player_pos) -> Array`、`_get_far_teams(state, player_pos) -> Array`（既有 private，簽名不變）；`player_pos` 在 `_advance_tick_body` 全程在 scope。
- Produces: 無新對外介面。`near_teams`/`far_teams` 變成各自 gate 的區域變數（每 tick 無條件 O(N) 全掃 → 改為只在 gate 命中時算 = 消滅 near-cadence 內 ×N 純浪費、順帶減 O(N²) 幫兇；行為零變因結果原本就只在 gate 內消費）。

**背景（為何零行為變）**：`_get_near_teams`/`_get_far_teams` 結果目前於 152-153 每 tick 算，但**唯一消費點**分別在 `% NEAR_CADENCE`（186 起）與 `% FAR_ZONE_INTERVAL`（238 起）gate 內。gate 未命中的 tick 算了丟棄 = 純浪費。搬進 gate = 命中時才算，值與時機完全相同。已核 154–155 之間、`_step_captives`/`_step_cleanup_extinct_teams`（262–263）、跨 gate 均無引用（near gate 只用 near_teams、far gate 只用 far_teams），無 cross-use。

- [ ] **Step 1: 跑基準錨定回歸值**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "seeded warring"`
Expected: `seeded warring reproducible OK (seed=1337 ticks=1200 final={ "teams": 46, "factions": 8, "established": 1, "pop": 380 } probe_capture=0)`

- [ ] **Step 2: 移除 152-153 的無條件計算**

刪除 sim_runner.gd 現行：
```gdscript
	var near_teams := _get_near_teams(state, player_pos)
	var far_teams := _get_far_teams(state, player_pos)
```
（連同其上方空行留一行即可，勿動 149-150 的 `time_speed_mult`/`time_vision_mult`。）

- [ ] **Step 3: near gate 內插入 near_teams**

在 `if state.world.current_tick % NEAR_CADENCE == 0:` 之後、gate 內第一行（forced_event 區塊之前）插入：
```gdscript
		var near_teams := _get_near_teams(state, player_pos)
```

- [ ] **Step 4: far gate 內插入 far_teams**

在 `if state.world.current_tick % FAR_ZONE_INTERVAL == 0:` 之後、gate 內第一行（`_step1b_update_vision(state, far_teams, ...)` 之前）插入：
```gdscript
		var far_teams := _get_far_teams(state, player_pos)
```

- [ ] **Step 5: 跑回歸——seeded 必須不變**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "seeded warring|SCRIPT ERROR"`
Expected: 同 Step 1 的 `teams=46 factions=8 established=1 pop=380`，**零 `SCRIPT ERROR`**。若 team 數偏移 → hoist 引入行為變（多半 cross-use 漏核），退回。

- [ ] **Step 6: 跑 framework 驗魂未 dormant**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/framework_validation.gd 2>&1 | Select-String "PASS=|DORMANT="`
Expected: `--- PASS=7  DORMANT=0 ---`

- [ ] **Step 7: Commit**

```bash
git add scripts/simulation/sim_runner.gd
git commit -m "perf(sim): hoist near/far team scan into cadence gates (zero-behavior)"
```

---

### Task 2: 修2 — 10 裸 cadence/timeout 常數導出 TimeScale

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`（常數宣告：42, 93, 96, 97, 101, 102, 105, 108, 109, 112 行的 10 個 const）
- Create: `scripts/debug/time_const_check.gd`（導出值 == 預期整數斷言）
- Test（回歸）: `scripts/debug/headless_test.gd`、`scripts/debug/framework_validation.gd`

**Interfaces:**
- Consumes: `TimeScale.days(n: int) -> int`（`= n * TICK_PER_DAY`）、`TimeScale.hours(n: int) -> int`（`= n * TICK_PER_DAY / 24`）。現行 `TICK_PER_DAY = 240`。
- Produces: 10 個 const 值不變（見下表），僅來源改為語意導出。`FLEE_TIMEOUT` 順帶修硬編 `240` bug（原 `5 * 240` 不跟根）。

**導出對照表（現根 240 下全等值 → 零行為變）：**

| const | 原值 | 導出 | 驗算 |
|---|---|---|---|
| `INDEP_STRATEGY_CADENCE` | 720 | `TimeScale.days(3)` | 3×240=720 |
| `FLEE_TIMEOUT` | `5 * 240` | `TimeScale.days(5)` | 5×240=1200（修硬編 240） |
| `PROSPERITY_CADENCE` | 720 | `TimeScale.days(3)` | 720 |
| `PROSPERITY_CADENCE_MILITARY` | 360 | `TimeScale.hours(36)` | 36×240/24=360 |
| `THREAT_CADENCE` | 240 | `TimeScale.days(1)` | 240 |
| `TRADE_TIMEOUT` | 1440 | `TimeScale.days(6)` | 6×240=1440 |
| `TRADE_TIMEOUT_PER_HEX` | 120 | `TimeScale.hours(12)` | 12×240/24=120 |
| `RESIDENCY_CADENCE` | 720 | `TimeScale.days(3)` | 720 |
| `RESIDENCY_COOLDOWN` | 1680 | `TimeScale.days(7)` | 7×240=1680 |
| `OCCUPY_ETA_MAX` | 720 | `TimeScale.days(3)` | 720 |

**注意**：GDScript `const` 可用另一 const 的 `static func` 求值嗎？`TimeScale.days(3)` 是 static func 呼叫，**const 初始化不接受非常量表達式**。故這些必須改為 `static` 或普通類別變數，或改用 const 算式。→ 用 **const 直接算式**保持 const 語意：`const THREAT_CADENCE: int = TimeScale.TICK_PER_DAY * 1`。但 `TimeScale.TICK_PER_DAY` 本身是 const（`= WorldState.TICKS_PER_DAY`），跨類別 const 引用在 GDScript 合法。故：

- [ ] **Step 1: 寫斷言腳本 `time_const_check.gd`（先失敗）**

Create `scripts/debug/time_const_check.gd`：
```gdscript
extends SceneTree

# 驗：faction_ai 的時間常數導出後值等於原硬編值（現根 240）。零行為變閘。
func _initialize() -> void:
	var fails: int = 0
	var checks := [
		["INDEP_STRATEGY_CADENCE", FactionAISystem.INDEP_STRATEGY_CADENCE, 720],
		["FLEE_TIMEOUT", FactionAISystem.FLEE_TIMEOUT, 1200],
		["PROSPERITY_CADENCE", FactionAISystem.PROSPERITY_CADENCE, 720],
		["PROSPERITY_CADENCE_MILITARY", FactionAISystem.PROSPERITY_CADENCE_MILITARY, 360],
		["THREAT_CADENCE", FactionAISystem.THREAT_CADENCE, 240],
		["TRADE_TIMEOUT", FactionAISystem.TRADE_TIMEOUT, 1440],
		["TRADE_TIMEOUT_PER_HEX", FactionAISystem.TRADE_TIMEOUT_PER_HEX, 120],
		["RESIDENCY_CADENCE", FactionAISystem.RESIDENCY_CADENCE, 720],
		["RESIDENCY_COOLDOWN", FactionAISystem.RESIDENCY_COOLDOWN, 1680],
		["OCCUPY_ETA_MAX", FactionAISystem.OCCUPY_ETA_MAX, 720],
	]
	for c in checks:
		var name_s: String = c[0]; var got: int = c[1]; var want: int = c[2]
		if got != want:
			print("[FAIL] %s = %d, want %d" % [name_s, got, want]); fails += 1
		else:
			print("[OK] %s = %d" % [name_s, got])
	print("=== time_const_check: %s (fails=%d) ===" % ["PASS" if fails == 0 else "FAIL", fails])
	quit()
```

- [ ] **Step 2: 跑斷言腳本確認現值通過（baseline，改前）**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/time_const_check.gd 2>&1 | Select-String "PASS|FAIL"`
Expected: `=== time_const_check: PASS (fails=0) ===`（改前原硬編值本就等於期望值，這步錨定期望；改後必須仍 PASS）

- [ ] **Step 3: 改 10 個 const 為導出算式**

於 `faction_ai_system.gd` 逐一替換（保留原行內註解語意）：
```gdscript
const INDEP_STRATEGY_CADENCE: int = TimeScale.TICK_PER_DAY * 3        # 3 天評估一次
const FLEE_TIMEOUT: int = TimeScale.TICK_PER_DAY * 5                  # 逃跑逾時 5 天（修硬編 240，跟根）
const PROSPERITY_CADENCE: int = TimeScale.TICK_PER_DAY * 3           # 3 天 評估一次
const PROSPERITY_CADENCE_MILITARY: int = TimeScale.TICK_PER_DAY * 36 / 24  # 軍隊 1.5 天 = 36h
const THREAT_CADENCE: int = TimeScale.TICK_PER_DAY * 1               # 1 日 評估威脅
const TRADE_TIMEOUT: int = TimeScale.TICK_PER_DAY * 6                # 貿易 base timeout 6 日
const TRADE_TIMEOUT_PER_HEX: int = TimeScale.TICK_PER_DAY * 12 / 24  # 12h/hex
const RESIDENCY_CADENCE: int = TimeScale.TICK_PER_DAY * 3            # 3 天 評估居民派駐
const RESIDENCY_COOLDOWN: int = TimeScale.TICK_PER_DAY * 7           # 7 天 邀請被拒冷卻
const OCCUPY_ETA_MAX: int = TimeScale.TICK_PER_DAY * 3               # 佔村目標最遠 eta ≈3 日
```
（用 `TimeScale.TICK_PER_DAY * N`（跨類別 const 引用，合法）而非 `TimeScale.days(N)`（static func 呼叫，const 初始化不接受）。`* 36 / 24`、`* 12 / 24` 整數除盡：240×36=8640/24=360✓、240×12=2880/24=120✓。）

- [ ] **Step 4: 跑斷言腳本——改後必須仍 PASS**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/time_const_check.gd 2>&1 | Select-String "PASS|FAIL"`
Expected: `=== time_const_check: PASS (fails=0) ===`。任一 FAIL = 導出算錯，退回對照表。

- [ ] **Step 5: 跑 seeded + framework 回歸**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "seeded warring|SCRIPT ERROR"`
Expected: `teams=46 factions=8 established=1 pop=380`，零 `SCRIPT ERROR`。
Run: `.\tools\godot.ps1 --headless --script scripts/debug/framework_validation.gd 2>&1 | Select-String "PASS=|DORMANT="`
Expected: `--- PASS=7  DORMANT=0 ---`

- [ ] **Step 6: Commit**

```bash
git add scripts/simulation/faction_ai_system.gd scripts/debug/time_const_check.gd
git commit -m "refactor(faction_ai): derive 10 time constants from TimeScale root (zero-behavior, +FLEE hardcode fix)"
```

---

### Task 3: 修3 — eta 除數導出 TICKS_PER_DAY

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd:190`
- Test（回歸）: `scripts/debug/headless_test.gd`、`scripts/debug/framework_validation.gd`

**Interfaces:**
- Consumes: `WorldState.TICKS_PER_DAY`（現 240）。
- Produces: `eta_days` 計算不變值（現根 `/240.0` == `/float(240)`），改根後自動跟隨（取整漂移修）。

- [ ] **Step 1: 改硬編除數**

於 `faction_ai_system.gd:190` 現行：
```gdscript
		var eta_days: float = maxf(float(catch_result.eta) / 240.0, 1.0)
```
改為：
```gdscript
		var eta_days: float = maxf(float(catch_result.eta) / float(WorldState.TICKS_PER_DAY), 1.0)
```

- [ ] **Step 2: 跑 seeded + framework 回歸**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "seeded warring|SCRIPT ERROR"`
Expected: `teams=46 factions=8 established=1 pop=380`，零 `SCRIPT ERROR`。
Run: `.\tools\godot.ps1 --headless --script scripts/debug/framework_validation.gd 2>&1 | Select-String "PASS=|DORMANT="`
Expected: `--- PASS=7  DORMANT=0 ---`

- [ ] **Step 3: Commit**

```bash
git add scripts/simulation/faction_ai_system.gd
git commit -m "fix(faction_ai): derive eta_days divisor from TICKS_PER_DAY (kills hardcoded 240 drift)"
```

---

### Task 4: 防新增憲法閘 — 引擎外 task 指派面 site-freeze gate

**Files:**
- Create: `scripts/debug/constitution_gate.gd`（掃描 + 比對 baseline）
- Create: `scripts/debug/constitution_baseline.txt`（凍結指紋 manifest）

**Interfaces:**
- Consumes: `scripts/simulation/` 下所有 `.gd`（含子目錄 `events/`）。
- Produces: `[CONSTITUTION-GATE] PASS`（current ⊆ baseline）或 `FAIL`（current 有 baseline 外新增指紋，逐條印）。

**機制（★系統裁定，記錄於 plan 供實作）**：
- **鎖的面** = `TaskArbiter.transition(` 與 `TaskArbiter.try_set(` 的呼叫點（`TaskArbiter` 是設定具體 task 的唯一 API = 「action selection」實際落點）。`TaskArbiter.release(` 不鎖（= 清空/idle，非選具體行為）。
- **指紋** = `<relpath>::<enclosing_func>`（用 func 名非行號 → 檔內重排不 churn）。
- **契約** = current 指紋集 ⊆ baseline。**新增指紋 → FAIL**（arc 期間新引擎外 task 指派 = 違憲，訊息叫作者溶入引擎或呈報系統更新 baseline）。**移除 → PASS**（arc 溶解違憲子系統 → 面自動縮，印為進度）。
- **coverage 誠實聲明**：本閘鎖 TaskArbiter mutation 面，**不**覆蓋「return task 字串供他處消費」式違憲（如 `ambition_ladder.rung_task`）——那類靠 arc 逐張溶解 + review，非本機械閘。閘目標 = 「無新增引擎外 task 指派」，非完備語意偵測。此限制入 `invariants.md`（系統於 merge 後補）。
- **8 known 違憲**於 baseline 內以 `#` 註解標 arc 溶入序（threat 序1 / solo 序2 / vendetta 序4 / prosperity 序5 / dispatch 序6 …），供 arc 進度追蹤；非 8 者為既有合憲面（player 命令 / 引擎 to_task glue / BEG release 等），一併凍結。

- [ ] **Step 1: 寫掃描腳本 `constitution_gate.gd`**

Create `scripts/debug/constitution_gate.gd`：
```gdscript
extends SceneTree

# ★★★ 沙盒憲法防閘（site-freeze）：鎖 TaskArbiter mutation 面 = 引擎外 task 指派。
# 契約：current 指紋 ⊆ baseline。新增 = FAIL（叫作者溶入引擎或呈報系統）。移除 = PASS（arc 溶解）。
# 指紋 = <relpath>::<enclosing_func>。coverage = TaskArbiter.transition/try_set 呼叫點（見 plan 誠實聲明）。

const SCAN_DIR := "res://scripts/simulation"
const BASELINE := "res://scripts/debug/constitution_baseline.txt"
const MUT_RE := "TaskArbiter\\.(transition|try_set)\\("

func _initialize() -> void:
	var current: Dictionary = _scan()           # 指紋 -> true
	var baseline: Dictionary = _load_baseline()  # 指紋 -> true
	var added: Array = []
	for fp in current.keys():
		if not baseline.has(fp): added.append(fp)
	var removed: Array = []
	for fp in baseline.keys():
		if not current.has(fp): removed.append(fp)
	added.sort(); removed.sort()
	for fp in removed:
		print("[gate] removed (arc 溶解進度): %s" % fp)
	if added.is_empty():
		print("[CONSTITUTION-GATE] PASS (sites=%d, removed=%d)" % [current.size(), removed.size()])
	else:
		for fp in added:
			print("[gate] ❌ 新增引擎外 task 指派: %s" % fp)
		print("[CONSTITUTION-GATE] FAIL：新增 %d 個引擎外 task 指派點。溶入決策引擎，或呈報系統更新 baseline。" % added.size())
	quit()

func _scan() -> Dictionary:
	var out: Dictionary = {}
	var re := RegEx.new(); re.compile(MUT_RE)
	var func_re := RegEx.new(); func_re.compile("^\\s*(?:static\\s+)?func\\s+(\\w+)")
	_walk(SCAN_DIR, re, func_re, out)
	return out

func _walk(dir_path: String, re: RegEx, func_re: RegEx, out: Dictionary) -> void:
	var d := DirAccess.open(dir_path)
	if d == null: return
	d.list_dir_begin()
	var name_s: String = d.get_next()
	while name_s != "":
		var full: String = dir_path + "/" + name_s
		if d.current_is_dir():
			if not name_s.begins_with("."):
				_walk(full, re, func_re, out)
		elif name_s.ends_with(".gd"):
			_scan_file(full, re, func_re, out)
		name_s = d.get_next()
	d.list_dir_end()

func _scan_file(path: String, re: RegEx, func_re: RegEx, out: Dictionary) -> void:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null: return
	var rel: String = path.replace("res://", "")
	var cur_func: String = "<global>"
	while not f.eof_reached():
		var line: String = f.get_line()
		var fm := func_re.search(line)
		if fm != null:
			cur_func = fm.get_string(1)
		if re.search(line) != null:
			out["%s::%s" % [rel, cur_func]] = true
	f.close()

func _load_baseline() -> Dictionary:
	var out: Dictionary = {}
	var f := FileAccess.open(BASELINE, FileAccess.READ)
	if f == null:
		push_error("baseline 不存在：%s（首次跑 Step 2 產生）" % BASELINE)
		return out
	while not f.eof_reached():
		var line: String = f.get_line().strip_edges()
		if line == "" or line.begins_with("#"): continue
		out[line] = true
	f.close()
	return out
```

- [ ] **Step 2: 產生 baseline（record 模式）**

用臨時掃描印出當前指紋集，落檔為 baseline。跑一次性 record 指令（腳本已有 `_scan`，暫時讓它印集合）：先建空 baseline 佔位，跑閘看 FAIL 列出的 `added` 即當前全集；把那些指紋（去掉前綴 emoji/文字）寫進 `constitution_baseline.txt`。

實作步驟：
1. 先 `New-Item scripts/debug/constitution_baseline.txt`（空檔）。
2. Run: `.\tools\godot.ps1 --headless --script scripts/debug/constitution_gate.gd 2>&1 | Select-String "新增引擎外"`
   → 每行 `[gate] ❌ 新增引擎外 task 指派: <relpath>::<func>`。
3. 把每行的 `<relpath>::<func>` 指紋抽出，排序去重，寫進 `constitution_baseline.txt`，一行一指紋。檔頭加註解：
```
# 沙盒憲法 site-freeze baseline（凍結引擎外 task 指派面）。
# 契約：current ⊆ 本檔。新增指紋 = FAIL。移除（arc 溶解）= PASS。
# 8 known 違憲以 # 序N 標於對應指紋上方（threat 序1/solo 序2/vendetta 序4/prosperity 序5/dispatch 序6）。
# 產生：constitution_gate.gd record（2026-07-05 序0）。
```

- [ ] **Step 3: 標註 8 known 違憲指紋的 arc 序**

於 baseline 內，在對應指紋上方加 `# 序N` 註解（依 constitution-audit 清單）：
- `scripts/simulation/faction_ai_system.gd::_evaluate_threat` 與 `::_dispatch_threat_response` → `# 序1 threat`
- `scripts/simulation/faction_ai_system.gd::_evaluate_solo` → `# 序2 solo`
- `scripts/simulation/faction_ai_system.gd`（vendetta try_set 所在 func，@771 附近）→ `# 序4 vendetta`
- `scripts/simulation/faction_ai_system.gd`（prosperity_attack 所在 func，@244 附近）→ `# 序5 prosperity`
- `scripts/simulation/faction_ai_system.gd::_assign_tasks` 與 `::_assign_member_tasks` → `# 序6 dispatch`
- `scripts/simulation/reaction_system.gd`（ReactionBridge try_set 所在 func）→ `# 序7 reaction`

（若某違憲不經 TaskArbiter（如 rung_task 回字串）→ 不在指紋集，屬 coverage 聲明外，跳過標註。）

- [ ] **Step 4: 跑閘驗 PASS（current == baseline）**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/constitution_gate.gd 2>&1 | Select-String "CONSTITUTION-GATE"`
Expected: `[CONSTITUTION-GATE] PASS (sites=N, removed=0)`

- [ ] **Step 5: 負向自測——加一個假違憲點必 FAIL**

暫時在 `scripts/simulation/outpost_system.gd` 任一既有 func **不同於現有指紋的位置**插一行假呼叫（僅測，勿留）：於某個目前無 TaskArbiter 呼叫的 func 內加：
```gdscript
	# TEST-ONLY 假違憲（本步結束刪除）
	if false: TaskArbiter.transition(null, "", 0)
```
Run: `.\tools\godot.ps1 --headless --script scripts/debug/constitution_gate.gd 2>&1 | Select-String "CONSTITUTION-GATE|新增"`
Expected: `FAIL`，且列出 `outpost_system.gd::<該func>`。
確認後**刪除該測試行**，再跑一次 → 回 `PASS`。

- [ ] **Step 6: Commit**

```bash
git add scripts/debug/constitution_gate.gd scripts/debug/constitution_baseline.txt
git commit -m "feat(constitution): site-freeze gate on engine-external task assignment (grandfather 8 known)"
```

---

## Self-Review

- **Spec coverage**：修1（Task 1 hoist）✓、修2（Task 2 十常數 + FLEE 硬編）✓、修3（Task 3 eta 除數）✓、防新增憲法閘（Task 4 site-freeze + 8 known grandfather）✓。headless time assert 對齊——現根 240 不變故 MOVE=48 assert 不需改，屬 A2 落地（不在本 slice），已於 Global Constraints「不動時間根」聲明。
- **零行為變證**：Task 1–3 每 Task 收尾都跑 seeded（46/8/1/380）+ framework（PASS=7），Task 2 另加 `time_const_check` 值等式閘。
- **Type/名稱一致**：`TimeScale.TICK_PER_DAY`（非 `TICKS_PER_DAY`，TimeScale 內部命名見 `time_scale.gd:14`）、`FactionAISystem` const 名對齊 grep 結果、`WorldState.TICKS_PER_DAY` 於 Task 3。
- **無 placeholder**：所有 step 附實碼/實指令/預期輸出。
```
