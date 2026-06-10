class_name ResourceSystem

const FOOD_PER_PERSON_PER_DAY: float = 2.4   # TEST VALUE — 2.4食物/人/天（原 0.1×24）
const FOOD_PER_MOUNT_PER_DAY: float = 0.5    # TEST VALUE — 草料 0.5食物/馬/天

const PUBLIC_RESOURCES: Array = ["ore_gold", "ore_silver", "ore_iron", "ore_steel", "mounts"]

# TEST VALUES — 平衡期需調整
const REGEN_RATE: Dictionary = {
	"plains":   { "food": 8.0,  "material": 0.5  },
	"forest":   { "food": 3.0,  "material": 12.0 },
	"mountain": { "food": 0.5,  "material": 2.0  },
}

# hex 軸座標六方向
const HEX_DIRS: Array = [
	Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1),
	Vector2i(0, -1), Vector2i(1, -1), Vector2i(-1, 1),
]

func collect_resources(state: WorldState, team_ids: Array) -> void:
	for tid in team_ids:
		if not state.teams.has(tid):
			continue
		var team: TeamData = state.teams[tid]
		var tile_id: int   = _pos_to_tile_id(team.tile_pos)
		if not state.world.tiles.has(tile_id):
			continue
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.outpost_level == 0:
			continue

		var pop_mult: float  = clampf(sqrt(float(team.population) / 5.0), 0.5, 2.0)
		var leader           = state.persons.get(team.leader_id)
		var prod_skill: float = float(leader.skills.get("生產", 0.0)) if leader else 0.0
		var eng_skill: float  = float(leader.skills.get("工程", 0.0)) if leader else 0.0

		if tile.outpost_level == 3:
			_collect_from_tile(state, team, tile, 2.0, pop_mult, prod_skill, eng_skill)
			for neighbor in _get_adjacent_tiles(state, team.tile_pos):
				_collect_from_tile(state, team, neighbor, 0.5, pop_mult, prod_skill, eng_skill)
		else:
			var outpost_mult: float = [1.0, 1.4][tile.outpost_level - 1]
			_collect_from_tile(state, team, tile, outpost_mult, pop_mult, prod_skill, eng_skill)

func regenerate_tiles(state: WorldState) -> void:
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		var rates = REGEN_RATE.get(tile.terrain, { "food": 2.0, "material": 1.0 })
		# food 再生受 harvest_factor 調節（季節性植物生長）
		var food_regen: float = float(rates["food"]) * tile.harvest_factor
		tile.resources["food"] = minf(
			float(tile.resources.get("food", 0)) + food_regen,
			float(tile.resource_cap.get("food", 0))
		)
		var mat_regen: float = float(rates["material"])
		tile.resources["material"] = minf(
			float(tile.resources.get("material", 0)) + mat_regen,
			float(tile.resource_cap.get("material", 0))
		)
		# ore / gem 不再生

func resolve_consumption(state: WorldState, team_ids: Array, cadence_ticks: int) -> void:
	var day_fraction: float = float(cadence_ticks) / float(WorldState.TICKS_PER_DAY)
	var ms := MovementSystem.new()
	for tid in team_ids:
		if not state.teams.has(tid):
			continue
		var team: TeamData = state.teams[tid]
		# mount 吃糧（草料）：effective_mounts × 0.5/day
		var em: int = ms.get_effective_mounts(team)
		if em > 0:
			var mount_food: float = float(em) * FOOD_PER_MOUNT_PER_DAY * day_fraction
			team.resources["food"] = maxf(0.0, float(team.resources.get("food", 0)) - mount_food)
		var total_pop: int = team.population + team.minor_population
		var food_needed: float = float(total_pop) * FOOD_PER_PERSON_PER_DAY * day_fraction
		var food_available: float = float(team.resources.get("food", 0))

		if food_available >= food_needed:
			team.resources["food"] = food_available - food_needed
			_update_person_needs(state, tid, "food", 1.0)
		else:
			team.resources["food"] = 0.0
			var satisfaction: float = food_available / food_needed if food_needed > 0.0 else 0.0
			_update_person_needs(state, tid, "food", satisfaction)
			# G-04：玩家食物告急通知
			if state.player_id != -1:
				var pp: PersonData = state.persons.get(state.player_id)
				if pp != null and pp.team_id == tid and satisfaction < 0.3:
					var already: bool = false
					for a in state.player_alerts:
						if a["type"] == "food_critical": already = true; break
					if not already:
						state.player_alerts.append({
							"type": "food_critical",
							"tick": state.world.current_tick,
							"data": { "needs_ratio": satisfaction }
						})

			# 飢餓徵用：food < 1 天份 + treasury > 0 → 應急抽公庫換 coin
			var food_after: float = float(team.resources.get("food", 0))
			if food_after < float(team.population) * FOOD_PER_PERSON_PER_DAY \
					and team.anon_treasury > 0.0:
				FactionAISystem.new()._extract_treasury(state, team, 0.3, "飢餓緊急")

func _collect_from_tile(state: WorldState, team: TeamData, src_tile: HexTileData,
		outpost_mult: float, pop_mult: float,
		prod_skill: float, eng_skill: float) -> void:
	for res in src_tile.resources.keys():
		var current: float = float(src_tile.resources.get(res, 0))
		if current <= 0.0:
			continue
		var gain: float = src_tile.productivity * current * 0.01
		gain *= outpost_mult * pop_mult
		match res:
			"food":
				gain *= (1.0 + float(src_tile.farming_level) * 0.5)
				gain *= (1.0 + prod_skill * 0.3)
				gain *= src_tile.harvest_factor
			"material":
				gain *= (1.0 + eng_skill * 0.3)
			"ore_gold", "ore_silver":
				gain *= (1.0 + eng_skill * 0.5)
		if res in PUBLIC_RESOURCES:
			# 礦進自家 outpost 公庫
			var dst_tile: HexTileData = state.world.tiles.get(_pos_to_tile_id(team.tile_pos))
			if dst_tile != null and dst_tile.outpost_level > 0:
				var cap: float = OutpostSystem.new()._get_storage_cap(dst_tile, res)
				var stored: float = float(dst_tile.public_storage.get(res, 0))
				dst_tile.public_storage[res] = minf(stored + gain, cap)
			else:
				# 無 outpost fallback 進 team
				team.resources[res] = float(team.resources.get(res, 0)) + gain
		else:
			team.resources[res] = float(team.resources.get(res, 0)) + gain
		# 從 tile 扣除（food/material 最終由 regenerate_tiles 補回；ore/gem 有限）
		src_tile.resources[res] = maxf(current - gain, 0.0)

func _get_adjacent_tiles(state: WorldState, center: Vector2i) -> Array:
	var result: Array = []
	for d in HEX_DIRS:
		var nid: int = _pos_to_tile_id(center + d)
		if state.world.tiles.has(nid):
			result.append(state.world.tiles[nid])
	return result

func _update_person_needs(state: WorldState, team_id: int, need: String, value: float) -> void:
	for pid in state.persons:
		var person: PersonData = state.persons[pid]
		if person.team_id != team_id:
			continue
		person.needs[need] = value
		if value < 0.5:
			person.stress = minf(person.stress + (0.5 - value) * 0.2, 1.0)
		else:
			person.stress = maxf(person.stress - 0.05, 0.0)
		if need == "food":
			if value < 0.3:
				person.fear    = minf(person.fear + 0.05, 1.0)
				person.loyalty = maxf(person.loyalty - 0.02, 0.0)
			else:
				person.fear = maxf(person.fear - 0.02, 0.0)

func _pos_to_tile_id(pos: Vector2i) -> int:
	return pos.x * 1000 + pos.y
