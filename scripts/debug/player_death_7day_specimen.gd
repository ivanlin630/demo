extends SceneTree
# ★量測員派工（systems 2026-10-06，藍圖裁）：
# docs/superpowers/handbacks/2026-10-06-systems-to-measurer-specimen-after-player-death.md
#
# 目的：產「玩家死後 7 天」specimen 給 QA 讀 motive→action→outcome（故事稽核，非機械判決）。
# 背景：故事結束票 #2（merge d415a5791）拿掉 sim_runner.gd 的 early return ⇒ 玩家絕後後世界照跑，
#   這一輪只驗過機械性質（tick 推進/旗標/fp 床結構），沒人讀過那段故事。
#
# 佈置（照 systems 信裡指定，不發明）：
#   ·seed=1337（固定，方便事後對帳；SpecimenDumpHelper 本身不需 seed，本床自選有 seed）
#   ·世界：GameSetup 正常建，先推 3 天讓母體有一點歷史，再殺玩家
#   ·殺法：照 scripts/debug/story_end_not_physics_bed.gd:67-73 那條（真的寫入者）
#     remove_member 清 named_members ＋ persons.erase(player_id) ＋ EventSystem.handle_player_succession
#   ·母體地板：殺完斷言 state.game_over == true 才往下推
#   ·再推 N=7 天（TICKS_PER_DAY*7）
#   ·specimen：原玩家隊 ＋ 3 支最近鄰 NPC 隊（tile_pos 歐氏距離，確定性選取，零 RNG）
#
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/player_death_7day_specimen.gd

const SEED: int = 1337
const WARMUP_DAYS: int = 3
const POST_DEATH_DAYS: int = 7
const NEARBY_TEAM_COUNT: int = 3

var _mech_anomalies: Array = []


func _initialize() -> void:
	var tree_sha: String = _git_head_sha()
	print("[TREE] HEAD=%s" % tree_sha)
	print("[SEED] %d" % SEED)
	_run()
	quit()


func _git_head_sha() -> String:
	var out: Array = []
	OS.execute("git", ["rev-parse", "--short=9", "HEAD"], out, true)
	if out.size() > 0:
		return String(out[0]).strip_edges()
	return "UNKNOWN"


func _run() -> void:
	seed(SEED)
	var ws := WorldState.new()
	GameSetup.setup(ws, GameSetup.load_config("res://config/default.json"))
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)

	# ── 暖身：先推 WARMUP_DAYS 天讓母體有歷史 ──────────────────────────────
	var warmup_ticks: int = WorldState.TICKS_PER_DAY * WARMUP_DAYS
	print("[WARMUP] 推 %d ticks（%d 天）..." % [warmup_ticks, WARMUP_DAYS])
	for _i in range(warmup_ticks):
		runner.advance_tick(ws, no_player)
	print("[WARMUP] done｜current_tick=%d｜teams=%d" % [ws.world.current_tick, ws.teams.size()])

	# ── 選 specimen 隊：原玩家隊 ＋ 最近鄰 NPC 隊（確定性，距離排序）────────
	var player_tid: int = ws.get_player_team_id()
	if player_tid == -1 or not ws.teams.has(player_tid):
		_mech_anomalies.append("★致命：暖身 %d 天後找不到玩家隊（player_tid=%d）⇒ 無法往下殺玩家" % [WARMUP_DAYS, player_tid])
		_finish(ws, "NO-PLAYER-TEAM")
		return

	var player_team: TeamData = ws.teams[player_tid]
	var player_pos: Vector2i = player_team.tile_pos
	var others: Array = []
	for tid in ws.teams.keys():
		if int(tid) == player_tid:
			continue
		var t: TeamData = ws.teams[tid]
		var d: float = Vector2(t.tile_pos - player_pos).length()
		others.append({"tid": int(tid), "dist": d})
	others.sort_custom(func(a, b):
		if a["dist"] != b["dist"]:
			return a["dist"] < b["dist"]
		return a["tid"] < b["tid"])   # ★distance 平手時用 tid 排序 tie-break，確定性零 RNG

	var nearby_ids: Array[int] = []
	for i in range(min(NEARBY_TEAM_COUNT, others.size())):
		nearby_ids.append(int(others[i]["tid"]))

	var specimen_ids: Array[int] = [player_tid]
	for nid in nearby_ids:
		specimen_ids.append(nid)
	print("[SPECIMEN-TEAMS] player=%d｜鄰近=%s" % [player_tid, str(nearby_ids)])

	# ── 手動啟 SpecimenTracer（id 在跑時才知道，走 SpecimenDumpHelper 文件講的
	#    「已知目標隊先手動 dispatch」路徑，等效於 setup_from_env 收尾那三行）──
	ws.specimen_team_ids = specimen_ids
	SpecimenTracer.reset()
	SpecimenTracer.enabled = true
	print("[SpecimenTracer] enabled=true｜specimen_team_ids=%s" % str(ws.specimen_team_ids))

	# ── 殺玩家：逐字照 story_end_not_physics_bed.gd:67-73（真的寫入者）────────
	var pid: int = ws.player_id
	for m in player_team.named_members.duplicate():
		ws.remove_member(player_team, int(m), false)
		if int(m) == pid:
			ws.persons.erase(pid)
	EventSystem.new().handle_player_succession(ws, player_team)
	print("[KILL] game_over=%s｜原因「%s」" % [str(ws.game_over), ws.game_over_reason])

	if not ws.game_over:
		_mech_anomalies.append("★★母體地板沒過：殺完 game_over 仍是 false（原因「%s」）⇒ 下面 7 天推的是一個沒死的世界，QA 讀到的不是「玩家死後」" % ws.game_over_reason)
		_finish(ws, "GAME-OVER-NOT-SET")
		return

	# ── snapshot（殺玩家後，推 7 天前）──────────────────────────────────────
	var before_snap: Dictionary = _snapshot_teams(ws, specimen_ids)
	var tick_before: int = ws.world.current_tick

	# ── 推 POST_DEATH_DAYS 天 ───────────────────────────────────────────────
	var post_ticks: int = WorldState.TICKS_PER_DAY * POST_DEATH_DAYS
	print("[POST-DEATH] 推 %d ticks（%d 天）..." % [post_ticks, POST_DEATH_DAYS])
	var return_dist: Dictionary = {}
	var errors_during_push: int = 0
	for _i in range(post_ticks):
		var r = runner.advance_tick(ws, no_player)
		var rs: String = str(r)
		return_dist[rs] = int(return_dist.get(rs, 0)) + 1
	var tick_after: int = ws.world.current_tick
	var actual_advance: int = tick_after - tick_before

	print("[POST-DEATH] done｜current_tick %d → %d（推 %d 次，實際 +%d）｜advance_tick 回傳分佈=%s" \
		% [tick_before, tick_after, post_ticks, actual_advance, str(return_dist)])

	if actual_advance != post_ticks:
		_mech_anomalies.append("★★tick 沒有如期前進：要求推 %d 次，current_tick 只 +%d（回傳分佈 %s）⇒ 世界可能卡住/提早停" \
			% [post_ticks, actual_advance, str(return_dist)])

	# ── snapshot after，比對是否有隊「全欄位凍結」（活著卻零變化＝可疑）──────
	var after_snap: Dictionary = _snapshot_teams(ws, specimen_ids)
	for tid in specimen_ids:
		var still_alive: bool = ws.teams.has(tid)
		if not still_alive:
			print("[TEAM %d] 7 天後已從 ws.teams 消失（併隊/殲滅/其他）" % tid)
			continue
		var b = before_snap.get(tid, null)
		var a = after_snap.get(tid, null)
		if b == null or a == null:
			continue
		if _dict_equal(b, a) and int(a.get("population", 0)) > 0:
			_mech_anomalies.append("★隊 %d：population>0 但 7 天內 population/tile_pos/current_task/food/coin/material 全部零變化（snapshot 逐字相同）⇒ 疑似凍結，非正常判故事" % tid)

	# ── dump specimen ───────────────────────────────────────────────────────
	_finish(ws, "OK")


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


func _finish(ws: WorldState, status: String) -> void:
	var out_path: String = "docs/measurements/player-death-7day.specimen.jsonl"
	SpecimenTracer.flush()
	SpecimenDumpHelper.dump(ws, out_path)
	print("\n=== player_death_7day_specimen DONE｜status=%s ===" % status)
	print("[DUMP-PATH] %s" % out_path)
	if _mech_anomalies.is_empty():
		print("[MECH-ANOMALIES] 無")
	else:
		print("[MECH-ANOMALIES] %d 條：" % _mech_anomalies.size())
		for a in _mech_anomalies:
			print("  - " + String(a))
