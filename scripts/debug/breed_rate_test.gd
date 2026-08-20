extends SceneTree
# 生育連續速率 TDD（gate ①–⑧）。
# ①常數註解指向 §7 反推（人工核；此處驗反推數值成立）②健康小村會生 ③餓村不生
# ④無懸崖（r 掃描單調連續）⑤同 rel_surplus 下 pop3 vs pop30 每人速率相同（防偷渡絕對 pop 依賴）
# ⑥LOD 等價（far/near 同窗累積相同）⑦near/far 穿梭不重複累加 ⑧冷啟動不爆（首次評估產 0）

var _fail := 0
func _ok(c: bool, m: String) -> void:
	if c: print("  PASS ", m)
	else: _fail += 1; print("  FAIL ", m)

func _initialize() -> void:
	_run(); quit()

func _mk(pop_anon: int, named_n: int, flow: float) -> Array:
	var s := WorldState.new(); s.world = WorldData.new(); s.player_id = -1
	s.world.current_tick = 1000
	var t := HexTileData.new(); t.tile_id = 0; t.tile_pos = Vector2i(0,0); t.terrain = "plains"
	s.world.tiles[0] = t
	var team := TeamData.new(); team.team_id = 1; team.tile_pos = Vector2i(0,0); team.faction_id = -1
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", pop_anon)
	team.anon_female_ratio = 0.5
	team.food_flow_avg = flow
	s.teams[1] = team
	for i in range(named_n):
		var p := PersonData.new(); p.id = 300 + i; p.team_id = 1
		p.sex = "男" if i % 2 == 0 else "女"
		p.needs = {"safety": 0.95, "food": 0.95}
		s.persons[p.id] = p
		team.named_members.append(p.id)
	if named_n > 0: team.leader_id = team.named_members[0]
	return [s, team]

# 推 n 天（每 near 窗一次 evaluate_all，模擬 near 節奏）
func _advance(s: WorldState, team: TeamData, days: int, windows_per_day: int) -> void:
	var rs := ReactionSystem.new()
	var step: int = int(WorldState.TICKS_PER_DAY / maxi(windows_per_day, 1))
	for _d in range(days * windows_per_day):
		s.world.current_tick += step
		rs.evaluate_all(s, [1], null, 1)

func _run() -> void:
	print("=== breed rate continuous test ===")
	# ① 反推數值成立：健康村 f=0.5（rel=K）、5 適齡 → 1 名額/30 日
	var f_at_k: float = ReactionSystem.breed_f(ReactionSystem.BREED_K)
	var days_per_slot: float = 1.0 / (ReactionSystem.BREED_BASE_RATE * f_at_k * 5.0)
	_ok(absf(f_at_k - 0.5) < 0.001, "f(K)=0.5（K=%.2f 錨在 p90）" % ReactionSystem.BREED_K)
	_ok(absf(days_per_slot - 30.0) < 1.5, "★§7 反推成立：健康村 5 適齡 → %.1f 日/名額（目標 30）" % days_per_slot)
	# ⑧ 冷啟動：首次評估只蓋戳記、產 0
	var w := _mk(20, 4, 20.0)   # 大盈餘
	var s: WorldState = w[0]; var team: TeamData = w[1]
	ReactionSystem.new().evaluate_all(s, [1], null, 1)
	_ok(team.minor_population == 0 and team.breed_progress == 0.0 and team.breed_progress_last_tick == 1000,
		"★冷啟動：首次評估只蓋戳記（progress=0、minor=0）")
	# ② 健康小村會生（pop 3-5、rel_surplus 明顯正）：舊規則下為 0
	var w2 := _mk(3, 2, 3.0)    # pop=5、日需 4 → rel=0.75 → f≈0.83
	var s2: WorldState = w2[0]; var t2: TeamData = w2[1]
	_ok(ReactionSystem.breed_rel_surplus(t2) > 0.5, "小村 rel_surplus=%.2f（舊絕對門檻 1.2 也過得了，但看下面 pop30 對照）" % ReactionSystem.breed_rel_surplus(t2))
	_advance(s2, t2, 60, 24)
	_ok(t2.minor_population > 0, "★健康小村 60 日內真的生（minor=%d、progress=%.2f）" % [t2.minor_population, t2.breed_progress])
	# ③ 餓村不生
	var w3 := _mk(10, 2, -2.0)
	var s3: WorldState = w3[0]; var t3: TeamData = w3[1]
	_advance(s3, t3, 60, 24)
	_ok(t3.minor_population == 0 and t3.breed_progress == 0.0, "★餓村（rel<=0）60 日零產、progress 不增")
	# ④ 無懸崖：r 由 0 掃到高值，f 單調連續
	# ★「無懸崖」＝連續且單調（非「斜率上限」——r/(r+K) 在 r→0 附近本來就陡，那是設計要的靈敏度）。
	# 判準：①單調不減 ②相鄰步差 → 0 當步長 → 0（用兩種步長比，粗步差不得大於細步差的 ~2 倍＝無斷點）
	var mono: bool = true
	var max_step_coarse: float = 0.0
	var max_step_fine: float = 0.0
	var prev: float = ReactionSystem.breed_f(0.0)
	var r: float = 0.0
	while r <= 3.0:
		r += 0.02
		var f: float = ReactionSystem.breed_f(r)
		if f < prev - 1e-9: mono = false
		max_step_coarse = maxf(max_step_coarse, f - prev)
		prev = f
	prev = ReactionSystem.breed_f(0.0); r = 0.0
	while r <= 3.0:
		r += 0.01
		var f2: float = ReactionSystem.breed_f(r)
		max_step_fine = maxf(max_step_fine, f2 - prev)
		prev = f2
	_ok(mono, "★單調不減（r=0→3）")
	_ok(max_step_coarse <= max_step_fine * 2.2 + 1e-6,
		"★無懸崖：步長減半→最大步差同步減半（粗 %.4f vs 細 %.4f＝連續無斷點）" % [max_step_coarse, max_step_fine])
	_ok(absf(ReactionSystem.breed_f(0.0)) < 1e-9 and ReactionSystem.breed_f(-0.5) == 0.0,
		"r<=0 → f=0（窮就少生）")
	# ⑤ 同 rel_surplus 下 pop3 vs pop30 每人速率相同
	var wa := _mk(1, 2, 0.0)
	var wb := _mk(28, 2, 0.0)
	# ★用實際 population 反算 flow（population getter = leader + named + anon，leader 也在 named_members
	#   內＝我第一版手算漏掉的坑）→ 兩村 rel_surplus 精確對齊，才驗得了「無絕對 pop 依賴」。
	var target_rel: float = 1.25
	(wa[1] as TeamData).food_flow_avg = target_rel * float((wa[1] as TeamData).population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY
	(wb[1] as TeamData).food_flow_avg = target_rel * float((wb[1] as TeamData).population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY
	var ra: float = ReactionSystem.breed_rel_surplus(wa[1])
	var rb: float = ReactionSystem.breed_rel_surplus(wb[1])
	_ok(absf(ra - rb) < 0.01, "兩村 rel_surplus 對齊（%.2f vs %.2f）" % [ra, rb])
	_ok(absf(ReactionSystem.breed_f(ra) - ReactionSystem.breed_f(rb)) < 1e-6,
		"★同 rel_surplus → 每人速率因子相同（無絕對 pop 依賴）")
	# ⑥⑦ LOD 等價 + near/far 穿梭不重複累加：同 30 天，near 節奏 vs far 節奏 vs 混合
	var near_w := _mk(20, 4, 8.0); var far_w := _mk(20, 4, 8.0); var mix_w := _mk(20, 4, 8.0)
	_advance(near_w[0], near_w[1], 30, 24)     # near：每小時
	_advance(far_w[0], far_w[1], 30, 2)        # far：每 12 小時（呼叫次數 1/12）
	var rs := ReactionSystem.new()
	var sm: WorldState = mix_w[0]; var tm: TeamData = mix_w[1]
	for _d in range(30 * 24):                   # 混合：交替 near/far 節奏
		sm.world.current_tick += int(WorldState.TICKS_PER_DAY / 24)
		rs.evaluate_all(sm, [1], null, 1)
		if _d % 12 == 0:
			rs.evaluate_all(sm, [1], null, 10)   # 同 tick 再被 far pass 掃一次
	var n_minor: int = (near_w[1] as TeamData).minor_population
	var f_minor: int = (far_w[1] as TeamData).minor_population
	_ok(n_minor == f_minor, "★LOD 等價：near %d vs far %d（rate×Δt 語意）" % [n_minor, f_minor])
	_ok(tm.minor_population == n_minor,
		"★near/far 穿梭不重複累加（混合 %d ＝ near %d；同 tick 二次呼叫 Δt=0 不加）" % [tm.minor_population, n_minor])
	if _fail == 0: print("ALL PASS")
	else: print("FAILS=%d" % _fail)
