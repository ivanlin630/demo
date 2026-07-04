# 飢餓致死鏈 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** famine_days 團級耗損（minor→anon）+ named 個人 hunger → blood 餓傷 → 昏迷（死碼復活）→ blood=0 死亡（通用死因）。

**Spec:** `docs/superpowers/specs/2026-06-13-famine-death-design.md`

**Verified facts:**
- `resource_system.resolve_consumption`（:67）：cadence 呼叫，`day_fraction = cadence_ticks / TICKS_PER_DAY`；satisfaction 計算 :93；`_update_person_needs` 把 satisfaction 寫進每個 named 的 `needs["food"]`
- `health_system.tick_natural_regen`（:190）：per person blood +0.2/tick（無出血時）+ body part hp regen；`BLOOD_COMA_THRESHOLD = 30.0` **零引用死碼**
- `encounter_system.is_combat_capable`（:95）：判 torso critical / 雙腿 critical / is_dead / has_exited — **不看 blood**
- `encounter_system.is_dead`（:91）：只看 torso severed
- named 戰死處理模式（encounter resolve ~:1054）：`named_members.erase(pid)` + `leader_id = -1`（person 留在 state.persons）；leader 死 → faction_ai `_promote_successor` / 玩家 → `_handle_player_leader_death` forced event
- `AnonTierSystem.kill_random(team, n, source)`：扣 tier 不扣 population（caller 自己扣 pop）
- `PersonData`：有 `blood: float = 100.0`、`needs` dict；無 hunger（需加）
- `TeamData`：無 famine_days（需加）
- 測試：`.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`

---

## Task 1: 團級 famine_days + minor/anon 耗損

**Files:**
- Modify: `scripts/data/team_data.gd`, `scripts/simulation/resource_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 失敗測試**

```gdscript
func _test_famine_days_accumulate() -> void:
	print("--- Famine Task1a: famine_days 累積/歸零 ---")
	# satisfaction < 0.3 跑 1 天 → famine_days 1；吃飽 → 歸 0
	# ...
	print("Famine Task1a OK")

func _test_famine_grace_no_death() -> void:
	# famine_days <= 7 → minor/anon/pop 不變
	# ...
	print("Famine Task1b OK")

func _test_famine_minor_dies_first() -> void:
	# famine_days > 7 + minor 5 → 每日 minor -ceili(5×0.1)；anon 不動
	# ...
	print("Famine Task1c OK")

func _test_famine_anon_after_minor() -> void:
	# minor 0 + anon 20 → 每日 kill_random ceili(20×0.05) + population 同步扣
	# sum(tiers)+named == population 保持
	# ...
	print("Famine Task1d OK")
```

- [ ] **Step 2: 實作**

`team_data.gd`：
```gdscript
var famine_days: int = 0   # 連續斷糧（satisfaction<0.3）天數；飢餓致死鏈用
```

`resource_system.gd` 常數 + `resolve_consumption` 內（satisfaction 算出後）：

```gdscript
const FAMINE_SATISFACTION_THRESHOLD: float = 0.3
const FAMINE_GRACE_DAYS: int = 7
const FAMINE_MINOR_DEATH_RATE: float = 0.10
const FAMINE_ANON_DEATH_RATE: float = 0.05

# famine 累積用 float 累加 day_fraction，存 team 上取整比較（或日邊界整算 — sub 擇一，注意 cadence 多次/日）
# 建議：team.famine_days 改存 float（_famine_acc），對外語意天數
if satisfaction < FAMINE_SATISFACTION_THRESHOLD:
	team.famine_days += day_fraction   # 欄位型別 float（命名保留 famine_days，單位=天）
	if team.famine_days > float(FAMINE_GRACE_DAYS):
		_apply_famine_attrition(state, team, day_fraction)
else:
	team.famine_days = 0.0

func _apply_famine_attrition(state: WorldState, team: TeamData, day_fraction: float) -> void:
	# 日比例死亡（cadence 分次按 day_fraction 機率/取整處理：每滿 1 天結算一次最簡 —
	# 用 fmod(famine_days, 1.0) 跨日偵測，跨日才結算，避免 cadence 重複殺）
	if int(team.famine_days) == int(team.famine_days - day_fraction): return   # 未跨日
	if team.minor_population > 0:
		var md: int = ceili(float(team.minor_population) * FAMINE_MINOR_DEATH_RATE)
		md = mini(md, team.minor_population)
		team.minor_population -= md
		print("[Famine] Team%d 餓死 minor %d (famine=%.0f天)" % [team.team_id, md, team.famine_days])
		return
	var anon_total: int = AnonTierSystem.total_pop(team)
	if anon_total > 0:
		var ad: int = maxi(ceili(float(anon_total) * FAMINE_ANON_DEATH_RATE), 1)
		var killed: Dictionary = AnonTierSystem.kill_random(team, ad, "famine")
		var actually: int = 0
		for t in killed: actually += killed[t]
		team.population = maxi(team.population - actually, 1)   # pop 最小 1（leader 不在此死）
		print("[Famine] Team%d 餓死 anon %d (famine=%.0f天)" % [team.team_id, actually, team.famine_days])
```

注意 `famine_days` 型別：team_data 宣告 `float`（語意=天）。

- [ ] **Step 3: 跑 + Commit**

```powershell
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
git add scripts/data/team_data.gd scripts/simulation/resource_system.gd scripts/debug/headless_test.gd
git commit -m "feat(famine): famine_days + minor/anon 耗損 (Task 1)"
```

---

## Task 2: named hunger + blood 餓傷

**Files:**
- Modify: `scripts/data/person_data.gd`, `scripts/simulation/resource_system.gd`, `scripts/simulation/health_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_hunger_accumulate_recover() -> void:
	# satisfaction 0 → hunger 每日 +0.05；吃飽 → -0.1/日；中途加入者 0 起算
	# ...
	print("Famine Task2a OK")

func _test_hunger_blood_drain() -> void:
	# hunger 0.8 → tick_natural_regen 不回血反流失；hunger 0.3 → 正常再生
	# ...
	print("Famine Task2b OK")
```

- [ ] **Step 2: 實作**

`person_data.gd`：
```gdscript
var hunger: float = 0.0   # 個人飢餓累積 [0,1]；跟人走不跟團（中途加入不繼承團時鐘）
```

`resource_system.resolve_consumption` 的 `_update_person_needs` 處（或同迴圈）per named：

```gdscript
const HUNGER_GAIN_PER_DAY: float = 0.05
const HUNGER_RECOVER_PER_DAY: float = 0.1

if satisfaction < FAMINE_SATISFACTION_THRESHOLD:
	p.hunger = minf(p.hunger + HUNGER_GAIN_PER_DAY * day_fraction
		* (FAMINE_SATISFACTION_THRESHOLD - satisfaction) / FAMINE_SATISFACTION_THRESHOLD, 1.0)
else:
	p.hunger = maxf(p.hunger - HUNGER_RECOVER_PER_DAY * day_fraction, 0.0)
```

`health_system.tick_natural_regen`：

```gdscript
const HUNGER_BLOOD_THRESHOLD: float = 0.7
const HUNGER_BLOOD_DRAIN_PER_TICK: float = 5.0 / float(WorldState.TICKS_PER_DAY)

# blood 再生分支改：
if p.hunger >= HUNGER_BLOOD_THRESHOLD:
	p.blood = maxf(p.blood - HUNGER_BLOOD_DRAIN_PER_TICK, 0.0)   # 餓傷：流失取代再生
elif not has_bleeding:
	p.blood = minf(p.blood + BLOOD_REGEN_PER_TICK, BLOOD_MAX)
```

（注意 tick_natural_regen 呼叫頻率 — grep caller 確認 per-tick or cadence，drain 常數對齊）

- [ ] **Step 3: 跑 + Commit**

```powershell
git add scripts/data/person_data.gd scripts/simulation/resource_system.gd scripts/simulation/health_system.gd scripts/debug/headless_test.gd
git commit -m "feat(famine): named hunger 累積 + blood 餓傷 (Task 2)"
```

---

## Task 3: 昏迷接線 + blood=0 死亡

**Files:**
- Modify: `scripts/simulation/encounter_system.gd`（昏迷）
- Modify: `scripts/simulation/health_system.gd`（死亡判定）+ 死亡處理接點（faction_ai / event_system 既有）
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_coma_incapacitates() -> void:
	# named unit blood 20 → is_combat_capable false（body parts 全 healthy 仍倒）
	# blood 40 → true
	# ...
	print("Famine Task3a OK")

func _test_blood_zero_death() -> void:
	# named blood → 0 → named_members.erase + person.team_id = -1
	# leader 死 → 繼承（_promote_successor 既有路徑觸發）
	# pop 同步 -1
	# ...
	print("Famine Task3b OK")

func _test_player_leader_starves() -> void:
	# 玩家 leader blood 0 → forced event（既有 _handle_player_leader_death 路徑）
	# ...
	print("Famine Task3c OK")
```

- [ ] **Step 2: 昏迷接線**

`encounter_system.is_combat_capable` 加（is_dead 檢查後）：

```gdscript
	# 失血/餓暈昏迷：blood < 30 → 倒地失能（BLOOD_COMA_THRESHOLD 實裝）
	var p_coma: PersonData = state.persons.get(unit.get("person_id", -1))
	if p_coma != null and p_coma.blood < HealthSystem.BLOOD_COMA_THRESHOLD:
		return false
	# anon unit 戰場血量（unit["blood"]）同判
	if unit.get("person_id", -1) == -1 \
			and float(unit.get("blood", 100.0)) < HealthSystem.BLOOD_COMA_THRESHOLD:
		return false
```

- [ ] **Step 3: blood=0 死亡（日邊界，health_system 新函數）**

```gdscript
# health_system.gd
static func check_starvation_deaths(state: WorldState) -> void:
	var dead: Array = []
	for pid in state.persons:
		var p: PersonData = state.persons[pid]
		if p.team_id == -1: continue
		if p.blood > 0.0: continue
		dead.append(pid)
	for pid in dead:
		var p: PersonData = state.persons[pid]
		var team: TeamData = state.teams.get(p.team_id)
		var cause: String = "餓死" if p.hunger >= 0.7 else "失血而亡"
		print("[Death] Person%d (team%d) %s" % [pid, p.team_id, cause])
		if team != null:
			team.named_members.erase(pid)
			team.population = maxi(team.population - 1, 1)
			if team.leader_id == pid:
				team.leader_id = -1
				# leader 死亡 → 既有繼承鏈（faction_ai evaluate_all 偵測 leader_id==-1 自動補；
				# 玩家 → _handle_player_leader_death 既有偵測點）
		p.team_id = -1
```

呼叫點：`sim_runner` 日邊界（與 DayNight print 同點）或 resolve_consumption 尾端 — sub 擇既有 cadence 點接。
**確認玩家死亡路徑**：grep `_handle_player_leader_death` 觸發點（偵測 leader_id==-1 或 person 死？），保證餓死也走到 choose_heir forced event。

- [ ] **Step 4: 跑 + Commit**

```powershell
git add scripts/simulation/encounter_system.gd scripts/simulation/health_system.gd scripts/debug/headless_test.gd
git commit -m "feat(famine): 昏迷接線 (BLOOD_COMA 實裝) + blood=0 死亡 (Task 3)"
```

---

## Task 4: 整合驗證 + 文件勘誤 + handback

**Files:**
- Modify: `docs/known_issues.md`（U4/S5 勘誤）
- Create: `docs/superpowers/handbacks/2026-06-13-famine-death.md`

- [ ] **Step 1: 跑全測試 + 90 天 multi + 2 年抽查**

```powershell
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_test.gd > godot_test.log 2>&1
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd > godot_multi.log 2>&1
Get-Content godot_multi.log | Select-String "Famine|Death|PopSample" | Select-Object -First 30
```

2 年抽查：config max_ticks 21600→172800（**Edit 工具改，嚴禁 PowerShell -replace**），跑完還原。

驗收：
- 流浪團不再永生：`[Famine]` 耗損出現、PopSample 曲線下行（流浪團）
- 居民村（轉正後）無 famine 死亡
- **無開局滅團潮**：grace 7 天內 pop 不掉；若多 config 開局大量餓死 → 回報並建議調 grace/比例（不自行大改 config）
- ALL INVARIANTS PASSED；`sum(tiers)+named == pop` 抽查；coin 守恆 delta 0

- [ ] **Step 2: known_issues U4/S5 勘誤**

兩條加註：「描述為 2026-05 舊 prototype 行為；現行架構餓死鏈由 2026-06-13 famine-death spec 補實」。

- [ ] **Step 3: handback + Commit**

```markdown
# Hand Back: 飢餓致死鏈
## 實作摘要 / 行為變化（famine 死亡分布、人口曲線 before/after、開局衝擊評估）/ 驗證 / 待確認（死亡率參數、戰場 bleeding 致死率上升觀察）
```

```powershell
git add docs/known_issues.md docs/superpowers/handbacks/2026-06-13-famine-death.md
git commit -m "docs: famine death handback + U4/S5 勘誤 (Task 4)"
```
