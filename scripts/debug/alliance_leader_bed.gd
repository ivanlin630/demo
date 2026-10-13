extends SceneTree
# @bed-kind: acceptance
# slice: 同盟不搬領袖（spec 2026-10-13-alliance-never-moves-faction-leader-HOW）
# 同盟不搬領袖＋據點易主進事件流（spec 2026-10-13-alliance-never-moves-faction-leader-HOW）
#   #8-0
#   R2  任一 set_owner（各 reason 佈置一次）⇒ 玩家相關時事件流有對應人話、而且是推進停點
#   R1c NPC↔NPC 易主 ⇒ 不 emit、pending_rethink 不被標
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/alliance_leader_bed.gd

const SEED: int = 1337
const REASONS: Array = ["alliance", "capture", "takeover", "construct", "abandon", "demolish", "relocate_abandon", "death_release"]

var _errors: int = 0


func _check(label: String, ok: bool) -> void:
	if ok:
		print("  PASS: " + label)
	else:
		_errors += 1
		push_error("[FAIL] " + label)


func _initialize() -> void:
	print("=== alliance_leader：同盟不搬領袖、據點易主進事件流 ===")
	_r2_player_related()
	_r1c_npc_silent()
	_l_player_side()
	_l2b_l2c_npc_rule()
	_l8_subjugate_leader()
	_l9_option_layer()
	_r1_resident()
	_l7_audit_30d()
	print("=== alliance_leader DONE === errors: %d" % _errors)
	quit(1 if _errors > 0 else 0)


func _world() -> WorldState:
	seed(SEED)
	var st := WorldState.new()
	GameSetup.setup(st, GameSetup.load_config("res://config/default.json"))
	return st


func _free_tile(st: WorldState) -> HexTileData:
	var ids: Array = st.world.tiles.keys()
	ids.sort()
	for k in ids:
		var t: HexTileData = st.world.tiles[k]
		if t.outpost_level == 0 and t.outpost_owner == -1:
			return t
	return null


func _npc(st: WorldState, skip: Array) -> TeamData:
	var ids: Array = st.teams.keys()
	ids.sort()
	var pfid: int = int((st.teams[st.get_player_team_id()] as TeamData).faction_id)
	for tid in ids:
		var t: TeamData = st.teams[tid]
		if int(tid) == st.get_player_team_id() or skip.has(int(tid)) or t.beast_kind != "" or t.leader_id == -1:
			continue
		if pfid != -1 and int(t.faction_id) == pfid:
			continue
		return t
	return null


func _r2_player_related() -> void:
	print("\n── R2 玩家相關的易主：每個 reason 都有人話、是推進停點 ──")
	var st: WorldState = _world()
	var ptid: int = st.get_player_team_id()
	var npc: TeamData = _npc(st, [])
	var bad: Array = []
	for i in range(REASONS.size()):
		var r: String = String(REASONS[i])
		var tile: HexTileData = _free_tile(st)
		tile.outpost_level = 1
		var seq0: int = st.player_event_seq
		# 偶數：玩家取得；奇數：玩家失去
		if i % 2 == 0:
			OutpostOwnerBank.set_owner(st, tile, npc.team_id, "init")
			OutpostOwnerBank.set_owner(st, tile, ptid, r)
		else:
			OutpostOwnerBank.set_owner(st, tile, ptid, "init")
			OutpostOwnerBank.set_owner(st, tile, npc.team_id if r != "abandon" and r != "demolish" and r != "relocate_abandon" and r != "death_release" else -1, r)
		var ev: Dictionary = WorldEvents.stop_event_since(st, seq0)
		var txt: String = String(ev.get("text", ""))
		var why: String = String(WorldEvents.OWNER_CHANGE_REASON.get(r, "?"))
		print("   %-16s ⇒ 停點=%s「%s」" % [r, str(not ev.is_empty()), txt])
		if ev.is_empty() or String(ev.get("kind", "")) != "outpost_owner_changed" or not txt.contains(why) \
				or not txt.contains("(%d,%d)" % [tile.tile_pos.x, tile.tile_pos.y]):
			bad.append(r)
	_check("R2 八種 reason 玩家相關時都有人話（含地點與原因）且是推進停點（缺 %s）" % str(bad), bad.is_empty())
	# init 不發
	var t2: HexTileData = _free_tile(st)
	t2.outpost_level = 1
	var seq1: int = st.player_event_seq
	OutpostOwnerBank.set_owner(st, t2, ptid, "init")
	_check("R2 init（開局佈置）不發事件", st.player_event_seq == seq1)


func _r1c_npc_silent() -> void:
	print("\n── R1c NPC↔NPC 易主：不 emit、不標 pending_rethink ──")
	var st: WorldState = _world()
	var a: TeamData = _npc(st, [])
	var b: TeamData = _npc(st, [a.team_id])
	var tile: HexTileData = _free_tile(st)
	tile.outpost_level = 1
	OutpostOwnerBank.set_owner(st, tile, a.team_id, "init")
	st.pending_rethink.clear()
	st.pending_think.clear()
	var seq0: int = st.player_event_seq
	OutpostOwnerBank.set_owner(st, tile, b.team_id, "capture")
	print("   Team%d → Team%d｜事件 %d 筆｜pending_rethink %s" % [a.team_id, b.team_id, st.player_event_seq - seq0, str(st.pending_rethink.keys())])
	_check("★母體地板：真的易主了", tile.outpost_owner == b.team_id)
	_check("R1c NPC↔NPC 易主不進事件流、不標 pending_rethink／pending_think", st.player_event_seq == seq0 and st.pending_rethink.is_empty() and st.pending_think.is_empty())


# ══ 同盟不搬領袖 ════════════════════════════════════════════════════════════
#   L1  玩家（勢力 F2 領袖）接受 F1 非領袖隊的同盟 ⇒ 玩家仍在 F2、對方加入 F2、句「TeamX 加入你的勢力F2」
#   L2  玩家（F2 領袖）接受 F1 領袖隊的同盟 ⇒ 兩隊都不換勢力、名聲不變、句「兩個勢力之間的結盟還沒做」
#   L3  玩家（F2 領袖）向 F1 某隊發起 ⇒ 玩家不離開 F2
#   L4  玩家獨立，接受 F1 隊的同盟 ⇒「你加入勢力F1」，提案行事先寫明
#   L6  玩家發起而成立的同盟：名聲只 +0.2 一次
#   L2b F1 領袖隊向 F2 非領袖成員提案 ⇒ 拒（收提案方不必是領袖）
#   L2c F2 成員向 F1 領袖提案、領袖接受 ⇒ 成員照搬入 F1（反向保持）
#   L5  兩勢力領袖之間 ⇒ 不成立（量測判定不是主要管道；見 alliance_growth_census）
#   L8  臣服把領袖隊搬走 ⇒ 原勢力繼位或解散，不懸空
#   L9  NPC 領袖不會對異勢力隊送 propose_alliance（選項層排除）；同輪改提通商
#   R1  玩家據點上的登記居民 R 向異勢力 T 提同盟 ⇒ 被拒（居民綁定），據點仍是玩家的、R 仍在玩家勢力
#   R1b R 經別的路徑換旗 ⇒ 事件流有「居民 R 改投」
#   R1d 結盟不轉讓據點：站在玩家據點上的產糧隊（非登記居民）與 T 結盟 ⇒ 據點仍是玩家的（舊 D C1 會送給 T）
#   L7  30 天世界 InvariantAudit 的勢力領袖條零違反
func _two_factions(st: WorldState) -> Array:
	var fids: Array = st.factions.keys()
	fids.sort()
	return [st.factions[fids[0]], st.factions[fids[1]]]


func _non_leader(st: WorldState, f: FactionData, skip: Array = []) -> TeamData:
	for tid in f.member_team_ids:
		if int(tid) != f.leader_team_id and not skip.has(int(tid)) and int(tid) != st.get_player_team_id():
			return st.teams[tid]
	return null


# 玩家當 F2 的領袖（原領袖留在 F2 當成員）
func _player_leads(st: WorldState, f2: FactionData) -> TeamData:
	var pt: TeamData = st.teams[st.get_player_team_id()]
	if pt.faction_id != f2.faction_id:
		st.set_team_faction(pt, f2.faction_id, WorldState.JOIN_SETUP)
	f2.leader_team_id = pt.team_id
	return pt


# 把 self 對 other 的外交分數推過門檻（糧缺、名聲、好感、義氣×信義拉滿）——只動 self 自己的欄位
func _warm(st: WorldState, self_t: TeamData, other: TeamData) -> void:
	ResourceBank.set_amt(self_t, "food", 0.0, "bed_seed")
	self_t.known_reputations[other.team_id] = 1.0
	var ldr: PersonData = st.persons.get(self_t.leader_id)
	if ldr != null:
		ldr.values["義氣"] = 1.0
		ldr.values["信義"] = 1.0
		ldr.relations[other.leader_id] = 1.0


func _first_indep(st: WorldState, skip: int) -> TeamData:
	var ids: Array = st.teams.keys()
	ids.sort()
	for tid in ids:
		var t: TeamData = st.teams[tid]
		if t.faction_id == -1 and t.beast_kind == "" and t.leader_id != -1 and int(tid) != skip:
			return t
	return null


func _l_player_side() -> void:
	print("\n── L1／L2／L3／L4／L6 玩家端 ──")
	var st: WorldState = _world()
	var fs: Array = _two_factions(st)
	var f1: FactionData = fs[0]
	var f2: FactionData = fs[1]
	var pt: TeamData = _player_leads(st, f2)
	var x: TeamData = _non_leader(st, f1)
	var pcs := PlayerCommandSystem.new()
	var r1: Dictionary = pcs._accept_diplomacy(st, x.team_id, "propose_alliance")
	print("   L1 接受 F1 成員 Team%d ⇒ 玩家在 %d、對方在 %d｜「%s」" % [x.team_id, pt.faction_id, x.faction_id, r1.get("msg", "")])
	_check("L1 玩家仍在 F2、對方加入 F2、句子寫實際後果", pt.faction_id == f2.faction_id and x.faction_id == f2.faction_id
		and String(r1.get("msg", "")) == "Team%d 加入你的勢力%d" % [x.team_id, f2.faction_id])
	var l1: TeamData = st.teams[f1.leader_team_id]
	var rep0: float = float(pt.known_reputations.get(l1.team_id, 0.5))
	var r2: Dictionary = pcs._accept_diplomacy(st, l1.team_id, "propose_alliance")
	print("   L2 接受 F1 領袖 Team%d ⇒ 玩家在 %d、對方在 %d｜「%s」" % [l1.team_id, pt.faction_id, l1.faction_id, r2.get("msg", "")])
	_check("L2 兩隊都不換勢力、名聲不變、句「兩個勢力之間的結盟還沒做」", pt.faction_id == f2.faction_id and l1.faction_id == f1.faction_id
		and is_equal_approx(float(pt.known_reputations.get(l1.team_id, 0.5)), rep0) and String(r2.get("msg", "")).contains("兩個勢力之間的結盟還沒做"))
	var y: TeamData = _non_leader(st, f1, [x.team_id])
	if y == null:
		_check("★母體地板：F1 還有另一支非領袖隊", false)
	else:
		y.known_reputations[pt.team_id] = 1.0
		var r3: Dictionary = pcs._action_propose_alliance(st, y.team_id, pt, pt.team_id)
		print("   L3 玩家向 F1 Team%d 發起 ⇒ 玩家在 %d｜「%s」" % [y.team_id, pt.faction_id, r3.get("msg", "")])
		_check("L3 玩家（F2 領袖）發起 ⇒ 不離開 F2", pt.faction_id == f2.faction_id)
	var ind: TeamData = _first_indep(st, pt.team_id)
	if ind != null:
		_warm(st, ind, pt)
		var before: float = float(pt.known_reputations.get(ind.team_id, 0.5))
		var r6: Dictionary = pcs._action_propose_alliance(st, ind.team_id, pt, pt.team_id)
		var after: float = float(pt.known_reputations.get(ind.team_id, 0.5))
		print("   L6 玩家向獨立 Team%d 發起 ⇒ 對方在 %d｜名聲 %.2f→%.2f｜「%s」" % [ind.team_id, ind.faction_id, before, after, r6.get("msg", "")])
		if bool(r6.get("ok", false)):
			_check("L6 名聲只 +0.2 一次（舊版 :876 重複呼叫加兩次）", is_equal_approx(after - before, minf(0.2, 1.0 - before)))
			_check("L6 句子寫實際後果（對方加入你的勢力）", String(r6.get("msg", "")) == "Team%d 加入你的勢力%d" % [ind.team_id, pt.faction_id])
		else:
			print("   （對方拒絕 ⇒ L6 不可判）")
			_check("★L6 母體地板：對方接受（不然名聲那一格不可判）", false)
	var st4: WorldState = _world()
	var fs4: Array = _two_factions(st4)
	var pt4: TeamData = st4.teams[st4.get_player_team_id()]
	if pt4.faction_id != -1:
		st4.set_team_faction(pt4, -1, WorldState.LEAVE_PLAYER)
	var z: TeamData = _non_leader(st4, fs4[0])
	var pre: String = PlayerCommandSystem.alliance_preview(st4, z.team_id)
	var r4: Dictionary = PlayerCommandSystem.new()._accept_diplomacy(st4, z.team_id, "propose_alliance")
	var f1id: int = (fs4[0] as FactionData).faction_id
	print("   L4 獨立玩家接受 F1 Team%d ⇒ 預告「%s」｜結果「%s」" % [z.team_id, pre, r4.get("msg", "")])
	_check("L4 結果「你加入勢力F1」且提案行事先寫明", pt4.faction_id == f1id
		and String(r4.get("msg", "")) == "你加入勢力%d" % f1id and pre.contains("你加入勢力%d" % f1id))


func _l2b_l2c_npc_rule() -> void:
	print("\n── L2b／L2c NPC 端規則 ──")
	var st: WorldState = _world()
	var fs: Array = _two_factions(st)
	var f1: FactionData = fs[0]
	var f2: FactionData = fs[1]
	var l1: TeamData = st.teams[f1.leader_team_id]
	var m2: TeamData = _non_leader(st, f2)
	m2.known_reputations[l1.team_id] = 1.0
	var dip := DiplomaticAiSystem.new()
	var ans: String = dip.handle_diplomacy_message(st, m2, l1, "propose_alliance")
	print("   L2b F1 領袖 Team%d → F2 成員 Team%d ⇒ %s｜領袖在 %d" % [l1.team_id, m2.team_id, ans, l1.faction_id])
	_check("L2b 勢力領袖向異勢力成員提案 ⇒ 拒、領袖不換勢力", ans != "accept" and l1.faction_id == f1.faction_id and f1.leader_team_id == l1.team_id)
	# L5：兩勢力領袖之間 ⇒ 不成立（不換勢力、不加名聲）
	var l2: TeamData = st.teams[f2.leader_team_id]
	_warm(st, l2, l1)
	var rep5: float = float(l2.known_reputations.get(l1.team_id, 0.5))
	var ans5: String = dip.handle_diplomacy_message(st, l2, l1, "propose_alliance")
	print("   L5 F1 領袖 Team%d → F2 領袖 Team%d ⇒ %s｜%d／%d｜名聲 %.2f→%.2f" % [l1.team_id, l2.team_id, ans5, l1.faction_id, l2.faction_id,
		rep5, float(l2.known_reputations.get(l1.team_id, 0.5))])
	_check("L5 兩勢力領袖之間的同盟 ⇒ 不成立、不換勢力、不加名聲", ans5 != "accept" and l1.faction_id == f1.faction_id
		and l2.faction_id == f2.faction_id and is_equal_approx(float(l2.known_reputations.get(l1.team_id, 0.5)), rep5))
	var res: Dictionary = dip._form_alliance(st, l1, m2)
	print("   L2c F2 成員 Team%d → F1 領袖 ⇒ %s｜成員在 %d" % [m2.team_id, str(res), m2.faction_id])
	_check("L2c 成員向異勢力領袖提案被接受 ⇒ 成員照搬入（反向保持）", m2.faction_id == f1.faction_id and String(res.get("action", "")) == "move")


func _l8_subjugate_leader() -> void:
	print("\n── L8 臣服把領袖隊搬走 ⇒ 繼位或解散，不懸空 ──")
	var st: WorldState = _world()
	var fs: Array = _two_factions(st)
	var f1: FactionData = fs[0]
	var f2: FactionData = fs[1]
	var old_leader: int = f1.leader_team_id
	st.set_team_faction(st.teams[old_leader], f2.faction_id, WorldState.JOIN_SUBJUGATE)
	var alive: bool = st.factions.has(f1.faction_id)
	var ok: bool = not alive or (st.teams.has(f1.leader_team_id) and (st.teams[f1.leader_team_id] as TeamData).faction_id == f1.faction_id)
	var v: Array = InvariantAudit.check(st).filter(func(x): return String(x).begins_with("勢力"))
	print("   原領袖 Team%d 被搬去 F%d ⇒ F%d 存在=%s 新領袖=%d｜L7 違反 %s" % [old_leader, f2.faction_id, f1.faction_id,
		str(alive), f1.leader_team_id, str(v)])
	_check("L8 原勢力繼位或解散、leader_team_id 不懸空", ok and v.is_empty() and (not alive or f1.leader_team_id != old_leader))


func _l9_option_layer() -> void:
	print("\n── L9 選項層：領袖不對異勢力隊送結盟、同輪改提通商 ──")
	var st: WorldState = _world()
	var fs: Array = _two_factions(st)
	var l1: TeamData = st.teams[(fs[0] as FactionData).leader_team_id]
	var m2: TeamData = _non_leader(st, fs[1])
	m2.tile_pos = l1.tile_pos
	st.team_discovered[l1.team_id] = [m2.team_id]
	_warm(st, l1, m2)
	var ldr: PersonData = st.persons.get(l1.leader_id)
	ldr.values["慎重"] = 0.0
	var dip := DiplomaticAiSystem.new()
	var score: float = dip._calc_diplomacy_score(st, l1, m2)
	Probe.reset()
	Probe.enabled = true
	dip.try_proactive_diplomacy(st, l1)
	Probe.enabled = false
	var sa: int = int(Probe.counts.get("dip.send.propose_alliance", 0))
	var stt: int = int(Probe.counts.get("dip.send.propose_trade", 0))
	print("   score %.2f｜送結盟 %d｜送通商 %d" % [score, sa, stt])
	_check("★母體地板：分數夠高（>0.6，修前會送結盟）", score > 0.6)
	_check("L9 領袖不對異勢力隊送結盟；同輪改提通商", sa == 0 and stt == 1)


func _r1_resident() -> void:
	print("\n── R1／R1b／R1d 居民與據點 ──")
	var st: WorldState = _world()
	var fs: Array = _two_factions(st)
	var f2: FactionData = fs[1]
	var pt: TeamData = _player_leads(st, f2)
	var tile: HexTileData = _free_tile(st)
	tile.outpost_level = 1
	OutpostOwnerBank.set_owner(st, tile, pt.team_id, "init")
	var r: TeamData = _non_leader(st, f2)
	r.tile_pos = tile.tile_pos
	r.work_outpost = tile.tile_pos
	var t: TeamData = _non_leader(st, fs[0])
	t.known_reputations[r.team_id] = 1.0
	var dip := DiplomaticAiSystem.new()
	var ans: String = dip.handle_diplomacy_message(st, t, r, "propose_alliance")
	print("   R1 居民 Team%d → 異勢力 Team%d ⇒ %s｜%s｜據點主 %d｜R 在 %d" % [r.team_id, t.team_id, ans, str(dip.last_alliance), tile.outpost_owner, r.faction_id])
	_check("R1 登記居民不得被結盟搬出地主勢力：被拒、據點仍是玩家的、R 仍在玩家勢力",
		ans != "accept" and tile.outpost_owner == pt.team_id and r.faction_id == f2.faction_id and String(dip.last_alliance.get("code", "")) == "resident_bound")
	var seq0: int = st.player_event_seq
	st.set_team_faction(r, -1, WorldState.LEAVE_DEFECT_EVENT)
	var ev: Dictionary = WorldEvents.stop_event_since(st, seq0)
	print("   R1b R 脫離 ⇒ 「%s」" % String(ev.get("text", "")))
	_check("R1b 居民經別的路徑換旗 ⇒ 地主（玩家）事件流有「居民 R 改投」、是推進停點", String(ev.get("kind", "")) == "resident_changed_faction"
		and String(ev.get("text", "")).contains("Team%d" % r.team_id))
	var tile2: HexTileData = _free_tile(st)
	tile2.outpost_level = 1
	OutpostOwnerBank.set_owner(st, tile2, pt.team_id, "init")
	var p2: TeamData = _first_indep(st, pt.team_id)
	if p2 == null:
		_check("★母體地板：有一支獨立隊可佈置", false)
		return
	p2.tile_pos = tile2.tile_pos
	p2.work_outpost = Vector2i(-1, -1)
	if not p2.tags.has(TeamData.TAG_PRODUCE):
		p2.tags.append(TeamData.TAG_PRODUCE)
	var res: Dictionary = dip._form_alliance(st, t, p2)
	print("   R1d 產糧隊 Team%d（站在玩家據點）與 Team%d 結盟 ⇒ %s｜據點主 %d" % [p2.team_id, t.team_id, str(res), tile2.outpost_owner])
	_check("★母體地板：結盟真的成立（p2 入 T 的勢力）", String(res.get("action", "")) == "move")
	_check("R1d 結盟不轉讓據點（舊 D C1 會把玩家據點送給 T）", tile2.outpost_owner == pt.team_id)


func _l7_audit_30d() -> void:
	print("\n── L7 30 天世界：勢力領袖不懸空（InvariantAudit）──")
	var st: WorldState = _world()
	var runner := SimRunner.new()
	var bad: Array = []
	for d in range(30):
		for i in range(WorldState.TICKS_PER_DAY):
			var p: TeamData = st.teams.get(st.get_player_team_id())
			runner.advance_tick(st, p.tile_pos if p != null else Vector2i(-1, -1))
			if st.encounter_active:
				runner._encounter_system.resolve_encounter_end(st, "draw")
		for v in InvariantAudit.check(st):
			if String(v).begins_with("勢力"):
				bad.append("d%d %s" % [d + 1, v])
	print("   30 天、每日檢查：勢力領袖違反 %d 筆 %s" % [bad.size(), str(bad.slice(0, 5))])
	_check("L7 30 天世界勢力領袖條零違反", bad.is_empty())
