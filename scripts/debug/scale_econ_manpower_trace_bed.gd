extends SceneTree

# [measurer持久fixture 2026-08-11] 指標團(lord Team0)人手池(anon池) sharpened trace表——用戶reframe後版本。
# ticket:docs/superpowers/handbacks/2026-08-11-systems-to-measurer-manpower-trace-sharpened.md(supersede舊版)
# ★改答兩問(非『池空了沒』):①每筆drain歸類=deliberate領主dispatch(herald/scout/builder/distribute/migrant)
# vs automatic機械(overflow-spinoff,領主無得選)②盲派檢查:dispatch前有無讀available-anon(state-aware vs blind)。
# ★盲派檢查code-read結論(已坐實,寫入報告非本bed臨時tap):
#   herald _try_herald_side(faction_ai_system.gd:2031) AnonTierSystem.total_pop(team)<1→return(檔前檢查)
#   scout  dispatch_anon_messenger(subteam_system.gd:143) AnonTierSystem.total_pop(parent)<1→return -1
#   migrant dispatch_anon_migrants(subteam_system.gd:112) AnonTierSystem.total_pop(parent)<k→return -1
#   builder/convoy SubteamSystem.dispatch(subteam_system.gd:53-56) pop_count 受 parent.population 上界夾死
#     (population getter=team_data.gd:57 即時算入AnonTierSystem.total_pop,非stale副本)+transfer_proportional
#     (anon_tier_system.gd:177 actual=mini(count,total))永不超額轉移 → 結構上找不到blind-dispatch site。
# ★spinoff(automatic)機制:population_system.gd check_overflow_for_team(population>cap才觸發)_create_overflow_team
#   →非lord決策,世界機制。cap=faction_ai_system.gd._outpost_pop_cap(civilian L1=20)。
# ★格式=day|anon池|Δ|population|outpost_cap|type(deliberate/automatic)|blind_check(state-aware/n-a)|事件訊號
# ★中性呈現:只列數字+同期訊號相關性,不預設『池空=bug』,讓用戶自己判斷spinoff是否genuine。
# 純觀測:inline SimRunner、既有Probe tap(help.letter_dispatched/care.scout_dispatched/distribute.dispatch/
# migrant.dispatched/invest.dispatched)+state直讀(population/minor_population/新team_id出現/
# FactionAISystem._outpost_pop_cap既有public函式pure-read)、零temp production tap零RNG。

const DISP_CONFIG := "res://config/infonet_scale_econ_dispersed.json"
const SEED: int = 8181
const DAYS: int = 45
const LORD: int = 0

func _initialize() -> void:
	print("=== 指標團(Team%d)人手池 clean trace(seed=%d %d天) ===" % [LORD, SEED, DAYS])
	seed(SEED)
	FactionAISystem._a2b_remote_tribute_payers.clear()
	Probe.reset(); Probe.enabled = true
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config(DISP_CONFIG)
	config["seed"] = SEED
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	var ticks: int = WorldState.TICKS_PER_DAY * DAYS

	var fai := FactionAISystem.new()
	var prev_anon: int = -1
	var seen_tids: Dictionary = {}
	for tid in state.teams: seen_tids[tid] = true
	var prev_counts: Dictionary = {}
	var watch_keys: Array = ["help.letter_dispatched", "care.scout_dispatched", "distribute.dispatch",
		"migrant.dispatched", "invest.dispatched", "death.starve_anon", "death.defect_leave"]
	for k in watch_keys: prev_counts[k] = 0
	var prev_named: int = -1

	# ★§長跑必附specimen(用戶定2026-07-22 hook):本表下behavior-causal歸因(type/blind_check/guess)→QA故事稽核用。
	state.specimen_team_ids = [LORD]
	SpecimenTracer.reset(); SpecimenTracer.enabled = true

	var table: Array = []
	print("\ntick(day) | anon池 | Δ | pop | minor_pop | outpost_cap | 新增team_id(spinoff) | 同期dispatch事件 | type | blind_check | 原因")
	print("----------|--------|---|-----|-----------|-------------|----------------------|------------------|------|-------------|------")

	# ★涵蓋要求(ticket):開局~day10逐tick(細粒度不漏事件)、day10後只在整日邊界抽樣(粗)。
	const FINE_WINDOW_TICKS: int = WorldState.TICKS_PER_DAY * 10
	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		var ct: int = state.world.current_tick
		var is_checkpoint: bool = (ct <= FINE_WINDOW_TICKS) or (ct % WorldState.TICKS_PER_DAY == 0)
		if is_checkpoint:
			var day: int = ct / WorldState.TICKS_PER_DAY
			var label: String = "t%d(d%d)" % [ct, day]
			var new_today: Array = []
			for tid in state.teams:
				if not seen_tids.has(tid):
					seen_tids[tid] = true
					new_today.append(tid)
			var dispatch_today: Dictionary = {}
			for k in watch_keys:
				var cur: int = int(Probe.counts.get(k, 0))
				var d: int = cur - int(prev_counts[k])
				if d > 0: dispatch_today[k] = d
				prev_counts[k] = cur

			if not state.teams.has(LORD):
				var row: Dictionary = {"tick": ct, "day": day, "anon": -99, "delta": null, "pop": -99, "minor_pop": -99,
					"cap": -99, "new_teams": new_today, "dispatch": dispatch_today, "guess": "lord隊已不存在(gone/merged)"}
				table.append(row)
				if not new_today.is_empty() or not dispatch_today.is_empty():
					print("%s | %6s | %s | %3s | %9s | %11s | %s | %s | %s" % [
						label, "-", "-", "-", "-", "-", str(new_today), str(dispatch_today), row["guess"]])
				continue

			var t: TeamData = state.teams[LORD]
			var anon: int = AnonTierSystem.total_pop(t)
			var delta: int = anon - prev_anon if prev_anon != -1 else 0
			var cap: int = fai._outpost_pop_cap(state, t.tile_pos)
			var named_now: int = (1 if t.leader_id != -1 else 0) + t.named_members.size()
			var named_delta: int = named_now - prev_named if prev_named != -1 else 0
			prev_named = named_now

			var guess: String = "無變化"
			var evt_type: String = "n/a"
			var blind_check: String = "n/a"
			if delta != 0:
				var reasons: Array = []
				var deliberate_hit: bool = false
				if dispatch_today.has("help.letter_dispatched"):
					reasons.append("求援信使派出(herald)"); deliberate_hit = true
				if dispatch_today.has("care.scout_dispatched"):
					reasons.append("care-loop scout派出"); deliberate_hit = true
				if dispatch_today.has("distribute.dispatch"):
					reasons.append("distribute convoy派出"); deliberate_hit = true
				if dispatch_today.has("migrant.dispatched"):
					reasons.append("migrant移民隊派出"); deliberate_hit = true
				if dispatch_today.has("invest.dispatched"):
					reasons.append("invest convoy派出"); deliberate_hit = true
				if dispatch_today.has("death.starve_anon"):
					reasons.append("★餓死(famine,death.starve_anon×%d,resource_system.gd:230)" % dispatch_today["death.starve_anon"])
					evt_type = "automatic(世界機制,非領主決策)"; blind_check = "n/a(死亡非dispatch判準不適用)"
				if dispatch_today.has("death.defect_leave"):
					reasons.append("領主本人N3_defect反應致1 anon出走(reaction_system.gd:281,個體NPC自主reaction非領主指令)")
					evt_type = "automatic(NPC個體reaction,非領主dispatch決策)"; blind_check = "n/a(非dispatch判準不適用)"
				if named_delta > 0 and delta < 0 and reasons.is_empty():
					reasons.append("疑anon→named晉升(named+%d同日,person_generator.gd:103,非死亡非派出)" % named_delta)
					evt_type = "automatic(世界機制,advisor拔擢非直接領主人力決策)"; blind_check = "n/a"
				# ★spinoff歸屬:_create_overflow_team無parent連結(population_system.gd:55-72無set_subteam_parent),
				#   唯一可靠線索=tile_pos共址(overflow team.tile_pos=origin.tile_pos)。global new_today可能是別隊(1/2/3)
				#   同日分村的巧合,故只有tile_pos match才歸因team0自己的spinoff,避免誤判。
				var own_spinoff: Array = []
				for ntid in new_today:
					if state.teams.has(ntid) and state.teams[ntid].tile_pos == t.tile_pos:
						own_spinoff.append(ntid)
				if not own_spinoff.is_empty():
					var over: bool = t.population > cap
					# ★觸發時機誠實註記:check_overflow_for_team正規走日邊界(population_system.gd sim_runner.gd:231
					# tick%TICKS_PER_DAY==0)、但event_system.gd:55(Succession named-successor分支)可離峰直呼
					# check_overflow_for_team——非整日邊界tick出現的spinoff=走後者、population<=cap不代表矛盾。
					var on_day_boundary: bool = (ct % WorldState.TICKS_PER_DAY == 0)
					reasons.append("population-overflow分村(Team%s 與Team0同tile_pos,population%d %s cap%d,%s)" % [
						str(own_spinoff), t.population, (">" if over else "<="), cap,
						("日邊界檢查tick" if on_day_boundary else "★離峰tick(非日邊界)→較可能走event_system.gd:55 Succession連鎖呼叫,非routine日檢,待QA specimen核")])
					if not deliberate_hit:
						evt_type = "automatic(世界機制,領主無得選)"
						blind_check = "n/a(非領主決策,不適用盲派判準)"
					for ntid in own_spinoff:
						if not int(ntid) in state.specimen_team_ids: state.specimen_team_ids.append(int(ntid))
				elif not new_today.is_empty():
					reasons.append("(同日別隊Team%s分村,tile_pos不同非Team0自己的spinoff,巧合排除)" % str(new_today))
				if deliberate_hit:
					evt_type = "deliberate(領主dispatch決策)"
					blind_check = "state-aware(code-confirmed:dispatch函式檔前檢查AnonTierSystem.total_pop才發,見檔頭註)"
				if delta > 0 and reasons.is_empty():
					reasons.append("疑生育回補/merge併回(無對應dispatch訊號,需進一步確認)")
				if delta < 0 and reasons.is_empty():
					reasons.append("原因不明(無對應已知訊號,需進一步確認)")
				guess = " + ".join(reasons) if not reasons.is_empty() else "原因不明"

			table.append({"tick": ct, "day": day, "anon": anon, "delta": delta, "pop": t.population,
				"minor_pop": t.minor_population, "cap": cap, "new_teams": new_today,
				"dispatch": dispatch_today, "type": evt_type, "blind_check": blind_check, "guess": guess})
			if delta != 0 or not new_today.is_empty() or not dispatch_today.is_empty():
				print("%s | %6d | %+3d | %3d | %9d | %11d | %s | %s | %s | %s | %s" % [
					label, anon, delta, t.population, t.minor_population, cap, str(new_today), str(dispatch_today),
					evt_type, blind_check, guess])
			prev_anon = anon

	SpecimenTracer.flush()
	var spec_path: String = "docs/measurements/2026-08-11-scale-econ-manpower-trace-sharpened-seed%d.specimen.jsonl" % SEED
	SpecimenDumpHelper.dump(state, spec_path)
	SpecimenTracer.reset()
	Probe.enabled = false

	var dump: Dictionary = {"seed": SEED, "days": DAYS, "lord": LORD, "table": table}
	var f := FileAccess.open("res://docs/measurements/2026-08-11-scale-econ-manpower-trace-sharpened-seed%d.json" % SEED, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(dump, "  ")); f.close()
		print("\n[dump] → res://docs/measurements/2026-08-11-scale-econ-manpower-trace-sharpened-seed%d.json" % SEED)
	print("=== DONE ===")
	quit()
