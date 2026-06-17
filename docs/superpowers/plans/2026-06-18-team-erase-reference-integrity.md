# Team Erase 引用完整性（單一 chokepoint 清光懸空 ref + audit）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 加 `WorldState.erase_team(tid)` 單一 chokepoint，team 移除時一處清光**所有**指向它的 ref（其他隊的 combat_target/order_target_id/strategic_assignments/cooldown/reputation + team_known/team_discovered 交叉條目 + 自身 registry + faction + 母子）。三條 erase 路徑全走它。加 `InvariantAudit._check_no_dangling_team_id` 守。使「無懸空 team_id」成真不變量 → 靜默 `.get()+continue` guard 變冗餘可拆。

**Architecture:** 同 invariant 工作哲學（單一入口 + audit）。現況：`cleanup_extinct_teams`（滅團）只 route assets + detach parent + teams.erase，漏清其他隊 ref + 自身 team_known/discovered；`_erase_absorbed_team`（merge）清較全；`beast._cleanup` 清交叉 discovered。三條各做一半 → 統一到 chokepoint。

**Tech Stack:** Godot 4.2.2 GDScript。閘 = `headless_test.gd`（`=== DONE ===`）+ `game_sim_multi.gd`（新 `dangling team_id` audit → 0；既有 coin_eq=0、全 invariant 0 維持）。

**前置（強制，依 `docs/process/03_implementer.md`）：**
```powershell
git worktree add .worktrees/team-erase-integrity -b feat/team-erase-integrity
cd .worktrees/team-erase-integrity
```

**Baseline：** `headless_test.gd` → `=== DONE ===`。記 `game_sim_multi.gd` 既有 invariant 全 0（cohort/faction/subteam/population）。

---

## team_id ref 點清單（研究確認）

| 持有處 | 欄位 | 型 |
|---|---|---|
| TeamData | `combat_target` / `order_target_id` | int |
| TeamData | `parent_team_id`(雙向已 detach) / `subteam_ids`(雙向已) / `faction_id`(雙向已) | int/Array |
| TeamData | `known_reputations` / `invite_cooldown` / `diplomacy_reject_cooldown` / `strategic_assignments` | Dict（鍵=tid） |
| WorldState | `team_known` / `team_discovered` | Dict（鍵=tid，值=Array[tid]） |
| FactionData | `member_team_ids`(雙向已) / `leader_team_id`(滅團 disband) / `known_member_states` | Array/int/Dict(鍵=tid) |

erase 時須清：自身 registry 條目 + **所有其他隊**的 int ref（==tid→-1）、dict 鍵(tid)、list 含 tid + faction 三項 + 母子。

---

## File Structure

| 檔案 | 動作 |
|---|---|
| `scripts/data/world_state.gd` | Modify | 加 `erase_team(tid)` chokepoint |
| `scripts/simulation/faction_ai_system.gd` | Modify | `cleanup_extinct_teams` 走 `erase_team` |
| `scripts/simulation/subteam_system.gd` | Modify | `_erase_absorbed_team` 走 `erase_team` |
| `scripts/simulation/beast_system.gd` | Modify | `_cleanup` 走 `erase_team` |
| `scripts/simulation/invariant_audit.gd` | Modify | 加 `_check_no_dangling_team_id` |
| `scripts/debug/headless_test.gd` | Modify | 加 `_test_erase_team` |

---

## Task 1: WorldState.erase_team chokepoint

**Files:** Modify `scripts/data/world_state.gd`（接在 `detach_subteam` 後）

- [ ] **Step 1: 加 erase_team**

```gdscript
# 單一 team 移除 chokepoint：清光所有指向 tid 的 ref，使「無懸空 team_id」成不變量。
# 所有 team 移除（滅團/合併/野獸清除）都須走此入口。
func erase_team(tid: int) -> void:
	var team: TeamData = teams.get(tid)
	if team == null:
		return
	# 1. 母子：脫離 parent + 孤兒化自己的子隊
	if team.parent_team_id != -1:
		detach_subteam(team)
	for cid in team.subteam_ids.duplicate():
		if teams.has(cid):
			teams[cid].parent_team_id = -1
	team.subteam_ids.clear()
	# 2. faction：退成員 + known_member_states + 若為盟主則解散
	if team.faction_id != -1 and factions.has(team.faction_id):
		var f = factions[team.faction_id]
		f.member_team_ids.erase(tid)
		f.known_member_states.erase(tid)
		if f.leader_team_id == tid:
			disband_faction(team.faction_id)
	# 3. 其他隊指向 tid 的 ref 全清
	for otid in teams:
		if otid == tid:
			continue
		var o: TeamData = teams[otid]
		if o.combat_target == tid:
			o.combat_target = -1
		if o.order_target_id == tid:
			o.order_target_id = -1
		o.known_reputations.erase(tid)
		o.invite_cooldown.erase(tid)
		o.diplomacy_reject_cooldown.erase(tid)
		o.strategic_assignments.erase(tid)
	# 4. registry：自身條目 + 交叉 discovered/known
	team_known.erase(tid)
	team_discovered.erase(tid)
	for obs in team_known:
		team_known[obs].erase(tid)
	for obs in team_discovered:
		team_discovered[obs].erase(tid)
	# 5. 移除
	teams.erase(tid)
```
> `disband_faction` 在 teams.erase 前呼叫（tid 仍在 teams，安全）。step 3 迴圈在 step 2 之後（faction 已處理）。子隊孤兒化：parent 死 → 子隊變獨立（parent_team_id=-1），非連帶滅團。

- [ ] **Step 2: 跑 headless**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 3: Commit**

```bash
git add scripts/data/world_state.gd
git commit -m "feat(state): erase_team 單一 chokepoint 清光懸空 team_id ref"
```

---

## Task 2: erase_team 單元測試

**Files:** Modify `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加測試 + 註冊**

```gdscript
func _test_erase_team() -> void:
	var st := WorldState.new()
	var a := TeamData.new(); a.team_id = 1; st.teams[1] = a; st.team_known[1] = []; st.team_discovered[1] = []
	var b := TeamData.new(); b.team_id = 2; st.teams[2] = b; st.team_known[2] = [1]; st.team_discovered[2] = [1]
	# b 指向 a 的各種 ref
	b.combat_target = 1; b.order_target_id = 1
	b.known_reputations[1] = 0.7; b.invite_cooldown[1] = 99
	b.diplomacy_reject_cooldown[1] = 50; b.strategic_assignments[1] = Vector2i(0,0)
	# a 有子隊 c
	var c := TeamData.new(); c.team_id = 3; c.parent_team_id = 1; st.teams[3] = c
	a.subteam_ids = [3]
	st.erase_team(1)
	assert(not st.teams.has(1), "a 已移除")
	assert(b.combat_target == -1 and b.order_target_id == -1, "b 的 int ref 清空")
	assert(not b.known_reputations.has(1) and not b.invite_cooldown.has(1), "b 的 dict 鍵清空")
	assert(not b.diplomacy_reject_cooldown.has(1) and not b.strategic_assignments.has(1), "b 其餘 dict 清空")
	assert(not st.team_discovered[2].has(1) and not st.team_known[2].has(1), "交叉 discovered/known 清 1")
	assert(not st.team_known.has(1) and not st.team_discovered.has(1), "自身 registry 條目清")
	assert(c.parent_team_id == -1, "子隊孤兒化")
	print("[OK] _test_erase_team")
```
註冊於 `_initialize()`：`_test_erase_team()`。

- [ ] **Step 2: 跑 headless**

Expected: `[OK] _test_erase_team`、`=== DONE ===`。

- [ ] **Step 3: Commit**

```bash
git add scripts/debug/headless_test.gd
git commit -m "test: erase_team 清光 ref 單元測試"
```

---

## Task 3: 三條 erase 路徑走 chokepoint

- [ ] **Step 1: cleanup_extinct_teams**

`scripts/simulation/faction_ai_system.gd:1349-1358`，把：
```gdscript
		var team: TeamData = state.teams[tid]
		_route_extinct_assets(state, team)
		if team.parent_team_id != -1:
			state.detach_subteam(team)
		state.teams.erase(tid)
```
改成：
```gdscript
		var team: TeamData = state.teams[tid]
		_route_extinct_assets(state, team)
		state.erase_team(tid)   # 清光所有 ref（含 detach、registry、交叉）
```

- [ ] **Step 2: _erase_absorbed_team**

`scripts/simulation/subteam_system.gd:103-113`（`_erase_absorbed_team`），整個函數體改為委派：
```gdscript
func _erase_absorbed_team(state: WorldState, absorbed_id: int) -> void:
	state.erase_team(absorbed_id)
```
> erase_team 已涵蓋 faction member/known_member_states erase + registry + 交叉 ref，取代原手動清理。

- [ ] **Step 3: beast _cleanup**

`scripts/simulation/beast_system.gd:57-62`（`_cleanup`），整個函數體改為：
```gdscript
func _cleanup(state: WorldState, beast_id: int) -> void:
	state.erase_team(beast_id)
```
> 取代原手動 teams/known/discovered + 交叉 discovered 清理（erase_team 已含）。

- [ ] **Step 4: 全 headless 回歸**

```powershell
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`、無 `SCRIPT ERROR`、滅團/合併/野獸相關測試綠。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/faction_ai_system.gd scripts/simulation/subteam_system.gd scripts/simulation/beast_system.gd
git commit -m "refactor(state): 滅團/合併/野獸 erase 三路徑統一走 erase_team"
```

---

## Task 4: InvariantAudit 懸空 team_id 網

**Files:** Modify `scripts/simulation/invariant_audit.gd`

- [ ] **Step 1: 加 _check_no_dangling_team_id + 註冊**

`check()` 加 `_check_no_dangling_team_id(state, violations)`。檔末加：
```gdscript
# 無懸空 team_id：任何欄位/dict/list 指向不存在的 team = erase 漏清。
static func _check_no_dangling_team_id(state: WorldState, out: Array[String]) -> void:
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.combat_target != -1 and not state.teams.has(t.combat_target):
			out.append("懸空 Team%d.combat_target=%d 不存在" % [tid, t.combat_target])
		if t.order_target_id != -1 and not state.teams.has(t.order_target_id):
			out.append("懸空 Team%d.order_target_id=%d 不存在" % [tid, t.order_target_id])
		for k in t.known_reputations:
			if not state.teams.has(k):
				out.append("懸空 Team%d.known_reputations 含死 Team%d" % [tid, k]); break
		for k in t.strategic_assignments:
			if k != -1 and not state.teams.has(k):
				out.append("懸空 Team%d.strategic_assignments 含死 Team%d" % [tid, k]); break
	for obs in state.team_discovered:
		for did in state.team_discovered[obs]:
			if not state.teams.has(did):
				out.append("懸空 team_discovered[%d] 含死 Team%d" % [obs, did]); break
```
> cooldown dict（invite/diplomacy_reject）含死 id 屬時限性無害（不檢，避免 noise）；如要嚴格可加。`strategic_assignments` 的 `-1` 鍵是突圍語意（非 team）→ 跳過。

- [ ] **Step 2: 跑 headless**

Expected: `=== DONE ===`、`InvariantAudit ... OK`、無 `SCRIPT ERROR`。

- [ ] **Step 3: Commit**

```bash
git add scripts/simulation/invariant_audit.gd
git commit -m "feat(audit): InvariantAudit 加無懸空 team_id 網"
```

---

## Task 5: drift 歸零驗證 + 殘留追蹤

- [ ] **Step 1: multi sanity**

```powershell
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd
```
Expected: `懸空 ...` → **0**（4 config）。既有 cohort/faction/subteam/population 全 0、coin_eq=0、無 `SCRIPT ERROR` 維持。

- [ ] **Step 2: 追殘留（若懸空 > 0）**

殘留 = 某 team 移除路徑沒走 `erase_team`，或某 ref 點漏清。grep `teams\.erase` 在 `scripts/`，確認除 `world_state.erase_team` 內部外無其他直接 `state.teams.erase`；有則改走 erase_team。重跑到 0。

- [ ] **Step 3: Commit（若有殘留修正）**

```bash
git add -A
git commit -m "fix(state): 補殘留 team 移除點走 erase_team"
```

---

## Task 6: hand-back

- [ ] **Step 1: hand-back** `docs/superpowers/handbacks/2026-06-18-team-erase-reference-integrity.md`：
- 實作摘要：erase_team chokepoint + 三路徑統一 + audit 網（每檔一行）。
- 驗證：懸空 team_id → 0；既有全 invariant 0、coin_eq=0 維持；headless 綠。
- 連動風險 / 後續：「無懸空 team_id」現為真不變量 → 消費端靜默 `.get()+continue` guard 變**冗餘**，可後續 sweep 拆（改 assert 或刪）；本 plan 不動 guard（先立不變量，deguard 另開）。cooldown dict 死鍵未檢（時限無害）。
- 與哲學：完成 reference integrity（單一入口 + audit），呼應「code 寫好就不靠 guard」——靠結構保證而非紀律。

- [ ] **Step 2: Commit + push + 回報**

```bash
git add docs/superpowers/handbacks/2026-06-18-team-erase-reference-integrity.md
git commit -m "docs: team erase 引用完整性 hand-back"
git push -u origin feat/team-erase-integrity
```
回報分支（finishing 選 Option 3，主 session merge）。

---

## Self-Review

**Spec coverage：** 延伸 invariant 工作到 reference integrity（master spec 未明列，但同「單一入口 + audit」哲學）。涵蓋研究確認的全 team_id ref 點。deguard 是後續（本 plan 立不變量，不動消費端）。

**Placeholder scan：** 無 TBD。Task 5 殘留追蹤 audit-driven（grep teams.erase + 懸空訊息），非 placeholder。

**Type consistency：** `erase_team(tid: int)` 為 WorldState 方法，呼叫端持 `state`。`team_discovered`/`team_known` 值為 Array（`.erase` by value，對齊 beast_system:62 用法）。`known_reputations`/`strategic_assignments`/cooldown 為 Dict（`.erase` by key）。`_check_no_dangling_team_id(state, out)` 對齊既有 `_check_*` 模式。三路徑委派後 `erase_team` 為唯一 `teams.erase` 點（除其內部）。
