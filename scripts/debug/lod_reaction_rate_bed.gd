extends SceneTree
# ★gate①（靈魂）：rate-equivalence——同條件下 far 隊長窗累積 breed 次數 ≈ near 隊。
#   near 隊（每 NEAR_CADENCE 跑一次、trials=1）vs far 隊（每 FAR_ZONE_INTERVAL 跑一次、trials=10）。
# ★gate②：無玩家 headless → reaction.breed > 0、minor_population 不再全 0。
# 純量測 bed（合成世界、直接呼 ReactionSystem，不動 production）。

var _fail := 0
func _ok(c: bool, m: String) -> void:
	if c: print("  PASS ", m)
	else: _fail += 1; print("  FAIL ", m)

func _initialize() -> void:
	_run(); quit()

func _mk(seed_v: int) -> Array:
	seed(seed_v)
	var s := WorldState.new(); s.world = WorldData.new(); s.player_id = -1
	var t := HexTileData.new(); t.tile_id = 0; t.tile_pos = Vector2i(0,0); t.terrain = "plains"
	t.resources = {"food": 200.0}; t.resource_cap = {"food": 400.0}
	s.world.tiles[0] = t
	var team := TeamData.new(); team.team_id = 1; team.tile_pos = Vector2i(0,0); team.faction_id = -1
	team.tags = [TeamData.TAG_PRODUCE]      # 讓 P2_produce 真的成為 winner（morale target 才會拉高）
	team.work_morale = 0.5                  # ★起點遠離 target → lerp 收斂速度差異才看得出來
	team.food_flow_avg = 5.0            # 盈餘（過 BREED_FLOW_MIN）
	# ★_breed_balance 讀 anon 池的性別比（非 named 的 sex）→ 必須有 anon 母體，否則 balance=0 恆不生
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", 60)
	team.anon_female_ratio = 0.5
	team.resources = {"food": 300.0}
	s.teams[1] = team
	# 40 名有名成員（半男半女、needs 足）→ 生育母體夠大、cap=pop*0.25
	# 一名高壓成員 → N2_riot 真的 fire（unrest 才有累積可比）
	var rioter := PersonData.new(); rioter.id = 90; rioter.team_id = 1
	rioter.sex = "男"; rioter.needs = {"safety": 0.2, "food": 0.9}
	rioter.stress = 0.95; rioter.fear = 0.95; rioter.loyalty = 0.5
	rioter.values = {"殘忍": 0.9, "慎重": 0.1}
	s.persons[rioter.id] = rioter; team.named_members.append(rioter.id)
	for i in range(3):   # 少量 named breeder → 期望次數落在未飽和區
		var p := PersonData.new(); p.id = 100 + i; p.team_id = 1
		p.sex = "男" if i % 2 == 0 else "女"
		p.needs = {"safety": 0.9, "food": 0.9}
		p.skills = {"生產": 0.8}
		p.loyalty = 0.9; p.stress = 0.1
		s.persons[p.id] = p
		team.named_members.append(p.id)
	team.leader_id = team.named_members[0]
	return [s, team]

func _run() -> void:
	print("=== LOD rate-equivalence bed ===")
	# ★窗長要落在【未飽和】區間才是真 rate 證據（撞 cap 兩側都會等於 cap＝ratio 假 1.00）。
	var windows: int = int(OS.get_environment("ADHOC_TICKS")) if OS.get_environment("ADHOC_TICKS") != "" else 20
	# A：near 節奏（每窗呼一次、trials=1）
	var wa := _mk(1337); var sa: WorldState = wa[0]; var ta: TeamData = wa[1]
	var rs := ReactionSystem.new()
	Probe.enabled = true; Probe.reset()
	for _i in range(windows):
		sa.world.current_tick += WorldState.TICKS_PER_HOUR
		rs.evaluate_all(sa, [1], null, 1)
	var near_breed: int = int(Probe.counts.get("reaction.breed", 0))
	var near_minor: int = ta.minor_population
	var near_morale: float = ta.work_morale
	var near_unrest: int = ta.unrest_turns
	# B：far 節奏（每 10 窗呼一次、trials=10）＝同樣 720 個 near 窗的時間
	var wb := _mk(1337); var sb: WorldState = wb[0]; var tb: TeamData = wb[1]
	Probe.reset()
	for _i in range(windows / 10):
		sb.world.current_tick += WorldState.TICKS_PER_HOUR * 10
		rs.evaluate_all(sb, [1], null, 10)
	var far_breed: int = int(Probe.counts.get("reaction.breed", 0))
	var far_minor: int = tb.minor_population
	var far_morale: float = tb.work_morale
	var far_unrest: int = tb.unrest_turns
	Probe.enabled = false
	print("  near: breed=%d minor=%d ｜ far: breed=%d minor=%d（同 %d 個 near 窗）" % [
		near_breed, near_minor, far_breed, far_minor, windows])
	_ok(near_breed > 0 and far_breed > 0, "★兩側都真的 fire（不是只證有 fire 就算過，見下方 ratio）")
	var ratio: float = float(far_breed) / maxf(float(near_breed), 1.0)
	_ok(ratio >= 0.7 and ratio <= 1.4, "★rate-equivalence：far/near = %.2f（容差 0.7~1.4）" % ratio)
	_ok(absf(float(far_minor - near_minor)) <= maxf(float(near_minor) * 0.4, 2.0),
		"minor_population 收斂相當（near %d vs far %d）" % [near_minor, far_minor])
	# cap 檢查：兩側都不得超過 pop*0.25
	var cap_a: int = maxi(1, int(ta.population * 0.25))
	_ok(near_minor < cap_a and far_minor < cap_a,
		"★未飽和區間（cap=%d、near %d、far %d）＝ratio 是真 rate 證據、非被 cap 綁住" % [cap_a, near_minor, far_minor])
	_ok(near_minor <= cap_a and far_minor <= cap_a,
		"★團級 cap 兩側都守住（cap=%d、near %d、far %d）＝迴圈內逐次檢查有效" % [cap_a, near_minor, far_minor])
	# ★addendum gate：累積型（每次呼叫累積一點）也要 far≈near——判準是「每次呼叫是否累積」非「有沒有 RNG」。
	print("  work_morale: near=%.4f far=%.4f ｜ unrest: near=%d far=%d" % [
		near_morale, far_morale, near_unrest, far_unrest])
	_ok(absf(near_morale - far_morale) <= 0.05,
		"★work_morale far≈near（|Δ|=%.4f ≤ 0.05）＝lerp 補償 w_eff=1-(1-0.1)^trials 有效（它乘進採集產出）" % absf(near_morale - far_morale))
	_ok(absf(float(near_unrest - far_unrest)) <= maxf(float(near_unrest) * 0.25, 2.0),
		"★unrest far≈near（near %d vs far %d）＝±1×trials 補償有效" % [near_unrest, far_unrest])
	if _fail == 0: print("ALL PASS")
	else: print("FAILS=%d" % _fail)
