extends SceneTree
# ★★★S3 驗收床：主判準是【觸發間隔】不是【事件率】。
#   理由（systems 定）：間隔是【機制自身的性質】，不受世界分岔汙染——
#   而七支全變慢會讓世界大幅分岔，分岔後聚合不可比是 S2 才立的規矩。
func _initialize() -> void:
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 30
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "peaceful_economy"
	seed(1337)
	var state := WorldState.new()
	GameSetup.setup(state, GameSetup.load_config("res://config/%s.json" % cfg))
	Probe.reset(); Probe.enabled = true
	var ticks: int = days * WorldState.TICKS_PER_DAY
	var runner := SimRunner.new()
	for _t in range(ticks):
		runner.advance_tick(state, Vector2i(-1, -1))
	var day_t: float = float(WorldState.TICKS_PER_DAY)
	print("=== s3_tier_interval === cfg=%s days=%d ticks=%d T3=%d tick (%.2f 天)"
		% [cfg, days, ticks, DecisionTier.T3_STRATEGIC, float(DecisionTier.T3_STRATEGIC) / day_t])
	var rows: Array = Probe.samples.get("tier.fire", [])
	print("★母體 vs 樣本：tier.fire 寫入 %d 筆（cap 6000）%s"
		% [rows.size(), "  ★★撞到 cap ⇒ 這是前 N 筆不是全部" if rows.size() >= 6000 else ""])
	var by: Dictionary = {}
	for r in rows:
		var k: String = String(r["k"]) + "#" + str(r["team"])
		if not by.has(k): by[k] = []
		(by[k] as Array).append(int(r["tick"]))
	var agg: Dictionary = {}
	for k2 in by:
		var arr: Array = by[k2]
		arr.sort()
		var kind: String = String(k2).split("#")[0]
		if not agg.has(kind): agg[kind] = {"gaps": [], "fires": 0, "actors": {}}
		agg[kind]["fires"] = int(agg[kind]["fires"]) + arr.size()
		(agg[kind]["actors"] as Dictionary)[String(k2).split("#")[1]] = true
		for i in range(1, arr.size()):
			(agg[kind]["gaps"] as Array).append(int(arr[i]) - int(arr[i - 1]))
	var kinds: Array = agg.keys(); kinds.sort()
	print("\n── 觸發間隔（主判準）──")
	for kk in kinds:
		var gaps: Array = agg[kk]["gaps"]
		gaps.sort()
		var med: float = 0.0
		if gaps.size() > 0:
			med = float(gaps[gaps.size() / 2])
		print("  %-16s 中位間隔 %8.1f tick = %5.2f 天 ｜分母：fire %d 次 / %d 個行為者 / 間隔樣本 %d"
			% [kk, med, med / day_t, int(agg[kk]["fires"]), (agg[kk]["actors"] as Dictionary).size(), gaps.size()])
	var br: Array = Probe.samples.get("body.tick", [])
	var bt: Array = []
	for b in br: bt.append(int(b["t"]))
	bt.sort()
	var aligned: int = 0
	for t2 in bt:
		if t2 % DecisionTier.T3_STRATEGIC == 0: aligned += 1
	print("
── ★外層評估 _evaluate_all_body 跑了幾次──")
	print("  共 %d 次｜其中 %d 次落在 T3 的整數倍上（%% %d == 0）" % [bt.size(), aligned, DecisionTier.T3_STRATEGIC])
	print("  前 12 個 tick：%s" % str(bt.slice(0, 12)))
	print("  後 12 個 tick：%s" % str(bt.slice(maxi(bt.size() - 12, 0))))
	var gg: Array = []
	for gi in range(1, bt.size()): gg.append(int(bt[gi]) - int(bt[gi - 1]))
	gg.sort()
	if gg.size() > 0:
		print("  外層間隔：中位 %d tick｜最小 %d｜最大 %d" % [int(gg[gg.size() / 2]), int(gg[0]), int(gg[gg.size() - 1])])
	print("
── ★fire 發生在哪些 tick（一眼看出規律）──")
	var tk: Dictionary = {}
	for r2 in rows:
		var kk2: String = String(r2["k"])
		if not tk.has(kk2): tk[kk2] = {}
		(tk[kk2] as Dictionary)[int(r2["tick"])] = true
	var tkeys: Array = tk.keys(); tkeys.sort()
	for k5 in tkeys:
		var ts: Array = (tk[k5] as Dictionary).keys(); ts.sort()
		print("  %-16s ticks=%s" % [String(k5), str(ts.slice(0, 12))])
	print("
── ★不受 cap 影響的計數（分辨【真的只 fire 一次】vs【樣本被截】）──")
	for ck in Probe.counts:
		if String(ck).begins_with("tier.count."):
			print("  %-24s %d 次" % [String(ck), int(Probe.counts[ck])])
	if kinds.is_empty():
		print("  ★tier.fire key 不存在，而 Probe 是 ON ⇒【一次都沒 fire】（tap 在，只是沒到期）")
	print("\n── 意圖對照組：_rebuild_goals 出口分類對帳（互斥且窮盡）──")
	var entry: int = int(Probe.counts.get("goalexit.entry", 0))
	var parts: Array = ["leader_null", "player_override", "survival_override", "reached_intent_gate"]
	var sum: int = 0
	for pn in parts:
		var c: int = int(Probe.counts.get("goalexit." + String(pn), 0))
		sum += c
		print("  %-22s %d" % [String(pn), c])
	print("  %-22s %d（未走到任何標記出口＝跑完全程）" % ["其餘", entry - sum])
	print("  ★entry = %d ｜四出口合計 %d ⇒ %s" % [entry, sum, "★對帳一致" if sum <= entry else "★★對帳異常"])
	print("=== s3_tier_interval DONE ===")
	quit()
