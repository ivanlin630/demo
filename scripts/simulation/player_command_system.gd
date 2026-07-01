# scripts/simulation/player_command_system.gd
class_name PlayerCommandSystem

const RECRUIT_COST_ANON:  float = 50.0   # TEST VALUE
const RECRUIT_COST_NAMED: float = 150.0  # TEST VALUE
const JOIN_ONBOARD_MEAL:  float = 0.8    # 一餐 ≈ FOOD_PER_PERSON_PER_DAY/3 (TEST VALUE)
const TRAIN_COST_COIN: float = 30.0      # TEST VALUE — 一次訓練 coin（守恆:餉銀入公庫,非 sink）
const TRAIN_EXP_GAIN:  float = 20.0      # TEST VALUE — 一次訓練給最低非菁英 tier 的 exp
const CAMP_BUILD_TICKS: int   = 240      # TEST VALUE — 紮營 person-ticks（免材料但限時施工）
const CAMP_FOOD_CAP:    float = 40.0     # TEST VALUE — 紮營只抬 food cap（regen 產糧）,不送即時糧
const AID_GIVE_DEFAULT: float = 5.0      # TEST VALUE — forced aid_request give 預設量（一餐量,免新增數值輸入 UI）

# 投降抽成清單：30% 轉移給受降方（含武備 — 半繳械投降）
const SURRENDER_TRANSFER_RES: Array = [
	"food", "coin", "goods",
	"weapon_melee_low", "weapon_melee_high",
	"weapon_ranged_low", "weapon_ranged_high",
	"armor_low", "armor_high",
]

var _interaction: InteractionSystem = InteractionSystem.new()
var _diplomatic:  DiplomaticAiSystem = DiplomaticAiSystem.new()
var _encounter:   EncounterSystem    = EncounterSystem.new()
var _subteam:     SubteamSystem      = SubteamSystem.new()
var _action_registry: Dictionary = {}

# ── 主動互動 ────────────────────────────────────────────────

# 查詢對 target_id 可用的行動（已過濾條件）
# 返回 Array[String]，子集合自：
#   "ignore"           → 永遠可選
#   "attack"           → 永遠可選
#   "trade"            → target 有 coin OR 玩家有 coin
#   "propose_alliance" → target 非同勢力
#   "demand_tribute"   → 玩家 population > target.population × 1.5
#   "extort"           → 玩家 readiness >= 0.7
#   "recruit"          → 永遠可選（STUB — 招募邏輯尚未實裝）
func get_available_actions(state: WorldState, target_id: int) -> Array[String]:
	var actions: Array[String] = ["ignore", "attack"]
	var pt: TeamData  = _get_player_team(state)
	var tgt: TeamData = state.teams.get(target_id)
	if pt == null or tgt == null:
		return actions
	if _can_trade(state, pt, tgt):
		actions.append("trade")
	if tgt.faction_id != pt.faction_id:
		actions.append("propose_alliance")
	if pt.population > int(tgt.population * 1.5):
		actions.append("demand_tribute")
	if pt.readiness >= 0.7:
		actions.append("extort")
	var coin: float = float(pt.resources.get("coin", 0))
	if coin >= RECRUIT_COST_ANON:
		actions.append("recruit")
	# recruit_anon：有 coin 且目標有匿名人口可招（與 recruit 並列，直接執行版）
	if coin >= RECRUIT_COST_ANON and _target_has_anon(tgt):
		actions.append("recruit_anon")
	# invite_settle：玩家站在自家 outpost → 可邀目標前來定居
	if _can_invite_settle(state, pt, tgt):
		actions.append("invite_settle")
	actions.append("gather_intel")
	# beg：玩家主動乞討（對稱性——NPC 會乞食,玩家亦可）。需求/接受由 _resolve_aid_request 自決,非需時自然被拒
	actions.append("beg")
	return actions

# UI 覆蓋審計用：回傳全 registry action id（_test_action_ui_coverage 驗每個都有 UI 路徑）
func get_registered_actions() -> Array:
	if _action_registry.is_empty():
		_setup_registry()
	return _action_registry.keys()

# recruit_anon 前提：目標人口 > 1（_recruit_anon_internal 拒 pop<=1）
func _target_has_anon(tgt: TeamData) -> bool:
	return tgt.population > 1

# invite_settle 前提：玩家腳下為自家 outpost（_action_invite_settle 需 settle_pos 指向自家 outpost）
func _can_invite_settle(state: WorldState, pt: TeamData, tgt: TeamData) -> bool:
	if tgt == null:
		return false
	var tile: HexTileData = state.world.tiles.get(pt.tile_pos.x * 1000 + pt.tile_pos.y)
	return tile != null and tile.outpost_level > 0 and tile.outpost_owner == pt.team_id

# ── Registry 初始化 ───────────────────────────────────────────

func _setup_registry() -> void:
	_action_registry = {
		"trade":                  _action_trade,
		"propose_alliance":       _action_propose_alliance,
		"demand_tribute":         _action_demand_tribute,
		"attack":                 _action_attack,
		"extort":                 _action_extort,
		"recruit":                _action_recruit,
		"recruit_anon":           _action_recruit_anon,
		"take_loot":              _action_take_loot,
		"leave_loot":             _action_leave_loot,
		"establish_faction":      _action_establish_faction_cmd,
		"refresh_targets":        _action_refresh_targets,
		"confirm_trade":          _action_confirm_trade,
		"submit_trade_offer":     _action_submit_trade_offer,
		"cancel_trade":           _action_cancel_trade,
		"set_tribute_rate":       _action_set_tribute_rate,
		"set_armed_anon_ratio":   _action_set_armed_ratio,
		"build_outpost":          _action_build_outpost,
		"upgrade_outpost":        _action_upgrade_outpost,
		"upgrade_farming":        _action_upgrade_farming,
		"upgrade_manufacturing":  _action_upgrade_manufacturing,
		"build_facility":         _action_build_facility,
		"demolish_outpost":       _action_demolish_outpost,
		"abandon_outpost":        _action_abandon_outpost,
		"dispatch_subteam":       _action_dispatch_subteam,
		"order_subteam":          _action_order_subteam,
		"recall_subteam":         _action_recall_subteam,
		"subjugate_enemy":        _action_subjugate_enemy,
		"leave_faction":          _action_leave_faction,
		"betray_faction":         _action_betray_faction,
		"disband_faction":        _action_disband_faction,
		"offer_surrender":        _action_offer_surrender,
		"surrender_in_encounter": _action_surrender_in_encounter,
		"accept_encounter":        _action_accept_encounter,
		"surrender_pre_encounter": _action_surrender_pre_encounter,
		"set_faction_goal":       _action_set_faction_goal,
		"order_faction_member":   _action_order_faction_member,
		"clear_member_order":     _action_clear_member_order,
		"gather_intel":           _action_gather_intel,
		"beg":                    _action_beg,
		"confirm_gather_intel":   _action_confirm_gather_intel,
		"respond_aid_request":    _action_respond_aid_request,
		"invite_settle":          _action_invite_settle,
		"choose_heir":            _action_choose_heir,
		"extract_treasury":       _action_extract_treasury,
		"withdraw_from_storage":  _action_withdraw_from_storage,
		"deposit_to_storage":     _action_deposit_to_storage,
		"hunt":                   _action_hunt,
		"hunt_beast":             _action_hunt_beast,
		"train":                  _action_train,
		"camp":                   _action_camp,
		"promote_anon":           _action_promote_anon,
	}

# 執行玩家主動行動
# 返回 { "ok": bool, "msg": String }
func execute_action(state: WorldState, target_id: int, action: String) -> Dictionary:
	var pt: TeamData = _get_player_team(state)
	var pt_id: int   = _get_player_team_id(state)
	# H: choose_heir 在玩家 person 已死時觸發，pt 必為 null，需在 null 守衛前處理
	if action == "choose_heir":
		if _action_registry.is_empty():
			_setup_registry()
		return _action_registry["choose_heir"].call(state, target_id, pt, pt_id)
	if pt == null:
		return { "ok": false, "msg": "找不到玩家 team" }
	if action == "ignore":
		state.player_pending_targets.erase(target_id)
		return { "ok": true, "msg": "忽略" }
	if _action_registry.is_empty():
		_setup_registry()
	if not _action_registry.has(action):
		return { "ok": false, "msg": "未知行動: %s" % action }
	return _action_registry[action].call(state, target_id, pt, pt_id)

# ── Action Handlers ───────────────────────────────────────────

func _action_hunt(state: WorldState, _target: int, pt: TeamData, _pt_id: int) -> Dictionary:
	var tile: HexTileData = state.world.tiles.get(pt.tile_pos.x * 1000 + pt.tile_pos.y)
	if tile == null or int(tile.resources.get("wild_game", 0)) <= 0:
		return { "ok": false, "msg": "此地無獵物" }
	var r: Dictionary = HuntSystem.new().hunt_small_game(state, pt, tile, true)
	return { "ok": true, "msg": r.get("msg", "") }

func _action_hunt_beast(state: WorldState, _target: int, pt: TeamData, pt_id: int) -> Dictionary:
	var tile: HexTileData = state.world.tiles.get(pt.tile_pos.x * 1000 + pt.tile_pos.y)
	if tile == null or int(tile.resources.get("predator_density", 0)) <= 0:
		return { "ok": false, "msg": "此地無猛獸可獵" }
	# 依地形選獸級（簡版：山→bear、其餘→boar）。TEST VALUE，待 2b-2 量測調整。
	var kind: String = "bear" if tile.terrain == "mountain" else "boar"
	tile.resources["predator_density"] = int(tile.resources["predator_density"]) - 1   # 枯竭
	var bid: int = BeastSystem.new().build_beast_team(state, kind, pt.tile_pos)
	_encounter.init_encounter(state, pt_id, bid, "normal")
	return { "ok": true, "msg": "發起獵 %s" % kind, "requires_preview": false }

# 訓練/晉升：一次性花 coin → 給最低非菁英 tier 一批 exp → 立即嘗試升階（reuse AnonTierSystem,玩家版比 NPC 完整）
# coin 守恆：訓練餉銀入自隊公庫(anon_treasury),不蒸發（對齊 try_promote「訓練餉銀入公庫」）。
func _action_train(state: WorldState, _target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	if AnonTierSystem.total_pop(pt) <= 0:
		return { "ok": false, "msg": "無匿名人口可訓練" }
	if float(pt.resources.get("coin", 0)) < TRAIN_COST_COIN:
		return { "ok": false, "msg": "coin 不足訓練（需 %.0f）" % TRAIN_COST_COIN }
	ResourceBank.add(pt, "coin", -TRAIN_COST_COIN, "player_train")
	AnonTreasuryBank.deposit(pt, TRAIN_COST_COIN, "train_salary")   # 守恆：餉銀入公庫,不蒸發（coin_eq 不破）
	var target_tier: String = ""
	for tier in AnonTierSystem.TIER_ORDER:
		if tier == AnonCohort.TIER_ELITE: break
		if int(pt.anon_tiers.get(tier, 0)) > 0:
			target_tier = tier; break
	if target_tier == "":
		return { "ok": true, "msg": "訓練（-%.0f coin,無可升階對象）" % TRAIN_COST_COIN }
	AnonTierSystem.add_exp(pt, target_tier, TRAIN_EXP_GAIN)
	var promoted: int = 0
	for tier in AnonTierSystem.TIER_ORDER:
		if tier == AnonCohort.TIER_ELITE: break
		var n: int = int(pt.anon_tiers.get(tier, 0))
		if n > 0:
			promoted += AnonTierSystem.try_promote(state, pt, tier, n)
	var msg: String = "訓練（-%.0f coin → %s +exp" % [TRAIN_COST_COIN, target_tier]
	if promoted > 0:
		msg += "，升階 %d 人" % promoted
	msg += "）"
	return { "ok": true, "msg": msg, "payload": {"promoted": promoted} }

# 拔擢匿名→記名（對稱性）：玩家版走與 NPC 同一條路徑 PersonGenerator.generate_for_team
# （已含「從 anon 桶移除 1 + treasury×3 bonus + 加 state.persons」）。command 只負責 append named_members。
# population getter 自動守恆：anon-1 / named+1,總 pop 不變。NPC 缺 named 時自動拔擢,玩家無對應 → 全 anon 隊永遠卡(無法派子隊/任命),此 command 補上。
func _action_promote_anon(state: WorldState, _target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	if AnonTierSystem.total_pop(pt) <= 0:
		return { "ok": false, "msg": "無匿名兵可拔擢" }
	var p: PersonData = PersonGenerator.generate_for_team(state, pt, "member")
	if p == null:
		return { "ok": false, "msg": "拔擢失敗（無可拔擢 anon）" }
	state.add_member(pt, p.id)   # 拔擢 anon→named（leader 不變,新增 named 成員）
	return { "ok": true, "msg": "拔擢 %s 為記名成員" % p.person_name }

# 紮營（Y 版,生存落腳）：免材料 + 無即時糧（只抬 cap）+ 距離 spacing + 限時施工。
# 玩家發起的限時建造令（設玩家隊 task=建設,PRIO_PLAYER）→ construction 推進 → 完工釋放回 idle。
func _action_camp(state: WorldState, _target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	var camp_type: String = str(state.player_state.get("build_type", "civilian"))
	if camp_type not in ["civilian", "military"]:
		return { "ok": false, "msg": "無效紮營類型" }
	var tile: HexTileData = state.world.tiles.get(pt.tile_pos.x * 1000 + pt.tile_pos.y)
	if tile == null:
		return { "ok": false, "msg": "格子不存在" }
	if tile.outpost_level > 0 or tile.outpost_owner != -1:
		return { "ok": false, "msg": "此地已有據點" }
	if tile.terrain == "mountain":
		return { "ok": false, "msg": "山地無法紮營" }
	var os := OutpostSystem.new()
	if not os._check_distance(state, tile.tile_pos, camp_type):
		return { "ok": false, "msg": "離既有據點太近,無法紮營" }
	tile.construction_target = { "action": "crude_camp", "type": camp_type, "level": 1, "owner": pt.team_id }
	tile.construction_ticks_left = CAMP_BUILD_TICKS
	tile.construction_started_tick = -1
	TaskArbiter.try_set(state, pt, TeamData.TASK_BUILD, pt.tile_pos, TaskArbiter.PRIO_PLAYER, "player_camp")
	return { "ok": true, "msg": "開始紮營 %s（%d ticks,免材料）" % [camp_type, CAMP_BUILD_TICKS] }

func _action_extract_treasury(state: WorldState, _target: int, pt: TeamData, _pt_id: int) -> Dictionary:
	var ratio: float = float(state.player_state.get("extract_ratio", 0.0))
	if ratio <= 0.0 or ratio > 1.0:
		return { "ok": false, "msg": "extract_ratio 必須 (0, 1]" }
	FactionAISystem.new()._extract_treasury(state, pt, ratio, "玩家主動")
	return { "ok": true, "msg": "徵用 %.0f%%" % (ratio * 100) }

func _action_withdraw_from_storage(state: WorldState, _target: int, pt: TeamData, pt_id: int) -> Dictionary:
	var res: String = state.player_state.get("storage_res", "")
	var amount: float = float(state.player_state.get("storage_amount", 0.0))
	if res == "" or amount <= 0: return { "ok": false, "msg": "未指定 res/amount" }
	var tile: HexTileData = state.world.tiles.get(pt.tile_pos.x * 1000 + pt.tile_pos.y)
	if tile == null or tile.outpost_owner != pt_id: return { "ok": false, "msg": "非自家 outpost" }
	var stored: float = float(tile.public_storage.get(res, 0))
	if stored < amount: return { "ok": false, "msg": "公庫不足" }
	tile.public_storage[res] = stored - amount
	ResourceBank.add(pt, res, amount, "withdraw_storage")
	return { "ok": true, "msg": "取 %s × %.0f" % [res, amount] }

func _action_deposit_to_storage(state: WorldState, _target: int, pt: TeamData, pt_id: int) -> Dictionary:
	var res: String = state.player_state.get("storage_res", "")
	var amount: float = float(state.player_state.get("storage_amount", 0.0))
	if res == "" or amount <= 0: return { "ok": false, "msg": "未指定 res/amount" }
	var tile: HexTileData = state.world.tiles.get(pt.tile_pos.x * 1000 + pt.tile_pos.y)
	if tile == null or tile.outpost_owner != pt_id: return { "ok": false, "msg": "非自家 outpost" }
	var have: float = float(pt.resources.get(res, 0))
	if have < amount: return { "ok": false, "msg": "team 資源不足" }
	var cap: float = OutpostSystem.new()._get_storage_cap(tile, res)
	var stored: float = float(tile.public_storage.get(res, 0))
	if stored + amount > cap: return { "ok": false, "msg": "公庫已滿" }
	tile.public_storage[res] = stored + amount
	ResourceBank.set_amt(pt, res, have - amount, "deposit_storage")
	return { "ok": true, "msg": "存 %s × %.0f" % [res, amount] }

func _action_trade(state: WorldState, target_id: int, _pt: TeamData, _pt_id: int) -> Dictionary:
	var tgt: TeamData = state.teams.get(target_id)
	if tgt == null:
		state.player_pending_targets.erase(target_id)
		return { "ok": false, "msg": "目標不存在" }
	state.player_state["pending_trade_target"] = target_id
	return { "ok": true, "msg": "等待確認",
			 "requires_preview": true, "preview_target_id": target_id }

func _action_propose_alliance(state: WorldState, target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	var tgt: TeamData = state.teams.get(target_id)
	if tgt == null:
		return { "ok": false, "msg": "目標不存在" }
	var resp: String = _diplomatic.handle_diplomacy_message(state, tgt, pt, "propose_alliance")
	if resp == "accept":
		if pt.faction_id == -1 and tgt.faction_id == -1:
			state.create_faction(pt_id)
		_diplomatic._form_alliance(state, pt, tgt)
		print("[PlayerCmd] 同盟成立，勢力%d" % pt.faction_id)
	state.player_pending_targets.erase(target_id)
	return { "ok": resp == "accept", "msg": "外交結果: %s" % resp }

func _action_demand_tribute(state: WorldState, target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	var tgt: TeamData = state.teams.get(target_id)
	if tgt == null:
		return { "ok": false, "msg": "目標不存在" }
	var resp: String = _diplomatic.handle_diplomacy_message(state, tgt, pt, "demand_tribute")
	state.player_pending_targets.erase(target_id)
	if resp == "accept":
		var amount: float = float(tgt.resources.get("coin", 0)) * 0.1  # TEST VALUE
		ResourceBank.add(tgt, "coin", -amount, "demand_tribute_out")
		ResourceBank.add(pt, "coin", amount, "demand_tribute_in")
		print("[PlayerCmd] 索貢成功 Team%d→玩家 %.0f coin" % [target_id, amount])
		return { "ok": true, "msg": "索貢成功（獲得%.0f coin）" % amount }
	else:
		UnrestBank.add(tgt, 2, "player")
		var leader_p: PersonData = state.persons.get(tgt.leader_id)
		if leader_p:
			leader_p.memory.append({
				"event_id": state.world.current_tick,
				"intensity": "significant",
				"reaction": "tribute_refused"
			})
		print("[PlayerCmd] 索貢遭拒 Team%d unrest+2" % target_id)
		return { "ok": false, "msg": "索貢遭拒，關係惡化" }

func _action_attack(state: WorldState, target_id: int, _pt: TeamData, pt_id: int) -> Dictionary:
	var tgt: TeamData = state.teams.get(target_id)
	if tgt == null:
		return { "ok": false, "msg": "目標不存在" }
	_encounter.init_encounter(state, pt_id, target_id, "normal")
	if not state.player_hostile_teams.has(target_id):
		state.player_hostile_teams.append(target_id)
	state.player_pending_targets.erase(target_id)
	print("[PlayerCmd] 玩家發起攻擊 Team%d → Team%d" % [pt_id, target_id])
	return { "ok": true, "msg": "發起攻擊" }

func _action_extort(state: WorldState, target_id: int, _pt: TeamData, pt_id: int) -> Dictionary:
	var extort_result := _interaction.resolve_extortion_direct(state, pt_id, target_id)
	state.player_pending_targets.erase(target_id)
	if not extort_result.get("accepted", true):
		var tgt2: TeamData = state.teams.get(target_id)
		if tgt2:
			UnrestBank.add(tgt2, 1, "player")
		print("[PlayerCmd] 勒索遭拒 Team%d unrest+1" % target_id)
	return { "ok": extort_result.get("ok", false), "msg": extort_result.get("msg", "") }

func _action_recruit(state: WorldState, target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	# Always return a menu — never auto-execute. Player must call recruit_anon or recruit_named.
	var tgt: TeamData = state.teams.get(target_id)
	if tgt == null:
		state.player_pending_targets.erase(target_id)
		return { "ok": false, "msg": "目標不存在" }
	var willing: Array = []
	for pid in tgt.named_members:
		if pid == tgt.leader_id: continue
		var person: PersonData = state.persons.get(pid)
		if person and person.loyalty < 0.4:
			willing.append(pid)
	var coin: float      = float(pt.resources.get("coin", 0))
	var anon_ok: bool    = coin >= RECRUIT_COST_ANON and tgt.population > 1
	var willing_dto: Array = []
	if not willing.is_empty():
		willing_dto = PlayerApiMapper.map_willing_members(state, willing)
	return { "ok": true, "msg": "選擇招募方式",
			 "payload": {
				 "has_willing_named":   not willing.is_empty(),
				 "willing_members":     willing_dto,
				 "anon_available":      anon_ok,
				 "anon_cost":           int(RECRUIT_COST_ANON),
				 "named_cost":          int(RECRUIT_COST_NAMED),
				 "target_team_id":      target_id
			 }}


func _action_recruit_anon(state: WorldState, target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	var tgt3: TeamData = state.teams.get(target_id)
	if tgt3 == null:
		return { "ok": false, "msg": "目標不存在" }
	return _recruit_anon_internal(state, pt, tgt3, target_id)

func _action_take_loot(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	var res: Dictionary = state.last_encounter_result
	if res.is_empty() or res.get("winner_id", -1) != pt_id:
		return { "ok": false, "msg": "無可收取戰利品" }
	var loot: Dictionary = res.get("loot_pool", {})
	var loser_team: TeamData = state.teams.get(res.get("loser_id", -1))
	for rk in loot:
		var amount: float = float(loot[rk])
		if loser_team != null:
			ResourceBank.remove(loser_team, rk, amount, "collect_loot_out")
		ResourceBank.add(pt, rk, amount, "collect_loot_in")
	state.last_encounter_result = {}
	print("[PlayerCmd] 收取戰利品: %s" % str(loot))
	return { "ok": true, "msg": "收取戰利品成功",
			 "payload": {"refresh_required": true} }

func _action_leave_loot(state: WorldState, _target_id: int, _pt: TeamData, _pt_id: int) -> Dictionary:
	state.last_encounter_result = {}
	return { "ok": true, "msg": "放棄戰利品" }

func _action_establish_faction_cmd(state: WorldState, _target_id: int, _pt: TeamData, _pt_id: int) -> Dictionary:
	return establish_faction(state)

func _action_refresh_targets(state: WorldState, _target_id: int, _pt: TeamData, _pt_id: int) -> Dictionary:
	refresh_colocation_targets(state)
	return { "ok": true, "msg": "互動目標已更新" }

func _action_confirm_trade(state: WorldState, target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	# If a structured trade_offer is present, delegate to the new offer system
	if state.player_state.has("trade_offer"):
		return _action_submit_trade_offer(state, target_id, pt, pt_id)
	# Legacy fallback: NPC-initiated trade confirmation
	var tid2: int = int(state.player_state.get("pending_trade_target", -1))
	if tid2 < 0 or not state.teams.has(tid2):
		return { "ok": false, "msg": "無待確認貿易" }
	var result2 := _interaction.resolve_trade_direct(state, pt_id, tid2)
	state.player_pending_targets.erase(tid2)
	state.player_state.erase("pending_trade_target")
	return result2

func _action_submit_trade_offer(state: WorldState, _target_id: int, _pt: TeamData, pt_id: int) -> Dictionary:
	var tid: int          = int(state.player_state.get("pending_trade_target", -1))
	var offer: Dictionary = state.player_state.get("trade_offer", {})
	if tid < 0 or offer.is_empty():
		return { "ok": false, "msg": "無待送出的出價" }
	if not state.teams.has(tid):
		return { "ok": false, "msg": "目標隊伍不存在" }
	var result := PlayerTradeSystem.new().execute_offer(state, pt_id, tid, offer)
	if result.get("ok", false):
		state.player_pending_targets.erase(tid)
		state.player_state.erase("pending_trade_target")
		state.player_state.erase("trade_offer")
	return result

func _action_cancel_trade(state: WorldState, _target_id: int, _pt: TeamData, _pt_id: int) -> Dictionary:
	var tid3: int = int(state.player_state.get("pending_trade_target", -1))
	if tid3 >= 0:
		state.player_pending_targets.erase(tid3)
	state.player_state.erase("pending_trade_target")
	return { "ok": true, "msg": "取消貿易" }

func _action_set_tribute_rate(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	var rate: float = float(state.player_state.get("tribute_rate_input", 0.1))
	rate = clampf(rate, 0.0, 1.0)
	if pt.faction_id == -1:
		return { "ok": false, "msg": "玩家不在勢力中" }
	var f_tr: FactionData = state.factions.get(pt.faction_id)
	if f_tr == null:
		return { "ok": false, "msg": "勢力不存在" }
	if f_tr.leader_team_id != pt_id:
		return { "ok": false, "msg": "只有 leader 可設定徵收率" }
	f_tr.tribute_rate = rate
	print("[PlayerCmd] set_tribute_rate → %.2f" % rate)
	return { "ok": true, "msg": "徵收率設為 %.0f%%" % (rate * 100) }

# U18：設自隊匿名武裝比例（none-target，比照 set_tribute_rate）
func _action_set_armed_ratio(state: WorldState, _target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	var r: float = clampf(float(state.player_state.get("armed_ratio_input", pt.armed_anon_ratio)), 0.0, 1.0)
	pt.armed_anon_ratio = r
	print("[PlayerCmd] set_armed_anon_ratio → %.2f" % r)
	return { "ok": true, "msg": "武裝比例設為 %.0f%%" % (r * 100.0) }

func _action_build_outpost(state: WorldState, _target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	var outpost_type: String = str(state.player_state.get("build_type", "civilian"))
	if outpost_type not in ["civilian", "military"]:
		return { "ok": false, "msg": "無效據點類型" }
	var _os := OutpostSystem.new()
	var ok: bool = _os.start_build(state, pt, outpost_type, 1)
	if not ok:
		return { "ok": false, "msg": "無法建造（資源不足或距離限制）" }
	print("[PlayerCmd] build_outpost type=%s" % outpost_type)
	return { "ok": true, "msg": "開始建造 %s" % outpost_type }

func _action_upgrade_outpost(state: WorldState, _target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	var _os2 := OutpostSystem.new()
	var ok2: bool = _os2.start_upgrade_level(state, pt)
	if not ok2:
		return { "ok": false, "msg": "無法升級（非 owner 或已滿級）" }
	return { "ok": true, "msg": "開始升級據點" }

func _action_upgrade_farming(state: WorldState, _target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	var _os3 := OutpostSystem.new()
	var ok3: bool = _os3.start_upgrade_farming(state, pt)
	if not ok3:
		return { "ok": false, "msg": "無法升級農業（非 civilian 或已滿）" }
	return { "ok": true, "msg": "開始升級農業" }

func _action_upgrade_manufacturing(state: WorldState, _target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	var _os4 := OutpostSystem.new()
	var ok4: bool = _os4.start_upgrade_manufacturing(state, pt)
	if not ok4:
		return { "ok": false, "msg": "無法升級製造（條件不符）" }
	return { "ok": true, "msg": "開始升級製造" }

# 統一設施擴建入口：依 player_state["facility_type"] 走通用 start_upgrade_facility
func _action_build_facility(state: WorldState, _target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	var facility: String = str(state.player_state.get("facility_type", "farming"))
	if facility == "manufacturing":
		facility = "workshop"   # 舊指令別名
	if not OutpostSystem.FACILITY_DEF.has(facility):
		return { "ok": false, "msg": "未知 facility: %s" % facility }
	var _os := OutpostSystem.new()
	var ok: bool = _os.start_upgrade_facility(state, pt, facility)
	if not ok:
		return { "ok": false, "msg": "無法擴建 %s（條件不符）" % facility }
	return { "ok": true, "msg": "開始擴建 %s" % facility }

func _action_demolish_outpost(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	var _os5 := OutpostSystem.new()
	var tile_id5: int = pt.tile_pos.x * 1000 + pt.tile_pos.y
	var tile5: HexTileData = state.world.tiles.get(tile_id5)
	if tile5 == null:
		return { "ok": false, "msg": "格子不存在" }
	if tile5.construction_ticks_left > 0 and tile5.outpost_level == 0:
		tile5.construction_team_id   = -1
		tile5.construction_ticks_left = 0
		tile5.construction_target     = {}
		TaskArbiter.release(pt)
		return { "ok": true, "msg": "取消施工" }
	if not _os5._has_control(state, pt_id, tile5):
		return { "ok": false, "msg": "無支配權，無法拆除" }
	var ok5: bool = _os5.demolish_with_control(state, pt)
	if not ok5:
		return { "ok": false, "msg": "無法拆除" }
	return { "ok": true, "msg": "開始拆除據點" }

func _action_abandon_outpost(state: WorldState, _target_id: int, _pt: TeamData, pt_id: int) -> Dictionary:
	var pos_arr: Array = state.player_state.get("abandon_pos", [-1, -1])
	var pos := Vector2i(int(pos_arr[0]), int(pos_arr[1]))
	if pos.x < 0:
		return { "ok": false, "msg": "未指定 outpost 位置" }
	var tile: HexTileData = state.world.tiles.get(pos.x * 1000 + pos.y)
	if tile == null or tile.outpost_level == 0:
		return { "ok": false, "msg": "目標無 outpost" }
	if tile.outpost_owner != pt_id:
		return { "ok": false, "msg": "非自家 outpost" }
	OutpostOwnerBank.set_owner(tile, -1, "abandon")
	return { "ok": true, "msg": "已棄置 outpost (%d,%d)" % [pos.x, pos.y] }

func _action_dispatch_subteam(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	var sub_leader_id: int = int(state.player_state.get("sub_leader_id", -1))
	var pop_count: int     = int(state.player_state.get("sub_pop_count", 1))
	var task: String       = str(state.player_state.get("sub_task", TeamData.TASK_IDLE))
	var tq: int = int(state.player_state.get("sub_move_q", -1))
	var tr: int = int(state.player_state.get("sub_move_r", -1))
	var move_tgt: Vector2i = Vector2i(tq, tr)
	if sub_leader_id == -1 or not state.persons.has(sub_leader_id):
		return { "ok": false, "msg": "未指定子隊 leader" }
	if pop_count < 1 or pop_count >= pt.population:
		return { "ok": false, "msg": "人數不合法（1 ~ population-1）" }
	var sub_id: int = SubteamSystem.new().dispatch(state, pt_id, sub_leader_id, pop_count, task, move_tgt)
	if sub_id == -1:
		return { "ok": false, "msg": "派遣失敗" }
	return { "ok": true, "msg": "派出子隊 Team%d" % sub_id, "sub_id": sub_id }

func _action_order_subteam(state: WorldState, _target_id: int, _pt: TeamData, pt_id: int) -> Dictionary:
	var sub_id2: int   = int(state.player_state.get("order_sub_id", -1))
	var new_task: String = str(state.player_state.get("sub_new_task", TeamData.TASK_IDLE))
	var nq: int = int(state.player_state.get("sub_new_move_q", -1))
	var nr: int = int(state.player_state.get("sub_new_move_r", -1))
	var sub2: TeamData = state.teams.get(sub_id2)
	if sub2 == null or sub2.parent_team_id != pt_id:
		return { "ok": false, "msg": "目標不是玩家子隊" }
	if new_task == TeamData.TASK_IDLE:
		TaskArbiter.release(sub2)
		sub2.move_target = Vector2i(nq, nr)
	elif not TaskArbiter.try_set(state, sub2, new_task, Vector2i(nq, nr),
			TaskArbiter.PRIO_PLAYER, "player_order"):
		return { "ok": false, "msg": "Team%d 正忙（更高優先任務 %s）" % [sub_id2, sub2.current_task] }
	print("[PlayerCmd] order_subteam Team%d → task=%s move=(%d,%d)" % [sub_id2, new_task, nq, nr])
	return { "ok": true, "msg": "已下令 Team%d" % sub_id2 }

func _action_recall_subteam(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	var recall_sub_id: int = int(state.player_state.get("recall_sub_id", -1))
	var recall_sub: TeamData = state.teams.get(recall_sub_id)
	if recall_sub == null or recall_sub.parent_team_id != pt_id:
		return { "ok": false, "msg": "目標不是玩家子隊" }
	if pt.population < 2:
		return { "ok": false, "msg": "人數不足以派信使" }
	var herald_leader_id: int = -1
	for pid in pt.named_members:
		if pid != pt.leader_id:
			herald_leader_id = pid
			break
	if herald_leader_id == -1:
		return { "ok": false, "msg": "無可用的信使人選" }
	var herald_id: int = SubteamSystem.new().dispatch(
		state, pt_id, herald_leader_id, 1, TeamData.TASK_HERALD,
		recall_sub.tile_pos, recall_sub_id, TeamData.TASK_MERGE)
	if herald_id == -1:
		return { "ok": false, "msg": "派信使失敗" }
	return { "ok": true, "msg": "信使已出發至 Team%d" % recall_sub_id }

func _action_subjugate_enemy(state: WorldState, _target_id: int, _pt: TeamData, pt_id: int) -> Dictionary:
	var result: Dictionary = state.last_encounter_result
	if result.is_empty() or not result.get("can_subjugate", false):
		return { "ok": false, "msg": "無可收編的敗者" }
	var loser_id: int = int(result.get("loser_id", -1))
	var loser: TeamData = state.teams.get(loser_id)
	if loser == null:
		return { "ok": false, "msg": "敗者已消滅" }
	_interaction.subjugate_team(state, pt_id, loser_id)
	state.last_encounter_result["can_subjugate"] = false
	return { "ok": true, "msg": "收編 Team%d" % loser_id }

func _action_leave_faction(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	if pt.faction_id == -1:
		return { "ok": false, "msg": "玩家不在勢力中" }
	var fid3: int = pt.faction_id
	var f3: FactionData = state.factions.get(fid3)
	if f3 == null:
		return { "ok": false, "msg": "勢力不存在" }
	if f3.leader_team_id == pt_id:
		return { "ok": false, "msg": "請使用 disband_faction（leader 不能普通離開）" }
	state.clear_team_faction(pt)   # 玩家離開 faction（雙向同步）
	var leader_team3: TeamData = state.teams.get(f3.leader_team_id)
	if leader_team3 != null:
		var leader_p3: PersonData = state.persons.get(leader_team3.leader_id)
		if leader_p3:
			LoyaltyBank.adjust(leader_p3, -0.15, "faction_leave")
	print("[PlayerCmd] 玩家離開勢力%d" % fid3)
	return { "ok": true, "msg": "已離開勢力" }

func _action_betray_faction(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	if pt.faction_id == -1:
		return { "ok": false, "msg": "玩家不在勢力中" }
	var fid4: int = pt.faction_id
	var f4: FactionData = state.factions.get(fid4)
	if f4 == null:
		return { "ok": false, "msg": "勢力不存在" }
	for tid4 in f4.member_team_ids:
		if tid4 == pt_id: continue
		if not state.player_hostile_teams.has(tid4):
			state.player_hostile_teams.append(tid4)
	state.clear_team_faction(pt)   # 玩家背叛離開 faction（雙向同步）
	state.player_state["betrayal_count"] = int(state.player_state.get("betrayal_count", 0)) + 1
	var leader_team4: TeamData = state.teams.get(f4.leader_team_id)
	if leader_team4 != null:
		var leader_p4: PersonData = state.persons.get(leader_team4.leader_id)
		if leader_p4:
			leader_p4.memory.append({
				"type": "betrayal", "subject_id": pt.leader_id,
				"tick": state.world.current_tick, "intensity": 0.9
			})
	print("[PlayerCmd] 玩家背叛勢力%d（betrayal_count=%d）" % [
		fid4, state.player_state["betrayal_count"]])
	return { "ok": true, "msg": "背叛勢力，原成員已敵對" }

func _action_disband_faction(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	if pt.faction_id == -1:
		return { "ok": false, "msg": "玩家不在勢力中" }
	var fid5: int = pt.faction_id
	var f5: FactionData = state.factions.get(fid5)
	if f5 == null:
		return { "ok": false, "msg": "勢力不存在" }
	if f5.leader_team_id != pt_id:
		return { "ok": false, "msg": "只有 leader 可解散勢力" }
	for tid5 in f5.member_team_ids:
		if tid5 == pt_id: continue
		var mt5: TeamData = state.teams.get(tid5)
		if mt5 == null: continue
		var lp5: PersonData = state.persons.get(mt5.leader_id)
		if lp5:
			LoyaltyBank.adjust(lp5, -0.3, "faction_disband")
	state.disband_faction(fid5)
	return { "ok": true, "msg": "勢力已解散" }

# 投降資產轉移：from 隊 30% 指定資源交給 to 隊（收編前戰利品，守恆）
func _transfer_surrender_assets(from: TeamData, to: TeamData) -> void:
	for res in SURRENDER_TRANSFER_RES:
		var amt: float = float(from.resources.get(res, 0)) * 0.3
		ResourceBank.add(from, res, -amt, "surrender_out")
		ResourceBank.add(to, res, amt, "surrender_in")

func _action_offer_surrender(state: WorldState, target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	var tgt6: TeamData = state.teams.get(target_id)
	if tgt6 == null:
		return { "ok": false, "msg": "目標不存在" }
	var resp6: String = _diplomatic.handle_diplomacy_message(state, tgt6, pt, "offer_surrender")
	state.player_pending_targets.erase(target_id)
	if resp6 == "accept":
		_transfer_surrender_assets(pt, tgt6)
		_interaction.subjugate_team(state, target_id, pt_id)
		print("[PlayerCmd] 玩家投降 Team%d 接受" % target_id)
		return { "ok": true, "msg": "投降被接受，已被收編" }
	else:
		return { "ok": false, "msg": "對方拒絕接受投降" }

func _action_surrender_in_encounter(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	if not state.encounter_active:
		return { "ok": false, "msg": "非戰鬥中" }
	var enemy_id6: int = state.encounter_defender_id if state.encounter_attacker_id == pt_id \
		else state.encounter_attacker_id
	var enemy6: TeamData = state.teams.get(enemy_id6)
	if enemy6 == null:
		return { "ok": false, "msg": "找不到對手" }
	var resp6b: String = _diplomatic.handle_diplomacy_message(state, enemy6, pt, "offer_surrender")
	if resp6b == "accept":
		_transfer_surrender_assets(pt, enemy6)
		_interaction.subjugate_team(state, enemy_id6, pt_id)
		_encounter.cleanup_encounter(state)
		print("[PlayerCmd] 玩家戰中投降，Team%d 接受" % enemy_id6)
		return { "ok": true, "msg": "投降被接受" }
	else:
		return { "ok": false, "msg": "對方拒絕" }

func _action_accept_encounter(state: WorldState, _target_id: int, _pt: TeamData, _pt_id: int) -> Dictionary:
	var pre: Dictionary = state.player_pre_encounter
	if pre.is_empty():
		return { "ok": false, "msg": "無待處理預備遭遇戰" }
	var atk_id: int = int(pre.get("attacker_id", -1))
	var def_id: int = int(pre.get("defender_id", -1))
	state.player_pre_encounter = {}
	_encounter.init_encounter(state, atk_id, def_id, "normal")
	print("[PlayerCmd] 玩家選擇迎擊，遭遇戰開始 Team%d vs Team%d" % [atk_id, def_id])
	return { "ok": true, "msg": "迎擊！遭遇戰開始" }

func _action_surrender_pre_encounter(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	var pre: Dictionary = state.player_pre_encounter
	if pre.is_empty():
		return { "ok": false, "msg": "無待處理預備遭遇戰" }
	var atk_id: int = int(pre.get("attacker_id", -1))
	var attacker: TeamData = state.teams.get(atk_id)
	if attacker == null:
		state.player_pre_encounter = {}
		return { "ok": false, "msg": "攻擊者不存在" }
	var resp: String = _diplomatic.handle_diplomacy_message(state, attacker, pt, "offer_surrender")
	state.player_pre_encounter = {}
	if resp == "accept":
		_transfer_surrender_assets(pt, attacker)
		_interaction.subjugate_team(state, atk_id, pt_id)
		print("[PlayerCmd] 玩家預備投降，Team%d 接受" % atk_id)
		return { "ok": true, "msg": "投降被接受，已被收編" }
	else:
		# 對方拒絕投降 → 強迫開戰
		_encounter.init_encounter(state, atk_id, pt_id, "normal")
		print("[PlayerCmd] 玩家預備投降遭拒，強制遭遇戰 Team%d vs Team%d" % [atk_id, pt_id])
		return { "ok": false, "msg": "對方拒絕投降，遭遇戰強制開始" }

func _action_set_faction_goal(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	if pt.faction_id == -1:
		return { "ok": false, "msg": "玩家不在勢力中" }
	var goal9: String = str(state.player_state.get("faction_goal_input", ""))
	if goal9 not in ["expand", "defend", "trade_net", ""]:
		return { "ok": false, "msg": "無效目標（expand/defend/trade_net/空字串清除）" }
	var f9: FactionData = state.factions.get(pt.faction_id)
	if f9 == null:
		return { "ok": false, "msg": "勢力不存在" }
	if f9.leader_team_id != pt_id:
		return { "ok": false, "msg": "只有 leader 可設定勢力目標" }
	f9.player_goal_override = goal9
	var msg9: String = "清除 override" if goal9.is_empty() else "勢力目標設為 %s" % goal9
	print("[PlayerCmd] set_faction_goal → %s" % goal9)
	return { "ok": true, "msg": msg9 }

func _action_order_faction_member(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	var member_team_id: int   = int(state.player_state.get("order_member_id", -1))
	var m_task: String        = str(state.player_state.get("member_task", ""))
	var member_team: TeamData = state.teams.get(member_team_id)
	if member_team == null:
		return { "ok": false, "msg": "目標成員不存在" }
	if m_task.is_empty():
		return { "ok": false, "msg": "未指定任務" }
	if pt.population < 2:
		return { "ok": false, "msg": "人數不足以派信使" }
	# 從 named_members 選一非 leader 的成員當信使
	var herald_leader_id: int = -1
	for pid in pt.named_members:
		if pid != pt.leader_id:
			herald_leader_id = pid
			break
	if herald_leader_id == -1:
		return { "ok": false, "msg": "無可用的信使人選（需至少一名非隊長的記名成員）" }
	var herald_id: int = _subteam.dispatch(
		state, pt_id, herald_leader_id, 1, TeamData.TASK_HERALD,
		member_team.tile_pos, member_team_id, m_task)
	if herald_id == -1:
		return { "ok": false, "msg": "派信使失敗" }
	state.player_pending_orders[str(member_team_id)] = {"task": m_task, "herald_id": herald_id}
	print("[PlayerCmd] order_faction_member Team%d → herald Team%d 傳達任務: %s" % [member_team_id, herald_id, m_task])
	return { "ok": true, "msg": "信使 Team%d 已出發至 Team%d" % [herald_id, member_team_id] }

func _action_gather_intel(state: WorldState, target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	var tgt_gi: TeamData = state.teams.get(target_id)
	if tgt_gi == null:
		return { "ok": false, "msg": "目標不存在" }
	var options: Array = InquirySystem.new().get_options(state, pt, tgt_gi)
	if options.is_empty():
		return { "ok": false, "msg": "無可打聽的情報" }
	return {
		"ok": true,
		"msg": "選擇要打聽的情報",
		"payload": { "inquiry_options": options, "npc_id": target_id }
	}

func _action_confirm_gather_intel(state: WorldState, _target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	var npc_id_gi: int     = int(state.player_state.get("gather_intel_npc_id", -1))
	var choice_gi: String  = str(state.player_state.get("gather_intel_choice", ""))
	var npc_gi: TeamData   = state.teams.get(npc_id_gi)
	if npc_gi == null or choice_gi.is_empty():
		return { "ok": false, "msg": "參數遺漏" }
	var result_gi: Dictionary = InquirySystem.new().resolve_inquiry(state, pt, npc_gi, choice_gi)
	print("[PlayerCmd] gather_intel choice=%s 結果筆數=%d" % [choice_gi, result_gi.size()])
	return { "ok": true, "msg": "情報獲取", "payload": result_gi }

func _action_clear_member_order(state: WorldState, _target_id: int, pt: TeamData, _pt_id: int) -> Dictionary:
	# player_state 需設定：order_member_id（目標 team）
	var member_id: int = int(state.player_state.get("order_member_id", -1))
	var mt: TeamData = state.teams.get(member_id)
	if mt == null or mt.faction_id != pt.faction_id:
		return { "ok": false, "msg": "目標不是同勢力成員" }
	mt.player_commanded_task = ""
	print("[PlayerCmd] clear_member_order Team%d" % member_id)
	return { "ok": true, "msg": "已清除 Team%d 的直接指令" % member_id }

# ── 投靠收留（食物軌整團併入）──────────────────────────────

# 投靠收留：扣 onboarding 食物（MEAL×對方人數，被吃掉=合法消耗）+ 整團併入（reuse merge_teams,守恆）
func _accept_join_request(state: WorldState, from_id: int) -> Dictionary:
	var pt: TeamData = _get_player_team(state)
	var from_team: TeamData = state.teams.get(from_id)
	if pt == null or from_team == null:
		return { "ok": false, "msg": "對象不存在" }
	if pt.tile_pos != from_team.tile_pos:
		return { "ok": false, "msg": "需同格才能收留" }
	# 預估可進人數（受 pop_cap 限,與 merge 部分合併同口徑）
	var leader = state.persons.get(pt.leader_id)
	var cmd: float = float(leader.skills.get("統領", 0.0)) if leader else 0.0
	var capacity: int = TeamData.pop_cap_from_leadership(cmd) - pt.population
	var will_join: int = mini(from_team.population, maxi(capacity, 0))
	if will_join <= 0:
		return { "ok": false, "msg": "隊伍已滿，無法收留" }
	var cost: float = JOIN_ONBOARD_MEAL * float(will_join)
	if float(pt.resources.get("food", 0)) < cost:
		return { "ok": false, "msg": "食物不足收留（需%.1f）" % cost }
	# 量測實際併入（撞 cap 沒進來的不餵、不報）→ 食物按 delta 扣,守恆與 msg 與實際一致
	var pop_before: int = pt.population
	SubteamSystem.new().merge_teams(state, pt.team_id, from_id)         # 整團併入：pop/named/tier/treasury 守恆
	var joined: int = pt.population - pop_before
	var actual_cost: float = JOIN_ONBOARD_MEAL * float(joined)
	ResourceBank.add(pt, "food", -actual_cost, "join_onboard_meal")   # 餵他們進來：吃掉,食物非守恆
	return { "ok": true, "msg": "收留 %d 人（食物 -%.1f）" % [joined, actual_cost],
		"payload": {"joined": joined, "food_cost": actual_cost} }

# ── 被動回應（NPC 強制非戰互動）────────────────────────────

# 查詢 forced_event 的回應選項
# "diplomacy" → ["accept", "refuse"]
# "extort"    → ["pay", "refuse"]
func get_forced_response_options(state: WorldState) -> Array[String]:
	var fe: Dictionary = state.player_forced_event
	var action: String = fe.get("action", "")
	match action:
		"diplomacy":
			# 動態：雙方獨立 + alliance/surrender → 加入/自立；否則 accept/refuse
			var from_team: TeamData = state.teams.get(fe.get("from_id", -1))
			var pp: PersonData = state.persons.get(state.player_id)
			var player_team: TeamData = state.teams.get(pp.team_id) if pp != null else null
			var both_independent: bool = from_team != null and player_team != null \
				and from_team.faction_id == -1 and player_team.faction_id == -1 \
				and fe.get("proposal", "") in ["alliance", "surrender"]
			if both_independent:
				return ["accept_join", "accept_lead", "refuse"] as Array[String]
			return ["accept", "refuse"] as Array[String]
		"extort":
			return ["pay", "refuse"] as Array[String]
		"join_request":
			return ["accept", "refuse"] as Array[String]
		"aid_request":
			return ["give", "refuse"] as Array[String]
		"choose_heir":
			# N-2: 重查活候選——只回「仍存在且仍在該隊 named_members」的 pid（消 raise→select 窗內死亡 stale）。
			# team 由 fe.team_id 取(權威)：choose_heir 時玩家 person 已死,_get_player_team 可能 null。
			var ids: Array[String] = []
			var pt: TeamData = state.teams.get(int(fe.get("team_id", -1)))
			for pid in fe.get("candidates", []):
				var ip: int = int(pid)
				if state.persons.has(ip) and pt != null and pt.named_members.has(ip):
					ids.append("heir_%d" % ip)
			return ids
	return [] as Array[String]

# 回應強制互動，清除 forced_event
# 返回 { "ok": bool, "msg": String }
func respond_to_forced(state: WorldState, response: String) -> Dictionary:
	var fe: Dictionary = state.player_forced_event
	if fe.is_empty():
		return { "ok": false, "msg": "無待處理強制事件" }
	var result: Dictionary
	match fe.get("action", ""):
		"diplomacy":
			match response:
				"accept", "accept_join":
					result = _accept_diplomacy(state,
						fe.get("from_id", -1), fe.get("proposal", "alliance"))
				"accept_lead":
					result = _accept_diplomacy_as_leader(state, fe.get("from_id", -1))
				"refuse":
					result = { "ok": true, "msg": "拒絕外交提案" }
				_:
					result = { "ok": false, "msg": "未知回應: %s" % response }
		"extort":
			if response == "pay":
				result = _pay_extortion(state, fe.get("from_id", -1))
			else:
				result = { "ok": true, "msg": "拒絕勒索" }
		"join_request":
			if response == "accept":
				result = _accept_join_request(state, fe.get("from_id", -1))
			else:
				result = { "ok": true, "msg": "婉拒收留" }
		"aid_request":
			if response == "give":
				state.player_state["aid_response"] = { "give_amount": AID_GIVE_DEFAULT }
			else:
				state.player_state["aid_response"] = { "refuse": true }
			result = _action_respond_aid_request(state, -1, _get_player_team(state), _get_player_team_id(state))
		"choose_heir":
			# N-2: 重查活候選——消 raise→select 窗內死亡 stale，避免永久 leaderless。
			var live: Array[String] = get_forced_response_options(state)
			if live.is_empty():
				# 全候選已死 → 終局（mirror leader-death 無繼承）；fall through 清 forced。
				# team 由 fe.team_id 取(權威),勿靠可能已失效的 _get_player_team。
				var dead_team: TeamData = state.teams.get(int(fe.get("team_id", -1)))
				if dead_team != null:
					EventSystem.new().handle_player_succession(state, dead_team)
				else:
					state.game_over = true
					state.game_over_reason = "玩家絕後（隊已滅,無繼承人）"
				result = { "ok": true, "msg": "無人可繼承,終局" }
			elif not live.has(response):
				# 單一 stale（選了已死候選）→ 不清 forced,讓玩家重選
				return { "ok": false, "msg": "繼承人已不可用,請重選" }
			else:
				var hid: int = int(response.trim_prefix("heir_"))
				state.player_state["heir_id"] = hid
				result = _action_choose_heir(state, -1, _get_player_team(state), _get_player_team_id(state))
		_:
			result = { "ok": false, "msg": "未知強制事件類型" }
	state.player_forced_event = {}
	state.player_forced_event_id = ""
	return result

func resolve_forced_response(state: WorldState, interaction_id: String, response_id: String) -> Dictionary:
	if state.player_forced_event.is_empty():
		return {"ok": false, "code": "forced_response_missing", "msg": "no active forced interaction"}
	if interaction_id != "" and interaction_id != state.player_forced_event_id:
		return {"ok": false, "code": "forced_response_missing", "msg": "interaction expired or wrong id"}
	var valid: Array[String] = get_forced_response_options(state)
	if not valid.has(response_id):
		return {"ok": false, "code": "forced_response_invalid", "msg": "invalid response_id: %s" % response_id}
	return respond_to_forced(state, response_id)

# ── 清除 pending ─────────────────────────────────────────────

# 玩家 team 格子改變時呼叫（SimRunner 負責呼叫）
# player_forced_event 不清除（NPC 外交/勒索不因移動取消）
func clear_pending_targets(state: WorldState) -> void:
	state.player_pending_targets.clear()
	state.player_state.erase("pending_trade_target")

# 玩家主動按下互動鍵（T）時呼叫：掃描同格 NPC，加入 pending_targets
# 讓 ignore 後仍可再次主動觸發互動
func refresh_colocation_targets(state: WorldState) -> void:
	var pt: TeamData = _get_player_team(state)
	if pt == null:
		return
	for other_id in state.teams:
		if other_id == pt.team_id:
			continue
		var other: TeamData = state.teams[other_id]
		if other.tile_pos != pt.tile_pos:
			continue
		if other.combat_target != -1:
			continue
		if not state.player_pending_targets.has(other_id):
			state.player_pending_targets.append(other_id)

func _action_respond_aid_request(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	var fe: Dictionary = state.player_forced_event
	if fe.is_empty() or fe.get("action", "") != "aid_request":
		return { "ok": false, "msg": "無待回應 aid event" }
	var beggar_id: int = int(fe.get("from_id", -1))
	var beggar: TeamData = state.teams.get(beggar_id)
	if beggar == null:
		state.player_forced_event = {}
		state.player_forced_event_id = ""
		return { "ok": false, "msg": "beggar 不存在" }
	var b_leader: PersonData = state.persons.get(beggar.leader_id)
	var response: Dictionary = state.player_state.get("aid_response", {})
	var msg_sys := SimMessageSystem.new()
	var npc_ai  := NpcAiSystem.new()
	if response.get("refuse", false):
		msg_sys.emit_message(state, "aid_refused",
			"玩家拒絕援助 Team%d" % beggar_id, pt,
			{ "origin": str(pt_id), "target": str(beggar_id) })
		beggar.update_reputation(pt_id, -0.1)
		if b_leader: npc_ai.write_memory(b_leader, "rejected_aid", pt_id,
			state.world.current_tick, 0.5)
	else:
		var amt: float = float(response.get("give_amount", 0.0))
		var actual: float = minf(amt, float(pt.resources.get("food", 0)))
		if actual <= 0.0:
			msg_sys.emit_message(state, "aid_refused",
				"玩家無餘糧援助 Team%d" % beggar_id, pt,
				{ "origin": str(pt_id), "target": str(beggar_id) })
		else:
			ResourceBank.add(pt, "food", -actual, "player_aid_out")
			ResourceBank.add(beggar, "food", actual, "player_aid_in")
			msg_sys.emit_message(state, "aid_given",
				"玩家援助 Team%d %.0f 食物" % [beggar_id, actual], pt,
				{ "origin": str(pt_id), "target": str(beggar_id),
				  "amount": "%.0f" % actual })
			beggar.update_reputation(pt_id, 0.15)
			if b_leader: npc_ai.write_memory(b_leader, "benefactor", pt_id,
				state.world.current_tick, clampf(actual / 50.0, 0.1, 1.0))
	state.clear_social_target(beggar)   # BEG 現走 social_target（非 combat_target）
	if beggar.previous_task != "" and beggar.previous_task != TeamData.TASK_IDLE:
		TaskArbiter.transition(beggar, beggar.previous_task, TaskArbiter.PRIO_DISPATCH)
	else:
		TaskArbiter.release(beggar)
	beggar.previous_task = ""
	state.player_forced_event = {}
	state.player_forced_event_id = ""
	state.player_state.erase("aid_response")
	return { "ok": true, "msg": "已處理" }

func _action_choose_heir(state: WorldState, _target: int, _pt: TeamData, _pt_id: int) -> Dictionary:
	var fe: Dictionary = state.player_forced_event
	if fe.get("action", "") != "choose_heir":
		return { "ok": false, "msg": "無待選繼承人事件" }
	var heir_id: int = int(state.player_state.get("heir_id", -1))
	if heir_id == -1:
		return { "ok": false, "msg": "未選繼承人" }
	if not fe.get("candidates", []).has(heir_id):
		return { "ok": false, "msg": "非合法候選" }
	var team_id: int = int(fe.get("team_id", -1))
	var team: TeamData = state.teams.get(team_id)
	var heir: PersonData = state.persons.get(heir_id)
	if team == null or heir == null:
		return { "ok": false, "msg": "team/person 失效" }
	team.leader_id = heir_id
	state.remove_member(team, heir_id, false)   # 繼任 leader：出 named 仍屬本隊
	heir.role = "leader"
	state.player_id = heir_id
	state.player_forced_event = {}
	state.player_forced_event_id = ""
	state.player_state.erase("heir_id")
	print("[Heir] %s 繼任玩家 (Team%d)" % [heir.person_name, team_id])
	return { "ok": true, "msg": "%s 繼任" % heir.person_name }

func _action_invite_settle(state: WorldState, target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	var tgt: TeamData = state.teams.get(target_id)
	if tgt == null: return { "ok": false, "msg": "目標不存在" }
	var pos_arr: Array = state.player_state.get("settle_pos", [-1, -1])
	var target_pos: Vector2i = Vector2i(int(pos_arr[0]), int(pos_arr[1]))
	if target_pos == Vector2i(-1, -1):
		target_pos = pt.tile_pos   # 互動選單路徑未設 settle_pos → 預設玩家腳下 outpost（emit gate 已保證站在自家 outpost）
	var tile: HexTileData = state.world.tiles.get(target_pos.x * 1000 + target_pos.y)
	if tile == null or tile.outpost_level == 0 or tile.outpost_owner != pt_id:
		return { "ok": false, "msg": "目標非自家 outpost" }
	# 評估接受
	var resp: String = _diplomatic.handle_diplomacy_message(state, tgt, pt, "invite_settle")
	if resp == "accept":
		_interaction._execute_settlement(state, target_id, target_pos, pt.faction_id)
		return { "ok": true, "msg": "Team%d 接受邀請" % target_id }
	return { "ok": true, "msg": "Team%d 拒絕邀請" % target_id, "accepted": false }

func _action_beg(state: WorldState, target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	var tgt: TeamData = state.teams.get(target_id)
	if tgt == null: return { "ok": false, "msg": "目標不存在" }
	if pt.tile_pos != tgt.tile_pos: return { "ok": false, "msg": "需同格才能乞討" }
	# 玩家當乞丐:reuse _resolve_aid_request（NPC 依 honor/rep/greed 自決;給糧守恆轉移;重複乞討 annoyance 自限）
	var r: Dictionary = _interaction._resolve_aid_request(state, pt_id, target_id)
	if r.get("accepted", false):
		return { "ok": true, "msg": "Team%d 施捨食物 %.0f" % [target_id, float(r.get("amount", 0))] }
	return { "ok": true, "msg": "Team%d 不予施捨（%s）" % [target_id, r.get("msg", "拒絕")] }

# ── 內部 helper ──────────────────────────────────────────────

func _get_player_team(state: WorldState) -> TeamData:
	var p: PersonData = state.persons.get(state.player_id)
	if p == null:
		return null
	return state.teams.get(p.team_id)

func _get_player_team_id(state: WorldState) -> int:
	return state.get_player_team_id()

func _can_trade(state: WorldState, pt: TeamData, tgt: TeamData) -> bool:
	# 雙方任一有 coin 即可嘗試貿易（細節由 resolve_trade_direct 判定）
	return float(pt.resources.get("coin", 0)) > 0.0 \
		or float(tgt.resources.get("coin", 0)) > 0.0

func _accept_diplomacy(state: WorldState, from_id: int, proposal: String) -> Dictionary:
	var from_team: TeamData = state.teams.get(from_id)
	var pt: TeamData = _get_player_team(state)
	if from_team == null or pt == null:
		return { "ok": false, "msg": "隊伍不存在" }
	match proposal:
		"alliance", "surrender":
			# 雙方皆獨立時 _form_alliance 無效，需先建立勢力
			if from_team.faction_id == -1 and pt.faction_id == -1:
				state.create_faction(from_id)   # NPC 為領袖
			_diplomatic._form_alliance(state, from_team, pt)
			return { "ok": true, "msg": "接受同盟，加入勢力%d" % from_team.faction_id }
		"tribute", "demand_tribute":   # _send_diplomacy_message 寫 "demand_tribute"（原只認 "tribute" → 未知提案類型 bug）
			return _pay_extortion(state, from_id)
	return { "ok": false, "msg": "未知提案類型：%s" % proposal }

func _accept_diplomacy_as_leader(state: WorldState, from_id: int) -> Dictionary:
	var from_team: TeamData = state.teams.get(from_id)
	var pt: TeamData = _get_player_team(state)
	var pt_id: int   = _get_player_team_id(state)
	if from_team == null or pt == null:
		return { "ok": false, "msg": "隊伍不存在" }
	if pt.faction_id == -1:
		state.create_faction(pt_id)
	_diplomatic._form_alliance(state, pt, from_team)
	return { "ok": true, "msg": "自立後接納 Team%d，勢力%d" % [from_id, pt.faction_id] }

func _pay_extortion(state: WorldState, from_id: int) -> Dictionary:
	# 轉移資源給 from_id（金額由 _resolve_extortion 計算）
	var pt_id: int = _get_player_team_id(state)
	if pt_id == -1:
		return { "ok": false, "msg": "找不到玩家 team" }
	_interaction.resolve_extortion_direct(state, from_id, pt_id)
	return { "ok": true, "msg": "支付勒索" }

func _recruit_anon_internal(state: WorldState, pt: TeamData,
		tgt: TeamData, target_id: int) -> Dictionary:
	var pt_id: int  = _get_player_team_id(state)
	var coin: float = float(pt.resources.get("coin", 0))
	if coin < RECRUIT_COST_ANON:
		state.player_pending_targets.erase(target_id)
		return { "ok": false, "msg": "金幣不足（需%d）" % int(RECRUIT_COST_ANON) }
	if tgt.population <= 1:
		state.player_pending_targets.erase(target_id)
		return { "ok": false, "msg": "目標人口不足" }
	ResourceBank.set_amt(pt, "coin", coin - RECRUIT_COST_ANON, "recruit_anon_pay")
	# 守恆：買人付給對方，coin 不蒸發
	ResourceBank.add(tgt, "coin", RECRUIT_COST_ANON, "recruit_anon_receive")
	# 被招募 anon 帶走在原團的 treasury 份額
	var tgt_named: int = tgt.named_members.size() + (1 if tgt.leader_id != -1 else 0)
	var tgt_anon: int = maxi(tgt.population - tgt_named, 1)
	var share: float = minf(tgt.anon_treasury / float(tgt_anon), tgt.anon_treasury)
	AnonTreasuryBank.transfer(tgt, pt, share, "recruit_share")
	AnonTierSystem.transfer_proportional(tgt, pt, 1)
	state.player_pending_targets.erase(target_id)
	print("[Recruit] 匿名 Team%d←%d, 花%.0f coin, 新人口=%d" % [
		pt_id, target_id, RECRUIT_COST_ANON, pt.population])
	return { "ok": true, "msg": "招募成功（花費%d coin，新人口%d）" % [
		int(RECRUIT_COST_ANON), pt.population],
		"payload": {"has_willing_named": false, "refresh_required": true} }

# ── 查詢 API（Phase 1 新增） ─────────────────────────

func get_player_team(state: WorldState) -> TeamData:
	var p: PersonData = state.persons.get(state.player_id)
	if p == null: return null
	return state.teams.get(p.team_id)

func get_player_person(state: WorldState) -> PersonData:
	return state.persons.get(state.player_id)

func inspect_team(state: WorldState, team_id: int) -> Dictionary:
	var t: TeamData = state.teams.get(team_id)
	if t == null: return {}
	var leader: PersonData = state.persons.get(t.leader_id)
	var members: Array = []
	for pid in t.named_members:
		var p: PersonData = state.persons.get(pid)
		if p:
			members.append({
				"id": p.id, "name": p.person_name, "role": p.role,
				"loyalty": p.loyalty, "fatigue": p.stress
			})
	var leader_info: Dictionary = {}
	if leader:
		leader_info = { "id": leader.id, "name": leader.person_name }
	return {
		"team_id": t.team_id, "tile_pos": t.tile_pos, "population": t.population,
		"fatigue": t.fatigue, "current_task": t.current_task,
		"faction_id": t.faction_id, "tags": t.tags,
		"leader": leader_info, "named_members": members,
		"resources": t.resources
	}

func inspect_member(state: WorldState, person_id: int) -> Dictionary:
	var p: PersonData = state.persons.get(person_id)
	if p == null: return {}
	return {
		"id": p.id, "name": p.person_name, "role": p.role,
		"team_id": p.team_id, "age": p.age,
		"loyalty": p.loyalty, "stress": p.stress, "fear": p.fear,
		"values": p.values, "attributes": p.attributes, "skills": p.skills,
		"equipment": p.equipment
	}

func move_to(state: WorldState, target_pos: Vector2i) -> Dictionary:
	var pt: TeamData = get_player_team(state)
	if pt == null:
		return { "ok": false, "msg": "玩家 team 不存在" }
	var key: int = target_pos.x * 1000 + target_pos.y
	if not state.world.tiles.has(key):
		return { "ok": false, "msg": "目標格不在地圖內" }
	if pt.tile_pos == target_pos:
		return { "ok": true, "msg": "已在目標格" }
	pt.move_target = target_pos
	return { "ok": true, "msg": "設定目標 (%d,%d)" % [target_pos.x, target_pos.y] }

func cancel_move(state: WorldState) -> Dictionary:
	var pt: TeamData = get_player_team(state)
	if pt == null:
		return { "ok": false, "msg": "玩家 team 不存在" }
	pt.move_target = Vector2i(-1, -1)
	state.player_state.erase("pending_trade_target")
	return { "ok": true, "msg": "取消移動" }

func establish_faction(state: WorldState) -> Dictionary:
	var pt: TeamData = _get_player_team(state)
	var pt_id: int   = _get_player_team_id(state)
	if pt == null:
		return { "ok": false, "code": "no_controlled_team",
				 "message": "找不到玩家隊伍", "payload": {} }
	if pt.faction_id != -1:
		return { "ok": false, "code": "action_unavailable",
				 "message": "已屬勢力%d" % pt.faction_id, "payload": {} }
	state.create_faction(pt_id)
	print("[PlayerCmd] 玩家建立勢力%d" % pt.faction_id)
	return { "ok": true, "code": "ok",
			 "message": "建立勢力%d" % pt.faction_id,
			 "payload": {"action_id": "establish_faction", "refresh_required": true} }

# execute_action variant that passes full target dict (for "member" kind actions)
func execute_action_with_target(state: WorldState, action: String, target: Dictionary) -> Dictionary:
	var pt: TeamData = _get_player_team(state)
	var pt_id: int   = _get_player_team_id(state)
	if pt == null:
		return { "ok": false, "msg": "找不到玩家 team" }
	match action:
		"recruit_named":
			var from_team_id: int = target.get("team_id", -1)
			var person_id: int    = target.get("member_id", -1)
			return _recruit_named_internal(state, pt, from_team_id, person_id)
		"set_member_salary":
			return _action_set_member_salary(state, target, pt)
		"equip_member":
			return _action_equip_member(state, target, pt)
		"unequip_member":
			return _action_unequip_member(state, target, pt)
	return { "ok": false, "msg": "不支援 member 目標的行動: %s" % action }

# S9：玩家調自隊名成員薪資。amount 經 player_state["salary_input"] 暫存。
func _action_set_member_salary(state: WorldState, target: Dictionary, pt: TeamData) -> Dictionary:
	var mid: int = int(target.get("member_id", -1))
	var m: PersonData = state.persons.get(mid)
	if m == null or not pt.named_members.has(mid):
		return { "ok": false, "msg": "非自隊成員" }
	var amt: float = float(state.player_state.get("salary_input", m.salary))
	m.salary = maxf(amt, 0.0)
	print("[PlayerCmd] set_member_salary P%d → %.0f" % [mid, m.salary])
	return { "ok": true, "msg": "%s 薪資設為 %.0f" % [m.person_name, m.salary] }

# U13b：從自隊武器池裝備名成員 slot（扣 team 資源；原槽位裝備還回池）。
func _action_equip_member(state: WorldState, target: Dictionary, pt: TeamData) -> Dictionary:
	var mid: int    = int(target.get("member_id", -1))
	var slot: String  = String(target.get("slot_id", ""))
	var grade: String = String(target.get("item_grade", ""))
	var m: PersonData = state.persons.get(mid)
	if m == null or not pt.named_members.has(mid):
		return { "ok": false, "msg": "非自隊成員" }
	if slot == "" or grade == "" or int(pt.resources.get(grade, 0)) <= 0:
		return { "ok": false, "msg": "無此裝備" }
	# 先卸原槽（pool 裝備還回池）
	var cur: Dictionary = m.equipment.get(slot, {})
	if cur.get("type", "none") == "pool" and cur.get("grade", "") != "":
		ResourceBank.add(pt, cur["grade"], 1, "equip_swap_return")
	ResourceBank.add(pt, grade, -1, "equip_swap_take")
	m.equipment[slot] = { "type": "pool", "grade": grade }
	if ItemAttributes.is_2h(grade):
		m.equipment["hand_2"] = { "type": "2h_ref" }
	print("[PlayerCmd] equip_member P%d slot=%s grade=%s" % [mid, slot, grade])
	return { "ok": true, "msg": "%s 裝備 %s" % [m.person_name, grade] }

# U13b：卸下名成員 slot 裝備，還回 team 武器池。
func _action_unequip_member(state: WorldState, target: Dictionary, pt: TeamData) -> Dictionary:
	var mid: int   = int(target.get("member_id", -1))
	var slot: String = String(target.get("slot_id", ""))
	var m: PersonData = state.persons.get(mid)
	if m == null or not pt.named_members.has(mid):
		return { "ok": false, "msg": "非自隊成員" }
	var cur: Dictionary = m.equipment.get(slot, {})
	if cur.get("type", "none") == "pool" and cur.get("grade", "") != "":
		pt.resources[cur["grade"]] = int(pt.resources.get(cur["grade"], 0)) + 1
		if ItemAttributes.is_2h(cur["grade"]):
			m.equipment["hand_2"] = { "type": "none", "grade": "" }
	m.equipment[slot] = { "type": "none", "grade": "" }
	print("[PlayerCmd] unequip_member P%d slot=%s" % [mid, slot])
	return { "ok": true, "msg": "%s 卸下 %s" % [m.person_name, slot] }

func _recruit_named_internal(state: WorldState, pt: TeamData,
		from_team_id: int, person_id: int) -> Dictionary:
	var tgt4: TeamData    = state.teams.get(from_team_id)
	var p: PersonData     = state.persons.get(person_id)
	if tgt4 == null or p == null or p.team_id != from_team_id:
		return { "ok": false, "msg": "成員不存在或已離隊" }
	var coin: float = float(pt.resources.get("coin", 0))
	if coin < RECRUIT_COST_NAMED:
		return { "ok": false, "msg": "金幣不足（named 需%d）" % int(RECRUIT_COST_NAMED) }
	# 轉移
	var pt_id: int = _get_player_team_id(state)
	ResourceBank.set_amt(pt, "coin", coin - RECRUIT_COST_NAMED, "recruit_named_pay")
	# 守恆：買人付給對方，coin 不蒸發
	ResourceBank.add(tgt4, "coin", RECRUIT_COST_NAMED, "recruit_named_receive")
	state.remove_member(tgt4, person_id, false)   # 出原隊 roster（team_id 由 add 設 pt）
	LoyaltyBank.set_baseline(p, 0.5, "recruit")
	state.add_member(pt, person_id)               # 入玩家隊 + team_id=pt

	state.player_pending_targets.erase(from_team_id)
	print("[Recruit] Named P%d (%s) Team%d→%d" % [
		person_id, p.person_name, from_team_id, pt_id])
	return { "ok": true, "msg": "招募 %s 成功（花費%d coin）" % [
		p.person_name, int(RECRUIT_COST_NAMED)],
		"payload": {"refresh_required": true} }
