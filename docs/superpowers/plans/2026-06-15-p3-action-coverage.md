# P3 全動作覆蓋 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 補齊 6 個 registered + NPC 在用但玩家無 UI 路徑的孤兒動作（公庫存取、outpost 設施/棄置、faction 提幣、team-target 招匿名/邀定居），達成對稱性。

**Architecture:** 後端 6 action 全現成（本 plan 不改後端邏輯）。A 公庫=新 query DTO + 新 UI mode；B/C=既有 outpost/faction 面板 `actions[]` 加列 + handler 鍵；D=`get_available_actions` emit（自動上互動選單，零新 UI）。守 UI 邊界：UI 只渲染 DTO + 送 command。

**Tech Stack:** Godot 4.2.2 GDScript；headless + ui_flow；`.\tools\godot.ps1`。

依據 spec：`docs/superpowers/specs/2026-06-15-p3-action-coverage-design.md`。

**既有可用（不重寫）**：
- `_action_deposit_to_storage`/`_action_withdraw_from_storage`（讀 `storage_res`/`storage_amount`，gate `tile.outpost_owner==pt_id`）。
- `OutpostSystem._get_storage_cap(tile, res)`（私有）、`OutpostSystem.FACILITY_DEF`（8 類：farming/workshop/apothecary/mint/stable/smeltery/weaponsmith/armorsmith）、`slots_used`/`slot_cap`。
- `_action_build_facility`（讀 `facility_type`）、`_action_abandon_outpost`（讀 `abandon_pos:[x,y]`，set outpost_owner=-1）。
- `_action_extract_treasury`（讀 `extract_ratio`(0,1]）。
- `_action_recruit_anon(target_id)`、`_action_invite_settle(target_id)`（team-target）。
- `PlayerCommandSystem.get_available_actions(state, target_id)`（互動選單動作源）。
- `map_outpost_panel`/`map_faction_panel`（皆回 `actions:[]`）；text_ui `_handle_outpost_mode`/`_build_outpost_str`、`_handle_faction_mode`/`_build_faction_str`；`set_player_input`、`_input_mode` numeric。

---

## 檔案結構

- `scripts/simulation/outpost_system.gd`（改）：公開 `storage_cap(tile,res)` wrapper。
- `scripts/simulation/player_api_mapper.gd`（改）：`map_storage_panel`；`map_outpost_panel` actions 加 build_facility/abandon_outpost；`map_faction_panel` actions 加 extract_treasury。
- `scripts/simulation/player_query_api.gd`（改）：`get_storage_panel`。
- `scripts/simulation/player_command_system.gd`（改）：`get_available_actions` emit recruit_anon/invite_settle。
- `scripts/ui/sim_bridge.gd`（改）：`query_storage_panel` facade。
- `scripts/ui/text_ui_main.gd`（改）：公庫 mode（`_handle_storage_mode`/`_build_storage_str` + 入口鍵 `[G]`）；outpost/faction handler 加 build_facility/abandon/extract_treasury 鍵。
- `scripts/debug/headless_test.gd` / `ui_flow_test.gd`（改）：測試。

---

## Task A: 公庫面板（新）

**Files:**
- Modify: `scripts/simulation/outpost_system.gd`
- Modify: `scripts/simulation/player_api_mapper.gd`
- Modify: `scripts/simulation/player_query_api.gd`
- Modify: `scripts/ui/sim_bridge.gd`
- Modify: `scripts/ui/text_ui_main.gd`
- Test: `scripts/debug/headless_test.gd`, `scripts/debug/ui_flow_test.gd`

- [ ] **Step 1: 寫失敗測試（DTO）** — `headless_test.gd`

```gdscript
func _test_storage_panel_dto() -> void:
	print("--- get_storage_panel DTO ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var leader := PersonData.new(); leader.id = 0; leader.team_id = 0
	state.persons[0] = leader; state.player_id = 0
	var pt := TeamData.new(); pt.team_id = 0; pt.leader_id = 0
	pt.tile_pos = Vector2i(4,4); pt.resources = {"food": 80.0, "coin": 20}
	state.teams[0] = pt
	var tile := HexTileData.new(); tile.outpost_owner = 0; tile.outpost_type = "civilian"
	tile.outpost_level = 1; tile.public_storage = {"food": 30.0}
	state.world.tiles[4*1000+4] = tile
	var qa := PlayerQueryApi.new()
	var d: Dictionary = qa.get_storage_panel(state).get("data", {}).get("storage_panel", {})
	assert(d.get("feasible", false), "自家 outpost 應 feasible")
	assert(d.get("stored", []).size() > 0, "公庫清單非空")
	assert(d.get("team_res", []).size() > 0, "我方清單非空")
	# 非自家 → not feasible
	tile.outpost_owner = 99
	var d2: Dictionary = qa.get_storage_panel(state).get("data", {}).get("storage_panel", {})
	assert(not d2.get("feasible", true), "非自家 outpost 應 not feasible")
	print("storage_panel DTO OK")
```

- [ ] **Step 2: 跑確認失敗** — `get_storage_panel` 未定義。

- [ ] **Step 3: 實作**

`outpost_system.gd`（公開 cap）：
```gdscript
func storage_cap(tile: HexTileData, res: String) -> float:
	return _get_storage_cap(tile, res)
```

`player_api_mapper.gd` 新 `map_storage_panel`：
```gdscript
static func map_storage_panel(state: WorldState) -> Dictionary:
	var pid: int = state.player_id
	var p: PersonData = state.persons.get(pid) if pid != -1 else null
	var pt: TeamData = state.teams.get(p.team_id) if p != null else null
	if pt == null:
		return { "feasible": false, "reason": "無隊伍", "stored": [], "team_res": [] }
	var tile = state.world.tiles.get(pt.tile_pos.x * 1000 + pt.tile_pos.y)
	if tile == null or tile.outpost_owner != pt.team_id:
		return { "feasible": false, "reason": "需站在自家 outpost", "stored": [], "team_res": [] }
	var os := OutpostSystem.new()
	var stored: Array = []
	for res in tile.public_storage:
		if float(tile.public_storage[res]) > 0:
			stored.append({ "res": res, "qty": int(tile.public_storage[res]), "cap": int(os.storage_cap(tile, res)) })
	var team_res: Array = []
	for res in pt.resources:
		if float(pt.resources[res]) > 0:
			team_res.append({ "res": res, "qty": int(pt.resources[res]) })
	return { "feasible": true, "reason": "", "stored": stored, "team_res": team_res }
```

`player_query_api.gd`：
```gdscript
func get_storage_panel(state: WorldState) -> Dictionary:
	var check := _check_player_with_team(state)
	if check["code"] != "ok":
		return PlayerApiMapper.map_query_envelope(false, check["code"], check["msg"], {})
	return PlayerApiMapper.map_query_envelope(true, "ok", "",
		{ "storage_panel": PlayerApiMapper.map_storage_panel(state) })
```

`sim_bridge.gd`：
```gdscript
func query_storage_panel() -> Dictionary:
	return _query_api.get_storage_panel(_state)
```

- [ ] **Step 4: 跑確認通過** — `storage_panel DTO OK`

- [ ] **Step 5: 寫失敗測試（UI flow）** — `ui_flow_test.gd`

```gdscript
func _test_storage_panel_ui() -> void:
	print("\n── 公庫面板 ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var ptid: int = st.persons[st.player_id].team_id
	var ppos = st.teams[ptid].tile_pos
	st.teams[ptid].resources["food"] = 60.0
	var tile = st.world.tiles.get(ppos.x*1000 + ppos.y)
	if tile == null:
		tile = HexTileData.new(); st.world.tiles[ppos.x*1000+ppos.y] = tile
	tile.outpost_owner = ptid; tile.outpost_type = "civilian"; tile.outpost_level = 1
	tile.public_storage = {"food": 20.0}
	node._storage_mode = true
	var s: String = node._build_storage_str()
	_check("公庫字串顯存入/取出", s.contains("存") and s.contains("取"))
	_check("公庫顯 food", s.contains("food"))
	await _free_ui(node)
```

- [ ] **Step 6: 跑確認失敗** — `_storage_mode`/`_build_storage_str` 未定義。

- [ ] **Step 7: 實作 UI**

`text_ui_main.gd`：
- 加 `var _storage_mode: bool = false`、`var _storage_page: int = 0`。
- MODE_KEYMAP 加 `"storage": "[數字]選項 [Esc]離開"`；頂層輸入處理（如 `_handle_global_key`）加 `[G]` 進 storage mode（僅 feasible 時，否則 feedback「需站在自家 outpost」）。
- mode dispatch（同 `_handle_outpost_mode` 旁）加 `_handle_storage_mode`。
- 顯示處（同 `_build_outpost_str` 旁）feasible 時 `_event_label.text = _build_storage_str()`。

```gdscript
func _storage_rows() -> Array:
	var d: Dictionary = _bridge.query_storage_panel().get("data", {}).get("storage_panel", {})
	var rows: Array = []
	for it in d.get("team_res", []):
		rows.append({"dir": "deposit", "res": it.get("res",""), "qty": it.get("qty",0)})
	for it in d.get("stored", []):
		rows.append({"dir": "withdraw", "res": it.get("res",""), "qty": it.get("qty",0), "cap": it.get("cap",0)})
	return rows

func _build_storage_str() -> String:
	var d: Dictionary = _bridge.query_storage_panel().get("data", {}).get("storage_panel", {})
	if not d.get("feasible", false):
		return "── 公庫 ──\n（%s）\n[Esc]離開" % d.get("reason", "")
	var lines: Array = ["── 公庫 ──"]
	var rows: Array = _storage_rows()
	var start: int = _storage_page * 9
	var endi: int = mini(start + 9, rows.size())
	var shown_dep: bool = false
	var shown_wd: bool = false
	for gi in range(start, endi):
		var row: Dictionary = rows[gi]
		var label: int = gi - start + 1
		if row["dir"] == "deposit":
			if not shown_dep: lines.append("存入（我方→公庫）："); shown_dep = true
			lines.append("  [%d] %s ×%d" % [label, row["res"], int(row["qty"])])
		else:
			if not shown_wd: lines.append("取出（公庫→我方）："); shown_wd = true
			lines.append("  [%d] %s ×%d/%d" % [label, row["res"], int(row["qty"]), int(row["cap"])])
	if rows.size() > 9:
		lines.append("第 %d/%d 頁 [,]上 [.]下" % [_storage_page + 1, int(ceil(rows.size()/9.0))])
	lines.append("[數字]選項 [Esc]離開")
	return "\n".join(lines)

func _handle_storage_mode(keycode: int) -> void:
	if keycode == KEY_ESCAPE:
		_storage_mode = false; _storage_page = 0; _refresh(); return
	if keycode == KEY_COMMA:
		_storage_page = maxi(0, _storage_page - 1); _refresh(); return
	if keycode == KEY_PERIOD:
		_storage_page += 1; _refresh(); return
	if keycode < KEY_1 or keycode > KEY_9:
		return
	var idx: int = (keycode - KEY_1) + _storage_page * 9
	var rows: Array = _storage_rows()
	if idx >= rows.size(): return
	var row: Dictionary = rows[idx]
	_input_mode = true
	_input_mode_type = "numeric"
	_input_buffer = ""
	_input_mode_prompt = "%s %s 數量: " % ["存" if row["dir"] == "deposit" else "取", row["res"]]
	_input_mode_callback = func(buf: String) -> void:
		var qty: int = int(buf)
		if qty > 0:
			_bridge.set_player_input("storage_res", row["res"])
			_bridge.set_player_input("storage_amount", float(qty))
			var aid: String = "deposit_to_storage" if row["dir"] == "deposit" else "withdraw_from_storage"
			var r: Dictionary = _bridge.command_player("execute_action", {
				"action_id": aid,
				"target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}})
			_set_feedback(r.get("ok", false), r.get("message", ""))
		_refresh()
	_input_bar.text = "%s_" % _input_mode_prompt
```
（對齊既有 `_handle_trade_mode` 的 callback/數量輸入模式；確認 `_input_mode_callback`/`_input_bar`/`_handle_global_key` 實際名稱與既有一致。）

- [ ] **Step 8: 跑確認通過** — `公庫面板` PASS
- [ ] **Step 9: Commit**

```bash
git add scripts/simulation/outpost_system.gd scripts/simulation/player_api_mapper.gd scripts/simulation/player_query_api.gd scripts/ui/sim_bridge.gd scripts/ui/text_ui_main.gd scripts/debug/headless_test.gd scripts/debug/ui_flow_test.gd
git commit -m "feat(ui): 公庫面板（deposit/withdraw_to_storage，DTO+新 mode）"
```

---

## Task D: get_available_actions emit recruit_anon / invite_settle

**Files:**
- Modify: `scripts/simulation/player_command_system.gd`
- Test: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_get_actions_recruit_anon_invite() -> void:
	print("--- get_available_actions: recruit_anon/invite_settle ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var leader := PersonData.new(); leader.id = 0; leader.team_id = 0
	state.persons[0] = leader; state.player_id = 0
	var pt := TeamData.new(); pt.team_id = 0; pt.leader_id = 0; pt.population = 10
	pt.tile_pos = Vector2i(4,4); pt.resources = {"coin": 500}
	state.teams[0] = pt
	var tgt := TeamData.new(); tgt.team_id = 1; tgt.population = 6
	tgt.tile_pos = Vector2i(4,4)
	state.teams[1] = tgt
	var cs := PlayerCommandSystem.new()
	var acts: Array = cs.get_available_actions(state, 1)
	assert(acts.has("recruit_anon"), "合格目標應含 recruit_anon")
	print("get_actions recruit_anon/invite_settle OK (acts=%s)" % str(acts))
```
（invite_settle 條件較特定[目標為可定居居民團+玩家擁當地 outpost]，測中先驗 recruit_anon；invite_settle 若條件難構，至少斷言實作後對符合情境的目標出現 — 依後端 `_action_invite_settle`/`_recruit_anon_internal` 實際前提調整斷言。）

- [ ] **Step 2: 跑確認失敗**

- [ ] **Step 3: 實作** — `player_command_system.gd` `get_available_actions`，於 `gather_intel` append 前加：

```gdscript
	# recruit_anon：有 coin 且目標有匿名人口可招（與 recruit 並列，label 區分）
	if coin >= RECRUIT_COST_ANON and _target_has_anon(tgt):
		actions.append("recruit_anon")
	# invite_settle：目標為可定居居民團 且玩家擁有當地 outpost
	if _can_invite_settle(state, pt, tgt):
		actions.append("invite_settle")
```
其中 `_target_has_anon`/`_can_invite_settle` 為小 helper（依 `_recruit_anon_internal`/`_action_invite_settle` 既有前提抽出條件；若前提已是簡單欄位判斷，可內聯）。**勿改 `_action_recruit_anon`/`_action_invite_settle` 行為**，只補 emit 條件。

- [ ] **Step 4: 跑確認通過** — `get_actions recruit_anon/invite_settle OK`
- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/player_command_system.gd scripts/debug/headless_test.gd
git commit -m "feat(api): get_available_actions emit recruit_anon/invite_settle（補互動選單）"
```

---

## Task B: outpost 面板擴（build_facility + abandon_outpost）

**Files:**
- Modify: `scripts/simulation/player_api_mapper.gd`（map_outpost_panel actions）
- Modify: `scripts/ui/text_ui_main.gd`（_handle_outpost_mode / _build_outpost_str）
- Test: `scripts/debug/ui_flow_test.gd`

- [ ] **Step 1: 寫失敗測試（flow）**

```gdscript
func _test_outpost_build_abandon() -> void:
	print("\n── outpost build_facility/abandon ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var ptid: int = st.persons[st.player_id].team_id
	var ppos = st.teams[ptid].tile_pos
	var tile = st.world.tiles.get(ppos.x*1000 + ppos.y)
	if tile == null:
		tile = HexTileData.new(); st.world.tiles[ppos.x*1000+ppos.y] = tile
	tile.outpost_owner = ptid; tile.outpost_type = "civilian"; tile.outpost_level = 1
	node._outpost_mode = true
	var s: String = node._build_outpost_str()
	_check("outpost 面板顯設施/棄置", s.contains("設施") or s.contains("擴建") or s.contains("棄"))
	await _free_ui(node)
```

- [ ] **Step 2: 跑確認失敗**

- [ ] **Step 3: 實作**

`map_outpost_panel`（`actions` builder，於 `demolish_outpost` append 後、`has_ctrl` 分支內）：
```gdscript
				actions.append("demolish_outpost")
				actions.append("abandon_outpost")
				# 有空 slot → 可蓋新設施（farming/workshop 外的類型）
				if OutpostSystem.slots_used(tile) < OutpostSystem.slot_cap(tile):
					actions.append("build_facility")
```

`text_ui_main.gd` `_handle_outpost_mode`：依該 action 在 panel `actions` 的索引/鍵（沿用既有 outpost handler 把 action 映射到數字鍵的模式）加：
- `build_facility` → 進設施選單：列 `OutpostSystem.FACILITY_DEF` 中 `allowed_outpost` 含本 outpost_type 的類型 → 選一 → `set_player_input("facility_type", key)` → 送 `build_facility`。
- `abandon_outpost` → **二次確認**（破壞性）：首次按顯「再按確認棄置」，再按 → `set_player_input("abandon_pos", [pt.tile_pos.x, pt.tile_pos.y])` → 送 `abandon_outpost`。

`_build_outpost_str` 對應顯示新列（label：build_facility=「蓋設施」、abandon_outpost=「棄置據點」），與 demolish 區分清楚（demolish=拆毀現地物、abandon=放棄所有權保留地物）。

- [ ] **Step 4: 跑確認通過** — `outpost build_facility/abandon` PASS
- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/player_api_mapper.gd scripts/ui/text_ui_main.gd scripts/debug/ui_flow_test.gd
git commit -m "feat(ui): outpost 面板加 build_facility（設施選單）+ abandon_outpost（二次確認）"
```

---

## Task C: faction 面板擴（extract_treasury）

**Files:**
- Modify: `scripts/simulation/player_api_mapper.gd`（map_faction_panel actions）
- Modify: `scripts/ui/text_ui_main.gd`（_handle_faction_mode / _build_faction_str）
- Test: `scripts/debug/ui_flow_test.gd`

- [ ] **Step 1: 寫失敗測試（flow）**

```gdscript
func _test_faction_extract_treasury() -> void:
	print("\n── faction extract_treasury ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var ptid: int = st.persons[st.player_id].team_id
	# 建勢力使玩家為 leader
	var fac := FactionData.new(); fac.faction_id = 555; fac.leader_team_id = ptid
	st.factions[555] = fac
	st.teams[ptid].faction_id = 555
	node._faction_mode = true
	var s: String = node._build_faction_str()
	_check("faction 面板顯提幣", s.contains("提幣") or s.contains("徵用") or s.contains("國庫"))
	await _free_ui(node)
```
（確認 `FactionData` 欄位名 leader_team_id/faction_id 與既有一致；若初始情境玩家已在勢力，可省建勢力步驟。）

- [ ] **Step 2: 跑確認失敗**

- [ ] **Step 3: 實作**

`map_faction_panel`（leader 分支，`set_faction_goal`/`set_tribute_rate` 旁）：
```gdscript
	if is_leader:
		actions.append_array(["set_faction_goal", "set_tribute_rate", "extract_treasury", ...])
```
（保留既有項，只加 `extract_treasury`。）

`text_ui_main.gd` `_handle_faction_mode`：該 action 對應鍵 → 進比例輸入（0,1] → `set_player_input("extract_ratio", r)` → 送 `extract_treasury` → feedback。高比例（如 >0.5）加二次確認。`_build_faction_str` 顯新列 label「徵用國庫」。

- [ ] **Step 4: 跑確認通過** — `faction extract_treasury` PASS
- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/player_api_mapper.gd scripts/ui/text_ui_main.gd scripts/debug/ui_flow_test.gd
git commit -m "feat(ui): faction 面板加 extract_treasury（比例輸入+高比例確認）"
```

---

## Task E: 註冊 + 整合（守恆）

- [ ] **Step 1: 註冊** 全新測：`_test_storage_panel_dto`、`_test_get_actions_recruit_anon_invite`（headless）；`_test_storage_panel_ui`、`_test_outpost_build_abandon`、`_test_faction_extract_treasury`（ui_flow）。
- [ ] **Step 2: 守恆整合測**（headless `_test_storage_conservation`）：deposit food 20 → withdraw food 20 → 隊 food 不變、公庫回原值（雙向守恆）；extract_treasury：國庫減量==隊增量。
- [ ] **Step 3: 全跑** — `.\tools\godot.ps1 --headless --import` 後跑 headless / ui_logic / ui_flow，無新 SCRIPT ERROR、新測全綠。
- [ ] **Step 4: handback** — `docs/superpowers/handbacks/2026-06-15-p3-action-coverage.md`，真視覺（面板版面/二次確認流）標待人工 run-verify。

---

## 注意事項（給實作者）

- **零新動作邏輯**：6 個 `_action_*` 既有，本 plan 只暴露 DTO/面板列/emit + UI。勿改後端行為。
- **UI 邊界**：全經 query DTO + `execute_action` command + `set_player_input`，零直存 state。
- **守恆**：deposit/withdraw、extract_treasury 既有雙向；Task E 驗。
- **破壞性二次確認**：abandon_outpost、extract_treasury(高比例) 須二次按鍵確認，防誤觸。
- **label 區分**：recruit vs recruit_anon、demolish vs abandon — 並列時 label 須讓玩家分得清差異。
- **既有名稱核對**：`_input_mode_callback`/`_input_bar`/`_handle_global_key`/各 mode handler 與顯示分派的實際函數名以 text_ui_main.gd 現況為準（本 plan 沿用 `_handle_trade_mode` 既有模式，照抄其結構）。
- **分頁**：公庫 res 多時沿用 `_*_page` 模式。
- baseline Bug8 勿動。順序：A→D→B→C→E。
