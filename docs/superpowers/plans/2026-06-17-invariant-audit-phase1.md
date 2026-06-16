# 不變量架構收口 Phase 1：InvariantAudit 框架 + 三網 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 建通用 `InvariantAudit` 框架 + 註冊 population / faction-雙向 / subteam-雙向 三個不變量檢查，接入 multi sanity + headless，讓現有 drift 從「默默壞」變「測試紅燈」。

**Architecture:** 純新增「檢查」層，**不改任何模擬行為**。一個 static `InvariantAudit.check(state) -> Array[String]` 列各不變量檢查函數（回違反訊息清單）。game_sim_multi 每月取樣呼叫 + headless 端到端測。Phase 1 預期**先紅**（揭露現有 population/雙向 drift）= 正確診斷，非失敗。

**Tech Stack:** Godot 4.2.2 GDScript；headless（`.\tools\godot.ps1`）+ game_sim_multi。

依據 spec：`docs/superpowers/specs/2026-06-17-invariant-architecture-design.md`。

**既有錨點（不重寫）**：
- `AnonTierSystem.total_pop(team) -> int`（anon_tiers 各 tier 總和）。
- population 不變量（game_setup.gd:342 反推）：`team.population == (1 if team.leader_id != -1 else 0) + team.named_members.size() + AnonTierSystem.total_pop(team) + team.wounded`。
- 雙向欄位：`team.faction_id` ↔ `FactionData.member_team_ids`；`team.parent_team_id` ↔ `team.subteam_ids`。
- `game_sim_multi._coin_equivalent_total`（既有守恆審計範本，約 :120）+ 月取樣點（`current_tick % WorldState.TICKS_PER_MONTH == 0`，約 :67）。
- 範本 getter：`team_data.gd:95-107`（anon_combat_skill/anon_wage computed getter）。

---

## 檔案結構

- `scripts/simulation/invariant_audit.gd`（新，class_name InvariantAudit）：static `check(state) -> Array[String]` + 各不變量私有檢查。放 simulation 下（headless + multi 都能用 class_name）。
- `scripts/debug/game_sim_multi.gd`（改）：月取樣呼 `InvariantAudit.check`，非空印 `[InvariantViolation]` + 計數，summary 報。
- `scripts/debug/headless_test.gd`（改）：`_test_invariant_audit`（建構正常 state → 0 違反；故意造 drift → 偵測到）。

---

## Task 1: InvariantAudit 框架 + population 檢查

**Files:**
- Create: `scripts/simulation/invariant_audit.gd`
- Test: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 寫失敗測試** — `headless_test.gd`

```gdscript
func _test_invariant_audit() -> void:
	print("--- InvariantAudit 框架 + population ---")
	var state := WorldState.new(); state.world = WorldData.new()
	# 正常隊：pop == leader(1) + named(1) + anon(3) + wounded(0) = 5
	var leader := PersonData.new(); leader.id = 0; leader.team_id = 0
	state.persons[0] = leader
	var m := PersonData.new(); m.id = 1; m.team_id = 0
	state.persons[1] = m
	var t := TeamData.new(); t.team_id = 0; t.leader_id = 0; t.named_members = [1]
	t.wounded = 0; t.population = 5
	AnonTierSystem.add_anon(t, "平民", 3)
	state.teams[0] = t
	assert(InvariantAudit.check(state).is_empty(), "正常隊不該有違反:%s" % str(InvariantAudit.check(state)))
	# 造 drift：named 死(移出 named_members)但 pop 沒減 → pop=5 但實際 leader+named(0)+anon(3)=4
	t.named_members = []
	var v: Array = InvariantAudit.check(state)
	assert(v.size() > 0, "pop drift 應被偵測")
	assert("population" in str(v), "違反訊息應含 population:%s" % str(v))
	print("InvariantAudit population OK")
```
註冊進 `_initialize()`。

- [ ] **Step 2: 跑確認失敗** — `InvariantAudit` 不存在。
Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`

- [ ] **Step 3: 實作** — `scripts/simulation/invariant_audit.gd`

```gdscript
class_name InvariantAudit

# 通用不變量審計：回違反訊息清單（空=全部一致）。
# 加新不變量 = 加一個 _check_* 並在 check() 呼叫。真存的守恆量(coin_eq)/不能衍生的不變量註冊於此。
static func check(state: WorldState) -> Array[String]:
	var violations: Array[String] = []
	_check_population(state, violations)
	return violations

# population 不變量：== leader(0/1) + named + anon + wounded
static func _check_population(state: WorldState, out: Array[String]) -> void:
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		var expected: int = (1 if t.leader_id != -1 else 0) \
			+ t.named_members.size() + AnonTierSystem.total_pop(t) + t.wounded
		if t.population != expected:
			out.append("population drift Team%d: 欄位=%d 期望=%d (leader%d+named%d+anon%d+wounded%d)" % [
				tid, t.population, expected,
				(1 if t.leader_id != -1 else 0), t.named_members.size(),
				AnonTierSystem.total_pop(t), t.wounded])
```

- [ ] **Step 4: 跑確認通過** — `InvariantAudit population OK`，headless `=== DONE ===`。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/invariant_audit.gd scripts/debug/headless_test.gd
git commit -m "feat(audit): InvariantAudit 框架 + population 衍生一致性檢查（Phase1）"
```

---

## Task 2: faction 雙向一致性檢查

**Files:**
- Modify: `scripts/simulation/invariant_audit.gd`
- Test: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 寫失敗測試** — `headless_test.gd`（在 `_test_invariant_audit` 後加新測或擴充；此處新函式）

```gdscript
func _test_invariant_faction_bidir() -> void:
	print("--- InvariantAudit faction 雙向 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var t := TeamData.new(); t.team_id = 0; t.faction_id = 9
	state.teams[0] = t
	var f := FactionData.new(); f.faction_id = 9; f.member_team_ids = [0]
	state.factions[9] = f
	# 修掉 population 干擾：給最小一致 team
	t.leader_id = -1; t.named_members = []; t.wounded = 0; t.population = 0
	assert(InvariantAudit.check(state).is_empty(), "雙向一致不該違反:%s" % str(InvariantAudit.check(state)))
	# 造懸空：member 列含 0 但 team0.faction_id 改成別的
	t.faction_id = 5
	assert("faction" in str(InvariantAudit.check(state)), "faction 雙向破口應偵測")
	# 反向：team 自稱屬 9 但不在 member 列
	t.faction_id = 9; f.member_team_ids = []
	assert("faction" in str(InvariantAudit.check(state)), "faction 反向破口應偵測")
	print("InvariantAudit faction 雙向 OK")
```
註冊進 `_initialize()`。

- [ ] **Step 2: 跑確認失敗** — `_check_faction_bidir` 未實作（測掛在反向偵測）。

- [ ] **Step 3: 實作** — `invariant_audit.gd` 加：

```gdscript
# check() 內加呼叫：
	_check_faction_bidir(state, violations)
```
```gdscript
# faction 雙向：member_team_ids 內每隊須回指此 faction；team.faction_id != -1 須在對應 member 列。
static func _check_faction_bidir(state: WorldState, out: Array[String]) -> void:
	for fid in state.factions:
		var f: FactionData = state.factions[fid]
		for tid in f.member_team_ids:
			var t: TeamData = state.teams.get(tid)
			if t == null:
				out.append("faction 懸空 Faction%d.member_team_ids 含已不存在 Team%d" % [fid, tid])
			elif t.faction_id != fid:
				out.append("faction 雙向破 Faction%d 列 Team%d 但其 faction_id=%d" % [fid, tid, t.faction_id])
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.faction_id == -1: continue
		var f: FactionData = state.factions.get(t.faction_id)
		if f == null:
			out.append("faction 反向破 Team%d.faction_id=%d 但 faction 不存在" % [tid, t.faction_id])
		elif not f.member_team_ids.has(tid):
			out.append("faction 反向破 Team%d 自稱屬 Faction%d 但不在 member_team_ids" % [tid, t.faction_id])
```
（確認 `WorldState.factions` 與 `FactionData.member_team_ids` 欄位名以現碼為準。）

- [ ] **Step 4: 跑確認通過** — `InvariantAudit faction 雙向 OK`。

- [ ] **Step 5: Commit**
```bash
git add scripts/simulation/invariant_audit.gd scripts/debug/headless_test.gd
git commit -m "feat(audit): faction 雙向一致性檢查（Phase1）"
```

---

## Task 3: subteam 雙向一致性檢查

**Files:**
- Modify: `scripts/simulation/invariant_audit.gd`
- Test: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 寫失敗測試** — `headless_test.gd`

```gdscript
func _test_invariant_subteam_bidir() -> void:
	print("--- InvariantAudit subteam 雙向 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var parent := TeamData.new(); parent.team_id = 0; parent.subteam_ids = [1]
	parent.leader_id = -1; parent.population = 0
	var child := TeamData.new(); child.team_id = 1; child.parent_team_id = 0
	child.leader_id = -1; child.population = 0
	state.teams[0] = parent; state.teams[1] = child
	assert(InvariantAudit.check(state).is_empty(), "subteam 一致不該違反:%s" % str(InvariantAudit.check(state)))
	# 造破口：parent 列 child 但 child.parent_team_id 改別的
	child.parent_team_id = -1
	assert("subteam" in str(InvariantAudit.check(state)), "subteam 雙向破應偵測")
	print("InvariantAudit subteam 雙向 OK")
```
註冊進 `_initialize()`。

- [ ] **Step 2: 跑確認失敗** — `_check_subteam_bidir` 未實作。

- [ ] **Step 3: 實作** — `invariant_audit.gd` 加：
```gdscript
# check() 內加呼叫：
	_check_subteam_bidir(state, violations)
```
```gdscript
# subteam 雙向：parent.subteam_ids 內每隊 parent_team_id 須回指 parent。
static func _check_subteam_bidir(state: WorldState, out: Array[String]) -> void:
	for pid in state.teams:
		var parent: TeamData = state.teams[pid]
		for cid in parent.subteam_ids:
			var child: TeamData = state.teams.get(cid)
			if child == null:
				out.append("subteam 懸空 Team%d.subteam_ids 含已不存在 Team%d" % [pid, cid])
			elif child.parent_team_id != pid:
				out.append("subteam 雙向破 Team%d 列子隊 Team%d 但其 parent_team_id=%d" % [pid, cid, child.parent_team_id])
```
（註：只查 parent→child 方向 + 懸空;child.parent_team_id 指向不存在 parent 的反向可選加，但 subteam 回歸/滅團路徑多由 parent 端維護，先查此向。）

- [ ] **Step 4: 跑確認通過** — `InvariantAudit subteam 雙向 OK`。

- [ ] **Step 5: Commit**
```bash
git add scripts/simulation/invariant_audit.gd scripts/debug/headless_test.gd
git commit -m "feat(audit): subteam 雙向一致性檢查（Phase1）"
```

---

## Task 4: 接入 multi sanity（揭露現有 drift）

**Files:**
- Modify: `scripts/debug/game_sim_multi.gd`

- [ ] **Step 1: 接入月取樣審計** — 在月取樣區（`current_tick % TICKS_PER_MONTH == 0`，約 :67-69 PopSample 附近）加：

```gdscript
			var inv: Array = InvariantAudit.check(state)
			if not inv.is_empty():
				inv_violations += inv.size()
				if inv_first_sample.is_empty():
					inv_first_sample = inv.slice(0, mini(3, inv.size()))
				print("[InvariantViolation] %s tick=%d 違反 %d 項,例:%s" % [
					cfg_name, state.world.current_tick, inv.size(), str(inv.slice(0, mini(2, inv.size())))])
```
在 `_run_config` 開頭加 `var inv_violations: int = 0` + `var inv_first_sample: Array = []`（與既有統計變數同區）。summary print 加 `[InvariantSummary] %s 違反取樣總計=%d 首例=%s`。

- [ ] **Step 2: 跑 multi（揭露現有 drift）** — 
```powershell
$env:GODOT_TIMEOUT='500'
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd
```
Expected: **預期看到 `[InvariantViolation]`**（現有 population/雙向 drift 現形）= **正確診斷**。記錄首例供 Phase 2/3 修。**不要因為紅就改模擬行為**——Phase 1 只負責「讓它可見」，修在後續階段。

- [ ] **Step 3: Commit**
```bash
git add scripts/debug/game_sim_multi.gd
git commit -m "feat(audit): multi sanity 接入 InvariantAudit（揭露現有 drift,Phase1 診斷）"
```

---

## Task 5: 收尾 + handback

- [ ] **Step 1: 全跑** — 殺孤兒 godot → `.\tools\godot.ps1 --headless --import` → headless（`=== DONE ===`、三個 `InvariantAudit ... OK` 綠）、ui_logic、ui_flow 不退。
- [ ] **Step 2: 記錄 multi 的 `[InvariantViolation]` 首例**（哪些 config、population vs 雙向、首現 tick）→ 寫進 handback，當 Phase 2/3 修復的基準清單。
- [ ] **Step 3: handback** — `docs/superpowers/handbacks/2026-06-17-invariant-audit-phase1.md`：框架接入摘要 + **multi 揭露的現有 drift 清單**（population 哪些 config 漂、雙向有無懸空）+ 連動風險（純加檢查,不改行為）+ 待 Phase 2（wounded getter + wounded net）/ Phase 3（population getter + 審 44 點）。

---

## 注意事項（給實作者）

- **Phase 1 只加「檢查」,絕不改任何模擬行為**。看到 `[InvariantViolation]` 是預期診斷,**不准為了消紅去改 population/faction mutation**（那是 Phase 2/3 的事,且要走衍生化非補貼）。
- 名稱核對：`WorldState.teams/factions`、`TeamData.named_members/anon_tiers/wounded/faction_id/parent_team_id/subteam_ids`、`FactionData.member_team_ids`、`AnonTierSystem.total_pop`、月取樣常數 `WorldState.TICKS_PER_MONTH` 以現碼為準。
- `Array[String]` typed return：若 GDScript 版本對 typed array append 挑剔,退 `Array`。
- headless assert 失敗卡 quit() → 先 print 再 assert。
- **不做**：wounded net（Phase 2,需先解 anon 傷況來源）、任何 getter 化、任何 mutation 收斂——本 plan 純框架+三網診斷。
