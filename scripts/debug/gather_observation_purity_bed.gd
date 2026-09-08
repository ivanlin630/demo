extends SceneTree
# ★問一個可以現在就答的問題：【呼叫 gather 去觀測，會不會改變世界】？
#   A 輪：只跑 tick（不觀測）｜B 輪：每天對每支隊呼一次 DecisionContext.gather
#
# ★★★2026-09-08 起這支床有【判準】了，而判準【不是】fp ——
#   fp 那一行只印、不判。理由：B ≠ A 是【已知未收口】的事實（有一條寫入路徑還沒找到），
#   把它做成 FAIL 格＝把一個【已知狀態】做成每次都紅的閘，那種閘會被無視。
#   ⇒ 判準改成【我真的收口了的那一半】：七個純讀路徑欄位的 observe 寫入必須是 0。
#
# ★★而判準要成立必須先有母體：`.advance > 0`。
#   否則「observe == 0」在【那個 tap 根本沒被執行到】時也成立 —— 恆綠。
#   ⇒ 每一欄都印 advance/observe 兩個數字，advance == 0 的欄判【不可判】而不是判綠。
const FIELDS: Array = [
	"idle_employ_cached", "idle_employ_next_tick",
	"expand_eval_next_tick", "expand_site_cached",
	"consolidate_target_cache", "absorb_target_cache", "consolidate_eval_next_tick",
]

var _fail: int = 0
var _unjudgeable: int = 0

func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else:
		print("  [FAIL] %s" % m)
		_fail += 1

func _initialize() -> void:
	var days: int = int(OS.get_environment("GP_DAYS")) if OS.has_environment("GP_DAYS") else 6
	print("=== gather_purity: days=%d ===" % days)

	var ra: Array = _run_world(days, false)
	var rb: Array = _run_world(days, true)
	var fp_a: String = ra[0]
	var fp_b: String = rb[0]
	var cb: Dictionary = rb[1]

	# ── 判準：觀測路徑的七個欄位一個都不准寫 ──────────────────
	print("  ── 純讀路徑：七欄 advance / observe ──")
	for f in FIELDS:
		var adv: int = int(cb.get("gather.write.%s.advance" % f, 0))
		var obs: int = int(cb.get("gather.write.%s.observe" % f, 0))
		print("     %-28s advance=%-6d observe=%d" % [f, adv, obs])
		if adv == 0:
			# ★母體為空 ⇒ 不可判。★★這【不是】綠：它說的是「這一輪沒有執行到那個寫入點」，
			#   而不是「觀測沒有寫」。把它算成綠就是恆綠。
			print("       ★不可判：advance == 0 ⇒ 這一輪根本沒走到這個寫入點")
			_unjudgeable += 1
		else:
			_ok(obs == 0, "%s：觀測路徑零寫入（母體 advance=%d）" % [f, adv])

	# ── labor 那一支：兩條路各自要有 tap 點過，否則同樣是母體為空 ──
	var ro: int = int(cb.get("labor.ensure_fresh.readonly", 0))
	var co: int = int(cb.get("labor.compute_only", 0))
	var sup: int = int(cb.get("labor.crisis_emit.suppressed", 0))
	var cadv: int = int(cb.get("labor.crisis_emit.advance", 0))
	print("  ── labor：readonly=%d compute_only=%d crisis_emit(advance=%d suppressed=%d) ──"
		% [ro, co, cadv, sup])
	_ok(ro > 0, "★母體：observe 路徑真的走過 LaborSystem.ensure_fresh（readonly > 0）")

	# ── fp：只印，不判（見檔頭）──────────────────────────
	print("  ── fp（★只印不判：B ≠ A 是已知未收口，不是回歸）──")
	print("     A（不觀測）        fp = %s" % fp_a)
	print("     B（每天 gather 全隊）fp = %s" % fp_b)
	if fp_a == fp_b:
		print("     ★相同 ⇒ 在這個窗口/config 下觀測沒有在 fp 上顯現")
	else:
		print("     ★★★不同 ⇒ 還有一條寫入路徑不在這七欄裡（fp 覆蓋 current_task/plan_phase/")
		print("        unrest_turns/resources/goal_state ⇒ 兇手在那幾欄之一）")

	if _unjudgeable > 0:
		print("[GP] ★%d 欄不可判（母體為空）—— ★★這不算過" % _unjudgeable)
	if _fail == 0 and _unjudgeable == 0:
		print("=== DONE === ALL PASS")
	else:
		print("=== DONE === %d FAIL / %d 不可判" % [_fail, _unjudgeable])
	quit()

func _run_world(days: int, observe: bool) -> Array:
	seed(1337)
	var cfg: Dictionary = GameSetup.load_config("res://config/warring_states.json")
	cfg["seed"] = 1337
	# ★arm 先於 setup（bed-arm 閘）：Probe.arm() ＝ reset + enabled + 順序判定
	var state: WorldState = MeasureBedHelper.arm_and_setup(cfg)
	var runner := SimRunner.new()
	for d in range(days):
		for _t in range(WorldState.TICKS_PER_DAY):
			runner.advance_tick(state, Vector2i(-1, -1))
		if observe:
			# ★鏡射 a4_rout_witness_bed:24 的動作：對隊呼 gather 讀 threat_react
			for tid in state.teams:
				var _c: DecisionContext = DecisionContext.gather(state, state.teams[tid])
				var _x: float = _c.threat_react
	return [StateFingerprint.compute(state), Probe.counts.duplicate(true)]
