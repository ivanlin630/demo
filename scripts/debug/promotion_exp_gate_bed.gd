extends SceneTree
# promotion_exp_gate_bed：晉升exp閘「門檻vs可達量」距離(systems派票+加掛三題，一次收完)。
# ★本體：exp存量(anon_exp vs 門檻50/100/200) + 流量逐來源(exp.add.<source>系列tap，9446d70b已merge)
# ★加掛①勒索四格(raid.extort/combat_at_outpost/combat_open_field/loot_noresolve，守恆式：四格加總==raid.resolve)
# ★加掛②convoy.deliver（faction_ai_system.gd:3464/3479/3484/3486/3488既有tap）
# ★加掛③promote逐筆bump_sample（anon_tier_system.gd既有，implementer 6c9a6175已補bounded樣本）
# ★誠實限（照抄自票面）：
#   ①本卷不下因果結論，只量「門檻與可達量的距離」
#   ②exp.add.dropped.*是【消失】非【沒給】——分開列：給出總量/真進anon_exp的量/丟棄量
#   ③exp.add.dropped.no_tier.*在【產線恆0】(team_data.gd:327-329三鍵預塞好)——它的0是【不會fire】
#     不是【沒發生】，不得寫成「沒有exp被丟棄」的證據
#   ④本卷不改任何常數，門檻該不該動是WHAT，blueprint裁
# 窗長：exp是累積量，太短窗看不出趨勢(空家不返教訓)——30天+每5天印一次期中報表看趨勢。
# 用法：BED_CONFIG(default warring_states.json) BED_DAYS(default 30) BED_SEED(default 1337)

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 30
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "res://config/warring_states.json"
	var seed_val: int = int(OS.get_environment("BED_SEED")) if OS.has_environment("BED_SEED") else 1337
	seed(seed_val)
	Probe.arm()
	var state: WorldState = MeasureBedHelper.arm_and_setup(cfg, true)
	var runner := SimRunner.new()
	var ticks: int = days * WorldState.TICKS_PER_DAY
	var no_player := Vector2i(-1, -1)

	print("=== promotion_exp_gate_bed: config=%s days=%d ticks=%d seed=%d ===" % [cfg, days, ticks, seed_val])

	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if tick % 7200 == 0 and tick > 0:   # 每5天
			_print_report(state, tick, false)

	_print_report(state, ticks, true)
	print("=== promotion_exp_gate_bed DONE ===")

func _print_report(state: WorldState, tick: int, is_final: bool) -> void:
	var tag: String = "=== 結果" if is_final else "--- [INTERIM] 期中"
	print("\n%s(窗=%.2f天/%d ticks) ===" % [tag, float(tick) / float(WorldState.TICKS_PER_DAY), tick])

	# ①leader戰術分布——母體＝所有有leader的隊
	var tacts: Array = []
	var tact_zero: int = 0
	var train_teams: int = 0
	var train_tact_pos: int = 0
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		var leader: PersonData = state.persons.get(t.leader_id)
		if leader == null: continue
		var tact: float = float(leader.skills.get("戰術", 0.0))
		tacts.append(tact)
		if tact <= 0.0: tact_zero += 1
		if t.current_task == TeamData.TASK_TRAIN:
			train_teams += 1
			if tact > 0.0: train_tact_pos += 1
	print("①leader戰術分布(母體=%d隊，有leader)：" % tacts.size())
	if tacts.is_empty():
		print("  ★母體=0——不可判")
	else:
		tacts.sort()
		var n1: int = tacts.size()
		print("  min=%.2f p50=%.2f max=%.2f　戰術==0的隊數=%d/%d(%.1f%%)" % [
			tacts[0], tacts[n1 / 2], tacts[n1 - 1], tact_zero, n1, 100.0 * float(tact_zero) / float(n1)])

	# ②TASK_TRAIN隊數 vs tact>0
	print("②TASK_TRAIN隊數=%d，其中tact>0=%d　　★差=%d＝『想訓練但訓練不會發生』(手不聽腦形狀)" % [
		train_teams, train_tact_pos, train_teams - train_tact_pos])

	# ③anon_exp各tier分布 vs 門檻
	print("③anon_exp各tier分布 vs 門檻(50/100/200)：")
	for tier in ["平民", "新兵", "老兵"]:
		var vals: Array = []
		var threshold: float = float(AnonTierSystem.PROMOTION_EXP_THRESHOLD.get(tier, 0.0))
		var over: int = 0
		for tid2 in state.teams:
			var t2: TeamData = state.teams[tid2]
			if not t2.anon_exp.has(tier): continue
			var v: float = float(t2.anon_exp[tier])
			vals.append(v)
			if v >= threshold: over += 1
		if vals.is_empty():
			print("  [%s]門檻=%.0f ★母體=0" % [tier, threshold])
		else:
			vals.sort()
			var n3: int = vals.size()
			print("  [%s]門檻=%.0f 母體=%d隊 min=%.1f p50=%.1f max=%.1f 達標(>=門檻)隊數=%d(%.1f%%)" % [
				tier, threshold, n3, vals[0], vals[n3 / 2], vals[n3 - 1], over, 100.0 * float(over) / float(n3)])

	# ④exp流量逐來源(9446d70b已merge的tap) —— ★分三欄：給出總量／真進anon_exp量／丟棄量
	print("④exp流量逐來源(★呼叫了但給0≠沒呼叫；dropped=消失非沒給；dropped.no_tier產線恆0見誠實限③)：")
	for src in ["combat_survivor_winner", "combat_survivor_loser", "train_npc", "train_player"]:
		var calls: int = int(Probe.counts.get("exp.add." + src, 0))
		var amount: float = Probe.amount("exp.add.amount." + src)
		var zero_calls: int = int(Probe.counts.get("exp.add.zero." + src, 0))
		var drop_elite: int = int(Probe.counts.get("exp.add.dropped.elite." + src, 0))
		var drop_notier: int = int(Probe.counts.get("exp.add.dropped.no_tier." + src, 0))
		if calls == 0 and zero_calls == 0 and drop_elite == 0 and drop_notier == 0:
			print("  [%s] ★母體=0——本窗這個來源從未呼叫過add_exp" % src)
		else:
			print("  [%s] 呼叫=%d(其中給0=%d) 給出總量=%.1f　丟棄:菁英無下階=%d 無此tier=%d" % [
				src, calls, zero_calls, amount, drop_elite, drop_notier])

	# ⑤promote.kill.*四格比例 + 母體核對
	print("⑤promote.kill.*四格(母體=promote.attempt)：")
	var attempt: int = int(Probe.counts.get("promote.attempt", 0))
	if attempt == 0:
		print("  ★母體=0——不可判")
	else:
		var kill_sum: int = 0
		for kill_key in ["count_le0", "already_elite", "not_enough_bodies", "not_enough_exp",
				"not_enough_res", "leader_tactics_cap", "elite_weapon"]:
			var kc: int = int(Probe.counts.get("promote.kill." + kill_key, 0))
			kill_sum += kc
			if kc > 0:
				print("  死在[%s]=%d(佔嘗試%.1f%%)" % [kill_key, kc, float(kc) / float(attempt) * 100.0])
		var ok: int = int(Probe.counts.get("promote.ok", 0))
		print("  嘗試=%d 成功=%d 死亡總和=%d　★母體核對：成功+死亡總和=%d %s嘗試數（差=%d，非0代表有未記路徑）" % [
			attempt, ok, kill_sum, ok + kill_sum,
			"==" if ok + kill_sum == attempt else "≠",
			attempt - (ok + kill_sum)])

	# 加掛①勒索四格 + 守恆式
	print("加掛①勒索四格（守恆式：四格加總 == raid.resolve）：")
	var extort: int = int(Probe.counts.get("raid.extort", 0))
	var combat_outpost: int = int(Probe.counts.get("raid.combat_at_outpost", 0))
	var combat_open: int = int(Probe.counts.get("raid.combat_open_field", 0))
	var loot_noresolve: int = int(Probe.counts.get("raid.loot_noresolve", 0))
	var resolve: int = int(Probe.counts.get("raid.resolve", 0))
	var raid_sum: int = extort + combat_outpost + combat_open + loot_noresolve
	print("  extort=%d combat_at_outpost=%d combat_open_field=%d loot_noresolve=%d　四格加總=%d vs resolve=%d %s" % [
		extort, combat_outpost, combat_open, loot_noresolve, raid_sum, resolve,
		"（守恆✓）" if raid_sum == resolve else "（★不守恆，差=%d，有計數器壞或有第五分支未記）" % (resolve - raid_sum)])
	if resolve == 0:
		print("  ★母體=0——raid.resolve本窗從未fire，勒索『零拒絕』的問題本窗答不了（不是答『沒有』，是答『量不到』）")
	elif extort == 0:
		print("  ★extort=0而resolve>0——這是blueprint『結局塌陷候選①』本輪真的答得出來的第一次：拒絕【沒有】fire過")
	else:
		print("  ★extort=%d>0——拒絕【有】fire過，blueprint『結局塌陷候選①』正式死" % extort)

	# 加掛②convoy.deliver
	print("加掛②convoy.deliver：抵達嘗試=%d　真成交(deliver_settled)=%d" % [
		int(Probe.counts.get("convoy.deliver", 0)), int(Probe.counts.get("convoy.deliver_settled", 0))])

	# 加掛③promote逐筆bump_sample——只在最終報表印(避免期中報表洗版)
	if is_final:
		print("加掛③promote逐筆bump_sample(implementer 6c9a6175已補，各≤8筆)：")
		for kill_key in ["not_enough_bodies", "not_enough_exp", "not_enough_res"]:
			var samples: Array = Probe.samples.get("promote.kill." + kill_key, [])
			print("  [%s] 樣本數=%d" % [kill_key, samples.size()])
			for s in samples:
				print("    %s" % str(s))
