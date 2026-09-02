extends SceneTree
# @observe-pure
# ★★★外觀層【寫入證據】床（驗收條款：每個新欄位必須有非零寫入證據）。
#   ★理由（既有條款）：欄位存在而恆空 ⇒ 決策永遠篩不到人，★★而它看起來像「沒人符合條件」。
#
# ★★另驗兩件 systems 2026-09-02 裁的：
#   ①`ACT_IDLE` 有非零寫入 —— ★寫入端的預設答案是 IDLE 不是 UNKNOWN
#   ②★★★`appearance.write_unknown_BUG` 必須【恆 0】—— 非 0 ＝ 分類表又缺一格
#     （★而處置是【報 systems】，不是自己補一個預設值把它蓋掉）

var _fail := 0
func _ok(c: bool, m: String) -> void:
	if c: print("  PASS ", m)
	else: _fail += 1; print("  FAIL ", m)

func _mk(state: WorldState, tid: int, pos: Vector2i, tags: Array) -> TeamData:
	var t := HexTileData.new()
	t.tile_id = pos.x * 1000 + pos.y; t.tile_pos = pos; t.terrain = "plains"
	if not state.world.tiles.has(t.tile_id): state.world.tiles[t.tile_id] = t
	var ldr := PersonData.new(); ldr.id = tid * 100 + 1; ldr.team_id = tid
	ldr.skills = {"偵查": 0.5}
	state.persons[ldr.id] = ldr
	var team := TeamData.new(); team.team_id = tid; team.leader_id = ldr.id
	team.tile_pos = pos; team.last_tile_pos = pos; team.tags = tags.duplicate()
	state.teams[tid] = team
	state.add_member(team, ldr.id)
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", 5)
	return team

func _init() -> void:
	print("=== 外觀層寫入證據 ===")
	var state := MeasureBedHelper.arm_and_new()
	seed(1337)
	var obs := _mk(state, 0, Vector2i(5, 5), [])
	var idle := _mk(state, 1, Vector2i(6, 5), ["流亡"])          # 靜止、無活動 ⇒ 期望 IDLE
	var mover := _mk(state, 2, Vector2i(5, 6), [])               # 位置與上一步不同 ⇒ MOVING
	mover.last_tile_pos = Vector2i(4, 6)
	var vs := VisionSystem.new()
	vs.tick_discovery(state, [0, 1, 2])

	var ap_idle: Dictionary = BeliefSystem.appearance(state, 0, 1)
	var ap_move: Dictionary = BeliefSystem.appearance(state, 0, 2)
	print("  對 team1（靜止）= %s｜對 team2（移動中）= %s" % [str(ap_idle), str(ap_move)])
	_ok(String(ap_idle["state"]) == "fresh", "前提：觀察真的發生了（state=fresh）★沒有這條，下面全部沒意義")
	_ok(String(ap_idle["activity"]) == BeliefSystem.ACT_IDLE,
		"★★★ACT_IDLE 有非零寫入（★寫入端的預設答案是 IDLE，不是 UNKNOWN）")
	_ok(String(ap_move["activity"]) == BeliefSystem.ACT_MOVING,
		"★ACT_MOVING 有非零寫入（位置與上一步不同＝真的在動）")
	_ok((ap_idle["tags"] as Array).has("流亡"), "★tags_seen 有非零寫入（旗號看得出來）")
	_ok(int(Probe.counts.get("appearance.write_unknown_BUG", 0)) == 0,
		"★★★寫入端 unknown 恆 0（非 0 ＝ 分類表又缺一格 ⇒ 報 systems，不自己補預設值）")
	print("  ★誠實限：①本床只造出 IDLE/MOVING 兩種活動；")
	print("    ★★COMBAT/BUILDING/SETTLED 的寫入證據【本床沒造】—— 它們有 code 路徑但這裡沒走到")
	print("    ★★★而「有 code 路徑」不等於「會發生」，那是另一輪（長窗）才答得了的")
	if _fail == 0: print("ALL PASS")
	else: print("FAILS=%d" % _fail)
	quit()
