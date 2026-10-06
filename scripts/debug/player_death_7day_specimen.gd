extends SceneTree
# ★量測員派工（systems 2026-10-06，藍圖裁）：
# 第一輪：docs/superpowers/handbacks/2026-10-06-systems-to-measurer-specimen-after-player-death.md
# 第二輪（開 Probe 重產）：docs/superpowers/handbacks/2026-10-06-systems-to-measurer-respecimen-probe-on-for-plunder.md
#
# 目的：產「玩家死後 7 天」specimen 給 QA 讀 motive→action→outcome（故事稽核）。
# 第二輪新增：補領袖票接上「掠奪」決策 tap（raid.composition，Probe-gated）⇒ 開 Probe 才讀得到。
#
# ★★先驗「觀測不改被觀測物」（同 seed 1337、同樹，跑三輪）：
#   PASS A：Probe=false｜SpecimenTracer=false（對照組）
#   PASS B：Probe=true ｜SpecimenTracer=false（只切 Probe 這一個變因）
#   → 比 A/B 的【決策序列 hash】與【世界 fp】：逐位元組相同才算「觀測沒有改世界」
#   PASS C（只有 A==B 才跑）：Probe=true｜SpecimenTracer=true（★正式產 specimen 的那輪）
#   → 額外跟 A 對一次 fp（SpecimenTracer 的中性 2026-07-28 已鎖regression，這裡只是順手複查)
#
# 佈置（照 systems 信裡指定，不發明）：
#   ·seed=1337｜先推 3 天暖身，再照 story_end_not_physics_bed.gd:67-73 殺玩家
#   ·母體地板：殺完斷言 state.game_over == true 才往下推
#   ·再推 N=7 天｜specimen=原玩家隊 ＋ 3 支最近鄰 NPC 隊（tile_pos 距離，確定性選取零 RNG）
#
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/player_death_7day_specimen.gd

const SEED: int = 1337
const WARMUP_DAYS: int = 3
const POST_DEATH_DAYS: int = 7
const NEARBY_TEAM_COUNT: int = 3


func _initialize() -> void:
	var tree_sha: String = _git_head_sha()
	print("[TREE] HEAD=%s" % tree_sha)
	print("[SEED] %d" % SEED)

	print("\n########## PASS A（Probe=OFF, SpecimenTracer=OFF，對照組）##########")
	var a: Dictionary = _run_pass(false, false)

	print("\n########## PASS B（Probe=ON , SpecimenTracer=OFF，只切 Probe）##########")
	var b: Dictionary = _run_pass(true, false)

	print("\n========== ②比較：Probe 開/關 是否改世界 ==========")
	var decision_n_match: bool = int(a["decision_n"]) == int(b["decision_n"])
	var decision_hash_match: bool = String(a["decision_hash"]) == String(b["decision_hash"])
	var fp_match: bool = String(a["world_fp"]) == String(b["world_fp"])
	print("[COMPARE] 決策序列筆數：A=%d｜B=%d｜一致=%s" % [int(a["decision_n"]), int(b["decision_n"]), str(decision_n_match)])
	print("[COMPARE] 決策序列 hash：A=%s" % String(a["decision_hash"]))
	print("[COMPARE]              B=%s｜一致=%s" % [String(b["decision_hash"]), str(decision_hash_match)])
	print("[COMPARE] 世界 fp(sha256)：A=%s" % String(a["world_fp"]))
	print("[COMPARE]                B=%s｜一致=%s" % [String(b["world_fp"]), str(fp_match)])

	var all_match: bool = decision_n_match and decision_hash_match and fp_match
	if not all_match:
		print("\n[HALT] ★★★Probe 開/關 兩輪不是逐位元組相同 ⇒ 開 Probe 改了世界（耗了 RNG 或別的副作用）。")
		print("[HALT] 停：不產正式 specimen（那會是讀到另一個世界），回報 systems 等裁。")
		quit(1)
		return

	print("[COMPARE] ★★★逐位元組相同 ⇒ 觀測沒有改被觀測物，Probe 開著重產 specimen 安全。")

	print("\n########## PASS C（Probe=ON, SpecimenTracer=ON，正式產 specimen）##########")
	var c: Dictionary = _run_pass(true, true)
	var bonus_fp_match: bool = String(c["world_fp"]) == String(a["world_fp"])
	print("[COMPARE] ★附加複查：PASS C（也開 SpecimenTracer）世界 fp 是否仍 == PASS A：%s" \
		% str(bonus_fp_match))
	if not bonus_fp_match:
		print("[WARN] PASS C 的 fp 跟 A 不同 ⇒ SpecimenTracer 疑似也動了這次的世界（它本身的中性已有舊 regression 鎖，\
這裡是本輪的複查，不是初次證明）——寫進交件，別默默吞掉。")

	# ── 印 raid.composition 桶：四欄是否「真的出現」（只驗程式碼有加不算）────────────
	print("\n========== ③raid.composition（Probe-gated，掠奪 tap）==========")
	var raid_samples: Array = Probe.samples.get("raid.composition", [])
	print("[raid.composition] 母體：桶內 %d 筆（cap=150）" % raid_samples.size())
	if raid_samples.is_empty():
		print("[raid.composition] ★★★空桶 ⇒ 四欄沒有真的出現，tap 沒接電（或這 10 天內沒有任何隊評估過「掠奪」）")
	else:
		print("[raid.composition] ★誠實限：這個桶的 _cmp dict 沒有 team_id／tick 欄位（production 現狀，\
非本床能加——那是 scripts/simulation/decision/decision_engine.gd，不是我的檔）⇒ 下面印的是【桶裡的樣本】，\
不能逐筆對應「哪支隊哪個 tick」。要對應哪支隊選了掠奪，見下面★我自己追蹤的決策序列（Team11 專列）。")
		var show_n: int = mini(8, raid_samples.size())
		for i in range(show_n):
			var row: Dictionary = raid_samples[i]
			print("  [raid.composition #%d] opt=%s｜原始util(drive)=%s｜需求層加權後(after_weight)=%s｜\
人格調製後(after_coeff)=%s｜最終合成(final)=%s" % [
				i, String(row.get("opt", "?")),
				str(row.get("drive", "?")), str(row.get("after_weight", "?")),
				str(row.get("after_coeff", "?")), str(row.get("final", "?"))])

	# ── Team11 自己的「選了掠奪」tick 清單（走我自己追蹤的決策序列，零碰 production）────
	print("\n[Team11-decision] 全程（10 天）current_option==\"掠奪\" 的 tick：")
	var t11_raid_ticks: Array = c["per_team_option_log"].get(11, [])
	var t11_raid_hits: Array = []
	for row2 in t11_raid_ticks:
		if String(row2[1]) == "掠奪":
			t11_raid_hits.append(int(row2[0]))
	print("  共 %d 次：%s" % [t11_raid_hits.size(), str(t11_raid_hits)])

	# ── Team15 leader_id / population 時間序列（死前一天到第 7 天）────────────────────
	print("\n========== 附加題：Team15（原玩家隊）leader_id／population 時間序列 ==========")
	print("[Team15-timeline] day｜leader_id｜population（day = 整場第幾天，0-indexed；殺玩家發生在 day %d 開頭）" \
		% WARMUP_DAYS)
	for row3 in c["team15_daily"]:
		print("  day=%2d｜tick=%6d｜leader_id=%4d｜population=%3d" \
			% [int(row3["day"]), int(row3["tick"]), int(row3["leader_id"]), int(row3["population"])])

	print("\n[MECH-ANOMALIES]")
	if c["mech_anomalies"].is_empty():
		print("  無")
	else:
		for anomaly in c["mech_anomalies"]:
			print("  - " + String(anomaly))

	print("\n[DUMP-PATH] %s" % String(c["dump_path"]))
	print("=== player_death_7day_specimen DONE（PASS A/B/C 全跑完）===")
	quit(0)


func _git_head_sha() -> String:
	var out: Array = []
	OS.execute("git", ["rev-parse", "--short=9", "HEAD"], out, true)
	if out.size() > 0:
		return String(out[0]).strip_edges()
	return "UNKNOWN"


# ══ 一輪完整跑法：seed→setup→Probe on/off→暖身→殺玩家→推 7 天→（可選）dump ══════════
func _run_pass(probe_on: bool, want_specimen: bool) -> Dictionary:
	var mech_anomalies: Array = []
	seed(SEED)
	var ws := WorldState.new()
	GameSetup.setup(ws, GameSetup.load_config("res://config/default.json"))
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)

	if probe_on:
		Probe.arm()   # reset()+enabled=true（純觀測，counts/samples 清零；不改世界）
	else:
		Probe.enabled = false
		Probe.reset()

	var hasher := HashingContext.new()
	hasher.start(HashingContext.HASH_SHA256)
	var decision_n: int = 0
	var per_team_option_log: Dictionary = {}   # team_id → Array[[tick, opt]]（全程，給 Team11 專列用）
	var team15_daily: Array = []
	var day_len: int = WorldState.TICKS_PER_DAY

	# ── 暖身 WARMUP_DAYS 天（逐天跑，日界記 decision hash + Team15 timeline）───────────
	for day in range(WARMUP_DAYS):
		for _i in range(day_len):
			runner.advance_tick(ws, no_player)
			_feed_hasher_and_log(ws, hasher, per_team_option_log)
			decision_n += 1
		_record_team15_day(ws, day, team15_daily)

	# ── 選 specimen 隊：原玩家隊 ＋ 最近鄰 NPC 隊（確定性，距離排序）────────────────────
	var player_tid: int = ws.get_player_team_id()
	if player_tid == -1 or not ws.teams.has(player_tid):
		mech_anomalies.append("★致命：暖身 %d 天後找不到玩家隊（player_tid=%d）⇒ 無法往下殺玩家" % [WARMUP_DAYS, player_tid])
		return _finish_pass(ws, hasher, mech_anomalies, want_specimen, per_team_option_log, team15_daily, "NO-PLAYER-TEAM")

	var player_team: TeamData = ws.teams[player_tid]
	var player_pos: Vector2i = player_team.tile_pos
	var others: Array = []
	for tid in ws.teams.keys():
		if int(tid) == player_tid:
			continue
		var t: TeamData = ws.teams[tid]
		var d: float = Vector2(t.tile_pos - player_pos).length()
		others.append({"tid": int(tid), "dist": d})
	others.sort_custom(func(x, y):
		if x["dist"] != y["dist"]:
			return x["dist"] < y["dist"]
		return x["tid"] < y["tid"])

	var nearby_ids: Array[int] = []
	for i in range(min(NEARBY_TEAM_COUNT, others.size())):
		nearby_ids.append(int(others[i]["tid"]))

	var specimen_ids: Array[int] = [player_tid]
	for nid in nearby_ids:
		specimen_ids.append(nid)

	if want_specimen:
		ws.specimen_team_ids = specimen_ids
		SpecimenTracer.reset()
		SpecimenTracer.enabled = true
		print("[SpecimenTracer] enabled=true｜specimen_team_ids=%s" % str(ws.specimen_team_ids))
	print("[SPECIMEN-TEAMS] player=%d｜鄰近=%s" % [player_tid, str(nearby_ids)])

	# ── 殺玩家：逐字照 story_end_not_physics_bed.gd:67-73（真的寫入者）────────────────
	var pid: int = ws.player_id
	for m in player_team.named_members.duplicate():
		ws.remove_member(player_team, int(m), false)
		if int(m) == pid:
			ws.persons.erase(pid)
	EventSystem.new().handle_player_succession(ws, player_team)
	print("[KILL] game_over=%s｜原因「%s」" % [str(ws.game_over), ws.game_over_reason])

	if not ws.game_over:
		mech_anomalies.append("★★母體地板沒過：殺完 game_over 仍是 false（原因「%s」）⇒ 下面 7 天推的是一個沒死的世界" % ws.game_over_reason)
		return _finish_pass(ws, hasher, mech_anomalies, want_specimen, per_team_option_log, team15_daily, "GAME-OVER-NOT-SET", specimen_ids)

	# ── snapshot（殺玩家後，推 7 天前）──────────────────────────────────────────────
	var before_snap: Dictionary = _snapshot_teams(ws, specimen_ids)
	var tick_before: int = ws.world.current_tick

	# ── 推 POST_DEATH_DAYS 天 ───────────────────────────────────────────────────────
	for day2 in range(POST_DEATH_DAYS):
		for _i2 in range(day_len):
			runner.advance_tick(ws, no_player)
			_feed_hasher_and_log(ws, hasher, per_team_option_log)
			decision_n += 1
		_record_team15_day(ws, WARMUP_DAYS + day2, team15_daily)
	var tick_after: int = ws.world.current_tick
	var actual_advance: int = tick_after - tick_before
	var expect_advance: int = WorldState.TICKS_PER_DAY * POST_DEATH_DAYS

	if actual_advance != expect_advance:
		mech_anomalies.append("★★tick 沒有如期前進：要求推 %d 次，current_tick 只 +%d ⇒ 世界可能卡住/提早停" \
			% [expect_advance, actual_advance])

	var after_snap: Dictionary = _snapshot_teams(ws, specimen_ids)
	for tid2 in specimen_ids:
		if not ws.teams.has(tid2):
			continue
		var bb = before_snap.get(tid2, null)
		var aa = after_snap.get(tid2, null)
		if bb == null or aa == null:
			continue
		if _dict_equal(bb, aa) and int(aa.get("population", 0)) > 0:
			mech_anomalies.append("★隊 %d：population>0 但 7 天內逐欄零變化 ⇒ 疑似凍結" % tid2)

	print("[POST-DEATH] current_tick %d → %d（實際 +%d）" % [tick_before, tick_after, actual_advance])
	return _finish_pass(ws, hasher, mech_anomalies, want_specimen, per_team_option_log, team15_daily, "OK", specimen_ids, decision_n)


func _finish_pass(ws: WorldState, hasher: HashingContext, mech_anomalies: Array,
		want_specimen: bool, per_team_option_log: Dictionary, team15_daily: Array,
		status: String, specimen_ids: Array = [], decision_n: int = 0) -> Dictionary:
	var fp: String = _world_fp(ws)
	var digest: PackedByteArray = hasher.finish()
	var dump_path: String = ""
	if want_specimen:
		dump_path = "docs/measurements/player-death-7day.specimen.jsonl"
		SpecimenTracer.flush()
		SpecimenDumpHelper.dump(ws, dump_path)
	if Probe.enabled:
		Probe.flush_all_streaks()
	return {
		"status": status,
		"world_fp": fp,
		"decision_hash": digest.hex_encode(),
		"decision_n": decision_n,
		"mech_anomalies": mech_anomalies,
		"dump_path": dump_path,
		"per_team_option_log": per_team_option_log,
		"team15_daily": team15_daily,
		"specimen_ids": specimen_ids,
	}


# ── 每 tick：餵決策序列 hash（純讀 current_option，零 RNG）＋ 記每隊 option log ──────
func _feed_hasher_and_log(ws: WorldState, hasher: HashingContext, per_team_option_log: Dictionary) -> void:
	var ids: Array = ws.teams.keys()
	ids.sort()
	var parts: Array = []
	for tid in ids:
		var t: TeamData = ws.teams[tid]
		parts.append("%d:%s" % [int(tid), t.current_option])
		if int(tid) == 11:   # ★只給 Team11 存全程 log（其餘隊只進 hash，不逐筆存，免記憶體爆）
			var arr: Array = per_team_option_log.get(11, [])
			arr.append([ws.world.current_tick, t.current_option])
			per_team_option_log[11] = arr
	var row_str: String = "|".join(parts)
	hasher.update(row_str.to_utf8_buffer())


func _record_team15_day(ws: WorldState, day: int, team15_daily: Array) -> void:
	var leader_id: int = -1
	var pop: int = 0
	if ws.teams.has(15):
		var t: TeamData = ws.teams[15]
		leader_id = t.leader_id
		pop = t.population
	team15_daily.append({"day": day, "tick": ws.world.current_tick, "leader_id": leader_id, "population": pop})


# ── 世界簽章（除 Probe/SpecimenTracer 的純觀測輸出外，世界狀態 byte-identical 判準）───
func _world_fp(ws: WorldState) -> String:
	var ids: Array = ws.teams.keys()
	ids.sort()
	var arr: Array = []
	for tid in ids:
		var t: TeamData = ws.teams[tid]
		arr.append([tid, t.leader_id, t.tile_pos.x, t.tile_pos.y, t.population,
			t.current_task, t.current_option, t.task_priority,
			snappedf(float(t.resources.get("food", 0)), 0.01),
			snappedf(float(t.resources.get("coin", 0)), 0.01),
			snappedf(float(t.resources.get("material", 0)), 0.01)])
	arr.append(["__world__", ws.world.current_tick, ws.game_over, ws.game_over_reason])
	return JSON.stringify(arr).sha256_text()


func _snapshot_teams(ws: WorldState, ids: Array) -> Dictionary:
	var out: Dictionary = {}
	for tid in ids:
		if not ws.teams.has(tid):
			continue
		var t: TeamData = ws.teams[tid]
		out[int(tid)] = {
			"population": t.population,
			"tile_pos": t.tile_pos,
			"current_task": t.current_task,
			"food": t.resources.get("food", 0.0),
			"coin": t.resources.get("coin", 0),
			"material": t.resources.get("material", 0),
		}
	return out


func _dict_equal(a: Dictionary, b: Dictionary) -> bool:
	for k in a.keys():
		if not b.has(k):
			return false
		if a[k] != b[k]:
			return false
	return true
