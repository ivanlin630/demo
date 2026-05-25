# Team Merge Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 實作通用 team 合併機制，允許同格 team 將指定 NPC 轉移給另一 team，剩餘人口自動成為 absorber 的 idle 子隊。

**Architecture:** `SubteamSystem.merge_teams` 加 `transfer_npc_ids: Array = []` 和 `transfer_anon: int = -1` 參數，獨立於現有 `_merge_into`（子隊回歸路徑不動）。`InteractionSystem._try_interact` 更新 idle auto-merge 呼叫，加 `_try_merge` 處理 TASK_MERGE。`FactionAI` 加 stub 欄位。`TeamData` 加 `TASK_MERGE` 常數。

**Tech Stack:** Godot 4.2.2 GDScript，無外部依賴。

---

## 檔案結構

| 檔案 | 動作 | 說明 |
|---|---|---|
| `scripts/data/team_data.gd` | 修改 line 16 後 | 加 `TASK_MERGE` 常數 |
| `scripts/simulation/subteam_system.gd` | 修改 line 78–79 | 替換 `merge_teams` 函式（`_merge_into` 不動） |
| `scripts/simulation/interaction_system.gd` | 修改 line 185–188 + 加新函式 | 更新 idle auto-merge；加 `_try_merge` |
| `scripts/simulation/faction_ai_system.gd` | 修改 `_update_goals` | 加 "合併" goal stub 注解 |
| `scripts/debug/headless_test.gd` | 修改 line 274 後 | 加 merge 驗證場景 |
| `docs/progress.md` | 修改 | 加入完成項目 |
| `docs/team.md` | 修改 | 加 TASK_MERGE 欄位說明 |

---

## 背景知識（implementer 必讀）

### 合併語義

`merge_teams(state, absorber_id, absorbed_id, transfer_npc_ids: Array = [], transfer_anon: int = -1)` 語義：

- `transfer_npc_ids`：要轉移的記名 NPC id 列表（必須屬於 absorbed team）
- `transfer_anon`：要轉移的匿民數量
  - `-1`（預設）：比例模式，依 `named_transferred / named_in_absorbed` 比例帶走對應匿民
  - `0`：不帶匿民（只移記名 NPC）
  - `N > 0`：明確指定 N 名匿民（clamp 到實際匿民數）
- 空陣列 + `-1` = `_merge_into`（舊行為，全員轉移）
- absorbed.leader → absorber.advisors；其他記名 → absorber.members；匿民直接計數轉移
- 資源依 `total_xfer / absorbed.population` 比例轉移（`total_xfer = named + anon`）
- absorber 人口上限由 `pop_cap_from_leadership(absorber_cmd)` 決定；先分配記名再分配匿民，capacity 不足則截斷
- 若 absorbed.population > 0 **轉移後**：absorbed 成為 absorber 的 idle 子隊（`parent_team_id = absorber_id`；task = "idle"；tags 加 "子團"；absorber.subteam_ids 加入）
- 若 absorbed.population == 0 轉移後：absorbed 刪除

### 繼承（on_leader_death）

- 僅在 absorbed.leader 被轉移至 absorber 時呼叫
- 呼叫時機：NPC 轉移完成後，若 absorbed.leader_id 不在 absorbed.leader_id 了（即被轉走），且 absorbed.population > 0
- 若 absorbed 無 NPC 可繼承，PersonGenerator 可能晉升；此為正常行為

### 現有 _merge_into

`_merge_into`（line 81–132）是子隊回歸路徑，**不動**。`try_merge_back`（line 68–76）繼續呼叫 `_merge_into`，不受影響。

### Idle auto-merge（interaction_system.gd line 185–188）

目前：
```gdscript
elif a.current_task == "idle" and b.current_task == "idle":
    var absorber: int = id_a if a.population >= b.population else id_b
    var absorbed: int = id_b if absorber == id_a else id_a
    SubteamSystem.new().merge_teams(state, absorber, absorbed)
```

改為傳所有 absorbed named NPC ids（完全合併）：
```gdscript
elif a.current_task == "idle" and b.current_task == "idle":
    var absorber: int = id_a if a.population >= b.population else id_b
    var absorbed: int = id_b if absorber == id_a else id_a
    var abs_team: TeamData = state.teams[absorbed]
    var all_npcs: Array = []
    if abs_team.leader_id != -1: all_npcs.append(abs_team.leader_id)
    all_npcs.append_array(abs_team.advisors)
    all_npcs.append_array(abs_team.members)
    SubteamSystem.new().merge_teams(state, absorber, absorbed, all_npcs)
```

### TASK_MERGE 觸發

`_try_interact` same_faction block 加：
```gdscript
elif (a.current_task == TeamData.TASK_MERGE and a.order_target_id == id_b) \
        or (b.current_task == TeamData.TASK_MERGE and b.order_target_id == id_a):
    _try_merge(state, id_a, id_b)
```

`_try_merge` 函式：
```gdscript
func _try_merge(state: WorldState, id_a: int, id_b: int) -> void:
    var a: TeamData = state.teams[id_a]
    var b: TeamData = state.teams[id_b]
    var merger_id: int = id_a if a.current_task == TeamData.TASK_MERGE else id_b
    var target_id: int = id_b if merger_id == id_a else id_a
    var merger: TeamData = state.teams[merger_id]
    if merger.order_target_id != target_id:
        return
    var absorbed_team: TeamData = state.teams[target_id]
    var all_npcs: Array = []
    if absorbed_team.leader_id != -1: all_npcs.append(absorbed_team.leader_id)
    all_npcs.append_array(absorbed_team.advisors)
    all_npcs.append_array(absorbed_team.members)
    SubteamSystem.new().merge_teams(state, merger_id, target_id, all_npcs)
    merger.current_task = TeamData.TASK_IDLE
    merger.order_target_id = -1
```

---

## Task A：TeamData 加 TASK_MERGE

**Files:**
- Modify: `scripts/data/team_data.gd` line 16

- [ ] **Step 1: 在 TASK_BUILD 後加一行**

找到：
```gdscript
const TASK_BUILD       := "建設"
```

替換為：
```gdscript
const TASK_BUILD       := "建設"
const TASK_MERGE       := "合併"
```

- [ ] **Step 2: 重建快取**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

預期：無 error，exit 0。

- [ ] **Step 3: Commit**

```powershell
git add scripts/data/team_data.gd
git commit -m "feat(data): add TASK_MERGE constant"
```

---

## Task B：SubteamSystem.merge_teams 改寫

**Files:**
- Modify: `scripts/simulation/subteam_system.gd` lines 78–79

- [ ] **Step 1: 替換 merge_teams 函式**

找到並替換（只替換 line 78–79，`_merge_into` 不動）：

舊：
```gdscript
func merge_teams(state: WorldState, absorber_id: int, absorbed_id: int) -> void:
	_merge_into(state, absorber_id, absorbed_id)
```

新：
```gdscript
func merge_teams(state: WorldState, absorber_id: int, absorbed_id: int,
		transfer_npc_ids: Array = [], transfer_anon: int = -1) -> void:
	if transfer_npc_ids.is_empty() and transfer_anon == -1:
		_merge_into(state, absorber_id, absorbed_id)
		return
	var absorber: TeamData = state.teams.get(absorber_id)
	var absorbed: TeamData = state.teams.get(absorbed_id)
	if absorber == null or absorbed == null or absorbed.population <= 0:
		return
	var absorber_leader = state.persons.get(absorber.leader_id)
	var absorber_cmd: float = float(absorber_leader.skills.get("統領", 0.0)) if absorber_leader else 0.0
	var absorber_cap: int = TeamData.pop_cap_from_leadership(absorber_cmd)
	var capacity: int = absorber_cap - absorber.population
	if capacity <= 0:
		print("[Merge] Team%d 容量已滿，無法合併 Team%d" % [absorber_id, absorbed_id])
		return
	var named_cap: int = mini(transfer_npc_ids.size(), capacity)
	var actual_npcs: Array = transfer_npc_ids.slice(0, named_cap)
	# 計算匿民轉移數量
	var named_in_absorbed: int = (1 if absorbed.leader_id != -1 else 0) \
		+ absorbed.advisors.size() + absorbed.members.size()
	var anon_pop: int = maxi(absorbed.population - named_in_absorbed, 0)
	var anon_xfer: int
	if transfer_anon == -1:
		if named_in_absorbed > 0:
			anon_xfer = int(round(float(anon_pop) * float(actual_npcs.size()) / float(named_in_absorbed)))
		else:
			anon_xfer = anon_pop
	elif transfer_anon == 0:
		anon_xfer = 0
	else:
		anon_xfer = mini(transfer_anon, anon_pop)
	anon_xfer = mini(anon_xfer, maxi(capacity - actual_npcs.size(), 0))
	anon_xfer = maxi(anon_xfer, 0)
	var total_xfer: int = actual_npcs.size() + anon_xfer
	var frac: float = float(total_xfer) / float(absorbed.population) if absorbed.population > 0 else 0.0
	var absorbed_leader_moved: bool = false
	for pid in actual_npcs:
		var p: PersonData = state.persons.get(pid)
		if p == null or p.team_id != absorbed_id:
			continue
		p.team_id = absorber_id
		if pid == absorbed.leader_id:
			absorbed_leader_moved = true
			absorbed.leader_id = -1
			if not absorber.advisors.has(pid):
				absorber.advisors.append(pid)
		else:
			absorbed.advisors.erase(pid)
			absorbed.members.erase(pid)
			if not absorber.members.has(pid):
				absorber.members.append(pid)
	absorber.population += total_xfer
	absorbed.population -= total_xfer
	absorber.wounded += int(round(float(absorbed.wounded) * frac))
	absorbed.wounded = maxi(absorbed.wounded - int(round(float(absorbed.wounded) * frac)), 0)
	for res in absorbed.resources:
		var amt: float = float(absorbed.resources.get(res, 0)) * frac
		absorber.resources[res] = float(absorber.resources.get(res, 0)) + amt
		absorbed.resources[res] = float(absorbed.resources.get(res, 0)) - amt
	if absorbed_leader_moved and absorbed.population > 0:
		var es := EventSystem.new()
		es.on_leader_death(state, absorbed)
	if absorbed.population <= 0:
		absorber.subteam_ids.erase(absorbed_id)
		state.teams.erase(absorbed_id)
		state.team_known.erase(absorbed_id)
		print("[Merge] Team%d ← Team%d 完全合併 (absorber_pop=%d)" % [
			absorber_id, absorbed_id, absorber.population])
	else:
		absorbed.parent_team_id = absorber_id
		absorbed.current_task = TeamData.TASK_IDLE
		if not absorbed.tags.has("子團"):
			absorbed.tags.append("子團")
		if not absorber.subteam_ids.has(absorbed_id):
			absorber.subteam_ids.append(absorbed_id)
		print("[Merge] Team%d ← Team%d 部分合併 (absorber=%d absorbed=%d)" % [
			absorber_id, absorbed_id, absorber.population, absorbed.population])
```

- [ ] **Step 2: 重建快取**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

預期：無 error，exit 0。

- [ ] **Step 3: Commit**

```powershell
git add scripts/simulation/subteam_system.gd
git commit -m "feat(sim): rewrite merge_teams with transfer_npc_ids support"
```

---

## Task C：InteractionSystem 更新

**Files:**
- Modify: `scripts/simulation/interaction_system.gd` lines 185–188 + 新增 `_try_merge` 函式

- [ ] **Step 1: 更新 idle auto-merge（lines 185–188）**

找到：
```gdscript
		elif a.current_task == "idle" and b.current_task == "idle":
			var absorber: int = id_a if a.population >= b.population else id_b
			var absorbed: int = id_b if absorber == id_a else id_a
			SubteamSystem.new().merge_teams(state, absorber, absorbed)
```

替換為：
```gdscript
		elif a.current_task == "idle" and b.current_task == "idle":
			var absorber: int = id_a if a.population >= b.population else id_b
			var absorbed: int = id_b if absorber == id_a else id_a
			var abs_team: TeamData = state.teams[absorbed]
			var all_npcs: Array = []
			if abs_team.leader_id != -1: all_npcs.append(abs_team.leader_id)
			all_npcs.append_array(abs_team.advisors)
			all_npcs.append_array(abs_team.members)
			SubteamSystem.new().merge_teams(state, absorber, absorbed, all_npcs)
```

- [ ] **Step 2: 加 TASK_MERGE 觸發（在 idle auto-merge 後，`return` 之前）**

找到（same_faction block 的最後一行 `return`，即 line 189）：
```gdscript
		elif a.current_task == "idle" and b.current_task == "idle":
			var absorber: int = id_a if a.population >= b.population else id_b
			var absorbed: int = id_b if absorber == id_a else id_a
			var abs_team: TeamData = state.teams[absorbed]
			var all_npcs: Array = []
			if abs_team.leader_id != -1: all_npcs.append(abs_team.leader_id)
			all_npcs.append_array(abs_team.advisors)
			all_npcs.append_array(abs_team.members)
			SubteamSystem.new().merge_teams(state, absorber, absorbed, all_npcs)
		return
```

替換為：
```gdscript
		elif a.current_task == "idle" and b.current_task == "idle":
			var absorber: int = id_a if a.population >= b.population else id_b
			var absorbed: int = id_b if absorber == id_a else id_a
			var abs_team: TeamData = state.teams[absorbed]
			var all_npcs: Array = []
			if abs_team.leader_id != -1: all_npcs.append(abs_team.leader_id)
			all_npcs.append_array(abs_team.advisors)
			all_npcs.append_array(abs_team.members)
			SubteamSystem.new().merge_teams(state, absorber, absorbed, all_npcs)
		elif (a.current_task == TeamData.TASK_MERGE and a.order_target_id == id_b) \
				or (b.current_task == TeamData.TASK_MERGE and b.order_target_id == id_a):
			_try_merge(state, id_a, id_b)
		return
```

- [ ] **Step 3: 加 `_try_merge` 函式（在 `_try_diplomacy` 函式之後加入）**

找到 `_try_diplomacy` 函式的結尾（約 line 650 附近），在其後加：

```gdscript
func _try_merge(state: WorldState, id_a: int, id_b: int) -> void:
	var a: TeamData = state.teams[id_a]
	var b: TeamData = state.teams[id_b]
	var merger_id: int = id_a if a.current_task == TeamData.TASK_MERGE else id_b
	var target_id: int = id_b if merger_id == id_a else id_a
	var merger: TeamData = state.teams[merger_id]
	if merger.order_target_id != target_id:
		return
	var absorbed_team: TeamData = state.teams[target_id]
	var all_npcs: Array = []
	if absorbed_team.leader_id != -1: all_npcs.append(absorbed_team.leader_id)
	all_npcs.append_array(absorbed_team.advisors)
	all_npcs.append_array(absorbed_team.members)
	SubteamSystem.new().merge_teams(state, merger_id, target_id, all_npcs)
	merger.current_task = TeamData.TASK_IDLE
	merger.order_target_id = -1
```

- [ ] **Step 4: 重建快取**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

預期：無 error，exit 0。

- [ ] **Step 5: Commit**

```powershell
git add scripts/simulation/interaction_system.gd
git commit -m "feat(sim): update idle auto-merge and add _try_merge for TASK_MERGE"
```

---

## Task D：FactionAISystem stub

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd` — `_update_goals` 函式末段（約 line 142 後）

- [ ] **Step 1: 在 `_update_goals` 末段加 stub 注解**

找到 `_update_goals` 函式的最後一行（`f.goals.append("掠奪")` 的 if 區塊結束，約 line 142）：

```gdscript
	if f.is_established and loot_score > LOOT_SCORE_THRESHOLD \
			and leader_team.readiness >= LOOT_READINESS_MIN \
			and _has_independent(state, f.leader_team_id) \
			and _tag_weight(leader_team, "掠奪") > 0.0:
		f.goals.append("掠奪")
```

在其後加：

```gdscript
	# TODO: "合併" goal — 由 leader 手動指派 order_target_id，FactionAI 目前不自動觸發
```

- [ ] **Step 2: 重建快取**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

預期：無 error，exit 0。

- [ ] **Step 3: Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd
git commit -m "docs(sim): add merge goal stub in FactionAI _update_goals"
```

---

## Task E：headless_test.gd 驗證場景

**Files:**
- Modify: `scripts/debug/headless_test.gd` — 在 line 274（`state.persons.erase(30)`）後插入

- [ ] **Step 1: 在 PersonGenerator 測試清理後、`print("=== Sim Test")` 前插入 merge 驗證**

找到（line 274–275）：
```gdscript
	state.persons.erase(30)   # 清理「假死」leader（模擬 _kill_named_npc 後段）
	print("=== Sim Test: 200 Ticks ===")
```

替換為：
```gdscript
	state.persons.erase(30)   # 清理「假死」leader（模擬 _kill_named_npc 後段）

	# ── merge_teams 驗證 ──
	var ma := TeamData.new()
	ma.team_id = 11; ma.population = 5; ma.faction_id = 99; ma.tile_pos = Vector2i(0, -4)
	state.teams[11] = ma; state.team_known[11] = []; state.team_discovered[11] = []
	var ma_p := PersonData.new()
	ma_p.id = 40; ma_p.person_name = "MA_leader"; ma_p.role = "leader"
	ma_p.team_id = 11; ma_p.skills["統領"] = 0.6; ma_p.loyalty = 0.8
	state.persons[40] = ma_p; ma.leader_id = 40

	var mb := TeamData.new()
	mb.team_id = 12; mb.population = 3; mb.faction_id = 99; mb.tile_pos = Vector2i(0, -4)
	mb.resources["food"] = 90.0
	state.teams[12] = mb; state.team_known[12] = []; state.team_discovered[12] = []
	var mb_p := PersonData.new()
	mb_p.id = 41; mb_p.person_name = "MB_leader"; mb_p.role = "leader"
	mb_p.team_id = 12; mb_p.loyalty = 0.7
	state.persons[41] = mb_p; mb.leader_id = 41
	var mb_m := PersonData.new()
	mb_m.id = 42; mb_m.person_name = "MB_member"; mb_m.role = "civilian"
	mb_m.team_id = 12; mb_m.loyalty = 0.7
	state.persons[42] = mb_m; mb.members.append(42)

	# 完全合併：transfer 所有 MB NPC，transfer_anon=-1（比例帶走匿民）
	# MB pop=3：leader(41) + member(42) + 1 匿民；named=2 → anon=1
	# transfer 2 named → anon_xfer = round(1 * 2/2) = 1 → total_xfer=3 → MB 完全合併
	var _merge_npcs: Array = [41, 42]
	var _ss := SubteamSystem.new()
	_ss.merge_teams(state, 11, 12, _merge_npcs)  # transfer_anon 預設 -1
	print("=== merge_teams 測試（完全合併）===")
	if not state.teams.has(12):
		print("  [OK] Team12 完全合併入 Team11 (pop=%d)" % ma.population)
		if ma.advisors.has(41):
			print("  [OK] MB_leader(41) 成為 Team11 advisor")
		else:
			print("  [FAIL] MB_leader(41) 未進入 advisors")
		if ma.members.has(42):
			print("  [OK] MB_member(42) 成為 Team11 member")
		else:
			print("  [FAIL] MB_member(42) 未進入 members")
		if ma.population == 8:  # 5 + 3
			print("  [OK] Team11 pop=8（含 1 匿民）")
		else:
			print("  [WARN] Team11 pop=%d（預期 8）" % ma.population)
	else:
		print("  [FAIL] Team12 未被刪除（pop=%d）" % mb.population)

	# 追加：transfer_anon=0 測試（只移記名 NPC，匿民留下）
	var mc := TeamData.new()
	mc.team_id = 13; mc.population = 4; mc.faction_id = 99; mc.tile_pos = Vector2i(0, -4)
	mc.resources["food"] = 60.0
	state.teams[13] = mc; state.team_known[13] = []; state.team_discovered[13] = []
	var mc_p := PersonData.new()
	mc_p.id = 43; mc_p.person_name = "MC_leader"; mc_p.role = "leader"
	mc_p.team_id = 13; mc_p.loyalty = 0.7
	state.persons[43] = mc_p; mc.leader_id = 43
	# pop=4：1 named(43) + 3 anon
	_ss.merge_teams(state, 11, 13, [43], 0)  # transfer_anon=0：只移 leader，匿民留下
	print("=== merge_teams 測試（transfer_anon=0）===")
	if state.teams.has(13) and mc.population == 3:
		print("  [OK] Team13 剩 3 匿民（成為子隊）")
		if mc.parent_team_id == 11:
			print("  [OK] Team13.parent_team_id=11")
		else:
			print("  [FAIL] Team13.parent_team_id=%d" % mc.parent_team_id)
	else:
		print("  [FAIL] Team13 pop=%d（預期 3）" % mc.population)
	# 清理
	state.teams.erase(11); state.teams.erase(12); state.teams.erase(13)
	state.team_known.erase(11); state.team_known.erase(12); state.team_known.erase(13)
	state.team_discovered.erase(11); state.team_discovered.erase(12); state.team_discovered.erase(13)
	state.persons.erase(40); state.persons.erase(41); state.persons.erase(42); state.persons.erase(43)

	print("=== Sim Test: 200 Ticks ===")
```

- [ ] **Step 2: 跑 headless**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期輸出（含以下片段）：
```
=== merge_teams 測試 ===
  [OK] Team12 完全合併入 Team11 (pop=8)
  [OK] MB_leader(41) 成為 Team11 advisor
  [OK] MB_member(42) 成為 Team11 member
=== Sim Test: 200 Ticks ===
...
=== DONE ===
```

無 SCRIPT ERROR，`=== DONE ===` 出現，原有輸出（[Trade], [SubAI], faction 等）仍正常。

- [ ] **Step 3: Commit**

```powershell
git add scripts/debug/headless_test.gd
git commit -m "test: add merge_teams headless validation (Team11+12)"
```

---

## Task F：文件更新

**Files:**
- Modify: `docs/progress.md`
- Modify: `docs/team.md`

- [ ] **Step 1: progress.md — 加入完成項目**

在 `docs/progress.md` 的模擬系統層表格中，找到 `| \`subteam_system.gd\`` 的欄位並更新說明，加入 `merge_teams(transfer_npc_ids)` 的描述。或在表格末加一行：

```
| `subteam_system.gd` | dispatch/merge（transfer_npc_ids）/try_merge_back；部分合併→idle子隊；on_leader_death 繼承 |
```

在「中優先」完成清單加入（strikethrough 格式）：

```markdown
| ~~**Team 合併**~~ | ~~`merge_teams(transfer_npc_ids)`；部分合併→idle子隊；TASK_MERGE + _try_merge；idle auto-merge 更新~~ | ~~✅ PersonGenerator 完成~~ |
```

- [ ] **Step 2: team.md — 加 TASK_MERGE 說明**

找到 `docs/team.md` 中 TASK 常數列表，加入：

```
| TASK_MERGE | "合併" | team 主動合併另一 team；同格觸發；order_target_id 指定目標 |
```

- [ ] **Step 3: Commit**

```powershell
git add docs/progress.md docs/team.md
git commit -m "docs: add team merge to progress and team docs"
```

---

## 驗證 Checklist

```
[ ] headless 跑 200 Tick 無 SCRIPT ERROR
[ ] "=== DONE ===" 出現
[ ] merge_teams 完全合併：[OK] Team12 完全合併入 Team11 (pop=8)
[ ] MB_leader(41) 在 Team11 advisors
[ ] MB_member(42) 在 Team11 members
[ ] transfer_anon=0：[OK] Team13 剩 3 匿民成為子隊，parent_team_id=11
[ ] 原有所有輸出仍正常（[Trade], [SubAI], faction 等）
[ ] PersonGenerator 測試仍 [OK]
```
