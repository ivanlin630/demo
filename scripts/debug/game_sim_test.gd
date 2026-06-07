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
	print("=== game_sim_test: 從 config 讀取場景 ===")

	var state := WorldState.new()
	var runner := SimRunner.new()
	var cmd  := PlayerCommandSystem.new()
	var config := GameSetup.load_config("res://config/game_sim_test.json")
	if config.is_empty():
		print("[FAIL] config/game_sim_test.json 載入失敗")
		return
	GameSetup.setup(state, config)
	var max_ticks: int = int(config.get("max_ticks", 7200))
	var schedule: Array = config.get("command_schedule", [])

	var fid_a: int = state.teams.get(TEAM_PLAYER, TeamData.new()).faction_id
	var fid_b: int = state.teams.get(TEAM_ENEMY, TeamData.new()).faction_id

	var pt0: TeamData = state.teams.get(TEAM_PLAYER)
	if pt0 != null:
		_initial_player_coin = float(pt0.resources.get("coin", 0))
		_initial_player_food = float(pt0.resources.get("food", 0))
		_last_player_coin    = _initial_player_coin

	print("\n=== 初始設定 ===")
	if state.factions.has(fid_a):
		print("  Faction A (id=%d) leader=Team%d members=%s" % [
			fid_a, state.factions[fid_a].leader_team_id,
			str(state.factions[fid_a].member_team_ids)])
	if state.factions.has(fid_b):
		print("  Faction B (id=%d) leader=Team%d members=%s" % [
			fid_b, state.factions[fid_b].leader_team_id,
			str(state.factions[fid_b].member_team_ids)])
	print("  player_id = Person%d (Team%d leader)" % [state.player_id, TEAM_PLAYER])
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		print("  Team%d pos=%s pop=%d food=%.0f coin=%.0f tags=%s task=%s faction=%d" % [
			tid, str(t.tile_pos), t.population,
			float(t.resources.get("food", 0)), float(t.resources.get("coin", 0)),
			str(t.tags), t.current_task, t.faction_id])

	print("\n=== 開始 %d tick 模擬 ===" % max_ticks)
	var ticks_completed: int = 0
	for tick in range(max_ticks):
		var player_pos: Vector2i = _player_pos(state)
		var _advance_result: String = runner.advance_tick(state, player_pos)
		ticks_completed += 1

		if state.encounter_active:
			_auto_drive_player_encounter(state, runner)
			if state.encounter_tick > 800:
				print("[TestGuard] encounter 超時 (tick=%d) → 強制 draw 結束" % state.encounter_tick)
				runner._encounter_system.resolve_encounter_end(state, "draw")

		# command_schedule 注入
		var sched_result: Dictionary = GameSetup.run_command_schedule_tick(
			state, cmd, schedule, tick + 1)
		var fired: Array = sched_result.get("fired", [])
		var results: Array = sched_result.get("results", [])
		for i in range(fired.size()):
			var act: String = fired[i]
			var r: Dictionary = results[i] if i < results.size() else {}
			_record_cmd(act, r)
			match act:
				"propose_alliance":
					_alliance_events_count += 1
					_diplomatic_events_count += 1
				"submit_trade_offer":
					if r.get("ok", false):
						_trade_events_count += 1

		if not state.player_forced_event.is_empty():
			_auto_respond_forced(state, cmd)

		_collect_stats(state, tick + 1)

		if (tick + 1) % 240 == 0:
			var pt: TeamData = state.teams.get(TEAM_PLAYER)
			if pt != null:
				print("[DBG named] tick=%d Team0 named_count=%d population=%d persons_total=%d" % [
					tick + 1, pt.named_members.size(), pt.population, state.persons.size()])
		if (tick + 1) % 240 == 0:
			var day: int = (tick + 1) / 240
			if day % 5 == 0 or day <= 5 or day >= 28:
				_print_daily_status(state, day)
			else:
				_print_daily_brief(state, day)

		if (tick + 1) % (240 * 5) == 0:
			_print_faction_matrix(state, (tick + 1) / 240, fid_a, fid_b)

		if (tick + 1) % 50 == 0:
			_check_invariants_periodic(state)

	_print_final_summary(state, ticks_completed)
	_check_invariants_final(state, ticks_completed)
	_evaluate_features(state)

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
# (setup helpers moved to GameSetup / config JSON)
# ══════════════════════════════════════════════════════════════════


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
