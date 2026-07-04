# scripts/simulation/diplomatic_ai_system.gd
class_name DiplomaticAiSystem

const BETRAY_CHECK_INTERVAL: int = 50 * WorldState.TICKS_PER_HOUR  # 每 50 小時
const REJECT_COOLDOWN: int = WorldState.TICKS_PER_DAY * 7   # 被拒後同對象冷卻 7 天
# G3-E Task3：背叛 belief 驅動化常數（TEST VALUE）
const BETRAY_ADVANTAGE_GAIN: float = 0.6   # belief「盟弱我利」→ 背叛動機加成
const BETRAY_CONF_MIN: float = 0.5         # belief 篤定度下限：不憑不確定情報背叛（慎重）
const BETRAY_DRIVE_MIN: float = 0.65       # 背叛動機門檻（承接舊 score>0.65 語意）
const BETRAY_DRIVE_HARD: float = 0.9       # 動機極高 → 幾乎必觸發（deterministic）
const BETRAY_MARGIN_CHANCE: float = 0.3    # MIN..HARD 之間 stochastic tie-break 上限（非主驅）
# 誘因結盟（gift）常數（TEST VALUE，seeded 校）
const ALLIANCE_ACCEPT_THRESHOLD: float = 0.55  # 結盟 accept 門檻（原硬編碼 0.55，提出成常數便於 seeded 微校）
const GIFT_NEED_FOOD_PER_POP: float = 10.0     # 「滿禮」基準：目標每人約 10 糧的禮視為足量（禮值/需求縮放分母）
const GIFT_TERM_MAX: float = 0.4               # 禮對 diplomacy score 最大貢獻（雪中送炭可推過門檻）
# F-I2 統一貢金/勒索屈服公式權重（TEST VALUE，seeded 校）。單一 owner：三 caller
#（LOOT 同格勒索 / 外交 demand_tribute / 玩家直接勒索）全走 tribute_accept，
# 情境差異=輸入權重（threat），非分叉公式。
const TRIBUTE_W_POWER: float = 0.4      # believed 實力比（沿舊 demand_tribute 權重）
const TRIBUTE_W_CAUTION: float = 0.3
const TRIBUTE_W_HONOR: float = 0.3      # 義氣抗屈服
const TRIBUTE_W_SURVIVAL: float = 0.2   # 求生欲傾向屈服（沿舊 _should_pay_tribute）
const TRIBUTE_W_FEAR: float = 0.2       # 恐懼傾向屈服（沿舊 resolve_extortion_direct）
const TRIBUTE_W_THREAT: float = 0.2     # 兵臨城下壓力（caller 輸入：同格=aggressor readiness、遠程外交=0）
const TRIBUTE_W_FEUD: float = 0.3       # F-I5 接線：血仇不屈
const TRIBUTE_W_GRATITUDE: float = 0.2  # F-I5 接線：恩義軟化
const TRIBUTE_ACCEPT_THRESHOLD: float = 0.1
const TRIBUTE_POWER_R_CAP: float = 3.0

# T-02：從 team_intel 取人口估算；無資料 fallback = self_pop（謹慎：視對方與己等強）
func _get_pop_est(state: WorldState, obs_id: int, tgt_id: int, fallback: int) -> int:
	return BeliefSystem.best_estimate(state, obs_id, tgt_id).get("population_est", fallback)

# F-I2 統一屈服公式（C 類：舊 interaction._should_pay_tribute / 本檔 demand_tribute 內嵌分 /
# interaction.resolve_extortion_direct 內嵌分全退役）。
# F-I7：aggressor 實力讀 believed pop（無估 fallback=self pop=視為等強，保守不偷看真值）。
# F-I5：consult feud/gratitude typed 邊當權重項。
static func tribute_accept(state: WorldState, defender: TeamData, aggressor: TeamData,
		threat: float) -> bool:
	if defender.current_task == TeamData.TASK_FLEE:
		return true
	var leader: PersonData = state.persons.get(defender.leader_id) if defender.leader_id != -1 else null
	if leader == null:
		return false
	var caution: float  = float(leader.values.get("慎重", 0.5))
	var honor: float    = float(leader.values.get("義氣", 0.5))
	var survival: float = float(leader.values.get("求生欲", 0.5))
	var agg_pop_est: int = BeliefSystem.best_estimate(state, defender.team_id, aggressor.team_id) \
		.get("population_est", defender.population)
	var power_r: float = clampf(float(agg_pop_est) / maxf(float(defender.population), 1.0),
		0.0, TRIBUTE_POWER_R_CAP)
	var score: float = (power_r - 1.0) * TRIBUTE_W_POWER \
		+ caution * TRIBUTE_W_CAUTION - honor * TRIBUTE_W_HONOR \
		+ survival * TRIBUTE_W_SURVIVAL + leader.fear * TRIBUTE_W_FEAR \
		+ clampf(threat, 0.0, 1.0) * TRIBUTE_W_THREAT
	if aggressor.leader_id != -1:
		score -= _edge_intensity_to(leader.relation_edges, "feud", aggressor.leader_id) * TRIBUTE_W_FEUD
		score += _edge_intensity_to(leader.relation_edges, "gratitude", aggressor.leader_id) * TRIBUTE_W_GRATITUDE
	return score > TRIBUTE_ACCEPT_THRESHOLD

# typed 邊 reader（指定 type+target 最強 intensity；無邊 0）。加 reader 不改 RelationGraph 核心。
static func _edge_intensity_to(edges: Array, type: String, target: int) -> float:
	var best: float = 0.0
	for e in RelationGraph.edges_of_type(edges, type):
		if int(e.get("target", -1)) == target:
			best = maxf(best, float(e.get("intensity", 0.0)))
	return best

func _calc_diplomacy_score(state: WorldState,
		self_team: TeamData, other_team: TeamData, gift: Dictionary = {}) -> float:
	var self_leader: PersonData = state.persons.get(self_team.leader_id)
	if self_leader == null: return 0.0

	var food_ratio: float = float(self_team.resources.get("food", 0)) / \
		maxf(self_team.population * 5.0, 1.0)
	var resource_need: float = clampf(1.0 - food_ratio, 0.0, 1.0)

	# T-02：用估算人口，fallback = self.population（謹慎估算）
	var other_pop_est: int = _get_pop_est(state, self_team.team_id, other_team.team_id, self_team.population)
	var power_gap: float = clampf(
		float(other_pop_est - self_team.population) / \
		maxf(self_team.population, 1.0), -1.0, 1.0)

	var rep: float = float(self_team.known_reputations.get(other_team.team_id, 0.5))

	var other_leader_id: int = other_team.leader_id
	var relation: float = float(self_leader.relations.get(other_leader_id, 0.0))

	var self_peace: float = self_leader.values.get("義氣", 0.5) * \
		self_leader.values.get("信義", 0.5)

	# 誘因結盟：gift term（禮值/目標需求 縮放——目標缺糧糧禮權重高=雪中送炭，連續信號）。
	# 白嘴（gift 空）→ term=0 → score 不變（仍難）；缺糧目標收足量糧禮 → term 推過門檻。
	var gift_term: float = 0.0
	var gift_food: float = float(gift.get("food", 0))
	if gift_food > 0.0:
		var need_scale: float = maxf(float(self_team.population) * GIFT_NEED_FOOD_PER_POP, 1.0)
		var gift_ratio: float = clampf(gift_food / need_scale, 0.0, 1.0)
		gift_term = gift_ratio * (0.4 + 0.6 * resource_need) * GIFT_TERM_MAX

	return clampf(
		resource_need * 0.3 +
		power_gap     * 0.2 +
		rep           * 0.2 +
		relation      * 0.15 +
		self_peace    * 0.15 +
		gift_term,
		0.0, 1.0)

func try_proactive_diplomacy(state: WorldState, self_team: TeamData) -> void:
	var self_leader: PersonData = state.persons.get(self_team.leader_id)
	if self_leader == null: return
	if randf() > self_leader.values.get("慎重", 0.5) * 0.5 + 0.2: return

	for other_id in state.team_discovered.get(self_team.team_id, []):
		var other: TeamData = state.teams.get(other_id)
		if other == null: continue
		if other.faction_id == self_team.faction_id and self_team.faction_id != -1: continue
		# invariant：外交/徵收需同格（嚴禁非同格互動）→ 隔空求貢/提案違規。對齊 process_on_move 同格外交。
		if other.tile_pos != self_team.tile_pos: continue
		# 被拒冷卻中 → 換下一個對象（防同對象連發 spam）
		if state.world.current_tick < int(self_team.diplomacy_reject_cooldown.get(other.team_id, 0)):
			continue
		var score: float = _calc_diplomacy_score(state, self_team, other)

		if score > 0.6 and self_team.faction_id != -1:
			_send_diplomacy_message(state, self_team, other, "propose_alliance")
			return
		elif score > 0.4:
			_send_diplomacy_message(state, self_team, other, "propose_trade")
			return

		# G3-E leak 1a：power_gap 讀 belief 非 god-view 真值（無估→fallback self_pop=保守等強→gap0→不求貢）
		var _other_pop_est: int = _get_pop_est(state, self_team.team_id, other.team_id, self_team.population)
		var power_gap: float = float(_other_pop_est - self_team.population) / \
			maxf(self_team.population, 1.0)
		if power_gap > 0.5 and self_leader.values.get("貪婪", 0.5) > 0.6:
			# G3d-1 風險 gate：求貢=敵對行動(基於「對方弱可欺」)，不確定且慎重→按兵；結盟/求和不 gate
			var _dcaution: float = float(self_leader.values.get("慎重", 0.5))
			if not BeliefSystem.confident_enough(state, self_team.team_id, other.team_id, _dcaution):
				continue
			_send_diplomacy_message(state, self_team, other, "demand_tribute")
			return

func _send_diplomacy_message(state: WorldState, sender: TeamData,
		target: TeamData, action: String) -> void:
	# G-01：偵測玩家目標 → 寫入 forced_event，不直接解算
	if state.player_id != -1:
		var player_person: PersonData = state.persons.get(state.player_id)
		if player_person != null and target.team_id == player_person.team_id:
			if state.player_forced_event.is_empty():
				state.player_forced_event = {
					"action": "diplomacy",
					"from_id": sender.team_id,
					"proposal": action,
				}
				state.player_forced_event_id = str(randi())
				# 設冷卻：玩家拒/超時後不立刻重發（原玩家路徑漏設 → 隔空 spam）
				sender.diplomacy_reject_cooldown[target.team_id] = \
					state.world.current_tick + REJECT_COOLDOWN
				print("[Diplomacy] Team%d 向玩家發起 %s → 寫入 forced_event" % [sender.team_id, action])
			return
	print("[Diplomacy] Team%d → Team%d: %s" % [sender.team_id, target.team_id, action])
	var response: String = handle_diplomacy_message(state, target, sender, action)
	print("[Diplomacy] Team%d 回應: %s" % [target.team_id, response])
	if response == "reject" or response == "refuse":
		sender.diplomacy_reject_cooldown[target.team_id] = \
			state.world.current_tick + REJECT_COOLDOWN
	# Tribute refusal consequence: write memory + reputation penalty
	if action == "demand_tribute" and response == "refuse":
		var sender_leader: PersonData = state.persons.get(sender.leader_id) if sender.leader_id >= 0 else null
		if sender_leader != null:
			# F-I6：走 write_memory 統一 schema（type 欄 → type-scan counter 可見）。0.2 TEST VALUE
			NpcAiSystem.new().write_memory(sender_leader, "tribute_refused",
				target.leader_id, state.world.current_tick, 0.2)
		sender.update_reputation(target.team_id, -0.1)
		target.update_reputation(sender.team_id, -0.05)
		print("[Diplomacy] Team%d 拒絕進貢 → demander memory tribute_refused, rep -0.1/-0.05" % target.team_id)

func handle_diplomacy_message(state: WorldState, self_team: TeamData,
		sender_team: TeamData, action: String, gift: Dictionary = {}) -> String:
	var score: float = _calc_diplomacy_score(state, self_team, sender_team, gift)
	match action:
		"propose_alliance":
			if score > ALLIANCE_ACCEPT_THRESHOLD:
				_form_alliance(state, self_team, sender_team)
				return "accept"
			return "reject"
		"propose_trade":
			if score > 0.4:
				self_team.update_reputation(sender_team.team_id, 0.05)
				sender_team.update_reputation(self_team.team_id, 0.05)
				return "accept"
			return "reject"
		"demand_tribute":
			# F-I2 統一公式（遠程外交無兵臨壓力 threat=0）
			return "accept" if tribute_accept(state, self_team, sender_team, 0.0) else "refuse"
		"offer_surrender":
			if score > 0.3:
				return "accept"
			return "reject"
		"invite_settle":
			var t_leader = state.persons.get(self_team.leader_id)
			if t_leader == null: return "reject"
			var rep: float = float(self_team.known_reputations.get(sender_team.team_id, 0.5))
			var ambition: float = float(t_leader.values.get("野心", 0.5))
			var survival: float = float(t_leader.values.get("求生欲", 0.5))
			var hungry: float = 0.3 if float(self_team.resources.get("food", 0)) < self_team.population * 7.0 else 0.0
			var accept_score: float = survival + clampf(rep - 0.5, -0.5, 0.5) + hungry - ambition * 0.4
			return "accept" if accept_score > 0.5 else "reject"
	return "reject"

func _form_alliance(state: WorldState,
		team_a: TeamData, team_b: TeamData) -> void:
	# team_a = 收提案方, team_b = 發起方（handle_diplomacy_message 呼叫序）
	if team_a.faction_id != -1:
		state.set_team_faction(team_b, team_a.faction_id)   # team_b 入 team_a faction（雙向同步）
		state.snapshot_faction_member(team_b.team_id, state.world.current_tick)
	elif team_b.faction_id != -1:
		state.set_team_faction(team_a, team_b.faction_id)   # team_a 入 team_b faction（雙向同步）
		state.snapshot_faction_member(team_a.team_id, state.world.current_tick)
	else:
		# 兩獨立 → create_faction（強者 leader，建國）。F-I1 搬家：以 population 取代 god-view team_strength
		#（建國=兩隊同意的結構性合意動作，非敵對評估；沿 _try_diplomacy 原「強者為 leader」語意）。
		var strong_id: int = team_a.team_id if team_a.population >= team_b.population else team_b.team_id
		var weak_id: int = team_b.team_id if strong_id == team_a.team_id else team_a.team_id
		var fid: int = state.create_faction(strong_id)
		if fid == -1:
			return
		state.set_team_faction(state.teams[weak_id], fid)   # 弱者入新 faction（雙向同步）
		state.snapshot_faction_member(strong_id, state.world.current_tick)
		state.snapshot_faction_member(weak_id, state.world.current_tick)
		print("[Diplomacy] Team%d + Team%d 建國 → 勢力%d（leader=Team%d）" % [
			team_a.team_id, team_b.team_id, fid, strong_id])
	team_a.update_reputation(team_b.team_id, 0.2)
	team_b.update_reputation(team_a.team_id, 0.2)
	print("[Diplomacy] Team%d 與 Team%d 結盟" % [team_a.team_id, team_b.team_id])
	# D C1: 若 team_b 是居民團 → 投降勸服，outpost 轉給 team_a
	if team_b.tags.has(TeamData.TAG_PRODUCE):
		var tile: HexTileData = state.world.tiles.get(team_b.tile_pos.x * 1000 + team_b.tile_pos.y)
		if tile != null and tile.outpost_level > 0 and tile.outpost_owner != team_a.team_id:
			var old_owner: int = tile.outpost_owner
			OutpostOwnerBank.set_owner(tile, team_a.team_id, "alliance")
			print("[Surrender] 居民團 Team%d 投降，outpost (%d,%d) %d→%d" % [
				team_b.team_id, team_b.tile_pos.x, team_b.tile_pos.y, old_owner, team_a.team_id])

# G3-E Task3+1e：背叛評估純函數（無 RNG，供決策與測試）。
# driver = 人格(野心/背信/薄義) + belief power advantage（盟弱我利→動機↑）；
# ally 實力估：優先 faction snapshot（同 faction 協調豁免=共享情報），次 belief est，
# 皆無 → 最保守（視盟不明→不背叛）。confidence = 1−belief uncertainty（不憑不確定情報背叛）。
func betrayal_assessment(state: WorldState, self_team: TeamData,
		ally_team: TeamData) -> Dictionary:
	var self_leader: PersonData = state.persons.get(self_team.leader_id)
	if self_leader == null:
		return { "would_betray": false, "advantage": 0.0, "confidence": 0.0, "driver": 0.0, "power_gap": 0.0 }
	var personality: float = \
		self_leader.values.get("野心", 0.5) * 0.4 + \
		(1.0 - self_leader.values.get("信義", 0.5)) * 0.4 + \
		(1.0 - self_leader.values.get("義氣", 0.5)) * 0.2
	# ally 實力估（非 god-view 真值）
	var ally_pop_est := -1.0
	if self_team.faction_id != -1:
		var f: FactionData = state.factions.get(self_team.faction_id)
		if f and f.known_member_states.has(ally_team.team_id):
			ally_pop_est = float(f.known_member_states[ally_team.team_id].get("population", -1.0))
	var has_bel: bool = BeliefSystem.has_belief(state, self_team.team_id, ally_team.team_id)
	if ally_pop_est < 0.0 and has_bel:
		ally_pop_est = float(BeliefSystem.best_estimate(state, self_team.team_id, ally_team.team_id).get("population_est", -1.0))
	if ally_pop_est < 0.0:
		# 無 snapshot 且無 belief → 最保守：不背叛
		return { "would_betray": false, "advantage": 0.0, "confidence": 0.0, "driver": personality, "power_gap": 0.0 }
	var power_gap: float = (ally_pop_est - float(self_team.population)) / \
		maxf(float(self_team.population), 1.0)
	var advantage: float = clampf(-power_gap, 0.0, 1.0)   # 盟弱我強 → advantage>0（可解釋 driver）
	var driver: float = personality + advantage * BETRAY_ADVANTAGE_GAIN
	if power_gap > 0.5: driver -= 0.3   # 盟強 → 抑制
	# 篤定度：belief 有情報用 uncertainty；純 snapshot（同 faction 共享）視為篤定
	var confidence := 1.0
	if has_bel:
		confidence = 1.0 - BeliefSystem.uncertainty(state, self_team.team_id, ally_team.team_id)
	var would: bool = driver >= BETRAY_DRIVE_MIN and confidence >= BETRAY_CONF_MIN
	return { "would_betray": would, "advantage": advantage, "confidence": confidence,
		"driver": driver, "power_gap": power_gap }

func consider_betrayal(state: WorldState, self_team: TeamData,
		ally_team: TeamData) -> bool:
	var a: Dictionary = betrayal_assessment(state, self_team, ally_team)
	if not a["would_betray"]: return false
	# driver 為主驅；接近門檻保留小 stochastic tie-break（非主驅，去純 RNG）
	var driver: float = float(a["driver"])
	var trigger: bool = driver >= BETRAY_DRIVE_HARD
	if not trigger:
		var margin: float = clampf((driver - BETRAY_DRIVE_MIN) / \
			maxf(BETRAY_DRIVE_HARD - BETRAY_DRIVE_MIN, 0.001), 0.0, 1.0)
		trigger = randf() < margin * BETRAY_MARGIN_CHANCE
	if not trigger: return false
	_execute_betrayal(state, self_team, ally_team)
	return true

func _execute_betrayal(state: WorldState, self_team: TeamData,
		ally_team: TeamData) -> void:
	state.clear_team_faction(self_team)   # 背叛離團（雙向同步）
	ally_team.update_reputation(self_team.team_id, -0.5)
	var ally_leader: PersonData = state.persons.get(ally_team.leader_id)
	if ally_leader:
		ally_leader.memory.append({
			"type": "betrayal", "subject_id": self_team.leader_id,
			"tick": state.world.current_tick, "intensity": 0.8
		})
	# G-04：勢力成員背叛通知
	if state.player_id != -1:
		var player_person: PersonData = state.persons.get(state.player_id)
		if player_person != null:
			var player_team: TeamData = state.teams.get(player_person.team_id)
			if player_team != null and player_team.faction_id != -1 and \
					player_team.faction_id == ally_team.faction_id:
				state.player_alerts.append({
					"type": "faction_member_betrayed",
					"tick": state.world.current_tick,
					"data": { "betrayer_id": self_team.team_id }
				})
	Probe.bump("g3.betrayal")   # Phase-E：背叛率可觀測（belief 驅動 vs 舊純 RNG）
	print("[Diplomacy] Team%d 背叛 Team%d" % [self_team.team_id, ally_team.team_id])
