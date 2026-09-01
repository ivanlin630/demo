extends SceneTree
# @observe-pure
# ★★★床 arm 順序閘（bed-arm-helper §3）——防【增量】：新床不得再自己拼 arm 順序。
#
# ★母體 ＝ `WorldState.new()` 的呼叫檔（★不是 `GameSetup.setup()`）。
#   ★★理由：建世界【必須】new 一個 WorldState，而 setup 只是其中一條路；
#     實測 274 檔 new WorldState、只有 138 檔走 setup ⇒ 用 setup 當母體會漏掉 136 檔。
#   ★★★這是引擎決定的窄口；`GameSetup.setup()` 是【我們習慣走的那條路】，不是唯一的路。
#
# ★判準（三分）：
#   ①用 MeasureBedHelper.arm_and_setup(...)            ⇒ OK
#   ②不用，但在既有白名單裡                             ⇒ 白名單（★不 FAIL，但【數字必印】）
#   ③不用、也不在白名單                                 ⇒ ★FAIL（新床，擋在這裡）
#
# ★★白名單的數字為什麼一定要印：★★★它【就是盲區規模】。
#   不印的話，「入白名單」等於把既有盲區洗成合法 —— 而那正是我們今天在治的病。

const ROOT: String = "res://scripts/debug"
const WHITELIST_PATH: String = "res://docs/process/bed-arm-whitelist.txt"
const HELPER_CALL: String = "MeasureBedHelper.arm_and_setup"
const SELF_EXEMPT: Array = [
	"scripts/debug/measure_bed_helper.gd",   # helper 自己
	"scripts/debug/bed_arm_gate.gd",         # 本閘自己
]

func _initialize() -> void:
	_run(); quit()

func _gather(dir_path: String, out: Array) -> void:
	var d := DirAccess.open(dir_path)
	if d == null:
		return
	d.list_dir_begin()
	var n := d.get_next()
	while n != "":
		if d.current_is_dir():
			if not n.begins_with("."):
				_gather(dir_path.path_join(n), out)
		elif n.ends_with(".gd"):
			out.append(dir_path.path_join(n))
		n = d.get_next()
	d.list_dir_end()

func _load_whitelist() -> Dictionary:
	var wl: Dictionary = {}
	var f := FileAccess.open(WHITELIST_PATH, FileAccess.READ)
	if f == null:
		return wl
	while not f.eof_reached():
		var line: String = f.get_line().strip_edges()
		if line == "" or line.begins_with("#"):
			continue
		wl[line] = true
	f.close()
	return wl

# 檔案是否【真的】建了世界（★排除純註解行：註解自成一欄，不進母體）。
# ★★★母體必須同時收「自己 new」與「透過 helper new」兩種 ——
#   ★否則遷移過的床會【掉出母體】：白名單少一張、helper 數卻永遠是 0，
#   ★★而那看起來像進步，實際上是【從清單上消失】—— 正是我們在治的那個病。
#   （這個缺口是本輪跑陽性對照時當場撞到的：控制床改用 helper 後，母體從 274 掉回 273。）
func _builds_world(path: String) -> bool:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return false
	var hit: bool = false
	while not f.eof_reached():
		var line: String = f.get_line()
		if line.strip_edges().begins_with("#"):
			continue
		if line.find("WorldState.new()") >= 0 or line.find(HELPER_CALL) >= 0:
			hit = true
			break
	f.close()
	return hit

func _uses_helper(path: String) -> bool:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return false
	var hit: bool = false
	while not f.eof_reached():
		var line: String = f.get_line()
		if line.strip_edges().begins_with("#"):
			continue
		if line.find(HELPER_CALL) >= 0:
			hit = true
			break
	f.close()
	return hit

func _run() -> void:
	var files: Array = []
	_gather(ROOT, files)
	files.sort()
	var wl: Dictionary = _load_whitelist()

	var pop: Array = []
	var ok: Array = []
	var listed: Array = []
	var bad: Array = []
	for fp in files:
		var rel: String = String(fp).replace("res://", "")
		if rel in SELF_EXEMPT:
			continue
		if not _builds_world(String(fp)):
			continue
		pop.append(rel)
		if _uses_helper(String(fp)):
			ok.append(rel)
		elif wl.has(rel):
			listed.append(rel)
		else:
			bad.append(rel)

	print("=== 床 arm 順序閘（母體＝WorldState.new() 的呼叫檔）===")
	print("母體 %d｜用 helper %d｜白名單 %d｜★未涵蓋 %d" % [pop.size(), ok.size(), listed.size(), bad.size()])
	# ★★★白名單數字必印 —— 它就是盲區規模，而它應該單向下降。
	print("[BED-ARM-GATE] ★白名單 %d 張 ⇒ 這就是【還沒治好的盲區規模】（★不是通過，是還沒做）"
		% listed.size())
	if listed.size() > 0 and OS.has_environment("BED_ARM_LIST"):
		for r in listed:
			print("   - ", r)
		print("   （設 BED_ARM_LIST=1 才列出全部；預設只印數字，避免每次跑洗版）")

	if bad.is_empty():
		print("[BED-ARM-GATE] PASS：沒有【新的】自己拼 arm 順序的床")
		return
	print("[BED-ARM-GATE] ★FAIL：%d 張床建了世界，既不用 helper 也不在白名單" % bad.size())
	for r in bad:
		print("   ★ ", r)
	print("★處置：改用 MeasureBedHelper.arm_and_setup()（順序寫死，沒得選錯）")
	print("★★若真的不能用（例如手工組世界不走 GameSetup），才加進白名單 ——")
	print("   ★★★而加進白名單會讓上面那個數字變大，那是【刻意可見】的代價。")
	quit(1)
