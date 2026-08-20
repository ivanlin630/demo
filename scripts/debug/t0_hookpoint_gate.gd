extends SceneTree
# ★T4 對帳守衛（constitution_gate 級）：production 裡 emit_message 用到的 type 集合
# 必須全部在 WorldEvents.MESSAGE_KINDS 掛點表內。新增突發事件型別未掛 → FAIL。
# ＝讓「白名單挑食」結構上不可能，而不是靠紀律。
#
# ★誠實邊界（spec §5）：本守衛只保護【①訊息型】（type 可枚舉）；
#   ②函式 chokepoint 與 ③狀態跨線【沒有結構性保護】——背叛正是從那個缺口漏的
#   （零 emit_message、卻有 player_alerts）。弱防護記 backlog、非本輪。
#
# env T0_FAKE_TYPE=1 → 注入一個假 type 驗守衛真的有牙（gate 要求）。

const SCAN_DIRS: Array = ["res://scripts/simulation", "res://scripts/simulation/decision",
	"res://scripts/simulation/events", "res://scripts/data"]

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var found: Dictionary = {}
	for d in SCAN_DIRS:
		_scan_dir(d, found)
	if OS.get_environment("T0_FAKE_TYPE") != "":
		found["__fake_unhooked_type__"] = "（注入測試）"
		print("[T0Gate] ★已注入假 type（驗守衛有牙）")
	var hooked: Dictionary = {}
	for k in WorldEvents.MESSAGE_KINDS:
		hooked[String(k)] = true
	var missing: Array = []
	for t in found.keys():
		if not hooked.has(String(t)):
			missing.append("%s  ← %s" % [t, found[t]])
	missing.sort()
	print("[T0Gate] emit_message type 掃到 %d 種、掛點表 %d 種" % [found.size(), hooked.size()])
	if missing.is_empty():
		print("[T0Gate] PASS（全部 type 都已掛 T0 事件匯流排）")
	else:
		print("[T0Gate] ★FAIL：%d 個 type 未掛 T0（新增突發事件必掛，否則相關隊不會被喚醒）：" % missing.size())
		for m in missing:
			print("   - %s" % m)

func _scan_dir(path: String, found: Dictionary) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return
	dir.list_dir_begin()
	var name: String = dir.get_next()
	while name != "":
		if dir.current_is_dir():
			name = dir.get_next()
			continue
		if name.ends_with(".gd"):
			_scan_file(path + "/" + name, found)
		name = dir.get_next()
	dir.list_dir_end()

func _scan_file(path: String, found: Dictionary) -> void:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return
	var line_no: int = 0
	while not f.eof_reached():
		var line: String = f.get_line()
		line_no += 1
		var idx: int = line.find("emit_message(")
		if idx == -1:
			continue
		var rest: String = line.substr(idx)
		# 取 emit_message(state, "<type>" 的第一個字串字面
		var q1: int = rest.find("\"")
		if q1 == -1:
			continue
		var q2: int = rest.find("\"", q1 + 1)
		if q2 == -1:
			continue
		var t: String = rest.substr(q1 + 1, q2 - q1 - 1)
		if t == "" or t.contains("%"):
			continue   # 動態組字串（如 "order_" + kind）→ 交由下方展開規則
		if t.ends_with("_"):
			# 動態前綴（order_ + buy/sell）→ 兩個都要求掛點
			found[t + "buy"] = "%s:%d（動態前綴）" % [path.get_file(), line_no]
			found[t + "sell"] = "%s:%d（動態前綴）" % [path.get_file(), line_no]
			continue
		found[t] = "%s:%d" % [path.get_file(), line_no]
	f.close()
