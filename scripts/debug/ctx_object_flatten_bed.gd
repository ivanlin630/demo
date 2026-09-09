extends SceneTree
# @bed-kind: acceptance
# slice: camp_target_est 攤平（★同一個改動點解兩件事：交本體 ＋ 看不懂）
#
# ★★而本床的形狀是【界限第十一條】的直接兌現（systems 2026-09-10 立）：
#   上一格守衛叫「改回傳值 ⇒ 引擎不得跟著變」，★實際只戳了 dict 的鍵
#   ⇒ duplicate(true) 不深拷【物件】，外層副本、裡面那顆仍是本體，而它綠得理直氣壯。
#   ⇒ ★★★所以這一格的斷言下在【物件層】：快照裡【不得有任何物件】，
#      而不是「camp_target_est 這一欄不是物件」——後者只擋得住我們今天知道的那一顆。

var _fails: int = 0
var _sections: int = 0
const EXPECT_SECTIONS: int = 3

func _initialize() -> void:
	print("=== CTX 物件攤平床 ===")
	var st := _mk()
	_test_readable(st)
	_test_no_object_anywhere(st)
	_test_mutation_isolated(st)
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
	seed(909)
	var st := WorldState.new()
	st.world = WorldData.new()
	st.world.current_tick = 1440
	for i in range(3):
		var tile := HexTileData.new()
		tile.tile_id = i * 1000 + i
		tile.tile_pos = Vector2i(i, i)
		tile.terrain = "plains"
		st.world.tiles[tile.tile_id] = tile
	var t := TeamData.new()
	t.team_id = 3
	t.tile_pos = Vector2i(1, 1)
	t.resources["food"] = 100.0
	AnonTierSystem.add_anon(t, "平民", 6)
	var ldr := PersonData.new()
	ldr.id = 30
	ldr.team_id = 3
	ldr.person_name = "攤平測試領袖"
	st.persons[30] = ldr
	t.leader_id = 30
	st.teams[3] = t
	st.player_id = 30
	DecisionContext.gather(st, t, true)
	return st

func _fields(st: WorldState) -> Dictionary:
	var q := PlayerQueryApi.new()
	return (q.get_decision_snapshot(st).get("data", {}) as Dictionary).get("fields", {})

# ★遞迴找物件：★★這個掃描器本身要有陽性對照，否則「零命中」可能只是它認不得物件
func _find_objects(v, path: String, out: Array, depth: int = 0) -> void:
	if depth > 6:
		return
	if v is Object and not (v is Callable):
		out.append(path)
	elif v is Dictionary:
		for k in (v as Dictionary):
			_find_objects((v as Dictionary)[k], "%s.%s" % [path, str(k)], out, depth + 1)
	elif v is Array:
		var i: int = 0
		for e in (v as Array):
			_find_objects(e, "%s[%d]" % [path, i], out, depth + 1)
			i += 1

func _test_readable(st: WorldState) -> void:
	print("-- ① 看得懂：camp_target_est 是可讀 dict，不是〈物件〉--")
	var f: Dictionary = _fields(st)
	var v = f.get("camp_target_est", null)
	if v == null:
		# ★誠實：這個世界沒有可紮營靶地時它本來就是 null ⇒ 那不是攤平失敗，
		#   ★★但它也代表【這一格沒被測到】—— 說出來，不要當綠。
		_ok(false, "①camp_target_est 是 null（★這個母體沒有靶地 ⇒ 本格【沒有測到】，不是綠）")
		_sections += 1
		return
	_ok(v is Dictionary, "①它現在是 Dictionary（原本是 VillageEstimate 物件）")
	var d: Dictionary = v
	print("    %s" % str(d))
	_ok(String(d.get("_kind", "")) == "village_estimate",
		"①★留著它原本是什麼（_kind=village_estimate）—— 攤平不該把來歷抹掉")
	for k in ["terrain", "outpost_level", "farming_level", "pop"]:
		_ok(d.has(k), "①欄位 %s 攤出來了" % k)
	_sections += 1

func _test_no_object_anywhere(st: WorldState) -> void:
	print("-- ② ★★物件層：整份快照裡【不得有任何物件】（不是只有 camp_target_est 那一欄）--")
	var f: Dictionary = _fields(st)
	var found: Array = []
	_find_objects(f, "fields", found)
	print("    掃到的物件：%s" % str(found))
	_ok(found.is_empty(), "②整份快照零物件（%d 欄）" % f.size())
	# ★陽性對照：掃描器認不認得物件（否則「零命中」可能是它瞎了）
	var faux: Dictionary = {"a": {"b": [VillageEstimate.make("plains", 1, 0, 5)]}}
	var found2: Array = []
	_find_objects(faux, "faux", found2)
	_ok(found2.size() == 1 and String(found2[0]) == "faux.a.b[0]",
		"②★陽性對照：塞一顆物件進巢狀結構 ⇒ 掃描器【具名】抓到（%s）" % str(found2))
	_sections += 1

func _test_mutation_isolated(st: WorldState) -> void:
	print("-- ③ 安全性：改攤平後的回傳值 ⇒ 引擎那份不得跟著變 --")
	var f: Dictionary = _fields(st)
	var before_snapshot: Dictionary = (st.teams[3] as TeamData).ctx_snapshot.duplicate(true)
	# 深處改一刀：巢狀 dict 的欄位
	var target = f.get("camp_target_est", null)
	if target is Dictionary:
		(target as Dictionary)["pop"] = -999
		(target as Dictionary)["__probe__"] = true
	f["food_stock"] = -12345.0
	var after: Dictionary = (st.teams[3] as TeamData).ctx_snapshot
	var same: bool = true
	for k in before_snapshot:
		if str(before_snapshot[k]) != str(after.get(k, "<缺>")):
			same = false
			print("    ★引擎那份被改到了：%s" % k)
	_ok(same, "③改回傳值（含【巢狀 dict 深處】那一刀）⇒ 引擎的 ctx_snapshot 一欄都沒變")
	# ★對照的另一半：直接改引擎那份 ⇒ 下一次查詢【必須】看得到（證明查的是真快照不是快取）
	(st.teams[3] as TeamData).ctx_snapshot["food_stock"] = 777.0
	var f2: Dictionary = _fields(st)
	_ok(abs(float(f2.get("food_stock", 0.0)) - 777.0) < 0.001,
		"③★另一半：改引擎那份 ⇒ 下一次查詢看得到（否則上面那格可能只是查詢面壞了）")
	_sections += 1
