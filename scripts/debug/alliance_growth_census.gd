extends SceneTree
# @bed-kind: diagnostic
# 同盟不搬領袖 §先量（spec 2026-10-13-alliance-never-moves-faction-leader-HOW）：在【修前】的行為上數
#   ①_form_alliance 發起方角色 × 收提案方角色（領袖／成員／獨立）3×3
#   ②各 JOIN 路徑的絕對次數（faction.join.<reason>；子隊繼承與開局佈置另列，不算頂層入勢力）
#   ③「領袖被搬走」那一支：次數、原勢力剩幾隊、搬去哪個勢力
#   ④set_owner reason=alliance（結盟送據點，#8 D C1）的次數
#   門檻（spec 事前定）：任一 seed 中該支造成的頂層入勢力 ≥ 20%，或使 ≥ 2 個勢力的頂層成員增加 ⇒「主要管道」⇒ NPC 端停手交數字
#   陽性對照：佈置「勢力 A 領袖發起、勢力 B 成員收」的提案 ⇒ 那一支修前確實會 fire（否則 0 次是母體太小的負斷言）
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/alliance_growth_census.gd　env AGC_SEEDS（預設 1337,2,3）AGC_DAYS（預設 30）

func _initialize() -> void:
	var seeds: Array = []
	for s in OS.get_environment("AGC_SEEDS").split(",", false):
		seeds.append(int(s))
	if seeds.is_empty():
		seeds = [1337, 2, 3]
	var days: int = int(OS.get_environment("AGC_DAYS")) if OS.get_environment("AGC_DAYS") != "" else 30
	print("=== alliance_growth_census：修前 NPC 結盟搬領袖這一支是不是主要管道 ===")
	_positive_control()
	var main_channel: bool = false
	for sd in seeds:
		main_channel = _run(int(sd), days) or main_channel
	print("\n=== alliance_growth_census DONE === 主要管道=%s（任一 seed 達門檻）" % str(main_channel))
	quit(0)


func _positive_control() -> void:
	print("\n── 陽性對照：A 勢力領袖向 B 勢力成員提同盟 ──")
	seed(1337)
	# ★arm 先於 setup（bed-arm 閘）；留玩家（玩家隊照常推進）
	var st := MeasureBedHelper.arm_and_setup("res://config/default.json", false)
	var fids: Array = st.factions.keys()
	fids.sort()
	var fa: FactionData = st.factions[fids[0]]
	var fb: FactionData = st.factions[fids[1]]
	var lead: TeamData = st.teams[fa.leader_team_id]
	var mem: TeamData = null
	for tid in fb.member_team_ids:
		if int(tid) != fb.leader_team_id:
			mem = st.teams[tid]
			break
	if mem == null:
		print("   ★勢力 B 沒有非領袖成員 ⇒ 陽性對照【不可判】")
		Probe.enabled = false
		return
	mem.tile_pos = lead.tile_pos
	mem.known_reputations[lead.team_id] = 1.0
	lead.known_reputations[mem.team_id] = 1.0
	var dip := DiplomaticAiSystem.new()
	var ans: String = dip.handle_diplomacy_message(st, mem, lead, "propose_alliance")
	if ans != "accept":
		print("   提案被拒（%s）⇒ 改直呼 _form_alliance 驗那一支會走到" % ans)
		dip._form_alliance(st, mem, lead)
	var fired: int = int(Probe.counts.get("alliance.moved_leader", 0))
	print("   回應 %s｜moved_leader %d｜領袖隊 Team%d 現在在勢力 %d｜原勢力 %d 的 leader_team_id=%d（懸空=%s）" % [ans, fired,
		lead.team_id, lead.faction_id, fa.faction_id, fa.leader_team_id, str(st.teams.has(fa.leader_team_id) and (st.teams[fa.leader_team_id] as TeamData).faction_id != fa.faction_id)])
	print("   ★陽性對照 %s" % ("通過：修前那一支確實會 fire" if fired > 0 else "失敗：那一支沒 fire"))
	Probe.enabled = false


func _run(sd: int, days: int) -> bool:
	seed(sd)
	# ★arm 先於 setup（bed-arm 閘）；留玩家（玩家隊照常推進）
	var st := MeasureBedHelper.arm_and_setup("res://config/default.json", false)
	var runner := SimRunner.new()
	var enc: int = 0
	for i in range(days * WorldState.TICKS_PER_DAY):
		var p: TeamData = st.teams.get(st.get_player_team_id())
		var r: String = runner.advance_tick(st, p.tile_pos if p != null else Vector2i(-1, -1))
		if st.encounter_active:
			enc += 1
			runner._encounter_system.resolve_encounter_end(st, "draw")
		if r == "awaiting_heir":
			break
	Probe.enabled = false
	var c: Dictionary = Probe.counts
	print("\n── seed %d｜%d 天（tick %d）｜遭遇 draw %d ──" % [sd, days, st.world.current_tick, enc])
	var roles: Array = ["leader", "member", "indep"]
	print("   ①_form_alliance 發起方 → 收提案方（列＝發起方）：")
	print("      %-8s %8s %8s %8s" % ["", "→leader", "→member", "→indep"])
	for b in roles:
		print("      %-8s %8d %8d %8d" % [b, int(c.get("alliance.form.%s_to_leader" % b, 0)),
			int(c.get("alliance.form.%s_to_member" % b, 0)), int(c.get("alliance.form.%s_to_indep" % b, 0))])
	var top: int = 0
	var parts: Array = []
	for r in WorldState.JOIN_REASONS + ["unknown_reason"]:
		var n: int = int(c.get("faction.join." + String(r), 0))
		if n > 0:
			parts.append("%s=%d" % [r, n])
		if not (String(r) in [WorldState.JOIN_SUBTEAM_INHERIT, WorldState.JOIN_SETUP, WorldState.JOIN_CREATE_LEADER]):
			top += n
	print("   ②JOIN 絕對次數：%s｜頂層入勢力（不含子隊繼承、開局、建國者自己）＝ %d" % [", ".join(parts), top])
	var moved: int = int(c.get("alliance.moved_leader", 0))
	var tos: Dictionary = {}
	var smp: Array = Probe.samples.get("alliance.moved_leader", [])
	for s in smp:
		tos[int((s as Dictionary).get("to_faction", -1))] = true
	print("   ③領袖被搬走 %d 次（佔頂層入勢力 %s）｜受益勢力 %d 個｜樣本 %s" % [moved,
		("%.0f%%" % (100.0 * moved / top)) if top > 0 else "—", tos.size(), str(smp.slice(0, 5))])
	print("   ④結盟送據點（set_owner reason=alliance）%d 次" % int(c.get("outpost.owner_change.reason.alliance", 0)))
	var share_hit: bool = top > 0 and float(moved) / float(top) >= 0.2
	var hit: bool = share_hit or tos.size() >= 2
	print("   ⇒ 門檻：佔比≥20%%=%s／受益勢力≥2=%s ⇒ 主要管道=%s" % [str(share_hit), str(tos.size() >= 2), str(hit)])
	return hit
