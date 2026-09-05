extends SceneTree

# ★★★反向斷言：**每個 production firsthand 寫入點的 snap 都含 `tile_pos`**
#   （systems 裁 2026-09-05：新鮮度那一票【留發現不留機制】，而發現要被【焊住】）
#
# ★為什麼是這個形狀：★★實測「三個 firsthand `record_claim` 寫入點全部同時寫 `tile_pos`」
#   ⇒ `tile_pos` 的新鮮度【就是】`last_tick`，沒有借 ⇒ 不需要第二個時戳。
#   ★★★而那個結論【依賴一個等式】，等式會被未來的 code 打破而【沒有人會記得這輪的討論】
#   ⇒ 所以把它變成一支會自己變紅的測試。
#
# ★★閘型床兩要件：結尾 `[TEST-SUITE-COMPLETE]` ＋ 失敗走 `push_error`（叫、不停）。
# ★★★而【陽性對照做在預設參數下】：本床自己造一筆「親見但不帶 tile_pos」的 claim，
#   ⇒ 若計數器【沒有】因此上升，那是【儀器壞了】而不是「production 沒問題」。

var _next_id: int = 1
var _fails: int = 0

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	print("=== belief 新鮮度等式 反向斷言 ===")
	seed(1337)
	var s := MeasureBedHelper.arm_and_new(); s.player_id = -1
	for x in range(0, 6):
		for y in range(0, 3):
			var t := HexTileData.new()
			t.tile_pos = Vector2i(x, y); t.terrain = "plains"
			t.resources = {"food": 50.0}; t.resource_cap = {"food": 200.0}
			s.world.tiles[x * 1000 + y] = t
	s.world.current_tick = 100
	var a := _mk_team(s, 5, Vector2i(2, 1))
	var b := _mk_team(s, 5, Vector2i(2, 1))   # ★同格 ⇒ 共位必見保證 vision 會寫
	s.rebuild_team_tile_index()

	# ── ★①陽性對照：故意造一筆【親見但不帶 tile_pos】──
	var before: int = int(Probe.counts.get("freshness.firsthand_no_tile_pos", 0))
	BeliefSystem.record_claim(s, a.team_id, b.team_id, a.team_id, "親見",
		{"population_est": 5}, 1.0, false)
	var after_ctrl: int = int(Probe.counts.get("freshness.firsthand_no_tile_pos", 0))
	print("  ★陽性對照：故意寫一筆不帶 tile_pos 的親見 claim ⇒ 計數 %d → %d" % [before, after_ctrl])
	if after_ctrl != before + 1:
		push_error("[FAIL] 陽性對照沒動 ⇒ ★這顆計數器【壞了】，而它的 0 不能當證據")
		_fails += 1

	# ── ★★②真正的斷言：跑 production 的三條 firsthand 路，計數【不得再上升】──
	var base: int = int(Probe.counts.get("freshness.firsthand_no_tile_pos", 0))
	var vs := VisionSystem.new()
	var it := InteractionSystem.new()
	var ids: Array = [a.team_id, b.team_id]
	for i in range(12):
		s.world.current_tick += WorldState.TICKS_PER_HOUR
		vs.tick_discovery(s, ids)                  # ★路①vision_system.gd:113
		it.process_colocated_residency(s, ids)     # ★★路②interaction_system.gd:1219（共位互動入口）
	var after: int = int(Probe.counts.get("freshness.firsthand_no_tile_pos", 0))
	print("  ★★production 路跑完：計數 %d → %d（★不得上升）" % [base, after])
	if after != base:
		push_error("[FAIL] 有 production firsthand 寫入點【沒帶 tile_pos】＝ %d 次 ⇒ "
			% (after - base)
			+ "★★`last_tick` 開始替 `tile_pos` 背書新鮮度 ⇒ 要補【逐欄位時戳】")
		_fails += 1
	else:
		print("     ✅等式仍成立：每一次親見都帶 tile_pos")

	# ── ★★★③而「有跑到」也要有證據（★否則 0 可能是【一次都沒寫】）──
	var wrote: int = int(Probe.counts.get("claim.write.same_tile", 0)) 		+ int(Probe.counts.get("vis.colo.detect", 0))
	print("  ★★★母體：本段實際發生的親見寫入相關計數 = %d" % wrote)
	if wrote == 0:
		push_error("[FAIL] 本段一次 firsthand 寫入都沒發生 ⇒ ★上面那個「不得上升」是【空過】")
		_fails += 1

	print("")
	print("★★★總計 FAIL = %d" % _fails)
	print("[TEST-SUITE-COMPLETE]")

func _mk_team(s: WorldState, pop: int, pos: Vector2i) -> TeamData:
	var p := PersonData.new(); p.id = _next_id; _next_id += 1
	p.values = {"求生欲": 0.5}; p.skills = {"統領": 0.5}
	s.persons[p.id] = p
	var t := TeamData.new(); t.team_id = _next_id; _next_id += 1
	t.leader_id = p.id; p.team_id = t.team_id
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", maxi(pop - 1, 0))
	t.tile_pos = pos; t.faction_id = -1; t.parent_team_id = -1
	t.resources = {"food": 100.0}
	t.current_task = TeamData.TASK_IDLE
	s.teams[t.team_id] = t
	return t
