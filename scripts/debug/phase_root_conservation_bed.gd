extends SceneTree
# @bed-kind: guard
# slice: 相位樹 ｜ ★根守恆（Σ 根 tot ≤ 容器總時）
#
# ★為什麼是【守恆】而不是第四條規矩（systems 立 2026-09-10）：
#   同型已經三次 —— ①`loop1.factions` 六個檢查點登記成兄弟 ②`indep.weakest_prey` 多外層共用
#   ③`loop2.solo_engine` 與 `loop2.solo` 巢狀卻都是根。
#   ★★三次的共同形狀是【登記表宣稱的樹 ≠ code 的巢狀】，而它們全部會被這一條抓到。
# ★★★成對對照三格：會紅／不得亂紅／現況也要綠（否則不知道它是不是恆紅）。

var fails: int = 0
var sections: int = 0

func _check(name: String, ok: bool, detail: String) -> void:
	sections += 1
	if ok:
		print("  PASS %s ── %s" % [name, detail])
	else:
		fails += 1
		print("  [FAIL] %s ── %s" % [name, detail])

func _initialize() -> void:
	print("=== 根守恆床 ===")
	# 同一份相位表，餵兩種登記：巢狀的兩層（solo 與它的桶）
	var ph: Dictionary = {
		"loop2.solo": 800_000,
		"loop2.solo_engine": 790_000,
		"loop2.solo_cheap": 10_000,
		"loop3.misc": 100_000,
	}
	var total: int = 1_000_000   # 容器總時 1.0 s

	# ①【會紅】把 solo_engine／solo_cheap 改回【根】⇒ Σ根 = 1.70s > 1.0s
	var as_roots: Dictionary = FactionAISystem.PHASE_PARENT.duplicate()
	as_roots["loop2.solo_engine"] = ""
	as_roots["loop2.solo_cheap"] = ""
	var rep_bad: String = FactionAISystem.phase_report(ph, total, as_roots)
	_check("①改回根 ⇒ 具名紅",
		rep_bad.contains("根守恆破") and rep_bad.contains("loop2.solo") and rep_bad.contains("loop2.solo_engine"),
		"訊息要點名貢獻最大的根，不能只說『破了』：%s" % rep_bad.split("｜")[0].split("|")[0])

	# ②【不得亂紅】現行登記（兩個桶是 loop2.solo 的兒子）⇒ Σ根 = 0.9s ≤ 1.0s
	var rep_ok: String = FactionAISystem.phase_report(ph, total)
	_check("②改回兒子 ⇒ 綠", not rep_ok.contains("根守恆破"),
		"同一份 ph、同一個 total，只差登記：%s" % rep_ok.split("|")[0])

	# ③【現況】真的跑世界 ⇒ 每一個【有相位資料的 tick】都要綠
	#   ★容器總時＝那個 tick 自己的牆鐘（★★不能拿根和當 total —— 那會讓這一格恆真）
	#   ★★★而 `_fai_ph` 現在每 tick 清 ⇒ 沒跑 evaluate_all 的 tick 是【空的】
	#     ⇒ 空的要跳過，並且**分開計數**（0 個可判 tick ＝ 不可判，不是綠）。
	var st := MeasureBedHelper.arm_and_setup("res://config/warring_states.json")
	SimRunner.phase_timing = true
	var runner := SimRunner.new()
	var judged: int = 0
	var broke: int = 0
	var first_break: String = ""
	for _i in range(600):
		var t0: int = Time.get_ticks_usec()
		runner.advance_tick(st, Vector2i(-1, -1))
		var dt: int = Time.get_ticks_usec() - t0
		var live: Dictionary = FactionAISystem._fai_ph
		if live.is_empty():
			continue
		judged += 1
		var rep: String = FactionAISystem.phase_report(live, dt)
		if rep.contains("根守恆破"):
			broke += 1
			if first_break == "":
				first_break = rep.split("｜")[0]
	_check("③現況綠", judged > 0 and broke == 0,
		"可判 tick %d 個（★0 ⇒ 不可判，不是綠）／破 %d 個%s" % [
			judged, broke, "" if first_break == "" else "｜首例：" + first_break])

	print("=== DONE === SECTIONS=%d/%d FAILS=%d" % [sections - fails, sections, fails])
	quit(1 if fails > 0 else 0)
