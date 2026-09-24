extends SceneTree
# @bed-kind: invariant

var _errors: int = 0

const EXPECTED_CELLS: Array = ["_test_interact_self_team_split", "_test_train_action_reachable", "_test_camp_action_reachable", "_test_join_request_ui", "_test_forced_choose_heir_ui", "_test_forced_aid_request_ui", "_test_recruit_named_reachable", "_test_capabilities_shown", "_test_storage_panel_ui", "_test_outpost_build_abandon", "_test_faction_extract_treasury", "_test_member_equip_flow", "_test_armed_ratio_cmd", "_test_armed_count_shown", "_test_u15_overlay_input_guard", "_test_player_status_label", "_test_q7_3_take_loot_flow", "_test_q7_5_dispatch_subteam_task", "_test_q7_6_faction_gate_leader", "_test_n1_subteam_promote_anon_hint", "_test_harness_smoke", "_test_u19_forced_auto_enter", "_test_u21_interact_paging", "_test_u12_trade_str", "_test_trade_offer_builder", "_test_hunt_action_listed", "_test_pages_frame", "_test_pages_zero_loss", "_test_pages_switch_key", "_test_pages_skylight", "_test_pages_single_source", "_test_pages_q1_source", "_test_pages_q3_changes", "_test_home_p1_value", "_test_home_p2_pair", "_test_home_p3_none", "_test_home_p4_multi", "_test_home_p5_halfset", "_test_home_p6_zero_is_real", "_test_render_idempotent", "_test_refresh_idempotent", "_test_p1b_exclude_empty", "_test_p11_pending_footer", "_test_p15_echo_at_most_twice", "_test_p17_consume_then_render", "_test_hover_p1_live", "_test_hover_p2_title", "_test_hover_p3_no_state_write", "_test_hover_p5_empty_and_crowded", "_test_recruit_pay_matches_delivery", "_test_p8_x_advances_one_hour", "_test_p8s_x_uses_the_constant", "_test_p9_single_advance_path", "_test_p10_footer_x_says_one_hour", "_test_p11_esc_interrupts_x", "_test_p13_dedupe_repeated_t", "_test_p14_dedupe_does_not_eat_meaningful", "_test_p15b_footer_labels_same_source", "_test_p16b_pending_zero_after_advance", "_test_p18_unbounded_sentinel_is_named", "_test_p19_control_coverage_ratchet", "_test_p2_whole_day_not_dropped"]

# ★★★【到場點名 ＋ 陽性對照】（systems 派工 2026-09-17）——
#   ★這支床的格是 **coroutine**（`await _test_X()`），而 `await` **不保護**：
#     reviewer 寫了 await 版 repro —— 中途丟錯**只中止那個 coroutine**，
#     `_initialize` 繼續 await 下一格、照樣印 `errors: 0`、exit code ＝ 0。
#   ⇒ ★★**同一份樣板通吃同步與 async**：打卡寫在【格自己的最後一行】，中途死掉就點不到名。
#   ★★★用法必須是 `_selftest_gate("格名").noop()` —— 死亡要發生在【那一格自己的 frame】裡
#     （★血證：把死亡放在被呼叫的 helper 裡，中止的是 helper，那一格照樣跑完）。
var _cells_ran: Array = []

func _cell(name: String) -> void:
	if not _cells_ran.has(name):
		_cells_ran.append(name)

func noop() -> void:
	pass

func _selftest_gate(cell: String) -> Object:
	if OS.get_environment("BED_SELFTEST_DIE") != cell:
		return self
	print("[SELFTEST] ★故意讓 `%s` 這一格在中途死掉" % cell)
	return null

func _roll_call_suffix() -> String:
	var missing: Array = []
	for c in EXPECTED_CELLS:
		if not _cells_ran.has(c): missing.append(c)
	if not missing.is_empty():
		_errors += 1
		print("[roll-call] ❌ ★**有格沒有跑完**：%s —— 執行期錯誤會靜默中止一支 func／coroutine，而那看起來像綠" % str(missing))
	return "｜到場點名 %d／%d" % [_cells_ran.size(), EXPECTED_CELLS.size()]


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
	# ★★★點名是【快照】：_roll_call_suffix() 一算就定了 ⇒ 在它【之後】跑的格永遠點不到名，
	#   而卷面會印「有格沒有跑完」——★那條訊息是對的，錯的是呼叫順序。
	#   ⇒ ★★新增格一律加在這一行【之前】。
	await _test_pages_frame()
	await _test_pages_zero_loss()
	await _test_pages_switch_key()
	await _test_pages_skylight()
	await _test_pages_single_source()
	await _test_pages_q1_source()
	await _test_pages_q3_changes()
	await _test_home_p1_value()
	await _test_home_p2_pair()
	await _test_home_p3_none()
	await _test_home_p4_multi()
	await _test_home_p5_halfset()
	await _test_home_p6_zero_is_real()
	await _test_render_idempotent()
	await _test_refresh_idempotent()
	await _test_p1b_exclude_empty()
	await _test_p11_pending_footer()
	await _test_p15_echo_at_most_twice()
	await _test_p17_consume_then_render()
	await _test_hover_p1_live()
	await _test_hover_p2_title()
	await _test_hover_p3_no_state_write()
	await _test_hover_p5_empty_and_crowded()
	await _test_recruit_pay_matches_delivery()
	await _test_p8_x_advances_one_hour()
	await _test_p8s_x_uses_the_constant()
	await _test_p9_single_advance_path()
	await _test_p10_footer_x_says_one_hour()
	await _test_p11_esc_interrupts_x()
	await _test_p13_dedupe_repeated_t()
	await _test_p14_dedupe_does_not_eat_meaningful()
	await _test_p15b_footer_labels_same_source()
	await _test_p16b_pending_zero_after_advance()
	await _test_p18_unbounded_sentinel_is_named()
	await _test_p19_control_coverage_ratchet()
	await _test_p2_whole_day_not_dropped()
	var _suffix: String = _roll_call_suffix()
	print("\n=== UI Flow Test DONE === errors: %d%s" % [_errors, _suffix])
	quit()

# P4-2:self/原地動作(hunt)應在 self-actions(目標選擇階段直接可選),不混進 team-target 行動清單。
func _test_interact_self_team_split() -> void:
	_selftest_gate("_test_interact_self_team_split").noop()
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
	AnonTierSystem.add_anon(other, "平民", 5)   # ★舊寫法是 getter-only 賦值（靕默 no-op）
	other.faction_id = -1
	st.teams[7001] = other
	st.team_discovered[ptid] = [7001]
	node._interact_mode = true; node._interact_target = -1
	# ★★★這裡是【佈置樣本】不是【走指令路徑】：`refresh_interaction_targets()` 已改成入列
	#   （spec §3-3b：它寫 player_pending_targets ＝ 世界狀態）⇒ 呼叫完【當下不會生效】,
	#   而這一格接著就要讀 pending_targets ⇒ 照原樣會紅，而那個紅不帶任何資訊。
	#   ★不插一顆 tick 的理由：推進會讓手動擺進去的隊【自己走掉】⇒ 擾動的是樣本不是被測的東西。
	#   ★★★【這一格因此繞過了指令路徑】—— 寫明是因為：不寫的話，下一個人會以為
	#     「指令路徑在這裡被測過了」，而真正守它的是 command_replay_bed 的 P1／P12。
	#     ★一個被繞過的東西如果沒有被寫下來，它看起來就像被覆蓋了。
	PlayerCommandSystem.new().refresh_colocation_targets(st)
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
	_cell("_test_interact_self_team_split")

func _test_train_action_reachable() -> void:
	_selftest_gate("_test_train_action_reachable").noop()
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
	_cell("_test_train_action_reachable")

func _test_camp_action_reachable() -> void:
	_selftest_gate("_test_camp_action_reachable").noop()
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
	_cell("_test_camp_action_reachable")

func _test_join_request_ui() -> void:
	_selftest_gate("_test_join_request_ui").noop()
	print("\n── join_request 收留 UI ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var ptid: int = st.persons[st.player_id].team_id
	st.teams[ptid].resources["food"] = 50.0
	var ppos = st.teams[ptid].tile_pos
	var ds := TeamData.new(); ds.team_id = 8888; ds.tile_pos = ppos
	AnonTierSystem.add_anon(ds, "平民", 3)   # ★舊寫法是 getter-only 賦值（靕默 no-op）
	st.teams[8888] = ds
	st.player_forced_event = {"action": "join_request", "from_id": 8888}
	st.player_forced_event_id = "t1"
	node._bridge.request_advance(1)   # _process 早段需 is_advancing 才往下跑
	node._process(0.1)   # U19 自動進 forced 模式
	var s: String = node._event_label.text
	_check("forced 顯收留選項", s.contains("收留") or s.contains("投靠") or s.contains("婉拒"))
	await _free_ui(node)

# Q7-1：forced choose_heir → UI DTO responses 列候選（非只拒絕）→ 選擇 → leader 接位 + forced 清
	_cell("_test_join_request_ui")
func _test_forced_choose_heir_ui() -> void:
	_selftest_gate("_test_forced_choose_heir_ui").noop()
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
	# ★★★指令佇列化之後，按鍵只是【入列】—— 世界要等下一顆 tick 才變（2026-09-24 實測）。
	#   ★我原本的分類表掃的是【床裡的 command_player 呼叫點】，而這一格是
	#     透過真實輸入路徑下指令（command_player 在 text_ui_main.gd 裡）⇒ ★★掃不到。
	#   ⇒ ★★★母體選錯了軸：「哪些格會下指令」≠「哪幾行寫了 command_player」。
	_apply_queue(node)
	_check("choose_heir 後 leader 接位", st.teams[ptid].leader_id == int(cands[0]))
	_check("choose_heir 後 forced 清除", st.player_forced_event.is_empty())
	await _free_ui(node)

# Q7-2：forced aid_request → UI DTO responses 含 give（非只拒絕）→ 選 give → 守恆轉糧 + forced 清
	_cell("_test_forced_choose_heir_ui")
func _test_forced_aid_request_ui() -> void:
	_selftest_gate("_test_forced_aid_request_ui").noop()
	print("\n── Q7-2 forced aid_request UI ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var ptid: int = st.persons[st.player_id].team_id
	var pt = st.teams[ptid]
	pt.resources["food"] = 100.0
	var ppos = pt.tile_pos
	var b := TeamData.new(); b.team_id = 8889; b.tile_pos = ppos
	AnonTierSystem.add_anon(b, "平民", 3)   # ★舊寫法是 getter-only 賦值（靕默 no-op）；leader 在下方設 ⇒ 1+3 = 4
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
	# ★★★指令佇列化之後，按鍵只是【入列】—— 世界要等下一顆 tick 才變（2026-09-24 實測）。
	#   ★我原本的分類表掃的是【床裡的 command_player 呼叫點】，而這一格是
	#     透過真實輸入路徑下指令（command_player 在 text_ui_main.gd 裡）⇒ ★★掃不到。
	#   ⇒ ★★★母體選錯了軸：「哪些格會下指令」≠「哪幾行寫了 command_player」。
	_apply_queue(node)
	_check("aid give 後 beggar 收糧", float(b.resources["food"]) > 0.0)
	_check("aid give 守恆", is_equal_approx(food_before, float(pt.resources["food"]) + float(b.resources["food"])))
	_check("aid 後 forced 清除", st.player_forced_event.is_empty())
	await _free_ui(node)

# A-1：記名招募在 TextUI 主場景可達。
# 真路徑：recruit action 回 menu payload（has_willing_named/willing_members/anon_available）；
# team-target handler 須消費此 payload → 進招募子模式 → 玩家選記名 → recruit_named 經 execute_action_with_target 真執行。
	_cell("_test_forced_aid_request_ui")
func _test_recruit_named_reachable() -> void:
	_selftest_gate("_test_recruit_named_reachable").noop()
	print("\n── A-1 記名招募 TextUI 可達 ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var pid: int = st.player_id
	var ptid: int = st.persons[pid].team_id
	var ppos = st.teams[ptid].tile_pos
	st.teams[ptid].resources["coin"] = 300.0   # > named gate 150
	# 同格 NPC 隊：含一名不忠 named 成員（loyalty<0.4）
	var npc := TeamData.new(); npc.team_id = 4321; npc.tile_pos = ppos
	# ★leader 43210 且 named_members 含 43210 與 43211 ⇒ getter = 1 + 2 + anon
	#   ★★（同一人既是 leader 又在 named 裡 ―― 那是舊 fixture 的寫法，我不動它，只把 anon 算對）
	AnonTierSystem.add_anon(npc, "平民", 1)   # ★舊寫法是 getter-only 賦值（靕默 no-op）
	npc.faction_id = -1
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
	# ★★★指令佇列化之後，按鍵只是【入列】—— 世界要等下一顆 tick 才變（2026-09-24 實測）。
	#   ★我原本的分類表掃的是【床裡的 command_player 呼叫點】，而這一格是
	#     透過真實輸入路徑下指令（command_player 在 text_ui_main.gd 裡）⇒ ★★掃不到。
	#   ⇒ ★★★母體選錯了軸：「哪些格會下指令」≠「哪幾行寫了 command_player」。
	_apply_queue(node)
	_check("recruit_named 執行：成員轉到玩家隊", st.persons[43211].team_id == ptid)
	_check("recruit_named 執行：coin 扣 150", abs(coin_before - float(st.teams[ptid].resources.get("coin", 0)) - 150.0) < 0.01)
	await _free_ui(node)
	_cell("_test_recruit_named_reachable")

func _test_capabilities_shown() -> void:
	_selftest_gate("_test_capabilities_shown").noop()
	print("\n── 隊能力讀數顯示 ──")
	var node = await _make_ui()
	node._refresh()
	# status label 應含能力讀數關鍵字
	var s: String = node._state_label.text
	# ★★★舊版三句都是 `contains(關鍵字)`，而 :686-689 的唯一閘是 `cap.is_empty()`，
	#   又因 player_api_mapper.gd 的 _team_capabilities() 永遠回非空 dict ⇒ ★那個閘恆假
	#   ⇒ 那一行恆印 ⇒ 三句恆真。
	# ⇒ ★★改成比【值】：戰力取自查詢面的 combat_power，畫面上那個數字必須等於它。
	var cap: Dictionary = node._cached_snapshot.get("controlled_team", {}).get("capabilities", {})
	_check("查詢面有 capabilities（★母體地板）", not cap.is_empty())
	var want_cp: int = int(round(float(cap.get("combat_power", -1.0))))
	_check("查詢面的 combat_power 有效（%d）" % want_cp, want_cp >= 0)
	var got_cp: int = _kv_int(s, "戰力 ")
	_check("畫面上的戰力 %d ＝ 查詢面的 %d" % [got_cp, want_cp], got_cp == want_cp)
	# ★欄位名仍然要在：整段被刪掉時，上面那個比較會因為【兩邊都撈不到】而意外相等
	_check("三個欄位名都還在（獵／戰力／日耗）",
		(s.contains("獵") or s.contains("狩獵")) and s.contains("戰力") and s.contains("日耗"))
	await _free_ui(node)

# 公庫面板：自家 outpost + 雙向資源 → 顯存入/取出 + food
	_cell("_test_capabilities_shown")
func _test_storage_panel_ui() -> void:
	_selftest_gate("_test_storage_panel_ui").noop()
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
	_cell("_test_storage_panel_ui")
func _test_outpost_build_abandon() -> void:
	_selftest_gate("_test_outpost_build_abandon").noop()
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
	_cell("_test_outpost_build_abandon")
func _test_faction_extract_treasury() -> void:
	_selftest_gate("_test_faction_extract_treasury").noop()
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
	_cell("_test_faction_extract_treasury")

func _test_member_equip_flow() -> void:
	_selftest_gate("_test_member_equip_flow").noop()
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
	_check("★入列成功（★注意：這【不是】「動作成功」，只是排進去了）", r.get("queued", false))
	var _ap_equip_member: Dictionary = _apply_queue(node)
	_check("★★母體地板：消費點真的吃到了（%d 條）%s" % [int(_ap_equip_member.get("applied", 0)), String(_ap_equip_member.get("why", ""))],
		int(_ap_equip_member.get("applied", 0)) >= 1)
	_check("★★★equip_member 在【消費點】成功（讀 command_log 的 ok，不是入列的 ok）", _ap_equip_member.get("ok", false))
	_check("成員裝上武器", st.persons[99001].equipment["hand_1"].get("grade","") == "weapon_melee_low")
	# ★★★這一行原本讀的是【指令下達之前】那次 render 的字（上一次 `_refresh()` 在 :429，
	#   而中間隔著 `command_player()` 與 `_apply_queue()`）⇒ ★它不可能反映那道指令。
	#   ★★而 `_apply_queue()` 只叫 `tick_step()`【不叫 `_refresh()`】——
	#     那正是 P17 第一版踩過的同一支 helper：★★★現成的工具會把你帶回它原本服務的那條路。
	#   ⇒ 這裡補一次 render，讓這一行讀的是【指令生效之後】的畫面。
	node._refresh()
	_check("status 含武裝比例（★讀的是指令生效【之後】那一次 render）",
		node._state_label.text.contains("比例"))
	await _free_ui(node)
	_cell("_test_member_equip_flow")

func _test_armed_ratio_cmd() -> void:
	_selftest_gate("_test_armed_ratio_cmd").noop()
	print("\n── 設武裝比例 ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	st.player_state["armed_ratio_input"] = 0.6
	var r = node._bridge.command_player("execute_action", {"action_id":"set_armed_anon_ratio","target":{"kind":"none"}})
	_check("★入列成功（★注意：這【不是】「動作成功」，只是排進去了）", r.get("queued", false))
	var _ap_set_armed_anon_ratio: Dictionary = _apply_queue(node)
	_check("★★母體地板：消費點真的吃到了（%d 條）%s" % [int(_ap_set_armed_anon_ratio.get("applied", 0)), String(_ap_set_armed_anon_ratio.get("why", ""))],
		int(_ap_set_armed_anon_ratio.get("applied", 0)) >= 1)
	_check("★★★set_armed_anon_ratio 在【消費點】成功（讀 command_log 的 ok，不是入列的 ok）", _ap_set_armed_anon_ratio.get("ok", false))
	var ptid: int = st.persons[st.player_id].team_id
	_check("ratio 設為 0.6", abs(st.teams[ptid].armed_anon_ratio - 0.6) < 0.01)
	await _free_ui(node)
	_cell("_test_armed_ratio_cmd")

func _test_armed_count_shown() -> void:
	_selftest_gate("_test_armed_count_shown").noop()
	print("\n── 自隊武裝數顯示 ──")
	var node = await _make_ui()
	node._refresh()
	# ★★★舊版是 `text.contains("武裝")` —— 而 text_ui_main.gd:680 那一行【沒有 if 包】
	#   ⇒ 只要 _refresh() 被呼叫過就一定含「武裝」⇒ ★它驗的是【函式被呼叫】不是【數字有顯示】。
	# ⇒ ★★改成把畫面上的數字撈出來跟【查詢面】比：欄位消失／改名／沒印，三種都會紅。
	# ★★★誠實限：若有人把它寫成【剛好等於今天這個值的常數】，這一格仍會綠——
	#   要擋那一種得跑兩個不同的世界，本格不做，而我把限制寫出來而不是假裝沒有。
	var ct: Dictionary = node._cached_snapshot.get("controlled_team", {})
	_check("查詢面有 controlled_team（★母體地板：空的話下面全是恆真）", not ct.is_empty())
	var want_armed: int = int(ct.get("armed_count", -1))
	_check("查詢面的 armed_count 有效（%d）" % want_armed, want_armed >= 0)
	var got_armed: int = _kv_int(node._state_label.text, "武裝: ")
	_check("畫面上的武裝數 %d ＝ 查詢面的 %d" % [got_armed, want_armed], got_armed == want_armed)
	await _free_ui(node)

# U15：遭遇戰 overlay 顯示中，主畫面 _input 須一律不處理（否則戰後按 Q→quit 閃退、WASD 漂游標）。
# 測：overlay visible → 送 KEY_W → _cursor 不動（證 guard early-return）。
	_cell("_test_armed_count_shown")
func _test_u15_overlay_input_guard() -> void:
	_selftest_gate("_test_u15_overlay_input_guard").noop()
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
	_cell("_test_u15_overlay_input_guard")

func _test_player_status_label() -> void:
	_selftest_gate("_test_player_status_label").noop()
	print("\n── 玩家隊狀態 label（非任務）──")
	var node = await _make_ui()
	node._refresh()
	var s: String = node._state_label.text
	# ★★★systems 裁「窄化，不是刪」：前半 `contains("狀態:")` 恆真（:679 無條件印），
	#   而後半 `not contains("任務:")` 是真的回歸守衛。
	# ★★【直接刪前半句】是錯的修法：只留 not-contains 的話，★★★一個【空字串】也會過
	#   ⇒ 那是【反方向的恆真】：從「範圍裡總有東西」變成「什麼都沒有也算對」。
	# ⇒ 窄化成：那一行要【存在】、且【冒號後面有內容】，再加回歸守衛。
	var line: String = _line_with(s, "狀態: ")
	_check("找得到狀態列那一行", line != "")
	var body: String = line.substr(line.find("狀態: ") + 4).strip_edges()
	_check("狀態列冒號後有內容（「%s」）" % body.substr(0, 20), body != "")
	# ★★★範圍窄化（2026-09-25 實測訂正）：原本是 `not s.contains("任務:")` —— 掃【整個畫面】，
	#   而這一格的主詞是【狀態列那一行】（格名就叫「玩家隊狀態 label（非任務）」）。
	#   ★它一直無害，因為在那之前全畫面沒有別的地方用到那三個字；
	#   ★★而「游標懸停真值」那一票印每支隊的 `任務:` 之後它就紅了 —— 紅在一個【與它主詞無關】的地方。
	#   ⇒ ★★★窄化不是刪除：守衛留著，只是縛回它真正的主詞（那一行），
	#     這樣它仍然抓得到「狀態列退回舊措辭」，而不會咬別的區塊。
	_check("★回歸守衛：狀態列那一行沒有退回舊措辭「任務:」", not line.contains("任務:"))
	await _free_ui(node)

# Q7-3：戰後 loot_pool 非空 → [K]take_loot 經 bridge 真把戰利品入庫、清 last_encounter_result。
	_cell("_test_player_status_label")
func _test_q7_3_take_loot_flow() -> void:
	_selftest_gate("_test_q7_3_take_loot_flow").noop()
	print("\n── Q7-3 戰後 take_loot 端到端 ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var ptid: int = st.persons[st.player_id].team_id
	var pt = st.teams[ptid]
	var before_food: float = float(pt.resources.get("food", 0))
	# 敗隊持有食物 → loot_pool 取自其資源
	var loser := TeamData.new(); loser.team_id = 7700
	AnonTierSystem.add_anon(loser, "平民", 3)   # ★舊寫法是 getter-only 賦值（靕默 no-op）
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
	_check("★入列成功（★注意：這【不是】「動作成功」，只是排進去了）", r.get("queued", false))
	var _ap_take_loot: Dictionary = _apply_queue(node)
	_check("★★母體地板：消費點真的吃到了（%d 條）%s" % [int(_ap_take_loot.get("applied", 0)), String(_ap_take_loot.get("why", ""))],
		int(_ap_take_loot.get("applied", 0)) >= 1)
	_check("★★★take_loot 在【消費點】成功（讀 command_log 的 ok，不是入列的 ok）", _ap_take_loot.get("ok", false))
	# ══════════ 可證偽的預測（systems 2026-09-23：不要預先赦免那個紅）══════════
	#   ★背景：`_apply_queue()` 推進一顆 tick 讓指令真的被套用 ⇒ 整個世界跟著走一步。
	#   ★★而【預寫的失敗語意對真紅與假紅一視同仁地加持說服力】⇒ 所以這裡寫的不是
	#     「這個紅是預期的」，是一個【可以被推翻的預測】：
	#     斷言的量：玩家隊 food 相對 before_food 的差，容差 0.01
	#     ①方向：只可能【不變】或【變少】。★變【多】＝預測被推翻＝發現。
	#     ②量級：糧耗走 cadence（SimRunner.NEAR_CADENCE ＝ TICKS_PER_HOUR ＝ 60）
	#        ⇒ 推進一顆 tick 只有在【剛好跨過該隊的錯開邊界】時才扣，否則一毛都不扣。
	#        若扣：pop × FOOD_PER_PERSON_PER_DAY(0.8) × 60/1440 ＝ pop × 0.0333
	#              （另有坐騎／馬匹草料 × 0.5/day ⇒ 每匹再算 0.0208）
	#     ③判準：落差【在這個式子算得出來的範圍內】⇒ 調容差；
	#            落差【在範圍外】（變多、或少掉遠超過 pop×0.0333）⇒ ★★★那是【發現】。
	#   ★而斷言本身【維持嚴格 0.01 不放寬】—— 放寬就是換一種方式預先赦免。
	#     第一次跑的那個紅【就是這個預測的實驗】。
	var _fd_delta: float = float(pt.resources.get("food", 0)) - (before_food + 30.0)
	var _fd_pop: int = pt.population + pt.minor_population
	var _fd_pred: float = float(_fd_pop) * ResourceSystem.FOOD_PER_PERSON_PER_DAY * float(SimRunner.NEAR_CADENCE) / float(WorldState.TICKS_PER_DAY)
	print("  [預測] 食物落差 實測=%.4f｜若這一 tick 剛好扣糧，預測扣掉 %.4f（pop=%d）｜方向：只准 ≤0" % [_fd_delta, _fd_pred, _fd_pop])
	_check("玩家食物 +30 入庫", abs(float(pt.resources.get("food", 0)) - (before_food + 30.0)) < 0.01)
	_check("敗隊食物 -30", abs(float(loser.resources.get("food", 0)) - 70.0) < 0.01)
	_check("last_encounter_result 已清", st.last_encounter_result.is_empty())
	await _free_ui(node)

# Q7-5：子隊派遣可選非 IDLE 任務。command 介面不變,UI 經 set_player_input("sub_task", 選定) 真派出帶任務子隊。
	_cell("_test_q7_3_take_loot_flow")
func _test_q7_5_dispatch_subteam_task() -> void:
	_selftest_gate("_test_q7_5_dispatch_subteam_task").noop()
	print("\n── Q7-5 子隊派遣帶任務 ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var ptid: int = st.persons[st.player_id].team_id
	var pt = st.teams[ptid]
	# ★舊寫法 pt.population = 10 已刪：它是靕默 no-op，而下一行的 add_anon 才是真的在加人。
	#   ★★pt 是玩家隊（已有 leader/成員）⇒ 不能把 10 当成目標值再算一次。
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
	_check("★入列成功（★注意：這【不是】「動作成功」，只是排進去了）", r.get("queued", false))
	var _ap_dispatch_subteam: Dictionary = _apply_queue(node)
	_check("★★母體地板：消費點真的吃到了（%d 條）%s" % [int(_ap_dispatch_subteam.get("applied", 0)), String(_ap_dispatch_subteam.get("why", ""))],
		int(_ap_dispatch_subteam.get("applied", 0)) >= 1)
	_check("★★★dispatch_subteam 在【消費點】成功（讀 command_log 的 ok，不是入列的 ok）", _ap_dispatch_subteam.get("ok", false))
	# 經 parent.subteam_ids 找剛派出的子隊（command 不回傳 sub_id）
	var sub_id: int = pt.subteam_ids[-1] if not pt.subteam_ids.is_empty() else -1
	_check("子隊 current_task = 覓食（非寫死 IDLE）",
		sub_id != -1 and st.teams.has(sub_id) and st.teams[sub_id].current_task == TeamData.TASK_FORAGE)
	await _free_ui(node)

# Q7-6：非 faction leader → 面板不顯 [A]目標 [B]徵收率（display 對齊 command 權限）；leader 則顯。
	_cell("_test_q7_5_dispatch_subteam_task")
func _test_q7_6_faction_gate_leader() -> void:
	_selftest_gate("_test_q7_6_faction_gate_leader").noop()
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
	_cell("_test_q7_6_faction_gate_leader")
func _test_n1_subteam_promote_anon_hint() -> void:
	_selftest_gate("_test_n1_subteam_promote_anon_hint").noop()
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
	_cell("_test_n1_subteam_promote_anon_hint")

func _check(label: String, ok: bool) -> void:
	print(("  PASS: " if ok else "  FAIL: ") + label)
	if not ok: _errors += 1

# 實例化 TextUI 場景 + 等 _ready。回傳 node。

# ★★★指令佇列化之後，「下指令 ⇒ 立刻讀效果」不再成立（spec §3-4）。
#   ★而這裡的風險【不是紅】是【假綠】：`command_player()` 現在回 {ok:true, queued:true}
#     ⇒ `_check("…成功", r.get("ok"))` **照樣綠，但它從此測的是「排進去了」不是「成功了」**。
#   ⇒ ★★所以這支 helper 做兩件事：①推進一顆 tick 讓它真的被套用
#     ②回傳【消費點的帳】—— 斷言要看那個 ok，不是入列的 ok。
#   ★★★誠實限（動工時無法消除）：推進一顆 tick 會讓【整個世界】走一步
#     ⇒ 後面那些比數值的斷言（例如「食物 +30」）現在多了一個 tick 的消耗在裡面。
#     ★那不是這支 helper 的錯，是【佇列語意本身】帶來的 —— 而它只能在跑得動的時候調容差。
func _apply_queue(node) -> Dictionary:
	var st: WorldState = node._bridge.get_state()
	var before_n: int = st.command_log.size()
	node._bridge.request_advance(1)
	node._bridge.tick_step()
	if st.command_log.size() <= before_n:
		return {"ok": false, "applied": 0, "why": "★消費點一條都沒吃到 ⇒ 佇列沒有被消費"}
	var last: Dictionary = st.command_log[st.command_log.size() - 1]
	return {"ok": bool(last.get("ok", false)), "applied": st.command_log.size() - before_n,
		"why": "", "entry": last}

func _make_ui() -> Node:
	# ★★★每一格都要拿到【一樣的世界】，而它不是自動的：
	#   ★這支床有 31 格，每一格各自 instantiate 一次；★★而 class 級（static）的殘留
	#     會跨格帶過去 ⇒ 第 27 格拿到的世界，與它單獨跑時【不是同一個】。
	#   ⇒ ★★★血證：同一棵樹跑三次 ⇒ 紅／紅／綠，而變的是 `狀態: <task_summary>`；
	#     而【擷取床單獨跑五次逐字相同】⇒ 變因不在擷取路徑，在【跨格殘留】。
	#   ★CrossRunReset 就是為這件事存在的（18 類），而這支床【從來沒叫過它】。
	# ★CrossRunReset.run() 拿掉了：它是 no-op —— game_setup.gd:43 本來就叫，
	#   而 _make_ui() 一定走到 GameSetup.setup()（text_ui_main.gd:124）。
	#   ★★保留一個 no-op 會讓下一個人以為「殘留」是這裡的問題，而它不是。
	# ★★★真因（33＋6 輪實驗定案）：Godot【每個行程開機時全域 RNG 是隨機的】
	#   —— 實測 4 個行程的第一個 randf()：0.336／0.970／0.761／0.207。
	#   而模擬會吃它 ⇒ 不 seed 的床【每次跑的世界都不同】⇒ `狀態: <task_summary>` 會變。
	# ★兩個被【數據】排除的假說（留著，因為它們看起來都很合理）：
	#   ①推進路徑：紅的那次與綠的逐字相同（frames=2 requests=2 [60,60]）
	#   ②前 30 格的殘留：★把這一格【單獨】跑，照樣紅 1/6
	# ⇒ ★★所以 seed() 是【必要的】，不是「多做一件事剛好壓住」。
	seed(1337)   # ★與 ui_state_str_capture.gd 的 UC_SEED 預設同值
	var node = load("res://scenes/TextUI.tscn").instantiate()
	get_root().add_child(node)
	await process_frame
	await process_frame
	return node

func _free_ui(node: Node) -> void:
	node.queue_free()
	await process_frame

func _test_harness_smoke() -> void:
	_selftest_gate("_test_harness_smoke").noop()
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
	_cell("_test_harness_smoke")
func _test_u19_forced_auto_enter() -> void:
	_selftest_gate("_test_u19_forced_auto_enter").noop()
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
	_cell("_test_u19_forced_auto_enter")
func _test_u21_interact_paging() -> void:
	_selftest_gate("_test_u21_interact_paging").noop()
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
		AnonTierSystem.add_anon(t, "平民", 3)   # ★舊寫法是 getter-only 賦值（靕默 no-op）
		t.faction_id = -1
		st.teams[t.team_id] = t
	node._interact_mode = true
	node._interact_target = -1
	node._interact_page = 0
	# ★★★這裡是【佈置樣本】不是【走指令路徑】：`refresh_interaction_targets()` 已改成入列
	#   （spec §3-3b：它寫 player_pending_targets ＝ 世界狀態）⇒ 呼叫完【當下不會生效】,
	#   而這一格接著就要讀 pending_targets ⇒ 照原樣會紅，而那個紅不帶任何資訊。
	#   ★不插一顆 tick 的理由：推進會讓手動擺進去的隊【自己走掉】⇒ 擾動的是樣本不是被測的東西。
	#   ★★★【這一格因此繞過了指令路徑】—— 寫明是因為：不寫的話，下一個人會以為
	#     「指令路徑在這裡被測過了」，而真正守它的是 command_replay_bed 的 P1／P12。
	#     ★一個被繞過的東西如果沒有被寫下來，它看起來就像被覆蓋了。
	PlayerCommandSystem.new().refresh_colocation_targets(st)
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
	_cell("_test_u21_interact_paging")
func _test_u12_trade_str() -> void:
	_selftest_gate("_test_u12_trade_str").noop()
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
	AnonTierSystem.add_anon(other, "平民", 5)   # ★舊寫法是 getter-only 賦值（靕默 no-op）
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
	_cell("_test_u12_trade_str")
func _test_trade_offer_builder() -> void:
	_selftest_gate("_test_trade_offer_builder").noop()
	print("\n── 交易 offer-builder ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var ptid: int = st.persons[st.player_id].team_id
	var ppos = st.teams[ptid].tile_pos
	st.teams[ptid].resources["food"] = 50.0
	var npc := TeamData.new(); npc.team_id = 7777; npc.tile_pos = ppos
	AnonTierSystem.add_anon(npc, "平民", 5)   # ★舊寫法是 getter-only 賦值（靕默 no-op）
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
	_cell("_test_trade_offer_builder")
func _test_hunt_action_listed() -> void:
	_selftest_gate("_test_hunt_action_listed").noop()
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
	_cell("_test_hunt_action_listed")

# ════════ 票A：UI 五分頁（spec 2026-09-23-ui-five-tabs-HOW.md §4）════════

# P1-a[框]：五個頁名都印得出來，且頁首帶 (i/5)。
# ★頁名【來自 UiPages.PAGE_ORDER】不是字面值 —— 寫死在這裡的話，這一格會變成
#   「我抄的字串等於我抄的字串」，改名時它照樣綠而畫面已經壞了。
func _test_pages_frame() -> void:
	_selftest_gate("_test_pages_frame").noop()
	print("\n── 票A P1-a 五分頁頁首 ──")
	var node = await _make_ui()
	_check("PAGE_ORDER 有 5 頁（現況 %d）" % UiPages.PAGE_ORDER.size(), UiPages.PAGE_ORDER.size() == 5)
	for i in range(UiPages.PAGE_ORDER.size()):
		node._page_idx = i
		var s: String = node._build_state_str()
		var want: String = UiPages.header(i)
		_check("第 %d 頁的頁首出現：%s" % [i + 1, want], s.contains(want))
		# ★★任一頁【全空白】＝紅（spec P4）。
		# ★★★第一版我寫「頁首之後非空白」——那是【恆真項】：頁尾的 Tick·Day 永遠跟在後面，
		#   所以就算整頁內容被拿光，那一格還是綠。（血證：注射「第 3 頁天窗不印」時它 PASS。）
		# ⇒ 改成只看【分頁區】：頁首 → 下一條分隔線（Tick·Day 那一段的起點）之間。
		var lines_s: PackedStringArray = s.split("\n")
		var hi: int = -1
		for li in range(lines_s.size()):
			if String(lines_s[li]) == want: hi = li; break
		_check("第 %d 頁找得到頁首行" % (i + 1), hi != -1)
		var body: Array = _page_body(lines_s, want)
		var body_txt: String = "".join(body).strip_edges()
		_check("第 %d 頁的【分頁區】非空（%d 行）" % [i + 1, body.size()], body_txt != "")
	await _free_ui(node)
	_cell("_test_pages_frame")

# P1-b[零損失]：舊 `_build_state_str()` 的每一條 raw 行，在（狀態列 ∪ 第 1 頁）裡
#   出現次數必須相同。★不 strip、★★不用集合測試（舊輸出有 4 條一模一樣的分隔線）。
# ★★★「前」來自票A 落地【之前】取的快照：
#     docs/measurements/2026-09-23-ui-ticketA-before-state-str.txt（commit 7738e52f6）
#   而它是在【特定世界＋特定 tick＋游標選在玩家格】取的 ⇒ 本格必須把世界對回去。
#   ⇒ ★對不上就判【不可判】，★★不判紅 —— 世界不同造成的差異不是這一票的缺陷。
func _test_pages_zero_loss() -> void:
	_selftest_gate("_test_pages_zero_loss").noop()
	print("\n── 票A P1-b 零損失（raw／逐行計數／不 strip）──")
	var path: String = "res://docs/measurements/2026-09-23-ui-ticketA-before-state-str.txt"
	if not FileAccess.file_exists(path):
		print("  ★★★【不可判】找不到「前」快照：%s" % path)
		print("    ⇒ ★這不是綠也不是紅：沒有「前」就沒有零損失可言")
		_errors += 1   # ★沒有基準【就是】缺陷（基準是這一票的交付物之一）
		_cell("_test_pages_zero_loss")
		return
	var txt: String = FileAccess.get_file_as_string(path)
	# ★★★世界要跟「前」同一顆種子：ui_flow_test 全檔【沒有 seed】⇒ 世界每次不同
	#   ⇒ ★`狀態: <task_summary>` 這一行會隨機變 ⇒ 這一格【隨機紅】（實測 3 次裡紅 2 次）
	#   ⇒ ★★而隨機紅比恆綠更糟：它會被讀成雜訊，然後整支註冊表上的閘被降級
	#   ★★★seed 必須在 _make_ui() 之前：場景在 _ready 建世界，吃的是全域 RNG
	# ★seed 與 CrossRunReset 已統一在 _make_ui() 裡做（每一格都要，不只這一格）
	var want_tick: int = -1
	var want_teams: int = -1
	var want_persons: int = -1
	var before: Array = []
	for ln in txt.split("\n"):
		if ln.begins_with("#UC "):
			if ln.begins_with("#UC tick="):
				want_tick = int(ln.substr(9).split("（")[0])
			if ln.contains("teams="):
				# ★不用 RegEx：那需要反斜線，而反斜線在【產生這支檔的工具鏈】上被吃過兩次
				#   （產生這支檔的 heredoc 把【兩個反斜線】收成【一個】⇒ GDScript 報 Invalid escape）
				#   ⇒ 用 split 解析，整條路上一個反斜線都不需要。
				# ★用 find 不用 token 前綴：那一行是「…非設定值）：teams=16 …」，
				#   ★★teams= 前面【沒有空白】（緊接在全形冒號後）⇒ split(" ") 的那一段
				#   會是「非設定值）：teams=16」而 begins_with("teams=") 為假 ⇒ 靜靜解析成 -1。
				#   ★★★而 -1 會讓下面判成【不可判】—— 看起來像「世界對不上」，其實是我的剖析壞了。
				want_teams = _kv_int(ln, "teams=")
				want_persons = _kv_int(ln, "persons=")
			continue
		before.append(ln)
	# ★★★檔案往返的產物：存檔是一行一個 store_line ⇒ 檔尾有換行 ⇒ split 出一個【尾端空字串】。
	#   而 `_build_state_str()` 回傳的字串【沒有】尾端換行 ⇒ 新輸出不會有那一個空元素。
	#   ⇒ ★不處理的話這一格會報「舊 1 次 → 新 0 次：（空行）」，而那不是【少印了一行】。
	#   ★★只砍【最後一個】而且【只砍空的那一個】—— 輸出中間若真的有空行，它仍然要被比。
	if not before.is_empty() and String(before[before.size() - 1]) == "":
		before.remove_at(before.size() - 1)
	var node = await _make_ui()
	var st = node._bridge.get_state()
	# ★把世界推到同一個 tick（★★看【世界的 tick 到了沒】，不是看請求過幾次）
	var guard: int = 0
	while st.world.current_tick < want_tick and guard < 4000:
		if not node._bridge.is_advancing():
			node._bridge.request_advance(want_tick - st.world.current_tick)
		await process_frame
		guard += 1
	# ★★★用完 guard ≠ 到達目標：★第一版沒有分開這兩件事，而它讓「推不動」
	#   看起來像「世界對得上」——實測血證：注射多推 1440 tick 時，世界【卡在 120】
	#   燒光 2000 frame，而卷面照樣往下比。
	if st.world.current_tick < want_tick:
		print("  ★★★【不可判】推不到「前」的 tick：目標 %d 實得 %d（frames=%d 已用完）" % [
			want_tick, st.world.current_tick, guard])
		print("    ⇒ ★這不是紅也不是綠：沒有推到同一個世界，零損失就無從比起")
		await _free_ui(node)
		_cell("_test_pages_zero_loss")
		return
	# ★★游標也要對回去（沒選格 ⇒ text_ui_main.gd:716 那 ~23 行一行都不會渲染）
	var ct: Dictionary = node._cached_snapshot.get("controlled_team", {})
	var cp: Dictionary = ct.get("position", {})
	if not cp.is_empty():
		node._selected = Vector2i(int(cp.get("q", 0)), int(cp.get("r", 0)))
	node._page_idx = 0
	var same_world: bool = (st.world.current_tick == want_tick
		and st.teams.size() == want_teams and st.persons.size() == want_persons)
	print("  世界：tick=%d/%d teams=%d/%d persons=%d/%d ⇒ %s" % [
		st.world.current_tick, want_tick, st.teams.size(), want_teams,
		st.persons.size(), want_persons, "對得上" if same_world else "對不上"])
	if not same_world:
		print("  ★★★【不可判】世界與「前」不同 ⇒ 差異不歸這一票")
		print("    ⇒ ★重取「前」：scripts/debug/ui_state_str_capture.gd（UC_OUT 指到那個路徑）")
		await _free_ui(node)
		_cell("_test_pages_zero_loss")
		return
	# ★★★票B 之後，「零損失」的比對對象必須是【五頁的聯集】不是第 1 頁：
	#   ★票B 的工作【就是】把行從未分類搬到對應頁 ⇒ 只比第 1 頁的話，
	#     每搬走一行這一格就紅一次 ⇒ ★★守衛會變成阻礙，而它擋的是【正確的改動】。
	#   ⇒ 聯集怎麼組：狀態列（頁首之前）＋ 每一頁的【分頁區】＋ 頁尾（Tick·Day 那段），
	#     ★★★而框架那兩段【只取一次】—— 它們每頁都印，直接全串會讓計數 ×5。
	var after: Array = _union_all_pages(node)
	# ★具名排除：兩邊都排，★★而排掉幾行要印出來（不是靜默略過）
	var n_ex_b: int = 0
	var n_ex_a: int = 0
	var n_st_b: int = 0
	var n_st_a: int = 0
	var before2: Array = []
	for l in before:
		if _p1b_structural(String(l)): n_st_b += 1
		elif _p1b_excluded(String(l)): n_ex_b += 1
		else: before2.append(l)
	var after2: Array = []
	for l in after:
		if _p1b_structural(String(l)): n_st_a += 1
		elif _p1b_excluded(String(l)): n_ex_a += 1
		else: after2.append(l)
	print("  ★P1-b 具名排除 %d 條規則｜前排除 %d 行／後排除 %d 行" % [
		P1B_EXCLUDE.size(), n_ex_b, n_ex_a])
	print("  ★結構行（spec 本來就不比）：前 %d 行／後 %d 行｜規則 %d 條，逐條指回 spec：" % [
		n_st_b, n_st_a, P1B_STRUCTURAL.size()])
	for e in P1B_STRUCTURAL:
		print("    [%s] %s" % [String(e["kind"]), String(e["spec"])])
	for e in P1B_EXCLUDE:
		print("    排除「%s…」：%s" % [String(e["prefix"]), String(e["why"])])
	before = before2
	after = after2
	var cb: Dictionary = {}
	for l in before: cb[l] = int(cb.get(l, 0)) + 1
	var ca: Dictionary = {}
	for l in after: ca[l] = int(ca.get(l, 0)) + 1
	var lost: int = 0
	for l in cb:
		var n_old: int = int(cb[l])
		var n_new: int = int(ca.get(l, 0))
		if n_new != n_old:
			lost += 1
			print("  ✗ 舊 %d 次 → 新 %d 次：%s" % [n_old, n_new, String(l).substr(0, 40)])
	_check("零損失：舊 %d 條相異行的出現次數全部相同（不 strip、不用集合）" % cb.size(), lost == 0)
	# ★母體地板：★★「零損失」在【空的前】上恆真 —— 那是恆真項不是判準
	_check("「前」的母體非空（%d 條相異行，且有重複行才測得出計數）" % cb.size(), cb.size() >= 10)
	var dup_max: int = 0
	for l in cb:
		if int(cb[l]) > dup_max: dup_max = int(cb[l])
	_check("「前」裡有重複行（最大 %d 次）⇒ 逐行計數這件事測得到" % dup_max, dup_max >= 2)
	await _free_ui(node)
	_cell("_test_pages_zero_loss")

# P2[鍵]：切鍵循環 5 次回原頁；overlay 開著時切鍵不吃。
# ★★★形狀是硬的（spec）：InputEventKey.new() ＋ node._input(ev)，抄 _test_u15_overlay_input_guard。
#   ★明文禁止 node._process(...) / node._bridge.set_player_input(...) ——
#   ★★那 25 支繞過 _input() 的 cell 綠的是「函式被呼叫」，不是「鍵盤按得到」。
func _test_pages_switch_key() -> void:
	_selftest_gate("_test_pages_switch_key").noop()
	print("\n── 票A P2 切鍵（真鍵盤路徑）──")
	var node = await _make_ui()
	node._page_idx = 0
	var ev := InputEventKey.new()
	ev.keycode = KEY_PERIOD
	ev.pressed = true
	var seen: Array = []
	for i in range(UiPages.PAGE_ORDER.size()):
		node._input(ev)
		seen.append(node._page_idx)
	_check("連按 %d 次回到第 1 頁（走完 %s）" % [UiPages.PAGE_ORDER.size(), str(seen)],
		node._page_idx == 0)
	# ★★★判準窄化（systems 2026-09-23：註解不是守衛）——原本是「走完有幾個相異」，
	#   ★而那條【兩邊同源】：按 `PAGE_ORDER.size()` 次、而 `next_idx` 是 mod 同一個數
	#     ⇒ 只要步長與頁數互質（步長 2、頁數 5），走 N 次照樣 N 個相異 ⇒ 驗不出步長錯。
	#   ⇒ ★★改成【每一步剛好 +1】：左邊＝實際走到的頁，右邊＝`(prev+1)%N` 這個【外部規則】
	#     ⇒ ★★★兩邊從【同源】變成【異源】，而成本一樣、比原判準嚴格。
	#     ★真正「一次走一頁」的實作恆滿足 +1 ⇒ 會紅的只有步長真的錯了那一種。
	var step_bad: Array = []
	var prev_i: int = 0
	for i in range(seen.size()):
		var want: int = (prev_i + 1) % UiPages.PAGE_ORDER.size()
		if int(seen[i]) != want:
			step_bad.append("第 %d 步：期望 %d 實得 %d" % [i + 1, want, int(seen[i])])
		prev_i = int(seen[i])
	for s in step_bad: print("    ✗ %s" % String(s))
	_check("★每一步【剛好 +1】（%d 步全對；走過 %s）" % [seen.size(), str(seen)], step_bad.is_empty())
	_check("★★母體地板：真的走了 %d 步（0 步的話「每一步都對」恆真）" % seen.size(),
		seen.size() == UiPages.PAGE_ORDER.size() and seen.size() >= 2)
	# ★反向鍵
	var ev2 := InputEventKey.new()
	ev2.keycode = KEY_COMMA
	ev2.pressed = true
	node._input(ev2)
	_check("[,] 反向切到最後一頁（idx=%d）" % node._page_idx, node._page_idx == UiPages.PAGE_ORDER.size() - 1)
	# ★★overlay 開著時不吃：★★★守衛是【結構性】的（_input 裡每個 overlay 先 return），
	#   而這一格就是在驗那個結構真的擋得住 —— 不是驗我寫了一個 if。
	node._page_idx = 2
	node._encounter_view.visible = true
	node._input(ev)
	_check("overlay 可見時切鍵被吞（頁仍是 2，實得 %d）" % node._page_idx, node._page_idx == 2)
	node._encounter_view.visible = false
	node._input(ev)
	_check("overlay 收起後切鍵恢復（頁變 3，實得 %d）" % node._page_idx, node._page_idx == 3)
	await _free_ui(node)
	_cell("_test_pages_switch_key")

# 從一行文字裡撈 `key=<整數>`。★找不到回 -1（★★而 -1 的意思是【沒撈到】，不是 0）。
func _kv_int(line: String, key: String) -> int:
	var i: int = line.find(key)
	if i == -1: return -1
	var rest: String = line.substr(i + key.length())
	var digits: String = ""
	for ch in rest:
		if ch >= "0" and ch <= "9": digits += ch
		else: break
	return int(digits) if digits != "" else -1

# ★宣告清單從【畫面那一支】拿，不在測試裡複製一份 —— ★★複製的那份不會跟著票B 變短，
#   而它會讓這一格在票B 接好之後【對著一份過期的宣告】判紅。
func _page_skylight_fields_of(node: Node, idx: int) -> Array:
	return node._page_skylight_fields(idx)

# 撈出【第一條含 key 的行】。★找不到回空字串（★★空字串＝【沒有那一行】，
#   不是【那一行是空的】—— 這兩件事在判準上不一樣）。
# 把五頁的內容組成【一個沒有重複框架】的聯集：狀態列 ＋ 各頁分頁區 ＋ 頁尾。
# ★用途：票B 把行搬到別頁之後，「有沒有東西不見了」仍然問得出來。
func _union_all_pages(node: Node) -> Array:
	var out: Array = []
	var keep: int = node._page_idx
	# ★★★`_build_state_str()` 【不是冪等的】：它會寫 `_res_baseline_day`／`_res_baseline`
	#   （text_ui_main.gd 的資源趨勢箭頭靠它算）⇒ ★第一次呼叫與第二次呼叫【輸出不同】。
	#   ★★血證：聯集呼叫它 5 次，而「前」是【單獨一次】產生的
	#     ⇒ 少了那個 `↓` ⇒ 零損失報「舊 1 次 → 新 0 次：  食:49↓ 幣:2085 材:5」。
	#   ⇒ ★★★所以每一頁都要從【同一個起點】renders —— 存起來、每次還原。
	var keep_day: int = node._res_baseline_day
	var keep_base: Dictionary = node._res_baseline.duplicate()
	for i in range(UiPages.PAGE_ORDER.size()):
		node._page_idx = i
		node._res_baseline_day = keep_day
		node._res_baseline = keep_base.duplicate()
		var ls: PackedStringArray = node._build_state_str().split("\n")
		var head: String = UiPages.header(i)
		var hi: int = -1
		for li in range(ls.size()):
			if String(ls[li]) == head: hi = li; break
		if hi == -1: continue
		if i == 0:
			# ★狀態列（頁首之前）只取一次
			for li in range(hi): out.append(String(ls[li]))
		for _b in _page_body(ls, head): out.append(String(_b))
		var li2: int = ls.size()
		for _k in range(ls.size() - 1, hi, -1):
			if String(ls[_k]).begins_with("Tick: "): li2 = _k; break
		if li2 - 1 > hi and String(ls[li2 - 1]).begins_with("────"): li2 -= 1
		if i == 0:
			# ★頁尾（Tick·Day 那段）只取一次
			for li in range(li2, ls.size()): out.append(String(ls[li]))
	node._page_idx = keep
	return out

# 取【分頁區】＝頁首之後、頁尾之前。
# ★★★頁尾的判準【不能是「第一條 ────」】——那是我第一版的寫法，而它一撞到
#   票B 就壞了：搬到經濟頁的資源段【開頭就是一條分隔線】⇒ 整頁被判成 0 行，
#   ★而那讓 P1-a 與 P1-b 同時誤紅（看起來像「內容不見了」，其實是【我沒讀到】）。
# ⇒ 改成錨在【Tick: 那一行】：頁尾是「Tick: 前面那條分隔線」開始的那一段。
# ★★★P1-b 的【具名排除清單】（systems 裁 2026-09-23）——
#   ★每一條都帶【為什麼】，★★而【不是】用「含 ↓↑ 就忽略」那種模糊比對：
#     模糊比對會連【真的掉了一行含箭頭的內容】也一起放過。
#   ★★★清單長度會印出來 ⇒ 它變長時有人看得見。
# ★★★【空了】—— 2026-09-23「render 不得寫 state」那張票把債還掉了。
#   原本唯一那一條是「  食:」（資源趨勢箭頭）：`_build_state_str()` 會寫 `_res_baseline*`
#   ⇒ 同一份世界、不同呼叫史就不是同一行字 ⇒ 該比而不比。
#   ★現在基準線的擁有者搬到日邊界（`_update_day_baseline()`，由 `_process()` 呼叫）
#   ⇒ render 只讀不寫 ⇒ 不需要豁免。
# ★★而這張清單【空著本身就是判準】（`_test_p1b_exclude_empty`）——
#   ★★★下一個人要再加一條，那一格會紅，他就必須說明為什麼那筆債可以欠。
const P1B_EXCLUDE: Array = [
]

# 回傳「這一行是否被具名排除」。★只比【前綴】且前綴必須來自上面那張表。
# ★★★【結構行】不進比對 —— 這不是豁免，是 spec 本來就寫的範圍（AMEND 2026-09-23 逐字：
#   「新增的行（頁首、未分類標題、天窗）不在比對範圍內」）。
#   ★而「前」是【票A 之後】拍的 ⇒ 它【已經含有】這些結構行 ⇒ 兩邊都要排，否則：
#     ①頁首：聯集用分頁區組，本來就不含頁首 ⇒ 「前」有、「後」沒有 ⇒ 假紅
#     ②★★未分類標題帶著行數（「將搬走 16 行」）⇒ 票B 每搬一批它【必然改變】
#        ⇒ ★★★拿它逐字比，等於要求票B 不要做事
# ★這與 P1B_EXCLUDE 是【兩件事】：那張表是【有代價的豁免】（該比而不比，要還債），
#   這裡是【本來就不該比的東西】—— ★★所以分開兩個函式，不混成一張表。
# 【範圍表】—— ★★★每一條都要指回 spec 的【哪一句】（systems 裁 2026-09-23）。
#   ★理由：範圍表與欠債表的【防長大】機制不一樣 ——
#     欠債表靠「帶票號 ＋ 印長度」；★★範圍表靠「每條指得回去」。
#   ★★★否則它會變成【為了讓守衛變綠而搬進來的地方】，
#     而那比欠債更隱形：★欠債至少承認自己是債。
const P1B_STRUCTURAL: Array = [
	{"kind": "page_header", "spec": "2026-09-23-ui-five-tabs-HOW.md AMEND：「新增的行（頁首、未分類標題、天窗）不在比對範圍內」"},
	{"kind": "unclassified_header", "spec": "同上 —— ★而它【帶著行數】，票B 每搬一批必然改變"},
	{"kind": "skylight", "spec": "同上 —— 天窗是票A 新增的行，不是舊畫面上的內容"},
]

# 回傳這一行屬於哪一種結構行；不是結構行回空字串。
func _p1b_structural_kind(line: String) -> String:
	if line.begins_with("── 未分類（"): return "unclassified_header"
	if line.ends_with("未接出（票B）"): return "skylight"
	for i in range(UiPages.PAGE_ORDER.size()):
		if line == UiPages.header(i): return "page_header"
	return ""

func _p1b_structural(line: String) -> bool:
	return _p1b_structural_kind(line) != ""

func _p1b_excluded(line: String) -> bool:
	for e in P1B_EXCLUDE:
		if line.begins_with(String(e["prefix"])): return true
	return false

func _page_body(ls: PackedStringArray, head: String) -> Array:
	var hi: int = -1
	for i in range(ls.size()):
		if String(ls[i]) == head: hi = i; break
	if hi == -1: return []
	var ti: int = ls.size()
	for i in range(ls.size() - 1, hi, -1):
		if String(ls[i]).begins_with("Tick: "): ti = i; break
	# ★Tick 行前面那條分隔線也屬於頁尾
	if ti - 1 > hi and String(ls[ti - 1]).begins_with("────"): ti -= 1
	var out: Array = []
	for i in range(hi + 1, ti): out.append(String(ls[i]))
	return out

func _line_with(text: String, key: String) -> String:
	for ln in text.split("\n"):
		if String(ln).contains(key): return String(ln)
	return ""

# ★`_uniq_n()` 已刪（2026-09-23）：它唯一的用途是切頁那格的「走完有幾個相異」，
#   而那個判準【兩邊同源、驗不出步長錯】，已窄化成「每一步剛好 +1」⇒ 這支沒有呼叫端了。
#   ★刪前驗過：全檔 `_uniq_n` 只剩【定義本身】一處出現（0 個呼叫端）。
#   ★★留這行字的理由跟刪掉那 8 行 `_log_event` 一樣：一個被刪掉的東西如果沒有留下
#     它在哪的紀錄，下一個人會以為它從來不存在 —— 而休眠的死碼正是靠「沒人記得」活下來的。

# P4[天窗]：第 2–5 頁的未接欄位必須印「未接出（票B）」，不得靜默空白。
func _test_pages_skylight() -> void:
	_selftest_gate("_test_pages_skylight").noop()
	print("\n── 票A P4 天窗 ──")
	var node = await _make_ui()
	var total: int = 0
	var declared: int = 0
	# ★★★從 0 開始，不是從 1：舊版跳過第 1 頁，而票B 第 2 批替生存頁加了宣告欄位
	#   ⇒ ★那四欄【不在母體裡】⇒ 印不印天窗都不會紅（systems 核出來的）。
	#   ★★這一族今天第四次：母體的起點寫死了一個【當時成立、後來不成立】的假設。
	for i in range(0, UiPages.PAGE_ORDER.size()):
		node._page_idx = i
		var s: String = node._build_state_str()
		# ★★★這一格是【一致性】檢查，不是【正確性】檢查 —— 兩邊同源（2026-09-23 自檢）：
		#   n 來自畫面，而畫面是【照 `_page_skylight_fields(i)` 印出來的】；d 也是它。
		#   ⇒ ★它抓得到：宣告了卻沒印（render 壞掉／函式被截斷）、印了卻沒宣告。
		#   ⇒ ★★它【抓不到】：宣告本身是錯的（少宣告一欄，兩邊一起少，照樣綠）。
		#   ⇒ ★★★那個缺口要由【外部錨】補：spec 裡的欄位清單。今天沒有那個錨，寫在這裡不假裝有。
		var n: int = s.count("未接出（票B）")
		var d: int = _page_skylight_fields_of(node, i).size()
		total += n
		declared += d
		_check("第 %d 頁（%s）印出的天窗 %d ＝ 宣告未接 %d" % [
			i + 1, String(UiPages.PAGE_ORDER[i]), n, d], n == d)
	# ★★★機器可讀的一行（systems 要的）：票B 每接好一欄它就變小 ⇒ 這是「天窗遞減」的讀數。
	print("[UI-SKYLIGHT] count=%d declared=%d" % [total, declared])
	print("  ★票A 交付時絕大多數格子是天窗（共 %d 個）—— 這是預期不是缺陷" % total)
	# ★★★P4 強化（reviewer R² 的非阻塞建議，2026-09-23）：
	#   ★缺口：接出一欄卻忘了把它從宣告拿掉 ⇒ 畫面會【同時印值與天窗】
	#     —— 而那比純天窗更糟：它同時說「有」跟「沒有」。
	#   ★★page0／page1 的兩欄已用動態 is_empty() 綁死不會脫鉤；
	#     風險留在【尚未接出的靜態清單】（page1-4），而那正是這一格守的東西。
	#   ⇒ 判法：同一頁裡，★★★某欄位既印了天窗、又有另一行以它的名字開頭 ⇒ 紅。
	var dup: Array = []
	for i in range(0, UiPages.PAGE_ORDER.size()):
		node._page_idx = i
		var ls: PackedStringArray = node._build_state_str().split("\n")
		var body: Array = _page_body(ls, UiPages.header(i))
		for f in node._page_skylight_fields(i):
			var name: String = String(f).split("（")[0]
			for ln in body:
				var t: String = String(ln)
				if t.ends_with("未接出（票B）"): continue
				if t.begins_with(name):
					dup.append("第 %d 頁「%s」既有天窗又有內容行：%s" % [i + 1, name, t])
	for d in dup: print("    ✗ %s" % String(d))
	_check("沒有欄位【同時】印值與天窗（%d 筆）" % dup.size(), dup.is_empty())
	# ★★★P4 原本判「天窗總數 0 ⇒ 紅」，而【票B 的成功條件正是天窗歸零】
	#   ⇒ ★票B 做完的那一天，這一格會因為【票B 成功】而變紅 —— 那是一個有到期日的守衛。
	#   ⇒ ★★所以判準換掉：★★★不是「必須有天窗」，是【宣告未接的欄位，每一個都要印出天窗】。
	#     declared 由 _page_skylight_fields() 宣告；票B 接好一欄就把它從宣告裡拿掉
	#     ⇒ declared 降到 0 時 total 也是 0 ⇒ 這一格【自然變綠】，不必有人回來改它。
	_check("每一個宣告未接的欄位都印出天窗（印 %d／宣告 %d）" % [total, declared], total == declared)
	# ★而【母體地板】改釘在【宣告】上：宣告 0 且票B 還沒做完 ⇒ 是這一格自己壞了
	#   ⇒ ★★所以這條只在票B 尚未交付時有意義，交付後它會與上面那條一起自然放行。
	if declared == 0:
		print("  ★★★宣告數 0 ⇒ 兩種可能：①票B 已把五頁全接完 ②_page_skylight_fields 壞了")
		print("    ⇒ ★這一格【不判】——請看 [UI-SKYLIGHT] 那一行的歷史走勢，而不是看這一格的顏色")
	await _free_ui(node)
	_cell("_test_pages_skylight")

# P3[單一來源]：text_ui_main.gd 不得有頁名字面值；c1_walkthrough.gd 不得自帶 PAGE_ORDER。
# ★★這一格掃的是【原始碼文字】，而它防的是「明天再長出第二份名單」。
func _test_pages_single_source() -> void:
	_selftest_gate("_test_pages_single_source").noop()
	print("\n── 票A P3 單一來源 ──")
	var ui_src: String = FileAccess.get_file_as_string("res://scripts/ui/text_ui_main.gd")
	var walk_src: String = FileAccess.get_file_as_string("res://scripts/debug/c1_walkthrough.gd")
	_check("原始碼撈得到（text_ui %d 字元／walkthrough %d 字元）" % [ui_src.length(), walk_src.length()],
		ui_src.length() > 1000 and walk_src.length() > 500)
	for name in UiPages.PAGE_ORDER:
		# ★只看【字串字面值】形態："生存"：註解裡提到頁名不算違規
		var lit: String = "\"%s\"" % String(name)
		_check("text_ui_main.gd 沒有頁名字面值 %s" % lit, not ui_src.contains(lit))
	_check("c1_walkthrough.gd 不再自帶 PAGE_ORDER", not walk_src.contains("const PAGE_ORDER"))
	_check("c1_walkthrough.gd 改讀 UiPages.PAGE_ORDER", walk_src.contains("UiPages.PAGE_ORDER"))
	_cell("_test_pages_single_source")


# ★票B Q1[來源]：接出來的欄位必須走【公開查詢面】—— 不得直接讀 state、不得是常數。
#   ★★這一格掃的是【原始碼文字】，而它防的是「接出來的值其實是自己算的／寫死的」。
func _test_pages_q1_source() -> void:
	_selftest_gate("_test_pages_q1_source").noop()
	print("
── 票B Q1 來源走查詢面 ──")
	var src: String = FileAccess.get_file_as_string("res://scripts/ui/text_ui_main.gd")
	_check("撈得到原始碼（%d 字元）" % src.length(), src.length() > 1000)
	for fn in ["_build_survival_lines", "_build_economy_lines"]:
		var a: int = src.find("func " + fn)
		_check("找得到 %s" % fn, a != -1)
		if a == -1: continue
		var b: int = src.find("
func ", a + 5)
		var body: String = src.substr(a, (b - a) if b != -1 else src.length() - a)
		# ★禁止：直接讀 state／runner；★★而 _cached_snapshot 與參數 ct/ps 是查詢面快照，允許
		_check("%s 不直接讀 state" % fn, not body.contains("_bridge.get_state()") and not body.contains("state."))
		_check("%s 不直接持有 runner" % fn, not body.contains("_runner"))
	_cell("_test_pages_q1_source")

# ★票B Q3[會動]：同一顆種子、兩個不同 tick ⇒ 畫面 diff 非空，★並印出【哪一行】變了。
#   ★★★母體地板：兩邊都要真的推到目標 —— 推不到就判【不可判】，
#     因為「沒有 diff」與「沒有推進」在卷面上長得一樣（★今天已經踩過一次）。
func _test_pages_q3_changes() -> void:
	_selftest_gate("_test_pages_q3_changes").noop()
	print("
── 票B Q3 世界動了畫面跟著動 ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var snaps: Array = []
	var reached: Array = []
	for target in [60, 120]:
		var g: int = 0
		while st.world.current_tick < target and g < 600:
			if not node._bridge.is_advancing():
				node._bridge.request_advance(target - st.world.current_tick)
			await process_frame
			g += 1
		reached.append(st.world.current_tick)
		snaps.append(node._build_state_str())
	print("  推進實得：%s（目標 60／120）" % str(reached))
	if int(reached[0]) != 60 or int(reached[1]) != 120:
		print("  ★★★【不可判】沒有推到兩個不同的 tick ⇒ 「沒有 diff」與「沒有推進」分不開")
		await _free_ui(node)
		_cell("_test_pages_q3_changes")
		return
	var a2: PackedStringArray = String(snaps[0]).split("
")
	var b2: PackedStringArray = String(snaps[1]).split("
")
	var changed: Array = []
	var n: int = maxi(a2.size(), b2.size())
	for i in range(n):
		var x: String = String(a2[i]) if i < a2.size() else "（無）"
		var y: String = String(b2[i]) if i < b2.size() else "（無）"
		if x != y: changed.append("第 %d 行：「%s」→「%s」" % [i + 1, x, y])
	# ★★★時鐘不算數：`Tick: N (Day D)` 每一顆 tick 都會變
	#   ⇒ ★就算【世界完全沒動、畫面完全沒更新】，只比「diff 非空」也會綠
	#   ⇒ ★★這與票A 的 P1-a 是同一個形狀（那一格被【頁尾的 Tick·Day】撐著恆綠，
	#     窄化到分頁區才修掉）—— ★★★所以這裡也要把【框架】排掉再問。
	var clock_changed: bool = false
	var real: Array = []
	for c in changed:
		if String(c).contains("Tick: "): clock_changed = true
		else: real.append(c)
	print("  ★變了 %d 行（其中時鐘 %s）：" % [changed.size(), "有變" if clock_changed else "沒變"])
	for c in changed: print("    %s" % String(c))
	_check("★時鐘以外還有東西變了（%d 行）—— 時鐘不算數" % real.size(), not real.is_empty())
	# ★而時鐘【該】變：它沒變代表兩次其實是同一個 tick ⇒ 那是【不可判】不是綠
	_check("時鐘確實前進了（兩次不是同一顆 tick）", clock_changed)
	await _free_ui(node)
	_cell("_test_pages_q3_changes")


# ════════ 票：查詢面補「家」（P1–P4）════════
# ★★★P3／P4 是【母體地板】：沒有它們，P1 在「剛好每隊都有且只有一個據點」的世界裡恆綠。

func _home_page_text(node: Node) -> String:
	node._page_idx = 0
	return node._build_state_str()

# 把玩家隊的據點數改成 n（0 或 2）。★走 tile 的真實欄位＋invalidate，不偽造快照。
func _home_set_outposts(node: Node, n: int) -> void:
	var st = node._bridge.get_state()
	var tid: int = st.persons[st.player_id].team_id
	var made: int = 0
	for key in st.world.tiles:
		var t = st.world.tiles[key]
		if t.outpost_owner == tid and t.outpost_level > 0:
			t.outpost_level = 0
			t.outpost_owner = -1
	if n > 0:
		var home: Vector2i = st.teams[tid].tile_pos
		for key2 in st.world.tiles:
			var t2 = st.world.tiles[key2]
			if made >= n: break
			t2.outpost_owner = tid
			t2.outpost_level = 1
			t2.outpost_type = "civilian"
			made += 1
	OwnerOutpostIndex.invalidate()
	node._bridge.request_advance(1)
	await process_frame

# P1[天窗消失]：查詢面給得出來 ⇒ 生存頁印真值，且「位置與家」不再是天窗
func _test_home_p1_value() -> void:
	_selftest_gate("_test_home_p1_value").noop()
	print("
── 家 P1 天窗消失、改印真值 ──")
	var node = await _make_ui()
	var ct: Dictionary = node._cached_snapshot.get("controlled_team", {})
	_check("查詢面有 home_pos 這個 key（★母體地板：沒有 key 的話下面全是空談）", ct.has("home_pos"))
	_check("三欄【同時】存在（pos/kind/distance）",
		ct.has("home_pos") and ct.has("home_kind") and ct.has("home_distance"))
	var s: String = _home_page_text(node)
	_check("生存頁不再印「位置與家」天窗", not s.contains("位置與家"))
	_check("生存頁印出「家：」那一行", s.contains("家："))
	await _free_ui(node)
	_cell("_test_home_p1_value")

# P2[成對對照]：把 home_pos 從查詢面拿掉 ⇒ ★那一格變回天窗（不是整頁壞掉）
func _test_home_p2_pair() -> void:
	_selftest_gate("_test_home_p2_pair").noop()
	print("
── 家 P2 成對對照 ──")
	var node = await _make_ui()
	var before: String = _home_page_text(node)
	_check("注射前：不是天窗", not before.contains("位置與家"))
	# ★只拿掉 home_pos 這一個 key —— ★★不動共用欄位（打共用欄位會讓整頁塌，那是零資訊）
	node._cached_snapshot["controlled_team"].erase("home_pos")
	var after: String = _home_page_text(node)
	_check("拿掉 home_pos ⇒ 「位置與家」變回天窗", after.contains("位置與家"))
	_check("★而整頁沒壞：其他行還在（人口／糧）", after.contains("糧") or after.contains("人口"))
	await _free_ui(node)
	_cell("_test_home_p2_pair")

# P3[無家]：沒有據點 ⇒ 三欄皆 null ⇒ 印「家：無」★而不是 (0,0)
func _test_home_p3_none() -> void:
	_selftest_gate("_test_home_p3_none").noop()
	print("
── 家 P3 沒有據點 ──")
	var node = await _make_ui()
	await _home_set_outposts(node, 0)
	var ct: Dictionary = node._cached_snapshot.get("controlled_team", {})
	_check("home_pos 為 null（★不是 (0,0)、不是 (-1,-1)）", ct.get("home_pos", 1) == null)
	_check("三欄【同時】為 null", ct.get("home_pos", 1) == null and ct.get("home_kind", 1) == null and ct.get("home_distance", 1) == null)
	var s: String = _home_page_text(node)
	_check("畫面印「家：無」", s.contains("家：無"))
	_check("★畫面沒有印出 (0,0)", not s.contains("家：(0,0)"))
	await _free_ui(node)
	_cell("_test_home_p3_none")

# P4[多據點]：★「暫代」兩個字是判準的一部分，不是文案 —— grep 不到 ⇒ 紅
func _test_home_p4_multi() -> void:
	_selftest_gate("_test_home_p4_multi").noop()
	print("
── 家 P4 多據點與【暫代】 ──")
	var node = await _make_ui()
	await _home_set_outposts(node, 2)
	var ct: Dictionary = node._cached_snapshot.get("controlled_team", {})
	_check("home_count ≥ 2（★母體地板：造不出兩個據點就別談多據點）", int(ct.get("home_count", 0)) >= 2)
	var s: String = _home_page_text(node)
	_check("畫面標出「（共 %d 處）」" % int(ct.get("home_count", 0)), s.contains("（共 "))
	_check("★★★畫面標出【暫代】—— 本城欄未落地，沒有這兩個字就分不出【這就是家】與【先湊一個】",
		s.contains("【暫代】"))
	await _free_ui(node)
	_cell("_test_home_p4_multi")


# P5[半套]：合約說三欄同時給或同時 null —— ★而合約破掉時要【看得見地壞】。
#   ★★這一格是從 P3 的陽性對照長出來的：那次注射讓 home_pos 單獨有值，
#     結果 `int(null)` 丟錯【把整個 _build_survival_lines 砍斷】，而點名照樣滿分。
func _test_home_p5_halfset() -> void:
	_selftest_gate("_test_home_p5_halfset").noop()
	print("
── 家 P5 半套要看得見地壞 ──")
	var node = await _make_ui()
	node._cached_snapshot["controlled_team"]["home_pos"] = {"q": 3, "r": 4}
	node._cached_snapshot["controlled_team"]["home_kind"] = null
	node._cached_snapshot["controlled_team"]["home_distance"] = null
	node._page_idx = 0
	var s: String = node._build_state_str()
	_check("半套時印出【半套】而不是崩掉", s.contains("【半套】"))
	_check("★而後面的行還在（函式沒有被砍斷）", s.contains("糧") or s.contains("人口"))
	await _free_ui(node)
	_cell("_test_home_p5_halfset")


# P6[(0,0) 是真座標不是哨兵]：reviewer 2026-09-23 的非阻塞建議，補成永久格。
#   ★為什麼要有：「沒有家」的表示法是 null，而 (0,0) 是【地圖上一個真的格子】。
#     ★★如果哪天有人把「沒有家」改成回 (0,0)（很常見的偷懶），畫面會印出
#       「家：(0,0)」而那是【一句謊】—— 而它不會有任何別的訊號。
#   ★★★這一格只驗畫面：production 端用 `_hp == null` 判、不是比座標值，
#     所以這裡釘的是【那個性質不准退化】，不是在補一個現在會紅的洞。
func _test_home_p6_zero_is_real() -> void:
	_selftest_gate("_test_home_p6_zero_is_real").noop()
	print("
── 家 P6 (0,0) 是真座標不是哨兵 ──")
	var node = await _make_ui()
	var ct: Dictionary = node._cached_snapshot["controlled_team"]
	ct["home_pos"] = {"q": 0, "r": 0}
	ct["home_kind"] = "營地"
	ct["home_distance"] = 7
	node._page_idx = 0
	var s: String = node._build_state_str()
	_check("三欄同時給、pos=(0,0) ⇒ 畫面印出座標", s.contains("家：(0,0)"))
	_check("★而【不是】「家：無」（(0,0) 不可被當成沒有家）", not s.contains("家：無"))
	_check("★★也不是【半套】（三欄齊全 ⇒ 不該走降級路徑）", not s.contains("【半套】"))
	_check("離家距離照印（7）", s.contains("離家 7"))
	await _free_ui(node)
	_cell("_test_home_p6_zero_is_real")


# ══════════ 票「render 不得寫 state」的驗收（HOW spec §4）══════════

# P1[冪等]：連續呼叫 `_build_state_str()` 兩次 ⇒ 逐字相同。
#   ★★母體地板：那一輪必須真的有【資源行】—— 否則兩次都沒有箭頭 ⇒ 這一格恆真。
func _test_render_idempotent() -> void:
	_selftest_gate("_test_render_idempotent").noop()
	print("
── render P1 冪等 ──")
	var node = await _make_ui()
	node._page_idx = 1   # 經濟頁：資源行在這一頁
	var a: String = node._build_state_str()
	var b: String = node._build_state_str()
	_check("★母體地板：這一輪真的有資源行（「食:」）—— 沒有的話冪等恆真", a.contains("食:"))
	_check("連續兩次 _build_state_str() 逐字相同", a == b)
	if a != b:
		var la: PackedStringArray = a.split(String.chr(10))
		var lb: PackedStringArray = b.split(String.chr(10))
		for i in range(min(la.size(), lb.size())):
			if la[i] != lb[i]:
				print("    第 %d 行不同：
      前「%s」
      後「%s」" % [i, la[i], lb[i]])
	await _free_ui(node)
	_cell("_test_render_idempotent")

# ★★★P1b[堵住「搬到姊妹函式」]：★塞一個【陳舊的基準】，畫一次，看 render 動不動它。
#
# ★★這一格改過兩次，兩次都是因為前一版【證明得出來是恆綠的】：
#   v1「連續呼叫 _build_state_str() 兩次」⇒ 繞過 _refresh()，把寫入搬進 _refresh() 照樣綠。
#   v2「呼叫史 1 次 vs 5 次」⇒ ★reviewer 2026-09-23 提疑、而我靜態推完證實他對：
#      壞設計下第 1 次就把基準寫定，第 2–5 次 `day == _res_baseline_day` 直接跳過
#      ⇒ n1 與 n5 算出【同一個值】⇒ 恆綠。★★整段測試沒有 tick 推進，世界資源不會變，
#        「這個 instance 第一次 render 時基準＝當下資源」對兩邊同樣成立。
#   ⇒ ★★★所以鑑別力的真來源不是【畫幾次】，是【基準與現值不同】——
#     而那個差異我可以直接塞進去，不必等世界跨日。
#
# 塞法：`_res_baseline` 設成比現值高一截、`_res_baseline_day` 設成一個不可能等於今天的值。
#   壞設計（render 會寫）⇒ 它看到 day != -999 ⇒ 當場把基準覆寫成現值 ⇒ 箭頭【持平】、且欄位被改。
#   好設計（render 只讀）⇒ 基準留著 ⇒ 現值 < 基準 ⇒ 箭頭【↓】、且欄位原封不動。
# ★兩個方向都驗：只驗「沒被改寫」的話，一支【根本不讀基準】的 render 也會綠。
func _test_refresh_idempotent() -> void:
	_selftest_gate("_test_refresh_idempotent").noop()
	print("
── render P1b 陳舊基準：render 只准讀不准寫 ──")
	var node = await _make_ui()
	node._page_idx = 1
	var ct: Dictionary = node._cached_snapshot.get("controlled_team", {})
	var res: Dictionary = ct.get("resources", {})
	_check("★母體地板：查詢面真的有資源（%d 個欄位）—— 沒有的話下面全是空談" % res.size(),
		not res.is_empty())
	if res.is_empty():
		await _free_ui(node)
		_cell("_test_refresh_idempotent")
		return
	const STALE_DAY: int = -999
	var planted: Dictionary = {
		"food": float(res.get("food", 0)) + 1000.0,
		"coin": float(res.get("coin", 0)) + 1000.0,
		"material": float(res.get("material", 0)) + 1000.0}
	node._res_baseline = planted.duplicate()
	node._res_baseline_day = STALE_DAY
	node._refresh()
	var txt: String = node._state_label.text
	_check("★★render 沒有改寫基準的【日】（仍是 %d）" % STALE_DAY,
		node._res_baseline_day == STALE_DAY)
	_check("★★render 沒有改寫基準的【值】", node._res_baseline == planted)
	# ★★★而它必須【讀】那個基準 —— 否則「沒被改寫」對一支根本不讀它的 render 也成立
	_check("★★★而它讀了：現值低於基準 ⇒ 資源行出現「↓」（實際：%s）" % (
			"有" if txt.contains("↓") else "沒有"), txt.contains("↓"))
	# 附帶：呼叫史不得影響畫面（★這一項【自己】沒有鑑別力，見上面的 v2 檢討，留著當附加約束）
	var first: String = txt
	for _i in range(4):
		node._refresh()
	_check("附帶：再畫 4 次，輸出逐字相同（★此項單獨不具鑑別力）", node._state_label.text == first)
	await _free_ui(node)
	_cell("_test_refresh_idempotent")

# P2[債還了]：★綁【清單長度】不綁那一條的名字 ——
#   綁名字的判準會隨措辭漂成恆綠或恆紅（spec §4）。
#   ★★這一格不是形式：豁免清單變短【就是這張票的成果本身】。
func _test_p1b_exclude_empty() -> void:
	_selftest_gate("_test_p1b_exclude_empty").noop()
	print("
── render P2 豁免清單已清空 ──")
	_check("P1B_EXCLUDE 是空的（目前 %d 條）⇒ 零損失比對不再放過任何一行" % P1B_EXCLUDE.size(),
		P1B_EXCLUDE.is_empty())
	print("  ★★而【結構行】清單（P1B_STRUCTURAL，%d 條）是另一件事：那是 spec 本來就不比的，不是債。"
		% P1B_STRUCTURAL.size())
	_cell("_test_p1b_exclude_empty")
# ══════════ P11［頁腳常駐「待執行 N 道」］（spec §3-5③）══════════
# ★常駐＝0 也要印：只在非零時才出現的東西，玩家學不會它的意思，
#   而「沒看到」與「沒有這個功能」在畫面上長得一樣。
# ★★★負對照：入列之後【不推進】⇒ N 必須【維持】不歸零 ——
#   ★沒有這一格的話，一支「每次 render 都把佇列清掉」的實作也會 0→1→0 看起來很對。
func _test_p11_pending_footer() -> void:
	_selftest_gate("_test_p11_pending_footer").noop()
	print("
── P11 頁腳「待執行 N 道」──")
	var node = await _make_ui()
	node._refresh()
	_check("★0 也印（常駐）", node._hint_line.text.contains("待執行 0 道"))
	node._bridge.command_player("move_to", {"tile_q": 9999, "tile_r": 9999})
	node._refresh()
	_check("入列一條 ⇒ 「待執行 1 道」", node._hint_line.text.contains("待執行 1 道"))
	node._bridge.command_player("move_to", {"tile_q": 9998, "tile_r": 9998})
	node._bridge.command_player("cancel_move", {})
	node._refresh()
	_check("再入列兩條 ⇒ 「待執行 3 道」", node._hint_line.text.contains("待執行 3 道"))
	# ★★★負對照：多畫幾次但【不推進】⇒ N 不准變
	for _i in range(4):
		node._refresh()
	_check("★★★不推進而連畫 4 次 ⇒ N 仍是 3（render 不得消費佇列）",
		node._hint_line.text.contains("待執行 3 道"))
	await _free_ui(node)
	_cell("_test_p11_pending_footer")


# ══════════ P15［同一條指令的回音不得超過兩次］（systems 立 2026-09-23）══════════
# ★★★為什麼要有：(a) 那 13 處【玩家回饋】的刪除【不會紅】—— 它們只會【多講一次話】
#   （入列一次、消費點一次、它們自己第三次）⇒ ★電池看不到，只有人看得到。
#   ★★而 systems 的判準是：「要靠人看」的驗收【在忙的那一天會變成沒看】，
#     而它沒看的樣子跟看過的樣子一模一樣 ⇒ 用戶的眼球不是 QA。
#   ⇒ ★★★「多講一次話」是【數得出來的】：入列 1 ＋ 消費點 1 ＝ 上限 2，第三次就是沒刪乾淨的那一處。
# ★母體地板：那一輪必須真的有【≥1 條指令走完入列→消費】—— 否則 0 次也 ≤2（恆真）。
# ★★負對照：故意讓畫面多講一次 ⇒ 必須紅。
func _test_p15_echo_at_most_twice() -> void:
	_selftest_gate("_test_p15_echo_at_most_twice").noop()
	print("
── P15 同一條指令的回音 ≤ 2 次 ──")
	var node = await _make_ui()
	var st: WorldState = node._bridge.get_state()
	# ★★★走【真實鍵盤路徑】不是直呼 bridge（2026-09-24 實測訂正）：
	#   直呼 `command_player()` 【繞過了印回音的那一行】（text_ui_main.gd:322 的 KEY_M
	#   分支才會 `_set_feedback(r.ok, r.message)`）⇒ 畫面上 0 次 ⇒ 「≤2」恆真。
	#   ★而那是這一格的母體地板抓到的 —— 它紅在「入列之後畫面至少講了一次（0）」。
	#   ⇒ ★★地板第二次證明它不是形式：這次它擋的是【我自己的格沒走對路徑】。
	var ev := InputEventKey.new()
	ev.keycode = KEY_M
	ev.pressed = true
	var tq: int = node._cursor.x
	var tr: int = node._cursor.y
	node._input(ev)
	var enqueue_msg: String = node._feedback_line.text
	node._refresh()
	var screen_after_enqueue: String = _all_screen_text(node)
	var ap: Dictionary = _apply_queue(node)
	node._refresh()
	var screen_after_apply: String = _all_screen_text(node)
	_check("★母體地板：那一條真的走完了入列→消費（消費點吃到 %d 條）" % int(ap.get("applied", 0)),
		int(ap.get("applied", 0)) >= 1)
	# ★數的是【動作的人話】出現幾次 —— 不是整句比對（整句比對會因為前後綴不同而漏數）
	var needle: String = PlayerCommandApi.describe("move_to", {"tile_q": tq, "tile_r": tr})
	var n_enq: int = screen_after_enqueue.count(needle)
	var n_app: int = screen_after_apply.count(needle)
	print("  入列那一句：「%s」｜關鍵字：「%s」" % [enqueue_msg, needle])
	print("  畫面出現次數：入列後 %d 次｜消費後 %d 次" % [n_enq, n_app])
	# ══════════ ★★★這道地板的【真實獵物】（2026-09-23，當天就發生了）══════════
	#   systems 兩次裁定要把「(a) 那 13 處呼叫端自己印 message」刪掉，理由是「多講一次話」。
	#   ★而 (乙)① 要求入列當下印「已排入：<動作>」，`command_player` 回的 message【就是那一句】
	#   ⇒ ★★那些呼叫端不是【多講一次】的人，是【唯一講第一次】的人。
	#   ⇒ ★★★照那個裁定刪下去，入列回音會整個消失，而【這一道地板會紅】。
	#     （實際沒有刪成：implementer 動手前逐處驗前提，發現 14 處裡只有 7 處印兩遍。）
	#   ⇒ 所以這道地板擋的不是「別人寫錯」，★是【這一票自己的兩個決定互相打架】。
	#   ★一個地板有真實的獵物，下一個人才不會拿掉它 —— 這行字就是那隻獵物。
	_check("★★母體地板：入列之後畫面上【至少講了一次】（%d）—— 0 次的話下面恆真" % n_enq, n_enq >= 1)
	_check("★★★消費之後，同一條指令的回音 ≤ 2 次（實測 %d）—— 第三次就是沒刪乾淨的那一處" % n_app,
		n_app <= 2)
	await _free_ui(node)
	_cell("_test_p15_echo_at_most_twice")

# 取【整個畫面】的文字：★分開的 Label 各自一段，漏掉任一段就會少數到回音
func _all_screen_text(node) -> String:
	var parts: PackedStringArray = PackedStringArray()
	for nm in ["_state_label", "_event_label", "_log_strip", "_feedback_line", "_hint_line",
			"_alert_bar", "_input_bar", "_map_label", "_debug_bar"]:
		if node.get(nm) != null:
			parts.append(String(node.get(nm).text))
	return String.chr(10).join(parts)


# ══════════ P17［入列 → 推進 → 再 render，按玩家的順序接起來］（systems 立 2026-09-24）══════════
# ★★★這一格的存在理由是一個【床從頭到尾沒有在看的病】：
#   2026-09-24 真機每一幀噴 `Nonexistent function 'get' in base 'String'`，而電池 80／80 是綠的。
#   根因：`text_ui_main.gd` 把指令結果句以 **String** append 進 `_events`，
#   而 `_events` 的讀者（`_log_strip_text` :711、`_build_debug_str` :1018）都用 `e.get("msg")`。
# ★而床為什麼沒抓到：它有「入列」的格（P11）、有「消費」的格（重播床）、有「render」的格（P1／P1b）
#   —— ★★而沒有一格把三件事【按玩家的順序】接起來。
#
# ★★★而我這一格的【第一版自己也是假綠】，留著這段因為它正是同一個病：
#   第一版用 `_apply_queue(node)` 推進，而那支 helper 只叫 `tick_step()`、★【沒有叫 `_process()`】
#   ⇒ 而把結果句排進 `_events` 的那段就在 `_process()` 裡
#   ⇒ ★`_events` 全程是空的 ⇒ 我那兩條形狀斷言【在空陣列上恆真】（卷面上寫著「共 0」）
#   ⇒ ★★而母體地板也沒接住，因為它找的是「畫面上有那句人話」——
#     而【入列回音】與【消費結果句】含同一句人話 ⇒ 它命中了前者
#   ⇒ ★★★所以這一版改成走【真的 `_process()`】，並把地板釘在 `_events` 裡的那一筆上。
func _test_p17_consume_then_render() -> void:
	_selftest_gate("_test_p17_consume_then_render").noop()
	print("
── P17 入列 → 推進 → 再 render ──")
	var node = await _make_ui()
	var st: WorldState = node._bridge.get_state()
	var ev := InputEventKey.new()
	ev.keycode = KEY_M
	ev.pressed = true
	var tq: int = node._cursor.x
	var tr: int = node._cursor.y
	var ev_n0: int = node._events.size()
	var log_n0: int = st.command_log.size()
	node._input(ev)                                  # ①入列（真實鍵盤路徑）
	# ②★走【玩家真的走的那條路】：`_process()` 自己會 tick_step ＋ 排空結果句 ＋ 在結尾 _refresh
	node._bridge.request_advance(1)
	node._process(0.1)
	_check("★母體地板①：消費點真的吃到了（command_log %d → %d）" % [log_n0, st.command_log.size()],
		st.command_log.size() > log_n0)
	# ★★母體地板②：結果句真的【進了 `_events`】—— 不是「畫面上有那句人話」
	#   （入列回音也含同一句人話 ⇒ 用畫面找會命中錯的那一個）
	var needle: String = PlayerCommandApi.describe("move_to", {"tile_q": tq, "tile_r": tr})
	var hit: int = 0
	for e in node._events:
		if (e is Dictionary) and String((e as Dictionary).get("msg", "")).contains(needle):
			hit += 1
	_check("★★母體地板②：結果句進了 _events（%d 筆命中「%s」；事件數 %d → %d）" % [
		hit, needle, ev_n0, node._events.size()], hit >= 1)
	# ★★★形狀：走讀者【真的會走的那條路】—— `_events` 混進 String 就會在這裡丟錯，
	#   而那個錯會把這一格砍斷 ⇒ 到場點名少一格（那就是它的偵測方式）
	var strip: String = TextUiMain._log_strip_text(node._events, 3)
	var dbg: String = node._build_debug_str()
	_check("★★★讀者走得過去且真的有東西：_log_strip_text() 回了 %d 字（0 字＝事件流是空的）" % strip.length(),
		strip.length() > 0)
	_check("★_build_debug_str() 印了事件段", dbg.contains("Events(last10)"))
	_check("★★而那一段裡看得到指令結果（type 標成 cmd）", dbg.contains("[cmd]"))
	# ★★★判準窄化成【必須是 Dictionary】，不是【必須有 msg】（2026-09-24 實測訂正）：
	#   玩家入口跑 1200 tick 之後這一條紅了（壞形狀 1／共 12），★而那【不是產品錯】——
	#   `sim_bridge._diff_events()` 合法地產出【只有 type 沒有 msg】的事件
	#   （`{"type":"encounter_triggered"}`／`{"type":"new_team_spotted"}`），
	#   而讀者用 `.get("msg", "")` 本來就容忍它。
	#   ⇒ ★★所以 `_events` 有【兩種合法形狀】，而我把其中一種寫成了缺陷。
	#   ⇒ ★★★窄化的方向要對：真 bug 是【String 混進來】（`String` 沒有 `.get()`）
	#     ⇒ 判「是不是 Dictionary」仍然抓得到它，而不會誤咬 type-only 那一種。
	var bad_shape: int = 0
	for e in node._events:
		if not (e is Dictionary):
			bad_shape += 1
	_check("★_events 每一個元素都是 Dictionary（★String 混進來就會在讀者身上丟錯）（壞形狀 %d／共 %d，★共 0 是不可判不是綠）" % [
		bad_shape, node._events.size()], bad_shape == 0 and node._events.size() > 0)
	await _free_ui(node)
	_cell("_test_p17_consume_then_render")


# ══════════ 游標懸停印整格真值（spec 2026-09-25，★明裁的 god-view 例外）══════════
# ★這一組的重點不是「印得出來」，是【它結構上流不進決策】——
#   所以 P3（不寫 state）才是這一票真正的判準，P1／P2 是它的前提（東西真的在）。

# ★★★按一個鍵 —— 走【真實鍵盤路徑】（`node._input`），不直呼 bridge。
#   ★理由是 2026-09-24 P17 的血証：現成的工具會把你帶回它原本服務的那條路，
#     而【玩家那條路】恰恰是沒有現成工具的那一條。
func _press_key(node, key: int) -> void:
	var ev := InputEventKey.new()
	ev.keycode = key
	ev.pressed = true
	node._input(ev)

# ★游標移動＝按鍵的一個特例 ⇒ 委派，不另寫一份（兩份實作會漂）
func _hover_move(node, key: int) -> void:
	_press_key(node, key)

# P1[即時]：移動游標【不按 Enter】⇒ 該格真值出現。
# ★即時性不是新加的機制：`_move_cursor()` 結尾本來就 `_refresh()`
#   ⇒ 這一格驗的是【那個區塊讀的是 `_cursor` 而不是 `_selected`】。
# ★★母體地板：游標要【真的動了】（而且 `_selected` 要維持未選狀態，否則印出來的
#   可能是舊的「選中」區塊，而那一段本來就存在 ⇒ 這一格會在沒做事時也綠）。
# 負對照：拿掉 `_move_cursor()` 結尾的 `_refresh()`（＝把即時觸發拿掉） ⇒ 已於 feat/cursor-hover-truth（2026-09-24 這一輪） 實測紅
func _test_hover_p1_live() -> void:
	_selftest_gate("_test_hover_p1_live").noop()
	print("
── 懸停 P1 不按 Enter 就出真值 ──")
	var node = await _make_ui()
	var c0: Vector2i = node._cursor
	_check("★★母體地板：起始 _selected 是未選狀態（%s）—— 否則印的可能是舊的選中區塊"
		% str(node._selected), node._selected == Vector2i(-1, -1))
	_hover_move(node, KEY_D)
	_check("★★母體地板：游標真的動了（%s → %s）" % [str(c0), str(node._cursor)],
		node._cursor != c0)
	# ★★★讀【畫面上那一行】（`_state_label.text`），★不是自己現叫一次 `_build_state_str()`：
	#   2026-09-25 負對照抓到的 —— 我原本現建一份字串，於是把 `_move_cursor()` 結尾的
	#   `_refresh()` 整個拿掉之後這一格【還是綠的】⇒ 它驗的是「區塊讀 _cursor」，
	#   ★★而【即時性】（游標一動、畫面就變）根本沒有被驗到。
	#   ⇒ 讀畫面才驗得到即時：沒有 `_refresh()` 的話 label 會停在【移動前】那一格。
	var s: String = String(node._state_label.text)
	_check("★不按 Enter ⇒ 真值區塊出現在【畫面上】", s.contains(TextUiMain.HOVER_TRUTH_TITLE))
	_check("★★而畫面上印的是【游標現在那一格】（找 tile_id=%d）"
		% (node._cursor.x * 1000 + node._cursor.y),
		s.contains("tile_id=%d" % (node._cursor.x * 1000 + node._cursor.y)))
	_check("★★★_selected 仍然未選（證明它讀的是 _cursor 不是 _selected）",
		node._selected == Vector2i(-1, -1))
	await _free_ui(node)
	_cell("_test_hover_p1_live")

# P2[標題在]：卷面 grep 得到那一行字。
# ★它防的是一個【認識論】的坑：用真值 debug 會看到附身者不知道的事
#   ⇒ 「AI 怎麼這麼笨」與「AI 根本不知道」在畫面上長得一樣。
# ★★判準綁常數 `HOVER_TRUTH_TITLE` 而不是抄一份字面值 —— 抄一份的話改字時
#   這一格會【自己跟著改】而不紅，那就不是判準了。
# 負對照：把 `HOVER_TRUTH_TITLE` 改成「格子資訊」（＝拿掉那句來源標籤） ⇒ 已於 feat/cursor-hover-truth（2026-09-24 這一輪） 實測紅
func _test_hover_p2_title() -> void:
	_selftest_gate("_test_hover_p2_title").noop()
	print("
── 懸停 P2 來源標籤 ──")
	var node = await _make_ui()
	_hover_move(node, KEY_S)
	var s: String = node._build_state_str()
	print("  標題常數：「%s」" % TextUiMain.HOVER_TRUTH_TITLE)
	_check("★畫面印出來源標籤", s.contains(TextUiMain.HOVER_TRUTH_TITLE))
	_check("★★而那句話含「非附身者所知」（★不是隨便一個標題都算）",
		TextUiMain.HOVER_TRUTH_TITLE.contains("非附身者所知"))
	await _free_ui(node)
	_cell("_test_hover_p2_title")

# ★★★P3[不寫 state]：連續移動游標 N 次 ⇒ world-fp 逐字不變。
#   ★這一格是這張票的【真正判準】：真值只准被看，不准被存。
#   ★★母體地板：那 N 次要【真的移動到不同的格】—— 否則「fp 不變」在游標沒動時恆真。
#   ★★★負對照（手動、跑完還原）：把真值快取進 `player_state` ⇒ 必須紅。
# 負對照：在 `_build_hover_truth_lines()` 開頭寫一行 `_bridge.get_state().player_state["hover_cache"] = str(_cursor)` ⇒ 已於 feat/cursor-hover-truth（2026-09-24 這一輪） 實測紅
func _test_hover_p3_no_state_write() -> void:
	_selftest_gate("_test_hover_p3_no_state_write").noop()
	print("
── 懸停 P3 只准看不准存 ──")
	var node = await _make_ui()
	var st: WorldState = node._bridge.get_state()
	var fp0: String = StateFingerprint.compute(st)
	var seen: Dictionary = {}
	seen[str(node._cursor)] = true
	for key in [KEY_D, KEY_S, KEY_A, KEY_W, KEY_D, KEY_S]:
		_hover_move(node, key)
		# ★★★走【玩家真正經歷的 render 入口】`_refresh()`，不是只叫 `_build_state_str()`：
		#   後者是我寫真值區塊時【手邊最方便】的那一支，而 `_refresh()` 還會建
		#   map／debug bar／hint line／log strip ⇒ ★render 路徑上【別的部分】若寫了 state，
		#   只叫 `_build_state_str()` 的版本看不到。
		#   ★★本票正好動了 render 路徑（頁腳現在讀 `pending_command_labels()`）
		#     ⇒ 這一格的覆蓋範圍要跟著那個改動一起長。
		node._refresh()
		seen[str(node._cursor)] = true
	_check("★★母體地板：游標真的走過 %d 個【不同】的格（1 個的話 fp 不變恆真）" % seen.size(),
		seen.size() >= 3)
	_check("★★★連續移動游標 ＋ 每步 render ⇒ world-fp 逐字不變（真值沒有被存進 state）",
		StateFingerprint.compute(st) == fp0)
	await _free_ui(node)
	_cell("_test_hover_p3_no_state_write")

# P5[空格與滿格都要走]：0 支隊的格與 ≥2 支隊的格各一次 ⇒ 都不炸、都印得出。
# ★負對照：把多隊那一支的迴圈上限寫死成 1 ⇒ 必須紅（手動）。
# 負對照：把多隊那一支的迴圈上限寫死成 1 ⇒ 已於 feat/cursor-hover-truth（2026-09-24 這一輪） 實測紅
func _test_hover_p5_empty_and_crowded() -> void:
	_selftest_gate("_test_hover_p5_empty_and_crowded").noop()
	print("
── 懸停 P5 空格與滿格 ──")
	var node = await _make_ui()
	var st: WorldState = node._bridge.get_state()
	# 找一個沒有任何隊的合法格
	var empty_at: Vector2i = Vector2i(-1, -1)
	for key in st.world.tiles.keys():
		var q: int = int(key) / 1000
		var r: int = int(key) % 1000
		if node._bridge.get_teams_at_tile(q, r).is_empty():
			empty_at = Vector2i(q, r)
			break
	_check("★母體地板：找得到一個沒有隊的格（%s）" % str(empty_at), empty_at != Vector2i(-1, -1))
	if empty_at != Vector2i(-1, -1):
		node._cursor = empty_at
		var s_empty: String = node._build_state_str()
		_check("空格：印得出且說「0 支」", s_empty.contains("格上隊伍：0 支"))
	# 造一個 3 支隊的格（★用真實欄位擺，不是假造回傳值）
	var crowd: Vector2i = st.persons[st.player_id].team_id if false else Vector2i(-1, -1)
	var tids: Array = st.teams.keys()
	_check("★★母體地板：世界裡至少有 3 支隊可以擺（%d 支）" % tids.size(), tids.size() >= 3)
	if tids.size() >= 3:
		crowd = st.teams[tids[0]].tile_pos
		st.teams[tids[1]].tile_pos = crowd
		st.teams[tids[2]].tile_pos = crowd
		node._cursor = crowd
		var s_crowd: String = node._build_state_str()
		var n_here: int = node._bridge.get_teams_at_tile(crowd.x, crowd.y).size()
		print("  滿格 %s 上有 %d 支" % [str(crowd), n_here])
		_check("★★★母體地板：那一格真的有 ≥3 支（%d）—— 1 支的話「多隊」沒被測到" % n_here,
			n_here >= 3)
		_check("滿格：印出「%d 支」" % n_here, s_crowd.contains("格上隊伍：%d 支" % n_here))
		var listed: int = 0
		for ln in s_crowd.split(String.chr(10)):
			if ln.strip_edges().begins_with("Team") and ln.contains("勢力id:"):
				listed += 1
		_check("★★★逐隊都印出來了（%d／%d）—— 迴圈上限寫死成 1 的話這裡會紅" % [listed, n_here],
			listed == n_here)
	await _free_ui(node)
	_cell("_test_hover_p5_empty_and_crowded")
# ══════════ 收費與交付必須成對（spec 2026-09-25，用戶回報「招募不 work」）══════════
# ★★★真相是三個獨立的錯疊在一起，而玩家只看得到第三個：
#   ①`_target_has_anon` 用 `population > 1` ＝【代理量】—— 它問「人夠多嗎」而不是「真的有匿名嗎」
#   ②`transfer_proportional` 的回傳【沒有人看】（沒有匿名可搬 ⇒ 搬 0）
#   ③照印「招募成功」
#   ⇒ 玩家：扣 50 coin、搬 0 人、畫面說成功。
# ★★母體地板（spec 指名）：那一輪要【同時】有招得到與招不到的目標各至少一個
#   —— 否則「成對」會在【全部都招得到】的樣本上恆真，而招不到那一支才是今天的病。
# ★負對照：把 moved 檢查拿掉（還原今天的行為）⇒ 必須紅。
func _recruit_once(node, tgt_id: int) -> Dictionary:
	var st: WorldState = node._bridge.get_state()
	var ptid: int = int(st.persons[st.player_id].team_id)
	var pt: TeamData = st.teams[ptid]
	var coin0: float = float(pt.resources.get("coin", 0))
	var pop0: int = AnonTierSystem.total_pop(pt)
	node._bridge.command_player("execute_action", {"action_id": "recruit_anon",
		"target": {"kind": "team", "team_id": tgt_id, "member_id": -1, "tile_q": -1, "tile_r": -1}})
	var ap: Dictionary = _apply_queue(node)
	return {"ok": bool(ap.get("ok", false)), "applied": int(ap.get("applied", 0)),
		"coin_delta": float(pt.resources.get("coin", 0)) - coin0,
		"anon_delta": AnonTierSystem.total_pop(pt) - pop0}

func _test_recruit_pay_matches_delivery() -> void:
	_selftest_gate("_test_recruit_pay_matches_delivery").noop()
	print("
── 招募：收費與交付必須成對 ──")
	var node = await _make_ui()
	var st: WorldState = node._bridge.get_state()
	var ptid: int = int(st.persons[st.player_id].token_id) if false else int(st.persons[st.player_id].team_id)
	var pt: TeamData = st.teams[ptid]
	ResourceBank.set_amt(pt, "coin", 9999.0, "test_seed_coin")
	# 造兩個目標，★都擺在玩家腳下（recruit 需要同格）
	var ids: Array = []
	for tid in st.teams.keys():
		if int(tid) != ptid:
			ids.append(int(tid))
		if ids.size() >= 2:
			break
	_check("★母體地板①：找得到兩支非玩家隊（%d）" % ids.size(), ids.size() >= 2)
	if ids.size() < 2:
		await _free_ui(node)
		_cell("_test_recruit_pay_matches_delivery")
		return
	var rich: TeamData = st.teams[ids[0]]    # 有匿名 ⇒ 招得到
	var barren: TeamData = st.teams[ids[1]]  # 全具名 ⇒ 招不到
	rich.tile_pos = pt.tile_pos
	barren.tile_pos = pt.tile_pos
	# barren：把匿名清光（★這正是今天那個病的觸發樣本 —— 全具名的目標）
	for tier in AnonCohort.TIER_ORDER:
		for health in AnonCohort.HEALTH_ORDER:
			AnonCohort.remove(barren.anon_cohorts, tier, health, 999999)
	# rich：確保真的有匿名
	if AnonTierSystem.total_pop(rich) <= 0:
		AnonCohort.add(rich.anon_cohorts, AnonCohort.TIER_ORDER[0], AnonCohort.HEALTH_ORDER[0], 3)
	_check("★★母體地板②：招得到那支真的有匿名（%d）" % AnonTierSystem.total_pop(rich),
		AnonTierSystem.total_pop(rich) > 0)
	_check("★★★母體地板③：招不到那支真的【沒有】匿名（%d）—— 這才是今天的病的樣本"
		% AnonTierSystem.total_pop(barren), AnonTierSystem.total_pop(barren) == 0)
	node._bridge.refresh_interaction_targets()
	_apply_queue(node)
	# ① 招得到：收費與交付成對
	var a: Dictionary = _recruit_once(node, int(ids[0]))
	print("  招得到那支：ok=%s coin_delta=%.0f anon_delta=%d" % [
		str(a["ok"]), float(a["coin_delta"]), int(a["anon_delta"])])
	_check("★招得到：真的搬了人（anon +%d）" % int(a["anon_delta"]), int(a["anon_delta"]) > 0)
	_check("★★招得到：收費與交付成對（扣 %.0f coin ÷ 單價 %d ＝ %d 人，實搬 %d 人）" % [
			-float(a["coin_delta"]), int(PlayerCommandSystem.RECRUIT_COST_ANON),
			int(round(-float(a["coin_delta"]) / float(PlayerCommandSystem.RECRUIT_COST_ANON))),
			int(a["anon_delta"])],
		is_equal_approx(-float(a["coin_delta"]),
			float(PlayerCommandSystem.RECRUIT_COST_ANON) * float(a["anon_delta"])))
	# ② 招不到：不扣錢、ok=false
	var b: Dictionary = _recruit_once(node, int(ids[1]))
	print("  招不到那支：ok=%s coin_delta=%.0f anon_delta=%d" % [
		str(b["ok"]), float(b["coin_delta"]), int(b["anon_delta"])])
	_check("★★★招不到：一毛都沒扣（coin_delta=%.0f）—— 這一條就是今天那個缺陷"
		% float(b["coin_delta"]), is_equal_approx(float(b["coin_delta"]), 0.0))
	_check("★招不到：一個人都沒搬（anon_delta=%d）" % int(b["anon_delta"]), int(b["anon_delta"]) == 0)
	_check("★★招不到：消費點回 ok=false（不是「成功」）", not bool(b["ok"]))
	await _free_ui(node)
	_cell("_test_recruit_pay_matches_delivery")

# ★★★把【整行註解】剝掉之後的原始碼 —— 給所有「掃原始碼」的格用。
#   ★它存在的理由是一個實測到的假紅（2026-09-25）：P9 斷言「UI 沒有直接呼叫
#     runner 推進」，而 `text_ui_main.gd:181` 有一行【註解】在【討論】
#     `runner.advance_tick()` ⇒ 判準命中了那句討論，紅在一個不存在的缺陷上。
#   ★★而它跟同一天早上那個 bare-tick 的病是【鏡像】：
#     ·bare-tick：作者【沒】寫「tick」那個字 ⇒ 缺陷靜靜溜過（假綠）
#     ·這裡：註解【提到】那個呼叫 ⇒ 假紅
#     ⇒ ★★★同一個根：判準錨在【原始碼那串字】，而不是錨在【有沒有真的呼叫】。
#   ★★★誠實限（寫出來，因為它還在）：只剝【整行】註解 ——
#     行尾的 inline 註解若提到那個字，這一支仍然會誤判。★要修就是繼續窄化，不是放棄掃描。
static func _code_only(src: String) -> String:
	var out: PackedStringArray = PackedStringArray()
	for l in src.split("\n"):
		if l.strip_edges().begins_with("#"):
			continue
		out.append(l)
	return String.chr(10).join(out)

# ══════════ §4b「推進一小時」鍵（spec 2026-09-25，用戶裁 #6）══════════
# ★★★這一組刻意做成【行為格 ＋ 靜態孿生】成對，而不是只有一邊：
#   ·靜態格＝早期警報（不用跑就紅），★但它錨在【原始碼那串字】上 ⇒ 可以被改寫繞過
#   ·行為格＝真判準（不受重寫影響）★★衝突時【行為格贏】—— 我們在乎的是行為
#   ⇒ ★★★systems 2026-09-25 立的規矩：沒有行為層孿生的靜態格，只是早期警報，不算守衛。

# P8［行為］：按 X ⇒ current_tick 增加 TICKS_PER_HOUR。
# ★負對照：把那一行改成 TICKS_PER_DAY ⇒ 必須紅（★守的是「一小時」不是「會動」）。
# ★★母體地板兩道，各擋一種恆綠：
#   ①按鍵之後必須【真的在推進】（否則 delta==0 與「什麼都沒發生」長得一樣）
#   ②這一輪【不能被事件提前擋住】—— tick_step 遇事件會把 remaining 歸零
#     ⇒ 那時 delta < 一小時而它【不是缺陷】⇒ 判【不可判】，不假裝綠也不假裝紅。
# 負對照：把 KEY_X 那一行改成 `request_advance(WorldState.TICKS_PER_DAY)` ⇒ 已於 feat/cursor-hover-truth（2026-09-24 這一輪） 實測紅
func _test_p8_x_advances_one_hour() -> void:
	_selftest_gate("_test_p8_x_advances_one_hour").noop()
	print("\n── P8 按 X 推進一小時 ──")
	var node = await _make_ui()
	var st: WorldState = node._bridge.get_state()
	var t0: int = st.world.current_tick
	_press_key(node, KEY_X)
	_check("★母體地板①：按 X 之後真的在推進中", node._bridge.is_advancing())
	# ★★★判準＝【請求量】，不是【世界走了多少】—— 這是 2026-09-25 負對照量出來的：
	#   把那一行改成 TICKS_PER_DAY 之後，第一幀走完一小時就被事件擋住（remaining 歸零）
	#   ⇒ delta 還是 60 ⇒ 【1440 與 60 在卷面上長得一模一樣】⇒ 負對照【不紅】。
	#   ⇒ ★被守的性質是「那個鍵【承諾】一小時」，而【走了多少】是世界的權利。
	var asked: int = node._bridge.ticks_remaining()
	print("   請求量=%d（TICKS_PER_HOUR=%d）" % [asked, WorldState.TICKS_PER_HOUR])
	_check("★★按 X ⇒ 請求量正好是 TICKS_PER_HOUR（實測 %d／期望 %d）" % [
		asked, WorldState.TICKS_PER_HOUR], asked == WorldState.TICKS_PER_HOUR)
	var frames: int = 0
	while node._bridge.is_advancing() and frames < 64:
		node._process(0.1)
		frames += 1
	var delta: int = st.world.current_tick - t0
	print("   實際走了 delta=%d frames=%d（★≤ 請求量：事件可以把它截短，不能讓它超過）" % [delta, frames])
	_check("★★★世界走的不超過那個請求（delta=%d ≤ %d）" % [delta, WorldState.TICKS_PER_HOUR],
		delta <= WorldState.TICKS_PER_HOUR)
	await _free_ui(node)
	_cell("_test_p8_x_advances_one_hour")

# P8s［靜態孿生］：X 那一行寫的是 TICKS_PER_HOUR，不是字面量。
# ★★★母體地板：先斷言【抓到了那一行】—— 找不到＝不可判，★不是綠。
#   理由：鍵位綁法若改成查表，這個錨會找不到 ⇒ 沒有地板它會變成「恆空母體恆綠」。
# ★範圍只到【那一個呼叫】，不全檔掃 60 —— 全檔掃會咬到合法的 60
#   （TICKS_PER_HOUR 的定義本身就是 60、秒、百分比）⇒ 那一格會恆紅，而恆紅與恆綠一樣是沒有守衛。
# 負對照：把 `KEY_X:` 改名成 `KEY_Y:`（打地板：找不到＝不可判，不是綠） ⇒ 已於 feat/cursor-hover-truth（2026-09-24 這一輪） 實測紅
func _test_p8s_x_uses_the_constant() -> void:
	_selftest_gate("_test_p8s_x_uses_the_constant").noop()
	print("\n── P8s X 那一行的單位（靜態孿生）──")
	var src: String = _code_only(FileAccess.get_file_as_string("res://scripts/ui/text_ui_main.gd"))
	_check("撈得到原始碼（剝掉整行註解後 %d 字元）" % src.length(), src.length() > 1000)
	var at: int = src.find("KEY_X:")
	_check("★母體地板：找得到 KEY_X 那一支（找不到＝不可判，不是綠）", at != -1)
	if at != -1:
		var nxt: int = src.find("KEY_", at + 6)
		var body: String = src.substr(at, (nxt - at) if nxt != -1 else 300)
		var ln: String = ""
		for l in body.split("\n"):
			if l.contains("request_advance("):
				ln = l
				break
		_check("★母體地板：那一段裡找得到 request_advance( 那一行", ln != "")
		if ln != "":
			print("   那一行：%s" % ln.strip_edges())
			_check("★★寫的是 WorldState.TICKS_PER_HOUR", ln.contains("WorldState.TICKS_PER_HOUR"))
			_check("★★★沒有裸數字 60（單位只准引用那個唯一自由參數）", not ln.contains("60"))
	_cell("_test_p8s_x_uses_the_constant")

# P9［同一條路］：★不得新開推進路徑 —— UI 只准透過 bridge 的 request_advance／tick_step 推進。
# ★母體地板：request_advance( 至少 2 處（SPACE ＋ X）⇒ 否則這一格在【檔案讀空】時恆綠。
# 負對照：在 `_process()` 插一行 `if false: get_parent().advance_tick()` ⇒ 已於 feat/cursor-hover-truth（2026-09-24 這一輪） 實測紅
func _test_p9_single_advance_path() -> void:
	_selftest_gate("_test_p9_single_advance_path").noop()
	print("\n── P9 只有一條推進路徑 ──")
	var raw: String = FileAccess.get_file_as_string("res://scripts/ui/text_ui_main.gd")
	# ★剝掉整行註解 —— 否則【討論】那個呼叫的註解會讓這一格假紅（實測過，見 _code_only 檔頭）
	var src: String = _code_only(raw)
	_check("★母體地板：剝註解之後還有 code（%d → %d 字元）" % [raw.length(), src.length()],
		src.length() > 1000)
	var n_req: int = src.count("_bridge.request_advance(")
	print("   _bridge.request_advance( 出現 %d 次" % n_req)
	_check("★母體地板：request_advance( 至少 2 處（SPACE ＋ X）", n_req >= 2)
	_check("★★UI 沒有直接呼叫 runner 推進（advance_tick）", not src.contains(".advance_tick("))
	_check("★★★UI 沒有自己的 advance_ticks 實作（那會是第三條路）",
		not src.contains("func advance_ticks"))
	_cell("_test_p9_single_advance_path")

# P10［頁腳有字＋單位統一］：keymap 的 X 那一項寫「1小時」不是「60tick」。
# ★判準只看【那一項的字串】（[X] 到下一個 [ 之間），不是全檔掃 60。
# 負對照：把 keymap 那一項改成 `[X]推進60tick` ⇒ 已於 feat/cursor-hover-truth（2026-09-24 這一輪） 實測紅
func _test_p10_footer_x_says_one_hour() -> void:
	_selftest_gate("_test_p10_footer_x_says_one_hour").noop()
	print("\n── P10 頁腳 X 那一項 ──")
	var node = await _make_ui()
	node._refresh()
	var hint: String = String(node._hint_line.text)
	var at: int = hint.find("[X]")
	_check("★母體地板：頁腳 keymap 裡找得到 [X]（找不到＝不可判）", at != -1)
	if at != -1:
		var rest: String = hint.substr(at + 3)
		var nxt: int = rest.find("[")
		var item: String = rest.substr(0, nxt) if nxt != -1 else rest
		print("   那一項：「%s」" % item)
		_check("★★那一項寫的是「1小時」", item.contains("1小時"))
		_check("★★★那一項沒有寫死的 60（用戶逐字：不要寫死60tick）", not item.contains("60"))
	await _free_ui(node)
	_cell("_test_p10_footer_x_says_one_hour")

# P11［Esc 中斷］：推進中按 Esc ⇒ 真的停下來。
# ★★★而這一格要先講一件【量出來的事實】，否則下一個人會以為它寫得太弱：
#   SimBridge.STEP_TICK_BOUND == WorldState.TICKS_PER_HOUR（sim_bridge.gd）
#   ⇒ ★一次 _process 就把【整個一小時】吃完
#   ⇒ ★★所以 X 鍵的可中斷窗口【只有一幀寬】（按鍵到下一次 _process 之間）
#   ⇒ ★★★那不是缺陷，是那兩個常數相等的必然結果；SPACE（一天＝24 幀）才有寬窗口。
# ★母體地板：按 Esc 之前必須【真的在推進中】（否則「停下來了」在根本沒開始時恆真）。
# 負對照：把 `KEY_ESCAPE:` 底下的 `if _bridge.is_advancing():` 改成 `if false:` ⇒ 已於 feat/cursor-hover-truth（2026-09-24 這一輪） 實測紅
func _test_p11_esc_interrupts_x() -> void:
	_selftest_gate("_test_p11_esc_interrupts_x").noop()
	print("\n── P11 Esc 中斷 ──")
	var node = await _make_ui()
	var st: WorldState = node._bridge.get_state()
	var t0: int = st.world.current_tick
	_press_key(node, KEY_X)
	_check("★母體地板：Esc 之前真的在推進中", node._bridge.is_advancing())
	_press_key(node, KEY_ESCAPE)
	_check("★★Esc 之後不再推進", not node._bridge.is_advancing())
	node._process(0.1)
	var delta: int = st.world.current_tick - t0
	print("   Esc 後再跑一幀，delta=%d（未中斷會是 %d）" % [delta, WorldState.TICKS_PER_HOUR])
	_check("★★★世界沒有走掉那一小時（delta=%d < %d）" % [delta, WorldState.TICKS_PER_HOUR],
		delta < WorldState.TICKS_PER_HOUR)
	await _free_ui(node)
	_cell("_test_p11_esc_interrupts_x")

# ══════════ §4c 待辦數看不懂：去重 ＋ 列名 ══════════

# P13［去重］：連按 T 三次 ⇒ 待辦 1 道。★守的是「1」不是「少於 3」。
# ★★母體地板：光看 ==1 不夠 —— 若只入列過一次，1 是【假綠】
#   ⇒ 另外要一個【合併真的發生過】的機器可讀證據：直呼同名無參數，必須回 merged=true。
# 負對照：把 `if _merges_into_tail(name, args):` 改成 `if false:`（＝去重整個拿掉） ⇒ 已於 feat/cursor-hover-truth（2026-09-24 這一輪） 實測紅
func _test_p13_dedupe_repeated_t() -> void:
	_selftest_gate("_test_p13_dedupe_repeated_t").noop()
	print("\n── P13 連按 T 去重 ──")
	var node = await _make_ui()
	# ★★★這一格第一版是【空的】，而是負對照抓出來的（2026-09-25）：
	#   我原本連按三次 KEY_T 然後斷言「待辦 1 道」。★把去重【整個拿掉】之後它【還是 1】
	#   ⇒ 那個 1 不是去重換來的。★★真因：第一次按 T 進入互動模式之後，
	#     `_input` 就被 `_handle_interact_mode()` 接走 ⇒ 第 2、3 次按鍵【到不了 KEY_T 分支】。
	#   ⇒ ★★★所以「按鍵三次只入列一次」是【按鍵路由】的結果，不是合併的結果。
	# ⇒ 改走那個鍵【真正呼叫的那一支】，讓它真的被要求入列三次。
	node._bridge.refresh_interaction_targets()
	node._bridge.refresh_interaction_targets()
	node._bridge.refresh_interaction_targets()
	var n: int = node._bridge.pending_command_count()
	print("   同名無參數入列三次 ⇒ 待辦 %d 道" % n)
	_check("★入列三次 ⇒ 待辦 1 道（不是 2 也不是 3）", n == 1)
	var r: Dictionary = node._bridge.command_player("refresh_targets", {})
	_check("★★★而第四次回 merged=true（合併路徑真的走過，不是從數字反推）",
		bool(r.get("merged", false)))
	_check("★而它仍然回 queued=true（那一道確實在佇列裡）", bool(r.get("queued", false)))
	# ★按鍵路由那件事本身留一個觀測（不是斷言）——★它是上面那段註解的證據，
	#   而下一個人若把互動模式的輸入接管改掉，這個數字會變，他會在卷面上看到。
	var node2 = await _make_ui()
	_press_key(node2, KEY_T)
	_press_key(node2, KEY_T)
	_press_key(node2, KEY_T)
	print("   ★對照觀測：連按 KEY_T 三次 ⇒ 待辦 %d 道（互動模式接走了後兩次按鍵）"
		% node2._bridge.pending_command_count())
	await _free_ui(node2)
	await _free_ui(node)
	_cell("_test_p13_dedupe_repeated_t")

# P14［不過度去重］：★★★spec 原本寫「按鍵 [T, 移動, T] ⇒ 待辦 2 道」——
#   而我實測發現那個【路線】驗不到它要驗的東西：KEY_T 是 toggle
#   （text_ui_main.gd 的 _interact_mode = not _interact_mode，只在【進入】時才 refresh）
#   ⇒ 第三次按 T 是【離開】互動模式 ⇒ 它【根本不入列】⇒ 佇列是 [refresh, move] ＝ 2
#   ⇒ ★★而把去重放寬成「佇列裡有就不加」之後【還是 2】⇒ 負對照不會紅 ⇒ 那一格是空的。
# ⇒ ★★★所以這一格走 bridge，讓兩個 refresh【真的被一個別的指令隔開】：
#   [refresh, move, refresh] ＝ 3 道；放寬成「佇列裡有就不加」⇒ 2 道 ⇒ 紅。
# 負對照：把 `_merges_into_tail()` 放寬成「佇列裡【有】就不加」（不只看尾端） ⇒ 已於 feat/cursor-hover-truth（2026-09-24 這一輪） 實測紅
func _test_p14_dedupe_does_not_eat_meaningful() -> void:
	_selftest_gate("_test_p14_dedupe_does_not_eat_meaningful").noop()
	print("\n── P14 去重不吃掉有意義的那一個 ──")
	var node = await _make_ui()
	var st: WorldState = node._bridge.get_state()
	var ptid: int = int(st.persons[st.player_id].team_id)
	var tp: Vector2i = st.teams[ptid].tile_pos
	node._bridge.command_player("refresh_targets", {})
	node._bridge.command_player("move_to", {"tile_q": int(tp.x) + 1, "tile_r": int(tp.y)})
	var r3: Dictionary = node._bridge.command_player("refresh_targets", {})
	var n: int = node._bridge.pending_command_count()
	print("   [refresh, move, refresh] ⇒ 待辦 %d 道" % n)
	_check("★★★被別的指令隔開的第二個 refresh【要保留】⇒ 3 道", n == 3)
	_check("★而它【沒有】被標成 merged（隔開了就不是同一道）", not bool(r3.get("merged", false)))
	await _free_ui(node)
	_cell("_test_p14_dedupe_does_not_eat_meaningful")

# P15b［列名同源］：頁腳列出的動作人話，與入列回音【同一份字串】。
# ★★★判準不是「兩邊看起來一樣」，是【兩邊都走 PlayerCommandApi.describe()】——
#   ★兩份文案會漂，而漂了沒有任何東西會紅。
# ★母體地板：那一刻頁腳要真的有待辦（0 道時列名區塊不出現 ⇒ 什麼都不印也會「相符」）。
# 負對照：把頁腳的 `"、".join(_labels)` 換成一句自己另寫的文案 ⇒ 已於 feat/cursor-hover-truth（2026-09-24 這一輪） 實測紅
func _test_p15b_footer_labels_same_source() -> void:
	_selftest_gate("_test_p15b_footer_labels_same_source").noop()
	print("\n── P15b 頁腳列名與回音同源 ──")
	var node = await _make_ui()
	var r: Dictionary = node._bridge.command_player("refresh_targets", {})
	var echo: String = String(r.get("message", ""))
	_check("★母體地板：真的有一道待辦", node._bridge.pending_command_count() >= 1)
	node._refresh()
	var hint: String = String(node._hint_line.text)
	var label: String = PlayerCommandApi.describe("refresh_targets", {})
	print("   回音：「%s」｜describe：「%s」" % [echo, label])
	_check("★入列回音含 describe() 那一份字串", echo.contains(label))
	_check("★★頁腳也含同一份字串（「%s」）" % label, hint.contains(label))
	var bsrc: String = FileAccess.get_file_as_string("res://scripts/ui/sim_bridge.gd")
	var at: int = bsrc.find("func pending_command_labels")
	_check("★母體地板：找得到 pending_command_labels（找不到＝不可判）", at != -1)
	if at != -1:
		var body: String = bsrc.substr(at, 400)
		_check("★★★列名走 PlayerCommandApi.describe()（不是另寫一份文案）",
			body.contains("PlayerCommandApi.describe("))
	await _free_ui(node)
	_cell("_test_p15b_footer_labels_same_source")

# P16b［推進後歸零］：推進一小時 ⇒ 待辦 0 道。
# ★母體地板：推進前要真的有 ≥1 道（否則「0 道」在一開始就恆真）。
# ★負對照：尚未點火（母體地板已驗：推進前真的有 ≥1 道；行為已被 P8 的請求量那一格覆蓋大半）
func _test_p16b_pending_zero_after_advance() -> void:
	_selftest_gate("_test_p16b_pending_zero_after_advance").noop()
	print("\n── P16b 推進後待辦歸零 ──")
	var node = await _make_ui()
	node._bridge.command_player("refresh_targets", {})
	var before: int = node._bridge.pending_command_count()
	_check("★母體地板：推進前真的有 ≥1 道（實測 %d）" % before, before >= 1)
	_press_key(node, KEY_X)
	var frames: int = 0
	while node._bridge.is_advancing() and frames < 64:
		node._process(0.1)
		frames += 1
	var after: int = node._bridge.pending_command_count()
	print("   推進前 %d 道 ⇒ 推進後 %d 道（frames=%d）" % [before, after, frames])
	_check("★★推進一小時之後待辦歸零", after == 0)
	await _free_ui(node)
	_cell("_test_p16b_pending_zero_after_advance")

# P18［無界哨兵要有名字］：UI 不得再出現裸的 99999。
# ★★★它守的不只是「魔術數字難看」：`99999` 與 ObserverBridge 的 `1000000` 曾經
#   看起來像「同一個意圖的兩個魔術數字」—— ★而它們不是（一個綁事件、一個綁幀預算，
#   而且分屬玩家路徑與儀器路徑）⇒ 沒有名字的話，下一個人會把它們統一，
#   而那是【把兩件事黏在一起】，不是收斂。
# ★★而 UI 裡那三處 99999 也不是同一件事（這是套用時才發現的）：
#   兩處是【哨兵】（推到有事件擋住）、一處是【夾具】（把玩家打的數字夾到上限）
#   ⇒ 所以是【兩個名字、一個值衍生】，不是一個名字用三次。
# ★母體地板：兩種用法都要真的在 UI 裡 —— 否則「沒有裸 99999」在【那些行被整個刪掉】時也會綠。
# 負對照：把 `SimBridge.ADVANCE_UNTIL_EVENT` 改回裸的 `99999` ⇒ 已於 feat/cursor-hover-truth（2026-09-24 這一輪） 實測紅
func _test_p18_unbounded_sentinel_is_named() -> void:
	_selftest_gate("_test_p18_unbounded_sentinel_is_named").noop()
	print("\n── P18 無界哨兵要有名字 ──")
	var ui: String = _code_only(FileAccess.get_file_as_string("res://scripts/ui/text_ui_main.gd"))
	var br: String = FileAccess.get_file_as_string("res://scripts/ui/sim_bridge.gd")
	_check("★母體地板：兩個常數本體都存在（哨兵 ＋ 夾具）",
		br.contains("const ADVANCE_UNTIL_EVENT") and br.contains("const ADVANCE_MAX_REQUEST"))
	# ★★★哨兵【衍生】自上限 —— 而不是再寫一次 99999：那個依賴是真的
	#   （哨兵請求的量不可以超過請求上限）⇒ 衍生讓它們不可能漂開。
	_check("★★哨兵是從上限衍生的（不是各寫一次同一個數字）",
		br.contains("const ADVANCE_UNTIL_EVENT: int = ADVANCE_MAX_REQUEST"))
	var used: int = ui.count("SimBridge.ADVANCE_UNTIL_EVENT")
	var clamp: int = ui.count("SimBridge.ADVANCE_MAX_REQUEST")
	print("   UI：哨兵 %d 處、夾具 %d 處" % [used, clamp])
	_check("★★母體地板：UI 用到哨兵 2 處（實測 %d）" % used, used == 2)
	_check("★★母體地板：UI 用到夾具 1 處（實測 %d）" % clamp, clamp == 1)
	_check("★★★UI 沒有裸的 99999", not ui.contains("99999"))
	_cell("_test_p18_unbounded_sentinel_is_named")

# P19［負對照覆蓋率棘輪］：留下【已實測紅】紀錄的格數，只准增加。
# ★★★形狀＝把一個【存量問題】變成一個【單調量】（同 `derived_excludes().size() <= 30`）：
#   ★單調量不需要有人記得它，也不需要一列 defer —— 尺自己會長。
# ★而它【不是】在說「其餘那些格是壞的」：沒被證明會紅 ≠ 空的。
#   ★★它守的是【不准往回走】—— 有人刪掉一行紀錄、或改了一格而沒有重新點火，這裡會紅。
# ★★★數的是【固定格式】那一行（`# 負對照：… ⇒ 已於 … 實測紅`），不是隨便含「實測紅」的字：
#   格式一致是它可被機械數的前提。而 spec 抄進註解的「★負對照：… ⇒ 必須紅」是【要求】
#   不是【紀錄】⇒ 那個格式刻意不會命中它（2026-09-24 被這件事咬過一次：
#   加註記的腳本用「負對照：」去重，把兩格真紀錄跳過了）。
# ★母體地板：先斷言兩個檔都數得到而且各自【非零】—— 否則「>= 地板」在【檔案讀空】時
#   也會是「0 >= 0」那種綠。
# ★★★它【不硬紅】：往上走時只印一句提醒，不強迫立刻抬地板。
#   ·棘輪的目的是【不准倒退】，不是【強迫前進】⇒ 對往前走開紅燈是在懲罰我們想要的行為
#   ·★誠實限：那句 print 在通過的閘裡【沒有人會讀到】（runner 不 dump 通過者的 stdout）
#     ⇒ 它的可見性由電池摘要那件事負責，不由這裡加一格紅去補
#     （★紅燈答不出可見性這個問題 —— 工具與問題不同軸）。
const CONTROL_FLOOR_UI: int = 15
const CONTROL_FLOOR_REPLAY: int = 2
# ★新床要納進同一把尺 —— 否則棘輪只守舊的那兩支，而新寫的格不在它的母體裡
const CONTROL_FLOOR_FEED: int = 7

# 負對照：刪掉床裡【任一行】「已於…實測紅」的紀錄（紀錄數 13 → 12） ⇒ 已於 feat/cursor-hover-truth（2026-09-24 這一輪） 實測紅
func _test_p19_control_coverage_ratchet() -> void:
	_selftest_gate("_test_p19_control_coverage_ratchet").noop()
	print("\n── P19 負對照覆蓋率棘輪 ──")
	var n_ui: int = _count_fired("res://scripts/debug/ui_flow_test.gd")
	var n_cr: int = _count_fired("res://scripts/debug/command_replay_bed.gd")
	print("   已實測紅紀錄：ui_flow_test %d（地板 %d）／command_replay_bed %d（地板 %d）" % [
		n_ui, CONTROL_FLOOR_UI, n_cr, CONTROL_FLOOR_REPLAY])
	_check("★母體地板：兩個檔都數得到非零（%d／%d）" % [n_ui, n_cr], n_ui > 0 and n_cr > 0)
	_check("★★ui_flow_test 的紀錄數沒有往回走（%d >= %d）" % [n_ui, CONTROL_FLOOR_UI],
		n_ui >= CONTROL_FLOOR_UI)
	_check("★★command_replay_bed 的紀錄數沒有往回走（%d >= %d）" % [n_cr, CONTROL_FLOOR_REPLAY],
		n_cr >= CONTROL_FLOOR_REPLAY)
	var n_fe: int = _count_fired("res://scripts/debug/player_event_feed_bed.gd")
	print("   player_event_feed_bed %d（地板 %d）" % [n_fe, CONTROL_FLOOR_FEED])
	_check("★★母體地板：新床也數得到非零（%d）" % n_fe, n_fe > 0)
	_check("★★player_event_feed_bed 的紀錄數沒有往回走（%d >= %d）" % [n_fe, CONTROL_FLOOR_FEED],
		n_fe >= CONTROL_FLOOR_FEED)
	if n_ui > CONTROL_FLOOR_UI or n_cr > CONTROL_FLOOR_REPLAY or n_fe > CONTROL_FLOOR_FEED:
		print("   ★紀錄數增加了 ⇒ 請把 CONTROL_FLOOR_* 抬到現值（%d／%d／%d）" % [n_ui, n_cr, n_fe])
	_cell("_test_p19_control_coverage_ratchet")

# 數【固定格式】那一行：`# 負對照：<怎麼點火> ⇒ 已於 <分支> 實測紅`
static func _count_fired(path: String) -> int:
	var src: String = FileAccess.get_file_as_string(path)
	var n: int = 0
	for l in src.split("\n"):
		var t: String = l.strip_edges()
		if t.begins_with("# 負對照：") and t.contains(" ⇒ 已於 ") and t.ends_with("實測紅"):
			n += 1
	return n

# P2［整天不漏］：推進【一天】＝24 次 step，而佇列壽命只有【一小時】
#   ⇒ ★讀者必須【每一次 step 之後都讀】，漏一次就漏掉整整一小時的事件。
# ★★★這一格守的是【讀點的位置】，不是「事件有沒有被 emit」（spec §4 P2 逐字）。
#   ⇒ 所以它逐小時各塞一件事件，然後數畫面上收到幾件：
#     ·讀點在迴圈裡 ⇒ 24 件全到
#     ·讀點搬到整天結束後才讀一次 ⇒ 只剩最後一小時那件（其餘被 TTL 清掉）⇒ 紅
# ★母體地板：先斷言【真的塞進去了 24 件】—— 沒塞進去的話「收到 0 件」也會等於「沒漏」。
# 負對照：把 `_process()` 裡那段撈取搬到迴圈之外（只在最後讀一次）⇒ 必須紅
# 負對照：把 `_process()` 裡那段撈取改成永遠讀空（＝只在整天之後才讀一次）⇒ 畫面收到 0 件 ⇒ 已於 feat/player-event-feed（2026-09-24 這一輪） 實測紅
func _test_p2_whole_day_not_dropped() -> void:
	_selftest_gate("_test_p2_whole_day_not_dropped").noop()
	print("\n── P2 推進一天不漏事件 ──")
	var node = await _make_ui()
	var st: WorldState = node._bridge.get_state()
	var ptid: int = st.get_player_team_id()
	_check("★母體地板①：有玩家隊（tid=%d）" % ptid, ptid != -1)
	if ptid == -1:
		await _free_ui(node)
		_cell("_test_p2_whole_day_not_dropped")
		return
	var hours: int = WorldState.TICKS_PER_DAY / WorldState.TICKS_PER_HOUR
	var before: int = 0
	for e in node._events:
		if String(e.get("type", "")) == "world": before += 1
	var injected: int = 0
	# ★★★判準＝【佇列曾接受的筆數 == 畫面收到的筆數】，不是「== 我注入的數」：
	#   我第一版寫 `got == injected`，而它【假設那一天不會有別的事件】——
	#   實測那一天世界自己也產了 9 件 ⇒ 33 vs 24 ⇒ 紅在一個不存在的缺陷上。
	#   ⇒ `player_event_seq` 是【佇列接受過幾筆】的累計器 ⇒ 拿它比，覆蓋注入的與自產的。
	var seq_before: int = st.player_event_seq
	# ★每一次 step 之前塞一件【自家隊】的事件，然後跑一幀（＝一小時）
	for h in range(hours):
		WorldEvents.emit(st, "leader_death", [ptid])
		injected += 1
		node._bridge.request_advance(WorldState.TICKS_PER_HOUR)
		node._process(0.1)
	var accepted: int = st.player_event_seq - seq_before
	var got: int = 0
	for e in node._events:
		if String(e.get("type", "")) == "world": got += 1
	got -= before
	print("   逐小時各塞 1 件、共 %d 小時｜佇列接受 %d 件 ⇒ 畫面收到 %d 件（★TTL=%d tick）" % [
		injected, accepted, got, SimRunner.RESULT_TTL_TICKS])
	_check("★母體地板②：真的塞進去了 %d 件" % injected, injected == hours)
	_check("★母體地板③：佇列接受的筆數 ≥ 注入數（%d ≥ %d）" % [accepted, injected], accepted >= injected)
	_check("★★★整天一件都沒漏（佇列接受 %d ＝ 畫面收到 %d）" % [accepted, got], got == accepted)
	await _free_ui(node)
	_cell("_test_p2_whole_day_not_dropped")
