extends SceneTree
# @bed-kind: diagnostic
# 友善度 F8 P8g（spec 2026-10-07 round5-friendliness §F8）：間距與山地禁紮退場的改前改後量測（先量，不預測）
#   seed 1337、30 天、default config（無玩家）：
#   camp.built｜settlement.l0_to_l1_start｜山地立營數｜據點兩兩最近距離分佈（第 30 天）｜山地營地存活最大天數
# ★報告逐字印一行 `mountain_camp_survived_days: <天數>`（defer mountain-build-time-by-terrain 的 met_check 讀它）
# ★輸出：印到 stdout；F8_MEASURE_OUT 環境變數給了路徑就把同一份追加寫進去（改前改後各一段）
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/f8_camp_spacing_measure.gd

const SEED: int = 1337
const DAYS: int = 30


func _initialize() -> void:
	seed(SEED)
	var ws: WorldState = MeasureBedHelper.arm_and_setup("res://config/default.json", false)
	var runner := SimRunner.new()
	var mountain_camps: int = 0
	var camp_born: Dictionary = {}     # tile_id → 立營 tick（山地）
	var survived_max: int = 0
	var seen_camp: Dictionary = {}
	for _i in range(DAYS * WorldState.TICKS_PER_DAY):
		runner.advance_tick(ws, Vector2i(-1, -1))
		var now: int = ws.world.current_tick
		for k in ws.world.tiles:
			var t: HexTileData = ws.world.tiles[k]
			var has_camp: bool = t.camp_level > 0
			if has_camp and not bool(seen_camp.get(k, false)):
				seen_camp[k] = true
				if t.terrain == "mountain":
					mountain_camps += 1
					camp_born[k] = now
			elif not has_camp and bool(seen_camp.get(k, false)):
				seen_camp[k] = false
			if camp_born.has(k):
				var alive: bool = t.camp_level > 0 or t.outpost_level > 0
				var days: int = int((now - int(camp_born[k])) / WorldState.TICKS_PER_DAY)
				survived_max = maxi(survived_max, days)
				if not alive:
					camp_born.erase(k)
	# 據點兩兩最近距離（第 30 天）
	var pos: Array = []
	for k2 in ws.world.tiles:
		var t2: HexTileData = ws.world.tiles[k2]
		if t2.outpost_level > 0:
			pos.append(t2.tile_pos)
	var hist: Dictionary = {}
	for a in pos:
		var best: int = 1 << 30
		for b in pos:
			if a == b:
				continue
			var dx: int = b.x - a.x
			var dy: int = b.y - a.y
			best = mini(best, (absi(dx) + absi(dx + dy) + absi(dy)) / 2)
		if best < (1 << 30):
			hist[best] = int(hist.get(best, 0)) + 1
	var keys: Array = hist.keys()
	keys.sort()
	var hist_s: Array = []
	for d in keys:
		hist_s.append("%d:%d" % [int(d), int(hist[d])])
	var lines: Array = [
		"[F8-P8g] tree=%s seed=%d days=%d" % [_git_head(), SEED, DAYS],
		"camp.built: %d" % int(Probe.counts.get("camp.built", 0)),
		"settlement.l0_to_l1_start: %d" % int(Probe.counts.get("settlement.l0_to_l1_start", 0)),
		"mountain_camps: %d" % mountain_camps,
		"outposts_day30: %d" % pos.size(),
		"nearest_outpost_distance_hist: %s" % ", ".join(PackedStringArray(hist_s)),
		"mountain_camp_survived_days: %d" % survived_max,
	]
	for l in lines:
		print(l)
	var out: String = OS.get_environment("F8_MEASURE_OUT")
	if out != "":
		var f := FileAccess.open(out, FileAccess.READ_WRITE if FileAccess.file_exists(out) else FileAccess.WRITE)
		f.seek_end()
		f.store_string("\n".join(PackedStringArray(lines)) + "\n\n")
		f.close()
	print("=== f8_camp_spacing_measure DONE ===")
	quit(0)


func _git_head() -> String:
	var o: Array = []
	OS.execute("git", ["rev-parse", "--short", "HEAD"], o)
	return String(o[0]).strip_edges() if not o.is_empty() else "?"
