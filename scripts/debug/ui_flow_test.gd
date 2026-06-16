extends SceneTree

var _errors: int = 0

func _initialize() -> void:
	await _test_harness_smoke()
	await _test_u19_forced_auto_enter()
	await _test_u21_interact_paging()
	await _test_u12_trade_str()
	await _test_trade_offer_builder()
	await _test_hunt_action_listed()
	await _test_armed_count_shown()
	await _test_member_equip_flow()
	await _test_armed_ratio_cmd()
	await _test_storage_panel_ui()
	await _test_outpost_build_abandon()
	await _test_faction_extract_treasury()
	await _test_u15_overlay_input_guard()
	await _test_capabilities_shown()
	await _test_join_request_ui()
	await _test_interact_self_team_split()
	await _test_recruit_named_reachable()
	await _test_player_status_label()
	print("\n=== UI Flow Test DONE === errors: %d" % _errors)
	quit()

# P4-2:self/原地動作(hunt)應在 self-actions(目標選擇階段直接可選),不混進 team-target 行動清單。
func _test_interact_self_team_split() -> void:
	print("\n── P4-2 互動 self/team 動作分離 ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var ptid: int = st.persons[st.player_id].team_id
	var ppos = st.teams[ptid].tile_pos
	var tile = st.world.tiles.get(ppos.x * 1000 + ppos.y)
	if tile == null:
		tile = HexTileData.new(); tile.tile_pos = ppos; st.world.tiles[ppos.x*1000+ppos.y] = tile
	tile.resources["wild_game"] = 5   # → hunt 可用
	var other := TeamData.new(); other.team_id = 7001; other.tile_pos = ppos
	other.population = 5; other.faction_id = -1
	st.teams[7001] = other
	st.team_discovered[ptid] = [7001]
	node._interact_mode = true; node._interact_target = -1
	node._bridge.refresh_interaction_targets()
	node._refresh()
	var split: Dictionary = node._interact_action_split()
	var self_ids: Array = []
	for a in split["self"]: self_ids.append(a.get("action_id", ""))
	_check("hunt 在 self-actions（不需先選隊）", "hunt" in self_ids)
	_check("目標選擇階段顯 hunt label", node._build_interact_str().contains("狩獵"))
	# 聚焦該隊 → team 行動清單不含 hunt
	node._interact_target = 7001
	node._refresh()
	var team_ids: Array = []
	for a in node._interact_action_split()["team"]: team_ids.append(a.get("action_id", ""))
	_check("team 行動清單不含 hunt", not ("hunt" in team_ids))
	await _free_ui(node)

func _test_join_request_ui() -> void:
	print("\n── join_request 收留 UI ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var ptid: int = st.persons[st.player_id].team_id
	st.teams[ptid].resources["food"] = 50.0
	var ppos = st.teams[ptid].tile_pos
	var ds := TeamData.new(); ds.team_id = 8888; ds.population = 3; ds.tile_pos = ppos
	st.teams[8888] = ds
	st.player_forced_event = {"action": "join_request", "from_id": 8888}
	st.player_forced_event_id = "t1"
	node._bridge.request_advance(1)   # _process 早段需 is_advancing 才往下跑
	node._process(0.1)   # U19 自動進 forced 模式
	var s: String = node._event_label.text
	_check("forced 顯收留選項", s.contains("收留") or s.contains("投靠") or s.contains("婉拒"))
	await _free_ui(node)

# A-1：記名招募在 TextUI 主場景可達。
# 真路徑：recruit action 回 menu payload（has_willing_named/willing_members/anon_available）；
# team-target handler 須消費此 payload → 進招募子模式 → 玩家選記名 → recruit_named 經 execute_action_with_target 真執行。
func _test_recruit_named_reachable() -> void:
	print("\n── A-1 記名招募 TextUI 可達 ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var pid: int = st.player_id
	var ptid: int = st.persons[pid].team_id
	var ppos = st.teams[ptid].tile_pos
	st.teams[ptid].resources["coin"] = 300.0   # > named gate 150
	# 同格 NPC 隊：含一名不忠 named 成員（loyalty<0.4）
	var npc := TeamData.new(); npc.team_id = 4321; npc.tile_pos = ppos
	npc.population = 4; npc.faction_id = -1
	st.teams[4321] = npc
	var lead := PersonData.new(); lead.id = 43210; lead.team_id = 4321; lead.loyalty = 0.9
	st.persons[43210] = lead; npc.leader_id = 43210; npc.named_members.append(43210)
	var disloyal := PersonData.new(); disloyal.id = 43211; disloyal.team_id = 4321
	disloyal.loyalty = 0.2; disloyal.person_name = "叛徒"; disloyal.skills = {"戰鬥": 0.5}
	st.persons[43211] = disloyal; npc.named_members.append(43211)
	# 進互動模式，直接聚焦該隊（對齊 main P4-2 互動模型：set _interact_target，不靠鍵碼索引）
	st.team_discovered[ptid] = st.team_discovered.get(ptid, [])
	if not st.team_discovered[ptid].has(4321): st.team_discovered[ptid].append(4321)
	st.player_pending_targets.append(4321)
	node._interact_mode = true
	node._interact_page = 0
	node._interact_target = 4321
	node._refresh()
	_check("已聚焦 NPC（_interact_target=4321）", node._interact_target == 4321)
	# recruit 為 team-target 動作（P4-2 後在 _interact_action_split()["team"]，非 available_actions）
	var team_acts: Array = node._interact_action_split()["team"]
	var recruit_idx: int = -1
	for i in range(team_acts.size()):
		if team_acts[i].get("action_id", "") == "recruit":
			recruit_idx = i; break
	_check("team 行動清單含 recruit", recruit_idx >= 0)
	if recruit_idx < 0 or recruit_idx >= 9:
		await _free_ui(node); return
	node._handle_interact_mode(KEY_1 + recruit_idx)   # 選 recruit → 進招募子模式
	# 斷言：進入招募子選單（顯記名候選 + 匿名選項）
	var rs: String = node._event_label.text
	print("  recruit 子選單文字: %s" % rs.replace("\n", " | "))
	_check("進招募子模式（_current_mode_name=recruit）", node._current_mode_name() == "recruit")
	_check("子選單顯記名候選（叛徒）", rs.contains("叛徒") or rs.contains("記名"))
	_check("子選單顯匿名選項", rs.contains("匿名"))
	# 選記名候選（第 1 個）→ recruit_named 真執行
	var coin_before: float = float(st.teams[ptid].resources.get("coin", 0))
	node._handle_recruit_mode(KEY_1)
	_check("recruit_named 執行：成員轉到玩家隊", st.persons[43211].team_id == ptid)
	_check("recruit_named 執行：coin 扣 150", abs(coin_before - float(st.teams[ptid].resources.get("coin", 0)) - 150.0) < 0.01)
	await _free_ui(node)

func _test_capabilities_shown() -> void:
	print("\n── 隊能力讀數顯示 ──")
	var node = await _make_ui()
	node._refresh()
	# status label 應含能力讀數關鍵字
	var s: String = node._state_label.text
	_check("status 含獵率", s.contains("獵") or s.contains("狩獵"))
	_check("status 含戰力", s.contains("戰力"))
	_check("status 含日耗", s.contains("日耗") or s.contains("耗"))
	await _free_ui(node)

# 公庫面板：自家 outpost + 雙向資源 → 顯存入/取出 + food
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

# outpost 面板：自家 outpost → 顯設施/棄置行動列
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

# faction 面板：玩家為 leader → 顯徵用國庫
func _test_faction_extract_treasury() -> void:
	print("\n── faction extract_treasury ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var ptid: int = st.persons[st.player_id].team_id
	var fac := FactionData.new(); fac.faction_id = 555; fac.leader_team_id = ptid
	st.factions[555] = fac
	st.teams[ptid].faction_id = 555
	node._faction_mode = true
	var s: String = node._build_faction_str()
	_check("faction 面板顯提幣", s.contains("提幣") or s.contains("徵用") or s.contains("國庫"))
	await _free_ui(node)

func _test_member_equip_flow() -> void:
	print("\n── 成員裝備 flow ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var ptid: int = st.persons[st.player_id].team_id
	# 注入名成員 + 武器池
	var m := PersonData.new(); m.id = 99001; m.team_id = ptid
	st.persons[99001] = m; st.teams[ptid].named_members.append(99001)
	st.teams[ptid].resources["weapon_melee_low"] = 2
	node._member_mode = true; node._member_detail_submode = 2; node._member_selection = 0
	node._refresh()
	var r = node._bridge.command_player("execute_action",
		{"action_id":"equip_member","target":{"kind":"member","team_id":ptid,"member_id":99001,"slot_id":"hand_1","item_grade":"weapon_melee_low"}})
	_check("equip_member 經 bridge 成功", r.get("ok", false))
	_check("成員裝上武器", st.persons[99001].equipment["hand_1"].get("grade","") == "weapon_melee_low")
	_check("status 含武裝比例", node._state_label.text.contains("比例"))
	await _free_ui(node)

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

func _test_armed_count_shown() -> void:
	print("\n── 自隊武裝數顯示 ──")
	var node = await _make_ui()
	node._refresh()
	_check("status 含「武裝」", node._state_label.text.contains("武裝"))
	await _free_ui(node)

# U15：遭遇戰 overlay 顯示中，主畫面 _input 須一律不處理（否則戰後按 Q→quit 閃退、WASD 漂游標）。
# 測：overlay visible → 送 KEY_W → _cursor 不動（證 guard early-return）。
func _test_u15_overlay_input_guard() -> void:
	print("\n── U15 overlay 輸入守衛 ──")
	var node = await _make_ui()
	node._encounter_view.visible = true
	var before: Vector2i = node._cursor
	var ev := InputEventKey.new()
	ev.keycode = KEY_W
	ev.pressed = true
	node._input(ev)
	_check("overlay 可見時 KEY_W 被吞（_cursor 不變）", node._cursor == before)
	# 反證：overlay 隱藏 → KEY_W 應移游標
	node._encounter_view.visible = false
	node._input(ev)
	_check("overlay 隱藏時 KEY_W 移游標（_cursor 變）", node._cursor != before)
	await _free_ui(node)

func _test_player_status_label() -> void:
	print("\n── 玩家隊狀態 label（非任務）──")
	var node = await _make_ui()
	node._refresh()
	var s: String = node._state_label.text
	_check("狀態列用「狀態:」不用「任務:」", s.contains("狀態:") and not s.contains("任務:"))
	await _free_ui(node)

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

# offer-builder：建構出價後 _build_trade_str 應顯雙欄(給/要)+天平，且非舊「無可交換」
func _test_trade_offer_builder() -> void:
	print("\n── 交易 offer-builder ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var ptid: int = st.persons[st.player_id].team_id
	var ppos = st.teams[ptid].tile_pos
	st.teams[ptid].resources["food"] = 50.0
	var npc := TeamData.new(); npc.team_id = 7777; npc.tile_pos = ppos; npc.population = 5
	npc.resources = {"coin": 100}
	st.teams[7777] = npc
	node._trade_mode = true; node._trade_target_id = 7777
	st.player_state["pending_trade_target"] = 7777
	st.player_state["trade_offer"] = {"player_gives": {"food": 10}, "player_wants": {"coin": 10}}
	var s: String = node._build_trade_str()
	_check("交易字串顯天平(給/要值)", s.contains("給") and s.contains("要"))
	_check("非舊『無可交換』", not s.contains("無可交換"))
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
