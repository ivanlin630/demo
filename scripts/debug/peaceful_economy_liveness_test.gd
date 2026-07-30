extends SceneTree

# @observe-pure  ★observer-no-global-RNG 靜態閘納管（純觀測零 RNG；違=FAIL）
# ──────────────────────────────────────────────────────────────────────────
# 和平經濟床 TDD — fixture-liveness 機械防死 fixture（HOW spec 2026-07-30 §7）。
# ★t0 斷言（R² 教訓）：每 ①隊/③料窮側 NeedOracle.need_keep(material)>0（因果活，非 material≈0 但 need≡0 死路）
#   + ①隊有 unowned forest tile 在 SEEK_TILE_RANGE 內（founding 靶存在）。否則 FAIL 拒開工。
# + config 載入 sanity（GameSetup.setup 無錯、~12 隊、有 unowned forest tile）。
# 純讀+斷言、零 RNG、零 sim 改。

const CONFIG_PATH := "res://config/peaceful_economy.json"
# ①founding（缺料傍林 established）+ ③料窮側 = material need>0 LIVE 案（need_keep(material) 因果活）。
const MATERIAL_LIVE_TEAMS: Array = [0, 1, 2, 6]
# ①founding 隊須有 unowned forest 靶在 seek 內。
const FOUNDING_TEAMS: Array = [0, 1, 2]

var _fail: int = 0

func _initialize() -> void:
	var state := WorldState.new()
	var config: Dictionary = GameSetup.load_config(CONFIG_PATH)
	if config.is_empty():
		_bad("config 載入失敗（%s 不存在/解析錯）" % CONFIG_PATH)
		_done(); return
	config["seed"] = int(config.get("seed", 70730))
	GameSetup.setup(state, config)

	# sanity：~12 隊
	if state.teams.size() < 10:
		_bad("隊數 %d < 10（explicit fixture 建置疑失敗）" % state.teams.size())
	else:
		_ok("config 載入 + setup：%d 隊" % state.teams.size())

	# sanity：地圖有 unowned forest tile（founding 靶母體）
	var total_unowned_forest: int = 0
	for tid in state.world.tiles:
		var t: HexTileData = state.world.tiles[tid]
		if t.terrain == "forest" and t.outpost_owner == -1:
			total_unowned_forest += 1
	if total_unowned_forest <= 0:
		_bad("全圖無 unowned forest tile（founding 靶母體空；調 seed/richness）")
	else:
		_ok("全圖 unowned forest tile=%d" % total_unowned_forest)

	# ★t0 liveness：material need>0（因果活）
	var fai := FactionAISystem.new()
	for tid in MATERIAL_LIVE_TEAMS:
		var team: TeamData = state.teams.get(tid)
		if team == null:
			_bad("LIVE 隊 T%d 不存在" % tid); continue
		var lv: Dictionary = TradeValuation.leader_vals(state, team)
		var need: float = NeedOracle.need_keep(state, team, "material", lv)
		var hold: float = float(team.resources.get("material", 0.0))
		var own: Vector2i = fai._find_own_outpost(state, team)
		if need > 0.0:
			_ok("T%d need_keep(material)=%.1f>0 (hold=%.0f own_outpost=%s) LIVE" % [tid, need, hold, str(own)])
		else:
			_bad("T%d need_keep(material)=0 = 因果死路（material≈0 但 need≡0；outpost=%s；apothecary/farming deficit<DESIRE_MIN?）拒開工" % [tid, str(own)])

	# ★①founding 隊 unowned forest 靶在 SEEK_TILE_RANGE 內、非腳下
	for tid in FOUNDING_TEAMS:
		var team: TeamData = state.teams.get(tid)
		if team == null: continue
		var found: bool = false
		for wtid in state.world.tiles:
			var t: HexTileData = state.world.tiles[wtid]
			if t.terrain != "forest" or t.outpost_owner != -1:
				continue
			if t.tile_pos == team.tile_pos:
				continue
			if fai._hex_dist(team.tile_pos, t.tile_pos) <= GoalResolver.SEEK_TILE_RANGE:
				found = true; break
		if found:
			_ok("T%d 有 unowned forest 靶在 SEEK_TILE_RANGE(%d) 內" % [tid, GoalResolver.SEEK_TILE_RANGE])
		else:
			_bad("T%d 無 unowned forest 靶在 seek 內 = founding 因果死路 拒開工" % tid)

	_done()

func _ok(msg: String) -> void:
	print("  [PASS] " + msg)

func _bad(msg: String) -> void:
	_fail += 1
	print("  [FAIL] " + msg)

func _done() -> void:
	if _fail == 0:
		print("=== DONE === ALL PASS（fixture LIVE，可開工）")
	else:
		print("=== DONE === %d FAIL（fixture 死路，拒開工）" % _fail)
	quit()
