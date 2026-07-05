extends SceneTree

# ★ 序6 faction 成員 dispatch 溶入引擎 融合驗（核心交付）。溶=融合非刪：
#   `_assign_member_tasks` goal→task if/elif 判斷器（含 V2-cmd 徵收 shadow 攻擊）撕除 →
#   faction 成員（非 subteam）走 `_decide_unified`（引擎 rank_scored 競秤）。
#   ★只改成員 dispatch gate（parent_team_id==-1），不動全域 uses_unified → 序3.5 preempt 保。
#
#   融合驗錨（§4）：
#     ① repertoire 沒少：徵收 goal+貪婪→徵收；攻擊 goal+好戰→攻擊；外交 goal→外交；弱 prey→掠奪。
#     ② ★V2-cmd 解：faction {徵收,攻擊} 雙 goal + 好戰成員 → 攻擊可勝（非恆被徵收支配）。
#     ③ ★成員 raid 接回：faction 成員 + 弱 prey → 掠奪 dispatch（打草穀活；序5 待項結清）。
#     ④ ★序3.5 preempt 不破（最高盯點）：忙碌成員（TASK_MANUFACTURE 軍隊）+ 壓境攻擊
#        → _evaluate_threat 仍 preempt（成員非-unified 路 preempt 活）。
#     ⑤ subteam guard：parent_team_id!=-1 成員不入 _decide_unified（防雙寫）。
#   任一破 = 融合失敗。
#
#   世界-based dispatch 測（非純 ctx）：改 gate 前成員走 hand-dispatch cascade → V2-cmd/raid/外交 FAIL；
#   改後走引擎 → PASS。preempt/repertoire-徵收/攻擊 兩態皆綠（保序）。

var _fails: int = 0

func _initialize() -> void:
	print("=== 序6 faction 成員 dispatch 溶入引擎 融合驗 ===")
	_check_repertoire()          # ①
	_check_v2cmd()               # ②
	_check_raid()                # ③
	_check_own_trade_produce()   # ① 本業（ctx）
	_check_preempt_preserved()   # ④
	_check_subteam_guard()       # ⑤
	if _fails == 0:
		print("[faction-dispatch-dissolution] ALL PASS")
	else:
		print("[faction-dispatch-dissolution] FAIL count=%d" % _fails)
	quit()

# ─────────── 世界 fixture builder ───────────
# faction f（faction_id=1，goals），leader team 10（遠置避 MERGE），focal 成員 20 @ (0,0)。
# opts：rich_member（30，遠，food_est 高＝徵收 target）/ indep（40 @ (1,0)，faction_id=-1＝攻擊/外交 target）
#       / prey（50 @ (1,0)，親見 belief 弱＝掠奪 target）/ loyalty。
func _build(member_tags: Array, goals: Array, persona: Dictionary, opts: Dictionary = {}) -> Dictionary:
	Probe.reset()
	var s := _new_state()
	_fill_plains(s, 4)
	var f := FactionData.new()
	f.faction_id = 1
	f.goals = goals.duplicate()
	f.leader_team_id = 10
	f.member_team_ids = [10, 20]
	s.factions[1] = f
	# leader team（遠置：dist>CONSOLIDATE_MAX_DIST=3 → 非 absorber、非 near-leader MERGE）
	var lt := TeamData.new(); lt.team_id = 10; lt.faction_id = 1
	lt.tile_pos = Vector2i(4, 4); lt.tags = ["統領"]
	var lldr := PersonData.new(); lldr.id = 100; lldr.team_id = 10
	s.persons[100] = lldr; lt.leader_id = 100; _seed_pop(lt, 20)
	s.teams[10] = lt
	# focal 成員 @ (0,0)
	var mt := TeamData.new(); mt.team_id = 20; mt.faction_id = 1
	mt.tile_pos = Vector2i(0, 0); mt.tags = member_tags.duplicate()
	mt.current_task = TeamData.TASK_IDLE; mt.combat_target = -1
	mt.armed_anon_ratio = 1.0
	mt.resources = {"food": 9999.0, "weapon_melee_low": 20.0}
	var mldr := PersonData.new(); mldr.id = 200; mldr.team_id = 20
	mldr.values = persona.duplicate(); mldr.loyalty = float(opts.get("loyalty", 1.0))
	s.persons[200] = mldr; mt.leader_id = 200; _seed_pop(mt, 12)
	s.teams[20] = mt
	s.team_discovered[20] = []
	f.known_member_states[20] = {"current_task": TeamData.TASK_IDLE, "food_est": 0.0}
	if bool(opts.get("rich_member", false)):
		f.member_team_ids.append(30)
		var rt := TeamData.new(); rt.team_id = 30; rt.faction_id = 1
		rt.tile_pos = Vector2i(-4, -4); rt.tags = ["軍隊"]
		var rl := PersonData.new(); rl.id = 300; rl.team_id = 30
		s.persons[300] = rl; rt.leader_id = 300; _seed_pop(rt, 12)
		rt.resources = {"food": 500.0, "coin": 900.0}
		s.teams[30] = rt
		f.known_member_states[30] = {"current_task": TeamData.TASK_IDLE, "food_est": 500.0}
	if bool(opts.get("indep", false)):
		var it := TeamData.new(); it.team_id = 40; it.faction_id = -1
		it.tile_pos = Vector2i(1, 0)
		var il := PersonData.new(); il.id = 400; il.team_id = 40
		s.persons[400] = il; it.leader_id = 400; _seed_pop(it, 4)
		it.resources = {"food": 50.0}
		s.teams[40] = it
		s.team_discovered[20].append(40)
		mt.known_reputations[40] = 0.5   # neutral-ish → 非壓境威脅
	if bool(opts.get("prey", false)):
		var pt := TeamData.new(); pt.team_id = 50; pt.faction_id = -1
		pt.tile_pos = Vector2i(1, 0)
		var pl := PersonData.new(); pl.id = 500; pl.team_id = 50
		s.persons[500] = pl; pt.leader_id = 500; _seed_pop(pt, 3)
		pt.resources = {"food": 30.0, "coin": 100.0}
		s.teams[50] = pt
		s.team_discovered[20].append(50)
		BeliefSystem.record_claim(s, 20, 50, 20, "親見",
			{"population_est": 3.0, "armed_est": 1.0, "tile_pos": Vector2i(1, 0),
			"coin_est": 100.0, "food_est": 30.0}, 1.0, false)
	return {"s": s, "f": f, "mt": mt}

func _dispatch(w: Dictionary) -> String:
	var fai := FactionAISystem.new()
	fai._assign_member_tasks(w["s"], w["f"])
	return (w["mt"] as TeamData).current_task

# ─────────── ① repertoire ───────────
func _check_repertoire() -> void:
	print("--- ① repertoire（徵收/攻擊/外交 各得對應）---")
	# 徵收 goal + 貪婪成員 → 徵收（兩態皆綠：保序）
	var w1 := _build(["軍隊"], ["徵收"], {"貪婪": 0.9, "好戰": 0.1, "野心": 0.5}, {"rich_member": true})
	_assert_task("徵收 goal+貪婪 → 徵收", _dispatch(w1), TeamData.TASK_TRIBUTE)
	# 攻擊 goal + 好戰成員 → 攻擊（兩態皆綠：保序）
	var w2 := _build(["軍隊"], ["攻擊"], {"好戰": 0.9, "殘忍": 0.9, "野心": 0.5}, {"indep": true})
	_assert_task("攻擊 goal+好戰 → 攻擊", _dispatch(w2), TeamData.TASK_ATTACK)
	# 外交 goal → 外交（軍隊 tag_weight(外交)=0 → 改前 hand-dispatch 走不到=IDLE；改後引擎 faction_duty 派）
	var w3 := _build(["軍隊"], ["外交"], {"義氣": 0.8, "計謀": 0.6, "好戰": 0.2}, {"indep": true})
	_assert_task("外交 goal → 外交", _dispatch(w3), TeamData.TASK_DIPLOMACY)

# ─────────── ② V2-cmd 解 ───────────
func _check_v2cmd() -> void:
	print("--- ② ★V2-cmd 解（{徵收,攻擊}雙goal+好戰 → 攻擊可勝）---")
	# 改前：cascade `if 徵收 ... elif 攻擊` → 好戰成員恆被徵收支配（TASK_TRIBUTE）=shadow。
	# 改後：引擎競秤，攻擊 util(faction_duty+attack_drive) > 徵收 util(faction_duty+levy_drive) → TASK_ATTACK。
	var w := _build(["軍隊"], ["徵收", "攻擊"],
		{"好戰": 0.9, "殘忍": 0.9, "貪婪": 0.2, "野心": 0.5, "信義": 0.1},
		{"rich_member": true, "indep": true})
	var t: String = _dispatch(w)
	if t == TeamData.TASK_ATTACK:
		print("[v2cmd] 好戰成員雙goal → 攻擊勝徵收 OK（shadow 自消，task=%s）" % t)
	else:
		_fails += 1
		print("[FAIL v2cmd] 預期 TASK_ATTACK 得 %s（徵收 shadow 未解）" % t)
	# 反向：貪婪成員同雙goal → 徵收勝（人格分歧真在秤）
	var w2 := _build(["軍隊"], ["徵收", "攻擊"],
		{"好戰": 0.1, "殘忍": 0.1, "貪婪": 0.9, "野心": 0.5, "信義": 0.5},
		{"rich_member": true, "indep": true})
	var t2: String = _dispatch(w2)
	if t2 == TeamData.TASK_TRIBUTE:
		print("[v2cmd] 貪婪成員雙goal → 徵收勝 OK（分歧非抹平，task=%s）" % t2)
	else:
		_fails += 1
		print("[FAIL v2cmd] 反向預期 TASK_TRIBUTE 得 %s" % t2)

# ─────────── ③ 成員 raid 接回 ───────────
func _check_raid() -> void:
	print("--- ③ ★成員 raid 接回（成員+弱prey → 掠奪）---")
	# 改前：cascade 無成員掠奪分支 → IDLE（raid 缺）。改後：引擎 loot_drive → TASK_LOOT（打草穀活）。
	var w := _build(["軍隊"], [], {"殘忍": 0.9, "好戰": 0.9, "貪婪": 0.5, "野心": 0.5}, {"prey": true})
	var t: String = _dispatch(w)
	if t == TeamData.TASK_LOOT:
		print("[raid] 成員見弱prey → 掠奪 dispatch OK（縫#3 結清，task=%s）" % t)
	else:
		_fails += 1
		print("[FAIL raid] 預期 TASK_LOOT 得 %s（成員 raid 未接回）" % t)

# ─────────── ① 本業（生產/貿易 tag → 本業；ctx-quick）───────────
# 生產/貿易 tag 成員改前即 uses_unified 走引擎（無 gate 變）→ ctx 驗本業 option 在秤。
func _check_own_trade_produce() -> void:
	print("--- ① 本業（生產/貿易 tag → 本業 option 可達）---")
	var cp := _mk_ctx({"義氣": 0.6, "慎重": 0.6, "野心": 0.3})
	cp.has_own_outpost = true          # 生產/駐守 applicable
	var op_p: Array = _opts(cp)
	if "生產" in op_p or "駐守" in op_p or "建設" in op_p:
		print("[本業] 生產 tag（has_outpost）→ 本業 option 可達 OK (%s)" % str(op_p))
	else:
		_fails += 1
		print("[FAIL 本業] 生產隊無本業 option (%s)" % str(op_p))
	var ct := _mk_ctx({"貪婪": 0.8, "野心": 0.4})
	ct.is_merchant = true; ct.has_goods = true; ct.has_arb = true
	ct.leader_values["_is_merchant"] = true
	if "貿易" in _opts(ct):
		print("[本業] 貿易 tag（has_goods+arb）→ 貿易 option 可達 OK")
	else:
		_fails += 1
		print("[FAIL 本業] 商隊無貿易 option (%s)" % str(_opts(ct)))

# ─────────── ④ 序3.5 preempt 保（最高盯點）───────────
# 忙碌 non-unified 成員（TASK_MANUFACTURE 軍隊）+ 壓境強攻擊者 → _evaluate_threat 仍 preempt。
# 不動全域 uses_unified → 成員 loop3 threat 路活（反龜縮 seam 保）。
func _check_preempt_preserved() -> void:
	print("--- ④ ★序3.5 preempt 保（忙碌成員遇壓境仍反應）---")
	var s := _new_state()
	var tid := 900
	var t := TeamData.new(); t.team_id = tid; t.tags = ["軍隊"]; t.faction_id = 1
	t.tile_pos = Vector2i(5, 5); t.leader_id = tid * 10
	AnonTierSystem.add_anon(t, "平民", 10)
	t.resources = {"food": 300.0}
	t.current_task = TeamData.TASK_MANUFACTURE
	t.task_priority = TaskArbiter.PRIO_DISPATCH
	t.combat_target = -1
	s.teams[tid] = t
	s.team_discovered[tid] = []
	s.team_intel[tid] = {}
	var ldr := PersonData.new(); ldr.id = tid * 10; ldr.team_id = tid
	ldr.values = {"求生欲": 0.5, "好戰": 0.9, "慎重": 0.2, "貪婪": 0.5, "信義": 0.5}
	s.persons[ldr.id] = ldr
	_place_plains(s, Vector2i(5, 5))
	# 壓境攻擊者 @ (6,5)，逼近（last=(7,5) velocity 朝我），40 武裝、敵意 rep 0.05。
	var etid := 901
	var e := TeamData.new(); e.team_id = etid; e.tile_pos = Vector2i(6, 5); e.faction_id = -1
	e.last_tile_pos = Vector2i(7, 5)
	AnonTierSystem.add_anon(e, "戰士", 40)
	s.teams[etid] = e
	_place_plains(s, Vector2i(6, 5))
	t.known_reputations[etid] = 0.05
	s.team_discovered[tid].append(etid)
	BeliefSystem.record_claim(s, tid, etid, etid, "親見", {"population_est": 40}, 1.0, false)
	var fai := FactionAISystem.new()
	Probe.enabled = true
	fai._evaluate_threat(s, t)
	var defensive := t.current_task in [TeamData.TASK_FLEE, TeamData.TASK_DEFEND,
		TeamData.TASK_PREPARE, TeamData.TASK_DIPLOMACY]
	if defensive and not fai.uses_unified(t):
		print("[preempt] 忙碌 non-unified 成員遇壓境 → 放下製造派 %s OK（uses_unified 未動,序3.5 保）" % t.current_task)
	else:
		_fails += 1
		print("[FAIL preempt] 忙碌成員遇壓境竟續 %s（unified=%s，序3.5 破！）" % [t.current_task, fai.uses_unified(t)])

# ─────────── ⑤ subteam guard（防雙寫）───────────
func _check_subteam_guard() -> void:
	print("--- ⑤ subteam guard（parent_team_id!=-1 不入引擎）---")
	var w := _build(["軍隊"], ["攻擊"], {"好戰": 0.9, "殘忍": 0.9}, {"indep": true})
	var mt: TeamData = w["mt"]
	# 把 focal 成員改成 subteam（parent!=-1）+ 施工中 marker task → dispatch 後應原封不動。
	mt.parent_team_id = 10
	mt.tags = [TeamData.TAG_SUBTEAM]
	mt.current_task = TeamData.TASK_BUILD
	var t: String = _dispatch(w)
	if t == TeamData.TASK_BUILD:
		print("[subteam] subteam 成員不入 _assign_member_tasks 引擎 → 續 %s OK（走 loop2，防雙寫）" % t)
	else:
		_fails += 1
		print("[FAIL subteam] subteam 被成員 dispatch 覆蓋成 %s（雙寫！）" % t)

# ─────────── helpers ───────────
func _assert_task(label: String, got: String, want: String) -> void:
	if got == want:
		print("[repertoire] %s OK (task=%s)" % [label, got])
	else:
		_fails += 1
		print("[FAIL repertoire] %s 預期 %s 得 %s" % [label, want, got])

func _mk_ctx(vals: Dictionary) -> DecisionContext:
	var c := DecisionContext.new()
	c.leader_values = vals
	c.food_days = 14.0
	c.population = 20
	c.threat_threshold = 999.0
	c.self_armed_ratio = 0.8
	return c

func _opts(c: DecisionContext) -> Array:
	var out: Array = []
	for e in DecisionEngine.rank_scored_ctx(c): out.append(e["opt"])
	return out

func _new_state() -> WorldState:
	var s := WorldState.new(); s.world = WorldData.new(); s.player_id = -1
	return s

func _seed_pop(team: TeamData, n: int) -> void:
	var named_in: int = team.named_members.size() + (1 if team.leader_id != -1 else 0)
	var want: int = maxi(n - named_in, 0)
	if want > 0:
		AnonCohort.add(team.anon_cohorts, "平民", "healthy", want)

func _tile(s: WorldState, pos: Vector2i) -> void:
	var key: int = pos.x * 1000 + pos.y
	if not s.world.tiles.has(key):
		var t := HexTileData.new()
		t.tile_id = key; t.tile_pos = pos; t.terrain = "plains"
		s.world.tiles[key] = t

func _fill_plains(s: WorldState, radius: int) -> void:
	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			_tile(s, Vector2i(x, y))

func _place_plains(s: WorldState, pos: Vector2i) -> void:
	var tile := HexTileData.new()
	tile.tile_id = pos.x * 1000 + pos.y; tile.tile_pos = pos; tile.terrain = "plains"
	s.world.tiles[tile.tile_id] = tile
