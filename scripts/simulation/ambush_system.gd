class_name AmbushSystem

# 掠食者隱蔽：base 低（動物天生隱蔽），森林再砍半。
const PREDATOR_EXPOSURE_BASE: float = 0.3   # TEST VALUE
const TERRAIN_HIDE_MULT: Dictionary = { "plains": 1.0, "forest": 0.5, "mountain": 0.7 }
const AMBUSH_BASE_CHANCE: float = 0.15      # TEST VALUE — 未偵測時每次 check 的伏擊機率

# 偵測 roll：隊伍 偵查(+求生) vs 掠食者 exposure × 地形隱蔽。回傳 true=偵測到（預警）。
func detect(state: WorldState, team: TeamData, tile: HexTileData) -> bool:
	var skill: float = _avg_skill(state, team, "偵查") + _avg_skill(state, team, "求生") * 0.5
	var hide: float = float(TERRAIN_HIDE_MULT.get(tile.terrain, 1.0))
	var exposure: float = PREDATOR_EXPOSURE_BASE * hide
	# 復用 vision 風格門檻：exposure + skill*0.4 > 門檻 → 偵測（skill 高則易見）
	return (exposure + skill * 0.4) > 0.4

func _avg_skill(state: WorldState, team: TeamData, skill: String) -> float:
	var total: float = 0.0
	var count: int = 0
	for pid in ([team.leader_id] as Array) + team.named_members:
		var p: PersonData = state.persons.get(pid)
		if p:
			total += float(p.skills.get(skill, 0.0))
			count += 1
	return total / maxf(float(count), 1.0)

# 對 team_ids 中位於 predator tile 的隊做伏擊把關。
func check_ambush(state: WorldState, team_ids: Array) -> void:
	for tid in team_ids:
		if not state.teams.has(tid):
			continue
		var team: TeamData = state.teams[tid]
		if team.beast_kind != "":
			continue   # 野獸不被伏擊
		if team.combat_target != -1 or state.encounter_active:
			continue
		var tile: HexTileData = state.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)
		if tile == null or int(tile.resources.get("predator_density", 0)) <= 0:
			continue
		if detect(state, team, tile):
			_on_detected(state, team, tile)   # 預警 + 長技能
			continue
		if randf() >= AMBUSH_BASE_CHANCE:
			continue   # 本次未觸發
		_trigger_ambush(state, team, tile)

func _on_detected(state: WorldState, team: TeamData, tile: HexTileData) -> void:
	# 長 偵查/求生（reuse 既有成長管道）
	_grow(state, team, "偵查"); _grow(state, team, "求生")
	# 玩家隊發預警訊息
	var leader = state.persons.get(team.leader_id)
	if leader != null and leader.id == state.player_id:
		print("[AmbushWarn] 玩家隊察覺 %s 有猛獸出沒" % tile.terrain)

func _trigger_ambush(state: WorldState, team: TeamData, tile: HexTileData) -> void:
	var kind: String = "bear" if tile.terrain == "mountain" else "boar"
	TileBank.pool_set(tile, "predator_density", int(tile.resources["predator_density"]) - 1, "ambush_predator")
	var bs := BeastSystem.new()
	var bid: int = bs.build_beast_team(state, kind, team.tile_pos)
	var leader = state.persons.get(team.leader_id)
	if leader != null and leader.id == state.player_id:
		# 玩家：直接進遭遇戰（獸=attacker；不走 pre_encounter 投降）
		EncounterSystem.new().init_encounter(state, bid, team.team_id, "normal")
		print("[Ambush] 玩家 Team%d 被 %s 伏擊！" % [team.team_id, kind])
	else:
		# NPC：npc_combat 自動解算（Bug9：不走 encounter）
		NpcCombatSystem.new().start_combat(state, bid, team.team_id)
		print("[Ambush] NPC Team%d 被 %s 伏擊" % [team.team_id, kind])

func _grow(state: WorldState, team: TeamData, skill: String) -> void:
	for pid in ([team.leader_id] as Array) + team.named_members:
		var p: PersonData = state.persons.get(pid)
		if p: SkillSystem.cap_add(p, skill, 0.001)

# beast 致死（殺人/勝）→ tile predator_infamy +1（輕量；持久惡獸實體留任務系統 spec）
func record_infamy(state: WorldState, pos: Vector2i) -> void:
	var tile: HexTileData = state.world.tiles.get(pos.x * 1000 + pos.y)
	if tile != null:
		tile.predator_infamy += 1
