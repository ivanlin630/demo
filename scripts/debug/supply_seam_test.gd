extends SceneTree

# 供給 seam 統一 accessor TDD（slice: supply-seam-effective-holding）
# spec: docs/superpowers/specs/2026-07-15-supply-seam-effective-holding.md
# effective_holding=team.resources+自家糧倉；spend_holding 守恆扣(先糧倉餘私產,不透支);settle 不賣幽靈貨。

var _fail: int = 0

func _initialize() -> void:
	_test_effective_holding()
	_test_spend_holding_conservation()
	_test_spend_holding_no_overdraft()
	_test_execute_transfer_conservation()
	if _fail == 0:
		print("=== DONE === ALL PASS")
	else:
		print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond: print("  [PASS] %s" % msg)
	else: _fail += 1; print("  [FAIL] %s" % msg)

# 定居隊 @ 自家 outpost(0,0)，糧倉 public_storage + team.resources。
func _mk(store: Dictionary, res_team: Dictionary) -> Array:   # → [state, team, tile]
	var state := WorldState.new(); state.world = WorldData.new()
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(0, 0); tile.terrain = "plains"
	tile.outpost_level = 1; tile.outpost_owner = 1; tile.public_storage = store.duplicate()
	state.world.tiles[0] = tile
	var team := TeamData.new(); team.team_id = 1; team.tile_pos = Vector2i(0, 0)
	team.resources = res_team.duplicate()
	state.teams[1] = team
	return [state, team, tile]

func _test_effective_holding() -> void:
	print("--- effective_holding = team.resources + 自家糧倉 ---")
	var w := _mk({"goods": 100.0}, {"goods": 30.0})
	_ok(ResourceSystem.effective_holding(w[0], w[1], "goods") == 130.0,
		"goods 30(私)+100(倉)=130，實際=%.0f" % ResourceSystem.effective_holding(w[0], w[1], "goods"))
	# 無自家 outpost（team 不在 outpost 上）→ 只私產
	var w2 := _mk({"material": 500.0}, {"material": 20.0})
	w2[1].tile_pos = Vector2i(5, 5)   # 離開 outpost → own_granary_tile 回 null
	_ok(ResourceSystem.effective_holding(w2[0], w2[1], "material") == 20.0,
		"離 outpost → 只私產 20（不含倉），實際=%.0f" % ResourceSystem.effective_holding(w2[0], w2[1], "material"))

func _test_spend_holding_conservation() -> void:
	print("--- spend_holding：先扣糧倉餘扣私產（守恆）---")
	var w := _mk({"goods": 100.0}, {"goods": 30.0})
	# 扣 50 → 糧倉 100→50，私產不動
	var s1: float = ResourceSystem.spend_holding(w[0], w[1], "goods", 50.0)
	_ok(s1 == 50.0 and float(w[2].public_storage.get("goods", 0)) == 50.0 and float(w[1].resources.get("goods", 0)) == 30.0,
		"扣50→糧倉 100→50、私產留 30、回 50")
	# 再扣 60 → 糧倉 50→0(扣50)、私產 30→20(扣10)、回 60
	var s2: float = ResourceSystem.spend_holding(w[0], w[1], "goods", 60.0)
	_ok(s2 == 60.0 and float(w[2].public_storage.get("goods", 0)) == 0.0 and float(w[1].resources.get("goods", 0)) == 20.0,
		"扣60→糧倉→0、私產 30→20、回 60（跨兩源守恆）")

func _test_spend_holding_no_overdraft() -> void:
	print("--- spend_holding：不透支（回實際扣量）---")
	var w := _mk({"material": 40.0}, {"material": 10.0})   # 共 50
	var s: float = ResourceSystem.spend_holding(w[0], w[1], "material", 200.0)   # 求 200 但只 50
	_ok(s == 50.0 and float(w[2].public_storage.get("material", 0)) == 0.0 and float(w[1].resources.get("material", 0)) == 0.0,
		"求 200 只有 50 → 回實際 50、庫存扣光不透支，實際回=%.0f" % s)

func _test_execute_transfer_conservation() -> void:
	print("--- _execute_transfer：seller 從糧倉出貨守恆（不賣幽靈貨）---")
	var w := _mk({"goods": 100.0}, {"goods": 0.0, "coin": 0.0})   # seller 貨在糧倉
	var seller: TeamData = w[1]
	var buyer := TeamData.new(); buyer.team_id = 2; buyer.tile_pos = Vector2i(0, 0)
	buyer.resources = {"goods": 0.0, "coin": 1000.0}
	w[0].teams[2] = buyer
	var goods_before: float = float(w[2].public_storage.get("goods", 0)) + float(seller.resources.get("goods", 0)) + float(buyer.resources.get("goods", 0))
	InteractionSystem.new()._execute_transfer(w[0], seller, buyer, "goods", 50, 2.0)
	var goods_after: float = float(w[2].public_storage.get("goods", 0)) + float(seller.resources.get("goods", 0)) + float(buyer.resources.get("goods", 0))
	_ok(float(w[2].public_storage.get("goods", 0)) == 50.0, "seller 糧倉 100→50（貨從 storage 出）")
	_ok(float(buyer.resources.get("goods", 0)) == 50.0, "buyer 收 50 進私產")
	_ok(goods_before == goods_after and goods_after == 100.0, "goods 守恆（總量 100 不變，非憑空/幽靈），before=%.0f after=%.0f" % [goods_before, goods_after])
	_ok(float(buyer.resources.get("coin", 0)) == 900.0 and float(seller.resources.get("coin", 0)) == 100.0, "coin 對流（buyer -100/seller +100）")
