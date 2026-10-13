extends SceneTree
# @bed-kind: acceptance
# slice: 大地圖整寬（spec 2026-10-13-map-pane-full-width-HOW）
# 大地圖整張看得到（spec 2026-10-13-map-pane-full-width-HOW，藍圖裁 43817c7d1 固定上下排）—— 驗【合成後的最終畫面】
#   M1  預設世界：地圖的每一列（renderer 輸出）在畫面上一字不缺；列數＝2R＋1（R 從 world 讀）
#   M2  `@` 在畫面內；游標移到地圖最右下角也在畫面內
#   M3  分頁區：改前輸出（舊右欄寬截斷）是改後輸出的逐列前綴
#   M5  無任何地圖列被靜默截（同 M1 的逐列比對，另數「被截的列」＝0）
#   M7  最寬列超過框內寬（R＝10 的地圖寬度）⇒ 標題含「（版面異常）」
#   （M8 在 play.py --selfcheck）
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/map_pane_bed.gd

const SEED: int = 1337

var _errors: int = 0


func _check(label: String, ok: bool) -> void:
	if ok:
		print("  PASS: " + label)
	else:
		_errors += 1
		push_error("[FAIL] " + label)


func _initialize() -> void:
	print("=== map_pane：地圖整寬、分頁在下、不靜默截 ===")
	await _m1_m2_m3_m5()
	_m7_abnormal()
	print("=== map_pane DONE === errors: %d" % _errors)
	quit(1 if _errors > 0 else 0)


func _build() -> Node:
	seed(SEED)
	var node: Node = load("res://scenes/TextUI.tscn").instantiate()
	get_root().add_child(node)
	await process_frame
	await process_frame
	node._refresh()
	return node


func _m1_m2_m3_m5() -> void:
	print("\n── M1／M2／M3／M5 預設世界的最終畫面 ──")
	var node: Node = await _build()
	var st: WorldState = node._bridge.get_state()
	var ext: Dictionary = TextMapRenderer.map_extent(st)
	var r: int = int(ext["radius"])
	var map_lines: Array = String(node._map_label.text).split("\n")
	var screen: String = String(node._screen_label.text)
	var missing: Array = []
	for l in map_lines:
		if not screen.contains("│" + String(l)):
			missing.append(String(l).strip_edges().substr(0, 20))
	print("   R=%d｜地圖 %d 列（應 %d）｜最寬 %d 欄／框內 %d｜畫面總列數 %d｜被截或缺的列 %d" % [r, map_lines.size(), 2 * r + 1,
		TextUiView.map_max_width(node._map_label.text), TextUiView.map_inner_width(), screen.split("\n").size(), missing.size()])
	_check("M1 地圖列數＝2R＋1（R 從 world 讀）", map_lines.size() == 2 * r + 1)
	_check("M1／M5 每一列在畫面上一字不缺（沒有任何列被靜默截）", missing.is_empty())
	_check("M5 預設世界最寬列放得進框（不觸發版面異常）", not screen.contains(TextUiView.MAP_ABNORMAL))
	_check("M2 `@` 在畫面內", screen.contains("@"))
	# 游標移到地圖最右下角（菱形範圍內 q 最大、r 最大的那一格）
	var center: Vector2i = ext["center"]
	node._cursor = center + Vector2i(0, r)
	node._refresh()
	var s2: String = String(node._screen_label.text)
	var last_row: String = String(String(node._map_label.text).split("\n")[2 * r])
	print("   游標移到 %s ⇒ 最後一列在畫面內=%s｜含游標框=%s" % [str(node._cursor), str(s2.contains("│" + last_row)), str(last_row.contains("["))])
	_check("M2 游標移到最下角也在畫面內", last_row.contains("[") and s2.contains("│" + last_row))
	# M3 分頁區：舊右欄寬（(COLS−3) − (COLS−3)/2）截出來的每一列，是新畫面那一列的前綴
	var old_rw: int = (TextUiLayout.COLS - 3) - int(float(TextUiLayout.COLS - 3) / 2.0)
	var pages: Array = String(node.build_regions("待執行 0 道").get("pages", "")).split("\n")
	var bad: int = 0
	for p in pages:
		var old: String = TextUiLayout.clip_to(String(p), old_rw)
		if not s2.contains("│" + old):
			bad += 1
	print("   分頁 %d 列｜舊截斷不是新畫面前綴的列 %d" % [pages.size(), bad])
	_check("★母體地板：分頁區有內容", pages.size() > 1)
	_check("M3 分頁區改前輸出是改後輸出的逐列前綴", bad == 0)
	node.queue_free()
	await process_frame


func _m7_abnormal() -> void:
	print("\n── M7 最寬列超過框內寬（R＝10 的寬度）⇒ 標題含「（版面異常）」──")
	var r: int = 10
	var row: String = "  ".repeat(2 * r) + "x   ".repeat(2 * r + 1)
	var box: String = TextUiView.map_pages_box(row, "p", "大寫=看得到", "[1]生存 ")
	var title: String = String(box.split("\n")[0])
	print("   最寬 %d 欄｜標題「%s」" % [TextUiLayout.display_width(row), title.substr(0, 40)])
	_check("M7 超寬 ⇒ 標題含「（版面異常）」、該列不截", title.contains(TextUiView.MAP_ABNORMAL) and box.contains("│" + row))
