class_name SpecimenTracer

# 指標 specimen 決策 tracer（純觀測，mirror Probe 全域 static）。
# 指定 1 指標團 → LOD-exempt trace 決策全程（想什麼/做什麼/狀態）= 可讀決策 timeline。
# enabled 預設 false → 一般跑 no-op（capture 皆 early-return，零非-specimen 成本）；seed/debug 開。
# 禁改遊戲 state：只讀 + append entry + 印。
static var enabled: bool = false
static var entries: Array = []          # timeline：每 specimen 每決策一條 entry（見 spec 資料模型）
static var _pending: Dictionary = {}    # team_id → { candidates:[{opt,util}], intent:{...} } 本 tick 決策 scratch
# 跨-flush 聚合（診斷 錨→行為用；flush 清 entries 但保留這些）
static var winner_hist: Dictionary = {}   # winner_opt → count（做了什麼）
static var intent_hist: Dictionary = {}   # intent str → count（想什麼）
static var decision_count: int = 0

# specimen 判定：enabled 且 team_id ∈ state.specimen_team_ids（gate 一律過此，零漏）。
static func is_specimen(state: WorldState, team_id: int) -> bool:
	return enabled and team_id in state.specimen_team_ids

static func reset() -> void:
	enabled = false
	entries.clear()
	_pending.clear()
	winner_hist.clear()
	intent_hist.clear()
	decision_count = 0

# ── capture_options：DecisionEngine rank/rank_survival 的 scored[] tap（現丟棄，唯一拿全 util 點）──
# scored 元素 = {u, i, opt}（decision_engine 內部格式）→ 存本決策全候選 {opt, util}。
static func capture_options(state: WorldState, team: TeamData, scored: Array) -> void:
	if not is_specimen(state, team.team_id): return
	var cands: Array = []
	for e in scored:
		cands.append({"opt": e.get("opt", "?"), "util": float(e.get("u", 0.0))})
	_scratch(team.team_id)["candidates"] = cands

# ── capture_intent：commander _emit_goal / solo _evaluate_independent_strategy tap ──
static func capture_intent(state: WorldState, team_id: int, intent: String, why: String, mode: String) -> void:
	if not is_specimen(state, team_id): return
	_scratch(team_id)["intent"] = {"intent": intent, "why": why, "mode": mode}

# ── capture_decision：winner commit tap → 組完整 entry（想什麼/做什麼/狀態 + action target belief）──
static func capture_decision(state: WorldState, team: TeamData, winner_opt: String,
		task: String, target: Vector2i) -> void:
	if not is_specimen(state, team.team_id): return
	var scr: Dictionary = _scratch(team.team_id)
	var intent = scr.get("intent", team.solo_intent if team.solo_intent != "" else "日常")
	# 該 action target 的 best_estimate（beliefs 不存 → 這裡 re-query action target 一條）
	var beliefs: Array = []
	var tgt_team_id: int = _target_team_id(state, target)
	if tgt_team_id != -1 and tgt_team_id != team.team_id:
		var bel: Dictionary = BeliefSystem.best_estimate(state, team.team_id, tgt_team_id)
		if not bel.is_empty():
			beliefs.append({"tgt": tgt_team_id, "est": bel})
	entries.append({
		"tick": state.world.current_tick,
		"team_id": team.team_id,
		"想什麼": {
			"intent": intent,
			"candidates": scr.get("candidates", []),
			"beliefs": beliefs,
		},
		"做什麼": {"winner_opt": winner_opt, "task": task, "target": target},
		"狀態": _snapshot(state, team),
	})
	# 聚合（跨 flush 存活，供 summary 診斷 錨→行為）
	winner_hist[winner_opt] = int(winner_hist.get(winner_opt, 0)) + 1
	var intent_key: String = str(intent["intent"]) if intent is Dictionary else str(intent)
	intent_hist[intent_key] = int(intent_hist.get(intent_key, 0)) + 1
	decision_count += 1
	_pending.erase(team.team_id)   # 本決策已成 entry，清 scratch

# ── flush：印可讀 timeline（mirror warring per-month summary），tag [Specimen T<id>] ──
static func flush() -> void:
	if not enabled or entries.is_empty(): return
	print("\n========== [SpecimenTracer] flush %d entries ==========" % entries.size())
	for e in entries:
		_print_entry(e)
	print("=======================================================")
	entries.clear()

# dump = flush 別名（spec 語彙；end full dump 用）。
static func dump() -> void:
	flush()

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
	var w: Dictionary = e["想什麼"]
	var d: Dictionary = e["做什麼"]
	var s: Dictionary = e["狀態"]
	var cand_str: String = ""
	for c in w["candidates"]:
		cand_str += "%s=%.2f " % [c["opt"], c["util"]]
	print("[Specimen T%d] tick=%d intent=%s | winner=%s task=%s tgt=%s" % [
		e["team_id"], e["tick"], str(w["intent"]),
		d["winner_opt"], d["task"], str(d["target"])])
	print("    candidates: %s" % cand_str.strip_edges())
	if not w["beliefs"].is_empty():
		print("    beliefs: %s" % str(w["beliefs"]))
	print("    狀態: pop=%d food(priv=%.1f/gran=%.1f/eff=%.1f) consume/d=%.1f rung=%d fid=%d coin=%.0f mat=%.0f" % [
		s["pop"], s["food_private"], s["food_granary"], s["effective_food"],
		s["consume_per_day"], s["rung"], s["faction_id"], s["coin"], s["material"]])
