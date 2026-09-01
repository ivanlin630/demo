extends SceneTree
# @observe-pure
# ★★★A#14 驗收③④：**觀測不得改變被觀測物**（systems 2026-09-02）
#   ①tracer 開 / 關，跑同一個世界 ⇒ ★三把尺三跑必須逐位元相同
#   ②★而【不要只用 state_fingerprint】：它排除 ephemeral/cadence 欄，對這類污染 structurally 瞎眼
#   ③★★所以三把一起報：fp（決策/生命週期）＋ ephemeral（快取/排程）＋ ★★★full（反射掃全部屬性）

# ★★★為什麼用【手工小世界】而不是 peaceful_economy（2026-09-02 實測逼出來的）：
#   ★peaceful_economy 一天 1440 tick／12 隊 ＝ ★★單跑約 7 分鐘（實測 max 單 tick 1.9 秒）
#   ⇒ 三跑對照要 20 分鐘以上，兩次都撞 GODOT_TIMEOUT 900s 被殺
#   ⇒ ★★★而純度問題【不需要真 config】：它需要的是「同一個世界跑兩次、tracer 開與關」
#     ⇒ 小世界一樣證得了，而且證得起（秒級）。★大世界那條另記在誠實限。
func _mk_team(state: WorldState, tid: int, pos: Vector2i, pop: int) -> TeamData:
	var t := HexTileData.new()
	t.tile_id = pos.x * 1000 + pos.y; t.tile_pos = pos; t.terrain = "plains"
	t.outpost_owner = -1; t.outpost_level = 0
	state.world.tiles[t.tile_id] = t
	var ldr := PersonData.new(); ldr.id = tid * 100 + 1
	ldr.team_id = tid
	ldr.values = {"好戰": 0.4, "野心": 0.5, "求生欲": 0.4, "慎重": 0.4}
	ldr.skills = {"戰鬥": 0.3, "統領": 0.4, "生產": 0.4}
	state.persons[ldr.id] = ldr
	var team := TeamData.new(); team.team_id = tid; team.leader_id = ldr.id
	team.tile_pos = pos; team.current_task = TeamData.TASK_IDLE
	state.teams[tid] = team
	state.add_member(team, ldr.id)
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", maxi(pop - 1, 0))
	team.resources = {"food": 120.0, "material": 20.0}
	return team

func _run_once(tracer_on: bool, ticks: int) -> Dictionary:
	var state := MeasureBedHelper.arm_and_new()
	seed(1337)
	for i in range(4):
		_mk_team(state, i, Vector2i(3 + i * 2, 5), 6)
	SpecimenTracer.reset()
	if tracer_on:
		# ★★★3 也要進 specimen —— 否則中途被殺的那隊不是 specimen ⇒ `capture_death` 不 fire
		#   ⇒ 這張床會【綠著】而【根本沒驗到本票新掛的那條路】（第一版就是這樣，deaths=0）
		state.specimen_team_ids = [0, 1, 3]
		SpecimenTracer.enabled = true
	var runner := SimRunner.new()
	for t in range(ticks):
		runner.advance_tick(state, Vector2i(-1, -1))
		# ★中途殺一隊 ⇒ 走到本票掛的那個窄口（否則這張床驗不到 capture_death 那條路）
		if t == int(ticks / 2) and state.teams.has(3):
			state.erase_team(3)
	return {
		"fp": StateFingerprint.compute(state),
		"eph": EphemeralStateHash.compute(state),
		"full": FullStateHash.compute(state),
		"entries": SpecimenTracer.entries.size(),
		"deaths": SpecimenTracer.death_count,
	}

func _init() -> void:
	var ticks: int = int(OS.get_environment("BED_TICKS")) if OS.has_environment("BED_TICKS") else 400
	print("=== A#14 觀測純度（tracer on/off × 三把尺）｜ticks=%d（手工小世界，理由見 _run_once 檔內）===" % ticks)
	print(EphemeralStateHash.note())
	print(FullStateHash.note())
	var off1 := _run_once(false, ticks)
	var on1  := _run_once(true,  ticks)
	var off2 := _run_once(false, ticks)
	var fail := 0
	for k in ["fp", "eph", "full"]:
		var same_off: bool = off1[k] == off2[k]
		var on_matches: bool = on1[k] == off1[k]
		print("  %-5s  off=%s  on=%s  off2=%s" % [k, String(off1[k]).substr(0,10),
			String(on1[k]).substr(0,10), String(off2[k]).substr(0,10)])
		if not same_off:
			fail += 1; print("    ★FAIL 決定性本身就破了（off 兩跑不同）⇒ ★★這時 on/off 比較【沒有意義】")
		elif not on_matches:
			fail += 1; print("    ★★★FAIL 開 tracer 改變了世界（這一把尺看得到）")
		else:
			print("    PASS 三跑一致")
	print("  tracer on：entries=%d deaths=%d（★證 tracer 真的在跑，不是被關著才「無污染」）"
		% [on1["entries"], on1["deaths"]])
	if int(on1["entries"]) == 0:
		fail += 1
		print("    ★FAIL tracer 開著卻 0 筆 ⇒ 上面的「無污染」是【假綠】（它根本沒動）")
	if int(on1["deaths"]) == 0:
		fail += 1
		print("    ★★★FAIL deaths=0 ⇒ 本票【新掛的那條路沒被走到】—— 無污染證的是別條路，不是它")
	print("ALL PASS" if fail == 0 else "FAILS=%d" % fail)
	quit()
