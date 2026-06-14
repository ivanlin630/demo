extends SceneTree

var _errors: int = 0

func _initialize() -> void:
	await _test_harness_smoke()
	await _test_u19_forced_auto_enter()
	await _test_u21_interact_paging()
	await _test_u12_trade_str()
	await _test_hunt_action_listed()
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

# U19：對玩家的 forced_event → _process 應自動進互動模式（否則玩家無從回應 → 卡死）。
# 真路徑：snapshot.forced_interaction 由 map_forced_interaction(state.player_forced_event) 產生；
# _process 早段 `if not is_advancing(): return` → 須先 request_advance 才會跑到 forced 偵測分支。
func _test_u19_forced_auto_enter() -> void:
	print("\n── U19 forced 自動進互動 ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	# 注入一個對玩家的 forced_event（diplomacy/demand_tribute）
	st.player_forced_event = { "action": "diplomacy", "from_id": 1, "proposal": "demand_tribute" }
	st.player_forced_event_id = "test"
	node._interact_mode = false
	node._bridge.request_advance(1)   # _process 早段需 is_advancing 才往下跑
	node._process(0.0)
	_check("forced 事件 → 自動進互動模式", node._interact_mode == true)
	await _free_ui(node)

# U21：互動選單 >9 項時 [.] 翻頁後 KEY_1 應選到全域第 10 項（解 10+ 選不到的 bug）。
# 真路徑：pending_targets 來自 state.player_pending_targets，由 refresh_colocation_targets
# 掃同格（tile_pos == 玩家、combat_target == -1）填入，與 team_discovered 無關。
func _test_u21_interact_paging() -> void:
	print("\n── U21 互動選單分頁 ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var pid: int = st.player_id
	var ptid: int = st.persons[pid].team_id
	var ppos = st.teams[ptid].tile_pos
	# 造 12 個同格隊（combat_target 預設 -1 → 全進 pending）
	for i in range(12):
		var t := TeamData.new()
		t.team_id = 5000 + i
		t.tile_pos = ppos
		t.population = 3
		t.faction_id = -1
		st.teams[t.team_id] = t
	node._interact_mode = true
	node._interact_target = -1
	node._interact_page = 0
	node._bridge.refresh_interaction_targets()
	node._refresh()
	var pending_n: int = node._cached_snapshot.get("pending_targets", []).size()
	_check("pending_targets >9（造同格隊成功）", pending_n > 9)
	# 翻到第 2 頁，按 KEY_1 → 全域 idx 9（第 10 項）
	node._handle_interact_mode(KEY_PERIOD)   # 下一頁
	node._handle_interact_mode(KEY_1)        # 該頁第 1 = 全域第 10
	_check("分頁後可選第 10+ 項（_interact_target 已設）", node._interact_target != -1)
	await _free_ui(node)

# U12：交易確認顯示真有資源（解過去顯「無資源」的 GUI 路徑 bug）。
# 真路徑：_build_trade_str → query_trade_direct_preview → InteractionSystem.preview_trade。
# preview API 需 target 在玩家 team_discovered 內，否則回 not_visible（無 preview）。
func _test_u12_trade_str() -> void:
	print("\n── U12 交易顯示有資源 ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var ptid: int = st.persons[st.player_id].team_id
	var ppos = st.teams[ptid].tile_pos
	st.teams[ptid].resources["food"] = 50.0   # from_food>10 → preview gives food
	# 同格鄰隊（food 少 → 玩家付出食物 → feasible）
	var other := TeamData.new()
	other.team_id = 6001
	other.tile_pos = ppos
	other.population = 5
	other.resources = {"coin": 100, "food": 0}
	st.teams[6001] = other
	# preview API 需 target 已發現
	st.team_discovered[ptid] = st.team_discovered.get(ptid, [])
	if not st.team_discovered[ptid].has(6001):
		st.team_discovered[ptid].append(6001)
	node._trade_mode = true
	node._trade_target_id = 6001
	var s: String = node._build_trade_str()
	_check("交易字串非『無可交換』", not s.contains("無可交換") and not s.contains("無資源"))
	await _free_ui(node)

# hunt：腳下 tile 有 wild_game → snapshot.available_actions 應含 hunt（P1 Layer 6 self/tile 動作）。
func _test_hunt_action_listed() -> void:
	print("\n── hunt 動作可選 ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var ptid: int = st.persons[st.player_id].team_id
	var ppos = st.teams[ptid].tile_pos
	var tile = st.world.tiles.get(ppos.x * 1000 + ppos.y)
	_check("玩家腳下 tile 存在", tile != null)
	if tile != null:
		tile.resources["wild_game"] = 5
	node._refresh()
	var acts: Array = node._cached_snapshot.get("available_actions", [])
	var ids: Array = []
	for a in acts:
		ids.append(a.get("action_id", ""))
	_check("腳下 wild_game → available_actions 含 hunt", "hunt" in ids)
	await _free_ui(node)
