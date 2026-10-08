class_name PlayerApiMapper

# ── Equippable slot lookup (compile-time const) ────────────────────────────────
const EQUIPPABLE_SLOTS: Dictionary = {
	"weapon_melee_low":   ["hand_1", "hand_2"],
	"weapon_melee_high":  ["hand_1", "hand_2"],
	"weapon_ranged_low":  ["hand_1"],
	"weapon_ranged_high": ["hand_1"],
	"armor_low":          ["head", "torso", "hand_1"],
	"armor_high":         ["head", "torso"],
}

# ── Envelope builders ──────────────────────────────────────────────────────────

static func map_query_envelope(ok: bool, code: String, message: String, data: Dictionary) -> Dictionary:
	return {"ok": ok, "code": code, "message": message, "data": data}

static func map_command_result(ok: bool, code: String, message: String, payload: Dictionary) -> Dictionary:
	return {"ok": ok, "code": code, "message": message, "payload": payload}

# ── Player summary ─────────────────────────────────────────────────────────────

static func map_player_summary(state: WorldState) -> Dictionary:
	var pid: int = state.player_id
	if pid == -1:
		return {
			"player_exists": false, "player_person_id": -1, "player_name": "",
			"controlled_team_id": -1, "controlled_team_name": "",
			"position": {"q": -1, "r": -1}, "encounter_active": false,
			"has_pending_targets": false, "has_forced_interaction": false
		}
	var p: PersonData = state.persons.get(pid)
	if p == null:
		return {
			"player_exists": false, "player_person_id": pid, "player_name": "",
			"controlled_team_id": -1, "controlled_team_name": "",
			"position": {"q": -1, "r": -1}, "encounter_active": false,
			"has_pending_targets": false, "has_forced_interaction": false
		}
	var tid: int = p.team_id
	var t: TeamData = state.teams.get(tid) if tid != -1 else null
	var _skills: Dictionary = {}
	for k in p.skills:
		if float(p.skills[k]) > 0.01:
			_skills[k] = float(p.skills[k])
	return {
		"player_exists": true,
		"player_person_id": pid,
		"player_name": p.person_name,
		"controlled_team_id": tid,
		"controlled_team_name": "Team%d" % tid if tid != -1 else "",
		"position": {"q": t.tile_pos.x, "r": t.tile_pos.y} if t != null else {"q": -1, "r": -1},
		"encounter_active": state.encounter_active,
		"pre_encounter_pending": not state.player_pre_encounter.is_empty(),
		"pre_encounter_attacker_id": int(state.player_pre_encounter.get("attacker_id", -1)),
		"has_pending_targets": not state.player_pending_targets.is_empty(),
		"has_forced_interaction": not state.player_forced_event.is_empty(),
		"hp_status": _hp_status(p),
		"loyalty": p.loyalty,
		"stress":  p.stress,
		"skills": _skills,
		"food_days": _food_days(t) if t != null else 0.0,
		"starving": (_food_days(t) < 3.0) if t != null else false,
	}

# ── Controlled team ────────────────────────────────────────────────────────────


# ★「家」三欄的唯一取值點 —— ★★三個 helper 都走同一個 `own_outpost_tile()`，
#   所以「三欄同時給或同時 null」是【結構保證】不是三處各自記得要對齊。
# ★★★營地不是家（blueprint §6）：這裡只認 outpost_level > 0，不認 L0 營地。
static func _home_tile(state: WorldState, t: TeamData) -> HexTileData:
	return state.own_outpost_tile(t.team_id)

static func _home_pos(state: WorldState, t: TeamData):
	var h: HexTileData = _home_tile(state, t)
	if h == null: return null   # ★明確 null —— 不是 (0,0)、不是 (-1,-1)（spec §3）
	return {"q": h.tile_pos.x, "r": h.tile_pos.y}

static func _home_kind(state: WorldState, t: TeamData):
	var h: HexTileData = _home_tile(state, t)
	if h == null: return null
	return h.outpost_type   # ★沿用 tile 既有分類，不新造詞（spec §3）

static func _home_distance(state: WorldState, t: TeamData):
	var h: HexTileData = _home_tile(state, t)
	if h == null: return null
	var a: Vector2i = t.tile_pos
	var b: Vector2i = h.tile_pos
	var dx: int = b.x - a.x
	var dy: int = b.y - a.y
	return (abs(dx) + abs(dx + dy) + abs(dy)) / 2

# ★F8 營地欄（藍圖裁（乙）68cd9883d：營地不是家，家欄不動）：camp_pos／camp_distance 同一支 own_camp_tile 取值
#   ⇒ 兩欄同給或同 null（同「家」三欄的結構保證）；自己的營地＝self-knowledge
static func _camp_pos(state: WorldState, t: TeamData):
	var c: HexTileData = state.own_camp_tile(t.team_id)
	if c == null: return null
	return {"q": c.tile_pos.x, "r": c.tile_pos.y}

static func _camp_distance(state: WorldState, t: TeamData):
	var c: HexTileData = state.own_camp_tile(t.team_id)
	if c == null: return null
	var dx: int = c.tile_pos.x - t.tile_pos.x
	var dy: int = c.tile_pos.y - t.tile_pos.y
	return (abs(dx) + abs(dx + dy) + abs(dy)) / 2

static func map_controlled_team(state: WorldState) -> Dictionary:
	var pid: int = state.player_id
	var p: PersonData = state.persons.get(pid) if pid != -1 else null
	var tid: int = p.team_id if p != null else -1
	var t: TeamData = state.teams.get(tid) if tid != -1 else null
	if t == null:
		return {}
	var members: Array = []
	var member_ids: Array = []
	if t.leader_id != -1:
		member_ids.append(t.leader_id)
	for mid in t.named_members:
		if mid != -1 and not member_ids.has(mid):
			member_ids.append(mid)
	for mid in member_ids:
		var m: PersonData = state.persons.get(mid)
		if m != null:
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
	var mv: Vector2i = t.move_target
	return {
		"id": tid,
		"name": "Team%d" % tid,
		"faction": str(t.faction_id) if t.faction_id != -1 else "",
		"faction_display": ("勢力%d" % t.faction_id) if t.faction_id >= 0 else "獨立",
		"position": {"q": t.tile_pos.x, "r": t.tile_pos.y},
		# ★★★「家」三欄（票：查詢面補「家」，2026-09-23）——★三欄【同時】給或【同時】null。
		#   半套會讓畫面印出「家：？ 離家 3」這種句子（spec §3 逐字）。
		# ★語意＝【本城】（blueprint 裁 2026-09-23；而它不是新語意——機制意圖帳 #55⑤ 2026-09-10 已裁）。
		#   ★★本城欄【尚未落地】⇒ 本票取值用 owner_outpost_index，
		#     語意＝「state.world.tiles 迭代序中第一個自家據點」⇒ ★★★所以畫面必須標【暫代】。
		# ★感知鐵律：自己擁有哪些據點＝self-knowledge，不是 god-view；
		#   距離只用【我的當前格】與【我自己的據點格】兩個我本來就知道的位置。
		"home_pos": _home_pos(state, t),
		"home_kind": _home_kind(state, t),
		"home_distance": _home_distance(state, t),
		"home_count": state.own_outpost_count(t.team_id),
		"camp_pos": _camp_pos(state, t),
		"camp_distance": _camp_distance(state, t),
		"members": members,
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
		"movement": {
			"has_target": mv != Vector2i(-1, -1),
			"target_q": mv.x,
			"target_r": mv.y
		},
		"fatigue_pct":      int(t.fatigue * 100),
		"population":       t.population,
		"anon_total":       AnonTierSystem.total_pop(t),
		"armed_count":      _armed_count(t),
		"armed_ratio":      t.armed_anon_ratio,
		"wounded":         t.wounded,
		"minor_population": t.minor_population,
		"faction_id":       t.faction_id,
		"food_days":        _food_days(t),
		"starving":         _food_days(t) < 3.0,   # WARNING_DAYS=3
		"task_summary": t.current_task,
		"capabilities": _team_capabilities(state, t),
	}

# 隊級能力讀數（按真技能聚合算，非假數字）：狩獵=named avg求生、戰力=武裝+named戰鬥、日耗=pop×2.4
static func _team_capabilities(state: WorldState, t: TeamData) -> Dictionary:
	var hp: Dictionary = HuntSystem.new().hunt_preview(state, t)
	var combat: float = float(_armed_count(t))
	for mid in ([t.leader_id] as Array) + t.named_members:
		var m: PersonData = state.persons.get(mid)
		if m != null: combat += float(m.skills.get("戰鬥", 0.0))
	return {
		"hunt_survival":     hp["survival"],
		"hunt_chance":       hp["chance"],
		"hunt_yield":        hp["yield"],
		"combat_power":      combat,             # proxy：武裝數 + named 戰鬥技能和（與遭遇戰上場概念對齊）
		"food_burn_per_day": float(t.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY,
	}

# 武裝數 = named 成員（含 leader）+ anon 持武（anon 人口 × armed_anon_ratio）
static func _armed_count(t: TeamData) -> int:
	var named_count: int = t.named_members.size() + (1 if t.leader_id != -1 else 0)
	var anon_pop: int = maxi(t.population - named_count, 0)
	return named_count + roundi(float(anon_pop) * float(t.armed_anon_ratio))

static func _food_days(t: TeamData) -> float:
	var burn: float = maxf(float(t.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY, 0.001)
	return float(t.resources.get("food", 0)) / burn

# ── Visible teams ──────────────────────────────────────────────────────────────

static func map_visible_teams(state: WorldState) -> Array:
	var pid: int = state.player_id
	var p: PersonData = state.persons.get(pid) if pid != -1 else null
	var tid: int = p.team_id if p != null else -1
	if tid == -1:
		return []
	var discovered: Array = state.team_discovered.get(tid, [])
	var result: Array = []
	for dtid in discovered:
		var dt: TeamData = state.teams.get(dtid)
		if dt == null:
			continue
		var intel: Dictionary = BeliefSystem.best_estimate(state, tid, dtid)
		var pop_est: int = int(intel["population_est"]) if intel.has("population_est") else -1
		result.append({
			"id": dtid,
			"name": "Team%d" % dtid,
			"relation": "unknown",
			"position": {"q": dt.tile_pos.x, "r": dt.tile_pos.y},
			"faction_display": ("勢力%d" % dt.faction_id) if dt.faction_id >= 0 else "獨立",
			"population": pop_est,   # -1 = 未知；否則為 intel 估計值（含噪）
			"can_interact": not state.player_pending_targets.has(dtid),
			"can_inspect": true,
			"can_target": true
		})
	return result

# ── Focused member ─────────────────────────────────────────────────────────────

static func map_focused_member(state: WorldState, focus_team_id: int, focus_member_id: int) -> Dictionary:
	var sentinel: Dictionary = {
		"id": -1, "name": "", "team_id": -1, "team_name": "", "role": "",
		"status": {"health": "", "stress": 0.0, "loyalty": 0.0},
		"available_actions": []
	}
	if focus_team_id == -1 or focus_member_id == -1:
		return sentinel
	var t: TeamData = state.teams.get(focus_team_id)
	var mp: PersonData = state.persons.get(focus_member_id)
	if t == null or mp == null or mp.team_id != focus_team_id:
		return sentinel
	return {
		"id": focus_member_id,
		"name": mp.person_name,
		"team_id": focus_team_id,
		"team_name": "Team%d" % focus_team_id,
		"role": mp.role,
		"status": {"health": "healthy", "stress": mp.stress, "loyalty": mp.loyalty},
		"available_actions": []
	}

# ── Pending targets ────────────────────────────────────────────────────────────

static func map_pending_targets(state: WorldState) -> Array:
	var result: Array = []
	for tid in state.player_pending_targets:
		var t: TeamData = state.teams.get(tid)
		result.append({
			"target_type": "team",
			"target_id": int(tid),
			"display_name": "Team%d" % tid,
			"is_valid": t != null
		})
	return result

static func map_willing_members(state: WorldState, person_ids: Array) -> Array:
	var result: Array = []
	for pid in person_ids:
		var p: PersonData = state.persons.get(pid)
		if p == null: continue
		var best_sk: String = "—"; var best_v: float = 0.0
		for sk in p.skills:
			var v: float = float(p.skills[sk])
			if v > best_v: best_v = v; best_sk = "%s:%.2f" % [sk, v]
		result.append({
			"person_id": pid,
			"name": p.person_name if p.person_name != "" else "P%d" % pid,
			"team_id": p.team_id,
			"loyalty": p.loyalty,
			"top_skill": best_sk,
			"recruit_cost": PlayerCommandSystem.RECRUIT_COST_NAMED
		})
	return result

# ── Forced interaction ─────────────────────────────────────────────────────────

static func map_forced_interaction(state: WorldState) -> Dictionary:
	var empty_result: Dictionary = {
		"interaction_id": "",
		"interaction_type": "",
		"source": {"team_id": -1, "team_name": "", "member_id": -1, "member_name": ""},
		"message": "",
		"consequence": "",
		"no_response": "",
		"responses": []
	}
	var evt: Dictionary = state.player_forced_event
	if evt.is_empty():
		return empty_result
	var iid: String = state.player_forced_event_id
	var from_id: int = evt.get("from_id", -1)
	var action: String = evt.get("action", "")
	var proposal: String = evt.get("proposal", "")
	var who: String = source_display(state, from_id)
	var msg: String = ""
	# msg：per-action 文案（display 文案,單一處,保留 per-action）
	match action:
		"choose_heir":
			msg = action_phrase(action, proposal)   # ★不冠「誰」：死的是自家領袖,沒有對方
		"join_request":
			var ft: TeamData = state.teams.get(from_id)
			msg = "%s%s（%d 人）" % [who, action_phrase(action, proposal),
				ft.population if ft != null else 0]
		"aid_request":
			var ft2: TeamData = state.teams.get(from_id)
			msg = "%s%s（%d 人）" % [who, action_phrase(action, proposal),
				ft2.population if ft2 != null else 0]
		_:
			# ★未知 action 也不吞（`action_phrase` 的 fallback 會把原樣 id 印在括號裡）
			msg = "%s%s" % [who, action_phrase(action, proposal)]
	# responses：單一源 = get_forced_response_options，每 id 配 label（不可 drift）
	var pcs := PlayerCommandSystem.new()
	var responses: Array = []
	for rid in pcs.get_forced_response_options(state):
		responses.append({
			"response_id": rid,
			"label": forced_label(action, rid, state, evt),
			"command_args": { "interaction_id": iid, "response_id": rid }
		})
	return {
		"interaction_id": iid,
		"interaction_type": action,
		"source": {
			"team_id": from_id,
			"team_name": "Team%d" % from_id if from_id != -1 else "",
			"member_id": -1,
			"member_name": ""
		},
		"message": msg,
		"consequence": accept_consequence(action, proposal),
		"no_response": no_response_line(action),
		"responses": responses
	}

# ── 強制事件的人話（★★★三張表【與 `forced_label` 同處】：spec §3① 裁「不另開表」）──
#   ★理由是 drift：選項有人話而事件本身沒有,正是因為那兩半【不在同一個地方】被維護。

# proposal → 「要什麼」片語。
# ★★★母體【不是封閉集】（spec §1③）：`proposal` 有兩個寫入者、兩套詞彙
#   （`diplomatic_ai_system.gd:174` 寫 propose_*；`interaction_system.gd:294` 寫 `order_task`
#    ⇒ 第三個具體字串 `tribute_offer`）⇒ ★認不得的 id **印出來不吞掉**：
#   下一個新 proposal 會在玩家畫面上自己現形,而不是靜默變成空字串。
static func proposal_phrase(proposal: String) -> String:
	match proposal:
		"alliance", "propose_alliance":  return "提議與你結盟"
		"propose_trade":                 return "提議與你通商"
		"surrender":                     return "提議向你投降"
		"tribute", "demand_tribute":     return "要求你納貢"
		"tribute_offer":                 return "要向你進貢"
	return "提議（未知：%s）" % proposal

# action → 「要什麼」片語。★★★world_events.describe（生命週期三句）也呼這一支
#   ⇒ 面板與事件流【同一張表】；否則兩邊會各自漂（這正是本票要修的那個病）。
static func action_phrase(action: String, proposal: String) -> String:
	match action:
		"diplomacy":    return proposal_phrase(proposal)
		"extort":       return "勒索你"
		"join_request": return "求投靠"
		"aid_request":  return "向你乞食"
		"choose_heir":  return "領袖殞落,要你擇繼承人"
	return "（未知事件：%s）" % action

# 「接受＝什麼後果」一句。★同樣：認不得就把 id 印出來。
static func accept_consequence(action: String, proposal: String) -> String:
	match action:
		"diplomacy":
			match proposal:
				"alliance", "propose_alliance": return "接受＝與對方結盟（互不侵犯）"
				"propose_trade":                return "接受＝與對方通商"
				"surrender":                    return "接受＝收下對方的歸順"
				"tribute", "demand_tribute":    return "接受＝付出一筆糧食"
				"tribute_offer":                return "接受＝收下對方的貢品"
			return "接受＝後果未知（提案：%s）" % proposal
		"extort":       return "接受＝付錢了事"
		"join_request": return "接受＝對方整隊併入你"
		"aid_request":  return "接受＝撥一批糧食給對方"
		"choose_heir":  return "選擇＝由他繼承你的位置"
	return "接受＝後果未知（事件：%s）" % action

# 「不回應會怎樣」一句。
# ★★刻意【不寫任何 tick 數】：逾時是在 `sim_runner` 的 hour-tick 那一格清掉的
#   ⇒ 真實語意是「下一個整點」而不是「從現在起一小時」,而寫死 60 兩種意思都會錯。
static func no_response_line(action: String) -> String:
	if action == "choose_heir":
		return "不回應＝世界停住,直到你選出繼承人"   # choose_heir 不逾時（sim_runner 明確排除）
	return "不回應＝下一個整點視同拒絕（最多 1 小時）"

# 「誰」——隊號＋勢力＋關係摘要。
# ★★★關係取自【玩家自己隊的 `known_reputations`】＝ belief,不是 god-view 真值（感知鐵律）。
static func source_display(state: WorldState, from_id: int) -> String:
	if from_id == -1:
		return "某支隊伍"
	var t: TeamData = state.teams.get(from_id)
	var fac: String = ("勢力%d" % t.faction_id) if (t != null and t.faction_id >= 0) else "獨立"
	return "Team%d（%s，關係：%s）" % [from_id, fac, relation_summary(player_known_rep(state, from_id))]

static func player_known_rep(state: WorldState, tid: int) -> float:
	var pt: TeamData = state.teams.get(state.get_player_team_id())
	if pt == null:
		return 0.5   # ★沒有玩家隊 ⇒ 中性,不是「敵視」
	return float(pt.known_reputations.get(tid, 0.5))

# 0..1 的 reputation → 摘要詞。★玩家從來沒看過這個數字（本票是第一個顯示它的地方）。
static func relation_summary(v: float) -> String:
	if v >= 0.75: return "親密"
	if v >= 0.55: return "友好"
	if v >= 0.45: return "普通"
	if v >= 0.25: return "冷淡"
	return "敵視"

# ★★★動作 id → 中文（★本表是【搬】過來的唯一一份：原本住在
#   `PlayerQueryApi._action_label`，而 `PlayerCommandApi.describe()` 也要用它
#   ⇒ 搬到這裡並讓那邊變薄委派，**不是抄第二份**）。
#   ★★不認得的 id **不吞掉**：印「（未知動作：xxx）」——
#     吞掉的話玩家看到的是一句沒有主詞的話，而下一個人也不知道少了哪一個。
static func action_label(action_id: String) -> String:
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
		"train":                 return "訓練（-%d 幣）" % int(PlayerCommandSystem.TRAIN_COST_COIN)
		"promote_anon":          return "拔擢匿名→記名"
		"rest":                  return "休息"
		"camp":                  return "紮營"
		"settle":                return "紮根"
		# ★`cancel_move` 補進來（2026-10-01）：查詢面原本**手寫**「取消移動」
		#   ⇒ 那是第二個 label 生產者，而本票把那 11 段收成一個迴圈之後
		#     迴圈只呼這一支 ⇒ 手寫那一份隨之消失。
		"cancel_move":           return "取消移動"
		"take_loot":             return "收割戰利品"
		"leave_loot":            return "放棄戰利品"
		"recruit_anon":          return "招募匿名"
		"invite_settle":         return "邀請定居"
		"recruit_named":         return "招募成員"
		# ★「確認貿易」那一列已退場（2026-10-01）：那個動作不存在了 ⇒ 它的顯示名也不該在。
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
		# ★★★這 12 個是【母體補完】補上的（spec 2026-09-30）：它們在 `_action_registry` 裡，
		#   而舊表只收了選單會列的那些 ⇒ 其餘 12 個玩家按得到卻只能看到原樣 id。
		#   ⇒ 抓到它們的不是我讀表，是床把 registry 的 51 個鍵逐一問過一遍
		#     （★那一格現在是常駐的：新增動詞沒有中文 label ⇒ 紅）。
		"abandon_outpost":        return "棄置據點"
		"accept_encounter":       return "接戰"
		"build_facility":         return "蓋設施"
		"choose_heir":            return "擇繼承人"
		"deposit_to_storage":     return "存入公庫"
		"extract_treasury":       return "徵用國庫"
		"refresh_targets":        return "重掃同格對象"
		"respond_aid_request":    return "回應乞食"
		"set_armed_anon_ratio":   return "調整武裝比例"
		"submit_trade_offer":     return "送出出價"
		"surrender_pre_encounter": return "戰前投降"
		"withdraw_from_storage":  return "取出公庫"
	return "（未知動作：%s）" % action_id

# ★設施 id → 中文（唯一一份；同樣不吞掉不認得的）。
#   ★★它被 handler 的 msg 用（「無法擴建<設施>（條件不符）」）——
#     而那一句原本印的是 `farming` 這種原樣 id。
static func facility_label(facility: String) -> String:
	match facility:
		"farming":       return "農地"
		"workshop":      return "工坊"
		"apothecary":    return "藥舖"
		"mint":          return "鑄幣坊"
		"stable":        return "馬廄"
		"smeltery":      return "冶煉坊"
		"weaponsmith":   return "兵器鋪"
		"armorsmith":    return "甲冶鋪"
	return "（未知設施：%s）" % facility

# ★裝備部位 id → 中文。★這一份是【新的】，而它是唯一一份：
#   原本連選單都印原樣 id（`"裝備 %s → %s"`）⇒ 玩家面本來就漏著英文。
#   ⇒ 同樣不吞掉不認得的部位。
static func slot_label(slot_id: String) -> String:
	match slot_id:
		"head":   return "頭部"
		"torso":  return "身體"
		"hand_1": return "主手"
		"hand_2": return "副手"
	return "（未知部位：%s）" % slot_id

# 每個 forced response id 的顯示 label（per-action,單一處）
# ══ ★★★tick → 玩家看得到的「第 N 天 HH:MM」（2026-10-01，版面 v2 §2②）═══════════
#   ★全庫原本**沒有**這支（我 grep 過）⇒ 稿子的頂列第一欄沒有來源。
#   ★★而它**必須從 `WorldState` 的常數導**，不准手抄數字（用戶立法「估算器禁手抄物理」）：
#     `TICKS_PER_HOUR` 是唯一自由參數，`TICKS_PER_DAY` 由它推導
#     ⇒ 改那個常數，這支的輸出**必須跟著變**（床有一格用它當負對照：動輸入不動事實）。
#   ★★★天從 1 起算（玩家讀的是「第 1 天」不是「第 0 天」）；時分用 24 小時制補零。
# ★★★【真實世界的常數 vs 專案的旋鈕】—— 這一行是 P9 那一格咬出來的：
#   我第一版寫 `* 60.0`，而那一格報「手抄物理」⇒ ★而它**咬對了一半**：
#   ·`1440`／`24` 是**可以從旋鈕導出來的**（`TICKS_PER_DAY = TICKS_PER_HOUR * 24`）
#     ⇒ 手抄它們＝把旋鈕的第二份放進玩家面字串
#   ·而「一小時有 60 分」是**真實世界**的事實，**不是**這個專案的自由參數
#     ⇒ 它不可能被「導出來」，它只能被**具名**。
#   ⇒ ★★所以修法不是把守衛放寬，是**把它具名**：讓「哪一個是旋鈕、哪一個是世界」
#     在 code 裡看得見，而守衛繼續咬裸字面。
#   ★★★（而 `TICKS_PER_HOUR = 60` 讓「1 tick ＝ 1 分鐘」在今天成立；
#     旋鈕若改成 30，一個 tick 就是 2 分鐘 —— 而下面那個算式**自己會跟著變**。）
const MINUTES_PER_HOUR: int = 60

static func tick_clock(tick: int) -> String:
	var per_day: int = WorldState.TICKS_PER_DAY
	var per_hour: int = WorldState.TICKS_PER_HOUR
	var day: int = int(tick / per_day) + 1
	var rem: int = tick % per_day
	var hour: int = int(rem / per_hour)
	var minute: int = int(float(rem % per_hour) / float(per_hour) * float(MINUTES_PER_HOUR))
	return "%d 天 %02d:%02d" % [day, hour, minute]

# ★★★NPC 的【外交回覆】中文（2026-10-01，battery10 的 `scripted-exploration` 咬到）——
#   ★它與 `forced_label()` **不是同一件事**，所以不重用它：
#     `forced_label` 是【玩家自己要按的選單標籤】（帶 ✓／✗、吃 `evt` 與 `state`），
#     而這裡要的是【對方回了什麼】⇒ 兩者的主詞不同，共用會讓畫面出現「✓ 接受」當成對方的回答。
#   ★★而它放在這一支檔是因為**這裡是玩家面字串的唯一生產者**（⑤ 那張票搬過來的）。
#   ★★★未知值【不吞】：印「（未知回覆：xxx）」——
#     `handle_diplomacy_message` 回的是 "accept"／"refuse"／"reject"，
#     而多一個值的時候我要在畫面上看到它，不是看到一個空字串。
# ══ ★★★「對方拒絕了」的可辨識字樣 —— **唯一一份**（spec 2026-10-07 terminal-ui-fixes U1，R² 加）════════
#   ★結果句（`sim_runner._refused_text` 與 accepted:false 那一支）用它組字；終端 E2E 的紅二分類器讀同一份判「被拒」
#   ⇒ 一處定義兩處讀：文案改了而分類器沒跟上 ⇒ 不可能（沒有第二份可以漂）
const REFUSED_WORD: String = "被拒絕"      # 指令本身被拒（前置／消費點）
const DECLINED_WORD: String = "對方拒絕"   # 指令有執行、對方不答應（handler 回 ok:true、accepted:false）
const REFUSAL_WORDS: Array = [REFUSED_WORD, DECLINED_WORD]

static func diplomacy_reply_label(resp: String) -> String:
	match resp:
		"accept":            return "接受"
		"refuse", "reject":  return "拒絕"
	return "（未知回覆：%s）" % resp

# ★U5（spec 2026-10-07 terminal-ui-fixes，E2E E4）：標籤不帶 ✓／✗ 前綴 —— 舊版四個選項帶著它們，
#   終端（CP950）印不出來，看起來是「[A]  接受」多一格；事件句「回應了「✓ 接受」」也帶著它
#   ⇒ 接受／拒絕的意思由字本身說，不靠記號
static func forced_label(action: String, rid: String, state: WorldState, evt: Dictionary) -> String:
	match action:
		"diplomacy":
			match rid:
				"accept": return "接受"
				"accept_join": return "加入對方勢力（對方為主）"
				"accept_lead": return "自立後接納對方（我為主）"
				"refuse": return "拒絕"
		"extort":
			return "付錢" if rid == "pay" else "拒絕"
		"join_request":
			var ft: TeamData = state.teams.get(evt.get("from_id", -1))
			var n: int = ft.population if ft != null else 0
			if rid == "accept":
				return "收留（食物 -%.1f,+%d 人）" % [PlayerCommandSystem.JOIN_ONBOARD_MEAL * n, n]
			return "婉拒"
		"aid_request":
			return "施捨 %.0f 糧" % PlayerCommandSystem.AID_GIVE_DEFAULT if rid == "give" else "拒絕"
		"choose_heir":
			var pid: int = int(rid.trim_prefix("heir_"))
			var p: PersonData = state.persons.get(pid)
			return "立 %s 為繼承人" % (p.person_name if p != null else "P%d" % pid)
	return rid

# ── Location context ───────────────────────────────────────────────────────────

static func map_location_context(state: WorldState, tile_q: int, tile_r: int) -> Dictionary:
	var not_visible: Dictionary = {
		"tile": {"q": tile_q, "r": tile_r},
		"visibility_state": "hidden",
		"terrain": null,
		"settlement": null,
		"occupants": [],
		"is_player_here": false,
		"hints": []
	}
	if tile_q == -1 or tile_r == -1:
		not_visible["tile"] = {"q": -1, "r": -1}
		return not_visible
	var tile_key: int = tile_q * 1000 + tile_r
	if not state.world.tiles.has(tile_key):
		return not_visible
	var pid: int = state.player_id
	var p: PersonData = state.persons.get(pid) if pid != -1 else null
	var ptid: int = p.team_id if p != null else -1
	var tile: HexTileData = state.world.tiles[tile_key] as HexTileData
	var pt: TeamData = state.teams.get(ptid) if ptid != -1 else null
	var is_here: bool = pt != null and pt.tile_pos == Vector2i(tile_q, tile_r)
	var occupants: Array = []
	for oid in state.teams:
		if oid == ptid:
			continue
		var ot: TeamData = state.teams[oid]
		if ot.tile_pos == Vector2i(tile_q, tile_r):
			occupants.append({"team_id": oid, "team_name": "Team%d" % oid, "relation": "unknown"})
	var settlement = null
	if tile.outpost_type != "" and tile.outpost_owner != -1:
		settlement = {
			"id": tile.outpost_owner,
			"name": "%s Lv%d" % [tile.outpost_type, tile.outpost_level],
			"owner_faction": ""
		}
	return {
		"tile": {"q": tile_q, "r": tile_r},
		"visibility_state": "visible",
		"terrain": tile.terrain,
		"settlement": settlement,
		"occupants": occupants,
		"is_player_here": is_here,
		"food": int(tile.resources.get("food", 0)),
		"wild_game": int(tile.resources.get("wild_game", 0)),
		"predator": _predator_intel(state, tile),
		"hints": []
	}

# 玩家對該 tile 掠食者的認知：none(無) / detected(偵測到，預警) / lurking(有但沒察覺)
static func _predator_intel(state: WorldState, tile: HexTileData) -> String:
	if int(tile.resources.get("predator_density", 0)) <= 0:
		return "none"
	var pid: int = state.player_id
	var p: PersonData = state.persons.get(pid) if pid != -1 else null
	var pt: TeamData = state.teams.get(p.team_id) if p != null else null
	if pt != null and pt.tile_pos == tile.tile_pos:
		if AmbushSystem.new().detect(state, pt, tile):
			return "detected"
		return "lurking"
	return "lurking"   # 非腳下格 → 預設未察覺（認知不透明）

# ── Inventory state ────────────────────────────────────────────────────────────

static func _get_equip_slots(grade: String) -> PackedStringArray:
	var slots: Array = EQUIPPABLE_SLOTS.get(grade, [])
	return PackedStringArray(slots)

static func _make_item_action(action_id: String, label: String, enabled: bool,
		disabled_reason: String, command_name: String, command_args: Dictionary) -> Dictionary:
	return {
		"action_id": action_id, "label": label, "enabled": enabled,
		"disabled_reason": disabled_reason,
		"target_requirements": {
			"allowed_kinds": PackedStringArray(["none"]),
			"requires_visible_target": false,
			"requires_forced_interaction": false,
			"allows_self_target": false
		},
		"command_name": command_name, "command_args": command_args
	}

static func map_inventory_state(state: WorldState) -> Dictionary:
	var pid: int = state.player_id
	var p: PersonData = state.persons.get(pid) if pid != -1 else null
	var tid: int = p.team_id if p != null else -1
	var t: TeamData = state.teams.get(tid) if tid != -1 else null
	var raw_inv: Array = state.player_state.get("inventory", []) if not state.player_state.is_empty() else []

	var inv_items: Array = []
	for item in raw_inv:
		var grade: String = item.get("grade", "")
		var qty: int = item.get("qty", 1)
		var slots: PackedStringArray = _get_equip_slots(grade)
		var row_actions: Array = []
		for slot in slots:
			row_actions.append(_make_item_action(
				"equip_%s_%s" % [grade, slot],
				"裝備 %s → %s" % [grade, slot_label(slot)],
				true, "",
				"equip_item", {"slot_id": slot, "item_grade": grade}
			))
		row_actions.append(_make_item_action(
			"deposit_%s" % grade, "存入隊伍",
			t != null, "" if t != null else "無受控隊伍",
			"deposit_item", {"item_grade": grade, "qty": qty}
		))
		inv_items.append({"row_id": grade, "grade": grade, "qty": qty, "equip_slots": slots, "available_actions": row_actions})

	var take_items: Array = []
	if t != null:
		for res_key in t.resources:
			var qty: int = int(t.resources[res_key])
			if qty > 0:
				take_items.append({
					"row_id": res_key, "grade": res_key, "qty": qty,
					"available_actions": [
						_make_item_action("take_%s" % res_key, "取出 %s" % res_key, true, "",
							"take_team_item", {"item_grade": res_key, "qty": 1})
					]
				})

	var equipped: Dictionary = {"head": "", "torso": "", "hand_1": "", "hand_2": ""}
	if p != null:
		for slot in ["head", "torso", "hand_1", "hand_2"]:
			equipped[slot] = p.equipment.get(slot, {}).get("grade", "")

	var unequip_actions: Array = []
	for slot in ["head", "torso", "hand_1", "hand_2"]:
		if equipped[slot] != "":
			unequip_actions.append(_make_item_action(
				"unequip_%s" % slot,
				"卸下 %s (%s)" % [slot, equipped[slot]],
				true, "",
				"unequip_item", {"slot_id": slot}
			))

	return {
		"inventory_items": inv_items,
		"team_takeable_items": take_items,
		"equipped_items": equipped,
		"available_actions": unequip_actions
	}

# ── Available action builder ───────────────────────────────────────────────────

# ★★★【缺口③，2026-10-01】：`opens_submenu` 原本**不在信封裡** ——
#   全列版（`get_action_availability`）有算它，而信封把它吃掉
#   ⇒ 排版層的 `▸`（稿子的「招募 ▸／打聽 ▸」）**永遠印不出來**。
#   ★而它的失效長相是「那個符號沒出現」—— 沒有任何斷言在看，所以它是靜默的。
#   ★★預設 `false`：既有 21 個呼叫點不用改（它們不是子選單入口），
#     而團隊目標那一條路把全列版算出來的值傳進來。
# ★F3（spec 2026-10-07 round5-friendliness）：`hint`＝能解除這個不可條件的動作 id（引擎給；指不出 ⇒ ""）
#   ⇒ 排版層把拒絕句排成「<動作>不行：<原因>；可以先做 <hint 的動作名>」，不自寫下一步
static func map_available_action(action_id: String, label: String, enabled: bool,
		disabled_reason: String, target_requirements: Dictionary,
		command_name: String, command_args: Dictionary,
		opens_submenu: bool = false, hint: String = "") -> Dictionary:
	return {
		"action_id": action_id, "label": label, "enabled": enabled,
		"disabled_reason": disabled_reason,
		"hint": hint,
		"opens_submenu": opens_submenu,
		"target_requirements": target_requirements,
		"command_name": command_name, "command_args": command_args
	}

# ── Private helpers ───────────────────────────────────────────────────────────

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

# ── Snapshot meta ──────────────────────────────────────────────────────────────

static func map_snapshot_meta(focus_valid: bool, cursor_valid: bool) -> Dictionary:
	return {"focus_valid": focus_valid, "cursor_valid": cursor_valid}

# ── Full player snapshot ───────────────────────────────────────────────────────

static func map_members_detail(state: WorldState) -> Array:
	var pid: int = state.player_id
	var p: PersonData = state.persons.get(pid) if pid != -1 else null
	var tid: int = p.team_id if p != null else -1
	var t: TeamData = state.teams.get(tid) if tid != -1 else null
	if t == null:
		return []
	var member_ids: Array = []
	if t.leader_id != -1:
		member_ids.append(t.leader_id)
	for mid in t.named_members:
		if mid != -1 and not member_ids.has(mid):
			member_ids.append(mid)
	var result: Array = []
	for mid in member_ids:
		var m: PersonData = state.persons.get(mid)
		if m == null:
			continue
		var hp_current: float = 0.0
		var hp_max_total: float = 0.0
		for part_data in m.body_parts.values():
			hp_current += float(part_data.get("hp", 0.0))
			hp_max_total += float(part_data.get("max_hp", 0.0))
		var inventory: Array = []
		if mid == pid:
			inventory = state.player_state.get("inventory", []).duplicate()
		result.append({
			"id":         mid,
			"name":       m.person_name,
			"role":       "leader" if mid == t.leader_id else "member",
			"stress":     m.stress,
			"fear":       m.fear,
			"loyalty":    m.loyalty,
			"hp_current": hp_current,
			"hp_max":     hp_max_total,
			"attributes": m.attributes.duplicate(),
			"values":     m.values.duplicate(),
			"skills":     m.skills.duplicate(),
			"body_parts": m.body_parts.duplicate(true),
			"equipped":   m.equipment.duplicate(true),
			"inventory":  inventory,
		})
	return result

static func map_team_stats(state: WorldState) -> Dictionary:
	var pid: int = state.player_id
	var p: PersonData = state.persons.get(pid) if pid != -1 else null
	var tid: int = p.team_id if p != null else -1
	var t: TeamData = state.teams.get(tid) if tid != -1 else null
	if t == null:
		return {}
	var ms := MovementSystem.new()
	return {
		"food_qty":       int(t.resources.get("food", 0.0)),
		"carry_weight":   ms.calc_total_weight(t),
		"carry_capacity": ms.get_carry_capacity(t),
		"member_count":   (1 if t.leader_id != -1 else 0) + t.named_members.size(),
	}

static func map_player_snapshot(state: WorldState, focus_team_id: int, focus_member_id: int,
		cursor_q: int, cursor_r: int, actions: Array) -> Dictionary:
	var focus_valid: bool = focus_team_id != -1 and focus_member_id != -1 \
		and state.teams.has(focus_team_id) and state.persons.has(focus_member_id)
	var cursor_valid: bool = cursor_q != -1 and cursor_r != -1 \
		and state.world.tiles.has(cursor_q * 1000 + cursor_r)
	var out: Dictionary = {
		"player_summary":     map_player_summary(state),
		"controlled_team":    map_controlled_team(state),
		"visible_teams":      map_visible_teams(state),
		"focused_member":     map_focused_member(state, focus_team_id, focus_member_id),
		"pending_targets":    map_pending_targets(state),
		"forced_interaction": map_forced_interaction(state),
		"location_context":   map_location_context(state, cursor_q, cursor_r),
		"available_actions":  actions,
		"inventory_state":    map_inventory_state(state),
		"snapshot_meta":      map_snapshot_meta(focus_valid, cursor_valid),
		"members_detail":     map_members_detail(state),
		"team_stats":         map_team_stats(state),
	}
	# ★故事結束（票 #2 刀 0）：**只加鍵、不改既有鍵** —— 兩鍵的產生者只有 `map_story_end()`
	out.merge(map_story_end(state))
	# ★威脅欄（H0）：寫入者**永遠**帶 `threat_line` 鍵 —— 產生者只有 `map_threat_line()`
	out["threat_line"] = map_threat_line(state)
	return out

# ══ ★★★★★【故事結束的兩鍵 —— UI 讀 `game_over` 的【唯一】資料路徑】（票 #2 刀 0）═══════
# spec：`docs/superpowers/specs/2026-09-24-game-over-is-a-story-end-not-world-physics-HOW.md` §5c
#   ★意圖帳 #43：`game_over` ＝【UI 層的故事結束】⇒ UI 要讀得到它，而**不准走 `_bridge` 直讀**
#     （那會是第二條資料路徑）⇒ 由 mapper 出，view 讀 snapshot 的那兩鍵。
# ★★★★★而 snapshot 有**兩個出口**，兩鍵必須**兩個都有**（實作端讀 code 抓到，spec 沒寫）：
#   ·成功：`map_player_snapshot()` 那一份（上面）
#   ·★失敗：`player_query_api.get_player_snapshot()` 在 `_check_player_with_team` 不過時
#     回 `data = {}` ⇒ ★而**真的 game_over 很可能走這條**（讀 code 的推論，實測見
#     `terminal_selfcheck_bed` 的「已結束（戰死）」走法）：玩家戰死 ⇒
#     `npc_combat_system.gd` 的 `state.persons.erase(p.id)` ⇒ `_check_player` 回 `no_player`
#   ⇒ ★★只放在成功那份的話，**那一欄只會在「旗標被手動設在一個活世界上」的 fixture 裡亮**，
#     而玩家真的死掉的那一屏**一個字都沒有** —— 正是本票要治的那個病。
#   ⇒ 所以失敗出口也帶這兩鍵（`get_player_snapshot` 呼叫本函式），**產生者仍然只有這一個**。
static func map_story_end(state: WorldState) -> Dictionary:
	return {"game_over": state.game_over, "game_over_reason": state.game_over_reason}


# ══ ★★★★★【威脅欄：附身隊【所知】的最急一句】（spec 2026-10-06 threat-column-says-what-the-team-knows）══
# ★★H0：本函式是 `threat_line` 的**唯一**產生者，而且**永遠回一個字串**（快照兩個出口都帶這個鍵）
#   ·讀者用 `has("threat_line")` 判：鍵不存在 ⇒「尚未提供」（＝沒有寫入者）
#   ·「（無）」由**這裡明示**寫出 ⇒ 與「沒有寫入者」**不再同形**（那正是這一欄說謊了一整輪的機制）
# ★H0′：附身者沒有隊（`map_controlled_team` 走 `{}` 出口）⇒ 回佔位符「—」（＝不知道），不是值主張
# 優先序（藍圖逐字）：①交戰中 ②敵對且最後所知 ≤ N 格 ③所知野獸群 ≤ N 格 ④勢力交戰 ⑤（無）
#   ★④**不做**：「與某勢力交戰」的狀態不存在（`git grep -E "at_war|war_with" -- scripts/simulation scripts/data` ＝ 0；
#     `FactionData.relations`〔neutral／ally／enemy〕全站零寫入者）⇒ spec §2 逐字：找不到就不做、回報
# ★★★感知鐵律：只讀【附身隊自己知道的】——
#   ·①＝「我是不是這場戰的一方」（`encounter_active` ＋ 兩方 id）—— **不讀 `encounter_log`**（今天安全是意外）
#   ·②③＝ **同一條** `BeliefSystem.best_estimate` 迴圈（野獸是偽隊伍，差別只在 `beast_kind`）
#     ⇒ 位置用 belief 的 `tile_pos`，**不讀**其他隊的真實 `tile_pos`
#   ·「敵對」＝ `state.player_hostile_teams`（自己的敵意清單＝自我知識）
#   ·N ＝ `VisionSystem.vision_range(附身隊, 當下晝夜倍率)`（不寫死）
#   ·★誠實限：野獸種類讀 `state.teams[tgt].beast_kind`（spec §2 指定的判準）——那是身分不是位置；
#     目標已不在 `state.teams`（死了／散了）⇒ 當作非野獸（**不**因此跳過，否則「它死了」會從真值漏進來）
const BEAST_LABEL: Dictionary = {"deer": "鹿群", "boar": "野豬", "bear": "熊", "wolves": "狼群"}

static func map_threat_line(state: WorldState) -> String:
	var pid: int = state.player_id
	var p: PersonData = state.persons.get(pid) if pid != -1 else null
	var tid: int = p.team_id if p != null else -1
	var t: TeamData = state.teams.get(tid) if tid != -1 else null
	if t == null:
		return "—"
	# ①交戰中
	if state.encounter_active and tid in [state.encounter_attacker_id, state.encounter_defender_id]:
		var other: int = state.encounter_defender_id if tid == state.encounter_attacker_id \
			else state.encounter_attacker_id
		return "交戰中：%s" % _threat_name(state, other)
	# ②③ 一個迴圈（★P5：本函式體內呼叫 best_estimate 的地方 ＝ 1）
	var n: int = VisionSystem.vision_range(state, t, DayNightSystem.new().get_vision_mult(state))
	var enemy_id: int = -1
	var enemy_d: int = 1 << 30
	var beast_id: int = -1
	var beast_d: int = 1 << 30
	var beast_pos: Vector2i = Vector2i(-1, -1)
	for tgt in BeliefSystem.known_targets(state, tid):
		var g: int = int(tgt)
		if g == tid:
			continue
		var bel: Dictionary = BeliefSystem.best_estimate(state, tid, g)
		if not bel.has("tile_pos"):
			continue
		var at: Vector2i = bel["tile_pos"]
		var d: int = _hex_d(t.tile_pos, at)
		if d > n:
			continue
		var tt: TeamData = state.teams.get(g)
		if tt != null and tt.beast_kind != "":
			if d < beast_d:
				beast_d = d; beast_id = g; beast_pos = at
		elif state.player_hostile_teams.has(g):
			if d < enemy_d:
				enemy_d = d; enemy_id = g
	if enemy_id != -1:
		return "Team%d 敵對，最後所知 %d 格" % [enemy_id, enemy_d]
	if beast_id != -1:
		return "%s有%s" % [_bearing(t.tile_pos, beast_pos), _threat_name(state, beast_id)]
	return "（無）"

static func _threat_name(state: WorldState, team_id: int) -> String:
	var tt: TeamData = state.teams.get(team_id)
	if tt != null and tt.beast_kind != "":
		return String(BEAST_LABEL.get(tt.beast_kind, "野獸"))
	return "Team%d" % team_id

static func _hex_d(a: Vector2i, b: Vector2i) -> int:
	var dx: int = b.x - a.x
	var dy: int = b.y - a.y
	return (abs(dx) + abs(dx + dy) + abs(dy)) / 2

# 方位：axial (q, r) → 平面（x ＝ q ＋ r／2、y ＝ r·√3／2，y 往下 ＝ 南）→ 八方位
#   ★誠實限：「r 增加 ＝ 往南」是照地圖逐列由上往下印的慣例；同格 ⇒「附近」
static func _bearing(from: Vector2i, to: Vector2i) -> String:
	var dq: float = float(to.x - from.x)
	var dr: float = float(to.y - from.y)
	var x: float = dq + dr * 0.5
	var y: float = dr * 0.8660254
	if absf(x) < 0.01 and absf(y) < 0.01:
		return "附近"
	var ang: float = rad_to_deg(atan2(-y, x))   # 0 ＝ 東、90 ＝ 北
	var names: Array = ["東邊", "東北", "北邊", "西北", "西邊", "西南", "南邊", "東南"]
	var idx: int = int(round(fposmod(ang, 360.0) / 45.0)) % 8
	return String(names[idx])

# ── Faction panel ──────────────────────────────────────────────────────────────

static func map_faction_panel(state: WorldState) -> Dictionary:
	var pid: int = state.player_id
	if pid == -1:
		return {"in_faction": false, "faction_id": -1, "is_leader": false,
			"faction_goal": "", "player_goal_override": "", "tribute_rate": 0.0,
			"member_orders": [], "actions": []}
	var p: PersonData = state.persons.get(pid)
	if p == null:
		return {"in_faction": false, "faction_id": -1, "is_leader": false,
			"faction_goal": "", "player_goal_override": "", "tribute_rate": 0.0,
			"member_orders": [], "actions": []}
	var pt: TeamData = state.teams.get(p.team_id)
	if pt == null or pt.faction_id == -1:
		return {"in_faction": false, "faction_id": -1, "is_leader": false,
			"faction_goal": "", "player_goal_override": "", "tribute_rate": 0.0,
			"member_orders": [], "actions": []}
	var f = state.factions.get(pt.faction_id)
	if f == null:
		return {"in_faction": false, "faction_id": -1, "is_leader": false,
			"faction_goal": "", "player_goal_override": "", "tribute_rate": 0.0,
			"member_orders": [], "actions": []}
	var is_leader: bool = f.leader_team_id == pt.team_id
	var pending_orders: Dictionary = state.player_pending_orders
	var member_orders: Array = []
	for mid in f.member_team_ids:
		var mt: TeamData = state.require_team(mid)
		var ml: PersonData = state.persons.get(mt.leader_id)
		var name_str: String = ml.person_name if ml else "Team%d" % mid
		var pending: Dictionary = pending_orders.get(str(mid), {})
		member_orders.append({
			"team_id": mid,
			"name": name_str,
			"tile_pos": mt.tile_pos,
			"commanded_task": mt.player_commanded_task,
			"pending_task": pending.get("task", ""),
			"herald_id": pending.get("herald_id", -1),
		})
	var actions: Array = ["order_faction_member", "clear_member_order"]
	if is_leader:
		actions.append_array(["set_faction_goal", "set_tribute_rate", "extract_treasury",
			"leave_faction", "betray_faction", "disband_faction"])
	else:
		actions.append("leave_faction")
	return {
		"in_faction": true,
		"faction_id": pt.faction_id,
		"is_leader": is_leader,
		"faction_goal": ", ".join(f.goals) if f.goals.size() > 0 else "",
		"player_goal_override": f.player_goal_override,
		"tribute_rate": f.tribute_rate,
		"member_orders": member_orders,
		"actions": actions,
	}

# ── Storage panel (公庫) ─────────────────────────────────────────────────────
# 公庫存取面板 DTO：feasible=站在自家 outpost；stored=公庫現貨、team_res=我方可存。
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
		if int(tile.public_storage[res]) >= 1:   # 整數 ≥1 才可交易，避免碎量顯示 ×0 幽靈列
			stored.append({ "res": res, "qty": int(tile.public_storage[res]), "cap": int(os.storage_cap(tile, res)) })
	var team_res: Array = []
	for res in pt.resources:
		if int(pt.resources[res]) >= 1:
			team_res.append({ "res": res, "qty": int(pt.resources[res]) })
	return { "feasible": true, "reason": "", "stored": stored, "team_res": team_res }

# ── Outpost panel ──────────────────────────────────────────────────────────────

static func map_outpost_panel(state: WorldState) -> Dictionary:
	var pid: int = state.player_id
	if pid == -1:
		return {"tile_pos": Vector2i(-1, -1), "outpost_type": "", "outpost_level": 0,
			"outpost_owner": -1, "has_control": false,
			"construction_in_progress": false, "ticks_left": 0, "actions": []}
	var p: PersonData = state.persons.get(pid)
	if p == null:
		return {"tile_pos": Vector2i(-1, -1), "outpost_type": "", "outpost_level": 0,
			"outpost_owner": -1, "has_control": false,
			"construction_in_progress": false, "ticks_left": 0, "actions": []}
	var pt: TeamData = state.teams.get(p.team_id)
	if pt == null:
		return {"tile_pos": Vector2i(-1, -1), "outpost_type": "", "outpost_level": 0,
			"outpost_owner": -1, "has_control": false,
			"construction_in_progress": false, "ticks_left": 0, "actions": []}
	var key: int = pt.tile_pos.x * 1000 + pt.tile_pos.y
	var tile = state.world.tiles.get(key)
	if tile == null:
		return {"tile_pos": pt.tile_pos, "outpost_type": "", "outpost_level": 0,
			"outpost_owner": -1, "has_control": false,
			"construction_in_progress": false, "ticks_left": 0, "actions": []}
	var has_ctrl: bool = tile.outpost_owner == -1 or tile.outpost_owner == pt.team_id
	var in_progress: bool = tile.construction_team_id != -1
	# Facility caps (mirrors OutpostSystem constants to avoid dependency)
	# slot 制：設施可升至 Lv3；新設施需空 slot + allowed_outpost
	var farming_max: int = 0
	var mfg_max: int = 0
	if tile.outpost_type == "civilian" and tile.outpost_level > 0:
		var slot_free: bool = OutpostSystem.slots_used(tile) < OutpostSystem.slot_cap(tile)
		farming_max = 3 if (tile.farming_level > 0 or slot_free) else 0
		mfg_max     = 3 if (tile.manufacturing_level > 0 or slot_free) else 0
	var actions: Array = []
	if has_ctrl:
		if tile.outpost_type == "" and not in_progress:
			actions.append("build_outpost")
		elif tile.outpost_type != "" and not in_progress:
			if tile.outpost_level < 3:
				actions.append("upgrade_outpost")
			if tile.farming_level < farming_max:
				actions.append("upgrade_farming")
			if tile.manufacturing_level < mfg_max:
				actions.append("upgrade_manufacturing")
			actions.append("demolish_outpost")
			# 棄置（放棄所有權保留地物，別於 demolish 拆毀地物）
			actions.append("abandon_outpost")
			# 有空 slot → 可蓋新設施
			if OutpostSystem.slots_used(tile) < OutpostSystem.slot_cap(tile):
				actions.append("build_facility")
	return {
		"tile_pos": pt.tile_pos,
		"outpost_type": tile.outpost_type,
		"outpost_level": tile.outpost_level,
		"outpost_owner": tile.outpost_owner,
		"has_control": has_ctrl,
		"construction_in_progress": in_progress,
		"ticks_left": tile.construction_ticks_left,
		"farming_level": tile.farming_level,
		"farming_max": farming_max,
		"manufacturing_level": tile.manufacturing_level,
		"manufacturing_max": mfg_max,
		"actions": actions,
	}

# ── Subteam panel ──────────────────────────────────────────────────────────────

static func map_subteam_panel(state: WorldState) -> Dictionary:
	var pid: int = state.player_id
	if pid == -1:
		return {"subteams": [], "actions_per_subteam": {}, "dispatch_candidates": [], "player_population": 0}
	var p: PersonData = state.persons.get(pid)
	if p == null:
		return {"subteams": [], "actions_per_subteam": {}, "dispatch_candidates": [], "player_population": 0}
	var ptid: int = p.team_id
	var pt: TeamData = state.teams.get(ptid)
	var subteams: Array = []
	var actions_per: Dictionary = {}
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.parent_team_id != ptid: continue
		subteams.append({
			"team_id": tid,
			"tile_pos": t.tile_pos,
			"current_task": t.current_task,
			"order_task": t.order_task,
			"population": t.population,
			"player_commanded_task": t.player_commanded_task,
		})
		actions_per[str(tid)] = ["order_subteam", "recall_subteam"]
	# Candidates: named members of player team not already leading a subteam
	var used_leaders: Array = []
	for tid2 in state.teams:
		var t2: TeamData = state.teams[tid2]
		if t2.parent_team_id == ptid:
			used_leaders.append(t2.leader_id)
	var candidates: Array = []
	if pt != null:
		for mpid in pt.named_members:
			if mpid == pt.leader_id: continue
			if used_leaders.has(mpid): continue
			var mp: PersonData = state.persons.get(mpid)
			if mp == null: continue
			candidates.append({"person_id": mpid, "name": mp.person_name})
	return {
		"subteams": subteams,
		"actions_per_subteam": actions_per,
		"dispatch_candidates": candidates,
		"player_population": pt.population if pt != null else 0,
		"anon_count": AnonTierSystem.total_pop(pt) if pt != null else 0,
	}

# ── Body slots ─────────────────────────────────────────────────────────────────

static func map_body_slots(state: WorldState) -> Dictionary:
	var pid: int = state.player_id
	var p: PersonData = state.persons.get(pid) if pid != -1 else null
	if p == null:
		return {"head": "", "torso": "", "right_arm": "", "left_arm": "", "right_leg": "", "left_leg": ""}
	var slots: Array = ["head", "torso", "right_arm", "left_arm", "right_leg", "left_leg"]
	var result: Dictionary = {}
	for slot in slots:
		result[slot] = p.equipment.get(slot, {}).get("grade", "")
	return result

# ── Global messages ────────────────────────────────────────────────────────────

static func map_global_messages(state: WorldState, n: int = 10) -> Array:
	var msgs: Array = []
	var start: int = maxi(0, state.global_messages.size() - n)
	for i in range(start, state.global_messages.size()):
		var m = state.global_messages[i]
		# ★世界寫進 global_messages 的是 MessageData（5／5 個 production 寫入點，零個 Dictionary）。
		#   舊版只認 Dictionary ⇒ 每一則都退回 str(m) ＝ <RefCounted#…>，
		#   而這支函式是【面向玩家】的那一支。
		# ★★沒有 description 時說出【它是哪一種事件】（type），
		#   ★★★不得退回印物件 id——物件 id 對玩家是雜訊，而它【看起來像內容】。
		if m is MessageData:
			var md: MessageData = m
			if md.description != "":
				msgs.append(md.description)
			elif md.type != "":
				msgs.append("(%s)" % md.type)
			else:
				msgs.append("(無描述事件)")
		elif m is Dictionary:
			# ★legacy 分支保留：「現在 5／5 是 MessageData」不保證以後沒人 append Dictionary。
			var d: String = String(m.get("description", ""))
			var dt: String = String(m.get("type", ""))
			if d != "":
				msgs.append(d)
			elif dt != "":
				msgs.append("(%s)" % dt)
			else:
				msgs.append("(無描述事件)")
		elif m is Object:
			# ★不認得的物件也不印 id：它仍然是【給玩家看】的一列。
			msgs.append("(未知事件物件:%s)" % (m as Object).get_class())
		else:
			msgs.append(str(m))
	return msgs

# ── Visible teams render ───────────────────────────────────────────────────────

static func map_visible_teams_render(state: WorldState, observer_tid: int) -> Array:
	if observer_tid < 0:
		return []
	var observer: TeamData = state.teams.get(observer_tid)
	if observer == null:
		return []
	var discovered: Array = state.team_discovered.get(observer_tid, [])
	var result: Array = []
	for tid in state.teams:
		var team: TeamData = state.teams[tid]
		var is_player: bool = tid == observer_tid
		if is_player:
			result.append({
				"team_id": tid, "tile_pos": team.tile_pos,
				"faction_id": team.faction_id, "population": team.population,
				"is_player": true, "is_hostile": false, "draw_mode": "current"
			})
			continue
		if not discovered.has(tid):
			continue
		var ddx: int = team.tile_pos.x - observer.tile_pos.x
		var ddy: int = team.tile_pos.y - observer.tile_pos.y
		var cur_dist: int = (abs(ddx) + abs(ddx + ddy) + abs(ddy)) / 2
		if cur_dist <= 3:
			result.append({
				"team_id": tid, "tile_pos": team.tile_pos,
				"faction_id": team.faction_id, "population": team.population,
				"is_player": false, "is_hostile": state.player_hostile_teams.has(tid),
				"draw_mode": "current"
			})
		else:
			var intel: Dictionary = BeliefSystem.best_estimate(state, observer_tid, tid)
			if intel.has("tile_pos"):
				result.append({
					"team_id": tid, "tile_pos": intel["tile_pos"],
					"faction_id": team.faction_id, "population": team.population,
					"is_player": false, "is_hostile": state.player_hostile_teams.has(tid),
					"draw_mode": "ghost"
				})
	return result

# ── Trade session DTO ────────────────────────────────────────────────────────
# offer-builder 契約：雙方可交易清單 + 當前出價 + 天平(NPC 視角值) + NPC 接受預估。
# 零新交易邏輯：估值 reuse TradeValuation.local_value（天平與接受同源），接受 reuse PlayerTradeSystem.evaluate_offer。
# whose-value：天平/接受用 NPC(tgt) 估值；player_items unit_value 用玩家視角供參考。
static func map_trade_session(state: WorldState, target_id: int) -> Dictionary:
	var pid: int = state.player_id
	var p: PersonData = state.persons.get(pid) if pid != -1 else null
	var pt: TeamData = state.teams.get(p.team_id) if p != null else null
	var tgt: TeamData = state.teams.get(target_id)
	if pt == null or tgt == null:
		return { "feasible": false, "player_items": [], "target_items": [],
			"offer": { "gives": {}, "wants": {} },
			"give_value": 0.0, "want_value": 0.0, "npc_would_accept": false }
	var feasible: bool = pt.tile_pos == tgt.tile_pos
	var p_items: Array = []
	var t_items: Array = []
	# ★票甲：白名單改讀【可交易品集合】—— 原本那句手工 `if res == "coin"` 是化石，型別修好後是死碼
	if Probe.enabled: Probe.bump("tradeable.read.player_mapper")
	for res in TradeValuation.TRADEABLE_RES:
		if int(pt.resources.get(res, 0)) >= 1:   # 整數 ≥1 才可交易，避免碎量顯示 ×0 幽靈列
			p_items.append({ "grade": res, "qty": int(pt.resources[res]), "unit_value": TradeValuation.local_value(pt, res, state) })
		if int(tgt.resources.get(res, 0)) >= 1:
			t_items.append({ "grade": res, "qty": int(tgt.resources[res]), "unit_value": TradeValuation.local_value(tgt, res, state) })
	if int(pt.resources.get("coin", 0)) > 0:
		p_items.append({ "grade": "coin", "qty": int(pt.resources["coin"]), "unit_value": 1.0 })
	if int(tgt.resources.get("coin", 0)) > 0:
		t_items.append({ "grade": "coin", "qty": int(tgt.resources["coin"]), "unit_value": 1.0 })
	var offer: Dictionary = state.player_state.get("trade_offer", {})
	var gives: Dictionary = offer.get("player_gives", {})
	var wants: Dictionary = offer.get("player_wants", {})
	var give_v: float = 0.0
	for r in gives:
		give_v += TradeValuation.local_value(tgt, r, state) * float(gives[r])   # NPC 視角(收 player 給)，與 evaluate_offer 同源
	var want_v: float = 0.0
	for r in wants:
		want_v += TradeValuation.local_value(tgt, r, state) * float(wants[r])   # NPC 視角(給出)，與 evaluate_offer 同源
	var accept: bool = false
	if not gives.is_empty() or not wants.is_empty():
		var ev := PlayerTradeSystem.new().evaluate_offer(state, pt.team_id, target_id,
			{ "player_gives": gives, "player_wants": wants })
		accept = ev.get("accepted", false)
	return {
		"feasible": feasible,
		"player_items": p_items, "target_items": t_items,
		"offer": { "gives": gives, "wants": wants },
		"give_value": give_v, "want_value": want_v,
		"npc_would_accept": accept,
	}
