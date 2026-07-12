class_name NeedHierarchy

# 需求金字塔五層急迫度（Maslow 式）。感測器非決策者：只讀「這層還缺多少」(0..1)。
# 生存(食物)→安全(威脅)→歸屬(faction/社交)→尊重(地位/擴張)→自我實現(立國/稱霸)。
const L_SURVIVAL: int = 0
const L_SAFETY: int = 1
const L_BELONGING: int = 2
const L_ESTEEM: int = 3
const L_ACTUAL: int = 4
const N_LAYERS: int = 5

# raw 急迫度門檻（TEST VALUE）
const SURVIVAL_SATED_DAYS: float = 5.0   # TEST VALUE — 食物餘命達此→生存急迫度 0（對齊 forage floor 域）
const URGENCY_EWMA_ALPHA: float = 0.25   # TEST VALUE — 急迫度平滑係數（同 S1 zero-randf pattern）

# 每層 raw 急迫度 = 該層底層指標距門檻的差距(0..1，越沒滿足越高)。純算術零 randf。
# food_days/threat 由呼叫端(gather)供（已算，避重複）；其餘讀 team/state + AmbitionLadder 門檻。
static func compute_raw(state: WorldState, team: TeamData, food_days: float, threat: float) -> PackedFloat32Array:
	var raw := PackedFloat32Array()
	raw.resize(N_LAYERS)
	# 生存：食物餘命距飽線
	raw[L_SURVIVAL] = clampf((SURVIVAL_SATED_DAYS - food_days) / SURVIVAL_SATED_DAYS, 0.0, 1.0)
	# 安全：威脅(ctx.threat 已 0..1 clamp)
	raw[L_SAFETY] = clampf(threat, 0.0, 1.0)
	# 歸屬：faction 規模距 STATE 門檻；solo(faction_id==-1)→完全未滿足=1
	var members: int = 0
	if team.faction_id != -1 and state.factions.has(team.faction_id):
		members = state.factions[team.faction_id].member_team_ids.size()
	if team.faction_id == -1:
		raw[L_BELONGING] = 1.0
	else:
		raw[L_BELONGING] = clampf(float(AmbitionLadder.STATE_MIN_FACTION_TEAMS - members) \
			/ float(AmbitionLadder.STATE_MIN_FACTION_TEAMS), 0.0, 1.0)
	# 尊重：野心 cap 與當前 rung 的差距（想爬多高 vs 已在哪）
	var cap: int = maxi(team.ambition_cap, 1)
	raw[L_ESTEEM] = clampf(float(team.ambition_cap - team.ambition_rung) / float(cap), 0.0, 1.0)
	# 自我實現：距立國/稱霸。未達 STATE→1；達 STATE 未達 HEGEMON→0.5；稱霸→0
	if not AmbitionLadder.milestone_met(state, team, AmbitionLadder.RUNG_STATE):
		raw[L_ACTUAL] = 1.0
	elif not AmbitionLadder.milestone_met(state, team, AmbitionLadder.RUNG_HEGEMON):
		raw[L_ACTUAL] = 0.5
	else:
		raw[L_ACTUAL] = 0.0
	return raw

# EWMA：new = α·raw + (1-α)·prev。prev 空(冷啟)視同全 0。純算術零 randf。
static func ewma_update(prev: PackedFloat32Array, raw: PackedFloat32Array) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	out.resize(N_LAYERS)
	var has_prev: bool = prev.size() == N_LAYERS
	for i in range(N_LAYERS):
		var p: float = prev[i] if has_prev else 0.0
		out[i] = URGENCY_EWMA_ALPHA * raw[i] + (1.0 - URGENCY_EWMA_ALPHA) * p
	return out
