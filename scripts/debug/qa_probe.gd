extends SceneTree

# QA 探測：驗證已知種子根因 + 幾個 B/C 類落差。純 print，不 assert（避免 headless 卡死）。

func _initialize() -> void:
	await _probe_join_request_population()
	await _probe_main_team_task()
	await _probe_recruit_anon_ui_path()
	await _probe_beg_ui_path()
	await _probe_hunt_beast_ui()
	await _probe_train_b_class()
	await _probe_camp_completion()
	await _probe_panic_guard()
	await _probe_gate_mismatches()
	await _probe_label_scope()
	print("\n=== QA PROBE DONE ===")
	quit()

# B類:train 執行後 state 真變(coin扣/exp/promote) + feedback
func _probe_train_b_class() -> void:
	print("\n── B類 train state+feedback ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var ptid = st.persons[st.player_id].team_id
	var pt = st.teams[ptid]
	# case1: 無 anon → gate
	for t in pt.anon_tiers: pt.anon_tiers[t] = 0
	pt.resources["coin"] = 100.0
	var cmd = PlayerCommandSystem.new()
	var r0 = cmd.execute_action(st, -1, "train")
	print("  無anon: ok=%s msg=%s (期望 ok=false gate)" % [r0.get("ok"), r0.get("msg","")])
	# case2: 有 anon 但 coin 不足
	AnonTierSystem.add_anon(pt, "平民", 5)
	pt.resources["coin"] = 10.0
	var r1 = cmd.execute_action(st, -1, "train")
	print("  coin不足: ok=%s msg=%s (期望 ok=false)" % [r1.get("ok"), r1.get("msg","")])
	print("  coin 未扣? before=10 now=%.1f" % float(pt.resources.get("coin",0)))
	# case3: 正常訓練
	pt.resources["coin"] = 100.0
	var coin_b = float(pt.resources.get("coin",0))
	var r2 = cmd.execute_action(st, -1, "train")
	print("  正常: ok=%s msg=%s" % [r2.get("ok"), r2.get("msg","")])
	print("  coin: %.1f → %.1f (delta=%.1f, 期望 -30)" % [coin_b, float(pt.resources.get("coin",0)), float(pt.resources.get("coin",0))-coin_b])
	print("  anon_exp after=%s" % str(pt.get("anon_exp")))
	await _free(node)

# B類:camp construction 設置 + 完工 → tile lvl1 + 無即時糧 + task release
func _probe_camp_completion() -> void:
	print("\n── B類 camp 完工(lvl1/無即時糧/task釋放) ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var ptid = st.persons[st.player_id].team_id
	var pt = st.teams[ptid]
	# 移到一個遠離既有 outpost 的空格(避免 _check_distance 失敗)
	pt.tile_pos = Vector2i(60, 60)
	var tk = pt.tile_pos.x*1000+pt.tile_pos.y
	var tile = st.world.tiles.get(tk)
	if tile == null:
		tile = HexTileData.new(); tile.tile_pos = pt.tile_pos; st.world.tiles[tk] = tile
	tile.outpost_level = 0; tile.outpost_owner = -1; tile.terrain = "plains"
	tile.resources["food"] = 0.0
	tile.resource_cap["food"] = 0.0
	var cmd = PlayerCommandSystem.new()
	var r = cmd.execute_action(st, -1, "camp")
	print("  發起紮營: ok=%s msg=%s" % [r.get("ok"), r.get("msg","")])
	print("  construction_target=%s ticks_left=%d" % [str(tile.construction_target), tile.construction_ticks_left])
	print("  玩家隊 current_task=%s (期望 建設)" % pt.current_task)
	# 推進建造直到完工
	var os = OutpostSystem.new()
	var guard = 0
	while tile.construction_ticks_left > 0 and guard < 1000:
		os._tick_construction(st, tile)
		guard += 1
	print("  完工後 outpost_level=%d owner=%d type=%s" % [tile.outpost_level, tile.outpost_owner, tile.outpost_type])
	print("  ★去剝削檢查 tile.resources[food]=%.1f (期望 0,不被塞即時糧)" % float(tile.resources.get("food",0)))
	print("  tile.resource_cap[food]=%.1f (期望 >=40 抬cap)" % float(tile.resource_cap.get("food",0)))
	print("  玩家隊 current_task=%s (期望 釋放回 idle/空,非 建設)" % pt.current_task)
	await _free(node)

# panic 守衛:玩家主隊恐慌不被設逃跑 task,但 work_morale 仍受影響
func _probe_panic_guard() -> void:
	print("\n── panic 守衛(玩家主隊不被劫持 task) ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var pid = st.player_id
	var ptid = st.persons[pid].team_id
	var pt = st.teams[ptid]
	print("  玩家隊 leader_id=%d, state.player_id=%d, leader_id==player_id? %s" % [pt.leader_id, pid, pt.leader_id == pid])
	print("  → 守衛條件 team.leader_id != state.player_id;若玩家隊 leader_id==player_id 則跳過劫持")
	await _free(node)

# gate 不一致探測:camp 列出條件 vs 命令拒絕條件;train 列出 vs 命令
func _probe_gate_mismatches() -> void:
	print("\n── gate 不一致(列出 vs 執行) ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var ptid = st.persons[st.player_id].team_id
	var pt = st.teams[ptid]
	# train: 有 anon 但 coin=0 → 列出嗎?執行拒嗎?
	AnonTierSystem.add_anon(pt, "平民", 3)
	pt.resources["coin"] = 0.0
	node._refresh()
	var self_ids = []
	for a in node._interact_action_split()["self"]: self_ids.append(a.get("action_id",""))
	print("  train 在 self(coin=0)? %s (gate 僅查 anon>0,不查 coin)" % ("train" in self_ids))
	var label = ""
	for a in node._interact_action_split()["self"]:
		if a.get("action_id","")=="train": label = a.get("label","")
	print("  train label='%s' (是否提示需 coin?)" % label)
	# camp: 太近既有 outpost → 列出嗎?
	var tile = st.world.tiles.get(pt.tile_pos.x*1000+pt.tile_pos.y)
	if tile != null:
		tile.outpost_level = 0; tile.outpost_owner = -1; tile.terrain = "plains"
		# 鄰格放 outpost 使 _check_distance 失敗
		var os = OutpostSystem.new()
		var ok_dist = os._check_distance(st, tile.tile_pos, "civilian")
		print("  腳下 _check_distance(civilian)=%s" % ok_dist)
	node._refresh()
	self_ids = []
	for a in node._interact_action_split()["self"]: self_ids.append(a.get("action_id",""))
	print("  camp 在 self? %s (query gate 不查 _check_distance)" % ("camp" in self_ids))
	await _free(node)

# label scope:自隊「狀態:」,子隊/成員下令保留「任務」字樣
func _probe_label_scope() -> void:
	print("\n── label scope(自隊狀態 vs 子隊任務) ──")
	var node = await _make_ui()
	node._refresh()
	var s = node._state_label.text
	print("  自隊 status 含「狀態:」? %s  含「任務:」? %s" % [s.contains("狀態:"), s.contains("任務:")])
	await _free(node)

func _make_ui() -> Node:
	var node = load("res://scenes/TextUI.tscn").instantiate()
	get_root().add_child(node)
	await process_frame
	await process_frame
	return node

func _free(node: Node) -> void:
	node.queue_free()
	await process_frame

# 種子1：收留流民後 population 是否真增 + UI controlled_team.population 是否更新
func _probe_join_request_population() -> void:
	print("\n── 種子1 收留流民 population ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var pid = st.player_id
	var ptid = st.persons[pid].team_id
	var pt = st.teams[ptid]
	var leader = st.persons.get(pt.leader_id)
	var cmd_skill = float(leader.skills.get("統領", 0.0)) if leader else 0.0
	var cap = TeamData.pop_cap_from_leadership(cmd_skill)
	print("  玩家 leader 統領=%.3f → pop_cap=%d, 現 population=%d" % [cmd_skill, cap, pt.population])
	pt.resources["food"] = 200.0
	var ppos = pt.tile_pos
	var ds = TeamData.new(); ds.team_id = 91001; ds.population = 8; ds.tile_pos = ppos; ds.faction_id = -1
	st.teams[91001] = ds
	var before = pt.population
	st.player_forced_event = {"action": "join_request", "from_id": 91001}
	st.player_forced_event_id = "probe1"
	var cmd = PlayerCommandSystem.new()
	var r = cmd.respond_to_forced(st, "accept")
	print("  收留結果 ok=%s msg=%s" % [r.get("ok"), r.get("msg","")])
	print("  population: before=%d after=%d (delta=%d, 期望+8 或受 cap 限)" % [before, pt.population, pt.population - before])
	# UI 顯示
	node._refresh()
	var ct = node._cached_snapshot.get("controlled_team", {})
	print("  UI controlled_team.population=%d" % ct.get("population", -1))
	await _free(node)

# 種子相關 C 類：玩家能否設自隊 TASK_TRAIN（NPC 自動訓練升 tier，玩家無對應）
func _probe_main_team_task() -> void:
	print("\n── C類 玩家自隊任務/訓練 ──")
	var node = await _make_ui()
	var cmd = PlayerCommandSystem.new()
	var actions = cmd.get_registered_actions()
	var has_set_main_task = false
	var has_promote = false
	var has_train = false
	for a in actions:
		if "task" in str(a) and "sub" not in str(a) and "member" not in str(a): has_set_main_task = true
		if "promote" in str(a) or "train" in str(a): has_promote = true
	print("  registered actions 含設自隊 task? %s" % has_set_main_task)
	print("  registered actions 含 promote/train? %s" % has_promote)
	print("  → NPC 經 TASK_TRAIN 自動 add_exp+try_promote 升 anon tier；玩家無 command 設自隊 TASK_TRAIN 也無 try_promote 入口")
	await _free(node)

# recruit_anon：UI 互動選單到底有沒有路徑執行 recruit_anon / recruit_named？
func _probe_recruit_anon_ui_path() -> void:
	print("\n── recruit/recruit_anon/recruit_named UI 路徑 ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var ptid = st.persons[st.player_id].team_id
	var pt = st.teams[ptid]
	pt.resources["coin"] = 500.0
	var ppos = pt.tile_pos
	var tgt = TeamData.new(); tgt.team_id = 92001; tgt.population = 6; tgt.tile_pos = ppos; tgt.faction_id = -1
	var m = PersonData.new(); m.id = 92099; m.team_id = 92001; m.loyalty = 0.2
	st.persons[92099] = m; tgt.named_members.append(92099); tgt.leader_id = -1
	st.teams[92001] = tgt
	st.team_discovered[ptid] = st.team_discovered.get(ptid, [])
	if not st.team_discovered[ptid].has(92001): st.team_discovered[ptid].append(92001)
	st.player_pending_targets.append(92001)
	node._interact_mode = true
	node._interact_target = 92001
	node._refresh()
	var split = node._interact_action_split()
	var team_ids = []
	for a in split["team"]: team_ids.append(a.get("action_id",""))
	print("  team-target 行動清單: %s" % str(team_ids))
	print("  含 recruit? %s  recruit_anon? %s" % ["recruit" in team_ids, "recruit_anon" in team_ids])
	# recruit 回 menu payload，UI interact handler 是否處理 menu？檢查 handler 只 _log_event/_set_feedback
	print("  → recruit 回 payload menu(has_willing_named/anon_available);檢查 _handle_interact_mode team 分支有無消費此 menu")
	await _free(node)

# beg：玩家乞討 UI 是否可達 + 執行後是否有 feedback
func _probe_beg_ui_path() -> void:
	print("\n── beg 乞討 UI 路徑 ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var ptid = st.persons[st.player_id].team_id
	var ppos = st.teams[ptid].tile_pos
	var tgt = TeamData.new(); tgt.team_id = 93001; tgt.population = 6; tgt.tile_pos = ppos; tgt.faction_id = -1
	tgt.resources["food"] = 100.0
	st.teams[93001] = tgt
	st.team_discovered[ptid] = st.team_discovered.get(ptid, [])
	if not st.team_discovered[ptid].has(93001): st.team_discovered[ptid].append(93001)
	st.player_pending_targets.append(93001)
	node._interact_mode = true; node._interact_target = 93001
	node._refresh()
	var team_ids = []
	for a in node._interact_action_split()["team"]: team_ids.append(a.get("action_id",""))
	print("  team-target 含 beg? %s  含 gather_intel? %s" % ["beg" in team_ids, "gather_intel" in team_ids])
	await _free(node)

# hunt_beast：腳下 predator → available_actions 是否含 hunt_beast + UI self-action 顯示
func _probe_hunt_beast_ui() -> void:
	print("\n── hunt_beast UI 路徑 ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var ptid = st.persons[st.player_id].team_id
	var ppos = st.teams[ptid].tile_pos
	var tile = st.world.tiles.get(ppos.x*1000+ppos.y)
	if tile != null:
		tile.resources["predator_density"] = 3
	node._refresh()
	var ids = []
	for a in node._cached_snapshot.get("available_actions", []): ids.append(a.get("action_id",""))
	print("  available_actions 含 hunt_beast? %s" % ("hunt_beast" in ids))
	var self_ids = []
	for a in node._interact_action_split()["self"]: self_ids.append(a.get("action_id",""))
	print("  interact self-actions 含 hunt_beast? %s" % ("hunt_beast" in self_ids))
	await _free(node)
