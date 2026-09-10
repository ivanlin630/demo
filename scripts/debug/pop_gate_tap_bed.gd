extends SceneTree
# @bed-kind: acceptance
# slice: pop 閘的逐筆 tap（鏡射同函式材料軸的款式）
#
# ★不變量【全量暫態可觀測性】的直球案例：一個決策閘只有聚合 counter ＝ 量測盲點。
# ★★聚合說得出「被擋幾次」，說不出【差多少人、誰在擋、當時多大】——
#   ★★★而那正是「pop*2 這個 TEST VALUE 該不該是這個數」要看的東西（本票不動門檻，只讓它可量）。

var _fails: int = 0
var _sections: int = 0
const EXPECT_SECTIONS: int = 2

func _initialize() -> void:
	print("=== pop 閘 tap 床 ===")
	_test_tap_fires()
	_test_mirrors_material_shape()
	if _sections != EXPECT_SECTIONS:
		_fails += 1
		push_error("[FAIL] 只跑完 %d/%d 段" % [_sections, EXPECT_SECTIONS])
	print("=== DONE === SECTIONS=%d/%d FAILS=%d" % [_sections, EXPECT_SECTIONS, _fails])
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_fails += 1
		push_error("[FAIL] " + msg)

func _test_tap_fires() -> void:
	print("-- ① 真的會 fire，而且逐筆有 detail --")
	Probe.arm()
	seed(4242)
	var st := WorldState.new()
	GameSetup.setup(st, GameSetup.load_config("res://config/warring_states.json"))
	st.player_id = -1
	var runner := SimRunner.new()
	for _i in range(3000):
		runner.advance_tick(st, Vector2i(-1, -1))
	var n_gate: int = int(Probe.counts.get("funnel.build_gate.pop", 0))
	var samples: Array = Probe.samples.get("dispatch_fail.pop_detail", [])
	print("    聚合 counter=%d｜逐筆樣本=%d 筆" % [n_gate, samples.size()])
	_ok(n_gate > 0, "①★母體地板：pop 閘真的被踩到 %d 次（0 次的話下一格不可判）" % n_gate)
	_ok(samples.size() > 0, "①逐筆 tap 有樣本（★聚合有、逐筆沒有 ＝ 盲點還在）")
	if samples.size() > 0:
		var s0: Dictionary = samples[0]
		print("    第一筆：%s" % str(s0))
		for k in ["team", "faction", "pop", "need", "gap", "level", "tick"]:
			_ok(s0.has(k), "①欄位 %s 在（★缺一欄就答不出「差多少人」那類問題）" % k)
		_ok(int(s0["gap"]) == int(s0["need"]) - int(s0["pop"]),
			"①★gap 自洽（need − pop）—— 不是另外算一個會漂的數")
	_sections += 1

func _test_mirrors_material_shape() -> void:
	print("-- ② 款式與同函式的材料軸一致（★同一支函式裡兩個閘不該長不一樣）--")
	var f := FileAccess.open("res://scripts/simulation/faction_ai_system.gd", FileAccess.READ)
	var src: String = f.get_as_text() if f != null else ""
	if f != null:
		f.close()
	_ok(src.contains('bump_sample("dispatch_fail.material_detail"'), "②材料軸那支還在（對照組）")
	_ok(src.contains('bump_sample("dispatch_fail.pop_detail"'), "②pop 軸這支已補上")
	# ★兩支都要有 cap（bump_sample 的 ring buffer 上限）——否則長跑會無界成長
	var mi: int = src.find('dispatch_fail.material_detail')
	var pi: int = src.find('dispatch_fail.pop_detail')
	_ok(src.substr(mi, 600).contains("}, 30)") and src.substr(pi, 600).contains("}, 30)"),
		"②★兩支都有 cap=30（bounded；★★無界成長的 tap 會在長跑裡變成另一個問題）")
	_sections += 1
