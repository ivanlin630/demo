extends SceneTree

# P3 協同戰 feel 驗證場景（藍圖 ruling 2026-06-26 §3「要構造好戰霸主派系跑給我看」）。
# 純驗證腳本：構造好戰派系 A（多 persona member）+ 和平商業派系 B + 獨立敵 → 跑 faction_ai
# → 量測 ruling 4 問：①跟戰隊數合理 ②人格染色 ③不 over-war(B 不被拖入) ④脫軌叛離真發生。
# 不改遊戲邏輯，只建 fixture + 量測。

func _initialize() -> void:
	_run()
	quit()

func _new_state() -> WorldState:
	var s := WorldState.new()
	s.world = WorldData.new()
	s.player_id = -1
	return s

func _tile(s: WorldState, pos: Vector2i) -> void:
	var key: int = pos.x * 1000 + pos.y
	if not s.world.tiles.has(key):
		var t := HexTileData.new(); t.tile_pos = pos; t.terrain = "plains"
		s.world.tiles[key] = t

func _fill(s: WorldState, r: int) -> void:
	for x in range(-r, r + 1):
		for y in range(-r, r + 1):
			_tile(s, Vector2i(x, y))

func _seed(team: TeamData, n: int) -> void:
	var named: int = team.named_members.size() + (1 if team.leader_id != -1 else 0)
	if n - named > 0:
		AnonCohort.add(team.anon_cohorts, "平民", "healthy", n - named)

# 建 unified 隊（TAG_PRODUCE → 走 DecisionEngine）。給足糧避 survival 碾壓。
func _mk_member(s: WorldState, tid: int, pid: int, fid: int, pos: Vector2i,
		values: Dictionary, loyalty: float, enemy_id: int) -> TeamData:
	var t := TeamData.new()
	t.team_id = tid; t.tile_pos = pos; t.faction_id = fid
	t.tags = [TeamData.TAG_PRODUCE]
	var p := PersonData.new(); p.id = pid; p.team_id = tid
	p.values = values; p.loyalty = loyalty
	s.persons[pid] = p; t.leader_id = pid
	_seed(t, 8)
	t.resources = {"food": 99999.0, "material": 50.0, "goods": 30.0, "weapon_melee_low": 10.0}
	s.teams[tid] = t
	if enemy_id != -1:
		s.team_discovered[tid] = [enemy_id]
	return t

func _task(t: TeamData) -> String:
	return t.current_task

func _run() -> void:
	print("=== P3 war scenario: 協同戰 feel 驗證 ===")
	var s := _new_state()
	_fill(s, 6)
	var fai := FactionAISystem.new()

	# ── 獨立敵（faction_id=-1，弱，鄰近派系 A）──
	var enemy := TeamData.new(); enemy.team_id = 99; enemy.tile_pos = Vector2i(2, 0)
	enemy.faction_id = -1
	var e_ldr := PersonData.new(); e_ldr.id = 990; e_ldr.team_id = 99
	s.persons[990] = e_ldr; enemy.leader_id = 990
	_seed(enemy, 4); enemy.resources = {"food": 100.0, "coin": 300.0}
	s.teams[99] = enemy

	# ── 派系 A：好戰霸主 ──
	var a_leader := TeamData.new(); a_leader.team_id = 0; a_leader.tile_pos = Vector2i(0, 0)
	a_leader.faction_id = 100; a_leader.readiness = 1.0
	a_leader.tags = [TeamData.TAG_MILITARY]
	var a_ldr := PersonData.new(); a_ldr.id = 1; a_ldr.team_id = 0
	# attack_score=野心.4+好戰.4-義氣.4 = .36+.36-.04=.68 > .3；established → 攻擊 directive
	a_ldr.values = {"野心": 0.9, "好戰": 0.9, "義氣": 0.1, "慎重": 0.3, "貪婪": 0.5, "殘忍": 0.6}
	a_ldr.loyalty = 1.0
	s.persons[1] = a_ldr; a_leader.leader_id = 1; _seed(a_leader, 12)
	a_leader.resources = {"food": 99999.0, "material": 200.0, "weapon_melee_low": 30.0}
	a_leader.armed_anon_ratio = 1.0   # own_armed≈12 >> 敵 armed_est 2×0.8 → 過攻擊 strength gate
	s.teams[0] = a_leader
	s.team_discovered[0] = [99]
	# leader belief 敵弱（過 strength gate own_armed >= tgt_armed*0.8）
	BeliefSystem.record_claim(s, 0, 99, 990, "親見",
		{"population_est": 4.0, "armed_est": 2.0, "tile_pos": Vector2i(2, 0), "coin_est": 300.0},
		1.0, false)

	# 派系 A 成員（unified，多 persona × loyalty）
	var ma1 := _mk_member(s, 1, 11, 100, Vector2i(1, 0), {"好戰": 0.9, "殘忍": 0.7, "野心": 0.5}, 0.9, 99)   # 忠誠好戰
	var ma2 := _mk_member(s, 2, 12, 100, Vector2i(0, 1), {"好戰": 0.1, "殘忍": 0.1, "野心": 0.4}, 0.9, 99)   # 忠誠溫和
	var ma3 := _mk_member(s, 3, 13, 100, Vector2i(1, 1), {"好戰": 0.5, "野心": 0.9, "貪婪": 0.8}, 0.15, 99)  # 叛逆(低忠誠高野心)
	var ma4 := _mk_member(s, 4, 14, 100, Vector2i(0, -1), {"好戰": 0.5, "野心": 0.5}, 0.7, 99)              # 中庸

	var fa := FactionData.new()
	fa.faction_id = 100; fa.leader_team_id = 0
	fa.member_team_ids = [0, 1, 2, 3, 4]; fa.is_established = true
	s.factions[100] = fa

	# ── 派系 B：和平商業（不該被拖入戰爭）──
	var b_leader := TeamData.new(); b_leader.team_id = 50; b_leader.tile_pos = Vector2i(-4, 0)
	b_leader.faction_id = 200; b_leader.readiness = 1.0
	b_leader.tags = [TeamData.TAG_MERCHANT]
	var b_ldr := PersonData.new(); b_ldr.id = 5; b_ldr.team_id = 50
	b_ldr.values = {"野心": 0.3, "好戰": 0.1, "義氣": 0.7, "貪婪": 0.8}   # attack_score 負 → 無攻擊 directive
	b_ldr.loyalty = 1.0
	s.persons[5] = b_ldr; b_leader.leader_id = 5; _seed(b_leader, 10)
	b_leader.resources = {"food": 99999.0, "goods": 50.0}
	s.teams[50] = b_leader
	var mb1 := _mk_member(s, 51, 511, 200, Vector2i(-4, 1), {"好戰": 0.8, "貪婪": 0.7}, 0.9, 99)   # 好戰但派系不開戰
	var fb := FactionData.new()
	fb.faction_id = 200; fb.leader_team_id = 50
	fb.member_team_ids = [50, 51]; fb.is_established = true
	s.factions[200] = fb

	# ── 跑 faction_ai（驅動 _update_goals → _assign_member_tasks → _decide_unified）──
	for i in 4:
		fai.evaluate_all(s, [0, 1, 2, 3, 4, 50, 51, 99])

	# ── 量測 ──
	print("\n--- 派系 A directive ---")
	print("  f.goals = %s（期望含 攻擊）" % str(fa.goals))

	print("\n--- 派系 A 成員選擇（跟戰 / 染色 / 脫軌）---")
	var a_members := [
		{"t": ma1, "tag": "忠誠好戰", "loy": 0.9, "war": 0.9},
		{"t": ma2, "tag": "忠誠溫和", "loy": 0.9, "war": 0.1},
		{"t": ma3, "tag": "叛逆(低忠高野)", "loy": 0.15, "war": 0.5},
		{"t": ma4, "tag": "中庸", "loy": 0.7, "war": 0.5},
	]
	var attackers: int = 0
	for m in a_members:
		var tt: TeamData = m["t"]
		var atk: bool = _task(tt) == TeamData.TASK_ATTACK
		if atk: attackers += 1
		# attack util（染色量級）
		var ctx := DecisionContext.gather(s, tt)
		var u: float = DecisionTerms.weight("faction_duty", ctx.leader_values) * DecisionTerms.eval("faction_duty", ctx, "攻擊") \
			+ DecisionTerms.weight("attack", ctx.leader_values) * DecisionTerms.eval("attack_drive", ctx, "攻擊")
		var applic: Array = DecisionOptions.applicable(ctx)
		print("  %-16s loy=%.2f 好戰=%.1f → task=%-8s attack_util=%.2f %s" % [
			m["tag"], m["loy"], m["war"], _task(tt), u, "[參戰]" if atk else "[不參戰]"])
		print("       [diag] faction_id=%d directive='%s' atk_target=%d discovered=%s 攻擊applic=%s" % [
			tt.faction_id, ctx.faction_directive, ctx.faction_attack_target,
			str(s.team_discovered.get(tt.team_id, [])), "攻擊" in applic])
	print("  → 跟戰隊數 = %d / 4" % attackers)

	print("\n--- 派系 B（和平商業，驗 war 不擴散）---")
	print("  B.goals = %s（期望無 攻擊）" % str(fb.goals))
	print("  B-leader task=%s  B-member(好戰) task=%s（期望非 攻擊）" % [_task(b_leader), _task(mb1)])

	print("\n--- over-war 檢查 ---")
	var total_attack: int = 0
	for tid in [0, 1, 2, 3, 4, 50, 51]:
		if _task(s.teams[tid]) == TeamData.TASK_ATTACK: total_attack += 1
	print("  全世界 TASK_ATTACK 隊數 = %d（僅派系 A 部分成員，非全打成一團）" % total_attack)

	print("\n=== P3 war scenario DONE ===")
