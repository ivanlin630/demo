extends SceneTree
# 生育(a) anon 也算生育者 TDD（slice: breed-anon-eligible）。
# gate3 窮村仍不生（rel_surplus<=0 → f=0 → 零產出）
# gate4 ★安全代理有效：同糧食、named 安全門檻全滅 → 速率顯著下降
# gate5 ★wounded 不算：anon 全移進 wounded 桶 → 不生
# ＋ anon 真的貢獻（無 named 適齡但有 anon → daily > 0）＋ 無 named 時 fallback 0.5

var _fail := 0
func _ok(c: bool, m: String) -> void:
	if c: print("  PASS ", m)
	else: _fail += 1; print("  FAIL ", m)

func _initialize() -> void:
	_run(); quit()

func _mk(anon_healthy: int, named_safe: bool, food_flow: float, wounded: int = 0) -> Array:
	var s := WorldState.new(); s.world = WorldData.new()
	s.world.current_tick = 10000
	var t := HexTileData.new(); t.tile_id = 0; t.tile_pos = Vector2i(0, 0); t.terrain = "plains"
	t.resources = {"food": 100.0}; t.resource_cap = {"food": 300.0}
	s.world.tiles[0] = t
	var team := TeamData.new(); team.team_id = 1; team.tile_pos = Vector2i(0, 0)
	if anon_healthy > 0: AnonCohort.add(team.anon_cohorts, "平民", "healthy", anon_healthy)
	if wounded > 0: AnonCohort.add(team.anon_cohorts, "平民", "wounded", wounded)
	team.anon_female_ratio = 0.5
	team.resources = {"food": 200.0}
	team.food_flow_avg = food_flow
	team.breed_progress_last_tick = 10000 - WorldState.TICKS_PER_DAY   # 已過一天
	s.teams[1] = team
	var p := PersonData.new(); p.id = 100; p.team_id = 1; p.sex = "female"
	p.needs = {"safety": 0.9 if named_safe else 0.2, "food": 0.9}
	s.persons[100] = p
	team.leader_id = 100
	team.named_members.append(100)
	return [s, team]

func _rate(s: WorldState, team: TeamData) -> float:
	var before: float = team.breed_progress
	var rs := ReactionSystem.new()
	rs._tick_breed(s, team)
	return team.breed_progress - before

func _run() -> void:
	print("=== breed anon eligible test ===")
	Probe.enabled = true; Probe.reset()

	# 基準：6 healthy anon + 1 安全 named + 正食物流
	var w := _mk(6, true, 8.0)
	var base_rate: float = _rate(w[0], w[1])
	_ok(base_rate > 0.0, "基準：健康村有產出（daily=%.5f）" % base_rate)
	_ok(int(Probe.counts.get("breed.eligible_anon", 0)) >= 1, "★anon 真的被算成生育者（tap 有值）")

	# gate3 窮村：食物流 <= 0 → f=0 → 零產出
	var w3 := _mk(6, true, 0.0)
	_ok(_rate(w3[0], w3[1]) == 0.0, "gate3 窮村不生（rel_surplus<=0）")

	# gate4 ★安全代理：同糧食、named 安全門檻全滅
	var w4 := _mk(6, false, 8.0)
	var unsafe_rate: float = _rate(w4[0], w4[1])
	_ok(unsafe_rate < base_rate, "★gate4 named 全不安全 → 速率下降（%.5f < %.5f）" % [unsafe_rate, base_rate])
	_ok(unsafe_rate == 0.0, "★gate4 安全代理=0（唯一 named 不安全）→ anon 也不生")

	# gate5 ★wounded 不算：anon 全在 wounded 桶
	# ★測的是【anon 這一半】：所以移除 named（否則 named 自己就會生，測不到 anon 的貢獻）。
	#   註：named 在場時即使 anon 全 wounded 仍會生，因為 _breed_balance 的兩性池含 wounded——
	#   那是既有行為，spec 明令本刀不動 balance，已記進交件。
	var w5 := _mk(0, true, 8.0, 6)
	var s5: WorldState = w5[0]; var t5: TeamData = w5[1]
	s5.persons.clear(); t5.named_members.clear(); t5.leader_id = -1
	_ok(_rate(s5, t5) == 0.0, "★gate5 anon 全 wounded（且無 named）→ 不生")

	# 無 named 時 fallback 0.5（不是 1.0）
	var w6 := _mk(6, true, 8.0)
	var s6: WorldState = w6[0]; var t6: TeamData = w6[1]
	s6.persons.clear(); t6.named_members.clear(); t6.leader_id = -1
	var rate_noname: float = _rate(s6, t6)
	var w7 := _mk(6, true, 8.0)
	var rate_named_safe: float = _rate(w7[0], w7[1])
	_ok(rate_noname > 0.0 and rate_noname < rate_named_safe,
		"★無 named → fallback 0.5（%.5f 介於 0 與全安全 %.5f 之間，非預設最安全）" % [rate_noname, rate_named_safe])

	Probe.enabled = false
	print("=== %s（fail=%d）===" % ["ALL PASS" if _fail == 0 else "HAS FAILURE", _fail])
