extends SceneTree
# @bed-kind: diagnostic
# slice: team_known 0 條 — 母體 vs 缺陷普查（派工 2026-10-01-systems-to-measurer-DISPATCH-team-known-zero-after-400-ticks.md）
#
# ★逐字複現 scripts/debug/available_actions_bed.gd 的 `_fresh()`＋`_target()`＋`_arm_for("confirm_gather_intel")`
#   那段佈置（seed=20260930／config=warring_states／ARM_TICKS_FOR_KNOWLEDGE=400），
#   不重新發明——只加普查印出，零改動production。
# ★本床只讀不寫：零新 Probe.bump（全部讀既有 tap：msg.sent／prop.*／help.need_deposited／
#   care.firsthand_distress／scout.info_returned），零新世界機制。

func _initialize() -> void:
	var tree_sha := OS.get_environment("KZ_SHA") if OS.has_environment("KZ_SHA") else "?"
	print("=== team_known 0 條普查（tree=%s）===" % tree_sha)

	seed(20260930)
	var st := MeasureBedHelper.arm_and_new()
	GameSetup.setup(st, GameSetup.load_config("res://config/warring_states.json"))
	var pt: TeamData = st.teams.get(st.get_player_team_id())
	print("[佈置] player_team=%d｜世界隊數(setup後)=%d" % [pt.team_id, st.teams.size()])

	# ── 逐字複現 available_actions_bed.gd::_target() ──
	var tgt_id: int = -1
	for k in st.teams.keys():
		if int(k) != pt.team_id and st.teams[k].leader_id != -1:
			st.teams[k].tile_pos = pt.tile_pos
			tgt_id = int(k)
			break
	print("[佈置] _target() 選到 tgt=%d（teleport 到 player tile_pos=%s）" % [tgt_id, str(pt.tile_pos)])
	if tgt_id == -1:
		print("[不可判] 找不到可用 target（leader_id==-1 的隊全滿）")
		quit(2); return

	var runner := SimRunner.new()
	const ARM_TICKS: int = 400
	for _i in range(ARM_TICKS):
		runner.advance_tick(st, pt.tile_pos)

	var kn: int = BeliefSystem.known_targets(st, tgt_id).size()
	var ev: int = (st.team_known.get(tgt_id, []) as Array).size()
	print("[複現] 推 %d tick 之後：tgt 知道 %d 支隊、記得 %d 條事件（對照原句：知道3／記得0）" % [ARM_TICKS, kn, ev])

	# ── 一、母體：team_known 全隊分佈（不只看 tgt）──
	var sizes: Dictionary = {}   # size -> team 數
	var nonzero_teams: Array = []
	for tid in st.teams.keys():
		var n: int = (st.team_known.get(int(tid), []) as Array).size()
		sizes[n] = int(sizes.get(n, 0)) + 1
		if n > 0:
			nonzero_teams.append("team%d=%d條" % [int(tid), n])
	var size_keys: Array = sizes.keys()
	size_keys.sort()
	print("[母體①] team_known 分佈（幾支隊有幾條，含 0）：")
	for sk in size_keys:
		print("   %d 條的隊 = %d 支" % [int(sk), int(sizes[sk])])
	print("[母體①] 非零隊逐列：%s" % (str(nonzero_teams) if not nonzero_teams.is_empty() else "（無，全部隊皆 0 條）"))

	# ── 二、機會數：world-wide（讀既有 Probe tap，零新增）──
	print("[母體②] global_messages.size()（世界累計訊息總數，TTL=7天=10080tick 遠大於本窗400tick ⇒ 尚未被 prune）＝ %d" % st.global_messages.size())
	var probe_keys: Array = ["msg.sent", "prop.call", "prop.arrivals", "prop.colocated_pair",
		"msg.prop_candidate", "msg.prop_done", "msg.delivered", "msg.distorted",
		"help.need_deposited", "care.firsthand_distress", "scout.info_returned", "scout.target_dead", "scout.timeout"]
	print("[母體②] 既有 Probe 計數器（world-wide 機會數，零新 tap）：")
	for pk in probe_keys:
		print("   %s = %d" % [pk, int(Probe.counts.get(pk, 0))])

	# ── 三、global_messages 依 origin_team_id 分組（誰真的原生產生過訊息）──
	var by_origin: Dictionary = {}
	for m in st.global_messages:
		var oid: int = int(m.origin_team_id)
		by_origin[oid] = int(by_origin.get(oid, 0)) + 1
	print("[母體③] global_messages 依 origin_team_id 分組（%d 個不同來源隊）：" % by_origin.size())
	for oid in by_origin.keys():
		print("   team%d 自己原生產生 = %d 條%s" % [int(oid), int(by_origin[oid]), "  ← 就是 tgt" if int(oid) == tgt_id else ""])
	print("[母體③] tgt(team%d) 自己原生產生的訊息數 ＝ %d（這是它『自己知道自己做過的事』那一半機會）"
		% [tgt_id, int(by_origin.get(tgt_id, 0))])

	# ── 四、判讀（不裁，只报） ──
	var world_wide_opportunities: int = int(Probe.counts.get("msg.sent", 0))
	var tgt_self_origin: int = int(by_origin.get(tgt_id, 0))
	print("[判讀] world-wide 機會數(msg.sent)=%d｜tgt 自己origin機會數=%d｜tgt 記得的事件數=%d" % [
		world_wide_opportunities, tgt_self_origin, ev])
	if world_wide_opportunities == 0:
		print("[判讀] ⇒ 世界在這 %d tick 內【連一條訊息都沒發生過】(msg.sent=0，非只 tgt) ⇒ ★母體太年輕/窗太短，不是機制壞掉" % ARM_TICKS)
	elif tgt_self_origin == 0 and ev == 0:
		print("[判讀] ⇒ 世界其他地方有事發生(msg.sent=%d>0)，但 tgt 自己沒有原生事件、也沒收到任何 propagate ⇒ 這是【這支隊剛好很安靜】，不能排除『它本來就沒參與任何事』" % world_wide_opportunities)
	elif tgt_self_origin > 0 and ev == 0:
		print("[判讀] ⇒ ★★★tgt 自己原生產生過 %d 條訊息，但 team_known 仍是 0 ⇒ 這是缺陷訊號，需要往下查是哪個寫入點沒接上" % tgt_self_origin)
	else:
		print("[判讀] ⇒ tgt 有機會也有記錄，跟原句「記得0條」不一致，環境可能已經漂移，需要重跑核對")

	print("=== team_known 0 條普查 DONE ===")
	quit(0)
