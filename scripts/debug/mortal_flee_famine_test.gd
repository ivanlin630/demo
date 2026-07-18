extends SceneTree

# cause2 fix：_mortal_flee_check 認飢餓（de-patch，膽量秤延進戰鬥）。
# eff>3 絕對門檻對飢餓 pre-empt 膽量秤=補丁閘 → 撕除，飢餓隊即使 eff>3 進絕境逃判。
# ★邊界:FAMINE_W 須大到極端斷糧(food→0)時 famine_pressure 超最勇 flee_thr(1.1)→連勇者餓極也逃。

var _fail: int = 0

func _initialize() -> void:
	_test_healthy_notstarving_no_flee()
	_test_brave_healthy_extreme_famine_flees()
	_test_famine_courage_scale()
	if _fail == 0:
		print("=== DONE === ALL PASS")
	else:
		print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  [PASS] %s" % msg)
	else:
		_fail += 1
		print("  [FAIL] %s" % msg)

# 構 self(pop/wounded/courage/food_days)+enemy(pop)，food_days 經 resources.food 設。
func _mk(state: WorldState, id: int, pop: int, wounded: int, martial: float, caution: float, food_days: float) -> TeamData:
	var t := TeamData.new(); t.team_id = id; t.tile_pos = Vector2i(id, 0); t.leader_id = id * 10
	AnonTierSystem.add_anon(t, "平民", pop)
	t.wounded = wounded
	t.resources = {"food": food_days * float(pop) * ResourceSystem.FOOD_PER_PERSON_PER_DAY}
	var ldr := PersonData.new(); ldr.id = id * 10; ldr.team_id = id
	ldr.values = {"好戰": martial, "慎重": caution}
	state.persons[ldr.id] = ldr
	state.teams[id] = t
	var tile := HexTileData.new(); tile.tile_pos = t.tile_pos
	state.world.tiles[id * 1000] = tile
	return t

func _flee(pop_s: int, wounded_s: int, martial: float, caution: float, food_days: float, pop_e: int) -> bool:
	var st := WorldState.new(); st.world = WorldData.new(); st.world.current_tick = 100
	var ncs := NpcCombatSystem.new()
	_mk(st, 1, pop_s, wounded_s, martial, caution, food_days)
	_mk(st, 2, pop_e, 0, 0.5, 0.5, 5.0)
	return ncs._mortal_flee_check(st, 1, 2)

# (3) 健康+不餓 eff>3 → 續戰（non-starving 不亂逃）
func _test_healthy_notstarving_no_flee() -> void:
	print("--- 健康(eff>3)+不餓 → 續戰(no flee) ---")
	_ok(not _flee(6, 0, 0.5, 0.5, 10.0, 6), "健康 eff=6 + food_days=10(不餓)→ return false 續戰")
	_ok(not _flee(6, 0, 1.0, 0.0, 10.0, 12), "健康勇者 eff=6 + 不餓 + 被 outnumber → 仍續戰(眾寡由既有三端管)")

# (2) 勇者+健康(eff>3)+極端斷糧(food→0) → mortal_flee fire（FAMINE_W 夠，勇者餓極也逃）
func _test_brave_healthy_extreme_famine_flees() -> void:
	print("--- 勇者+健康(eff>3)+極端斷糧 → mortal_flee fire ---")
	# 好戰1慎重0→courage1→flee_thr=1.1(最勇)；food_days=0→famine_pressure=1；FAMINE_W 須頂過 1.1
	_ok(_flee(6, 0, 1.0, 0.0, 0.0, 6), "最勇者健康(eff=6)+極端斷糧(food_days=0)→ mortal_flee fire(餓極必逃,非傻站死)")

# (4) 膽量秤：餓+怯早逃 / 餓+勇撐（同 famine，courage 分流）
func _test_famine_courage_scale() -> void:
	print("--- 膽量秤：餓+怯早逃 / 餓+勇撐 ---")
	# 中度餓(food_days≈1.5→famine_pressure≈0.5)，健康 eff>3(criticality=0)、無 outnumber
	# 怯者 flee_thr=0.5：0.5×FAMINE_W 應 ≥0.5 → 逃；勇者 flee_thr=1.1：0.5×FAMINE_W <1.1 → 撐
	_ok(_flee(6, 0, 0.0, 1.0, 1.5, 6), "餓+怯(courage=0,flee_thr=0.5)→早逃")
	_ok(not _flee(6, 0, 1.0, 0.0, 1.5, 6), "餓+勇(courage=1,flee_thr=1.1)→中度餓仍撐")
