# @observe-pure  ★observer-no-global-RNG 靜態閘納管(純觀測零 RNG;違=FAIL)
class_name SpecimenTracer

# 指標 specimen 決策 tracer（純觀測，mirror Probe 全域 static）。
# 指定 1 指標團 → LOD-exempt trace 決策全程（想什麼/做什麼/狀態）= 可讀決策 timeline。
# enabled 預設 false → 一般跑 no-op（capture 皆 early-return，零非-specimen 成本）；seed/debug 開。
# 禁改遊戲 state：只讀 + append entry + 印。
static var enabled: bool = false
static var entries: Array = []          # timeline：每 specimen 每決策一條 entry（見 spec 資料模型）；flush() 清空
static var _archive: Array = []         # 全量 archive：capture 時與 entries 同步 append，flush 不清 → write_jsonl 涵蓋全程(含死隊最後決策，非侵入 jsonl 輸出)
static var _pending: Dictionary = {}    # team_id → { candidates:[{opt,util}], intent:{...} } 本 tick 決策 scratch
# 跨-flush 聚合（診斷 錨→行為用；flush 清 entries 但保留這些）
static var winner_hist: Dictionary = {}   # winner_opt → count（做了什麼）
static var intent_hist: Dictionary = {}   # intent str → count（想什麼）
static var decision_count: int = 0
# Fix 2 時間維 heartbeat：team_id→最後 entry tick（capture_decision/heartbeat 更新）→ 補洞判據。
static var _last_entry_tick: Dictionary = {}
const HEARTBEAT_CADENCE: int = WorldState.TICKS_PER_DAY / 4   # TEST VALUE — 6h；specimen 無決策超此→補心跳(timeline 無洞、有界)

# specimen 判定：enabled 且 team_id ∈ state.specimen_team_ids（gate 一律過此，零漏）。
static func is_specimen(state: WorldState, team_id: int) -> bool:
	return enabled and team_id in state.specimen_team_ids

# ★觀測非侵入單點（observer_no_global_rng 家族）：tracer 的 re-query（純觀測，非真決策）包此——
# 關 Probe.enabled（防 tracer re-query bump 污染 Probe counter）+ suppress_observe_noise（防 randf）。
# 鏡射 RNG-confound 修的 suppress 模式，擴含 Probe。return-based 可重入。scope 只包 re-query，微秒級。
static func _begin_observe() -> Array:
	var saved: Array = [Probe.enabled, PathSystem.suppress_observe_noise]
	Probe.enabled = false
	PathSystem.suppress_observe_noise = true
	return saved

static func _end_observe(saved: Array) -> void:
	Probe.enabled = saved[0]
	PathSystem.suppress_observe_noise = saved[1]

static func reset() -> void:
	enabled = false
	entries.clear()
	_archive.clear()
	_pending.clear()
	winner_hist.clear()
	intent_hist.clear()
	decision_count = 0
	_last_entry_tick.clear()

# ── capture_options：DecisionEngine rank/rank_survival 的 scored[] tap（現丟棄，唯一拿全 util 點）──
# scored 元素 = {u, i, opt}（decision_engine 內部格式）→ 存本決策全候選 {opt, util}。
static func capture_options(state: WorldState, team: TeamData, scored: Array, ctx: DecisionContext = null) -> void:
	if not is_specimen(state, team.team_id): return
	var cands: Array = []
	# ★confound 修（觀測禁耗 global RNG，invariants durable rule）：下方 to_task 迴圈每候選重呼
	# finder→estimate_catch_up→observe_velocity→randf＝tracer **額外**消耗 global RNG → 觀測誰岔開世界。
	# 包 suppress_observe_noise（save/restore）使此段 RNG-neutral。真實 rank 的 estimate_catch_up 在 capture
	# 之前（rank 內）不受影響、保留 noise → 真實世界軌跡不變。
	var _obs: Array = _begin_observe()   # suppress RNG(observe_velocity)+Probe(to_task→finder bump)污染
	for e in scored:
		var opt: String = String(e.get("opt", "?"))
		# 可派性標記（arg­max 疑點結案 follow-up①）：util 最高 ≠ 可派。鏡射 dispatch 迴圈跳過條件
		# （faction_ai :1844 task==IDLE / :1846 target==(-1,-1) 非 FLEE）→ 標 ✗，免再誤判 argmax。
		# 只讀 to_task（lookup 無 state 變更），specimen-gated → 零非-specimen 成本。
		var td: Dictionary = DecisionOptions.to_task(state, team, opt)
		var _task = td.get("task", TeamData.TASK_IDLE)
		var _tgt: Vector2i = td.get("target", Vector2i(-1, -1))
		var nd: bool = (_task == TeamData.TASK_IDLE) \
			or (_tgt == Vector2i(-1, -1) and _task != TeamData.TASK_FLEE)
		cands.append({"opt": opt, "util": float(e.get("u", 0.0)), "nd": nd})
	_end_observe(_obs)
	_scratch(team.team_id)["candidates"] = cands
	# 威脅來源（純讀 ctx）：QA 判 survival/flee 空鎖有無真威脅驅動（threat_id=-1+react≈0=無威脅空鎖=慢版 thrash 嫌疑）。
	if ctx != null:
		_scratch(team.team_id)["threat"] = {
			"threat_id": ctx.threat_id, "threat_pos": ctx.threat_pos,
			"threat_react": snappedf(ctx.threat_react, 0.01),
		}

# ── capture_intent：commander _emit_goal / solo _evaluate_independent_strategy tap ──
static func capture_intent(state: WorldState, team_id: int, intent: String, why: String, mode: String) -> void:
	if not is_specimen(state, team_id): return
	_scratch(team_id)["intent"] = {"intent": intent, "why": why, "mode": mode}

# ── Fix 1 person-reaction tap（內政盲點補）：記 specimen 隊成員反應 winner（誰/reaction/why driver 快照）──
# phase:"reaction" entry；純讀 person（loyalty/stress）；is_specimen gate；零 mutation/RNG。QA 判 defect/riot 真因。
static func capture_reaction(state: WorldState, person: PersonData, team: TeamData, reaction: String, why: Dictionary) -> void:
	if not is_specimen(state, team.team_id): return
	var _obs: Array = _begin_observe()   # _snapshot callees 可能 bump Probe → suppress（觀測非侵入）
	var _snap: Dictionary = _snapshot(state, team)
	_end_observe(_obs)
	var entry: Dictionary = {
		"tick": state.world.current_tick, "team_id": team.team_id, "phase": "reaction",
		"person_id": person.id, "reaction": reaction, "why": why,
		"狀態": _snap,
	}
	entries.append(entry)
	_archive.append(entry)
	_last_entry_tick[team.team_id] = state.world.current_tick

# ── capture_decision：winner commit tap → 組完整 entry（想什麼/做什麼/狀態 + action target belief）──
static func capture_decision(state: WorldState, team: TeamData, winner_opt: String,
		task: String, target: Vector2i, result: String = "committed") -> void:
	if not is_specimen(state, team.team_id): return
	var scr: Dictionary = _scratch(team.team_id)
	var _solo_t: String = String(team.solo_intent.get("type", "")) if team.solo_intent is Dictionary else ""
	var intent = scr.get("intent", _solo_t if _solo_t != "" else "日常")
	# 該 action target 的 best_estimate（beliefs 不存 → 這裡 re-query action target 一條）。
	# ★包 _begin/_end_observe：re-query bump Probe 會污染 counter（sim 不讀但違觀測不變量）→ suppress。
	var _obs: Array = _begin_observe()
	var beliefs: Array = []
	var tgt_team_id: int = _target_team_id(state, target)
	if tgt_team_id != -1 and tgt_team_id != team.team_id:
		var bel: Dictionary = BeliefSystem.best_estimate(state, team.team_id, tgt_team_id)
		if not bel.is_empty():
			beliefs.append({"tgt": tgt_team_id, "est": bel})
	var _snap: Dictionary = _snapshot(state, team)   # _snapshot callees 可能 bump Probe → 同包 suppress
	_end_observe(_obs)
	# ★T1 改名（QA 誤讀修）：這欄來自 capture_intent tap，掛在【戰略層】（_emit_goal /
	# _evaluate_independent_strategy、慢 cadence）＝戰略姿態，★不是本 tick 決策 winner 的動機
	# （team9 整段停在「防衛/備戰守土」而後段真正驅動的是缺糧＝兩層混用同一欄名，非 stale bug）。
	# ★T2 本 tick 動機：winner 為什麼贏——主需求層（team.need_urgency argmax 的 narrative_label，
	# 純讀現成值、不重算）+ 五層數值 + winner 在 candidates 裡的 util。★零重算、零 state 寫入。
	var _cands: Array = scr.get("candidates", [])
	var _winner_util: float = 0.0
	for _c in _cands:
		if String((_c as Dictionary).get("opt", "")) == winner_opt:
			_winner_util = float((_c as Dictionary).get("util", 0.0)); break
	var _layers: PackedFloat32Array = team.need_urgency
	var _need_now: Dictionary = {
		"主需求層": NeedHierarchy.narrative_label(_layers) if _layers.size() == NeedHierarchy.N_LAYERS else "",
		"層值": Array(_layers),
		"winner_util": snappedf(_winner_util, 0.001),
	}
	var entry: Dictionary = {
		"tick": state.world.current_tick,
		"team_id": team.team_id,
		"想什麼": {
			"strategic_intent": intent,
			"本tick動機": _need_now,
			"candidates": _cands,
			"beliefs": beliefs,
			"threat": scr.get("threat", {}),
		},
		"做什麼": {"winner_opt": winner_opt, "task": task, "target": target, "result": result},
		"狀態": _snap,
	}
	entries.append(entry)
	_archive.append(entry)   # ★全量 archive（flush 清 entries 不動此）→ write_jsonl 死隊最後決策不遺漏
	_last_entry_tick[team.team_id] = state.world.current_tick   # Fix 2：更新最後 entry tick（heartbeat 補洞判據）
	# 聚合（跨 flush 存活，供 summary 診斷 錨→行為）
	winner_hist[winner_opt] = int(winner_hist.get(winner_opt, 0)) + 1
	var intent_key: String = str(intent["intent"]) if intent is Dictionary else str(intent)
	intent_hist[intent_key] = int(intent_hist.get(intent_key, 0)) + 1
	decision_count += 1
	_pending.erase(team.team_id)   # 本決策已成 entry，清 scratch

# Fix 2 時間維 heartbeat sweep（evaluate_all 末尾呼）：specimen 隊本 tick 無決策 entry 且距上次 entry 超
# HEARTBEAT_CADENCE → append 輕 heartbeat entry（_snapshot 純讀，無候選/belief 重算）→ timeline 無 >6h 洞、不膨脹。
# ★零 state mutation / 零 RNG；specimen-gated（只迭代 specimen_team_ids + enabled gate）→ tracer off 零成本、byte-identical。
static func heartbeat_sweep(state: WorldState) -> void:
	if not enabled: return
	var now: int = state.world.current_tick
	for tid in state.specimen_team_ids:
		if not state.teams.has(tid): continue
		if now - int(_last_entry_tick.get(tid, -999999999)) < HEARTBEAT_CADENCE: continue
		var team: TeamData = state.teams[tid]
		var _obs: Array = _begin_observe()   # _snapshot callees 可能 bump Probe → suppress
		var _snap: Dictionary = _snapshot(state, team)
		_end_observe(_obs)
		var entry: Dictionary = {
			"tick": now, "team_id": tid, "phase": "heartbeat", "reason": "no-decision",
			"狀態": _snap,
		}
		entries.append(entry)
		_archive.append(entry)
		_last_entry_tick[tid] = now

# ── flush：印可讀 timeline（mirror warring per-month summary），tag [Specimen T<id>] ──
static func flush() -> void:
	if not enabled or entries.is_empty(): return
	print("\n========== [SpecimenTracer] flush %d entries（候選 ✗=當下不可派/無target，util雖高仍fallthrough）==========" % entries.size())
	for e in entries:
		_print_entry(e)
	print("=======================================================")
	entries.clear()

# dump = flush 別名（spec 語彙；end full dump 用）。
static func dump() -> void:
	flush()

# ── write_jsonl：全量 trace → jsonl（每 entry 一行 JSON）。純讀 _archive + 寫檔，零 state mutation/零 RNG。──
# _archive 於 capture_decision 時同步累積、flush 不清 → 涵蓋全程（含已 flush 出去的 + 死隊死前最後決策）。
# Vector2i/Vector2 經 _json_safe 轉 [x,y]（JSON 不原生支援 Vector）。
static func write_jsonl(path: String) -> void:
	var f: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_error("[SpecimenTracer] write_jsonl 開檔失敗(%d): %s" % [FileAccess.get_open_error(), path])
		return
	for e in _archive:
		f.store_line(JSON.stringify(_json_safe(e)))
	f.close()
	print("[SpecimenTracer] write_jsonl → %s (%d entries)" % [path, _archive.size()])

# 遞迴轉 JSON-safe：Vector2i/Vector2 → [x,y]；Dictionary/Array 遞迴；其餘原樣。
static func _json_safe(v):
	if v is Vector2i or v is Vector2:
		return [v.x, v.y]
	if v is Dictionary:
		var d: Dictionary = {}
		for k in v:
			d[str(k)] = _json_safe(v[k])
		return d
	if v is Array:
		var a: Array = []
		for x in v:
			a.append(_json_safe(x))
		return a
	return v

# summary：跨-flush 聚合印（錨→行為診斷：想什麼 intent 分布 vs 做什麼 winner 分布）。
static func summary() -> void:
	print("\n========== [SpecimenTracer] summary（%d 決策）==========" % decision_count)
	print("[Specimen] 想什麼(intent 分布): %s" % str(intent_hist))
	print("[Specimen] 做什麼(winner_opt 分布): %s" % str(winner_hist))
	print("=======================================================")

# ────────── 內部 ──────────

static func _scratch(team_id: int) -> Dictionary:
	if not _pending.has(team_id):
		_pending[team_id] = {}
	return _pending[team_id]

static func _snapshot(state: WorldState, team: TeamData) -> Dictionary:
	var g: HexTileData = ResourceSystem.own_granary_tile(state, team)
	var granary_food: float = float(g.public_storage.get("food", 0)) if g != null else 0.0
	var leader: PersonData = state.persons.get(team.leader_id)
	var rung: int = AmbitionLadder.target_rung(state, team, leader) if leader != null else -1
	# slice A 補：leader trait dump（性格顯性化驗收要——一眼看出此 leader 性格對應什麼資源分配/option）。
	var lv: Dictionary = leader.values if leader != null else {}
	var traits: Dictionary = {
		"野心": snappedf(float(lv.get("野心", 0.5)), 0.01),
		"慎重": snappedf(float(lv.get("慎重", 0.5)), 0.01),
		"求生欲": snappedf(float(lv.get("求生欲", 0.5)), 0.01),
		"好戰": snappedf(float(lv.get("好戰", 0.5)), 0.01),
		"貪婪": snappedf(float(lv.get("貪婪", 0.5)), 0.01),
		"food_sec_target": snappedf(DecisionTerms.food_security_target(lv), 0.1),   # 該性格的食物安全存量目標(天)
	}
	# 買糧執行鏈可觀測（純讀 active_orders/tile）：分「換皮(單卡 never 到市集/never 成交)」vs「成交沒 tap」。
	var _buy_food_qty: int = 0
	var _orders_summary: Array = []
	for o in team.active_orders:
		# ★訂單簿 tap：帶 order_id + 壽命 → QA 讀故事可直接分辨「同一張單卡了 8 天」vs「重掛了 5 次」
		# （原本只能用 qty_rem 跳動反推）。
		_orders_summary.append({
			"order_id": int(o.get("order_id", -1)), "kind": o["kind"], "res": o["res"],
			"qty_rem": int(o["qty_remaining"]),
			"created_tick": int(o.get("created_tick", -1)),
			"age_days": snappedf(float(state.world.current_tick - int(o.get("created_tick", state.world.current_tick))) / float(WorldState.TICKS_PER_DAY), 0.1),
		})
		if o["kind"] == "buy" and o["res"] == "food":
			_buy_food_qty = int(o["qty_remaining"])
	var _mtile: HexTileData = state.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)
	var _at_market: bool = _mtile != null and _mtile.outpost_level > 0   # 在市集 outpost（讀板成交前提）
	return {
		"pop": team.population,
		"food_private": float(team.resources.get("food", 0)),
		"food_granary": granary_food,
		"effective_food": ResourceSystem.effective_food(state, team),
		"consume_per_day": float(team.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY,
		"rung": rung,
		"faction_id": team.faction_id,
		"coin": float(team.resources.get("coin", 0)),
		"material": float(team.resources.get("material", 0)),
		"leader_traits": traits,
		"active_buy_food_qty": _buy_food_qty,
		"at_market": _at_market,
		"orders": _orders_summary,
	}

# action target Vector2i → 站該格的 team_id（belief re-query 用）；無/自己 → -1。
static func _target_team_id(state: WorldState, target: Vector2i) -> int:
	if target == Vector2i(-1, -1): return -1
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t != null and t.tile_pos == target:
			return tid
	return -1

static func _print_entry(e: Dictionary) -> void:
	# Fix 2 heartbeat entry（無 想什麼/做什麼，只 狀態）→ 輕印，不存取決策欄（防 Invalid get index）。
	if e.get("phase") == "heartbeat":
		var hs: Dictionary = e.get("狀態", {})
		print("[Specimen T%d] tick=%d ♥heartbeat（no-decision）pop=%d food(eff=%.1f)" % [
			int(e.get("team_id", -1)), int(e.get("tick", -1)),
			int(hs.get("pop", 0)), float(hs.get("effective_food", 0.0))])
		return
	if e.get("phase") == "reaction":
		print("[Specimen T%d] tick=%d ⚡reaction person=%d %s why=%s" % [
			int(e.get("team_id", -1)), int(e.get("tick", -1)),
			int(e.get("person_id", -1)), str(e.get("reaction", "")), str(e.get("why", {}))])
		return
	var w: Dictionary = e["想什麼"]
	var d: Dictionary = e["做什麼"]
	var s: Dictionary = e["狀態"]
	var cand_str: String = ""
	for c in w["candidates"]:
		cand_str += "%s=%.2f%s " % [c["opt"], c["util"], "✗" if c.get("nd", false) else ""]
	# ★讀者一眼分兩層：strategic_intent＝慢 cadence 戰略姿態；motive＝本 tick 這個 winner 為何贏。
	var _m: Dictionary = w.get("本tick動機", {})
	print("[Specimen T%d] tick=%d strategic_intent=%s | motive=%s(util=%.2f) | winner=%s task=%s tgt=%s" % [
		e["team_id"], e["tick"], str(w.get("strategic_intent", w.get("intent", "?"))),
		str(_m.get("主需求層", "?")), float(_m.get("winner_util", 0.0)),
		d["winner_opt"], d["task"], str(d["target"])])
	print("    candidates: %s" % cand_str.strip_edges())
	if not w["beliefs"].is_empty():
		print("    beliefs: %s" % str(w["beliefs"]))
	print("    狀態: pop=%d food(priv=%.1f/gran=%.1f/eff=%.1f) consume/d=%.1f rung=%d fid=%d coin=%.0f mat=%.0f" % [
		s["pop"], s["food_private"], s["food_granary"], s["effective_food"],
		s["consume_per_day"], s["rung"], s["faction_id"], s["coin"], s["material"]])
	var _tr: Dictionary = s.get("leader_traits", {})
	if not _tr.is_empty():
		print("    leader: 野心=%.2f 慎重=%.2f 求生欲=%.2f 好戰=%.2f 貪婪=%.2f → food_sec_target=%.1f天" % [
			_tr.get("野心", 0.5), _tr.get("慎重", 0.5), _tr.get("求生欲", 0.5),
			_tr.get("好戰", 0.5), _tr.get("貪婪", 0.5), _tr.get("food_sec_target", 4.0)])
