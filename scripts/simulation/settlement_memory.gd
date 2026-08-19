class_name SettlementMemory

# ★§4c 選址結果反饋迴路（思考層四缺件之一：第一條反饋邊）。
# 建點/認領的結局寫回【自己 leader 的 memory】、下次選址讀回 → 同團第二次選址避開失敗地。
# ★self-knowledge：只寫/讀自己 leader 的記憶，★禁全域黑名單（別團不受影響、記憶隨人走）。
# ★禁永久黑名單：線性衰減、過期歸零（同 join_rejected cooldown 精神，但選址是低頻高成本決策→窗長得多）。
# 零 RNG、純算術。寫入走 NpcAiSystem.write_site_memory（薄函式，不碰 p.relations）。

const SITE_FAILED: String = "site_failed"     # 棄置/衰敗/主動棄村＝這塊地沒撐住
const SITE_THRIVED: String = "site_thrived"   # 據點升級完工＝這塊地養得起發展
const SITE_MEMORY_INTENSITY: float = 0.5      # 沿用 join_rejected 既有 weight 慣例
const SITE_MEMORY_TTL_DAYS: float = 30.0      # TEST VALUE — 一季；選址=低頻高成本決策，記憶該跨季節
                                              #（對照 JOIN_REJECT_COOLDOWN_TICKS=2 日：那是「此刻不可行」，這是「這地不好」）

# 寫：只寫存活隊的存活 leader（團滅不寫＝人死沒人記得，也避免寫進已 erase 的 person）。
static func record_site_outcome(state: WorldState, team: TeamData, tile: HexTileData, outcome: String) -> void:
	if state == null or team == null or tile == null:
		return
	var leader: PersonData = state.persons.get(team.leader_id)
	if leader == null:
		return   # leader 已亡/未設 → 沒人記得
	NpcAiSystem.new().write_site_memory(leader, outcome, tile.tile_id,
		state.world.current_tick, SITE_MEMORY_INTENSITY)
	# ★tap（憲法級）：寫端計數。p.memory 是 MEMORY_MAX FIFO 且與人際記憶共用 → site 記憶很可能
	# 還沒到 TTL 就被擠掉；write vs applied 的落差＝eviction 吞掉多少反饋（否則此 slice 靜默失效無從判定）。
	if Probe.enabled:
		Probe.bump("site_memory.write")
		Probe.bump("site_memory.write." + outcome)

# 讀：該 leader 對某 tile 的選址記憶調整量（正=好地、負=壞地、0=無記憶或已過期）。
# 調整量 = Σ intensity × max(0, 1 − 已過天數/TTL)（線性衰減、過期歸零非永久黑名單）。
# failed 取負、thrived 取正；同一地多次結局累加（去過兩次都失敗＝更避開）。
static func site_bias(state: WorldState, team: TeamData, tile_id: int) -> float:
	if state == null or team == null:
		return 0.0
	var leader: PersonData = state.persons.get(team.leader_id)
	if leader == null:
		return 0.0
	var now: int = state.world.current_tick
	var bias: float = 0.0
	for m in leader.memory:
		var t: String = String(m.get("type", ""))
		if t != SITE_FAILED and t != SITE_THRIVED:
			continue
		if int(m.get("subject_id", -1)) != tile_id:
			continue
		var days: float = float(now - int(m.get("tick", 0))) / float(WorldState.TICKS_PER_DAY)
		var fresh: float = maxf(0.0, 1.0 - days / SITE_MEMORY_TTL_DAYS)   # 線性衰減、過期=0
		if fresh <= 0.0:
			continue
		var w: float = float(m.get("intensity", SITE_MEMORY_INTENSITY)) * fresh
		bias += w if t == SITE_THRIVED else -w
	return bias

# ★下界 0.25 非 0（merge-gate 訂正 B）：兩次同地失敗 → bias=-1.0 → 若下界 0 則乘子=0 →
# settle_site_quality/camp_drive 直接歸零＝【絕對門檻 pre-empt 引擎】（瀕餓隊連唯一去處都不能紮）
# ＝patch-gate 病型、違「禁硬門檻回潮」。0.25＝記憶重度折價但仍可被絕境秤贏（湧現過濾非門檻）。
const QUALITY_FLOOR: float = 0.25   # TEST VALUE — 記憶折價下限（保留被絕境壓過的可能）
const QUALITY_CEIL: float = 2.0

# 選址品質乘子（掛既有選址 util 的地點品質項、★不新增獨立 term 線）：
# bias 正→>1（好地更值得）、負→<1（壞地折價）、無記憶→1.0。
# ★tap（憲法級全量暫態可觀測性）：乘子 != 1.0＝記憶真的作用到決策 → bump applied；
#   與寫端 site_memory.write 對照可量出 MEMORY_MAX FIFO eviction 吞掉多少反饋。
static func quality_multiplier(state: WorldState, team: TeamData, tile_id: int) -> float:
	var mult: float = clampf(1.0 + site_bias(state, team, tile_id), QUALITY_FLOOR, QUALITY_CEIL)
	if Probe.enabled and not is_equal_approx(mult, 1.0):
		Probe.bump("site_memory.applied")
	return mult
