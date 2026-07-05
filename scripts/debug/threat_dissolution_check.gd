extends SceneTree

# ★ 序1 threat 融合驗（核心交付）。融合非刪雙關：
#   5a repertoire：4 人格原型各由對應反應達成（FLEE/DEFEND/PREPARE/求和 皆可觸）+ 居民守衛（居民不可迎戰）。
#   5b 率表：seeded warring 威脅反應 dispatch 率 > 0（該出現還出現，不被新權衡默默吃）。
#   Task7 unified：unified 隊遇威脅時 threat option 在主 rank 競爭得動（不被日常決策完全壓過）。
# 任一破 = 融合失敗。

var _fails: int = 0

func _initialize() -> void:
	_check_repertoire()
	_check_resident_guard()
	_check_unified_path()
	_check_rate_table()
	if _fails == 0:
		print("[threat-dissolution] ALL PASS")
	else:
		print("[threat-dissolution] FAIL count=%d" % _fails)
	quit()

# ── 5a repertoire：手構 ctx（deterministic，繞世界 setup）→ rank_threat[0] == 預期 ──
# moderate threat_react=0.8（> 全原型 threshold）：4 原型秤 argmax 落各自反應（見 commit 註公式）。
func _mk_ctx(vals: Dictionary) -> DecisionContext:
	var c := DecisionContext.new()
	c.leader_values = vals
	c.threat_react = 0.8
	c.threat_threshold = ThreatAssessment.THREAT_BASE_THRESHOLD + float(vals.get("慎重", 0.5)) * 0.3
	c.threat_id = 1
	c.threat_pos = Vector2i(2, 0)
	c.is_resident = false
	return c

func _expect_first(label: String, vals: Dictionary, expected: String) -> void:
	var ranked: Array = DecisionEngine.rank_threat(_mk_ctx(vals))
	var got: String = ranked[0] if not ranked.is_empty() else "<空>"
	if got != expected:
		_fails += 1
		print("[FAIL] 原型%s 預期 %s 得 %s (ranked=%s)" % [label, expected, got, str(ranked)])
	else:
		print("[repertoire] 原型%s → %s OK" % [label, got])

func _check_repertoire() -> void:
	print("--- 5a repertoire (4 原型) ---")
	# 求生欲高 → survival(FLEE=逃跑)
	_expect_first("FLEE", {"求生欲": 0.9, "好戰": 0.1, "慎重": 0.5, "貪婪": 0.5, "信義": 0.5}, "survival")
	# 好戰高+非居民 → 迎戰(DEFEND)
	_expect_first("DEFEND", {"求生欲": 0.3, "好戰": 0.9, "慎重": 0.2, "貪婪": 0.5, "信義": 0.5}, "迎戰")
	# 慎重高 → 備戰(PREPARE)
	_expect_first("PREPARE", {"求生欲": 0.4, "好戰": 0.4, "慎重": 0.9, "貪婪": 0.5, "信義": 0.5}, "備戰")
	# 貪婪+信義高+好戰低 → 求和(pacify)
	_expect_first("PACIFY", {"求生欲": 0.5, "好戰": 0.1, "慎重": 0.5, "貪婪": 0.8, "信義": 0.7}, "求和")

# ── 居民守衛：好戰居民隊 → 迎戰 不在 applicable（鏡射舊 is_resident 排除）──
func _check_resident_guard() -> void:
	print("--- 5a 居民守衛 ---")
	var c := _mk_ctx({"求生欲": 0.3, "好戰": 0.9, "慎重": 0.2, "貪婪": 0.5, "信義": 0.5})
	c.is_resident = true
	var appl: Array = DecisionOptions.applicable(c)
	if "迎戰" in appl:
		_fails += 1
		print("[FAIL] 居民守衛：好戰居民 迎戰 仍 applicable (%s)" % str(appl))
	else:
		# 備戰/求和 仍可（居民只是不能迎戰）
		var ranked: Array = DecisionEngine.rank_threat(c)
		print("[repertoire] 居民守衛 OK (迎戰 排除，居民 ranked=%s)" % str(ranked))

# ── Task7 unified：MERCHANT 健康隊遇威脅 → threat option 在主 rank 競爭得動 ──
func _check_unified_path() -> void:
	print("--- Task7 unified threat 主 rank ---")
	var state := WorldState.new(); state.world = WorldData.new()
	# 健康 merchant（food 足 → survival 絕境不壓 rank，看 threat 能否浮現）+ 好戰 leader
	var tid := 800
	var t := TeamData.new(); t.team_id = tid; t.tags = [TeamData.TAG_MERCHANT]
	t.tile_pos = Vector2i(5, 5); t.leader_id = tid * 10
	AnonTierSystem.add_anon(t, "平民", 10)
	t.resources = {"food": 300.0}   # 健康（food_days 高）
	state.teams[tid] = t
	state.team_discovered[tid] = []
	state.team_intel[tid] = {}
	var ldr := PersonData.new(); ldr.id = tid * 10; ldr.team_id = tid
	ldr.values = {"好戰": 0.8, "慎重": 0.5, "求生欲": 0.5, "貪婪": 0.5, "信義": 0.5}
	state.persons[ldr.id] = ldr
	_place_plains(state, Vector2i(5, 5))
	# 敵隊：逼近（last_tile 朝我）+ 敵意 rep + 同等實力（moderate threat，非碾壓）
	var etid := 801
	var e := TeamData.new(); e.team_id = etid; e.tile_pos = Vector2i(7, 5); e.faction_id = -1
	e.last_tile_pos = Vector2i(8, 5)   # 8→7 朝我(5,5)逼近
	AnonTierSystem.add_anon(e, "平民", 12)
	state.teams[etid] = e
	_place_plains(state, Vector2i(7, 5))
	t.known_reputations[etid] = 0.1   # 敵意
	state.team_discovered[tid].append(etid)
	BeliefSystem.record_claim(state, tid, etid, etid, "親見", {"population_est": 12}, 1.0, false)

	var ctx := DecisionContext.gather(state, t)
	var ranked: Array = DecisionEngine.rank_scored(state, t)
	var opts: Array = []
	for e2 in ranked: opts.append(e2["opt"])
	var threat_opts := ["備戰", "迎戰", "求和", "survival"]
	var surfaced: Array = []
	for o in threat_opts:
		if o in opts: surfaced.append(o)
	print("[unified] threat_react=%.2f food_days=%.2f ranked=%s" % [ctx.threat_react, ctx.food_days, str(opts)])
	if surfaced.is_empty():
		_fails += 1
		print("[FAIL] unified 隊遇威脅無 threat option 進主 rank（該出現沒出現）")
	else:
		print("[unified] threat option 浮現主 rank OK: %s" % str(surfaced))

# ── 5b 率表：seeded warring → threat dispatch 率 > 0（Probe.threat.dispatch.*）──
func _check_rate_table() -> void:
	print("--- 5b 率表 (seeded warring 1200t) ---")
	WarringHarness.run(1337, 1200)   # 內部 Probe.enabled，跑完 counts 保留（下次 run 才 reset）
	var flee: int = int(Probe.counts.get("threat.dispatch.survival", 0))
	var prepare: int = int(Probe.counts.get("threat.dispatch.備戰", 0))
	var defend: int = int(Probe.counts.get("threat.dispatch.迎戰", 0))
	var pacify: int = int(Probe.counts.get("threat.dispatch.求和", 0))
	var total: int = flee + prepare + defend + pacify
	print("[rate] flee=%d prepare=%d defend=%d pacify=%d total=%d" % [flee, prepare, defend, pacify, total])
	# 硬斷言：威脅存在時防守 dispatch 率 > 0（該出現還出現，不被新權衡默默吃）。
	# 對照 Task0 baseline(flee13/prepare4/defend1/pacify0)：pacify 稀有(此 seed/窗=0)→不逐類斷，聚合 > 0。
	if total <= 0:
		_fails += 1
		print("[FAIL] 率表：seeded 威脅反應總 dispatch = 0（threat 被融合默默吃掉）")
	else:
		print("[rate] 聚合 dispatch > 0 OK（repertoire 逐類可達性由 5a 證）")

func _place_plains(state: WorldState, pos: Vector2i) -> void:
	var tile := HexTileData.new()
	tile.tile_id = pos.x * 1000 + pos.y; tile.tile_pos = pos; tile.terrain = "plains"
	state.world.tiles[tile.tile_id] = tile
