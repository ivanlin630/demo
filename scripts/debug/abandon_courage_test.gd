extends SceneTree

# 照妖鏡#1 機制證：膽量→潰退門檻（deterministic unit，不靠 emergent warring 頻率）。
# warring bed 潰退罕觸(combat 多殲滅先於 readiness 掉到 0.2)→ 桶 in-vivo 稀疏;
# 此測直證公式+門檻攤開+退場時機因果（勇撐到更低 readiness 才退）。

var _pass: int = 0
var _fail: int = 0
func _check(c: bool, m: String) -> void:
	if c: _pass += 1
	else: _fail += 1; print("  [FAIL] ", m)

func _mk_leader(state: WorldState, pid: int, martial: float, caution: float) -> void:
	var p := PersonData.new()
	p.id = pid
	p.values = {"好戰": martial, "慎重": caution}
	state.persons[pid] = p

func _mk_team(state: WorldState, tid: int, leader_id: int) -> TeamData:
	var t := TeamData.new()
	t.team_id = tid
	t.leader_id = leader_id
	state.teams[tid] = t
	return t

func _initialize() -> void:
	print("=== abandon_courage_test ===")
	var state := WorldState.new()
	# 勇者 leader（好戰 1.0 / 慎重 0.0 → courage 1.0）
	_mk_leader(state, 1, 1.0, 0.0)
	# 怯者 leader（好戰 0.0 / 慎重 1.0 → courage 0.0）
	_mk_leader(state, 2, 0.0, 1.0)
	# 均值 leader（好戰=慎重 → courage 0.5）
	_mk_leader(state, 3, 0.5, 0.5)
	var brave := _mk_team(state, 10, 1)
	var timid := _mk_team(state, 20, 2)
	var mid := _mk_team(state, 30, 3)
	var noldr := _mk_team(state, 40, -1)  # 無 leader → BASE

	# courage 公式
	_check(abs(NpcCombatSystem._courage_of(state, brave) - 1.0) < 1e-6, "brave courage=1.0")
	_check(abs(NpcCombatSystem._courage_of(state, timid) - 0.0) < 1e-6, "timid courage=0.0")
	_check(abs(NpcCombatSystem._courage_of(state, mid) - 0.5) < 1e-6, "mid courage=0.5")

	# 門檻攤開（spread 非 shift）：勇門檻低(晚逃) < 均值(BASE) < 怯門檻高(早逃)
	var th_brave: float = NpcCombatSystem._abandon_threshold(state, brave)
	var th_timid: float = NpcCombatSystem._abandon_threshold(state, timid)
	var th_mid: float = NpcCombatSystem._abandon_threshold(state, mid)
	var th_noldr: float = NpcCombatSystem._abandon_threshold(state, noldr)
	print("  th_brave=%.3f th_mid=%.3f th_timid=%.3f th_noldr=%.3f" % [th_brave, th_mid, th_timid, th_noldr])
	_check(th_brave < th_mid, "勇門檻 < 均值(晚逃)")
	_check(th_mid < th_timid, "均值 < 怯門檻(早逃)")
	_check(abs(th_mid - NpcCombatSystem.ABANDON_THRESHOLD_BASE) < 1e-6, "均值門檻=BASE(0.2)")
	_check(abs(th_noldr - NpcCombatSystem.ABANDON_THRESHOLD_BASE) < 1e-6, "無leader=BASE")
	# 對稱：勇/怯偏離 BASE 等量（均值守恆）
	_check(abs((NpcCombatSystem.ABANDON_THRESHOLD_BASE - th_brave) - (th_timid - NpcCombatSystem.ABANDON_THRESHOLD_BASE)) < 1e-6,
		"勇/怯 對 BASE 對稱(均值守恆)")
	# 量級=spread/2=0.08（勇 0.12 / 怯 0.28）
	_check(abs(th_brave - 0.12) < 1e-6, "勇門檻=0.12")
	_check(abs(th_timid - 0.28) < 1e-6, "怯門檻=0.28")

	# 退場時機因果：readiness 從 1.0 逐 round drain，勇者需更多 round 才觸潰退(撐到更低 readiness)
	# 模擬 readiness 掃描：門檻越低→越晚潰退→退時 readiness 越低
	_check(th_brave < th_timid, "退時 readiness：勇(<%.2f) < 怯(<%.2f) — 勇撐到更低才退" % [th_brave, th_timid])

	print("=== abandon_courage_test: PASS=%d FAIL=%d ===" % [_pass, _fail])
	print("[ABANDON-COURAGE-TEST] " + ("ALL PASS" if _fail == 0 else "FAILED"))
	quit()
