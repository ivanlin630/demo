class_name NeedHierarchy

# 需求金字塔五層急迫度（Maslow 式）。感測器非決策者：只讀「這層還缺多少」(0..1)。
# 生存(食物)→安全(威脅)→歸屬(faction/社交)→尊重(地位/擴張)→自我實現(立國/稱霸)。
# §2 層獨立（invariants）：raw 可讀「世界訊號」(food_days/threat/cap/rung…) + 「靜態人格 trait」(如慎重/野心，
#   同 consistency_coeff 早讀 leader_values 先例)，但**不可讀其他 raw[layer] 的 urgency 值**（防循環耦合）。
#   ∴ Fix3-v2 讀領袖人格算 esteem 參考線 = 合規（trait 非他層 urgency）。
const L_SURVIVAL: int = 0
const L_SAFETY: int = 1
const L_BELONGING: int = 2
const L_ESTEEM: int = 3
const L_ACTUAL: int = 4
const N_LAYERS: int = 5

# raw 急迫度門檻（TEST VALUE）
const SURVIVAL_SATED_DAYS: float = 5.0   # TEST VALUE — 食物餘命達此→生存急迫度 0（對齊 forage floor 域）
# Fix3-v2 esteem food_ready 參考線人格化（退役死常數 ESTEEM_FOOD_REF_DAYS=3）。
# 候選2 收編：門檻函式單一 home = DecisionTerms.food_security_target(領袖慎重/野心)，此處直接呼(別雙常數)。
const URGENCY_EWMA_ALPHA: float = 0.25   # TEST VALUE — 急迫度平滑係數（同 S1 zero-randf pattern）

# §6 主敘事標籤（純顯示衍生值）：取急迫度最高層 → 給人看的簡化摘要。非決策(決策走 coeff 完整混合)。
const LABEL_SURVIVAL: String = "求生"
const LABEL_SAFETY: String = "警戒"
const LABEL_BELONGING: String = "歸附"
const LABEL_ESTEEM: String = "立業"
const LABEL_ACTUAL: String = "立國"

static func narrative_label(urgency: PackedFloat32Array) -> String:
	if urgency.size() != N_LAYERS:
		return ""
	var labels: Array = [LABEL_SURVIVAL, LABEL_SAFETY, LABEL_BELONGING, LABEL_ESTEEM, LABEL_ACTUAL]
	var best_i: int = 0
	for i in range(1, N_LAYERS):
		if urgency[i] > urgency[best_i]:
			best_i = i
	return labels[best_i]

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
	# 尊重（地位/擴張）就緒度 = 基礎穩(食/安有餘裕在意地位) × 機會(野心階梯還有空間爬)。
	# 讀世界訊號(food_days/threat/cap/rung) + 靜態人格 trait，禁讀他層 urgency（守 §2 獨立）。
	# Fix3-v2 人格化：參考線改 f(領袖慎重/野心)——退役死常數 ESTEEM_FOOD_REF_DAYS=3(過低→餓著發展→attrition 惡化)。
	# 性格只調日常風格(謹慎存久發展慢 / 野心薄糧搏發展快，層2/5)；★極端低糧由層0 boost 保底奪回求生 argmax，
	# 任何性格都不許結構性餓死（翻正舊立場「野心餓死=特色」——結構性必然餓死是 bug 非設計）。
	var _ldr: PersonData = state.persons.get(team.leader_id) if team.leader_id != -1 else null
	var _lvals: Dictionary = _ldr.values if _ldr != null else {}
	var food_ready: float = clampf(food_days / DecisionTerms.food_security_target(_lvals), 0.0, 1.0)
	var safe_ready: float = 1.0 - clampf(threat, 0.0, 1.0)
	var cap_e: int = maxi(team.ambition_cap, 1)
	var ambition_gap: float = clampf(float(team.ambition_cap - team.ambition_rung) / float(cap_e), 0.0, 1.0)
	raw[L_ESTEEM] = food_ready * safe_ready * ambition_gap
	# 自我實現（立國/稱霸）就緒度 = 接近立國條件(食流盈餘×夠人×有社會結構) × 機會(未達稱霸頂)。solo→0。
	var ff_ready: float = clampf(team.food_flow_avg / AmbitionLadder.ACCUMULATE_FLOW_MIN, 0.0, 1.0)
	var pop_ready: float = clampf(float(team.population) / float(AmbitionLadder.EXPAND_MIN_POP), 0.0, 1.0)
	var faction_ready: float = 0.0
	if team.faction_id != -1 and state.factions.has(team.faction_id) \
			and state.factions[team.faction_id].member_team_ids.size() >= 1:
		faction_ready = 1.0
	var gap_a: float = 0.0 if AmbitionLadder.milestone_met(state, team, AmbitionLadder.RUNG_HEGEMON) else 1.0
	raw[L_ACTUAL] = ff_ready * pop_ready * faction_ready * gap_a
	return raw

# §3 一致性係數 affinity 表：option → 服務哪些需求層(權重，行和≈1)。純靜態 lookup，零動態分支。
# [生存, 安全, 歸屬, 尊重, 自我實現]。全 23 REGISTRY option 覆蓋（spec §3「全 23 統一套用」）。
# TEST VALUE：語意分配（organic measure 校）。
const AFFINITY: Dictionary = {
	# 生存-class（求糧/苟活）
	"覓食":     [0.9, 0.1, 0.0, 0.0, 0.0],
	"買糧":     [0.9, 0.0, 0.1, 0.0, 0.0],
	"返家補給": [0.7, 0.2, 0.1, 0.0, 0.0],
	"紮營":     [0.6, 0.1, 0.0, 0.1, 0.2],   # 紮營=建基→間接自我實現
	"乞食":     [0.8, 0.0, 0.2, 0.0, 0.0],
	"自救建田": [0.8, 0.0, 0.0, 0.0, 0.2],   # ★復甦 R2 §2B.1：蓋產糧設施自救=生存主導(layer0)+基業(自我實現)→coeff 隨食急迫追蹤(同覓食生存層)
	# 安全-class（威脅反應）
	"survival": [0.2, 0.8, 0.0, 0.0, 0.0],   # FLEE
	"備戰":     [0.1, 0.8, 0.0, 0.1, 0.0],
	"迎戰":     [0.1, 0.6, 0.0, 0.3, 0.0],
	"求和":     [0.1, 0.7, 0.2, 0.0, 0.0],
	# 歸屬-class（社交/結盟）
	"併入":     [0.3, 0.1, 0.6, 0.0, 0.0],
	"外交":     [0.0, 0.1, 0.6, 0.1, 0.2],
	"歸建":     [0.1, 0.1, 0.8, 0.0, 0.0],
	"吸納":     [0.0, 0.0, 0.4, 0.3, 0.3],   # 吸弱鄰=擴張(尊重)+建國基(自我實現)
	# 尊重-class（地位/征服/積累）
	"訓練":     [0.0, 0.1, 0.0, 0.7, 0.2],
	"攻擊":     [0.1, 0.1, 0.0, 0.6, 0.2],
	"掠奪":     [0.4, 0.0, 0.0, 0.5, 0.1],   # 掠奪=絕境糧(生存)+武力地位(尊重)
	"佔村":     [0.3, 0.0, 0.0, 0.4, 0.3],   # 佔村=糧基+擴張+建國
	"徵收":     [0.0, 0.0, 0.2, 0.6, 0.2],
	"生產":     [0.3, 0.0, 0.0, 0.5, 0.2],   # 積累
	"貿易":     [0.2, 0.0, 0.1, 0.6, 0.1],   # 致富=尊重(地位)
	"囤貨":     [0.1, 0.0, 0.0, 0.7, 0.2],
	# 自我實現-class（建國/稱霸/定居長治）
	"建設":     [0.1, 0.0, 0.0, 0.3, 0.6],   # 建設=據點基業→自我實現
	"駐守":     [0.2, 0.1, 0.1, 0.1, 0.5],   # 定居長治
}

const _AFFINITY_UNIFORM: Array = [0.2, 0.2, 0.2, 0.2, 0.2]

# affinity 查表（未列 option→均勻，coeff 對其近中性）。純 lookup。回 Array（const Dict value 型別）。
static func affinity_of(opt: String) -> Array:
	if AFFINITY.has(opt):
		return AFFINITY[opt]
	return _AFFINITY_UNIFORM

# option 主 affinity 層(argmax)。空/未知→-1。純 lookup（診斷 probe/S3 用）。
static func main_layer_of(opt: String) -> int:
	if opt == "": return -1
	var aff: Array = affinity_of(opt)
	var best: int = 0
	for i in range(1, N_LAYERS):
		if float(aff[i]) > float(aff[best]): best = i
	return best

# §3 軟降權：coeff = clampf(1 - steepness·(1-alignment), FLOOR, 1)。純算術零分支。
# alignment = Σ affinity[opt]·urgency ∈[0,1]（affinity 行和≈1、urgency≤1 → alignment≤1）。
# §4 steepness 由人格：謹慎↑陡(遠層壓極重)、野心↓陡(狂人遠層仍有機會)。軟降權不歸零(FLOOR)。
const COEFF_FLOOR: float = 0.15      # TEST VALUE — 軟降權下限（永不歸零=非硬排除）
const STEEP_BASE: float = 0.5        # TEST VALUE — 降權陡度基值
const STEEP_CAUTION: float = 0.4     # TEST VALUE — 慎重加陡（謹慎者遠層壓重）
const STEEP_AMBITION: float = 0.35   # TEST VALUE — 野心減陡（狂人遠層仍可跳階）

static func consistency_coeff(opt: String, urgency: PackedFloat32Array, leader_values: Dictionary) -> float:
	if urgency.size() != N_LAYERS:
		return 1.0   # 冷啟(未更新)→中性不調變
	var aff: Array = affinity_of(opt)
	var alignment: float = 0.0
	for i in range(N_LAYERS):
		alignment += float(aff[i]) * urgency[i]
	alignment = clampf(alignment, 0.0, 1.0)
	var caution: float = float(leader_values.get("慎重", 0.5))
	var ambition: float = float(leader_values.get("野心", 0.5))
	var steepness: float = clampf(STEEP_BASE + caution * STEEP_CAUTION - ambition * STEEP_AMBITION, 0.0, 1.0)
	return clampf(1.0 - steepness * (1.0 - alignment), COEFF_FLOOR, 1.0)

# EWMA：new = α·raw + (1-α)·prev。prev 空(冷啟)視同全 0。純算術零 randf。
static func ewma_update(prev: PackedFloat32Array, raw: PackedFloat32Array) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	out.resize(N_LAYERS)
	var has_prev: bool = prev.size() == N_LAYERS
	for i in range(N_LAYERS):
		var p: float = prev[i] if has_prev else 0.0
		out[i] = URGENCY_EWMA_ALPHA * raw[i] + (1.0 - URGENCY_EWMA_ALPHA) * p
	return out
