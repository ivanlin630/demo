class_name StateFingerprint

# ★F0 安全網（spec 2026-08-07-framework-F0-state-fingerprint-HOW）：全 world-state 結構化 canonical hash。
# ★★命門：純讀 state 零寫、★零 global RNG（觀測儀器不擾世界=[[feedback_observer_no_global_rng]] LOD→RNG 犯過 2 次、第三度警戒）。
# 用途：純結構 slice（抽 decision chunk/切模組）前後 fingerprint 三跑一致 + 多 seed×多床 regression 不變 = 真證「只搬位置」（行為零漂移）。
# full canonical（sorted-by-id + dict 顯式 sort[非信 GDScript4 插入序、跨 code 版本序穩定]+ float 量化 round 1e-4）→ hash collapse 任意 size 成定長。

const QUANT: float = 10000.0   # float 量化 1e-4（避浮點格式噪；round(x*QUANT) 整數化）

# ★★★本尺【排除】什麼 —— 而它必須被【印在使用它的當下】，不能只寫在註解裡。
#   血證（2026-09-01）：這段排除清單本來只存在於 :69 的一行註解裡，
#   ⇒ ★於是有人（systems）拿 fp 當「tracer 沒有污染世界」的證據，
#     ★★而 fp 對那個 bug 類別是【結構性地瞎的】——它不是量不到，是設計上就不看。
#   ⇒ ★★★systems 已立成 invariant：凡輸出 fingerprint／比對結果的地方，
#     同一段輸出要帶一行「本尺排除：…」。這個常數就是那一行的單一來源。
# ★★★【子層級】的排除 —— 這一段仍然是【手抄的】，而我把它標出來而不是假裝它不是：
#   它講的是 TeamData／PersonData 內部的欄位（food_runway 等），
#   ★而本檔的導出檢查只涵蓋【WorldState 的頂層欄位】那個粒度
#   ⇒ ★★「_emit_teams 漏掉 TeamData 某個新欄位」這一類【本尺仍然看不到】，說在前面。
const EXCLUDES_SUBFIELD: String = "ephemeral 快取(food_runway/persist_strength/food_flow_avg/need_urgency)" 	+ " ＋ cadence 排程欄(*_eval_next_tick) ＋ observer/probe"

const WORLD_STATE_PATH: String = "res://scripts/data/world_state.gd"
const SELF_PATH: String = "res://scripts/simulation/state_fingerprint.gd"

static var _derived_cache: Array = []

# ★頂層欄位的排除清單＝【算出來的】，不是手抄的（HOW spec 2026-09-10）。
#   判準：WorldState 的某個 var 欄位，本檔【有沒有真的去讀它】（原始碼裡出現 "state.<欄位>"）——
#   ★沒讀到 ⇒ 它就進「本尺排除」那一行，而那一行從此是【算出來的】不是手抄的。
#   ★★它信任的不是某一個字串（EXCLUDES 那種），是【整份原始碼的文字搜尋】，
#   ★★★所以「新增一個頂層欄位而兩邊都沒提到它」這種靜默缺席，在這個粒度上不會發生。
static func derived_excludes() -> Array:
	if not _derived_cache.is_empty():
		return _derived_cache
	var f := FileAccess.open(SELF_PATH, FileAccess.READ)
	if f == null:
		return ["<讀不到本檔原始碼 ⇒ 這一行【不可判】，不要當成「沒有盲區」>"]
	var src: String = f.get_as_text()
	f.close()
	var ws_script = load(WORLD_STATE_PATH)
	if ws_script == null:
		return ["<讀不到 world_state.gd ⇒ 不可判>"]
	_derived_cache = derive_from(ws_script, src)
	return _derived_cache

# ★推導本體拆成純函式：★★這樣床可以餵【假的 WorldState ＋ 假的 fp 原始碼】給它，
#   ⇒ 「加一個新欄位會不會被具名」不用真的去改 WorldState 才驗得到。
static func derive_from(ws_script, src: String) -> Array:
	var missing: Array = []
	for pi in ws_script.get_script_property_list():
		var n: String = String(pi.get("name", ""))
		if n == "" or n.begins_with("_"):
			continue
		if int(pi.get("usage", 0)) & PROPERTY_USAGE_SCRIPT_VARIABLE == 0:
			continue
		# ★判準是【本檔有沒有真的去讀它】＝ 原始碼裡出現 "state.<欄位>"，
		#   ★★而不是「這個名字在檔案裡出現過」—— 血證：我第一版用後者，
		#   結果我自己在【註解裡提到 player_pending_targets】就讓它從盲區清單消失了
		#   ⇒ ★★★一個會被【提到它的註解】關掉的檢查，等於誰寫一句話就能讓紅燈熄掉。
		if not src.contains("state." + n):
			missing.append(n)
	missing.sort()
	return missing

# ★★★子層級的導出檢查（HOW spec 2026-09-10）：頂層那支【自己寫明看不到子層級】——
#   「_emit_teams 漏掉 TeamData 某個新欄位」那一類。★而一個【被寫下來的洞仍然是洞】。
#   母體＝每個被序列化的資料類的 var 欄位（get_script_property_list 抽，不手抄）；
#   判準＝【那支 _emit_* 裡宣告的、型別相符的那個變數】的 "<變數>.<欄位>"
#     ★★R² 訂正：只比對 ".<欄位>" 會誤判 —— 函式裡若有第二個變數剛好有同名欄位
#     （tile_pos／faction_id／team_id 這種橫跨多類的常見名）就會被算成「讀過了」。
#     ⇒ 現在先從函式本體抓出 `var X: <該類>` 的變數名，再組 "X.<欄位>"。
#   ★註解先被剝掉（「提及 ≠ 讀取」，今天血證過一次，不重演）。
#   ★★★它仍然看不到【第三層】（例如 TeamData 裡某個 Dictionary 的鍵）—— 這句住在這裡，
#   不是只住在交件信裡。
const SUBFIELD_MAP: Array = [
	["TeamData",    "res://scripts/data/team_data.gd",    "_emit_teams",   ""],
	["PersonData",  "res://scripts/data/person_data.gd",  "_emit_persons", ""],
	["FactionData", "res://scripts/data/faction_data.gd", "_emit_factions",""],
	["HexTileData", "res://scripts/data/tile_data.gd",    "_emit_tiles",   ""],
	# ★WorldData 沒有 `var w: WorldData` 這種宣告，它一律走 state.world.<欄位>
	#   ⇒ 用 accessor 提示（第四欄），而不是硬套「找型別宣告」那條規則。
	["WorldData",   "res://scripts/data/world_data.gd",   "_emit_world",   "state.world"],
]

# ★★兩支【被排除而那是對的】的 _emit_*：它們序列化的是【裸 Dictionary】，
#   沒有 class_name 背書 ⇒ get_script_property_list 天生不適用（不是漏，是不適用）。
const SUBFIELD_NOT_APPLICABLE: Array = ["_emit_belief", "_emit_player"]

static var _subfield_cache: Dictionary = {}

# ★R² 補的第二格：SUBFIELD_MAP 自己【也是手抄的】——第 8 支 _emit_* 出現時，
#   沒有任何機制會發現它沒跟著加一行 ⇒ ★★本票要根治的病換了個容器又長出來。
#   ⇒ 這支把【行集本身】也變成導出的：本檔所有 static func _emit_* × 已登記的 ⇒ 差集具名。
static func emit_registry_gaps() -> Array:
	var f := FileAccess.open(SELF_PATH, FileAccess.READ)
	if f == null:
		return ["<讀不到本檔原始碼 ⇒ 不可判>"]
	var src: String = f.get_as_text()
	f.close()
	var registered: Array = []
	for entry in SUBFIELD_MAP:
		if String(entry[2]) != "":
			registered.append(String(entry[2]))
	var gaps: Array = []
	for l in src.split("\n"):
		var line: String = String(l)
		if not line.begins_with("static func _emit_"):
			continue
		var nm: String = line.substr(12, line.find("(") - 12)
		if nm in registered or nm in SUBFIELD_NOT_APPLICABLE:
			continue
		gaps.append(nm)
	gaps.sort()
	return gaps

# 回 {類名: {"in_ruler": [...], "string_read": [...], "excluded": [...]}}
static func derived_subfield_excludes() -> Dictionary:
	if not _subfield_cache.is_empty():
		return _subfield_cache
	var f := FileAccess.open(SELF_PATH, FileAccess.READ)
	if f == null:
		return {"<讀不到本檔原始碼>": {"in_ruler": [], "string_read": [], "excluded": []}}
	var src: String = f.get_as_text()
	f.close()
	var out: Dictionary = {}
	for entry in SUBFIELD_MAP:
		var cls: String = String(entry[0])
		var sc = load(String(entry[1]))
		if sc == null:
			continue
		# ★accessor 非空（WorldData 走 state.world.<欄位>）⇒ 用整份原始碼：
		#   它的欄位散在 _emit_world 與 _emit_tiles 兩支裡（tiles 是被 _emit_tiles 讀的）。
		var body: String = _strip_comments(src) if String(entry[3]) != "" else _slice_fn_body(src, String(entry[2]))
		var accessor: String = String(entry[3])
		if accessor == "":
			accessor = _typed_var_name(body, cls)
		out[cls] = derive_subfield_from(sc, body, accessor)
	_subfield_cache = out
	return out

# 從函式本體抓出 `var X: <型別>` 的變數名（★沒抓到 ⇒ 回空字串，而空字串會讓
#   下面那支【拒絕判斷】而不是退回寬鬆比對 —— 判不了要說判不了，不要偷偷降級。）
static func _typed_var_name(body: String, cls: String) -> String:
	for l in body.split("\n"):
		var line: String = String(l).strip_edges()
		if not line.begins_with("var "):
			continue
		var colon: int = line.find(": " + cls)
		if colon < 0:
			continue
		return line.substr(4, colon - 4).strip_edges()
	return ""

static func _strip_comments(src: String) -> String:
	var out: PackedStringArray = PackedStringArray()
	for l in src.split("\n"):
		var line: String = String(l)
		var hash_at: int = line.find("#")
		if hash_at >= 0:
			line = line.substr(0, hash_at)
		out.append(line)
	return "\n".join(out)

# 抽出某支函式的本體（到下一個 "static func" 為止）
# ★名字不叫 _emit_body：★★床第一次跑就抓到——它自己會被 emit_registry_gaps 的
#   「static func _emit_」掃到，變成一支【未登記的 _emit_*】＝我的工具誤報我自己。
static func _slice_fn_body(src: String, fname: String) -> String:
	var body: PackedStringArray = PackedStringArray()
	var inside: bool = false
	for l in _strip_comments(src).split("\n"):
		var line: String = String(l)
		if line.begins_with("static func "):
			inside = line.begins_with("static func " + fname + "(")
			continue
		if not inside:
			continue
		body.append(line)
	return "\n".join(body)

# 純函式（床可餵假類 ＋ 假本體 ＋ 假 accessor）
static func derive_subfield_from(cls_script, body_raw: String, accessor: String = "") -> Dictionary:
	# ★剝註解【在判準這一側】做，不是靠呼叫端先剝好：
	#   ★★床第一次跑就抓到 —— 我原本把剝註解放在 _emit_body（只有真實檔案走它），
	#   而床餵原始文字進來，於是「提及 ≠ 讀取」那一格當場紅。
	#   ★★★保證要跟【做判斷的那段程式碼】住在一起，否則它只對某一條呼叫路徑成立。
	var body: String = _strip_comments(body_raw)
	var in_ruler: Array = []
	var string_read: Array = []
	var excluded: Array = []
	if accessor == "":
		return {"in_ruler": [], "string_read": [],
			"excluded": ["<找不到型別相符的變數 ⇒ 本類【不可判】，不退回寬鬆比對>"]}
	for pi in cls_script.get_script_property_list():
		var n: String = String(pi.get("name", ""))
		if n == "" or n.begins_with("_"):
			continue
		if int(pi.get("usage", 0)) & PROPERTY_USAGE_SCRIPT_VARIABLE == 0:
			continue
		if body.contains(accessor + "." + n):
			in_ruler.append(n)
		elif body.contains('"' + n + '"'):
			# ★第三桶（★★量出來的，不是我設計的）：farming_level 走 t.get("farming_level")
			#   ⇒ 字串鍵動態讀取，"<變數>.<欄位>" 這個判準看不到它。
			#   ★★★不併進「尺內」是因為字串也可能只是某個 dict 的鍵
			#   ⇒ 併進去會【隱藏一個真的缺口】，而漏報比誤報貴。
			string_read.append(n)
		else:
			excluded.append(n)
	in_ruler.sort()
	string_read.sort()
	excluded.sort()
	return {"in_ruler": in_ruler, "string_read": string_read, "excluded": excluded}


# ★輸出 fp 的地方請印這一行（單一來源，改一處全部跟）。
static func blind_note() -> String:
	var d: Array = derived_excludes()
	var top: String = ("、".join(d)) if not d.is_empty() else "（無）"
	var out: String = "[FP-BLIND] ★本尺排除【頂層欄位・導出】：" + top
	out += "｜【子層級・導出】" + _subfield_summary()
	var gaps: Array = emit_registry_gaps()
	if not gaps.is_empty():
		# ★登記表自己少了一列 ⇒ 印在同一行（★★它不會靜默：少一列不會紅＝橡皮圖章）
		out += "｜★★未登記的 _emit_*：" + "、".join(gaps)
	out += "｜【子層級・手抄補述（只涵蓋列出的那些）】" + EXCLUDES_SUBFIELD
	out += " ⇒ ★★fp 相同【不等於】沒有污染（那半由 EphemeralStateHash 量）"
	out += " ★★★而三層以下（dict 內部的鍵）本尺看不到。"
	return out

static func _subfield_summary() -> String:
	var parts: PackedStringArray = PackedStringArray()
	for cls in derived_subfield_excludes():
		var d: Dictionary = derived_subfield_excludes()[cls]
		parts.append("%s 尺內 %d／字串鍵讀取 %d／★沒看到被讀 %d：%s" % [String(cls),
			(d["in_ruler"] as Array).size(), (d["string_read"] as Array).size(),
			(d["excluded"] as Array).size(), "、".join(d["excluded"])])
	return " ｜ ".join(parts)

# 全 state canonical hash（decision-and-lifecycle-affected state；純讀零 RNG）。
static func compute(state: WorldState) -> String:
	var buf: PackedStringArray = PackedStringArray()
	_emit_teams(state, buf)
	_emit_persons(state, buf)
	_emit_factions(state, buf)
	_emit_belief(state, buf)
	_emit_tiles(state, buf)
	_emit_world(state, buf)
	_emit_player(state, buf)
	return "\n".join(buf).md5_text()

# ★★★哨兵（HOW spec 2026-09-10）：player_* 進 canon 【不是】因為玩家會影響 sim，
#   而是因為【sim 不該碰 player_*】—— 兩顆【無玩家】的 seeded 跑若在這一段上分岔，
#   ⇒ ★有系統在沒有玩家的世界裡寫了玩家欄（或更兇：在那條路上耗掉全域 RNG）。
#   ★★精確版（不是字面版）：sim 可以【對玩家說話】，但【只在有玩家的時候】
#     —— 字面版會讓 player_forced_event／player_alerts 不能存在，遊戲玩不成。
#   ★★★它看到的粒度：頂層 10 個 player_* 欄位；Dictionary 走【鍵排序後的鍵＋值】、
#     Array 走整個 str() —— 所以 player_state 這種 dict 的【內部鍵】看得到，
#     而巢狀第二層以下只走 str()：形狀變了看得到，浮點細節不保證。
static func _emit_player(state: WorldState, buf: PackedStringArray) -> void:
	buf.append("P|id=%d|possess_prev=%d|fe_id=%s" % [
		state.player_id, state.player_possess_prev, state.player_forced_event_id])
	buf.append("P|hostile=%s" % str(state.player_hostile_teams))
	buf.append("P|pending_targets=%s" % str(state.player_pending_targets))
	buf.append("P|alerts=%d" % state.player_alerts.size())
	for pair in [["state", state.player_state], ["forced_event", state.player_forced_event],
			["pending_orders", state.player_pending_orders], ["pre_encounter", state.player_pre_encounter]]:
		var d: Dictionary = pair[1]
		var ks: Array = d.keys()
		ks.sort()
		var parts: PackedStringArray = PackedStringArray()
		for k in ks:
			parts.append("%s=%s" % [str(k), str(d[k])])
		buf.append("P|%s{%s}" % [String(pair[0]), ",".join(parts)])

# ★給床用：只取 player_* 那一段（★「fp 相同」與「player 段相同」是兩個不同的斷言，
#   ★★而哨兵要的是後者 —— 前者可能因為世界別處也一起變而說不清楚）。
static func player_section(state: WorldState) -> String:
	var buf: PackedStringArray = PackedStringArray()
	_emit_player(state, buf)
	return "\n".join(buf)

# 逐域 fingerprint（除錯/假覆蓋檢：驗某域欄位在 27 筆真有變化非死值）。
static func compute_domains(state: WorldState) -> Dictionary:
	var t := PackedStringArray(); _emit_teams(state, t)
	var p := PackedStringArray(); _emit_persons(state, p)
	var f := PackedStringArray(); _emit_factions(state, f)
	var b := PackedStringArray(); _emit_belief(state, b)
	var ti := PackedStringArray(); _emit_tiles(state, ti)
	var w := PackedStringArray(); _emit_world(state, w)
	return {
		"teams": "\n".join(t).md5_text(), "persons": "\n".join(p).md5_text(),
		"factions": "\n".join(f).md5_text(), "belief": "\n".join(b).md5_text(),
		"tiles": "\n".join(ti).md5_text(), "world": "\n".join(w).md5_text(),
	}

# ──────── canonical 序列化 primitives（純函式）────────
static func _q(v: float) -> String:
	return str(roundi(v * QUANT))   # 量化整數化（穩定、無浮點格式噪）

static func _vec(v: Vector2i) -> String:
	return "%d,%d" % [v.x, v.y]

static func _dict_canon(d: Dictionary) -> String:
	var keys: Array = d.keys(); keys.sort()   # ★顯式 sort（非信插入序）
	var parts: PackedStringArray = PackedStringArray()
	for k in keys:
		parts.append("%s=%s" % [str(k), _val_canon(d[k])])
	return ";".join(parts)

static func _arr_canon(a: Array) -> String:
	var c: Array = []
	for x in a: c.append(str(x))
	c.sort()   # ★sort（set 語意欄如 tags/members 序穩定）
	return ";".join(PackedStringArray(c))

static func _val_canon(v) -> String:
	if v is float: return _q(v)
	if v is int or v is bool: return str(v)
	if v is Vector2i: return _vec(v)
	if v is Dictionary: return "{" + _dict_canon(v) + "}"
	if v is Array: return "[" + _arr_canon(v) + "]"
	return str(v)

# ★★★覆蓋擴張（HOW spec 2026-09-10）：進尺欄位【由 FpCoverage 導出】，不手抄。
#   ★每一支 _emit_* 的手寫那一行【保留】（它是給人讀的骨架），
#   ★★而下面這一行是【機器維護的全集】—— 新增欄位自動進尺，不必有人記得回來改。
#   ★★★物件型別的值一律只取類名：物件的 str() 帶 instance id，★逐跑不同 ⇒ 會把尺變成噪音。
static func _derived_line(obj: Object, tag: String, cls: String) -> String:
	var parts: PackedStringArray = PackedStringArray()
	for n in FpCoverage.fields_for(cls):
		parts.append("%s=%s" % [n, _canon_deep(obj.get(n))])
	return "%s|%s" % [tag, ";".join(parts)]

# ★物件在【任何深度】都只取類名 —— ★★血證：第一版只擋了頂層，
#   而 WorldData.tiles 是一個【裝滿物件的 Dictionary】⇒ _val_canon 落到 str() ⇒ 吐出 instance id
#   ⇒ ★★★同 seed 兩跑 fp 不同 = 這張票唯一的真風險（尺變噪音）當場現形，
#     而它不是「某欄該被豁免」，是【我的序列化寫錯了】—— 兩者的處置完全不同。
static func _canon_deep(v, depth: int = 0) -> String:
	if depth > 4:
		return "…"
	if v is Object:
		var o: Object = v
		if o.get_script() != null:
			return "OBJ:" + String(o.get_script().resource_path.get_file())
		return "OBJ:" + o.get_class()
	if v is Dictionary:
		var ks: Array = (v as Dictionary).keys()
		ks.sort()
		var dp: PackedStringArray = PackedStringArray()
		for k in ks:
			dp.append("%s=%s" % [str(k), _canon_deep((v as Dictionary)[k], depth + 1)])
		return "{" + ";".join(dp) + "}"
	if v is Array:
		var ap: Array = []
		for e in (v as Array):
			ap.append(_canon_deep(e, depth + 1))
		ap.sort()
		return "[" + ";".join(PackedStringArray(ap)) + "]"
	return _val_canon(v)

# ──────── 域序列化（sorted by id、spec §2.1 欄位）────────
static func _emit_teams(state: WorldState, buf: PackedStringArray) -> void:
	var ids: Array = state.teams.keys(); ids.sort()
	for tid in ids:
		var t: TeamData = state.teams[tid]
		# 全 decision/lifecycle 持久欄（full canonical、最大化 drift 偵測）。
		# ★排除 ephemeral 快取（food_runway/persist_strength/food_flow_avg/need_urgency=recompute/EWMA）+ cadence 排程欄（*_eval_next_tick）+ observer/probe。
		buf.append("T|%d|pop=%d|minor=%d|prisoner=%d|task=%s|prio=%d|reason=%s|prev=%s|pos=%s|mt=%s|corvee=%s|fac=%d|parent=%d|combat=%d|social=%d|opt=%s|unrest=%d|famine=%s|rung=%d|phase=%s|breedp=%s|breedt=%d|res=%s|tags=%s|anon=%s|subs=%s|rep=%s|intent=%s|goals=%s|fail=%s|wo=%s" % [
			t.team_id, t.population, t.minor_population, t.prisoner_population, t.current_task, t.task_priority, t.task_reason, t.previous_task,
			_vec(t.tile_pos), _vec(t.move_target), _vec(t.corvee_site), t.faction_id, t.parent_team_id, t.combat_target, t.social_target,
			t.current_option, t.unrest_turns, _q(t.famine_days), t.ambition_rung, t.plan_phase,
			# ★生育累積器兩欄＝直接因果態（值本身決定下次跨過 1.0 是哪個 tick）→ 必入 fp
			_q(t.breed_progress), t.breed_progress_last_tick,
			_dict_canon(t.resources), _arr_canon(t.tags), _dict_canon(t.anon_cohorts), _arr_canon(t.subteam_ids),
			_dict_canon(t.known_reputations), _dict_canon(t.solo_intent), _arr_canon(t.goal_state),
			# ★失敗記憶＝直接因果態（乘進 util、改下輪 argmax）→ 必入 fp（同 breed_progress 判準）
			# ★登記錨 ④a：`work_outpost` 是【持久決策態】（居民身分由它答）⇒ 必入 fp
			#   ⇒ ★fp 會變，而那是預期的（spec 驗收⑤）：附歸因、同 seed 兩跑仍須相同。
			_dict_canon(t.recent_failures), _vec(t.work_outpost)])
		buf.append(_derived_line(t, "TD", "TeamData"))

static func _emit_persons(state: WorldState, buf: PackedStringArray) -> void:
	var ids: Array = state.persons.keys(); ids.sort()
	for pid in ids:
		var p: PersonData = state.persons[pid]
		buf.append("P|%d|team=%d|dead=%s|loy=%s|values=%s|skills=%s|mem=%s" % [
			p.id, p.team_id, str(p.is_dead), _q(p.loyalty),
			_dict_canon(p.values), _dict_canon(p.skills), _memory_canon(p.memory)])

# memory full canonical（type+key+tick sorted、非全 value dump=防噪但足偵移位漂移）。
		buf.append(_derived_line(p, "PD", "PersonData"))
static func _memory_canon(mem: Array) -> String:
	var lines: PackedStringArray = PackedStringArray()
	for m in mem:
		if m is Dictionary:
			lines.append("%s:%s:%s" % [str(m.get("type", "")), str(m.get("key", m.get("subject", ""))), str(m.get("tick", ""))])
		else:
			lines.append(str(m))
	var s: Array = []
	for l in lines: s.append(l)
	s.sort()
	return ";".join(PackedStringArray(s))

static func _emit_factions(state: WorldState, buf: PackedStringArray) -> void:
	var ids: Array = state.factions.keys(); ids.sort()
	for fid in ids:
		var f: FactionData = state.factions[fid]
		buf.append("F|%d|leader=%d|est=%s|members=%s|goals=%s|drivers=%s|relations=%s" % [
			f.faction_id, f.leader_team_id, str(f.is_established),
			_arr_canon(f.member_team_ids), _arr_canon(f.goals), _dict_canon(f.goal_drivers), _dict_canon(f.relations)])
		buf.append(_derived_line(f, "FD", "FactionData"))

static func _emit_belief(state: WorldState, buf: PackedStringArray) -> void:
	# per-observer sorted canonical（team_discovered / team_intel / known_reputations 結構摘要）。
	var obs: Array = state.team_discovered.keys(); obs.sort()
	for oid in obs:
		buf.append("Bd|%d|%s" % [oid, _arr_canon(state.team_discovered[oid])])
	var iobs: Array = state.team_intel.keys(); iobs.sort()
	for oid in iobs:
		buf.append("Bi|%d|%s" % [oid, _val_canon(state.team_intel[oid])])

static func _emit_tiles(state: WorldState, buf: PackedStringArray) -> void:
	var ids: Array = state.world.tiles.keys(); ids.sort()
	for tid in ids:
		var t: HexTileData = state.world.tiles[tid]
		if t.outpost_level <= 0 and t.construction_team_id == -1 and t.camp_level <= 0:
			continue   # 純野格無 outpost/施工/L0營地 → 不入 fingerprint（★S2a：camp_level>0 必入、否則 L0 變化 determinism 盲點）
		buf.append("H|%d|owner=%d|lvl=%d|camp=%d|campleft=%d|campteam=%d|farm=%s|ctid=%d|cleft=%d|store=%s" % [
			tid, t.outpost_owner, t.outpost_level, t.camp_level, t.camp_ticks_left, t.camp_team_id,
			str(t.get("farming_level")), t.construction_team_id, t.construction_ticks_left,
			_dict_canon(t.public_storage)])
		buf.append(_derived_line(t, "HD", "HexTileData"))

static func _emit_world(state: WorldState, buf: PackedStringArray) -> void:
	buf.append("W|tick=%d|letters=%d|teams=%d|persons=%d|factions=%d|pending_erase=%d" % [
		state.world.current_tick, state.in_transit_letters.size(),
		state.teams.size(), state.persons.size(), state.factions.size(), state.teams_pending_erase.size()])
	# in_transit_letters canonical（kind/origin/target/relocate_to sorted、真送達漂移偵測）。
	var ls: Array = []
	for l in state.in_transit_letters:
		if l is Dictionary:
			ls.append("%s:%d:%s:%s" % [str(l.get("kind","")), int(l.get("origin_team_id",-1)), _vec(l.get("target_pos", Vector2i(-1,-1))), _vec(l.get("relocate_to", Vector2i(-1,-1)))])
	ls.sort()
	for e in ls: buf.append("L|" + e)
	buf.append(_derived_line(state.world, "WD", "WorldData"))
