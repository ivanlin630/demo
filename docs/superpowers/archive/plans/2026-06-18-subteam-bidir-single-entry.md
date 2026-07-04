# Subteam 雙向單一入口（parent_team_id ↔ subteam_ids 根治）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 加 `WorldState.set_subteam_parent(child, pid)` / `detach_subteam(child)` 單一入口（一處同維護 `child.parent_team_id` ↔ `parent.subteam_ids`），散落的母子關係變動走入口，並補「子隊滅團未從 parent.subteam_ids 移除」缺口，根治 `subteam 雙向破/懸空` drift（現 multi ~13 取樣）。完成 = master invariant spec 規則 3 全竣（faction ✅ + subteam）。

**Architecture:** 同 faction 雙向（剛完成）的模式。`_check_subteam_bidir`（InvariantAudit）已是現成審計網。主缺口 = 子隊經**滅團路徑**（`cleanup_extinct_teams`）erase 時只清 faction member、不清 parent.subteam_ids → 懸空。

**Tech Stack:** Godot 4.2.2 GDScript。閘 = `headless_test.gd`（`=== DONE ===`）+ `game_sim_multi.gd`（`subteam 雙向破`/`subteam 懸空` → 0；coin_eq=0、population/faction drift=0 維持）。

**前置（強制，依 `docs/process/03_implementer.md`）：**
```powershell
git worktree add .worktrees/subteam-bidir -b feat/subteam-bidir
cd .worktrees/subteam-bidir
```

**Baseline：** 跑 `game_sim_multi.gd` 記各 config `subteam` 違反量（目標→0）。`headless_test.gd` 須 `=== DONE ===`。

---

## File Structure

| 檔案 | 動作 |
|---|---|
| `scripts/data/world_state.gd` | Modify | 加 `set_subteam_parent` / `detach_subteam`（接在 `set_team_faction` 後） |
| `scripts/simulation/faction_ai_system.gd` | Modify | **主缺口**：`cleanup_extinct_teams` erase 子隊前 detach（清 parent.subteam_ids） |
| `scripts/simulation/subteam_system.gd` | Modify | dispatch / merge 母子變動走入口 |
| `scripts/simulation/{outpost,interaction}_system.gd` | Modify | 散落 detach 走入口 |
| `scripts/debug/headless_test.gd` | Modify | 加 `_test_set_subteam_parent` |

> **不轉換**：純讀（`parent_team_id == X` 比較）不動。

---

## Task 1: WorldState 雙向入口

**Files:** Modify `scripts/data/world_state.gd`（接在 `clear_team_faction` 後）

- [ ] **Step 1: 加入口**

```gdscript
# 雙向單一入口：child.parent_team_id ↔ parent.subteam_ids 一處同維護（規則3）。
# 換 parent 自動退舊母、入新母；idempotent。
func set_subteam_parent(child: TeamData, parent_id: int) -> void:
	if child.parent_team_id == parent_id:
		return
	if child.parent_team_id != -1 and teams.has(child.parent_team_id):
		teams[child.parent_team_id].subteam_ids.erase(child.team_id)
	child.parent_team_id = parent_id
	if parent_id != -1 and teams.has(parent_id):
		if not teams[parent_id].subteam_ids.has(child.team_id):
			teams[parent_id].subteam_ids.append(child.team_id)

func detach_subteam(child: TeamData) -> void:
	set_subteam_parent(child, -1)
```

- [ ] **Step 2: 跑 headless**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 3: Commit**

```bash
git add scripts/data/world_state.gd
git commit -m "feat(subteam): WorldState set_subteam_parent/detach_subteam 雙向入口"
```

---

## Task 2: 入口單元測試

**Files:** Modify `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加測試 + 註冊**

```gdscript
func _test_set_subteam_parent() -> void:
	var st := WorldState.new()
	var pa := TeamData.new(); pa.team_id = 1; st.teams[1] = pa
	var pb := TeamData.new(); pb.team_id = 2; st.teams[2] = pb
	var c := TeamData.new(); c.team_id = 3; st.teams[3] = c
	st.set_subteam_parent(c, 1)
	assert(c.parent_team_id == 1 and pa.subteam_ids.has(3), "入 pa 兩側同步")
	st.set_subteam_parent(c, 2)
	assert(c.parent_team_id == 2 and not pa.subteam_ids.has(3) and pb.subteam_ids.has(3), "換 pb 退舊入新")
	st.detach_subteam(c)
	assert(c.parent_team_id == -1 and not pb.subteam_ids.has(3), "detach 退 pb")
	st.set_subteam_parent(c, 2); st.set_subteam_parent(c, 2)
	assert(pb.subteam_ids.count(3) == 1, "重複入不重複 append")
	print("[OK] _test_set_subteam_parent")
```
註冊於 `_initialize()`：
```gdscript
	_test_set_subteam_parent()
```

- [ ] **Step 2: 跑 headless**

Expected: `[OK] _test_set_subteam_parent`、`=== DONE ===`。

- [ ] **Step 3: Commit**

```bash
git add scripts/debug/headless_test.gd
git commit -m "test: set_subteam_parent 雙向入口單元測試"
```

---

## Task 3: 主缺口 — 子隊滅團 detach

**Files:** Modify `scripts/simulation/faction_ai_system.gd`（`cleanup_extinct_teams`，約 :1349-1359）

子隊經滅團路徑 erase 時，`cleanup_extinct_teams` 只 `_route_extinct_assets` + `teams.erase`，**不清 parent.subteam_ids** → 母團殘留懸空子隊 id（`subteam 懸空` 大宗）。

- [ ] **Step 1: erase 前 detach**

在 `cleanup_extinct_teams` 的 `state.teams.erase(tid)` **之前**加：
```gdscript
		if team.parent_team_id != -1:
			state.detach_subteam(team)   # 子隊滅團 → 從 parent.subteam_ids 移除（消懸空）
```
> 放在 `_route_extinct_assets(state, team)` 之後、`state.teams.erase(tid)` 之前。此時 team 仍在 `state.teams`，detach 正確清 parent 側。

- [ ] **Step 2: 驗 headless**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 3: Commit**

```bash
git add scripts/simulation/faction_ai_system.gd
git commit -m "fix(subteam): 子隊滅團前 detach（消 parent.subteam_ids 懸空）"
```

---

## Task 4: 散落母子變動走入口

各站把「`child.parent_team_id = X`（+ 相鄰 subteam_ids append/erase）」改成單一 `state.set_subteam_parent(child, X)` / `state.detach_subteam(child)`，刪手動 subteam_ids 維護。

- [ ] **Step 1: 逐站遷移**

- `scripts/simulation/subteam_system.gd`：
  - dispatch（:27 `sub.parent_team_id = parent_id` + :63 `parent.subteam_ids.append`）：刪這兩行，在 `state.teams[sub.team_id] = sub`（:64 區）**之後**加 `state.set_subteam_parent(sub, parent_id)`（sub 已入 teams → 入口正確）。
  - `merge_teams`（:172 erase + :177 `parent_team_id = absorber_id` + :182 append）：改 `state.set_subteam_parent(absorbed, absorber_id)`，刪相鄰 erase/append。
  - `_merge_into`（:199-202 capacity 滿回歸失敗：:200 `parent_team_id=-1` + :202 erase）→ `state.detach_subteam(absorbed)`，刪 erase。
  - `_merge_into` 完全合併路徑（:230 `absorber.subteam_ids.erase`，後接 `_erase_absorbed_team`）：此為 erase 前清母關係 → 改 `state.detach_subteam(absorbed)`（在 _erase 前）或確認 `_erase_absorbed_team` 後 audit 不破。**讀 :219-234 上下文**：若 absorbed 即將 _erase_absorbed_team，detach 一次即可，刪重複 erase。
  > merge 多分支，**逐一讀 :115-234 上下文**對齊（哪些是 reparent 哪些是 detach），通則：reparent→set_subteam_parent、脫離/滅團前→detach。
- `scripts/simulation/outpost_system.gd:315-316`（`parent.subteam_ids.erase` + `team.parent_team_id = -1`）→ `state.detach_subteam(team)`，刪兩行。
- `scripts/simulation/faction_ai_system.gd:845-846`（`parent.subteam_ids.erase` + `sub.parent_team_id = -1`）→ `state.detach_subteam(sub)`，刪兩行（確認該函數有 `state`）。
- `scripts/simulation/interaction_system.gd:969`（`subteam.parent_team_id = -1` 單側，疑未配對）→ `state.detach_subteam(subteam)`（確認 `state` 可取得；若無 state 參數則順鏈傳入或在 caller 處理）。

> 通則：reparent（換母）→ `set_subteam_parent`；脫離為獨立團 → `detach_subteam`。每站改完該函數須持 `state`。

- [ ] **Step 2: 全 headless 回歸**

```powershell
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`、無 `SCRIPT ERROR`、subteam/merge/dispatch 相關測試全綠。

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "refactor(subteam): 母子關係變動走 set_subteam_parent/detach_subteam 入口"
```

---

## Task 5: drift 歸零驗證 + 殘留追蹤

- [ ] **Step 1: multi sanity**

```powershell
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd
```
Expected: `subteam 雙向破` / `subteam 懸空` → **0**（4 config）。`coin_eq=0`、`population drift=0`、`faction 反向破=0` 維持、無 `SCRIPT ERROR`。

- [ ] **Step 2: 追殘留（若 subteam 違反 > 0）**

grep `parent_team_id\s*=` / `subteam_ids\.(append|erase)` 在 `scripts/simulation`，核對是否仍有未走入口的轉移/脫離點，補遷直到 0。

- [ ] **Step 3: Commit（若有殘留修正）**

```bash
git add -A
git commit -m "fix(subteam): 補殘留 subteam 雙向 drift 點"
```

---

## Task 6: hand-back

- [ ] **Step 1: hand-back** `docs/superpowers/handbacks/2026-06-18-subteam-bidir-single-entry.md`：
- 實作摘要：入口 + 滅團 detach + 各遷移點（每檔一行）。
- 驗證：baseline vs 修後 subteam 違反數（→0）；headless 綠；coin_eq=0、population/faction drift=0 維持。
- 與 spec：完成 master invariant spec 規則 3（subteam 雙向），audit `_check_subteam_bidir` 已存。**規則 3 全竣（faction+subteam）→ 整個「散落不變量」債類根除。**

- [ ] **Step 2: Commit + push + 回報**

```bash
git add docs/superpowers/handbacks/2026-06-18-subteam-bidir-single-entry.md
git commit -m "docs: subteam 雙向單一入口 hand-back"
git push -u origin feat/subteam-bidir
```
回報分支（finishing 選 Option 3，主 session merge）。

---

## Self-Review

**Spec coverage：** 實作 master invariant spec 規則 3 的 subteam 雙向部分（`set_subteam_parent`/`detach_subteam` + 散落改走入口 + 滅團 detach 缺口）。與剛完成的 faction 雙向同模式，完成後規則 3 全竣。

**Placeholder scan：** 無 TBD。Task 4 merge 多分支附「逐一讀上下文、reparent vs detach 通則」判準，非 placeholder。

**Type consistency：** `set_subteam_parent(child: TeamData, parent_id: int)` / `detach_subteam(child: TeamData)` 為 WorldState 方法（對齊 `set_team_faction` 模式），呼叫端持 `state`。`TeamData.subteam_ids` 為 Array。`_check_subteam_bidir` 簽名不變。
