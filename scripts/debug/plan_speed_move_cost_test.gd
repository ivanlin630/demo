extends SceneTree
# @bed-kind: acceptance
# slice: 普查批一① MOVE_TILES_PER_DAY 接執行端真成本
#
# 驗收四格（HOW spec 2026-09-09 §4）：
#   ①慢隊的計畫天數要比中性隊長  ②快隊比舊平版估短
#   ③單位健全性（區間判準，抓「差 1440 倍＝接錯」）
#   ④rootdiff.* 三格不得被決策端污染（★含反向對照：執行端呼叫時必須【會】動）

const OLD_FLAT: float = 2.0   # ★舊常數（production 已刪）——這裡只當【對照基準】

var _fails: int = 0
var _sections: int = 0
const EXPECT_SECTIONS: int = 3   # ★總結行要同時答【跑完了嗎】與【驗過了嗎】：
#   本床第一版在 ④ 中途崩掉,而它照樣印 FAILS=0 —— ★中途崩跟通過長得一樣。

func _initialize() -> void:
	print("=== PLAN SPEED FROM REAL MOVE COST ===")
	_test_differentiation()
	_test_unit_sanity()
	_test_probe_not_polluted()
	if _sections != EXPECT_SECTIONS:
		_fails += 1
		push_error("[FAIL] 只跑完 %d/%d 段 —— 中途崩掉（★沒有這一格,崩掉會印成 FAILS=0）" % [_sections, EXPECT_SECTIONS])
	print("=== DONE === SECTIONS=%d/%d FAILS=%d" % [_sections, EXPECT_SECTIONS, _fails])
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_fails += 1
		push_error("[FAIL] " + msg)

func _put_tile(st: WorldState, pos: Vector2i, terrain: String) -> void:
	var t := HexTileData.new()
	t.tile_pos = pos
	t.terrain = terrain
	st.world.tiles[pos.x * 1000 + pos.y] = t

func _mk_team(st: WorldState, tid: int, pos: Vector2i) -> TeamData:
	var tm := TeamData.new()
	tm.team_id = tid
	tm.tile_pos = pos
	AnonTierSystem.add_anon(tm, "平民", 10)
	tm.resources = { "food": 10.0 }
	st.teams[tid] = tm
	return tm

# 中性 / 慢 / 快 三隊（同一個世界，只差它們自己的狀態）
func _mk_world() -> Dictionary:
	var st := WorldState.new()
	_put_tile(st, Vector2i(0, 0), "plains")
	_put_tile(st, Vector2i(1, 0), "mountain")
	_put_tile(st, Vector2i(2, 0), "plains")
	var neutral := _mk_team(st, 0, Vector2i(0, 0))
	var slow := _mk_team(st, 1, Vector2i(1, 0))
	slow.fatigue = 1.0
	slow.resources = { "food": 3000.0 }   # 重載（cap = pop*BASE_CARRY = 100，重 300）
	var fast := _mk_team(st, 2, Vector2i(2, 0))
	fast.resources = { "food": 10.0, "mounts": 10.0 }
	return { "state": st, "neutral": neutral, "slow": slow, "fast": fast }

func _days(st: WorldState, tm: TeamData, target: Vector2i) -> float:
	return GoalResolver._estimate_delay_days(st, tm, { "task": TeamData.TASK_TRADE, "target": target })

func _tiles_per_day(st: WorldState, tm: TeamData) -> float:
	var cost: int = MovementSystem.move_cost_pure(st, tm, 1.0, null)
	return float(WorldState.TICKS_PER_DAY) / float(maxi(cost, 1))

func _test_differentiation() -> void:
	print("-- ①② 計畫天數要分得出快慢 --")
	var w := _mk_world()
	var st: WorldState = w["state"]
	var target := Vector2i(20, 0)
	var d_neutral: float = _days(st, w["neutral"], target)
	var d_slow: float = _days(st, w["slow"], target)
	var d_fast: float = _days(st, w["fast"], target)
	var dist_n: int = FactionAISystem._hex_dist((w["neutral"] as TeamData).tile_pos, target)
	var dist_s: int = FactionAISystem._hex_dist((w["slow"] as TeamData).tile_pos, target)
	var dist_f: int = FactionAISystem._hex_dist((w["fast"] as TeamData).tile_pos, target)
	print("  中性 dist=%d days=%.2f (tiles/day=%.2f)" % [dist_n, d_neutral, _tiles_per_day(st, w["neutral"])])
	print("  慢隊 dist=%d days=%.2f (tiles/day=%.2f)" % [dist_s, d_slow, _tiles_per_day(st, w["slow"])])
	print("  快隊 dist=%d days=%.2f (tiles/day=%.2f)" % [dist_f, d_fast, _tiles_per_day(st, w["fast"])])
	# 距離不同 ⇒ 比【每格天數】才是同一把尺
	var per_n: float = d_neutral / float(maxi(dist_n, 1))
	var per_s: float = d_slow / float(maxi(dist_s, 1))
	var per_f: float = d_fast / float(maxi(dist_f, 1))
	_ok(per_s > per_n, "①慢隊每格天數(%.4f) > 中性(%.4f)" % [per_s, per_n])
	_ok(per_f < per_n, "②快隊每格天數(%.4f) < 中性(%.4f)" % [per_f, per_n])
	_ok(per_f < 1.0 / OLD_FLAT, "②快隊每格天數(%.4f) < 舊平版估 %.4f" % [per_f, 1.0 / OLD_FLAT])
	# ★反向對照：機制關掉這格還會綠嗎——三隊狀態不同卻拿到同一個數＝接線沒接上
	_ok(not (is_equal_approx(per_s, per_n) and is_equal_approx(per_f, per_n)),
		"反向對照：三隊【不】共用同一個每格天數（共用＝仍是平版常數）")
	_sections += 1

func _test_unit_sanity() -> void:
	print("-- ③ 單位健全性（差 1440 倍＝接錯，差 1-9 倍＝發現）--")
	var w := _mk_world()
	var st: WorldState = w["state"]
	for key in ["neutral", "slow", "fast"]:
		var tpd: float = _tiles_per_day(st, w[key])
		var ratio: float = tpd / OLD_FLAT
		_ok(ratio < 20.0, "③%s 比舊常數 %.2f 倍 < 20（≥100 倍＝單位接錯）" % [key, ratio])
		_ok(tpd >= 2.0 - 0.001 and tpd <= 18.0 + 0.001,
			"③%s tiles/day=%.2f 落在 clamp 可達區間 [2,18]" % [key, tpd])
	_sections += 1

func _test_probe_not_polluted() -> void:
	print("-- ④ rootdiff.* 三格：決策端不得動它，執行端必須動它 --")
	var keys := ["rootdiff.TERRAIN_SPEED_MULT", "rootdiff.WAGON_TERRAIN_MULT", "rootdiff.NAMED_WEIGHT"]
	var w := _mk_world()
	var st: WorldState = w["state"]
	var tm: TeamData = w["neutral"]
	tm.resources["wagons"] = 2.0
	var leader := PersonData.new()
	leader.id = 900
	st.persons[900] = leader
	tm.leader_id = 900
	Probe.enabled = true
	var before := {}
	for k in keys:
		before[k] = int(Probe.counts.get(k, 0))
	for i in 5:
		_days(st, tm, Vector2i(20, 0))
	var unchanged := true
	for k in keys:
		if int(Probe.counts.get(k, 0)) != int(before[k]):
			unchanged = false
	_ok(unchanged, "④決策端呼叫 5 次，三格計數不變")
	# ★反向對照：不做這格的話，「不變」也可能是【Probe 根本沒在數】
	var ms := MovementSystem.new()
	ms._move_cost(st, tm, 1.0)
	var moved := true
	for k in keys:
		if int(Probe.counts.get(k, 0)) <= int(before[k]):
			moved = false
			print("    ★%s 沒有增加（before=%d after=%d）" % [k, int(before[k]), int(Probe.counts.get(k, 0))])
	_ok(moved, "④反向對照：執行端呼叫一次，三格計數【都】增加（否則『不變』是恆真式）")
	Probe.enabled = false
	_sections += 1
