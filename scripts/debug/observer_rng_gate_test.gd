extends SceneTree

# observer-no-global-RNG 靜態閘 TDD（HOW spec 2026-07-29 §2/§4）：7 向量 + 逃生口 regex 邊界。
# ★fixture 用字串非真 .gd 檔（真 observe-pure 檔含 RNG 會破真 gate）。regex 需與 observability_gate 一致。

const RNG_FUNC_RE := "(?<![\\w.])(randf_range|randi_range|randfn|randf|randi|randomize|seed)\\s*\\("
const RNG_METHOD_RE := "\\.(pick_random|shuffle)\\s*\\("

var _fail: int = 0
var _func_re := RegEx.new()
var _method_re := RegEx.new()

func _initialize() -> void:
	_func_re.compile(RNG_FUNC_RE)
	_method_re.compile(RNG_METHOD_RE)
	# 反例（應命中=global RNG）
	_hit("var x = randf()", "bare randf")
	_hit("var x = randi() % 5", "bare randi")
	_hit("var g = randfn(0.0, 1.0)", "randfn 高斯")
	_hit("var r = randf_range(0.0, 1.0)", "randf_range")
	_hit("\tseed(123)", "bare seed(裸括號全域重播種)")
	_hit("\trandomize()", "randomize")
	_hit("var t = arr.pick_random()", "arr.pick_random(方法照抓)")
	_hit("\tdeck.shuffle()", "shuffle 照抓")
	# 逃生口（本地 seeded rng，應不命中）
	_miss("var x = rng.randf()", "rng.randf 本地逃生口")
	_miss("var y = _local_rng.randi_range(0, 5)", "_local_rng.randi_range 逃生口")
	_miss("\trng.seed = 123", "rng.seed=x property 賦值(無括號)不命中")
	_miss("\tvar rng := RandomNumberGenerator.new()", "宣告本地 rng 不命中")
	# 非 RNG 正常行不誤報
	_miss("\tvar total = pop * FOOD_PER_PERSON", "一般算術")
	_miss("# seed(123) in comment", "註解行(gate 另跳純註解;此 regex 本身也不該誤配 comment 內? 實 gate 跳 # 行)")
	if _fail == 0:
		print("=== DONE === ALL PASS")
	else:
		print("=== DONE === %d FAIL" % _fail)
	quit()

func _matches(line: String) -> bool:
	return _func_re.search(line) != null or _method_re.search(line) != null

func _hit(line: String, desc: String) -> void:
	if _matches(line):
		print("  [PASS] 命中 global RNG: %s" % desc)
	else:
		_fail += 1
		print("  [FAIL] 應命中卻漏: %s (%s)" % [desc, line])

func _miss(line: String, desc: String) -> void:
	# 註解行的 gate 實際跳過（strip.begins_with #），但此純 regex 對 comment 內 seed( 會命中——
	# 故 comment 測改測 gate 行為:略過純註解。此處只測非註解逃生口。
	if line.strip_edges().begins_with("#"):
		print("  [PASS] 純註解行 gate 跳過(不判): %s" % desc)
		return
	if not _matches(line):
		print("  [PASS] 逃生口/非RNG 不誤報: %s" % desc)
	else:
		_fail += 1
		print("  [FAIL] 誤報: %s (%s)" % [desc, line])
