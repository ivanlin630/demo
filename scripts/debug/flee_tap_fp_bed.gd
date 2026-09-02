extends SceneTree
# @observe-pure
# ★★★#5 的【硬條件】驗證：tap 加上去之後 fp 逐位元不變。
#
# ★為什麼不直接用 state_fingerprint_bed：★★它【不 arm Probe】(:40-59 全程沒碰 Probe)
#   ⇒ Probe.enabled=false ⇒ 我那三個 tap 全是 no-op ⇒ 那樣測出來的「fp 不變」是【儀器沒開】。
#   ★★★而「儀器改變被觀測物」這個失效形態，只有在【儀器開著】的時候才會現形。
#   ⇒ 本床 arm Probe，才是真的在測本票要測的東西。
const CP: Array = [240, 1000, 2400]

func _initialize() -> void:
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "warring_states"
	var sd: int = int(OS.get_environment("BED_SEED")) if OS.has_environment("BED_SEED") else 1337
	seed(sd)
	var state: WorldState = MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg, true)
	print("[CONTROL] Probe.enabled=%s ★若這裡是 false，下面的『fp 不變』一文不值" % str(Probe.enabled))
	var runner := SimRunner.new()
	var maxcp: int = int(CP[CP.size() - 1])
	for tick in range(1, maxcp + 1):
		runner.advance_tick(state, Vector2i(-1, -1))
		if tick in CP:
			print("FP|%d|%s" % [tick, StateFingerprint.compute(state)])
	# ★桶也印出來 —— 證明【這個窗裡 tap 真的有 fire】（否則又是「儀器沒開」的另一種形狀）
	var keys: Array = ["flee.pos_none_no_threat", "flee.pos_none_positionless", "flee.pos_ok",
		"flee.set_invalid.decide_unified", "flee.set_ok.decide_unified",
		"flee.set_invalid.solo", "flee.set_ok.solo", "flee.backstop_release"]
	for k in keys:
		print("BUCKET|%s|%d" % [k, int(Probe.counts.get(k, 0))])
	print("=== flee_tap_fp DONE ===")
	quit()
