extends SceneTree

# extraction de-patch need-driven TDD（spec 2026-07-23-extraction-need-driven-depatch）。
# 根:_consider_extraction flat `greed-prud×0.5>0.4` 死常數+不讀 need→中位領袖永不 extract→
# salary coin 鎖 anon_treasury 取不回→spendable 低→has_specie=false→買不起→脫貧鏈斷。
# de-patch:①coin_need 信號(material-buy+food-buy means-end)②need-driven extract(砍 flat gate)
#   ③persona buffer texture(慎重厚/貪婪薄,★下限>0 非清空)。

var _fail: int = 0

func _initialize() -> void:
	_test_mid_leader_extracts()   # ①中位領袖(greed.5/prud.5)+coin_need>spendable→extract(原永不)
	_test_no_need_no_extract()    # ②無 coin_need(食足無 buy-intent)→不 extract(不亂徵)
	_test_persona_buffer()        # ★③慎重 buffer>貪婪 + greed=1.0 buffer>0(絕對>0 測真清空反例)
	_test_shortfall_nonpos()      # ④shortfall≤0(spendable 已夠)→不 extract
	_test_conservation()          # ⑤守恆(anon_treasury→team.coin 搬,總和不變)
	_test_emergency_intact()      # ⑥emergency 路徑不變(is_emergency 低 penalty 分支完好)
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

# team + leader(greed/prud)+ anon_treasury + coin + food。無 outpost(construction material need=0)。
func _mk(greed: float, prud: float, treasury: float, coin: float, food: float) -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	for x in range(3, 8):
		for y in range(3, 8):
			var tl := HexTileData.new(); tl.tile_pos = Vector2i(x, y); tl.terrain = "plains"
			state.world.tiles[x * 1000 + y] = tl
	state.player_id = -999   # 非玩家
	var team := TeamData.new(); team.team_id = 1; team.tile_pos = Vector2i(5, 5); team.faction_id = 5
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", 10)   # pop 10 → burn 8/day
	team.anon_treasury = treasury
	team.resources["coin"] = coin
	team.resources["food"] = food
	var l := PersonData.new(); l.id = 10; l.values = {"貪婪": greed, "慎重": prud}; l.skills = {}
	state.persons[10] = l; team.leader_id = 10
	state.teams[1] = team
	return [state, team]

# ① 中位領袖 + coin_need>spendable（食壓 food=0）→ extract 觸發（原 flat gate 永不）
func _test_mid_leader_extracts() -> void:
	print("--- ①中位領袖 need-driven extract ---")
	var w: Array = _mk(0.5, 0.5, 100.0, 0.0, 0.0)   # 中位人格 + 食壓(food 0) + coin 0
	var fai := FactionAISystem.new()
	var need: float = CoinTreasury.coin_need(w[0], w[1])
	CoinTreasury.consider_extraction(w[0], w[1])
	var coin_after: float = float(w[1].resources.get("coin", 0))
	_ok(need > 0.0, "食壓 → coin_need>0（means-end food-buy，got %.0f）" % need)
	_ok(coin_after > 0.0 and w[1].anon_treasury < 100.0, "中位領袖(greed.5/prud.5)有真需 → extract 取回 coin（原 flat 0.4 永不，coin %.0f treasury %.0f）" % [coin_after, w[1].anon_treasury])

# ② 無 coin_need（食足 + 無 outpost 無建設 need）→ 不 extract
func _test_no_need_no_extract() -> void:
	print("--- ②無 need→不 extract ---")
	var w: Array = _mk(0.5, 0.5, 100.0, 0.0, 1000.0)   # food 充足(food_days 遠>DESPERATION)、無 outpost
	var fai := FactionAISystem.new()
	_ok(is_equal_approx(CoinTreasury.coin_need(w[0], w[1]), 0.0), "食足無建設 → coin_need=0")
	CoinTreasury.consider_extraction(w[0], w[1])
	_ok(float(w[1].resources.get("coin", 0)) == 0.0 and is_equal_approx(w[1].anon_treasury, 100.0), "無 need → 不 extract（treasury 100 不動，不亂徵）")

# ★③ persona buffer：慎重 buffer > 貪婪 + 即使 greed=1.0(慎重 0) buffer > 0（測真清空反例）
func _test_persona_buffer() -> void:
	print("--- ★③persona buffer texture ---")
	var fai := FactionAISystem.new()
	var prudent := PersonData.new(); prudent.values = {"貪婪": 0.0, "慎重": 1.0}
	var greedy := PersonData.new(); greedy.values = {"貪婪": 1.0, "慎重": 0.0}
	var bp: float = CoinTreasury.extract_buffer(prudent)
	var bg: float = CoinTreasury.extract_buffer(greedy)
	_ok(bp > bg, "慎重 leader buffer(%.0f) > 貪婪 leader buffer(%.0f)（texture）" % [bp, bg])
	_ok(bg > 0.0, "★即使最貪婪 leader(greed 1.0/慎重 0) buffer=%.0f > 0（下限守護=非清空 treasury，真清空反例）" % bg)

# ④ shortfall≤0（spendable coin 已夠）→ 不 extract
func _test_shortfall_nonpos() -> void:
	print("--- ④shortfall≤0→不 extract ---")
	var w: Array = _mk(0.5, 0.5, 100.0, 1000.0, 0.0)   # 食壓有 need 但 coin 1000 已夠
	var fai := FactionAISystem.new()
	var need: float = CoinTreasury.coin_need(w[0], w[1])
	CoinTreasury.consider_extraction(w[0], w[1])
	_ok(need < 1000.0 and is_equal_approx(w[1].anon_treasury, 100.0), "spendable 1000≥coin_need %.0f → shortfall≤0 → 不 extract（treasury 不動）" % need)

# ⑤ 守恆：extract 前後 (team.coin + anon_treasury) 總和不變
func _test_conservation() -> void:
	print("--- ⑤守恆 ---")
	var w: Array = _mk(0.5, 0.5, 100.0, 0.0, 0.0)   # 食壓 → 會 extract
	var before: float = float(w[1].resources.get("coin", 0)) + w[1].anon_treasury
	CoinTreasury.consider_extraction(w[0], w[1])
	var after: float = float(w[1].resources.get("coin", 0)) + w[1].anon_treasury
	_ok(is_equal_approx(before, after), "coin+treasury 前 %.1f == 後 %.1f（anon_treasury→team.coin 池間搬，守恆）" % [before, after])

# ⑥ emergency 路徑不變：_extract_treasury("飢餓緊急") 走 is_emergency 低 penalty 分支（未被 de-patch 動）
func _test_emergency_intact() -> void:
	print("--- ⑥emergency 路徑不變 ---")
	# 兩隊同額 extract，一 emergency 一 need_driven，比 leader stress penalty（emergency 0.05 < 非 0.15）。
	var we: Array = _mk(0.5, 0.5, 100.0, 0.0, 0.0)
	var wn: Array = _mk(0.5, 0.5, 100.0, 0.0, 0.0)
	var fai := FactionAISystem.new()
	CoinTreasury.extract_treasury(we[0], we[1], 0.5, "飢餓緊急")
	CoinTreasury.extract_treasury(wn[0], wn[1], 0.5, "need_driven")
	var stress_e: float = we[0].persons[10].stress
	var stress_n: float = wn[0].persons[10].stress
	_ok(stress_e < stress_n, "emergency stress penalty(%.3f) < 非 emergency(%.3f)（is_emergency 分支完好，de-patch 未動）" % [stress_e, stress_n])
