# scripts/simulation/npc_ai_system.gd
class_name NpcAiSystem

const MEMORY_MAX: int = 20   # TEST VALUE
const VENDETTA_INTENSITY: float = 0.6     # TEST VALUE：脫軌的最低仇恨強度
const VENDETTA_BELLIGERENCE: float = 0.6  # 好戰 ≥ 此
const VENDETTA_PRUDENCE: float = 0.4      # 慎重 < 此

# A feud：嚴重度×個性 gate。全 TEST VALUE。
const FEUD_BASE_FACTOR := 0.2
const FEUD_HONOR_W := 0.7
const FEUD_BELLIGERENCE_W := 0.4
const FEUD_MIN := 0.30
const FEUD_SPREAD_FACTOR := 0.6
# ★★★【`extorted` 是一個死名字】（systems §0 訂正①，2026-09-16）：
#   ★`write_memory(…, "extorted", …)` 的呼叫點**全庫 0 個**；
#     真正的重徵事件寫的是 **`"special_taxed"`**（`interaction_system.gd:696`）
#   ⇒ 它不在任何一個 match 裡 ⇒ 落進 `_` ⇒ **零邊、零標量、零 goal。**
#   ★★所以這裡是**改名不加鍵**：留著 `extorted` 就是留一個永遠不會被觸發的分支
#     ——★★★而那種分支**看起來像已經接好了**。
#   ★嚴重度沿用 0.30：**這不是新數字，是同一個值換了正確的鍵。**
# ★★`rejected_aid`（供養失守／求救不應）同一個病的第二例：三個寫入點全在，卻不在任何 match 裡。
#   嚴重度 **0.325 ＝ (0.30 + 0.35) / 2** ——★**表內兩個相鄰值的中點**，不是挑一個數（TEST VALUE）。
# ★★★`benefactor`（**受人援助**）是同一個病的**第三例**，而 systems 的 §0 沒有掃到它：
#   `interaction_system.gd:1218/:1560`、`player_command_system.gd:1024` 三個寫入點，
#   而 `kindness` 的**呼叫點只有 `salary_system.gd:229`（超額發薪）** ——
#   ⇒ ★**「被救了一命」在今天的世界裡不產生任何 gratitude 邊。**
#   ⇒ 而 WHAT 的三寫入第三條正是「**kindness 加呼叫點**」⇒ 同 §0 的處方：**用已經被寫的名字。**
const FEUD_SEVERITY := {
	"massacre": 1.0, "betrayal": 0.8, "subjugated": 0.5, "looted": 0.35,
	"special_taxed": 0.30,
	"rejected_aid": 0.325,   # TEST VALUE（推法＝表內相鄰兩值中點，非手填）
}

# A feud：唯一形成點。severity×個性 factor，FEUD_MIN gate。回 true=已結仇。
static func form_feud(victim: PersonData, perp_id: int, severity: float, tick: int) -> bool:
	if victim == null or perp_id == -1 or victim.id == perp_id:
		return false
	var honor: float = float(victim.values.get("義氣", 0.5))
	var bell: float  = float(victim.values.get("好戰", 0.5))
	var factor: float = FEUD_BASE_FACTOR + honor * FEUD_HONOR_W + bell * FEUD_BELLIGERENCE_W
	var intensity: float = clampf(severity * factor, 0.0, 1.0)
	if intensity < FEUD_MIN:
		return false
	RelationGraph.add_edge(victim.relation_edges, "feud", perp_id, intensity, tick)
	_activate_goal(victim, "revenge", perp_id)
	Probe.bump("g2.feud_formed")
	if Probe.enabled:
		# ★逐 severity 記母體（★單一個 `g2.feud_formed` 答不出【是哪個名字接上了】——
		#   而本切片改的正是名字 ⇒ 沒有這一格，接沒接上在總數裡長得一模一樣）。
		Probe.bump("grudge.form.feud")
		Probe.bump("grudge.form.feud.sev%.3f" % severity)
	return true

# A feud：滅族 → 同 faction 餘部繼承（弱於親歷）。事件當下（erase 前）呼。
static func spread_feud(state: WorldState, victim_team: TeamData, perp_id: int, severity: float, tick: int) -> void:
	var fid: int = victim_team.faction_id
	if fid == -1 or not state.factions.has(fid):
		return
	var perp: PersonData = state.persons.get(perp_id)
	var perp_team: int = perp.team_id if perp else -1
	for tid in state.factions[fid].member_team_ids:
		if tid == victim_team.team_id or tid == perp_team:
			continue
		var t: TeamData = state.teams.get(tid)
		if t == null:
			continue
		form_feud(state.persons.get(t.leader_id), perp_id, severity * FEUD_SPREAD_FACTOR, tick)

# 強血仇 + 衝動 → 脫軌目標 team_id（否則 -1）。讀 G2a feud 邊。
func vendetta_target(state: WorldState, leader: PersonData) -> int:
	if leader == null:
		return -1
	if float(leader.values.get("好戰", 0.5)) < VENDETTA_BELLIGERENCE:
		return -1
	if float(leader.values.get("慎重", 0.5)) >= VENDETTA_PRUDENCE:
		return -1
	var edge: Dictionary = RelationGraph.strongest(leader.relation_edges, "feud")
	if edge.is_empty() or float(edge.get("intensity", 0.0)) < VENDETTA_INTENSITY:
		return -1
	var foe: PersonData = state.persons.get(int(edge.get("target", -1)))
	if foe == null or foe.team_id == leader.team_id or not state.teams.has(foe.team_id):
		return -1
	return foe.team_id

func write_memory(p: PersonData, type: String, subject_id: int,
		tick: int, intensity: float) -> void:
	p.memory.append({
		"type": type, "subject_id": subject_id,
		"tick": tick, "intensity": intensity,
	})
	_trim_memory(p)
	_update_relations(p, type, subject_id, intensity)
	_trigger_goals(p, type, subject_id)
	_write_relation_edge(p, type, subject_id, tick, intensity)   # G2a：同步 typed 邊

# ★§4c 選址記憶專用薄函式（R² 必查項①：禁原樣重用 write_memory）：
# write_memory 不是純 append——它連呼 _update_relations（只要 subject_id != -1 就無條件寫
# p.relations[subject_id]）/ _trigger_goals / _write_relation_edge；subject 傳 tile_id 會在人際
# 關係字典塞「跟一塊地的交情」假記錄，汙染所有假設 relations.keys() 是 person id 的 code。
# 故本函式只做 memory.append + _trim_memory，★跳過三個 interpersonal side-effect；
# 共用 write_memory 完全不動（8 個既有 caller 零影響）。零 RNG。
func write_site_memory(p: PersonData, type: String, tile_id: int,
		tick: int, intensity: float) -> void:
	if p == null:
		return
	p.memory.append({
		"type": type, "subject_id": tile_id,
		"tick": tick, "intensity": intensity,
	})
	_trim_memory(p)

func _write_relation_edge(p: PersonData, type: String, subject_id: int,
		tick: int, intensity: float) -> void:
	# G2a additive：對齊 _trigger_goals 映射，填 typed 邊。reader 在 G2b/G2d。
	match type:
		"betrayal", "looted", "special_taxed", "rejected_aid":
			# A feud：改走 form_feud（severity×個性 gate）。bump 移進 form_feud（不雙計）。
			NpcAiSystem.form_feud(p, subject_id, FEUD_SEVERITY.get(type, intensity), tick)
		"kindness", "aided_in_battle", "benefactor":
			RelationGraph.add_edge(p.relation_edges, "gratitude", subject_id, intensity, tick)
			if Probe.enabled: Probe.bump("grudge.form.gratitude." + type)
		"master":
			RelationGraph.add_edge(p.relation_edges, "protect", subject_id, intensity, tick)

func _trim_memory(p: PersonData) -> void:
	while p.memory.size() > MEMORY_MAX:
		p.memory.pop_front()

func _update_relations(p: PersonData, type: String,
		subject_id: int, intensity: float) -> void:
	if subject_id == -1: return
	var delta: float
	match type:
		"betrayal":          delta = -intensity * 0.8
		"kindness":          delta =  intensity * 0.4
		"master":            delta =  intensity * 0.5
		"witnessed_atrocity":delta = -0.1
		"looted":            delta = -intensity * 0.6
		"special_taxed":     delta = -intensity * 0.5   # ★原本寫 "extorted" ＝ 沒有人叫的名字
		"rejected_aid":      delta = -intensity * 0.5   # ★同族：三個寫入點都落進 `_`
		"benefactor":        delta =  intensity * 0.4   # ★受援＝善意，同 kindness 的係數
		"aided_in_battle":   delta =  intensity * 0.5
		_:                   delta = 0.0
	var cur: float = float(p.relations.get(subject_id, 0.0))
	p.relations[subject_id] = clampf(cur + delta, -1.0, 1.0)

func _trigger_goals(p: PersonData, type: String, subject_id: int) -> void:
	match type:
		"betrayal", "looted", "special_taxed", "rejected_aid":
			_activate_goal(p, "revenge", subject_id)
		"kindness", "aided_in_battle", "benefactor":
			_activate_goal(p, "gratitude", subject_id)
		"master":
			_activate_goal(p, "protect", subject_id)

static func _activate_goal(p: PersonData, goal_type: String, target_id: int) -> void:
	for g in p.goals:
		if g["type"] == goal_type and g["target_id"] == target_id:
			g["active"] = true
			return
	p.goals.append({ "type": goal_type, "target_id": target_id, "active": true })

func generate_birth_goals(p: PersonData) -> void:
	if p.values.get("貪婪",  0.5) > 0.6:
		p.goals.append({ "type": "wealth",      "target_id": -1, "active": true })
	if p.values.get("求生欲",0.5) > 0.6:
		p.goals.append({ "type": "escape_war",  "target_id": -1, "active": true })
	if p.values.get("野心",  0.5) > 0.65:
		p.goals.append({ "type": "domination",  "target_id": -1, "active": true })
	if p.values.get("好戰",  0.5) > 0.55:
		p.goals.append({ "type": "merit",       "target_id": -1, "active": true })
	if p.values.get("義氣",  0.5) > 0.65:
		p.goals.append({ "type": "peace",       "target_id": -1, "active": true })

func check_goal_alignment(p: PersonData, task: String) -> float:
	var delta: float = 0.0
	for g in p.goals:
		if not g.get("active", false): continue
		delta += _goal_task_delta(g["type"], task)
	return delta

func _goal_task_delta(goal_type: String, task: String) -> float:
	match goal_type:
		"wealth":
			if task in [TeamData.TASK_TRADE, TeamData.TASK_PRODUCE, TeamData.TASK_MANUFACTURE, TeamData.TASK_LOOT]: return 0.005
		"escape_war":
			if task in [TeamData.TASK_ATTACK, TeamData.TASK_LOOT]: return -0.015
			if task in [TeamData.TASK_FLEE, TeamData.TASK_REST, TeamData.TASK_TRADE]: return 0.005
		"domination":
			if task in [TeamData.TASK_ATTACK, TeamData.TASK_LOOT]: return 0.005
		"merit":
			if task in [TeamData.TASK_ATTACK]: return 0.005
		"peace":
			if task in [TeamData.TASK_ATTACK, TeamData.TASK_LOOT]: return -0.01
			if task in [TeamData.TASK_DIPLOMACY, TeamData.TASK_TRADE]: return 0.005
		"revenge":
			if task in [TeamData.TASK_ATTACK, TeamData.TASK_LOOT]: return 0.005
		# ★★★`gratitude` 的 `0.003` 已砍（WHAT 明文，用戶裁 2026-09-16）：
		#   ★它是一個**掛在任務類別上的死常數**——「對誰有恩」在它裡面看不見
		#   ⇒ 對恩人與對陌生人做同一件事，加的分**一模一樣**。
		#   ★★恩的行為出口改由**逐方估值**承擔（`trade_valuation.ask_price` 讀 `gratitude` 邊折價）
		#     ⇒ ★★★**那條路知道「對誰」，這條路不知道** —— 兩條並存只會讓後者稀釋前者。
		"protect":
			if task in [TeamData.TASK_ATTACK]: return 0.008
	return 0.0

func cleanup_goals(state: WorldState, p: PersonData) -> void:
	for g in p.goals:
		if g["target_id"] == -1: continue
		if not state.persons.has(g["target_id"]):
			match g["type"]:
				"revenge":
					var new_target: int = _find_revenge_redirect(state, p, g["target_id"])
					if new_target != -1:
						g["target_id"] = new_target
					else:
						g["type"] = _fallback_birth_goal(p)
						g["target_id"] = -1
				"gratitude", "protect":
					g["type"] = _fallback_birth_goal(p)
					g["target_id"] = -1

func _find_revenge_redirect(state: WorldState, p: PersonData,
		dead_id: int) -> int:
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.leader_id == dead_id or dead_id in t.named_members:
			if t.leader_id != p.id:
				return t.leader_id
	return -1

func _fallback_birth_goal(p: PersonData) -> String:
	var candidates: Array = [
		{ "type": "wealth",     "value": p.values.get("貪婪",  0.5) },
		{ "type": "escape_war", "value": p.values.get("求生欲",0.5) },
		{ "type": "domination", "value": p.values.get("野心",  0.5) },
		{ "type": "merit",      "value": p.values.get("好戰",  0.5) },
		{ "type": "peace",      "value": p.values.get("義氣",  0.5) },
	]
	candidates.sort_custom(func(a, b): return a["value"] > b["value"])
	return candidates[0]["type"]

# ★★★【報恩 ⇒ 消耗恩】（恩怨帳切片A §1.2；WHAT：**消耗邊的是【事件】，被動與無不消耗**）
#   ★「報恩」在本切片裡有且只有一個已存在的形狀：**折價真的成交了**
#     （WHAT 列的四個形狀＝援助／**折價**／優先成交／替他打，而本切片只接了折價那條讀者線）。
#   ★★所以呼叫端是【成交完成】那一刻，**不是 `ask_price` 被算出來的那一刻** ——
#     ★★★算了價而沒成交＝**沒有報到恩**，那正是「被動不消耗」這條鐵則要擋的東西。
# ★【消耗量怎麼來】：`grat × W`，兩個量**都已經在式子裡**（零新常數）——
#   ★★它逐字等於**這一筆折價裡「因為恩」而讓掉的那個比例** ⇒ 讓掉多少＝報掉多少。
#   ★★★（恩 0.6、中庸人格 W=0.15 ⇒ 每筆消耗 0.09 ⇒ 約七筆生意還完一次救命之恩；
#     ★這個「七」不是我挑的，它是上面兩個數的後果 —— **要改請改那兩個數**。）
static func repay_gratitude(state: WorldState, seller: TeamData, buyer_leader_id: int) -> float:
	if state == null or seller == null or buyer_leader_id == -1 or seller.leader_id == -1:
		return 0.0
	var sl: PersonData = state.persons.get(seller.leader_id)
	if sl == null:
		return 0.0
	var grat: float = RelationGraph.intensity_to(sl.relation_edges, "gratitude", buyer_leader_id)
	if grat <= 0.0:
		return 0.0
	var w: float = TradeValuation.grudge_weight(sl.values)
	var taken: float = RelationGraph.consume_edge(sl.relation_edges, "gratitude", buyer_leader_id, grat * w)
	if Probe.enabled and taken > 0.0:
		Probe.bump("grudge.consume.repay_trade")
		Probe.add_amount("grudge.consume.repay_trade.amount", taken)
	return taken
