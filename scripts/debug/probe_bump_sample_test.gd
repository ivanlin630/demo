extends SceneTree

# Probe.bump_sample TDD（spec 2026-07-21-probe-bump-sample）。§④b 聚合帶 bounded 樣本工具。
# 硬約束：off no-op(byte-identical)/first-N cap 無 RNG/只寫 Probe.samples/reset 清。

var _fail: int = 0

func _initialize() -> void:
	_test_off_noop()
	_test_append_to_cap()
	_test_no_append_past_cap()
	_test_reset_clears()
	if _fail == 0:
		print("=== DONE === ALL PASS")
	else:
		print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  [PASS] %s" % msg)
	else:
		_fail += 1
		print("  [FAIL] %s" % msg)

# ① enabled=false → bump_sample no-op（samples 空=off byte-identical）
func _test_off_noop() -> void:
	print("--- ① off → no-op ---")
	Probe.reset(); Probe.enabled = false
	Probe.bump_sample("e", {"x": 1})
	_ok(Probe.samples.is_empty(), "off → samples 空（no-op，sim 不擾）")

# ② enabled=true → append 到 cap
func _test_append_to_cap() -> void:
	print("--- ② append 到 cap ---")
	Probe.reset(); Probe.enabled = true
	for i in range(3):
		Probe.bump_sample("e", {"x": i}, 5)
	_ok(Probe.samples.get("e", []).size() == 3, "append 3 個（<cap 5，got %d）" % Probe.samples.get("e", []).size())
	_ok(Probe.samples["e"][0]["x"] == 0 and Probe.samples["e"][2]["x"] == 2, "instance 內容正確(first-N 順序)")

# ③ cap 後不再 append（first-N 非替換）
func _test_no_append_past_cap() -> void:
	print("--- ③ cap 後不 append ---")
	Probe.reset(); Probe.enabled = true
	for i in range(10):
		Probe.bump_sample("e", {"x": i}, 4)
	_ok(Probe.samples.get("e", []).size() == 4, "停在 cap 4（first-N 非 reservoir，got %d）" % Probe.samples.get("e", []).size())
	_ok(Probe.samples["e"][3]["x"] == 3, "保前 4 個(first-N=前來先得，非後替換)")

# ④ reset 清 samples
func _test_reset_clears() -> void:
	print("--- ④ reset 清 samples ---")
	Probe.enabled = true
	Probe.bump_sample("e", {"x": 1})
	Probe.reset()
	_ok(Probe.samples.is_empty(), "reset → samples 清空")
	Probe.enabled = false   # 復原 default（防污染別測）
