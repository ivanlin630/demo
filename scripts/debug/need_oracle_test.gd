extends SceneTree

# Arc1 統一 need oracle TDD（feat/need-oracle）
# spec: docs/superpowers/specs/2026-07-16-arc1-unified-need-oracle.md
# S1：NeedOracle 骨架 + food 自用真推導；供應鏈(S2)/貿易(S3) fallback 舊常數。

var _fail: int = 0

func _initialize() -> void:
	_test_s1_food_self_use()
	_test_s1_fallback_and_demand()
	_test_s2_supply_chain_gating()
	_test_s2_gap_not_raw()
	_test_s3_trade_demand_nonghost()
	_test_s4_per_recipe_stop()
	if _fail == 0:
		print("=== DONE === ALL PASS")
	else:
		print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond: print("  [PASS] %s" % msg)
	else: _fail += 1; print("  [FAIL] %s" % msg)

func _mk_team(pop: int) -> TeamData:
	var t := TeamData.new(); t.team_id = 1; t.leader_id = 100
	for i in range(pop - 1): t.named_members.append(200 + i)
	return t

# ── S1：food 自用真推導（日耗×pop×人格安全天）──
func _test_s1_food_self_use() -> void:
	print("--- S1：food 自用推導（消耗率×pop×人格 buffer 天）---")
	var team := _mk_team(10)   # pop 10
	var neutral := {"慎重": 0.5, "野心": 0.5}
	var expected: float = ResourceSystem.FOOD_PER_PERSON_PER_DAY * 10.0 * DecisionTerms.food_security_target(neutral)
	var got: float = NeedOracle.need_keep(null, team, "food", neutral)
	_ok(absf(got - expected) < 0.001, "food need_keep(%.1f) = 日耗×pop×安全天(%.1f)" % [got, expected])
	# 人格化：慎重領袖 buffer 大 → food need_keep 高（存久）
	var cautious := {"慎重": 1.0, "野心": 0.0}
	var greedy := {"慎重": 0.0, "野心": 1.0}
	var nk_caution: float = NeedOracle.need_keep(null, team, "food", cautious)
	var nk_greedy: float = NeedOracle.need_keep(null, team, "food", greedy)
	_ok(nk_caution > nk_greedy, "★人格化：慎重領袖 food need_keep(%.1f) > 大膽領袖(%.1f)（buffer 大）" % [nk_caution, nk_greedy])

# ── goods=純貿易品 need_keep=0（#6）+ demand S3 前 fallback ──
func _test_s1_fallback_and_demand() -> void:
	print("--- goods 純貿易 need_keep=0 + demand fallback ---")
	var team := _mk_team(10)
	var lv := {"慎重": 0.5}
	# goods=純貿易品：無自用消費 sink（#6）、無下游供應鏈 → need_keep=0（方向正確，賣 min(holding,demand) 不死守）
	_ok(NeedOracle.need_keep(null, team, "goods", lv) == 0.0, "★goods need_keep=0（純貿易品，可賣餘量=holding）")
	# demand S3 前 fallback 0（reader 尚未切）
	_ok(NeedOracle.demand(null, team, "goods", lv) == 0.0, "demand(goods)=0（S3 前 fallback，reader 未切）")
	_ok(NeedOracle.demand(null, team, "food", lv) == 0.0, "demand(food)=0（S3 前 fallback）")

# state + team + 自家 outpost tile（可設 weaponsmith_level 等設施）。
func _mk_state_team_facility(pop: int, level_key: String, level: int) -> Array:   # → [state, team]
	var s := WorldState.new(); s.world = WorldData.new(); s.world.current_tick = 0
	var t := TeamData.new(); t.team_id = 1; t.leader_id = 100
	var ldr := PersonData.new(); ldr.id = 100; ldr.values = {"慎重": 0.5}; s.persons[100] = ldr
	for i in range(pop - 1): t.named_members.append(200 + i)
	t.tile_pos = Vector2i(0, 0)
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(0, 0)
	tile.outpost_level = 1; tile.outpost_owner = 1
	if level > 0: tile.set(level_key, level)
	s.world.tiles[0] = tile
	s.teams[1] = t
	return [s, t]

# ── S2：供應鏈傳導 + 設施 gating（有設施→中間品 need>0；無設施→0）──
func _test_s2_supply_chain_gating() -> void:
	print("--- S2：供應鏈傳導 + 設施 gating ---")
	# weaponsmith 隊、weapon holding=0 → material need_keep>0（被 weapon gap 拉）
	var w := _mk_state_team_facility(10, "weaponsmith_level", 1)
	var lv := {"慎重": 0.5}
	var mat_need: float = NeedOracle.need_keep(w[0], w[1], "material", lv)
	_ok(mat_need > 0.0, "★weaponsmith 隊 material need_keep(%.1f)>0（供應鏈傳導：weapon gap→原料）" % mat_need)
	var ore_need: float = NeedOracle.need_keep(w[0], w[1], "ore_iron", lv)
	_ok(ore_need > 0.0, "ore_iron need_keep(%.1f)>0（weapon 消耗 ore_iron）" % ore_need)
	# 無設施隊 → 供應鏈=0（gating），純中間品 need_keep=0
	var n := _mk_state_team_facility(10, "weaponsmith_level", 0)
	_ok(NeedOracle.need_keep(n[0], n[1], "material", lv) == 0.0, "★無製造設施→material need_keep=0（設施 gating，不背供應鏈）")
	_ok(NeedOracle._self_use(n[1], "gem", lv) == 0.0, "純中間品 gem 自用=0（need 全走供應鏈）")

# ── S2：gap 非 raw（下游成品已滿→不囤原料）──
func _test_s2_gap_not_raw() -> void:
	print("--- S2：gap 非 raw（成品滿→不囤原料）---")
	var w := _mk_state_team_facility(10, "weaponsmith_level", 1)
	var lv := {"慎重": 0.5}
	# 灌滿所有 weapon holding（遠超 need_keep）→ gap=0 → material 供應鏈=0
	for wp in ["weapon_melee_low", "weapon_ranged_low", "weapon_melee_high", "weapon_ranged_high"]:
		w[1].resources[wp] = 9999.0
	var mat_need: float = NeedOracle.need_keep(w[0], w[1], "material", lv)
	_ok(mat_need == 0.0, "★成品(weapon)已滿→material need_keep=0（gap 非 raw，不囤爆原料）")

func _mk_buy_msg(res: String, qty: int, origin: int, expire: int) -> MessageData:
	var m := MessageData.new(); m.type = "order_buy"
	m.params = {"res": res, "qty": qty, "origin_team": origin, "expire_tick": expire}
	return m

# ── S3：貿易 demand 非幽靈視圖（過期買單不供產）+ 野心秤 ──
func _test_s3_trade_demand_nonghost() -> void:
	print("--- S3：貿易 demand 非幽靈（過期濾）+ 野心 ---")
	var s := WorldState.new(); s.world = WorldData.new(); s.world.current_tick = 100
	var team := _mk_team(10)
	s.team_known[1] = [
		_mk_buy_msg("goods", 40, 5, 200),   # 有效（expire 200 > tick 100）
		_mk_buy_msg("goods", 30, 5, 50),    # ★過期（expire 50 <= 100）→ 非幽靈濾除
	]
	var lv_amb := {"野心": 0.5}
	var d: float = NeedOracle.demand(s, team, "goods", lv_amb)
	# 只算有效單 40，野心 0.5 秤(0.5+0.5=1.0) → 40
	_ok(absf(d - 40.0) < 0.001, "★demand(goods)=40（有效單40，過期單30 非幽靈濾除）實際=%.1f" % d)
	# 野心高 → demand 大（致富綁 deal）
	var d_hi: float = NeedOracle.demand(s, team, "goods", {"野心": 1.0})
	_ok(d_hi > d, "★野心高 demand(%.1f) > 中性(%.1f)（致富野心秤）" % [d_hi, d])
	# 全過期 → demand=0
	s.team_known[1] = [_mk_buy_msg("goods", 30, 5, 50)]
	_ok(NeedOracle.demand(s, team, "goods", lv_amb) == 0.0, "全過期買單→demand=0（幽靈不供產）")

# ── S4：per-recipe 停產（goods 有 demand→產；goods 滿→停該 recipe，不燒 material）──
func _test_s4_per_recipe_stop() -> void:
	print("--- S4：per-recipe 停產（reader 切 oracle）---")
	var w := _mk_state_team_facility(10, "manufacturing_level", 1)   # workshop
	w[0].world.current_tick = 100
	w[1].resources = {"material": 100.0, "goods": 0.0, "gem": 0.0}
	w[0].team_known[1] = [_mk_buy_msg("goods", 40, 5, 200)]   # goods demand 40（有效）
	var mfg := ManufacturingSystem.new()
	var mat0: float = float(w[1].resources.get("material", 0))
	# goods 有 demand + holding 0 → 產 goods（消耗 material）
	var ran: String = mfg._run_recipe_group(w[0], w[1], w[0].world.tiles[0], "manufacturing_level", 1.0)
	_ok(ran == "goods", "★goods 有 demand→產 goods（reader 切 oracle need+demand，實際=%s）" % ran)
	_ok(float(w[1].resources.get("material", 0)) < mat0, "產 goods 消耗 material（%.1f→%.1f）" % [mat0, float(w[1].resources.get("material", 0))])
	# goods 灌滿（≥demand）+ 無其他 need（tools/arrows self_use 也要考量）→ 至少 goods 該停
	# 用純 goods 場景：holding 遠超 demand → goods recipe 被 per-recipe stop 跳過
	w[1].resources = {"material": 100.0, "goods": 9999.0}
	w[0].team_known[1] = [_mk_buy_msg("goods", 40, 5, 200)]
	# goods 滿 → 不再產 goods（可能產 tools/arrows 因 terminal self_use，但 goods 這條 recipe stop）
	var ran2: String = mfg._run_recipe_group(w[0], w[1], w[0].world.tiles[0], "manufacturing_level", 1.0)
	_ok(ran2 != "goods", "★goods 滿→per-recipe 停產 goods（不燒 material 囤爆，實際=%s）" % ran2)
