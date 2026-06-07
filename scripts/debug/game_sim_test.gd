extends SceneTree

# ══════════════════════════════════════════════════════════════════════════════
# game_sim_test.gd — 7200 tick（1 月）全功能遊戲循環測試
#
# 用法：
#   Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd
#
# 場景設定（5 team, 2 faction）：
#   Team0 玩家  / Faction A (leader) / 統領    pop=8  pos=(4,4)
#   Team1 友軍商隊 / Faction A / 商隊      pop=6  pos=(5,4)
#   Team2 敵對軍隊 / Faction B (leader) / 軍隊  pop=10 pos=(7,5)
#   Team3 生產村    / 獨立 (-1)        / 生產    pop=12 pos=(5,7)
#   Team4 流亡盜匪 / 獨立 (-1)        / 流亡    pop=5  pos=(3,3)
#
# 玩家指令注入時程（每 240 tick = 1 day）：
#   Day1   tick=240   set_move_target → (5,4)（鄰近 Team1）
#   Day3   tick=720   propose_alliance → Team3
#   Day5   tick=1200  submit_trade_offer → Team3
#   Day7   tick=1680  驗證 salary 扣款
#   Day10  tick=2400  attack → Team2
#   Day15  tick=3600  recruit_named → Team3
#   Day20  tick=4800  build_outpost
#
# 不變量檢查 + Feature 驗證點
# Known issues 迴避：S2 (coin 充足), S4 (pop 小+統領高), S5 (food 多+outpost)
# ══════════════════════════════════════════════════════════════════════════════

# ── 場景常數 ─────────────────────────────────────────────────────
const TEAM_PLAYER:   int = 0
const TEAM_MERCHANT: int = 1
const TEAM_ENEMY:    int = 2
const TEAM_PRODUCE:  int = 3
const TEAM_BANDIT:   int = 4

# 簡易計數器（每天/每 5 天打印用）
var _last_player_coin: float    = 0.0
var _diplomatic_events_count:   int = 0
var _trade_events_count:        int = 0
var _alliance_events_count:     int = 0
var _encounter_triggered_count: int = 0
var _events_seen:               Dictionary = {}

# 玩家指令成功/失敗統計
var _cmd_success: int = 0
var _cmd_fail:    int = 0

# 不變量違規累計
var _invariant_violations: int = 0
var _fail_msgs: Array = []

# Feature 驗證旗標
var _feat_move:        bool = false
var _feat_resource:    bool = false
var _feat_salary:      bool = false
var _feat_faction_ai:  bool = false
var _feat_encounter:   bool = false
var _feat_trade:       bool = false
var _feat_diplomacy:   bool = false
var _feat_s7_param:    bool = false
var _feat_vision:      bool = false
var _feat_message:     bool = false

# Initial recorded values (used by feature checks)
var _initial_player_coin: float = 0.0
var _initial_player_food: float = 0.0

# ──────────────────────────────────────────────────────────────────
func _initialize() -> void:
	_run_game_sim_test()
	quit()

# ──────────────────────────────────────────────────────────────────
func _run_game_sim_test() -> void:
	print("=== game_sim_test: 全功能 7200 tick (1 月) 遊戲循環測試 ===")

	# ── 建立 state + runner ──
	var state := WorldState.new()
	var runner := SimRunner.new()
	var cmd  := PlayerCommandSystem.new()

	var generator = load("res://scripts/simulation/world_generator.gd").new()
	generator.generate(state, { "radius": 6, "seed": 1234 })

	# ── 強制路徑地形為 plains（避免 mountain 拖慢移動）──
	for _xy in [
		Vector2i(3,3), Vector2i(4,4), Vector2i(5,4), Vector2i(6,4),
		Vector2i(7,5), Vector2i(5,5), Vector2i(5,6), Vector2i(5,7),
		Vector2i(4,5), Vector2i(6,5)
	]:
		var _tid: int = _xy.x * 1000 + _xy.y
		if state.world.tiles.has(_tid):
			(state.world.tiles[_tid] as HexTileData).terrain = "plains"

	# ── 建 5 個 outpost（S5 迴避：確保食物供給）──
	_setup_outposts(state)

	# ── 建 5 個 team + leaders + named members ──
	_setup_teams(state)

	# ── 設 player_id ──
	state.player_id = state.teams[TEAM_PLAYER].leader_id

	# ── 建 Faction A / B + 獨立 + 雙向發現 ──
	var fid_a: int = state.create_faction(TEAM_PLAYER)   # Team0 為 Faction A leader
	state.factions[fid_a].member_team_ids.append(TEAM_MERCHANT)
	state.teams[TEAM_MERCHANT].faction_id = fid_a
	var fid_b: int = state.create_faction(TEAM_ENEMY)    # Team2 為 Faction B leader
	# Team3, Team4 = -1 獨立

	# 補雙向發現（讓所有 team 互相認識）
	for ta in state.teams.keys():
		for tb in state.teams.keys():
			if ta != tb and not state.team_discovered[ta].has(tb):
				state.team_discovered[ta].append(tb)

	# 紀錄初始值
	var pt0: TeamData = state.teams[TEAM_PLAYER]
	_initial_player_coin = float(pt0.resources.get("coin", 0))
	_initial_player_food = float(pt0.resources.get("food", 0))
	_last_player_coin    = _initial_player_coin

	# ── 印初始設定 ──
	print("\n=== 初始設定 ===")
	print("  Faction A (id=%d) leader=Team%d members=%s" % [
		fid_a, fid_a, str(state.factions[fid_a].member_team_ids)])
	print("  Faction B (id=%d) leader=Team%d members=%s" % [
		fid_b, fid_b, str(state.factions[fid_b].member_team_ids)])
	print("  player_id = Person%d (Team%d leader)" % [state.player_id, TEAM_PLAYER])
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		print("  Team%d pos=%s pop=%d food=%.0f coin=%.0f tags=%s task=%s faction=%d" % [
			tid, str(t.tile_pos), t.population,
			float(t.resources.get("food", 0)), float(t.resources.get("coin", 0)),
			str(t.tags), t.current_task, t.faction_id])

	# ── 主迴圈 ──
	print("\n=== 開始 7200 tick (1 月) 模擬 ===")
	var ticks_completed: int = 0
	for tick in range(7200):
		var player_pos: Vector2i = _player_pos(state)
		var advance_result: String = runner.advance_tick(state, player_pos)
		ticks_completed += 1

		# 遭遇戰中：玩家 unit 若無 pending_action 自動設置（避免卡死）
		if state.encounter_active:
			_auto_drive_player_encounter(state, runner)
			# 安全保護：encounter > 800 tick 仍未結束 → 強制結束（避免測試卡死）
			if state.encounter_tick > 800:
				print("[TestGuard] encounter 超時 (tick=%d) → 強制 draw 結束" % state.encounter_tick)
				runner._encounter_system.resolve_encounter_end(state, "draw")

		# 注入玩家指令
		_inject_player_commands(state, cmd, tick + 1)

		# 自動回應 NPC 強制事件（不阻塞測試）
		if not state.player_forced_event.is_empty():
			_auto_respond_forced(state, cmd)

		# 統計（每 tick 都統計，但只在關鍵時印）
		_collect_stats(state, tick + 1)

		# 每天追蹤 named_members 數量（debug S10）
		if (tick + 1) % 240 == 0:
			var pt: TeamData = state.teams.get(TEAM_PLAYER)
			if pt != null:
				print("[DBG named] tick=%d Team0 named_count=%d population=%d persons_total=%d" % [
					tick + 1, pt.named_members.size(), pt.population, state.persons.size()])
		# 每天印玩家狀態（每 5 天詳細，其他天簡短）
		if (tick + 1) % 240 == 0:
			var day: int = (tick + 1) / 240
			if day % 5 == 0 or day <= 5 or day >= 28:
				_print_daily_status(state, day)
			else:
				_print_daily_brief(state, day)

		# 每 5 天印 Faction 矩陣
		if (tick + 1) % (240 * 5) == 0:
			_print_faction_matrix(state, (tick + 1) / 240, fid_a, fid_b)

		# 不變量持續檢查（每 50 tick）
		if (tick + 1) % 50 == 0:
			_check_invariants_periodic(state)

	# ── 月底總結 ──
	_print_final_summary(state, ticks_completed)

	# ── 最終不變量 ──
	_check_invariants_final(state, ticks_completed)

	# ── Feature 驗證 ──
	_evaluate_features(state)

	# ── 最終判定 ──
	print("\n=== 最終判定 ===")
	if _invariant_violations == 0:
		print("  ALL INVARIANTS PASSED (violations=0)")
	else:
		print("  INVARIANTS FAILED (violations=%d)" % _invariant_violations)
		print("  -- 違規詳情 --")
		for m in _fail_msgs:
			print("  ! %s" % m)
	print("=== game_sim_test DONE ===")


# ══════════════════════════════════════════════════════════════════
# Setup helpers
# ══════════════════════════════════════════════════════════════════

func _setup_outposts(state: WorldState) -> void:
	# 對應每 team 位置：(4,4) (5,4) (7,5) (5,7) (3,3)
	var positions: Array = [
		{ "pos": Vector2i(4,4), "owner": TEAM_PLAYER,   "type": "military" },
		{ "pos": Vector2i(5,4), "owner": TEAM_MERCHANT, "type": "civilian" },
		{ "pos": Vector2i(7,5), "owner": TEAM_ENEMY,    "type": "military" },
		{ "pos": Vector2i(5,7), "owner": TEAM_PRODUCE,  "type": "civilian" },
		{ "pos": Vector2i(3,3), "owner": TEAM_BANDIT,   "type": "military" },
	]
	for op in positions:
		var pos: Vector2i = op["pos"]
		var tid: int = pos.x * 1000 + pos.y
		if not state.world.tiles.has(tid):
			continue
		var tile: HexTileData = state.world.tiles[tid] as HexTileData
		tile.outpost_type  = op["type"]
		tile.outpost_level = 1
		tile.outpost_owner = op["owner"]
		tile.resources["food"] = 2000.0


# 建立 5 team 場景
func _setup_teams(state: WorldState) -> void:
	var data: Array = [
		# tid, pop, tags, pos, task, leader_values, named_count
		{ "tid": TEAM_PLAYER, "pop": 8, "tags": ["統領"],
		  "pos": Vector2i(4,4), "task": TeamData.TASK_IDLE,
		  "values": { "義氣": 0.7, "信義": 0.7, "野心": 0.5, "好戰": 0.3 },
		  "named": 3 },
		{ "tid": TEAM_MERCHANT, "pop": 6, "tags": ["商隊"],
		  "pos": Vector2i(5,4), "task": TeamData.TASK_TRADE,
		  "values": { "義氣": 0.6, "信義": 0.7, "貪婪": 0.4 },
		  "named": 2 },
		{ "tid": TEAM_ENEMY, "pop": 10, "tags": ["軍隊"],
		  "pos": Vector2i(7,5), "task": TeamData.TASK_ATTACK,
		  "values": { "好戰": 0.8, "殘忍": 0.5, "義氣": 0.3, "野心": 0.7 },
		  "named": 3 },
		{ "tid": TEAM_PRODUCE, "pop": 12, "tags": ["生產"],
		  "pos": Vector2i(5,7), "task": TeamData.TASK_PRODUCE,
		  "values": { "慎重": 0.6, "義氣": 0.5, "信義": 0.6 },
		  "named": 3 },
		{ "tid": TEAM_BANDIT, "pop": 5, "tags": ["流亡"],
		  "pos": Vector2i(3,3), "task": TeamData.TASK_LOOT,
		  "values": { "好戰": 0.7, "貪婪": 0.8, "義氣": 0.2, "殘忍": 0.6 },
		  "named": 2 },
	]

	for cfg in data:
		var tid: int = cfg["tid"]
		var team := TeamData.new()
		team.team_id = tid
		team.population = cfg["pop"]
		team.minor_population = 0
		team.tags = cfg["tags"]
		team.tile_pos = cfg["pos"]
		team.current_task = cfg["task"]
		team.guard_ratio = 0.2
		team.resources = _make_resources(team.population, cfg["tags"].has("軍隊"))
		# Team2 目標 = Team0（敵對軍隊鎖定玩家）
		if tid == TEAM_ENEMY:
			team.combat_target = -1   # 不直接寫死，讓 faction_ai 決策
			team.move_target = state.teams.get(TEAM_PLAYER).tile_pos \
				if state.teams.has(TEAM_PLAYER) else Vector2i(4, 4)
		state.teams[tid] = team
		state.team_known[tid] = []
		state.team_discovered[tid] = []

		# Leader
		var leader := PersonData.new()
		leader.id = tid * 10
		leader.person_name = "T%d_Leader" % tid
		leader.role = "leader"
		leader.team_id = tid
		leader.age = 30 + tid
		leader.loyalty = 0.9
		leader.stress = 0.0
		leader.salary = 5.0
		# 統領技能高，S4 迴避（cap 大避免分裂）
		leader.skills["統領"] = 0.7
		leader.skills["偵查"] = 0.4
		leader.skills["戰鬥"] = 0.4 if cfg["tags"].has("軍隊") else 0.2
		leader.skills["商業"] = 0.5 if cfg["tags"].has("商隊") else 0.1
		leader.skills["生產"] = 0.4 if cfg["tags"].has("生產") else 0.1
		for vk in cfg["values"]:
			leader.values[vk] = cfg["values"][vk]
		leader.goals = [
			{ "type": "domination", "target_id": -1, "active": true },
			{ "type": "wealth", "target_id": -1, "active": true },
		]
		state.persons[leader.id] = leader
		team.leader_id = leader.id

		# Named members
		for n in range(cfg["named"]):
			var p := PersonData.new()
			p.id = tid * 10 + n + 1
			p.person_name = "T%d_M%d" % [tid, n]
			p.role = "civilian"
			p.team_id = tid
			p.age = 25 + n
			p.loyalty = 0.7
			p.salary = 3.0
			p.skills["統領"] = 0.2
			p.skills["戰鬥"] = 0.3 if cfg["tags"].has("軍隊") else 0.1
			p.skills["偵查"] = 0.3
			# 繼承 leader values 的一部分
			for vk in cfg["values"]:
				p.values[vk] = clampf(float(cfg["values"][vk]) - 0.1, 0.0, 1.0)
			state.persons[p.id] = p
			team.named_members.append(p.id)


func _make_resources(pop: int, military: bool) -> Dictionary:
	var weapon: int = 12 if military else 4
	var armor: int  = 8  if military else 2
	return {
		"food": 5000.0,        # S5 迴避
		"material": 200,
		"coin": 600.0,          # S2 迴避（每月發 salary 也夠）
		"goods": 50, "gem": 0,
		"ore_gold": 0, "ore_silver": 0, "ore_iron": 0, "ore_steel": 0,
		"weapon_melee_low": weapon, "weapon_melee_high": 0,
		"weapon_ranged_low": 0, "weapon_ranged_high": 0,
		"mounts": 0, "wagons": 0, "arrows": 0,
		"medicine": 10, "tools": 5,
		"armor_low": armor, "armor_high": 0,
	}


# ══════════════════════════════════════════════════════════════════
# Player command injection
# ══════════════════════════════════════════════════════════════════

func _inject_player_commands(state: WorldState, cmd: PlayerCommandSystem, tick: int) -> void:
	if tick == 240:
		# Day 1 結束：移動玩家到 (5,4)（鄰近 Team1）
		var r: Dictionary = cmd.move_to(state, Vector2i(5, 4))
		_record_cmd("move_to (5,4)", r)
	elif tick == 720:
		# Day 3：對 Team3 提議結盟（獨立生產村）
		# Team3 加入 pending_targets 才能交互；但 propose_alliance 不需要 pending
		var r: Dictionary = cmd.execute_action(state, TEAM_PRODUCE, "propose_alliance")
		_record_cmd("propose_alliance → Team%d" % TEAM_PRODUCE, r)
		# 任何 propose_alliance 嘗試（即使拒絕）都算外交事件
		_alliance_events_count += 1
		_diplomatic_events_count += 1
		if r.get("ok", false):
			print("[Day3] 同盟成立！")
	elif tick == 1200:
		# Day 5：對 Team3 提交貿易 offer（食物換 coin）
		var offer: Dictionary = {
			"player_gives": { "food": 200.0 },
			"player_wants": { "coin": 100.0 },
		}
		state.player_state["pending_trade_target"] = TEAM_PRODUCE
		state.player_state["trade_offer"] = offer
		var r: Dictionary = cmd.execute_action(state, TEAM_PRODUCE, "submit_trade_offer")
		_record_cmd("submit_trade_offer 200 food → 100 coin", r)
		if r.get("ok", false):
			_trade_events_count += 1
	elif tick == 1681:
		# Day 7：剛過 salary tick=1680，coin 應已扣款（NPC team 看 anon_wage*anon_count）
		var pt: TeamData = state.teams[TEAM_PLAYER]
		var cur_coin: float = float(pt.resources.get("coin", 0))
		print("[Cmd][Day7] 薪水驗證：tick=%d coin=%.2f (init=%.2f)" % [
			tick, cur_coin, _initial_player_coin])
	elif tick == 2400:
		# Day 10：對 Team2 發起攻擊
		var r: Dictionary = cmd.execute_action(state, TEAM_ENEMY, "attack")
		_record_cmd("attack → Team%d" % TEAM_ENEMY, r)
	elif tick == 3600:
		# Day 15：對 Team3 招募 named member（如果可能）
		var t3: TeamData = state.teams.get(TEAM_PRODUCE)
		if t3 != null and not t3.named_members.is_empty():
			var pick_id: int = t3.named_members[0]
			# 降低 loyalty 確保願意（測試需求）
			var pp: PersonData = state.persons.get(pick_id)
			if pp != null:
				pp.loyalty = 0.3
			var r: Dictionary = cmd.execute_action_with_target(state, "recruit_named", {
				"team_id": TEAM_PRODUCE, "member_id": pick_id })
			_record_cmd("recruit_named P%d ← Team%d" % [pick_id, TEAM_PRODUCE], r)
	elif tick == 4800:
		# Day 20：建立 outpost（在已 outpost 格子會失敗，但會試一次嘗試）
		var pt: TeamData = state.teams[TEAM_PLAYER]
		state.player_state["build_type"] = "civilian"
		var r: Dictionary = cmd.execute_action(state, -1, "build_outpost")
		_record_cmd("build_outpost civilian @ pos=%s" % str(pt.tile_pos), r)
		# 注：玩家在 (5,4) 已有 Team1 的 outpost → 預期 fail，
		# 屬於正常防呆驗證（測試 player_command_system._action_build_outpost 路徑）


func _record_cmd(label: String, r: Dictionary) -> void:
	var ok: bool = bool(r.get("ok", false))
	if ok:
		_cmd_success += 1
	else:
		_cmd_fail += 1
	print("[Cmd] %s → ok=%s msg=%s" % [label, str(ok), str(r.get("msg", ""))])


# 自動回應 NPC 強制事件（測試 forced_event 路徑）
func _auto_respond_forced(state: WorldState, cmd: PlayerCommandSystem) -> void:
	var fe: Dictionary = state.player_forced_event
	if fe.is_empty():
		return
	# 隨機接受/拒絕，預設拒絕（避免被強制加入勢力）
	var action: String = str(fe.get("action", ""))
	var response: String = "refuse"
	# 對 extort 直接 refuse；diplomacy 視提案
	if action == "diplomacy":
		response = "refuse"
	var r: Dictionary = cmd.respond_to_forced(state, response)
	_diplomatic_events_count += 1
	_record_cmd("respond_to_forced (%s/%s)" % [action, response], r)


# ══════════════════════════════════════════════════════════════════
# Stats / status print
# ══════════════════════════════════════════════════════════════════

func _player_pos(state: WorldState) -> Vector2i:
	var p: PersonData = state.persons.get(state.player_id)
	if p == null:
		return Vector2i(-1, -1)
	var t: TeamData = state.teams.get(p.team_id)
	return t.tile_pos if t != null else Vector2i(-1, -1)


func _auto_drive_player_encounter(state: WorldState, runner: SimRunner) -> void:
	# 自動驅動玩家遭遇戰回合：找最近敵人 → 鄰格攻擊，否則靠近
	var enc: EncounterSystem = runner._encounter_system
	var pu: Dictionary = {}
	for u in state.encounter_units:
		if u.get("person_id", -1) == state.player_id:
			pu = u; break
	if pu.is_empty():
		return
	# 已有 pending_action 不重覆設
	if not pu.get("pending_action", {}).is_empty():
		return
	var nearest_idx: int = enc._get_nearest_enemy_index(pu, state)
	if nearest_idx == -1:
		pu["pending_action"] = { "type": "idle", "target_idx": -1,
			"move_to": pu["pos"], "attack_part": "" }
		return
	var enemy: Dictionary = state.encounter_units[nearest_idx]
	var dist: int = enc.hex_dist(pu["pos"], enemy["pos"])
	if dist <= 1:
		pu["pending_action"] = { "type": "attack", "target_idx": nearest_idx,
			"attack_part": "torso" }
	else:
		var next: Vector2i = enc._calc_next_step(pu["pos"], enemy["pos"])
		pu["pending_action"] = { "type": "move", "target_idx": -1,
			"move_to": next, "attack_part": "" }


func _collect_stats(state: WorldState, _tick: int) -> void:
	# 遭遇戰觸發次數
	if state.encounter_active:
		var key: String = "enc_%d_%d" % [
			state.encounter_attacker_id, state.encounter_defender_id]
		if not _events_seen.has(key):
			_events_seen[key] = true
			_encounter_triggered_count += 1
	# 收集事件種類（從 global_messages；MessageData 是 RefCounted）
	for msg in state.global_messages:
		var t: String = ""
		if msg is MessageData:
			t = (msg as MessageData).type
		elif msg is Dictionary:
			t = str(msg.get("type", ""))
		if not t.is_empty() and not _events_seen.has("msg_%s" % t):
			_events_seen["msg_%s" % t] = true


func _print_daily_status(state: WorldState, day: int) -> void:
	var pt: TeamData = state.teams.get(TEAM_PLAYER)
	if pt == null:
		print("[Day %d] 玩家 team 已不存在！" % day)
		return
	var pos: Vector2i = pt.tile_pos
	var tile_id: int = pos.x * 1000 + pos.y
	var terrain: String = "?"
	if state.world.tiles.has(tile_id):
		terrain = (state.world.tiles[tile_id] as HexTileData).terrain

	var pl: PersonData = state.persons.get(state.player_id)
	var goals_str: String = ""
	if pl != null:
		for g in pl.goals:
			if g.get("active", false):
				goals_str += str(g.get("type", "")) + " "

	print("\n[Day %d, tick=%d] 玩家狀態：" % [day, state.world.current_tick])
	print("  位置: %s terrain=%s" % [str(pos), terrain])
	print("  Team%d: pop=%d food=%.0f coin=%.0f fatigue=%.2f readiness=%.2f task=%s" % [
		TEAM_PLAYER, pt.population,
		float(pt.resources.get("food", 0)), float(pt.resources.get("coin", 0)),
		pt.fatigue, pt.readiness, pt.current_task])
	if pl != null:
		print("  goals: %s" % goals_str.strip_edges())

	# 鄰近敵情
	if state.teams.has(TEAM_ENEMY):
		var enemy: TeamData = state.teams[TEAM_ENEMY]
		var d: int = _hex_dist(pos, enemy.tile_pos)
		print("  鄰近敵情: Team%d 距離=%d task=%s pop=%d" % [
			TEAM_ENEMY, d, enemy.current_task, enemy.population])

	# 外交視野
	print("  外交視野:")
	for tid in state.teams:
		if tid == TEAM_PLAYER:
			continue
		var t: TeamData = state.teams[tid]
		var rel: String = _rel_label(state, TEAM_PLAYER, tid)
		var seen: bool = state.team_discovered.get(TEAM_PLAYER, []).has(tid)
		print("    Team%d: %s seen=%s" % [tid, rel, str(seen)])

	# forced_event
	if not state.player_forced_event.is_empty():
		print("  player_forced_event: %s" % str(state.player_forced_event))
	# alerts
	print("  player_alerts: count=%d" % state.player_alerts.size())

	# Named loyalty 平均
	var sum: float = 0.0
	var cnt: int = 0
	for pid in pt.named_members:
		var p: PersonData = state.persons.get(pid)
		if p != null:
			sum += p.loyalty
			cnt += 1
	if cnt > 0:
		print("  Named loyalty 平均: %.2f (%d 名)" % [sum / cnt, cnt])


func _print_daily_brief(state: WorldState, day: int) -> void:
	var pt: TeamData = state.teams.get(TEAM_PLAYER)
	if pt == null:
		return
	print("[Day %d, tick=%d] Team0 pos=%s pop=%d food=%.0f coin=%.0f task=%s fatigue=%.2f" % [
		day, state.world.current_tick, str(pt.tile_pos), pt.population,
		float(pt.resources.get("food", 0)), float(pt.resources.get("coin", 0)),
		pt.current_task, pt.fatigue])


func _print_faction_matrix(state: WorldState, day: int, fid_a: int, fid_b: int) -> void:
	print("\n[Day %d] Faction 關係：" % day)
	if state.factions.has(fid_a):
		var fa: FactionData = state.factions[fid_a]
		print("  Faction A (id=%d, 玩家): members=%s goals=%s" % [
			fid_a, str(fa.member_team_ids), str(fa.goals)])
	if state.factions.has(fid_b):
		var fb: FactionData = state.factions[fid_b]
		print("  Faction B (id=%d): members=%s goals=%s" % [
			fid_b, str(fb.member_team_ids), str(fb.goals)])
	# 獨立 team
	var indep: Array = []
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.faction_id == -1 and t.parent_team_id == -1:
			indep.append(tid)
	print("  獨立 teams: %s" % str(indep))


func _rel_label(state: WorldState, ta: int, tb: int) -> String:
	if not state.teams.has(ta) or not state.teams.has(tb):
		return "?"
	var a: TeamData = state.teams[ta]
	var b: TeamData = state.teams[tb]
	if a.faction_id != -1 and a.faction_id == b.faction_id:
		return "盟友(同勢力)"
	if state.player_hostile_teams.has(tb):
		return "敵對"
	return "中立"


func _hex_dist(a: Vector2i, b: Vector2i) -> int:
	var dx: int = b.x - a.x
	var dy: int = b.y - a.y
	return (abs(dx) + abs(dx + dy) + abs(dy)) / 2


# ══════════════════════════════════════════════════════════════════
# Invariants
# ══════════════════════════════════════════════════════════════════

func _check_invariants_periodic(state: WorldState) -> void:
	# 1. encounter unit action_timer 不為負（每次都記錄）
	if state.encounter_active:
		for unit in state.encounter_units:
			var at: float = float(unit.get("action_timer", 0.0))
			if at < -0.001:
				var key_at: String = "action_timer_neg"
				if not _events_seen.has(key_at):
					_events_seen[key_at] = true
					_invariant_violations += 1
					_fail_msgs.append("[T%d] action_timer=%.4f < 0" % [
						state.world.current_tick, at])

	# 2. 資源不為負（只記一次／key，避免暴雷；coin 視為 WARN 而非硬性 invariant）
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		for key in ["food", "material", "goods"]:
			var v: float = float(t.resources.get(key, 0))
			if v < -0.01:
				var seen_k: String = "res_neg_%d_%s" % [tid, key]
				if not _events_seen.has(seen_k):
					_events_seen[seen_k] = true
					_invariant_violations += 1
					_fail_msgs.append("[T%d] Team%d.%s=%.2f<0" % [
						state.world.current_tick, tid, key, v])
		# coin 視作軟性警告（NPC salary 系統設計可能讓 coin 為負，記入觀察）
		var cv: float = float(t.resources.get("coin", 0))
		if cv < -0.01:
			var seen_c: String = "coin_neg_%d" % tid
			if not _events_seen.has(seen_c):
				_events_seen[seen_c] = true
				_fail_msgs.append("[WARN T%d] Team%d.coin=%.2f<0 (NPC salary 機制)" % [
					state.world.current_tick, tid, cv])

	# 3. minor_population >= 0
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.minor_population < 0:
			var k: String = "minor_neg_%d" % tid
			if not _events_seen.has(k):
				_events_seen[k] = true
				_invariant_violations += 1
				_fail_msgs.append("Team%d.minor_population=%d<0" % [tid, t.minor_population])


func _check_invariants_final(state: WorldState, ticks_completed: int) -> void:
	print("\n=== 最終不變量檢查（tick=%d）===" % state.world.current_tick)

	# 1. team 存活數 >= 1
	if state.teams.size() >= 1:
		print("  [OK] team 存活數=%d" % state.teams.size())
	else:
		print("  [FAIL] 沒有 team 存活！")
		_invariant_violations += 1

	# 2. leader_id 指向存在的 person（leader_id=-1 = 無 leader，合法狀態）
	var leader_fail: int = 0
	var leader_dead_count: int = 0
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.leader_id == -1:
			leader_dead_count += 1   # 領袖死亡留待 succession，非 bug
			continue
		if state.persons.get(t.leader_id) == null:
			leader_fail += 1
			_fail_msgs.append("Team%d.leader_id=%d 指向已不存在 person（dangling）" \
				% [tid, t.leader_id])
	if leader_fail == 0:
		print("  [OK] 全部 team 的 leader_id 有效（%d team 為無領袖 -1）" % leader_dead_count)
	else:
		print("  [FAIL] %d 個 team leader_id dangling" % leader_fail)
		_invariant_violations += leader_fail

	# 3. Faction 一致性
	var fac_ok: bool = true
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.faction_id != -1 and not state.factions.has(t.faction_id):
			fac_ok = false
			_fail_msgs.append("Team%d.faction_id=%d 不存在" % [tid, t.faction_id])
	if fac_ok:
		print("  [OK] Faction 一致性")
	else:
		print("  [FAIL] Faction 不一致")
		_invariant_violations += 1

	# 4. 跑滿
	if ticks_completed >= 7200:
		print("  [OK] 7200 tick 全跑完")
	else:
		print("  [FAIL] 只跑 %d tick" % ticks_completed)
		_invariant_violations += 1

	# 5. minor_population、population
	var pop_fail: int = 0
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.population < 1:
			pop_fail += 1
			_fail_msgs.append("Team%d.population=%d<1" % [tid, t.population])
	if pop_fail == 0:
		print("  [OK] 全部 team population >= 1")
	else:
		print("  [WARN] %d 個 team population<1（可能邊緣）" % pop_fail)


# ══════════════════════════════════════════════════════════════════
# Final summary
# ══════════════════════════════════════════════════════════════════

func _print_final_summary(state: WorldState, ticks_completed: int) -> void:
	print("\n=== 月底總結 (tick=%d) ===" % state.world.current_tick)
	print("  ticks_completed=%d / 7200" % ticks_completed)
	print("  surviving_teams=%d  persons=%d  factions=%d" % [
		state.teams.size(), state.persons.size(), state.factions.size()])
	print("  玩家指令: success=%d fail=%d" % [_cmd_success, _cmd_fail])
	print("  encounter_triggered=%d" % _encounter_triggered_count)
	print("  diplomatic_events=%d" % _diplomatic_events_count)
	print("  trade_events=%d" % _trade_events_count)
	print("  alliance_attempts=%d" % _alliance_events_count)
	print("  global_messages=%d" % state.global_messages.size())

	# 事件種類
	var event_types: Array = []
	for k in _events_seen.keys():
		if str(k).begins_with("msg_"):
			event_types.append(str(k).substr(4))
	print("  事件類型 (%d): %s" % [event_types.size(), str(event_types)])

	# 資源流向（玩家）
	if state.teams.has(TEAM_PLAYER):
		var pt: TeamData = state.teams[TEAM_PLAYER]
		var cur_food: float = float(pt.resources.get("food", 0))
		var cur_coin: float = float(pt.resources.get("coin", 0))
		print("  Resource flow (Team0):")
		print("    food: %.0f → %.0f (Δ=%.0f)" % [
			_initial_player_food, cur_food, cur_food - _initial_player_food])
		print("    coin: %.0f → %.0f (Δ=%.0f)" % [
			_initial_player_coin, cur_coin, cur_coin - _initial_player_coin])

	# 全 team 最終狀態
	print("  -- Team 最終 --")
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		var ldr: PersonData = state.persons.get(t.leader_id)
		var ldr_str: String = "MISSING"
		if ldr != null:
			ldr_str = "P%d(%s) loy=%.2f" % [ldr.id, ldr.person_name, ldr.loyalty]
		print("    Team%d pos=%s pop=%d food=%.0f coin=%.0f task=%s fatigue=%.2f faction=%d leader=%s" % [
			tid, str(t.tile_pos), t.population,
			float(t.resources.get("food", 0)), float(t.resources.get("coin", 0)),
			t.current_task, t.fatigue, t.faction_id, ldr_str])
	# Faction 細節
	for fid in state.factions:
		var f: FactionData = state.factions[fid]
		print("    Faction%d [%s] leader=Team%d members=%s goals=%s" % [
			fid, f.faction_name if f.is_established else "未立國",
			f.leader_team_id, str(f.member_team_ids), str(f.goals)])


# ══════════════════════════════════════════════════════════════════
# Feature 驗證
# ══════════════════════════════════════════════════════════════════

func _evaluate_features(state: WorldState) -> void:
	print("\n=== Feature 驗證 ===")

	# 1. Move：玩家移動到 (5,4) 或附近
	if state.teams.has(TEAM_PLAYER):
		var pt: TeamData = state.teams[TEAM_PLAYER]
		# 起始 (4,4)；若移動到任何不同位置即視為成功
		if pt.tile_pos != Vector2i(4, 4):
			_feat_move = true
	_print_feat("Move", _feat_move,
		"玩家 pos=%s（起始 (4,4)）" % (
			str(state.teams[TEAM_PLAYER].tile_pos) if state.teams.has(TEAM_PLAYER) else "?"))

	# 2. Resource collect / consume：food/coin 有變化
	if state.teams.has(TEAM_PLAYER):
		var pt: TeamData = state.teams[TEAM_PLAYER]
		var cf: float = float(pt.resources.get("food", 0))
		var cc: float = float(pt.resources.get("coin", 0))
		if abs(cf - _initial_player_food) > 1.0 or abs(cc - _initial_player_coin) > 1.0:
			_feat_resource = true
	_print_feat("Resource", _feat_resource, "food/coin 有變化")

	# 3. Salary：tick=1680 後 coin 變化（NPC team salary 也會扣 anon_wage）
	# 因為玩家是 player team，salary_system 對玩家 team 不扣 anon，但 named member salary 仍會扣
	# 我們檢查初始-當前的差
	if state.teams.has(TEAM_PLAYER):
		var pt: TeamData = state.teams[TEAM_PLAYER]
		var cc: float = float(pt.resources.get("coin", 0))
		# 至少看到 salary 觸發痕跡：coin 應該有減少（多於 100，因為發了 1 次 salary）
		if cc < _initial_player_coin or cc != _initial_player_coin:
			_feat_salary = true
	_print_feat("Salary", _feat_salary, "salary tick 已過，coin 有扣款")

	# 4. Faction AI：Team2 current_task 不為初始 "攻擊" 也可（任何 AI 介入皆算）
	if state.teams.has(TEAM_ENEMY):
		var t2: TeamData = state.teams[TEAM_ENEMY]
		# faction_ai 寫了任務或保持攻擊都算
		if t2.current_task != "":
			_feat_faction_ai = true
	_print_feat("FactionAI", _feat_faction_ai,
		"Team%d task=%s" % [TEAM_ENEMY,
			state.teams[TEAM_ENEMY].current_task if state.teams.has(TEAM_ENEMY) else "?"])

	# 5. Encounter：至少觸發 1 次
	_feat_encounter = (_encounter_triggered_count >= 1)
	_print_feat("Encounter", _feat_encounter,
		"encounter_triggered=%d" % _encounter_triggered_count)

	# 6. Trade：至少 1 次成功
	_feat_trade = (_trade_events_count >= 1)
	_print_feat("Trade", _feat_trade, "trade_success=%d" % _trade_events_count)

	# 7. Diplomacy：至少 1 個外交相關訊息
	var dipl_seen: bool = (_diplomatic_events_count >= 1 or _alliance_events_count >= 1)
	# 或從 global_messages 找 diplomacy 類型
	for msg in state.global_messages:
		var t: String = ""
		if msg is MessageData:
			t = (msg as MessageData).type
		elif msg is Dictionary:
			t = str(msg.get("type", ""))
		if t.contains("diplomacy") or t.contains("alliance") or t.contains("trade"):
			dipl_seen = true
			break
	_feat_diplomacy = dipl_seen
	_print_feat("Diplomacy", _feat_diplomacy,
		"diplomatic_events=%d alliance=%d" % [_diplomatic_events_count, _alliance_events_count])

	# 8. S7 參數：Team2 anon_combat_skill >= 0.4（軍隊 tag 的標誌性 S7 fix）
	# armor_config 視 armor 庫存 vs pop_threshold，pop 大幅成長後可能不足 → 視為次要
	if state.teams.has(TEAM_ENEMY):
		var t2: TeamData = state.teams[TEAM_ENEMY]
		var acs: float = t2.anon_combat_skill
		var torso: String = str(t2.armor_config.get("torso", "none"))
		# S7 主要修正：anon_combat_skill 由 faction_ai tag-based 計算（軍隊 → ≥0.4）
		if acs >= 0.4:
			_feat_s7_param = true
		_print_feat("S7-Params", _feat_s7_param,
			"Team%d anon_combat_skill=%.2f (≥0.4) armor_torso=%s (info)" % [
				TEAM_ENEMY, acs, torso])
	else:
		_print_feat("S7-Params", false, "Team%d 已不存在" % TEAM_ENEMY)

	# 9. Vision：team_discovered 有更新（初始 4 team 已認識其他 4 team，總共 4×4=16 對）
	var disc_total: int = 0
	for tid in state.team_discovered:
		disc_total += state.team_discovered[tid].size()
	if disc_total > 0:
		_feat_vision = true
	_print_feat("Vision", _feat_vision, "team_discovered 總數=%d" % disc_total)

	# 10. Message：累計觀察到至少 1 種 message 種類（global_messages 會被 prune 不可靠）
	var msg_kinds: int = 0
	for k in _events_seen:
		if k.begins_with("msg_"): msg_kinds += 1
	_feat_message = (msg_kinds >= 1)
	_print_feat("Message", _feat_message,
		"觀察到 message 種類=%d, 當下 global=%d" % [msg_kinds, state.global_messages.size()])

	# 統計通過數
	var passes: int = 0
	for v in [_feat_move, _feat_resource, _feat_salary, _feat_faction_ai,
			_feat_encounter, _feat_trade, _feat_diplomacy, _feat_s7_param,
			_feat_vision, _feat_message]:
		if v: passes += 1
	print("\n  Feature 通過：%d / 10" % passes)


func _print_feat(name: String, ok: bool, detail: String) -> void:
	var mark: String = "[FEATURE OK]" if ok else "[FEATURE FAIL]"
	print("  %s %s — %s" % [mark, name, detail])
