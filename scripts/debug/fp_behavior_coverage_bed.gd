extends SceneTree
# @bed-kind: acceptance
# slice: fp 覆蓋擴到【會影響行為的欄位】全集（清單生成式，禁手抄）
#
# ★代理判準（可導出）：該欄位有沒有被【模擬層的 code】讀到（輸出行不算）。
#   ★★它是保守超集：「被讀到」⊋「真的影響行為」⇒ 多守不是錯守。
# ★★★而本票唯一的真風險是【擴太多 ⇒ fp 變噪音】—— 噪音尺等於沒有尺
#   ⇒ 決定論那一格（③）跑在長窗上，且窗長用【tick 數 ＋ 遊戲天】兩種單位寫。

var _fails: int = 0
var _sections: int = 0
const EXPECT_SECTIONS: int = 6

func _initialize() -> void:
	print("=== fp 行為欄位覆蓋床 ===")
	_test_generated_not_handwritten()
	_test_trigger_samples_in_ruler()
	_test_counts_sum_up()
	_test_exemption_evidence()
	_test_determinism_short()
	_test_sentinel_still_works()
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

func _world(ticks: int, cfg: String) -> WorldState:
	seed(1337)
	var st := WorldState.new()
	GameSetup.setup(st, GameSetup.load_config("res://config/%s.json" % cfg))
	st.player_id = -1
	var runner := SimRunner.new()
	for _t in range(ticks):
		runner.advance_tick(st, Vector2i(-1, -1))
	return st

func _test_generated_not_handwritten() -> void:
	print("-- ① 清單是生成的（★假欄位：在模擬層被讀 ⇒ 進尺；只在 print 裡被讀 ⇒ 不進尺）--")
	# ★用推導本體直接驗判準（不必真的去改 data class）：模擬層文字裡有沒有 ".欄位"
	var src: String = FpCoverage.sim_source()
	_ok(src.length() > 100000, "①母體地板：模擬層原始碼掃到 %d 字（空母體不得判綠）" % src.length())
	_ok(src.contains(".population"), "①一個真的被讀的欄位在母體裡找得到")
	# ★★輸出行【整行不算】：print/Probe/emit_message 那幾行已經在來源被剝掉
	_ok(not src.contains("Probe.bump("), "①★輸出行真的被剝掉了（Probe. 一行都不剩）")
	_ok(not src.contains("print("), "①★print 行也一樣（★★否則「只被 print 讀到」的欄位會被誤判成進尺）")
	_sections += 1

func _test_trigger_samples_in_ruler() -> void:
	print("-- ⑤ 觸發樣本：今天被點名的設施等級必須在尺內 --")
	var tile_fields: Array = FpCoverage.fields_for("HexTileData")
	for f in ["apothecary_level", "mint_level", "armorsmith_level", "manufacturing_level", "farming_level"]:
		_ok(f in tile_fields, "⑤HexTileData.%s 進尺" % f)
	var team_fields: Array = FpCoverage.fields_for("TeamData")
	_ok("anon_treasury" in team_fields, "⑤TeamData.anon_treasury 進尺（★匿名層的錢，之前不在尺裡）")
	_sections += 1

func _test_counts_sum_up() -> void:
	print("-- ⑥ 數字對帳：進尺 ＋ 三類豁免 ＝ var 欄位總數（差額必須 0）--")
	var d: Dictionary = FpCoverage.derive()
	var paths := {
		"TeamData": "res://scripts/data/team_data.gd",
		"PersonData": "res://scripts/data/person_data.gd",
		"FactionData": "res://scripts/data/faction_data.gd",
		"HexTileData": "res://scripts/data/tile_data.gd",
		"WorldData": "res://scripts/data/world_data.gd",
	}
	for cls in paths:
		var sc = load(paths[cls])
		var total: int = 0
		for pi in sc.get_script_property_list():
			var n: String = String(pi.get("name", ""))
			if n == "" or n.begins_with("_"):
				continue
			if int(pi.get("usage", 0)) & PROPERTY_USAGE_SCRIPT_VARIABLE == 0:
				continue
			total += 1
		var e: Dictionary = d[cls]
		var got: int = (e["in_ruler"] as Array).size() + (e["cadence"] as Array).size() \
			+ (e["ephemeral"] as Array).size() + (e["observation"] as Array).size()
		print("    %-12s 進尺 %3d ＋ cadence %2d ＋ ephemeral %d ＋ 觀測 %2d ＝ %d（總 %d）" % [cls,
			(e["in_ruler"] as Array).size(), (e["cadence"] as Array).size(),
			(e["ephemeral"] as Array).size(), (e["observation"] as Array).size(), got, total])
		_ok(got == total, "⑥%s 差額為 0" % cls)
	_sections += 1

func _test_exemption_evidence() -> void:
	print("-- ② 豁免要有證據（沒有證據的豁免 ＝ 不豁免）--")
	var d: Dictionary = FpCoverage.derive()
	# (c) 觀測專用：★它的讀取點必須【全部】落在輸出位置 ⇒ 剝掉輸出行之後就找不到它
	var src: String = FpCoverage.sim_source()
	var obs: Array = d["TeamData"]["observation"]
	print("    (c) 觀測/未讀候選：%s" % str(obs))
	for n in obs:
		_ok(not src.contains("." + String(n)),
			"②(c) %s 的讀取點全部落在輸出位置（剝掉輸出行後找不到它）" % String(n))
	# (b) cadence：★由【後綴規則】導出而不是列名字 ⇒ 驗規則本身
	var cad: Array = d["TeamData"]["cadence"]
	_ok(cad.size() > 0, "②(b) cadence 由後綴規則導出，抓到 %d 欄（★規則不是名單，會跟著世界長大）" % cad.size())
	for n in cad:
		var ok_suffix: bool = false
		for suf in FpCoverage.CADENCE_SUFFIXES:
			if String(n).ends_with(String(suf)):
				ok_suffix = true
		_ok(ok_suffix, "②(b) %s 真的符合後綴規則（不是有人手動塞進來的）" % String(n))
	# (a) ephemeral：清空 → 推進 → 值被算回來（★這一格是可跑的證據，不是宣稱）
	var st := _world(40, "demo")
	var tid: int = -1
	for k in st.teams:
		if (st.teams[k] as TeamData).food_runway > 0.0:
			tid = int(k)
			break
	if tid == -1:
		_ok(false, "②(a) ★沒有任何一隊的 food_runway > 0 ⇒ 這一格【沒有測到】，不是綠")
	else:
		var t: TeamData = st.teams[tid]
		var before: float = t.food_runway
		t.food_runway = 0.0
		var runner := SimRunner.new()
		for _i in range(20):
			runner.advance_tick(st, Vector2i(-1, -1))
		print("    (a) food_runway 清空前 %.3f ／ 推進 20 tick 後 %.3f" % [before, t.food_runway])
		_ok(t.food_runway > 0.0, "②(a) ephemeral：清空之後【被算回來】⇒ 它是快取不是狀態")
	_sections += 1

func _test_determinism_short() -> void:
	print("-- ③ 決定論（短窗；★長窗那半跑在另一支長跑，見交件）--")
	var t0: int = Time.get_ticks_usec()
	var a := _world(200, "demo")
	var fa: String = StateFingerprint.compute(a)
	var cost_us: int = Time.get_ticks_usec() - t0
	var b := _world(200, "demo")
	_ok(fa == StateFingerprint.compute(b), "③同 seed 兩跑 fp 相同（200 tick ＝ 0.14 遊戲天）")
	# ★★成本：擴張後 hash 要多久（spec ④② 要求量，不得假設它便宜）
	var t1: int = Time.get_ticks_usec()
	for _i in range(10):
		StateFingerprint.compute(a)
	print("    ★fp 計算成本：%.2f ms／次（%d 隊）｜200 tick 跑＋一次 hash＝%.1f ms" % [
		float(Time.get_ticks_usec() - t1) / 10000.0, a.teams.size(), float(cost_us) / 1000.0])
	_sections += 1

func _test_sentinel_still_works() -> void:
	print("-- ④ 上一張票的哨兵仍然有效 --")
	var st := WorldState.new()
	st.world = WorldData.new()
	var base: String = StateFingerprint.player_section(st)
	st.player_alerts.append({"type": "__control__"})
	_ok(StateFingerprint.player_section(st) != base, "④注入偷寫 ⇒ player 段仍然當場變（哨兵沒被這次擴張蓋掉）")
	_sections += 1
