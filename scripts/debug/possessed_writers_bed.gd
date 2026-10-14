extends SceneTree
# @bed-kind: invariant
# 附身隊後續 丙（spec 2026-10-13-possessed-team-followups-HOW §丙）：分類為【決策】、修法＝入口對 possessed return 的三支
#   C1  玩家只是成員（隊長是 NPC）⇒ 一天內 _decide_unified 本體不碰附身隊（last_decision_tick／current_option 不動）；
#       同世界一支 NPC 成員隊照常決策（對照：條件真的會走到那一支）
#   C2  玩家隊有一座沒居民的自家據點 ⇒ 居民派駐不替他派子隊／邀流亡；同佈置的 NPC 隊會派（對照）
#   C3  玩家只是成員、隊上公庫有錢、缺糧 ⇒ 不自動徵用公庫；同佈置的 NPC 隊會徵（對照）
#   ★寫入觀察（possessed_writers_census）30 天只量得到 C1 的欄位；C2／C3 在那組世界沒觸發 ⇒ 佈置在這裡造
#   負對照：各拿掉一條 possessed return ⇒ 對應那一格紅
#   ★到場點名：三格各自報到，末行印「到場 3／3」（expect 釘它）
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/possessed_writers_bed.gd

const SEED: int = 1337
const CELLS: Array = ["C1", "C2", "C3"]

var _errors: int = 0
var _present: Dictionary = {}


func _check(label: String, ok: bool) -> void:
	if ok:
		print("  PASS: " + label)
	else:
		_errors += 1
		push_error("[FAIL] " + label)


func _initialize() -> void:
	print("=== possessed_writers：AI 決策入口不碰附身隊 ===")
	_c1_member_decide()
	_c2_residency()
	_c3_extraction()
	var n: int = 0
	for c in CELLS:
		if _present.has(c):
			n += 1
		else:
			push_error("[FAIL] 格 %s 沒有跑完（到場點名缺）" % c)
			_errors += 1
	print("=== possessed_writers DONE === 到場 %d／%d errors: %d" % [n, CELLS.size(), _errors])
	quit(1 if _errors > 0 else 0)


func _world() -> WorldState:
	seed(SEED)
	var st := WorldState.new()
	GameSetup.setup(st, GameSetup.load_config("res://config/default.json"))
	return st


# 依 id 排序的非玩家真隊（有領袖、非野獸、非子隊）
func _npc_teams(st: WorldState) -> Array:
	var out: Array = []
	var ptid: int = st.get_player_team_id()
	var ids: Array = st.teams.keys()
	ids.sort()
	for tid in ids:
		var t: TeamData = st.teams[tid]
		if int(tid) != ptid and t.leader_id != -1 and t.beast_kind == "" and t.parent_team_id == -1 and not t.possessed:
			out.append(t)
	return out


# 玩家移入一支 NPC 隊當成員（同 possessed_writers_census 的 member 情形）；回那一隊
func _join_as_member(st: WorldState, host: TeamData) -> TeamData:
	st.remove_member(st.teams[st.get_player_team_id()], st.player_id, false)
	st.add_member(host, st.player_id)
	return host


# ── C1 ──────────────────────────────────────────────────────────────────────
func _c1_member_decide() -> void:
	print("\n── C1 玩家只是成員 ⇒ 引擎本體不碰附身隊 ──")
	var st: WorldState = _world()
	var npcs: Array = _npc_teams(st)
	var host: TeamData = _join_as_member(st, npcs[0])
	var ctrl: TeamData = null
	for t in _npc_teams(st):
		if t.team_id != host.team_id:
			ctrl = t
			break
	_check("★C1 地板：附身隊隊長不是玩家、possessed＝真；有對照隊", host.possessed and host.leader_id != st.player_id and ctrl != null)
	var h_ld0: int = host.last_decision_tick
	var h_op0: String = host.current_option
	var c_ld0: int = ctrl.last_decision_tick
	var runner := SimRunner.new()
	for i in range(WorldState.TICKS_PER_DAY):
		runner.advance_tick(st, host.tile_pos)
		if st.encounter_active:
			runner._encounter_system.resolve_encounter_end(st, "draw")
	print("   附身隊 T%d last_decision_tick %d→%d current_option「%s」→「%s」｜對照 T%d last_decision_tick %d→%d" % [host.team_id,
		h_ld0, host.last_decision_tick, h_op0, host.current_option, ctrl.team_id, c_ld0, ctrl.last_decision_tick])
	_check("★C1 對照：NPC 隊一天內有決策（last_decision_tick 前進）", ctrl.last_decision_tick > c_ld0)
	_check("C1 附身隊一天內 last_decision_tick、current_option 不動", host.last_decision_tick == h_ld0 and host.current_option == h_op0)
	_present["C1"] = true


# ── C2 ──────────────────────────────────────────────────────────────────────
# 佈置：在隊所在格旁找一格空地，蓋一座 L1 據點給它（沒居民）；隊長偏派子隊（野心／好戰高、商業／慎重低）；人口補足
func _seed_empty_outpost(st: WorldState, t: TeamData) -> HexTileData:
	for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(-1, 1)]:
		var p: Vector2i = t.tile_pos + d
		var tile: HexTileData = st.world.tiles.get(p.x * 1000 + p.y)
		if tile == null or tile.outpost_level > 0 or tile.outpost_owner != -1:
			continue
		tile.outpost_level = 1
		tile.outpost_type = "civilian"
		OutpostOwnerBank.set_owner(st, tile, t.team_id, "bed_seed")
		return tile
	return null


func _lean_dispatch(st: WorldState, t: TeamData) -> void:
	var ld: PersonData = st.persons.get(t.leader_id)
	ld.values["野心"] = 1.0
	ld.values["好戰"] = 1.0
	ld.values["慎重"] = 0.0
	ld.skills["商業"] = 0.0
	if t.population < 20:
		AnonTierSystem.add_anon(t, AnonTierSystem.TIER_ORDER[0], 20 - t.population)   # 派子隊要求留下 ≥ MIN_PARENT_POP_AFTER_DISPATCH


func _subs(st: WorldState, t: TeamData) -> int:
	var n: int = 0
	for tid in st.teams:
		if (st.teams[tid] as TeamData).parent_team_id == t.team_id:
			n += 1
	return n


func _c2_residency() -> void:
	print("\n── C2 自家空據點 ⇒ 居民派駐不替附身隊派子隊 ──")
	var st: WorldState = _world()
	var pt: TeamData = st.teams[st.get_player_team_id()]
	var ctrl: TeamData = null
	var npcs: Array = _npc_teams(st)
	if not npcs.is_empty():
		ctrl = npcs[0]   # 人口由 _lean_dispatch 補足（同附身隊）
	var fai: FactionAISystem = FactionAISystem.shared()
	var res: Array = []
	for t in [ctrl, pt]:
		if t == null:
			res.append({})
			continue
		_lean_dispatch(st, t)
		var tile: HexTileData = _seed_empty_outpost(st, t)
		var s0: int = _subs(st, t)
		t.residency_eval_next_tick = 0
		fai._evaluate_outpost_residency(st, t)
		res.append({"tile": tile != null, "pop": t.population, "s0": s0, "s1": _subs(st, t), "possessed": t.possessed})
	print("   對照 T%d %s｜附身隊 T%d %s" % [ctrl.team_id if ctrl != null else -1, str(res[0]), pt.team_id, str(res[1])])
	_check("★C2 對照：NPC 隊同佈置會派子隊（條件真的會觸發）", ctrl != null and bool(res[0].get("tile", false)) and int(res[0]["s1"]) > int(res[0]["s0"]))
	_check("★C2 地板：附身隊佈置成立（有空據點、人口 %d）" % int(res[1].get("pop", 0)), bool(res[1].get("tile", false)) and bool(res[1].get("possessed", false)))
	_check("C2 附身隊不被派子隊", int(res[1].get("s1", -1)) == int(res[1].get("s0", -2)))
	_present["C2"] = true


# ── C3 ──────────────────────────────────────────────────────────────────────
func _c3_extraction() -> void:
	print("\n── C3 玩家只是成員、公庫有錢、缺糧 ⇒ 不自動徵用 ──")
	var st: WorldState = _world()
	var npcs: Array = _npc_teams(st)
	var host: TeamData = _join_as_member(st, npcs[0])
	var ctrl: TeamData = null
	for t in _npc_teams(st):
		if t.team_id != host.team_id:
			ctrl = t
			break
	var res: Array = []
	for t in [ctrl, host]:
		t.anon_treasury = 500.0
		ResourceBank.set_amt(t, "coin", 0.0, "bed_seed")
		ResourceBank.set_amt(t, "food", 0.0, "bed_seed")
		var g: HexTileData = ResourceSystem.own_granary_tile(st, t)
		if g != null:
			TileBank.set_amt(g, "food", 0.0, "bed_seed")
		var need: float = CoinTreasury.coin_need(st, t)
		CoinTreasury.consider_extraction(st, t)
		res.append({"need": snappedf(need, 0.1), "treasury": snappedf(t.anon_treasury, 0.1), "coin": snappedf(float(t.resources.get("coin", 0.0)), 0.1),
			"possessed": t.possessed, "leader_is_player": t.leader_id == st.player_id})
	print("   對照 T%d %s｜附身隊 T%d %s" % [ctrl.team_id, str(res[0]), host.team_id, str(res[1])])
	_check("★C3 對照：NPC 隊同佈置會徵用（公庫 <500）", float(res[0]["treasury"]) < 500.0)
	_check("★C3 地板：附身隊隊長不是玩家、有缺口", bool(res[1]["possessed"]) and not bool(res[1]["leader_is_player"]) and float(res[1]["need"]) > 0.0)
	_check("C3 附身隊公庫不動（500）、coin 不動（0）", float(res[1]["treasury"]) == 500.0 and float(res[1]["coin"]) == 0.0)
	_present["C3"] = true
