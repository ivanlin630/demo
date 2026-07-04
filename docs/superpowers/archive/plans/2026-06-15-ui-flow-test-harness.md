# UI-flow 測試 harness Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 建 headless UI-flow 整合測試 harness：實例化 TextUI.tscn → 注入 bridge state → 驅動鍵盤 handler → 斷言 label/state。自動抓輸入流/選單/顯示 class bug，省手動 GUI 驗。

**Architecture:** 新 `scripts/debug/ui_flow_test.gd`（extends SceneTree）。helper：實例化場景(await _ready)、注入 state、驅動 key、斷言、free。首批測試覆蓋 U19/U21/U12/hunt（已修的應 PASS，證 harness 有效）。

**Tech Stack:** Godot 4.2.2 GDScript headless SceneTree；`.\tools\godot.ps1`。可行性已 smoke 驗（2026-06-15）。

依據 spec：`docs/superpowers/specs/2026-06-15-ui-flow-test-harness-design.md`。

---

## 檔案結構

- `scripts/debug/ui_flow_test.gd`（建）：harness + 測試。

已驗事實（smoke）：`load("res://scenes/TextUI.tscn").instantiate()` + `get_root().add_child()` → `_ready` 建 `_state_label`/`_event_label`/`_bridge`(12 teams from default.json)；`node._handle_interact_mode(keycode)` 可呼叫；`node._bridge.get_state()` 可注入；2× `await process_frame` 足夠 _ready。

---

## Task 1: harness scaffold + 自我 smoke

**Files:**
- Create: `scripts/debug/ui_flow_test.gd`

- [ ] **Step 1: 寫 harness + 第一個 smoke 測試**

```gdscript
extends SceneTree

var _errors: int = 0

func _initialize() -> void:
	await _test_harness_smoke()
	# 後續測試在此依序 await
	print("\n=== UI Flow Test DONE === errors: %d" % _errors)
	quit()

func _check(label: String, ok: bool) -> void:
	print(("  PASS: " if ok else "  FAIL: ") + label)
	if not ok: _errors += 1

# 實例化 TextUI 場景 + 等 _ready。回傳 node。
func _make_ui() -> Node:
	var node = load("res://scenes/TextUI.tscn").instantiate()
	get_root().add_child(node)
	await process_frame
	await process_frame
	return node

func _free_ui(node: Node) -> void:
	node.queue_free()
	await process_frame

func _test_harness_smoke() -> void:
	print("\n── harness smoke ──")
	var node = await _make_ui()
	_check("node 實例化", node != null)
	_check("_state_label 存在", node.get("_state_label") != null)
	_check("_bridge 存在", node.get("_bridge") != null)
	_check("_handle_interact_mode 可呼叫", node.has_method("_handle_interact_mode"))
	await _free_ui(node)
```

- [ ] **Step 2: 跑**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/ui_flow_test.gd`
Expected: harness smoke 全 PASS、`errors: 0`、無 SCRIPT ERROR。

- [ ] **Step 3: Commit**

```bash
git add scripts/debug/ui_flow_test.gd
git commit -m "test(ui-flow): harness scaffold + 自我 smoke"
```

---

## Task 2: U19 forced 自動進選單

**Files:**
- Modify: `scripts/debug/ui_flow_test.gd`

- [ ] **Step 1: 寫測試**

```gdscript
func _test_u19_forced_auto_enter() -> void:
	print("\n── U19 forced 自動進互動 ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	# 注入一個對玩家的 forced_event（仿 diplomacy/aid）
	st.player_forced_event = { "action": "diplomacy", "from_id": 1, "proposal": "demand_tribute" }
	st.player_forced_event_id = "test"
	node._interact_mode = false
	node._process(0.0)   # _process 應偵測 forced → 進互動模式
	_check("forced 事件 → 自動進互動模式", node._interact_mode == true)
	await _free_ui(node)
```

註：`_process` 內讀 `_cached_snapshot.forced_interaction`；確認 `_process` 先 `_refresh()`（更新 snapshot）再判 forced（讀現行 `_process`：line ~152 `_refresh()` 後讀 ps + forced 分支）。若 `_process` 早段 `if not is_advancing(): return` 擋住，測試需先 `node._bridge.request_advance(1)` 或直接呼叫 forced 偵測段。實作者讀 `_process` 對齊：必要時改呼叫驅動 forced 偵測的最小公開路徑。

- [ ] **Step 2: 跑** — 應 PASS（U19 已修）。若 FAIL → 確認 `_process` 驅動路徑（見註）。
- [ ] **Step 3: 註冊** `_initialize` 加 `await _test_u19_forced_auto_enter()`。
- [ ] **Step 4: Commit**

```bash
git commit -am "test(ui-flow): U19 forced 自動進互動模式"
```

---

## Task 3: U21 互動選單分頁

**Files:**
- Modify: `scripts/debug/ui_flow_test.gd`

- [ ] **Step 1: 寫測試**

```gdscript
func _test_u21_interact_paging() -> void:
	print("\n── U21 互動選單分頁 ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var pid: int = st.player_id
	var ptid: int = st.persons[pid].team_id
	var ppos = st.teams[ptid].tile_pos
	# 造 12 個同格 discovered 隊（>9 → 需翻頁）
	var made: Array = []
	for i in range(12):
		var t := TeamData.new()
		t.team_id = 5000 + i; t.tile_pos = ppos; t.population = 3; t.faction_id = -1
		st.teams[t.team_id] = t
		st.team_discovered[ptid] = st.team_discovered.get(ptid, [])
		st.team_discovered[ptid].append(t.team_id)
		made.append(t.team_id)
	node._interact_mode = true
	node._interact_target = -1
	node._interact_page = 0
	node._bridge.refresh_interaction_targets()
	node._refresh()
	# 翻到第 2 頁，按 KEY_1 → 應選到第 10 個 pending（全域 idx 9）
	node._handle_interact_mode(KEY_PERIOD)   # 下一頁
	node._handle_interact_mode(KEY_1)        # 該頁第 1 = 全域第 10
	_check("分頁後可選第 10+ 項（_interact_target 已設）", node._interact_target != -1)
	await _free_ui(node)
```

註：pending_targets 由 `refresh_interaction_targets` 依同格 + can_interact 掃出。確認 12 個同格隊都進 pending（若 can_interact 過濾掉部分，調整造隊條件或斷言改「翻頁後 KEY_1 選到的 target 屬第二頁範圍」）。實作者讀 `refresh_interaction_targets`/pending 過濾對齊。

- [ ] **Step 2: 跑** — 應 PASS（U21 已修）。
- [ ] **Step 3: 註冊 + Commit**

```bash
git commit -am "test(ui-flow): U21 互動選單分頁可選 10+"
```

---

## Task 4: U12 交易顯示 + hunt 動作可選

**Files:**
- Modify: `scripts/debug/ui_flow_test.gd`

- [ ] **Step 1: 寫測試**

```gdscript
func _test_u12_trade_str() -> void:
	print("\n── U12 交易顯示有資源 ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var ptid: int = st.persons[st.player_id].team_id
	var ppos = st.teams[ptid].tile_pos
	st.teams[ptid].resources["food"] = 50.0
	# 同格鄰隊有 coin
	var other := TeamData.new()
	other.team_id = 6001; other.tile_pos = ppos; other.population = 5
	other.resources = {"coin": 100}
	st.teams[6001] = other
	node._trade_mode = true
	node._trade_target_id = 6001
	var s: String = node._build_trade_str()
	_check("交易字串非『無資源』", not s.contains("無可交換") and not s.contains("無資源"))
	await _free_ui(node)

func _test_hunt_action_listed() -> void:
	print("\n── hunt 動作可選 ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var ptid: int = st.persons[st.player_id].team_id
	var tile = st.world.tiles.get(st.teams[ptid].tile_pos.x*1000 + st.teams[ptid].tile_pos.y)
	if tile != null: tile.resources["wild_game"] = 5
	node._refresh()
	var acts: Array = node._cached_snapshot.get("available_actions", [])
	var ids: Array = []
	for a in acts: ids.append(a.get("action_id",""))
	_check("腳下 wild_game → available_actions 含 hunt", "hunt" in ids)
	await _free_ui(node)
```

註：`_build_trade_str` / trade preview 路徑依現行碼（U12 已加 direct preview）；確認函數名 + trade_mode 欄位（讀現行 trade 模式）。hunt：依 P1 available_actions Layer。實作者對齊實際欄位名。

- [ ] **Step 2: 跑** — U12/hunt 應 PASS（已修）。若 FAIL → 揭露 U12 GUI 路徑真相（headless 抓到 = 正是 harness 價值）。
- [ ] **Step 3: 註冊 + Commit**

```bash
git commit -am "test(ui-flow): U12 交易顯示 + hunt 動作可選"
```

---

## Task 5: 註冊全部 + 文件

**Files:**
- Modify: `scripts/debug/ui_flow_test.gd`（`_initialize` 串起全部）
- Modify: `docs/progress.md`（記 harness）

- [ ] **Step 1: 確認 `_initialize` await 串起全部測試**
- [ ] **Step 2: 全跑** — `errors: 0`、無 SCRIPT ERROR。**若某案 FAIL = 真抓到 GUI bug**（記 known_issues，屬 harness 立功）。
- [ ] **Step 3: progress 記 ui_flow_test harness（未來 UI 修加對應 flow 測試自動回歸）**
- [ ] **Step 4: handback** — `docs/superpowers/handbacks/2026-06-15-ui-flow-test-harness.md`，附各案 PASS/FAIL + harness 用法。

---

## 注意事項（給實作者）

- **每測試獨立 `_make_ui` + `_free_ui`**（await frame），免 node 殘留。
- **default.json 預設 state 干擾**：注入前清/覆蓋相關欄位（pending/forced/resources）。
- **驅動路徑對齊現行碼**：`_process` 的 forced 偵測 / `refresh_interaction_targets` 的 pending 過濾 / `_build_trade_str` 欄位 — 讀現行 text_ui_main 對齊，**不臆造**。
- **harness 測真碼**（呼叫 node 真方法 + 讀真 label/state），不鏡像 UI 邏輯。
- **若已修案 FAIL**：先查是 harness 驅動沒對齊（修測試）還是真 bug 殘留（記 known_issues）。
- 真·視覺（旗色/佈局/U16 fog）不在本 harness 範圍。
- 純測試新增，不改 sim/UI 產品碼。
