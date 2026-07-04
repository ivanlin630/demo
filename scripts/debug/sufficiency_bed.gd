extends SceneTree

# 全系統充足性率表 harness（純機器，零 sim 邏輯變）。
# default 自然世界（無玩家）× 多 seed × N 月自跑 → 全系統率表。
# 每列：分子/分母=率 + 月切面 + 想要/可行/發生 三元組（可行定義各鏈自述）。
# 表尾 machine-readable JSON（一行/列）。事件流 dump 見 SUFF_DUMP。
# 復用 Probe：開 enabled → 既有+新增 counter 全計 → 讀 counts 排率表。
# 不判決（合理 0 vs 斷鏈 0 歸 QA）；貿易列=佔位引貿易軌漏斗。
#
# 用法（env）：
#   SUFF_SEEDS   多 seed 逗號集，default "1337,2674"
#   SUFF_MONTHS  跑幾月，default 6
#   SUFF_DUMP    事件流落檔路徑（global_messages+observer_messages）
#   SUFF_JSON    率表 machine-readable JSON 落檔路徑（可選；default 只印 stdout）

const CONFIG_PATH: String = "res://config/default.json"

# 率表列定義。want/feasible/happened = Probe counts key（缺→0）。
# rate = happened / feasible。可行(feasible)定義寫在 note（各鏈自述），供 QA 判合理 0 vs 斷鏈 0。
const ROWS: Array = [
	# 貿易：佔位引貿易軌六站漏斗（本軌不重做）
	{"chain": "貿易", "label": "六站漏斗", "want": "", "feasible": "", "happened": "",
	 "note": "佔位——引貿易軌 g1.order_placed→board_read→arb_hit→order_fulfilled 六站，本軌不重做"},
	# 消息傳播
	{"chain": "消息傳播", "label": "送達/發出", "want": "msg.sent", "feasible": "msg.prop_candidate", "happened": "msg.delivered",
	 "note": "可行=同格鄰隊有未知訊息(可傳機會);想要=emit_message 發出;發生=copy 實 append receiver"},
	{"chain": "消息傳播", "label": "失真/傳播", "want": "msg.prop_done", "feasible": "msg.prop_done", "happened": "msg.distorted",
	 "note": "可行=實傳 copy 總數;發生=標 distorted 的 copy"},
	{"chain": "消息傳播", "label": "消費/送達", "want": "msg.delivered", "feasible": "msg.delivered", "happened": "g1.board_read",
	 "note": "消費=訂單看板讀(唯一有決策消費者的 msg 類);非 order 類今無消費 chokepoint→結構性缺(QA 素材)"},
	# belief
	{"chain": "belief", "label": "實質讀/問", "want": "bel.has_belief_call", "feasible": "bel.has_belief_true", "happened": "bel.best_hit",
	 "note": "想要=決策問 has_belief;可行=有 claim;發生=best_estimate 回非空(實讀到估值)。fallback=call−true"},
	{"chain": "belief", "label": "口碑比對/機會", "want": "bel.reconcile_opportunity", "feasible": "bel.reconcile_opportunity", "happened": "bel.reconcile_compared",
	 "note": "可行=親見 record 有 relayed 可比;發生=實比對(→trust_up/down 母數)"},
	# G3 識破
	{"chain": "G3識破", "label": "識破/謊言", "want": "g3.lie_claim", "feasible": "g3.lie_claim", "happened_sum": ["g3.detect_生疑", "g3.detect_裁決"],
	 "note": "可行=收到 distorted claim;發生=生疑+裁決(信假=沒識破)"},
	{"chain": "G3識破", "label": "scout 收斂/派出", "want": "prosp.gate_scout_defer", "feasible": "g3.scout_dispatch", "happened": "g3.scout_converge",
	 "note": "想要=情報不足想查證;可行=實派斥候;發生=收斂轉攻"},
	# 外交
	{"chain": "外交", "label": "提案 accept/發出", "want": "dip.proposal_sent", "feasible": "dip.proposal_handled", "happened": "dip.proposal_accept",
	 "note": "可行=提案抵達決策者(handle 實跑);發生=回 accept"},
	{"chain": "外交", "label": "envoy 送達/派出", "want": "envoy.dispatched", "feasible": "envoy.dispatched", "happened": "envoy.delivered",
	 "note": "既有;已知 delivered≈0=首列病單(QA 判)"},
	# RelationGraph
	{"chain": "RelationGraph", "label": "邊改結果/含邊評估", "want": "rel.tribute_eval", "feasible": "rel.tribute_with_edge", "happened": "rel.tribute_edge_flipped",
	 "note": "可行=tribute_accept 評估含 feud/gratitude 邊;發生=去邊後門檻結果反轉(邊真咬)"},
	# 意圖→行為
	{"chain": "意圖→行為", "label": "征服 想=做",
	 "want": "intent.sel_征服",
	 "feasible": "conq.member_atk_eligible+conq.declared",
	 "happened": "conq.member_atk_dispatch+conq.prosperity_reached",
	 "note": "想要=選征服意圖(commander+獨立);可行=有可攻路徑(成員 faction_goal 攻擊 eligible+獨立征服 declared);發生=TASK_ATTACK 實派。舊 conq.intent/winner_prosperity 只 bump 於 solo=征服 隊(_decide_unified 1519 + 舊 solo 1808),commander directive(faction 級)不經此=by construction 空(V2 假陽性根,已改配對)。註:want=per-cadence 選次,feas/hap=實派次,分母級距不同→率為方向性非絕對"},
	# 捕俘/同化/佔村/立國（既有漏斗收編）
	{"chain": "捕俘", "label": "capture/戰", "want": "conq.combat_entered", "feasible": "conq.combat_entered", "happened": "capture.total",
	 "note": "既有漏斗;可行=進戰鬥;發生=產生俘虜"},
	{"chain": "同化", "label": "assimilate/capture", "want": "capture.total", "feasible": "capture.total", "happened": "p1.assimilate",
	 "note": "既有;可行=有俘;發生=同化啟動"},
	{"chain": "佔村", "label": "flip/dispatch", "want": "occupy.dispatch", "feasible": "occupy.dispatch", "happened": "occupy.capture_flip",
	 "note": "既有;可行=派佔村;發生=翻旗"},
	{"chain": "立國", "label": "found/夠格", "want": "indep.gate_ambitious", "feasible": "indep.gate_path_ok", "happened": "g2.faction_found",
	 "note": "既有;想要=野心夠;可行=路徑可達;發生=立國完成"},
]

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var seeds: Array = _parse_seeds()
	var months: int = int(OS.get_environment("SUFF_MONTHS")) if OS.has_environment("SUFF_MONTHS") else 6
	var ticks: int = maxi(months, 1) * WorldState.TICKS_PER_MONTH
	print("=== sufficiency_bed：seeds=%s months=%d (ticks=%d) config=%s ===" % [
		str(seeds), months, ticks, CONFIG_PATH])
	var all_results: Dictionary = {}
	for s in seeds:
		var r: Dictionary = _run_one(int(s), ticks)
		if r.is_empty():
			print("[FAIL] seed=%d 空（config 載入失敗？）" % int(s)); continue
		all_results[str(int(s))] = r
		_print_rate_table(int(s), r)
	_print_json_block(all_results)
	# 事件流 dump 落檔
	var dump_path: String = OS.get_environment("SUFF_DUMP")
	if dump_path != "":
		var dump: Dictionary = {}
		for sk in all_results:
			dump[sk] = all_results[sk]["msg_dump"]
		var f := FileAccess.open(dump_path, FileAccess.WRITE)
		if f == null:
			print("[FAIL] 無法寫 SUFF_DUMP=%s" % dump_path)
		else:
			f.store_string(JSON.stringify(dump, "  ")); f.close()
			var g0: int = int(all_results.values()[0]["msg_dump"]["global"].size()) if not all_results.is_empty() else 0
			print("[bed] 事件流 dump 已寫 → %s (seed0 global=%d)" % [dump_path, g0])
	print("=== sufficiency_bed DONE ===")

func _parse_seeds() -> Array:
	var raw: String = OS.get_environment("SUFF_SEEDS")
	if raw == "": raw = "1337,2674"
	var out: Array = []
	for tok in raw.split(",", false):
		var t: String = tok.strip_edges()
		if t.is_valid_int(): out.append(int(t))
	return out

# 跑一 seed → 回 {seed, final_counts, final_peaks, monthly[], msg_dump{}}。
func _run_one(world_seed: int, total_ticks: int) -> Dictionary:
	seed(world_seed)                    # 播 global RNG（runtime bare randf/randi）
	Probe.enabled = true
	Probe.reset()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config(CONFIG_PATH)
	if config.is_empty():
		Probe.enabled = false
		return {}
	config["seed"] = world_seed         # 播 setup RNG（map/team/person gen local rng）
	GameSetup.setup(state, config)
	state.player_id = -1                 # 自然世界：無玩家 → 全 NPC AI 自解，無 forced_event 卡死
	var no_player := Vector2i(-1, -1)
	var monthly: Array = []
	var prev_snapshot: Dictionary = {}
	for tick in range(total_ticks):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if (tick + 1) % WorldState.TICKS_PER_MONTH == 0:
			var cur: Dictionary = Probe.counts.duplicate(true)
			monthly.append({
				"month": (tick + 1) / WorldState.TICKS_PER_MONTH,
				"delta": _counts_delta(prev_snapshot, cur),
				"teams": state.teams.size(),
				"pop": _total_pop(state),
			})
			prev_snapshot = cur
		if state.teams.is_empty():
			monthly.append({"month": -1, "delta": {}, "teams": 0, "pop": 0})
			break
	var result: Dictionary = {
		"seed": world_seed,
		"final_counts": Probe.counts.duplicate(true),
		"final_peaks": Probe.peaks.duplicate(true),
		"monthly": monthly,
		"msg_dump": _collect_msg_dump(state),
	}
	Probe.enabled = false
	return result

func _counts_delta(prev: Dictionary, cur: Dictionary) -> Dictionary:
	var d: Dictionary = {}
	for k in cur:
		var p: int = int(prev.get(k, 0))
		if int(cur[k]) - p != 0:
			d[k] = int(cur[k]) - p
	return d

func _total_pop(state: WorldState) -> int:
	var n: int = 0
	for tid in state.teams: n += state.teams[tid].population
	return n

func _collect_msg_dump(state: WorldState) -> Dictionary:
	return {
		"global": _msgs_to_array(state.global_messages),
		"observer": _msgs_to_array(state.observer_messages),
	}

func _msgs_to_array(msgs: Array) -> Array:
	var out: Array = []
	for m in msgs:
		out.append({
			"id": m.id, "type": m.type, "desc": m.description,
			"pos": [m.source_pos.x, m.source_pos.y],
			"origin_team": m.origin_team_id, "origin_tick": m.origin_tick,
			"strength": m.strength, "distorted": m.is_distorted,
			"params": m.params,
		})
	return out

func _cnt(counts: Dictionary, key: String) -> int:
	# 支援 "a+b+c" 求和 key（跨路徑合計，如 commander+獨立征服路徑）。
	if key.find("+") != -1:
		var s: int = 0
		for k in key.split("+", false): s += int(counts.get(k.strip_edges(), 0))
		return s
	return int(counts.get(key, 0))

func _happened_val(counts: Dictionary, row: Dictionary) -> int:
	if row.has("happened_sum"):
		var s: int = 0
		for k in row["happened_sum"]: s += _cnt(counts, k)
		return s
	return _cnt(counts, row.get("happened", ""))

func _rate_str(hap: int, feas: int) -> String:
	if feas == 0: return "n/a"
	return "%.1f%%" % (100.0 * float(hap) / float(feas))

func _is_placeholder(row: Dictionary) -> bool:
	return String(row.get("want", "")) == "" and not row.has("happened_sum") \
		and String(row.get("happened", "")) == ""

func _print_rate_table(s: int, r: Dictionary) -> void:
	var counts: Dictionary = r["final_counts"]
	print("\n────────── [充足性率表] seed=%d ──────────" % s)
	print("%-14s %-18s %8s   想要/可行/發生   定義" % ["鏈", "列", "率"])
	for row in ROWS:
		if _is_placeholder(row):
			print("%-14s %-18s %8s   [%s]" % [row["chain"], row["label"], "—", row["note"]])
			continue
		var want: int = _cnt(counts, row.get("want", ""))
		var feas: int = _cnt(counts, row.get("feasible", ""))
		var hap: int = _happened_val(counts, row)
		print("%-14s %-18s %8s   %d/%d/%d   %s" % [
			row["chain"], row["label"], _rate_str(hap, feas), want, feas, hap, row["note"]])
	# 事件系統動態列（各 evt.<name>.fire / .check）
	print("── 事件系統（各型 fire/check）──")
	var evt_names: Dictionary = {}
	for k in counts:
		if String(k).begins_with("evt.") and String(k).ends_with(".check"):
			evt_names[String(k).trim_prefix("evt.").trim_suffix(".check")] = true
	for name in evt_names:
		var chk: int = _cnt(counts, "evt.%s.check" % name)
		var fire: int = _cnt(counts, "evt.%s.fire" % name)
		print("%-14s %-18s %8s   %d/%d/%d   可行=eligibility 檢查;發生=fire" % [
			"事件", name, _rate_str(fire, chk), chk, chk, fire])
	# 月切面
	print("── 月切面 delta（非零 counter/月）──")
	for m in r["monthly"]:
		print("[月%s] teams=%d pop=%d delta=%s" % [
			str(m["month"]), int(m["teams"]), int(m["pop"]), str(m["delta"])])

func _print_json_block(all_results: Dictionary) -> void:
	print("\n────────── [JSON 區塊] machine-readable（parse 得動）──────────")
	for sk in all_results:
		var r: Dictionary = all_results[sk]
		var counts: Dictionary = r["final_counts"]
		var rows_out: Array = []
		for row in ROWS:
			if _is_placeholder(row):
				continue
			var want: int = _cnt(counts, row.get("want", ""))
			var feas: int = _cnt(counts, row.get("feasible", ""))
			var hap: int = _happened_val(counts, row)
			rows_out.append({
				"chain": row["chain"], "label": row["label"],
				"want": want, "feasible": feas, "happened": hap,
				"rate": (float(hap) / float(feas)) if feas > 0 else null,
			})
		var obj: Dictionary = {"seed": int(sk), "rows": rows_out}
		print("[SUFF_JSON] " + JSON.stringify(obj))
	# 可選：全量落檔
	var json_path: String = OS.get_environment("SUFF_JSON")
	if json_path != "":
		var f := FileAccess.open(json_path, FileAccess.WRITE)
		if f != null:
			f.store_string(JSON.stringify(all_results, "  ")); f.close()
			print("[bed] 率表 JSON 已寫 → %s" % json_path)
