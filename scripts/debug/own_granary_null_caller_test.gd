extends SceneTree
# T2 regression（own-granary-pin）：_attempt_barter 的 reserve 呼點漏傳 state → reserve 內 state=null default
# → need_keep(null)→_self_use(null,food)→effective_food(null)→own_granary_tile(null) 崩（day0.8 起、measurer day15）。
# 根修=呼點補傳 state（非 own_granary 頭加 guard）。本測坐實：①站家隊 effective_food 含糧倉 ②reserve(food,state)
# 不崩且 granary-aware ③_attempt_barter 端到端不崩（pre-fix 在此崩）。

var _fail := 0
func _ok(c: bool, m: String) -> void:
	if c: print("  PASS ", m)
	else: _fail += 1; print("  FAIL ", m)

func _init() -> void:
	print("=== own_granary null-caller T2 regression ===")
	var state := WorldState.new(); state.world = WorldData.new()
	# A 站自家 outpost tile，糧倉 food=100、私產 food=0（WS-1 定居隊糧在糧倉）
	var apos := Vector2i(5,5)
	var atile := HexTileData.new()
	atile.tile_id = apos.x*1000+apos.y; atile.tile_pos = apos; atile.terrain = "plains"
	atile.outpost_owner = 1; atile.outpost_level = 1
	atile.public_storage = {"food": 100.0}
	state.world.tiles[atile.tile_id] = atile
	# B 站空地（非自家 outpost）
	var bpos := Vector2i(6,5)
	var btile := HexTileData.new()
	btile.tile_id = bpos.x*1000+bpos.y; btile.tile_pos = bpos; btile.terrain = "plains"
	btile.outpost_owner = -1; btile.outpost_level = 0
	state.world.tiles[btile.tile_id] = btile

	var la := PersonData.new(); la.id = 10; la.values = {"貪婪": 0.5, "慎重": 0.5, "求生欲": 0.5}
	var lb := PersonData.new(); lb.id = 20; lb.values = {"貪婪": 0.5, "慎重": 0.5, "求生欲": 0.5}
	state.persons[10] = la; state.persons[20] = lb

	var a := TeamData.new(); a.team_id = 1; a.leader_id = 10; a.tile_pos = apos
	a.population = 5; a.resources = {"food": 0, "material": 50}
	var b := TeamData.new(); b.team_id = 2; b.leader_id = 20; b.tile_pos = bpos
	b.population = 5; b.resources = {"food": 50, "material": 0}
	state.teams[1] = a; state.teams[2] = b

	# ① 站家隊 effective_food 含糧倉（granary-aware、非只私產）
	_ok(ResourceSystem.effective_food(state, a) == 100.0, "effective_food 站家隊含糧倉=100（私產0+糧倉100）")

	# ② reserve(food, state) granary-aware 不崩（pre-fix：state=null default→own_granary(null)崩）
	var lv := TradeValuation.leader_vals(state, a)
	var r := TradeValuation.reserve(a, "food", lv, state)
	_ok(r > 0.0, "reserve(food,state) 不崩且 need_keep>0（granary-aware food need）")

	# ③ 端到端 _attempt_barter 不崩（pinned 根：:990/:997 呼點補傳 state；pre-fix 此處 own_granary(null)崩）
	var isys := InteractionSystem.new()
	isys._attempt_barter(state, a, b)   # 到此不崩=修復（崩則 SceneTree abort、永不到下行）
	_ok(true, "_attempt_barter 端到端不崩（reserve 呼點已補傳 state）")

	if _fail == 0: print("ALL PASS")
	else: print("FAILS=%d" % _fail)
	quit()
