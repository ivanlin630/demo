extends SceneTree
# @observe-pure
# ★★★工期單一真值【常駐斷言】（systems 裁定 2026-09-01，S6 phase2 §4）。
#
# ★為什麼是常駐而不是一次性驗收：
#   一次性驗收只證明「落地那天是對的」，
#   ★★而我們整天在數的病全都是【落地那天是對的、後來沒人回來看】。
#
# ★★母體 ＝【`tile.construction_ticks_left` 的真寫入點】—— 引擎決定的軸：
#   任何工期要生效都得寫進那個欄位，★★★所以這個母體不會因為別人怎麼命名而發散。
#   （對照組：用 token 列舉「工期」會漏掉 CORVEE，因為它不經任何一張表——phase1 的血證。）
#
# ★斷言：每個【非清除】的寫入點，右手邊必須來自唯一入口 build_person_hours(...)。
#   ⇒ 手寫常數、第二張表、或「同步兩張表」的寫法，都會在這裡紅。
#
# ★★誠實限：本閘讀的是【原始碼文本】不是執行期的值。
#   ⇒ 它抓得到「這一行沒有經過入口」，★★★抓不到「經過入口但參數給錯 kind」。
#     後者由 s6_phase2_single_source_bed 的倍數對照守（兩支互補，缺一不可）。

const SCAN_DIRS: Array = ["res://scripts/simulation"]
const FIELD: String = "construction_ticks_left"
const ENTRY: String = "build_person_hours("

var _fail := 0
var _rows: Array = []

func _initialize() -> void:
	_run(); quit()

func _gather(dir_path: String, out: Array) -> void:
	var d := DirAccess.open(dir_path)
	if d == null:
		return
	d.list_dir_begin()
	var name := d.get_next()
	while name != "":
		if d.current_is_dir():
			if not name.begins_with("."):
				_gather(dir_path.path_join(name), out)
		elif name.ends_with(".gd"):
			out.append(dir_path.path_join(name))
		name = d.get_next()
	d.list_dir_end()

func _run() -> void:
	print("=== 工期單一真值常駐閘（母體＝%s 的真寫入點）===" % FIELD)
	var files: Array = []
	for root in SCAN_DIRS:
		_gather(String(root), files)
	files.sort()

	var n_clear: int = 0
	var n_ok: int = 0
	var bad: Array = []
	for fp in files:
		var f := FileAccess.open(String(fp), FileAccess.READ)
		if f == null:
			continue
		var lineno: int = 0
		while not f.eof_reached():
			var line: String = f.get_line()
			lineno += 1
			var stripped: String = line.strip_edges()
			if stripped.begins_with("#"):
				continue                      # ★註解自成一欄：不算母體
			var i: int = stripped.find(FIELD)
			if i < 0:
				continue
			# 只要【賦值】：欄位後面第一個非空白字元是 '=' 且不是 '=='
			var rest: String = stripped.substr(i + FIELD.length()).strip_edges()
			if not rest.begins_with("="):
				continue
			if rest.begins_with("=="):
				continue
			var rhs: String = rest.substr(1).strip_edges()
			if rhs.begins_with("-="):                      # `-=` 是推進不是設定工期
				continue
			var row: String = "%s:%d| %s" % [String(fp).replace("res://", ""), lineno, rhs]
			if rhs == "0":
				n_clear += 1                               # 清除工地，不是設定工期
			elif rhs.find(ENTRY) >= 0:
				n_ok += 1
				_rows.append("OK   | " + row)
			else:
				bad.append(row)
				_rows.append("★BAD | " + row)
		f.close()

	# `-=` 的推進行會被上面的 `begins_with("=")` 濾掉嗎？——不會，`-=` 的 '-' 在欄位與 '=' 之間。
	# ⇒ 這裡明白列出計數，讓母體大小【看得見】，而不是靠讀 code 相信它對。
	print("母體：真寫入點 %d（其中設定工期 %d、清除工地 %d）" % [n_ok + bad.size() + n_clear, n_ok + bad.size(), n_clear])
	for r in _rows:
		print("  ", r)

	if bad.is_empty():
		print("\n★PASS：每個設定工期的寫入點都來自唯一入口 %s" % ENTRY)
	else:
		_fail = bad.size()
		print("\n★FAIL：%d 個寫入點【沒有經過唯一入口】" % bad.size())
		for b in bad:
			print("  ", b)
		print("★處置：改成呼叫 OutpostSystem.build_person_hours(kind, level)。")
		print("★★不要在別處造第二張表再讓它等於錨 —— 那是【同步兩張表】，沒有人會維護那個關係。")

	var out: Array = []
	out.append("# 工期單一真值常駐閘｜母體＝%s 的真寫入點（引擎決定的軸）" % FIELD)
	out.append("# 設定工期 %d｜清除工地 %d｜未經入口 %d" % [n_ok + bad.size(), n_clear, bad.size()])
	for r in _rows:
		out.append(r)
	out.append("# ★誠實限：讀原始碼文本 ⇒ 抓得到「沒經過入口」，抓不到「經過入口但 kind 給錯」")
	out.append("#   後者由 s6_phase2_single_source_bed 的倍數對照守")
	var path: String = OS.get_environment("CDSG_OUT") if OS.has_environment("CDSG_OUT") \
		else "docs/measurements/.construction-duration-source-gate.txt"
	var wf := FileAccess.open(path, FileAccess.WRITE)
	if wf != null:
		wf.store_string("\n".join(PackedStringArray(out)) + "\n"); wf.close()
	print("=== construction_duration_source_gate DONE（fail=%d）===" % _fail)
