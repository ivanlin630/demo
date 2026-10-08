extends SceneTree
# @bed-kind: invariant
# slice: 友善度 F10（spec 2026-10-07-round5-friendliness-convergence §F10，用戶裁 藍圖 4d70c8aad②）——終端地圖視窗＝整張
#
# ★這支床原本守的是 U16「@ 永遠在視窗正中、地圖在底下捲」（VIEW_RADIUS＝5、以玩家為中心）
#   ⇒ F10 把它翻過來（用戶裁）：視窗中心＝地圖中心、半徑＝地圖半徑；@ 畫在玩家實際位置
#   ⇒ 舊斷言（@ 在正中列、換位同欄）整段退場，換成下面三格；留這段字讓 grep U16 的人知道它去哪了
#
# ★期望值不讀 renderer：地圖中心與半徑由本床自己從 state.world.tiles 的鍵（x*1000+y）算
#   （儲存座標中心在 (N,N) 不是 (0,0)；world_generator 的 radius 是 config、生成後沒存進 state）
# P10a 列數＝2r+1、每列實格數 ≤ 2r+1、最寬列格數＝2r+1｜任一列顯示寬 ≤ 120
# P10b 玩家走到地圖邊緣 ⇒ @ 在那個位置（不在正中列）、整張輪廓（每列格數）不動
# P10c 反向（負對照）：renderer 改回以玩家為中心、半徑 5 ⇒ P10a 必紅（detached 樹實測，見交件信）
#
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/map_render_test.gd

var _errors: int = 0


func _check(msg: String, cond: bool) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_errors += 1
		push_error("[FAIL] " + msg)


func _world(radius: int) -> WorldState:
	var state := WorldState.new()
	var gen = load("res://scripts/simulation/world_generator.gd").new()
	gen.generate(state, {"radius": radius, "seed": 42})
	var team := TeamData.new()
	team.team_id = 0
	AnonTierSystem.add_anon(team, "平民", 9)
	team.tags = ["統領"]
	team.resources = {"food": 500.0, "coin": 50}
	state.teams[0] = team
	state.team_known[0] = []
	state.team_discovered[0] = []
	var leader := PersonData.new()
	leader.id = 0; leader.person_name = "玩家"; leader.role = "leader"
	leader.team_id = 0; leader.loyalty = 1.0
	state.persons[0] = leader
	team.leader_id = 0
	state.player_id = 0
	return state


# 本床自己的地圖中心與半徑（不讀 renderer）
static func _extent(state: WorldState) -> Dictionary:
	var qs: Array = []
	var rs: Array = []
	for k in state.world.tiles.keys():
		qs.append(int(k) / 1000)
		rs.append(int(k) % 1000)
	var c := Vector2i((qs.min() + qs.max()) / 2, (rs.min() + rs.max()) / 2)
	var r: int = 0
	for k2 in state.world.tiles.keys():
		var p := Vector2i(int(k2) / 1000, int(k2) % 1000)
		var dx: int = p.x - c.x
		var dy: int = p.y - c.y
		r = maxi(r, (absi(dx) + absi(dx + dy) + absi(dy)) / 2)
	return {"center": c, "radius": r}


static func _cells(line: String) -> int:
	var n: int = 0
	var re := RegEx.create_from_string("\\S+")
	for _m in re.search_all(line):
		n += 1
	return n


func _initialize() -> void:
	print("=== F10 終端地圖視窗＝整張 ===")
	for radius in [4, 8]:
		var st: WorldState = _world(int(radius))
		var ex: Dictionary = _extent(st)
		var c: Vector2i = ex["center"]
		var r: int = int(ex["radius"])
		print("\n── 地圖 radius=%d：本床算的中心 %s、半徑 %d ──" % [radius, str(c), r])
		st.teams[0].tile_pos = c
		var m1: String = TextMapRenderer.render(st, 0, Vector2i(-99, -99))
		var rows1: Array = m1.split("\n")
		var widths: Array = []
		for l1 in rows1:
			widths.append(_cells(String(l1)))
		var max_w: int = 0
		var max_cols: int = 0
		for i in range(rows1.size()):
			max_w = maxi(max_w, int(widths[i]))
			max_cols = maxi(max_cols, TextUiLayout.display_width(String(rows1[i])))
		print("   列數 %d｜每列格數 %s｜最寬顯示 %d 欄" % [rows1.size(), str(widths), max_cols])
		_check("P10a 列數＝2r+1（%d）" % (2 * r + 1), rows1.size() == 2 * r + 1)
		_check("P10a 每列實格數 ≤ 2r+1、最寬列＝2r+1（%d）" % (2 * r + 1), max_w == 2 * r + 1)
		_check("P10a 任一列顯示寬 ≤ 120（%d）" % max_cols, max_cols <= 120)
		# P10b：玩家走到地圖邊緣（中心往 +r 走 r 格 ⇒ 最底列；沿 q 走列不變、會留在正中列）
		var edge: Vector2i = c + Vector2i(0, r)
		_check("★P10b 母體地板：邊緣那格真的在地圖上", st.world.tiles.has(edge.x * 1000 + edge.y))
		st.teams[0].tile_pos = edge
		var m2: String = TextMapRenderer.render(st, 0, Vector2i(-99, -99))
		var rows2: Array = m2.split("\n")
		var at_row: int = -1
		for j in range(rows2.size()):
			if String(rows2[j]).contains("@"):
				at_row = j
		var widths2: Array = []
		for l2 in rows2:
			widths2.append(_cells(String(l2)))
		print("   玩家在 %s ⇒ @ 在第 %d 列（正中列 %d）｜每列格數 %s" % [str(edge), at_row, r, str(widths2)])
		_check("P10b @ 畫在玩家實際位置那一列（%d），不在正中" % (edge.y - c.y + r),
			at_row == edge.y - c.y + r)
		_check("P10b 整張輪廓不動（每列格數與玩家在中心時相同）", widths2 == widths)
		_check("P10b @ 只有一個", m2.count("@") == 1)
	print("\n=== map_render_test DONE === errors: %d" % _errors)
	quit(1 if _errors > 0 else 0)
