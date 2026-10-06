extends SceneTree
# @bed-kind: invariant
# ══ 故事結束之後，原玩家隊照 NPC 的路補領袖 ═══════════════════════════════════════════════
# spec：`docs/superpowers/specs/2026-10-06-player-team-succession-after-story-end-HOW.md` §4／§4b
#
# ★兩條死法（理由寫在 `_orphan_qa` 上方）：
#   ·P1／P2／P7 ＝ QA 那條（玩家人物留在 persons、直呼寫入者）—— 舊版在這條上**永遠**補不到領袖
#   ·P4 ＝ 戰死真路徑 `NpcCombatSystem._kill_named_npc`：它依序做 `on_leader_death` → 勢力交接的讀者（`:786-790`）
#     → 出 named → erase ⇒ 不在床裡手抄「勢力交接」那幾行（抄的那份不會跟著產線改）
#
# 格：P1 補到領袖（game_over 照設）｜P2 推過一個溢出檢查邊界不被切到 1｜P3 單一定義（反向掃）｜
#     P4 勢力兩個方向｜P7 全世界 leaderless 活隊掃描（先量；原玩家隊以外的逐隊印出、回報不擴票）

var _errors: int = 0
var _cells_ran: Array = []
const EXPECTED_CELLS: Array = ["P1", "P2", "P3", "P4", "P7"]
const P7_DAYS: int = 7


func _initialize() -> void:
	print("=== player_team_succession：故事結束之後原玩家隊照 NPC 的路補領袖 ===")
	_p1_p2()
	_p3_single_definition()
	_p4_faction_both_directions()
	_p7_no_leaderless_live_team()
	var missing: Array = []
	for c in EXPECTED_CELLS:
		if not _cells_ran.has(String(c)):
			missing.append(String(c))
	_check("★到場點名：%d／%d（缺：%s）" % [_cells_ran.size(), EXPECTED_CELLS.size(), str(missing)],
		missing.is_empty())
	print("\n=== player_team_succession DONE === errors: %d" % _errors)
	quit(1 if _errors > 0 else 0)


func _check(msg: String, cond: bool) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_errors += 1
		push_error("[FAIL] " + msg)


func _mk_world() -> WorldState:
	seed(1337)
	var ws := WorldState.new()
	GameSetup.setup(ws, GameSetup.load_config("res://config/default.json"))
	return ws


# 清掉玩家隊的其他 named（讓玩家一死就是「絕後」），再讓玩家**戰死**（真的路徑）
func _orphan_and_kill(ws: WorldState) -> Dictionary:
	var pid: int = ws.player_id
	var ptid: int = ws.persons[pid].team_id
	var pt: TeamData = ws.teams[ptid]
	for m in pt.named_members.duplicate():
		if int(m) == pid:
			continue
		ws.remove_member(pt, int(m), false)
		ws.persons.erase(int(m))
	var named_before: int = pt.named_members.size()
	var pop_before: int = pt.population
	var was_leader: bool = pt.leader_id == pid
	NpcCombatSystem.new()._kill_named_npc(ws, ptid, ws.persons[pid])
	return {"ptid": ptid, "named_before": named_before, "pop_before": pop_before, "was_leader": was_leader}


# ══ ★★QA 那條佈置（逐字照 story_end_not_physics_bed／player_death_7day_specimen 的殺法）══════════
#   清 named、**玩家人物留在 persons**（他是領袖、不在 named 迴圈裡）、直呼真的寫入者
#   ⇒ ★★這正是 QA 讀到的形狀：玩家人物還在 ⇒ `get_player_team_id()` 仍回原隊
#     ⇒ loop3 安全網每 tick 重呼 `on_leader_death` 都走**玩家分支** ⇒ 舊版永遠 `return false`
#   ⇒ ★而戰死真路徑（`_kill_named_npc`）最後會 erase 玩家 ⇒ 安全網查不到玩家隊、走 NPC 路**自己補上**
#     ⇒ 用它當 P2 的佈置，負對照（改回 return false）**不會紅**（2026-10-06 實測：pop 8 → 8）
#     ⇒ 所以 P1／P2／P7 用這條，戰死路徑只留給 P4（它要的是 `:786-790` 那個讀者）
func _orphan_qa(ws: WorldState) -> Dictionary:
	var pid: int = ws.player_id
	var ptid: int = ws.persons[pid].team_id
	var pt: TeamData = ws.teams[ptid]
	var was_leader: bool = pt.leader_id == pid
	for m in pt.named_members.duplicate():
		ws.remove_member(pt, int(m), false)
		if int(m) == pid:
			ws.persons.erase(pid)
	var named_before: int = pt.named_members.size()
	var pop_before: int = pt.population
	EventSystem.new().handle_player_succession(ws, pt)
	return {"ptid": ptid, "named_before": named_before, "pop_before": pop_before, "was_leader": was_leader,
		"player_in_persons": ws.persons.has(pid)}


# ══ P1／P2 ════════════════════════════════════════════════════════════════════════
func _p1_p2() -> void:
	print("\n── P1 絕後之後 game_over 照設、原玩家隊補到領袖｜P2 推過溢出檢查邊界不被切到 1 ──")
	var ws: WorldState = _mk_world()
	var r: Dictionary = _orphan_qa(ws)
	var ptid: int = int(r["ptid"])
	var pt: TeamData = ws.teams.get(ptid)
	print("   Team%d：死前 named（玩家以外）＝ %d｜玩家是領袖 ＝ %s｜死前 pop ＝ %d｜玩家人物仍在 persons ＝ %s" % [ptid,
		int(r["named_before"]), str(r["was_leader"]), int(r["pop_before"]), str(r["player_in_persons"])])
	_check("★母體地板：QA 的形狀（玩家人物仍在 persons ⇒ 安全網仍走玩家分支）", bool(r["player_in_persons"]))
	_check("★母體地板：玩家死前是領袖、而隊裡沒有其他 named（走的是絕後那條，不是選繼承人）",
		bool(r["was_leader"]) and int(r["named_before"]) == 0)
	print("   game_over ＝ %s「%s」｜原玩家隊 leader_id ＝ %d" % [str(ws.game_over), ws.game_over_reason,
		pt.leader_id if pt != null else -999])
	_check("★★★P1 故事結束照設（game_over ＝ true）", ws.game_over)
	_check("★★★P1 原玩家隊補到領袖（leader_id ≠ -1）", pt != null and pt.leader_id != -1)
	# P2：推到下一個溢出檢查邊界之後
	var runner := SimRunner.new()
	var iv: int = PopulationSystem.OVERFLOW_CHECK_INTERVAL
	var pop0: int = pt.population if pt != null else -1
	var start: int = ws.world.current_tick
	var target: int = (start / iv + 1) * iv + 1
	while ws.world.current_tick < target:
		runner.advance_tick(ws, Vector2i(-1, -1))
	var pt2: TeamData = ws.teams.get(ptid)
	var pop1: int = pt2.population if pt2 != null else -1
	print("   推 tick %d → %d（跨過邊界 %d）｜pop %d → %d｜leader_id ＝ %d" % [start, ws.world.current_tick,
		target - 1, pop0, pop1, pt2.leader_id if pt2 != null else -999])
	_check("★母體地板：真的跨過一個溢出檢查邊界", ws.world.current_tick > target - 1 and start < target - 1)
	_check("★★★P2 推過邊界之後原玩家隊 pop **沒有**被切到 1（%d → %d）" % [pop0, pop1], pop1 > 1)
	_cells_ran.append("P1")
	_cells_ran.append("P2")


# ══ P3 單一定義 ═══════════════════════════════════════════════════════════════════
static func _anon_promote_calls(text: String) -> Array:
	var out: Array = []
	var ls: PackedStringArray = text.split("\n")
	for i in range(ls.size()):
		var code: String = ls[i].split("#")[0]
		if code.contains("generate_for_team(") and code.contains("\"member\""):
			out.append(i + 1)
	return out


func _p3_single_definition() -> void:
	print("\n── P3 「從 anon 晉升」只有一份 ──")
	var text: String = FileAccess.get_file_as_string("res://scripts/simulation/event_system.gd")
	_check("★母體地板：真的讀到 event_system.gd（%d 行）" % text.split("\n").size(), text.split("\n").size() > 50)
	var hits: Array = _anon_promote_calls(text)
	print("   event_system.gd 裡 generate_for_team(…, \"member\") 的非註解行 ＝ %s" % str(hits))
	_check("★★★P3 只有 1 處（%d）" % hits.size(), hits.size() == 1)
	var probe: String = "\tvar a := PersonGenerator.generate_for_team(state, team, \"member\")\n" \
		+ "\t# PersonGenerator.generate_for_team(state, team, \"member\")\n" \
		+ "\tvar b := PersonGenerator.generate_for_team(state, t2, \"member\")"
	_check("★★【反向對照】合成三行（兩行呼叫／一行註解）⇒ 抽取器回 2（%s）" % str(_anon_promote_calls(probe)),
		_anon_promote_calls(probe).size() == 2)
	_cells_ran.append("P3")


# ══ P4 勢力兩個方向 ════════════════════════════════════════════════════════════════
func _make_player_team_faction_leader(ws: WorldState) -> int:
	var ptid: int = ws.persons[ws.player_id].team_id
	var pt: TeamData = ws.teams[ptid]
	var fids: Array = ws.factions.keys()
	fids.sort()
	var fid: int = int(fids[0])
	var f = ws.factions[fid]
	if pt.faction_id != fid:
		ws.set_team_faction(pt, fid)
	if not f.member_team_ids.has(ptid):
		f.member_team_ids.append(ptid)
	f.leader_team_id = ptid
	return fid


func _p4_faction_both_directions() -> void:
	print("\n── P4 原玩家隊是盟主 ⇒ 絕後之後勢力留下；★反向：真的無人可補 ⇒ 照舊交出／解散 ──")
	var ws: WorldState = _mk_world()
	var fid: int = _make_player_team_faction_leader(ws)
	var ptid: int = ws.persons[ws.player_id].team_id
	_check("★母體地板：佈置生效（勢力 %d 的盟主 ＝ Team%d）" % [fid, ws.factions[fid].leader_team_id],
		ws.factions[fid].leader_team_id == ptid and ws.teams[ptid].faction_id == fid)
	_orphan_and_kill(ws)
	var f = ws.factions.get(fid)
	print("   有匿名人口可補：勢力在 ＝ %s｜盟主 ＝ %s" % [str(f != null),
		("Team%d" % f.leader_team_id) if f != null else "—"])
	_check("★★★P4 勢力仍在、盟主仍是原玩家隊", f != null and f.leader_team_id == ptid)
	# ★反向：named 與 anon 都空 ⇒ _npc_succession 回 false ⇒ 讀者照舊交出／解散
	var ws2: WorldState = _mk_world()
	var fid2: int = _make_player_team_faction_leader(ws2)
	var ptid2: int = ws2.persons[ws2.player_id].team_id
	var pt2: TeamData = ws2.teams[ptid2]
	pt2.anon_cohorts.clear()
	print("   清空匿名人口之後 pop ＝ %d（只剩領袖本人）" % pt2.population)
	_check("★母體地板：匿名人口真的空了", AnonCohort.total(pt2.anon_cohorts) == 0)
	_orphan_and_kill(ws2)
	var f2 = ws2.factions.get(fid2)
	print("   無人可補：勢力在 ＝ %s｜盟主 ＝ %s" % [str(f2 != null),
		("Team%d" % f2.leader_team_id) if f2 != null else "—"])
	_check("★★★P4【反向】真的無人可補 ⇒ 盟主不再是原玩家隊（交出或解散）",
		f2 == null or f2.leader_team_id != ptid2)
	_cells_ran.append("P4")


# ══ P7 全世界 leaderless 活隊（先量）══════════════════════════════════════════════════
func _p7_no_leaderless_live_team() -> void:
	print("\n── P7 長跑 %d 天（玩家絕後）之後：leaderless 且 pop ≥ 1、連兩個每日邊界都如此的隊 ＝ 0 ──" % P7_DAYS)
	var ws: WorldState = _mk_world()
	var r: Dictionary = _orphan_qa(ws)
	var ptid: int = int(r["ptid"])
	_check("★母體地板：這一輪真的有玩家絕後（game_over ＝ true）", ws.game_over)
	var runner := SimRunner.new()
	var prev: Dictionary = {}       # team_id → 上一個邊界是否 leaderless
	var flagged: Dictionary = {}    # team_id → {first, tags}
	var first_seen: Dictionary = {}
	var scanned_max: int = 0
	var end_tick: int = ws.world.current_tick + P7_DAYS * WorldState.TICKS_PER_DAY
	while ws.world.current_tick < end_tick:
		runner.advance_tick(ws, Vector2i(-1, -1))
		if ws.world.current_tick % WorldState.TICKS_PER_DAY != 0:
			continue
		var now: Dictionary = {}
		var scanned: int = 0
		for k in ws.teams.keys():
			var t: TeamData = ws.teams[k]
			if not ws.is_live_team(int(k)) or t.beast_kind != "":
				continue
			scanned += 1
			if t.leader_id == -1 and t.population >= 1:
				now[int(k)] = true
				if not first_seen.has(int(k)):
					first_seen[int(k)] = ws.world.current_tick
				if prev.has(int(k)) and not flagged.has(int(k)):
					flagged[int(k)] = {"first": first_seen[int(k)], "tags": str(t.tags), "pop": t.population}
		scanned_max = maxi(scanned_max, scanned)
		prev = now
	print("   每個邊界掃描的活隊數（最多）＝ %d" % scanned_max)
	_check("★母體地板：掃描的隊數 > 0（%d）" % scanned_max, scanned_max > 0)
	var others: Array = []
	for k in flagged.keys():
		var d: Dictionary = flagged[k]
		print("   ★leaderless 活隊 Team%d：首見 tick %d（第 %d 天）｜tags %s｜pop %d%s" % [int(k), int(d["first"]),
			int(d["first"]) / WorldState.TICKS_PER_DAY, String(d["tags"]), int(d["pop"]),
			"  ← 原玩家隊" if int(k) == ptid else ""])
		if int(k) != ptid:
			others.append(int(k))
	_check("★★★P7 原玩家隊不在其中", not flagged.has(ptid))
	print("   原玩家隊以外的 leaderless 活隊 ＝ %s（★先量：若非空 ＝ 既有洞，回報不擴票）" % str(others))
	# ★先量（2026-10-06 第一次跑，seed 1337、7 天、每邊界最多掃 22 隊）＝ []  ⇒ 沒有既有洞 ⇒ 升成全世界斷言
	_check("★★★P7 全世界 leaderless 且 pop ≥ 1、連兩個每日邊界的活隊 ＝ 0（%d）" % flagged.size(), flagged.is_empty())
	_cells_ran.append("P7")
