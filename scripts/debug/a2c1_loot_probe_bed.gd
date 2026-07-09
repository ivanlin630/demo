extends SceneTree

# 職業搶匪量測 harness（純 debug/infra，零 sim 邏輯變）。
# 沿用 WarringHarness.run，額外 dump Probe.peaks（loot_util/loot_lead 峰值，非分布——
# 現有 Probe.note 只存單run內max，無per-event log/fed-starve分層，需改 faction_ai_system.gd
# 才拿得到，本 bed 不動 scripts/simulation，如實只給拿得到的聚合）。
#
# 用法：WARRING_SEEDS=1337,42,7 WARRING_MONTHS=3 LOOT_OUT=<path> godot --script a2c1_loot_probe_bed.gd

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var seeds: Array = _parse_seeds()
	var months: int = int(OS.get_environment("WARRING_MONTHS")) if OS.has_environment("WARRING_MONTHS") else 3
	var ticks: int = maxi(months, 1) * WorldState.TICKS_PER_MONTH
	print("=== a2c1_loot_probe_bed：seeds=%s months=%d (ticks=%d) ===" % [str(seeds), months, ticks])

	var results: Dictionary = {}
	for s in seeds:
		var r: Dictionary = WarringHarness.run(int(s), ticks)
		if r.is_empty():
			print("[FAIL] seed=%d harness 空" % int(s)); continue
		var loot_util: float = float(Probe.peaks.get("conq.loot_util", -1.0))
		var loot_lead: float = float(Probe.peaks.get("conq.loot_lead", -1.0))
		var winner_loot: int = int(Probe.counts.get("conq.winner_loot", 0))
		var winner_prosperity: int = int(Probe.counts.get("conq.winner_prosperity", 0))
		var winner_other: int = int(Probe.counts.get("conq.winner_other", 0))
		var conq_intent: int = int(Probe.counts.get("conq.intent", 0))
		var seed_result: Dictionary = {
			"final": r["final"], "attrition_pct": r["attrition_pct"],
			"loot_util_peak": loot_util, "loot_lead_peak": loot_lead,
			"conq.winner_loot": winner_loot, "conq.winner_prosperity": winner_prosperity,
			"conq.winner_other": winner_other, "conq.intent": conq_intent,
			"winner_loot_rate_of_intent": (0.0 if conq_intent == 0 else 100.0 * winner_loot / float(conq_intent)),
		}
		results[str(int(s))] = seed_result
		print("--- seed=%d ---" % int(s))
		print("[loot] loot_util_peak=%.2f loot_lead_peak=%.2f winner_loot=%d/%d(intent) rate=%.1f%%" % [
			loot_util, loot_lead, winner_loot, conq_intent, seed_result["winner_loot_rate_of_intent"]])

	var out_path: String = OS.get_environment("LOOT_OUT")
	if out_path != "":
		var f := FileAccess.open(out_path, FileAccess.WRITE)
		if f == null:
			print("[FAIL] 無法寫 LOOT_OUT=%s" % out_path)
		else:
			f.store_string(JSON.stringify(results, "  "))
			f.close()
			print("[bed] 已寫 → %s" % out_path)

	print("=== a2c1_loot_probe_bed DONE ===")

func _parse_seeds() -> Array:
	var raw: String = OS.get_environment("WARRING_SEEDS")
	if raw == "":
		raw = "1337"
	var out: Array = []
	for tok in raw.split(",", false):
		var t: String = tok.strip_edges()
		if t.is_valid_int():
			out.append(int(t))
	return out
