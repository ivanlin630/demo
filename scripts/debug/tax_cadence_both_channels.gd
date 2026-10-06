extends SceneTree
# @bed-kind: diagnostic
# ★量測員派工（systems 2026-10-06，藍圖裁 c3b3515f4③）：節律重算，母體＝tribute_out+tribute_in
# （勢力貢）＋raid_out+raid_in（居民稅）兩條管道【分開印】，不合成一個分佈。
# 每一對(收者→付者)：最短間隔／間隔分佈／每刀有效率(實扣/扣前)／付方扣後剩餘比例。
#
# 做法：driver_ledger 逐tick drain+clear（避免環形緩衝丟棄）。每tick advance_tick前先snapshot
# 全隊 food/goods/coin（算「扣前」用）。同tick同channel若恰好1個付方1個收方才配成一刀事件
# （同既有判準：模糊的tick印出來誠實限，不硬配）。
#
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/tax_cadence_both_channels.gd

const SEED: int = 1337
const TOTAL_TICKS: int = 30 * 1440
const CHANNELS: Dictionary = {
	"faction_tribute": {"out": "tribute_out", "in": "tribute_in"},
	"resident_tax": {"out": "raid_out", "in": "raid_in"},
}
const RES_KEYS: Array = ["food", "goods", "coin"]


func _initialize() -> void:
	var tree_sha: String = _git_head_sha()
	print("[TREE] HEAD=%s" % tree_sha)
	print("[SEED] %d｜殺玩家=否" % SEED)

	seed(SEED)
	var ws: WorldState = MeasureBedHelper.arm_and_setup("res://config/default.json", false)
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)

	WorldState.driver_ledger_enabled = true
	WorldState.clear_driver_ledger()

	# channel → "collector-payer" → Array[{tick, efficiency, remaining_ratio, extracted, pre_stock}]
	var events_by_channel: Dictionary = {"faction_tribute": {}, "resident_tax": {}}
	var ambiguous_n: Dictionary = {"faction_tribute": 0, "resident_tax": 0}

	var prev_snapshot: Dictionary = {}   # team_id → {food,goods,coin}（上一tick期末＝這一tick期初）
	for tid0 in ws.teams.keys():
		var t0: TeamData = ws.teams[tid0]
		prev_snapshot[int(tid0)] = _snap(t0)

	for _i in range(TOTAL_TICKS):
		runner.advance_tick(ws, no_player)
		var cur_tick: int = ws.world.current_tick

		for channel_key in CHANNELS.keys():
			var out_reason: String = CHANNELS[channel_key]["out"]
			var in_reason: String = CHANNELS[channel_key]["in"]
			var outs_by_payer: Dictionary = {}   # payer_id → Array[{res,delta}]
			var ins_by_collector: Dictionary = {}
			for entry in WorldState.driver_ledger:
				var reason: String = String(entry["reason"])
				if reason != out_reason and reason != in_reason:
					continue
				var ent = entry["entity"]
				if not (ent is TeamData):
					continue
				var etid: int = int(ent.team_id)
				var field: String = String(entry["field"])
				if not RES_KEYS.has(field):
					continue
				if reason == out_reason:
					var arr: Array = outs_by_payer.get(etid, [])
					arr.append({"res": field, "delta": float(entry["delta"])})
					outs_by_payer[etid] = arr
				else:
					var arr2: Array = ins_by_collector.get(etid, [])
					arr2.append({"res": field, "delta": float(entry["delta"])})
					ins_by_collector[etid] = arr2
			if outs_by_payer.is_empty() and ins_by_collector.is_empty():
				continue
			if outs_by_payer.size() == 1 and ins_by_collector.size() == 1:
				var payer_id: int = int(outs_by_payer.keys()[0])
				var collector_id: int = int(ins_by_collector.keys()[0])
				var out_entries: Array = outs_by_payer[payer_id]
				var extracted: float = 0.0
				var pre_stock: float = 0.0
				var pre: Dictionary = prev_snapshot.get(payer_id, {})
				for e in out_entries:
					extracted += absf(float(e["delta"]))
					pre_stock += float(pre.get(String(e["res"]), 0.0))
				var efficiency: float = (extracted / pre_stock) if pre_stock > 0.0 else -1.0
				var remaining_ratio: float = (1.0 - efficiency) if efficiency >= 0.0 else -1.0
				var key: String = "%d-%d" % [collector_id, payer_id]
				var ch_dict: Dictionary = events_by_channel[channel_key]
				var arr3: Array = ch_dict.get(key, [])
				arr3.append({"tick": cur_tick, "extracted": snappedf(extracted, 0.01),
					"pre_stock": snappedf(pre_stock, 0.01), "efficiency": snappedf(efficiency, 0.001),
					"remaining_ratio": snappedf(remaining_ratio, 0.001)})
				ch_dict[key] = arr3
				events_by_channel[channel_key] = ch_dict
			else:
				ambiguous_n[channel_key] = int(ambiguous_n[channel_key]) + 1

		WorldState.clear_driver_ledger()
		for tid1 in ws.teams.keys():
			prev_snapshot[int(tid1)] = _snap(ws.teams[tid1])

	for channel_key2 in CHANNELS.keys():
		var label: String = "勢力貢（tribute_out/in）" if channel_key2 == "faction_tribute" else "居民稅（raid_out/in）"
		print("\n========== 管道：%s — %s ==========" % [channel_key2, label])
		print("★模糊tick（同時多付方或多收方，捨棄不硬配）＝%d" % int(ambiguous_n[channel_key2]))
		var ch_dict2: Dictionary = events_by_channel[channel_key2]
		var pair_keys: Array = ch_dict2.keys()
		pair_keys.sort()
		for key2 in pair_keys:
			var evs: Array = ch_dict2[key2]
			var ticks2: Array = []
			for e2 in evs: ticks2.append(int(e2["tick"]))
			var gaps: Array = []
			for i2 in range(1, ticks2.size()):
				gaps.append(ticks2[i2] - ticks2[i2 - 1])
			var min_gap: int = (gaps.min() if not gaps.is_empty() else -1)
			print("  (collector-payer)=%s｜事件次數=%d｜最短間隔=%s tick｜間隔分佈=%s" \
				% [key2, evs.size(), str(min_gap), str(gaps)])
			for e3 in evs:
				print("    tick=%d｜實扣=%.2f｜扣前=%.2f｜每刀效率=%s｜付方扣後剩餘比例=%s" % [
					int(e3["tick"]), float(e3["extracted"]), float(e3["pre_stock"]),
					(str(e3["efficiency"]) if float(e3["efficiency"]) >= 0.0 else "N/A(扣前=0)"),
					(str(e3["remaining_ratio"]) if float(e3["remaining_ratio"]) >= 0.0 else "N/A")])

	var out_path: String = "docs/measurements/tax-cadence-both-channels.jsonl"
	var f: FileAccess = FileAccess.open(out_path, FileAccess.WRITE)
	f.store_line(JSON.stringify({"kind": "meta", "tree": tree_sha, "seed": SEED,
		"ambiguous_n": ambiguous_n}))
	for channel_key3 in CHANNELS.keys():
		var ch_dict3: Dictionary = events_by_channel[channel_key3]
		for key3 in ch_dict3.keys():
			f.store_line(JSON.stringify({"kind": "pair", "channel": channel_key3, "pair": key3, "events": ch_dict3[key3]}))
	f.close()
	print("\n[DUMP-PATH] %s" % out_path)
	print("=== tax_cadence_both_channels DONE ===")
	quit(0)


func _snap(t: TeamData) -> Dictionary:
	return {"food": float(t.resources.get("food", 0.0)), "goods": float(t.resources.get("goods", 0.0)),
		"coin": float(t.resources.get("coin", 0.0))}


func _git_head_sha() -> String:
	var out: Array = []
	OS.execute("git", ["rev-parse", "--short=9", "HEAD"], out, true)
	if out.size() > 0:
		return String(out[0]).strip_edges()
	return "UNKNOWN"
