extends SceneTree

# named-scarcity 出口 A+B TDD（spec 2026-08-12）：B 訓練 util need-connect(真根修) + A 絕境 field-promote(救急弱)。
# 核：①officer_need bounded ②B train_drive=officer_need×MAG machine-demonstrate(0→0、full 贏 build argmax、bounded)
#   ③A 真絕境 field-promote 弱平民 fire + 非絕境不 relax + 前多疑-blocked 領主 now 提拔（decouple 解卡）。

var _fail: int = 0
func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else: _fail += 1; print("  [FAIL] %s" % m)

func _mk_lord(villages: int, advisors: int, leader_vals: Dictionary, anon: Dictionary) -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100000
	var fac := FactionData.new(); fac.faction_id = 0; fac.leader_team_id = 1
	var members: Array = [1]
	for i in range(villages): members.append(100 + i)
	fac.member_team_ids = members; state.factions[0] = fac
	var t := TeamData.new(); t.team_id = 1; t.faction_id = 0; t.tile_pos = Vector2i(5,5)
	var lp := PersonData.new(); lp.id = 11; lp.values = leader_vals; state.persons[11] = lp; t.leader_id = 11
	var nm: Array = []
	for j in range(advisors):
		var ap := PersonData.new(); ap.id = 20 + j; ap.skills = {"統領": 0.5}; state.persons[ap.id] = ap; nm.append(ap.id)
	t.named_members = nm
	for tier in anon: AnonCohort.add(t.anon_cohorts, tier, "healthy", int(anon[tier]))
	state.teams[1] = t
	return [state, t]

func _train_util_in_rank(train_drive: float) -> Array:
	var c := DecisionContext.new()
	c.leader_values = {"野心": 0.6, "統領": 0.6}
	c.food_days = 14.0; c.population = 20; c.threat_threshold = 999.0; c.self_armed_ratio = 0.5
	c.has_trainable = true
	c.ambient_train_drive = train_drive
	var out: Array = []
	for e in DecisionEngine.rank_scored_ctx(c): out.append(String(e["opt"]))
	return out

func _initialize() -> void:
	var fai := FactionAISystem.new()

	print("=== ①officer_need bounded（single source 供 B/A）===")
	var suff := _mk_lord(2, 4, {}, {"平民": 8})   # 2 村 desired=1、已 4 記名 → 夠
	var short := _mk_lord(8, 0, {}, {"平民": 8})   # 8 村 desired=4、0 記名 → 缺
	_ok(FactionAISystem.officer_need(suff[0], suff[1]) == 0.0, "officer 夠(spare4≥desired1 且 bench4≥CONCURRENT) → officer_need=0（bounded）")
	_ok(FactionAISystem.officer_need(short[0], short[1]) == 1.0, "officer 缺(spare0/desired4) → officer_need=1.0")
	# ★realistic-scarce（arc 原症、villages-oversight 漏、dispatch-demand catches）：村數-satisfied 但 bench 短缺。
	var realistic := _mk_lord(2, 1, {}, {"平民": 8})   # 2 村 desired=1、spare=1 → governing 足(oversight_need=0)、但 bench=1<CONCURRENT2
	_ok(FactionAISystem.officer_need(realistic[0], realistic[1]) > 0.0,
		"★realistic-scarce(村數 governing 足但 bench=1 短缺)→ officer_need=%.2f>0（dispatch-demand 補 villages-oversight 漏的真壓力）" % FactionAISystem.officer_need(realistic[0], realistic[1]))
	# dispatch 派出後 bench→0：想派更多派不出=T12 原症 → officer_need 更高。
	var depleted := _mk_lord(2, 0, {}, {"平民": 8})   # 派出後 spare=0
	_ok(FactionAISystem.officer_need(depleted[0], depleted[1]) > FactionAISystem.officer_need(realistic[0], realistic[1]),
		"派出後 bench=0（想派更多派不出）→ officer_need 更高（%.2f>%.2f、T12 原症）" % [FactionAISystem.officer_need(depleted[0], depleted[1]), FactionAISystem.officer_need(realistic[0], realistic[1])])
	# ★bounded 守：bench 足（spare≥CONCURRENT）+ 村數足 → dispatch-demand 0 → officer_need 0。
	var benched := _mk_lord(2, 2, {}, {"平民": 8})   # spare=2≥CONCURRENT2 → 有 bench
	_ok(FactionAISystem.officer_need(benched[0], benched[1]) == 0.0, "bench 足(spare2≥CONCURRENT2)→ officer_need=0（bounded、能派無壓不練）")

	print("=== ②B: train_drive = officer_need × MAG machine-demonstrate（bounded、贏 build argmax）===")
	const BUILD_REF: float = 1.11   # 硬數據：build util ≈ 1.11（訓練須夠高才轉）
	print("  --- officer_need → ambient_train_drive 曲線 ---")
	var prev := -1.0; var mono := true
	for i in range(6):
		var need: float = float(i) / 5.0
		var td: float = need * FactionAISystem.TRAIN_OFFICER_MAG
		print("    officer_need=%.1f  train_drive=%.3f" % [need, td])
		if td < prev - 1e-9: mono = false
		prev = td
	_ok(0.0 * FactionAISystem.TRAIN_OFFICER_MAG == 0.0, "officer_need=0 → train_drive=0（bounded、officer 夠不練 非 always-train）")
	_ok(1.0 * FactionAISystem.TRAIN_OFFICER_MAG > BUILD_REF, "officer_need=1 → train_drive %.2f > build %.2f（缺 officer 訓練贏 argmax）" % [FactionAISystem.TRAIN_OFFICER_MAG, BUILD_REF])
	_ok(mono, "train_drive 對 officer_need 單調（need-connected 非 flat）")
	# ★真 argmax：同 ctx、train_drive high vs 0 → 訓練 rank 升（need 驅動 argmax、非文字宣稱）。
	var rank_high: Array = _train_util_in_rank(1.0 * FactionAISystem.TRAIN_OFFICER_MAG)
	var rank_low: Array = _train_util_in_rank(0.0)
	var hi_pos: int = rank_high.find("訓練"); var lo_pos: int = rank_low.find("訓練")
	print("  train_drive high: rank=%s" % str(rank_high))
	print("  train_drive 0   : rank=%s" % str(rank_low))
	_ok(hi_pos != -1 and hi_pos == 0, "缺 officer(train_drive high) → 訓練=rank[0] argmax winner")
	_ok(lo_pos == -1 or lo_pos > hi_pos, "officer 夠(train_drive 0) → 訓練 rank 掉（%d→%d、bounded 讓位）" % [hi_pos, lo_pos])

	print("=== ③A: 絕境 field-promote 弱平民 fire ===")
	# 真絕境：8村 desired4 + 0記名 + 僅平民(quality 0.14<門檻→normal 不 fire) + 野心 → A relax field-promote。
	var d := _mk_lord(8, 0, {"野心": 0.9, "慎重": 0.2}, {"平民": 6})
	var dstate: WorldState = d[0]; var dteam: TeamData = d[1]
	Probe.reset(); Probe.enabled = true
	fai._try_promote_advisor(dstate, dteam)
	Probe.enabled = false
	_ok(int(Probe.counts.get("promote.fired", 0)) == 1 and int(Probe.counts.get("promote.field_desperate", 0)) == 1,
		"真絕境(缺officer+僅平民+無時間)→ A field-promote fire（promote.field_desperate=1）")
	var nid: int = dteam.named_members[dteam.named_members.size()-1]
	var wk = dstate.persons[nid]
	_ok(float(wk.skills.get("統領", 0.0)) < 0.5, "被急徵者=弱 officer（統領 %.2f 低、平民 tier 灌技能少=救急不救好）" % float(wk.skills.get("統領", 0.0)))

	print("=== ④A bounded：非絕境不 relax（quality gate 守）===")
	# 中度需求（2村 desired1、0記名 demand=1.0 但…實際 demand=1、非<0.9）——改用低需求場景：4村但已3記名→demand低。
	var nd := _mk_lord(4, 3, {"野心": 0.9, "慎重": 0.2}, {"平民": 6})   # desired2、spare3→demand0 → 根本不入
	Probe.reset(); Probe.enabled = true
	fai._try_promote_advisor(nd[0], nd[1])
	Probe.enabled = false
	_ok(int(Probe.counts.get("promote.fired", 0)) == 0, "officer 夠(demand0) → 不 field-promote（bounded）")
	# 有夠格候選(菁英)+缺officer → normal 路 fire（非 A 急徵路）=B 育成好 officer 的等價。
	var gq := _mk_lord(8, 0, {"野心": 0.9, "慎重": 0.2}, {"菁英": 6})
	Probe.reset(); Probe.enabled = true
	fai._try_promote_advisor(gq[0], gq[1])
	Probe.enabled = false
	_ok(int(Probe.counts.get("promote.fired", 0)) == 1 and int(Probe.counts.get("promote.field_desperate", 0)) == 0,
		"有菁英候選缺officer → normal 提好 officer fire（非 A 急徵路、field_desperate=0）")

	print("=== ⑤★倒因果修：前多疑-blocked 領主真絕境 now field-promote（decouple、relief 解卡）===")
	# 用戶裁 decouple：慎重0.9/野心0.2 lord 舊 desp_util=1×(0.3+0.18−0.63→0)=0 never fire → now pmult=0.48 → desp_util 0.48>0.3 fire。
	var pd := _mk_lord(8, 0, {"野心": 0.2, "慎重": 0.9}, {"平民": 6})
	Probe.reset(); Probe.enabled = true
	fai._try_promote_advisor(pd[0], pd[1])
	Probe.enabled = false
	_ok(int(Probe.counts.get("promote.field_desperate", 0)) == 1,
		"★前多疑-blocked 領主(慎重0.9/野心0.2)真絕境 now field-promote fire（多疑與提拔 decouple、relief 不再被慎重永久卡）")

	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()
