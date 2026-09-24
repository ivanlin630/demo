class_name PlayerQueryApi

# ══════════ 兩支【披著指令外衣的查詢】（systems 裁 2026-09-23）══════════
# ★★★為什麼搬到這裡：它們【不改世界】—— 放進指令佇列＝把查詢當指令，
#   而重播帳裡會多出兩條「什麼都沒做」的指令 ⇒ ★帳本身變得不誠實。
# ★稽核（遞移閉包，切掉儀器鏈；★我第一版用名字解析呼叫，閉包爆成 886 支＝過寬過濾，已改窄）：
#   `InquirySystem.get_options` ⇒ 11 支函式、**0 個寫點**
#     （它走 `BeliefSystem.best_estimate` ⇒ ★讀 belief 不讀 god-view，感知鐵律沒破）
#   `_action_recruit` ⇒ 2 支、1 個寫點，而那個寫點在【失敗路徑】：
#     `state.player_pending_targets.erase(target_id)`（目標不存在時的清理）
#     ⇒ ★★查詢不得有副作用 ⇒ 這裡【先檢查存在】、不讓它走到那一行。
#     ⇒ ★★★而那個清理沒有消失：隊伍死亡時 `world_state.gd:878` 本來就會 erase。
# ★真正改世界的是【選完之後】那一條（confirm_gather_intel／recruit_named／recruit_anon）
#   —— 那一條照常走 `command_player` 進佇列。
func _query_menu(state: WorldState, target_id: int, action_id: String) -> Dictionary:
	var pre := _check_player_with_team(state)
	if pre["code"] != "ok":
		return PlayerApiMapper.map_query_envelope(false, pre["code"], pre["msg"], {})
	# ★★★不是 `teams.has()` 而是 `can_be_player_target()`（＝`is_live_team`）——
	#   ★`has()` 對【待刪除的殭屍隊】也是 true ⇒ 玩家會對一支正在被移除的隊開選單。
	#   ★★這是 live-team-ratchet 抓出來的（2026-09-24 第一次跑）：我寫的是 [L] 形
	#     （守 `has()` 之後還把 target_id 派出去），而那支棘輪的判準就是為了這個。
	#   ★★★而它【不是偽陽】：全庫兩個玩家面路徑（interaction_system.gd:309、
	#     player_command_system.gd:974）用的都是 `can_be_player_target` ——
	#     我漏的是【這個專案既有的那道守衛】，不是棘輪太嚴。
	if not state.can_be_player_target(target_id):
		return PlayerApiMapper.map_query_envelope(false, "not_found", "目標不存在", {})
	var p: PersonData = state.persons[state.player_id]
	var pt: TeamData = state.teams[p.team_id]
	var sys := PlayerCommandSystem.new()
	# ★同一份真相：直接叫 command system 的那一支，不在這裡抄一份邏輯
	#   （★★抄一份就是 (丁) 被否決的那個病：兩份會漂開，而漂開那天沒有訊號）
	var r: Dictionary = {}
	if action_id == "gather_intel":
		r = sys._action_gather_intel(state, target_id, pt, p.team_id)
	else:
		r = sys._action_recruit(state, target_id, pt, p.team_id)
	if not bool(r.get("ok", false)):
		return PlayerApiMapper.map_query_envelope(false, "unavailable", String(r.get("msg", "")), {})
	return PlayerApiMapper.map_query_envelope(true, "ok", String(r.get("msg", "")), r.get("payload", {}))

func get_inquiry_options(state: WorldState, target_id: int) -> Dictionary:
	return _query_menu(state, target_id, "gather_intel")

func get_recruit_menu(state: WorldState, target_id: int) -> Dictionary:
	return _query_menu(state, target_id, "recruit")

# ★★★記憶頁（spec §3(G)）：打聽寫進去的東西，玩家要【看得見】。
#   ★沒有它，(A) 做完了玩家也看不見 ⇒ 而【看不見的需求不會回來敲門】：
#     它會變成「打聽好像沒用」然後沒有人再提。
#   ★★【唯讀、零寫、零 RNG】—— 它只讀 `state.team_intel[ptid]`（走 BeliefSystem 的
#     `known_targets()`／`claims()`，不自己解析那個結構：解析兩份會漂）。
func query_memory_panel(state: WorldState) -> Dictionary:
	# ★★★守衛要照【本檔的】慣例：`_check_player_with_team()` 回的 Dictionary【永遠非空】
	#   （成功時是 `{"code": "ok", ...}`）⇒ 用 `is_empty()` 判會【永遠提早返回】。
	#   ★我第一版抄了 `player_command_api` 的 `if not pre.is_empty()` —— 那個檔的慣例不同
	#   ⇒ ★★後果是面板【恆空】，而它不會噴錯：P6 的「記憶頁非空」紅出來才看到。
	var check: Dictionary = _check_player_with_team(state)
	if check["code"] != "ok":
		return PlayerApiMapper.map_query_envelope(false, check["code"], check["msg"], {})
	var ptid: int = state.get_player_team_id()
	var rows: Array = []
	for tgt in BeliefSystem.known_targets(state, ptid):
		var cs: Array = BeliefSystem.claims(state, ptid, int(tgt))
		if cs.is_empty(): continue
		var latest: int = 0
		var src: int = -1
		var suspicious: bool = false
		for c in cs:
			var t: int = int(c.get("last_tick", 0))
			if t >= latest:
				latest = t
				src = int(c.get("source_id", -1))
			if bool(c.get("is_suspicious", false)):
				suspicious = true
		rows.append({
			"target_id": int(tgt),
			"claim_count": cs.size(),
			"latest_tick": latest,
			# ★來源印【隊名】而不是只有 id —— 驗收句要的是「來自 TeamX」
			"source": ("Team%d" % src) if src != -1 else "不明",
			"source_id": src,
			"is_suspicious": suspicious,
		})
	rows.sort_custom(func(a, b): return int(a["target_id"]) < int(b["target_id"]))
	return PlayerApiMapper.map_query_envelope(true, "ok", "", {"memory": rows})

func get_player_snapshot(state: WorldState, request: Dictionary) -> Dictionary:
	var player_check := _check_player_with_team(state)
	if player_check["code"] != "ok":
		return PlayerApiMapper.map_query_envelope(false, player_check["code"], player_check["msg"], {})

	var focus_team_id: int   = request.get("focus_team_id",   -1)
	var focus_member_id: int = request.get("focus_member_id", -1)
	var cursor_q: int        = request.get("cursor_tile_q",   -1)
	var cursor_r: int        = request.get("cursor_tile_r",   -1)

	if focus_member_id != -1 and focus_team_id == -1:
		return PlayerApiMapper.map_query_envelope(false, "invalid_focus",
			"focus_member_id requires focus_team_id", {})
	if (cursor_q == -1) != (cursor_r == -1):
		return PlayerApiMapper.map_query_envelope(false, "invalid_request",
			"cursor_tile_q and cursor_tile_r must both be set or both be -1", {})

	var cmd_sys := PlayerCommandSystem.new()
	var actions := _build_available_actions(state, cmd_sys, focus_team_id, focus_member_id, cursor_q, cursor_r)
	var snapshot := PlayerApiMapper.map_player_snapshot(
		state, focus_team_id, focus_member_id, cursor_q, cursor_r, actions)
	return PlayerApiMapper.map_query_envelope(true, "ok", "", {"snapshot": snapshot})

func get_team_details(state: WorldState, team_id: int) -> Dictionary:
	var check := _check_player(state)
	if check["code"] != "ok":
		return PlayerApiMapper.map_query_envelope(false, check["code"], check["msg"], {})
	if not state.teams.has(team_id):
		return PlayerApiMapper.map_query_envelope(false, "invalid_team", "team not found", {})
	var p: PersonData = state.persons[state.player_id]
	var discovered: Array = state.team_discovered.get(p.team_id, [])
	if team_id != p.team_id and not discovered.has(team_id):
		return PlayerApiMapper.map_query_envelope(false, "not_visible", "team not visible", {})
	var t: TeamData = state.teams[team_id]
	var members: Array = []
	for mid in ([t.leader_id] + t.named_members):
		var m: PersonData = state.persons.get(mid)
		if m != null:
			members.append({"id": m.id, "name": m.person_name, "role": m.role})
	var team_data: Dictionary = {
		"id": team_id,
		"name": "Team%d" % team_id,
		"faction": str(t.faction_id) if t.faction_id != -1 else "",
		"position": {"q": t.tile_pos.x, "r": t.tile_pos.y},
		"members": members,
		"resources": {
			"food":     int(t.resources.get("food", 0)),
			"coin":     int(t.resources.get("coin", 0)),
			"material": int(t.resources.get("material", 0))
		},
		"interaction_options": []
	}
	return PlayerApiMapper.map_query_envelope(true, "ok", "", {"team": team_data})

func get_member_details(state: WorldState, team_id: int, member_id: int) -> Dictionary:
	var check := _check_player(state)
	if check["code"] != "ok":
		return PlayerApiMapper.map_query_envelope(false, check["code"], check["msg"], {})
	if not state.teams.has(team_id):
		return PlayerApiMapper.map_query_envelope(false, "invalid_team", "team not found", {})
	var p: PersonData = state.persons[state.player_id]
	var discovered: Array = state.team_discovered.get(p.team_id, [])
	if team_id != p.team_id and not discovered.has(team_id):
		return PlayerApiMapper.map_query_envelope(false, "not_visible", "team not visible", {})
	var mp: PersonData = state.persons.get(member_id)
	if mp == null or mp.team_id != team_id:
		return PlayerApiMapper.map_query_envelope(false, "invalid_member", "member not found in team", {})
	var member_data: Dictionary = {
		"id": member_id,
		"name": mp.person_name,
		"team_id": team_id,
		"team_name": "Team%d" % team_id,
		"role": mp.role,
		"status": {"health": "healthy", "stress": mp.stress, "loyalty": mp.loyalty},
		"available_actions": []
	}
	return PlayerApiMapper.map_query_envelope(true, "ok", "", {"member": member_data})

func get_location_context(state: WorldState, tile_q: int, tile_r: int) -> Dictionary:
	if state.player_id == -1:
		return PlayerApiMapper.map_query_envelope(false, "no_player", "no player", {})
	if tile_q == -1 or tile_r == -1:
		return PlayerApiMapper.map_query_envelope(false, "invalid_tile", "invalid tile coordinates", {})
	if not state.world.tiles.has(tile_q * 1000 + tile_r):
		return PlayerApiMapper.map_query_envelope(false, "invalid_tile", "tile not found", {})
	var location := PlayerApiMapper.map_location_context(state, tile_q, tile_r)
	return PlayerApiMapper.map_query_envelope(true, "ok", "", {"location": location})

func get_trade_preview(state: WorldState, target_team_id: int) -> Dictionary:
	var check := _check_player_with_team(state)
	if check["code"] != "ok":
		return PlayerApiMapper.map_query_envelope(false, check["code"], check["msg"], {})
	var p: PersonData  = state.persons[state.player_id]
	var pt_id: int     = p.team_id
	if not state.teams.has(target_team_id):
		return PlayerApiMapper.map_query_envelope(false, "invalid_team", "team not found", {})
	var discovered: Array = state.team_discovered.get(pt_id, [])
	if target_team_id != pt_id and not discovered.has(target_team_id):
		return PlayerApiMapper.map_query_envelope(false, "not_visible", "team not visible", {})
	var trade          := PlayerTradeSystem.new()
	var resources      := trade.get_tradeable_resources(state, pt_id, target_team_id)
	var offer: Dictionary = state.player_state.get("trade_offer", {})
	var preview: Dictionary = {}
	if not offer.is_empty():
		preview = trade.preview_offer(state, pt_id, target_team_id, offer)
	return PlayerApiMapper.map_query_envelope(true, "ok", "", {
		"resources":    resources,
		"offer_preview": preview,
	})

# U12: 直接互動交易（resolve_trade_direct）的預覽 — 回 {feasible, player_gives, player_gets}
# text UI confirm_trade 流程走此 auto-trade，非 offer-based get_trade_preview
func get_trade_direct_preview(state: WorldState, target_team_id: int) -> Dictionary:
	var check := _check_player_with_team(state)
	if check["code"] != "ok":
		return PlayerApiMapper.map_query_envelope(false, check["code"], check["msg"], {})
	var p: PersonData = state.persons[state.player_id]
	var pt_id: int    = p.team_id
	if not state.teams.has(target_team_id):
		return PlayerApiMapper.map_query_envelope(false, "invalid_team", "team not found", {})
	var discovered: Array = state.team_discovered.get(pt_id, [])
	if target_team_id != pt_id and not discovered.has(target_team_id):
		return PlayerApiMapper.map_query_envelope(false, "not_visible", "team not visible", {})
	var preview: Dictionary = InteractionSystem.new().preview_trade(state, pt_id, target_team_id)
	return PlayerApiMapper.map_query_envelope(true, "ok", "", { "preview": preview })

# 互動 offer-builder：雙方清單+估值+公平度 DTO（reuse evaluate_offer / TradeValuation.local_value）
func get_trade_session(state: WorldState, target_id: int) -> Dictionary:
	var check := _check_player_with_team(state)
	if check["code"] != "ok":
		return PlayerApiMapper.map_query_envelope(false, check["code"], check["msg"], {})
	return PlayerApiMapper.map_query_envelope(true, "ok", "",
		PlayerApiMapper.map_trade_session(state, target_id))

func get_available_actions(state: WorldState, request: Dictionary) -> Dictionary:
	var check := _check_player_with_team(state)
	if check["code"] != "ok":
		return PlayerApiMapper.map_query_envelope(false, check["code"], check["msg"], {})

	var team_id: int    = request.get("team_id",              -1)
	var member_id: int  = request.get("member_id",            -1)
	var tile_q: int     = request.get("tile_q",               -1)
	var tile_r: int     = request.get("tile_r",               -1)
	var fi_id: String   = request.get("forced_interaction_id", "")

	if member_id != -1 and team_id == -1:
		return PlayerApiMapper.map_query_envelope(false, "invalid_focus",
			"member_id requires team_id", {})
	if (tile_q == -1) != (tile_r == -1):
		return PlayerApiMapper.map_query_envelope(false, "invalid_request",
			"tile_q and tile_r must both be set or both be -1", {})
	if fi_id != "" and fi_id != state.player_forced_event_id:
		return PlayerApiMapper.map_query_envelope(false, "forced_response_missing",
			"forced interaction expired", {})
	if team_id != -1 and not state.teams.has(team_id):
		return PlayerApiMapper.map_query_envelope(false, "invalid_team", "team not found", {})
	if member_id != -1 and not state.persons.has(member_id):
		return PlayerApiMapper.map_query_envelope(false, "invalid_member", "member not found", {})
	if tile_q != -1 and not state.world.tiles.has(tile_q * 1000 + tile_r):
		return PlayerApiMapper.map_query_envelope(false, "invalid_tile", "tile not found", {})

	var cmd_sys := PlayerCommandSystem.new()
	var actions := _build_available_actions(state, cmd_sys, team_id, member_id, tile_q, tile_r)
	return PlayerApiMapper.map_query_envelope(true, "ok", "", {"actions": actions})

# ── Private helpers ────────────────────────────────────────────────────────────

func _check_player(state: WorldState) -> Dictionary:
	if state.player_id == -1 or not state.persons.has(state.player_id):
		return {"code": "no_player", "msg": "no player"}
	return {"code": "ok", "msg": ""}

func _check_player_with_team(state: WorldState) -> Dictionary:
	var check := _check_player(state)
	if check["code"] != "ok":
		return check
	var p: PersonData = state.persons[state.player_id]
	if not state.teams.has(p.team_id):
		return {"code": "no_controlled_team", "msg": "no controlled team"}
	return {"code": "ok", "msg": ""}

func _build_available_actions(state: WorldState, cmd_sys: PlayerCommandSystem,
		focus_team_id: int, focus_member_id: int, cursor_q: int, cursor_r: int) -> Array:
	var actions: Array = []
	# Layer 1: forced interaction responses
	var fi := PlayerApiMapper.map_forced_interaction(state)
	for resp in fi.get("responses", []):
		actions.append(PlayerApiMapper.map_available_action(
			"forced_%s" % resp["response_id"],
			resp["label"],
			true, "",
			{
				"allowed_kinds": PackedStringArray(["none"]),
				"requires_visible_target": false,
				"requires_forced_interaction": true,
				"allows_self_target": false
			},
			"respond_to_forced", resp["command_args"]
		))

	# Layer 2 & 3: focused member / tile context (Phase 1: empty — spec allows this)

	# Layer 4: team-level actions against focused team
	var p: PersonData = state.persons.get(state.player_id)
	var ptid: int = p.team_id if p != null else -1
	if focus_team_id != -1 and focus_team_id != ptid and state.teams.has(focus_team_id):
		var team_actions: Array[String] = cmd_sys.get_available_actions(state, focus_team_id)
		for act in team_actions:
			actions.append(PlayerApiMapper.map_available_action(
				act, _action_label(act), true, "",
				{
					"allowed_kinds": PackedStringArray(["team"]),
					"requires_visible_target": true,
					"requires_forced_interaction": false,
					"allows_self_target": false
				},
				"execute_action",
				{
					"action_id": act,
					"target": {"kind": "team", "team_id": focus_team_id, "member_id": -1, "tile_q": -1, "tile_r": -1}
				}
			))

		# Disabled actions (shown in menu with reason)
		var tgt_team: TeamData = state.teams.get(focus_team_id)
		var pt_team: TeamData  = state.teams.get(ptid) if ptid != -1 else null
		if pt_team != null and tgt_team != null:
			# demand_tribute: disabled when population condition not met
			if not team_actions.has("demand_tribute"):
				var tribute_ok: bool = pt_team.population > int(tgt_team.population * 1.5)
				if not tribute_ok:
					actions.append(PlayerApiMapper.map_available_action(
						"demand_tribute", "索貢", false,
						"人口不足（需超過對方 1.5 倍）",
						{
							"allowed_kinds": PackedStringArray(["team"]),
							"requires_visible_target": true,
							"requires_forced_interaction": false,
							"allows_self_target": false
						},
						"execute_action",
						{
							"action_id": "demand_tribute",
							"target": {"kind": "team", "team_id": focus_team_id, "member_id": -1, "tile_q": -1, "tile_r": -1}
						}
					))
			# extort: disabled when readiness < 0.7
			if not team_actions.has("extort"):
				actions.append(PlayerApiMapper.map_available_action(
					"extort", "勒索", false,
					"準備值不足（需 ≥ 0.7，現為%.1f）" % pt_team.readiness,
					{
						"allowed_kinds": PackedStringArray(["team"]),
						"requires_visible_target": true,
						"requires_forced_interaction": false,
						"allows_self_target": false
					},
					"execute_action",
					{
						"action_id": "extort",
						"target": {"kind": "team", "team_id": focus_team_id, "member_id": -1, "tile_q": -1, "tile_r": -1}
					}
				))
			# recruit: disabled when coin < RECRUIT_COST_ANON
			if not team_actions.has("recruit"):
				var pt_coin: float = float(pt_team.resources.get("coin", 0))
				if pt_coin < PlayerCommandSystem.RECRUIT_COST_ANON:
					actions.append(PlayerApiMapper.map_available_action(
						"recruit", "招募", false,
						"金幣不足（需%d，現%d）" % [int(PlayerCommandSystem.RECRUIT_COST_ANON), int(pt_coin)],
						{
							"allowed_kinds": PackedStringArray(["team"]),
							"requires_visible_target": true,
							"requires_forced_interaction": false,
							"allows_self_target": false
						},
						"execute_action",
						{
							"action_id": "recruit",
							"target": {"kind": "team", "team_id": focus_team_id, "member_id": -1, "tile_q": -1, "tile_r": -1}
						}
					))

	# move_to (cursor set)
	if cursor_q != -1 and cursor_r != -1:
		actions.append(PlayerApiMapper.map_available_action(
			"move_to", "移動到 (%d,%d)" % [cursor_q, cursor_r], true, "",
			{
				"allowed_kinds": PackedStringArray(["tile"]),
				"requires_visible_target": false,
				"requires_forced_interaction": false,
				"allows_self_target": false
			},
			"move_to", {"tile_q": cursor_q, "tile_r": cursor_r}
		))

	# cancel_move (team has a move target)
	var pt: TeamData = state.teams.get(ptid) if ptid != -1 else null
	if pt != null and pt.move_target != Vector2i(-1, -1):
		actions.append(PlayerApiMapper.map_available_action(
			"cancel_move", "取消移動", true, "",
			{
				"allowed_kinds": PackedStringArray(["none"]),
				"requires_visible_target": false,
				"requires_forced_interaction": false,
				"allows_self_target": false
			},
			"cancel_move", {}
		))

	# Layer 5: player-team global actions (no target required)
	var pt_data: TeamData = state.teams.get(ptid) if ptid != -1 else null
	if pt_data != null and pt_data.faction_id == -1:
		actions.append(PlayerApiMapper.map_available_action(
			"establish_faction", "建立勢力", true, "",
			{
				"allowed_kinds": PackedStringArray(["none"]),
				"requires_visible_target": false,
				"requires_forced_interaction": false,
				"allows_self_target": false
			},
			"execute_action",
			{
				"action_id": "establish_faction",
				"target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}
			}
		))

	# take_loot / leave_loot when player won last encounter
	if not state.last_encounter_result.is_empty():
		var ler: Dictionary = state.last_encounter_result
		if ler.get("winner_id", -1) == ptid:
			var loot_preview: Dictionary = ler.get("loot_pool", {})
			actions.append(PlayerApiMapper.map_available_action(
				"take_loot", "收取戰利品", true, "",
				{
					"allowed_kinds": PackedStringArray(["none"]),
					"requires_visible_target": false,
					"requires_forced_interaction": false,
					"allows_self_target": false
				},
				"execute_action",
				{
					"action_id": "take_loot",
					"target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1},
					"loot_preview": loot_preview
				}
			))
			actions.append(PlayerApiMapper.map_available_action(
				"leave_loot", "放棄戰利品", true, "",
				{
					"allowed_kinds": PackedStringArray(["none"]),
					"requires_visible_target": false,
					"requires_forced_interaction": false,
					"allows_self_target": false
				},
				"execute_action",
				{
					"action_id": "leave_loot",
					"target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}
				}
			))

	# subjugate_enemy（戰後可收編）
	if state.last_encounter_result.get("can_subjugate", false):
		actions.append(PlayerApiMapper.map_available_action(
			"subjugate_enemy", "收編敗者", true, "",
			{
				"allowed_kinds": PackedStringArray(["none"]),
				"requires_visible_target": false,
				"requires_forced_interaction": false,
				"allows_self_target": false
			},
			"execute_action",
			{"action_id": "subjugate_enemy",
			 "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}}
		))

	# confirm_gather_intel（等待選題）
	if state.player_state.has("pending_intel_target"):
		actions.append(PlayerApiMapper.map_available_action(
			"confirm_gather_intel", "確認打聽", true, "",
			{
				"allowed_kinds": PackedStringArray(["none"]),
				"requires_visible_target": false,
				"requires_forced_interaction": false,
				"allows_self_target": false
			},
			"execute_action",
			{"action_id": "confirm_gather_intel",
			 "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1}}
		))

	# offer_surrender（戰鬥中對目標提出投降）
	if state.encounter_active and focus_team_id != -1:
		actions.append(PlayerApiMapper.map_available_action(
			"offer_surrender", "投降請和", true, "",
			{
				"allowed_kinds": PackedStringArray(["team"]),
				"requires_visible_target": true,
				"requires_forced_interaction": false,
				"allows_self_target": false
			},
			"execute_action",
			{"action_id": "offer_surrender",
			 "target": {"kind": "team", "team_id": focus_team_id, "member_id": -1, "tile_q": -1, "tile_r": -1}}
		))

	# Layer 6: 玩家隊 self/tile 動作（hunt/hunt_beast，依腳下 tile）
	var self_tile: HexTileData = pt_tile_self(state, ptid)
	if self_tile != null:
		if int(self_tile.resources.get("wild_game", 0)) > 0:
			actions.append(PlayerApiMapper.map_available_action(
				"hunt", _action_label("hunt"), true, "",
				{ "allowed_kinds": PackedStringArray(["none"]),
				  "requires_visible_target": false, "requires_forced_interaction": false,
				  "allows_self_target": false },
				"execute_action",
				{ "action_id": "hunt", "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1} }))
		if int(self_tile.resources.get("predator_density", 0)) > 0:
			actions.append(PlayerApiMapper.map_available_action(
				"hunt_beast", _action_label("hunt_beast"), true, "",
				{ "allowed_kinds": PackedStringArray(["none"]),
				  "requires_visible_target": false, "requires_forced_interaction": false,
				  "allows_self_target": false },
				"execute_action",
				{ "action_id": "hunt_beast", "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1} }))

	# camp（self-action,紮營）：腳下無主 + 非山地 + 未開發 + 距離 spacing 通過才列（免材料落腳 lvl1 outpost）。
	# N-3: 補 _action_camp 的 _check_distance 真 gate（否則距離太近恆列→選後才拒）。
	var camp_type: String = str(state.player_state.get("build_type", "civilian"))
	if camp_type not in ["civilian", "military"]: camp_type = "civilian"
	if self_tile != null and self_tile.outpost_level == 0 and self_tile.outpost_owner == -1 \
			and self_tile.terrain != "mountain" \
			and OutpostSystem.new()._check_distance(state, self_tile.tile_pos, camp_type):
		actions.append(PlayerApiMapper.map_available_action(
			"camp", _action_label("camp"), true, "",
			{ "allowed_kinds": PackedStringArray(["none"]),
			  "requires_visible_target": false, "requires_forced_interaction": false,
			  "allows_self_target": false },
			"execute_action",
			{ "action_id": "camp", "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1} }))

	# train（self-action）：有匿名人口 + coin >= TRAIN_COST_COIN 才列。一次性 coin→add_exp+try_promote。
	# N-3: 補 _action_train 的 coin 真 gate（否則 coin 不足恆列→選後才拒）。
	var pt_train: TeamData = state.teams.get(ptid) if ptid != -1 else null
	if pt_train != null and AnonTierSystem.total_pop(pt_train) > 0 \
			and float(pt_train.resources.get("coin", 0)) >= PlayerCommandSystem.TRAIN_COST_COIN:
		actions.append(PlayerApiMapper.map_available_action(
			"train", _action_label("train"), true, "",
			{ "allowed_kinds": PackedStringArray(["none"]),
			  "requires_visible_target": false, "requires_forced_interaction": false,
			  "allows_self_target": false },
			"execute_action",
			{ "action_id": "train", "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1} }))

	# promote_anon（self-action）：有匿名人口才列。拔擢 1 anon→named（對稱性,解全 anon 隊無法派子隊）。
	if pt_train != null and AnonTierSystem.total_pop(pt_train) > 0:
		actions.append(PlayerApiMapper.map_available_action(
			"promote_anon", _action_label("promote_anon"), true, "",
			{ "allowed_kinds": PackedStringArray(["none"]),
			  "requires_visible_target": false, "requires_forced_interaction": false,
			  "allows_self_target": false },
			"execute_action",
			{ "action_id": "promote_anon", "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1} }))

	return actions

func pt_tile_self(state: WorldState, ptid: int) -> HexTileData:
	if ptid == -1 or not state.teams.has(ptid): return null
	var pt: TeamData = state.teams[ptid]
	return state.world.tiles.get(pt.tile_pos.x * 1000 + pt.tile_pos.y)

func get_and_clear_alerts(state: WorldState) -> Array:
	var alerts: Array = state.player_alerts.duplicate()
	state.player_alerts.clear()
	return alerts

func query_faction_panel(state: WorldState) -> Dictionary:
	var check := _check_player(state)
	if check["code"] != "ok":
		return PlayerApiMapper.map_query_envelope(false, check["code"], check["msg"], {})
	return PlayerApiMapper.map_query_envelope(true, "ok", "",
		{"faction_panel": PlayerApiMapper.map_faction_panel(state)})

func get_storage_panel(state: WorldState) -> Dictionary:
	var check := _check_player_with_team(state)
	if check["code"] != "ok":
		return PlayerApiMapper.map_query_envelope(false, check["code"], check["msg"], {})
	return PlayerApiMapper.map_query_envelope(true, "ok", "",
		{ "storage_panel": PlayerApiMapper.map_storage_panel(state) })

func query_outpost_panel(state: WorldState) -> Dictionary:
	var check := _check_player(state)
	if check["code"] != "ok":
		return PlayerApiMapper.map_query_envelope(false, check["code"], check["msg"], {})
	return PlayerApiMapper.map_query_envelope(true, "ok", "",
		{"outpost_panel": PlayerApiMapper.map_outpost_panel(state)})

func query_subteam_panel(state: WorldState) -> Dictionary:
	var check := _check_player(state)
	if check["code"] != "ok":
		return PlayerApiMapper.map_query_envelope(false, check["code"], check["msg"], {})
	return PlayerApiMapper.map_query_envelope(true, "ok", "",
		{"subteam_panel": PlayerApiMapper.map_subteam_panel(state)})

# ★★★事件流（C1 票①併入）：機制早就有（player_api_mapper.gd:792 map_global_messages），
#   ★而它【唯一的呼叫點是 ui/sim_bridge.gd:154】—— GUI 在用，agent/REPL 層零呼叫。
#   ⇒ 這正是「機制蓋好了、只接了 GUI 沒接 agent」的活教材（P9 病歷）。
#   ★★形狀照既有 wrapper（get_storage_panel／query_outpost_panel）。
func get_event_stream(state: WorldState, n: int = 10) -> Dictionary:
	var check := _check_player(state)
	if check["code"] != "ok":
		return PlayerApiMapper.map_query_envelope(false, check["code"], check["msg"], {})
	return PlayerApiMapper.map_query_envelope(true, "ok", "",
		{ "events": PlayerApiMapper.map_global_messages(state, n) })

# ★世界時鐘（票②）：狀態列四件事之一【現在幾時】——★而任何查詢面原本都沒有時間。
#   ★★它是【查詢面本身】的補件，不是「為狀態列開的捷徑」：任何人問時間都走這裡。
func get_world_clock(state: WorldState) -> Dictionary:
	var tick: int = state.world.current_tick
	return PlayerApiMapper.map_query_envelope(true, "ok", "", {
		"tick": tick,
		"day": int(tick / WorldState.TICKS_PER_DAY),
		"tick_of_day": tick % WorldState.TICKS_PER_DAY,
		"ticks_per_day": WorldState.TICKS_PER_DAY,
		# ★速度檔【不在引擎裡】：推進由呼叫端決定（票① advance_ticks 的裁定）
		#   ⇒ 這裡誠實印「由呼叫端控制」而不是編一個檔位出來。
		"speed": "由呼叫端控制（advance_ticks）",
	})

# ★★★常駐狀態列（票② §1）：我是誰／在哪／在做什麼／現在幾時。
#   ★★四件事【全部來自既有查詢動詞】—— 本函式只【組合】，不自己讀 state：
#   否則它會變成第二個資料來源，而兩個來源必然 drift。
func get_status_line(state: WorldState) -> Dictionary:
	var snap: Dictionary = get_player_snapshot(state, {})
	if not bool(snap.get("ok", false)):
		return snap
	var ctx: Dictionary = get_decision_snapshot(state)
	var clock: Dictionary = get_world_clock(state)
	# ★真實形狀：get_player_snapshot 的 data 是 {"snapshot": {...}}，而【我第一版直接讀 data】
	#   ⇒ 我是誰／在哪 兩格印成「未知」。★★那不是「查詢面沒有」，是【我讀錯了一層】——
	#   ★★★而兩者在畫面上長得一模一樣（都是空的），這正是走查要抓的東西，只是這次被我自己撞到。
	var sd: Dictionary = (snap.get("data", {}) as Dictionary).get("snapshot", {})
	# ★真實鍵是 `player_summary`（map_player_snapshot:572）——★我猜了兩次鍵名（"player"／直讀 data），
	#   兩次都印成「未接出」。★★而「未接出」與「我讀錯鍵」在畫面上長得一樣 ⇒
	#   ★★★狀態列自陳 sources 那一行就是為了這種時候：先查【我讀對了嗎】再說查詢面缺什麼。
	var player_sum: Dictionary = sd.get("player_summary", {})
	var cd: Dictionary = ctx.get("data", {})
	var fields: Dictionary = cd.get("fields", {})
	return PlayerApiMapper.map_query_envelope(true, "ok", "", {
		"who": player_sum.get("player_name", "（未接出）"),
		"team": player_sum.get("controlled_team_name", "（未接出）"),
		"where": {
			"tile": player_sum.get("position", null),
			"q": player_sum.get("q", null), "r": player_sum.get("r", null),
		},
		"doing": {
			# ★current_task 來自 ctx 快照（B1 已接出）——★★沒快照時誠實說沒有，不填「idle」
			"current_task": fields.get("current_task", null),
			"has_snapshot": bool(cd.get("snapshot", false)),
			"snapshot_age_ticks": cd.get("age_ticks", null),
			"intent": fields.get("intent", null),
		},
		"clock": clock.get("data", {}),
		# ★★★來源自陳：狀態列讀了哪幾支動詞 —— 讓「它有沒有走查詢面」可被查證
		"sources": ["get_player_snapshot", "get_decision_snapshot", "get_world_clock"],
	})

# ★★★決策快照（B1）：把引擎【替這具身體讀的每一個欄位】端出來。
#   ★值來自 sim 自己那一次 gather（team.ctx_snapshot），★★查詢端【不重算】——
#   重算＝觀察一次跑一次引擎，而那是有血證的禁止形狀。
#   ★★★還沒有快照時回 {snapshot:false, note:…}：★玩家知道自己看不到、以及為什麼，
#   比一堆 0 有用（同 inspect 票的 threat 那格）。
func get_decision_snapshot(state: WorldState) -> Dictionary:
	var check := _check_player_with_team(state)
	if check["code"] != "ok":
		return PlayerApiMapper.map_query_envelope(false, check["code"], check["msg"], {})
	var t: TeamData = state.teams[state.persons[state.player_id].team_id]
	if t.ctx_snapshot.is_empty():
		return PlayerApiMapper.map_query_envelope(true, "ok", "", {
			"snapshot": false,
			"note": "尚無快照：引擎還沒替這支隊跑過一次決策（推進幾 tick 後就會有）",
		})
	return PlayerApiMapper.map_query_envelope(true, "ok", "", {
		"snapshot": true,
		"snapshot_tick": t.ctx_snapshot_tick,
		"age_ticks": state.world.current_tick - t.ctx_snapshot_tick,   # ★快照有年紀，讀的人要看得到
		# ★回【副本】不是本體：t.ctx_snapshot 直接交出去 ＝ 呼叫端手上握著引擎的狀態，
		#   ★★改它就改了世界（床第一次跑就撞到：拿到的 f0 被後面的 erase 一起改了）
		#   ⇒ 觀測不得改變被觀測物 —— duplicate(true) 連巢狀 dict/array 一起複製。
		"fields": t.ctx_snapshot.duplicate(true),
	})

func _action_label(action_id: String) -> String:
	match action_id:
		"ignore":           return "忽略"
		"attack":           return "攻擊"
		"trade":            return "貿易"
		"propose_alliance": return "提議同盟"
		"demand_tribute":        return "要求納貢"
		"extort":                return "勒索"
		"recruit":               return "招募"
		"establish_faction":     return "建立勢力"
		"hunt":                  return "狩獵"
		"hunt_beast":            return "獵猛獸"
		"train":                 return "訓練（-%d coin）" % int(PlayerCommandSystem.TRAIN_COST_COIN)
		"promote_anon":          return "拔擢匿名→記名"
		"camp":                  return "紮營"
		"take_loot":             return "收割戰利品"
		"leave_loot":            return "放棄戰利品"
		"recruit_anon":          return "招募匿名"
		"invite_settle":         return "邀請定居"
		"recruit_named":         return "招募成員"
		"confirm_trade":         return "確認貿易"
		"cancel_trade":          return "取消貿易"
		"gather_intel":           return "打聽情報"
		"beg":                    return "乞討"
		"confirm_gather_intel":   return "確認打聽"
		"subjugate_enemy":        return "收編敗者"
		"offer_surrender":        return "投降請和"
		"surrender_in_encounter": return "戰中投降"
		"leave_faction":          return "退出勢力"
		"betray_faction":         return "背叛勢力"
		"disband_faction":        return "解散勢力"
		"set_faction_goal":       return "設定勢力目標"
		"order_faction_member":   return "下令成員"
		"clear_member_order":     return "清除指令"
		"set_tribute_rate":       return "調整徵收率"
		"build_outpost":          return "建設前哨站"
		"upgrade_outpost":        return "升級等級"
		"upgrade_farming":        return "升級農作"
		"upgrade_manufacturing":  return "升級製造"
		"demolish_outpost":       return "拆除前哨站"
		"dispatch_subteam":       return "派遣子隊"
		"order_subteam":          return "下令子隊"
		"recall_subteam":         return "召回子隊"
	return action_id
