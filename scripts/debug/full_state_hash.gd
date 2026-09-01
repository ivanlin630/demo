# @observe-pure  ★純讀零寫零 RNG
class_name FullStateHash

# ★★★為什麼要有第三把尺（2026-09-02，A#14 驗收③）：
#   ★`StateFingerprint` 排除 ephemeral／cadence 欄 ⇒ 對「觀測污染快取」這一類【結構性瞎眼】
#   ★★`EphemeralStateHash` 補了那一半，★而它自己的檔頭就寫著「這是【下界】不是全集」——
#     ★★★它是一份【我手列的欄位清單】，而清單會漏，漏了不會有人知道。
#   ⇒ 本尺不列清單：★用 `get_property_list()` 把物件上【每一個 script 變數】都掃進來。
#     ★★這是「用形狀判，不用名單判」的同一條紀律（systems 2026-09-02 裁 `_begin_observe` 是黑名單時立的）。
#
# ★涵蓋：state.teams / state.world.tiles / state.persons / state.factions 的【全部 script 屬性】
# ★★★【只在同一棵樹內可比】—— 2026-09-02 血證，而它是【設計的直接後果】不是 bug：
#   ★systems 在 main 上重現我 branch 的數字，得到不同值（我 74fa9265 ／ 他 58bb00c4）。
#   ★★成因：本尺掃的是【全部 script 屬性】⇒ 兩棵樹的欄位集不同就必然不同雜湊。
#     實測：`team_data.gd` main 117 個 `var` ／ branch 121 個（branch 多 4 個食物流量欄）。
#   ⇒ ★★★所以它【正確地】對「有人靜靜加了一個欄位」敏感 —— 那正是它比手列清單強的地方，
#     ★而同一個性質讓它【跨 commit／跨分支不可比】。
#   ⇒ ★用法：只在【同一棵樹、同一份 code】內做 A/B（tracer 開/關、掛點有/無）；
#     ★★要跨 merge 邊界比，兩邊各自在自己的樹上跑，比【各自的 before/after】，不是比絕對值。
#
# ★★不涵蓋（誠實限，印在輸出旁邊）：
#   ①WorldState 自己的頂層欄（pending_* 等）——它們是 tick 內暫態，另議
#   ②Object reference 型欄位只取其 to_string（不遞迴展開）
#   ③★★★浮點【不量化】：本尺要抓的是「有沒有被碰過」，量化會把微小污染磨掉

const _SKIP_PREFIX: String = "_"   # ★私有/內部欄仍然收（GDScript 的 _ 只是慣例）——這行留著是為了說明「我沒有跳過它們」

static func _props_of(o: Object) -> PackedStringArray:
	var out: PackedStringArray = PackedStringArray()
	for p in o.get_property_list():
		# ★只收 script 變數（PROPERTY_USAGE_SCRIPT_VARIABLE），不收引擎內建欄
		if int(p.get("usage", 0)) & PROPERTY_USAGE_SCRIPT_VARIABLE:
			out.append(String(p["name"]))
	out.sort()
	return out

static func _val_str(v) -> String:
	if v is Dictionary:
		var ks: Array = v.keys(); ks.sort()
		var parts: PackedStringArray = PackedStringArray()
		for k in ks:
			parts.append("%s=%s" % [str(k), _val_str(v[k])])
		return "{" + ",".join(parts) + "}"
	if v is Array:
		var pa: PackedStringArray = PackedStringArray()
		for x in v:
			pa.append(_val_str(x))
		return "[" + ",".join(pa) + "]"
	if v is Object:
		return "<obj>"   # ★不遞迴：物件參考另行由它自己的容器掃到
	return str(v)

static func _dump_collection(coll: Dictionary, tag: String, buf: PackedStringArray) -> void:
	var keys: Array = coll.keys(); keys.sort()
	for k in keys:
		var o = coll[k]
		if not (o is Object):
			buf.append("%s[%s]=%s" % [tag, str(k), _val_str(o)]); continue
		var line: PackedStringArray = PackedStringArray()
		for pn in _props_of(o):
			line.append("%s=%s" % [pn, _val_str(o.get(pn))])
		buf.append("%s[%s]|%s" % [tag, str(k), ";".join(line)])

static func compute(state: WorldState) -> String:
	var buf: PackedStringArray = PackedStringArray()
	_dump_collection(state.teams, "T", buf)
	_dump_collection(state.world.tiles, "L", buf)
	_dump_collection(state.persons, "P", buf)
	_dump_collection(state.factions, "F", buf)
	return "\n".join(buf).md5_text()

# ★輸出時必附（invariant：盲區要出現在【使用它的當下】）
static func note() -> String:
	return "[FULL-HASH] 涵蓋 teams/tiles/persons/factions 的【全部 script 屬性】（get_property_list，非手列清單）" \
		+ "｜★★★【只在同一棵樹內可比】：欄位集一變雜湊就變（設計如此，非 bug）——跨 commit/分支請比各自的 before/after，不要比絕對值" \
		+ "｜★不含 WorldState 頂層暫態欄；★★Object 參考不遞迴；★★★float 不量化（要抓「有沒有被碰過」）"
