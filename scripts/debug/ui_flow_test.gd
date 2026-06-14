extends SceneTree

var _errors: int = 0

func _initialize() -> void:
	await _test_harness_smoke()
	# 後續測試在此依序 await
	print("\n=== UI Flow Test DONE === errors: %d" % _errors)
	quit()

func _check(label: String, ok: bool) -> void:
	print(("  PASS: " if ok else "  FAIL: ") + label)
	if not ok: _errors += 1

# 實例化 TextUI 場景 + 等 _ready。回傳 node。
func _make_ui() -> Node:
	var node = load("res://scenes/TextUI.tscn").instantiate()
	get_root().add_child(node)
	await process_frame
	await process_frame
	return node

func _free_ui(node: Node) -> void:
	node.queue_free()
	await process_frame

func _test_harness_smoke() -> void:
	print("\n── harness smoke ──")
	var node = await _make_ui()
	_check("node 實例化", node != null)
	_check("_state_label 存在", node.get("_state_label") != null)
	_check("_bridge 存在", node.get("_bridge") != null)
	_check("_handle_interact_mode 可呼叫", node.has_method("_handle_interact_mode"))
	await _free_ui(node)
