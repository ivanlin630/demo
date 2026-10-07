# scripts/simulation/diplomatic_ai_system.gd
class_name DiplomaticAiSystem

# ★S3 搬入 T3：【背叛傾向】同結盟，是關係層的戰略重估。
const BETRAY_CHECK_INTERVAL: int = DecisionTier.C_BETRAY_CHECK
# TIER: n/a — 語意時長非節律（某事多久算過期，不是多久評一次）
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
# ★★★好感（`p.relations`，兩層關係帳的【好感層】）在決策裡的權重。
#   它原本是 `_calc_diplomacy_score` 裡的一個 inline `0.15`（結盟那一項）——
#   本票要在 `tribute_accept` 讀同一個帳，而**一份真相只存一份** ⇒ 提成常數兩處共用，
#   不手抄第二個數（手抄的那一份會漂：下一次有人改只會改到一邊）。
#   ★★而它**刻意不與 `TRIBUTE_W_FEUD` 共用**：藍圖裁「決策讀兩項，權重各自獨立可改」
#     —— 好感層（小事、線性、會回中）與記憶層（大事、飽和、帶原因）是兩個帳。
const RELATION_W_AFFINITY: float = 0.15
const TRIBUTE_POWER_R_CAP: float = 3.0

# T-02：從 team_intel 取人口估算；無資料 fallback = self_pop（謹慎：視對方與己等強）
func _get_pop_est(state: WorldState, obs_id: int, tgt_id: int, fallback: int) -> int:
	return BeliefSystem.best_estimate(state, obs_id, tgt_id).get("population_est", fallback)

# F-I2 統一屈服公式（C 類：舊 interaction._should_pay_tribute / 本檔 demand_tribute 內嵌分 /
# interaction.resolve_extortion_direct 內嵌分全退役）。
# F-I7：aggressor 實力讀 believed pop（無估 fallback=self pop=視為等強，保守不偷看真值）。
# F-I5：consult feud/gratitude typed 邊當權重項。
const TRIBUTE_W_FLEE: float = 0.25   # de-patch 閘5 TEST VALUE：逃跑絕境屈服傾向(<義氣權重 0.3→膽識/義氣可拒=絕境戲)

static func tribute_accept(state: WorldState, defender: TeamData, aggressor: TeamData,
		threat: float) -> bool:
	return bool(tribute_eval(state, defender, aggressor, threat).get("accept", false))


# ★XB（spec 2026-10-07 battle-screen-asserted-and-extortion-brake §XB②）：同一支秤，把分數各項交出來
#   ⇒ 量測床讀這裡（不手抄公式）；`tribute_accept` 只是取 accept 那一欄 ⇒ 判決與量測同一份算式
#   ★無 leader ⇒ {accept:false, no_leader:true}（與舊行為同：沒人拍板就不屈服）
static func tribute_eval(state: WorldState, defender: TeamData, aggressor: TeamData,
		threat: float) -> Dictionary:
	var leader: PersonData = state.persons.get(defender.leader_id) if defender.leader_id != -1 else null
	if leader == null:
		return {"accept": false, "no_leader": true}
	# de-patch 閘5：拆「逃跑=必屈服」硬 override → 逃跑=絕境屈服傾向(加分)，但義氣/膽識高仍可邊逃邊拒(絕境戲)。
	var flee_desperation: float = TRIBUTE_W_FLEE if defender.current_task == TeamData.TASK_FLEE else 0.0
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
		+ clampf(threat, 0.0, 1.0) * TRIBUTE_W_THREAT \
		+ flee_desperation   # 閘5：逃跑絕境屈服傾向（義氣/膽識高可抵銷 → 邊逃邊拒）
	# ★★★好感項（本票的煞車出口）：被反覆索貢的人對索貢者的好感會往下掉（`_update_relations`
	#   的 "tributed" 那一列），而**在本票之前沒有人在這裡讀它** ——
	#   `p.relations` 全庫只有一個讀者（`_calc_diplomacy_score` 的結盟項）
	#   ⇒ 屈不屈服完全沒讀好感 ⇒ 煞車的載體【沒接電】。這一行就是接電。
	#   ★負好感 ⇒ score 下降 ⇒ 濫按到某一次開始被拒；★而第幾次翻**不釘**（床印序列）。
	var affinity: float = 0.0
	if aggressor.leader_id != -1:
		affinity = float(leader.relations.get(aggressor.leader_id, 0.0))
	score += affinity * RELATION_W_AFFINITY
	# ★★`score_no_edge` 的語意是【沒有 typed 邊時的分數】⇒ 好感【算在它裡面】：
	#   好感不是邊，而下面那個 edge_flipped 探針要量的正是「邊翻不翻得動」這一件事。
	var score_no_edge: float = score
	var had_edge: bool = false
	var feud_i: float = 0.0
	var grat_i: float = 0.0
	if aggressor.leader_id != -1:
		feud_i = _edge_intensity_to(leader.relation_edges, "feud", aggressor.leader_id)
		grat_i = _edge_intensity_to(leader.relation_edges, "gratitude", aggressor.leader_id)
		score -= feud_i * TRIBUTE_W_FEUD
		score += grat_i * TRIBUTE_W_GRATITUDE
		had_edge = feud_i > 0.0 or grat_i > 0.0
	if Probe.enabled:
		Probe.bump("rel.tribute_eval")
		# ★★★score_no_edge 要能被床讀到（spec P2′ 的母體地板 (b)）：
		#   「20 次裡至少一次拒絕」在一個 score 太高的世界裡永遠不會發生，
		#   而那一格的卸面會長得跟「煞车沒接上」一模一樣。
		#   ★用 add_amount（累計）＋rel.tribute_eval（次數）：床自己相減再除
		#   ⇒ 印出來的是【每一次的值】不是累計（累計直接跟門檻比是已經犯過的誤判）。
		Probe.add_amount("tribute.score_no_edge_sum", score_no_edge)
		Probe.add_amount("tribute.affinity_sum", affinity)
		if had_edge:
			Probe.bump("rel.tribute_with_edge")
			if (score > TRIBUTE_ACCEPT_THRESHOLD) != (score_no_edge > TRIBUTE_ACCEPT_THRESHOLD):
				Probe.bump("rel.tribute_edge_flipped")
	return {"accept": score > TRIBUTE_ACCEPT_THRESHOLD, "score": score, "score_no_edge": score_no_edge,
		"affinity": affinity, "feud": feud_i, "gratitude": grat_i, "threshold": TRIBUTE_ACCEPT_THRESHOLD}

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
	if self_leader == null: return 0.0   # gate-ok: guard early-return (self_leader null)

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
		relation      * RELATION_W_AFFINITY +
		self_peace    * 0.15 +
		gift_term,
		0.0, 1.0)

func try_proactive_diplomacy(state: WorldState, self_team: TeamData) -> void:
	var self_leader: PersonData = state.persons.get(self_team.leader_id)
	if self_leader == null: return
	# de-patch 閘2b（blueprint 明裁 legit RNG 案③，retry alone）：曲線陡化——慎重推兩端
	# （極謹慎 never proactive、大膽近乎每 tick，骰只斷中間）。慎重³ vs 舊 ×0.5+0.2(0.2~0.7 平)。
	var _caut2: float = float(self_leader.values.get("慎重", 0.5))
	if randf() < _caut2 * _caut2 * _caut2: return   # gate-ok: rng: 慎重³ 人格加權骰(案③ blueprint 裁 legit,非決策硬 gate)

	for other_id in state.team_discovered.get(self_team.team_id, []):
		var other: TeamData = state.teams.get(other_id)
		if other == null: continue
		if other.faction_id == self_team.faction_id and self_team.faction_id != -1: continue
		# invariant：外交/徵收需同格（嚴禁非同格互動）→ 隔空求貢/提案違規。對齊 process_on_move 同格外交。
		if other.tile_pos != self_team.tile_pos: continue   # gate-ok: 讀 other.tile_pos 只為【同格測試】(co-location)——同格才互動＝物理可見，非遠距窺探
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
		var _other_pop_est: int = _get_pop_est(state, self_team.team_id, other.team_id, self_team.population)   # gate-ok: 這一行讀的是 self_team.population(自己)；★偵測器把 `other.` 之後同行出現的 `.population` 誤配
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
				state.set_player_forced_event({
					"action": "diplomacy",
					"from_id": sender.team_id,
					"proposal": action,
				}, str(randi()))   # gate-ok: rng: event-ID str(randi())(非決策骰)
				# 設冷卻：玩家拒/超時後不立刻重發（原玩家路徑漏設 → 隔空 spam）
				sender.diplomacy_reject_cooldown[target.team_id] = \
					state.world.current_tick + REJECT_COOLDOWN
				print("[Diplomacy] Team%d 向玩家發起 %s → 寫入 forced_event" % [sender.team_id, action])
			return
	print("[Diplomacy] Team%d → Team%d: %s" % [sender.team_id, target.team_id, action])
	Probe.bump("dip.proposal_sent")
	var response: String = handle_diplomacy_message(state, target, sender, action)
	print("[Diplomacy] Team%d 回應: %s" % [target.team_id, response])
	if response == "reject" or response == "refuse":
		sender.diplomacy_reject_cooldown[target.team_id] = \
			state.world.current_tick + REJECT_COOLDOWN
	# ★★★談成 ⇒ 錢要真的動（spec 2026-09-30）：這一支原本**只有一句 print** ——
	#   同一個分岔的兩側嚴重不對稱（拒絕那半做了三件事、接受那半什麼都沒有）
	#   ⇒ 而那種不對稱通常是「有人只寫了他當時在想的那一半」。
	#   ★走共用解算點 ⇒ 金額與玩家同一支算式、恩怨走同一段（NPC 之間也有煞車）。
	if action == "demand_tribute" and response == "accept":
		var amount: float = apply_tribute_accept(state, target, sender)
		print("[Diplomacy] Team%d 向 Team%d 索貢談成：%.1f coin" % [
			sender.team_id, target.team_id, amount])
	# Tribute refusal consequence: write memory + reputation penalty
	if action == "demand_tribute" and response == "refuse":
		record_tribute_refused(state, sender, target)
		sender.update_reputation(target.team_id, -0.1)
		target.update_reputation(sender.team_id, -0.05)
		print("[Diplomacy] Team%d 拒絕進貢 → demander memory tribute_refused, rep -0.1/-0.05" % target.team_id)

# ★★★索貢談成的【全部】效果 —— 一個真相只存一份（spec 2026-09-30 §6，藍圖裁 (a)）。
#   玩家那條路（`player_command_system._action_demand_tribute`）與 NPC↔NPC 那條路
#   **都呼這一支** ⇒ 金額同一支算式、恩怨走同一段。
#   ★藍圖逐字：同一動詞同一價；而缺恩怨那一段 ＝ **NPC 之間濫索無煞車（只有玩家有）**。
#   ★★為什麼係數留在這裡：玩家端原本寫 `coin_before * 0.1  # TEST VALUE` 的字面
#     ⇒ 兩條路各自一份會漂（改一邊）⇒ 提成常數並讓兩邊都引用它。
#   ★★★而恩怨那一段就是濫按煞車那票的 `write_memory("tributed", …)` ——
#     本支是它的**第三個**呼叫點（前兩個：player_command_system 的遠程索貢、
#     interaction_system 的 `_resolve_extortion`）⇒ 呼同一支，不另外發明。
#   回傳實際拿走的金額（玩家端的結果句要用它）。
const TRIBUTE_TAKE_RATIO: float = 0.1   # TEST VALUE（藍圖明文留給平衡階段，本票不動它）

# ══ ★★★★★★【轉帳那一半，拆出來】（spec `2026-10-01-tribute-offer-loop…` §3①，裁 甲）══
# ★為什麼要拆：`apply_tribute_accept` 同時做**兩件語意不同的事** ——
#   ①`payer → taker` 轉 coin（**物理**：東西換了手）
#   ②`write_memory(payer_leader, "tributed", …)`（**關係**：對方記得這件事）
#   ★★而②的方向**隨情境相反**：
#     ·`demand_tribute`（索貢／勒索）＝**強制** ⇒ 對方記一筆（`npc_ai_system.gd:117`
#       把 `"tributed"` 歸在 betrayal／looted／rejected_aid 同一組 ⇒ 走 `form_feud` 結仇邊）
#     ·★`tribute_offer`（**對方主動**來進貢）＝**自願** ⇒ 玩家接受它**不該讓對方結仇**
#       —— 不然玩家會看到「剛送我東西的 NPC 突然對我有仇恨值」
#   ⇒ ★★★所以重用整支 ＝ 把**強制情境的關係語意偷渡到自願情境**
#     ⇒ 拆：轉帳那一半可以重用，關係那一半不行。
# ★而藍圖裁 **(甲) 不寫關係**（主動進貢 ＝ **買保險**不是示好）⇒ 接受那一刻**雙方情感都不動**：
#   ·付方好感**不升** —— **恐懼或算計不是好感**
#   ·也**不結仇** —— 自願的，沒人搶他
#   ⇒ ★★★而否決「寫正面」的理由最硬：**寫正面 ＝ 把保險誤記成友誼**，
#     而後面每一個讀好感的決策都會把「**怕你的人**」當成「**喜歡你的人**」
#     ⇒ **錯誤不會留在那一筆記憶裡，它會跑到後面每一個讀好感的決策上。**
# ★★「NPC 主動送貢之後它對玩家的感覺應該是什麼」＝ **WHAT** ⇒ 已呈藍圖，不在本票。
# ★`_state` 底線前綴 ＝ **刻意不用**（轉帳不需要世界；簽章與 `apply_tribute_accept` 對齊
#   是為了讓兩支在呼叫端長得一樣 —— 而「長得一樣」在這裡是刻意的：它讓
#   「我該呼哪一支」只取決於**情境是強制還是自願**，不取決於參數湊不湊得出來）。
static func apply_tribute_transfer(_state: WorldState, payer: TeamData, taker: TeamData) -> float:
	if payer == null or taker == null:
		return 0.0
	var coin_before: float = float(payer.resources.get("coin", 0))
	# ★`coin_before <= 0` ⇒ 什麼都不做：拿走 0 不是一件被記得住的事，而 0/0 算不出比例。
	if coin_before <= 0.0:
		return 0.0
	var amount: float = coin_before * TRIBUTE_TAKE_RATIO
	ResourceBank.add(payer, "coin", -amount, "demand_tribute_out")
	ResourceBank.add(taker, "coin", amount, "demand_tribute_in")
	return amount


# 索貢／勒索那條路的【全部】效果 ＝ 轉帳 ＋ 對方記一筆（**強制情境**）
# ★它的兩個呼叫端都是強制情境：`:218`（NPC↔NPC 索貢）與
#   `player_command_system` 的 `demand_tribute`（玩家向對方索貢）
#   ⇒ ★★而 `tribute_offer`（對方主動送）**不呼這一支**，它呼上面那一支
#     —— 那一條差別就是本票的全部內容。
# ★XB③（systems 2026-10-07）：索貢被拒的記憶【唯一寫入點】——NPC↔NPC（上面 demand_tribute 那支）與
#   玩家遠程索貢（player_command_system `_action_demand_tribute`）共呼
#   ★寫在【索貢方】領袖身上（記得被誰拒過），typed ⇒ 進關係帳；`tributed` 寫在被勒索方，主詞相反、不合流
const TRIBUTE_REFUSED_INTENSITY: float = 0.2   # TEST VALUE（原 NPC 那支的字面，搬來共用，不改值）
static func record_tribute_refused(state: WorldState, demander: TeamData, refuser: TeamData) -> void:
	if demander == null or refuser == null or demander.leader_id < 0:
		return
	var dl: PersonData = state.persons.get(demander.leader_id)
	if dl == null:
		return
	# F-I6：走 write_memory 統一 schema（type 欄 → type-scan counter 可見）
	NpcAiSystem.new().write_memory(dl, "tribute_refused", refuser.leader_id, state.world.current_tick,
		TRIBUTE_REFUSED_INTENSITY)


static func apply_tribute_accept(state: WorldState, payer: TeamData, taker: TeamData) -> float:
	var coin_before: float = float(payer.resources.get("coin", 0)) if payer != null else 0.0
	var amount: float = apply_tribute_transfer(state, payer, taker)
	if amount <= 0.0:
		return amount
	if taker.leader_id != -1:
		var payer_leader: PersonData = state.persons.get(payer.leader_id)
		if payer_leader != null:
			NpcAiSystem.new().write_memory(payer_leader, "tributed", taker.leader_id,
				state.world.current_tick, amount / coin_before)
	return amount


# ══ ★★★★★★【`tribute_offer` 的收尾：三件，而它只有一處定義】（spec §3③）═══════════
# ★真因（spec §1）：**同一個狀態機有兩條出口，而玩家那一條沒有收尾** ——
#   NPC↔NPC 那條（`interaction_system.gd` 那一段）本來就做了這三件；
#   而玩家那條（`interaction_system` 寫 forced_event 那一段）**一件都沒有**
#   ⇒ 任務還在 ⇒ 下一輪再提 ⇒ 用戶看到的「**接受或拒絕都一樣重提**」。
# ★★所以修法不是「新增一個 handler」，是**把已經存在的收尾接到玩家那一側**，
#   而**三個出口（接受／拒絕／逾時）各自呼它一次** —— 不要在三個地方各抄一份。
# ★★★`static func` 的理由（R² 查到的）：`sim_runner.gd` **沒有 `PlayerCommandSystem` 的實例參照**
#   ⇒ 收尾必須能被類別名直呼（同 `TaskArbiter.release`／`DiplomaticAiSystem.REJECT_COOLDOWN`
#   本來就是這樣被呼的 ⇒ **不是新花樣**）。
# ★★★★而它**自己判 `order_task`**（不要求呼叫端先判）：
#   接受／拒絕／逾時那三處都是**所有 diplomacy 提案共用**的通用分支
#   ⇒ 若收尾無條件執行，會對 alliance／surrender／propose_trade 的 NPC
#     **去清一個它們沒設過的 `order_task`**、去 release 一個不是它設的 task。
#   ⇒ ★**所以守衛放在這一支裡面**（一處）而不是三個呼叫端各寫一次 `if`
#     —— 三份 `if` 會漂，而漂掉的那一份是靜默的。
#   ⇒ ★★而它**回傳有沒有真的收尾**（`bool`）：呼叫端要能分辨「收了」與「不是這條路」，
#     而**那個差別不可以只能靠猜**。
static func settle_tribute_offer(state: WorldState, from_team: TeamData, target_id: int) -> bool:
	if from_team == null or state == null:
		return false
	if from_team.order_task != TeamData.TASK_TRIBUTE_OFFER:
		return false
	TaskArbiter.release(from_team)
	from_team.diplomacy_reject_cooldown[target_id] = \
		state.world.current_tick + REJECT_COOLDOWN
	from_team.order_task = ""   # 清 order_task（防殘留→下次外交/結盟誤路由為求和）
	return true

# ★★★接受通商的【全部】效果 —— 一個真相只存一份（spec 2026-09-30 §2①）。
#   NPC↔NPC 那一支與玩家 handler **都呼這一支**（呼叫點恰好 2 個，床 P2(a) 指名斷言）。
#   ★為什麼不讓玩家端呼 `handle_diplomacy_message`：那一支會重跑 `score > 0.4`
#     ⇒ 而玩家的決定是【玩家按的】，不是秤出來的 ⇒ 重跑那把秤＝把玩家的決定交還給 AI。
#   ★★為什麼不在玩家端複製那兩行：複製的那一份會漂
#     —— 下一次有人改這個係數只會改到一邊。⇒ 係數留在這裡，玩家端不得出現它的字面。
# ★★★而【只寫 team 名聲，一個字都不多】：
#   上游裁定寫「名聲／好感加分」，而這一支 code 走的是 `known_reputations`（**team 名聲**），
#   **不是** `p.relations`（**person 好感**）。
#   ⇒ 若玩家端順手也寫好感，玩家就得到一個【NPC 得不到的效果】＝**特例**，
#     而那正好違反這條裁定自己的原則（零特例）。
const TRADE_ACCEPT_REP: float = 0.05

# ★不吃 `state`：這一支只動兩個 TeamData 的名聲欄。
#   ★★刻意不加一個沒用到的參數 —— 一個假參數會讓下一個人以為它還寫了別的世界狀態。
static func apply_trade_accept(a: TeamData, b: TeamData) -> void:
	if a == null or b == null:
		return
	a.update_reputation(b.team_id, TRADE_ACCEPT_REP)
	b.update_reputation(a.team_id, TRADE_ACCEPT_REP)

func handle_diplomacy_message(state: WorldState, self_team: TeamData,
		sender_team: TeamData, action: String, gift: Dictionary = {}) -> String:
	if Probe.enabled: Probe.bump("dip.proposal_handled")
	var score: float = _calc_diplomacy_score(state, self_team, sender_team, gift)
	match action:
		"propose_alliance":
			if score > ALLIANCE_ACCEPT_THRESHOLD:
				_form_alliance(state, self_team, sender_team)
				if Probe.enabled: Probe.bump("dip.proposal_accept")
				return "accept"
			return "reject"
		"propose_trade":
			if score > 0.4:
				apply_trade_accept(self_team, sender_team)
				if Probe.enabled: Probe.bump("dip.proposal_accept")
				return "accept"
			return "reject"
		"demand_tribute":
			# F-I2 統一公式（遠程外交無兵臨壓力 threat=0）
			var _acc: bool = tribute_accept(state, self_team, sender_team, 0.0)
			if _acc and Probe.enabled: Probe.bump("dip.proposal_accept")
			return "accept" if _acc else "refuse"
		"offer_surrender":
			if score > 0.3:
				if Probe.enabled: Probe.bump("dip.proposal_accept")
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
	# ★cohesion g3 延伸：bond counter-term（P4 第四出口、解單邊秤）——留在勢力的真好處(被救/恩義/聲譽)抵背叛驅力。
	#   忠的/被救的(stay_benefit 高)→driver<0.65 不叛；無情+利大+無恩義(stay_benefit≈0)→仍過門檻照叛(genuine opportunism 保留)。
	#   ★共享同一 _faction_stay_benefit(faction_ai defect/uprising/defection-eval 共用=一套非兩套)；跨 class 呼 FactionAISystem.shared() 既有慣例。
	#   零 god-view(self benefactor memory + known_reputations belief)；純算術減項 determinism 零新 randf。
	driver -= FactionAISystem.shared()._faction_stay_benefit(state, self_team)
	if Probe.enabled: Probe.note("g3.betray_driver_post_bond", driver)
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
	state.clear_team_faction(self_team, WorldState.LEAVE_BETRAYAL)   # 背叛離團（雙向同步）
	# ★T0-A1 ②第五個 chokepoint（R² 抓到的漏網）：本函式全檔零 emit_message、卻有 player_alerts
	# 通知玩家 → 玩家立刻知道自己被背叛、NPC 受害者卻不會＝玩家中心家族。這裡把受害方喚醒。
	WorldEvents.emit(state, "betrayed", [ally_team.team_id])
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
