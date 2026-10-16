extends SceneTree
# @bed-kind: acceptance
# slice: 結構輪兩個探針：建點一支身體（L1 要材料、就地採）＋子隊到場一支身體（spec 2026-10-16-structure-round-probes-build-and-subteam-arrival-HOW）
# 建點（V）：
#   V1  五個入口同一份佈置（森林格、池固定、帶 20 料）⇒ construction_target 的 action/type/level/gather_left、ticks_left、扣料逐數相同；owner 照入口
#   V2  scripts/simulation 內 "action": "build" 寫入 1 處；舊紮根開工函式 0 處；"crude_camp" 0 處
#   V3  採段每 tick：ticks_left 不動；tile 材料減少 == gather_left 減少 == site_stock 增加；採完才開始築
#   V4  帶夠料 ⇒ 開工當下 gather_left 0、第一個推進 tick 就築
#   V5  池 0 且停回生 ⇒ 不刷新 last_progress ⇒ 停工逾時取消、退 site_stock 的 50%
#   V5b 真平原格、需 50、帶 0 ⇒ build_eta_total_days == INF；實跑 ⇒ 期限內取消（gather_abort +1）、退 site_stock 50%
#   V6  森林格：估算採段天數 vs 實跑天數差 ≤ 1 日
#   V6b 採走一半後停採 24 小時 ⇒ 池回到 cap；回補量＝回生呼叫次數 × REGEN_RATE
#   V7  營地格完工 ⇒ 營地四欄清、food cap ≥40、outpost_built 訊息、owner 對、主隊 release；非營地格營地欄不碰；NPC 子隊 _auto_settle_builder
#   V8b 同一平原目標：母隊庫存 0 ⇒ site_barren；庫存 ≥ need ⇒ 過閘、子隊開工 gather_left 0
#   V9  玩家紮根回句含「需材」「可採約」、不含「免材料」；工地資料 phase 兩段、UI 印「採料」「建造」
#   G9  玩家紮根、建設之後施工中 task_priority == PRIO_PLAYER
#   V10 玩家子隊帶 0 料派往森林格 ⇒ precheck ok、回句含「需材」「可採約」
#   V11 選址 gather_term：料 0 森林與山地都 <0 且山地絕對值大；料 ≥ need 都 0；野心 0.8 比 0.2 絕對值大；決勝格
#   V11b 母隊料 0、範圍內只有平原 ⇒ 選址回空、site.filtered_barren>0；料 ≥ need ⇒ 回得出來
#   P1  同隊同 food_runway：gather_left 0（已採完）vs gather_left need ⇒ 後者 safe_factor 與 _progress 較小
# 子隊到場（S）：
#   S1  NPC 子隊與玩家子隊 SETTLE ①母隊據點 done ②同勢力別隊 done ③外勢力 refused 同 reason ④獨立對獨立 refused（新舊並排）⑤母隊已亡同勢力 done
#   S2  CAMP 空地 done、已有營地 refused；玩家側 refused 發 camp_refused 事件
#   S3  子隊段（_evaluate_subteam／_tick_player_subteam）不再直呼 _convert_to_resident、establish_crude_camp
#   S4  S1③ 的 NPC 子隊下一 tick 進 merge_queue
#   S5  NPC SETTLE 子隊途中（move_target≠-1）站在外勢力格與自家據點格 N tick ⇒ 仍 SETTLE、不 merge、不轉居民
# 新點缺料進同一本需求帳（N，§三之三）：
#   N1 在路上（主隊走回營地／子隊建造在途）⇒ 新點那一支＝整筆成本、料單 for=new_outpost｜N2 沒承諾 0｜N2b 三種非①的 TASK_BUILD 0
#   N3 採段 ⇒ gather_left（子隊 tile_pos／母隊 corvee_site，①②互斥）｜N3b 雙算殘差印數｜N4／N4b 施工隊（含接手工人）帶的料抵進工地
#   N5 (a) reserve＝need_keep×只看糧急 (b) ②去交易不賣料｜N6 買料效用｜N6b 迫切隨進度降｜N6c 新點先占上限｜N8 承諾不被換掉
#   N7＝既有床 material_hold_test 照綠（不在本床）
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/build_verb_one_body_bed.gd
#   BED_ONLY=_v1,_s1 只跑點名的格（負對照用）

const SEED: int = 20261016
const P: int = 0      # 玩家隊
const N: int = 1      # NPC 主隊（同勢力 1）
const F: int = 2      # 同勢力別隊
const X: int = 3      # 外勢力（勢力 2）
const I1: int = 4     # 獨立隊
const I2: int = 5     # 另一獨立隊
const SITE: Vector2i = Vector2i(8, 8)

var _errors: int = 0
var _present: Dictionary = {}
var _only: Array = []

func _check(label: String, ok: bool) -> void:
	if ok:
		print("  PASS: " + label)
	else:
		_errors += 1
		push_error("[FAIL] " + label)

func _cell(c: String) -> void:
	_present[c] = true

func _want(c: String) -> bool:
	return _only.is_empty() or _only.has(c)

func _initialize() -> void:
	var env: String = OS.get_environment("BED_ONLY")
	if env != "":
		_only = Array(env.split(","))
	print("=== build_verb_one_body：建點一支身體＋子隊到場一支身體 ===")
	var cells: Array = ["_v1", "_v2", "_v3", "_v4", "_v5", "_v5b", "_v6", "_v6b", "_v7", "_v8b", "_v9", "_g9", "_v10", "_v11", "_v11b", "_p1",
		"_s1", "_s2", "_s3", "_s4", "_s5",
		"_n1", "_n2", "_n2b", "_n3", "_n3b", "_n4", "_n4b", "_n5", "_n6", "_n6b", "_n6c", "_n8"]
	for c in cells:
		if _want(c):
			call(c)
	var want_n: int = cells.size() if _only.is_empty() else _only.size()
	print("=== build_verb_one_body DONE === 到場 %d／%d errors: %d" % [_present.size(), want_n, _errors])
	quit(1 if _errors > 0 else 0)

# ── 佈置 ─────────────────────────────────────────────────────────────────────
static func _team(id: int, pos: Vector2i, pop: int, fid: int, leader: bool, vals: Dictionary = {}, mat: float = 0.0) -> Dictionary:
	return {"id": id, "name": "T%d" % id, "tile_pos": [pos.x, pos.y], "population": pop, "tags": [],
		"faction_id": fid, "is_faction_leader": leader, "anon_tiers": {"平民": pop - 1},
		"resources": {"food": 20000.0, "coin": 100.0, "material": mat},
		"leader": {"name": "L%d" % id, "skills": {"統領": 0.6}, "values": vals}}

# 玩家 P、NPC 主隊 N、同勢力 F、外勢力 X、獨立 I1／I2。★所有隊的隊長人格中性（紮根型別＝民用）
func _mk(player: bool = true, n_pos: Vector2i = SITE, p_pos: Vector2i = Vector2i(4, 4)) -> WorldState:
	seed(SEED)
	var cfg: Dictionary = {"seed": SEED, "mode": "explicit", "max_ticks": 100000, "map": {"radius": 12, "resource_richness": 5},
		"teams": [
			_team(P, p_pos, 10, 1, false),
			_team(N, n_pos, 20, 1, true),
			_team(F, Vector2i(10, 4), 8, 1, false),
			_team(X, Vector2i(2, 10), 8, 2, true),
			_team(I1, Vector2i(12, 2), 8, -1, false),
			_team(I2, Vector2i(2, 2), 8, -1, false),
		]}
	if player:
		cfg["player"] = {"team_id": P}
	var st: WorldState = MeasureBedHelper.arm_and_setup(cfg, false)
	_add_named(st, st.teams[P], 3)
	_add_named(st, st.teams[N], 3)
	return st

var _next_pid: int = 97001
func _add_named(st: WorldState, t: TeamData, n: int) -> void:
	for i in range(n):
		var m := PersonData.new()
		m.id = _next_pid
		_next_pid += 1
		m.team_id = t.team_id
		m.skills["統領"] = 0.5
		st.persons[m.id] = m
		t.named_members.append(m.id)

func _tile(st: WorldState, pos: Vector2i) -> HexTileData:
	return st.world.tiles.get(pos.x * 1000 + pos.y)

# 把一格設成指定地形與材料池（空地、沒有據點／營地／工地）
func _site(st: WorldState, pos: Vector2i, terrain: String, cap: float, prod: float, camp_team: int = -1) -> HexTileData:
	var t: HexTileData = _tile(st, pos)
	t.terrain = terrain
	t.resource_cap["material"] = cap
	t.resources["material"] = cap
	t.productivity = prod
	t.outpost_level = 0
	t.outpost_type = ""
	t.construction_team_id = -1
	t.construction_target = {}
	if camp_team != -1:
		t.camp_level = 1
		t.camp_team_id = camp_team
		t.camp_ticks_left = 99 * WorldState.TICKS_PER_DAY
		OwnerCampIndex.invalidate()
	return t

func _put(st: WorldState, t: TeamData, pos: Vector2i) -> void:
	t.tile_pos = pos
	t.move_target = Vector2i(-1, -1)

func _mat(t: TeamData) -> float:
	return float(t.resources.get("material", 0))

func _gl(tile: HexTileData) -> float:
	return float((tile.construction_target.get("gather_left", {}) as Dictionary).get("material", -1.0))

func _ss(tile: HexTileData) -> float:
	return float((tile.construction_target.get("site_stock", {}) as Dictionary).get("material", -1.0))

func _spare(st: WorldState, t: TeamData) -> int:
	for pid in t.named_members:
		if pid == t.leader_id or not st.persons.has(pid):
			continue
		var busy: bool = false
		for tid in st.teams:
			if (st.teams[tid] as TeamData).leader_id == pid:
				busy = true
		if not busy:
			return pid
	return -1

func _npc_sub(st: WorldState, mother: TeamData, task: String, pop: int = 6) -> TeamData:
	var sid: int = SubteamSystem.new().dispatch(st, mother.team_id, _spare(st, mother), pop, task, Vector2i(-1, -1))
	return st.teams.get(sid)

func _player_dispatch(st: WorldState, task: String, pos: Vector2i, n: int, bt: String = "civilian") -> Dictionary:
	var pt: TeamData = st.teams[P]
	st.player_state["sub_leader_id"] = _spare(st, pt)
	st.player_state["sub_pop_count"] = n
	st.player_state["sub_task"] = task
	st.player_state["sub_move_q"] = pos.x
	st.player_state["sub_move_r"] = pos.y
	st.player_state["sub_build_type"] = bt
	return PlayerCommandSystem.new().execute_action(st, -1, "dispatch_subteam")

func _row(name: String, st: WorldState, tile: HexTileData, builder: TeamData, mat0: float) -> Dictionary:
	var ct: Dictionary = tile.construction_target
	var r: Dictionary = {"entry": name, "action": String(ct.get("action", "")), "type": String(ct.get("type", "")),
		"level": int(ct.get("level", 0)), "gather_left": _gl(tile), "ticks_left": tile.construction_ticks_left,
		"paid": mat0 - (_mat(builder) if builder != null else 0.0), "owner": int(ct.get("owner", -1)),
		"builder": builder.team_id if builder != null else -1}
	print("    V1|%s|action=%s type=%s level=%d gather_left=%.1f ticks_left=%d 扣料=%.1f owner=%d 施工隊=%d" % [
		name, r["action"], r["type"], r["level"], r["gather_left"], r["ticks_left"], r["paid"], r["owner"], r["builder"]])
	return r

# ── V1 五入口同數 ────────────────────────────────────────────────────────────
func _v1() -> void:
	print("\n── V1 五入口同數（森林、池 150、帶 20 料）──")
	var rows: Array = []
	# ① NPC 紮根
	var st: WorldState = _mk(false)
	var n: TeamData = st.teams[N]
	var tile := _site(st, SITE, "forest", 150.0, 0.9, N)
	ResourceBank.set_amt(n, "material", 20.0, "bed_seed")
	FactionAISystem.shared()._commit_settle_site(st, n, {"settle_site": SITE})
	rows.append(_row("NPC紮根", st, tile, n, 20.0))
	var own1: bool = int(tile.construction_target.get("owner", -1)) == N
	# ② 玩家紮根
	st = _mk(true, Vector2i(2, 6), SITE)
	var pt: TeamData = st.teams[P]
	tile = _site(st, SITE, "forest", 150.0, 0.9, P)
	ResourceBank.set_amt(pt, "material", 20.0, "bed_seed")
	st.player_state["build_type"] = "civilian"
	var r2: Dictionary = PlayerCommandSystem.new()._action_settle(st, -1, pt, P)
	print("    玩家紮根回句：%s" % String(r2.get("msg", "")))
	rows.append(_row("玩家紮根", st, tile, pt, 20.0))
	var own2: bool = int(tile.construction_target.get("owner", -1)) == P
	# ③ 玩家建設
	st = _mk(true, Vector2i(2, 6), SITE)
	pt = st.teams[P]
	tile = _site(st, SITE, "forest", 150.0, 0.9)
	ResourceBank.set_amt(pt, "material", 20.0, "bed_seed")
	st.player_state["build_type"] = "civilian"
	var r3: Dictionary = PlayerCommandSystem.new()._action_build_outpost(st, -1, pt, P)
	print("    玩家建設回句：%s" % String(r3.get("msg", "")))
	rows.append(_row("玩家建設", st, tile, pt, 20.0))
	var own3: bool = not tile.construction_target.has("owner") and tile.construction_team_id == P
	# ④ NPC 子隊抵達
	st = _mk(false, Vector2i(2, 6))
	n = st.teams[N]
	tile = _site(st, SITE, "forest", 150.0, 0.9)
	var sub: TeamData = _npc_sub(st, n, TeamData.TASK_CONSTRUCT)
	ResourceBank.set_amt(sub, "material", 20.0, "bed_seed")
	sub.task_extra_data = {"build_type": "civilian", "level": 1}
	_put(st, sub, SITE)
	OutpostSystem.new().begin_subteam_construction(st, sub)
	rows.append(_row("NPC子隊抵達", st, tile, sub, 20.0))
	var own4: bool = not tile.construction_target.has("owner") and tile.construction_team_id == sub.team_id
	# ⑤ 玩家子隊腳下派遣
	st = _mk(true, Vector2i(2, 6), SITE)
	pt = st.teams[P]
	tile = _site(st, SITE, "forest", 150.0, 0.9)
	ResourceBank.set_amt(pt, "material", 200.0, "bed_seed")   # 子隊按人數比例分到料；派遣後再把子隊的料設成 20 不行（腳下派遣當場開工）⇒ 比例 3/10 ⇒ 200×0.3＝60，見下
	# ★腳下派遣當場開工 ⇒ 子隊帶的料＝母隊按人數比例那一份；要它剛好 20 ⇒ 母隊 20 / (3/10)
	ResourceBank.set_amt(pt, "material", 20.0 * 10.0 / 3.0, "bed_seed")
	var r5: Dictionary = _player_dispatch(st, TeamData.TASK_CONSTRUCT, SITE, 3)
	var sub5: TeamData = st.teams.get(int(r5.get("sub_id", -1)))
	print("    玩家子隊派遣回句：%s" % String(r5.get("msg", "")))
	rows.append(_row("玩家子隊腳下", st, tile, sub5, 20.0))
	var own5: bool = int(tile.construction_target.get("owner", -1)) == P
	_cell("_v1")
	var same: bool = rows.size() == 5
	for r in rows:
		same = same and String(r["action"]) == "build" and String(r["type"]) == "civilian" and int(r["level"]) == 1 \
			and is_equal_approx(float(r["gather_left"]), 30.0) and int(r["ticks_left"]) == int(rows[0]["ticks_left"]) \
			and is_equal_approx(float(r["paid"]), 20.0)
	_check("V1 五入口 action/type/level/gather_left(30)/ticks_left/扣料(20) 逐數相同", same)
	_check("V1 owner：紮根／建設＝施工隊、玩家子隊＝母隊、NPC 子隊＝缺省（%s %s %s %s %s）" % [own1, own2, own3, own4, own5],
		own1 and own2 and own3 and own4 and own5)

# ── V2 寫入點 ────────────────────────────────────────────────────────────────
func _v2() -> void:
	print("\n── V2 寫入點只有一處 ──")
	var n_build: int = 0
	var n_old: int = 0
	var n_cc: int = 0
	for f in _gd_files("res://scripts/simulation"):
		var txt: String = FileAccess.get_file_as_string(f)
		n_build += txt.count("\"action\": \"build\"")
		n_old += txt.count("start_settle_" + "construction")
		n_cc += txt.count("\"crude_" + "camp\"")
	print("    \"action\": \"build\"=%d｜舊紮根開工函式=%d｜\"crude_camp\"=%d" % [n_build, n_old, n_cc])
	_cell("_v2")
	_check("V2 寫入 1 處、舊函式 0、crude_camp 0", n_build == 1 and n_old == 0 and n_cc == 0)

func _gd_files(dir: String) -> Array:
	var out: Array = []
	var d := DirAccess.open(dir)
	if d == null:
		return out
	for f in d.get_files():
		if f.ends_with(".gd"):
			out.append(dir + "/" + f)
	for sd in d.get_directories():
		out += _gd_files(dir + "/" + sd)
	return out

# 主隊在森林格開工（玩家建設那一支）⇒ 回 [st, tile, team]
func _forest_site(carried: float, pool: float = 150.0, terrain: String = "forest", prod: float = 0.9) -> Array:
	var st: WorldState = _mk(true, Vector2i(2, 6), SITE)
	var pt: TeamData = st.teams[P]
	var tile := _site(st, SITE, terrain, pool, prod)
	ResourceBank.set_amt(pt, "material", carried, "bed_seed")
	st.player_state["build_type"] = "civilian"
	PlayerCommandSystem.new()._action_build_outpost(st, -1, pt, P)
	return [st, tile, pt]

# ── V3 採段守恆 ──────────────────────────────────────────────────────────────
func _v3() -> void:
	print("\n── V3 採段守恆、採段不築 ──")
	var w: Array = _forest_site(0.0)
	var st: WorldState = w[0]; var tile: HexTileData = w[1]
	var os := OutpostSystem.new()
	var bad: int = 0
	var ticks0: int = tile.construction_ticks_left
	var n_g: int = 0
	var first_build_dec: bool = false
	for i in range(2000):
		var g0: float = _gl(tile); var s0: float = _ss(tile); var m0: float = float(tile.resources.get("material", 0)); var k0: int = tile.construction_ticks_left
		os._tick_construction(st, tile)
		if g0 > 0.0:
			n_g += 1
			var dm: float = m0 - float(tile.resources.get("material", 0))
			var dg: float = g0 - _gl(tile)
			var ds: float = _ss(tile) - s0
			if tile.construction_ticks_left != k0 or absf(dm - dg) > 1e-6 or absf(dg - ds) > 1e-6:
				bad += 1
		else:
			first_build_dec = tile.construction_ticks_left < k0
			break
	print("    採段 %d tick｜違反 %d｜ticks_left %d→%d｜採完後第一 tick 減=%s｜site_stock=%.2f" % [n_g, bad, ticks0, tile.construction_ticks_left, str(first_build_dec), _ss(tile)])
	_cell("_v3")
	_check("V3 採段每 tick ticks_left 不動、三量相等（%d tick 違反 %d）" % [n_g, bad], n_g > 0 and bad == 0)
	_check("V3 採完之後 ticks_left 開始減", first_build_dec)

# ── V4 帶夠就跳過採段 ────────────────────────────────────────────────────────
func _v4() -> void:
	print("\n── V4 帶夠料 ──")
	var w: Array = _forest_site(60.0)
	var st: WorldState = w[0]; var tile: HexTileData = w[1]; var pt: TeamData = w[2]
	var gl0: float = _gl(tile)
	var k0: int = tile.construction_ticks_left
	OutpostSystem.new()._tick_construction(st, tile)
	print("    gather_left=%.1f｜ticks_left %d→%d｜剩料 %.1f" % [gl0, k0, tile.construction_ticks_left, _mat(pt)])
	_cell("_v4")
	_check("V4 帶 60 ≥ 50 ⇒ gather_left 0、第一 tick 就築、只扣 50", gl0 == 0.0 and tile.construction_ticks_left < k0 and is_equal_approx(_mat(pt), 10.0))

# ── V5 池被採光 ──────────────────────────────────────────────────────────────
func _v5() -> void:
	print("\n── V5 池 0、停回生 ⇒ 停工逾時 ──")
	var w: Array = _forest_site(20.0, 0.0)
	var st: WorldState = w[0]; var tile: HexTileData = w[1]; var pt: TeamData = w[2]
	var os := OutpostSystem.new()
	var lp0: int = tile.construction_last_progress_tick
	for i in range(30):
		st.world.current_tick += 1
		os._tick_construction(st, tile)
	var lp1: int = tile.construction_last_progress_tick
	var tmo: float = OutpostSystem.construction_timeout_days(tile)
	var ab0: int = int(Probe.counts.get("construct.gather_abort", 0))
	st.world.current_tick = lp1 + int(round(tmo * float(WorldState.TICKS_PER_DAY))) + 1
	var m_before: float = _mat(pt)
	var stock: float = _ss(tile)
	var cancelled: bool = os.check_construction_timeout(st, tile)
	var refund: float = _mat(pt) - m_before
	print("    last_progress %d→%d（30 tick 後）｜逾時 %.2f 天｜取消=%s｜site_stock=%.1f 退 %.1f｜gather_abort +%d" % [
		lp0, lp1, tmo, str(cancelled), stock, refund, int(Probe.counts.get("construct.gather_abort", 0)) - ab0])
	_cell("_v5")
	_check("V5 池 0 ⇒ last_progress 不刷新", lp1 == lp0)
	_check("V5 停工逾時取消、退 site_stock 的 50%%（%.1f／%.1f）" % [refund, stock], cancelled and is_equal_approx(refund, stock * 0.5) and stock > 0.0
		and tmo < OutpostSystem.gather_window_days())

# ── V5b 平原蓋不成 ───────────────────────────────────────────────────────────
func _v5b() -> void:
	print("\n── V5b 真平原格、帶 0 ──")
	var st: WorldState = _mk(true, Vector2i(2, 6), SITE)
	var pt: TeamData = st.teams[P]
	var tile: HexTileData = null
	for tid in st.world.tiles:
		var t: HexTileData = st.world.tiles[tid]
		if t.terrain == "plains" and t.outpost_level == 0 and t.camp_level == 0 and t.construction_team_id == -1 and _tile(st, t.tile_pos) != null:
			tile = t
			break
	_check("★V5b 地板：找得到生成的平原格", tile != null)
	if tile == null:
		return
	_put(st, pt, tile.tile_pos)
	ResourceBank.set_amt(pt, "material", 0.0, "bed_seed")
	var est: float = OutpostSystem.build_eta_total_days(st, pt, "civilian", 1, pt.population, 0.0, OutpostSystem.site_of_tile(tile))
	print("    平原 cap=%.1f productivity=%.3f ⇒ build_eta_total_days=%s" % [float(tile.resource_cap.get("material", 0)), tile.productivity, str(est)])
	st.player_state["build_type"] = "civilian"
	PlayerCommandSystem.new()._action_build_outpost(st, -1, pt, P)
	var t0: int = st.world.current_tick
	var ab0: int = int(Probe.counts.get("construct.gather_abort", 0))
	var runner := SimRunner.new()
	var m0: float = _mat(pt)
	var stock_last: float = 0.0
	var done_tick: int = -1
	var limit: int = int((OutpostSystem.gather_window_days() + 2.0) * WorldState.TICKS_PER_DAY)
	for i in range(limit):
		if tile.construction_team_id != -1:
			stock_last = _ss(tile)
		runner.advance_tick(st, pt.tile_pos)
		if st.encounter_active:
			runner._encounter_system.resolve_encounter_end(st, "draw")
		st.player_forced_event = {}
		if tile.construction_team_id == -1:
			done_tick = st.world.current_tick
			break
	var days: float = float(done_tick - t0) / float(WorldState.TICKS_PER_DAY) if done_tick != -1 else -1.0
	var refund: float = _mat(pt) - m0
	print("    取消於第 %.2f 天｜gather_abort +%d｜取消前 site_stock=%.2f 退 %.2f" % [days, int(Probe.counts.get("construct.gather_abort", 0)) - ab0, stock_last, refund])
	_cell("_v5b")
	_check("V5b 估算 INF", est == INF)
	_check("V5b 實跑在期限內被取消（gather_abort +1）、退 site_stock 50%%", done_tick != -1 and days <= OutpostSystem.gather_window_days() + 1.0
		and int(Probe.counts.get("construct.gather_abort", 0)) - ab0 == 1 and absf(refund - stock_last * 0.5) < 0.05)

# ── V6 估算器同源 ────────────────────────────────────────────────────────────
func _v6() -> void:
	print("\n── V6 估算 vs 實跑（森林、帶 20）──")
	var st: WorldState = _mk(true, Vector2i(2, 6), SITE)
	var pt: TeamData = st.teams[P]
	var tile := _site(st, SITE, "forest", 150.0, 0.9)
	ResourceBank.set_amt(pt, "material", 20.0, "bed_seed")
	var est_total: float = OutpostSystem.build_eta_total_days(st, pt, "civilian", 1, pt.population, 20.0, OutpostSystem.site_of_tile(tile))
	var est_g: float = OutpostSystem.gather_eta_days(st, pt, 50.0, 20.0, OutpostSystem.site_of_tile(tile))
	st.player_state["build_type"] = "civilian"
	PlayerCommandSystem.new()._action_build_outpost(st, -1, pt, P)
	var t0: int = st.world.current_tick
	var runner := SimRunner.new()
	var t_done: int = -1
	for i in range(int(20.0 * WorldState.TICKS_PER_DAY)):
		runner.advance_tick(st, pt.tile_pos)
		if st.encounter_active:
			runner._encounter_system.resolve_encounter_end(st, "draw")
		st.player_forced_event = {}
		if tile.construction_team_id == -1 or _gl(tile) <= 0.0:
			t_done = st.world.current_tick
			break
	var real_g: float = float(t_done - t0) / float(WorldState.TICKS_PER_DAY) if t_done != -1 else INF
	print("    V6|估算採段 %.3f 天（總 %.3f）｜實跑採段 %.3f 天" % [est_g, est_total, real_g])
	_cell("_v6")
	_check("V6 採段估算與實跑差 ≤ 1 日（%.3f vs %.3f）" % [est_g, real_g], est_g > 0.0 and absf(est_g - real_g) <= 1.0)

# ── V6b 池貼上限 ─────────────────────────────────────────────────────────────
func _v6b() -> void:
	print("\n── V6b 停採 24 小時池回 cap ──")
	var st: WorldState = _mk(false)
	var tile := _site(st, Vector2i(3, 9), "forest", 150.0, 0.9)
	tile.resources["material"] = 75.0
	var rs := ResourceSystem.new()
	var calls: int = 0
	var first: float = 0.0
	for h in range(24):
		var b: float = float(tile.resources.get("material", 0))
		rs.regenerate_tiles(st, WorldState.TICKS_PER_HOUR)
		calls += 1
		if h == 0:
			first = float(tile.resources.get("material", 0)) - b
	var rate: float = float(ResourceSystem.REGEN_RATE["forest"]["material"])
	print("    第一次回補 %.2f（REGEN_RATE %.2f）｜%d 次後池 %.2f／cap %.2f" % [first, rate, calls, float(tile.resources.get("material", 0)), 150.0])
	_cell("_v6b")
	_check("V6b 每次回補＝REGEN_RATE（不乘 day_fraction）、24 小時後回到 cap", is_equal_approx(first, rate) and is_equal_approx(float(tile.resources.get("material", 0)), 150.0))

# ── V7 完工一支 ──────────────────────────────────────────────────────────────
func _v7() -> void:
	print("\n── V7 完工一支 ──")
	# 營地格：NPC 主隊紮根完工
	var st: WorldState = _mk(false)
	var n: TeamData = st.teams[N]
	var tile := _site(st, SITE, "forest", 150.0, 0.9, N)
	tile.resource_cap["food"] = 5.0
	ResourceBank.set_amt(n, "material", 60.0, "bed_seed")
	FactionAISystem.shared()._commit_settle_site(st, n, {"settle_site": SITE})
	var msg0: int = st.global_messages.size()
	tile.construction_ticks_left = 1
	OutpostSystem.new()._tick_construction(st, tile)
	var msg_ok: bool = false
	for i in range(msg0, st.global_messages.size()):
		if String((st.global_messages[i] as MessageData).type) == "outpost_built":
			msg_ok = true
	var camp_clear: bool = tile.camp_level == 0 and tile.camp_team_id == -1 and tile.camp_ticks_left == 0
	print("    營地格：L%d owner=%d 營地欄清=%s food_cap=%.1f 訊息=%s 主隊 task=%s corvee=%s" % [tile.outpost_level, tile.outpost_owner, str(camp_clear),
		float(tile.resource_cap.get("food", 0)), str(msg_ok), n.current_task, str(n.corvee_site)])
	_cell("_v7")
	_check("V7 營地格完工：營地四欄清、food cap ≥40、outpost_built、owner＝施工隊、主隊 release、corvee 清", tile.outpost_level == 1 and camp_clear
		and float(tile.resource_cap.get("food", 0)) >= 40.0 and msg_ok and tile.outpost_owner == N and n.current_task != TeamData.TASK_BUILD
		and n.corvee_site == Vector2i(-1, -1))
	# 非營地格：營地欄不被碰
	st = _mk(true, Vector2i(2, 6), SITE)
	var pt: TeamData = st.teams[P]
	tile = _site(st, SITE, "forest", 150.0, 0.9)
	tile.camp_ticks_left = 77
	ResourceBank.set_amt(pt, "material", 60.0, "bed_seed")
	st.player_state["build_type"] = "civilian"
	PlayerCommandSystem.new()._action_build_outpost(st, -1, pt, P)
	tile.construction_ticks_left = 1
	OutpostSystem.new()._tick_construction(st, tile)
	print("    非營地格：L%d camp_ticks_left=%d" % [tile.outpost_level, tile.camp_ticks_left])
	_check("V7 非營地格完工：營地欄不被碰（camp_ticks_left 仍 77）", tile.outpost_level == 1 and tile.camp_ticks_left == 77)
	# NPC 子隊：_auto_settle_builder
	st = _mk(false, Vector2i(2, 6))
	n = st.teams[N]
	tile = _site(st, SITE, "forest", 150.0, 0.9)
	var sub: TeamData = _npc_sub(st, n, TeamData.TASK_CONSTRUCT)
	ResourceBank.set_amt(sub, "material", 60.0, "bed_seed")
	sub.task_extra_data = {"build_type": "civilian", "level": 1}
	_put(st, sub, SITE)
	OutpostSystem.new().begin_subteam_construction(st, sub)
	var sb0: int = int(Probe.counts.get("outpost.settle_builder", 0))
	tile.construction_ticks_left = 1
	OutpostSystem.new()._tick_construction(st, tile)
	print("    NPC 子隊：settle_builder +%d tags=%s parent=%d" % [int(Probe.counts.get("outpost.settle_builder", 0)) - sb0, str(sub.tags), sub.parent_team_id])
	_check("V7 NPC 子隊完工 ⇒ _auto_settle_builder（PRODUCE tag、脫母團）", sub.tags.has(TeamData.TAG_PRODUCE) and sub.parent_team_id == -1)

# ── V8b 撥料與估算同源 ───────────────────────────────────────────────────────
func _v8b() -> void:
	print("\n── V8b 撥料與估算同源（平原目標）──")
	var res: Array = []
	for mat in [0.0, 200.0]:
		var st: WorldState = _mk(false, Vector2i(6, 6))
		var n: TeamData = st.teams[N]
		var tgt := Vector2i(8, 6)
		var tile := _site(st, tgt, "plains", 12.0, 1.1)
		ResourceBank.set_amt(n, "material", mat, "bed_seed")
		var sb0: int = int(Probe.counts.get("funnel.build_gate.site_barren", 0))
		var ok: bool = FactionAISystem.shared()._dispatch_builder(st, n, tgt, "civilian", 1)
		var sb: int = int(Probe.counts.get("funnel.build_gate.site_barren", 0)) - sb0
		var gl: float = -1.0
		if ok:
			for cid in n.subteam_ids:
				var c: TeamData = st.teams.get(cid)
				if c != null and c.current_task == TeamData.TASK_CONSTRUCT:
					_put(st, c, tgt)
					OutpostSystem.new().begin_subteam_construction(st, c)
					gl = _gl(tile)
		print("    母隊料 %.0f ⇒ 派出=%s site_barren +%d｜到場開工 gather_left=%.1f" % [mat, str(ok), sb, gl])
		res.append([ok, sb, gl])
	_cell("_v8b")
	_check("V8b 母隊料 0 ⇒ site_barren", not bool(res[0][0]) and int(res[0][1]) == 1)
	_check("V8b 母隊料 ≥ need ⇒ 過閘、子隊開工 gather_left 0", bool(res[1][0]) and int(res[1][1]) == 0 and float(res[1][2]) == 0.0)

# ── V9 玩家面 ────────────────────────────────────────────────────────────────
func _v9() -> void:
	print("\n── V9 玩家面 ──")
	var st: WorldState = _mk(true, Vector2i(2, 6), SITE)
	var pt: TeamData = st.teams[P]
	var tile := _site(st, SITE, "forest", 150.0, 0.9, P)
	ResourceBank.set_amt(pt, "material", 10.0, "bed_seed")
	st.player_state["build_type"] = "civilian"
	var r: Dictionary = PlayerCommandSystem.new()._action_settle(st, -1, pt, P)
	var msg: String = String(r.get("msg", ""))
	var op: Dictionary = PlayerApiMapper.map_outpost_panel(st) if PlayerApiMapper.has_method("map_outpost_panel") else {}
	var line_g: String = TextUiMain.construction_progress_line(op)
	var os := OutpostSystem.new()
	for i in range(3000):
		if _gl(tile) <= 0.0: break
		os._tick_construction(st, tile)
	os._tick_construction(st, tile)
	var op2: Dictionary = PlayerApiMapper.map_outpost_panel(st) if PlayerApiMapper.has_method("map_outpost_panel") else {}
	var line_b: String = TextUiMain.construction_progress_line(op2)
	print("    回句：%s" % msg)
	print("    phase=%s「%s」→ phase=%s「%s」" % [String(op.get("phase", "?")), line_g, String(op2.get("phase", "?")), line_b])
	_cell("_v9")
	_check("V9 紮根回句含「需材」「可採約」、不含「免材料」", bool(r.get("ok", false)) and msg.contains("需材") and msg.contains("可採約") and not msg.contains("免材料"))
	_check("V9 工地 phase 兩段：gather「採料」→ build「建造」", String(op.get("phase", "")) == "gather" and line_g.contains("採料")
		and String(op2.get("phase", "")) == "build" and line_b.contains("建造"))

# ── G9 玩家優先序 ────────────────────────────────────────────────────────────
func _g9() -> void:
	print("\n── G9 玩家優先序 ──")
	var out: Array = []
	for which in ["settle", "build"]:
		var st: WorldState = _mk(true, Vector2i(2, 6), SITE)
		var pt: TeamData = st.teams[P]
		_site(st, SITE, "forest", 150.0, 0.9, P if which == "settle" else -1)
		ResourceBank.set_amt(pt, "material", 20.0, "bed_seed")
		st.player_state["build_type"] = "civilian"
		if which == "settle":
			PlayerCommandSystem.new()._action_settle(st, -1, pt, P)
		else:
			PlayerCommandSystem.new()._action_build_outpost(st, -1, pt, P)
		var p0: int = pt.task_priority
		var runner := SimRunner.new()
		for i in range(WorldState.TICKS_PER_HOUR * 3):
			runner.advance_tick(st, pt.tile_pos)
			if st.encounter_active:
				runner._encounter_system.resolve_encounter_end(st, "draw")
			st.player_forced_event = {}
		print("    %s：當下 prio=%d、3 小時後 task=%s prio=%d" % [which, p0, pt.current_task, pt.task_priority])
		out.append(p0 == TaskArbiter.PRIO_PLAYER and pt.current_task == TeamData.TASK_BUILD and pt.task_priority == TaskArbiter.PRIO_PLAYER)
	_cell("_g9")
	_check("G9 玩家紮根、建設施工中 task_priority == PRIO_PLAYER", out[0] and out[1])

# ── V10 玩家子隊建設不擋料 ───────────────────────────────────────────────────
func _v10() -> void:
	print("\n── V10 玩家子隊帶 0 料派往森林 ──")
	var st: WorldState = _mk(true, Vector2i(2, 6), Vector2i(7, 8))
	var pt: TeamData = st.teams[P]
	_site(st, SITE, "forest", 150.0, 0.9)
	ResourceBank.set_amt(pt, "material", 0.0, "bed_seed")
	var pre: Dictionary = PlayerCommandSystem.precheck_subteam_build(st, pt, SITE, 3, null)
	print("    precheck=%s" % str(pre))
	_cell("_v10")
	_check("V10 precheck ok、回句含「需材」「可採約」", bool(pre.get("ok", false)) and String(pre.get("note", "")).contains("需材") and String(pre.get("note", "")).contains("可採約"))

# ── V11 選址秤讀採料天數 ─────────────────────────────────────────────────────
func _v11() -> void:
	print("\n── V11 選址 gather_term ──")
	var st: WorldState = _mk(false, Vector2i(6, 6))
	var n: TeamData = st.teams[N]
	var fa := FactionAISystem.shared()
	var ft := _site(st, Vector2i(8, 6), "forest", 150.0, 0.5)
	var mt := _site(st, Vector2i(6, 8), "mountain", 65.0, 0.9)
	var cost: Dictionary = OutpostSystem.OUTPOST_COST["civilian"][0]
	var rows: Dictionary = {}
	for mat in [0.0, 200.0]:
		ResourceBank.set_amt(n, "material", mat, "bed_seed")
		var gf: float = FactionAISystem.site_gather_term(fa.site_gather_days(st, n, ft, cost), 0.5)
		var gm: float = FactionAISystem.site_gather_term(fa.site_gather_days(st, n, mt, cost), 0.5)
		var sf: float = float(fa._site_candidate_score(st, ft, 2, 1.0, [], 1.0, gf)["score"])
		var sm: float = float(fa._site_candidate_score(st, mt, 2, 1.0, [], 1.0, gm)["score"])
		rows[mat] = [gf, gm, sf, sm]
		print("    V11|母隊料 %.0f｜森林 gather_term=%.2f score=%.1f｜山地 gather_term=%.2f score=%.1f ⇒ 選%s" % [mat, gf, sf, gm, sm, "森林" if sf > sm else "山地"])
	ResourceBank.set_amt(n, "material", 0.0, "bed_seed")
	var g_lo: float = FactionAISystem.site_gather_term(fa.site_gather_days(st, n, ft, cost), 0.2)
	var g_hi: float = FactionAISystem.site_gather_term(fa.site_gather_days(st, n, ft, cost), 0.8)
	print("    野心 0.2 ⇒ %.2f｜0.8 ⇒ %.2f" % [g_lo, g_hi])
	_cell("_v11")
	var r0: Array = rows[0.0]; var r1: Array = rows[200.0]
	_check("V11 料 0 ⇒ 兩格 gather_term<0、山地絕對值大", r0[0] < 0.0 and r0[1] < 0.0 and absf(r0[1]) > absf(r0[0]))
	_check("V11 料 ≥ need ⇒ 兩格 gather_term 都 0", r1[0] == 0.0 and r1[1] == 0.0)
	_check("V11 野心 0.8 比 0.2 絕對值大", absf(g_hi) > absf(g_lo))
	_check("V11 決勝格：料 0 選森林、料 ≥ need 選山地", r0[2] > r0[3] and r1[3] > r1[2])

# ── V11b 採不完不進候選 ──────────────────────────────────────────────────────
func _v11b() -> void:
	print("\n── V11b 範圍內只有平原 ──")
	var out: Array = []
	for mat in [0.0, 200.0]:
		var st: WorldState = _mk(false, Vector2i(6, 6))
		var n: TeamData = st.teams[N]
		for tid in st.world.tiles:
			var t: HexTileData = st.world.tiles[tid]
			if t.outpost_level > 0: continue
			t.terrain = "plains"
			t.resource_cap["material"] = 12.0
			t.resources["material"] = 12.0
			t.productivity = 1.2
		ResourceBank.set_amt(n, "material", mat, "bed_seed")
		var fb0: int = int(Probe.counts.get("site.filtered_barren", 0))
		var loc: Dictionary = FactionAISystem.shared()._evaluate_new_outpost_location(st, n)
		var fb: int = int(Probe.counts.get("site.filtered_barren", 0)) - fb0
		print("    母隊料 %.0f ⇒ 選址=%s filtered_barren +%d" % [mat, str(loc.get("pos", "空")), fb])
		out.append([loc.is_empty(), fb])
	_cell("_v11b")
	_check("V11b 料 0 ⇒ 選址回空、filtered_barren>0", bool(out[0][0]) and int(out[0][1]) > 0)
	_check("V11b 料 ≥ need ⇒ 回得出來、不濾", not bool(out[1][0]) and int(out[1][1]) == 0)

# ── P1 持守看得到採段 ────────────────────────────────────────────────────────
func _p1() -> void:
	print("\n── P1 持守看得到採段 ──")
	var vals: Array = []
	for gathered in [true, false]:
		var st: WorldState = _mk(false)
		var n: TeamData = st.teams[N]
		var tile := _site(st, SITE, "forest", 150.0, 0.9)
		var total: int = OutpostSystem.build_person_hours("civilian", 1)
		tile.construction_team_id = N
		tile.construction_ticks_left = total
		tile.construction_target = {"action": "build", "type": "civilian", "level": 1, "need": 50.0, "carried": 0.0,
			"gather_left": {"material": 0.0 if gathered else 50.0}, "site_stock": {"material": 50.0 if gathered else 0.0},
			"start_pop": n.population}
		tile.construction_started_tick = st.world.current_tick
		tile.construction_last_progress_tick = st.world.current_tick
		n.current_task = TeamData.TASK_BUILD
		n.corvee_site = SITE
		n.food_runway = 6.0
		var sf: float = PersistStrength._safe_factor(st, n, 0.5, 0.5)
		var pg: float = PersistStrength._progress(st, n)
		print("    gather_left=%s ⇒ safe_factor=%.3f _progress=%.3f" % ["0" if gathered else "need", sf, pg])
		vals.append([sf, pg])
	_cell("_p1")
	_check("P1 gather_left=need 的 safe_factor 較小", vals[1][0] < vals[0][0])
	_check("P1 gather_left=need 的 _progress 較小", vals[1][1] < vals[0][1])

# ── S1 同佈置兩種子隊同結果 ──────────────────────────────────────────────────
# 在 pos 立一座 owner 的 L1 據點
func _outpost(st: WorldState, pos: Vector2i, owner: int) -> void:
	var t: HexTileData = _tile(st, pos)
	t.outpost_type = "civilian"
	t.outpost_level = 1
	OutpostOwnerBank.set_owner(st, t, owner, "bed_seed")
	OwnerOutpostIndex.invalidate()

func _settle_case(label: String, mother_id: int, owner_id: int, player_side: bool, kill_mother: bool = false) -> Dictionary:
	var st: WorldState = _mk(false)
	var mother: TeamData = st.teams[mother_id]
	_add_named(st, mother, 2)
	if AnonTierSystem.total_pop(mother) < 10:
		AnonTierSystem.add_anon(mother, AnonCohort.TIER_PLEB, 10)
	var pos := Vector2i(5, 8)
	_outpost(st, pos, owner_id)
	var sub: TeamData = _npc_sub(st, mother, TeamData.TASK_SETTLE, 3)
	sub.player_controlled = player_side
	_put(st, sub, pos)
	if kill_mother:
		st.detach_subteam(sub)
		sub.parent_team_id = mother_id   # 母隊已亡：子隊仍記著它（判準要退到子隊自己的勢力）
		st.teams.erase(mother_id)
	var o: TeamData = st.teams.get(owner_id)
	var old_rule: bool = o != null and o.faction_id == sub.faction_id
	var arr: Dictionary = SubteamSystem.on_arrival(st, sub)
	print("    S1|%s|%s｜新=%s「%s」｜舊 NPC 判準=%s" % [label, "玩家子隊" if player_side else "NPC子隊", String(arr["outcome"]), String(arr["reason"]), "會轉" if old_rule else "不轉"])
	return arr

func _s1() -> void:
	print("\n── S1 SETTLE 兩種子隊同結果 ──")
	var ok: bool = true
	var rs: Dictionary = {}
	for side in [false, true]:
		var a: Dictionary = _settle_case("①母隊據點", N, N, side)
		var b: Dictionary = _settle_case("②同勢力別隊", N, F, side)
		var c: Dictionary = _settle_case("③外勢力", N, X, side)
		var e: Dictionary = _settle_case("⑤母隊已亡、同勢力", N, F, side, true)
		ok = ok and String(a["outcome"]) == "done" and String(b["outcome"]) == "done" and String(c["outcome"]) == "refused" and String(e["outcome"]) == "done"
		rs[side] = c
	var d: Dictionary = _settle_case("④獨立對獨立", I1, I2, false)
	_cell("_s1")
	_check("S1 ①②⑤ done、③ refused（NPC 與玩家子隊同結果）", ok)
	_check("S1 ③ 兩邊 reason 相同", String(rs[false]["reason"]) == String(rs[true]["reason"]) and String(rs[false]["reason"]) != "")
	_check("S1 ④ 獨立 NPC 子隊到另一獨立隊據點 ⇒ refused（修前會轉）", String(d["outcome"]) == "refused")

# ── S2 CAMP ──────────────────────────────────────────────────────────────────
func _s2() -> void:
	print("\n── S2 CAMP ──")
	var st: WorldState = _mk(true, Vector2i(2, 6), Vector2i(7, 8))
	var pt: TeamData = st.teams[P]
	var empty := Vector2i(8, 8)
	_site(st, empty, "forest", 150.0, 0.9)
	_tile(st, empty).terrain = "plains"
	var r1: Dictionary = _player_dispatch(st, TeamData.TASK_CAMP, empty, 3)
	var s1: TeamData = st.teams.get(int(r1.get("sub_id", -1)))
	var o1: Dictionary = {}
	if s1 != null:
		_put(st, s1, empty)
		o1 = SubteamSystem.on_arrival(st, s1)
	# 已有營地的格（玩家側：走腦那一支，看事件）
	var busy := Vector2i(6, 8)
	var bt := _site(st, busy, "plains", 12.0, 1.1, I2)
	bt.camp_team_id = I2
	var r2: Dictionary = _player_dispatch(st, TeamData.TASK_CAMP, Vector2i(8, 9), 3)
	var s2: TeamData = st.teams.get(int(r2.get("sub_id", -1)))
	var seq0: int = st.player_event_seq
	var outcome2: String = ""
	if s2 != null:
		_put(st, s2, busy)
		var ref0: int = int(Probe.counts.get("subteam.arrival.camp.refused.player", 0))
		FactionAISystem.shared()._tick_player_subteam(st, s2, [])
		outcome2 = "refused" if int(Probe.counts.get("subteam.arrival.camp.refused.player", 0)) > ref0 else "?"
	var ev: bool = false
	for e in st.player_events:
		if int(e.get("seq", 0)) > seq0 and String(e.get("kind", "")) == "player_subteam":
			ev = true
	print("    空地 ⇒ %s｜已有營地 ⇒ %s，事件=%s" % [String(o1.get("outcome", "?")), outcome2, str(ev)])
	_cell("_s2")
	_check("S2 空地 done、已有營地 refused、玩家側發 camp_refused 事件", String(o1.get("outcome", "")) == "done" and outcome2 == "refused" and ev)

# ── S3 寫入點 ────────────────────────────────────────────────────────────────
func _s3() -> void:
	print("\n── S3 子隊段寫入點 ──")
	var txt: String = FileAccess.get_file_as_string("res://scripts/simulation/faction_ai_system.gd")
	var bad: int = 0
	for fn in ["func _evaluate_subteam(", "func _tick_player_subteam("]:
		var a: int = txt.find(fn)
		var b: int = txt.find("\nfunc ", a + 5)
		var body: String = txt.substr(a, b - a)
		var c: int = body.count("_convert_to_resident(") + body.count("establish_crude_camp(")
		print("    %s … 直呼 %d 次" % [fn, c])
		bad += c if a != -1 else 99
	var sub_txt: String = FileAccess.get_file_as_string("res://scripts/simulation/subteam_system.gd")
	var has_body: bool = sub_txt.contains("static func on_arrival(")
	_cell("_s3")
	_check("S3 子隊段零直呼、身體在 SubteamSystem.on_arrival", bad == 0 and has_body)

# ── S4 住不進去就回 ──────────────────────────────────────────────────────────
func _s4() -> void:
	print("\n── S4 NPC 住不進去 ⇒ 回母隊 ──")
	var st: WorldState = _mk(false)
	var mother: TeamData = st.teams[N]
	var pos := Vector2i(5, 8)
	_outpost(st, pos, X)
	var sub: TeamData = _npc_sub(st, mother, TeamData.TASK_SETTLE, 3)
	_put(st, sub, pos)
	var mq: Array = []
	FactionAISystem.shared()._evaluate_subteam(st, sub, mq)
	print("    merge_queue=%s task=%s" % [str(mq), sub.current_task])
	_cell("_s4")
	_check("S4 外勢力據點 ⇒ release＋進 merge_queue", mq.has(sub.team_id) and sub.current_task != TeamData.TASK_SETTLE)

# ── S5 途中不判 ──────────────────────────────────────────────────────────────
func _s5() -> void:
	print("\n── S5 途中不判 ──")
	var st: WorldState = _mk(false)
	var mother: TeamData = st.teams[N]
	var own := Vector2i(5, 8)
	var foreign := Vector2i(6, 8)
	_outpost(st, own, F)
	_outpost(st, foreign, X)
	var sub: TeamData = _npc_sub(st, mother, TeamData.TASK_SETTLE, 3)
	var conv0: int = int(Probe.counts.get("subteam.arrival.settle.done.npc", 0))
	var mq: Array = []
	var bad: int = 0
	for i in range(20):
		sub.tile_pos = own if i % 2 == 0 else foreign
		sub.move_target = Vector2i(11, 11)
		FactionAISystem.shared()._evaluate_subteam(st, sub, mq)
		if sub.current_task != TeamData.TASK_SETTLE or mq.has(sub.team_id):
			bad += 1
	var conv: int = int(Probe.counts.get("subteam.arrival.settle.done.npc", 0)) - conv0
	print("    20 tick 交替站在自家／外勢力據點、仍在路上 ⇒ 偏離 %d、轉居民 %d" % [bad, conv])
	_cell("_s5")
	_check("S5 途中仍 SETTLE、不 merge、不轉居民", bad == 0 and conv == 0 and st.teams.has(sub.team_id))

# ══ §三之三 新點缺料進同一本需求帳（N）══════════════════════════════════════
const CAMP_C: Vector2i = Vector2i(9, 6)

# 沒據點的主隊 N 走回自己的營地（_commit_settle_site 走回那一支的狀態）、身上料 mat
func _walker(mat: float) -> Array:
	var st: WorldState = _mk(false, Vector2i(6, 6))
	var n: TeamData = st.teams[N]
	var camp := _site(st, CAMP_C, "forest", 150.0, 0.9, N)
	n.current_task = TeamData.TASK_BUILD
	n.move_target = CAMP_C
	n.task_extra_data = {"settle_site": CAMP_C}
	ResourceBank.set_amt(n, "material", mat, "bed_seed")
	return [st, n, camp]

func _lvn(st: WorldState, t: TeamData) -> Dictionary:
	return TradeValuation.leader_vals(st, t)

func _cost(type: String) -> float:
	return float((OutpostSystem.OUTPOST_COST[type][0] as Dictionary).get("material", 0))

func _n1() -> void:
	print("\n── N1 在路上的承諾進需求帳 ──")
	var w: Array = _walker(0.0)
	var st: WorldState = w[0]; var n: TeamData = w[1]
	var walk0: int = int(Probe.counts.get("need.new_outpost.walk", 0))
	var ctype: String = FactionAISystem.settle_camp_type(st, n)
	var nk: float = NeedOracle.need_keep(st, n, "material", _lvn(st, n))
	var nn: float = NeedOracle._new_outpost_need(st, n, "material")
	var fac: float = NeedOracle._construction_facility_need(st, n, "material", _lvn(st, n))
	var rsv: float = TradeValuation.reserve(n, "material", _lvn(st, n), st)
	var sb0: int = int(Probe.counts.get("g1.shortage_buy.new_outpost", 0))
	OrderSystem.new().tick_team_orders(st, n)
	var od: Dictionary = {}
	for o in n.active_orders:
		if String(o["kind"]) == "buy" and String(o["res"]) == "material":
			od = o
	print("    主隊走回營地｜型別 %s 成本 %.0f｜新點那一支 %.1f 設施那一支 %.1f｜need_keep %.1f｜reserve %.1f｜買單 qty=%s for=%s｜walk +%d" % [
		ctype, _cost(ctype), nn, fac, nk, rsv, str(od.get("qty_remaining", "—")), str(od.get("for", "—")),
		int(Probe.counts.get("need.new_outpost.walk", 0)) - walk0])
	_cell("_n1")
	_check("N1 主隊在路上 ⇒ 新點那一支＝L1 成本、need_keep ≥ 成本", is_equal_approx(nn, _cost(ctype)) and nk >= _cost(ctype))
	_check("N1 料單 for=new_outpost、量＝reserve−持有（★reserve＝need_keep×液化係數）", String(od.get("for", "")) == "new_outpost"
		and int(od.get("qty_remaining", -1)) == int(rsv) and int(Probe.counts.get("g1.shortage_buy.new_outpost", 0)) == sb0 + 1)
	_check("N1 need.new_outpost.walk 有數", int(Probe.counts.get("need.new_outpost.walk", 0)) > walk0)
	# 另一列：派出的子隊在路上（任務＝建造 TASK_CONSTRUCT）
	var st2: WorldState = _mk(false, Vector2i(6, 6))
	var n2: TeamData = st2.teams[N]
	var tgt := Vector2i(8, 6)
	_site(st2, tgt, "forest", 150.0, 0.9)
	var ok: bool = FactionAISystem.shared()._dispatch_builder(st2, n2, tgt, "civilian", 1)
	var sub: TeamData = null
	for cid in n2.subteam_ids:
		var c: TeamData = st2.teams.get(cid)
		if c != null and c.current_task == TeamData.TASK_CONSTRUCT:
			sub = c
	var sn: float = NeedOracle._new_outpost_need(st2, sub, "material") if sub != null else -1.0
	print("    子隊在路上｜派出=%s｜task=%s move_target=%s 帶料 %.1f｜新點那一支 %.1f" % [str(ok), sub.current_task if sub else "—",
		str(sub.move_target) if sub else "—", _mat(sub) if sub else -1.0, sn])
	_check("N1 子隊在路上 ⇒ 新點那一支＝整筆成本（不扣持有）", sub != null and is_equal_approx(sn, _cost("civilian")))

func _n2() -> void:
	print("\n── N2 沒承諾就不算 ──")
	var ok: bool = true
	for task in [TeamData.TASK_IDLE, TeamData.TASK_FORAGE]:
		var w: Array = _walker(0.0)
		var st: WorldState = w[0]; var n: TeamData = w[1]
		n.current_task = task
		var nn: float = NeedOracle._new_outpost_need(st, n, "material")
		var cn: float = NeedOracle._construction_need(st, n, "material", _lvn(st, n))
		var fac: float = NeedOracle._construction_facility_need(st, n, "material", _lvn(st, n))
		print("    task=%s｜新點 %.1f｜_construction_need %.1f == 設施那一支 %.1f" % [task, nn, cn, fac])
		ok = ok and nn == 0.0 and cn == fac
	_cell("_n2")
	_check("N2 任務不是 TASK_BUILD ⇒ 新點 0、建造需求與修前同式（只剩設施那一支）", ok)

func _n2b() -> void:
	print("\n── N2b 三種不是①的 TASK_BUILD ──")
	var vals: Array = []
	# ①「建設」選項：目標＝腳下
	var w: Array = _walker(0.0)
	var st: WorldState = w[0]; var n: TeamData = w[1]
	_put(st, n, CAMP_C)
	n.move_target = CAMP_C
	vals.append(["目標＝腳下", NeedOracle._new_outpost_need(st, n, "material")])
	# ②復工工人：目標格有別隊的工地
	w = _walker(0.0); st = w[0]; n = w[1]
	(w[2] as HexTileData).construction_team_id = F
	vals.append(["目標格有別隊工地", NeedOracle._new_outpost_need(st, n, "material")])
	# ③升級設施：目標格 outpost_level > 0
	w = _walker(0.0); st = w[0]; n = w[1]
	(w[2] as HexTileData).outpost_level = 1
	vals.append(["目標格已是據點", NeedOracle._new_outpost_need(st, n, "material")])
	var ok: bool = true
	for v in vals:
		print("    %s ⇒ 新點 %.1f" % [v[0], v[1]])
		ok = ok and float(v[1]) == 0.0
	_cell("_n2b")
	_check("N2b 三種都是 0", ok)

# 森林工地（採段中，gather_left gl、site_stock need−gl），工地登記 ct
func _gather_site(st: WorldState, pos: Vector2i, ct: int, gl: float, type: String = "civilian") -> HexTileData:
	var tile := _site(st, pos, "forest", 150.0, 0.9)
	var need: float = _cost(type)
	tile.construction_team_id = ct
	tile.construction_ticks_left = OutpostSystem.build_person_hours(type, 1)
	tile.construction_target = {"action": "build", "type": type, "level": 1, "owner": ct, "need": need, "carried": 0.0,
		"gather_left": {"material": gl}, "site_stock": {"material": maxf(need - gl, 0.0)}, "start_pop": 6}
	tile.construction_started_tick = st.world.current_tick
	tile.construction_last_progress_tick = st.world.current_tick
	return tile

func _n3() -> void:
	print("\n── N3 採段的需求＝剩下的缺口 ──")
	var g0: int = int(Probe.counts.get("need.new_outpost.gather", 0))
	# 子隊：站在工地上（讀 tile_pos）
	var st: WorldState = _mk(false, Vector2i(6, 6))
	var n: TeamData = st.teams[N]
	var sub: TeamData = _npc_sub(st, n, TeamData.TASK_BUILD)
	var site := Vector2i(8, 6)
	_gather_site(st, site, sub.team_id, 30.0)
	_put(st, sub, site)
	sub.current_task = TeamData.TASK_BUILD
	var a: float = NeedOracle._new_outpost_need(st, sub, "material")
	# 母隊：離格（讀 corvee_site），同時 move_target 指向另一座自家營地（①若不互斥會再加 50）
	var w: Array = _walker(0.0)
	var st2: WorldState = w[0]; var n2: TeamData = w[1]
	var site2 := Vector2i(6, 9)
	_gather_site(st2, site2, N, 30.0)
	n2.corvee_site = site2
	var b: float = NeedOracle._new_outpost_need(st2, n2, "material")
	print("    子隊在格 ⇒ %.1f｜母隊離格（corvee_site）＋move_target 指向自家營地 ⇒ %.1f｜gather +%d" % [a, b,
		int(Probe.counts.get("need.new_outpost.gather", 0)) - g0])
	_cell("_n3")
	_check("N3 子隊讀 tile_pos ⇒ 30", is_equal_approx(a, 30.0))
	_check("N3 母隊讀 corvee_site ⇒ 30、不再加①的整筆", is_equal_approx(b, 30.0))
	_check("N3 need.new_outpost.gather 有數", int(Probe.counts.get("need.new_outpost.gather", 0)) > g0)

func _n3b() -> void:
	print("\n── N3b 雙算殘差可見（不斷言值）──")
	var w: Array = _walker(0.0)
	var st: WorldState = w[0]; var n: TeamData = w[1]
	var site := Vector2i(6, 9)
	_gather_site(st, site, N, 30.0)
	n.corvee_site = site
	var f: TeamData = st.teams[F]
	_add_named(st, f, 2)
	var wk: TeamData = _npc_sub(st, f, TeamData.TASK_BUILD, 3)
	_put(st, wk, site)
	wk.current_task = TeamData.TASK_BUILD
	var nc0: int = int(Probe.counts.get("need.new_outpost.gather.not_ct", 0))
	var cnt: int = 0
	for t in [n, wk]:
		if NeedOracle._new_outpost_need(st, t, "material") > 0.0:
			cnt += 1
	print("    同一工地滿足施工隊謂詞的隊數 %d｜need.new_outpost.gather.not_ct +%d" % [cnt, int(Probe.counts.get("need.new_outpost.gather.not_ct", 0)) - nc0])
	_cell("_n3b")
	_check("N3b 計數被印出（>0）", cnt > 0)

func _n4() -> void:
	print("\n── N4 採段吃帶來的料 ──")
	var w: Array = _forest_site(0.0, 0.0)   # 池 0 ⇒ 本 tick 採不到，變化全是抵料
	var st: WorldState = w[0]; var tile: HexTileData = w[1]; var pt: TeamData = w[2]
	ResourceBank.set_amt(pt, "material", 20.0, "bed_seed")
	var g0: float = _gl(tile); var s0: float = _ss(tile); var m0: float = _mat(pt)
	var os := OutpostSystem.new()
	os._tick_construction(st, tile)
	var dg: float = g0 - _gl(tile); var ds: float = _ss(tile) - s0; var dm: float = m0 - _mat(pt)
	var inv: Array = InvariantAudit.check(st)
	print("    帶 20 ⇒ gather_left %.1f→%.1f｜site_stock +%.1f｜隊上 −%.1f｜InvariantAudit 違反 %d（★它沒有材料守恆項，守恆用三量相等驗）" % [g0, _gl(tile), ds, dm, inv.size()])
	_cell("_n4")
	_check("N4 gather_left −20、site_stock +20、隊上 −20", is_equal_approx(dg, 20.0) and is_equal_approx(ds, 20.0) and is_equal_approx(dm, 20.0) and inv.is_empty())
	ResourceBank.set_amt(pt, "material", 100.0, "bed_seed")
	var k0: int = tile.construction_ticks_left
	os._tick_construction(st, tile)
	print("    帶 100 ≥ 剩 %.1f ⇒ gather_left=%.1f｜ticks_left %d→%d｜隊上剩 %.1f" % [g0 - 20.0, _gl(tile), k0, tile.construction_ticks_left, _mat(pt)])
	_check("N4 帶的料 ≥ gather_left ⇒ 當 tick 轉築段", _gl(tile) == 0.0 and tile.construction_ticks_left < k0 and is_equal_approx(_mat(pt), 100.0 - (g0 - 20.0)))

func _n4b() -> void:
	print("\n── N4b 接手的工人也吃料 ──")
	var st: WorldState = _mk(false, Vector2i(6, 6))
	var n: TeamData = st.teams[N]
	var site := Vector2i(8, 6)
	var tile := _gather_site(st, site, N, 40.0)
	tile.resources["material"] = 0.0
	n.corvee_site = site   # 原施工隊離格（在 (6,6)）、身上 0 料
	ResourceBank.set_amt(n, "material", 0.0, "bed_seed")
	var f: TeamData = st.teams[F]
	_add_named(st, f, 2)
	var wk: TeamData = _npc_sub(st, f, TeamData.TASK_BUILD, 3)
	_put(st, wk, site)
	wk.current_task = TeamData.TASK_BUILD
	ResourceBank.set_amt(wk, "material", 20.0, "bed_seed")
	var g0: float = _gl(tile); var s0: float = _ss(tile)
	OutpostSystem.new()._tick_construction(st, tile)
	print("    工人（非原施工隊）帶 20 ⇒ gather_left %.1f→%.1f｜site_stock +%.1f｜工人剩 %.1f｜原施工隊剩 %.1f" % [g0, _gl(tile), _ss(tile) - s0, _mat(wk), _mat(n)])
	_cell("_n4b")
	_check("N4b 接手工人帶的料抵進工地、工人 −20", is_equal_approx(g0 - _gl(tile), 20.0) and is_equal_approx(_ss(tile) - s0, 20.0) and is_equal_approx(_mat(wk), 0.0)
		and InvariantAudit.check(st).is_empty())

# coin 急（有 payroll、coin 0）而糧不急
func _coin_urgent(st: WorldState, t: TeamData) -> void:
	ResourceBank.set_amt(t, "coin", 0.0, "bed_seed")

func _n5() -> void:
	print("\n── N5 守料 ──")
	# (a) 斷言值
	var w: Array = _walker(0.0)
	var st: WorldState = w[0]; var n: TeamData = w[1]
	_coin_urgent(st, n)
	var lv: Dictionary = _lvn(st, n)
	var nk: float = NeedOracle.need_keep(st, n, "material", lv)
	var r: float = TradeValuation.reserve(n, "material", lv, st)
	var ffo: float = TradeValuation._reserve_factor_food_only(n, lv, st)
	var fall: float = TradeValuation._reserve_factor(n, lv, st)
	var w2: Array = _walker(0.0)
	var st2: WorldState = w2[0]; var n2: TeamData = w2[1]
	n2.current_task = TeamData.TASK_IDLE
	_coin_urgent(st2, n2)
	var r2: float = TradeValuation.reserve(n2, "material", _lvn(st2, n2), st2)
	print("    (a) 有承諾：reserve %.2f｜need_keep %.2f × 只看糧急 %.3f ＝ %.2f（全急迫係數 %.3f）｜沒承諾 reserve %.2f" % [r, nk, ffo, nk * ffo, fall, r2])
	_cell("_n5")
	_check("N5(a) 有承諾 ⇒ reserve＝need_keep×只看糧急係數；沒承諾不同", is_equal_approx(r, nk * ffo) and not is_equal_approx(r, r2))
	# (b) 斷言行為：②（corvee_site 工地 gather_left>0）、隊暫時去交易、coin 急而糧不急 ⇒ 賣盤不發 material
	#   ★持料取 25（< reserve）：規格寫 60，但 reserve＝need_keep×0.6（RESERVE_BASE，中性人格）＝30 ⇒ 60 會賣出 30（見交件信）
	var sold: Array = []
	for committed in [true, false]:
		var w3: Array = _walker(0.0)
		var st3: WorldState = w3[0]; var n3: TeamData = w3[1]
		var site := Vector2i(6, 9)
		_gather_site(st3, site, N if committed else -1, 50.0)
		n3.corvee_site = site if committed else Vector2i(-1, -1)
		n3.current_task = TeamData.TASK_TRADE
		n3.move_target = Vector2i(-1, -1)
		_coin_urgent(st3, n3)
		ResourceBank.set_amt(n3, "material", 25.0, "bed_seed")
		OrderSystem.new().tick_team_orders(st3, n3)
		var s: int = 0
		for o in n3.active_orders:
			if String(o["kind"]) == "sell" and String(o["res"]) == "material":
				s += int(o["qty_remaining"])
		print("    (b) %s｜持料 25｜reserve %.2f｜賣盤 material %d" % ["②工地 gather_left 50" if committed else "沒工地（對照）", TradeValuation.reserve(n3, "material", _lvn(st3, n3), st3), s])
		sold.append(s)
	_check("N5(b) ②狀態去交易 ⇒ 賣盤不發 material；沒工地的對照會賣", int(sold[0]) == 0 and int(sold[1]) > 0)

func _drive(st: WorldState, t: TeamData) -> float:
	var c := DecisionContext.new()
	var need: float = NeedOracle.need_keep(st, t, "material", _lvn(st, t))
	c.material_need_total = need
	c.material_shortfall = maxf(need - ResourceSystem.effective_holding(st, t, "material"), 0.0)
	c.material_build_urgency = NeedOracle.material_build_urgency(st, t)
	c.has_material_market = true
	c.has_specie = true
	return DecisionTerms.eval("buymaterial_drive", c, "買料")

func _n6() -> void:
	print("\n── N6 買料效用 ──")
	var w: Array = _walker(0.0)
	var st: WorldState = w[0]; var n: TeamData = w[1]
	var d0: float = _drive(st, n)
	var u0: float = NeedOracle.material_build_urgency(st, n)
	var w2: Array = _walker(200.0)
	var d1: float = _drive(w2[0], w2[1])
	var w3: Array = _walker(0.0)
	_site(w3[0], CAMP_C, "plains", 12.0, 1.1, N)
	var up: float = NeedOracle.new_outpost_urgency(w3[0], w3[1])
	print("    在路上料 0：urgency %.3f drive %.3f｜帶 200：drive %.3f｜平原營地 urgency %.3f" % [u0, d0, d1, up])
	_cell("_n6")
	_check("N6 在路上料 0 ⇒ drive > 0", d0 > 0.0)
	_check("N6 帶料 ≥ 成本 ⇒ drive 0", d1 == 0.0)
	_check("N6 平原目標（採不完）⇒ urgency 1", up == 1.0)

func _n6b() -> void:
	print("\n── N6b 採段中迫切隨進度降 ──")
	var u: Array = []
	for gl in [70.0, 5.0]:
		var st: WorldState = _mk(false, Vector2i(6, 6))
		var n: TeamData = st.teams[N]
		var sub: TeamData = _npc_sub(st, n, TeamData.TASK_BUILD)
		var site := Vector2i(8, 6)
		_gather_site(st, site, sub.team_id, gl, "military")   # military L1 需 80 ⇒ gather_left 70 合法
		_put(st, sub, site)
		sub.current_task = TeamData.TASK_BUILD
		var v: float = NeedOracle.new_outpost_urgency(st, sub)
		print("    gather_left=%.0f ⇒ 新點迫切 %.4f" % [gl, v])
		u.append(v)
	_cell("_n6b")
	_check("N6b gather_left 5 的迫切嚴格小於 70、且 ≥ 0", float(u[1]) < float(u[0]) and float(u[1]) >= 0.0)

func _n6c() -> void:
	print("\n── N6c 上限分配（新點先占）──")
	# 主隊 N 腳下有軍用 L1 據點（設施那一支 = weaponsmith 等 → 撞上限）＋自己離格的採段工地 gather_left 80
	var st: WorldState = _mk(false, Vector2i(6, 6))
	var n: TeamData = st.teams[N]
	var own: HexTileData = _tile(st, Vector2i(6, 6))
	own.outpost_type = "military"; own.outpost_level = 1
	OutpostOwnerBank.set_owner(st, own, N, "bed_seed")
	OwnerOutpostIndex.invalidate()
	n.armed_anon_ratio = 0.0
	var lv: Dictionary = _lvn(st, n)
	var site := Vector2i(6, 9)
	_gather_site(st, site, N, 80.0, "military")
	n.corvee_site = site
	n.current_task = TeamData.TASK_BUILD
	var nn: float = NeedOracle._new_outpost_need(st, n, "material")
	var fac: float = NeedOracle._construction_facility_need(st, n, "material", lv)
	var cn: float = NeedOracle._construction_need(st, n, "material", lv)
	print("    新點 %.1f｜設施（原值）%.1f｜_construction_need %.1f（上限 %.0f）" % [nn, fac, cn, NeedOracle.CONSTRUCTION_MATERIAL_NEED_CAP])
	_cell("_n6c")
	_check("N6c 新點 80 全留、設施得剩下的 20、合計 100", is_equal_approx(nn, 80.0) and fac >= 20.0 and is_equal_approx(cn, 100.0))

func _n8() -> void:
	print("\n── N8 承諾不被自己的需求換掉 ──")
	var w: Array = _walker(0.0)
	var st: WorldState = w[0]; var n: TeamData = w[1]
	n.goal_eval_next_tick = 0
	GoalResolver.ensure_maintain_goals(st, n)
	var mm: String = ""
	for g in n.goal_state:
		if String(g.get("goal_type", "")) == "maintain_material":
			mm = String(g.get("status", ""))
	var hold0: int = int(Probe.counts.get("persist.hold", 0))
	var runner := SimRunner.new()
	var swapped: String = ""
	var ticks: int = 0
	for i in range(3 * WorldState.TICKS_PER_DAY):
		runner.advance_tick(st, Vector2i(-1, -1))
		ticks += 1
		if not st.teams.has(N):
			break
		if n.current_task != TeamData.TASK_BUILD:
			swapped = n.current_task
			break
		if n.move_target == Vector2i(-1, -1) or n.tile_pos == CAMP_C:
			break
	print("    maintain_material=%s｜跑 %d tick｜task 換成=%s｜persist.hold +%d｜到營地=%s" % [mm, ticks, swapped if swapped != "" else "（沒換）",
		int(Probe.counts.get("persist.hold", 0)) - hold0, str(n.tile_pos == CAMP_C)])
	_cell("_n8")
	_check("N8 maintain_material active", mm == "active")
	_check("N8 TASK_BUILD 沒被換掉（或 persist.hold 有增）", swapped == "" or int(Probe.counts.get("persist.hold", 0)) > hold0)
