# Faction 雙向單一入口（faction_id ↔ member_team_ids 根治）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 加 `WorldState.set_team_faction(team, fid)` / `clear_team_faction(team)` 單一入口（一處同維護 `team.faction_id` 兩側 + `faction.member_team_ids`），所有散落的 faction 歸屬變動改走入口，根治 `faction 反向破` drift（現 multi sanity ~1431 取樣）。

**Architecture:** 同 anon cohort 的「單一入口 + audit 網」哲學（master invariant spec 規則 3）。`_check_faction_bidir`（InvariantAudit）已是現成審計網。主 bug = `subteam_system.gd:27` 子隊繼承 parent faction_id 卻不加 member_team_ids；順帶把所有 join/leave/subjugate/merge/defect 變動點收斂入口，未來新增 faction 變動點不可能再漏。

**Tech Stack:** Godot 4.2.2 GDScript。閘 = `headless_test.gd`（`=== DONE ===`）+ `game_sim_multi.gd`（`faction 反向破`/`faction 雙向破`/`faction 懸空` → 0；coin_eq=0、population drift=0 維持）。

**前置（強制，依 `docs/process/03_implementer.md`）：**
```powershell
git worktree add .worktrees/faction-bidir -b feat/faction-bidir
cd .worktrees/faction-bidir
```

**Baseline 量測：** 跑 `game_sim_multi.gd`，記各 config `[InvariantSummary]` 的 `faction 反向破` 量（當對照，目標→0）。`headless_test.gd` 須 `=== DONE ===`。

> **⚠ 原子性**：入口加好後逐站遷移；中途部分遷移行為仍正確（入口與舊散寫等效），但 drift 要全遷移完才歸 0。Task 末驗。

---

## File Structure

| 檔案 | 動作 |
|---|---|
| `scripts/data/world_state.gd` | Modify | 加 `set_team_faction` / `clear_team_faction`（接在 `disband_faction` 後） |
| `scripts/simulation/subteam_system.gd:27` | Modify | **主 bug**：子隊 faction 繼承走入口 |
| `scripts/simulation/{game_setup,faction_ai,npc_combat,diplomatic_ai,interaction}_system.gd` + `events/event_faction_defect.gd` + `player_command_system.gd` | Modify | join/leave/subjugate/merge/defect 變動改走入口 |
| `scripts/debug/headless_test.gd` | Modify | 加 `_test_set_team_faction`（雙向 + 換 faction 自動退舊） |

> **不轉換**：brand-new team 建立時的 `faction_id = -1` 純初始化（`reaction:323` / `population:59` / `beast:28` / `event_unrest_split:67`）—— 新隊無 faction 成員關係，預設即 -1，非轉移，留原樣。

---

## Task 1: WorldState 雙向入口

**Files:** Modify `scripts/data/world_state.gd`（接在 `disband_faction` 後，約 :87）

- [ ] **Step 1: 加入口**

```gdscript
# 雙向單一入口：team.faction_id ↔ faction.member_team_ids 一處同維護（規則3）。
# 換 faction 自動退舊團、入新團；idempotent。
func set_team_faction(team: TeamData, fid: int) -> void:
	if team.faction_id == fid:
		return
	if team.faction_id != -1 and factions.has(team.faction_id):
		factions[team.faction_id].member_team_ids.erase(team.team_id)
	team.faction_id = fid
	if fid != -1 and factions.has(fid):
		if not factions[fid].member_team_ids.has(team.team_id):
			factions[fid].member_team_ids.append(team.team_id)

func clear_team_faction(team: TeamData) -> void:
	set_team_faction(team, -1)
```
> 若 `fid` 指向不存在的 faction → 只設 `faction_id`（無 member 可加）；屬 caller 傳錯，audit 的「faction 不存在」會抓。

- [ ] **Step 2: 跑 headless**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 3: Commit**

```bash
git add scripts/data/world_state.gd
git commit -m "feat(faction): WorldState set_team_faction/clear_team_faction 雙向入口"
```

---

## Task 2: 入口單元測試

**Files:** Modify `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加測試 + 註冊**

```gdscript
func _test_set_team_faction() -> void:
	var st := WorldState.new()
	var t := TeamData.new(); t.team_id = 1; st.teams[1] = t
	var fa := FactionData.new(); fa.faction_id = 10; st.factions[10] = fa
	var fb := FactionData.new(); fb.faction_id = 20; st.factions[20] = fb
	# 入 fa：兩側同步
	st.set_team_faction(t, 10)
	assert(t.faction_id == 10 and fa.member_team_ids.has(1), "入 fa 兩側同步")
	# 換 fb：自動退 fa、入 fb
	st.set_team_faction(t, 20)
	assert(t.faction_id == 20 and not fa.member_team_ids.has(1) and fb.member_team_ids.has(1), "換 fb 退舊入新")
	# 清空：退 fb
	st.clear_team_faction(t)
	assert(t.faction_id == -1 and not fb.member_team_ids.has(1), "清空退 fb")
	# idempotent：重複入不重複 append
	st.set_team_faction(t, 20); st.set_team_faction(t, 20)
	assert(fb.member_team_ids.count(1) == 1, "重複入不重複 append")
	print("[OK] _test_set_team_faction")
```
註冊於 `_initialize()`：
```gdscript
	_test_set_team_faction()
```

- [ ] **Step 2: 跑 headless**

Expected: `[OK] _test_set_team_faction`、`=== DONE ===`。

- [ ] **Step 3: Commit**

```bash
git add scripts/debug/headless_test.gd
git commit -m "test: set_team_faction 雙向入口單元測試"
```

---

## Task 3: 主 bug — subteam dispatch 走入口

**Files:** Modify `scripts/simulation/subteam_system.gd`（dispatch，:27 + state 取得）

- [ ] **Step 1: 子隊 faction 繼承走入口**

dispatch 原 `sub.faction_id = parent.faction_id`（:27）只設單側 → 子隊不在 member_team_ids（1431 大宗）。`sub` 此時尚未入 `state.teams`（:63 才入）→ set_team_faction 的 `member_team_ids.append` 不依賴 sub 在 teams，可直接呼叫；但需先把 sub 放入 state 或在入 state 後再設 faction。

把 :27 的 `sub.faction_id = parent.faction_id` **移除**，改在 `state.teams[sub.team_id] = sub`（:63）**之後**加：
```gdscript
	state.set_team_faction(sub, parent.faction_id)
```
> 此時 sub 已在 `state.teams` + sub.team_id 正確 → 入口正確把 sub 加入 parent 的 faction.member_team_ids。dispatch 函數已持有 `state` 參數。

- [ ] **Step 2: 驗 subteam 場景**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `=== DONE ===`，無 `SCRIPT ERROR`，subteam 相關測試綠。

- [ ] **Step 3: Commit**

```bash
git add scripts/simulation/subteam_system.gd
git commit -m "fix(faction): subteam dispatch 子隊 faction 繼承走 set_team_faction（修 member_team_ids 漏）"
```

---

## Task 4: join/leave/subjugate/merge/defect 變動走入口

各站把「`team.faction_id = X`（+ 相鄰 member_team_ids append/erase）」改成單一 `state.set_team_faction(team, X)` / `state.clear_team_faction(team)`，刪除原本手動的 member_team_ids 維護行。

- [ ] **Step 1: 逐站遷移**

- `scripts/simulation/npc_combat_system.gd:502-503`（subjugate 敗方入勝方 faction）：
  ```gdscript
  state.set_team_faction(loser, fid)   # 取代 member_team_ids.append + loser.faction_id = fid
  ```
  （刪原 :502 append、:503 賦值。確認該函數有 `state`。）
- `scripts/simulation/interaction_system.gd:380-382` 與 `:944-951`（join faction）：改 `state.set_team_faction(target, fid)` / `state.set_team_faction(t, faction_id)`，刪相鄰手動 append。
- `scripts/simulation/event_faction_defect.gd:21-25`（defect 離團）：改 `state.clear_team_faction(team)`，刪 :24 erase（:26 的 `member_team_ids.size() <= 1` 解散判斷保留，但在 clear 之後讀）。
- `scripts/simulation/diplomatic_ai_system.gd:150-159`（合併入 faction，兩段 a/b）：各改 `state.set_team_faction(team_b, team_a.faction_id)` / `state.set_team_faction(team_a, team_b.faction_id)`，刪相鄰 append；`:200-201`（離團）改 `state.clear_team_faction(self_team)`，刪 :200 erase。
- `scripts/simulation/faction_ai_system.gd:2397/2403/2463/2465/2468`（faction 重指派/離散）：`team.faction_id = X` → `state.set_team_faction(team, X)`（X 為 -1 時即 clear）。**先讀各處上下文**確認無相鄰 member 維護被遺漏（有則一併刪）。`_on_team_extinct:1342` 的 `f.member_team_ids.erase` 屬滅團清理（team 即將 erase，faction_id 不再 set）→ 可保留或改 `clear_team_faction`；**保留**（滅團路徑，team 不再存活，無雙向意義）。
- `scripts/simulation/player_command_system.gd:599-600` 與 `:620-621`（玩家離開 faction）：改 `state.clear_team_faction(pt)`，刪相鄰 erase。
- `scripts/simulation/game_setup.gd:154-155 / 246-250 / 258-259 / 428-430`（setup 入 faction，已成對）：改 `state.set_team_faction(state.teams[tid], fid)`，刪相鄰手動 append。**確認 faction 已建立**（:411 註解「先 create factions」→ 順序 OK；若某路徑先設 faction 後建 faction，set_team_faction 會 append 不到 → 保持原順序，faction 先建）。`:449 team.faction_id = int(t_cfg.get("faction_id", -1))` 屬建隊初始（subteam config）→ 若該 faction 存在用 set_team_faction，否則純初始化保留（**讀上下文判斷**）。

> 通則：只改「轉移」語意的寫入（team 在 faction 間移動）。brand-new team 的 `faction_id = -1` 初始化不動。每站改完該函數須持有 `state`（多數已有；無則順參數鏈傳入或確認可取得）。

- [ ] **Step 2: 全 headless 回歸**

```powershell
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`、無 `SCRIPT ERROR`、faction/diplomacy/subjugate 相關測試全綠。

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "refactor(faction): join/leave/subjugate/merge/defect 變動走 set_team_faction 入口"
```

---

## Task 5: drift 歸零驗證 + 殘留追蹤

- [ ] **Step 1: multi sanity**

```powershell
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd
```
Expected: `[InvariantSummary]` 的 `faction 反向破` / `faction 雙向破` / `faction 懸空` → **0**（4 config）。`coin_eq delta=0`、`population drift=0` 維持、無 `SCRIPT ERROR`。

- [ ] **Step 2: 追殘留（若 faction 違反 > 0）**

殘留 = 漏遷某轉移點，或某處仍直接 `faction_id =` 未走入口。grep `\.faction_id\s*=` 在 `scripts/simulation`（排除 `== -1` 比較與 brand-new init），核對是否該走入口。補遷直到 0。

- [ ] **Step 3: Commit（若有殘留修正）**

```bash
git add -A
git commit -m "fix(faction): 補殘留 faction 雙向 drift 點"
```

---

## Task 6: hand-back

- [ ] **Step 1: hand-back** `docs/superpowers/handbacks/2026-06-17-faction-bidir-single-entry.md`：
- 實作摘要：入口 + 各遷移點（每檔一行）。
- 驗證：baseline vs 修後 faction 違反數（→0）；headless 綠；coin_eq=0、population drift=0 維持。
- 連動風險：滅團路徑 `_on_team_extinct` member erase 保留（team 不再存活）；brand-new team init `=-1` 未動（非轉移）。
- 與 spec：實作 master invariant spec 規則 3（faction 雙向單一入口），audit 網 `_check_faction_bidir` 已存。

- [ ] **Step 2: Commit + push + 回報**

```bash
git add docs/superpowers/handbacks/2026-06-17-faction-bidir-single-entry.md
git commit -m "docs: faction 雙向單一入口 hand-back"
git push -u origin feat/faction-bidir
```
回報分支（finishing 選 Option 3，主 session merge）。

---

## Self-Review

**Spec coverage：** 實作 master invariant spec（`2026-06-17-invariant-architecture-design.md`）規則 3 的 faction 雙向部分（`set_team_faction`/`clear_team_faction` + 散落改走入口）。subteam 部分另已有 audit；`_massacre_residents` 滅團走 `_on_team_extinct`（已存路由），本 plan 不重做。

**Placeholder scan：** 無 TBD。Task 4 多處附「先讀上下文判斷」是因 faction_ai/game_setup 各站語意需現場核對（轉移 vs 初始化），附明確判準（轉移走入口、init 不動），非 placeholder。

**Type consistency：** `set_team_faction(team: TeamData, fid: int)` / `clear_team_faction(team: TeamData)` 為 WorldState 方法，呼叫端持 `state`。`FactionData.member_team_ids` 為 Array。`_check_faction_bidir` 簽名不變。所有遷移點刪除手動 member 維護後，雙向唯一維護者 = 入口。
