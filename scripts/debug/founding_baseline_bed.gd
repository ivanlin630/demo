extends SceneTree
# @bed-kind: diagnostic
# slice: 觀察輪（板一之半）——新開據點的地形、位置、開點天數（systems 2026-10-18 請求信 observation-round-founding-instrument-baseline）
# ★只觀測、零 RNG、不開 Probe：自己 new WorldState + GameSetup.setup（不呼 Probe.arm），每 tick 結束後掃 tiles／teams 的現成欄位。
#   世界推進與 build_site_census.gd 同一套（含「encounter_tick>800 就判 draw」，否則玩家遭遇戰會卡住模擬）。
# 「蓋成」＝ tile.outpost_level 0→>0（setup 後才算）。逐列印：哪隊、哪 tick、哪格、地形、離最近的【其他】據點幾格、離母隊幾格。
# 「第一次想開點」兩個訊號都印（不挑一個藏另一個）：
#   A＝蓋成這隊（以及它的母隊鏈）第一次被看到 current_task ∈ {紮營,建設,建造} 的 tick（意願訊號：被選中那一拍）
#   B＝蓋成這隊若是子隊，它【出生】的 tick（派建造子隊被選中的那一拍；獨立隊無 B）
#   開點目標合併後若有更好的訊號（目標表裡的開點目標）比對時再加一欄。
# 想開沒成：tile.construction_target.action=="build" 出現後又被清掉且 outpost_level 仍 0 ⇒ 一列取消；
#   原因無 Probe 無法直接讀 ⇒ 只印【可觀測的推論】：存活 tick 數、是否過採料期限（gather_window_days）、施工隊是否還在、料量。
# env：LW_CONFIG（warring_states）／PERF_SEED（20260922）／TICKS（20000；0 則用 ADHOC_DAYS×1440）／ADHOC_DAYS／OUT（可選：另寫一份到檔）

var _lines: Array = []

func _initialize() -> void:
	_run()
	quit()

func _env(k: String, d: String) -> String:
	var v: String = OS.get_environment(k)
	return v if v != "" else d

func _p(s: String) -> void:
	print(s)
	_lines.append(s)

func _hex_dist(a: Vector2i, b: Vector2i) -> int:
	var dx: int = b.x - a.x
	var dy: int = b.y - a.y
	return (absi(dx) + absi(dx + dy) + absi(dy)) / 2

func _git_head_sha() -> String:
	var out: Array = []
	OS.execute("git", ["rev-parse", "--short=9", "HEAD"], out, true)
	return String(out[0]).strip_edges() if out.size() > 0 else "UNKNOWN"

func _world_fp(ws: WorldState) -> String:
	var ids: Array = ws.teams.keys()
	ids.sort()
	var arr: Array = []
	for tid in ids:
		var t: TeamData = ws.teams[tid]
		arr.append([tid, t.leader_id, t.tile_pos.x, t.tile_pos.y, t.population, t.current_task, t.current_option, t.task_priority,
			snappedf(float(t.resources.get("food", 0)), 0.01), snappedf(float(t.resources.get("coin", 0)), 0.01),
			snappedf(float(t.resources.get("material", 0)), 0.01)])
	arr.append(["__world__", ws.world.current_tick, ws.game_over, ws.game_over_reason])
	return JSON.stringify(arr).sha256_text()

func _is_want_task(task: String) -> bool:
	return task == TeamData.TASK_CAMP or task == TeamData.TASK_BUILD or task == TeamData.TASK_CONSTRUCT

func _median(arr: Array) -> float:
	if arr.is_empty():
		return -1.0
	var s: Array = arr.duplicate()
	s.sort()
	return float(s[s.size() / 2])

func _run() -> void:
	var cfg: String = _env("LW_CONFIG", "warring_states")
	var sd: int = int(_env("PERF_SEED", "20260922"))
	var total: int = int(_env("TICKS", "20000"))
	if total <= 0:
		total = int(_env("ADHOC_DAYS", "30")) * WorldState.TICKS_PER_DAY
	var tpd: float = float(WorldState.TICKS_PER_DAY)
	_p("=== founding_baseline_bed：config=%s seed=%d ticks=%d（≈%.1f 天）tree=%s Probe.enabled=%s ===" % [
		cfg, sd, total, total / tpd, _git_head_sha(), str(Probe.enabled)])
	seed(sd)
	FactionAISystem._a2b_remote_tribute_payers.clear()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/%s.json" % cfg)
	config["seed"] = sd
	var state := WorldState.new()
	GameSetup.setup(state, config)

	var level0: Dictionary = {}      # tile_pos -> outpost_level（上一 tick）
	var seen_build: Dictionary = {}  # tile_pos -> {start, team, owner, terrain, gather_left, stock, last_ct_alive}
	var born: Dictionary = {}        # team_id -> 出生 tick（setup 後才見到的 team）
	var parent_of: Dictionary = {}   # team_id -> parent_team_id
	var first_want: Dictionary = {}  # team_id -> 第一次見到 want task 的 tick
	var base_ids: Dictionary = {}
	for tid in state.teams:
		base_ids[tid] = true
	for tid in state.teams:
		parent_of[tid] = (state.teams[tid] as TeamData).parent_team_id
	for tid in state.world.tiles:
		var t0: HexTileData = state.world.tiles[tid]
		level0[t0.tile_pos] = t0.outpost_level
	var founded: Array = []
	var cancelled: Array = []
	var max_tick: int = 0
	for _i in range(total):
		runner.advance_tick(state, Vector2i(-1, -1))
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		var now: int = state.world.current_tick
		max_tick = now
		for tid in state.teams:
			var tm: TeamData = state.teams[tid]
			if not born.has(tid) and not base_ids.has(tid):
				born[tid] = now
				parent_of[tid] = tm.parent_team_id
			if not first_want.has(tid) and _is_want_task(tm.current_task):
				first_want[tid] = now
		for tid in state.world.tiles:
			var t: HexTileData = state.world.tiles[tid]
			var pos: Vector2i = t.tile_pos
			var is_build: bool = not t.construction_target.is_empty() and str(t.construction_target.get("action", "")) == "build"
			if is_build and not seen_build.has(pos):
				var ct: TeamData = state.teams.get(t.construction_team_id)
				seen_build[pos] = {"start": now, "team": t.construction_team_id, "terrain": t.terrain,
					"cstart": t.construction_started_tick,
					"gather_left": float((t.construction_target.get("gather_left", {}) as Dictionary).get("material", 0.0)),
					"parent": (ct.parent_team_id if ct != null else -2)}
			var prev: int = int(level0.get(pos, 0))
			if t.outpost_level > 0 and prev == 0:
				var rec: Dictionary = seen_build.get(pos, {})
				var team_id: int = int(rec.get("team", t.outpost_owner))
				var ft: TeamData = state.teams.get(team_id)
				var nearest: int = -1
				for oid in state.world.tiles:
					var o: HexTileData = state.world.tiles[oid]
					if o.outpost_level > 0 and o.tile_pos != pos:
						var d: int = _hex_dist(o.tile_pos, pos)
						if nearest < 0 or d < nearest:
							nearest = d
				var par: int = int(parent_of.get(team_id, -1))
				var par_d: int = -1
				var pt: TeamData = state.teams.get(par)
				if pt != null:
					par_d = _hex_dist(pt.tile_pos, pos)
				var wa: int = int(first_want.get(team_id, -1))
				var wp: int = int(first_want.get(par, -1)) if par != -1 else -1
				var wcand: Array = []
				if wa >= 0: wcand.append(wa)
				if wp >= 0: wcand.append(wp)
				var wmin: int = -1
				for w in wcand:
					wmin = int(w) if wmin < 0 else mini(wmin, int(w))
				founded.append({"tick": now, "team": team_id, "owner": t.outpost_owner, "pos": pos, "terrain": t.terrain,
					"nearest_other": nearest, "parent": par, "parent_dist": par_d,
					"A_self": wa, "A_parent": wp, "A_min": wmin, "B_born": int(born.get(team_id, -1)),
					"build_start": int(rec.get("start", -1)), "cstart": int(rec.get("cstart", -1)),
					"via": ("construct" if rec.has("start") else "NOT-via-construct")})
				seen_build.erase(pos)
			elif not is_build and seen_build.has(pos) and t.outpost_level == 0:
				var r2: Dictionary = seen_build[pos]
				var ct2: TeamData = state.teams.get(int(r2["team"]))
				cancelled.append({"tick": now, "pos": pos, "terrain": t.terrain, "team": r2["team"], "start": r2["start"],
					"lived": now - int(r2["start"]), "gather_left0": r2["gather_left"], "team_alive": ct2 != null,
					"team_pop": (ct2.population if ct2 != null else -1)})
				seen_build.erase(pos)
			level0[pos] = t.outpost_level
		if state.teams.is_empty():
			break

	var open_at_end: Array = []
	for pos in seen_build:
		var r3: Dictionary = seen_build[pos]
		open_at_end.append("(%d,%d) %s 隊%s 開工 tick %d" % [pos.x, pos.y, r3["terrain"], str(r3["team"]), int(r3["start"])])
	_p("--- 結束 tick=%d teams=%d world_fp=%s ---" % [max_tick, state.teams.size(), _world_fp(state)])
	_p("--- 蓋成 %d 座（outpost_level 0→>0，setup 後）---" % founded.size())
	_p("F|idx|tick|day|team|owner|pos|terrain|離最近其他據點|母隊|離母隊|A自身|A母隊|A最早|蓋成−A最早(天)|B出生|蓋成−B(天)|開工tick|via")
	var days_a: Array = []
	var days_b: Array = []
	var terr: Dictionary = {}
	var i: int = 0
	for f in founded:
		var da: float = (float(int(f["tick"]) - int(f["A_min"])) / tpd) if int(f["A_min"]) >= 0 else -1.0
		var db: float = (float(int(f["tick"]) - int(f["B_born"])) / tpd) if int(f["B_born"]) >= 0 else -1.0
		if da >= 0.0: days_a.append(da)
		if db >= 0.0: days_b.append(db)
		terr[f["terrain"]] = int(terr.get(f["terrain"], 0)) + 1
		var p2: Vector2i = f["pos"]
		_p("F|%d|%d|%.2f|%d|%d|(%d,%d)|%s|%d|%d|%d|%d|%d|%d|%.2f|%d|%.2f|%d|%s" % [i, f["tick"], int(f["tick"]) / tpd, f["team"], f["owner"],
			p2.x, p2.y, f["terrain"], f["nearest_other"], f["parent"], f["parent_dist"], f["A_self"], f["A_parent"], f["A_min"], da,
			f["B_born"], db, f["build_start"], f["via"]])
		i += 1
	_p("--- 想開沒成：施工中被取消（outpost_level 仍 0）%d 列 ---" % cancelled.size())
	_p("C|tick|pos|terrain|team|開工tick|存活tick|開工時缺料|隊還在|隊人口|推論")
	var win_ticks: int = int(round(OutpostSystem.gather_window_days() * tpd))
	for c in cancelled:
		var p3: Vector2i = c["pos"]
		var why: String = "存活>採料期限(%d)⇒疑 gather_abort" % win_ticks if int(c["lived"]) > win_ticks else "存活≤採料期限⇒疑停工逾時或隊被召走"
		if not bool(c["team_alive"]):
			why += "｜施工隊已不在世界"
		_p("C|%d|(%d,%d)|%s|%d|%d|%d|%.1f|%s|%d|%s" % [c["tick"], p3.x, p3.y, c["terrain"], c["team"], c["start"], c["lived"],
			c["gather_left0"], str(c["team_alive"]), c["team_pop"], why])
	_p("--- 結束時仍在施工 %d 處：%s ---" % [open_at_end.size(), "；".join(open_at_end)])
	_p("--- 彙總 ---")
	_p("S|蓋成數=%d｜取消數=%d｜結束仍施工=%d" % [founded.size(), cancelled.size(), open_at_end.size()])
	_p("S|地形分佈=%s" % JSON.stringify(terr))
	days_a.sort()
	days_b.sort()
	_p("S|開點天數（訊號A，蓋成−A最早）n=%d 中位=%.2f 最大=%.2f" % [days_a.size(), _median(days_a), (days_a[-1] if not days_a.is_empty() else -1.0)])
	_p("S|開點天數（訊號B，蓋成−子隊出生）n=%d 中位=%.2f 最大=%.2f" % [days_b.size(), _median(days_b), (days_b[-1] if not days_b.is_empty() else -1.0)])
	var out: String = _env("OUT", "")
	if out != "":
		var fh := FileAccess.open(out, FileAccess.WRITE)
		if fh != null:
			fh.store_string("\n".join(_lines) + "\n")
			fh.close()
