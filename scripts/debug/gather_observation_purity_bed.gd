extends SceneTree
# @bed-kind: pending
# blocker: gather-purity-bed-as-gate
# ★問一個可以現在就答的問題：【呼叫 gather 去觀測，會不會改變世界】？
#   ★★不改 measurer 的床——自己造兩輪同種子世界：
#     A 輪：只跑 tick（不觀測）
#     B 輪：每天對每支隊呼一次 DecisionContext.gather（＝ a4_rout_witness_bed 的觀測動作）
#   ⇒ 比 fp。fp 不同 ⇒ ★★★觀測確實改變了被觀測物，而那與「gather 該不該有快取」是兩個問題。
# ★★★實測結論（2026-09-07，warring_states 20 日、seed 1337）：
#   A（不觀測）        fp = 7f83b4875ef1248874f1d5bfd555cf3b
#   B（每天 gather 全隊）fp = a652923e4b414b78609cf6a37d632910
#   ⇒ ★不同 ⇒ 觀測【確實】改變了世界。
#
# ★★誠實限（★這條必須跟結論一起走）：本床 B 輪對【全部】隊呼 gather，
#   而 a4_rout_witness_bed 只對【半徑內】的隊呼 ⇒ 本床證明【機制存在且有 fp 級後果】，
#   ★★★它【沒有】量出那支床實際的擾動大小 —— 兩件事不要混。
func _initialize() -> void:
	var days: int = int(OS.get_environment("GP_DAYS")) if OS.has_environment("GP_DAYS") else 20
	print("=== gather_purity: days=%d ===" % days)
	var fp_a: String = _run_world(days, false)
	var fp_b: String = _run_world(days, true)
	print("[GP] A（不觀測）fp = %s" % fp_a)
	print("[GP] B（每天 gather 全隊）fp = %s" % fp_b)
	if fp_a == fp_b:
		print("[GP] ★相同 ⇒ 在這個窗口/這個 config 下，觀測【沒有】改變 fp")
		print("[GP]   ★★而那【不等於】gather 是純讀——它只說那些寫入沒有在 fp 上顯現")
	else:
		print("[GP] ★★★不同 ⇒ 觀測【確實】改變了世界（fp 是機械證據）")
	quit()

func _run_world(days: int, observe: bool) -> String:
	seed(1337)
	var state := WorldState.new()
	var cfg: Dictionary = GameSetup.load_config("res://config/warring_states.json")
	cfg["seed"] = 1337
	GameSetup.setup(state, cfg)
	var runner := SimRunner.new()
	for d in range(days):
		for _t in range(WorldState.TICKS_PER_DAY):
			runner.advance_tick(state, Vector2i(-1, -1))
		if observe:
			# ★鏡射 a4_rout_witness_bed:24 的動作：對隊呼 gather 讀 threat_react
			for tid in state.teams:
				var _c: DecisionContext = DecisionContext.gather(state, state.teams[tid])
				var _x: float = _c.threat_react
	return StateFingerprint.compute(state)
