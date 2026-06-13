class_name TeamTrace

# 行為遙測：對 watched team 每取樣點印一行結構化快照（狀態 + 決策）。
# 用途：診斷追擊收斂 / 經濟死水 / leader 在想什麼。跑完移除呼叫即可。

const WATCHED: Array = [0, 1, 2, 4]   # game_sim_test: 慎重leader / 居民 / 好戰leader / 流亡

static func dump(state: WorldState, tick: int) -> void:
	var day: int = tick / 240
	for tid in WATCHED:
		var t: TeamData = state.teams.get(tid)
		if t == null:
			print("[Trace] d%d T%d <gone>" % [day, tid])
			continue
		var leader: PersonData = state.persons.get(t.leader_id)
		# 距離 move_target
		var dist: int = -1
		if t.move_target != Vector2i(-1, -1):
			dist = _hex_dist(t.tile_pos, t.move_target)
		# 速度
		var spd: float = AnonTierSystem.avg_speed(t)
		# 糧
		var food: float = float(t.resources.get("food", 0))
		var burn: float = maxf(float(t.population) * 2.4, 0.001)
		var food_days: float = food / burn
		# 腳下公庫（自有 outpost）
		var vault_s: String = "-"
		var ht: HexTileData = state.world.tiles.get(t.tile_pos.x * 1000 + t.tile_pos.y)
		if ht != null and ht.outpost_level > 0 and ht.outpost_owner == tid:
			vault_s = "mat%.0f/food%.0f/tools%.0f" % [
				float(ht.public_storage.get("material", 0)),
				float(ht.public_storage.get("food", 0)),
				float(ht.public_storage.get("tools", 0))]
		# 私產
		var priv_s: String = "mat%.0f/coin%.0f/tools%.0f" % [
			float(t.resources.get("material", 0)),
			float(t.resources.get("coin", 0)),
			float(t.resources.get("tools", 0))]
		# anon 分布
		var tiers: Dictionary = AnonTierSystem.tier_breakdown(t)
		var anon_s: String = "%d/%d/%d/%d" % [
			int(tiers.get("平民", 0)), int(tiers.get("新兵", 0)),
			int(tiers.get("老兵", 0)), int(tiers.get("菁英", 0))]
		# leader 心理（驅動反應）
		var psy_s: String = "-"
		if leader != null:
			psy_s = "loy%.2f/str%.2f/fear%.2f/hung%.2f" % [
				leader.loyalty, leader.stress, leader.fear,
				float(leader.get("hunger")) if leader.get("hunger") != null else 0.0]
		# 目標 id
		var tgt_s: String = "cbt%d/pro%d/ord%d" % [
			t.combat_target, t.prosperity_target_id, t.order_target_id]

		print("[Trace] d%d T%d @%s task=%s(p%d)[%s] mt=%s dist=%d spd=%.2f | food=%.0f(%.1fd) famine=%.0f | pop=%d anon=%s | vault=%s priv=%s | rdy%.2f mor%.2f unr%d | %s | %s" % [
			day, tid, _vs(t.tile_pos), t.current_task, t.task_priority, t.task_reason,
			_vs(t.move_target), dist, spd,
			food, food_days, t.famine_days,
			t.population, anon_s, vault_s, priv_s,
			t.readiness, t.work_morale, t.unrest_turns, tgt_s, psy_s])

static func _vs(v: Vector2i) -> String:
	return "(%d,%d)" % [v.x, v.y]

static func _hex_dist(a: Vector2i, b: Vector2i) -> int:
	var dq: int = a.x - b.x
	var dr: int = a.y - b.y
	return int((abs(dq) + abs(dr) + abs(dq + dr)) / 2)
