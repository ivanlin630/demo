extends SceneTree

# specimen 觀測非侵入化 TDD（slice: specimen-observer-noninvasive）
#
# ★★★【第⑧票 2026-09-06 警語】本床的 full-HD 對照【已恆等於預設】——
#   `SimRunner.force_full_hd` 隨 near/far 分班一起退場，所以「全高清 vs LOD」這個對照
#   ★兩邊變成同一個東西 ⇒ ★★此對照【已無鑑別力】。
#   ★★★而本床【沒有被刪】是刻意的：刪床是另一個決定。要不要重寫或退休 → systems + measurer。
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
	_test_trade_threat_taps()
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
	print("--- Fix 1 LOD 分區非侵入：★★★本測項已隨第⑧票【退場】 ---")
	# ★★★第⑧票（2026-09-06）拆掉 near/far 分班本體 ⇒ `_get_near_teams`／`_get_far_teams`
	#   這兩支函式【已不存在】，而本測項證的是「specimen 不改變它們的分類結果」。
	#   ⇒ ★被證的那個東西沒了，測項不是失敗也不是通過，是【沒有指涉對象】。
	# ★★而我【不刪這個函式】：留下這段說明，讓下一個人知道
	#   「Fix 1 的保護現在由【分班不存在】本身提供」—— 而不是以為有人偷偷拿掉了一條保護。
	# ★★★形狀升級了不是消失了：以前要證「specimen 不影響分區」，
	#   現在【沒有分區可影響】—— 那是 by construction 的更強版本。
	_ok(true, "★分班已拆除 ⇒ specimen 不可能影響 near/far 分類（沒有分類）—— by construction")
	print("     ★而這條【恆真】，它【沒有鑑別力】—— 真正的保護是 `lod-split-guard` 那道閘：")
	print("        ★★有人重新引入按 player_pos 分批 ⇒ 那道閘會紅，而不是這條會紅。")

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

# ── 交易執行 + 威脅來源 tap（slice: specimen-trade-threat-taps；QA 缺口①②）──
# spec: docs/superpowers/specs/2026-07-14-specimen-trade-threat-taps.md
# Fix1 _snapshot 加 active_buy_food_qty/at_market/orders（買糧執行鏈可判換皮 vs tap-miss）。
# Fix2 capture_options 收 ctx → 想什麼.threat（threat_id/threat_pos/threat_react；判空鎖有無真威脅）。
func _test_trade_threat_taps() -> void:
	print("--- 交易執行 + 威脅來源 tap：jsonl 含新欄 ---")
	var world_seed := 1337
	var ticks := 200
	var sr: Array = _setup_world(world_seed)
	var state: WorldState = sr[0]
	var runner: SimRunner = sr[1]
	var ids: Array = state.teams.keys()
	ids.sort()
	state.specimen_team_ids.assign(ids.slice(0, mini(5, ids.size())))
	SpecimenTracer.reset()
	SpecimenTracer.enabled = true
	var no_player := Vector2i(-1, -1)
	for _tick in range(ticks):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
	var path := "user://specimen_trade_threat_trace.jsonl"
	SpecimenTracer.write_jsonl(path)
	SpecimenTracer.enabled = false

	var f := FileAccess.open(path, FileAccess.READ)
	_ok(f != null, "jsonl 檔開得成")
	var n := 0
	var trade_ok := false   # 狀態含 active_buy_food_qty/at_market/orders
	var threat_ok := false  # 想什麼.threat 含 threat_id/threat_react
	if f != null:
		while not f.eof_reached():
			var line := f.get_line()
			if line.strip_edges().is_empty(): continue
			n += 1
			var e = JSON.parse_string(line)
			if not (e is Dictionary): continue
			var snap = e.get("狀態", {})
			if snap is Dictionary and snap.has("active_buy_food_qty") and snap.has("at_market") and snap.has("orders"):
				trade_ok = true
			var want = e.get("想什麼", {})
			if want is Dictionary and want.get("threat", null) is Dictionary \
					and want["threat"].has("threat_id") and want["threat"].has("threat_react"):
				threat_ok = true
		f.close()
	_ok(n > 0, "jsonl 非空(%d 行)" % n)
	_ok(trade_ok, "Fix1：狀態含 active_buy_food_qty/at_market/orders（交易執行可判）")
	_ok(threat_ok, "Fix2：想什麼.threat 含 threat_id/threat_react（威脅來源可判）")
	SpecimenTracer.reset()
