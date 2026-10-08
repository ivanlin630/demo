# scripts/ui/text_map_renderer.gd
class_name TextMapRenderer

# ★#9（spec 2026-09-29 map-memory-and-godview-leak §8）：「看得到」的半徑每隊、隨時間變 ——
#   單一權威是 VisionSystem.vision_range(state, team, 日夜倍率)（純讀）；這裡【不】再存一份平常數
const TERRAIN_CHAR: Dictionary = { "plains": "P", "forest": "F", "mountain": "M" }

# ★#9 §7 字元語言（用戶 2026-10-07 點頭）：一格只印一個主字，由上往下搶
#   ① @ 你｜② a–z 看得到的隊伍｜③ ^ 村 # 營 $ 市集（已知據點）｜④ a? 記得的隊（belief 位置）｜⑤ P F M 看得到的地形／p f m 記得的地形／? 沒去過
# ★隊伍字母不得撞「記得的地形」：p f m 已被地形佔用 ⇒ 字母表＝a–z 去掉 f m p（23 個）；第 24 支起印 *
const TEAM_LETTERS: String = "abcdeghijklnoqrstuvwxyz"
const GLYPH_BY_TYPE: Dictionary = {"civilian": "^", "military": "#"}
const MARKET_GLYPH: String = "$"
# ★圖例與字元表同一處維護（P8：新增一種而不加圖例 ⇒ 床紅）
#   ★它印在地圖框的上框（text_ui_view.map_pages_box），左半框只裝得下 ~48 欄 ⇒ 字要短（終端自驗 (e-1) 擋超寬）
const LEGEND: String = "@你 a隊 ^村 #營 $市集 a?記得 P看見 p記得 ?未知"

# ★F10（spec 2026-10-07 round5-friendliness §F10，用戶裁 藍圖 4d70c8aad②）：視窗＝整張地圖
#   ⇒ 視窗中心＝地圖中心、半徑＝地圖半徑，兩者都從 state.world.tiles 的座標範圍算（儲存座標中心在 (N,N) 不是 (0,0)；
#     world_generator 的 radius 是 config、生成後沒存進 state ⇒ 不寫死）
#   ⇒ @ 畫在玩家實際位置（舊 U16「@ 永遠在正中、地圖在底下捲」那條由這一條取代）
# axial 投影:列 dr 的水平位移 = dq + dr/2 → 用累進切變（每列右移半格 = 2 字元）。
#   寬度：r=8 ⇒ 每列 17 格 × 4 字＝68，加最末列切變縮排 2 × 2r＝32 ⇒ 最寬 100 欄
static func map_extent(state: WorldState) -> Dictionary:
	var qmin: int = 1 << 30
	var qmax: int = -(1 << 30)
	var rmin: int = 1 << 30
	var rmax: int = -(1 << 30)
	for k in state.world.tiles.keys():
		var q: int = int(k) / 1000
		var r: int = int(k) % 1000
		qmin = mini(qmin, q); qmax = maxi(qmax, q)
		rmin = mini(rmin, r); rmax = maxi(rmax, r)
	if qmin > qmax:
		return {"center": Vector2i.ZERO, "radius": 0}
	var c := Vector2i((qmin + qmax) / 2, (rmin + rmax) / 2)
	var rad: int = 0
	for k2 in state.world.tiles.keys():
		rad = maxi(rad, _hex_dist(c, Vector2i(int(k2) / 1000, int(k2) % 1000)))
	return {"center": c, "radius": rad}


# ★#9 §7③：代號表【一份、一個產生點】—— 地圖、右欄清單、游標處三處同讀
#   母體＝這一幀畫得出來的隊（看得到的＋belief 未過期的），按 team_id 排 ⇒ 依序配字母；超過 23 支 ⇒ *
#   ★不用右欄順序當代號：右欄只列可互動目標，記得的隊不在裡面，翻頁也會讓字母換人
static func team_codes(state: WorldState, player_tid: int, vision_mult: float = 1.0) -> Dictionary:
	var pt: TeamData = state.teams.get(player_tid)
	if pt == null:
		return {}
	var vr: int = VisionSystem.vision_range(state, pt, vision_mult)
	var ids: Array = []
	for tid in state.teams:
		if int(tid) == player_tid or not state.is_live_team(int(tid)):
			continue
		var t: TeamData = state.teams[tid]
		if _hex_dist(pt.tile_pos, t.tile_pos) <= vr:
			ids.append(int(tid))   # ★看得到（此刻真的在視野內 ⇒ 真位置合法）
		elif BeliefSystem.belief_pos(state, player_tid, int(tid)) != Vector2i(-1, -1):
			ids.append(int(tid))   # ★記得（belief 未過期；過期與否由 sim 的 BELIEF_STALE_TICKS 決定）
	ids.sort()
	var out: Dictionary = {}
	for i in range(ids.size()):
		out[ids[i]] = TEAM_LETTERS[i] if i < TEAM_LETTERS.length() else "*"
	return out


# ★#9 §7（R² b9c3a5381）：overlay 一幀算一次 —— 只讀 belief／視野內真位置／代號表，★不接 HexTileData
#   ⇒ 據點只經這裡進來（不讀 live tile 的據點欄），市集只讀 team_market_known
#   產出 {tile_key: {"team": 碼, "site": 圖示, "remembered": 碼}}
static func _belief_overlay(state: WorldState, player_tid: int, vr: int, codes: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	var pt: TeamData = state.teams.get(player_tid)
	if pt == null:
		return out
	for rec in BeliefSystem.known_outposts(state, player_tid):
		var p: Vector2i = rec["tile_pos"]
		_ov(out, p)["site"] = String(GLYPH_BY_TYPE.get(String(rec.get("type", "")), ""))
	for mk in state.team_market_known.get(player_tid, {}):
		var e: Dictionary = out.get(int(mk), {})
		e["site"] = MARKET_GLYPH   # ★市集壓村
		out[int(mk)] = e
	for tid in codes:
		var t: TeamData = state.teams.get(tid)
		if t == null:
			continue
		if _hex_dist(pt.tile_pos, t.tile_pos) <= vr:
			var e2: Dictionary = _ov(out, t.tile_pos)
			if not e2.has("team"):
				e2["team"] = String(codes[tid])
		else:
			var bp: Vector2i = BeliefSystem.belief_pos(state, player_tid, int(tid))
			if bp != Vector2i(-1, -1):
				var e3: Dictionary = _ov(out, bp)
				if not e3.has("remembered"):
					e3["remembered"] = String(codes[tid])
	return out


static func _ov(out: Dictionary, p: Vector2i) -> Dictionary:
	var k: int = p.x * 1000 + p.y
	if not out.has(k):
		out[k] = {}
	return out[k]


# vision_mult：日夜倍率（sim_bridge.get_vision_mult() 傳進來；renderer 不伸進 runner）
static func render(state: WorldState, player_tid: int, cursor: Vector2i, vision_mult: float = 1.0) -> String:
	var player_team: TeamData = state.teams.get(player_tid)
	var player_pos: Vector2i  = player_team.tile_pos if player_team else Vector2i(-99, -99)
	var vr: int = VisionSystem.vision_range(state, player_team, vision_mult) if player_team else 0
	var codes: Dictionary = team_codes(state, player_tid, vision_mult)
	var overlay: Dictionary = _belief_overlay(state, player_tid, vr, codes)
	# ★#9 §3(B)：記得的格讀 team_tile_known[玩家]（地點知識；地不會走 ⇒ 不過期）
	var remembered: Dictionary = state.team_tile_known.get(player_tid, {})

	# 以地圖中心為中心的整張視窗:dr/dq ∈ [-R, R]，hex 距離內才畫。
	# 每列累進切變 indent = (dr + R) * 2（dr 由上到下遞增 → 右移）。
	var ext: Dictionary = map_extent(state)
	var center: Vector2i = ext["center"]
	var view_r: int = int(ext["radius"])
	var lines: Array = []
	for dr in range(-view_r, view_r + 1):
		var indent: String = "  ".repeat(dr + view_r)
		var line: String = indent
		for dq in range(-view_r, view_r + 1):
			if _hex_dist(Vector2i(dq, dr), Vector2i.ZERO) > view_r:
				line += "    "   # 視窗外（菱形外緣）留白,維持對齊
				continue
			var pos: Vector2i = center + Vector2i(dq, dr)
			var key: int = pos.x * 1000 + pos.y
			var tile = state.world.tiles.get(key)
			var terrain: String = String(tile.terrain) if tile != null else ""   # ★地形讀 live 合法：地不會走
			line += _cell(terrain, pos == player_pos, pos == cursor,
				_hex_dist(player_pos, pos) <= vr, remembered.has(key), overlay.get(key, {}))
		lines.append(line)
	return "\n".join(lines)


# ★#9 §7：_cell 不收 HexTileData（結構上就拿不到 live 的據點欄）
#   一格 4 字元：一字主字 ⇒ "x   "／游標 "[x] "；兩字（a?）⇒ "a?  "／游標 "[a?]"
static func _cell(terrain: String, is_player: bool, is_cursor: bool, in_vision: bool, remembered: bool,
		ov: Dictionary) -> String:
	if terrain == "" and not is_player:
		return "[ ] " if is_cursor else "    "
	var ch: String
	if is_player:
		ch = "@"
	elif ov.has("team"):
		ch = String(ov["team"])
	elif String(ov.get("site", "")) != "":
		ch = String(ov["site"])
	elif ov.has("remembered"):
		ch = String(ov["remembered"]) + "?"
	elif in_vision:
		ch = TERRAIN_CHAR.get(terrain, "P")
	elif remembered:
		ch = String(TERRAIN_CHAR.get(terrain, "P")).to_lower()
	else:
		ch = "?"
	if ch.length() >= 2:
		return "[%s]" % ch if is_cursor else "%s  " % ch
	return "[%s] " % ch if is_cursor else "%s   " % ch


static func _hex_dist(a: Vector2i, b: Vector2i) -> int:
	var dx := b.x - a.x; var dy := b.y - a.y
	return (abs(dx) + abs(dx + dy) + abs(dy)) / 2
