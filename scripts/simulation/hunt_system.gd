class_name HuntSystem

# 小獵物抽象狩獵：求生技能 roll → 成功得食物 + 枯竭 1 隻。無場景（危險野獸戰鬥屬 Plan 2b）。
const FOOD_PER_GAME: float = 12.0          # TEST VALUE — 每隻小獵物食物
const ACTIVE_BASE_CHANCE: float = 0.4      # TEST VALUE — 主動狩獵基礎命中
const PASSIVE_BASE_CHANCE: float = 0.08    # TEST VALUE — 覓食被動小獵命中（低）

# active=true 玩家/NPC 主動狩獵；active=false 覓食 tick 被動。回傳 {success, food, msg}
func hunt_small_game(state: WorldState, team: TeamData, tile: HexTileData, active: bool) -> Dictionary:
	var game: int = int(tile.resources.get("wild_game", 0))
	if game <= 0:
		return { "success": false, "food": 0.0, "msg": "無獵物" }
	var survival: float = _avg_survival(state, team)
	var base: float = ACTIVE_BASE_CHANCE if active else PASSIVE_BASE_CHANCE
	var chance: float = clampf(base + survival * 0.4, 0.0, 0.95)
	if randf() >= chance:
		return { "success": false, "food": 0.0, "msg": "空手而回" }
	tile.resources["wild_game"] = game - 1   # 枯竭 1 隻
	var food: float = FOOD_PER_GAME * (1.0 + survival * 0.3)
	team.resources["food"] = float(team.resources.get("food", 0)) + food
	team.forage_today = float(team.forage_today) + food   # 併入覓食 episode 日彙整
	return { "success": true, "food": food, "msg": "獵得野味 +%d 糧" % int(round(food)) }

func _avg_survival(state: WorldState, team: TeamData) -> float:
	var total: float = 0.0; var count: int = 0
	for pid in ([team.leader_id] as Array) + team.named_members:
		var p: PersonData = state.persons.get(pid)
		if p: total += float(p.skills.get("求生", 0.0)); count += 1
	return total / maxf(float(count), 1.0)

# dry-run：不消耗、不擲骰，回隊狩獵能力（按 hunt_small_game 主動公式 chance/yield）。能力讀數 legibility 用。
func hunt_preview(state: WorldState, team: TeamData) -> Dictionary:
	var survival: float = _avg_survival(state, team)
	return {
		"survival": survival,
		"chance":   clampf(ACTIVE_BASE_CHANCE + survival * 0.4, 0.0, 0.95),
		"yield":    FOOD_PER_GAME * (1.0 + survival * 0.3),
	}
