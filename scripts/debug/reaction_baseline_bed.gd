extends SceneTree

# TEMP bed（Task 0 baseline，序7 reaction 溶入前後對照用）。跑完刪。
# seeded warring 1337/1200t → 印 seeded 結構 + FLEE 相關 probe。
# bridge panic-flee 觸發次數 = 掃 stdout [ReactionBridge] 行（外部 grep），此 bed 只出 seeded 結構+threat dispatch。

func _initialize() -> void:
	var r: Dictionary = WarringHarness.run(1337, 1200)
	print("[baseline] seeded final teams=%d factions=%d established=%d pop=%d attrition=%.1f%%" % [
		r["final"]["teams"], r["final"]["factions"], r["final"]["established"],
		r["final"]["pop"], r["attrition_pct"]])
	var flee: int = int(Probe.counts.get("threat.dispatch.survival", 0))
	var prep: int = int(Probe.counts.get("threat.dispatch.備戰", 0))
	var defn: int = int(Probe.counts.get("threat.dispatch.迎戰", 0))
	var pac: int = int(Probe.counts.get("threat.dispatch.求和", 0))
	print("[baseline] threat.dispatch flee=%d prepare=%d defend=%d pacify=%d" % [flee, prep, defn, pac])
	print("[baseline] === DONE ===")
	quit()
