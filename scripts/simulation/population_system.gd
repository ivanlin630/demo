class_name PopulationSystem

# TIER: unmigrated(b) — S3 只搬七支，本顆待 S5+
const OVERFLOW_CHECK_INTERVAL: int = WorldState.TICKS_PER_DAY   # 每天檢查
const MATURE_RATE: float = 0.1   # TEST VALUE — 每月 minor 轉成人比例（簡版，無性別/個體年齡）
# ★#18 用：每隊【前一日】人口（★純觀測，只在 Probe.enabled 內讀寫）
static var _pop_last: Dictionary = {}

# ★跨 run 清除（CrossRunReset 單一呼叫點）
static func _reset_cross_run() -> Dictionary:
	var cleared: Dictionary = {}
	if not _pop_last.is_empty(): cleared["PopulationSystem._pop_last"] = _pop_last.size()
	_pop_last.clear()
	return {"checked": 1, "cleared": cleared}

func check_overflow(state: WorldState) -> void:
	# minor 長大簡版：每月 10% minor → 平民 anon（人口循環下游，性別/年齡留人口結構 spec）
	# ★★★同 `modulo-same-shape-4`：外層 `_step1d_overflow` 已被 %1440 過濾，
	#   而 43200%1440==0 ⇒ 現在安全，★而那是算術整除不是機制 ⇒ 一併遷。
	var _dm: Array = HarvestSystem._due(state.world, state.world.minor_mature_next_tick,
		WorldState.TICKS_PER_MONTH)
	state.world.minor_mature_next_tick = int(_dm[1])
	if bool(_dm[0]):
		_mature_minors(state)
	# ★★★順手第四格（systems 2026-09-04）：`minor_population > population` 的隊×tick。
	#   ★背景：4 個寫入點都在出生／成年／饑荒死，★★而【戰鬥傷亡路徑一個都沒有】
	#   ⇒ 若成人死光而 minor 沒跟著減，就會出現「小孩比大人多」的狀態。
	#   ★★★恆 0 ⇒ 那條銷案；非 0 ⇒ 貼隊 id 讓 systems 判是哪條路造成的。
	if Probe.enabled:
		for tid2 in state.teams:
			var t2: TeamData = state.teams[tid2]
			if t2.minor_population > t2.population:
				Probe.bump("minor_exceeds_pop")
				Probe.bump("minor_exceeds_pop.team.%d" % tid2)
	# ★★★格二結算（#3：覓食輸掉之後【真的怎麼了】）——★blueprint 的關鍵一問：
	#   輸掉每一票【有沒有代價】。★★定義寫死在先（免得事後挑）：
	#     `ate`     ＝ N 天內 `effective_food` 比當時【回升】（★經 crisis 那條路真的吃到了 ⇒ 輸 rank 沒代價）
	#     `starved` ＝ 期間 `population` 下降 或 `famine_days` 增加（★★輸掉真的有代價）
	#     `neither` ＝ 活著但沒吃到（★★★兩者之間，原樣報）
	#   ★N ＝ 既有 `DECISION_CADENCE`，不新增常數；★★隊沒了 ⇒ 記 `gone`（那也是後果）
	if Probe.enabled and not FactionAISystem._forage_watch.is_empty():
		var _due: Array = []
		for _wid in FactionAISystem._forage_watch:
			var _w: Dictionary = FactionAISystem._forage_watch[_wid]
			if state.world.current_tick - int(_w.get("tick", 0)) >= FactionAISystem.DECISION_CADENCE:
				_due.append(_wid)
		for _wid2 in _due:
			var _w2: Dictionary = FactionAISystem._forage_watch[_wid2]
			var _t3: TeamData = state.teams.get(_wid2)
			if _t3 == null:
				Probe.bump("mseek.forage.outcome.gone")
			else:
				var _now_food: float = ResourceSystem.effective_food(state, _t3)
				if _t3.population < int(_w2.get("pop", 0)) or _t3.famine_days > float(_w2.get("famine", 0.0)):
					Probe.bump("mseek.forage.outcome.starved")
				elif _now_food > float(_w2.get("food", 0.0)):
					Probe.bump("mseek.forage.outcome.ate")
				else:
					Probe.bump("mseek.forage.outcome.neither")
			FactionAISystem._forage_watch.erase(_wid2)
	# ★★★#18 免費補答（systems 2026-09-04 pilot）：★問的是【團滅到剩 1 人】＝一個【轉變】，
	#   ★★不是「現在 pop==1」—— 後者一直都有（今天 team 52 就是），拿它回答會恆為「有」。
	#   ⇒ 記【前一日 pop > 1 而今日 pop == 1】的那一刻，並存隊 id 供 specimen 回查。
	if Probe.enabled:
		for tid3 in state.teams:
			var t4: TeamData = state.teams[tid3]
			var _prev: int = int(_pop_last.get(tid3, -1))
			if _prev > 1 and t4.population == 1:
				Probe.bump("solo_survivor.transition")
				Probe.bump("solo_survivor.team.%d" % tid3)
				Probe.bump_sample("solo_survivor.sample", {
					"tick": state.world.current_tick, "team": tid3,
					"prev_pop": _prev, "task": t4.current_task,
					"intent": str(t4.solo_intent),   # ★Dictionary ⇒ 原樣存（★不預先詮釋成一個字串標籤）
				}, 100)
			_pop_last[tid3] = t4.population
	for tid in state.teams.keys():
		check_overflow_for_team(state, tid)

func _mature_minors(state: WorldState) -> void:
	# 不設人口上限：長大超過 cap → 同一次 check_overflow 後續的溢出檢查自然分團（移民潮）
	for tid in state.teams:
		var team: TeamData = state.teams[tid]
		if team.minor_population <= 0: continue
		var n: int = maxi(int(team.minor_population * MATURE_RATE), 1)
		n = mini(n, team.minor_population)
		team.minor_population -= n
		AnonTierSystem.add_anon(team, AnonCohort.TIER_PLEB, n)
		print("[PopMgmt] Team%d %d 名未成年長大成人（平民）" % [tid, n])

# ★§4b 唯一新常數（TEST VALUE、R² 判 margin 優於純 delay）：機械拆隊保底的觸發倍率。
# population > cap × 此值 才機械介入；之間的小超額留給決策層（擴點）自己解。
const POP_OVERFLOW_MARGIN: float = 1.15

func check_overflow_for_team(state: WorldState, tid: int) -> void:
	if not state.teams.has(tid):
		return
	var team: TeamData = state.teams[tid]
	# ★農業b ⑥：effective_pop_cap=領導基數×據點放大器（統一取代 PRODUCE-outpost-table/leader-only 分流；
	# L0/無據點→放大器×1=領導帽守 S2a 界線；據點發展→承載更多=size matter via 據點 genuine）。
	var cap: int = FactionAISystem.effective_pop_cap(state, team)
	# ★§4b overflow 決策化（margin-based 保底、非純時間 delay）：小超額留給決策層（擴點 option 的邊際帳
	# 會隨閒勞力/承載壓力升→團主動開分點＝有計畫的擴張），只有滾到顯著超額（決策層明顯沒接住）才機械
	# 介入拆隊。margin 隨 population 成長最終必觸發＝無「決策永遠沒接住」死角；★保底不刪（避免 pop 卡 cap
	# 無出口）。純 delay 與溢出量級無關（小超額與難民潮同一延遲）→ 用 margin 而非時間。
	if float(team.population) <= float(cap) * POP_OVERFLOW_MARGIN:
		return
	var overflow: int = team.population - cap
	if overflow <= 0:
		return
	if Probe.enabled: Probe.bump("overflow_split.mechanical_fire")   # 決策化生效驗：此計數應趨近 0
	var spare_id: int = -1
	for nid in team.named_members:
		if nid != team.leader_id:
			spare_id = nid
			break
	if spare_id != -1:
		SubteamSystem.new().dispatch(state, tid, spare_id, overflow, "idle", team.tile_pos)
		print("[PopMgmt] Team%d 超額 %d 人，advisor Team%d 帶走" % [tid, overflow, spare_id])
	else:
		_create_overflow_team(state, team, overflow)

func _create_overflow_team(state: WorldState, origin: TeamData, overflow_pop: int) -> void:
	var ot := TeamData.new()
	ot.team_id      = state.consume_next_team_id()
	ot.tile_pos     = origin.tile_pos
	state.set_team_faction(ot, -1)   # S11 chokepoint（fresh team，no-op；單寫者一致）
	state.set_team_tags(ot, ["流亡"], "overflow_split")
	ot.current_task = TeamData.TASK_IDLE   # 新 team 建立豁免：overflow 流亡 idle + priority 0
	ot.task_priority = 0
	var frac: float = float(overflow_pop) / float(origin.population)
	for res in origin.resources:
		var amt: float = float(origin.resources.get(res, 0)) * frac
		ResourceBank.set_amt(ot, res, amt, "overflow_split")
		ResourceBank.add(origin, res, -amt, "overflow_split")
	AnonTierSystem.transfer_proportional(origin, ot, overflow_pop)
	state.create_team(ot)   # S9 chokepoint：註冊 + known/discovered init
	var promoted := PersonGenerator.generate_for_team(state, ot, "member")
	if promoted != null:
		ot.leader_id  = promoted.id
		promoted.role = "leader"
	print("[PopMgmt] Team%d 超額 %d 人無 advisor，獨立流亡 Team%d" % [
		origin.team_id, overflow_pop, ot.team_id])

