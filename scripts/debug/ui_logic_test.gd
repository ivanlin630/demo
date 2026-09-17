extends SceneTree
# @bed-kind: invariant

var _errors: int = 0
const EXPECTED_CELLS: Array = ["_test_post_combat_hint", "_test_attack_select_hint", "_test_unit_color", "_test_constants", "_test_setup_sanity", "_test_vision_threshold", "_test_member_health_line", "_test_resource_trend", "_test_mode_keymap", "_test_feedback_format", "_test_log_strip"]

# ★★★【到場點名 ＋ 陽性對照】（systems 派工；樣板同 `constitution_gate` 第一批）——
#   ★病：GDScript 的執行期錯誤**只中止那一支 func**（coroutine 也一樣，`await` 不保護）⇒
#     床照樣跑到最後、照樣印通過橫幅，而 runner 只看 exit code 與 expect ⇒ **兩者都通過**。
#   ★★修法：每一格【自己的最後一行】打卡，末尾對名單，**少一格就把橫幅變成 FAIL**。
#   ★★★用法必須是 `_selftest_gate("格名").noop()` —— 死亡要發生在【那一格自己的 frame】裡
#     （★血證：放進被呼叫的 helper 裡 ⇒ 中止的是 helper、那一格照樣跑完 ⇒ 會誤判成「這裡沒有洞」）。
var _cells_ran: Array = []

func _cell(name: String) -> void:
	if not _cells_ran.has(name):
		_cells_ran.append(name)

func noop() -> void:
	pass

func _selftest_gate(cell: String) -> Object:
	if OS.get_environment("BED_SELFTEST_DIE") != cell:
		return self
	print("[SELFTEST] ★故意讓 `%s` 這一格在中途死掉" % cell)
	return null

func _roll_call_missing() -> Array:
	var missing: Array = []
	for c in EXPECTED_CELLS:
		if not _cells_ran.has(c): missing.append(c)
	if not missing.is_empty():
		print("[roll-call] ❌ ★**有格沒有跑完**：%s —— 執行期錯誤會靜默中止一支 func，而那看起來像綠" % str(missing))
	return missing

func _initialize() -> void:
	_test_constants()
	_test_setup_sanity()
	_test_vision_threshold()
	_test_member_health_line()
	_test_resource_trend()
	_test_mode_keymap()
	_test_feedback_format()
	_test_log_strip()
	_test_post_combat_hint()
	_test_attack_select_hint()
	_test_unit_color()
	var _miss: Array = _roll_call_missing()
	var _suffix: String = "｜到場點名 %d／%d" % [_cells_ran.size(), EXPECTED_CELLS.size()]
	if not _miss.is_empty(): _errors += 1
	print("\n=== UI Logic Test DONE === errors: %d%s" % [_errors, _suffix])
	quit()

# ── U10: 遭遇戰戰後提示組字 ──────────────────────────────────────────────────
func _test_post_combat_hint() -> void:
	_selftest_gate("_test_post_combat_hint").noop()
	print("\n── U10. 戰後提示 ──")
	var EncView = load("res://scripts/ui/encounter_view.gd")
	var hint_subj: String = EncView._post_combat_hint({"can_subjugate": true})
	var hint_no:   String = EncView._post_combat_hint({"can_subjugate": false})
	_check("can_subjugate → 含「J收編」", hint_subj.contains("J") and hint_subj.contains("收編"))
	_check("不可收編 → 僅按任意鍵（無 J）", not hint_no.contains("J"))
	_check("提示永遠含「離開」字樣", hint_no.contains("離開") and hint_subj.contains("離開"))
	# Q7-3: loot_pool 非空 → hint 含 [K]拿戰利品 [L]留下
	var hint_loot: String = EncView._post_combat_hint({"can_subjugate": true, "loot_pool": {"food": 30.0}})
	_check("有戰利品 → 含「K」拿戰利品", hint_loot.contains("K") and hint_loot.contains("戰利品"))
	_check("有戰利品 → 含「L」留下", hint_loot.contains("L") and hint_loot.contains("留下"))
	_check("無戰利品 → 不含「拿戰利品」", not hint_subj.contains("拿戰利品"))
	var summ: String = EncView._post_combat_summary({"winner_id": 0, "loser_id": 1})
	_check("戰果摘要含勝負隊", summ.contains("Team0") and summ.contains("Team1"))
	_check("空結果摘要 fallback「結束」", EncView._post_combat_summary({}) == "結束")
	_cell("_test_post_combat_hint")

func _test_attack_select_hint() -> void:
	_selftest_gate("_test_attack_select_hint").noop()
	print("\n── attack_select 提示 ──")
	var EncView = load("res://scripts/ui/encounter_view.gd")
	var h: String = EncView._attack_select_hint("torso")
	_check("含 ↑↓選部位", h.contains("↑") and h.contains("部位"))
	_check("含 Enter 攻擊", h.contains("Enter") and h.contains("攻擊"))
	_check("含 Esc 取消", h.contains("Esc"))
	_check("顯當前部位", h.contains("torso"))

# U17: 遭遇戰旗色（玩家藍/自家綠/敵紅，防再反）
	_cell("_test_attack_select_hint")
func _test_unit_color() -> void:
	_selftest_gate("_test_unit_color").noop()
	print("\n── U17. 遭遇戰旗色 ──")
	var EncView = load("res://scripts/ui/encounter_view.gd")
	_check("玩家=藍", EncView._unit_color(true, true) == Color.DODGER_BLUE)
	_check("自家 anon=綠", EncView._unit_color(false, true) == Color.GREEN)
	_check("敵=紅", EncView._unit_color(false, false) == Color.RED)
	_cell("_test_unit_color")

func _check(label: String, ok: bool) -> void:
	if ok:
		print("  PASS: %s" % label)
	else:
		print("  FAIL: %s" % label)
		_errors += 1

# ── Task 1: Simulation 常數 ──────────────────────────────────────────────────

func _test_constants() -> void:
	_selftest_gate("_test_constants").noop()
	print("\n── Task1. Simulation 常數 ──")
	_check("SALARY_INTERVAL >= 720", SalarySystem.SALARY_INTERVAL >= 720)
	_check("SEASON_LENGTH >= 240", HarvestSystem.SEASON_LENGTH >= 240)
	print("  ℹ salary_system.gd SALARY_INTERVAL = %d" % SalarySystem.SALARY_INTERVAL)
	print("  ℹ harvest_system.gd SEASON_LENGTH  = %d" % HarvestSystem.SEASON_LENGTH)

# ── Task 2: Test Setup ────────────────────────────────────────────────────────
	_cell("_test_constants")

func _test_setup_sanity() -> void:
	_selftest_gate("_test_setup_sanity").noop()
	print("\n── Task2. Test Setup ──")
	const FOOD_START := 5000.0
	const POP := 10
	const TICKS_PER_DAY := 24.0
	var days: float = FOOD_START / (float(POP) * 0.1 * TICKS_PER_DAY)
	_check("初始食物撐 > 30 天 (%.1f天)" % days, days > 30.0)
	var cap: int = TeamData.pop_cap_from_leadership(0.5)
	_check("統領=0.5 → cap=%d > 10 → 不分裂" % cap, cap > 10)

# ── Task 3: 視野門檻 + 移動邊界 ──────────────────────────────────────────────
	_cell("_test_setup_sanity")

func _test_vision_threshold() -> void:
	_selftest_gate("_test_vision_threshold").noop()
	print("\n── Task3. 視野門檻 + 移動邊界 ──")
	var state := WorldState.new()
	var gen = load("res://scripts/simulation/world_generator.gd").new()
	gen.generate(state, {"radius": 4, "seed": 42})
	for _pos in [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)]:
		var _k: int = _pos.x * 1000 + _pos.y
		if state.world.tiles.has(_k):
			(state.world.tiles[_k] as HexTileData).terrain = "plains"
	for t in range(3):
		var team := TeamData.new()
		team.team_id = t
		AnonTierSystem.add_anon(team, "平民", 8)   # ★舊寫法是 getter-only 賦值（靕默 no-op）；getter = leader(0/1)+named+anon（下方 loop 再造 leader+1 named）
		team.tile_pos = Vector2i(t, 0)
		team.resources = {
			"food": 5000.0, "material": 10, "coin": 200, "goods": 0, "gem": 0,
			"ore_gold": 0, "ore_silver": 0, "ore_iron": 0, "ore_steel": 0,
			"weapon_melee_low": 0, "weapon_melee_high": 0,
			"weapon_ranged_low": 0, "weapon_ranged_high": 0,
			"mounts": 0, "wagons": 0, "arrows": 0,
			"medicine": 0, "tools": 0, "armor_low": 0, "armor_high": 0,
		}
		state.teams[t] = team
		state.team_known[t] = []; state.team_discovered[t] = []
		for p in range(2):
			var person := PersonData.new()
			person.id = t * 2 + p; person.person_name = "P%d_%d" % [t, p]
			person.role = "leader" if p == 0 else "civilian"
			person.team_id = t; person.age = 25; person.loyalty = 0.9
			person.skills["統領"] = 0.5
			state.persons[person.id] = person
			if p == 0: team.leader_id = person.id
			else: team.named_members.append(person.id)
	PlayerSystem.new().init_player(state, 0, 0)
	var vis := VisionSystem.new()
	vis.tick_discovery(state, [0, 1, 2])
	var disc0: Array = state.team_discovered.get(0, [])
	_check("team0 看到 team1（dist=1）", disc0.has(1))
	_check("team0 看到 team2（dist=2）", disc0.has(2))
	var out := Vector2i(10, 10)
	_check("(10,10) 不在地圖（邊界驗證依據）",
		not state.world.tiles.has(out.x * 1000 + out.y))

# ── chrome P2: status 成員健康一行 ───────────────────────────────────────────
	_cell("_test_vision_threshold")

func _test_member_health_line() -> void:
	_selftest_gate("_test_member_health_line").noop()
	print("\n── chrome. 成員健康一行 ──")
	var members: Array = [
		{ "name": "甲", "hp_status": "正常" },
		{ "name": "乙", "hp_status": "重傷" },
		{ "name": "丙", "hp_status": "輕傷" },
	]
	var line: String = TextUiMain._member_health_line(members)
	_check("摘要傷員（乙重傷）line=%s" % line, "重傷" in line and "乙" in line)
	var ok_line: String = TextUiMain._member_health_line([{ "name": "甲", "hp_status": "正常" }])
	_check("全正常非空 line=%s" % ok_line, ok_line != "")

# ── chrome P2: 資源趨勢箭頭 ──────────────────────────────────────────────────
	_cell("_test_member_health_line")

func _test_resource_trend() -> void:
	_selftest_gate("_test_resource_trend").noop()
	print("\n── chrome. 資源趨勢箭頭 ──")
	_check("增→↑", TextUiMain._resource_trend(100.0, 120.0) == "↑")
	_check("減→↓", TextUiMain._resource_trend(100.0, 80.0) == "↓")
	_check("平→無", TextUiMain._resource_trend(100.0, 100.0) == "")

# ── chrome P2: 模式 keymap ───────────────────────────────────────────────────
	_cell("_test_resource_trend")

func _test_mode_keymap() -> void:
	_selftest_gate("_test_mode_keymap").noop()
	print("\n── chrome. 模式 keymap ──")
	_check("main 有鍵表", TextUiMain._mode_keymap("main") != "")
	_check("interact 有鍵表", TextUiMain._mode_keymap("interact") != "")
	_check("未知 mode fallback main", TextUiMain._mode_keymap("zzz") == TextUiMain._mode_keymap("main"))

# ── chrome P2: feedback 行格式 ───────────────────────────────────────────────
	_cell("_test_mode_keymap")

func _test_feedback_format() -> void:
	_selftest_gate("_test_feedback_format").noop()
	print("\n── chrome. feedback 格式 ──")
	_check("成功訊息含內容", TextUiMain._feedback_text(true, "獵得野味 +12").contains("獵得"))
	_check("成敗異色", TextUiMain._feedback_color(true) != TextUiMain._feedback_color(false))

# ── chrome P2: event LogStrip 組字 ───────────────────────────────────────────
	_cell("_test_feedback_format")

func _test_log_strip() -> void:
	_selftest_gate("_test_log_strip").noop()
	print("\n── chrome. event LogStrip ──")
	var events: Array = [
		{"type":"ui","msg":"A"}, {"type":"ui","msg":"B"}, {"type":"ui","msg":"C"}, {"type":"ui","msg":"D"}
	]
	var s: String = TextUiMain._log_strip_text(events, 3)
	_check("顯最新 3 條（BCD）s=%s" % s, "D" in s and "C" in s and "B" in s)
	_check("舊的 A 不顯", not ("A" in s))
	_cell("_test_log_strip")
