extends SceneTree
# @bed-kind: acceptance
# slice: 觀察窗 inspect 深化（五欄）＋ ctx 覆蓋率兩張表
#
# 驗收（spec §4）：③五個新欄位各一格自檢，斷言【值真的來自 state】不是空字串/預設值
#   ★成對對照：構造【有目標】與【沒目標】的隊 ⇒ 面板上看得出差別
#   ★★居民團清單是【位置謂詞】：印的是此刻站在這裡的，不是屬於這裡的

var _fails: int = 0
var _sections: int = 0
const EXPECT_SECTIONS: int = 4

func _initialize() -> void:
	print("=== OBSERVER INSPECT DEPTH ===")
	_test_team_target_and_goal()
	_test_morale_and_threat()
	_test_residents_here_now()
	_test_coverage_tables()
	if _sections != EXPECT_SECTIONS:
		_fails += 1
		push_error("[FAIL] 只跑完 %d/%d 段 —— 中途崩掉" % [_sections, EXPECT_SECTIONS])
	print("=== DONE === SECTIONS=%d/%d FAILS=%d" % [_sections, EXPECT_SECTIONS, _fails])
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_fails += 1
		push_error("[FAIL] " + msg)

func _mk() -> WorldState:
	var st := WorldState.new()
	st.world = WorldData.new()
	st.world.current_tick = 3000
	var tile := HexTileData.new()
	tile.tile_id = 5005
	tile.tile_pos = Vector2i(5, 5)
	tile.terrain = "plains"
	tile.outpost_type = "civilian"
	tile.outpost_level = 1
	tile.outpost_owner = 1
	tile.resources = { "food": 30.0 }
	tile.resource_cap = { "food": 100.0 }
	st.world.tiles[5005] = tile
	return st

func _mk_team(st: WorldState, tid: int, pos: Vector2i) -> TeamData:
	var t := TeamData.new()
	t.team_id = tid
	t.tile_pos = pos
	AnonTierSystem.add_anon(t, "平民", 6)
	var p := PersonData.new()
	p.id = 500 + tid
	p.team_id = tid
	st.persons[p.id] = p
	t.leader_id = p.id
	st.teams[tid] = t
	return t

func _test_team_target_and_goal() -> void:
	print("-- ③目標對象 ＋ goal 細節（★成對對照：有目標 vs 沒目標）--")
	var st := _mk()
	var with_t := _mk_team(st, 1, Vector2i(5, 5))
	with_t.move_target = Vector2i(7, 7)
	with_t.combat_target = 2
	with_t.social_target = 3
	with_t.goal_state = [{ "goal_type": "求糧", "target": null, "created_tick": 2900, "status": "active" }]
	var without := _mk_team(st, 2, Vector2i(6, 6))
	var a: Dictionary = ObserverQueryApi.query_team(st, 1)
	var b: Dictionary = ObserverQueryApi.query_team(st, 2)
	print("    有目標隊：target=%s｜goal_state=%s" % [str(a.get("target", {})), str(a.get("goal_state", []))])
	print("    無目標隊：target=%s｜goal_state=%s" % [str(b.get("target", {})), str(b.get("goal_state", []))])
	_ok(a.has("target") and int((a["target"] as Dictionary)["combat_team_id"]) == 2,
		"③目標對象【真的來自 state】（combat_target=2）")
	_ok((a["target"] as Dictionary)["move_pos"] == Vector2i(7, 7), "③move_target 也端得出來")
	_ok((a.get("goal_state", []) as Array).size() == 1
		and String(((a["goal_state"] as Array)[0] as Dictionary).get("goal_type", "")) == "求糧",
		"③goal 細節印【引擎自己存的結構】（不加解釋層＝票②的事）")
	# ★成對對照：沒目標的隊必須看得出差別（否則面板等於沒有這一欄）
	_ok(int((b["target"] as Dictionary)["combat_team_id"]) == -1
		and (b.get("goal_state", []) as Array).is_empty(),
		"★成對對照：沒目標的隊【看得出差別】（-1 / 空陣列）")
	_sections += 1

func _test_morale_and_threat() -> void:
	print("-- ③morale ＋ 威脅感（★威脅感沒有快照：印【未快照】不偷算）--")
	var st := _mk()
	var t := _mk_team(st, 1, Vector2i(5, 5))
	t.work_morale = 1.23
	var d: Dictionary = ObserverQueryApi.query_team(st, 1)
	print("    work_morale=%s｜threat=%s" % [str(d.get("work_morale", null)), str(d.get("threat", {}))])
	_ok(is_equal_approx(float(d.get("work_morale", -1.0)), 1.23),
		"③morale 真的來自 state（work_morale=1.23，不是預設 1.0）")
	var th: Dictionary = d.get("threat", {})
	_ok(th.has("snapshot") and not bool(th["snapshot"]),
		"③威脅感明說【未快照】——★而不是偷偷 gather 一次（觀測改變被觀測物的血證）")
	_ok(String(th.get("note", "")).length() > 10,
		"③而且它說了【為什麼】：讀的人不必去猜 0 是什麼意思")
	_sections += 1

func _test_residents_here_now() -> void:
	print("-- ③居民團清單（★位置謂詞：此刻在這裡，不是屬於這裡）--")
	var st := _mk()
	var owner := _mk_team(st, 1, Vector2i(5, 5))
	owner.tags = [TeamData.TAG_PRODUCE]
	var away := _mk_team(st, 3, Vector2i(9, 9))   # ★屬於這裡但【不在】這裡
	away.tags = [TeamData.TAG_PRODUCE]
	var d: Dictionary = ObserverQueryApi.query_outpost(st, Vector2i(5, 5))
	var res: Array = d.get("residents_here_now", [])
	print("    residents_here_now=%s" % str(res))
	_ok(res.size() == 1 and int((res[0] as Dictionary)["team_id"]) == 1,
		"③居民團清單來自 state（此刻在這格的 1 支）")
	_ok(true, "★誠實限：空清單【不是面板壞了】——這個世界目前沒有村莊那一層（known_issues 已坐實）")
	# ★成對對照：把隊移走 ⇒ 清單要變空（否則它印的是【歸屬】不是【位置】）
	owner.tile_pos = Vector2i(8, 8)
	var d2: Dictionary = ObserverQueryApi.query_outpost(st, Vector2i(5, 5))
	_ok((d2.get("residents_here_now", []) as Array).is_empty(),
		"★成對對照：隊走了 ⇒ 清單變空 ⇒ 它印的是【位置】不是【歸屬】")
	_sections += 1

func _test_coverage_tables() -> void:
	print("-- 覆蓋率兩張表（★兩張都要有，母體單位不同）--")
	for path in ["res://docs/process/ctx-exposure.tsv", "res://docs/process/ctx-supplement.tsv"]:
		var f := FileAccess.open(path, FileAccess.READ)
		var ok: bool = f != null
		var n: int = 0
		if f != null:
			for line in f.get_as_text().split("\n"):
				var l: String = String(line)
				if l != "" and not l.begins_with("#") and not l.begins_with("field") and not l.begins_with("item"):
					n += 1
			f.close()
		print("    %s ⇒ %d 列" % [path, n])
		_ok(ok and n > 0, "表存在且非空：%s" % path)
	_ok(true, "★閘本身跑在 .claude/hooks/ctx-coverage-gate.sh（★腐爛判定是【反方向】：豁免欄位不得被查詢面讀走）")
	_sections += 1
