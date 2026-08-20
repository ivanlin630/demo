extends SceneTree
# specimen 選樣血緣封閉 TDD（slice: specimen-lineage-scope）。
# ①母隊在清單 → 子隊自動在範圍（執行期生成的 porter 也算）
# ②孫隊（子的子）亦在範圍 ③無血緣他隊不在範圍
# ④enabled=false → 一律 false（零成本 gate 不變）
# ⑤★環狀 parent 不掛（深度上限保護）
# ⑥★純觀測：判定本身不改任何 state（specimen_team_ids 不被寫入）

var _fail := 0
func _ok(c: bool, m: String) -> void:
	if c: print("  PASS ", m)
	else: _fail += 1; print("  FAIL ", m)

func _initialize() -> void:
	_run(); quit()

func _mk_team(s: WorldState, tid: int, parent: int) -> TeamData:
	var t := TeamData.new(); t.team_id = tid; t.tile_pos = Vector2i(0, 0)
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", 3)
	s.teams[tid] = t
	if parent != -1: s.set_subteam_parent(t, parent)
	return t

func _run() -> void:
	print("=== specimen lineage scope test ===")
	var s := WorldState.new(); s.world = WorldData.new()
	_mk_team(s, 5, -1)        # 母隊（在清單）
	_mk_team(s, 12, 5)        # porter 子隊（執行期才生成）
	_mk_team(s, 13, 12)       # 孫隊
	_mk_team(s, 99, -1)       # 無關他隊
	s.specimen_team_ids = [5]
	SpecimenTracer.enabled = true

	_ok(SpecimenTracer.is_specimen(s, 5), "①母隊本身在範圍")
	_ok(SpecimenTracer.is_specimen(s, 12), "★①子隊自動在範圍（靜態清單沒有它）")
	_ok(SpecimenTracer.is_specimen(s, 13), "②孫隊亦在範圍")
	_ok(not SpecimenTracer.is_specimen(s, 99), "③無血緣他隊不在範圍")

	var before: Array = s.specimen_team_ids.duplicate()
	SpecimenTracer.is_specimen(s, 12)
	_ok(s.specimen_team_ids == before, "★⑥判定不寫 state（純觀測、清單未被擴寫）")

	# ⑤ 環狀保護：12 ↔ 14 互為 parent（病態資料）→ 不得無限迴圈
	var t14 := _mk_team(s, 14, -1)
	t14.parent_team_id = 12
	s.teams[12].parent_team_id = 14
	s.specimen_team_ids = [99]   # 讓鏈上沒有命中 → 必須靠深度上限收斂
	_ok(not SpecimenTracer.is_specimen(s, 14), "★⑤環狀 parent 不掛（深度上限收斂、回 false）")

	SpecimenTracer.enabled = false
	s.specimen_team_ids = [5]
	_ok(not SpecimenTracer.is_specimen(s, 5) and not SpecimenTracer.is_specimen(s, 12),
		"④enabled=false → 一律 false（零成本 gate）")

	print("=== %s（fail=%d）===" % ["ALL PASS" if _fail == 0 else "HAS FAILURE", _fail])
