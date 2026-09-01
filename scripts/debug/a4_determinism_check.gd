extends SceneTree

# L3 temp measurement-only：A4 三修合力 determinism 獨立複驗（measurer 側、非production）。
# 鏡射 fp_acceptance.gd 手法：seed(1337) + warring_states config + N tick → StateFingerprint.compute()。
# 跑 3 次比對 32-hex 是否 byte-identical。

func _initialize() -> void:
	var ticks: int = int(OS.get_environment("FP_TICKS")) if OS.has_environment("FP_TICKS") else 1000
	seed(1337)
	var state := WorldState.new()
	# ★★可換床（S1a 驗收要【兩張床】的 fp）：★預設仍是 warring_states ⇒ 既有呼叫端行為一行不變。
	var cfg: String = OS.get_environment("FP_CONFIG") if OS.has_environment("FP_CONFIG") else "warring_states"
	GameSetup.setup(state, GameSetup.load_config("res://config/%s.json" % cfg))
	var runner := SimRunner.new()
	for _t in range(ticks):
		runner.advance_tick(state, Vector2i(-1, -1))
	print(StateFingerprint.blind_note())   # ★盲區印在使用它的當下（invariant 2026-09-01）
	var fp: String = StateFingerprint.compute(state)
	print("=== a4_determinism_check DONE === config=%s ticks=%d fp=%s" % [cfg, ticks, fp])
	quit()
