extends SceneTree
# @bed-kind: invariant
# ══ 票 A3：領取在自家市集不再被「不自交易」擋掉＋到場落空留失敗記號 ═══════════════════════════
# spec：`docs/superpowers/specs/2026-10-06-a-committed-action-must-change-the-world-HOW.md` §4 A3
#
# ★驗的是**真的入口**：`SimRunner._step3c_read_market_board(state, [tid])`（sim_runner 每 tick 在抵達後呼的那一支）
#   ⇒ 兩道閘都在路上：入口的 owner 閘（已拆）＋ resolver 內的「自家市集不自交易」早返回（領取已搬到它之前）
#   ⇒ ★只呼 resolver 的話，入口那道閘的回歸看不到（spec 原文只讀了 resolver 本體，正是這樣漏的）
# ★為什麼用佈置不用自然樣本：seed 1337、30 天的世界裡沒有任何隊「承諾領取並抵達自家市集」
#   （Team14 那筆卡住的待領，是因為它從沒選領取 —— 實測選領取 0 tick，修改前後 [Claim] 事件逐行相同）
#
# 格：P1 自家市集：承諾領取＋抵達 ⇒ 那個種類（material）必增、待領清空、★領完被 release（latch 不再）
#     P2 別人的市集：照舊領得到（不被這次搬動弄壞）
#     P3 失敗記號：承諾領取、到場落空 ⇒ recent_failures 有「領取|<tile_id>」且對那一格折價 < 1；
#        ★反向：領到了 ⇒ 沒有那一筆；★反向二：沒承諾領取（路過）⇒ 落空也不記
#     P4 ~~非領取的 option 帶 TRADE 抵達自家市集 ⇒ 不 release（systems 裁 (B)）~~
#        ★票 A2（藍圖裁 eeca99661，2026-10-07）推翻：自家市集規則只禁自己的單、入口兩道閘拿掉、只留一條路
#        ⇒ 任何 option 帶 TRADE 抵達市集（含自家）都照抵達規則放手；不是承諾領取 ⇒ 不記「領取」落空

var _errors: int = 0
var _cells_ran: Array = []
const EXPECTED_CELLS: Array = ["P1", "P2", "P3", "P4"]
const AMT: float = 7.0


func _initialize() -> void:
	print("=== claim_at_own_market：領取在自家市集＋到場落空的失敗記號 ===")
	_p1_own_market()
	_p2_other_market()
	_p3_failure_marker()
	_p4_non_claim_option_not_released()
	var missing: Array = []
	for c in EXPECTED_CELLS:
		if not _cells_ran.has(String(c)):
			missing.append(String(c))
	_check("★到場點名：%d／%d（缺：%s）" % [_cells_ran.size(), EXPECTED_CELLS.size(), str(missing)], missing.is_empty())
	print("\n=== claim_at_own_market DONE === errors: %d" % _errors)
	quit(1 if _errors > 0 else 0)


func _check(msg: String, cond: bool) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_errors += 1
		push_error("[FAIL] " + msg)


func _mk_world() -> WorldState:
	seed(1337)
	var ws := WorldState.new()
	GameSetup.setup(ws, GameSetup.load_config("res://config/default.json"))
	ws.player_id = -1
	return ws


# 找一個有市集（outpost_level > 0）的格：owner ＝ 某隊（want_own＝true 時回 [tile, owner_team]，否則回 [tile, 另一支隊]）
func _pick(ws: WorldState, want_own: bool) -> Array:
	var ids: Array = ws.world.tiles.keys()
	ids.sort()
	for k in ids:
		var tile: HexTileData = ws.world.tiles[k]
		if tile.outpost_level <= 0 or not ws.teams.has(tile.outpost_owner):
			continue
		if want_own:
			return [tile, ws.teams[tile.outpost_owner]]
		var tids: Array = ws.teams.keys()
		tids.sort()
		for t in tids:
			var tt: TeamData = ws.teams[t]
			if int(t) != tile.outpost_owner and tt.beast_kind == "":
				return [tile, tt]
	return []


# 佈置：隊站在那一格、task＝TRADE、current_option＝領取（＝「承諾領取並抵達」的形狀）
func _stage(team: TeamData, tile: HexTileData, option: String) -> void:
	team.tile_pos = tile.tile_pos
	team.move_target = tile.tile_pos
	team.current_task = TeamData.TASK_TRADE
	team.current_option = option


func _p1_own_market() -> void:
	print("\n── P1 自家市集：承諾領取＋抵達 ⇒ 那個種類必增 ──")
	var ws: WorldState = _mk_world()
	var pick: Array = _pick(ws, true)
	_check("★母體地板：找得到有主的市集格", not pick.is_empty())
	if pick.is_empty():
		_cells_ran.append("P1")
		return
	var tile: HexTileData = pick[0]
	var team: TeamData = pick[1]
	tile.pending_claims.append({"owner_team": team.team_id, "kind": "goods", "res": "material", "amt": AMT})
	_stage(team, tile, "領取")
	var before: float = float(team.resources.get("material", 0.0))
	print("   %s owner ＝ Team%d｜待領 material %.1f｜Team%d 站在上面、task＝TRADE、option＝領取" % [
		str(tile.tile_pos), tile.outpost_owner, AMT, team.team_id])
	_check("★母體地板：待領真的在**自家**市集（outpost_owner ＝ 待領主）", tile.outpost_owner == team.team_id)
	SimRunner.new()._step3c_read_market_board(ws, [team.team_id])
	var after: float = float(team.resources.get("material", 0.0))
	print("   material %.1f → %.1f｜待領剩 %d 筆" % [before, after, tile.pending_claims.size()])
	_check("★★★P1 material 必增 %.1f（%.1f → %.1f）" % [AMT, before, after], is_equal_approx(after - before, AMT))
	_check("★★P1 那筆待領被清掉", tile.pending_claims.is_empty())
	# ★★latch：承諾領取、到了、領完 ⇒ 必須被 release（否則它領完還卡在 TASK_TRADE）
	print("   領完之後 task ＝ %s" % str(team.current_task))
	_check("★★★P1 領完被 release（task 不再是 TRADE：%s）" % str(team.current_task), team.current_task != TeamData.TASK_TRADE)
	_cells_ran.append("P1")


func _p2_other_market() -> void:
	print("\n── P2 別人的市集：照舊領得到 ──")
	var ws: WorldState = _mk_world()
	var pick: Array = _pick(ws, false)
	_check("★母體地板：找得到別人的市集格", not pick.is_empty())
	if pick.is_empty():
		_cells_ran.append("P2")
		return
	var tile: HexTileData = pick[0]
	var team: TeamData = pick[1]
	tile.pending_claims.append({"owner_team": team.team_id, "kind": "coin", "res": "coin", "amt": AMT})
	_stage(team, tile, "領取")
	var before: float = float(team.resources.get("coin", 0.0))
	SimRunner.new()._step3c_read_market_board(ws, [team.team_id])
	var after: float = float(team.resources.get("coin", 0.0))
	print("   %s owner ＝ Team%d｜Team%d 領 coin：%.2f → %.2f" % [str(tile.tile_pos), tile.outpost_owner, team.team_id, before, after])
	_check("★母體地板：真的是別人的市集", tile.outpost_owner != team.team_id)
	# ★coin 那一側可能同時有市集成交（訪客會吃板上的單）⇒ 只斷言「至少領到那一筆」
	_check("★★★P2 coin 至少增 %.1f（%.2f）" % [AMT, after - before], after - before >= AMT - 0.001)
	var left: int = 0
	for c in tile.pending_claims:
		if int((c as Dictionary).get("owner_team", -1)) == team.team_id:
			left += 1
	_check("★★P2 本隊在那一格的待領清空（剩 %d）" % left, left == 0)
	_cells_ran.append("P2")


func _p3_failure_marker() -> void:
	print("\n── P3 失敗記號：承諾領取、到場落空 ⇒ 記一筆；★反向兩個 ──")
	# (a) 落空：承諾領取，而那一格沒有待領
	var ws: WorldState = _mk_world()
	var pick: Array = _pick(ws, true)
	if pick.is_empty():
		_check("★母體地板：找得到有主的市集格", false)
		_cells_ran.append("P3")
		return
	var tile: HexTileData = pick[0]
	var team: TeamData = pick[1]
	var k: String = FailureMemory.key("領取", str(tile.tile_id))
	_stage(team, tile, "領取")
	SimRunner.new()._step3c_read_market_board(ws, [team.team_id])
	var ctx := DecisionContext.new()
	ctx.pending_claim_tile_id = tile.tile_id
	var m: float = FailureMemory.mult_for_option(ws, team, "領取", ctx)
	print("   (a) 落空：recent_failures 有「%s」＝ %s｜對那一格的折價 ＝ %.3f" % [k, str(team.recent_failures.has(k)), m])
	_check("★★★P3(a) 承諾領取、到場落空 ⇒ 有那一筆失敗記憶", team.recent_failures.has(k))
	_check("★★★P3(a) 下輪對那一格的「領取」折價 < 1（%.3f）" % m, m < 1.0)
	# ★另一格不受影響（target 對準那一格，不是一次落空就對所有待領折價）
	var ctx2 := DecisionContext.new()
	ctx2.pending_claim_tile_id = tile.tile_id + 1
	_check("★★P3(a) 別格不折價（%.3f）" % FailureMemory.mult_for_option(ws, team, "領取", ctx2),
		FailureMemory.mult_for_option(ws, team, "領取", ctx2) == 1.0)
	# (b) 反向：領到了 ⇒ 不記
	var ws2: WorldState = _mk_world()
	var p2: Array = _pick(ws2, true)
	var tile2: HexTileData = p2[0]
	var team2: TeamData = p2[1]
	tile2.pending_claims.append({"owner_team": team2.team_id, "kind": "goods", "res": "material", "amt": AMT})
	_stage(team2, tile2, "領取")
	SimRunner.new()._step3c_read_market_board(ws2, [team2.team_id])
	var k2: String = FailureMemory.key("領取", str(tile2.tile_id))
	print("   (b) 領到了：recent_failures 有那一筆 ＝ %s" % str(team2.recent_failures.has(k2)))
	_check("★★★P3(b)【反向】領到了 ⇒ 沒有失敗記憶", not team2.recent_failures.has(k2))
	# (c) 反向二：沒承諾領取（路過、在貿易）⇒ 落空也不記
	var ws3: WorldState = _mk_world()
	var p3: Array = _pick(ws3, true)
	var tile3: HexTileData = p3[0]
	var team3: TeamData = p3[1]
	_stage(team3, tile3, "貿易")
	SimRunner.new()._step3c_read_market_board(ws3, [team3.team_id])
	var k3: String = FailureMemory.key("領取", str(tile3.tile_id))
	print("   (c) 沒承諾領取：recent_failures 有那一筆 ＝ %s" % str(team3.recent_failures.has(k3)))
	_check("★★P3(c)【反向】沒承諾領取 ⇒ 落空不記", not team3.recent_failures.has(k3))
	_cells_ran.append("P3")


func _p4_non_claim_option_not_released() -> void:
	print("\n── P4 非領取的 option 帶 TRADE 抵達自家市集 ⇒ 照抵達規則放手（票 A2 改判）──")
	var ws: WorldState = _mk_world()
	var pick: Array = _pick(ws, true)
	if pick.is_empty():
		_check("★母體地板：找得到有主的市集格", false)
		_cells_ran.append("P4")
		return
	var tile: HexTileData = pick[0]
	var team: TeamData = pick[1]
	_stage(team, tile, "survival")   # ★Team40 的形狀：option 是 survival 標籤、task 是 TRADE、站在自家市集
	SimRunner.new()._step3c_read_market_board(ws, [team.team_id])
	print("   option＝survival、task＝TRADE 抵達自家市集之後 task ＝ %s" % str(team.current_task))
	_check("★★★P4 抵達即放手（task 不再是 TRADE；票 A2 之前這一格斷言的是相反）", team.current_task != TeamData.TASK_TRADE)
	_check("★★P4 也沒記落空（不是承諾領取）", not team.recent_failures.has(FailureMemory.key("領取", str(tile.tile_id))))
	_cells_ran.append("P4")
