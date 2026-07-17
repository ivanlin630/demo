extends SceneTree

# threat-oracle S1.5 god-view fix + perceived_power_ratio 曝（行為變小）
# spec: threat-oracle §S1.5。
# (a) _power_ratio 無 belief fallback other.population→self_team.population（禁 god-view，虛張生效）。
# (b) ctx.perceived_power_ratio 曝（clean 純戰力比，供 S2 winnable；≠ threat_react）。

var _fail: int = 0

func _initialize() -> void:
	_test_power_ratio_no_belief_uses_self_pop()
	_test_ctx_perceived_power_ratio_exposed()
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

func _feq(a: float, b: float, msg: String) -> void:
	_ok(absf(a - b) < 1e-6, "%s (a=%.6f b=%.6f)" % [msg, a, b])

func _mk_team(tid: int, pop: int, tpos: Vector2i) -> TeamData:
	var t := TeamData.new(); t.team_id = tid; t.tile_pos = tpos
	AnonTierSystem.add_anon(t, "平民", pop)
	return t

# (a) 無 belief → _power_ratio 用 self_pop 非 other.population（god-view fix）
func _test_power_ratio_no_belief_uses_self_pop() -> void:
	print("--- (a) 無 belief → _power_ratio self_pop（禁 god-view）---")
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100
	var self_t := _mk_team(1, 10, Vector2i(5, 5))    # 自己 pop=10
	var other := _mk_team(2, 100, Vector2i(6, 5))     # 對方 pop=100（真值，god-view 才看得到）
	state.teams[1] = self_t; state.teams[2] = other
	state.team_discovered[1] = [2]
	# ★不 record 任何 belief claim → best_estimate 空 → 走 fallback
	var ratio: float = ThreatAssessment._power_ratio(state, self_t, other)
	# 修後 fallback=self_pop(10)：other_power = 10×0.3 = 3.0；self_power = 10×avg_combat
	var self_power: float = float(self_t.population) * AnonTierSystem.avg_combat_skill(self_t)
	var expected_self: float = (float(self_t.population) * 0.3) / maxf(self_power, 0.1)
	var expected_god: float = (float(other.population) * 0.3) / maxf(self_power, 0.1)
	print("  [info] ratio=%.4f self_pop-based=%.4f god-view-based=%.4f" % [ratio, expected_self, expected_god])
	_feq(ratio, expected_self, "無 belief → pop_est=self_pop（虛張生效，禁讀 other.population）")
	_ok(absf(ratio - expected_god) > 1e-4, "★確非 god-view（other.population=100 未洩漏）")

# (b) ctx.perceived_power_ratio 曝 + ≠ threat_react
func _test_ctx_perceived_power_ratio_exposed() -> void:
	print("--- (b) ctx.perceived_power_ratio 曝（≠ threat_react）---")
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100
	var self_t := _mk_team(1, 10, Vector2i(5, 5))
	self_t.leader_id = 10
	var ldr := PersonData.new(); ldr.id = 10; ldr.team_id = 1; ldr.values = {"慎重": 0.5}
	state.persons[10] = ldr
	var enemy := _mk_team(2, 12, Vector2i(7, 5)); enemy.faction_id = -1
	enemy.last_tile_pos = Vector2i(8, 5)   # 逼近
	state.teams[1] = self_t; state.teams[2] = enemy
	state.team_discovered[1] = [2]
	state.team_intel[1] = {}
	self_t.known_reputations[2] = 0.1
	BeliefSystem.record_claim(state, 1, 2, 2, "親見", {"population_est": 12}, 1.0, false)
	var ctx := DecisionContext.gather(state, self_t)
	var direct: float = ThreatAssessment._power_ratio(state, self_t, enemy)
	print("  [info] perceived_power_ratio=%.4f _power_ratio(direct)=%.4f threat_react=%.4f" % [
		ctx.perceived_power_ratio, direct, ctx.threat_react])
	_feq(ctx.perceived_power_ratio, direct, "perceived_power_ratio == _power_ratio(threat target)")
	_ok(absf(ctx.perceived_power_ratio - ctx.threat_react) > 1e-6 or ctx.threat_react == 0.0,
		"perceived_power_ratio ≠ threat_react（純戰力比≠approach+hostility blend）")
