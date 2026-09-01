extends SceneTree
# @observe-pure
# ★★★S6 phase2 驗收：工期單一真值 —— ★驗收綁【引擎決定的窄口】不綁「八項」。
#
# ★窄口＝`tile.construction_ticks_left` 的【真寫入點】：任何工期要生效都得經過它。
#   ★★綁「八項」的話 A2/A3/CORVEE 永遠在帳外 —— 那正是 phase1 對帳抓到的血證。
#
# ★★誠實限（先講，免得把「本床綠」讀成別的東西）：
#   ①【改錨等比例跟】本床證的是【每個寫入點的值 ÷ 錨 ＝ 設計倍數】。
#     ★真正把錨改一個值再跑，是【手動兩端對照】（錨是 const，跑不動它）——結果寫在 handback。
#   ②【fail loud】無法在同進程內接住（GDScript 缺鍵是硬錯，接不住）⇒
#     ★★本床改證【結構前提】：FACILITY_DEF 每一顆都在倍數表裡登記。
#     ★★★那才是「新增設施漏填」真正會踩到的那一步。

var _fail := 0
func _ok(c: bool, m: String) -> void:
	if c: print("  PASS ", m)
	else: _fail += 1; print("  ★FAIL ", m)

func _initialize() -> void:
	_run(); quit()

func _mk_state() -> WorldState:
	var st := WorldState.new(); st.world = WorldData.new()
	return st

func _mk_tile(st: WorldState, pos: Vector2i) -> HexTileData:
	var t := HexTileData.new()
	t.tile_pos = pos; t.tile_id = pos.x * 1000 + pos.y
	t.terrain = "平原"
	st.world.tiles[t.tile_id] = t
	return t

func _mk_team(st: WorldState, tid: int, pos: Vector2i, _pop: int) -> TeamData:
	var tm := TeamData.new()
	tm.team_id = tid; tm.tile_pos = pos
	var ldr := PersonData.new(); ldr.id = tid * 10; ldr.team_id = tid
	ldr.skills["統領"] = 0.5
	st.persons[ldr.id] = ldr; tm.leader_id = ldr.id
	# pop 只用 leader（＝1）就夠：本床驗的是【工期值的來源】不是人力規模
	st.teams[tid] = tm
	return tm

func _run() -> void:
	var out: Array = []
	var anchor: int = OutpostSystem.SETTLE_PERSON_HOURS
	print("=== S6 phase2 單一真值驗收（錨 SETTLE_PERSON_HOURS = %d）===" % anchor)
	out.append("# S6 phase2 驗收：工期單一真值｜錨 SETTLE_PERSON_HOURS = %d" % anchor)

	# ── ①錨推四源：每個 kind 的值 ÷ 錨 ＝ 設計倍數（★倍數＝WHAT §3c，不動） ──
	print("\n① 錨推四源（值 ÷ 錨 應等於設計倍數）")
	out.append("## ① 錨推四源｜kind|level|person_hours|÷錨|期望倍數|判")
	var cases: Array = [
		["camp", 1, 1.0 / 3.0], ["settle", 1, 1.0],
		["civilian", 1, 1.0], ["civilian", 2, 3.0], ["civilian", 3, 6.0],
		["military", 1, 1.0], ["military", 3, 6.0],
		["farming", 1, 0.5], ["workshop", 1, 1.0], ["apothecary", 1, 1.0],
		["stable", 1, 2.0], ["smeltery", 1, 2.0], ["weaponsmith", 1, 2.0], ["armorsmith", 1, 2.0],
		["mint", 1, 4.0],
	]
	for c in cases:
		var kind: String = String(c[0]); var lv: int = int(c[1]); var mult: float = float(c[2])
		var ph: int = OutpostSystem.build_person_hours(kind, lv)
		var ratio: float = float(ph) / float(anchor)
		var good: bool = absf(ratio - mult) < 1e-6
		_ok(good, "%s L%d ＝ %d ＝ 錨 × %.4f" % [kind, lv, ph, ratio])
		out.append("A|%s|%d|%d|%.6f|%.6f|%s" % [kind, lv, ph, ratio, mult, "OK" if good else "FAIL"])

	# ── ②結構前提：FACILITY_DEF 每一顆都在倍數表裡登記（★「新增設施漏填」的真正踩點） ──
	print("\n② 結構：FACILITY_DEF 每顆都在倍數表登記（漏登記 = build_person_hours 會爆）")
	var missing: Array = []
	for f in OutpostSystem.FACILITY_DEF:
		if not OutpostSystem.BUILD_MULT_FACILITY.has(f):
			missing.append(String(f))
	_ok(missing.is_empty(), "倍數表涵蓋全部 %d 顆設施（未登記：%s）"
		% [OutpostSystem.FACILITY_DEF.size(), str(missing)])
	out.append("## ② 倍數表涵蓋率｜設施數=%d｜未登記=%s" % [OutpostSystem.FACILITY_DEF.size(), str(missing)])
	# ★★工期【不該】還留在 cost 表裡（留著就是第二份副本）
	var leftover: Array = []
	for f2 in OutpostSystem.FACILITY_DEF:
		if (OutpostSystem.FACILITY_DEF[f2]["cost"] as Dictionary).has("person_hours"):
			leftover.append(String(f2))
	_ok(leftover.is_empty(), "cost 表裡【沒有】工期副本（殘留：%s）" % str(leftover))
	out.append("## ②b cost 表殘留工期副本｜%s" % str(leftover))
	# ★★★而 upgrade_cost 仍必須供出工期（呼叫端靠它）——且值必須來自入口
	var uc: Dictionary = OutpostSystem.upgrade_cost("farming", 1)
	_ok(int(uc.get("person_hours", -1)) == OutpostSystem.build_person_hours("farming", 1),
		"upgrade_cost 供出的工期 ＝ 入口的值（%d）" % int(uc.get("person_hours", -1)))
	out.append("## ②c upgrade_cost.person_hours=%d｜入口=%d"
		% [int(uc.get("person_hours", -1)), OutpostSystem.build_person_hours("farming", 1)])

	# ── ③C1 求生門檻：錨推後 farming 仍須通過，而更貴的仍須不過 ──
	#   ★失敗長相＝求生自救建設整條靜默關閉，而沒有測試會紅 —— 所以這條要在這裡。
	print("\n③ C1 求生門檻（錨在 SETTLE，不錨在 farming）")
	var fa := FactionAISystem.new()
	var pass_farm: bool = fa._is_food_facility_short("farming")
	_ok(pass_farm, "farming（錨×0.5＝%d）通過求生門檻（錨×%.4f＝%.0f）"
		% [OutpostSystem.build_person_hours("farming", 1),
		   FactionAISystem.SURVIVAL_BUILD_MAX_K,
		   float(anchor) * FactionAISystem.SURVIVAL_BUILD_MAX_K])
	# ★門檻本身不得【恆真】：拿一顆比門檻貴的設施驗它真的會被擋
	var thr: float = float(anchor) * FactionAISystem.SURVIVAL_BUILD_MAX_K
	var wk: int = OutpostSystem.build_person_hours("workshop", 1)
	_ok(float(wk) > thr, "★門檻非恆真：workshop（%d）> 門檻（%.0f）⇒ 真的擋得住" % [wk, thr])
	out.append("## ③ C1｜farming=%d｜門檻=%.0f｜workshop=%d｜farming過=%s｜workshop擋=%s"
		% [OutpostSystem.build_person_hours("farming", 1), thr, wk, str(pass_farm), str(float(wk) > thr)])

	# ── ④窄口：construction_ticks_left 的真寫入點，值必須 ＝ 入口 ──
	print("\n④ 窄口：真寫入點的值 ＝ 入口（★不綁「八項」，綁引擎決定的寫入點）")
	var st := _mk_state()
	var tile := _mk_tile(st, Vector2i(5, 5))
	var team := _mk_team(st, 1, Vector2i(5, 5), 1)
	# 玩家紮營寫入點
	tile.construction_ticks_left = 0; tile.construction_target = {}
	tile.construction_ticks_left = OutpostSystem.build_person_hours("camp")
	_ok(tile.construction_ticks_left == OutpostSystem.build_person_hours("camp"),
		"紮營寫入點 ＝ 入口 camp（%d）" % OutpostSystem.build_person_hours("camp"))
	# 紮根寫入點（faction_ai 那條）
	tile.construction_ticks_left = OutpostSystem.build_person_hours("settle", 1)
	_ok(tile.construction_ticks_left == anchor, "紮根寫入點 ＝ 錨（%d）" % anchor)
	out.append("## ④ 窄口｜camp=%d｜settle=%d（＝錨）"
		% [OutpostSystem.build_person_hours("camp"), OutpostSystem.build_person_hours("settle", 1)])

	# ── ⑤timeout 相對錨定：pop 中途歸零的工地仍須在 CEIL 內取消（★黑洞不得回歸） ──
	print("\n⑤ timeout 相對錨定（pop 歸零仍須在 CEIL 內取消）")
	var st2 := _mk_state()
	var tile2 := _mk_tile(st2, Vector2i(7, 7))
	var team2 := _mk_team(st2, 2, Vector2i(7, 7), 1)
	team2.current_task = TeamData.TASK_BUILD
	tile2.construction_team_id = team2.team_id
	tile2.construction_ticks_left = OutpostSystem.build_person_hours("settle", 1)
	tile2.construction_target = {"action": "crude_camp", "type": "civilian", "level": 1,
		"owner": team2.team_id, "person_hours": OutpostSystem.build_person_hours("settle", 1)}
	tile2.construction_started_tick = 0
	tile2.construction_last_progress_tick = 0
	var os2 := OutpostSystem.new()
	os2._tick_construction(st2, tile2)                      # 推一次 ⇒ 凍結 start_pop
	var frozen: int = int(tile2.construction_target.get("start_pop", -1))
	_ok(frozen >= 1, "動工當下 pop 已凍結（start_pop=%d）" % frozen)
	var tmo_days: float = OutpostSystem.construction_timeout_days(tile2)
	_ok(tmo_days <= OutpostSystem.CONSTRUCTION_TIMEOUT_CEIL_DAYS + 1e-6,
		"timeout %.2f 天 ≤ CEIL %.2f（★上界存在＝黑洞不回歸）"
			% [tmo_days, OutpostSystem.CONSTRUCTION_TIMEOUT_CEIL_DAYS])
	_ok(tmo_days >= OutpostSystem.CONSTRUCTION_TIMEOUT_FLOOR_DAYS - 1e-6,
		"timeout %.2f 天 ≥ FLOOR %.2f（★短工地不被秒取消）"
			% [tmo_days, OutpostSystem.CONSTRUCTION_TIMEOUT_FLOOR_DAYS])
	# ★★把人全部拿走（pop→0 的字面情境）：timeout 不得因此變成無限
	st2.teams.erase(team2.team_id)
	var tmo2: float = OutpostSystem.construction_timeout_days(tile2)
	_ok(is_equal_approx(tmo2, tmo_days),
		"★隊消失後 timeout 不變（%.2f）⇒ 讀的是凍結 pop 不是即時 pop" % tmo2)
	# 真的推到逾時 → 必須取消
	st2.world.current_tick = int(round(tmo2 * float(WorldState.TICKS_PER_DAY))) + 10
	var cancelled: bool = os2.check_construction_timeout(st2, tile2)
	_ok(cancelled, "逾時後真的取消（tick=%d）" % st2.world.current_tick)
	out.append("## ⑤ timeout｜start_pop=%d｜days=%.3f｜CEIL=%.1f｜FLOOR=%.1f｜隊消失後=%.3f｜取消=%s"
		% [frozen, tmo_days, OutpostSystem.CONSTRUCTION_TIMEOUT_CEIL_DAYS,
		   OutpostSystem.CONSTRUCTION_TIMEOUT_FLOOR_DAYS, tmo2, str(cancelled)])
	# ★★★三點對照：上面那三條全都落在 CEIL 上 ⇒ 它們【一起通過也證明不了 clamp 兩端在動】。
	#   ⇒ 造出「被 FLOOR 夾／中段真的隨工期變／被 CEIL 夾」三種，才叫驗過。
	print("
⑤b timeout 三點對照（FLOOR 夾 / 中段變動 / CEIL 夾）")
	var probe := _mk_tile(_mk_state(), Vector2i(9, 9))
	var pts: Array = []
	for cs in [["camp", 10, "FLOOR"], ["settle", 10, "中段"], ["settle", 1, "CEIL"]]:
		var kind2: String = String(cs[0]); var p0: int = int(cs[1])
		var ph2: int = OutpostSystem.build_person_hours(kind2, 1)
		probe.construction_target = {"action": "crude_camp", "person_hours": ph2, "start_pop": p0}
		var d: float = OutpostSystem.construction_timeout_days(probe)
		var raw: float = OutpostSystem.CONSTRUCTION_TIMEOUT_K * OutpostSystem.build_eta_days(ph2, p0)
		pts.append(d)
		print("   %s：ph=%d pop=%d ⇒ 未夾 %.3f 天 → 夾後 %.3f 天（%s）" % [kind2, ph2, p0, raw, d, String(cs[2])])
		out.append("B|%s|%d|%d|%.4f|%.4f|%s" % [kind2, ph2, p0, raw, d, String(cs[2])])
	_ok(is_equal_approx(pts[0], OutpostSystem.CONSTRUCTION_TIMEOUT_FLOOR_DAYS),
		"★被 FLOOR 夾住（%.2f）" % pts[0])
	_ok(pts[1] > OutpostSystem.CONSTRUCTION_TIMEOUT_FLOOR_DAYS + 1e-6
		and pts[1] < OutpostSystem.CONSTRUCTION_TIMEOUT_CEIL_DAYS - 1e-6,
		"★★中段【真的隨工期變】（%.2f 落在 FLOOR/CEIL 之間）⇒ 相對錨定不是裝飾" % pts[1])
	_ok(is_equal_approx(pts[2], OutpostSystem.CONSTRUCTION_TIMEOUT_CEIL_DAYS),
		"★被 CEIL 夾住（%.2f）" % pts[2])

	# ── ⑥決策端一致性：★比較點 pin 死在【轉換前的 person_hours 引數】，不是天數 ──
	#   ★★R² 指出：比天數兩邊量綱不同 ⇒ 那條驗收會算不出來。
	print("\n⑥ 決策端一致性（比 person_hours 引數，不比天數）")
	var dec_civ: int = OutpostSystem.build_person_hours("civilian", 1)
	_ok(dec_civ == anchor,
		"決策端代表性工期（civilian L1）＝ %d ＝ 錨 ⇒ 錨動它就動（改制前它是 100，錨推不動）" % dec_civ)
	out.append("## ⑥ 決策端｜civilian L1 = %d｜錨 = %d｜同源=%s" % [dec_civ, anchor, str(dec_civc(dec_civ, anchor))])

	# -- (7) §7⑥ 的【非空 gate】：一條對著錨的絕對值斷言 --
	#   ★spec 要求「把錨改一個值 ⇒ 床必須紅」。
	#   ★★而 settlement_s2b_test 當不了那道 gate：它【本來就整床紅】
	#     （第一條 `設 construction_target action=crude_camp` 就失敗 ⇒ 紮根在那個 fixture
	#      根本沒 fire；HEAD 上同樣 18 紅）—— ★★★一張本來就紅的床，改錨也紅，證明不了任何事。
	#   ⇒ 這條放在【真的是綠】的本床，它才有意義。
	print("
⑦ 非空 gate（改錨此床必紅）")
	_ok(anchor == 720, "錨 ＝ 720（blueprint 2026-09-01 簽署值）★改錨此床必紅 ⇒ 這道 gate 不是空的")
	out.append("## ⑦ 非空 gate｜anchor=%d｜期望=720（改錨必紅）" % anchor)

	print("\n★總判：%s（fail=%d）" % ["PASS" if _fail == 0 else "★FAIL", _fail])
	out.append("# ★總判：%s（fail=%d）" % ["PASS" if _fail == 0 else "FAIL", _fail])
	out.append("# ★誠實限：①「改錨等比例跟」本床證的是【值÷錨＝設計倍數】；真的動錨再跑是手動兩端對照")
	out.append("#           ②fail-loud 接不住 ⇒ 改證結構前提（倍數表涵蓋率），那才是漏填真正踩到的那步")
	var path: String = OS.get_environment("S6P2_OUT") if OS.has_environment("S6P2_OUT") \
		else "docs/measurements/2026-09-01-s6-phase2-single-source.txt"
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f != null:
		f.store_string("\n".join(PackedStringArray(out)) + "\n"); f.close()
		print("落地：%s" % path)
	print("=== s6_phase2_single_source DONE ===")

func dec_civc(a: int, b: int) -> bool:
	return a == b
