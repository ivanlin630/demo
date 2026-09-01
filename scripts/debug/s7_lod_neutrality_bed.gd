extends SceneTree

# ★★★S7 LOD產出中性性驗證床(measurer側,純觀測,零production改動)。
#   同一座工坊、同一組人、同一份配方——一組near一組far，比每日【真實產出量】
#   (manufacture.output.<res>，不是runs_per_day()估算函式)。
#
# 用法：LOD_MODE=near|far BED_DAYS=30 godot --script scripts/debug/s7_lod_neutrality_bed.gd
#   near: player_pos=團隊位置(距離0，落在LOD_NEAR_RADIUS內)
#   far:  player_pos=極遠處(超過LOD_NEAR_RADIUS)

func _mk() -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 0
	for x in range(0, 12):
		for y in range(0, 12):
			var tl := HexTileData.new(); tl.tile_pos = Vector2i(x, y); tl.terrain = "plains"
			state.world.tiles[x * 1000 + y] = tl
	var team := TeamData.new()
	team.team_id = 1
	team.tile_pos = Vector2i(5, 5)
	team.faction_id = -1
	team.tags = ["生產"]
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", 10)
	var l := PersonData.new()
	l.id = 10
	l.team_id = 1
	l.values = {"好戰": 0.3, "貪婪": 0.3, "慎重": 0.5, "野心": 0.3, "義氣": 0.5}
	l.skills = {"生產": 0.5, "統領": 0.5}
	state.persons[10] = l
	team.leader_id = 10
	state.teams[1] = team
	var tile: HexTileData = state.world.tiles[5 * 1000 + 5]
	tile.outpost_owner = 1
	tile.outpost_type = "civilian"
	tile.outpost_level = 2
	tile.manufacturing_level = 2   # ★工坊(workshop)直接手動已建成，繞開organic build-up的世界軌跡差異
	# ★材料塞爆量：確保material/food永遠不是瓶頸——這輪要測的是LOD頻率不是料夠不夠
	#   ★血證：第一版忘了塞food，團隊活活餓死+spawn子隊also餓死，30日窗中途崩潰，數字不可信
	# ★BED_SCARCE=1：本想造【材料受限】情境（驗收③）——★★而它【沒有成功】，實測記在這裡：
	#   工坊(manufacturing_level)全部配方的輸入只有 material / gem / horses / tools，
	#   四種都塞到 1e6，而 manufacture.noop_no_material 仍然 486/720 窗。
	#   ⇒ ★★★這個 fixture 的 binding constraint【不是原料】，是 need-gating / 勞力
	#     （worker_rate == 0 時 _run_recipe_group 也回 ""）。
	#   ⇒ ★而那也表示 tap 名字說謊：`manufacture.noop_no_material` 同時在數
	#     「原料不足」與「worker_rate==0」兩種完全不同的事。
	#   ⇒ ★★所以 material=30 這一跑產出幾乎不變（22.0303 vs 22.0305）—— 它證明的是
	#     「material 不是瓶頸」，不是「受限下仍有部分產出」。★★★驗收③因此只有【弱證據】。
	var scarce: bool = OS.has_environment("BED_SCARCE") and OS.get_environment("BED_SCARCE") == "1"
	team.resources["food"] = 1000000.0
	team.resources["material"] = 30.0 if scarce else 1000000.0
	team.resources["horses"] = 1000000.0
	team.resources["tools"] = 1000000.0
	team.resources["gem"] = 1000000.0
	return [state, team]

func _initialize() -> void:
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 30
	var mode: String = OS.get_environment("LOD_MODE") if OS.has_environment("LOD_MODE") else "near"
	seed(1337)
	Probe.reset()
	Probe.enabled = true
	var w: Array = _mk()
	var state: WorldState = w[0]
	var team: TeamData = w[1]
	var player_pos: Vector2i = team.tile_pos if mode == "near" else Vector2i(team.tile_pos.x + 100, team.tile_pos.y + 100)
	var runner := SimRunner.new()
	var ticks: int = days * WorldState.TICKS_PER_DAY
	# ★★★兩種跑法，因為它們回答【不同的問題】——上一輪把兩者混成一個數字才會讀不出來：
	#   isolated：只驅動 manufacture 這一步，母體凍住 ⇒ 答「補償算對了嗎」
	#   world   ：整個 advance_tick ⇒ 答「世界跑起來如何」，★但帶 confound（pop/隊數會分岔）
	#   ★★raw 比值在 world 模式【不可讀】：本輪 near 收在 pop=1、far 收在 pop=8。
	var isolated: bool = OS.has_environment("BED_ISOLATED") and OS.get_environment("BED_ISOLATED") == "1"
	if isolated:
		var cad: int = SimRunner.NEAR_CADENCE if mode == "near" else SimRunner.FAR_ZONE_INTERVAL
		for _t in range(ticks):
			state.world.current_tick += 1
			if state.world.current_tick % cad == 0:
				runner._step5b_manufacture(state, [1], cad)
	else:
		for _t in range(ticks):
			runner.advance_tick(state, player_pos)

	print("=== s7_lod_neutrality_bed === mode=%s days=%d ticks=%d player_pos=%s team_pos=%s"
		% [mode, days, ticks, str(player_pos), str(team.tile_pos)])
	var _scarce: bool = OS.has_environment("BED_SCARCE") and OS.get_environment("BED_SCARCE") == "1"
	print("材料：%s" % ("★受限(material=30)" if _scarce else "充足(1e6)"))
	print("跑法：%s" % ("isolated（只驅動 manufacture，母體凍住）" if isolated else "world（整個 advance_tick，★帶 confound）"))
	# ★★★母體雙軌（spec 判準⑧）：raw 總量會被【隊數/人口】的 confound 汙染，
	#   而上一輪就是這樣（near 1 隊 / far 9 隊）⇒ ★不得靜默：兩軌都印，讓讀的人自己看得到。
	var n_teams: int = state.teams.size()
	var tot_pop: int = 0
	for _tid in state.teams:
		tot_pop += int((state.teams[_tid] as TeamData).population)
	print("母體：team1_pop=%d｜世界隊數=%d｜世界總人口=%d｜manufacturing_level=%d｜material剩餘=%.1f"
		% [team.population, n_teams, tot_pop,
		   (state.world.tiles[5 * 1000 + 5] as HexTileData).manufacturing_level,
		   float(team.resources.get("material", 0))])
	print("★★raw 與 per-team/per-pop 三軌並報 —— ★raw 單獨一個數字【不可比】")
	print("── manufacture.output.* 原始總量+每日 ──")
	var any_output: bool = false
	for k in Probe.amounts:
		var ks: String = String(k)
		if ks.begins_with("manufacture.output."):
			any_output = true
			var total: float = float(Probe.amounts[k])
			print("  %-30s 總量=%.4f  每日(raw)=%.6f  每日每隊=%.6f  每日每人=%.6f"
				% [ks, total, total / float(days),
				   total / float(days) / maxf(float(n_teams), 1.0),
				   total / float(days) / maxf(float(tot_pop), 1.0)])
	if not any_output:
		print("  ★沒有任何manufacture.output.*——這件事本輪從未發生(Probe是ON)")
	print("── 輔助診斷(manufacture三桶，看是no_facility/no_material/fired哪一種) ──")
	for name in ["fired", "noop_no_outpost", "noop_no_worker", "noop_no_facility", "noop_no_material"]:
		var total2: int = int(Probe.counts.get("manufacture." + name, 0))
		print("  %-20s 總數=%d" % [name, total2])
	# ★★★驗收③：材料受限時必須出現【部分產出】0 < q < N
	#   ★失敗長相＝只有 {0, N} 雙峰 ⇒ 門檻被抬高了（倍率式會這樣），材料緊時整個停產。
	#   ★★本床材料塞爆 ⇒ 這裡量不到「受限」——所以這一欄只印【現況分佈】，
	#     真正的受限情境由 BED_SCARCE=1 那一跑量（見下）。
	print("── 驗收③ 部分產出分佈（batch 內實際跑了幾窗）──")
	var partial_n: int = int(Probe.counts.get("manufacture.batch_partial", 0))
	var full_n: int    = int(Probe.counts.get("manufacture.batch_full", 0))
	var zero_n: int    = int(Probe.counts.get("manufacture.batch_zero", 0))
	print("  0<q<N（部分）=%d｜q==N（全滿）=%d｜q==0（全空）=%d" % [partial_n, full_n, zero_n])
	if partial_n == 0 and (full_n + zero_n) > 0:
		print("  ★注意：只有 {0, N} 雙峰、沒有部分產出 —— 材料充足時這是正常的，")
		print("        ★★但在【材料受限】那一跑若仍如此，就是門檻被抬高了。")
	print("── 假設告警（registry 前提壞掉時該叫）──")
	print("  manufacture.cadence_assumption_stale = %d"
		% int(Probe.counts.get("manufacture.cadence_assumption_stale", 0)))
	print("=== s7_lod_neutrality_bed DONE ===")
	quit()
