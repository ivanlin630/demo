extends SceneTree

# specimen 觀測非侵入化 TDD（slice: specimen-observer-noninvasive）
# spec: docs/superpowers/specs/2026-07-14-specimen-observer-noninvasive.md
#
# Fix 1：移除 sim_runner _get_near_teams/_get_far_teams 的 specimen LOD-exemption。
#   → specimen 完全不參與 LOD 分區 → 換觀測對象不改任何隊的 near/far 歸類 →
#     不岔 RNG → 世界 byte-identical（Heisenberg-free 觀測）。★非侵入「by construction」：
#     specimen 不進 LOD 邏輯 ⇒ 不可能擾動世界（QED，unit test 直測此）。
# Fix 3：SpecimenTracer.write_jsonl → 全量 trace jsonl（_archive 跨 flush 累積，死隊不遺漏）。
#
# ★spec TDD-1 字面寫「force_full_hd + 世界 byte-identical」，但兩點需校正（已 flag to:systems）：
#   (a) force_full_hd 下 _get_near/_get_far 短路(:452 全 near/:464 無 far)、specimen exemption
#       根本不觸達 → 該設定 pre-fix 也 green（測不出 fix）。
#   (b) 侵入只在 normal LOD 顯現；無-player warring 世界的世界級 byte-diff 需長跑才顯（近端量不到），
#       故核心 red/green 用 LOD 分區「unit test」直測改動點（快、確定、直接證非侵入 by construction）。
#   世界級 byte-identical = measurer 全-HD headline 驗收職責（本 test 不越俎代庖近端量測）。

var _fail: int = 0
const CFG := "res://config/warring_states.json"

func _initialize() -> void:
	_test_lod_partition_noninvasive()
	_test_jsonl_production()
	if _fail == 0:
		print("=== DONE === ALL PASS")
	else:
		print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  [PASS] %s" % msg)
	else:
		_fail += 1
		print("  [FAIL] %s" % msg)

# ── Fix 1 核心：LOD 分區不再受 specimen 影響（unit，red-pre/green-post）──
func _mk_state_with_teams() -> WorldState:
	var state := WorldState.new()
	state.world = WorldData.new()
	var near_t := TeamData.new(); near_t.team_id = 1; near_t.tile_pos = Vector2i(1, 0)    # 距(0,0)=1 <= LOD_NEAR(3)
	var far_t := TeamData.new(); far_t.team_id = 2; far_t.tile_pos = Vector2i(50, 50)      # 距(0,0)>>3 → far
	state.teams[1] = near_t
	state.teams[2] = far_t
	return state

func _test_lod_partition_noninvasive() -> void:
	print("--- Fix 1 LOD 分區非侵入：specimen 不改 near/far 分類 ---")
	var runner := SimRunner.new()
	var player_pos := Vector2i(0, 0)
	var state := _mk_state_with_teams()
	state.specimen_team_ids = [2]   # far team 2 設 specimen
	var near: Array = runner._get_near_teams(state, player_pos)
	var far: Array = runner._get_far_teams(state, player_pos)
	# post-fix：specimen 不豁免 → far team 2 依距離歸 far、不入 near（pre-fix 被強制入 near=紅）
	_ok(not (2 in near), "specimen far team 不被強制入 near（依距離歸類）")
	_ok(2 in far, "specimen far team 正常參與 far 降級（不再跳過）")
	# near team 1 不受影響
	_ok(1 in near, "near team（距1）仍 near")
	_ok(not (1 in far), "near team 不在 far")
	# ★換觀測對象不改分區：specimen=[1] vs [2] → team 2 的歸類完全相同（非侵入 by construction）
	state.specimen_team_ids = [1]
	var near_b: Array = runner._get_near_teams(state, player_pos)
	var far_b: Array = runner._get_far_teams(state, player_pos)
	_ok((2 in far) == (2 in far_b) and (2 in near) == (2 in near_b),
		"換 specimen [2]→[1]：team 2 near/far 歸類不變（觀測選擇零影響分區）")

# ── Fix 3：jsonl writer 非空 + archive 跨 flush 全捕 ──
func _setup_world(world_seed: int) -> Array:   # → [state, runner]
	seed(world_seed)
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config(CFG)
	config["seed"] = world_seed
	GameSetup.setup(state, config)
	return [state, runner]

func _test_jsonl_production() -> void:
	print("--- Fix 3 jsonl writer：非空、每行 valid JSON、archive 跨 flush 全捕 ---")
	var world_seed := 1337
	var ticks := 200
	var sr: Array = _setup_world(world_seed)
	var state: WorldState = sr[0]
	var runner: SimRunner = sr[1]
	SimRunner.force_full_hd = true   # judged-world acceptance 設定：全-HD（此路 specimen 不特殊）
	var ids: Array = state.teams.keys()
	ids.sort()
	state.specimen_team_ids.assign(ids.slice(0, mini(5, ids.size())))   # 前幾隊觀測，提高 capture 命中
	SpecimenTracer.reset()
	SpecimenTracer.enabled = true
	var no_player := Vector2i(-1, -1)
	for _tick in range(ticks):
		runner.advance_tick(state, no_player)   # sim_runner:138 每日 flush → 驗 archive 跨 flush 存活
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
	var total_decisions: int = SpecimenTracer.decision_count
	var path := "user://specimen_test_trace.jsonl"
	SpecimenTracer.write_jsonl(path)
	SpecimenTracer.enabled = false
	SimRunner.force_full_hd = false

	var f := FileAccess.open(path, FileAccess.READ)
	_ok(f != null, "jsonl 檔開得成")
	var n_lines := 0
	var n_valid := 0
	if f != null:
		while not f.eof_reached():
			var line := f.get_line()
			if line.strip_edges().is_empty(): continue
			n_lines += 1
			var parsed = JSON.parse_string(line)
			if parsed is Dictionary and parsed.has("tick") and parsed.has("team_id") and parsed.has("做什麼"):
				n_valid += 1
		f.close()
	_ok(total_decisions > 0, "specimen 產生決策(decision_count=%d)" % total_decisions)
	_ok(n_lines > 0, "jsonl 非空(%d 行)" % n_lines)
	_ok(n_valid == n_lines and n_lines > 0, "每行 valid JSON 且含 tick/team_id/做什麼(%d/%d)" % [n_valid, n_lines])
	# ★核心：jsonl 行數 == decision_count → _archive 跨每日 flush 全捕（死隊/已 flush 決策不遺漏）。
	#   若只讀 entries（flush 會清），行數會 << decision_count。
	_ok(n_lines == total_decisions,
		"jsonl 行數(%d)==decision_count(%d)：archive 跨 flush 全捕不遺漏" % [n_lines, total_decisions])
	SpecimenTracer.reset()
