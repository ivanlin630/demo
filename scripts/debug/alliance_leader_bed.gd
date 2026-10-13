extends SceneTree
# @bed-kind: acceptance
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
