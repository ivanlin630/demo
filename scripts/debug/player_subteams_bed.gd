extends SceneTree
# @bed-kind: acceptance
# slice: 玩家子隊真的做事（只做玩家給的任務；spec 2026-10-13-player-subteams-execute-given-tasks-HOW）
# 玩家子隊（QA 故事稽核 2026-10-13；藍圖三裁 81a62871e）
#   S1  覓食到一格外有糧的格 ⇒ 抵達後停留、1 天內所在格採集入帳、未被併回；母隊走到它那格也不吞；結果句寫此格產出
#   S2  偵查 ⇒ 停在目標格、那格對玩家可見；選單無「巡邏」
#   S3  待機 ⇒ 24 小時內 task、位置不變
#   S4  整天零「找上門」來自自己的子隊（強制事件 from_id 不是子隊）
#   S5  落腳 ⇒ 目標格 L0 營地；已有據點的格 ⇒ 不可帶原因
#   S6  移居自家據點 ⇒ 成為居民；非自家據點 ⇒ 不可帶原因
#   S7  建設 ⇒ 抵達後 task＝建設、construction_team_id＝子隊、進度推進；缺料 ⇒ 不可帶原因
#   S7b 完工後召回 ⇒ 據點 owner 仍是玩家隊｜S7c start_build 的 transition 沒被 deny
#   S8  被攻擊 ⇒ 事件流「你的子隊…攻擊」、是停點；不自動逃｜S8b 紀律脫離 ⇒ 玩家事件
#   S9  召回 ⇒ 併回
#   S10 腳下派遣 ⇒ 當下就算抵達（move_target 不留）
#   S12 自主子隊面板標「自主」；下令被接受才翻成玩家子隊、之後 24 小時無決策層改派；被拒的令不翻
#   ★S11（NPC 一律歸建閘量測、kin 外交／威脅修前修後）在 player_subteams_census.gd（diagnostic）
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/player_subteams_bed.gd

const SEED: int = 1337
const CFG: String = "res://config/default.json"

var _errors: int = 0
var _first_stall: String = ""


func _check(label: String, ok: bool) -> void:
	if ok:
		print("  PASS: " + label)
	else:
		_errors += 1
		push_error("[FAIL] " + label)


func _initialize() -> void:
	print("=== player_subteams：玩家子隊只做玩家給的任務 ===")
	_s1_forage()
	_s2_scout()
	_s3_s4_idle()
	_s5_camp()
	_s6_settle()
	_s7_build()
	_s8_attacked()
	_s9_recall()
	_s10_at_foot()
	_s12_autonomous()
	_s13_kin_and_arbiter()
	print("   首次未推進：%s" % (_first_stall if _first_stall != "" else "無"))
	print("=== player_subteams DONE === errors: %d" % _errors)
	quit(1 if _errors > 0 else 0)


# ── 共用 ──────────────────────────────────────────────────────────────────────
func _world() -> WorldState:
	seed(SEED)
	var st: WorldState = MeasureBedHelper.arm_and_setup(CFG, false)
	var pt: TeamData = _pt(st)
	# 子隊要一位非領袖的記名成員當隊長、母隊要夠人
	# 子隊隊長一位＋召回信使一位（_action_recall_subteam 要一名非領袖的記名成員）
	var spare: int = 0
	for pid in pt.named_members:
		if pid != pt.leader_id and st.persons.has(pid):
			spare += 1
	var next_id: int = 96001
	while spare < 2:
		var m := PersonData.new()
		m.id = next_id
		next_id += 1
		m.team_id = pt.team_id
		m.skills["統領"] = 0.5
		st.persons[m.id] = m
		pt.named_members.append(m.id)
		spare += 1
	if AnonTierSystem.total_pop(pt) < 8:
		AnonTierSystem.add_anon(pt, AnonCohort.TIER_PLEB, 8)
	return st


func _pt(st: WorldState) -> TeamData:
	return st.teams[st.get_player_team_id()]


func _spare_leader(st: WorldState, pt: TeamData) -> int:
	for pid in pt.named_members:
		if pid != pt.leader_id and st.persons.has(pid):
			var busy: bool = false
			for tid in st.teams:
				if (st.teams[tid] as TeamData).leader_id == pid:
					busy = true
			if not busy:
				return pid
	return -1


func _dispatch(st: WorldState, task: String, pos: Vector2i, n: int = 3, build_type: String = "") -> Dictionary:
	var pt: TeamData = _pt(st)
	st.player_state["sub_leader_id"] = _spare_leader(st, pt)
	st.player_state["sub_pop_count"] = n
	st.player_state["sub_task"] = task
	st.player_state["sub_move_q"] = pos.x
	st.player_state["sub_move_r"] = pos.y
	if build_type != "":
		st.player_state["sub_build_type"] = build_type
	return PlayerCommandSystem.new().execute_action(st, -1, "dispatch_subteam")


func _adv(st: WorldState, runner: SimRunner, n: int, watch: Callable = Callable()) -> void:
	for i in range(n):
		var p: TeamData = st.teams.get(st.get_player_team_id())
		var why: String = runner.advance_tick(st, p.tile_pos if p != null else Vector2i(-1, -1))
		if why != "" and _first_stall == "":
			_first_stall = "tick %d：%s" % [st.world.current_tick, why]
		if st.encounter_active:
			runner._encounter_system.resolve_encounter_end(st, "draw")
		st.player_forced_event = {}   # 床不回應找上門：清掉（S4 在清之前讀）
		if watch.is_valid():
			watch.call()


func _neighbors(pos: Vector2i) -> Array:
	return [pos + Vector2i(1, 0), pos + Vector2i(-1, 0), pos + Vector2i(0, 1), pos + Vector2i(0, -1),
		pos + Vector2i(1, -1), pos + Vector2i(-1, 1)]


func _tile(st: WorldState, pos: Vector2i) -> HexTileData:
	return st.world.tiles.get(pos.x * 1000 + pos.y)


# 一格外、玩家看得到、沒有據點／營地／工地的格；need_food ⇒ 要有糧
func _free_neighbor(st: WorldState, need_food: bool = false) -> Vector2i:
	var pt: TeamData = _pt(st)
	for nb in _neighbors(pt.tile_pos):
		var t: HexTileData = _tile(st, nb)
		if t == null or t.outpost_level > 0 or t.outpost_owner != -1 or t.camp_level > 0 or t.construction_team_id != -1:
			continue
		if t.terrain == "mountain" or t.terrain == "water":
			continue
		if String(PlayerQueryApi.tile_knowledge(st, nb).get("status", "")) == "unvisited":
			continue
		if need_food and float(t.resources.get("food", 0)) <= 1.0:
			continue
		return nb
	return Vector2i(-1, -1)


# 推進直到條件成立（faction AI 依隊錯開 cadence ⇒ 抵達後不保證下一 tick 就輪到；給期限、印實際等了幾 tick）
func _until(st: WorldState, runner: SimRunner, cond: Callable, max_ticks: int, label: String) -> bool:
	for i in range(max_ticks + 1):
		if cond.call():
			print("   %s：%d tick 後成立" % [label, i])
			return true
		if i < max_ticks:
			_adv(st, runner, 1)
	print("   %s：%d tick 內未成立" % [label, max_ticks])
	return false


# 一格外另一個空格（排除 avoid）
func _other_free_neighbor(st: WorldState, avoid: Vector2i) -> Vector2i:
	var pt: TeamData = _pt(st)
	for nb in _neighbors(pt.tile_pos):
		if nb == avoid:
			continue
		var t: HexTileData = _tile(st, nb)
		if t == null or t.outpost_level > 0 or t.outpost_owner != -1 or t.camp_level > 0 or t.construction_team_id != -1:
			continue
		if t.terrain == "water":
			continue
		if String(PlayerQueryApi.tile_knowledge(st, nb).get("status", "")) == "unvisited":
			continue
		return nb
	return Vector2i(-1, -1)


# 佈置一個別人的 L1 據點（S5／S6 的「不可」格；世界裡玩家看得到的據點不保證存在）
func _seed_foreign_outpost(st: WorldState, pos: Vector2i) -> int:
	var pt: TeamData = _pt(st)
	var other: int = -1
	for tid in st.teams:
		var t: TeamData = st.teams[tid]
		if int(tid) != pt.team_id and t.parent_team_id == -1 and t.beast_kind == "" and pt.parent_team_id != int(tid):   # 非自家人（頂層隊、不是玩家隊的母隊）
			other = int(tid)
			break
	var tile: HexTileData = _tile(st, pos)
	tile.outpost_type = "civilian"
	tile.outpost_level = 1
	OutpostOwnerBank.set_owner(st, tile, other, "bed_seed")
	return other


func _arrive(st: WorldState, runner: SimRunner, sub_id: int, max_ticks: int = 2 * WorldState.TICKS_PER_DAY) -> bool:
	for i in range(max_ticks):
		var s: TeamData = st.teams.get(sub_id)
		if s == null:
			return false
		if s.move_target == Vector2i(-1, -1):
			return true
		_adv(st, runner, 1)
	return false


# ── S1 覓食 ──────────────────────────────────────────────────────────────────
func _s1_forage() -> void:
	print("\n── S1 覓食 ──")
	var st: WorldState = _world()
	var runner := SimRunner.new()
	var pt: TeamData = _pt(st)
	var tgt: Vector2i = _free_neighbor(st, true)
	_check("★母體地板：一格外有看得到、有糧的格", tgt != Vector2i(-1, -1))
	if tgt == Vector2i(-1, -1):
		return
	# ★採集是被動的、只在有營地／據點的格（resource_system collect）⇒ 「有糧源的格」＝有營地且池裡有糧
	var bare: Vector2i = _other_free_neighbor(st, tgt)
	if bare != Vector2i(-1, -1):
		# ★修前樹沒有這一支 ⇒ callv（修前讀到空字串＝那一格紅，不是編不過）
		var pcs := PlayerCommandSystem.new()
		var sent_b: String = String(pcs.callv("_subteam_task_sentence", [st, TeamData.TASK_FORAGE, bare])) if pcs.has_method("_subteam_task_sentence") else ""
		print("   光格 %s 的結果句「%s」" % [str(bare), sent_b])
		_check("S1b 沒營地／據點的格 ⇒ 結果句不報產出、說採不到", not sent_b.contains("此格產出") and sent_b.contains("採不到"))
	var ct: HexTileData = _tile(st, tgt)
	ct.camp_level = 1
	ct.camp_team_id = pt.team_id
	ct.camp_ticks_left = 30 * WorldState.TICKS_PER_DAY
	OwnerCampIndex.invalidate()
	var r: Dictionary = _dispatch(st, TeamData.TASK_FORAGE, tgt)
	var sid: int = int(r.get("sub_id", -1))
	print("   派遣「%s」" % String(r.get("msg", "")))
	_check("S1 結果句寫此格產出", String(r.get("msg", "")).contains("此格產出"))
	var arrived: bool = _arrive(st, runner, sid)
	_check("★S1 地板：子隊抵達", arrived)
	if not arrived:
		return
	var sub: TeamData = st.teams[sid]
	var f0: float = float(sub.resources.get("food", 0))
	var tile_f0: float = float(_tile(st, tgt).resources.get("food", 0))
	_adv(st, runner, WorldState.TICKS_PER_DAY)
	var alive: bool = st.teams.has(sid)
	var sub1: TeamData = st.teams.get(sid)
	var f1: float = float(sub1.resources.get("food", 0)) if sub1 != null else -1.0
	var eat: float = float(sub1.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY if sub1 != null else 0.0
	var tile_f1: float = float(_tile(st, tgt).resources.get("food", 0))
	print("   1 天：子隊在=%s 位置 %s task=%s｜隊上糧 %.1f→%.1f（吃 %.1f）｜格上糧 %.1f→%.1f" % [str(alive),
		str(sub1.tile_pos) if sub1 != null else "-", sub1.current_task if sub1 != null else "-", f0, f1, eat, tile_f0, tile_f1])
	_check("S1 1 天後仍在、仍是玩家子隊、停在目標格", alive and sub1.parent_team_id == pt.team_id and sub1.tile_pos == tgt)
	_check("S1 所在格採集入帳（隊上糧＋吃掉的 > 起點）", alive and f1 + eat > f0 + 0.01)
	# 母隊走到它那格：不吞
	pt.tile_pos = tgt
	SubteamSystem.new().try_merge_back(st, sid)
	_check("S1 母隊到同格 ⇒ 不被 try_merge_back 吞", st.teams.has(sid))


# ── S2 偵查 ──────────────────────────────────────────────────────────────────
func _s2_scout() -> void:
	print("\n── S2 偵查 ──")
	var has_patrol: bool = false
	for e in TextUiMain.SUBTEAM_TASK_CHOICES:   # ★玩家實際看到的派遣選單
		if String(e[0]) == TeamData.TASK_PATROL:
			has_patrol = true
	_check("S2 子隊選單無「巡邏」", not has_patrol)
	var st: WorldState = _world()
	var runner := SimRunner.new()
	var pt: TeamData = _pt(st)
	var tgt: Vector2i = pt.tile_pos + Vector2i(2, 0)
	if _tile(st, tgt) == null:
		tgt = pt.tile_pos + Vector2i(-2, 0)
	var r: Dictionary = _dispatch(st, TeamData.TASK_SCOUT, tgt)
	var sid: int = int(r.get("sub_id", -1))
	print("   派遣「%s」" % String(r.get("msg", "")))
	var arrived: bool = _arrive(st, runner, sid, 3 * WorldState.TICKS_PER_DAY)
	_adv(st, runner, 60)
	var sub: TeamData = st.teams.get(sid)
	print("   抵達=%s 位置 %s task=%s" % [str(arrived), str(sub.tile_pos) if sub != null else "-", sub.current_task if sub != null else "-"])
	_check("S2 偵查 ⇒ 停在目標格、結果句「停留觀察」", arrived and sub != null and sub.tile_pos == tgt and String(r.get("msg", "")).contains("停留觀察"))


# ── S3／S4 待機、零找上門 ────────────────────────────────────────────────────
func _s3_s4_idle() -> void:
	print("\n── S3／S4 待機 24 小時 ──")
	var st: WorldState = _world()
	var runner := SimRunner.new()
	var pt: TeamData = _pt(st)
	var r: Dictionary = _dispatch(st, TeamData.TASK_IDLE, pt.tile_pos)
	var sid: int = int(r.get("sub_id", -1))
	var sub: TeamData = st.teams.get(sid)
	_check("★S3 地板：派出了", sub != null)
	if sub == null:
		return
	var pos0: Vector2i = sub.tile_pos
	var changes: Array = []
	var knocks: Array = []
	var w := func() -> void:
		var s: TeamData = st.teams.get(sid)
		if s == null:
			changes.append("消失")
			return
		if s.current_task != TeamData.TASK_IDLE or s.tile_pos != pos0 or s.move_target != Vector2i(-1, -1):
			changes.append("t%d %s %s" % [st.world.current_tick, s.current_task, str(s.tile_pos)])
	# 找上門要在 _adv 清掉之前讀 ⇒ 逐 tick 自己推
	for i in range(WorldState.TICKS_PER_DAY):
		var why: String = runner.advance_tick(st, pt.tile_pos)
		if why != "" and _first_stall == "":
			_first_stall = "tick %d：%s" % [st.world.current_tick, why]
		if not st.player_forced_event.is_empty() and int(st.player_forced_event.get("from_id", -1)) == sid:
			knocks.append(str(st.player_forced_event))
		st.player_forced_event = {}
		if st.encounter_active:
			runner._encounter_system.resolve_encounter_end(st, "draw")
		w.call()
	print("   24 小時：變化 %d 筆 %s｜子隊找上門 %d" % [changes.size(), str(changes.slice(0, 3)), knocks.size()])
	_check("S3 待機 ⇒ 24 小時 task／位置不變、不被改派", changes.is_empty())
	_check("S4 整天零「找上門」來自自己的子隊", knocks.is_empty())


# ── S5 落腳 ──────────────────────────────────────────────────────────────────
func _s5_camp() -> void:
	print("\n── S5 落腳 ──")
	var st: WorldState = _world()
	var runner := SimRunner.new()
	var pt: TeamData = _pt(st)
	var tgt: Vector2i = _free_neighbor(st)
	_check("★S5 地板：一格外有可紮營的格", tgt != Vector2i(-1, -1))
	if tgt == Vector2i(-1, -1):
		return
	var r: Dictionary = _dispatch(st, TeamData.TASK_CAMP, tgt)
	var sid: int = int(r.get("sub_id", -1))
	_arrive(st, runner, sid)
	var t: HexTileData = _tile(st, tgt)
	_until(st, runner, func(): return t.camp_level > 0, WorldState.TICKS_PER_DAY, "S5 目標格出營地")
	print("   「%s」｜目標格 camp_level=%d camp_team=%d" % [String(r.get("msg", "")), t.camp_level, t.camp_team_id])
	# ★途中不得在別格紮營（求生路徑會在 TASK_CAMP 途中踩到可紮的格就地紮；玩家子隊不自動求生）
	var stray: Array = []
	for k in st.world.tiles:
		var tt: HexTileData = st.world.tiles[k]
		if tt.camp_level > 0 and tt.camp_team_id == sid and tt.tile_pos != tgt:
			stray.append(tt.tile_pos)
	print("   途中別格營地：%s" % str(stray))
	_check("S5b 途中沒有在別格紮營", stray.is_empty())
	_check("S5 落腳 ⇒ 目標格出現 L0 營地（起建隊＝子隊）", t.camp_level == 1 and t.camp_team_id == sid)
	# 已有據點的格 ⇒ 不可帶原因
	var op: Vector2i = _other_free_neighbor(st, tgt)
	if op != Vector2i(-1, -1):
		_seed_foreign_outpost(st, op)
	var chk: Dictionary = _precheck(st, pt, op, TeamData.TASK_CAMP) if op != Vector2i(-1, -1) else {}
	print("   已有據點的格 %s ⇒ %s" % [str(op), str(chk)])
	_check("S5 已有據點的格 ⇒ 不可、帶原因", op != Vector2i(-1, -1) and not bool(chk.get("ok", true)) and String(chk.get("reason", "")) != "")


# ── S6 移居自家據點 ──────────────────────────────────────────────────────────
func _s6_settle() -> void:
	print("\n── S6 移居自家據點 ──")
	var st: WorldState = _world()
	var runner := SimRunner.new()
	var pt: TeamData = _pt(st)
	var tgt: Vector2i = _free_neighbor(st)
	var t: HexTileData = _tile(st, tgt) if tgt != Vector2i(-1, -1) else null
	_check("★S6 地板：一格外有空格可佈置成自家據點", t != null)
	if t == null:
		return
	t.outpost_type = "civilian"
	t.outpost_level = 1
	OutpostOwnerBank.set_owner(st, t, pt.team_id, "bed_seed")
	var r: Dictionary = _dispatch(st, TeamData.TASK_SETTLE, tgt)
	var sid: int = int(r.get("sub_id", -1))
	_arrive(st, runner, sid)
	_until(st, runner, func(): return st.teams.get(sid) == null or (st.teams[sid] as TeamData).parent_team_id == -1,
		WorldState.TICKS_PER_DAY, "S6 轉居民")
	var sub: TeamData = st.teams.get(sid)
	print("   「%s」｜子隊 tags=%s parent=%d" % [String(r.get("msg", "")), str(sub.tags) if sub != null else "-", sub.parent_team_id if sub != null else -9])
	_check("S6 移居自家據點 ⇒ 成為居民（生產 tag、脫離母隊）", sub != null and sub.tags.has(TeamData.TAG_PRODUCE) and sub.parent_team_id == -1)
	var other: Vector2i = _other_free_neighbor(st, tgt)
	if other != Vector2i(-1, -1):
		_seed_foreign_outpost(st, other)
	var chk: Dictionary = _precheck(st, pt, other, TeamData.TASK_SETTLE) if other != Vector2i(-1, -1) else {}
	print("   別人的據點 %s ⇒ %s" % [str(other), str(chk)])
	_check("S6 非自家據點 ⇒ 不可、原因「不是你的據點」", other != Vector2i(-1, -1) and not bool(chk.get("ok", true)) and String(chk.get("reason", "")).contains("不是你的據點"))


# ── S7 建設 ──────────────────────────────────────────────────────────────────
func _s7_build() -> void:
	print("\n── S7 建設 ──")
	var st: WorldState = _world()
	var runner := SimRunner.new()
	var pt: TeamData = _pt(st)
	var tgt: Vector2i = _free_neighbor(st)
	_check("★S7 地板：一格外有可建的格", tgt != Vector2i(-1, -1))
	if tgt == Vector2i(-1, -1):
		return
	# 缺料 ⇒ 不可
	ResourceBank.set_amt(pt, "material", 0.0, "bed_seed")
	st.player_state["sub_pop_count"] = 3
	st.player_state["sub_build_type"] = "civilian"
	var short: Dictionary = _precheck(st, pt, tgt, TeamData.TASK_CONSTRUCT, 3)
	print("   缺料 ⇒ %s" % str(short))
	_check("S7 缺料 ⇒ 不可、帶原因（需…子隊帶…）", not bool(short.get("ok", true)) and String(short.get("reason", "")).contains("子隊帶"))
	ResourceBank.set_amt(pt, "material", 5000.0, "bed_seed")
	var deny0: int = int(Probe.counts.get("arbiter.deny.possessed.by.construction_started", 0))
	var r: Dictionary = _dispatch(st, TeamData.TASK_CONSTRUCT, tgt, 3, "civilian")
	var sid: int = int(r.get("sub_id", -1))
	print("   派遣「%s」" % String(r.get("msg", "")))
	_arrive(st, runner, sid)
	_adv(st, runner, 2)
	var t: HexTileData = _tile(st, tgt)
	var sub: TeamData = st.teams.get(sid)
	var left0: int = t.construction_ticks_left
	_adv(st, runner, 60)
	var left1: int = t.construction_ticks_left
	print("   抵達後 task=%s 工地隊=%d｜工量 %d→%d" % [sub.current_task if sub != null else "-", t.construction_team_id, left0, left1])
	_check("S7 抵達後 task＝建設、construction_team_id＝子隊、進度推進", sub != null and sub.current_task == TeamData.TASK_BUILD
		and t.construction_team_id == sid and left1 < left0)
	_check("S7c start_build 的 transition 在玩家子隊上不被 deny（具名來源）",
		int(Probe.counts.get("arbiter.deny.possessed.by.construction_started", 0)) == deny0 and sub != null and sub.current_task == TeamData.TASK_BUILD)
	# S7b 完工 → 召回 ⇒ owner 仍是玩家隊
	t.construction_ticks_left = 1
	_until(st, runner, func(): return t.outpost_level > 0, WorldState.TICKS_PER_DAY, "S7b 完工")
	var owner_done: int = t.outpost_owner
	var rec: Dictionary = _recall(st, sid)
	var merged: bool = _wait_gone(st, runner, sid, 4 * WorldState.TICKS_PER_DAY)
	print("   完工 owner=%d（玩家 %d）｜召回「%s」併回=%s｜之後 owner=%d" % [owner_done, pt.team_id, String(rec.get("msg", "")), str(merged), t.outpost_owner])
	_check("S7b 完工 owner＝玩家隊；召回併回後仍是玩家隊", owner_done == pt.team_id and merged and t.outpost_owner == pt.team_id)


# ★修前樹沒有 pop_count 參數 ⇒ 走 callv（修前呼不到就回空字典＝那一格紅，不是編不過）
func _precheck(st: WorldState, pt: TeamData, pos: Vector2i, task: String, pop: int = -1) -> Dictionary:
	st.player_state["sub_pop_count"] = pop
	var res = PlayerCommandSystem.new().callv("precheck_dispatch_task", [st, pt, pos, task, 1.0, pop] if pop > 0 else [st, pt, pos, task])
	return res if res is Dictionary else {}

func _recall(st: WorldState, sid: int) -> Dictionary:
	st.player_state["recall_sub_id"] = sid
	return PlayerCommandSystem.new().execute_action(st, -1, "recall_subteam")


func _wait_gone(st: WorldState, runner: SimRunner, sid: int, max_ticks: int) -> bool:
	for i in range(max_ticks):
		if not st.teams.has(sid):
			return true
		_adv(st, runner, 1)
	return not st.teams.has(sid)


# ── S8 被攻擊／紀律 ──────────────────────────────────────────────────────────
func _s8_attacked() -> void:
	print("\n── S8 被攻擊／紀律脫離 ──")
	var st: WorldState = _world()
	var runner := SimRunner.new()
	var pt: TeamData = _pt(st)
	var r: Dictionary = _dispatch(st, TeamData.TASK_IDLE, pt.tile_pos)
	var sid: int = int(r.get("sub_id", -1))
	var atk: int = -1
	for tid in st.teams:
		var o: TeamData = st.teams[tid]
		if int(tid) != pt.team_id and int(tid) != sid and o.beast_kind == "" and o.combat_target == -1 and o.parent_team_id == -1:
			atk = int(tid)
			break
	var seq0: int = st.player_event_seq
	st.teams[atk].tile_pos = st.teams[sid].tile_pos
	NpcCombatSystem.new().start_combat(st, atk, sid)
	var stop: Dictionary = WorldEvents.stop_event_since(st, seq0)
	var txt: String = ""
	for e in st.player_events:
		if int(e.get("seq", 0)) > seq0 and String(e.get("kind", "")) == "player_subteam":
			txt = String(e.get("text", ""))
	_adv(st, runner, 30)
	var sub: TeamData = st.teams.get(sid)
	print("   事件「%s」｜停點 kind=%s｜30 分鐘後 task=%s" % [txt, String(stop.get("kind", "")), sub.current_task if sub != null else "(沒了)"])
	_check("S8 事件流有「你的子隊…攻擊」且是推進停點", txt.contains("你的子隊") and txt.contains("攻擊") and String(stop.get("kind", "")) == "player_subteam")
	_check("S8 不自動逃（task 不是逃跑）", sub == null or sub.current_task != TeamData.TASK_FLEE)
	# S8b 紀律：壓到必脫離的人心，直接呼那一支（randf 合法機率）
	var st2: WorldState = _world()
	var p2: TeamData = _pt(st2)
	var r2: Dictionary = _dispatch(st2, TeamData.TASK_IDLE, p2.tile_pos)
	var s2: TeamData = st2.teams.get(int(r2.get("sub_id", -1)))
	var ld: PersonData = st2.persons.get(s2.leader_id)
	ld.loyalty = 0.0
	ld.stress = 1.0
	var seq2: int = st2.player_event_seq
	var fired: bool = false
	for i in range(2000):
		if FactionAISystem.shared()._check_discipline(st2, s2):
			fired = true
			break
	var txt2: String = ""
	for e in st2.player_events:
		if int(e.get("seq", 0)) > seq2 and String(e.get("kind", "")) == "player_subteam":
			txt2 = String(e.get("text", ""))
	print("   紀律脫離 fired=%s｜事件「%s」｜之後 player_controlled=%s" % [str(fired), txt2, str(s2.get("player_controlled"))])
	_check("S8b 紀律失效脫離 ⇒ 玩家事件、不再是玩家子隊", fired and txt2.contains("紀律失效") and s2.get("player_controlled") != true)


# ── S9 召回 ──────────────────────────────────────────────────────────────────
func _s9_recall() -> void:
	print("\n── S9 召回 ──")
	var st: WorldState = _world()
	var runner := SimRunner.new()
	var tgt: Vector2i = _free_neighbor(st)
	var r: Dictionary = _dispatch(st, TeamData.TASK_FORAGE, tgt)
	var sid: int = int(r.get("sub_id", -1))
	_arrive(st, runner, sid)
	_adv(st, runner, WorldState.TICKS_PER_DAY)   # 抵達後停一天（歸建閘有 cadence；修前 1 天內必吞，見 S1）
	# ★地板：召回前子隊還在 —— 否則「子隊消失」是抵達即歸建閘先吞掉的，不是召回做的（修前就是這樣綠的）
	_check("★S9 地板：召回前子隊還在（不是先被歸建閘吞掉）", st.teams.has(sid))
	var pop0: int = _pt(st).population
	var rec: Dictionary = _recall(st, sid)
	var merged: bool = _wait_gone(st, runner, sid, 4 * WorldState.TICKS_PER_DAY)
	print("   召回「%s」｜併回=%s｜母隊人口 %d→%d" % [String(rec.get("msg", "")), str(merged), pop0, _pt(st).population])
	_check("S9 召回 ⇒ 併回（子隊消失、人回母隊）", merged and _pt(st).population > pop0)


# ── S10 腳下派遣 ─────────────────────────────────────────────────────────────
func _s10_at_foot() -> void:
	print("\n── S10 腳下派遣 ──")
	var st: WorldState = _world()
	var pt: TeamData = _pt(st)
	var r: Dictionary = _dispatch(st, TeamData.TASK_FORAGE, pt.tile_pos)
	var sub: TeamData = st.teams.get(int(r.get("sub_id", -1)))
	print("   派遣當下 move_target=%s" % (str(sub.move_target) if sub != null else "-"))
	_check("S10 腳下派遣 ⇒ 當下就算抵達（不等移動計時）", sub != null and sub.move_target == Vector2i(-1, -1) and sub.tile_pos == pt.tile_pos)


# ── S12 自主子隊 ─────────────────────────────────────────────────────────────
func _s12_autonomous() -> void:
	print("\n── S12 自主子隊（換附身後繼承來的）──")
	var st: WorldState = _world()
	var runner := SimRunner.new()
	var pt: TeamData = _pt(st)
	# 不經玩家派遣路徑 ⇒ 沒有 dispatched_by_player（＝換附身時新附身隊既有的子隊）
	var sid: int = SubteamSystem.new().dispatch(st, pt.team_id, _spare_leader(st, pt), 3, TeamData.TASK_IDLE, Vector2i(-1, -1))
	var sub: TeamData = st.teams.get(sid)
	var panel: Dictionary = PlayerApiMapper.map_subteam_panel(st)
	var auto_mark: bool = false
	for row in panel.get("subteams", []):
		if int(row.get("team_id", -1)) == sid:
			auto_mark = bool(row.get("autonomous", false))
	_check("S12 面板標「自主」（非你派出）", auto_mark and sub.get("player_controlled") != true)
	# 被拒的令不翻
	st.player_state["order_sub_id"] = sid
	st.player_state["sub_new_task"] = "fly_to_moon"
	st.player_state["sub_new_move_q"] = -1
	st.player_state["sub_new_move_r"] = -1
	var bad: Dictionary = PlayerCommandSystem.new().execute_action(st, -1, "order_subteam")
	_check("S12 被拒的令不翻（仍自主）", not bool(bad.get("ok", true)) and sub.get("dispatched_by_player") != true)
	# 下令移動 ⇒ 翻 ⇒ 24 小時無決策層改派
	var tgt: Vector2i = _free_neighbor(st)
	st.player_state["sub_new_task"] = TeamData.TASK_IDLE
	st.player_state["sub_new_move_q"] = tgt.x
	st.player_state["sub_new_move_r"] = tgt.y
	var ok: Dictionary = PlayerCommandSystem.new().execute_action(st, -1, "order_subteam")
	var changes: Array = []
	var w := func() -> void:
		var s: TeamData = st.teams.get(sid)
		if s == null:
			changes.append("消失")
		elif s.current_task != TeamData.TASK_IDLE or (s.move_target != tgt and s.move_target != Vector2i(-1, -1)):
			changes.append("t%d %s→%s" % [st.world.current_tick, s.current_task, str(s.move_target)])
	_adv(st, runner, WorldState.TICKS_PER_DAY, w)
	var s1: TeamData = st.teams.get(sid)
	print("   下令「%s」｜player_controlled=%s｜24 小時改派 %d 筆 %s｜位置 %s" % [String(ok.get("msg", "")),
		str(s1.get("player_controlled")) if s1 != null else "-", changes.size(), str(changes.slice(0, 3)), str(s1.tile_pos) if s1 != null else "-"])
	_check("S12 下令被接受 ⇒ 成為玩家子隊、24 小時無決策層改派、走到了目標格", bool(ok.get("ok", false)) and s1 != null
		and s1.get("player_controlled") == true and changes.is_empty() and s1.tile_pos == tgt)


# ── S13 自家人與 arbiter（負對照補格：決策層入口已跳過玩家子隊 ⇒ 下面三把要直接呼叫才看得到）──
func _s13_kin_and_arbiter() -> void:
	print("
── S13 自家人／arbiter ──")
	var st: WorldState = _world()
	var pt: TeamData = _pt(st)
	# S3b：玩家子隊的 arbiter 擋決策層來源
	var r: Dictionary = _dispatch(st, TeamData.TASK_IDLE, pt.tile_pos)
	var ps: TeamData = st.teams.get(int(r.get("sub_id", -1)))
	var ok_set: bool = TaskArbiter.try_set(st, ps, TeamData.TASK_FORAGE, ps.tile_pos, TaskArbiter.PRIO_DISPATCH, "unified") if ps != null else true
	print("   玩家子隊 try_set(覓食, unified) ⇒ %s｜task=%s" % [str(ok_set), ps.current_task if ps != null else "-"])
	_check("S3b 玩家子隊：arbiter 擋決策層來源（unified）", ps != null and not ok_set and ps.current_task == TeamData.TASK_IDLE)
	# 自主子隊（非玩家派出）站在母隊格
	var sid: int = SubteamSystem.new().dispatch(st, pt.team_id, _spare_leader(st, pt), 2, TeamData.TASK_IDLE, Vector2i(-1, -1))
	var sub: TeamData = st.teams.get(sid)
	if sub == null:
		_check("★S13 地板：自主子隊派得出", false)
		return
	var disc: Array = st.team_discovered.get(sid, [])
	if not disc.has(pt.team_id):
		disc.append(pt.team_id)
	st.team_discovered[sid] = disc
	var ldr: PersonData = st.persons.get(sub.leader_id)
	var pl: PersonData = st.persons.get(pt.leader_id)
	# ★佈置成「不排除自家人就一定會走到提案」：慎重 0（不被人格骰斷）、跟母隊領袖關係滿、名聲滿 ⇒ 分數過 0.4
	if ldr != null:
		ldr.values["慎重"] = 0.0
		ldr.values["義氣"] = 1.0
		ldr.values["信義"] = 1.0
		if pl != null:
			ldr.relations[pl.id] = 1.0
	sub.known_reputations[pt.team_id] = 1.0
	# S4b：自主子隊不對母隊走到提案那一步（通商暫停中 ⇒ 數 dip.trade_paused ＋ 找上門 ＋ 送出）
	var dip := DiplomaticAiSystem.new()
	var fired: int = 0
	var tp0: int = int(Probe.counts.get("dip.trade_paused", 0))
	for i in range(300):
		st.player_forced_event = {}
		dip.try_proactive_diplomacy(st, sub)
		if not st.player_forced_event.is_empty():
			fired += 1
	st.player_forced_event = {}
	var tp: int = int(Probe.counts.get("dip.trade_paused", 0)) - tp0
	print("   自主子隊同格 300 次 try_proactive_diplomacy ⇒ 找上門 %d 次、走到通商（暫停）%d 次｜Probe.enabled=%s" % [fired, tp, str(Probe.enabled)])
	_check("★S4b 地板：Probe 有開（不然通商那一格恆 0）", Probe.enabled)
	_check("S4b 自主子隊不對母隊外交（譜系，不看勢力）", fired == 0 and tp == 0)
	# S4c：威脅掃描不選母隊 —— 佈置成「不排除自家人就會選它」：親見母隊位置（本 tick firsthand）＋名聲 0（敵意滿）
	sub.known_reputations[pt.team_id] = 0.0
	BeliefSystem.record_claim(st, sid, pt.team_id, sid, "firsthand", {"tile_pos": pt.tile_pos, "pop": pt.population}, 1.0, false)
	var raw: float = ThreatAssessment.score(st, sub, pt)
	var ctx: DecisionContext = DecisionContext.gather(st, sub)
	print("   自主子隊對母隊威脅原始分=%.2f｜掃描結果最大威脅 id=%d（母隊 %d）分=%.2f" % [raw, ctx.threat_id, pt.team_id, ctx.threat_react])
	_check("★S4c 地板：母隊在分數上是威脅（原始分 > 0）", raw > 0.0)
	_check("S4c 自主子隊威脅掃描不選母隊", ctx.threat_id != pt.team_id)
