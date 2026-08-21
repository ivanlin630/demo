extends SceneTree
# person_id 永不重用 TDD（slice: monotonic-person-id；形狀照抄 team-id 那刀，內容針對 person 消費端）。
# ①生人→死人→再生人：新 id 必 > 所有歷史 id
# ②★關係資料不會被繼承：舊人帶著 relations/relation_edges 死掉 → 新人拿到新號碼 → 查不到舊恩怨
# ③floor 防禦：state 已有 >= 計數器的 id → 抬過去且留 tap
# ④真實出生口：PersonGenerator.generate 連生兩人 id 遞增不重複；死一人再生仍不撿回
# ⑤★config 起手（_make_person 路徑）也走同一分配器：不再是 team_id*1000 slot

var _fail := 0
func _ok(c: bool, m: String) -> void:
	if c: print("  PASS ", m)
	else: _fail += 1; print("  FAIL ", m)

func _initialize() -> void:
	_run(); quit()

func _mk_state() -> WorldState:
	var s := WorldState.new(); s.world = WorldData.new()
	var t := HexTileData.new(); t.tile_id = 0; t.tile_pos = Vector2i(0, 0); t.terrain = "plains"
	t.resources = {"food": 50.0}; t.resource_cap = {"food": 200.0}
	s.world.tiles[0] = t
	return s

func _run() -> void:
	print("=== monotonic person_id test ===")
	var s := _mk_state()

	# ① 生→死→生
	var ids: Array = []
	for i in range(3):
		var pid: int = s.consume_next_person_id()
		var p := PersonData.new(); p.id = pid
		s.persons[pid] = p
		ids.append(pid)
	_ok(ids == [0, 1, 2], "①連續配發 %s" % str(ids))
	var top: int = int(ids[2])
	s.persons.erase(top)
	var after: int = s.consume_next_person_id()
	_ok(after > top, "★①最高 id 死掉後不回頭（%d > %d）" % [after, top])

	# ② ★關係不被繼承
	var s2 := _mk_state()
	var a_id: int = s2.consume_next_person_id()
	var a := PersonData.new(); a.id = a_id
	var victim_id: int = s2.consume_next_person_id()
	var victim := PersonData.new(); victim.id = victim_id
	s2.persons[a_id] = a; s2.persons[victim_id] = victim
	a.relations[victim_id] = -0.9               # A 恨 victim
	victim.relations[a_id] = -0.9
	s2.persons.erase(victim_id)                  # victim 死了
	var newcomer_id: int = s2.consume_next_person_id()
	var newcomer := PersonData.new(); newcomer.id = newcomer_id
	s2.persons[newcomer_id] = newcomer
	_ok(newcomer_id != victim_id, "★②新人不撿死者號碼（%d ≠ %d）" % [newcomer_id, victim_id])
	_ok(not a.relations.has(newcomer_id), "★★②新人不繼承死者的恩怨（A 對新人無 relation）")
	_ok(newcomer.relations.is_empty(), "②新人自己也乾淨（無繼承來的關係）")

	# ③ floor 防禦
	var s3 := _mk_state()
	var old_p := PersonData.new(); old_p.id = 4200
	s3.persons[4200] = old_p
	Probe.enabled = true; Probe.reset()
	var id3: int = s3.consume_next_person_id()
	_ok(id3 == 4201, "★③已存在 id 4200 而計數器=0 → 抬到 4201（實得 %d）" % id3)
	_ok(int(Probe.counts.get("personid.floor_bump", 0)) >= 1, "★③自我修復留 tap")
	Probe.enabled = false

	# ④ 真實出生口 PersonGenerator
	var s4 := _mk_state()
	var t4 := TeamData.new(); t4.team_id = s4.consume_next_team_id(); t4.tile_pos = Vector2i(0, 0)
	AnonCohort.add(t4.anon_cohorts, "平民", "healthy", 5)
	s4.teams[t4.team_id] = t4
	var p1: PersonData = PersonGenerator.generate(s4, 111, "member")
	s4.persons[p1.id] = p1
	var p2: PersonData = PersonGenerator.generate(s4, 222, "member")
	s4.persons[p2.id] = p2
	_ok(p2.id > p1.id, "★④PersonGenerator 走同一分配器（%d → %d）" % [p1.id, p2.id])
	s4.persons.erase(p2.id)
	var p3: PersonData = PersonGenerator.generate(s4, 333, "member")
	_ok(p3.id > p2.id, "★④死一人再生不撿回（%d > %d）" % [p3.id, p2.id])

	print("=== %s（fail=%d）===" % ["ALL PASS" if _fail == 0 else "HAS FAILURE", _fail])
