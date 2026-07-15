extends SceneTree

# 市場成交條件液化 TDD（slice: market-liquidize，經濟 revive ①刀）
# spec: docs/superpowers/specs/2026-07-15-market-liquidize-deal-conditions.md
# Fix1 reserve 非活命品液化+人格化(貪婪守/絕境鬆手)，★SURVIVAL_GOODS(food/medicine)保 floor 不液化。
# Fix2 ask/bid 液化：折扣人格化(急鬆手/貪守價)，willing 對閉合邊際價差→成交；貪婪守價→部分談崩(摩擦)。
# 守恆：成交走既有 _execute_transfer(coin↔goods 等值)。

var _fail: int = 0

func _initialize() -> void:
	_test_reserve_personalized()
	_test_survival_goods_floor()
	_test_ask_bid_liquidize()
	_test_conservation()
	if _fail == 0:
		print("=== DONE === ALL PASS")
	else:
		print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond: print("  [PASS] %s" % msg)
	else: _fail += 1; print("  [FAIL] %s" % msg)

# team + leader(人格) + pop（named_members 湊數）+ 指定 resources。
func _mk(leader_vals: Dictionary, res: Dictionary, pop: int = 10, commerce: float = 0.0) -> Array:   # → [state, team]
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 0
	var team := TeamData.new(); team.team_id = 1
	team.resources = res.duplicate()
	var ldr := PersonData.new(); ldr.id = 100; ldr.values = leader_vals; ldr.skills = {"商業": commerce}
	state.persons[100] = ldr; team.leader_id = 100
	for i in range(pop - 1):   # +leader = pop
		team.named_members.append(200 + i)
	state.teams[1] = team
	return [state, team]

# ── Fix1：非活命品 reserve 人格化液化 ──
func _test_reserve_personalized() -> void:
	print("--- Fix1 reserve 人格化：貪婪守貨(高) vs 絕境鬆手(低) ---")
	# 貪婪非絕境（食足幣足→urgency 0）
	var wg := _mk({"貪婪": 0.9, "慎重": 0.9}, {"food": 40.0, "coin": 200.0})
	var rg: float = TradeValuation.reserve(wg[1], "material", TradeValuation.leader_vals(wg[0], wg[1]))
	# 絕境（斷糧缺幣→urgency 1）
	var wd := _mk({"貪婪": 0.3, "慎重": 0.3}, {"food": 0.0, "coin": 0.0})
	var rd: float = TradeValuation.reserve(wd[1], "material", TradeValuation.leader_vals(wd[0], wd[1]))
	_ok(rg > rd, "貪婪非絕境 reserve(%.1f) > 絕境 reserve(%.1f)（守貨 vs 鬆手）" % [rg, rd])
	# 降底：絕境非活命品 reserve < flat 舊值(pop×TARGET)＝流動為底
	var flat: float = 10.0 * float(TradeValuation.TARGET_PER_POP["material"])
	_ok(rd < flat, "絕境 reserve(%.1f) < flat 舊值(%.1f)（液化降底→願賣方變多）" % [rd, flat])

# ── Fix1 R²：SURVIVAL_GOODS(food/medicine)保 floor，絕境不甩活命糧 ──
func _test_survival_goods_floor() -> void:
	print("--- Fix1 R²：活命糧 floor（絕境 medicine/food 不液化甩光）---")
	var wd := _mk({"貪婪": 0.3, "慎重": 0.3}, {"food": 0.0, "coin": 0.0})   # 絕境
	var lv: Dictionary = TradeValuation.leader_vals(wd[0], wd[1])
	# medicine：保 flat survival floor（= pop×TARGET，不隨 urgency 降）
	var med_floor: float = 10.0 * float(TradeValuation.TARGET_PER_POP["medicine"])
	var r_med: float = TradeValuation.reserve(wd[1], "medicine", lv)
	_ok(absf(r_med - med_floor) < 0.001, "★絕境 medicine reserve(%.1f) == survival floor(%.1f)（不液化）" % [r_med, med_floor])
	# 對比：同絕境下非活命品(material)被液化降底，medicine 未降 → 保護成立
	var r_mat: float = TradeValuation.reserve(wd[1], "material", lv)
	_ok(r_med > r_mat, "★medicine reserve(%.1f) > material reserve(%.1f)（活命糧受保、非活命品液化）" % [r_med, r_mat])
	# food：保人格 survival floor（既有分支，>0 不因絕境歸零）
	var r_food: float = TradeValuation.reserve(wd[1], "food", lv)
	_ok(r_food > 0.0, "絕境 food reserve(%.1f) > 0（survival floor 保）" % r_food)

# ── Fix2：ask/bid 液化——willing 對成交，貪婪守價談崩(摩擦) ──
func _test_ask_bid_liquidize() -> void:
	print("--- Fix2 ask/bid 液化：絕境賣方成交 vs 貪婪守價談崩 ---")
	var iact := InteractionSystem.new()
	# 貪婪非絕境賣方：守價(折扣~0)→ ask 貼 seller value > 邊際 bid → 談崩(摩擦質感)
	var sg := _mk({"貪婪": 0.9, "慎重": 0.9}, {"material": 42.0, "food": 40.0, "coin": 200.0})
	var bg := _mk({}, {"material": 45.0, "coin": 1000.0})
	var bg_coin0: float = float(bg[1].resources.get("coin", 0))
	iact._attempt_trade_direction(sg[0], sg[1], bg[1])
	_ok(absf(float(bg[1].resources.get("coin", 0)) - bg_coin0) < 0.001, "貪婪守價 → 邊際 willing 對談崩（buyer coin 不變）")
	# 絕境賣方：鬆手(折扣深)→ ask 遠低 bid → 成交
	var sd := _mk({"貪婪": 0.3, "慎重": 0.3}, {"material": 42.0, "food": 0.0, "coin": 0.0})
	var bd := _mk({}, {"material": 45.0, "coin": 1000.0})
	var bd_coin0: float = float(bd[1].resources.get("coin", 0))
	iact._attempt_trade_direction(sd[0], sd[1], bd[1])
	_ok(float(bd[1].resources.get("coin", 0)) < bd_coin0, "絕境鬆手 → willing 對成交（buyer coin 降）")

# ── 守恆：成交總 coin/goods 不生不滅 ──
func _test_conservation() -> void:
	print("--- 守恆：成交 coin↔goods 等值搬（總量不變）---")
	var iact := InteractionSystem.new()
	var sd := _mk({"貪婪": 0.3, "慎重": 0.3}, {"material": 42.0, "food": 0.0, "coin": 0.0})
	var bd := _mk({}, {"material": 45.0, "coin": 1000.0})
	var s: TeamData = sd[1]; var b: TeamData = bd[1]
	var coin0: float = float(s.resources.get("coin", 0)) + float(b.resources.get("coin", 0))
	var mat0: float = float(s.resources.get("material", 0)) + float(b.resources.get("material", 0))
	iact._attempt_trade_direction(sd[0], s, b)
	var coin1: float = float(s.resources.get("coin", 0)) + float(b.resources.get("coin", 0))
	var mat1: float = float(s.resources.get("material", 0)) + float(b.resources.get("material", 0))
	_ok(absf(coin1 - coin0) < 0.001, "★總 coin 守恆（%.2f→%.2f）" % [coin0, coin1])
	_ok(absf(mat1 - mat0) < 0.001, "★總 material 守恆（%.2f→%.2f）" % [mat0, mat1])
