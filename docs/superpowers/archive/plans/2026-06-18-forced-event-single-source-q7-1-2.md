# Forced-Event 單一真值源 + Q7-1/Q7-2 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** forced-event response id 統一由 `get_forced_response_options` 算（精確動態），mapper 從它導 label、respond 照它派 handler；補 `choose_heir`（修 Q7-1 致命 softlock）+ `aid_request`（修 Q7-2）。

**Architecture:** 依 spec `2026-06-18-forced-event-single-source-design.md`。id 清單單一真值源 → 三聯不可 drift。mapper 迭代 options + `_forced_label(action,id,state,fe)`；choose_heir options=動態候選 pid、aid_request=`["give","refuse"]`。

**Tech Stack:** Godot 4.2.2 GDScript。閘 = `headless_test.gd` + `ui_flow_test.gd`（forced 模式驅動）+ `game_sim_multi.gd`（coin_eq=0、全 invariant 0）。

> **Q7 系列**：本 plan=Q7-1+Q7-2（同源）。Q7-3(take_loot 文字 UI)/Q7-4/Q7-5/Q7-6 後續。

**前置（強制，依 `docs/process/03_implementer.md`）：**
```powershell
git worktree add .worktrees/q7-forced -b feat/q7-forced
cd .worktrees/q7-forced
```

**Baseline：** `headless_test.gd` → `=== DONE ===`；`ui_flow_test.gd` 綠。

---

## 既有契約（研究確認，勿改）
- `_action_choose_heir`（player_command:961）：讀 `player_state["heir_id"]`(int) + 驗 `fe["candidates"]`(pid 陣列).has(heir_id) → 設 leader_id/player_id=heir_id、清 forced、erase heir_id。
- `_action_respond_aid_request`（:912）：讀 `player_state["aid_response"]={refuse:bool, give_amount:float}` → 守恆轉糧+reputation、清 forced、erase aid_response。
- 兩 handler **自清 forced_event**；`respond_to_forced` 末亦清（無害重複）。

---

## File Structure

| 檔案 | 動作 |
|---|---|
| `scripts/simulation/player_command_system.gd` | Modify | `get_forced_response_options`（精確動態 id 單一源 + choose_heir/aid_request）；`respond_to_forced` 補 choose_heir/aid_request 派發 |
| `scripts/simulation/player_api_mapper.gd` | Modify | `map_forced_interaction` 改迭代 options 導 responses + 新 `_forced_label`；補 choose_heir/aid_request msg |
| `scripts/debug/headless_test.gd` | Modify | `_test_forced_choose_heir` / `_test_forced_aid_request` / drift 防護測試 |
| `scripts/debug/ui_flow_test.gd` | Modify | forced 模式驅動 choose_heir/aid_request |

---

## Task 1: get_forced_response_options 成精確 id 單一源

**Files:** Modify `player_command_system.gd:834`

- [ ] **Step 1: 改成算精確動態 id（含 diplomacy 動態、choose_heir、aid_request）**

```gdscript
func get_forced_response_options(state: WorldState) -> Array[String]:
	var fe: Dictionary = state.player_forced_event
	var action: String = fe.get("action", "")
	match action:
		"diplomacy":
			# 動態：雙方獨立 + alliance/surrender → 加入/自立；否則 accept/refuse
			var from_team: TeamData = state.teams.get(fe.get("from_id", -1))
			var pp: PersonData = state.persons.get(state.player_id)
			var player_team: TeamData = state.teams.get(pp.team_id) if pp != null else null
			var both_independent: bool = from_team != null and player_team != null \
				and from_team.faction_id == -1 and player_team.faction_id == -1 \
				and fe.get("proposal", "") in ["alliance", "surrender"]
			if both_independent:
				return ["accept_join", "accept_lead", "refuse"] as Array[String]
			return ["accept", "refuse"] as Array[String]
		"extort":
			return ["pay", "refuse"] as Array[String]
		"join_request":
			return ["accept", "refuse"] as Array[String]
		"aid_request":
			return ["give", "refuse"] as Array[String]
		"choose_heir":
			var ids: Array[String] = []
			for pid in fe.get("candidates", []):
				ids.append("heir_%d" % int(pid))
			return ids
	return [] as Array[String]
```
> diplomacy 動態邏輯與 mapper 原 `both_independent` 一致（消既有 options/mapper superset drift）。choose_heir id 編碼 `"heir_<pid>"`。

- [ ] **Step 2: headless** Expected: `=== DONE ===`，無 SCRIPT ERROR（既有 diplomacy/extort/join forced 測試綠）。
- [ ] **Step 3: Commit** `git commit -am "refactor(forced): get_forced_response_options 算精確動態 id（單一源 + aid/heir）"`

---

## Task 2: respond_to_forced 補 choose_heir / aid_request 派發

**Files:** Modify `player_command_system.gd:849`（`respond_to_forced` match）

- [ ] **Step 1: 加兩分支**

在 `respond_to_forced` 的 `match fe.get("action","")` 加（既有 diplomacy/extort/join_request 不動）：
```gdscript
		"aid_request":
			if response == "give":
				state.player_state["aid_response"] = { "give_amount": AID_GIVE_DEFAULT }
			else:
				state.player_state["aid_response"] = { "refuse": true }
			result = _action_respond_aid_request(state, -1, _player_team(state), _player_team_id(state))
		"choose_heir":
			# response_id = "heir_<pid>"
			var hid: int = int(response.trim_prefix("heir_"))
			state.player_state["heir_id"] = hid
			result = _action_choose_heir(state, -1, _player_team(state), _player_team_id(state))
```
> `AID_GIVE_DEFAULT`：在 PlayerCommandSystem 加 const（合理一餐量,如 `const AID_GIVE_DEFAULT: float = 5.0   # TEST VALUE`,避免新增數值輸入 UI）。`_player_team(state)`/`_player_team_id(state)`：用既有取玩家隊 helper（**讀檔確認 helper 名**,如 `_get_player_team`/`_player_team_id`；無則 inline 取 `state.persons[state.player_id].team_id`）。兩 handler 自清 forced；`respond_to_forced` 末的清除保留（重複無害）。

- [ ] **Step 2: headless** Expected: `=== DONE ===`，無 SCRIPT ERROR。
- [ ] **Step 3: Commit** `git commit -am "feat(forced): respond_to_forced 補 choose_heir/aid_request 派發（修 Q7-1/Q7-2 resolve）"`

---

## Task 3: map_forced_interaction 從 options 導 responses + _forced_label

**Files:** Modify `player_api_mapper.gd:265`

- [ ] **Step 1: responses 改迭代 options + label**

把 `map_forced_interaction` 的 `match action` 內**硬編 responses 陣列**全移除,改：每 action 只算 `msg`（display 文案,保留 per-action）；`responses` 統一由 options 導：
```gdscript
	# msg：per-action 文案（保留既有各 action msg 計算，含新 choose_heir/aid_request）
	match action:
		"diplomacy":
			msg = "Team%d 要求你納貢" % from_id if proposal == "demand_tribute" else "Team%d 提議 %s" % [from_id, proposal]
		"extort":
			msg = "Team%d 勒索你" % from_id
		"join_request":
			var ft: TeamData = state.teams.get(from_id)
			msg = "Team%d 求投靠（%d 人）" % [from_id, ft.population if ft != null else 0]
		"aid_request":
			var ft2: TeamData = state.teams.get(from_id)
			msg = "Team%d 向你乞食（%d 人）" % [from_id, ft2.population if ft2 != null else 0]
		"choose_heir":
			msg = "領袖殞落,擇繼承人"
		_:
			msg = "Team%d 強制事件" % from_id
	# responses：單一源 = get_forced_response_options，每 id 配 label
	var pcs := PlayerCommandSystem.new()
	responses = []
	for rid in pcs.get_forced_response_options(state):
		responses.append({
			"response_id": rid,
			"label": _forced_label(action, rid, state, evt),
			"command_args": { "interaction_id": iid, "response_id": rid }
		})
```
> 確認 `PlayerCommandSystem` 可在 mapper 實例化（既有依賴方向；若 mapper 已 import PlayerCommandSystem const 則用,否則 `PlayerCommandSystem.new()`）。

- [ ] **Step 2: 加 _forced_label**

```gdscript
static func _forced_label(action: String, rid: String, state: WorldState, evt: Dictionary) -> String:
	match action:
		"diplomacy":
			match rid:
				"accept": return "✓ 接受"
				"accept_join": return "加入對方勢力（對方為主）"
				"accept_lead": return "自立後接納對方（我為主）"
				"refuse": return "✗ 拒絕"
		"extort":
			return "付錢" if rid == "pay" else "拒絕"
		"join_request":
			var ft: TeamData = state.teams.get(evt.get("from_id", -1))
			var n: int = ft.population if ft != null else 0
			if rid == "accept":
				return "收留（食物 -%.1f,+%d 人）" % [PlayerCommandSystem.JOIN_ONBOARD_MEAL * n, n]
			return "✗ 婉拒"
		"aid_request":
			return "施捨 %.0f 糧" % PlayerCommandSystem.AID_GIVE_DEFAULT if rid == "give" else "✗ 拒絕"
		"choose_heir":
			var pid: int = int(rid.trim_prefix("heir_"))
			var p: PersonData = state.persons.get(pid)
			return "立 %s 為繼承人" % (p.person_name if p != null else "P%d" % pid)
	return rid
```

- [ ] **Step 3: import 快取 + headless + ui_flow** Expected: `=== DONE ===`、ui_flow 綠、無 SCRIPT ERROR。
- [ ] **Step 4: Commit** `git commit -am "refactor(forced): mapper responses 從 options 導 + _forced_label（單一源,消三聯 drift）"`

---

## Task 4: 測試（端到端 + drift 防護）+ 回歸 + hand-back

**Files:** Modify `headless_test.gd`、`ui_flow_test.gd`

- [ ] **Step 1: headless 端到端 + drift 測試**

```gdscript
func _test_forced_choose_heir() -> void:
	# 注入 choose_heir forced + 2 候選 → options 回 heir_id → respond 選一 → leader 接位 + forced 清
	# （建 state：玩家隊 leader_id=-1、candidates=[兩 named pid]、player_forced_event={action:"choose_heir", candidates:[...]}）
	# assert get_forced_response_options 含 "heir_<pid>" ×2
	# assert respond_to_forced("heir_<pid>") → team.leader_id == pid、player_forced_event 空
	print("[OK] _test_forced_choose_heir")

func _test_forced_aid_request() -> void:
	# 注入 aid_request forced（beggar 有 leader）→ options ["give","refuse"]
	# respond "give" → 玩家 food 減、beggar food 增（守恆）、forced 清
	print("[OK] _test_forced_aid_request")

func _test_forced_options_label_no_drift() -> void:
	# 對 diplomacy(both_independent 兩種)/extort/join_request/aid_request/choose_heir：
	# get_forced_response_options 的 id 集合 == map_forced_interaction.responses 的 response_id 集合（逐 action 注入 fe 比對）
	print("[OK] _test_forced_options_label_no_drift")
```
> 實作填入具體 state 建構 + assert（參考既有 forced 測試 setup 模式）。註冊於 `_initialize()`。

- [ ] **Step 2: ui_flow forced 驅動**

`ui_flow_test.gd` 加：注入 choose_heir/aid_request forced → `_process` 進互動模式 → 斷言 DTO `responses` 列候選/give（**非只拒絕**）→ 驅動選擇 → state 變 + forced 清。

- [ ] **Step 3: 全回歸**

```powershell
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
.\tools\godot.ps1 --headless --script scripts/debug/ui_flow_test.gd
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd
```
Expected: 全 `=== DONE ===`、forced 測試綠、coin_eq=0、全 invariant 0、無 SCRIPT ERROR。

- [ ] **Step 4: hand-back** `docs/superpowers/handbacks/2026-06-18-forced-event-q7-1-2.md`（依 03 格式：三聯單一源化 + choose_heir/aid_request + 既有 diplomacy drift 順修；驗證；待主 session Q7-3~6）。

- [ ] **Step 5: Commit + push + 回報**

```bash
git add -A && git commit -m "docs: forced-event Q7-1/Q7-2 hand-back"
git push -u origin feat/q7-forced
```

---

## Self-Review

**Spec coverage：** 涵蓋 spec：id 單一源（get_forced_response_options 精確動態）+ mapper 導 label + choose_heir(Q7-1)+aid_request(Q7-2)+順修 diplomacy superset drift。UI data-driven 自動列（Task 2 ui_flow 驗）。

**Placeholder scan：** Task 4 測試體標「實作填入具體 state+assert」非 placeholder（附建構指引 + 參考既有模式 + 明確斷言目標）。Task 2 helper 名「讀檔確認」附 fallback。

**Type consistency：** `get_forced_response_options(state)->Array[String]` 簽名不變;新 `_forced_label(action,rid,state,evt)->String`;choose_heir id `"heir_<pid>"` 編解碼於 options/respond/label 三處一致;`AID_GIVE_DEFAULT` const 於 PlayerCommandSystem,label 引用。既有 `_action_choose_heir`/`_action_respond_aid_request` 契約不改。
