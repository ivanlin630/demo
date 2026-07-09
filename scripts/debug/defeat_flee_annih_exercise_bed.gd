extends SceneTree

# 敗北逃 rev2 殲滅端定向 exercise 床（守衛床，留檔複跑）。
# 為什麼：organic full_probe（3seed/3mo）annih=0 是 sample 空洞（mortal_flee.n_high=0，
# 高勇氣小隊從沒進戰），非「稀」。此床用確定性 synthetic encounter matrix 直接構造
# 「高勇氣小隊 × eff 劣勢 × outnumber」交集，逼 n_high>0，量殲滅端真數字。
# rev2 公式不動、不調參（見 handback 2026-07-10-systems-to-measurer-defeat-flee-annih-exercise-bed）。
#
# courage 桶（好戰/慎重）：high(1.0/0.0) mid(0.5/0.5) low(0.0/1.0)
# self eff（pop-wounded，含 leader+anon，無 wounded）：{1,2,3}
# enemy eff：{1,2,3,4}
# 每格 REPEATS 場（seed 逐場遞增 → 確定性可複跑，非同場重複）。

const COURAGE_BUCKETS: Dictionary = {
	"high": {"martial": 1.0, "caution": 0.0},
	"mid":  {"martial": 0.5, "caution": 0.5},
	"low":  {"martial": 0.0, "caution": 1.0},
}
const SELF_EFFS: Array = [1, 2, 3]
const ENEMY_EFFS: Array = [1, 2, 3, 4]
const REPEATS: int = 20
const MAX_ROUNDS: int = 80   # 安全上限，避免異常無限迴圈

var _combat_sys: NpcCombatSystem
var _next_id: int = 1000
var _base_seed: int = 900001

func _initialize() -> void:
	_run()
	quit()

func _mk_leader(state: WorldState, martial: float, caution: float) -> int:
	var pid: int = _next_id
	_next_id += 1
	var p := PersonData.new()
	p.id = pid
	p.values = {"好戰": martial, "慎重": caution, "殘忍": 0.5, "義氣": 0.5}
	p.skills = {"統領": 0.5, "戰術": 0.0, "弓箭": 0.0}
	state.persons[pid] = p
	return pid

# eff = 1(leader) + anon_healthy。anon 塞「平民」桶（tier 對此測不重要，只需 pop 計數）。
func _mk_team(state: WorldState, tid: int, martial: float, caution: float, eff: int, pos: Vector2i) -> void:
	var leader_id: int = _mk_leader(state, martial, caution)
	var t := TeamData.new()
	t.team_id = tid
	t.leader_id = leader_id
	t.tile_pos = pos
	t.readiness = 1.0
	if eff > 1:
		AnonTierSystem.add_anon(t, "平民", eff - 1)
	state.teams[tid] = t

# 跑到終局（combat_target 清空 或 一方隊消失）或 MAX_ROUNDS 安全跳出。回 "annihilation"/"mortal_flee"/"other"/"timeout"。
func _run_one_encounter(state: WorldState, self_id: int, enemy_id: int) -> String:
	var pre_annih: int = int(Probe.counts.get("combat.end_annihilation", 0))
	var pre_flee: int = int(Probe.counts.get("mortal_flee.n", 0))
	_combat_sys.start_combat(state, self_id, enemy_id)
	var rounds: int = 0
	while state.teams.has(self_id) and state.teams.has(enemy_id) \
			and state.teams[self_id].combat_target == enemy_id \
			and state.teams[enemy_id].combat_target == self_id and rounds < MAX_ROUNDS:
		_combat_sys.process_ongoing_combat(state, [self_id, enemy_id])
		rounds += 1
	var post_annih: int = int(Probe.counts.get("combat.end_annihilation", 0))
	var post_flee: int = int(Probe.counts.get("mortal_flee.n", 0))
	if post_annih > pre_annih: return "annihilation"
	if post_flee > pre_flee: return "mortal_flee"
	if rounds >= MAX_ROUNDS: return "timeout"
	return "other"

func _run() -> void:
	print("=== defeat_flee_annih_exercise_bed（殲滅端定向床，rev2）===")
	Probe.enabled = true
	Probe.reset()
	_combat_sys = NpcCombatSystem.new()

	var outcome_by_bucket: Dictionary = {}
	for bk in COURAGE_BUCKETS:
		outcome_by_bucket[bk] = {"annihilation": 0, "mortal_flee": 0, "other": 0, "timeout": 0, "n": 0}

	var run_seed: int = _base_seed
	for bk in COURAGE_BUCKETS.keys():
		var c: Dictionary = COURAGE_BUCKETS[bk]
		for self_eff in SELF_EFFS:
			for enemy_eff in ENEMY_EFFS:
				for _r in range(REPEATS):
					run_seed += 1
					seed(run_seed)
					var state := WorldState.new()
					var self_id: int = 1
					var enemy_id: int = 2
					_mk_team(state, self_id, c["martial"], c["caution"], self_eff, Vector2i(0, 0))
					# enemy：均值 courage（固定，非本測變因），無 tile 位移
					_mk_team(state, enemy_id, 0.5, 0.5, enemy_eff, Vector2i(0, 0))
					var outcome: String = _run_one_encounter(state, self_id, enemy_id)
					outcome_by_bucket[bk][outcome] += 1
					outcome_by_bucket[bk]["n"] += 1

	print("\n--- outcome by courage bucket（self 為受測方，enemy 固定 mid）---")
	for bk in ["high", "mid", "low"]:
		var d: Dictionary = outcome_by_bucket[bk]
		print("  courage=%s  n=%d  annihilation=%d  mortal_flee=%d  other=%d  timeout=%d" % [
			bk, d["n"], d["annihilation"], d["mortal_flee"], d["other"], d["timeout"]])

	print("\n--- Probe 分桶（WarringHarness 同款 key）---")
	for k in ["mortal_flee.n", "mortal_flee.n_high", "mortal_flee.n_mid", "mortal_flee.n_low",
			"annih.n_high", "annih.n_mid", "annih.n_low",
			"combat.end_annihilation", "combat.end_rout", "combat.end_retreat", "combat.ended_n",
			"conq.combat_entered", "conq.combat_decisive", "conq.retreat_captured", "conq.no_capture"]:
		print("  %s=%d" % [k, int(Probe.counts.get(k, 0))])

	var annih_n: int = int(Probe.counts.get("combat.str_ratio_annih_n", 0))
	if annih_n > 0:
		var str_ratio_mean: float = Probe.amount("combat.str_ratio_annih_sum") / float(annih_n)
		var pop_ratio_mean: float = Probe.amount("combat.pop_ratio_annih_sum") / float(annih_n)
		print("  str_ratio_annih_mean=%.3f  pop_ratio_annih_mean=%.3f  (n=%d)" % [
			str_ratio_mean, pop_ratio_mean, annih_n])
	else:
		print("  str_ratio_annih_mean=N/A pop_ratio_annih_mean=N/A (annih_n=0)")

	var n_high_flee: int = int(Probe.counts.get("mortal_flee.n_high", 0))
	var n_high_annih: int = int(Probe.counts.get("annih.n_high", 0))
	print("\n[定案數字] n_high(mortal_flee)=%d  n_high(annih)=%d" % [n_high_flee, n_high_annih])
	print("[定案數字] n_high>0 達成 = %s" % ("YES" if n_high_flee > 0 or n_high_annih > 0 else "NO"))

	Probe.enabled = false
	print("\n=== defeat_flee_annih_exercise_bed DONE ===")
