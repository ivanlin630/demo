# B4 成員管理（調薪/武裝anon/成員裝備）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 補玩家「管理自隊」的 3 個缺口指令 + UI：調名成員薪資（S9）、設匿名武裝比例（U18，玩家找不到武裝 anon）、裝備/卸下名成員（U13b，目前只能裝玩家）。

**Architecture:** sim 側補 3 指令於 `player_command_system`（set_member_salary / set_armed_anon_ratio / equip_member·unequip_member），改寫既有可寫欄位（person.salary / team.armed_anon_ratio / member equipment）。UI 側接到 member 模式 + status。各指令 headless TDD，UI 接線配 ui_flow harness。

**Tech Stack:** Godot 4.2.2 GDScript；headless + ui_flow/ui_logic；`.\tools\godot.ps1`。

依據：known_issues S9(調薪)/U18(武裝anon)/U13b(成員裝備)；spec textui-overhaul §4 命令缺口。

---

## 檔案結構

- `scripts/simulation/player_command_system.gd`（改）：registry + `_action_set_member_salary` / `_action_set_armed_ratio` / `_action_equip_member` / `_action_unequip_member`（member-target 走 `execute_action_with_target`）。
- `scripts/simulation/player_command_api.gd`（讀）：member-target dispatch（kind:"member" 已存在，line 60-67）。
- `scripts/ui/text_ui_main.gd`（改）：member 模式裝備 submode 加 equip/unequip 鍵 + 調薪輸入；status/指令設武裝比例。
- `scripts/debug/headless_test.gd` / `ui_flow_test.gd`（改）：測試。

可用：`person.salary`(float 可寫)、`team.armed_anon_ratio`(float 可寫)、member-target dispatch（command_api kind:"member" 讀 member_id）、`execute_action_with_target`（cmd_sys 既有，member 動作用）。

---

## Task 1: set_member_salary 指令

**Files:**
- Modify: `scripts/simulation/player_command_system.gd`
- Test: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_set_member_salary() -> void:
	print("--- set_member_salary ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var leader := PersonData.new(); leader.id = 0; leader.team_id = 0
	var m := PersonData.new(); m.id = 1; m.team_id = 0; m.salary = 5.0
	state.persons[0] = leader; state.persons[1] = m; state.player_id = 0
	var team := TeamData.new(); team.team_id = 0; team.leader_id = 0; team.named_members = [1]
	state.teams[0] = team
	var cmd := PlayerCommandSystem.new()
	state.player_state["salary_input"] = 12.0
	var r: Dictionary = cmd.execute_action_with_target(state, "set_member_salary",
		{"kind":"member","team_id":0,"member_id":1})
	assert(r.get("ok", false), "set_member_salary 應成功，msg=%s" % str(r.get("msg","")))
	assert(abs(state.persons[1].salary - 12.0) < 0.01, "成員薪資應=12，實際=%s" % str(state.persons[1].salary))
	print("set_member_salary OK")
```

- [ ] **Step 2: 跑確認失敗** — `未知行動` / 缺 handler。

- [ ] **Step 3: 實作**

`_setup_registry` 加 `"set_member_salary": _action_set_member_salary,`。
（member-target 動作經 `execute_action_with_target` 分派，讀 member_id；確認該函數對 registry callable 的呼叫簽名 — 讀現行 `execute_action_with_target`，比照既有 member 動作如 `order_faction_member`/`clear_member_order` 對齊參數。）
```gdscript
func _action_set_member_salary(state: WorldState, target: Dictionary, pt: TeamData, _pt_id: int) -> Dictionary:
	var mid: int = int(target.get("member_id", -1))
	var m: PersonData = state.persons.get(mid)
	if m == null or not pt.named_members.has(mid):
		return { "ok": false, "msg": "非自隊成員" }
	var amt: float = float(state.player_state.get("salary_input", m.salary))
	m.salary = maxf(amt, 0.0)
	return { "ok": true, "msg": "%s 薪資設為 %.0f" % [m.person_name, m.salary] }
```
（簽名依 `execute_action_with_target` 真實對 member 動作的傳參調整：可能傳 target dict 或 member_id。實作者讀對齊既有 member-target 動作。）

- [ ] **Step 4: 跑確認通過** — `set_member_salary OK`
- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/player_command_system.gd scripts/debug/headless_test.gd
git commit -m "feat: set_member_salary 指令（S9 玩家調名成員薪資）"
```

---

## Task 2: set_armed_anon_ratio 指令

**Files:**
- Modify: `scripts/simulation/player_command_system.gd`
- Test: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_set_armed_ratio() -> void:
	print("--- set_armed_anon_ratio ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var leader := PersonData.new(); leader.id = 0; leader.team_id = 0
	state.persons[0] = leader; state.player_id = 0
	var team := TeamData.new(); team.team_id = 0; team.leader_id = 0; team.armed_anon_ratio = 0.0
	state.teams[0] = team
	var cmd := PlayerCommandSystem.new()
	state.player_state["armed_ratio_input"] = 0.7
	var r: Dictionary = cmd.execute_action(state, -1, "set_armed_anon_ratio")
	assert(r.get("ok", false), "應成功")
	assert(abs(team.armed_anon_ratio - 0.7) < 0.01, "ratio=0.7，實際=%s" % str(team.armed_anon_ratio))
	# 越界夾住
	state.player_state["armed_ratio_input"] = 1.5
	cmd.execute_action(state, -1, "set_armed_anon_ratio")
	assert(team.armed_anon_ratio <= 1.0, "夾在 1.0")
	print("set_armed_ratio OK")
```

- [ ] **Step 2: 跑確認失敗**

- [ ] **Step 3: 實作**

registry 加 `"set_armed_anon_ratio": _action_set_armed_ratio,`（self/none-target，簽名比照 `_action_set_tribute_rate`）：
```gdscript
func _action_set_armed_ratio(state: WorldState, _target: int, pt: TeamData, _pt_id: int) -> Dictionary:
	var r: float = clampf(float(state.player_state.get("armed_ratio_input", pt.armed_anon_ratio)), 0.0, 1.0)
	pt.armed_anon_ratio = r
	return { "ok": true, "msg": "武裝比例設為 %.0f%%" % (r * 100.0) }
```

- [ ] **Step 4: 跑確認通過** — `set_armed_ratio OK`
- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/player_command_system.gd scripts/debug/headless_test.gd
git commit -m "feat: set_armed_anon_ratio 指令（U18 玩家設匿名武裝比例）"
```

---

## Task 3: equip_member / unequip_member 指令

**Files:**
- Modify: `scripts/simulation/player_command_system.gd`（+ 借 `player_system` 裝備邏輯模式）
- Test: `scripts/debug/headless_test.gd`

**根因**：`player_system.equip_item` 只裝玩家 leader，無 member 變體。

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_equip_member() -> void:
	print("--- equip_member ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var leader := PersonData.new(); leader.id = 0; leader.team_id = 0
	var m := PersonData.new(); m.id = 1; m.team_id = 0
	state.persons[0] = leader; state.persons[1] = m; state.player_id = 0
	var team := TeamData.new(); team.team_id = 0; team.leader_id = 0; team.named_members = [1]
	team.resources = {"weapon_melee_low": 1}
	state.teams[0] = team
	var cmd := PlayerCommandSystem.new()
	var r: Dictionary = cmd.execute_action_with_target(state, "equip_member",
		{"kind":"member","team_id":0,"member_id":1,"slot_id":"hand_1","item_grade":"weapon_melee_low"})
	assert(r.get("ok", false), "equip_member 應成功，msg=%s" % str(r.get("msg","")))
	assert(state.persons[1].equipment["hand_1"].get("grade","") == "weapon_melee_low", "成員手1 應裝武器")
	assert(int(team.resources.get("weapon_melee_low",0)) == 0, "武器從 team 池扣 1")
	# unequip 還回
	cmd.execute_action_with_target(state, "unequip_member",
		{"kind":"member","team_id":0,"member_id":1,"slot_id":"hand_1"})
	assert(int(team.resources.get("weapon_melee_low",0)) == 1, "卸下還回 team 池")
	print("equip_member OK")
```

- [ ] **Step 2: 跑確認失敗**

- [ ] **Step 3: 實作**

registry 加 `"equip_member"` / `"unequip_member"`。實作（從 team 武器池裝/卸名成員 slot，扣/還資源；參照 `player_system.equip_item` 對玩家的邏輯，改 target = member）：
```gdscript
func _action_equip_member(state, target: Dictionary, pt: TeamData, _pt_id: int) -> Dictionary:
	var mid: int = int(target.get("member_id", -1))
	var slot: String = String(target.get("slot_id", ""))
	var grade: String = String(target.get("item_grade", ""))
	var m: PersonData = state.persons.get(mid)
	if m == null or not pt.named_members.has(mid): return {"ok": false, "msg": "非自隊成員"}
	if slot == "" or grade == "" or int(pt.resources.get(grade, 0)) <= 0: return {"ok": false, "msg": "無此裝備"}
	# 先卸原槽（還回池）
	var cur: Dictionary = m.equipment.get(slot, {})
	if cur.get("type","none") == "pool" and cur.get("grade","") != "":
		pt.resources[cur["grade"]] = int(pt.resources.get(cur["grade"],0)) + 1
	pt.resources[grade] = int(pt.resources[grade]) - 1
	m.equipment[slot] = {"type":"pool","grade":grade}
	return {"ok": true, "msg": "%s 裝備 %s" % [m.person_name, grade]}

func _action_unequip_member(state, target: Dictionary, pt: TeamData, _pt_id: int) -> Dictionary:
	var mid: int = int(target.get("member_id", -1))
	var slot: String = String(target.get("slot_id", ""))
	var m: PersonData = state.persons.get(mid)
	if m == null or not pt.named_members.has(mid): return {"ok": false, "msg": "非自隊成員"}
	var cur: Dictionary = m.equipment.get(slot, {})
	if cur.get("type","none") == "pool" and cur.get("grade","") != "":
		pt.resources[cur["grade"]] = int(pt.resources.get(cur["grade"],0)) + 1
	m.equipment[slot] = {"type":"none","grade":""}
	return {"ok": true, "msg": "%s 卸下 %s" % [m.person_name, slot]}
```
（確認 `execute_action_with_target` 把 target dict（含 slot_id/item_grade）傳入 handler；若它只傳 member_id，需從 player_state 取 slot/grade — 讀現行 `execute_action_with_target` 對齊參數傳遞。）

- [ ] **Step 4: 跑確認通過** — `equip_member OK`
- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/player_command_system.gd scripts/debug/headless_test.gd
git commit -m "feat: equip_member/unequip_member 指令（U13b 裝備名成員）"
```

---

## Task 4: member 模式 UI — 裝備 + 調薪

**Files:**
- Modify: `scripts/ui/text_ui_main.gd`（`_handle_member_mode` equipment submode + salary 輸入）
- Test: `scripts/debug/ui_flow_test.gd`

- [ ] **Step 1: 接線**

讀 `_handle_member_mode`（line ~702）+ submode 2（equipment）。加：
- equipment submode：列當前成員各 slot + team 可裝武器；`[E]` 裝（進選武器子流程或裝第一個可用）、`[U]` 卸 → 呼 `_bridge.command_player("execute_action", {action_id, target:{kind:"member", team_id, member_id, slot_id, item_grade}})` → `_set_feedback`。
- 調薪：member 任一 submode `[$]` 或 `[Y]` → 進數字輸入模式（既有 `_input_mode`）收 amount → `player_state.salary_input` → `set_member_salary`。
- member keymap 提示補對應鍵。

（依現行 _handle_member_mode 結構對齊；用既有 `_input_mode` 收數字。）

- [ ] **Step 2: flow 測試**

```gdscript
func _test_member_equip_flow() -> void:
	print("\n── 成員裝備 flow ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var ptid: int = st.persons[st.player_id].team_id
	# 確保自隊有 named 成員 + 武器池
	# （default state 玩家隊可能無 named；注入一個）
	var m := PersonData.new(); m.id = 99001; m.team_id = ptid
	st.persons[99001] = m; st.teams[ptid].named_members.append(99001)
	st.teams[ptid].resources["weapon_melee_low"] = 2
	node._member_mode = true; node._member_detail_submode = 2; node._member_selection = 0
	node._refresh()
	# 驅動裝備鍵（依實作鍵）→ 斷言成員裝上 / feedback
	# （實作者依實際鍵 + 選取對齊；最小斷言：呼叫 equip_member 後 member equipment 有 grade）
	var r = node._bridge.command_player("execute_action",
		{"action_id":"equip_member","target":{"kind":"member","team_id":ptid,"member_id":99001,"slot_id":"hand_1","item_grade":"weapon_melee_low"}})
	_check("equip_member 經 bridge 成功", r.get("ok", false))
	_check("成員裝上武器", st.persons[99001].equipment["hand_1"].get("grade","") == "weapon_melee_low")
	await _free_ui(node)
```

- [ ] **Step 3: 跑 + Commit**

```bash
git add scripts/ui/text_ui_main.gd scripts/debug/ui_flow_test.gd
git commit -m "feat(ui): member 模式裝備/卸下 + 調薪入口"
```

---

## Task 5: 武裝比例 UI + status 顯示

**Files:**
- Modify: `scripts/ui/text_ui_main.gd`
- Test: `scripts/debug/ui_flow_test.gd`

- [ ] **Step 1: 接線**

status 區（B3 已顯武裝數）旁顯武裝比例 `armed_anon_ratio`（DTO 補 `armed_ratio` 至 controlled_team，或讀既有欄位）。主模式加 `[+]/[-]` 或指令調整 → `player_state.armed_ratio_input` → `set_armed_anon_ratio` → feedback。

- [ ] **Step 2: flow 測試**

```gdscript
func _test_armed_ratio_cmd() -> void:
	print("\n── 設武裝比例 ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	st.player_state["armed_ratio_input"] = 0.6
	var r = node._bridge.command_player("execute_action", {"action_id":"set_armed_anon_ratio","target":{"kind":"none"}})
	_check("set_armed_anon_ratio 成功", r.get("ok", false))
	var ptid: int = st.persons[st.player_id].team_id
	_check("ratio 設為 0.6", abs(st.teams[ptid].armed_anon_ratio - 0.6) < 0.01)
	await _free_ui(node)
```

- [ ] **Step 3: 跑 + Commit**

```bash
git add scripts/ui/text_ui_main.gd scripts/debug/ui_flow_test.gd
git commit -m "feat(ui): 武裝比例設定 + status 顯示"
```

---

## Task 6: 註冊 + 驗證 + handback

- [ ] **Step 1: 註冊** 新測試（headless 3 + ui_flow 2）。
- [ ] **Step 2: 全跑** — headless / ui_logic / ui_flow 無新增 SCRIPT ERROR、新測試綠。
- [ ] **Step 3: handback** — `docs/superpowers/handbacks/2026-06-15-b4-member-management.md`。member UI 鍵位真視覺標待人工 run-verify（指令/flow 已自動測）。

---

## 注意事項（給實作者）

- **先查 `execute_action_with_target` 對 member 動作的傳參**（target dict 全傳 vs 只 member_id）：member equip 需 slot_id/item_grade，若該函數不傳，改經 `player_state` 暫存（比照 tribute_rate_input/salary_input 模式）。讀現行對齊，勿臆造。
- **守恆**：member equip 從 team 武器池扣、卸下還回（不憑空生滅）；headless 測已驗扣/還。
- **harness 用起來**：指令 headless TDD、UI 接線配 ui_flow。真視覺（鍵位/版面）才人工。
- **UI 邊界**：text_ui 經 bridge command_player，勿直改 state。
- 交易介面 = 功能 spec、P3 = 全覆蓋，均不在本批。
- baseline Bug8 勿動。
