extends SceneTree
# @bed-kind: acceptance
# slice: 卡①(a)(b) 糧改走稅路 ＋ 卡③ 勞力池只收自己人（HOW spec 2026-09-11）
#
# ★★★這張票的驗收在【自然世界判不動】：三個 config 在 t=0 房客都是 0，
#   而「白捐 ＝ 0」在沒有房客的世界裡**自動成立** ⇒ ★必須用 fixture 造房客，
#   ★★而自然世界那一格【明寫不可判】，不准用「沒有不一致」冒充綠。
# ★房客用的是**世界真的會產生的那一種**（`_convert_to_resident` 那條路的結果狀態：
#   同 faction、站在別人的據點上、登記在那裡）。

var fails: int = 0
var sections: int = 0

func _ok(name: String, cond: bool, detail: String) -> void:
	sections += 1
	if cond:
		print("  PASS %s ── %s" % [name, detail])
	else:
		fails += 1
		print("  [FAIL] %s ── %s" % [name, detail])

func _initialize() -> void:
	print("=== 房客分成／吃得到／不再白捐（fixture）===")
	seed(20260911)
	var st := MeasureBedHelper.arm_and_setup("res://config/peaceful_economy.json")
	# ── 造 fixture：地主（owner）＋ 房客（同 faction、站在地主據點、登記在那裡）──
	print("[step] setup 完成，開始找地主")
	var landlord: TeamData = null
	var tile: HexTileData = null
	for tid in st.teams:
		var t: TeamData = st.teams[tid]
		var ot: HexTileData = st.own_outpost_tile(t.team_id)
		if ot != null and ot.outpost_level > 0:
			landlord = t
			tile = ot
			break
	if landlord == null:
		print("★母體塌陷：找不到有據點的隊 ⇒ 不可判")
		print("=== DONE === SECTIONS=0/6 FAILS=1")
		quit(1)
	print("[step] 地主 Team%d @(%d,%d)" % [landlord.team_id, tile.tile_pos.x, tile.tile_pos.y])
	var lodger := TeamData.new()
	print("[step] a new")
	lodger.team_id = 90001
	lodger.faction_id = landlord.faction_id
	lodger.tile_pos = tile.tile_pos
	# ★`tags` 走單寫者 chokepoint、`population` 是**計算屬性**（直寫會被靜默吞掉）
	#   ⇒ ★★用 anon cohort 加人（★★★第一版我直寫 `population = 10`，床當場撞上吞寫守衛）
	print("[step] b 設欄位完成")
	st.set_team_tags(lodger, [TeamData.TAG_PRODUCE], "lodger_fixture")
	print("[step] c tags 完成")
	AnonCohort.add(lodger.anon_cohorts, "平民", "healthy", 10)
	print("[step] d anon 完成 pop=%d" % lodger.population)
	lodger.work_outpost = tile.tile_pos          # ★登記在這格（登記錨 ④a）
	print("[step] e 登記完成")
	st.teams[lodger.team_id] = lodger
	print("[step] f 入世界完成")
	OwnerOutpostIndex.invalidate()
	FacilityExistenceIndex.invalidate()
	print("[step] 房客造好 pop=%d" % lodger.population)

	# ①分成：房客採 100 糧 ⇒ 私產留 (1−tax)×100、公庫收 tax×100
	var rs := ResourceSystem.new()
	print("[step] 要算稅率了")
	var rate: float = ResourceSystem.tax_rate_for(st, landlord)
	print("[step] 稅率=%.3f" % rate)
	lodger.resources["food"] = 100.0
	var vault_before: float = float(tile.public_storage.get("food", 0))
	rs._apply_normal_tax(st, lodger, tile, {"food": 100.0})
	var priv_after: float = float(lodger.resources.get("food", 0))
	var vault_after: float = float(tile.public_storage.get("food", 0))
	_ok("①房客分成", abs(priv_after - (1.0 - rate) * 100.0) < 0.01 and abs((vault_after - vault_before) - rate * 100.0) < 0.01,
		"tax_rate=%.3f ⇒ 私產留 %.2f（期望 %.2f）／公庫收 %.2f（期望 %.2f）" % [
			rate, priv_after, (1.0 - rate) * 100.0, vault_after - vault_before, rate * 100.0])

	# ②吃得到：消費端【真的扣到】它自己的私產
	var before_priv: float = float(lodger.resources.get("food", 0))
	rs.resolve_consumption(st, [lodger.team_id], WorldState.TICKS_PER_DAY)   # ★走 production 的消費路徑
	var after_priv: float = float(lodger.resources.get("food", 0))
	_ok("②房客吃得到", after_priv < before_priv,
		"私產 %.2f → %.2f（★看【扣】，不是看「有效糧變多」）" % [before_priv, after_priv])

	# ③白捐歸零：房客【沒登記】時不進地主勞力池；★成對對照：登記回去 ⇒ 要回到被算進去
	var pool_with_reg: float = LaborSystem.pool_of(st, tile)
	lodger.work_outpost = Vector2i(-1, -1)       # 取消登記 ＝ 路過的隊
	var pool_no_reg: float = LaborSystem.pool_of(st, tile)
	lodger.work_outpost = tile.tile_pos          # 登記回去（成對對照的另一半）
	var pool_back: float = LaborSystem.pool_of(st, tile)
	_ok("③白捐歸零＋成對對照", pool_no_reg < pool_with_reg and abs(pool_back - pool_with_reg) < 0.01,
		"登記時池=%.1f／未登記=%.1f／登記回去=%.1f（★中間那個要變小，第三個要回來）" % [
			pool_with_reg, pool_no_reg, pool_back])

	# ④owner 自採守恆：採集者 ＝ owner 時，**私產＋公庫的總和與改前相同**（★換路不是漏水）
	var own_priv0: float = float(landlord.resources.get("food", 0))
	var own_vault0: float = float(tile.public_storage.get("food", 0))
	landlord.resources["food"] = own_priv0 + 100.0        # ★模擬「剛採到 100」
	var total_before: float = own_priv0 + 100.0 + own_vault0
	rs._apply_normal_tax(st, landlord, tile, {"food": 100.0})
	var total_after: float = float(landlord.resources.get("food", 0)) + float(tile.public_storage.get("food", 0))
	_ok("④owner 自採守恆", abs(total_after - total_before) < 0.01,
		"私產＋公庫 %.2f → %.2f（★差 %.4f；★★自己付自己＝帳面轉移，總和不動）" % [
			total_before, total_after, total_after - total_before])

	# ⑤tax_rate 分布（★不是平均；★★不得全部等於 0.3 ＝ 接線沒接上）
	var rates: Dictionary = {}
	for tid in st.teams:
		var t2: TeamData = st.teams[tid]
		var r: float = ResourceSystem.tax_rate_for(st, t2)
		var k: String = "%.2f" % r
		rates[k] = int(rates.get(k, 0)) + 1
	var distinct: int = rates.size()
	var all_default: bool = distinct == 1 and rates.has("0.30")
	_ok("⑤tax_rate 會動", distinct > 1 and not all_default,
		"相異稅率 %d 種：%s（★全部 0.30 ⇒ 接線沒接上）" % [distinct, str(rates)])

	# ⑥自然世界：明寫不可判 ＋ 母體數字
	var lodgers_natural: int = 0
	var residents_natural: int = 0
	for tid in st.teams:
		var t3: TeamData = st.teams[tid]
		if int(tid) == lodger.team_id:
			continue
		if st.is_registered_resident(t3):
			residents_natural += 1
			var rt: HexTileData = st.world.tiles.get(t3.work_outpost.x * 1000 + t3.work_outpost.y)
			if rt != null and rt.outpost_owner != t3.team_id:
				lodgers_natural += 1
	sections += 1
	print("  ★⑥自然世界：居民 %d／**房客 %d** ⇒ %s" % [residents_natural, lodgers_natural,
		"可判" if lodgers_natural > 0 else "**不可判**（★★沒有房客時「白捐＝0」自動成立，不是綠）"])

	print("  ★⑦fp（本床改了世界 ⇒ 只作記錄，不當判準）=%s" % StateFingerprint.compute(st))
	print("=== DONE === SECTIONS=%d/%d FAILS=%d" % [sections - fails, sections, fails])
	quit(1 if fails > 0 else 0)
