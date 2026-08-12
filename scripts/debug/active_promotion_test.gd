extends SceneTree

# 主動升匿名 TDD（spec 2026-08-12 §2/§2.5/§3/§4）：領主 deliberate 提拔 anon→named、bounded 非 crank。
# ★多疑與提拔 decouple（用戶裁、倒因果修）：慎重不再壓提拔（懷疑對已存在的人、擋創造=倒因果）；差異化=野心 rate。
# 核：①§2.5 promote_util bounded(低需求→0 need-gated 非 flat)+野心 modulate②野心差異化(rate 非 gate、低野心仍 fire)
#   ③候選資質 gate(低 tier→低)④firing=named+1/anon-1(kill_random 真扣)/獨立人格⑤前多疑-blocked 領主 now 提拔(relief 解卡)。

var _fail: int = 0
func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else: _fail += 1; print("  [FAIL] %s" % m)

# 建領主隊：faction leader team 1 + N 村(member_team_ids)+ leader 人格 + named advisors + anon tiers。
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

func _initialize() -> void:
	var fai := FactionAISystem.new()

	print("=== ①§2.5 promote_util bounded machine-demonstrate（野心 modulate、多疑 decouple）===")
	# 低需求 → util→0（need-gated、非 flat 逢缺必補；bounded 不變）。
	_ok(FactionAISystem.promote_util(0.0, 0.9, 1.0) == 0.0, "demand=0 → util=0（記名夠不提、bounded need-gated）")
	# ★倒因果修（用戶裁）：慎重不再壓提拔——低野心 lord 缺 officer+候選 → 照樣 fire（懷疑對已存在的人、擋創造=倒因果）。
	_ok(FactionAISystem.promote_util(1.0, 0.2, 1.0) > 0.3, "★低野心 demand=1+候選 → util>0.3 照 fire（多疑與提拔 decouple、非被慎重永久卡）")
	# 野心領主(野心 0.9)高需求 → util 更高（rate 差異、非 gate）。
	_ok(FactionAISystem.promote_util(1.0, 0.9, 1.0) > FactionAISystem.promote_util(1.0, 0.2, 1.0),
		"野心高 util > 野心低（差異化=野心 rate、皆 fire）")
	# machine-demonstrate：util vs demand 曲線（野心 modulate rate）+ 單調 + bounded（demand=0→0）。
	print("  --- promote_util vs demand（quality=1.0）machine-demonstrate ---")
	var amb_prev := -1.0; var lo_prev := -1.0; var mono := true
	for i in range(6):
		var dm: float = float(i) / 5.0
		var u_amb: float = FactionAISystem.promote_util(dm, 0.9, 1.0)   # 野心大→養大班底
		var u_lo: float = FactionAISystem.promote_util(dm, 0.2, 1.0)    # 野心低→仍 need-driven fire、rate 低
		var u_neu: float = FactionAISystem.promote_util(dm, 0.5, 1.0)
		print("    demand=%.1f  野心高=%.3f 中性=%.3f 野心低=%.3f" % [dm, u_amb, u_neu, u_lo])
		if u_amb < amb_prev - 1e-9: mono = false
		if u_lo < lo_prev - 1e-9: mono = false
		amb_prev = u_amb; lo_prev = u_lo
	_ok(mono, "util 對 demand 單調非遞減（野心 modulate rate、bounded demand=0→0、非 flat）")
	_ok(FactionAISystem.promote_util(0.0, 0.9, 1.0) == 0.0 and FactionAISystem.promote_util(0.0, 0.2, 1.0) == 0.0,
		"★bounded：demand=0 → 各野心 util 皆 0（need-gated 不變、純去慎重壓制無新 crank）")

	print("=== ②野心差異化（rate 非 gate、低野心仍 fire）===")
	var u_a: float = FactionAISystem.promote_util(0.8, 0.9, 1.0)   # 野心高
	var u_n: float = FactionAISystem.promote_util(0.8, 0.5, 1.0)   # 中性
	var u_p: float = FactionAISystem.promote_util(0.8, 0.2, 1.0)   # 野心低
	_ok(u_a > u_n and u_n > u_p, "野心高 %.3f > 中性 %.3f > 野心低 %.3f（差異化=野心 rate）" % [u_a, u_n, u_p])
	_ok(u_p > 0.3, "★野心低 %.3f 仍 > 0.3 fire（need-driven、野心 modulate rate 非 gate、非多疑永久卡）" % u_p)

	print("=== ③候選資質 gate（低 tier→低 util）===")
	var qb := _mk_lord(6, 0, {"野心": 0.9, "慎重": 0.2}, {"平民": 8})   # 只平民
	var qe := _mk_lord(6, 0, {"野心": 0.9, "慎重": 0.2}, {"菁英": 8})   # 菁英
	_ok(fai._best_candidate_quality(qb[1]) < fai._best_candidate_quality(qe[1]),
		"平民-only quality %.2f < 菁英 quality %.2f（資質浮現、非每平民幹部料）" % [fai._best_candidate_quality(qb[1]), fai._best_candidate_quality(qe[1])])

	print("=== ④firing：野心領主多村缺記名 + 菁英候選 → 提拔（named+1/anon-1/獨立人格）===")
	var e := _mk_lord(8, 0, {"野心": 0.9, "慎重": 0.2}, {"菁英": 6})
	var estate: WorldState = e[0]; var eteam: TeamData = e[1]
	var named0: int = eteam.named_members.size(); var anon0: int = AnonTierSystem.total_pop(eteam)
	Probe.reset(); Probe.enabled = true
	fai._try_promote_advisor(estate, eteam)
	Probe.enabled = false
	_ok(int(Probe.counts.get("promote.fired", 0)) == 1, "野心領主提拔 fire（promote.fired=1）")
	_ok(eteam.named_members.size() == named0 + 1, "named roster +1（%d→%d、add_member 加進 lord roster 非 subteam）" % [named0, eteam.named_members.size()])
	_ok(AnonTierSystem.total_pop(eteam) == anon0 - 1, "★anon 池 -1（%d→%d、kill_random 真扣代價）" % [anon0, AnonTierSystem.total_pop(eteam)])
	var newid: int = eteam.named_members[eteam.named_members.size() - 1]
	_ok(estate.persons.has(newid) and estate.persons[newid].values.size() > 0, "被提者=獨立人格個體(generate() values 非複製)=§3 忠誠賭注真實")

	print("=== ⑤★倒因果修：前被多疑永久卡的領主 now 缺 officer+候選 → 提拔（relief 解卡）===")
	# 用戶裁 decouple：慎重0.6/野心0.3 lord 舊 pmult=0.3+0.27−0.42=0.15<0.3 never fire → now pmult=0.57 → util>0.3 fire。
	var p := _mk_lord(8, 0, {"野心": 0.3, "慎重": 0.6}, {"菁英": 6})
	Probe.reset(); Probe.enabled = true
	fai._try_promote_advisor(p[0], p[1])
	Probe.enabled = false
	_ok(int(Probe.counts.get("promote.fired", 0)) == 1 and (p[1] as TeamData).named_members.size() == 1,
		"★前多疑-blocked 領主(慎重0.6/野心0.3)now 缺 officer+菁英候選 → 提拔 fire（named-scarcity relief 不再被多疑倒因果卡）")

	print("=== ⑥bounded：記名夠(spare≥desired)→demand 0→不提 ===")
	var s := _mk_lord(2, 4, {"野心": 0.9, "慎重": 0.2}, {"菁英": 6})   # 2 村 desired=1、已 4 記名
	_ok(FactionAISystem.officer_need(s[0], s[1]) == 0.0, "spare(4)≥desired(1)→officer_need=0（bounded、夠人手不提）")
	Probe.reset(); Probe.enabled = true
	fai._try_promote_advisor(s[0], s[1])
	Probe.enabled = false
	_ok(int(Probe.counts.get("promote.fired", 0)) == 0, "記名夠 → 不提（非逢缺必補的反面：夠了就不提）")

	print("=== ⑦無 anon 候選 → 不提 ===")
	var z := _mk_lord(8, 0, {"野心": 0.9, "慎重": 0.2}, {})
	Probe.reset(); Probe.enabled = true
	fai._try_promote_advisor(z[0], z[1])
	Probe.enabled = false
	_ok(int(Probe.counts.get("promote.fired", 0)) == 0, "無 anon → 不提（無可提對象）")

	print("=== ⑧cadence 接線：info_side_dispatch_all 真呼 _try_promote_advisor（whole-cadence LIVE）===")
	var w := _mk_lord(8, 0, {"野心": 0.9, "慎重": 0.2}, {"菁英": 6})
	var wstate: WorldState = w[0]; var wteam: TeamData = w[1]
	wteam.info_eval_next_tick = 0   # 過 cadence gate
	Probe.reset(); Probe.enabled = true
	fai.info_side_dispatch_all(wstate, [1])   # 走真 cadence 入口（非直呼 _try_promote_advisor）
	Probe.enabled = false
	_ok(int(Probe.counts.get("promote.fired", 0)) == 1 and wteam.named_members.size() == 1,
		"info_side_dispatch_all → _try_promote_advisor fire（cadence 接線 LIVE、promoted 同 tick 可供 dispatch）")

	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()
