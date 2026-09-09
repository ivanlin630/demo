extends SceneTree
# @bed-kind: pending
# blocker: gather-purity-bed-as-gate
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
# ★總結行的分母（systems 小票 2026-09-09）：中途崩掉【只會少印幾行】，而剩下的每一行都還是 PASS
#   ⇒ 中途崩與全部通過在輸出上一模一樣。SECTIONS 讓「跑完了嗎」與「驗過了嗎」分開回答。
# ★★分母綁【fixture 段】的七欄而不是世界段：fixture 的母體是【造出來的】(確定性)，
#   而世界段有沒有走到某個寫入點【隨世界變】——把它掛進 SECTIONS 會做出一格會隨機假紅的閘。
#   ★★★世界段的判定數照樣印在同一行（只是不進分母），所以它變少一樣看得見。
var _fixture_judged: int = 0
var _world_judged: int = 0

func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else:
		print("  [FAIL] %s" % m)
		_fail += 1

func _initialize() -> void:
	var days: int = int(OS.get_environment("GP_DAYS")) if OS.has_environment("GP_DAYS") else 1
	print("=== gather_purity: days=%d ===" % days)

	# ★先跑 fixture：母體靠造，不靠世界碰運氣
	print("  ── fixture（造出 idle_labor > 0）──")
	var cf: Dictionary = _fixture_counts()
	for f in FIELDS:
		var fa: int = int(cf.get("gather.write.%s.advance" % f, 0))
		var fo: int = int(cf.get("gather.write.%s.observe" % f, 0))
		print("     %-28s advance=%-4d observe=%d" % [f, fa, fo])
		# ★★★判準優先序：`observe > 0` 【本身就是違規】，
		#   不該先被【母體為空】吃掉。實測血證：拿掉 `and advance` 之後，
		#   第一呼（observe）就把 cadence 用掉 ⇒ advance 那一呼反而不寫
		#   ⇒ advance == 0 ⇒ 若先判母體就會把【真的寫了】報成【不可判】。
		if fo > 0:
			_ok(false, "fixture %s：觀測路徑寫了 %d 次（★寫了就是違規，跟母體無關）" % [f, fo])
			_fixture_judged += 1
		elif fa == 0:
			print("       ★fixture 沒造出這一欄的母體")
			_unjudgeable += 1
		else:
			_ok(true, "fixture %s：觀測零寫入（母體 advance=%d）" % [f, fa])
			_fixture_judged += 1

	# ★★★世界段預設【關】（systems 裁 2026-09-09）：這支床【貴的那一半正好是不判決的那一半】——
	#   七格 fixture 是判準（母體是造出來的、便宜）；世界段是 print-only（fp 比對 + 世界段判定），
	#   而它要跑兩個世界 ⇒ 208s+。閘只需要判準那一半。
	# ★開關：`GP_WORLD=1` 才跑（人手診斷用）。★★關掉時世界段欄位印【已略過】不印 0/7 ——
	#   「關掉」與「跑了但一格都沒判到」是兩件事，印成 0/7 會把它們變成同一件。
	var world_on: bool = OS.get_environment("GP_WORLD") == "1"
	var fp_a: String = ""
	var fp_b: String = ""
	var cb: Dictionary = {}
	if world_on:
		var ra: Array = _run_world(days, false)
		var rb: Array = _run_world(days, true)
		fp_a = String(ra[0])
		fp_b = String(rb[0])
		cb = rb[1]
	else:
		print("  ── 世界段：已略過（GP_WORLD=1 才跑；它是 print-only 的診斷，不是判準）──")

	# ★以下【全部】依賴世界段的計數（cb）——世界段關掉時它們無法判，
	#   ★不是判成 0，是【不判】：cb 為空時 adv/obs 都會是 0，而那跟「跑了都沒寫」長得一樣。
	if world_on:
		# ── 判準：觀測路徑的七個欄位一個都不准寫 ──────────────────
		print("  ── 純讀路徑：七欄 advance / observe ──")
		for f in FIELDS:
			var adv: int = int(cb.get("gather.write.%s.advance" % f, 0))
			var obs: int = int(cb.get("gather.write.%s.observe" % f, 0))
			print("     %-28s advance=%-6d observe=%d" % [f, adv, obs])
			if obs > 0:
				_ok(false, "%s：觀測路徑寫了 %d 次（★寫了就是違規，跟母體無關）" % [f, obs])
				_world_judged += 1
			elif adv == 0:
				# ★母體交給 fixture 背（systems 裁）：用【取樣一個世界】去測【code 形狀】是類別錯誤。
				#   ⇒ 世界段降級成【診斷】：只在 observe > 0 時紅，不再計【不可判】。
				print("       （世界段沒走到這個寫入點；母體由 fixture 負責）")
			else:
				_ok(true, "%s：觀測路徑零寫入（母體 advance=%d）" % [f, adv])
				_world_judged += 1

		# ── labor 那一支：兩條路各自要有 tap 點過，否則同樣是母體為空 ──
		var ro: int = int(cb.get("labor.ensure_fresh.readonly", 0))
		var co: int = int(cb.get("labor.compute_only", 0))
		var sup: int = int(cb.get("labor.crisis_emit.suppressed", 0))
		var cadv: int = int(cb.get("labor.crisis_emit.advance", 0))
		print("  ── labor：readonly=%d compute_only=%d crisis_emit(advance=%d suppressed=%d) ──"
			% [ro, co, cadv, sup])
		_ok(ro > 0, "★母體：observe 路徑真的走過 LaborSystem.ensure_fresh（readonly > 0）")

	# ── fp：只印，不判（見檔頭）──────────────────────────
	if world_on:
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
	var world_col: String = ("%d/%d（不進分母：隨世界變）" % [_world_judged, FIELDS.size()]) if world_on 		else "已略過（GP_WORLD=1 才跑）"
	print("=== DONE === SECTIONS=%d/%d FAILS=%d 不可判=%d｜世界段判定=%s" % [
		_fixture_judged, FIELDS.size(), _fail, _unjudgeable, world_col])
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

# ★★★fixture（systems 裁 2026-09-08）：用【取樣一個世界】去測【一個 code 形狀】是類別錯誤。
#   那四欄的前置是 `c.idle_labor > 0`（:312 / :465），而那是一個可以【造】的條件：
#     tile 自家據點、無資源無製造設施 ⇒ demand 空 ⇒ _dcap = 0
#     共位一支 TAG_PRODUCE 的隊 ⇒ pool > 0 ⇒ idle_labor = pool > 0
#   ⇒ 母體【造出來】而不是【等出來】。
func _fixture_counts() -> Dictionary:
	var state: WorldState = MeasureBedHelper.arm_and_new()
	state.world.current_tick = 100
	var t := TeamData.new()
	t.team_id = 1
	t.tags = [TeamData.TAG_PRODUCE]
	t.tile_pos = Vector2i(3, 3)
	var ldr := PersonData.new(); ldr.id = 10; ldr.team_id = 1
	state.persons[10] = ldr
	t.leader_id = 10
	t.named_members = [10]
	state.teams[1] = t
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(3, 3)
	tile.outpost_owner = 1
	tile.outpost_level = 1
	state.world.tiles[3 * 1000 + 3] = tile
	# ★★★順序是這支 fixture 的命門（實測血證 2026-09-08）：
	#   若先呼 advance 再呼 observe，advance 那一呼已把 `*_eval_next_tick`
	#   推到未來 ⇒ observe 那一呼走【快取分支】，本來就不寫
	#   ⇒ ★把 `and advance` 拿掉它照樣全綠 ⇒ 【這個斷言不可能變紅】。
	# ⇒ observe 必須在 cadence【到期】時呼：前一呼（next_tick 還是 0），
	#   後一呼把 tick 推過 cadence 再呼一次 ―― 兩次都是【該寫而不寫】的情境。
	var _b0: DecisionContext = DecisionContext.gather(state, t, false)  # observe（cadence 到期）
	var _a: DecisionContext = DecisionContext.gather(state, t, true)    # advance（造母體）
	print("     fixture: idle_labor(advance)=%.2f" % _a.idle_labor)
	state.world.current_tick += 100000                                  # ★推過所有 cadence
	var _b1: DecisionContext = DecisionContext.gather(state, t, false)  # observe（再次到期）
	return Probe.counts.duplicate(true)
