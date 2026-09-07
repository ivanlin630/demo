extends SceneTree
# ★用完即棄：兩個對照 —— ①counter 真的會動 ②合併時小孩真的被搬走（而不是被記成死亡）
var _fail: int = 0
func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else: _fail += 1; print("  [FAIL] %s" % m)

func _initialize() -> void:
	var state: WorldState = MeasureBedHelper.arm_and_new()
	# ── ①陽性對照：一支帶小孩的隊直接滅團 ⇒ counter 必須動
	var t := TeamData.new(); t.team_id = 1
	AnonTierSystem.add_anon(t, "平民", 4)
	t.minor_population = 3
	state.teams[1] = t
	print("[CTRL1] 滅團前 minor=%d" % t.minor_population)
	state.erase_teams([1])
	print("[CTRL1] erase.minors_lost=%.0f  erase.teams_with_minors=%d"
		% [Probe.amount("erase.minors_lost"), int(Probe.counts.get("erase.teams_with_minors", 0))])
	_ok(is_equal_approx(Probe.amount("erase.minors_lost"), 3.0), "①陽性：滅團帶走的 3 個小孩被計到")
	_ok(int(Probe.counts.get("erase.teams_with_minors", 0)) == 1, "①兩個桶分開：帶小孩死的隊數 = 1")
	# ── ②陰性對照：合併路徑 ⇒ 小孩該被【搬走】，而滅團 counter【不該】記到它們
	Probe.reset(); Probe.enabled = true
	var st2: WorldState = MeasureBedHelper.arm_and_new()
	var absorber := TeamData.new(); absorber.team_id = 10
	AnonTierSystem.add_anon(absorber, "平民", 5)
	var sub := TeamData.new(); sub.team_id = 11; sub.parent_team_id = 10
	AnonTierSystem.add_anon(sub, "平民", 3)
	sub.minor_population = 2
	sub.task_extra_data["migrant_target"] = 10
	var _minors_before: int = sub.minor_population + absorber.minor_population
	absorber.tile_pos = Vector2i(4, 4); sub.tile_pos = Vector2i(4, 4)
	st2.teams[10] = absorber; st2.teams[11] = sub
	var fai := FactionAISystem.new()
	fai._tick_migrant(st2, sub, [])
	print("[CTRL2] 合併後 absorber.minor=%d  sub.minor=%d  merge.minors_moved_n=%.0f"
		% [absorber.minor_population, sub.minor_population, Probe.amount("merge.minors_moved_n")])
	st2.erase_teams([11])
	print("[CTRL2] 滅團 counter erase.minors_lost=%.0f ★★該是 0（小孩已經先搬走）"
		% Probe.amount("erase.minors_lost"))
	_ok(absorber.minor_population == 2 and sub.minor_population == 0, "②小孩跟著大人走（2 進 absorber、sub 歸 0）")
	_ok(is_equal_approx(Probe.amount("erase.minors_lost"), 0.0),
		"②★順序陣阱：被併的小孩【沒有】被記成死亡")
	# ★★★守恆：上一格【沒有牙】――陰性對照實測：把搬家關掉之後
	#   小孩【憑空消失】（absorber 0、sub 0、死亡 counter 也 0）而那一格照樣綠。
	#   ⇒ ★「counter 是 0」對【正確搬走】與【被銷毀】給同一個判決。
	#   ⇒ ★★要的是【守恆】：搬家前的小孩數 == 事後兩邊相加 + 死亡損失。
	var _minors_after: int = absorber.minor_population + sub.minor_population
	print("[CTRL2] 守恆：前 %d ｜ 後 %d ｜ 死亡損失 %.0f"
		% [_minors_before, _minors_after, Probe.amount("erase.minors_lost")])
	_ok(_minors_before == _minors_after + int(Probe.amount("erase.minors_lost")),
		"②★★守恆：小孩不憑空消失（前 %d == 後 %d + 損失 %.0f）"
		% [_minors_before, _minors_after, Probe.amount("erase.minors_lost")])
	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()
