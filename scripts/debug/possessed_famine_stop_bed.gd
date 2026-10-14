extends SceneTree
# @bed-kind: acceptance
# slice: 附身隊後續三件 乙（spec 2026-10-13-possessed-team-followups-HOW）
# 附身隊後續 乙（spec 2026-10-13-possessed-team-followups-HOW §乙；藍圖裁「開始挨餓」進推進停點）
#   B1  玩家隊糧（隊上與糧倉）寫死 0，按 X（推進到事件）⇒ 停在 famine_crossed 那一 tick，結果行＝「存糧吃完，開始挨餓（再 N 天…）」
#   B2  別隊挨餓 ⇒ 推進不停（停點只看主體含玩家隊）
#   B3  已在挨餓中（famine_days > 0）再推進 ⇒ 不重複停
#   B3b 進項→耗盡震盪：糧給一日量的 1.2 倍，分兩次餵（第二次在第一次耗盡之後）⇒ 停點次數＝耗盡次數＝2
#       ★先量（不節流的依據）：附身 30 天兩世界×2 種子單日最多 1 次（docs/measurements/2026-10-14-possessed-followups/）
#   負對照：從 ADVANCE_STOP_KINDS 拿掉 famine_crossed ⇒ B1、B3b 紅
#   ★到場點名：四格各自報到，末行印「到場 4／4」（expect 釘它）
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/possessed_famine_stop_bed.gd

const SEED: int = 1337
const CELLS: Array = ["B1", "B2", "B3", "B3b"]

var _errors: int = 0
var _present: Dictionary = {}
var _runner: SimRunner = null
# ★挨餓事件的獨立計數（不經停點那一路）：每個 tick_step 之後掃匯流排記 seq
#   ★不能事後掃：玩家事件壽命＝RESULT_TTL_TICKS（一小時，sim_runner 清），兩次餵相隔一天以上 ⇒ 第一筆早被清掉（第一版實測少數 1）
var _cross_seen: Dictionary = {}


func _check(label: String, ok: bool) -> void:
	if ok:
		print("  PASS: " + label)
	else:
		_errors += 1
		push_error("[FAIL] " + label)


func _initialize() -> void:
	print("=== possessed_famine_stop：自家隊開始挨餓 ⇒ 推進停下 ===")
	_b1_stop_at_crossing()
	_b2_other_team_no_stop()
	_b3_no_repeat()
	_b3b_oscillation()
	var n: int = 0
	for c in CELLS:
		if _present.has(c):
			n += 1
		else:
			push_error("[FAIL] 格 %s 沒有跑完（到場點名缺）" % c)
			_errors += 1
	print("=== possessed_famine_stop DONE === 到場 %d／%d errors: %d" % [n, CELLS.size(), _errors])
	quit(1 if _errors > 0 else 0)


func _world() -> Array:
	seed(SEED)
	var st := WorldState.new()
	GameSetup.setup(st, GameSetup.load_config("res://config/default.json"))
	var runner := SimRunner.new()
	_runner = runner
	var bridge := SimBridge.new(runner, st)
	return [st, bridge]


func _starve(st: WorldState, t: TeamData) -> void:
	ResourceBank.set_amt(t, "food", 0.0, "bed_seed")
	var g: HexTileData = ResourceSystem.own_granary_tile(st, t)
	if g != null:
		TileBank.set_amt(g, "food", 0.0, "bed_seed")


func _daily_need(t: TeamData) -> float:
	return float(t.population + t.minor_population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY \
		+ float(t.resources.get("horses", 0)) * ResourceSystem.FOOD_PER_MOUNT_PER_DAY


# 按 X 一次（推進到停點事件、或請求用完）；回 {stop_kind, stop_text, tick, advanced}
func _press_x(st: WorldState, bridge: SimBridge, max_ticks: int) -> Dictionary:
	var t0: int = st.world.current_tick
	bridge.request_advance(max_ticks)
	var stop: Dictionary = {}
	var guard: int = 0
	while bridge.is_advancing() and guard < max_ticks + 10:
		guard += 1
		var r: Dictionary = bridge.tick_step()
		var ptid: int = st.get_player_team_id()
		for pe in st.player_events:
			if String(pe.get("kind", "")) == "famine_crossed" and (pe.get("subjects", []) as Array).has(ptid):
				_cross_seen[int(pe.get("seq", 0))] = true
		for e in r.get("events", []):
			if String(e.get("type", "")) == "stop_event" and stop.is_empty():
				stop = e
	return {"stop_kind": String(stop.get("kind", "")), "stop_text": String(stop.get("text", "")),
		"tick": st.world.current_tick, "advanced": st.world.current_tick - t0}


# 玩家隊糧吃光之前，其他停點（遭遇／敵人逼近…）可能先擋下 ⇒ 連按 X 直到 famine_crossed 停點或期限；其他停點逐一記下
func _press_until_famine(st: WorldState, bridge: SimBridge, max_ticks: int, others: Array) -> Dictionary:
	var t0: int = st.world.current_tick
	while st.world.current_tick - t0 < max_ticks:
		var r: Dictionary = _press_x(st, bridge, max_ticks - (st.world.current_tick - t0))
		if r["stop_kind"] == "famine_crossed":
			return r
		if r["stop_kind"] == "":
			return r
		others.append(r["stop_kind"])
		if st.encounter_active:
			_runner._encounter_system.resolve_encounter_end(st, "draw")
	return {"stop_kind": "", "stop_text": "", "tick": st.world.current_tick, "advanced": st.world.current_tick - t0}


func _crossing_tick(st: WorldState, ptid: int, after_seq: int) -> int:
	for e in st.player_events:
		if int(e.get("seq", 0)) > after_seq and String(e.get("kind", "")) == "famine_crossed" \
				and (e.get("subjects", []) as Array).has(ptid):
			return int(e.get("tick", -1))
	return -1


# ── B1 ──────────────────────────────────────────────────────────────────────
func _b1_stop_at_crossing() -> void:
	print("\n── B1 玩家隊糧寫死 0 ⇒ 按 X 停在開始挨餓那一 tick ──")
	var w: Array = _world()
	var st: WorldState = w[0]
	var bridge: SimBridge = w[1]
	var pt: TeamData = st.teams[st.get_player_team_id()]
	_check("★B1 地板：玩家隊附身、尚未挨餓", pt.possessed and pt.famine_days <= 0.0)
	_starve(st, pt)
	var seq0: int = st.player_event_seq
	var others: Array = []
	var r: Dictionary = _press_until_famine(st, bridge, WorldState.TICKS_PER_DAY, others)
	var cross: int = _crossing_tick(st, pt.team_id, seq0)
	var want: String = "存糧吃完，開始挨餓（再 %d 天開始有人餓死）" % ResourceSystem.FAMINE_GRACE_DAYS
	print("   停點 kind=%s tick=%d｜挨餓事件 tick=%d｜其他停點 %s｜結果行「%s」" % [r["stop_kind"], r["tick"], cross, str(others), r["stop_text"]])
	_check("B1 停點是 famine_crossed", r["stop_kind"] == "famine_crossed")
	_check("B1 停在挨餓事件那一 tick", cross != -1 and r["tick"] == cross)
	_check("B1 結果行＝「<隊>：%s」（N 讀 FAMINE_GRACE_DAYS）" % want, r["stop_text"].ends_with(want))
	_present["B1"] = true


# ── B2 ──────────────────────────────────────────────────────────────────────
func _b2_other_team_no_stop() -> void:
	print("\n── B2 別隊挨餓 ⇒ 推進不停 ──")
	var w: Array = _world()
	var st: WorldState = w[0]
	var bridge: SimBridge = w[1]
	var pt: TeamData = st.teams[st.get_player_team_id()]
	ResourceBank.set_amt(pt, "food", 10000.0, "bed_seed")   # 玩家隊不會餓
	var npc: TeamData = null
	var ids: Array = st.teams.keys()
	ids.sort()
	for tid in ids:
		var t: TeamData = st.teams[tid]
		if int(tid) != pt.team_id and t.beast_kind == "" and t.parent_team_id == -1 and t.population > 0:
			npc = t
			break
	_check("★B2 地板：有一支非玩家真隊", npc != null)
	if npc == null:
		_present["B2"] = true
		return
	_starve(st, npc)
	var fam0: int = 0
	var crossed: bool = false
	var stops: Array = []
	var t0: int = st.world.current_tick
	while st.world.current_tick - t0 < WorldState.TICKS_PER_DAY:
		var r: Dictionary = _press_x(st, bridge, WorldState.TICKS_PER_DAY - (st.world.current_tick - t0))
		if npc.famine_days > 0.0:
			crossed = true
		if r["stop_kind"] != "":
			stops.append(r["stop_kind"])
			if st.encounter_active:
				_runner._encounter_system.resolve_encounter_end(st, "draw")
		if r["advanced"] == 0:
			break
	print("   別隊 T%d famine_days=%.2f（挨餓了=%s）｜這一天的停點 %s" % [npc.team_id, npc.famine_days, str(crossed), str(stops)])
	_check("★B2 地板：別隊真的開始挨餓", crossed)
	_check("B2 停點裡沒有 famine_crossed", not stops.has("famine_crossed"))
	_present["B2"] = true


# ── B3 ──────────────────────────────────────────────────────────────────────
func _b3_no_repeat() -> void:
	print("\n── B3 已在挨餓中再推進 ⇒ 不重複停 ──")
	var w: Array = _world()
	var st: WorldState = w[0]
	var bridge: SimBridge = w[1]
	var pt: TeamData = st.teams[st.get_player_team_id()]
	_starve(st, pt)
	var others: Array = []
	var r1: Dictionary = _press_until_famine(st, bridge, WorldState.TICKS_PER_DAY, others)
	_check("★B3 地板：第一次停在 famine_crossed、famine_days > 0", r1["stop_kind"] == "famine_crossed" and pt.famine_days > 0.0)
	var again: Array = []
	var r2: Dictionary = _press_until_famine(st, bridge, WorldState.TICKS_PER_DAY, again)
	print("   第二次按 X：停點 kind=%s 推進 %d tick｜famine_days=%.2f" % [r2["stop_kind"], r2["advanced"], pt.famine_days])
	_check("B3 挨餓中（一天內仍吃不到）不再停在 famine_crossed", r2["stop_kind"] != "famine_crossed" and pt.famine_days > 0.0)
	_present["B3"] = true


# ── B3b ─────────────────────────────────────────────────────────────────────
func _b3b_oscillation() -> void:
	print("\n── B3b 糧一日量 1.2 倍分兩次餵 ⇒ 停點次數＝耗盡次數＝2 ──")
	var w: Array = _world()
	var st: WorldState = w[0]
	var bridge: SimBridge = w[1]
	var pt: TeamData = st.teams[st.get_player_team_id()]
	_starve(st, pt)
	var half: float = _daily_need(pt) * 1.2 / 2.0
	_cross_seen.clear()
	var stops: int = 0
	var feeds: int = 0
	var others: Array = []
	ResourceBank.set_amt(pt, "food", half, "bed_seed")
	feeds += 1
	var r1: Dictionary = _press_until_famine(st, bridge, 2 * WorldState.TICKS_PER_DAY, others)
	if r1["stop_kind"] == "famine_crossed":
		stops += 1
	ResourceBank.set_amt(pt, "food", float(pt.resources.get("food", 0.0)) + half, "bed_seed")   # 第一次耗盡之後才餵第二次
	feeds += 1
	var r2: Dictionary = _press_until_famine(st, bridge, 2 * WorldState.TICKS_PER_DAY, others)
	if r2["stop_kind"] == "famine_crossed":
		stops += 1
	var crossings: int = _cross_seen.size()
	print("   一日量 %.1f｜每次餵 %.1f×%d｜耗盡（famine_crossed 事件）%d 次｜停點 %d 次｜其他停點 %s" % [_daily_need(pt), half, feeds, crossings, stops, str(others)])
	_check("★B3b 地板：耗盡次數＝2（兩次餵都吃完）", crossings == 2)
	_check("B3b 停點次數＝耗盡次數＝2（不節流）", stops == crossings and stops == 2)
	_present["B3b"] = true
