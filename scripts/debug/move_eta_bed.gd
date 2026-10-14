extends SceneTree
# @bed-kind: acceptance
# slice: 移動預計時間同一把尺（spec 2026-10-13-move-eta-same-ruler-HOW）
# 下令句「預計 N 分鐘」＝實走（容差 0，tick 精確）；抵達句 N＝模擬抵達 tick − 下令 tick
#   E1  平原兩格、白天、下令 tick 為 60 的倍數（陽性對照，修前可能也綠）
#   E2  同路徑、下令在整點後 1 分／整點前 1 分
#   E3  跨夜（21:00 前後下令）
#   E4  含森林、move_tick_acc 起始非 0
#   E5  長路（6 格）、等代價路徑多、跨夜；佈置從「平原／散布森林 × 距離 6 目標」裡挑第一個重規劃會分岔的 ⇒ 守「每步重規劃」（地板：實走的路 ≠ 起點算的整條路）
#   E6  抵達對帳：同世界兩份，一份逐 tick、一份經 SimBridge 以 60／37 tick 為一塊推進 ⇒ bridge 記的抵達 tick 與 N 相同
#   E7  疲勞 0%：12 小時行進逐次疲勞 pass 印原始值與分類（量測，結論寫進信）
#   E8  路上一格真地形是山、玩家沒去過 ⇒ 估算＝「那格當平原且已知」的估算、≠ 真實已知估算；句子「至少」；估算 ≤ 實走
#   E9  同 tick 先跑 belief 版估算再讓真移動走同一對起終點 ⇒ 路逐格相同（快取不汙染）＋估算不改快取大小
#   SRC 同源：載重超過上限（只經 move_cost_at_pure 進來）⇒ 估算與實走一起變；結構：process 與估算器都呼 run_window、迴圈只有一份
#   R   第二階殘差（疲勞中途變／糧吃掉變輕／人口變動）：只印殘差，不放寬 E1–E5
#   AI  AI 舊估算（_estimate_eta_to）夜間兩格的低估百分比（回填 known_issues）
#   ★佈置：玩家隊搬到離其他隊最遠的格；全圖地形改平原（E4／E5／E8 另加）；全圖標為已知（E8 例外那一格）
#   ★地板（每格）：試驗期間遭遇 0、疲勞 ≤ 0.5（速度倍率恆 1）、不超載、人口不變、走到目標
#   負對照（另跑）：估算器改回 eta_ticks(hex_dist) ⇒ E2–E5 紅；估算器沿凍結路徑 ⇒ E5 紅
#   ★到場點名：每格各自報到，末行印「到場 N／N」
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/move_eta_bed.gd

const SEED: int = 1337
const CELLS: Array = ["E1", "E2a", "E2b", "E3a", "E3b", "E4", "E5", "E6", "E7", "E8", "E9", "SRC", "R1", "R2", "R3", "AI"]
const DAY: int = WorldState.TICKS_PER_DAY

var _errors: int = 0
var _present: Dictionary = {}
var _enc: int = 0


func _check(label: String, ok: bool) -> void:
	if ok:
		print("  PASS: " + label)
	else:
		_errors += 1
		push_error("[FAIL] " + label)


func _initialize() -> void:
	print("=== move_eta：預計時間＝實走 ===")
	_e_cell("E1", 600, Vector2i(2, 0), 0, "")
	_e_cell("E2a", 601, Vector2i(2, 0), 0, "")
	_e_cell("E2b", 599, Vector2i(2, 0), 0, "")
	_e_cell("E3a", 1250, Vector2i(2, 0), 0, "")
	_e_cell("E3b", 1270, Vector2i(2, 0), 0, "")
	_e_cell("E4", 615, Vector2i(3, 0), 100, "forest_band")
	_e5()
	_e6()
	_e7()
	_e8()
	_e9()
	_src()
	_residuals()
	_ai()
	var n: int = 0
	for c in CELLS:
		if _present.has(c):
			n += 1
		else:
			push_error("[FAIL] 格 %s 沒有跑完（到場點名缺）" % c)
			_errors += 1
	print("=== move_eta DONE === 到場 %d／%d errors: %d" % [n, CELLS.size(), _errors])
	quit(1 if _errors > 0 else 0)


# ── 佈置 ─────────────────────────────────────────────────────────────────────
func _world() -> Array:
	seed(SEED)
	PathSystem._reset_cross_run()
	var st := WorldState.new()
	GameSetup.setup(st, GameSetup.load_config("res://config/default.json"))
	return [st, SimRunner.new()]


static func _hexd(a: Vector2i, b: Vector2i) -> int:
	var dq: int = b.x - a.x
	var dr: int = b.y - a.y
	return (absi(dq) + absi(dq + dr) + absi(dr)) / 2


func _has_tile(st: WorldState, p: Vector2i) -> bool:
	return st.world.tiles.has(p.x * 1000 + p.y)


# 玩家隊搬到「半徑 7 內格子都在地圖上」且離其他隊最遠的格；全圖平原、全圖已知；疲勞、餘量歸零
func _prep(st: WorldState) -> TeamData:
	var pt: TeamData = st.teams[st.get_player_team_id()]
	var keys: Array = st.world.tiles.keys()
	keys.sort()
	var best: Vector2i = pt.tile_pos
	var bd: int = -1
	for k in keys:
		var p: Vector2i = (st.world.tiles[k] as HexTileData).tile_pos
		var inside: bool = true
		for dq in range(-7, 8):
			for dr in range(maxi(-7, -dq - 7), mini(7, -dq + 7) + 1):
				if not _has_tile(st, p + Vector2i(dq, dr)):
					inside = false
					break
			if not inside:
				break
		if not inside:
			continue
		var md: int = 1 << 30
		for tid in st.teams:
			var t: TeamData = st.teams[tid]
			if t == pt or t.population <= 0:
				continue
			md = mini(md, _hexd(p, t.tile_pos))
		if md > bd:
			bd = md
			best = p
	pt.tile_pos = best
	st.rebuild_team_tile_index()
	var known: Dictionary = {}
	for k in keys:
		(st.world.tiles[k] as HexTileData).terrain = "plains"
		known[k] = true
	st.team_tile_known[pt.team_id] = known
	pt.fatigue = 0.0
	pt.move_tick_acc = 0
	PathSystem._reset_cross_run()
	return pt


func _set_terrain(st: WorldState, p: Vector2i, terrain: String) -> void:
	(st.world.tiles[p.x * 1000 + p.y] as HexTileData).terrain = terrain


# 地形佈置（相對起點 s）
func _lay(st: WorldState, s: Vector2i, kind: String) -> void:
	match kind:
		"plains":        # 全平原（E5 挑佈置時換回用）
			for k in st.world.tiles:
				(st.world.tiles[k] as HexTileData).terrain = "plains"
		"forest_band":   # q 偏移 1、2 的整條帶都是森林 ⇒ 任何路都要穿過
			for k in st.world.tiles:
				var p: Vector2i = (st.world.tiles[k] as HexTileData).tile_pos
				if p.x - s.x in [1, 2]:
					(st.world.tiles[k] as HexTileData).terrain = "forest"
		"scatter":       # 散布森林：等代價的路很多、而每條路森林出現的先後不同
			for k in st.world.tiles:
				var p: Vector2i = (st.world.tiles[k] as HexTileData).tile_pos
				var d: Vector2i = p - s
				if d != Vector2i.ZERO and posmod(d.x + 2 * d.y, 3) == 0:
					(st.world.tiles[k] as HexTileData).terrain = "forest"
	PathSystem._reset_cross_run()


func _tick(st: WorldState, runner: SimRunner) -> void:
	var pt: TeamData = st.teams.get(st.get_player_team_id())
	runner.advance_tick(st, pt.tile_pos if pt != null else Vector2i(-1, -1))
	if st.encounter_active:
		_enc += 1
		runner._encounter_system.resolve_encounter_end(st, "draw")


func _advance_to(st: WorldState, runner: SimRunner, tick: int) -> void:
	while st.world.current_tick < tick:
		_tick(st, runner)


# 在 current_tick ＝ T−1 時排入 move_to ⇒ T 那一顆消化（同玩家按鍵：指令在推時間之後、系統之前）
func _order(st: WorldState, runner: SimRunner, tgt: Vector2i) -> Dictionary:
	st.command_seq += 1
	var seq: int = st.command_seq
	st.pending_commands.append({"name": "move_to", "args": {"tile_q": tgt.x, "tile_r": tgt.y}, "seq": seq})
	_tick(st, runner)
	var text: String = ""
	for r in st.command_results:
		if int(r.get("seq", -1)) == seq:
			text = String(r.get("text", ""))
	var pt: TeamData = st.teams[st.get_player_team_id()]
	return {"text": text, "order_tick": pt.task_start_tick, "tick": st.world.current_tick, "eta": _parse_eta(text),
		"atleast": text.contains("至少")}


func _parse_eta(text: String) -> int:
	var re := RegEx.new()
	re.compile("(預計|至少) (\\d+) 分鐘")
	var m: RegExMatch = re.search(text)
	return int(m.get_string(2)) if m != null else -1


# 逐 tick 推到 move_target 被清；回 {arrive_tick, path, fat_max, over, pop0, pop1, enc, arrived}
func _walk(st: WorldState, runner: SimRunner, tgt: Vector2i, mid_hook: Callable = Callable()) -> Dictionary:
	var pt: TeamData = st.teams[st.get_player_team_id()]
	var path: Array = [pt.tile_pos]
	var fat_max: float = pt.fatigue
	var over: bool = false
	var pop0: int = pt.population
	var enc0: int = _enc
	var guard: int = 0
	while pt.move_target != Vector2i(-1, -1) and guard < 4 * DAY:
		guard += 1
		_tick(st, runner)
		if pt.tile_pos != path[-1]:
			path.append(pt.tile_pos)
			if mid_hook.is_valid():
				mid_hook.call(st, pt, path.size() - 1)
		fat_max = maxf(fat_max, pt.fatigue)
		if MovementSystem.calc_total_weight_pure(pt) > MovementSystem.get_carry_capacity_pure(pt):
			over = true
	return {"arrive_tick": st.world.current_tick, "path": path, "fat_max": fat_max, "over": over,
		"pop0": pop0, "pop1": pt.population, "enc": _enc - enc0, "arrived": pt.tile_pos == tgt,
		"reason": pt.task_reason}


func _floor(label: String, wk: Dictionary, allow_over: bool = false) -> void:
	_check("★%s 地板：走到目標、遭遇 0、疲勞 ≤0.5（最高 %.3f）、%s人口不變（%d→%d）" % [label, float(wk["fat_max"]),
		"" if allow_over else "不超載、", int(wk["pop0"]), int(wk["pop1"])],
		bool(wk["arrived"]) and int(wk["enc"]) == 0 and float(wk["fat_max"]) <= 0.5 \
			and (allow_over or not bool(wk["over"])) and int(wk["pop0"]) == int(wk["pop1"]))


# ── E1–E4 ────────────────────────────────────────────────────────────────────
func _e_cell(label: String, start: int, off: Vector2i, acc0: int, lay: String) -> Dictionary:
	print("\n── %s 下令 tick %d（%02d:%02d）、目標 +%s、起始餘量 %d、地形 %s ──" % [label, start,
		(start % DAY) / 60, start % 60, str(off), acc0, lay if lay != "" else "平原"])
	var w: Array = _world()
	var st: WorldState = w[0]
	var runner: SimRunner = w[1]
	var pt: TeamData = _prep(st)
	if lay != "":
		_lay(st, pt.tile_pos, lay)
	var tgt: Vector2i = pt.tile_pos + off
	_advance_to(st, runner, start - 1)
	pt.move_tick_acc = acc0
	var o: Dictionary = _order(st, runner, tgt)
	var wk: Dictionary = _walk(st, runner, tgt)
	var actual: int = int(wk["arrive_tick"]) - int(o["order_tick"])
	print("   結果句「%s」｜下令 tick %d｜抵達 tick %d｜實走 %d｜估算 %d｜路 %s" % [o["text"], o["order_tick"],
		wk["arrive_tick"], actual, o["eta"], str(wk["path"])])
	_check("★%s 地板：下令 tick＝%d" % [label, start], int(o["order_tick"]) == start)
	_floor(label, wk)
	_check("%s 估算＝實走（%d＝%d）" % [label, o["eta"], actual], int(o["eta"]) == actual and not bool(o["atleast"]))
	_present[label] = true
	return {"eta": o["eta"], "actual": actual, "path": wk["path"]}


# ── E5 ───────────────────────────────────────────────────────────────────────
# [佈置名, 目標位移]：第一個「逐步重規劃（_astar 從每一格重算）走出的路 ≠ 起點整條路」的候選；都不分岔 ⇒ []
func _e5_pick(st: WorldState, s: Vector2i) -> Array:
	var offs: Array = [Vector2i(3, 3), Vector2i(6, 0), Vector2i(0, 6), Vector2i(4, 2), Vector2i(2, 4),
		Vector2i(5, 1), Vector2i(1, 5), Vector2i(-3, 6), Vector2i(6, -3), Vector2i(-6, 3)]
	for lay in ["plains", "scatter"]:
		_lay(st, s, "plains")
		_lay(st, s, lay)
		for off in offs:
			var tgt: Vector2i = s + off
			if not st.world.tiles.has(tgt.x * 1000 + tgt.y):
				continue
			var frozen: Array = PathSystem._astar(st, s, tgt)["path"]
			var walked: Array = [s]
			var cur: Vector2i = s
			for _i in 30:
				if cur == tgt:
					break
				cur = (PathSystem._astar(st, cur, tgt)["path"] as Array)[1]
				walked.append(cur)
			print("   候選 %s %s：起點路 %s｜重規劃 %s" % [lay, str(off), str(frozen), str(walked)])
			if str(frozen) != str(walked):
				return [lay, off]
	return []

func _e5() -> void:
	print("
── E5 長路 6 格、等代價路徑多、跨夜 ⇒ 每步重規劃 ──")
	var w: Array = _world()
	var st: WorldState = w[0]
	var runner: SimRunner = w[1]
	var pt: TeamData = _prep(st)
	_advance_to(st, runner, 600 - 1)
	# ★佈置挑選：_astar 用 sort_custom（不穩定排序）破同分 ⇒ 從中途格重規劃【可能】不是起點那條路的後段；
	#   哪一種地形／目標會分岔事先不知道 ⇒ 逐個候選（平原／散布森林 × 距離 6 的目標）用 _astar 靜態走一遍，
	#   挑第一個「重規劃走出的路 ≠ 起點算的整條路」的；地板仍比【實走】的路（不是這個預演）
	var pick: Array = _e5_pick(st, pt.tile_pos)
	_check("★E5 佈置：候選裡有每步重規劃會分岔的（%s）" % str(pick), not pick.is_empty())
	if pick.is_empty():
		return
	_lay(st, pt.tile_pos, "plains")
	_lay(st, pt.tile_pos, String(pick[0]))
	var tgt: Vector2i = pt.tile_pos + (pick[1] as Vector2i)
	var frozen: Array = PathSystem.find_path(st, pt.tile_pos, tgt)["path"]
	# ★估算器的影子路：同代價的兩條路在這個佈置走一樣久 ⇒ 只比分鐘數，估算器沿凍結路徑也會對（負對照 n2 紅不了）
	#   ⇒ 另比估算器影子走過的格＝實走的格（下令前同一顆 tick、同一個 state 呼叫，跟 move_to 裡那次同輸入）
	var est: Dictionary = MovementSystem.estimate_travel_ticks(st, pt, tgt, st.world.current_tick + 1)
	var o: Dictionary = _order(st, runner, tgt)
	var wk: Dictionary = _walk(st, runner, tgt)
	var actual: int = int(wk["arrive_tick"]) - int(o["order_tick"])
	print("   結果句「%s」｜實走 %d｜估算 %d" % [o["text"], actual, o["eta"]])
	print("   起點算的整條路 %s" % str(frozen))
	print("   估算器影子路   %s" % str(est.get("path", [])))
	print("   實際走過的路   %s" % str(wk["path"]))
	_floor("E5", wk)
	_check("★E5 地板：實走的路 ≠ 起點算的整條路（每步重規劃真的有差）", str(frozen) != str(wk["path"]))
	_check("★E5 地板：跨夜（抵達在下令後 %d 分、超過到 21:36 的 %d 分）" % [actual, 1296 - 600], actual > 1296 - 600)
	_check("E5 估算＝實走（%d＝%d）" % [o["eta"], actual], int(o["eta"]) == actual)
	_check("E5 估算器影子路＝實走的路", str(est.get("path", [])) == str(wk["path"]))
	_present["E5"] = true

# ── E6 ───────────────────────────────────────────────────────────────────────
func _e6() -> void:
	print("\n── E6 抵達對帳：逐 tick 與 SimBridge 推進塊（60／37 tick）同一個 N ──")
	var ref: Dictionary = {}
	for mode in ["per_tick", "block60", "block37"]:
		var w: Array = _world()
		var st: WorldState = w[0]
		var runner: SimRunner = w[1]
		var pt: TeamData = _prep(st)
		var tgt: Vector2i = pt.tile_pos + Vector2i(2, 0)
		_advance_to(st, runner, 641 - 1)
		if mode == "per_tick":
			var o: Dictionary = _order(st, runner, tgt)
			var wk: Dictionary = _walk(st, runner, tgt)
			ref = {"order": int(o["order_tick"]), "arrive": int(wk["arrive_tick"]), "eta": int(o["eta"])}
			print("   逐 tick：下令 %d、抵達 %d、N＝%d、估算 %d" % [ref["order"], ref["arrive"], ref["arrive"] - ref["order"], ref["eta"]])
			continue
		var bridge := SimBridge.new(runner, st)
		bridge._enqueue_command("move_to", {"tile_q": tgt.x, "tile_r": tgt.y})
		var blk: int = 60 if mode == "block60" else 37
		var guard: int = 0
		while bridge.get_player_last_arrival().is_empty() and guard < 200:
			guard += 1
			bridge.advance_ticks(blk)
			if st.encounter_active:
				_enc += 1
				runner._encounter_system.resolve_encounter_end(st, "draw")
		var arr: Dictionary = bridge.get_player_last_arrival()
		var n: int = int(arr.get("tick", -1)) - int(arr.get("order_tick", 0))
		print("   %s：bridge 記 下令 %d、抵達 %d、N＝%d｜推完時 tick %d" % [mode, int(arr.get("order_tick", -1)),
			int(arr.get("tick", -1)), n, st.world.current_tick])
		_check("E6 %s：抵達 tick 與逐 tick 相同（%d＝%d）、N 相同（%d）" % [mode, int(arr.get("tick", -1)), ref["arrive"], n],
			int(arr.get("tick", -1)) == ref["arrive"] and int(arr.get("order_tick", -1)) == ref["order"])
		# ★只在 60 塊上斷言：640＋60k 永遠不是整點、而移動只在整點 ⇒ 推完時必然不是抵達那一顆；37 塊可能剛好撞上（只印）
		if mode == "block60":
			_check("★E6 block60 地板：推進塊越過抵達那一顆（推完 tick %d ≠ 抵達 tick）—— 記到的不是輪詢看到的 tick" % st.world.current_tick,
				st.world.current_tick != int(arr.get("tick", -1)))
	_check("E6 N＝估算（%d＝%d）" % [ref["arrive"] - ref["order"], ref["eta"]], ref["arrive"] - ref["order"] == ref["eta"])
	var ui_src: String = FileAccess.get_file_as_string("res://scripts/ui/text_ui_main.gd")
	_check("E6 畫面的抵達句讀 bridge 記的那一筆（_arrival_sentence → get_player_last_arrival）",
		ui_src.contains("get_player_last_arrival()") and ui_src.count("_arrival_sentence(") >= 3)
	_present["E6"] = true


# ── E7 疲勞 ──────────────────────────────────────────────────────────────────
func _e7() -> void:
	print("\n── E7 疲勞 0%：玩家隊 12 小時行進，逐次疲勞 pass ──")
	Probe.arm()
	var w: Array = _world()
	var st: WorldState = w[0]
	var runner: SimRunner = w[1]
	var pt: TeamData = _prep(st)
	var tgt: Vector2i = pt.tile_pos + Vector2i(6, 0)
	_advance_to(st, runner, 600 - 1)
	var key: String = "sysexec.fatigue.byteam.%04d" % pt.team_id
	var n0: int = int(Probe.counts.get("fatigue.pass.n", 0))
	var cls0: Dictionary = {}
	for c in ["moved", "combat", "task", "rest"]:
		cls0[c] = int(Probe.counts.get("fatigue.class." + c, 0))
	var o: Dictionary = _order(st, runner, tgt)
	var passes: Array = []
	var stepped_hours: int = 0
	var last_pos: Vector2i = pt.tile_pos
	var t_end: int = int(o["order_tick"]) + 12 * 60
	var stepped_since_pass: bool = false
	while st.world.current_tick < t_end:
		var c0: int = int(Probe.counts.get(key, 0))
		var f0: float = pt.fatigue
		_tick(st, runner)
		if pt.tile_pos != last_pos:
			stepped_hours += 1
			stepped_since_pass = true
			last_pos = pt.tile_pos
		if int(Probe.counts.get(key, 0)) > c0:
			var d: float = pt.fatigue - f0
			var cls: String = "耗力" if d > 0.0 else ("回復" if d < 0.0 else ("回復（已是 0）" if f0 == 0.0 else "不變"))
			passes.append("t%d(+%02d) %.4f→%.4f %s%s" % [st.world.current_tick, st.world.current_tick % 60, f0, pt.fatigue, cls,
				"｜這段有跨格" if stepped_since_pass else ""])
			stepped_since_pass = false
	for p in passes:
		print("   " + p)
	var cls_d: Dictionary = {}
	for c in ["moved", "combat", "task", "rest"]:
		cls_d[c] = int(Probe.counts.get("fatigue.class." + c, 0)) - int(cls0[c])
	print("   12 小時：玩家隊疲勞 pass %d 次｜跨格 %d 次｜最終 fatigue %.4f（畫面 %d%%）" % [passes.size(), stepped_hours,
		pt.fatigue, int(pt.fatigue * 100)])
	print("   全世界 fatigue.pass.n +%d｜fatigue.class.* +%s" % [int(Probe.counts.get("fatigue.pass.n", 0)) - n0, str(cls_d)])
	print("   UI「疲勞」讀 PlayerApiMapper fatigue_pct＝int(team.fatigue×100)（不是成員 stress）")
	Probe.enabled = false
	_check("★E7 地板：12 小時內疲勞 pass ≥ 12 次、玩家隊有跨格", passes.size() >= 12 and stepped_hours > 0)
	_present["E7"] = true


# ── E8 ───────────────────────────────────────────────────────────────────────
func _e8_world() -> Dictionary:
	var w: Array = _world()
	var st: WorldState = w[0]
	var runner: SimRunner = w[1]
	var pt: TeamData = _prep(st)
	var vr: int = VisionSystem.vision_range(st, pt)
	var m: Vector2i = pt.tile_pos + Vector2i(vr + 1, 0)
	var tgt: Vector2i = pt.tile_pos + Vector2i(vr + 3, 0)
	_set_terrain(st, m, "mountain")
	PathSystem._reset_cross_run()
	return {"st": st, "runner": runner, "pt": pt, "m": m, "tgt": tgt, "vr": vr}


func _forget(st: WorldState, pt: TeamData, m: Vector2i) -> void:
	(st.team_tile_known[pt.team_id] as Dictionary).erase(m.x * 1000 + m.y)


func _e8() -> void:
	print("\n── E8 路上一格是山、玩家沒去過 ⇒「至少 N 分鐘」、N＝當平原的估算、≤ 實走 ──")
	var e: Dictionary = _e8_world()
	var st: WorldState = e["st"]
	var runner: SimRunner = e["runner"]
	var pt: TeamData = e["pt"]
	var m: Vector2i = e["m"]
	var tgt: Vector2i = e["tgt"]
	var start: int = 601
	_advance_to(st, runner, start - 1)
	# 對照估算（同一刻、同起點、同餘量；start_tick＝下令那一顆）
	var known: Dictionary = st.team_tile_known[pt.team_id]
	known[m.x * 1000 + m.y] = true
	var est_true: Dictionary = MovementSystem.estimate_travel_ticks(st, pt, tgt, start)
	_set_terrain(st, m, "plains")
	var est_plain: Dictionary = MovementSystem.estimate_travel_ticks(st, pt, tgt, start)
	_set_terrain(st, m, "mountain")
	_forget(st, pt, m)
	PathSystem._reset_cross_run()
	var in_view: bool = MovementSystem.belief_known_tiles(st, pt).has(m.x * 1000 + m.y)
	var o: Dictionary = _order(st, runner, tgt)
	var wk: Dictionary = _walk(st, runner, tgt)
	var actual: int = int(wk["arrive_tick"]) - int(o["order_tick"])
	print("   視野 %d｜山在 %s｜目標 %s" % [e["vr"], str(m), str(tgt)])
	print("   結果句「%s」｜估算 %d｜當平原且已知 %d｜真實已知 %d｜實走 %d｜實走的路 %s" % [o["text"], o["eta"],
		int(est_plain["ticks"]), int(est_true["ticks"]), actual, str(wk["path"])])
	_check("★E8 地板：下令時那一格不在玩家已知範圍", not in_view)
	_floor("E8", wk)
	_check("E8 句子是「至少 N 分鐘」", bool(o["atleast"]))
	_check("E8 估算＝那格當平原的估算（%d＝%d）" % [o["eta"], int(est_plain["ticks"])], int(o["eta"]) == int(est_plain["ticks"]))
	_check("E8 估算 ≠ 真實已知的估算（%d≠%d）—— 不洩露迷霧裡的地形" % [o["eta"], int(est_true["ticks"])], int(o["eta"]) != int(est_true["ticks"]))
	_check("E8 估算 ≤ 實走（下界：%d ≤ %d）" % [o["eta"], actual], int(o["eta"]) <= actual)
	_present["E8"] = true


# ── E9 ───────────────────────────────────────────────────────────────────────
func _e9() -> void:
	print("\n── E9 belief 估算不汙染共用快取：同 tick 先估算再真走 ⇒ 路逐格相同 ──")
	var paths: Array = []
	var cache_delta: int = -1
	for arm in ["with_estimator", "without"]:
		var e: Dictionary = _e8_world()
		var st: WorldState = e["st"]
		var runner: SimRunner = e["runner"]
		var pt: TeamData = e["pt"]
		var tgt: Vector2i = e["tgt"]
		_advance_to(st, runner, 601 - 1)
		_forget(st, pt, e["m"])
		if arm == "with_estimator":
			var c0: int = PathSystem._path_cache.size()
			MovementSystem.estimate_travel_ticks(st, pt, tgt, 601)
			cache_delta = PathSystem._path_cache.size() - c0
			_order(st, runner, tgt)   # move_to 內又跑一次估算（同一顆 tick、在移動之前）
		else:
			# 不經 move_to（不跑估算）：同一筆 arbiter 佔用，早一顆 tick 寫；601 非整點 ⇒ 移動窗口相同
			TaskArbiter.try_set(st, pt, TeamData.TASK_TRAVEL, tgt, TaskArbiter.PRIO_PLAYER, "player_move")
		var wk: Dictionary = _walk(st, runner, tgt)
		paths.append(wk["path"])
		print("   %s：路 %s｜抵達 tick %d" % [arm, str(wk["path"]), int(wk["arrive_tick"])])
	_check("E9 估算前後共用快取大小不變（差 %d）" % cache_delta, cache_delta == 0)
	_check("E9 跑過估算的世界，真移動的路與沒跑估算的逐格相同", str(paths[0]) == str(paths[1]))
	_present["E9"] = true


# ── SRC 同源 ─────────────────────────────────────────────────────────────────
func _src() -> void:
	print("\n── SRC 同源：載重超過上限 ⇒ 估算與實走一起變 ──")
	var res: Array = []
	for over in [false, true]:
		var w: Array = _world()
		var st: WorldState = w[0]
		var runner: SimRunner = w[1]
		var pt: TeamData = _prep(st)
		var tgt: Vector2i = pt.tile_pos + Vector2i(2, 0)
		if over:
			ResourceBank.set_amt(pt, "material", MovementSystem.get_carry_capacity_pure(pt) * 2.0, "bed_seed")
		_advance_to(st, runner, 601 - 1)
		var o: Dictionary = _order(st, runner, tgt)
		var wk: Dictionary = _walk(st, runner, tgt)
		var actual: int = int(wk["arrive_tick"]) - int(o["order_tick"])
		res.append({"eta": int(o["eta"]), "actual": actual})
		print("   %s：結果句「%s」｜實走 %d｜重 %.1f／上限 %.1f" % ["超載" if over else "不超載", o["text"], actual,
			MovementSystem.calc_total_weight_pure(pt), MovementSystem.get_carry_capacity_pure(pt)])
		_floor("SRC %s" % ("超載" if over else "不超載"), wk, over)
	_check("SRC 超載改變了估算（%d→%d）" % [res[0]["eta"], res[1]["eta"]], res[0]["eta"] != res[1]["eta"])
	_check("SRC 兩種載重下估算都＝實走（%d＝%d、%d＝%d）" % [res[0]["eta"], res[0]["actual"], res[1]["eta"], res[1]["actual"]],
		res[0]["eta"] == res[0]["actual"] and res[1]["eta"] == res[1]["actual"])
	var src: String = FileAccess.get_file_as_string("res://scripts/simulation/movement_system.gd")
	var p_body: String = _func_body(src, "func process(")
	var e_body: String = _func_body(src, "static func estimate_travel_ticks(")
	_check("SRC 結構：process 與 estimate_travel_ticks 都呼 run_window、檔內步進迴圈只有一份",
		p_body.contains("run_window(") and e_body.contains("run_window(") and src.count("while steps < max_steps") == 1)
	_present["SRC"] = true


func _func_body(src: String, head: String) -> String:
	var i: int = src.find(head)
	if i < 0:
		return ""
	var j: int = src.find("\nfunc ", i + 1)
	var k: int = src.find("\nstatic func ", i + 1)
	var end: int = src.length()
	for x in [j, k]:
		if x > 0 and x < end:
			end = x
	return src.substr(i, end - i)


# ── R 第二階殘差 ─────────────────────────────────────────────────────────────
func _residuals() -> void:
	print("\n── R 第二階殘差（只印，不放寬 E1–E5）──")
	for label in ["R1", "R2", "R3"]:
		var w: Array = _world()
		var st: WorldState = w[0]
		var runner: SimRunner = w[1]
		var pt: TeamData = _prep(st)
		var tgt: Vector2i = pt.tile_pos + Vector2i(4, 0)
		var hook: Callable = Callable()
		var what: String = ""
		match label:
			"R1":
				what = "疲勞中途變（起始 0.80）"
			"R2":
				what = "糧吃掉變輕（起始超載，超出部分全是糧）"
				ResourceBank.set_amt(pt, "food", float(pt.resources.get("food", 0.0)) \
					+ (MovementSystem.get_carry_capacity_pure(pt) - MovementSystem.calc_total_weight_pure(pt)) / 0.1 + 300.0, "bed_seed")
			"R3":
				what = "人口變動（第 2 格加入 20 名匿名）"
				hook = func(_s: WorldState, t: TeamData, step: int) -> void:
					if step == 2:
						AnonTierSystem.add_anon(t, AnonTierSystem.TIER_ORDER[0], 20)
		_advance_to(st, runner, 601 - 1)
		if label == "R1":
			pt.fatigue = 0.8
		var o: Dictionary = _order(st, runner, tgt)
		var r_in: Dictionary = MovementSystem.estimate_travel_ticks(st, pt, tgt, int(o["order_tick"]))["residual_inputs"]
		var wk: Dictionary = _walk(st, runner, tgt, hook)
		var actual: int = int(wk["arrive_tick"]) - int(o["order_tick"])
		print("   %s %s：估算 %d｜實走 %d｜殘差 %+d（%+.1f%%）｜凍住的輸入 %s｜走完 疲勞 %.3f 重 %.1f 人口 %d" % [label, what,
			o["eta"], actual, actual - int(o["eta"]), 100.0 * float(actual - int(o["eta"])) / maxf(float(o["eta"]), 1.0), str(r_in),
			pt.fatigue, MovementSystem.calc_total_weight_pure(pt), pt.population])
		_check("★%s 地板：走到目標、估算有值" % label, bool(wk["arrived"]) and int(o["eta"]) > 0)
		_present[label] = true


# ── AI 舊估算 ────────────────────────────────────────────────────────────────
func _ai() -> void:
	print("\n── AI 舊估算（_estimate_eta_to）夜間兩格 ──")
	var w: Array = _world()
	var st: WorldState = w[0]
	var runner: SimRunner = w[1]
	var pt: TeamData = _prep(st)
	var tgt: Vector2i = pt.tile_pos + Vector2i(2, 0)
	var start: int = 1310   # 21:50，夜
	_advance_to(st, runner, start - 1)
	var old: int = FactionAISystem.shared()._estimate_eta_to(st, pt, tgt)
	var o: Dictionary = _order(st, runner, tgt)
	var wk: Dictionary = _walk(st, runner, tgt)
	var actual: int = int(wk["arrive_tick"]) - int(o["order_tick"])
	print("   下令 21:50｜AI 舊估算 %d｜新估算 %d｜實走 %d｜舊估算低估 %.1f%%" % [old, o["eta"], actual,
		100.0 * float(actual - old) / maxf(float(actual), 1.0)])
	_floor("AI", wk)
	_check("AI 新估算＝實走（%d＝%d）" % [o["eta"], actual], int(o["eta"]) == actual)
	_present["AI"] = true
