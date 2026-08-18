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
# ★糧流感知 Slice A（§4）：safe_ratio=runway/ETA 調制 persist（存活持守）。只 TASK_BUILD（有真 ETA）；
# 5 種無 ETA（CONSTRUCT/UPGRADE/EXPAND/SETTLE/MIGRATE）走原 persist（safe_ratio 不介入）。
const RATIO_SAFE: float = 2.0            # TEST VALUE — runway≥此×ETA→safe_factor=1（糧充裕 persist 全維持）
const RATIO_FLOOR_BASE: float = 0.5      # TEST VALUE — ratio_floor 人格基準
const RATIO_FLOOR_SPAN: float = 0.4      # TEST VALUE — 人格對 floor 的餘裕幅度（務實高 floor 早放/固執低 floor 撐久=team14 根治）
const RATIO_FLOOR_MIN: float = 0.1
const RATIO_FLOOR_MAX: float = 1.0

# ★active-construction persist floor（founding-completion fix，spec 2026-07-30，坐實根=bed dump 0b6523db
#   construct.stall=29101/complete_build=0：remote founding 子隊 cold-start(progress≈0)→base_persist<
#   PERSIST_HOLD_THRESHOLD(0.1)→persist.hold gate 不 fire→routine argmax(覓食/外交@PRIO_DISPATCH,ct_reason=unified)
#   搶班→progress 永不累積=惡性循環）。施工中隊(TASK_BUILD AND construction_ticks_left>0)hard-floor persist_eff≥此。
# ★>PERSIST_HOLD_THRESHOLD(task_arbiter 0.1)+margin → persist.hold 擋 routine 搶班 → 留 TASK_BUILD → 完工。
# ★均一 floor 非 floor×lean（R² 判合理例外，§4）：floor×lean 令務實隊 0.15×0.2=0.03<原 threshold 0.1=該人格永 0%
#   完工=引擎結構死角剛好綁 personality 非合理人格分化；pipeline 完整性 > 人格分化（同 crisis handling 不分人格精神）。
# ★hard floor 蓋過 safe_factor（§3）：crisis/survival/threat 自有 task_arbiter ≥PRIO_THREAT bypass 打斷施工
#   （team14 餓死照放手=crisis 路徑非靠 persist 降 floor 下）→ floor 只擋 routine 覓食/外交、不擋 crisis=不破 team14。
const CONSTRUCTION_ACTIVE_FLOOR: float = 0.15   # TEST VALUE — >PERSIST_HOLD_THRESHOLD(0.1)+margin

# 開放式/無承諾動作（progressive-only gate 排除 → persist=0，走既有 timeout）。
const NON_PROGRESSIVE: Array = [TeamData.TASK_IDLE, TeamData.TASK_FLEE]

# ★settlement S2b：TASK_BUILD 的工地 tile——優先 corvee_site（自己起的 L0→L1 工程、團可能離開覓食後回頭），
# 否則腳下（remote founding 子隊 on-site / 其他 build）。修「團離開→persist 查 team.tile_pos 錯 tile→floor miss→
# abandoned corvee stall forever」根（self-knowledge corvee_site 非 god-view）。
static func _build_tile(state: WorldState, team: TeamData) -> HexTileData:
	if team.corvee_site != Vector2i(-1, -1):
		var ct: HexTileData = state.world.tiles.get(team.corvee_site.x * 1000 + team.corvee_site.y)
		if ct != null and ct.construction_team_id == team.team_id and ct.construction_ticks_left > 0:
			return ct   # 自己未完 corvee 工地（離開仍認得）
	return state.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)

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
	var base_persist: float = clampf(PERSIST_CAP * progress * lean, 0.0, PERSIST_CAP)
	# ★糧流感知 Slice A（§4）：TASK_BUILD 有真 ETA → safe_ratio 調制（乘法縮放非硬塌，避 regression 向凍）。
	#   5 種無 ETA task 走原 persist（safe_ratio 不介入，維持 Slice 1-4 行為）。
	if team.current_task == TeamData.TASK_BUILD:
		var sf: float = _safe_factor(state, team, stick, flex)
		var computed: float = base_persist * sf   # persist_effective = persist × safe_factor（糧見底→sf→0→放手求生）
		# ★active-construction hard floor：施工真進行中(construction_ticks_left>0)→persist≥CONSTRUCTION_ACTIVE_FLOOR
		#   （蓋過 safe_factor；cold-start/低 lean 也擋 routine argmax 搶班；crisis 自有 ≥THREAT bypass，不靠此）。
		var tile: HexTileData = _build_tile(state, team)   # ★S2b：corvee_site 優先（離開工地仍受保護、回頭續建）
		if tile != null and tile.construction_ticks_left > 0:
			return maxf(computed, CONSTRUCTION_ACTIVE_FLOOR)
		return computed
	return base_persist

# ★safe_factor（§4b）：safe_ratio=runway/ETA → [0,1]，人格 ratio_floor 餘裕。糧充裕→1(黏)；見底→0(放手)。
# 乘法縮放連續（非硬門檻塌=避 PROGRESSIVE_HOLD attrition→0 向凍 regression）。純算術零 RNG。
static func _safe_factor(state: WorldState, team: TeamData, stick: float, flex: float) -> float:
	var tile: HexTileData = _build_tile(state, team)   # ★S2b：corvee_site 優先
	if tile == null or tile.construction_ticks_left <= 0:
		return 1.0   # 無真施工中 → 不調制（safe）
	var eta_days: float = float(tile.construction_ticks_left) / maxf(float(team.population), 1.0)   # 粗估:剩 person-ticks/pop
	if eta_days <= 0.0:
		return 1.0
	var safe_ratio: float = team.food_runway / eta_days   # runway 撐得到完成否
	# ★人格 ratio_floor（team14 根治）：務實/機會(flex 高)→floor 高(早放留餘裕);固執/恆心(stick 高)→floor 低(撐久 edge-riding)。
	var ratio_floor: float = clampf(RATIO_FLOOR_BASE + (flex - stick) * RATIO_FLOOR_SPAN, RATIO_FLOOR_MIN, RATIO_FLOOR_MAX)
	if RATIO_SAFE <= ratio_floor:
		return 1.0 if safe_ratio >= RATIO_SAFE else 0.0   # 退化防除零
	return clampf((safe_ratio - ratio_floor) / (RATIO_SAFE - ratio_floor), 0.0, 1.0)

# ★Slice 2 進度信號：施工中隊用真 construction-tick 進度（sunk=(total−left)/total，隨 tick 倒數更新=新鮮，
#   解決決策層 cadence(1日) vs 執行層(每tick) 落差）；非施工 committed 動作退回 committed 時間佔比 proxy。
static func _progress(state: WorldState, team: TeamData) -> float:
	if team.current_task == TeamData.TASK_BUILD:
		var tile: HexTileData = _build_tile(state, team)   # ★S2b：corvee_site 優先
		if tile != null and tile.construction_ticks_left > 0:
			var total: int = OutpostSystem.construction_ticks_total(tile)
			if total > 0:
				return clampf(float(total - tile.construction_ticks_left) / float(total), 0.0, 1.0)
	# fallback：committed 時間佔比（戰略意圖/campaign 等無 tile 進度的 committed 動作）。
	var elapsed: int = state.world.current_tick - team.task_start_tick
	var horizon: float = COMMIT_HORIZON_DAYS * float(WorldState.TICKS_PER_DAY)
	return clampf(float(elapsed) / maxf(horizon, 1.0), 0.0, 1.0)
