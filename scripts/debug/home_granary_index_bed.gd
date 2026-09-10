extends SceneTree
# @bed-kind: acceptance
# slice: _home_granary_food 全圖掃 → O(1) 索引（★語意等價由既有驗證器證，不自己另寫比對）
#
# ★★而本床的四格對應 spec §④：①shadow 零不一致 ②fp（另跑）③絕對成本 ④分兩組（有/無自家 outpost）
#   ⑤成對對照：把索引換回全掃 ⇒ 成本必須回到舊量級。
# ★★★而④是【成因診斷對不對】的直接證據：沒有自家 outpost 的隊本來要掃完整張圖，
#   有的隊第一個就 return ⇒ 前者的改善應該遠大於後者。

var _fails: int = 0
var _sections: int = 0
const EXPECT_SECTIONS: int = 3

func _initialize() -> void:
	print("=== home_granary 索引床 ===")
	var st := _world(600)
	_test_shadow(st)
	_test_cost_two_groups(st)
	_test_value_equal(st)
	if _sections != EXPECT_SECTIONS:
		_fails += 1
		push_error("[FAIL] 只跑完 %d/%d 段" % [_sections, EXPECT_SECTIONS])
	print("=== DONE === SECTIONS=%d/%d FAILS=%d" % [_sections, EXPECT_SECTIONS, _fails])
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_fails += 1
		push_error("[FAIL] " + msg)

func _world(ticks: int) -> WorldState:
	seed(4242)
	var st := WorldState.new()
	GameSetup.setup(st, GameSetup.load_config("res://config/warring_states.json"))
	st.player_id = -1
	var runner := SimRunner.new()
	for _i in range(ticks):
		runner.advance_tick(st, Vector2i(-1, -1))
	return st

# ── ① shadow：語意等價（★用既有驗證器）──────────────────────────────
func _test_shadow(st: WorldState) -> void:
	print("-- ① 語意等價：開 OwnerOutpostIndex.shadow 跑一窗 ⇒ 零不一致 --")
	OwnerOutpostIndex.shadow = true
	OwnerOutpostIndex.shadow_reset()
	var runner := SimRunner.new()
	for _i in range(120):
		runner.advance_tick(st, Vector2i(-1, -1))
	var checks: int = OwnerOutpostIndex.shadow_checks
	var fails: int = OwnerOutpostIndex.shadow_fails
	OwnerOutpostIndex.shadow = false
	print("    shadow_checks=%d｜shadow_fails=%d" % [checks, fails])
	_ok(checks > 0, "①★母體地板：shadow 真的比對了 %d 次（0 次的話下一格沒有鑑別力）" % checks)
	_ok(fails == 0, "①零不一致 ⇒ 索引與舊全圖掃【逐次相同】")
	_sections += 1

# ── ③④⑤ 成本：兩條路各自量，並分兩組 ────────────────────────────────
func _test_cost_two_groups(st: WorldState) -> void:
	print("-- ③④⑤ 成本（★分【有自家 outpost】與【沒有】兩組）--")
	var with_home: Array = []
	var without_home: Array = []
	var idx_us: Array = []
	var reps: int = 20
	for tid in st.teams:
		var t: TeamData = st.teams[tid]
		var has_home: bool = st.own_outpost_tile(int(tid)) != null
		# 舊路：全圖掃（★它現在只在 shadow 下被 production 呼叫，這裡直接量它當對照組）
		var t0: int = Time.get_ticks_usec()
		for _r in range(reps):
			DecisionContext._scan_home_granary_tile_legacy(st, int(tid))
		var legacy: float = float(Time.get_ticks_usec() - t0) / float(reps)
		# 新路：索引
		var t1: int = Time.get_ticks_usec()
		for _r in range(reps):
			st.own_outpost_tile(int(tid))
		var index_c: float = float(Time.get_ticks_usec() - t1) / float(reps)
		idx_us.append(index_c)
		if has_home:
			with_home.append(legacy)
		else:
			without_home.append(legacy)
	with_home.sort()
	without_home.sort()
	idx_us.sort()
	var med_idx: float = float(idx_us[idx_us.size() / 2])
	print("    索引（新路）每次 %.3f us（n=%d）" % [med_idx, idx_us.size()])
	if not with_home.is_empty():
		print("    舊全圖掃｜★有自家 outpost 的隊 %d 支：每次中位 %.1f us" % [
			with_home.size(), float(with_home[with_home.size() / 2])])
	if not without_home.is_empty():
		print("    舊全圖掃｜★★沒有自家 outpost 的隊 %d 支：每次中位 %.1f us" % [
			without_home.size(), float(without_home[without_home.size() / 2])])
	_ok(not without_home.is_empty(),
		"④★母體地板：真的有【沒有自家 outpost】的隊（%d 支）—— 那是最壞路徑那一群" % without_home.size())
	var med_without: float = float(without_home[without_home.size() / 2]) if not without_home.is_empty() else 0.0
	var med_with: float = float(with_home[with_home.size() / 2]) if not with_home.is_empty() else 0.0
	_ok(med_without > med_with,
		"④沒有自家 outpost 的隊【本來】比較貴（%.1f us > %.1f us）⇒ 成因診斷對得上" % [med_without, med_with])
	_ok(med_idx * 3.0 < med_without,
		"⑤成對對照：換回全掃 ⇒ 成本回到 %.1f us（新路 %.3f us，★快 %.0f 倍）"
			% [med_without, med_idx, med_without / maxf(0.001, med_idx)])
	_sections += 1

# ── ② 值一致（★行為腿：fp 那一格另跑，這裡驗回傳值本身）────────────
func _test_value_equal(st: WorldState) -> void:
	print("-- ② 回傳值逐隊相同（★fp 不變那一格在 a4 另跑；這裡是行為腿）--")
	var diffs: int = 0
	var checked: int = 0
	for tid in st.teams:
		var t: TeamData = st.teams[tid]
		var idx_tile: HexTileData = st.own_outpost_tile(int(tid))
		var idx_food: float = float(idx_tile.public_storage.get("food", 0)) if idx_tile != null else 0.0
		var legacy_pos: Vector2i = DecisionContext._scan_home_granary_tile_legacy(st, int(tid))
		var legacy_food: float = 0.0
		if legacy_pos != Vector2i(-1, -1):
			var lt: HexTileData = st.world.tiles.get(legacy_pos.x * 1000 + legacy_pos.y)
			legacy_food = float(lt.public_storage.get("food", 0)) if lt != null else 0.0
		checked += 1
		if abs(idx_food - legacy_food) > 0.0001:
			diffs += 1
			print("    ★不一致 team=%d 索引=%.2f 舊掃=%.2f" % [int(tid), idx_food, legacy_food])
	print("    逐隊比對 %d 支｜不一致 %d 支" % [checked, diffs])
	_ok(checked > 0, "②★母體地板：真的比了 %d 支" % checked)
	_ok(diffs == 0, "②每一支隊的【家糧數字】新舊相同")
	_sections += 1
