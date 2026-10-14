extends SceneTree
# @bed-kind: acceptance
# slice: 玩家行動稽核三件＋通商提案暫停（spec 2026-10-13-player-action-audit-fixes-HOW）
# 玩家行動稽核（第五輪回饋 #9）：宣稱動作必須改世界
#   M1  ①先量：設比例後推 1 tick／1 天，印每一步 armed_anon_ratio（修前：被 _update_anon_ratio 用庫存蓋回）
#   A1  設 0.5、武器足 ⇒ 1 天後實際 0.5；武器只夠 30% ⇒ 實際 0.3、結果句含「武器只夠 30%」；面板印「目標／實際」
#   T1  無可升階對象（全精銳）⇒ 錢不變、ok:false、清單列在不可側並帶原因
#   T1b 清單顯示可做 → 移走唯一可升階對象 → 執行 ⇒ 不扣錢、回原因
#   R1  重掃 ⇒ 事件流／feed 不增加「重掃」、結果行不變、頁腳待執行不算它；player_pending_targets 照舊寫（印 md5 跨樹比）
#   P4  （WFP 另跑）30 天 propose_trade 送出 0、demand_tribute 次數印出跨樹比；玩家行動清單無通商
# ★修前樹上跑：armed_anon_target 用 get()/set() 讀寫（修前沒有那一欄 ⇒ 編得過、讀到 null）
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/player_action_audit_bed.gd
#   env PAA_P4_DAYS（預設 30；0 ＝ 不跑 P4）

const SEED: int = 1337
const CFG: String = "res://config/default.json"

var _errors: int = 0


func _check(label: String, ok: bool) -> void:
	if ok:
		print("  PASS: " + label)
	else:
		_errors += 1
		push_error("[FAIL] " + label)


func _initialize() -> void:
	_run()


func _run() -> void:
	print("=== player_action_audit：宣稱動作必須改世界 ===")
	_m1_a1_armed()
	_t1_train()
	await _r1_refresh()
	_p4_trade_paused()
	print("=== player_action_audit DONE === errors: %d" % _errors)
	quit(1 if _errors > 0 else 0)


func _world() -> WorldState:
	seed(SEED)
	return MeasureBedHelper.arm_and_setup(CFG, false)


func _set_weapons(t: TeamData, units: int) -> void:
	for w in EquipmentSystem.WEAPON_TYPES:
		ResourceBank.set_amt(t, "weapon_" + w, 0, "bed_seed")
	ResourceBank.set_amt(t, "weapon_melee_low", units, "bed_seed")


func _anon_pop(t: TeamData) -> int:
	return maxi(t.population - t.named_members.size() - (1 if t.leader_id != -1 else 0), 0)


func _set_ratio(st: WorldState, pt: TeamData, r: float) -> Dictionary:
	st.player_state["armed_ratio_input"] = r
	return PlayerCommandSystem.new().execute_action(st, -1, "set_armed_anon_ratio")


# ── M1／A1 ──────────────────────────────────────────────────────────────────
func _m1_a1_armed() -> void:
	print("\n── M1（先量）／A1 武裝比例 ──")
	var st: WorldState = _world()
	var pt: TeamData = st.teams[st.get_player_team_id()]
	var anon: int = _anon_pop(pt)
	_check("★母體地板：玩家隊有匿名人口（>=4，30% 才排得出整數人）", anon >= 4)
	_set_weapons(pt, anon * EquipmentSystem.UNITS_PER_EQUIP)   # 武器夠全員
	var runner := SimRunner.new()
	var r: Dictionary = _set_ratio(st, pt, 0.5)
	var series: PackedStringArray = PackedStringArray(["設完 %.3f" % pt.armed_anon_ratio])
	for i in range(3):
		runner.advance_tick(st, pt.tile_pos)
		series.append("t+%d %.3f" % [i + 1, pt.armed_anon_ratio])
	for i in range(WorldState.TICKS_PER_DAY - 3):
		runner.advance_tick(st, pt.tile_pos)
	_set_weapons(pt, anon * EquipmentSystem.UNITS_PER_EQUIP)   # 一天裡可能被買賣動到 ⇒ 量之前補回「夠」
	runner.advance_tick(st, pt.tile_pos)
	series.append("1 天後 %.3f" % pt.armed_anon_ratio)
	print("   匿名 %d｜目標欄 %s｜「%s」｜%s" % [anon, str(pt.get("armed_anon_target")), String(r.get("msg", "")), " → ".join(series)])
	_check("A1 武器足、設 0.5 ⇒ 1 天後實際 0.5（修前：被庫存重算蓋回 1.0）", is_equal_approx(pt.armed_anon_ratio, 0.5))

	# 武器只夠 30%
	var units30: int = int(floor(float(anon) * 0.3)) * EquipmentSystem.UNITS_PER_EQUIP
	_set_weapons(pt, units30)
	var expect_can: float = float(units30 / EquipmentSystem.UNITS_PER_EQUIP) / float(anon)
	var r2: Dictionary = _set_ratio(st, pt, 0.5)
	for i in range(WorldState.TICKS_PER_DAY - 1):
		runner.advance_tick(st, pt.tile_pos)
	_set_weapons(pt, units30)   # 同上：量之前補回「只夠 30%」
	runner.advance_tick(st, pt.tile_pos)
	var pct: String = "%.0f%%" % (expect_can * 100.0)
	print("   武器只夠 %s｜「%s」｜實際 %.3f" % [pct, String(r2.get("msg", "")), pt.armed_anon_ratio])
	_check("A1b 武器只夠 %s ⇒ 實際＝可武裝比例、結果句含「武器只夠 %s」" % [pct, pct],
		is_equal_approx(pt.armed_anon_ratio, expect_can) and String(r2.get("msg", "")).contains("武器只夠 " + pct))
	var panel: String = _team_panel(st)
	var line: String = ""
	for ln in panel.split("\n"):
		if ln.contains("武裝:"):
			line = ln
	print("   面板：%s" % line)
	_check("A1c 面板印「目標 50%／實際 N%」", line.contains("目標 50%%／實際 %d%%" % int(pt.armed_anon_ratio * 100.0)))

	# NPC 隊：目標未設 ⇒ 照庫存（逐字照舊）
	var npc: TeamData = null
	for tid in st.teams:
		if int(tid) != pt.team_id and _anon_pop(st.teams[tid]) > 0:
			npc = st.teams[tid]
			break
	if npc != null:
		var tgt = npc.get("armed_anon_target")
		_set_weapons(npc, 2)
		runner.advance_tick(st, pt.tile_pos)
		var can_n: float = minf(1.0, 1.0 / float(_anon_pop(npc)))
		print("   NPC Team%d 目標欄 %s｜實際 %.3f（庫存可武裝 %.3f）" % [npc.team_id, str(tgt), npc.armed_anon_ratio, can_n])
		_check("A2a NPC 目標未設（-1）⇒ 實際＝庫存可武裝", tgt != null and float(tgt) < 0.0 and is_equal_approx(npc.armed_anon_ratio, can_n))


func _team_panel(st: WorldState) -> String:
	# ★面板那一行的唯一生產者：mapper 給 ct、text_ui_main._build_unclassified_lines 排字（不另寫一份）
	var node: Node = load("res://scenes/TextUI.tscn").instantiate()
	var lines: Array = node._build_unclassified_lines(PlayerApiMapper.map_controlled_team(st), {}, {})
	node.free()
	return "\n".join(PackedStringArray(lines))


# ── T1／T1b ─────────────────────────────────────────────────────────────────
func _train_row(st: WorldState, pt: TeamData) -> Dictionary:
	var acts: Array = PlayerQueryApi.new()._build_available_actions(st, PlayerCommandSystem.new(), -1, -1, pt.tile_pos.x, pt.tile_pos.y)
	for a in acts:
		if String((a as Dictionary).get("action_id", "")) == "train":
			return a
	return {}


func _all_elite(pt: TeamData) -> void:
	var n: int = AnonTierSystem.total_pop(pt)
	pt.anon_cohorts = {}
	AnonTierSystem.add_anon(pt, AnonCohort.TIER_ELITE, n)


func _t1_train() -> void:
	print("\n── T1／T1b 訓練沒人可練 ──")
	var st: WorldState = _world()
	var pt: TeamData = st.teams[st.get_player_team_id()]
	ResourceBank.set_amt(pt, "coin", 1000.0, "bed_seed")
	_all_elite(pt)
	var coin0: float = float(pt.resources.get("coin", 0))
	var row: Dictionary = _train_row(st, pt)
	var r: Dictionary = PlayerCommandSystem.new().execute_action(st, -1, "train")
	var coin1: float = float(pt.resources.get("coin", 0))
	print("   全精銳 %d 人｜清單 enabled=%s 原因「%s」｜執行 ok=%s「%s」｜幣 %.1f→%.1f" % [AnonTierSystem.total_pop(pt),
		str(row.get("enabled", "?")), String(row.get("disabled_reason", "")), str(r.get("ok", "?")), String(r.get("msg", "")), coin0, coin1])
	_check("★母體地板：全精銳、人口 >0、錢夠", AnonTierSystem.total_pop(pt) > 0 and coin0 >= PlayerCommandSystem.TRAIN_COST_COIN)
	_check("T1 無可升階對象 ⇒ 錢不變、ok:false", is_equal_approx(coin0, coin1) and not bool(r.get("ok", true)))
	_check("T1 清單列在不可側並帶原因", not row.is_empty() and not bool(row.get("enabled", true)) and String(row.get("disabled_reason", "")) != "")

	# T1b：清單可做 → 移走唯一可升階對象 → 執行
	var st2: WorldState = _world()
	var p2: TeamData = st2.teams[st2.get_player_team_id()]
	ResourceBank.set_amt(p2, "coin", 1000.0, "bed_seed")
	var n2: int = AnonTierSystem.total_pop(p2)
	p2.anon_cohorts = {}
	AnonTierSystem.add_anon(p2, AnonCohort.TIER_ELITE, maxi(n2 - 1, 1))
	AnonTierSystem.add_anon(p2, AnonCohort.TIER_PLEB, 1)
	var row_b: Dictionary = _train_row(st2, p2)
	p2.anon_cohorts = {}
	AnonTierSystem.add_anon(p2, AnonCohort.TIER_ELITE, n2)   # 移走那一個可升階的
	var c0: float = float(p2.resources.get("coin", 0))
	var rb: Dictionary = PlayerCommandSystem.new().execute_action(st2, -1, "train")
	var c1: float = float(p2.resources.get("coin", 0))
	print("   T1b 先：清單 enabled=%s｜移走後執行 ok=%s「%s」｜幣 %.1f→%.1f" % [str(row_b.get("enabled", "?")),
		str(rb.get("ok", "?")), String(rb.get("msg", "")), c0, c1])
	_check("★T1b 母體地板：移走前清單顯示可做", bool(row_b.get("enabled", false)))
	_check("T1b 移走唯一可升階對象後執行 ⇒ 不扣錢、回原因", is_equal_approx(c0, c1) and not bool(rb.get("ok", true)) and String(rb.get("msg", "")) != "")


# ── R1 ──────────────────────────────────────────────────────────────────────
func _count_refresh(rows: Array) -> int:
	var n: int = 0
	for e in rows:
		if str(e).contains("重掃"):
			n += 1
	return n


func _r1_refresh() -> void:
	print("\n── R1 重掃不是世界動作 ──")
	seed(SEED)
	var node: Node = load("res://scenes/TextUI.tscn").instantiate()
	get_root().add_child(node)
	await process_frame
	await process_frame
	node.suppress_quit = true
	node._refresh()
	var st: WorldState = node._bridge._state
	# 同格放一支平靜的 NPC ⇒ 重掃有東西可寫（否則 player_pending_targets 恆空、跨樹比是空比空）
	var pt_r: TeamData = st.teams[st.get_player_team_id()]
	var guest_id: int = -1
	for tid in st.teams:
		var o: TeamData = st.teams[tid]
		if int(tid) != pt_r.team_id and o.combat_target == -1 and st.can_be_player_target(int(tid)):
			guest_id = int(tid)
			o.tile_pos = pt_r.tile_pos
			break
	var ev0: int = _count_refresh(node._events)
	var fd0: int = _count_refresh(node._feed_rows)
	var fb0: String = String(node._feedback_line.text)
	node._bridge.refresh_interaction_targets()
	var pend_q: int = node._bridge.pending_command_count()
	var raw_q: int = st.pending_commands.size()
	var t0: int = st.world.current_tick
	await PlayerRepl.press_on(node, PlayerRepl.keycode_for("x"))
	for i in range(30):
		if st.world.current_tick > t0 and st.pending_commands.is_empty():
			break
		await process_frame
	node._refresh()
	var ev1: int = _count_refresh(node._events)
	var fd1: int = _count_refresh(node._feed_rows)
	var fb1: String = String(node._feedback_line.text)
	var pt_md5: String = str(st.player_pending_targets).md5_text()
	print("   入列後 佇列 %d 道、頁腳算 %d 道｜tick %d→%d｜事件流「重掃」%d→%d｜feed %d→%d｜結果行「%s」→「%s」" % [raw_q, pend_q,
		t0, st.world.current_tick, ev0, ev1, fd0, fd1, fb0, fb1])
	print("   player_pending_targets %d 筆 md5=%s（★跨樹比：修前修後須逐字相同）" % [st.player_pending_targets.size(), pt_md5])
	_check("★母體地板：同格對象清單更新（客隊 Team%d 進了 player_pending_targets）" % guest_id, guest_id != -1 and st.player_pending_targets.has(guest_id))
	_check("★母體地板：重掃真的入了佇列、也真的結算了（tick 前進、佇列清空）", raw_q >= 1 and st.world.current_tick > t0 and st.pending_commands.is_empty())
	_check("R1 事件流與 feed 不多出「重掃」", ev1 == ev0 and fd1 == fd0)
	_check("R1 結果行不被重掃蓋掉", not fb1.contains("重掃"))
	_check("R1 頁腳待執行不把介面內部令算進去", pend_q == raw_q - 1)
	node.queue_free()
	await process_frame


# ── P4 ──────────────────────────────────────────────────────────────────────
func _p4_trade_paused() -> void:
	var days: int = int(OS.get_environment("PAA_P4_DAYS")) if OS.get_environment("PAA_P4_DAYS") != "" else 30
	print("\n── P4 通商提案暫停（%d 天）──" % days)
	var st: WorldState = _world()
	var pt: TeamData = st.teams[st.get_player_team_id()]
	var labels: PackedStringArray = PackedStringArray()
	for a in PlayerQueryApi.new()._build_available_actions(st, PlayerCommandSystem.new(), -1, -1, pt.tile_pos.x, pt.tile_pos.y):
		labels.append(String((a as Dictionary).get("label", "")))
	var has_trade_menu: bool = false
	for lb in labels:
		if lb.contains("通商"):
			has_trade_menu = true
	_check("P4 玩家行動清單無通商", not has_trade_menu)
	if days <= 0:
		return
	var runner := SimRunner.new()
	for i in range(days * WorldState.TICKS_PER_DAY):
		var p: TeamData = st.teams.get(st.get_player_team_id())
		runner.advance_tick(st, p.tile_pos if p != null else Vector2i(-1, -1))
		if st.encounter_active:
			runner._encounter_system.resolve_encounter_end(st, "draw")
	var c: Dictionary = Probe.counts
	print("   送出 propose_trade %d｜demand_tribute %d｜propose_alliance %d｜暫停命中 %d（★demand_tribute 跨樹比：修前修後須相同）" % [
		int(c.get("dip.send.propose_trade", 0)), int(c.get("dip.send.demand_tribute", 0)),
		int(c.get("dip.send.propose_alliance", 0)), int(c.get("dip.trade_paused", 0))])
	_check("P4 30 天 propose_trade 送出 0 次", int(c.get("dip.send.propose_trade", 0)) == 0)
	_check("★P4 母體地板：暫停分支真的被走到（>0）", int(c.get("dip.trade_paused", 0)) > 0)
