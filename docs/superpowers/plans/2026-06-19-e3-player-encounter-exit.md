# E-3 玩家遭遇戰離場 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 修「玩家被困在遭遇戰」——玩家在地圖邊界往場外移動 = 離場（玩家角色 unit `has_exited`），復用既有 retreat/exit 機制。

**Architecture:** 最小 wire。玩家移動現被 `encounter_view._is_in_map` clamp 鎖在場內。改為：邊界往場外按方向 → pending `move` 帶場外 `move_to`；`encounter_system._decide_action` 玩家 `move` 分支偵測 off-map target → 回 `{type:"retreat"}`（既有 retreat apply 在 `hex_dist > MAP_RADIUS` 設 `has_exited`）。只玩家角色 unit 離場；全隊撤退 = gold-plate，不做（藍圖裁定留衝突傘）。

**Tech Stack:** Godot 4.2.2 GDScript；headless harness（`scripts/debug/headless_test.gd`，`_test_*` 註冊於 `_initialize()`，`assert` 失敗即中止）。

## Global Constraints

- 跑 wrapper：`.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`（UTF-8）。
- 藍圖約束（handback `2026-06-19-systems-to-blueprint-e2-e3-scope` 裁定）：**只做最小邊界離場（復用 has_exited）**。「退場有代價」（追擊落跑傷兵/慢兵）**留衝突傘，別 gold-plate**。
- 來源：known_issues E-3；藍圖裁定 E-3→(a) 系統獨立最小快修。
- 回歸閘：headless `=== DONE ===` + 0 assert fail + InvariantAudit 0 + coin_eq 守恆。
- encounter_view 屬 UI 層，headless 難自動測 → UI 端改動靠 sim 端測試 + 標 run-verify（真人玩測）。

## File Structure

- `scripts/simulation/encounter_system.gd`：`_decide_action` 玩家 `move` 分支加 off-map → exit（可測，核心）。
- `scripts/ui/encounter_view.gd`：idle HEX_DIRS handler 放行邊界往外移動 + UI hint（UI wire，run-verify）。

---

### Task 1: encounter_system 玩家 off-map move → 離場（has_exited）

**Files:**
- Modify: `scripts/simulation/encounter_system.gd`（`_decide_action` 玩家 `move` 分支，約 :397-399）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Produces: `_decide_action` 玩家 pending `{type:"move", move_to:<off-map>}` → 回 `{type:"retreat", move_to:<off-map>, target_idx:-1, attack_part:""}`；in-map move → 維持 `{type:"move"}`。retreat apply（:870-874）在 `hex_dist(0,move_to) > MAP_RADIUS` 設 `has_exited=true`。

- [ ] **Step 1: 寫失敗測試**

加到 `scripts/debug/headless_test.gd`：

```gdscript
func _test_e3_player_edge_exit() -> void:
	print("--- E-3：玩家邊界往場外移動 → 離場 ---")
	var enc := EncounterSystem.new()
	var s := WorldState.new(); s.world = WorldData.new()
	# 兩隊各 1 named，玩家為 atk leader
	var atk := TeamData.new(); atk.team_id = 0; atk.tile_pos = Vector2i(0,0)
	var pl := PersonData.new(); pl.id = 500; pl.team_id = 0; s.persons[500] = pl; atk.leader_id = 500
	var def := TeamData.new(); def.team_id = 1; def.tile_pos = Vector2i(0,0)
	var dl := PersonData.new(); dl.id = 600; dl.team_id = 1; s.persons[600] = dl; def.leader_id = 600
	s.teams[0] = atk; s.teams[1] = def
	s.player_id = 500
	enc.init_encounter(s, 0, 1, "normal")
	# 找玩家 unit，置於邊界，設 pending 往場外
	var pu_idx: int = -1
	for i in range(s.encounter_units.size()):
		if s.encounter_units[i].get("person_id", -1) == 500: pu_idx = i; break
	assert(pu_idx >= 0, "找到玩家 unit")
	var edge := Vector2i(EncounterSystem.MAP_RADIUS, 0)            # 邊界 hex
	var offmap := Vector2i(EncounterSystem.MAP_RADIUS + 1, 0)      # 場外
	s.encounter_units[pu_idx]["pos"] = edge
	s.encounter_units[pu_idx]["action_timer"] = 0
	s.encounter_units[pu_idx]["pending_action"] = {"type": "move", "move_to": offmap}
	enc.advance_encounter_tick(s)   # 驅動一回合處理 pending（既有 _enc 測試用此入口）
	assert(s.encounter_units[pu_idx].get("has_exited", false),
		"玩家往場外移動應離場(has_exited)，實際=%s" % str(s.encounter_units[pu_idx].get("has_exited", false)))
	print("E-3 player edge exit OK")
```

> 入口 = `advance_encounter_tick(state) -> String`（encounter_system:818，既有測試 headless:922 用法）。

`_initialize()` 加 `_test_e3_player_edge_exit()`。

- [ ] **Step 2: 跑 harness 驗證失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: 玩家 `move` 到 off-map → 現 move apply `_is_in_map` clamp 不動 → `has_exited` 仍 false → assert 失敗中止。

- [ ] **Step 3: 實作 _decide_action off-map → retreat**

`scripts/simulation/encounter_system.gd` 的 `_decide_action` 玩家 `"move"` 分支（約 :397-399）：

```gdscript
			"move":
				return { "type": "move", "target_idx": -1,
					"move_to": pa.get("move_to", unit["pos"]), "attack_part": "" }
```

換成：

```gdscript
			"move":
				var mv: Vector2i = pa.get("move_to", unit["pos"])
				# 往場外移動 = 離場（復用 retreat apply：hex_dist>MAP_RADIUS → has_exited）
				if not _is_in_map(mv):
					return { "type": "retreat", "target_idx": -1,
						"move_to": mv, "attack_part": "" }
				return { "type": "move", "target_idx": -1,
					"move_to": mv, "attack_part": "" }
```

- [ ] **Step 4: 跑 harness 驗證通過**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `E-3 player edge exit OK`，整輪 `=== DONE ===`，既有 encounter 測試不破（in-map move 行為不變）。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/encounter_system.gd scripts/debug/headless_test.gd
git commit -m "feat(encounter): 玩家往場外移動→離場(復用 retreat/has_exited)"
```

---

### Task 2: encounter_view 放行邊界離場 + UI hint

**Files:**
- Modify: `scripts/ui/encounter_view.gd`（idle HEX_DIRS handler :397-401 + hint）

**Interfaces:**
- Consumes: Task 1 的 `_decide_action` off-map → exit。
- Produces: 玩家在邊界按往場外方向 → 設 pending `{type:"move", move_to:<off-map neighbor>}`（不 clamp）→ 結束玩家回合。

- [ ] **Step 1: 放行邊界往外移動**

`scripts/ui/encounter_view.gd` idle 模式 HEX_DIRS 分支（:397-401）：

```gdscript
			elif HEX_DIRS.has(keycode):
				var cur_pos: Vector2i = player_unit.get("pos", Vector2i.ZERO)
				var target: Vector2i = _hex_neighbor(cur_pos, keycode)
				if _is_in_map(target):   # P4-4:邊界 clamp,移動不走出戰場
					_do_move(player_unit, target, state)
```

換成：

```gdscript
			elif HEX_DIRS.has(keycode):
				var cur_pos: Vector2i = player_unit.get("pos", Vector2i.ZERO)
				var target: Vector2i = _hex_neighbor(cur_pos, keycode)
				if _is_in_map(target):
					_do_move(player_unit, target, state)
				else:
					_do_exit(player_unit, target)   # E-3:邊界往場外 = 離場
```

加 `_do_exit`（與 `_do_move` 並列，:449 附近）：

```gdscript
func _do_exit(unit: Dictionary, target: Vector2i) -> void:
	# E-3：往場外移動 = 離場。pending move 帶場外座標，encounter_system 轉 retreat → has_exited。
	unit["pending_action"] = { "type": "move", "target_idx": -1,
		"move_to": target, "attack_part": "" }
	_log("離開戰場…")
	_end_player_turn(unit)
```

- [ ] **Step 2: 加 UI hint**

找 idle 模式的操作提示文字（grep `KEY_SPACE` 附近的 hint label 或 `_post_combat_hint`/操作說明組裝處），加一行「邊界方向鍵 = 離場」。例（依既有 hint 組裝風格插入）：

```gdscript
	# idle 操作提示加離場說明（位置依既有 hint label 文字組裝）
	"... [方向]移動(邊界→離場) [R]攻擊 [空白]待機 [Z]選單 [F]投降 ..."
```

> 若 hint 文字為集中常數/函數，改該處；無集中 hint 則略過純文字（行為已通，hint 為 nice-to-have）。

- [ ] **Step 3: parse 驗證 + run-verify 標記**

Run: `.\tools\godot.ps1 --headless --import`（確認 encounter_view parse 無誤）
Expected: 無 SCRIPT ERROR。

> encounter_view 為 GUI，headless 無法驅真鍵入。**標 run-verify**：真人玩測「邊界按往外方向 → 玩家離場、encounter 結算/返世界」。Task 1 的 sim 測試已證離場機制本身正確。

- [ ] **Step 4: Commit**

```bash
git add scripts/ui/encounter_view.gd
git commit -m "feat(encounter-ui): 玩家邊界往場外方向鍵=離場 + hint(run-verify)"
```

---

### Task 3: known_issues 更新 + 回歸閘

**Files:**
- Modify: `docs/known_issues.md`（E-3 標已修，run-verify pending）

- [ ] **Step 1: 更新 known_issues**

`docs/known_issues.md` E-3 條標：✅ 已修（sim 端 `_test_e3_player_edge_exit` 驗；UI 端邊界離場 wire 待 run-verify）。記範圍：只最小玩家角色離場，「退場有代價」/全隊撤退留衝突統一傘。

- [ ] **Step 2: 全回歸閘**

```
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```

Expected: `=== DONE ===`、coin_eq=0、InvariantAudit 0、1000 Tick 無崩潰。

- [ ] **Step 3: Commit**

```bash
git add docs/known_issues.md
git commit -m "docs(known-issues): E-3 玩家離場 ✅ 修(sim 驗,UI run-verify)"
```

---

## Self-Review 註記

- **spec 覆蓋**：sim 端 off-map→exit(Task1，可測)、UI 端放行+hint(Task2，run-verify)、doc(Task3)。
- **藍圖約束遵守**：只最小邊界離場、復用 has_exited/retreat apply；無「退場代價」/全隊撤退（gold-plate→衝突傘）。
- **測試局限**：UI 鍵入 headless 不可測 → Task1 sim 測試保證機制；Task2 靠 run-verify。
- **既有行為不破**：in-map move 維持 `{type:"move"}` 原路徑；只 off-map target 轉 retreat。
- **執行時確認**：Task1 Step1 的回合驅動 public 入口名（`advance_encounter` 或既有 `_enc` 測試用法）；Task2 hint label 的集中與否。
