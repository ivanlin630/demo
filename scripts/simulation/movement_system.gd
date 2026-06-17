class_name MovementSystem

# world-hex 移動成本 = encounter-hex 動作時間 × 地圖直徑 / 世界速度倍率
const WORLD_SPEED_MULT: int = 5    # TEST VALUE — 倍率=5 → 0.2天/hex 菁英 / 0.29天/hex 平民（normal speed, plains, daytime）
const BASE_MOVE_TICKS: int = EncounterSystem.BASE_ACTION_TICKS * EncounterSystem.MAP_DIAMETER / WORLD_SPEED_MULT
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

func process(state: WorldState, team_ids: Array,
		time_mult: float = 1.0) -> Dictionary:
	# 護衛：每 tick 追蹤目標位置
	for tid in team_ids:
		if not state.teams.has(tid):
			continue
		var team: TeamData = state.teams[tid]
		if team.current_task != TeamData.TASK_ESCORT or team.order_target_id == -1:
			continue
		var target: TeamData = state.teams.get(team.order_target_id)
		if target == null:
			TaskArbiter.release(team)   # 護衛對象消失 → 任務結束
			team.order_target_id = -1
		else:
			team.move_target = target.tile_pos
	var arrived: Array = []
	var moved: Array = []
	for tid in team_ids:
		if not state.teams.has(tid):
			continue
		var team: TeamData = state.teams[tid]
		# 居民鎖：PRODUCE + 在自家 outpost + task 不在脫離清單
		if team.tags.has(TeamData.TAG_PRODUCE):
			var fai := FactionAISystem.new()
			if fai._is_resident_team(state, team) \
					and team.current_task not in [TeamData.TASK_FLEE, TeamData.TASK_JOIN, TeamData.TASK_REVOLT, TeamData.TASK_MIGRATE, TeamData.TASK_PREPARE]:
				continue
		if team.combat_target != -1:
			continue
		# strategic_assignments 優先（-1 key = 突圍；正整數 key = 包圍目標）
		if team.strategic_assignments.size() > 0 and team.current_task != TeamData.TASK_FLEE:
			var sa_target: Vector2i
			if team.strategic_assignments.has(-1):
				sa_target = team.strategic_assignments[-1]
			else:
				sa_target = team.strategic_assignments.values()[0]
			if team.move_target == Vector2i(-1, -1) or team.move_target == team.tile_pos:
				team.move_target = sa_target
		if team.move_target == Vector2i(-1, -1):
			continue
		var cost: int = _move_cost(state, team, time_mult)
		team.move_tick_acc += WorldState.TICKS_PER_HOUR
		if team.move_tick_acc < cost:
			continue
		team.move_tick_acc = 0
		var old_target: Vector2i = team.move_target
		if _step_team(state, team):
			moved.append(tid)
			# arrived = 走到原 move_target（_step_team 內到達會清 move_target）
			if team.tile_pos == old_target:
				arrived.append(tid)
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

func _resource_weight(key: String) -> float:
	match key:
		"food":              return 0.1
		"weapon_melee_low":  return 2.0
		"weapon_melee_high": return 3.0
		"armor_low":         return 4.0
		"armor_high":        return 7.0
		"mounts", "wagons":  return 0.0  # 搬運工具本身不計重
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
				team.anon_treasury += tile.abandoned_coin
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
