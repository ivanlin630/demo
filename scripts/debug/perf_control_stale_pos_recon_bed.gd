extends SceneTree
# @bed-kind: acceptance
# slice: 過期位置→偵查分池 效能對照(systems DISPATCH 2026-09-17，判準⑩：同床同seed換樹)
#
# ★★★這不是把 feat/stale-pos-recon 的床帶過來跑——那支床在 fixture 格(格3)呼叫
#   DecisionTerms.recon_freshness_factor()，main 沒有這支函式，parse 階段就死(已驗過，[FAIL]見交件信)。
# ★★而 [TickPerf] 本身是 sim_runner.gd(production，main也有)在advance_tick內自己印的，
#   不需要借branch的床——只要同seed/同config/同天數跑main自己的世界迴圈，就是可比的對照。
#   pick_recon_target 本來就在main的decision_context.gd:998/options.gd:586 常規決策路徑上
#   (main是continue-skip舊版，branch是新版)⇒ 兩邊都會走這條路，差別只在production code。
#
# env：BED_DAYS(預設10)／BED_SEED(預設1337)／BED_CONFIG(預設warring_states)

func _initialize() -> void:
	_bed_self_check_tree()
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 10
	var seed_val: int = int(OS.get_environment("BED_SEED")) if OS.has_environment("BED_SEED") else 1337
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "warring_states"
	print("=== 效能對照(main側)：config=%s days=%d seed=%d ===" % [cfg, days, seed_val])
	seed(seed_val)
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg)
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)
	for tick in range(days * WorldState.TICKS_PER_DAY):
		runner.advance_tick(st, no_player)
	print("[TEST-SUITE-COMPLETE]")
	quit(0)

func _bed_self_check_tree() -> void:
	var out: Array = []
	OS.execute("git", ["rev-parse", "--short", "HEAD"], out)
	var sha: String = (out[0] as String).strip_edges() if not out.is_empty() else "UNKNOWN"
	out.clear()
	OS.execute("git", ["status", "--porcelain", "--", "scripts/simulation/"], out)
	var dirty: int = 0
	if not out.is_empty():
		for l in (out[0] as String).split("\n"):
			if l.strip_edges() != "": dirty += 1
	print("[TREE] HEAD=%s scripts/simulation-dirty=%d（%s）" % [
		sha, dirty, "clean" if dirty == 0 else "★dirty：跟別份輸出比對前先確認同 commit"])
