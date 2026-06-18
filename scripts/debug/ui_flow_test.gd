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
	await _test_forced_choose_heir_ui()
	await _test_forced_aid_request_ui()
	await _test_interact_self_team_split()
	await _test_recruit_named_reachable()
	await _test_player_status_label()
	await _test_train_action_reachable()
	await _test_camp_action_reachable()
	await _test_q7_3_take_loot_flow()
	await _test_q7_5_dispatch_subteam_task()
	await _test_q7_6_faction_gate_leader()
	await _test_n1_subteam_promote_anon_hint()
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

func _test_train_action_reachable() -> void:
	print("\n── 訓練 self-action 可達 ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var pt = st.teams[st.persons[st.player_id].team_id]
	pt.resources["coin"] = 100.0
	AnonTierSystem.add_anon(pt, "平民", 4)
	node._interact_mode = true; node._interact_target = -1
	node._refresh()
	var self_ids: Array = []
	for a in node._interact_action_split()["self"]: self_ids.append(a.get("action_id",""))
	_check("train 在 self-actions", "train" in self_ids)
	await _free_ui(node)

func _test_camp_action_reachable() -> void:
	print("\n── 紮營 self-action 可達 ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var pt = st.teams[st.persons[st.player_id].team_id]
	var tile = st.world.tiles.get(pt.tile_pos.x*1000 + pt.tile_pos.y)
	if tile != null:
		tile.outpost_level = 0; tile.outpost_owner = -1; tile.terrain = "plains"
	# N-3: camp 現有 _check_distance 真 gate → 清掉附近既有 outpost 才能通過（gate 通過時仍可達）
	for tid in st.world.tiles:
		var t = st.world.tiles[tid]
		if t != tile: t.outpost_level = 0; t.outpost_owner = -1
	node._interact_mode = true; node._interact_target = -1
	node._refresh()
	var self_ids: Array = []
	for a in node._interact_action_split()["self"]: self_ids.append(a.get("action_id",""))
	_check("camp 在 self-actions（gate 通過時可達）", "camp" in self_ids)
	# N-3 反向：腳下相鄰格放一個 outpost → 距離 gate 擋下 → camp 不列（消選後才拒）
	var near_pos = Vector2i(pt.tile_pos.x + 1, pt.tile_pos.y)
	var near = st.world.tiles.get(near_pos.x*1000 + near_pos.y)
	if near == null:
		near = HexTileData.new(); near.tile_pos = near_pos; st.world.tiles[near_pos.x*1000+near_pos.y] = near
	near.outpost_level = 1; near.outpost_owner = 999; near.outpost_type = "civilian"
	node._refresh()
	var self_ids2: Array = []
	for a in node._interact_action_split()["self"]: self_ids2.append(a.get("action_id",""))
	_check("距離太近時 camp 不列（N-3 gate）", not ("camp" in self_ids2))
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

# Q7-1：forced choose_heir → UI DTO responses 列候選（非只拒絕）→ 選擇 → leader 接位 + forced 清
func _test_forced_choose_heir_ui() -> void:
	print("\n── Q7-1 forced choose_heir UI ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var ptid: int = st.persons[st.player_id].team_id
	var pt = st.teams[ptid]
	# 模擬玩家 leader 已死,擇繼承人。取兩名現有 named 當候選（或新建）
	var cands: Array = []
	for pid in pt.named_members:
		if pid != pt.leader_id:
			cands.append(pid)
		if cands.size() >= 2: break
	while cands.size() < 2:
		var np := PersonData.new(); np.id = 90000 + cands.size(); np.team_id = ptid
		np.person_name = "候選%d" % cands.size()
		st.persons[np.id] = np; pt.named_members.append(np.id); cands.append(np.id)
	pt.leader_id = -1
	st.player_forced_event = { "action": "choose_heir", "team_id": ptid, "candidates": cands }
	st.player_forced_event_id = "heir-ui"
	node._bridge.request_advance(1)
	node._process(0.1)
	var fi: Dictionary = node._cached_snapshot.get("forced_interaction", {})
	var resp_ids: Array = []
	for r in fi.get("responses", []): resp_ids.append(r.get("response_id", ""))
	_check("forced responses 列候選（非只拒絕）", resp_ids.size() == 2 and ("heir_%d" % int(cands[0])) in resp_ids)
	# 驅動選第一候選（forced 回應 = num 0 → KEY_1,因 fe_count>0 時 idx 0 對應第一 response）
	node._handle_interact_mode(KEY_1)
	_check("choose_heir 後 leader 接位", st.teams[ptid].leader_id == int(cands[0]))
	_check("choose_heir 後 forced 清除", st.player_forced_event.is_empty())
	await _free_ui(node)

# Q7-2：forced aid_request → UI DTO responses 含 give（非只拒絕）→ 選 give → 守恆轉糧 + forced 清
func _test_forced_aid_request_ui() -> void:
	print("\n── Q7-2 forced aid_request UI ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var ptid: int = st.persons[st.player_id].team_id
	var pt = st.teams[ptid]
	pt.resources["food"] = 100.0
	var ppos = pt.tile_pos
	var b := TeamData.new(); b.team_id = 8889; b.population = 4; b.tile_pos = ppos
	b.resources["food"] = 0.0
	var bl := PersonData.new(); bl.id = 88890; bl.team_id = 8889
	st.persons[88890] = bl; b.leader_id = 88890
	st.teams[8889] = b
	st.player_forced_event = { "action": "aid_request", "from_id": 8889 }
	st.player_forced_event_id = "aid-ui"
	node._bridge.request_advance(1)
	node._process(0.1)
	var fi: Dictionary = node._cached_snapshot.get("forced_interaction", {})
	var resp_ids: Array = []
	for r in fi.get("responses", []): resp_ids.append(r.get("response_id", ""))
	_check("forced responses 含 give（非只拒絕）", "give" in resp_ids and "refuse" in resp_ids)
	# give 是第一 response（options ["give","refuse"]）→ KEY_1
	var food_before: float = float(pt.resources["food"]) + float(b.resources["food"])
	node._handle_interact_mode(KEY_1)
	_check("aid give 後 beggar 收糧", float(b.resources["food"]) > 0.0)
	_check("aid give 守恆", is_equal_approx(food_before, float(pt.resources["food"]) + float(b.resources["food"])))
	_check("aid 後 forced 清除", st.player_forced_event.is_empty())
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

# Q7-3：戰後 loot_pool 非空 → [K]take_loot 經 bridge 真把戰利品入庫、清 last_encounter_result。
func _test_q7_3_take_loot_flow() -> void:
	print("\n── Q7-3 戰後 take_loot 端到端 ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var ptid: int = st.persons[st.player_id].team_id
	var pt = st.teams[ptid]
	var before_food: float = float(pt.resources.get("food", 0))
	# 敗隊持有食物 → loot_pool 取自其資源
	var loser := TeamData.new(); loser.team_id = 7700; loser.population = 3
	loser.resources["food"] = 100.0
	st.teams[7700] = loser
	# 模擬戰勝結算結果（玩家為 winner）
	st.last_encounter_result = {
		"winner_id": ptid, "loser_id": 7700,
		"loot_pool": {"food": 30.0}, "can_subjugate": true,
	}
	# hint 應提示 [K]/[L]
	var EncView = load("res://scripts/ui/encounter_view.gd")
	var hint: String = EncView._post_combat_hint(st.last_encounter_result)
	_check("post-combat hint 含 K/L 戰利品", hint.contains("K") and hint.contains("L"))
	# 執行 take_loot command（encounter_view 的 [K] 派的就是這個）
	var r = node._bridge.command_player("execute_action",
		{"action_id": "take_loot", "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}})
	_check("take_loot 經 bridge 成功", r.get("ok", false))
	_check("玩家食物 +30 入庫", abs(float(pt.resources.get("food", 0)) - (before_food + 30.0)) < 0.01)
	_check("敗隊食物 -30", abs(float(loser.resources.get("food", 0)) - 70.0) < 0.01)
	_check("last_encounter_result 已清", st.last_encounter_result.is_empty())
	await _free_ui(node)

# Q7-5：子隊派遣可選非 IDLE 任務。command 介面不變,UI 經 set_player_input("sub_task", 選定) 真派出帶任務子隊。
func _test_q7_5_dispatch_subteam_task() -> void:
	print("\n── Q7-5 子隊派遣帶任務 ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var ptid: int = st.persons[st.player_id].team_id
	var pt = st.teams[ptid]
	pt.population = 10
	AnonTierSystem.add_anon(pt, "平民", 8)
	# 注入命名非 leader 成員當子隊長
	var m := PersonData.new(); m.id = 95001; m.team_id = ptid; m.skills["統領"] = 0.5
	st.persons[95001] = m; pt.named_members.append(95001)
	# 選單 index→task 映射正確（覓食非 idle）
	_check("選單字串含覓食", TextUiMain._subteam_task_menu_str().contains("覓食"))
	var forage_task: String = TextUiMain._subteam_task_from_index(2)
	_check("index 2 → 覓食(非 idle)", forage_task == TeamData.TASK_FORAGE and forage_task != TeamData.TASK_IDLE)
	# 經 set_player_input 帶任務派遣（與 UI callback 同路徑）
	node._bridge.set_player_input("sub_leader_id", 95001)
	node._bridge.set_player_input("sub_pop_count", 3)
	node._bridge.set_player_input("sub_task", forage_task)
	node._bridge.set_player_input("sub_move_q", pt.tile_pos.x)
	node._bridge.set_player_input("sub_move_r", pt.tile_pos.y)
	var r = node._bridge.command_player("execute_action",
		{"action_id": "dispatch_subteam", "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}})
	_check("dispatch_subteam 成功", r.get("ok", false))
	# 經 parent.subteam_ids 找剛派出的子隊（command 不回傳 sub_id）
	var sub_id: int = pt.subteam_ids[-1] if not pt.subteam_ids.is_empty() else -1
	_check("子隊 current_task = 覓食（非寫死 IDLE）",
		sub_id != -1 and st.teams.has(sub_id) and st.teams[sub_id].current_task == TeamData.TASK_FORAGE)
	await _free_ui(node)

# Q7-6：非 faction leader → 面板不顯 [A]目標 [B]徵收率（display 對齊 command 權限）；leader 則顯。
func _test_q7_6_faction_gate_leader() -> void:
	print("\n── Q7-6 faction 設定鈕 gate leader ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var ptid: int = st.persons[st.player_id].team_id
	var fac := FactionData.new(); fac.faction_id = 556
	# 另一隊當 leader → 玩家是普通成員
	fac.leader_team_id = 99999
	st.factions[556] = fac
	st.teams[ptid].faction_id = 556
	node._faction_mode = true
	var s_member: String = node._build_faction_str()
	_check("非 leader 不顯 [A]設定目標", not s_member.contains("[A]設定目標"))
	_check("非 leader 不顯 [B]調整徵收率", not s_member.contains("[B]調整徵收率"))
	_check("非 leader 仍可離開勢力 [C]", s_member.contains("[C]離開勢力"))
	# 改玩家為 leader → 顯 [A]/[B]
	fac.leader_team_id = ptid
	var s_leader: String = node._build_faction_str()
	_check("leader 顯 [A]設定目標", s_leader.contains("[A]設定目標"))
	_check("leader 顯 [B]調整徵收率", s_leader.contains("[B]調整徵收率"))
	await _free_ui(node)

# N-1：全 anon 隊（leader + anon,無命名非 leader 成員）開子隊面板 → 引導去互動選單 promote_anon。
func _test_n1_subteam_promote_anon_hint() -> void:
	print("\n── N-1 子隊面板 promote_anon 引導 ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var ptid: int = st.persons[st.player_id].team_id
	var pt = st.teams[ptid]
	# 清空命名非 leader 成員（保留 leader）→ dispatch_candidates 空
	for mid in pt.named_members.duplicate():
		if mid != pt.leader_id:
			pt.named_members.erase(mid)
	AnonTierSystem.add_anon(pt, "平民", 5)   # 有 anon 可拔擢
	node._subteam_mode = true
	var s_anon: String = node._build_subteam_str()
	_check("全 anon 隊面板含 promote_anon 引導", s_anon.contains("拔擢匿名"))
	_check("不再只顯舊死路字（需命名非 leader 成員）", not s_anon.contains("（無：需命名非 leader 成員）"))
	# 無 anon 時退回舊死路字（不誤導）：清光全 tier/health anon
	for tier in AnonCohort.TIER_ORDER:
		for health in AnonCohort.HEALTH_ORDER:
			AnonCohort.remove(pt.anon_cohorts, tier, health, 999999)   # remove 自帶 clamp
	_check("anon 已清空", AnonTierSystem.total_pop(pt) == 0)
	var s_empty: String = node._build_subteam_str()
	_check("無 anon 時退回舊死路字", s_empty.contains("（無：需命名非 leader 成員）"))
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
