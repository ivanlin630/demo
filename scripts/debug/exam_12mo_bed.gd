extends SceneTree
# ★12mo 大考 run harness（純觀測、零 production 行為改動）。
# 動機：跨 run 比較被 CPU contention + config 差異污染 → k 值誠實 NULL；12mo 是【單一連續 run 內 N 自然
# 成長】＝天然消掉那兩個 confound → 唯一能乾淨回答 O(N) vs O(N²) 的機會 → 必須一次抓齊（漏開＝重跑 12 月）。
#
# env（皆走 godot-detach.ps1 白名單）：
#   PERF_SEED    seed（default 1337）
#   LW_CONFIG    config 名（default warring_states）
#   LW_MONTHS    月數（default 12）
#   WARRING_OUT  JSONL 落檔路徑（★增量 flush：被 reap 也留 partial）
#   SPECIMEN_SAMPLE_N / SPECIMEN_TEAM_ID  → SpecimenDumpHelper（逐隊 motive→action→outcome）
#   WARRING_PROGRESS  進度 sidecar（選用）
#   ADHOC_TICKS  短窗覆寫 tick 數（smoke gate 用）
#
# 每日一筆 JSONL：tick / N_teams / N_persons / per-tick us（avg+max）/ 六階段 phase breakdown
#   + 監看清單：mint_level 分佈、瞬時 daily_rate==0 的隊數（零產出卡死病型、★非 EMA）、
#     site_memory.write vs applied（§4c eviction）、need.ewma_advance & 隊數（推進 ≤1/隊/tick）、
#     starve 事件明細（death.starve_*）、政治事件計數（diplo/alliance/betray 家族）、
#     ★統領分佈 + effective_pop_cap 分佈（addendum-2、科目 A「世界是否領導荒」具名檢查）。

func _initialize() -> void:
	_run(); quit()

func _env(name: String, dflt: String) -> String:
	var v: String = OS.get_environment(name)
	return v if v != "" else dflt

func _run() -> void:
	var seed_v: int = int(_env("PERF_SEED", "1337"))
	var cfg: String = _env("LW_CONFIG", "warring_states")
	var months: int = int(_env("LW_MONTHS", "12"))
	var out_path: String = _env("WARRING_OUT", "docs/measurements/exam_12mo.jsonl")
	var prog_path: String = _env("WARRING_PROGRESS", "")
	var ticks: int = maxi(months, 1) * WorldState.TICKS_PER_MONTH
	if _env("ADHOC_TICKS", "") != "":
		ticks = int(_env("ADHOC_TICKS", "0"))   # 短窗覆寫（gate smoke 用；白名單 env）
	print("=== exam 12mo harness：seed=%d config=%s months=%d (ticks=%d) out=%s ===" % [
		seed_v, cfg, months, ticks, out_path])

	seed(seed_v)
	Probe.enabled = true
	Probe.reset()
	SimRunner.phase_timing = true   # ★opt-in 相位計時（預設 off；此處只為量測、不改行為）
	FactionAISystem._a2b_remote_tribute_payers.clear()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/%s.json" % cfg)
	if config.is_empty():
		print("[exam] ✗ config 載入失敗：%s" % cfg); return
	config["seed"] = seed_v
	GameSetup.setup(state, config)
	SpecimenDumpHelper.setup_from_env(state)   # ★同 run 併掛 specimen trace（QA 故事稽核用）

	var f: FileAccess = FileAccess.open(out_path, FileAccess.WRITE)
	var no_player := Vector2i(-1, -1)
	var day_us: int = 0
	var day_max_us: int = 0
	var day_ticks: int = 0
	var phase_acc: Dictionary = {}
	var prev_food: Dictionary = {}          # team_id → 上次日採樣的 effective_food（算瞬時 daily_rate）
	var prev_probe: Dictionary = {}         # probe key → 上次值（算當日增量）
	for t in range(ticks):
		var t0: int = Time.get_ticks_usec()
		runner.advance_tick(state, no_player)
		var dt: int = Time.get_ticks_usec() - t0
		day_us += dt; day_ticks += 1
		if dt > day_max_us: day_max_us = dt
		for ph in runner._ph:
			phase_acc[ph] = int(phase_acc.get(ph, 0)) + int(runner._ph[ph])
		if (t + 1) % WorldState.TICKS_PER_DAY != 0:
			continue
		# ── 每日一筆 ──
		var day: int = (t + 1) / WorldState.TICKS_PER_DAY
		var row: Dictionary = {
			"day": day, "tick": state.world.current_tick,
			"n_teams": state.teams.size(), "n_persons": state.persons.size(),
			"n_factions": state.factions.size(),
			"tick_us_avg": int(float(day_us) / maxf(float(day_ticks), 1.0)), "tick_us_max": day_max_us,
			"phase_us": phase_acc.duplicate(),
		}
		# mint_level 分佈 + 據點數
		var mint: Dictionary = {}
		for tile_id in state.world.tiles:
			var tl: HexTileData = state.world.tiles[tile_id]
			if tl.outpost_level <= 0: continue
			var k: String = "L%d" % tl.mint_level
			mint[k] = int(mint.get(k, 0)) + 1
		row["mint_level_dist"] = mint
		# ★addendum-2（blueprint 具名、科目 A 檢查）：統領分佈 + effective_pop_cap 分佈
		#   → 判「世界是否領導荒」（領導帽是 CONFIRMED 設計意圖，基數 tune/統領成長才是變數）。
		var cmds: Array = []
		var caps: Array = []
		for tid2 in state.teams:
			var tm: TeamData = state.teams[tid2]
			var l2: PersonData = state.persons.get(tm.leader_id)
			cmds.append(float(l2.skills.get("統領", 0.0)) if l2 != null else 0.0)
			caps.append(FactionAISystem.effective_pop_cap(state, tm))
		cmds.sort(); caps.sort()
		var cmd_hist: Dictionary = {}
		for cv in cmds:
			var b: String = "%.1f" % (floorf(float(cv) * 10.0) / 10.0)
			cmd_hist[b] = int(cmd_hist.get(b, 0)) + 1
		var cap_hist: Dictionary = {}
		for cv2 in caps:
			var cb: String = "<10" if int(cv2) < 10 else ("10-19" if int(cv2) < 20 else ("20-49" if int(cv2) < 50 else ">=50"))
			cap_hist[cb] = int(cap_hist.get(cb, 0)) + 1
		row["cmd_dist"] = {
			"min": (cmds[0] if not cmds.is_empty() else 0.0),
			"median": (cmds[cmds.size() / 2] if not cmds.is_empty() else 0.0),
			"max": (cmds[-1] if not cmds.is_empty() else 0.0),
			"hist": cmd_hist,
		}
		row["eff_pop_cap_dist"] = {
			"min": (caps[0] if not caps.is_empty() else 0),
			"median": (caps[caps.size() / 2] if not caps.is_empty() else 0),
			"max": (caps[-1] if not caps.is_empty() else 0),
			"hist": cap_hist,
		}
		# ★瞬時 daily_rate（非 EMA、QA 判 EMA 分類不可信）：今日 food − 昨日 food
		var zero_rate: int = 0
		var neg_rate: int = 0
		var rates: Dictionary = {}
		for tid in state.teams:
			var team: TeamData = state.teams[tid]
			var food_now: float = ResourceSystem.effective_food(state, team)
			if prev_food.has(tid):
				var rate: float = food_now - float(prev_food[tid])
				rates[tid] = rate
				if absf(rate) < 0.001: zero_rate += 1
				elif rate < 0.0: neg_rate += 1
			prev_food[tid] = food_now
		row["daily_rate_zero_teams"] = zero_rate
		row["daily_rate_neg_teams"] = neg_rate
		row["daily_rate_sampled"] = rates.size()
		# probe 家族當日增量（starve/政治/§4c/EWMA）
		# ★訂單簿 tap：加 trade./order.（原過濾器把訂單家族整個漏掉＝世界級數字事後救不回）
		var watch_prefixes: Array = ["death.", "site_memory.", "need.", "diplo", "alliance", "betray",
			"faction.", "trade.", "order."]
		var deltas: Dictionary = {}
		for key in Probe.counts.keys():
			var ks: String = String(key)
			var hit: bool = false
			for pre in watch_prefixes:
				if ks.begins_with(String(pre)): hit = true; break
			if not hit: continue
			var now_v: int = int(Probe.counts[key])
			var d: int = now_v - int(prev_probe.get(ks, 0))
			prev_probe[ks] = now_v
			if d != 0: deltas[ks] = d
		row["probe_delta"] = deltas
		# 推進 ≤1/隊/tick 檢查料（當日 advance 增量 vs 隊數×當日 tick 數）
		row["ewma_advance_day"] = int(deltas.get("need.ewma_advance", 0))
		row["ewma_advance_budget"] = state.teams.size() * day_ticks
		if f != null:
			f.store_line(JSON.stringify(row))
			if day % 5 == 0: f.flush()   # ★增量落檔（被 reap 也留 partial）
		if prog_path != "" and day % 5 == 0:
			var pf := FileAccess.open(prog_path, FileAccess.WRITE)
			if pf != null:
				pf.store_string("[exam] day %d/%d teams=%d persons=%d avg_us=%d\n" % [
					day, ticks / WorldState.TICKS_PER_DAY, state.teams.size(), state.persons.size(),
					row["tick_us_avg"]])
				pf.close()
		day_us = 0; day_max_us = 0; day_ticks = 0; phase_acc.clear()
		if state.teams.is_empty():
			print("[exam] 全滅 @day=%d" % day); break
	# ★結尾 dump 全量 Probe.counts（成本近零、保住所有未預見的問題——這輪的教訓：
	# 過濾器沒列到的 family 事後完全救不回）。JSONL 最後一行。
	if f != null:
		var _all: Dictionary = {}
		for _k in Probe.counts.keys():
			_all[String(_k)] = int(Probe.counts[_k])
		var _samples: Dictionary = {}
		for _sk in Probe.samples.keys():
			_samples[String(_sk)] = Probe.samples[_sk]
		f.store_line(JSON.stringify({"final_probe_counts": _all, "final_probe_samples": _samples}))
	if f != null: f.close()
	SpecimenDumpHelper.dump(state, _env("SPECIMEN_OUT", "docs/measurements/exam_12mo.specimen.jsonl"))
	SimRunner.phase_timing = false
	Probe.enabled = false
	print("=== exam harness DONE（JSONL → %s）===" % out_path)
