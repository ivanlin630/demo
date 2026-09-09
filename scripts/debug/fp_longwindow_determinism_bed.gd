extends SceneTree
# @bed-kind: acceptance
# slice: fp 覆蓋擴張後的【長窗決定論】——★本票唯一真風險（尺變噪音）的守衛
#
# ★窗長（R² 給的具體數字，★★而它同時寫 tick 與遊戲天）：
#   ≥43200 tick（30 遊戲日）＝ extraction_eval_next_tick 的一個 cadence 週期；
#   建議 86400 tick（60 遊戲日）＝ 2 倍餘裕，確保【轉過一輪並看到下一輪起點】。
# ★★★短窗的「沒分岔」可能只是【還沒輪到】—— 這支床存在的理由就是那句話。
#   env：FPLW_TICKS（預設 86400）／FPLW_CONFIG（預設 demo：3 隊，讓 60 天跑得動）

var _fails: int = 0

func _initialize() -> void:
	var ticks: int = int(OS.get_environment("FPLW_TICKS")) if OS.has_environment("FPLW_TICKS") else 86400
	var cfg: String = OS.get_environment("FPLW_CONFIG") if OS.has_environment("FPLW_CONFIG") else "demo"
	print("=== fp 長窗決定論床（%d tick ＝ %.1f 遊戲天，config=%s）===" % [
		ticks, float(ticks) / float(WorldState.TICKS_PER_DAY), cfg])
	var t0: int = Time.get_ticks_usec()
	var a: String = _run_fp(ticks, cfg)
	var t1: int = Time.get_ticks_usec()
	var b: String = _run_fp(ticks, cfg)
	print("    跑一趟 %.1f 秒｜fp_a=%s｜fp_b=%s" % [float(t1 - t0) / 1e6, a, b])
	if a == b:
		print("  PASS: 長窗同 seed 兩跑 fp 相同 ⇒ 擴張沒有把尺變成噪音")
	else:
		_fails += 1
		push_error("[FAIL] ★長窗兩跑 fp 不同 ⇒ 擴進來的欄位裡有【噪音源】"
			+ "（★處置照 spec §④①：把分岔那欄丟進 (a)(b) 證據流程，不要退回手抄清單）")
	print("=== DONE === SECTIONS=1/1 FAILS=%d" % _fails)
	quit()

func _run_fp(ticks: int, cfg: String) -> String:
	seed(20260910)
	var st := WorldState.new()
	GameSetup.setup(st, GameSetup.load_config("res://config/%s.json" % cfg))
	st.player_id = -1   # ★無玩家：哨兵那段也順便在長窗下受檢
	var runner := SimRunner.new()
	for _t in range(ticks):
		runner.advance_tick(st, Vector2i(-1, -1))
	return StateFingerprint.compute(st)
