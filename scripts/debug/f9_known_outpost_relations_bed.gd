extends SceneTree
# @bed-kind: invariant
# slice: 友善度 F9′（spec 2026-10-07 round5-friendliness §F9′，用戶裁 (C) 藍圖 c2ed35c05）——NPC 選址讀【已知】敵友據點
#   舊的選址避讓那一支（陌生人一律當敵、只看最近一座、只扣分）⇒ _known_outpost_relations（每座帶 g：同勢力 +1／否則 grat−feud）
#   分數項＝最負一座＋最正一座（不是 Σ）；每座 v＝g × max(0, 5−d) × 10 × w；w＝慎重＋(1−好戰)
#
# P9a belief 有敵對（feud 邊）據點在候選格 2 格外 vs 同位置但 belief 沒有 ⇒ 前者分數低、後者與無據點同分
# P9b 同勢力據點 2 格外 ⇒ 分數比沒有時高
# P9c 陌生人（無邊、非同勢力）據點 2 格外 ⇒ 分數與沒有時相同（★改前會扣，這格改前紅）
# P9d 慎重 0.9／好戰 0.1 vs 慎重 0.1／好戰 0.9 ⇒ 同一敵對據點的扣分前者大
# P9h 量級：候選格 5 格內 4 座已知敵城 ⇒ 該項 ≥ −50 × w（只算最強一座）
# P9f grep 舊名在 scripts/ 出現 0 次
# （P9e 負對照：拿掉該項 ⇒ P9a 兩者同分 —— detached 樹實測，見交件信）
# ★修前不存在的函式用 has_method／Script.call 動態呼 ⇒ 修前紅在格上
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/f9_known_outpost_relations_bed.gd

var _errors: int = 0
const FA_SCRIPT: Script = preload("res://scripts/simulation/faction_ai_system.gd")


func _check(msg: String, cond: bool) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_errors += 1
		push_error("[FAIL] " + msg)


func _initialize() -> void:
	print("=== F9′ NPC 選址讀已知敵友據點 ===")
	seed(20261008)
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/default.json", false)
	var fa := FactionAISystem.shared()
	var ids: Array = st.teams.keys()
	ids.sort()
	var me: TeamData = null
	var other: TeamData = null
	for k in ids:
		var t: TeamData = st.teams[k]
		if t.leader_id == -1:
			continue
		if me == null:
			me = t
		elif other == null and t.faction_id != me.faction_id:
			other = t
	_check("★母體地板：有我與一支不同勢力、有領袖的隊", me != null and other != null)
	if me == null or other == null:
		_finish()
		return
	var has_rel: bool = fa.has_method("_known_outpost_relations")
	var has_term: bool = _has_static("known_outpost_term")
	_check("★新函式在（_known_outpost_relations／known_outpost_term）", has_rel and has_term)
	var cand: Vector2i = Vector2i(8, 8)
	var op_pos: Vector2i = cand + Vector2i(2, 0)   # 候選格 2 格外
	var leader: PersonData = st.persons[me.leader_id]
	leader.values["慎重"] = 0.5
	leader.values["好戰"] = 0.5
	var w: float = 1.0
	# 無據點的基準
	st.team_tile_known[me.team_id] = {}
	var base: float = _term(fa, st, me, cand, w) if has_rel and has_term else -999.0
	print("   無已知據點 ⇒ 項 %.1f" % base)
	# P9c 陌生人
	_know(st, me, op_pos, other.team_id)
	var stranger: float = _term(fa, st, me, cand, w) if has_rel and has_term else -999.0
	print("   陌生人據點 2 格外 ⇒ 項 %.1f" % stranger)
	_check("P9c 陌生人（無邊、非同勢力）據點 2 格外 ⇒ 與沒有時同分", has_rel and has_term and is_equal_approx(stranger, base))
	# P9a 敵對（feud）
	RelationGraph.add_edge(leader.relation_edges, "feud", other.leader_id, 0.8, 0)
	var enemy: float = _term(fa, st, me, cand, w) if has_rel and has_term else -999.0
	st.team_tile_known[me.team_id] = {}
	var unknown_enemy: float = _term(fa, st, me, cand, w) if has_rel and has_term else -999.0
	print("   敵對據點 2 格外（belief 有）⇒ %.1f｜同位置但 belief 沒有 ⇒ %.1f" % [enemy, unknown_enemy])
	_check("P9a belief 有敵對據點 ⇒ 分數低", has_rel and has_term and enemy < base)
	_check("P9a 同位置但 belief 沒有 ⇒ 與無據點同分", has_rel and has_term and is_equal_approx(unknown_enemy, base))
	# ★P9a 在【選址分數】上（不只項本身）：候選格分數＝_site_candidate_score（選址迴圈同一支）
	#   ⇒ 負對照「拿掉該項」（P9e）會在這一格紅；只驗項本身的話拿掉也照綠（實測過一次）
	var has_score: bool = fa.has_method("_site_candidate_score")
	var ctile: HexTileData = st.world.tiles.get(cand.x * 1000 + cand.y)
	_check("★P9a-分數 母體地板：候選格在地圖上、分數函式在", ctile != null and has_score)
	if ctile != null and has_score:
		var s_none: float = float(fa.call("_site_candidate_score", st, ctile, 2, 1.0, [], w)["score"])
		_know(st, me, op_pos, other.team_id)
		var s_enemy: float = float(fa.call("_site_candidate_score", st, ctile, 2, 1.0, fa.call("_known_outpost_relations", st, me), w)["score"])
		st.team_tile_known[me.team_id] = {}
		var s_unknown: float = float(fa.call("_site_candidate_score", st, ctile, 2, 1.0, fa.call("_known_outpost_relations", st, me), w)["score"])
		print("   選址分數：無據點 %.1f｜已知敵城 2 格外 %.1f｜同位置但不知道 %.1f" % [s_none, s_enemy, s_unknown])
		_check("P9a-分數 已知敵城 ⇒ 候選格分數較低", s_enemy < s_none)
		_check("P9a-分數 不知道的敵城 ⇒ 分數與沒有時相同", is_equal_approx(s_unknown, s_none))
	# P9d 人格
	_know(st, me, op_pos, other.team_id)
	var w_cautious: float = float(FA_SCRIPT.call("site_persona_w", 0.9, 0.1)) if _has_static("site_persona_w") else 0.0
	var w_bold: float = float(FA_SCRIPT.call("site_persona_w", 0.1, 0.9)) if _has_static("site_persona_w") else 0.0
	var e_c: float = _term(fa, st, me, cand, w_cautious) if has_rel and has_term else 0.0
	var e_b: float = _term(fa, st, me, cand, w_bold) if has_rel and has_term else 0.0
	print("   w 慎重0.9/好戰0.1＝%.2f ⇒ %.1f｜w 慎重0.1/好戰0.9＝%.2f ⇒ %.1f" % [w_cautious, e_c, w_bold, e_b])
	_check("P9d 慎重高好戰低 ⇒ 同一敵對據點扣分較大", e_c < e_b and e_b < 0.0)
	# P9h 量級：4 座敵城 2 格外
	for dd in [Vector2i(0, 2), Vector2i(-2, 0), Vector2i(0, -2)]:
		_know(st, me, cand + dd, other.team_id)
	var four: float = _term(fa, st, me, cand, w) if has_rel and has_term else -999.0
	print("   4 座已知敵城都在 2 格外 ⇒ 項 %.1f（下限 −50×w＝%.1f；一座的值 %.1f）" % [four, -50.0 * w, enemy])
	_check("P9h 4 座已知敵城 ⇒ 項 ≥ −50×w，且＝最強一座（不是 Σ）", has_rel and has_term and four >= -50.0 * w and is_equal_approx(four, enemy))
	# P9b 同勢力（另一支同勢力的隊）
	st.team_tile_known[me.team_id] = {}
	var ally: TeamData = null
	for k2 in ids:
		var t2: TeamData = st.teams[k2]
		if t2 != me and t2.faction_id != -1 and t2.faction_id == me.faction_id:
			ally = t2
			break
	if ally == null and me.faction_id != -1 and st.factions.has(me.faction_id):
		ally = other
		(st.factions[me.faction_id] as FactionData).member_team_ids.append(other.team_id)
	_check("★P9b 母體地板：找得到（或佈置出）同勢力的隊", ally != null)
	if ally != null:
		_know(st, me, op_pos, ally.team_id)
		var friend: float = _term(fa, st, me, cand, w) if has_rel and has_term else -999.0
		print("   同勢力據點 2 格外 ⇒ 項 %.1f" % friend)
		_check("P9b 同勢力據點 2 格外 ⇒ 分數比沒有時高", friend > base)
	# P9f
	var old_name: String = "_enemy_outpost" + "_positions"
	var hits: int = 0
	for f in _gd_files("res://scripts"):
		hits += FileAccess.get_file_as_string(f).count(old_name)
	_check("P9f 舊名在 scripts/ 出現 0 次（%d）" % hits, hits == 0)
	_finish()


func _finish() -> void:
	print("\n=== f9_known_outpost_relations DONE === errors: %d" % _errors)
	quit(1 if _errors > 0 else 0)


static func _has_static(fn: String) -> bool:
	for m in FA_SCRIPT.get_script_method_list():
		if String(m.get("name", "")) == fn:
			return true
	return false


func _term(fa: FactionAISystem, st: WorldState, me: TeamData, cand: Vector2i, w: float) -> float:
	var rels: Array = fa.call("_known_outpost_relations", st, me)
	return float(FA_SCRIPT.call("known_outpost_term", rels, cand, w))


static func _know(st: WorldState, me: TeamData, p: Vector2i, owner: int) -> void:
	var known: Dictionary = st.team_tile_known.get(me.team_id, {})
	known[p.x * 1000 + p.y] = {"outpost": {"owner_id": owner, "level": 1, "last_tick": 0}}
	st.team_tile_known[me.team_id] = known


static func _gd_files(dir: String) -> Array:
	var out: Array = []
	var da := DirAccess.open(dir)
	if da == null:
		return out
	da.list_dir_begin()
	var n: String = da.get_next()
	while n != "":
		var full: String = dir + "/" + n
		if da.current_is_dir():
			if not n.begins_with("."):
				out.append_array(_gd_files(full))
		elif n.ends_with(".gd"):
			out.append(full)
		n = da.get_next()
	return out
