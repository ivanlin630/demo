extends SceneTree
# @observe-pure
# ★★★量：`manufacture.noop_no_material` 這個 tap 到底由什麼組成 —— ★只盤不修（production 0 行）。
#
# ★病（型③/LOD 那輪撞到的）：那顆 tap 的名字說「原料不足」，
#   ★★而 `_run_recipe_group` 回 "" 有【三種完全不同】的成因：
#     ①target <= 0 或 stock >= target ⇒ ★需求已滿／無需求（★★這其實是【健康行為】）
#     ②q <= 0                         ⇒ worker_rate == 0（勞力／need-gating），與原料無關
#     ③_can_consume_scaled 為 false   ⇒ ★★★真的原料不足
#   ⇒ 三者被記進同一個桶 ⇒ 讀的人會把「不需要生產」讀成「沒料」，然後去修一個不存在的問題。
#   ★而「三種」這個數字本身是【第一版副本漏了①、被對帳行抓出來】才知道的 ——
#     我原本以為是兩種。
#
# ★而這支床【不改 production】：它在床裡【複製那個 gate 的判斷】
#   （呼叫的是同一批 production 函式：worker_rate_of / _can_consume_scaled / RECIPE_GROUPS / RATES）
#   ⇒ ★★數字可以拿來當「該不該拆 tap」的依據，★★★但它是【複製品】不是 production 本身
#     —— 副本對不代表 production 對（S6 那次的教訓），所以下面每一欄都印出【判斷依據】。

func _initialize() -> void:
	_run(); quit()

func _mk_tile(st: WorldState, pos: Vector2i) -> HexTileData:
	var t := HexTileData.new()
	t.tile_pos = pos; t.tile_id = pos.x * 1000 + pos.y
	t.terrain = "plains"
	st.world.tiles[t.tile_id] = t
	return t

func _run() -> void:
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 30
	var scarce: bool = OS.has_environment("BED_SCARCE") and OS.get_environment("BED_SCARCE") == "1"
	seed(1337)
	# ★手工組世界走 helper 的另一支入口（arm 先發生）
	var st := MeasureBedHelper.arm_and_new()
	for x in range(0, 12):
		for y in range(0, 12):
			_mk_tile(st, Vector2i(x, y))
	var team := TeamData.new()
	team.team_id = 1
	team.tile_pos = Vector2i(5, 5)
	team.faction_id = -1
	team.tags = ["生產"]
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", 10)
	var l := PersonData.new()
	l.id = 10; l.team_id = 1
	l.values = {"好戰": 0.3, "貪婪": 0.3, "慎重": 0.5, "野心": 0.3, "義氣": 0.5}
	l.skills = {"生產": 0.5, "統領": 0.5}
	st.persons[10] = l
	team.leader_id = 10
	st.teams[1] = team
	var tile: HexTileData = st.world.tiles[5 * 1000 + 5]
	tile.outpost_owner = 1
	tile.outpost_type = "civilian"
	tile.outpost_level = 2
	tile.manufacturing_level = 2
	team.resources["food"] = 1000000.0
	# ★受限那一跑：把【真正會被吃掉的那個輸入】壓低（工坊配方只吃 material/gem/horses/tools）
	team.resources["material"] = 2.0 if scarce else 1000000.0
	team.resources["horses"] = 1000000.0
	team.resources["tools"] = 1000000.0
	team.resources["gem"] = 1000000.0
	st.player_id = -1

	var ms := ManufacturingSystem.new()
	var runner := SimRunner.new()
	var cad: int = SimRunner.NEAR_CADENCE
	var ticks: int = days * WorldState.TICKS_PER_DAY

	# 逐窗分類：★在【呼叫 production 之前】先算一次同樣的判斷，才知道那一窗是哪種成因
	# ★★★第一版副本【漏了一種成因】，而對帳行當場把它抓出來（床側 719 可跑 vs production 486 noop）：
	#   `_run_recipe_group:230-233` 還有一道 per-recipe 停產閘：
	#     target = NeedOracle.need_keep + demand；`target <= 0 or stock >= target` ⇒ continue
	#   ⇒ ★所以 noop_no_material 混的不是兩種成因，是【三種】。
	var n_sated: int = 0        # ★需求已滿／無需求（stock >= target）——★★這其實是【健康行為】
	var n_rate0: int = 0        # worker_rate == 0（★與原料無關）
	var n_material: int = 0     # 真的原料不足
	var n_mixed: int = 0        # 同一窗內多種成因（不同 recipe）
	var n_would_run: int = 0    # 有 recipe 做得起
	# ★★★per-recipe 計數（★受限那一跑逼出來的）：gate 是【逐配方】判的，
	#   而按【窗】分類會把「同窗內有的滿了、有的缺料」全丟進「混合」⇒ 訊號被自己的桶吞掉。
	#   ⇒ 兩種粒度【都印】：窗看「這一窗有沒有產出」，配方看「到底卡在哪一關」。
	var r_sated: int = 0
	var r_rate0: int = 0
	var r_material: int = 0
	var r_ok: int = 0
	var windows: int = 0
	for _t in range(ticks):
		st.world.current_tick += 1
		if st.world.current_tick % cad != 0:
			continue
		windows += 1
		var saw_sated: bool = false
		var saw_rate0: bool = false
		var saw_mat: bool = false
		var saw_ok: bool = false
		var lv: Dictionary = TradeValuation.leader_vals(st, team)
		# ★★第二次對帳不符（487 vs 486，差 1）才補上的：production 的 tick_all 在算 worker_rate
		#   【之前】會先 LaborSystem.ensure_fresh(state, tile)，而我的副本沒有
		#   ⇒ 首窗勞力快取未建 ⇒ worker_rate 不同 ⇒ 一窗分類差一格。
		#   ★★★副本要對，就得【連呼叫順序都鏡射】，不只鏡射判斷式。
		LaborSystem.ensure_fresh(st, tile)
		for level_key in ManufacturingSystem.RECIPE_GROUPS:
			if int(tile.get(level_key)) <= 0:
				continue
			var wr: float = ManufacturingSystem.worker_rate_of(st, team, tile, level_key)
			for recipe in (ManufacturingSystem.RECIPE_GROUPS[level_key] as Array):
				# ★成因①：per-recipe 停產（需求已滿／無需求）—— 鏡射 _run_recipe_group:230-233
				var outr: String = String(recipe["out"])
				var stock: float = float(team.resources.get(outr, 0)) 					+ float(tile.public_storage.get(outr, 0))
				var target: float = NeedOracle.need_keep(st, team, outr, lv) 					+ NeedOracle.demand(st, team, outr, lv)
				if target <= 0.0 or stock >= target:
					saw_sated = true; r_sated += 1
					continue
				var q: float = wr * float(ManufacturingSystem.RATES[recipe["rate_const"]])
				if q <= 0.0:
					saw_rate0 = true; r_rate0 += 1
				elif not ms._can_consume_scaled(st, team, tile, recipe["in"], q):
					saw_mat = true; r_material += 1
				else:
					saw_ok = true; r_ok += 1
		if saw_ok:
			n_would_run += 1
		else:
			var kinds: int = int(saw_sated) + int(saw_rate0) + int(saw_mat)
			if kinds > 1:
				n_mixed += 1
			elif saw_sated:
				n_sated += 1
			elif saw_rate0:
				n_rate0 += 1
			elif saw_mat:
				n_material += 1
		# ★跑真的那一步（讓 production tap 累計，才能與上面的分類對帳）
		runner._step5b_manufacture(st, [1], cad)

	var noop_mat: int = int(Probe.counts.get("manufacture.noop_no_output", 0))
	var noop_fac: int = int(Probe.counts.get("manufacture.noop_no_facility", 0))
	var fired: int = int(Probe.counts.get("manufacture.fired", 0))

	var out: Array = []
	out.append("# manufacture.noop_no_material 的成因拆解（★只盤不修，production 0 行）")
	out.append("# 材料：%s｜天數 %d｜窗數 %d" % ["★受限(material=2)" if scarce else "充足(1e6)", days, windows])
	out.append("#")
	out.append("## 床側分類（★複製 gate 的判斷，呼叫同一批 production 函式）")
	out.append("★需求已滿／無需求（健康行為）|%d" % n_sated)
	out.append("worker_rate==0（與原料無關）|%d" % n_rate0)
	out.append("真的原料不足              |%d" % n_material)
	out.append("同窗兩種都有              |%d" % n_mixed)
	out.append("有 recipe 做得起          |%d" % n_would_run)
	out.append("#")
	out.append("## ★★per-recipe 計數（★gate 是逐配方判的，這才是「卡在哪一關」的真粒度）")
	var rtot: int = r_sated + r_rate0 + r_material + r_ok
	out.append("需求已滿／無需求|%d|%.1f%%" % [r_sated, 100.0 * float(r_sated) / maxf(float(rtot), 1.0)])
	out.append("worker_rate==0  |%d|%.1f%%" % [r_rate0, 100.0 * float(r_rate0) / maxf(float(rtot), 1.0)])
	out.append("★真的原料不足   |%d|%.1f%%" % [r_material, 100.0 * float(r_material) / maxf(float(rtot), 1.0)])
	out.append("做得起          |%d|%.1f%%" % [r_ok, 100.0 * float(r_ok) / maxf(float(rtot), 1.0)])
	out.append("配方判斷總次數  |%d" % rtot)
	out.append("#")
	out.append("## production 側 tap（★對帳用）")
	out.append("manufacture.noop_no_output|%d" % noop_mat)
	out.append("★production 側 skip 三桶（改名票落地後）｜sated %d｜rate0 %d｜no_material %d"
		% [int(Probe.counts.get("manufacture.skip.sated", 0)),
		   int(Probe.counts.get("manufacture.skip.rate0", 0)),
		   int(Probe.counts.get("manufacture.skip.no_material", 0))])
	out.append("manufacture.noop_no_facility|%d" % noop_fac)
	out.append("manufacture.fired           |%d" % fired)
	out.append("#")
	var blocked: int = n_sated + n_rate0 + n_material + n_mixed
	var recon: bool = blocked == noop_mat
	out.append("## ★對帳：床側「被擋窗數」%d vs production 的 noop_no_output %d ⇒ %s"
		% [blocked, noop_mat, "一致" if recon else "★不一致 —— 副本與 production 判斷不同，先修這個"])
	if blocked > 0:
		out.append("## ★★成因占比：需求已滿 %.1f%%｜worker_rate==0 %.1f%%｜原料不足 %.1f%%｜混合 %.1f%%"
			% [100.0 * float(n_sated) / float(blocked),
			   100.0 * float(n_rate0) / float(blocked),
			   100.0 * float(n_material) / float(blocked),
			   100.0 * float(n_mixed) / float(blocked)])
	out.append("# ★★★誠實限：本床的分類是【複製品】，不是 production 本身。")
	out.append("#   副本對不代表 production 對 ⇒ 所以上面那條對帳行是這份數字能不能用的前提。")
	for line in out:
		print(line)
	var path: String = OS.get_environment("NOOP_OUT") if OS.has_environment("NOOP_OUT") \
		else "docs/measurements/2026-09-01-manufacture-noop-cause.txt"
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f != null:
		f.store_string("\n".join(PackedStringArray(out)) + "\n"); f.close()
		print("落地：%s" % path)
	print("=== manufacture_noop_cause DONE ===")
