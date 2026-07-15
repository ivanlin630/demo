extends SceneTree

# coin 循環 B 成員稅回收 TDD（slice: coin-circulation）
# spec: docs/superpowers/specs/2026-07-15-coin-circulation.md
# _collect_member_tax：named 成員 person.coin 抽稅回 team.coin 池（破 salary 單向枯竭）。
# ★守恆(池間搬,Δperson=−Δteam)、留 PERSONAL_COIN_FLOOR 不收乾、稅率掛領袖人格、玩家不自動。

var _fail: int = 0

func _initialize() -> void:
	_test_tax_conservation()
	_test_floor_not_drained()
	_test_greed_vs_prudence()
	_test_player_no_auto_tax()
	if _fail == 0:
		print("=== DONE === ALL PASS")
	else:
		print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond: print("  [PASS] %s" % msg)
	else: _fail += 1; print("  [FAIL] %s" % msg)

# team + leader(人格) + N named 成員(各 person.coin)。
func _mk(leader_vals: Dictionary, member_coins: Array, player: bool = false) -> Array:   # → [state, team]
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 0
	var team := TeamData.new(); team.team_id = 1
	team.resources = {"coin": 0.0}
	var ldr := PersonData.new(); ldr.id = 100; ldr.values = leader_vals
	state.persons[100] = ldr; team.leader_id = 100
	if player: state.player_id = 100
	var pid := 200
	for c in member_coins:
		var p := PersonData.new(); p.id = pid; p.coin = float(c)
		state.persons[pid] = p; team.named_members.append(pid)
		pid += 1
	state.teams[1] = team
	return [state, team]

func _members_coin(state: WorldState, team: TeamData) -> float:
	var s: float = 0.0
	for pid in team.named_members: s += state.persons[int(pid)].coin
	return s

func _test_tax_conservation() -> void:
	print("--- 守恆：Δperson = −Δteam（池間搬）---")
	var w := _mk({"貪婪": 0.9, "慎重": 0.1}, [100.0, 100.0])
	var mc0: float = _members_coin(w[0], w[1])
	var tc0: float = float(w[1].resources.get("coin", 0))
	FactionAISystem.new()._collect_member_tax(w[0], w[1])
	var mc1: float = _members_coin(w[0], w[1])
	var tc1: float = float(w[1].resources.get("coin", 0))
	_ok(mc1 < mc0, "成員 coin 降（%.0f→%.0f）" % [mc0, mc1])
	_ok(tc1 > tc0, "team.coin 升（%.0f→%.0f）" % [tc0, tc1])
	_ok(absf((mc0 - mc1) - (tc1 - tc0)) < 0.001, "★守恆：Δperson(%.2f)=−Δteam(%.2f)（總 coin 不變）" % [mc0 - mc1, tc1 - tc0])

func _test_floor_not_drained() -> void:
	print("--- floor：留 PERSONAL_COIN_FLOOR 不收乾 ---")
	var w := _mk({"貪婪": 1.0, "慎重": 0.0}, [100.0])   # max 稅率
	FactionAISystem.new()._collect_member_tax(w[0], w[1])
	var pc: float = w[0].persons[200].coin
	_ok(pc >= FactionAISystem.PERSONAL_COIN_FLOOR, "成員留 coin(%.1f) >= FLOOR(%.1f)（留燃料）" % [pc, FactionAISystem.PERSONAL_COIN_FLOOR])
	# 已在 floor 下 → 不收（levy<=0）
	var w2 := _mk({"貪婪": 1.0, "慎重": 0.0}, [3.0])   # < FLOOR
	FactionAISystem.new()._collect_member_tax(w2[0], w2[1])
	_ok(w2[0].persons[200].coin == 3.0 and float(w2[1].resources.get("coin", 0)) == 0.0, "已在 floor 下 → 不收（levy<=0）")

func _test_greed_vs_prudence() -> void:
	print("--- 人格化：貪婪領袖抽率 > 慎重領袖 ---")
	var wg := _mk({"貪婪": 0.9, "慎重": 0.1}, [100.0])
	FactionAISystem.new()._collect_member_tax(wg[0], wg[1])
	var levy_greed: float = float(wg[1].resources.get("coin", 0))
	var wp := _mk({"貪婪": 0.3, "慎重": 0.9}, [100.0])
	FactionAISystem.new()._collect_member_tax(wp[0], wp[1])
	var levy_prud: float = float(wp[1].resources.get("coin", 0))
	_ok(levy_greed > levy_prud, "貪婪領袖抽稅(%.1f) > 慎重領袖(%.1f)（人格化）" % [levy_greed, levy_prud])

func _test_player_no_auto_tax() -> void:
	print("--- 玩家隊不自動收稅 ---")
	var w := _mk({"貪婪": 0.9, "慎重": 0.1}, [100.0], true)   # player=true
	FactionAISystem.new()._collect_member_tax(w[0], w[1])
	_ok(float(w[1].resources.get("coin", 0)) == 0.0 and w[0].persons[200].coin == 100.0, "玩家隊→不自動收稅（手動）")
