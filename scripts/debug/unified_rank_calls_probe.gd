extends SceneTree
# ★`unified.rank.calls` 的【陽性對照】（systems 驗收 2 指定）：
#   ★要證明它是 **opt-in 不是常駐成本** ⇒ `Probe.enabled = false` 時該 counter【不存在】。
#   ★★兩趟同一支床、只差一個旗標：
#     ①enabled=false ⇒ counter 不在 `Probe.counts` 裡（★不是「值為 0」，是 key 根本沒有）
#     ②enabled=true  ⇒ counter 存在且 > 0
#   ★★★壞掉會長什麼樣：若有人日後把 `if Probe.enabled:` 拿掉，①會變成「key 存在」——
#     而那條 tap 每個 spike tick 被呼叫數萬～數十萬次，成本會靜靜長在 release 跑法上。
# env：LW_CONFIG / PERF_SEED / ADHOC_DAYS / PERF_OUT

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var cfg: String = _env("LW_CONFIG", "peaceful_economy")
	var days: int = int(_env("ADHOC_DAYS", "3"))
	var sd: int = int(_env("PERF_SEED", "1337"))
	var lines: Array = []
	# ★三臂（第三臂 2026-08-27 加：sample tap 依賴 phase_timing，要把那個依賴變成【可看見的事實】）
	#   [probe_on, timing_on]
	for arm in [[false, true], [true, true], [true, false]]:
		Probe.reset()
		Probe.enabled = bool(arm[0])
		SimRunner.phase_timing = bool(arm[1])
		var n: int = _run_arm(cfg, days, sd)
		var has_key: bool = Probe.counts.has("unified.rank.calls")
		var has_smp: bool = Probe.samples.has("unified.rank.call_us")
		var has_mkf: bool = Probe.samples.has("mkfill.order") or Probe.counts.has("mkfill.attempt.buy")
		lines.append("Probe.enabled=%-5s phase_timing=%-5s ⇒ calls key 存在=%-5s 值=%-6s｜★call_us 樣本存在=%-5s 筆數=%s（跑了 %d tick）" % [
			str(bool(arm[0])), str(bool(arm[1])), str(has_key),
			str(int(Probe.counts.get("unified.rank.calls", -1))) if has_key else "—",
			str(has_smp),
			str((Probe.samples["unified.rank.call_us"] as Array).size()) if has_smp else "（key 不存在）", n])
		lines.append("      ★mkfill.*（市場撮合 tap）key 存在=%s" % str(has_mkf))
		Probe.enabled = false
		SimRunner.phase_timing = false
	lines.append("★判準①：enabled=false 那列必須是【key 不存在】——★不是「值為 0」。")
	lines.append("★★判準②：enabled=true 但 phase_timing=false 那列，★call_us 樣本【必須不存在】——")
	lines.append("   它的單次耗時取自既有那對計時，關掉 phase_timing 就沒有時間可取。")
	lines.append("   ★★★把這個依賴印成一列事實，而不是寫在註解裡等人記得 ——")
	lines.append("   否則有人只開 Probe 會拿到空樣本，並讀成【沒有慢的呼叫】。")
	lines.append("   （值為 0 代表 bump 有跑只是沒累加；key 不存在才證明整條 tap 被旗標擋在外面。）")
	var text: String = "\n".join(PackedStringArray(lines))
	print("\n" + text)
	var out_path: String = OS.get_environment("PERF_OUT")
	if out_path != "":
		var f := FileAccess.open(out_path, FileAccess.WRITE)
		if f != null:
			f.store_string(text + "\n"); f.close()
	print("=== unified_rank_calls 陽性對照 DONE ===")

func _run_arm(cfg: String, days: int, sd: int) -> int:
	seed(sd)
	FactionAISystem._a2b_remote_tribute_payers.clear()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/%s.json" % cfg)
	if config.is_empty():
		print("[FAIL] config"); return 0
	config["seed"] = sd
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	var n: int = 0
	for _t in range(days * WorldState.TICKS_PER_DAY):
		runner.advance_tick(state, no_player)
		n += 1
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if state.teams.is_empty(): break
	return n

func _env(key: String, dflt: String) -> String:
	var v: String = OS.get_environment(key)
	return v if v != "" else dflt
