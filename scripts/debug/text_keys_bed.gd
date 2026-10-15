extends SceneTree
# @bed-kind: acceptance
# slice: 文本外置試點（spec 2026-10-15-advisor-reads-belief-and-text-externalization-pilot §2d）
# ★格：
#   T1  鍵對帳（執行期，兩向）：advisor 五情境 ×{優,均,劣,不知道}× 四語氣 × 各來源詞跑 compose
#       ⇒ ①落預設句＝0 ②advisor.tsv 每個 (鍵,變體) 至少被取用一次；names：resources 每鍵 res_name(full) 落預設＝0、
#       names.tsv full 每鍵都在 resources 鍵集合、short ⊆ full；外置與 TEMPLATES 同 (鍵,變體) 並存＝0
#   T2  槽對帳：每個 (鍵,變體) 句子裡的 {槽} 集合 ＝ AdvisorSystem._params_for 回的 key 集合（多給少給都紅）；names 句無槽
#   T3  交換畫面：雙方有 food／material／weapon_melee_low／coin ⇒ 面板無 ASCII 資源鍵，印糧食／木料／粗製近戰武器／錢
#   T4  一張表：names.tsv 的 weapon_*／armor_* 6 個 full 值在 scripts/**/*.gd 的字串字面（非註解）零出現；
#       反向：裝備欄（item_name）與事件句（res_name）對同一鍵印同一字
# ★紅時印出是哪一個 (鍵,變體)

const EXPECTED: Array = ["T1", "T2", "T3", "T4"]
var _errors: int = 0
var _present: Dictionary = {}

func _initialize() -> void:
	print("=== text_keys：外置文本鍵對帳／槽對帳／交換畫面／一張表 ===")
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/default.json", false)
	Probe.enabled = false
	TextBank.record = true
	TextBank.used.clear()
	TextBank.fallbacks.clear()
	_t1_t2(st)
	await _t3()
	_t4()
	TextBank.record = false
	var miss: Array = []
	for c in EXPECTED:
		if not _present.has(c):
			miss.append(c)
	if not miss.is_empty():
		_check("到場點名缺 %s" % str(miss), false)
	print("=== text_keys DONE === 到場 %d／%d errors: %d" % [_present.size(), EXPECTED.size(), _errors])
	quit(1 if _errors > 0 else 0)

func _check(msg: String, cond: bool) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_errors += 1
		push_error("[FAIL] " + msg)

# 四語氣的人格佈置（_advisor_tone 的四支）
const TONE_SETUPS: Dictionary = {
	"sarcastic": {"skills": {"計謀": 0.9}, "values": {"義氣": 0.1, "好戰": 0.5, "信義": 0.5}},
	"blunt":     {"skills": {"計謀": 0.0}, "values": {"義氣": 0.5, "好戰": 0.9, "信義": 0.5}},
	"formal":    {"skills": {"計謀": 0.0}, "values": {"義氣": 0.5, "好戰": 0.5, "信義": 0.9}},
	"default":   {"skills": {"計謀": 0.0}, "values": {"義氣": 0.5, "好戰": 0.5, "信義": 0.5}},
}

static func _ctx(st: WorldState, situation: String, band: String, source_word: String) -> Dictionary:
	return {"situation": situation, "target": 3, "band": band, "pop": 12.0, "armed": 6.0, "rep": 0.5, "days": 7.0,
		"enemies": 2, "dist": 4, "cred": 0.5,
		"basis": {"source_word": source_word, "source_id": 7, "tick": st.world.current_tick}}

static func _slots(s: String) -> Array:
	var out: Array = []
	for m in RegEx.create_from_string("\\{([A-Za-z_]+)\\}").search_all(s):
		if not out.has(m.get_string(1)):
			out.append(m.get_string(1))
	out.sort()
	return out


# ── T1／T2 ───────────────────────────────────────────────────────────────────
func _t1_t2(st: WorldState) -> void:
	print("\n── T1 鍵對帳（執行期兩向）／T2 槽對帳 ──")
	var ext: Dictionary = TextBank.external()
	var n_adv: int = 0
	var n_names: int = 0
	for k in ext:
		if TextBank.external_source(String(k)).ends_with("advisor.tsv"): n_adv += (ext[k] as Dictionary).size()
		else: n_names += (ext[k] as Dictionary).size()
	print("   外置：advisor.tsv %d 句、names.tsv %d 句" % [n_adv, n_names])
	_check("T1 母體地板：兩檔都讀到（advisor %d、names %d）" % [n_adv, n_names], n_adv >= 20 and n_names >= 20)
	# 第二份真相
	var dup: Array = []
	for k in ext:
		for v in ext[k]:
			if TextBank.TEMPLATES.has(k) and (TextBank.TEMPLATES[k] as Dictionary).has(v):
				dup.append("%s|%s" % [k, v])
	_check("T1 外置與 TEMPLATES 同 (鍵,變體) 並存＝0 %s" % str(dup), dup.is_empty())
	# advisor：五情境 × 四帶 × 四語氣 × 來源詞
	var adv: PersonData = PersonData.new()
	adv.id = 99999
	adv.person_name = "床顧問"
	var combos: int = 0
	for tone in TONE_SETUPS:
		adv.skills = (TONE_SETUPS[tone]["skills"] as Dictionary).duplicate()
		adv.values = (TONE_SETUPS[tone]["values"] as Dictionary).duplicate()
		_check("T1 佈置：人格對到語氣 %s" % tone, AdvisorSystem._advisor_tone(adv) == tone)
		for sit in AdvisorSystem.TEXT_SITUATIONS:
			for band in ["good", "even", "bad", "unknown"]:
				var words: Array = ["自家帳"] if sit == "resources" else ["親見", "聽說"]
				for w in words:
					AdvisorSystem.compose(st, adv, _ctx(st, String(sit), String(band), String(w)))
					combos += 1
	print("   compose 跑了 %d 組" % combos)
	var adv_fb: Array = TextBank.fallbacks.filter(func(x): return String(x).begins_with("advisor"))
	_check("T1 advisor 落預設句＝0 %s" % str(adv_fb), adv_fb.is_empty())
	var unused: Array = []
	for k in ext:
		if not TextBank.external_source(String(k)).ends_with("advisor.tsv"):
			continue
		for v in ext[k]:
			if not TextBank.used.has("%s|%s" % [k, v]):
				unused.append("%s|%s" % [k, v])
	_check("T1 advisor.tsv 每個 (鍵,變體) 至少被取用一次（沒被取用：%s）" % str(unused), unused.is_empty())
	# names
	var res_keys: Array = TeamData.new().resources.keys()
	TextBank.fallbacks.clear()
	for rk in res_keys:
		TextBank.res_name(String(rk), "full")
	_check("T1 names：resources %d 鍵 res_name(full) 落預設＝0 %s" % [res_keys.size(), str(TextBank.fallbacks)], TextBank.fallbacks.is_empty())
	var extra: Array = []
	var short_not_full: Array = []
	for k in ext:
		if not String(k).begins_with("res."):
			continue
		var rk2: String = String(k).substr(4)
		if (ext[k] as Dictionary).has("full") and not res_keys.has(rk2):
			extra.append(rk2)
		if (ext[k] as Dictionary).has("short") and not (ext[k] as Dictionary).has("full"):
			short_not_full.append(rk2)
	_check("T1 names.tsv full 每鍵都在 resources 鍵集合（多出：%s）" % str(extra), extra.is_empty())
	_check("T1 names.tsv short ⊆ full（short 沒有 full：%s）" % str(short_not_full), short_not_full.is_empty())
	_present["T1"] = true
	# T2 槽對帳
	var bad_slots: Array = []
	for k in ext:
		for v in ext[k]:
			var want: Array = _slots(String(ext[k][v]))
			var got: Array = []
			if String(k).begins_with("advisor"):
				var sit2: String = String(k).substr(8) if String(k).substr(8) in AdvisorSystem.TEXT_SITUATIONS else "assess_enemy"
				got = AdvisorSystem._params_for(String(k), String(v), st, _ctx(st, sit2, "good", String(v) if String(k) == "advisor_source" else "聽說")).keys()
			got.sort()
			if want != got:
				bad_slots.append("%s|%s 句 %s ≠ params %s" % [k, v, str(want), str(got)])
	_check("T2 每個 (鍵,變體) 的槽集合＝_params_for 的 key 集合（不符：%s）" % str(bad_slots), bad_slots.is_empty())
	_present["T2"] = true


# ── T3 ───────────────────────────────────────────────────────────────────────
func _t3() -> void:
	print("\n── T3 交換畫面不印 ASCII 資源鍵 ──")
	seed(20261015)
	var scene: PackedScene = load("res://scenes/TextUI.tscn")
	var node = scene.instantiate()
	get_root().add_child(node)
	await process_frame
	await process_frame
	var st: WorldState = node._bridge.get_state()
	var ptid: int = st.get_player_team_id()
	var pt: TeamData = st.teams[ptid]
	var other: int = -1
	var ids: Array = st.teams.keys()
	ids.sort()
	for tid in ids:
		if int(tid) != ptid and st.is_live_team(int(tid)) and st.teams[tid].beast_kind == "":
			other = int(tid)
			break
	var ot: TeamData = st.teams[other]
	ot.tile_pos = pt.tile_pos
	for t in [pt, ot]:
		for rk in ["food", "material", "weapon_melee_low", "coin"]:
			ResourceBank.add(t, rk, 20, "bed")
	node._trade_target_id = other
	node._bridge.set_player_input("trade_offer", {"player_gives": {"food": 2.0, "weapon_melee_low": 1.0}, "player_wants": {"material": 3.0, "coin": 1.0}})
	var s: String = node._build_trade_str()
	print(s)
	var ascii: Array = []
	for m in RegEx.create_from_string("[a-z]+_[a-z_]+|\\b(food|material|coin|goods)\\b").search_all(s):
		ascii.append(m.get_string())
	_check("T3 母體地板：面板有列出物品（不是「需同格」）", s.contains("我給") and s.contains("出價："))
	_check("T3 面板無 ASCII 資源鍵（命中 %s）" % str(ascii), ascii.is_empty())
	var want_words: Array = []
	for rk in ["food", "material", "weapon_melee_low", "coin"]:
		want_words.append(TextBank.res_name(rk))
	_check("T3 印 %s" % str(want_words), want_words.all(func(w): return s.contains(String(w))))
	_check("T3 出價列也是顯示名（「出價：給 %s×」）" % TextBank.res_name("food"), s.contains("給 " + TextBank.res_name("food") + "×") or s.contains("、" + TextBank.res_name("food") + "×"))
	get_root().remove_child(node)
	node.free()
	await process_frame
	_present["T3"] = true


# ── T4 ───────────────────────────────────────────────────────────────────────
func _t4() -> void:
	print("\n── T4 顯示名只准一張表 ──")
	var ext: Dictionary = TextBank.external()
	var vals: Array = []
	for k in ext:
		if (String(k).begins_with("res.weapon_") or String(k).begins_with("res.armor_")) and (ext[k] as Dictionary).has("full"):
			vals.append(String(ext[k]["full"]))
	print("   母體：%s" % str(vals))
	_check("T4 母體地板：weapon_*／armor_* full 值 6 個", vals.size() == 6)
	var hits: Array = []
	var files: Array = []
	_collect_gd("res://scripts", files)
	for f in files:
		var i: int = 0
		for l in FileAccess.get_file_as_string(String(f)).split("\n"):
			i += 1
			var code: String = l.split("#")[0]
			for v in vals:
				if code.contains("\"" + String(v)) or code.contains(String(v) + "\""):
					hits.append("%s:%d %s" % [f, i, v])
	print("   掃了 %d 支 .gd" % files.size())
	_check("T4 掃描母體地板：.gd 檔 > 100", files.size() > 100)
	_check("T4 六個值在 .gd 字串字面零出現（命中：%s）" % str(hits), hits.is_empty())
	var diff: Array = []
	for k in ["weapon_melee_low", "weapon_melee_high", "weapon_ranged_low", "weapon_ranged_high", "armor_low", "armor_high", "medicine", "tools"]:
		if TeamUiHelper.item_name(k) != TextBank.res_name(k):
			diff.append(k)
	_check("T4 反向：裝備欄 item_name 與事件句 res_name 對同一鍵同一字（不同：%s）" % str(diff), diff.is_empty())
	_present["T4"] = true

func _collect_gd(dir_path: String, out: Array) -> void:
	var d := DirAccess.open(dir_path)
	if d == null:
		return
	for f in d.get_files():
		if String(f).ends_with(".gd"):
			out.append(dir_path + "/" + String(f))
	for sub in d.get_directories():
		_collect_gd(dir_path + "/" + String(sub), out)
