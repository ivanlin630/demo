class_name Probe

# 量測累計器（純觀測）。enabled 預設 false → 一般跑 no-op；只 game_sim_test 開。
# 事件點插 1 行 Probe.bump(...)；結尾 Probe.summary()。禁改遊戲 state。
static var enabled: bool = false
static var counts: Dictionary = {}
static var peaks: Dictionary = {}

const AMBUSH_UNDEREST := 0.5   # TEST VALUE：belief 武力低估 < 真值 50% → 視為被誤導

static func bump(event: String, n: int = 1) -> void:
	if not enabled: return
	counts[event] = int(counts.get(event, 0)) + n

static func note(event: String, value: float) -> void:
	if not enabled: return
	peaks[event] = maxf(float(peaks.get(event, 0.0)), value)

static func reset() -> void:
	counts = {}; peaks = {}

static func ambush_check(state: WorldState, attacker_id: int, defender_id: int) -> void:
	if not enabled: return
	var defender = state.teams.get(defender_id)
	if defender == null: return
	var bel: Dictionary = BeliefSystem.best_estimate(state, attacker_id, defender_id)
	if bel.is_empty(): return
	var bel_str: float = float(bel.get("armed_est", bel.get("population_est", 0.0)))
	var real_str: float = float(defender.population)   # 真實力 proxy（armed 解算在戰鬥，pop 為穩定 proxy）
	if real_str > 0.0 and bel_str < real_str * AMBUSH_UNDEREST:
		bump("g3.ambush")

static func _rate(num_key: String, den_key: String) -> String:
	var den: int = int(counts.get(den_key, 0))
	if den == 0: return "n/a"
	return "%.1f%%" % (100.0 * float(counts.get(num_key, 0)) / float(den))

static func summary() -> void:
	print("\n========== [ProbeSummary] ==========")
	var keys: Array = counts.keys(); keys.sort()
	for k in keys:
		print("[ProbeSummary] %-28s = %d" % [k, int(counts[k])])
	for k in peaks:
		print("[ProbeSummary] %-28s peak= %.1f" % [k, float(peaks[k])])
	# 衍生率
	print("[ProbeSummary] 礦村建立次數  = %d" % int(counts.get("g1.mine_founded", 0)))
	print("[ProbeSummary] 鑄幣次數     = %d" % int(counts.get("g1.mint", 0)))
	print("[ProbeSummary] 訂單履約率   = %s" % _rate("g1.order_fulfilled", "g1.order_placed"))
	print("[ProbeSummary] 套利命中率   = %s" % _rate("g1.arb_hit", "g1.arb_attempt"))
	print("[ProbeSummary] scout 收斂率 = %s" % _rate("g3.scout_converge", "g3.scout_dispatch"))
	print("====================================")
