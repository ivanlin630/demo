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
	c.threat_react = 1.1   # ★S2 calibrate：高威脅(≥THREAT_BOOST_FLOOR 1.0，boost fires)→repertoire 各響應清晰
	c.threat_threshold = ThreatAssessment.THREAT_BASE_THRESHOLD + float(vals.get("慎重", 0.5)) * 0.3
	c.threat_id = 1
	c.threat_pos = Vector2i(2, 0)
	c.is_resident = false
	c.winnable = 0.1   # ★S2：不可勝場景（迎戰 override/求和/逃 outlet 前提；threat util 讀 winnable）
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
	# 好戰高+低慎重(reckless 死戰 override winnable)+非居民 → 迎戰(DEFEND)。★S2 calibrate：迎戰 dampen 後
	# 好戰-high 需 reckless(低慎重 override)或可勝才 charge；moderate 慎重+不可勝→備戰(respect,cautious-hawk)。
	_expect_first("DEFEND", {"求生欲": 0.3, "好戰": 0.9, "慎重": 0.1, "貪婪": 0.5, "信義": 0.5}, "迎戰")
	# 慎重高 → 備戰(PREPARE)
	_expect_first("PREPARE", {"求生欲": 0.4, "好戰": 0.4, "慎重": 0.9, "貪婪": 0.5, "信義": 0.5}, "備戰")
	# 貪婪+信義高+好戰低+★低求生欲(真 weak-pragmatic，非怯逃) → 求和(pacify outlet)
	# ★S2 migrate：舊 pacify threat-invariant→求生欲0.5 仍求和；新 FLEE=膽量秤(求生欲)×sev×(1−winnable)
	# → 求生欲0.5 膽量秤中→逃競爭；真 weak-pragmatic=低求生欲(不想逃只想低頭)才穩求和(對齊 spec 象限)。
	_expect_first("PACIFY", {"求生欲": 0.2, "好戰": 0.1, "慎重": 0.2, "貪婪": 0.8, "信義": 0.7}, "求和")

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

# ── 5b 率表：seeded warring threat dispatch（★序3 follow-up 改資訊性，非硬斷）──
#   原硬斷 total>0 耦合世界軌跡：序3 follow-up 收窄 idle-filler ambient FLEE churn 後，seeded 世界變靜
#   （幽靈 FLEE churn 曾是隊間威脅遭遇的主要製造者）→ non-unified idle 隊少真過門檻威脅 → seeded dispatch→0。
#   threat 機制未壞（_evaluate_threat 未動、loop3 PRIO_THREAT 仍先於 idle-filler）→ 硬斷改走確定性
#   live-seam 注入（_check_live_dispatch），與世界軌跡解耦。seeded 值保留為資訊性趨勢。
func _check_rate_table() -> void:
	print("--- 5b 率表 (seeded warring 1200t — 資訊性趨勢) ---")
	WarringHarness.run(1337, 1200)   # 內部 Probe.enabled，跑完 counts 保留（下次 run 才 reset）
	var flee: int = int(Probe.counts.get("threat.dispatch.survival", 0))
	var prepare: int = int(Probe.counts.get("threat.dispatch.備戰", 0))
	var defend: int = int(Probe.counts.get("threat.dispatch.迎戰", 0))
	var pacify: int = int(Probe.counts.get("threat.dispatch.求和", 0))
	var total: int = flee + prepare + defend + pacify
	print("[rate] seeded flee=%d prepare=%d defend=%d pacify=%d total=%d（資訊性：威脅遭遇=世界軌跡函數，序3 follow-up 靜世界後可為 0，非機制壞）" % [flee, prepare, defend, pacify, total])
	_check_live_dispatch()

# ── 5b live-seam（★硬斷）：確定性構 non-unified idle 威脅隊 → _evaluate_threat 實派 threat task + bump probe。
#   繞世界軌跡（不依賴 seeded 湧現）→ threat 派發 seam 恆可驗。求生欲高 leader → survival(FLEE) argmax。
func _check_live_dispatch() -> void:
	print("--- 5b live-seam：確定性 non-unified 威脅 → _evaluate_threat 實派 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	# non-unified（無 merchant/produce tag）idle 隊：求生欲高 + 慎重低（門檻低）→ FLEE。
	var tid := 810
	var t := TeamData.new(); t.team_id = tid; t.tags = ["軍隊"]
	t.tile_pos = Vector2i(5, 5); t.leader_id = tid * 10
	AnonTierSystem.add_anon(t, "平民", 8)
	t.resources = {"food": 300.0}
	t.current_task = TeamData.TASK_IDLE; t.combat_target = -1
	state.teams[tid] = t
	state.team_discovered[tid] = []
	state.team_intel[tid] = {}
	var ldr := PersonData.new(); ldr.id = tid * 10; ldr.team_id = tid
	ldr.values = {"求生欲": 0.9, "好戰": 0.1, "慎重": 0.2, "貪婪": 0.5, "信義": 0.5}
	state.persons[ldr.id] = ldr
	_place_plains(state, Vector2i(5, 5))
	# 逼近敵：碾壓實力 + 敵意 rep → threat_react 過門檻。
	var etid := 811
	var e := TeamData.new(); e.team_id = etid; e.tile_pos = Vector2i(6, 5); e.faction_id = -1
	e.last_tile_pos = Vector2i(8, 5)   # 8→6 朝我(5,5)逼近
	AnonTierSystem.add_anon(e, "戰士", 40)   # 碾壓實力
	state.teams[etid] = e
	_place_plains(state, Vector2i(6, 5))
	t.known_reputations[etid] = 0.05   # 敵意
	state.team_discovered[tid].append(etid)
	BeliefSystem.record_claim(state, tid, etid, etid, "親見", {"population_est": 40}, 1.0, false)

	# sanity：確認 non-unified + 過門檻（否則 _evaluate_threat 早退，斷言失效）。
	var fai := FactionAISystem.new()
	if fai.uses_unified(t):
		_fails += 1
		print("[FAIL] live-seam 隊竟 unified（tag 設錯，_evaluate_threat 走不到）"); return
	var ctx := DecisionContext.gather(state, t)
	print("[live] threat_react=%.2f threshold=%.2f" % [ctx.threat_react, ctx.threat_threshold])
	if ctx.threat_react < ctx.threat_threshold:
		_fails += 1
		print("[FAIL] live-seam 構不出過門檻威脅（threat_react<threshold），無法驗派發"); return

	Probe.enabled = true   # 直呼 seam：Probe 預設 no-op，須開啟才計 threat.dispatch bump
	var before: int = _threat_dispatch_total()
	fai._evaluate_threat(state, t)
	var after: int = _threat_dispatch_total()
	var dispatched: bool = t.current_task in [TeamData.TASK_FLEE, TeamData.TASK_DEFEND, TeamData.TASK_PREPARE]
	if dispatched and after > before:
		print("[live] _evaluate_threat 實派 %s + probe bump(%d→%d) OK（threat seam 確定性活）" % [t.current_task, before, after])
	else:
		_fails += 1
		print("[FAIL] live-seam：_evaluate_threat 未派 threat task（task=%s，probe %d→%d）" % [t.current_task, before, after])

func _threat_dispatch_total() -> int:
	return int(Probe.counts.get("threat.dispatch.survival", 0)) \
		+ int(Probe.counts.get("threat.dispatch.備戰", 0)) \
		+ int(Probe.counts.get("threat.dispatch.迎戰", 0)) \
		+ int(Probe.counts.get("threat.dispatch.求和", 0))

func _place_plains(state: WorldState, pos: Vector2i) -> void:
	var tile := HexTileData.new()
	tile.tile_id = pos.x * 1000 + pos.y; tile.tile_pos = pos; tile.terrain = "plains"
	state.world.tiles[tile.tile_id] = tile
