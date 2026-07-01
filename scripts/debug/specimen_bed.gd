extends SceneTree

# 指標 specimen 決策 tracer — measure 床（spec 交付核心：用 tracer measure 錨→行為）。
# 兩問（藍圖指定）：
#   1. 致富 intent fire 沒？fire 了 winner 有沒 = 貿易/賣貨 action？斷在哪？
#   2. potential-conqueror：征服 intent→攻擊鏈卡哪？
# 純觀測（tracer 零改決策）。econ_bed 商隊 = merchant specimen（unified 全捕）；
# warring 高野心 leader = conqueror specimen（commander intent 捕；攻擊 dispatch 觀 Probe/task）。

func _initialize() -> void:
	var mode: String = OS.get_environment("SPECIMEN_MODE")
	if mode == "": mode = "merchant"   # default 只跑快的 merchant（warring 重，另外跑）
	if mode in ["both", "merchant"]:
		_run_merchant()
	if mode in ["both", "conqueror"]:
		_run_conqueror()
	quit()

# ──────── 1. merchant specimen（致富→交易）────────
func _run_merchant() -> void:
	print("\n############ MERCHANT SPECIMEN（致富→交易 診斷）############")
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config := GameSetup.load_config("res://config/econ_bed.json")
	if config.is_empty():
		print("[FAIL] econ_bed config 載入失敗"); return
	GameSetup.setup(state, config)
	# econ_bed: Team2 = 中立商隊（merchant，coin/goods 充）。指定為 specimen。
	var merchant_id: int = _find_first_with_tag(state, TeamData.TAG_MERCHANT)
	if merchant_id == -1:
		print("[FAIL] 無 merchant 隊可指定 specimen"); return
	state.specimen_team_ids = [merchant_id]
	SpecimenTracer.reset()
	SpecimenTracer.enabled = true
	print("[bed] specimen = merchant Team%d (tags=%s)" % [
		merchant_id, str(state.teams[merchant_id].tags)])

	var anchor_pos := Vector2i(5, 5)   # econ_bed 近區錨（同 econ_bed_diagnose）
	# 短窗（10 天）→ 每日 flush 印可讀 timeline（sim_runner 日邊界呼 flush）
	for _t in range(240 * 10):
		runner.advance_tick(state, anchor_pos)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
	SpecimenTracer.flush()     # 收尾殘餘 entries
	SpecimenTracer.summary()   # 跨-flush 聚合：想什麼 vs 做什麼
	_diagnose_merchant(state, merchant_id)
	SpecimenTracer.reset()

func _diagnose_merchant(state: WorldState, mid: int) -> void:
	print("\n=== [診斷] 錨→行為（merchant）===")
	var t: TeamData = state.teams.get(mid)
	print("[診斷] specimen 現況: task=%s coin=%.0f goods=%.0f" % [
		t.current_task if t != null else "死/併",
		float(t.resources.get("coin", 0)) if t != null else -1,
		float(t.resources.get("goods", 0)) if t != null else -1])
	var w: Dictionary = SpecimenTracer.winner_hist
	var traded: int = int(w.get("貿易", 0)) + int(w.get("賣貨", 0))
	print("[診斷] winner=貿易/賣貨 次數=%d / 全決策=%d" % [traded, SpecimenTracer.decision_count])
	if SpecimenTracer.decision_count == 0:
		print("[診斷結論] specimen 零決策捕到 → unified 路徑未觸（斷在 dispatch 前，非決策層）")
	elif traded == 0:
		print("[診斷結論] 有決策但 winner 從不=貿易 → 致富沒接日常交易（錨有名日常無實 = 經濟真根）")
	else:
		print("[診斷結論] winner 有貿易 → 致富→交易鏈通（斷點在別處/履約層）")

# ──────── 2. conqueror specimen（征服→攻擊）────────
func _run_conqueror() -> void:
	print("\n############ CONQUEROR SPECIMEN（征服→攻擊 診斷）############")
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config := GameSetup.load_config("res://config/warring_states.json")
	if config.is_empty():
		print("[FAIL] warring config 載入失敗"); return
	GameSetup.setup(state, config)
	# 挑最高野心 leader 隊為 specimen（potential conqueror）
	var conq_id: int = _find_highest_ambition_leader(state)
	if conq_id == -1:
		print("[FAIL] 無 leader 隊可指定 specimen"); return
	state.specimen_team_ids = [conq_id]
	SpecimenTracer.reset()
	SpecimenTracer.enabled = true
	Probe.enabled = true; Probe.reset()
	var cl: PersonData = state.persons.get(state.teams[conq_id].leader_id)
	print("[bed] specimen = conqueror Team%d 野心=%.2f 好戰=%.2f" % [
		conq_id, float(cl.values.get("野心", 0)) if cl else -1,
		float(cl.values.get("好戰", 0)) if cl else -1])

	# 25 天：夠 commander intent 演化 + 立國/攻擊起步（warring 重，控 tick 避 timeout）。
	# conqueror 為 commander/military，攻擊 winner 非 unified/survival 路徑（plan scope 不捕）
	# → 觀 intent_hist(想什麼) + task/Probe(做什麼)。
	var no_player := Vector2i(-1, -1)
	for _t in range(240 * 25):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if state.teams.is_empty(): break
	SpecimenTracer.flush()
	SpecimenTracer.summary()
	_diagnose_conqueror(state, conq_id)
	Probe.enabled = false
	SpecimenTracer.reset()

func _diagnose_conqueror(state: WorldState, cid: int) -> void:
	print("\n=== [診斷] 錨→行為（conqueror）===")
	var t: TeamData = state.teams.get(cid)
	var i: Dictionary = SpecimenTracer.intent_hist
	var conquer_fired: bool = int(i.get("征服", 0)) > 0
	print("[診斷] intent_hist(想什麼)=%s" % str(i))
	print("[診斷] specimen 現況: %s task=%s combat_target=%d faction=%d" % [
		"活" if t != null else "死/併",
		t.current_task if t != null else "-",
		t.combat_target if t != null else -99,
		t.faction_id if t != null else -99])
	print("[診斷] Probe 攻擊相關: faction_found=%d indep_subjugate=%d vendetta=%d" % [
		int(Probe.counts.get("g2.faction_found", 0)),
		int(Probe.counts.get("indep.found_subjugate", 0)),
		int(Probe.counts.get("g2.vendetta_trigger", 0))])
	var solo_attack: bool = int(i.get("攻擊", 0)) > 0   # solo_intent task token（非 commander 征服）
	if conquer_fired:
		print("[診斷結論] commander 征服 intent fire → 看 task/combat_target 是否接攻擊（未接=intent→action 斷）")
	elif solo_attack:
		print("[診斷結論] 無 commander 征服 intent；攻擊來自 solo/survival 路徑（掠奪/vendetta），")
		print("           = 名義征服鏈未驅動，低層 survival-loot + 私仇代打（捕的 winner 皆 survival option）")
	else:
		print("[診斷結論] 征服/攻擊 intent 皆未 fire（斷在意圖層：commander 未選征服 + solo 未攻）")

# ──────── helpers ────────
func _find_first_with_tag(state: WorldState, tag: String) -> int:
	var ids: Array = state.teams.keys(); ids.sort()
	for tid in ids:
		if state.teams[tid].tags.has(tag):
			return tid
	return -1

func _find_highest_ambition_leader(state: WorldState) -> int:
	var best_id: int = -1
	var best_amb: float = -1.0
	var ids: Array = state.teams.keys(); ids.sort()
	for tid in ids:
		var t: TeamData = state.teams[tid]
		if t.leader_id == -1 or t.parent_team_id != -1:
			continue
		var p: PersonData = state.persons.get(t.leader_id)
		if p == null: continue
		var amb: float = float(p.values.get("野心", 0.0))
		if amb > best_amb:
			best_amb = amb; best_id = tid
	return best_id
