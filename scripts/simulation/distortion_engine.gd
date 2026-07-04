class_name DistortionEngine
# F-I4 單一失真引擎：估值擾動 / 位置偏移 / 身分誤報 / 任務謠傳 / 觀察欺敵 的「失真怎麼算」單一 owner。
# call site 只選 mode / 傳 context，不各自持公式。
# C 類退役：message._distort_content、message._distort_intel_entry、
# interaction._write_tier2_intel 內嵌欺敵三塊 → 收斂於此；message.exchange_messages（dormant 第4引擎）刪除。
# RNG 紀律：各 mode 內 randf 序 1:1 移植（行為統一造成的 seeded hash 變更由 spec 允許）。

const HEX_NEIGHBORS: Array = [
	Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1),
	Vector2i(0,-1), Vector2i(1,-1), Vector2i(-1,1),
]
const POS_OFFSETS_FAR: Array = [
	Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1),
	Vector2i(1,-1), Vector2i(-1,1), Vector2i(2,0), Vector2i(-2,0),
]
const TASK_RUMORS: Array = ["idle", "攻擊", "貿易", "生產", "偵查"]

# 觀察欺敵機率 = 人格函數（原 _write_tier2_intel deceive_chance）。TEST VALUE
const DECEIVE_HONOR_W: float = 0.5
const DECEIVE_SCHEME_W: float = 0.2
const DISGUISE_TAGS: Array = ["統領", "軍隊", "流亡", "子團"]

# 訊息內容失真。mode="unintentional"：40% 鄰格位置漂移（原 _exchange_one_way 內嵌塊）。
# mode="malicious"：50/50 身分誤報（origin 換隊）或位置偏移，＋惡意改寫描述（原 _distort_content）。
static func distort_message(state: WorldState, msg: MessageData, mode: String) -> void:
	match mode:
		"unintentional":
			if randf() < 0.4:
				msg.source_pos += HEX_NEIGHBORS[randi() % HEX_NEIGHBORS.size()]
		"malicious":
			if randf() < 0.5:
				var ids: Array = state.teams.keys()
				ids.erase(msg.origin_team_id)
				if not ids.is_empty():
					msg.origin_team_id = ids[randi() % ids.size()]
					msg.params["origin"] = str(msg.origin_team_id)
			else:
				msg.source_pos += POS_OFFSETS_FAR[randi() % POS_OFFSETS_FAR.size()]
				msg.params["x"] = str(msg.source_pos.x)
				msg.params["y"] = str(msg.source_pos.y)
			if TextBank.TEMPLATES.has(msg.type):
				msg.description = TextBank.fmt(msg.type, "malicious", msg.params)

# intel entry 失真（原 message._distort_intel_entry 1:1）。silent → {}。
static func distort_intel_entry(entry: Dictionary, mode: String, hop_decay: float) -> Dictionary:
	var e: Dictionary = entry.duplicate()
	match mode:
		"honest":
			e["population_est"] = roundi(float(e.get("population_est", 0)) * randf_range(0.9, 1.1))
		"unintentional":
			e["population_est"] = roundi(float(e.get("population_est", 0)) * randf_range(0.6, 1.5))
			e["tile_pos"] = e.get("tile_pos", Vector2i.ZERO) + \
				Vector2i(randi_range(-2, 2), randi_range(-2, 2))
			if randf() < 0.3:
				e["current_task"] = TASK_RUMORS[randi() % TASK_RUMORS.size()]
		"malicious":
			e["population_est"] = roundi(float(e.get("population_est", 0)) * randf_range(0.2, 3.0))
			e["tile_pos"] = e.get("tile_pos", Vector2i.ZERO) + \
				Vector2i(randi_range(-6, 6), randi_range(-6, 6))
			if randf() < 0.4:
				e["current_task"] = TASK_RUMORS[randi() % TASK_RUMORS.size()]
		"silent":
			return {}
	e["confidence"]    = clampf(float(e.get("confidence", 1.0)) * (1.0 - hop_decay), 0.0, 1.0)
	e["is_suspicious"] = false
	return e

# 親見觀察欺敵（原 _write_tier2_intel 三內嵌塊 1:1：偽裝平民 / 虛張聲勢 / 謊稱勢力）。
# 被觀察方（tgt/tgt_leader）人格驅動 deceive_chance；snap 就地改。
static func apply_observation_deception(state: WorldState, snap: Dictionary, tgt: TeamData,
		tgt_leader: PersonData, actual_armed: int) -> void:
	var honor: float   = float(tgt_leader.values.get("信義",  0.5)) if tgt_leader else 0.5
	var scheme: float  = float(tgt_leader.skills.get("計謀",  0.0)) if tgt_leader else 0.0
	var martial: float = float(tgt_leader.values.get("好戰",  0.5)) if tgt_leader else 0.5
	var caution: float = float(tgt_leader.values.get("慎重",  0.5)) if tgt_leader else 0.5
	var deceive_chance: float = (1.0 - honor) * DECEIVE_HONOR_W + scheme * DECEIVE_SCHEME_W  # TEST VALUE
	var has_disguise_tag: bool = false
	for dtag in DISGUISE_TAGS:
		if tgt.tags.has(dtag): has_disguise_tag = true; break
	if has_disguise_tag and randf() < deceive_chance:
		# 偽裝平民：低報武器，高報其他資源
		snap["armed_est"]    = roundi(actual_armed * randf_range(0.2, 0.4))
		snap["food_est"]     *= randf_range(1.5, 2.5)
		snap["material_est"] *= randf_range(1.5, 2.5)
		snap["goods_est"]    *= randf_range(1.5, 2.5)
	else:
		var is_bluff_task:     bool = tgt.current_task in [TeamData.TASK_ATTACK, TeamData.TASK_LOOT]
		var is_bluff_martial:  bool = martial > 0.6
		var is_bluff_merchant: bool = tgt.tags.has("商隊") and caution > 0.5
		var armed_ratio: float = float(actual_armed) / maxf(float(tgt.population), 1.0)
		if (is_bluff_task or is_bluff_martial or is_bluff_merchant) \
				and armed_ratio < 0.6 and randf() < deceive_chance:
			# 虛張聲勢：高報武器，低報其他資源
			var bluffed: int  = roundi(actual_armed * randf_range(2.0, 4.0))
			snap["armed_est"] = maxi(0, mini(bluffed, tgt.population - 1))
			snap["food_est"]     *= randf_range(0.3, 0.7)
			snap["material_est"] *= randf_range(0.3, 0.7)
			snap["goods_est"]    *= randf_range(0.3, 0.7)
	# R1b ③可騙 channel：弱獨立隊謊稱屬大勢力（faction_id 誤報 → 攻擊者 own 罰被嚇阻）。
	# 同 deceive 塊一欄非新系統；機率沿用 deceive_chance（人格驅動）。TEST VALUE 門檻。
	if tgt.faction_id == -1 \
			and float(actual_armed) / maxf(float(tgt.population), 1.0) < 0.5 \
			and randf() < deceive_chance:
		var bluff_fid: int = _biggest_established_faction(state)
		if bluff_fid != -1:
			snap["faction_id"] = bluff_fid

# faction_id 誤報用——最大 established faction（謊稱誰最能嚇阻）。無則 -1（不誤報）。
static func _biggest_established_faction(state: WorldState) -> int:
	var best_fid: int = -1
	var best_n: int = -1
	for fid in state.factions:
		var f: FactionData = state.factions[fid]
		if not f.is_established: continue
		if f.member_team_ids.size() > best_n:
			best_n = f.member_team_ids.size()
			best_fid = fid
	return best_fid
