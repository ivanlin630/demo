extends SceneTree

# 資訊網 缺口A 診斷（herald warring 恆 0）：warring 餓隊有無落 food 窗口(severity>0)? 若有,help_target 名冊 resolve 出否?
# → 定 severity 前置（沒隊夠餓）還是 target 前置（名冊沒解出）。probe 已在 _try_herald_side（help.severity_positive/target_resolved/target_unresolved）。
# 純觀測（Probe on 讀 counts）。seed1337 warring config 短窗（餓需時間累積）。

func _initialize() -> void:
	seed(1337)
	SimRunner.force_full_hd = true
	Probe.reset(); Probe.enabled = true
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/default.json")
	config["seed"] = 1337
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	var ticks: int = WorldState.TICKS_PER_MONTH / 2   # 2 週（餓累積 + 控 timeout）
	for t in range(ticks):
		runner.advance_tick(state, no_player)
		if state.teams.is_empty(): break
	Probe.enabled = false
	print("=== 缺口A warring-prereq (seed1337, 2wk) ===")
	print("  help.severity_positive=%d（落 food 窗口 severity>0 的隊-評次）" % int(Probe.counts.get("help.severity_positive", 0)))
	print("  help.target_resolved=%d（severity>0 且名冊/belief 解出施助者）" % int(Probe.counts.get("help.target_resolved", 0)))
	print("  help.target_unresolved=%d（severity>0 但施助者解不出）" % int(Probe.counts.get("help.target_unresolved", 0)))
	print("  help.herald_dispatched=%d / help.delivered=%d / help.need_deposited=%d" % [
		int(Probe.counts.get("help.herald_dispatched", 0)), int(Probe.counts.get("help.delivered", 0)), int(Probe.counts.get("help.need_deposited", 0))])
	print("  help.timeout=%d / help.target_dead=%d" % [int(Probe.counts.get("help.timeout", 0)), int(Probe.counts.get("help.target_dead", 0))])
	print("  distrib.entry_lord=%d / distrib.candidate_generated=%d / distribute.deliver=%d" % [
		int(Probe.counts.get("distrib.entry_lord", 0)), int(Probe.counts.get("distrib.candidate_generated", 0)), int(Probe.counts.get("distribute.deliver", 0))])
	# 判別
	var sev: int = int(Probe.counts.get("help.severity_positive", 0))
	var res: int = int(Probe.counts.get("help.target_resolved", 0))
	if sev == 0:
		print("  → ★缺口A root=severity 前置（2wk 內無隊落 food 窗口 severity>0；warring 隊沒夠餓 or 沒走 side-dispatch cadence）")
	elif res == 0:
		print("  → ★缺口A root=target 前置（有隊夠餓 %d 但名冊/belief 全解不出施助者=無領主/無自家 outpost/faction 結構）" % sev)
	else:
		print("  → severity+target 皆有(%d/%d)、缺口在下游（dispatch/lifecycle=缺口B）" % [sev, res])
	print("=== DONE ===")
	quit()
