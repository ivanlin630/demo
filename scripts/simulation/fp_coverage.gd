class_name FpCoverage

# ★★★「會影響行為的欄位」全集 —— 而它是【生成的】，不是手抄的（HOW spec 2026-09-10）。
#
# ★核心難點：「會影響行為」是【語意】，機器判不了。
#   ⇒ 用一個【保守的機械代理】：**該欄位有沒有被模擬層的 code 讀到**。
#   ⇒ ★★這個代理故意偏保守（「被讀到」⊋「真的影響行為」——讀了之後丟掉也算）
#      而方向是對的：**決定論尺寧可多守，不可少守**。
#
# 豁免三類，★每一類都要有【機械可驗的證據】（沒有證據的豁免 ＝ 不豁免）：
#   (a) ephemeral 快取   ⇒ 證據：清空 → 推進 → 值被算回來（床跑）
#   (b) cadence 排程欄   ⇒ 證據：★由【後綴規則】導出而不是列名字；且進尺不得讓同 seed 兩跑分岔
#   (c) 觀測／記帳專用   ⇒ 證據：★★它的讀取點【全部】落在輸出位置（print/Probe/emit_message）
#                            —— 而這正是 §① 判準的反面，同一支工具算出來的
#
# ★★★誠實限（三條，跟著清單一起活）：
#   ①代理是【超集】：某欄可能被讀了卻對行為無影響 ⇒ 多守，不是錯守。
#   ②跨類同名欄位會互相掩蓋（`tile_pos`／`faction_id` 這種）⇒ 仍是【多守】的方向。
#   ③本工具看不到【第三層】（Dictionary 內部的鍵）。

const SIM_DIRS: Array = ["res://scripts/simulation", "res://scripts/data"]
# ★輸出位置：這些呼叫裡的讀取【不算】「模擬層讀到」（它們是觀測，不是決策）
const OUTPUT_MARKERS: Array = ["print(", "Probe.", "emit_message(", "push_error(", "push_warning("]
# ★cadence 由【後綴規則】判定 —— ★★不是列一份名字（列名字的清單不會跟著世界長大）
const CADENCE_SUFFIXES: Array = ["_eval_next_tick", "_next_tick", "_check_tick"]
# ★ephemeral：這一份【是列名字的】，而每一個名字都要在床裡通過 (a) 的證據測試才算數
const EPHEMERAL_FIELDS: Array = ["food_runway", "persist_strength", "food_flow_avg", "need_urgency"]

static var _cache: Dictionary = {}
static var _src_cache: String = ""

# 把模擬層全部 .gd 讀成一份【剝掉註解與輸出行】的文字（★一次，之後靠 cache）
static func sim_source() -> String:
	if _src_cache != "":
		return _src_cache
	var buf: PackedStringArray = PackedStringArray()
	for d in SIM_DIRS:
		_collect(String(d), buf)
	_src_cache = "\n".join(buf)
	return _src_cache

static func _collect(dir_path: String, buf: PackedStringArray) -> void:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return
	dir.list_dir_begin()
	var name: String = dir.get_next()
	while name != "":
		var full: String = dir_path + "/" + name
		if dir.current_is_dir():
			if not name.begins_with("."):
				_collect(full, buf)
		elif name.ends_with(".gd"):
			var f := FileAccess.open(full, FileAccess.READ)
			if f != null:
				for l in f.get_as_text().split("\n"):
					var line: String = String(l)
					var h: int = line.find("#")
					if h >= 0:
						line = line.substr(0, h)      # ★剝註解：提及 ≠ 讀取
					var is_output: bool = false
					for m in OUTPUT_MARKERS:
						if line.contains(String(m)):
							is_output = true
							break
					if is_output:
						continue                      # ★輸出行整行不算（保守：寧可少算成「被讀」）
					buf.append(line)
				f.close()
		name = dir.get_next()
	dir.list_dir_end()

# 回 {類名: {"in_ruler": [], "cadence": [], "ephemeral": [], "observation": []}}
static func derive() -> Dictionary:
	if not _cache.is_empty():
		return _cache
	var src: String = sim_source()
	var out: Dictionary = {}
	for entry in StateFingerprint.SUBFIELD_MAP:
		var cls: String = String(entry[0])
		var sc = load(String(entry[1]))
		if sc == null:
			continue
		var in_ruler: Array = []
		var cadence: Array = []
		var ephemeral: Array = []
		var observation: Array = []
		for pi in sc.get_script_property_list():
			var n: String = String(pi.get("name", ""))
			if n == "" or n.begins_with("_"):
				continue
			if int(pi.get("usage", 0)) & PROPERTY_USAGE_SCRIPT_VARIABLE == 0:
				continue
			if _is_cadence(n):
				cadence.append(n)
			elif n in EPHEMERAL_FIELDS:
				ephemeral.append(n)
			elif src.contains("." + n):
				in_ruler.append(n)
			else:
				observation.append(n)   # ★只在輸出行被讀到（或根本沒被讀）⇒ (c) 候選
		in_ruler.sort(); cadence.sort(); ephemeral.sort(); observation.sort()
		out[cls] = {"in_ruler": in_ruler, "cadence": cadence,
			"ephemeral": ephemeral, "observation": observation}
	_cache = out
	return out

static func _is_cadence(n: String) -> bool:
	for suf in CADENCE_SUFFIXES:
		if n.ends_with(String(suf)):
			return true
	return false

# 某一類要進尺的欄位（給 StateFingerprint 用；★排序過 ⇒ canonical）
static func fields_for(cls: String) -> Array:
	var d: Dictionary = derive()
	if not d.has(cls):
		return []
	return d[cls]["in_ruler"]
