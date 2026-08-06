extends SceneTree

# ★F0 自身驗收（spec §4）：儀器不擾世界。★零 global RNG（R² 觀察①=直接 RNG 斷言為主、更快失敗好 debug；
# 第三度 RNG 警戒 feedback_observer_no_global_rng LOD→RNG 犯過 2 次）+ deterministic + 純讀不寫 state。

var _fail: int = 0
func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else: _fail += 1; print("  [FAIL] %s" % m)

func _initialize() -> void:
	# 真 seeded warring state 跑 500 tick（真世界、多域活）→ 對其自驗儀器。
	seed(1337)
	var state := WorldState.new()
	GameSetup.setup(state, GameSetup.load_config("res://config/warring_states.json"))
	var runner := SimRunner.new()
	for _t in range(500):
		runner.advance_tick(state, Vector2i(-1, -1))

	# ①★零 RNG（主）：compute() 前後同 seed 起點取 randi 相同 → compute 消耗 0 draw。
	seed(424242)
	var r_before: int = randi()
	seed(424242)
	var fp_a: String = StateFingerprint.compute(state)
	var fp_b: String = StateFingerprint.compute(state)
	var r_after: int = randi()
	_ok(r_before == r_after, "★零 global RNG：compute()×2 前後同 seed 起點 randi 相同(r=%d)＝零 draw(儀器不擾世界)" % r_before)

	# ②deterministic：同 state compute 兩次相同 + 32-hex。
	_ok(fp_a == fp_b and fp_a.length() == 32, "deterministic：同 state compute×2 相同 fp=%s(32-hex)" % fp_a)

	# ③純讀不寫：compute 前後 state 關鍵欄不變（team pop/task/tile 快照對比）＝零 mutation。
	var snap: Array = []
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		snap.append([tid, t.population, t.current_task, t.tile_pos, t.faction_id])
	var _ignore: String = StateFingerprint.compute(state)
	var unchanged: bool = true
	var i: int = 0
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		var s: Array = snap[i]; i += 1
		if s[0] != tid or s[1] != t.population or s[2] != t.current_task or s[3] != t.tile_pos or s[4] != t.faction_id:
			unchanged = false; break
	_ok(unchanged, "純讀不寫：compute 前後 %d 隊 pop/task/tile/faction 快照全同＝零 state mutation" % state.teams.size())

	# ④軌跡不變（輔）：再跑一次同 seed sim（不呼 compute）到 500 tick、fingerprint 應同 → 儀器不改世界軌跡。
	seed(1337)
	var state2 := WorldState.new()
	GameSetup.setup(state2, GameSetup.load_config("res://config/warring_states.json"))
	var runner2 := SimRunner.new()
	for _t in range(500):
		runner2.advance_tick(state2, Vector2i(-1, -1))
	var fp_clean: String = StateFingerprint.compute(state2)
	_ok(fp_clean == fp_a, "軌跡不變（輔）：另跑同 seed sim(全程無 compute 干擾)到 500tick fp 相同＝儀器零軌跡漂移")

	# ⑤敏感度：改一隊 task（真持久欄）→ fp 變（安全網真攔行為漂移）。
	var any_tid = state.teams.keys()[0]
	(state.teams[any_tid] as TeamData).current_task = "★test_mutant"
	_ok(StateFingerprint.compute(state) != fp_a, "敏感：改 1 隊 current_task → fp 變(結構 slice 誤改行為即 diff、安全網有效)")

	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()
