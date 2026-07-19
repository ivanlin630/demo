class_name MovementSystem

# world-hex 移動成本 = 遭遇戰動作時間 × 遭遇戰地圖尺度（TimeScale 骨架連動，錨①，=240=1天/hex）
# 禁另塞倍率（invariant Time#2）；倍速靠 GUI 觀看組不碰物理。
const BASE_MOVE_TICKS: int = TimeScale.MOVE_TICKS_PER_HEX
const MIN_MOVE_TICKS: int  = BASE_MOVE_TICKS / 3
const MAX_MOVE_TICKS: int  = BASE_MOVE_TICKS * 3
const NAMED_WEIGHT: int    = 3   # named 成員速度加權（隊速 = named×3 + 健康匿名×1 + 傷兵×0.5 的平均）

const TERRAIN_SPEED_MULT: Dictionary = {
	"plains":   1.0,
	"forest":   0.7,
	"mountain": 0.4,
}

const BASE_CARRY: float   = 10.0   # TEST VALUE
const MOUNT_BONUS: float  = 15.0   # TEST VALUE
const WAGON_BONUS: float  = 40.0   # TEST VALUE
# mount/wagon 速度公式參數（TEST VALUE）
const MOUNT_SPEED_FACTOR: float = 2.0    # mount_ratio 速度加成係數
const MOUNT_SIZE_CAP: float     = 50.0   # size_penalty 飽和點（騎兵數）
const MOUNT_SIZE_PENALTY: float = 0.2    # 大團騎兵協調混亂最大懲罰
const WAGON_SPEED_PENALTY: float = 0.3   # wagon_ratio 速度懲罰係數

const WAGON_TERRAIN_MULT: Dictionary = {
	"plains": 0.9, "forest": 0.4, "mountain": 0.2
}

# elapsed 積分（time-scale wave slice B，2026-07-05）：`move_tick_acc += elapsed_ticks`（真經過時間，
# near=NEAR_CADENCE=10、far=FAR_ZONE_INTERVAL=100，caller 傳實際 cadence 非硬編）→ far 每 100-tick
# 呼叫補回 100 tick 的移動預算 = 與 near 同速（修 far 10× 稀釋，envoy/trade 跨格旅程到得了）。
# 多格步進（疏非慢非笨）：一次呼叫 acc>=cost 時迴圈步進多格、每步 acc-=cost 保餘數（非 acc=0 丟零頭）。
# ★RNG 流神聖：迴圈多次呼 _step_team → randf 消耗序改變 = 預期行為變（far 移對＝世界不同）；
#   確定性仍守（同 seed 同結果）。禁在迴圈內先濾後算/memoize 重排 randf 消耗序。
func process(state: WorldState, team_ids: Array,
		time_mult: float = 1.0, elapsed_ticks: int = WorldState.TICKS_PER_HOUR) -> Dictionary:
	# 到達重追蹤：ESCORT/MERGE(order_target)/JOIN(social_target) 每 tick 追目標現位。
	# S-A seam 修 A：MERGE/JOIN 原用 dispatch 靜態快照→活躍大隊(absorber/host)移走→merger 走空 tile→
	# pair_seen=0(從不 co-locate)。比照 ESCORT 追移動目標。（BEG 短程暫不納。）
	for tid in team_ids:
		if not state.teams.has(tid):
			continue
		var team: TeamData = state.teams[tid]
		var tgt_id: int = -1
		if team.current_task == TeamData.TASK_ESCORT or team.current_task == TeamData.TASK_MERGE:
			tgt_id = team.order_target_id
		elif team.current_task == TeamData.TASK_JOIN:
			tgt_id = team.social_target
		if tgt_id == -1:
			continue
		var target: TeamData = state.teams.get(tgt_id)
		if target == null:
			TaskArbiter.release(team)   # 目標消失 → 任務結束
			team.order_target_id = -1
		else:
			# god-view 位置根治：逐 tick 追 belief last-seen（視野內刷新跟上 / 斷視線→last-seen→撲空逃脫）。
			# belief_pos 內部分流（同-faction MERGE→known_member_states）；(-1,-1)→保持原 move_target（★不退自身）。
			var bpos: Vector2i = BeliefSystem.belief_pos(state, tid, tgt_id)
			if bpos != Vector2i(-1, -1):
				team.move_target = bpos
	var arrived: Array = []
	var moved: Array = []
	for tid in team_ids:
		if not state.teams.has(tid):
			continue
		var team: TeamData = state.teams[tid]
		# 居民鎖：PRODUCE + 在自家 outpost + task 不在脫離清單
		if team.tags.has(TeamData.TAG_PRODUCE):
			var fai := FactionAISystem.new()
			# S-A：TASK_MERGE 納脫離清單（原缺→PRODUCE 居民 merger 被鎖在 outpost→永不到 absorber→pair_seen=0；
			# JOIN 本在清單=能離開,MERGE 漏=asymmetry 根。整併=脫離現據點併大隊,語意同 JOIN 該放行）。
			if fai._is_resident_team(state, team) \
					and team.current_task not in [TeamData.TASK_FLEE, TeamData.TASK_JOIN, TeamData.TASK_MERGE, TeamData.TASK_REVOLT, TeamData.TASK_MIGRATE, TeamData.TASK_PREPARE]:
				continue
		var _dbg_merge: bool = Probe.enabled and team.current_task == TeamData.TASK_MERGE
		if _dbg_merge: Probe.bump("merge.mv_reached")   # DIAG：TASK_MERGE 隊過居民鎖，進 movement
		if team.combat_target != -1:
			if _dbg_merge: Probe.bump("merge.mv_block_combat")   # DIAG：combat_target 擋移動
			continue
		# flee 位移根治：FLEE 隊(move_target 未設/已到達)+有威脅逃離位→算反向 away-tile（純幾何+可達，零 randf）。
		# flee_from_pos==(-1,-1)（無威脅情報）→ 不設 target → 下方 continue，靠 release 收（不亂逃）。
		if team.current_task == TeamData.TASK_FLEE and team.flee_from_pos != Vector2i(-1, -1) \
				and (team.move_target == Vector2i(-1, -1) or team.tile_pos == team.move_target):
			team.move_target = _flee_away_tile(state, team, team.flee_from_pos)
		# null-belief-flee backstop（冗餘 defense，修 B）：FLEE 但威脅無座標(flee_from_pos=-1)→無法算逃向
		# → release 回 IDLE re-rank（非下方 continue-freeze 卡 task=逃跑 餓死）。修 A applicability-gate 後正常
		# 不會無座標選 FLEE；此為 timing 邊角 backstop（FLEE 設後 belief 過期成 positionless）。
		if team.current_task == TeamData.TASK_FLEE and team.flee_from_pos == Vector2i(-1, -1):
			TaskArbiter.release(team)
			continue
		# A2c-2 折入：戰略移動 move_target 改由 arbiter-owned set_strategic_move 於 movement 前設
		#（sim_runner._step2a_strategic_move）→ 此處不再直讀 strategic_assignments（bypass 收攏）。
		if team.move_target == Vector2i(-1, -1):
			if _dbg_merge: Probe.bump("merge.mv_no_target")   # DIAG：move_target 未設
			continue
		if _dbg_merge: Probe.bump("merge.mv_moving")   # DIAG：TASK_MERGE 隊實際行軍
		team.move_tick_acc += elapsed_ticks
		var old_target: Vector2i = team.move_target
		# 多格迴圈：acc>=cost 逐格步進、每步 acc-=cost 保餘數（疏非慢非笨）。
		# max_steps 上限 = elapsed/MIN_MOVE_TICKS（cost 恒 clamp≥MIN → 防病態無限迴圈）。
		var max_steps: int = maxi(1, elapsed_ticks / MIN_MOVE_TICKS)
		var did_move: bool = false
		var steps: int = 0
		while steps < max_steps:
			var cost: int = _move_cost(state, team, time_mult)   # 每格重算（地形變）
			if team.move_tick_acc < cost:
				break
			team.move_tick_acc -= cost
			if _step_team(state, team):
				did_move = true
			steps += 1
			# 到達/stuck → _step_team 清 move_target → 停（既有到點/相遇語意保留）
			if team.move_target == Vector2i(-1, -1):
				break
		# cost 上限節流下 acc 可能仍 ≥cost（本 window 已步不動）→ clamp 至 MAX_MOVE_TICKS
		# 只留最多一格昂貴地形的餘數，丟不可能兌現的超額（非丟合法零頭）。
		team.move_tick_acc = mini(team.move_tick_acc, MAX_MOVE_TICKS)
		if did_move:
			moved.append(tid)
			# arrived = 走到原 move_target（_step_team 內到達會清 move_target）
			if team.tile_pos == old_target:
				arrived.append(tid)
				# D0 探針：到達點 ∈ strategic_assignments 值 = 戰略移動到達（sa_pos）。
				# 折後 move_target 由 set_strategic_move 設（仍 sa_pos），assignments 未變 → 計數保。
				if Probe.enabled and old_target in team.strategic_assignments.values():
					Probe.bump("strat.expand_reached")
	return { "arrived": arrived, "moved": moved }

func get_effective_mounts(team: TeamData) -> int:
	return mini(int(team.resources.get("mounts", 0)), team.population)

func get_effective_wagons(team: TeamData) -> int:
	# 1 人 1 獸：wagon 用剩餘人口（pop - effective_mounts）上限
	var rem: int = team.population - get_effective_mounts(team)
	return mini(int(team.resources.get("wagons", 0)), maxi(rem, 0))

func get_carry_capacity(team: TeamData) -> float:
	return team.population * BASE_CARRY \
		+ get_effective_mounts(team) * MOUNT_BONUS \
		+ get_effective_wagons(team) * WAGON_BONUS

func calc_total_weight(team: TeamData) -> float:
	var total: float = 0.0
	for key in team.resources:
		total += maxf(float(team.resources[key]), 0.0) * _resource_weight(key)
	return total

# 剩餘載重空間（weight 單位）= carry_cap − 當前總重，floor 0（防負/除零）。
func remaining_carry_space(team: TeamData) -> float:
	return maxf(get_carry_capacity(team) - calc_total_weight(team), 0.0)

# 某 res 還能裝幾個（依 _resource_weight；重量 0 的工具→大數不設限）。
func carry_space_for_res(team: TeamData, res: String) -> int:
	var w: float = _resource_weight(res)
	if w <= 0.0:
		return 1 << 30
	return int(remaining_carry_space(team) / w)

func _resource_weight(key: String) -> float:
	match key:
		"food":              return 0.1
		"weapon_melee_low":  return 2.0
		"weapon_melee_high": return 3.0
		"armor_low":         return 4.0
		"armor_high":        return 7.0
		"mounts", "wagons":  return 0.0  # 搬運工具本身不計重
		"coin":              return 0.0  # 錢幣不計入載重（WS-3 carry cap 不能因囤 coin 卡死進貨）
		_:                   return 1.0

func _move_cost(state: WorldState, team: TeamData, time_mult: float = 1.0) -> int:
	var speed: float = _compute_team_speed(state, team) * time_mult
	var tile_id: int = team.tile_pos.x * 1000 + team.tile_pos.y
	if state.world.tiles.has(tile_id):
		var terrain: String = (state.world.tiles[tile_id] as HexTileData).terrain
		speed *= TERRAIN_SPEED_MULT.get(terrain, 1.0)
	# 疲勞懲罰
	if team.fatigue >= 1.0:
		speed *= 0.3
	elif team.fatigue > 0.5:
		speed *= (1.0 - team.fatigue * 0.4)
	# 超載懲罰
	var cap: float = get_carry_capacity(team)
	var weight: float = calc_total_weight(team)
	if weight > cap:
		speed *= (cap / weight)
	# 車輛地形懲罰
	var wagons: int = get_effective_wagons(team)
	if wagons > 0:
		var tile_id2: int = team.tile_pos.x * 1000 + team.tile_pos.y
		var tile2 = state.world.tiles.get(tile_id2)
		var terrain2: String = tile2.terrain if tile2 else "plains"
		speed *= WAGON_TERRAIN_MULT.get(terrain2, 1.0)
	return clamp(int(round(float(BASE_MOVE_TICKS) / maxf(speed, 0.01))), MIN_MOVE_TICKS, MAX_MOVE_TICKS)

func _compute_team_speed(state: WorldState, team: TeamData) -> float:
	var base_speed: float = _compute_base_team_speed(state, team)
	return base_speed * _compute_mount_bonus(team) * _compute_wagon_penalty(team)

# mount 速度加成：(1 + ratio*FACTOR) * size_penalty
func _compute_mount_bonus(team: TeamData) -> float:
	if team.population <= 0: return 1.0
	var em: int = get_effective_mounts(team)
	if em == 0: return 1.0
	var ratio: float = float(em) / float(team.population)
	var size_penalty: float = 1.0 - clampf(float(em) / MOUNT_SIZE_CAP, 0.0, 1.0) * MOUNT_SIZE_PENALTY
	return (1.0 + ratio * MOUNT_SPEED_FACTOR) * size_penalty

# wagon 速度懲罰：1 - ratio*PENALTY（無 size penalty）
func _compute_wagon_penalty(team: TeamData) -> float:
	if team.population <= 0: return 1.0
	var ew: int = get_effective_wagons(team)
	if ew == 0: return 1.0
	var ratio: float = float(ew) / float(team.population)
	return 1.0 - ratio * WAGON_SPEED_PENALTY

func _compute_base_team_speed(state: WorldState, team: TeamData) -> float:
	var total_speed: float = 0.0
	var total_count: int = 0
	var named_ids: Array = team.named_members.duplicate()  # duplicate() — 避免直接修改 team.named_members
	if team.leader_id != -1:
		named_ids.append(team.leader_id)
	var named_found: int = 0
	for pid in named_ids:
		var p = state.persons.get(pid)
		if p != null:
			total_speed += p.get_effective_speed() * NAMED_WEIGHT
			total_count += NAMED_WEIGHT
			named_found += 1
	# anon 依 tier 各自 speed（取代舊統一 1.0）
	for tier in AnonTierSystem.TIER_ORDER:
		var n: int = int(team.anon_tiers.get(tier, 0))
		if n > 0:
			total_speed += float(n) * float(AnonTierSystem.TIER_STATS[tier]["speed"])
			total_count += n
	total_speed += float(team.wounded) * 0.5
	total_count += team.wounded
	if total_count == 0:
		return 1.0
	return total_speed / float(total_count)

# A* 路徑步進，_on_arrival 介面不變
func _step_team(state: WorldState, team: TeamData) -> bool:
	var old_pos: Vector2i = team.tile_pos
	if team.tile_pos == team.move_target:
		team.move_target = Vector2i(-1, -1)
		_on_arrival(state, team)
		return false
	var next_pos: Vector2i = _calc_next_step(state, team.tile_pos, team.move_target)
	# next_pos == 原地 → 無路徑（隔絕/被山阻），team stuck — cancel target
	if next_pos == team.tile_pos:
		print("[Move] Team %d stuck at (%d,%d) target=(%d,%d), task=%s, sa=%s" % [
			team.team_id, team.tile_pos.x, team.tile_pos.y,
			team.move_target.x, team.move_target.y,
			team.current_task, str(team.strategic_assignments)])
		team.move_target = Vector2i(-1, -1)
		return false
	team.last_tile_pos = old_pos   # 記錄上一步位置（observe_velocity 用）
	team.tile_pos = next_pos
	if team.tile_pos == team.move_target:
		team.move_target = Vector2i(-1, -1)
		_on_arrival(state, team)
	return team.tile_pos != old_pos

# A* 下一步：回傳 path[1]（下一格）；無路徑回原地
func _calc_next_step(state: WorldState, from: Vector2i, to: Vector2i) -> Vector2i:
	var result: Dictionary = PathSystem.find_path(state, from, to)
	if result.path.is_empty(): return from
	if result.path.size() > 1: return result.path[1]
	return result.path[0]

# 抵達只更新占用，不自動建立據點（據點建立為獨立 NPC 決策）
func _on_arrival(state: WorldState, team: TeamData) -> void:
	var tile_id: int = team.tile_pos.x * 1000 + team.tile_pos.y
	if state.world.tiles.has(tile_id):
		var tile: HexTileData = state.world.tiles[tile_id]
		tile.occupied_by = team.team_id
		# 撿 abandoned_coin（有 owner 則僅 owner 可撿）
		if tile.abandoned_coin > 0.0:
			if tile.outpost_owner == -1 or tile.outpost_owner == team.team_id:
				AnonTreasuryBank.deposit(team, tile.abandoned_coin, "pickup_abandoned")
				print("[Coin] Team%d 撿 %.0f 遺財" % [team.team_id, tile.abandoned_coin])
				tile.abandoned_coin = 0.0
	print("[Move] Team %d 抵達 (%d,%d)" % [team.team_id, team.tile_pos.x, team.tile_pos.y])
	# NPC 抵達自家 outpost → 自動領存公庫（玩家手動）
	if team.leader_id != state.player_id and state.world.tiles.has(tile_id):
		var own_tile: HexTileData = state.world.tiles[tile_id]
		if own_tile.outpost_owner == team.team_id and own_tile.outpost_level > 0:
			FactionAISystem.new()._evaluate_storage_visit(state, team, own_tile)
	# C: 基建子隊抵達 → 依 task 啟動施工
	if team.current_task in [TeamData.TASK_CONSTRUCT, TeamData.TASK_UPGRADE, TeamData.TASK_EXPAND]:
		OutpostSystem.new().begin_subteam_construction(state, team)

func _get_neighbors(pos: Vector2i) -> Array:
	return [
		pos + Vector2i(1, 0),  pos + Vector2i(-1, 0),
		pos + Vector2i(0, 1),  pos + Vector2i(0, -1),
		pos + Vector2i(1, -1), pos + Vector2i(-1, 1),
	]

func _hex_dist(a: Vector2i, b: Vector2i) -> int:
	var dx := b.x - a.x
	var dy := b.y - a.y
	return (abs(dx) + abs(dx + dy) + abs(dy)) / 2

# ────────── flee 位移根治（純幾何+可達，零 randf）──────────
const FLEE_STEP: int = 3   # TEST VALUE — flee 一次逃離 hex 數（away 方向步進上限）
const _HEX_DIRS: Array = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(-1, 1)]

# flee 反向 away-tile：從 team.tile_pos 朝遠離 from_pos 的 hex 方向逐步找最遠存在 tile（遇無 tile=邊界停）。
# 自家 outpost 在遠離威脅側→優先逃向 home（逃回家保命）。零 randf→同 seed 兩跑 bit-identical。
func _flee_away_tile(state: WorldState, team: TeamData, from_pos: Vector2i) -> Vector2i:
	var away: Vector2i = team.tile_pos - from_pos
	if away == Vector2i.ZERO: away = Vector2i(1, 0)   # 同格→任意方向
	var dir: Vector2i = _unit_hex(away)
	var best: Vector2i = team.tile_pos
	for step in range(1, FLEE_STEP + 1):
		var p: Vector2i = team.tile_pos + dir * step
		if state.world.tiles.get(p.x * 1000 + p.y) == null: break   # 邊界/無 tile → 停在最遠可達
		best = p
	# 自家 outpost 在遠離威脅側(away 同向)→ 優先逃向 home
	var home: Vector2i = FactionAISystem.new()._find_own_outpost(state, team)
	if home != Vector2i(-1, -1):
		var hd: Vector2i = home - team.tile_pos
		if hd.x * away.x + hd.y * away.y > 0:   # home 在遠離威脅方向
			best = home
	return best

# away 向量最接近的 hex 單位方向（6 方向 argmax dot；固定序 first-max on tie→deterministic）。
func _unit_hex(away: Vector2i) -> Vector2i:
	var best_dir: Vector2i = _HEX_DIRS[0]
	var best_dot: int = -999999
	for d in _HEX_DIRS:
		var dot: int = int(d.x) * away.x + int(d.y) * away.y
		if dot > best_dot:
			best_dot = dot; best_dir = d
	return best_dir
