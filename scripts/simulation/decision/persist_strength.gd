class_name PersistStrength

# ★持守統一 Slice 1（HOW spec 2026-07-28 §4/§5/§8）：決策層持守強度統一公式，取代 5 flat commitment bonus。
# 持守強度 = 人格加權(沉沒成本 sunk + 前瞻 prospect)，progressive-only，clamp ≤ PERSIST_CAP < 危機量級。
#
# ★憲法對齊（§9）：
#   - utility weigh 非 scripted：persist 是 rank 偏置權重（+util），非寫死 edge。
#   - 人格 WEIGH 不 GATE：人格調 sunk/prospect 混合比 = 連續權重，非硬類別閘。
#   - 非硬鎖（latch 反例）：persist 是 util 偏置、max PERSIST_CAP < 危機量級（survival boost ~2.0）→ 危機永遠可打斷、
#     世界照演化——**永不凍世界**（≠ latch 的 skip-reeval 硬鎖）。決策層 bonus 加在 score 上、隊照跑決策。
#
# ★Slice 1 = 決策層自算自用（rank cadence 算 sunk=committed 時間佔比 proxy）；Slice 2 補真進度事件新鮮度
#   （construction-tick 倒數/抵達時更新，非只 cadence）。progressive-only gate 排開放式（FLEE）/無承諾（IDLE）。

const PERSIST_CAP: float = 0.3   # TEST VALUE — 持守偏置上限（≈舊 COMMITMENT_BONUS max，< 危機量級 survival boost ~2.0=永可打斷）
const COMMIT_HORIZON_DAYS: float = 5.0   # TEST VALUE — sunk-cost 時間視野（committed 越久越黏，飽和於此天數）

# 開放式/無承諾動作（progressive-only gate 排除 → persist=0，走既有 timeout）。
const NON_PROGRESSIVE: Array = [TeamData.TASK_IDLE, TeamData.TASK_FLEE]

# 算持守強度 + 寫 team.persist_strength（決策層 rank cadence 呼）。純算術零 RNG。
static func compute(state: WorldState, team: TeamData) -> float:
	var ps: float = _value(state, team)
	team.persist_strength = ps
	return ps

# 純算（不寫欄）——單測/唯讀用。
static func _value(state: WorldState, team: TeamData) -> float:
	if state == null or team == null:
		return 0.0
	if team.current_task in NON_PROGRESSIVE:
		return 0.0   # progressive-only gate：開放式/無承諾動作不套持守（走既有 timeout）
	# ★沉沒成本（往回看，已投入越多越黏）：Slice 2 補真 construction-tick progress（施工中隊用實際 person-tick 進度，
	#   隨 construction tick 倒數更新=新鮮；非施工 committed 動作退回時間佔比 proxy）。
	var progress: float = _progress(state, team)
	# ★人格加權（weigh 非 gate，連續）：commitment_lean = stick(慎重/義氣 死硬完成) − flex(貪婪/野心 靈活轉換)。
	#   固執型 → lean 高（死守沉沒成本）；務實型 → lean 低（前瞻不夠近就轉換）。Slice 2 加顯式 prospect(離完成距離)
	#   讓務實型「近完成才黏」；Slice 1 決策層階段用 lean 標度沉沒成本（人格分化持守強度）。
	# （人格 key 用既有 team.leader.values；spec 的 固執/機會 不存在→映 慎重·義氣 / 貪婪·野心。）
	var vals: Dictionary = {}
	var leader = state.persons.get(team.leader_id)
	if leader != null:
		vals = leader.values
	var stick: float = clampf((float(vals.get("慎重", 0.5)) + float(vals.get("義氣", 0.5))) * 0.5, 0.0, 1.0)
	var flex: float = clampf((float(vals.get("貪婪", 0.5)) + float(vals.get("野心", 0.5))) * 0.5, 0.0, 1.0)
	var lean: float = clampf(0.5 + (stick - flex), 0.2, 1.0)   # 固執→1.0(死硬)/務實→0.2(靈活)/中性→0.5
	return clampf(PERSIST_CAP * progress * lean, 0.0, PERSIST_CAP)

# ★Slice 2 進度信號：施工中隊用真 construction-tick 進度（sunk=(total−left)/total，隨 tick 倒數更新=新鮮，
#   解決決策層 cadence(1日) vs 執行層(每tick) 落差）；非施工 committed 動作退回 committed 時間佔比 proxy。
static func _progress(state: WorldState, team: TeamData) -> float:
	if team.current_task == TeamData.TASK_BUILD:
		var tile: HexTileData = state.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)
		if tile != null and tile.construction_ticks_left > 0:
			var total: int = OutpostSystem.construction_ticks_total(tile)
			if total > 0:
				return clampf(float(total - tile.construction_ticks_left) / float(total), 0.0, 1.0)
	# fallback：committed 時間佔比（戰略意圖/campaign 等無 tile 進度的 committed 動作）。
	var elapsed: int = state.world.current_tick - team.task_start_tick
	var horizon: float = COMMIT_HORIZON_DAYS * float(WorldState.TICKS_PER_DAY)
	return clampf(float(elapsed) / maxf(horizon, 1.0), 0.0, 1.0)
