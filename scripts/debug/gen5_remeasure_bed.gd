extends SceneTree
# @bed-kind: acceptance
# slice: 世代5(sha 2fb10d7c1)重量測——HOW spec docs/superpowers/specs/2026-09-16-gen5-remeasure-HOW.md
#
# ★本床答四格＋一個(4a)/(4b)分類，★★主因是【比率需要多seed】(spec原句)：
#   ①處境攻擊成對反事實(餓且有牙 argmax會贏／飽且目標硬仍不打)——用真世界隊+production rank_scored_ctx，非合成ctx
#   ②偵查真發生：recon.dispatch.ok>0 對照舊走廊g3.scout_dispatch全窗=0
#   ③先驗被取代逐筆證據——復用scout_on_the_scale_bed.gd §A同款fixture手法(day0,不跑世界)
#   ④粒度桶1/2/3嚴格單調——純讀常數表(day0)，同③手法
#   (4a)/(4b)：擋攻擊的「優先序不足」現任task，用DecisionOptions.priority_for()靜態上限分類，
#     ★★迎戰(THREAT=70)/外交・貿易(DISPATCH=50，靜態無衰減)可定；
#     ★★★覓食/乞食/投靠/return_home/逃跑=survival-class(priority_for_need會依food_days衰減到50)
#     ⇒★這五個【靠聚合分不出逐筆】——本床誠實列為「待逐筆tap」，不猜。
#
# ★已知限制(2026-09-16系統床通則)：
#   ①逐日flush=②③④⑤大部分欄位；★唯獨①(paired argmax真隊搜尋)只在窗末print累計(找到即記,可提早知道
#     「有出現過」但「至今仍沒出現」要等窗末字樣才印)；被殺只會丟①的窗末彙總行,不丟②③④(它們逐日已印)。
#   ★多seed跑法=外層迴圈重開SceneTree不可行(godot單進程一趟只能一個seed)⇒改用ps1包裝跑多次、
#     每次獨立寫log，本檔本身仍是單seed一趟（env BED_SEED控制），彙總在跑完後由跑法腳本做。
#
# env：BED_DAYS(預設10)／BED_SEED(預設1337)／BED_CONFIG(預設warring_states)
# ★跑法：GODOT_TIMEOUT>=1800對長窗；本床預設10天窗已足(scout_on_the_scale_bed血證：目前無欄位真需30天)。

func _initialize() -> void:
	_run(); quit()

func _ok(cond: bool, msg: String) -> void:
	if cond: print("  [OK] %s" % msg)
	else: push_error("  [FAIL] %s" % msg)

func _feasible_has(scan: Dictionary, tid: int) -> bool:
	for f in (scan.get("feasible", []) as Array):
		if int((f as Dictionary).get("id", -1)) == tid: return true
	return false

func _run() -> void:
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 10
	var seed_val: int = int(OS.get_environment("BED_SEED")) if OS.has_environment("BED_SEED") else 1337
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "warring_states"
	print("=== gen5_remeasure_bed: config=%s days=%d seed=%d ===" % [cfg, days, seed_val])
	print("[HOST] start FreeMB=%.0f" % (float(OS.get_static_memory_usage()) / 1048576.0))

	# ══════ ③④ day0 fixture(復用scout_on_the_scale_bed §A手法，不跑世界) ══════
	seed(seed_val)
	var fx: WorldState = MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg)
	var obs: TeamData = null
	var tgt: TeamData = null
	var best_d: int = 1 << 30
	for a in fx.teams.values():
		if a == null or a.leader_id == -1 or fx.persons.get(a.leader_id) == null: continue
		for b in fx.teams.values():
			if b == null or a.team_id == b.team_id: continue
			if a.faction_id != -1 and a.faction_id == b.faction_id: continue
			var d: int = FactionAISystem._hex_dist(a.tile_pos, b.tile_pos)
			if d < best_d: best_d = d; obs = a; tgt = b
	if obs == null or tgt == null:
		push_error("[FAIL] §A母體0：找不到異派系隊對⇒③不可判")
	else:
		var ldr: PersonData = fx.persons.get(obs.leader_id)
		if fx.team_intel.has(obs.team_id): (fx.team_intel[obs.team_id] as Dictionary).erase(tgt.team_id)
		var pick_blind: Dictionary = DecisionContext.pick_recon_target(fx, obs)
		var was_blind_pick: bool = int(pick_blind["id"]) == tgt.team_id and bool(pick_blind["blind"])
		BeliefSystem.record_claim(fx, obs.team_id, tgt.team_id, obs.team_id, "firsthand",
			{"tile_pos": tgt.tile_pos, "resource_scale": 2, "coin_est": 300.0,
			"food_est": 120.0, "population_est": float(tgt.population)}, 1.0, false)
		var pick_priced: Dictionary = DecisionContext.pick_recon_target(fx, obs)
		var still_picked: bool = int(pick_priced["id"]) == tgt.team_id
		print("★③逐筆：Team%d→Team%d｜情報到手前偵查挑中=%s(blind=%s)｜到手後偵查仍挑中=%s" % [
			obs.team_id, tgt.team_id, str(was_blind_pick), str(bool(pick_blind["blind"])), str(still_picked)])
		_ok(was_blind_pick, "③-a 到手前：它是偵查候選(先驗具名blind=true)")
		_ok(not still_picked, "③-b 到手後：先驗被取代⇒不再是偵查候選(同一目標，逐筆非聚合)")

	var _ref_obs: float = FactionAISystem.reference_wealth(fx, obs) if obs != null else 1.0
	var _r1: float = FactionAISystem.richness_compressed(FactionAISystem.bucket_floor(1), _ref_obs)
	var _r2: float = FactionAISystem.richness_compressed(FactionAISystem.bucket_floor(2), _ref_obs)
	var _r3: float = FactionAISystem.richness_compressed(FactionAISystem.bucket_floor(3), _ref_obs)
	print("★④粒度：桶1=%.4f 桶2=%.4f 桶3=%.4f（CAP=%.2f）" % [_r1, _r2, _r3, FactionAISystem.TEAM_RICHNESS_CAP])
	_ok(_r1 < _r2 and _r2 < _r3, "④-a 嚴格單調")
	_ok(_r1 > 0.0, "④-b 最小桶 > 0")
	_ok(_r3 < FactionAISystem.TEAM_RICHNESS_CAP, "④-c 最大桶 < CAP")

	# ══════ (4a)/(4b) 靜態上限分類(day0，純讀函式，不看樣本) ══════
	print("")
	print("★(4a)/(4b) 分類：擋攻擊(own_priority=%d PRIO_DISPATCH)的現任task，priority_for()靜態上限" % TaskArbiter.PRIO_DISPATCH)
	var holder_tasks: Array = ["迎戰", "覓食", "return_home", "逃跑", "投靠", "外交", "乞食", "貿易"]
	var holder_opt_name: Dictionary = {"迎戰": "迎戰", "覓食": "覓食", "return_home": "返家補給",
		"逃跑": "survival", "投靠": "併入", "外交": "外交", "乞食": "乞食", "貿易": "貿易"}
	for h in holder_tasks:
		var opt_name: String = String(holder_opt_name.get(h, h))
		var static_prio: int = DecisionOptions.priority_for(opt_name)
		var verdict: String
		if static_prio > TaskArbiter.PRIO_DISPATCH and static_prio != TaskArbiter.PRIO_SURVIVAL:
			verdict = "確定(4a)——靜態優先序%d不衰減，恆>攻擊" % static_prio
		elif static_prio == TaskArbiter.PRIO_SURVIVAL:
			verdict = "★待逐筆——survival-class經priority_for_need依food_days衰減，可能80(4a)也可能50(4b)，聚合分不出"
		else:
			verdict = "確定(4b)手不聽腦——靜態優先序%d==攻擊，恆不應擋住" % static_prio
		print("   holder=%-12s opt=%-8s priority_for=%d ⇒ %s" % [h, opt_name, static_prio, verdict])
	print("   ★★★上面「待逐筆」那幾支的621次分佈需要真實樣本(現任task×tick的task_priority)才能定案，")
	print("      本床不猜——已另發tap-gap信給systems/implementer(仿_note_seek_deny加通用逐筆sample)。")

	# ══════ ①②世界跑一趟（真隊argmax paired反事實 + 偵查三數） ══════
	Probe.reset(); Probe.arm()
	seed(seed_val)
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg)
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)
	var ticks: int = days * WorldState.TICKS_PER_DAY
	var found_hungry_teeth_win: bool = false
	var found_hungry_teeth_case: String = ""
	var full_hard_checked: int = 0
	var full_hard_still_no_attack: int = 0
	var full_hard_counterexample: String = ""

	for tick in range(ticks):
		runner.advance_tick(st, no_player)
		if (tick + 1) % WorldState.TICKS_PER_DAY == 0:
			var d: int = (tick + 1) / WorldState.TICKS_PER_DAY
			# ①每7天抽一次全隊快照做paired反事實搜尋（找到就記,不重找同結論）
			if d % 7 == 0 or d == days:
				for tid in st.teams:
					var team: TeamData = st.teams[tid]
					if team == null or team.leader_id == -1: continue
					var leader: PersonData = st.persons.get(team.leader_id)
					if leader == null: continue
					var pop: int = team.population
					if pop <= 0: continue
					var need: float = maxf(float(pop) * ResourceSystem.FOOD_PER_PERSON_PER_DAY, 0.001)
					var fd: float = ResourceSystem.effective_food(st, team) / need
					var armed: float = FactionAISystem.new()._calc_own_armed(st, team)
					if not found_hungry_teeth_win and fd < DecisionTerms.DESPERATION_DAYS and armed > 0.0:
						var ctx: DecisionContext = DecisionContext.gather(st, team, false)
						var scored: Array = DecisionEngine.rank_scored_ctx(ctx, team.current_option, st, team)
						if not scored.is_empty() and String(scored[0]["opt"]) == "攻擊":
							found_hungry_teeth_win = true
							found_hungry_teeth_case = "day=%d team=%d food_days=%.2f armed=%.2f winner_u=%.4f" % [
								d, team.team_id, fd, armed, float(scored[0]["u"])]
					if fd > 10.0:
						var ctx2: DecisionContext = DecisionContext.gather(st, team, false)
						var scored2: Array = DecisionEngine.rank_scored_ctx(ctx2, team.current_option, st, team)
						if not scored2.is_empty():
							full_hard_checked += 1
							if String(scored2[0]["opt"]) != "攻擊":
								full_hard_still_no_attack += 1
							elif full_hard_counterexample == "":
								full_hard_counterexample = "day=%d team=%d food_days=%.2f 卻贏了攻擊argmax" % [d, team.team_id, fd]
			print("[WINDOW] day=%d/%d status=running" % [d, days])
			print("[DAILY] day=%d recon.cand=%d recon.win=%d recon.dispatch.ok=%d g3.scout_dispatch=%d atk.cand=%d atk.win=%d" % [
				d, int(Probe.counts.get("optpool.cand.偵查", 0)), int(Probe.counts.get("optpool.win.偵查", 0)),
				int(Probe.counts.get("recon.dispatch.ok", 0)), int(Probe.counts.get("g3.scout_dispatch", 0)),
				int(Probe.counts.get("optpool.cand.攻擊", 0)), int(Probe.counts.get("optpool.win.攻擊", 0))])

	print("[HOST] end FreeMB=%.0f" % (float(OS.get_static_memory_usage()) / 1048576.0))
	print("")
	print("★①paired反事實(真隊，非合成ctx，DecisionContext.gather+rank_scored_ctx)：")
	if found_hungry_teeth_win:
		print("   ★★餓且有牙 ⇒ 攻擊贏argmax：出現過⇒%s" % found_hungry_teeth_case)
	else:
		print("   ★★餓且有牙 ⇒ 攻擊贏argmax：至今(窗=%d天)仍未出現(不能證明永遠不發生，只能說到此為止=0)" % days)
	print("   ★對照：飽(food_days>10)時仍不打攻擊argmax = %d/%d 次（反例：%s）" % [
		full_hard_still_no_attack, full_hard_checked,
		full_hard_counterexample if full_hard_counterexample != "" else "（無）"])
	print("      ★兩格必須方向相反才算成對：前者出現＋後者絕大多數守住⇒成對成立")

	var e_cand: int = int(Probe.counts.get("optpool.cand.偵查", 0))
	var e_win: int = int(Probe.counts.get("optpool.win.偵查", 0))
	var e_eng: int = int(Probe.counts.get("recon.dispatch.ok", 0))
	var e_cor: int = int(Probe.counts.get("g3.scout_dispatch", 0))
	print("")
	print("★②偵查三數（全窗%d天）：候選=%d／贏=%d／真設上(recon.dispatch.ok)=%d｜舊走廊g3.scout_dispatch=%d" % [
		days, e_cand, e_win, e_eng, e_cor])
	_ok(e_eng > 0 or e_cand == 0, "②-a recon.dispatch.engine.ok>0（若母體0則不可判，非紅）")
	_ok(e_cor == 0, "②-b 舊走廊全窗=0（新制下不該再產生偵查）")
	if e_cand > 0:
		var eng_noop: int = int(Probe.counts.get("recon.dispatch.noop", 0))
		var deny_total: int = 0
		for k in Probe.counts:
			var ks: String = String(k)
			if ks.begins_with("arbiter.deny.") and ks.ends_with(".opt.偵查"):
				deny_total += int(Probe.counts[k])
		print("   對帳：設上%d + no-op%d = %d ｜ 拒絕表合計=%d（%s）" % [
			e_eng, eng_noop, e_eng + eng_noop, deny_total,
			"對上" if eng_noop == deny_total else "★★對不上⇒先查儀器"])

	print("")
	print("[WINDOW] day=%d/%d status=completed reason=window_reached" % [days, days])
	print("=== gen5_remeasure_bed DONE (seed=%d) ===" % seed_val)
