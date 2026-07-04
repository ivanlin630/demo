# Text UI → Player API 接口補全 Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 補齊 `player_api_mapper.gd` 缺少的 DTO 欄位，讓 `text_ui_main.gd` 的所有 display function 改用 snapshot，不再直接讀 `WorldState`／`TeamData`／`PersonData`。

**Spec:** `docs/superpowers/specs/2026-06-01-text-ui-api-connect.md`

**Worktree:** `.worktrees/text-ui-api`  
**Branch:** `feat/text-ui-api-connect`

---

## File Structure

| Action | Path | 改動摘要 |
|--------|------|---------|
| Modify | `scripts/simulation/player_api_mapper.gd` | 擴充 3 個 map 函式 + 新增 `_hp_status` private helper |
| Modify | `scripts/ui/text_ui_main.gd` | `_refresh_snapshot`、`_build_state_str`、`_visible_team_at`、`_build_member_str`、`_build_inv_str` 改用 snapshot |

---

## Task 1: 擴充 player_api_mapper.gd

### Task 1.1 新增 `_hp_status` private static helper

**File:** `scripts/simulation/player_api_mapper.gd`

- [ ] **Step 1:** 在檔案最底部加入：

```gdscript
static func _hp_status(p: PersonData) -> String:
	if p == null: return ""
	var has_severe := false
	var has_wound  := false
	for part in p.body_parts.values():
		var s: String = part.get("status", "healthy")
		if s == "severed" or s == "critical": has_severe = true
		elif s == "wounded": has_wound = true
	if has_severe: return "重傷"
	if has_wound:  return "輕傷"
	return "正常"
```

- [ ] **Step 2:** headless test：`=== DONE ===`，無 `SCRIPT ERROR`

---

### Task 1.2 擴充 `map_player_summary`

**File:** `scripts/simulation/player_api_mapper.gd`

在 `p != null` 那個 return dict 加入 `hp_status` 與 `skills`。

- [ ] **Step 1:** 找到 `map_player_summary` 最終 return（`"player_exists": true, ...` 的 block），在 `"has_forced_interaction": ...` 之後加：

```gdscript
		"hp_status": _hp_status(p),
		"skills": (func() -> Dictionary:
			var s: Dictionary = {}
			for k in p.skills:
				if float(p.skills[k]) > 0.01:
					s[k] = float(p.skills[k])
			return s).call(),
```

> **注意**：GDScript 4 lambda 直接 `.call()` 可用；或改用區域變數分步建 dict 再 assign，避免 lambda 若有 lint 問題。建議改用分步（下方為分步版本供參）：
```gdscript
		"hp_status": _hp_status(p),
```
在 return 前先計算：
```gdscript
	var _skills: Dictionary = {}
	for k in p.skills:
		if float(p.skills[k]) > 0.01:
			_skills[k] = float(p.skills[k])
```
return dict 加：
```gdscript
		"skills": _skills,
```

- [ ] **Step 2:** headless test pass

---

### Task 1.3 擴充 `map_controlled_team`

**File:** `scripts/simulation/player_api_mapper.gd`

- [ ] **Step 1:** `resources` dict 補全所有欄位，從：
```gdscript
		"resources": {
			"food": int(t.resources.get("food", 0)),
			"coin": int(t.resources.get("coin", 0)),
			"material": int(t.resources.get("material", 0))
		},
```
改成：
```gdscript
		"resources": {
			"food":               int(t.resources.get("food", 0)),
			"coin":               int(t.resources.get("coin", 0)),
			"material":           int(t.resources.get("material", 0)),
			"weapon_melee_low":   int(t.resources.get("weapon_melee_low", 0)),
			"weapon_melee_high":  int(t.resources.get("weapon_melee_high", 0)),
			"weapon_ranged_low":  int(t.resources.get("weapon_ranged_low", 0)),
			"weapon_ranged_high": int(t.resources.get("weapon_ranged_high", 0)),
			"armor_low":          int(t.resources.get("armor_low", 0)),
			"armor_high":         int(t.resources.get("armor_high", 0)),
			"medicine":           int(t.resources.get("medicine", 0)),
			"tools":              int(t.resources.get("tools", 0)),
		},
```

- [ ] **Step 2:** 在 `members` 陣列建構邏輯中，每項 append 改為包含 hp_status + equipment。找到：
```gdscript
		members.append({"id": m.id, "name": m.person_name, "role": m.role})
```
改成：
```gdscript
		members.append({
			"id": m.id,
			"name": m.person_name,
			"role": m.role,
			"hp_status": _hp_status(m),
			"equipment": {
				"hand_1": m.equipment.get("hand_1", {}).get("grade", ""),
				"torso":  m.equipment.get("torso",  {}).get("grade", ""),
			}
		})
```

- [ ] **Step 3:** 在 return dict 的 `"task_summary": t.current_task` 之前（或之後）加入新 top-level 欄位：
```gdscript
		"fatigue_pct":     int(t.fatigue * 100),
		"population":      t.population,
		"minor_population": t.minor_population,
		"faction_id":      t.faction_id,
		"faction_display": ("勢力%d" % t.faction_id) if t.faction_id >= 0 else "獨立",
```

- [ ] **Step 4:** headless test pass

---

### Task 1.4 擴充 `map_visible_teams`

**File:** `scripts/simulation/player_api_mapper.gd`

- [ ] **Step 1:** 在 `map_visible_teams` 的 `result.append(...)` 每項加入：
```gdscript
			"faction_display": ("勢力%d" % dt.faction_id) if dt.faction_id >= 0 else "獨立",
			"population": dt.population,
```

- [ ] **Step 2:** headless test pass

---

## Task 2: 修改 text_ui_main.gd

### Task 2.1 `_refresh_snapshot` 補傳 cursor

**File:** `scripts/ui/text_ui_main.gd`

- [ ] **Step 1:** 找到 `_refresh_snapshot`：
```gdscript
func _refresh_snapshot() -> void:
	var request: Dictionary = {}
	if _interact_target >= 0:
		request["focus_team_id"] = _interact_target
	var _result := _bridge.query_player(request)
	_cached_snapshot = _result.get("data", {}).get("snapshot", {})
```
改成：
```gdscript
func _refresh_snapshot() -> void:
	var request: Dictionary = {}
	if _interact_target >= 0:
		request["focus_team_id"] = _interact_target
	if _selected != Vector2i(-1, -1):
		request["cursor_tile_q"] = _selected.x
		request["cursor_tile_r"] = _selected.y
	var _result := _bridge.query_player(request)
	_cached_snapshot = _result.get("data", {}).get("snapshot", {})
```

- [ ] **Step 2:** headless test pass

---

### Task 2.2 `_visible_team_at` 改用 snapshot

**File:** `scripts/ui/text_ui_main.gd`

- [ ] **Step 1:** 找到現有 `_visible_team_at`：
```gdscript
func _visible_team_at(tile_key: int) -> int:
	var discovered: Array = _state.team_discovered.get(_player_tid, [])
	for tid in _state.teams:
		if tid == _player_tid: continue
		var t: TeamData = _state.teams[tid]
		if t.tile_pos.x * 1000 + t.tile_pos.y == tile_key and discovered.has(tid):
			return tid
	return -1
```
改成：
```gdscript
func _visible_team_at(tile_key: int) -> int:
	var q: int = tile_key / 1000
	var r: int = tile_key % 1000
	for vt in _cached_snapshot.get("visible_teams", []):
		var pos: Dictionary = vt.get("position", {})
		if pos.get("q", -999) == q and pos.get("r", -999) == r:
			return vt.get("id", -1)
	return -1
```

- [ ] **Step 2:** headless test pass

---

### Task 2.3 `_build_state_str` 改用 snapshot

**File:** `scripts/ui/text_ui_main.gd`

目標：`_state.teams` / `_state.persons` 讀取改為讀 snapshot；`_state.world.tiles`（tile 原始資料）仍允許直讀。

- [ ] **Step 1:** 將 `_build_state_str` 函式完整替換為下方實作（完整替換，避免漏改）：

```gdscript
func _build_state_str() -> String:
	var ct: Dictionary  = _cached_snapshot.get("controlled_team", {})
	var ps: Dictionary  = _cached_snapshot.get("player_summary", {})
	var lc: Dictionary  = _cached_snapshot.get("location_context", {})
	if ct.is_empty(): return "（無玩家 team）"
	var lines: Array = []

	var pos: Dictionary = ct.get("position", {})
	lines.append("Team%d @ (%d,%d) [%s]" % [
		ct.get("id", _player_tid),
		pos.get("q", 0), pos.get("r", 0),
		ct.get("faction_display", "?")])
	lines.append("任務: %s  疲勞: %d%%" % [ct.get("task_summary", ""), ct.get("fatigue_pct", 0)])
	lines.append("人口: %d | 未成年: %d" % [ct.get("population", 0), ct.get("minor_population", 0)])

	if ps.get("player_exists", false):
		lines.append("────────────────")
		lines.append("玩家: %s  HP:%s" % [ps.get("player_name", ""), ps.get("hp_status", "")])
		var skill_parts: Array = []
		for sk in ps.get("skills", {}):
			skill_parts.append("%s:%.2f" % [sk, float(ps["skills"][sk])])
		if not skill_parts.is_empty():
			lines.append("  " + " ".join(skill_parts))

	var res: Dictionary = ct.get("resources", {})
	lines.append("────────────────")
	lines.append("資源:")
	lines.append("  食:%d 幣:%d 材:%d" % [res.get("food", 0), res.get("coin", 0), res.get("material", 0)])
	lines.append("  低武:%d 高武:%d" % [res.get("weapon_melee_low", 0), res.get("weapon_melee_high", 0)])
	lines.append("  低甲:%d 高甲:%d" % [res.get("armor_low", 0), res.get("armor_high", 0)])
	lines.append("  藥:%d 工:%d" % [res.get("medicine", 0), res.get("tools", 0)])

	if _selected != Vector2i(-1, -1):
		var sel_key: int = _selected.x * 1000 + _selected.y
		var sel_tile = _state.world.tiles.get(sel_key)
		lines.append("────────────────")
		if sel_tile:
			lines.append("選中: (%d,%d) %s" % [_selected.x, _selected.y, sel_tile.terrain])
			lines.append("  農:%.0f%%  食:%d" % [sel_tile.productivity * 100, int(sel_tile.resources.get("food", 0))])
			# 查 location_context occupants（需已在 _refresh_snapshot 傳 cursor_tile_q/r）
			var occ: Array = lc.get("occupants", [])
			if not occ.is_empty():
				var vts: Array = _cached_snapshot.get("visible_teams", [])
				for o in occ:
					var oid: int = o.get("team_id", -1)
					var f_display: String = "?"
					var pop: int = 0
					for vt in vts:
						if vt.get("id", -1) == oid:
							f_display = vt.get("faction_display", "?")
							pop = vt.get("population", 0)
							break
					lines.append("  %s [%s] 人口:%d" % [o.get("team_name", "Team?"), f_display, pop])
		else:
			lines.append("選中: (%d,%d) [無效格]" % [_selected.x, _selected.y])

	lines.append("────────────────")
	lines.append("Tick: %d  (Day %d)" % [
		_state.world.current_tick,
		_state.world.current_tick / WorldState.TICKS_PER_DAY])
	var _pending_n: int = _cached_snapshot.get("pending_targets", []).size()
	var _forced_n:  int = 0 if _cached_snapshot.get("forced_interaction", {}).get("interaction_id", "").is_empty() else 1
	if _pending_n > 0 or _forced_n > 0:
		var _hint: String = "[T] 互動"
		if _pending_n > 0: _hint += ": 同格%d隊" % _pending_n
		if _forced_n > 0:  _hint += "  ⚠強制事件"
		lines.append(_hint)
	return "\n".join(lines)
```

- [ ] **Step 2:** headless test pass

---

### Task 2.4 `_build_member_str` 改用 snapshot

**File:** `scripts/ui/text_ui_main.gd`

- [ ] **Step 1:** 完整替換 `_build_member_str`：

```gdscript
func _build_member_str() -> String:
	var ct: Dictionary = _cached_snapshot.get("controlled_team", {})
	if ct.is_empty(): return "（無玩家 team）"
	var lines: Array = []
	lines.append("── 成員 %s ──" % ct.get("name", "Team?"))

	for m in ct.get("members", []):
		var role_tag: String = "[隊長]" if m.get("role", "") == "leader" else "[成員]"
		var hand1: String = m.get("equipment", {}).get("hand_1", "")
		if hand1.is_empty(): hand1 = "空"
		lines.append("%s %s  裝備:%s  HP:%s" % [role_tag, m.get("name", "?"), hand1, m.get("hp_status", "?")])

	var named_count: int = ct.get("members", []).size()
	var pop: int = ct.get("population", 0)
	var anon: int = maxi(0, pop - named_count)
	var res: Dictionary = ct.get("resources", {})
	var weapons: int = (res.get("weapon_melee_low",   0)
		+ res.get("weapon_melee_high",  0)
		+ res.get("weapon_ranged_low",  0)
		+ res.get("weapon_ranged_high", 0))
	var armed_rate: float = float(weapons) / maxf(float(pop), 1.0)
	lines.append("匿名人口: %d  武裝率: %d%%" % [anon, int(armed_rate * 100)])
	lines.append("── [P/Esc] 關閉 ──")
	return "\n".join(lines)
```

- [ ] **Step 2:** headless test pass

---

### Task 2.5 `_build_inv_str` equipped 區段改用 snapshot

**File:** `scripts/ui/text_ui_main.gd`

- [ ] **Step 1:** 在 `_build_inv_str` 中，找到讀取 player equipment 的段落：
```gdscript
	var player: PersonData = _state.persons.get(_state.player_id)
	var pt: TeamData       = _state.teams.get(_player_tid)
	if player == null or pt == null: return "（無資料）"
	var lines: Array = []

	lines.append("── 裝備 ──")
	var h1: String = player.equipment.get("hand_1", {}).get("grade", "")
	var h2: String = player.equipment.get("hand_2", {}).get("grade", "")
	lines.append("  右手:%s  左手:%s" % [h1 if not h1.is_empty() else "空", h2 if not h2.is_empty() else "空"])
	var body_slots: Array = ["head", "torso", "right_arm", "left_arm", "right_leg", "left_leg"]
	var body_names: Array = ["頭", "胸", "右臂", "左臂", "右腿", "左腿"]
	var body_strs: Array = []
	for i in range(body_slots.size()):
		var g: String = player.equipment.get(body_slots[i], {}).get("grade", "")
		body_strs.append("%s:%s" % [body_names[i], g if not g.is_empty() else "空"])
	lines.append("  " + " ".join(body_strs))
```
改成（`equipped_items` 從 snapshot 讀，body_slots 部分仍保留直讀 `_state.persons` 因 mapper 未 expose 這些 slot）：
```gdscript
	var ct: Dictionary      = _cached_snapshot.get("controlled_team", {})
	var inv_state: Dictionary = _cached_snapshot.get("inventory_state", {})
	if ct.is_empty() or inv_state.is_empty(): return "（無資料）"
	var equipped: Dictionary = inv_state.get("equipped_items", {})
	var lines: Array = []

	lines.append("── 裝備 ──")
	var h1: String = equipped.get("hand_1", "")
	var h2: String = equipped.get("hand_2", "")
	lines.append("  右手:%s  左手:%s" % [h1 if not h1.is_empty() else "空", h2 if not h2.is_empty() else "空"])
	# body_slots 目前 mapper 未 expose，仍直讀 _state.persons
	var player: PersonData = _state.persons.get(_state.player_id)
	var body_slots: Array = ["head", "torso", "right_arm", "left_arm", "right_leg", "left_leg"]
	var body_names: Array = ["頭", "胸", "右臂", "左臂", "右腿", "左腿"]
	var body_strs: Array = []
	for i in range(body_slots.size()):
		var g: String = player.equipment.get(body_slots[i], {}).get("grade", "") if player else ""
		body_strs.append("%s:%s" % [body_names[i], g if not g.is_empty() else "空"])
	lines.append("  " + " ".join(body_strs))
```

剩餘的 `inv` / `team_items` 段落不改（已走 snapshot）。但注意原本從 `pt: TeamData` 取 `pt.resources.get(team_items[i], 0)` 的部分，改從 `ct.get("resources", {})` 讀：
找到：
```gdscript
		var qty: int = int(pt.resources.get(team_items[i], 0))
```
改成：
```gdscript
		var qty: int = ct.get("resources", {}).get(team_items[i], 0)
```

同時，原本宣告的 `var pt: TeamData = _state.teams.get(_player_tid)` 已不再需要，可移除（但需確認同函式無其他 `pt` 使用）。

- [ ] **Step 2:** headless test pass

---

## Task 3: 最終驗收

- [ ] **Step 1:** 完整跑 headless test：
```powershell
A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```
確認 `=== DONE ===`，無 `SCRIPT ERROR`

- [ ] **Step 2:** commit：
```
feat(ui): switch text_ui display functions to player API snapshot
```

- [ ] **Step 3:** push branch：
```powershell
git push -u origin feat/text-ui-api-connect
```

- [ ] **Step 4:** 寫 handback 到 `docs/superpowers/handbacks/2026-06-01-text-ui-api-connect.md`

---

## 注意事項

- 每個 task 後都要跑 headless test，確認無 SCRIPT ERROR 再繼續
- `_get_hp_status` helper 保留不刪（map renderer 等未來可能用到）
- `_build_debug_str` / `TextMapRenderer` / `_process` 不改
- tile productivity / tile.resources.food 直讀 `_state.world.tiles` 是允許的（tile 非 player data）
- `cursor_tile_q` / `cursor_tile_r`（非 `cursor_q`/`cursor_r`）才是正確的 request key
- worktree 執行 headless test 要用 root 工具路徑：`A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe`
