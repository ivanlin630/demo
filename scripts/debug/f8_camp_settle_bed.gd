extends SceneTree
# @bed-kind: invariant
# slice: 友善度 F8 第三版（spec 2026-10-07 round5-friendliness §F8，藍圖裁 (i) 7d10ddb4a＋用戶裁 e1a09f429）
#   玩家紮營＝L0（establish_crude_camp）、紮根＝第二步；據點間距（2／11、NPC 選址 min_dist）與山地禁紮整條退場，只留「同格已有」
#
# P8a 緊鄰既有村的平地 ⇒ 紮營可｜山地 ⇒ 紮營可｜同格已有據點或營地 ⇒ 不可，原因照實
# P8b 緊鄰同類據點處先紮營（當場 L0）、再紮根 ⇒ 可（工期＝settle）
# P8c NPC：establish_crude_camp 在緊鄰村的格與山地 ⇒ true｜NPC 選址距中心 1 格的候選不再被排除
# P8d 紮營後營地欄＝座標、家欄不變；紮根完工 ⇒ 家欄＝那座據點、營地欄＝無｜反向：快照沒有 camp_pos 鍵 ⇒「？」不印「無」
# P8e 站在自己營地上 ⇒ 動作清單有「紮根」；空地 ⇒ 沒有｜紮根施工中再按 ⇒ 不可、工期不變
# P8f grep：間距常數／距離檢查／「山地無法紮營」在 scripts/ 出現 0 次｜crude_camp 工程設點只准一處
# （P8g 的 30 天改前改後數字在 f8_camp_spacing_measure.gd，量測產物落 docs/measurements/）
#
# ★修前不存在的函式（precheck_settle／_action_settle／_site_candidate_ok）用 has_method／call 動態呼
#   ⇒ 修前紅在格上，不讓整支床 parse 失敗
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/f8_camp_settle_bed.gd

var _errors: int = 0
# ★修前沒有 _camp_pos ⇒ 經 Script 動態呼（靜態引用會讓整支床 parse 失敗）
const MAPPER: Script = preload("res://scripts/simulation/player_api_mapper.gd")


func _check(msg: String, cond: bool) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_errors += 1
		push_error("[FAIL] " + msg)


func _fresh() -> WorldState:
	seed(20261008)
	var st: WorldState = MeasureBedHelper.arm_and_new()
	GameSetup.setup(st, GameSetup.load_config("res://config/warring_states.json"))
	return st


static func _tile(st: WorldState, p: Vector2i) -> HexTileData:
	return st.world.tiles.get(p.x * 1000 + p.y)


# 找一座既有村（outpost_level>0）與它旁邊一格平地（沒有據點、沒有營地）
static func _village_and_neighbor(st: WorldState, terrain: String) -> Array:
	var ids: Array = st.world.tiles.keys()
	ids.sort()
	for k in ids:
		var t: HexTileData = st.world.tiles[k]
		if t.outpost_level <= 0:
			continue
		for d in PathSystem.HEX_DIRS:
			var n: HexTileData = _tile(st, t.tile_pos + d)
			if n != null and n.outpost_level == 0 and n.outpost_owner == -1 and n.camp_level == 0 \
					and n.construction_team_id == -1 and n.terrain == terrain:
				return [t, n]
	return []


static func _any_tile(st: WorldState, terrain: String) -> HexTileData:
	var ids: Array = st.world.tiles.keys()
	ids.sort()
	for k in ids:
		var t: HexTileData = st.world.tiles[k]
		if t.terrain == terrain and t.outpost_level == 0 and t.outpost_owner == -1 and t.camp_level == 0:
			return t
	return null


func _initialize() -> void:
	print("=== F8 玩家紮營＝L0、紮根＝第二步；間距與山地禁令退場 ===")
	_p8a_p8b_p8d_p8e()
	_p8c()
	_p8d_reverse()
	_p8f()
	print("\n=== f8_camp_settle DONE === errors: %d" % _errors)
	quit(1 if _errors > 0 else 0)


func _p8a_p8b_p8d_p8e() -> void:
	print("\n── P8a 紮營可不可（緊鄰村的平地／山地／同格已有）──")
	var st: WorldState = _fresh()
	var cs := PlayerCommandSystem.new()
	var ptid: int = st.get_player_team_id()
	var pt: TeamData = st.teams[ptid]
	var vn: Array = _village_and_neighbor(st, "plains")
	_check("★母體地板：找得到「既有村＋旁邊一格平地」", vn.size() == 2)
	if vn.size() != 2:
		return
	pt.tile_pos = (vn[1] as HexTileData).tile_pos
	var r1: Dictionary = cs.precheck_camp(st, pt)
	print("   緊鄰村的平地 ⇒ %s" % str(r1))
	_check("P8a 緊鄰既有村的平地 ⇒ 紮營可", bool(r1.get("ok", false)))
	var mt: HexTileData = _any_tile(st, "mountain")
	_check("★母體地板：有一格空山地", mt != null)
	if mt != null:
		pt.tile_pos = mt.tile_pos
		var r2: Dictionary = cs.precheck_camp(st, pt)
		print("   山地 ⇒ %s" % str(r2))
		_check("P8a 山地 ⇒ 紮營可", bool(r2.get("ok", false)))
	pt.tile_pos = (vn[0] as HexTileData).tile_pos
	var r3: Dictionary = cs.precheck_camp(st, pt)
	print("   同格已有據點 ⇒ %s" % str(r3))
	_check("P8a 同格已有據點 ⇒ 不可「此地已有據點」", not bool(r3.get("ok", true)) and String(r3.get("reason", "")) == "此地已有據點")

	print("\n── P8b／P8d／P8e 緊鄰村處先紮營（當場 L0）、再紮根（工期＝settle）──")
	var camp_tile: HexTileData = vn[1]
	pt.tile_pos = camp_tile.tile_pos
	var home0 = PlayerApiMapper._home_pos(st, pt)
	var rc: Dictionary = cs._action_camp(st, -1, pt, ptid)
	print("   紮營 ⇒ %s｜camp_level=%d camp_team_id=%d" % [str(rc), camp_tile.camp_level, camp_tile.camp_team_id])
	_check("P8b 紮營當場是 L0 營地（camp_level＝1、起建隊＝玩家），不是 L1 工程", camp_tile.camp_level == 1 and camp_tile.camp_team_id == ptid and camp_tile.outpost_level == 0)
	var r4: Dictionary = cs.precheck_camp(st, pt)
	_check("P8a 同格已有營地 ⇒ 不可「此地已有營地」", not bool(r4.get("ok", true)) and String(r4.get("reason", "")) == "此地已有營地")
	var cpos = MAPPER.call("_camp_pos", st, pt) if _has_static(MAPPER, "_camp_pos") else "（無此欄）"
	print("   營地欄 ＝ %s｜家欄 ＝ %s（紮營前 %s）" % [str(cpos), str(PlayerApiMapper._home_pos(st, pt)), str(home0)])
	_check("P8d 紮營後營地欄＝那一格、家欄不變", typeof(cpos) == TYPE_DICTIONARY and int(cpos.get("q", -9)) == camp_tile.tile_pos.x \
		and int(cpos.get("r", -9)) == camp_tile.tile_pos.y and str(PlayerApiMapper._home_pos(st, pt)) == str(home0))
	# P8e：動作清單有「紮根」
	var ids_here: Array = _self_action_ids(st)
	print("   站在自己營地上 ⇒ 自家隊動作 %s" % str(ids_here))
	_check("P8e 站在自己營地上 ⇒ 動作清單有「紮根」", ids_here.has("settle"))
	var has_settle_cmd: bool = cs.has_method("_action_settle")
	_check("★P8b：紮根有自己的動作（_action_settle）", has_settle_cmd)
	if has_settle_cmd:
		var rs: Dictionary = cs.call("_action_settle", st, -1, pt, ptid)
		var want: int = OutpostSystem.build_person_hours("settle", 1)
		print("   紮根 ⇒ %s｜construction_ticks_left=%d（settle 工期 %d）" % [str(rs), camp_tile.construction_ticks_left, want])
		_check("P8b 紮根開工、工期＝settle", bool(rs.get("ok", false)) and camp_tile.construction_ticks_left == want and camp_tile.construction_team_id == ptid)
		camp_tile.construction_ticks_left = want - 5   # 佈置：已施工一點
		var pr: Dictionary = cs.call("precheck_settle", st, pt) if cs.has_method("precheck_settle") else {}
		var rs2: Dictionary = cs.call("_action_settle", st, -1, pt, ptid)
		print("   施工中再按 ⇒ precheck %s｜handler %s｜工期 %d" % [str(pr), str(rs2), camp_tile.construction_ticks_left])
		_check("P8e 紮根施工中再按 ⇒ 不可（原因「紮根施工中」）、工期不變",
			not bool(pr.get("ok", true)) and String(pr.get("reason", "")).begins_with("紮根施工中") \
			and not bool(rs2.get("ok", true)) and camp_tile.construction_ticks_left == want - 5)
		# P8d：完工 ⇒ 家＝那座據點、營地＝無
		camp_tile.construction_ticks_left = 1
		var runner := SimRunner.new()
		for _i in range(WorldState.TICKS_PER_DAY):
			if camp_tile.outpost_level > 0:
				break
			runner.advance_tick(st, Vector2i(-1, -1))
		var cpos2 = MAPPER.call("_camp_pos", st, pt) if _has_static(MAPPER, "_camp_pos") else "（無此欄）"
		var home2 = PlayerApiMapper._home_pos(st, pt)
		print("   完工後 outpost_level=%d｜家 %s｜營地 %s" % [camp_tile.outpost_level, str(home2), str(cpos2)])
		_check("P8d 紮根完工 ⇒ 家欄＝那座據點、營地欄＝無（null）",
			camp_tile.outpost_level > 0 and home2 != null and cpos2 == null)
	# P8e 反向：空地沒有「紮根」
	var plain2: HexTileData = _any_tile(st, "plains")
	if plain2 != null:
		pt.tile_pos = plain2.tile_pos
		var ids_plain: Array = _self_action_ids(st)
		_check("P8e【反向】空地 ⇒ 動作清單沒有「紮根」", not ids_plain.has("settle"))


static func _has_static(cls, fn: String) -> bool:
	for m in (cls as Script).get_script_method_list():
		if String(m.get("name", "")) == fn:
			return true
	return false


static func _self_action_ids(st: WorldState) -> Array:
	var out: Array = []
	var qa := PlayerQueryApi.new()
	var env: Dictionary = qa.get_available_actions(st, {})
	for a in (env.get("data", {}) as Dictionary).get("actions", []):
		var tr: Dictionary = a.get("target_requirements", {})
		if not ("team" in tr.get("allowed_kinds", PackedStringArray())):
			out.append(String(a.get("action_id", "")))
	return out


func _p8c() -> void:
	print("\n── P8c NPC：緊鄰村的格與山地可立營；選址距中心 1 格的候選不再被排除 ──")
	var st: WorldState = _fresh()
	var fa := FactionAISystem.shared()
	var npc: TeamData = null
	var ids: Array = st.teams.keys()
	ids.sort()
	for k in ids:
		if int(k) != st.get_player_team_id() and st.teams[k].leader_id != -1:
			npc = st.teams[k]
			break
	_check("★母體地板：有一支 NPC 隊", npc != null)
	if npc == null:
		return
	var vn: Array = _village_and_neighbor(st, "plains")
	if vn.size() == 2:
		npc.tile_pos = (vn[1] as HexTileData).tile_pos
		_check("P8c NPC 在緊鄰村的平地 establish_crude_camp ⇒ true", fa.establish_crude_camp(st, npc))
	var mt: HexTileData = _any_tile(st, "mountain")
	if mt != null:
		npc.tile_pos = mt.tile_pos
		_check("P8c NPC 在山地 establish_crude_camp ⇒ true", fa.establish_crude_camp(st, npc))
	var ok1: bool = fa.has_method("_site_candidate_ok") and bool(fa.call("_site_candidate_ok", 1, false))
	print("   選址候選：距中心 1 格（非礦山）⇒ %s" % str(ok1))
	_check("P8c NPC 選址：距中心 1 格的候選不再被 min_dist 排除", ok1)
	_check("P8c NPC 選址：搜尋半徑照舊（距中心 6 格非礦山 ⇒ 不是候選）",
		fa.has_method("_site_candidate_ok") and not bool(fa.call("_site_candidate_ok", 6, false)))


func _p8d_reverse() -> void:
	print("\n── P8d 反向：快照沒有 camp_pos 鍵 ⇒ 營地欄印「？」不印「無」；鍵在而 null ⇒「無」──")
	var base: Dictionary = {"clock": "1 天 00:00", "team_name": "T", "pop": "1", "home": "（無）", "food": "1 天",
		"threat": "—", "pending": "0 道"}
	var no_key: String = TextUiView.top_row(base)
	var with_null: Dictionary = base.duplicate()
	with_null["camp"] = "無"
	var nul: String = TextUiView.top_row(with_null)
	print("   沒有鍵 ⇒ %s\n   有鍵（無）⇒ %s" % [no_key, nul])
	_check("P8d 沒有寫入者 ⇒「營地：？」", no_key.contains("營地：？"))
	_check("P8d 寫入者說沒有 ⇒「營地：無」", nul.contains("營地：無"))


func _p8f() -> void:
	print("\n── P8f grep：間距規則與山地禁紮在 scripts/ 出現 0 次；crude_camp 工程設點只准一處 ──")
	# ★字面用拼接（本檔自己不能命中自己）
	var pats: Array = ["MIN_DIST" + "_", "_check" + "_distance", "山地無法" + "紮營"]
	var hits: Dictionary = {}
	var setpoints: Array = []
	var crude_pat: String = "\"action\": \"crude" + "_camp\""
	for f in _gd_files("res://scripts"):
		var txt: String = FileAccess.get_file_as_string(f)
		for p in pats:
			if txt.contains(String(p)):
				hits[f + "｜" + String(p)] = txt.count(String(p))
		if String(f).begins_with("res://scripts/simulation") and txt.contains(crude_pat):
			for _i in range(txt.count(crude_pat)):
				setpoints.append(f)
	print("   命中：%s" % str(hits))
	print("   crude_camp 工程設點：%s" % str(setpoints))
	_check("P8f 間距常數／距離檢查／「山地無法紮營」在 scripts/ 出現 0 次（%d 處）" % hits.size(), hits.is_empty())
	_check("P8f crude_camp 工程設點只准一處（共用函式）（%d）" % setpoints.size(), setpoints.size() == 1)


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
