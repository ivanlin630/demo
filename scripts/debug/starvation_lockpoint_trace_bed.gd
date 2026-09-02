extends SceneTree

# starvation_lockpoint_trace_bed：坐實死隊/逃隊的確切鎖點
# 直接讀 team state（非經 SpecimenTracer）：瀕死隊(food_days<閾值) OR 逃跑隊(TASK_FLEE，
# 不論 food 狀態，捕戰鬥驅動的逃跑動機→行動→結局) 每次取樣記錄
# current_task/combat_target/current_option/food_days/flee_from_pos，抓死亡/消失前軌跡。
# ★QA seed4201 regression 判準要（2026-07-18）：加收 survival_committed_option/
# survival_stall_cooldown，逐 tick 比對偵測「新排除進 cooldown」= stall_exclude fire 事件，
# 印 fire 前後 option + food_days 走勢（判 mis-fire 誤排除正在起作用的 option vs 窮死換無效格）。
# ★blueprint 當前世界故事審（2026-07-19）：加 TASK_FLEE 觸發(不限 food_days)+flee_from_pos，
# 捕「逃跑主導/人口重摔」是否 coherent（真威脅觸發+真逃離某位置）vs broken（對空氣逃）。
# 純觀測，不改 production 邏輯。用法：SPECIMEN_SEED(default 1337) SPECIMEN_MONTHS(default 8)
# FOOD_DAYS_THRESHOLD(default 3.0，低於此才記錄，省開銷)
# ★命名紀律（blueprint 2026-09-02，桶名只准宣稱判準本身）：分類桶「stuck-task」改名「has-committed-option」，
#   自 commit dd174bbd 起——舊量測檔(commit dd174bbd 之前產出)裡寫的是「stuck-task」，同一格，別當孤兒讀。

func _initialize() -> void:
	_run(); quit()

# ★finder-check（systems 2026-07-20 升級）：would_succeed 只驗優先權/combat/reason（dispatch 允許），
# 零 finder → 真 famine(所有 survival option finder-miss 無可達食物)坐 IDLE 也記 would_succeed=true → 誤標手不聽腦。
# 補真 finder：跑 SURVIVAL_OPTION_SET 每 opt 的 to_task，任一有可達 target(≠(-1,-1))=dispatchable。
# ★determinism-safe：DecisionOptions.to_task + 全 survival finder(_find_forage_tile 等)已驗零 randf（觀測不擾動）。
func _survival_finder_hits(state: WorldState, team: TeamData) -> bool:
	for opt in DecisionOptions.options_in_set("survival"):
		var td: Dictionary = DecisionOptions.to_task(state, team, opt)
		var tsk = td.get("task", TeamData.TASK_IDLE)
		var tgt: Vector2i = td.get("target", Vector2i(-1, -1))
		if tsk != TeamData.TASK_IDLE and tgt != Vector2i(-1, -1):
			return true   # 至少一 survival option finder 找到可達 target → 真能派得出（非 finder-miss famine）
	return false

# ★死因 3 分類抽成共用函式（2026-09-02，供「已死隊回溯」與「存活隊即時checkpoint」共用，
#   邏輯零差異——只是後者讓中途被砍的長跑也能拿到即時分類數，不必等 vanished 迴圈）。
func _classify_cause(snap: Dictionary) -> String:
	var _food: float = snap["food_days"]
	var _task: String = String(snap["task"])
	var _committed: String = String(snap["survival_committed_option"])
	var _would_dispatch: bool = bool(snap["would_survival_dispatch_succeed"])
	var _finder_hits: bool = bool(snap.get("survival_finder_hits", false))
	if _would_dispatch and _finder_hits and (_task == "idle" or _task == "等待新領主"):
		return "手不聽腦"
	elif not _finder_hits and _food < FactionAISystem.CRISIS_FLOOR:
		return "famine"
	elif _committed != "":
		return "has-committed-option"
	else:
		return "food-ok"

func _run() -> void:
	var seed_val: int = int(OS.get_environment("SPECIMEN_SEED")) if OS.has_environment("SPECIMEN_SEED") else 1337
	var months: int = int(OS.get_environment("SPECIMEN_MONTHS")) if OS.has_environment("SPECIMEN_MONTHS") else 8
	var threshold: float = float(OS.get_environment("FOOD_DAYS_THRESHOLD")) if OS.has_environment("FOOD_DAYS_THRESHOLD") else 3.0
	# ★對齊 WarringHarness.run()（seeded_warring_bed.gd 用的同一條 setup 序列）——
	# 之前誤用 res://config/default.json + force_full_hd=true，跟 aggregate 量測用的
	# warring_states.json（無 force_full_hd）是完全不同世界，seed 一樣也對不上（血教訓已修）。
	seed(seed_val)
	Probe.enabled = true
	Probe.reset()
	FactionAISystem._a2b_remote_tribute_payers.clear()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config_path: String = OS.get_environment("WARRING_CONFIG") if OS.get_environment("WARRING_CONFIG") != "" else "res://config/warring_states.json"
	var config: Dictionary = GameSetup.load_config(config_path)
	config["seed"] = seed_val
	GameSetup.setup(state, config)

	var known_ids: Dictionary = {}
	for tid in state.teams:
		known_ids[tid] = true
	var last_seen: Dictionary = {}   # team_id -> last near-death snapshot (Dictionary) before it vanished
	var history: Dictionary = {}     # team_id -> Array[snapshot]（最近 300 筆，看軌跡非只最後一刻）
	var fire_events: Dictionary = {}    # team_id -> Array[fire event dict]（stall_exclude 新排除偵測）
	var prev_cooldown_keys: Dictionary = {}   # team_id -> Array[option 字串]（上次看到的 cooldown key 集合，比對增量）

	var total_ticks: int = months * WorldState.TICKS_PER_MONTH
	var no_player := Vector2i(-1, -1)
	print("=== starvation_lockpoint_trace_bed: seed=%d months=%d threshold=%.1f天 ===" % [seed_val, months, threshold])
	for tick in range(total_ticks):
		runner.advance_tick(state, no_player)
		for tid in state.teams:
			var t: TeamData = state.teams[tid]
			known_ids[tid] = true
			var consume: float = float(t.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY
			var eff_food: float = ResourceSystem.effective_food(state, t)
			var food_days: float = eff_food / maxf(consume, 0.001)
			# stall_exclude fire 偵測：不限 food_days<threshold（fire 當下可能 food_days 剛好在門檻邊緣或稍高），
			# 只要曾進過瀕死追蹤（history 已有記錄）的隊，全程比對 cooldown key 增量。
			var cur_cooldown_keys: Array = t.survival_stall_cooldown.keys()
			if prev_cooldown_keys.has(tid):
				var prev_keys: Array = prev_cooldown_keys[tid]
				for k in cur_cooldown_keys:
					if k not in prev_keys:
						if not fire_events.has(tid):
							fire_events[tid] = []
						fire_events[tid].append({
							"tick": tick, "excluded_option": k, "food_days_at_fire": food_days,
							"committed_option_before": t.survival_committed_option,
							"famine_days": t.famine_days,
						})
			prev_cooldown_keys[tid] = cur_cooldown_keys
			if food_days < threshold or t.current_task == TeamData.TASK_FLEE:
				var reason_stripped: String = t.task_reason.trim_prefix("defy_")
				var self_replace_would_work: bool = (t.combat_target == -1) and (
					t.current_task == TeamData.TASK_IDLE or TaskArbiter.PRIO_SURVIVAL > t.task_priority or (
						t.task_priority == TaskArbiter.PRIO_SURVIVAL and "survival" in TaskArbiter.ENGINE_SOURCES
						and reason_stripped in TaskArbiter.ENGINE_SOURCES))
				var finder_hits: bool = _survival_finder_hits(state, t)   # ★真 finder（有可達食物 target）
				var snap: Dictionary = {
					"tick": tick, "team_id": tid, "task": t.current_task,
					"combat_target": t.combat_target, "current_option": t.current_option,
					"food_days": food_days, "pop": t.population, "famine_days": t.famine_days,
					"task_priority": t.task_priority, "task_reason": t.task_reason,
					"would_survival_dispatch_succeed": self_replace_would_work,
					"survival_finder_hits": finder_hits,
					"survival_committed_option": t.survival_committed_option,
					"survival_stall_cooldown_keys": str(cur_cooldown_keys),
					"tile_pos": t.tile_pos, "move_target": t.move_target,
					"flee_from_pos": t.flee_from_pos,
				}
				# ★slice2-perception QA要：belief-vs-live 落差（併入/absorb target 用 belief_pos 導航，
				# 對照 target 真 live tile_pos，看是否『信念位置跟真實位置不同→走錯路』新模式）。
				if t.absorb_target_cache != -1 and state.teams.has(t.absorb_target_cache):
					var tgt_team: TeamData = state.teams[t.absorb_target_cache]
					var bp: Vector2i = BeliefSystem.belief_pos(state, tid, t.absorb_target_cache)
					snap["absorb_target_id"] = t.absorb_target_cache
					snap["absorb_target_belief_pos"] = bp
					snap["absorb_target_live_pos"] = tgt_team.tile_pos
					snap["belief_vs_live_gap"] = (bp - tgt_team.tile_pos).length() if bp != Vector2i(-1, -1) else -1.0
				last_seen[tid] = snap
				if not history.has(tid):
					history[tid] = []
				var h: Array = history[tid]
				h.append(snap)
				if h.size() > 300:
					h.pop_front()
		if tick % 5000 == 0:
			print("[progress] tick=%d teams=%d near_death_tracked=%d" % [tick, state.teams.size(), last_seen.size()])
		if tick % 20000 == 0 and tick > 0 and not last_seen.is_empty():
			var _tally: Dictionary = {"手不聽腦": 0, "famine": 0, "has-committed-option": 0, "food-ok": 0}
			for _tid2 in last_seen.keys():
				var _c: String = _classify_cause(last_seen[_tid2])
				_tally[_c] = _tally.get(_c, 0) + 1
			print("[LIVE-CHECKPOINT] tick=%d 機會母體(near_death_tracked)=%d 分類={手不聽腦=%d famine=%d has-committed-option=%d food-ok=%d}" % [
				tick, last_seen.size(), _tally["手不聽腦"], _tally["famine"], _tally["has-committed-option"], _tally["food-ok"]])
			# ★systems 2026-09-02 授權：只對「手不聽腦」命中隊印逐隊明細（不印全部161隊，訊號稀釋）
			for _tid3 in last_seen.keys():
				if _classify_cause(last_seen[_tid3]) == "手不聽腦":
					var _s: Dictionary = last_seen[_tid3]
					print("    [LIVE-CHECKPOINT-DETAIL] team=%d tick=%d task=%s prio=%d reason=%s food_days=%.2f pop=%d famine_days=%.1f committed=%s finder_hits=%s" % [
						_tid3, _s["tick"], String(_s["task"]), _s["task_priority"], String(_s["task_reason"]),
						_s["food_days"], _s["pop"], _s["famine_days"], String(_s["survival_committed_option"]), str(_s.get("survival_finder_hits", false))])
					# ★★★per-option util 表【接到正確母體上】（systems 改票 2026-09-02）：
					#   ★上一版我把表 dump 在 funnel bed 的 3 次 lost 上 —— ★★而那是【健康隊、開局兩天內】
					#     （pop 8-9／runway 35-40 天／famine=0），不是 #10 的瀕死隊 ⇒ 母體錯
					#   ⇒ ★★★同一支表，接在【手不聽腦命中】這個判定點上。
					# ★而表【不是這裡重算的】：它是 production funnel（`_decide_unified`）在真決策當下寫的
					#   ⇒ ★★這裡只是【把它撈出來】—— ★★★若在這裡呼 rank_scored，那會推進 EWMA ＝
					#     觀測改變被觀測物，而這張床的整個價值就是它沒有改變世界。
					var _tabs: Array = Probe.samples.get("redispatch.lost_table", []) as Array
					# ★★★樣本數必印：`bump_sample` 是 first-N ⇒ ★滿了之後【後面的一筆都寫不進來】
					#   ⇒ ★★「撈不到表」要分得出【funnel 沒 fire】與【cap 早就滿了】
					if _tabs.size() >= 20000:
						print("      [UTIL-TABLE] ★★★警告：lost_table 樣本已達 cap(20000) ⇒ 後續未收錄，下面的「無表」不可讀成「沒發生」")
					var _hit: Dictionary = {}
					for _t4 in _tabs:
						if int((_t4 as Dictionary).get("team", -1)) == int(_tid3):
							_hit = _t4 as Dictionary
					if _hit.is_empty():
						# ★沒有表【不是「沒資料」】：funnel 只在 committed != "" 時 fire
						#   ⇒ ★★committed=="" 的手不聽腦隊，【再派本身無從發生】——那是另一回事
						print("      [UTIL-TABLE] team=%d 無表 ⇒ %s" % [_tid3,
							"committed 為空 ⇒ funnel 依設計不 fire（再派無標的）"
								if String(_s["survival_committed_option"]) == ""
								else "★committed 非空卻無表 ⇒ 這隊沒走到決策 entry（cadence/早退），要查"])
					else:
						print("      [UTIL-TABLE] team=%d tick=%s committed=%s current_option=%s persist_applies=%s persist=%s"
							% [_tid3, str(_hit["tick"]), String(_hit["committed"]), String(_hit["current_option"]),
							   str(_hit["persist_applies"]), str(_hit["persist_strength"])])
						print("      [UTIL-TABLE] 承諾 u=%s ／ 贏家 %s u=%s ／ 差距 %s ／ 現況 pop=%s runway=%s famine=%s"
							% [str(_hit["committed_u"]), String(_hit["winner"]), str(_hit["winner_u"]), str(_hit["gap"]),
							   str(_hit["pop"]), str(_hit["food_runway"]), str(_hit["famine_days"])])
						for _c2 in (_hit["table"] as Array):
							print("        %-12s u=%s" % [String((_c2 as Dictionary)["opt"]), str((_c2 as Dictionary)["u"])])
		if state.teams.is_empty():
			break

	# 找出消失的隊（known 但現在 state.teams 沒有）= 已滅團（餓死或其他因）
	print("\n=== 消失隊清單（known_ids 有、現 state.teams 無）===")
	var vanished: Array = []
	for tid in known_ids.keys():
		if not state.teams.has(tid):
			vanished.append(tid)
	vanished.sort()
	print("消失隊數=%d：%s" % [vanished.size(), str(vanished)])

	print("\n=== 消失隊死前鎖點（僅印曾被記錄=曾瀕死的） ===")
	for tid in vanished:
		if not last_seen.has(tid):
			print("--- team=%d：從未進入瀕死追蹤(food_days<%.1f)——非本輪diagnostic對象(可能戰死/其他) ---" % [tid, threshold])
			continue
		print("--- team=%d 死前軌跡（最近 %d 筆瀕死快照） ---" % [tid, history[tid].size()])
		for snap in history[tid]:
			var extra: String = ""
			if snap.has("belief_vs_live_gap"):
				extra = " absorb_target=%d belief_pos=%s live_pos=%s gap=%.1f" % [
					snap["absorb_target_id"], str(snap["absorb_target_belief_pos"]),
					str(snap["absorb_target_live_pos"]), snap["belief_vs_live_gap"]]
			print("    tick=%d task=%s prio=%d reason=%s combat_target=%d option=%s food_days=%.2f pop=%d famine_days=%.1f tile=%s move_target=%s flee_from=%s committed=%s cooldown=%s survival_dispatch_would_succeed=%s finder_hits=%s%s" % [
				snap["tick"], String(snap["task"]), snap["task_priority"], String(snap["task_reason"]),
				snap["combat_target"], String(snap["current_option"]),
				snap["food_days"], snap["pop"], snap["famine_days"],
				str(snap["tile_pos"]), str(snap["move_target"]), str(snap["flee_from_pos"]),
				String(snap["survival_committed_option"]), String(snap["survival_stall_cooldown_keys"]),
				str(snap["would_survival_dispatch_succeed"]), str(snap.get("survival_finder_hits", false)), extra])
		if fire_events.has(tid):
			print("    ★★ stall_exclude FIRE 事件（%d 次）：" % fire_events[tid].size())
			for ev in fire_events[tid]:
				print("      tick=%d 排除=%s (排除前承諾option=%s) food_days_at_fire=%.2f famine_days=%.1f" % [
					ev["tick"], String(ev["excluded_option"]), String(ev["committed_option_before"]),
					ev["food_days_at_fire"], ev["famine_days"]])
		# ★死因 3 分類（systems 批 2026-07-19，取代單軸「純窮死=無 stall_exclude fire」誤標）：
		# 舊標籤只表「無 stall_exclude」≠ 真缺糧，會把手不聽腦 stuck（food 足卻坐死）誤標餓死＝量測盲點捏假故事
		# （全量暫態可觀測性不變量正解）。純觀測：只讀已收集 snapshot 末筆，不碰 sim state/RNG（determinism-safe）。
		var _ls: Dictionary = history[tid][history[tid].size() - 1]
		var _food: float = _ls["food_days"]
		var _task: String = String(_ls["task"])
		var _committed: String = String(_ls["survival_committed_option"])
		var _would_dispatch: bool = bool(_ls["would_survival_dispatch_succeed"])
		var _finder_hits: bool = bool(_ls.get("survival_finder_hits", false))
		var _cause: String = ""
		# ★凍結-lens 優先於 food-lens + finder-check（systems 2026-07-20 兩封）：
		# would_succeed 只驗優先權/combat/reason（dispatch 允許），零 finder → 真 famine(所有 survival option
		# finder-miss 無可達食物)坐 IDLE 也 would_succeed=true → 誤標手不聽腦。∴ 手不聽腦 = dispatch 允許
		# (would_succeed) AND 真有可達食物(finder_hits) 卻坐 idle/等待新領主 = 真凍結（能派得出卻沒派）；
		# famine = finder 全 miss（真無可達食物）+ 深餓，不管 would_succeed（team21/65 若 finder-miss=真餓非凍結）。
		if _would_dispatch and _finder_hits and (_task == "idle" or _task == "等待新領主"):
			_cause = "手不聽腦（would_succeed=true+finder有可達食物 卻 task=%s 不執行 food_days=%.2f＝真凍結,slice1可治）" % [_task, _food]
		elif not _finder_hits and _food < FactionAISystem.CRISIS_FLOOR:
			_cause = "famine（finder全miss無可達食物 + food_days=%.2f<CRISIS_FLOOR=%.1f＝真餓,slice1救不了=經濟/可得性問題）" % [_food, FactionAISystem.CRISIS_FLOOR]
		elif _committed != "":
			_cause = "has-committed-option（food_days=%.2f 足 + committed=%s 卻消失＝當下有承諾option,不代表卡住,判準只到此）" % [_food, _committed]
		else:
			_cause = "food-ok-vanish（food_days=%.2f 足、無 stuck 徵兆＝疑 merge/combat/absorb 非餓死）" % _food
		print("    ★死因分類=%s%s" % [_cause, "" if fire_events.has(tid) else "（死前無 stall_exclude fire）"])
	print("=== DONE ===")
