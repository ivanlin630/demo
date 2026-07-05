extends SceneTree

# ★ 序3.5 threat preempt 融合驗（藍圖雙關）。承 threat_seam_diag 正式化。
#   忙碌目標對壓境攻擊者盲（idle-gate seam）→ 強威脅 preempt 非緊急進行中 task。
#   門檻鎖「真能傷你」（threat_react 訊號＝相對戰力+逼近+敵意），非「見武裝就恐慌」。
#
#   ① 該出現：忙碌隊（TASK_MANUFACTURE）+ 壓境攻擊者（40 武裝、敵意、逼近）
#            → _evaluate_threat 後放下製造，派 defensive（逃/備戰/迎戰/求和）。
#   ② 反向守 3（防抖動，禁「見武裝就 preempt」；★禁讀 tag，由 threat_react 低分自然滿足）：
#      a) 弱攻擊者（3 武裝 power_ratio<1、敵意、非逼近） → 續製造
#      b) 中立帶刀商隊（rep=1.0 友好、有武裝、非逼近）    → 續製造
#      c) 逼近但弱（3 武裝 power_ratio<1、逼近、敵意）    → 續製造
#   ③ 感知鐵律：反向 case 全用 belief 表象 pop_est + rep + 逼近設定，禁設 tag 打折。
# 任一破 = 融合失敗。

var _fails: int = 0

func _initialize() -> void:
	print("=== threat preempt 融合驗（雙關）===")
	_run_cases()
	if _fails == 0:
		print("[threat-preempt] ALL PASS")
	else:
		print("[threat-preempt] FAIL count=%d" % _fails)
	quit()

# 構世界：忙碌 non-unified 隊（current_task=TASK_MANUFACTURE、好戰 leader、10 pop、非居民）
#         + 單一攻擊者（pop_est / rep / 逼近 由參數控）。呼真 _evaluate_threat，回結果。
# 回 { react, threshold, task }。attacker 全靠 belief 表象 + rep + 位移，無 tag 打折。
func _mk_case(attacker_pop: int, rep: float, approaching: bool,
		busy_task: String = TeamData.TASK_MANUFACTURE, tags: Array = ["軍隊"],
		resident: bool = false) -> Dictionary:
	var state := WorldState.new(); state.world = WorldData.new()
	# 忙碌目標：tags 控 unified 與否（軍隊=non-unified 直驗 gate；TAG_PRODUCE=定居生產隊 unified 走 preempt path）。
	var tid := 900
	var t := TeamData.new(); t.team_id = tid; t.tags = tags
	t.tile_pos = Vector2i(5, 5); t.leader_id = tid * 10
	AnonTierSystem.add_anon(t, "平民", 10)
	t.resources = {"food": 300.0}
	t.current_task = busy_task                   # 忙碌（可 preempt）
	t.task_priority = TaskArbiter.PRIO_AMBIENT if busy_task == TeamData.TASK_PRODUCE \
		else TaskArbiter.PRIO_DISPATCH           # 生產=PRIO_AMBIENT(10)、製造=PRIO_DISPATCH(50)；PRIO_THREAT(70) 皆可打斷
	t.combat_target = -1
	state.teams[tid] = t
	state.team_discovered[tid] = []
	state.team_intel[tid] = {}
	var ldr := PersonData.new(); ldr.id = tid * 10; ldr.team_id = tid
	ldr.values = {"求生欲": 0.5, "好戰": 0.9, "慎重": 0.2, "貪婪": 0.5, "信義": 0.5}
	state.persons[ldr.id] = ldr
	_place_plains(state, Vector2i(5, 5))
	# resident：自家 outpost 站點（is_resident_static → TAG_PRODUCE + outpost_owner==self）→ 迎戰排除、逃/備戰/求和仍可。
	if resident:
		var tile: HexTileData = state.world.tiles.get(5 * 1000 + 5)
		tile.outpost_level = 1; tile.outpost_owner = tid; tile.outpost_type = "village"
	# 攻擊者：位置 (6,5)。逼近 → last_tile_pos = 後一格 (7,5)（velocity=(-1,0) 朝我(5,5)，approach=1）；
	# 非逼近 → last=tile（velocity=0，approach=0）。（velocity 幅度須 1，>1 會跨過我 → approach 誤判 0）
	var etid := 901
	var e := TeamData.new(); e.team_id = etid; e.tile_pos = Vector2i(6, 5); e.faction_id = -1
	e.last_tile_pos = Vector2i(7, 5) if approaching else Vector2i(6, 5)
	AnonTierSystem.add_anon(e, "戰士", attacker_pop)
	state.teams[etid] = e
	_place_plains(state, Vector2i(6, 5))
	t.known_reputations[etid] = rep
	state.team_discovered[tid].append(etid)
	# belief 表象：pop_est = attacker_pop（觀察者所見武裝規模，非全知 tag）。
	BeliefSystem.record_claim(state, tid, etid, etid, "親見", {"population_est": attacker_pop}, 1.0, false)

	var fai := FactionAISystem.new()
	var ctx := DecisionContext.gather(state, t)
	Probe.enabled = true
	fai._evaluate_threat(state, t)
	return { "react": ctx.threat_react, "threshold": ctx.threat_threshold, "task": t.current_task,
		"unified": fai.uses_unified(t), "resident": ctx.is_resident }

func _is_defensive(task: String) -> bool:
	return task in [TeamData.TASK_FLEE, TeamData.TASK_DEFEND, TeamData.TASK_PREPARE, TeamData.TASK_DIPLOMACY]

func _run_cases() -> void:
	# ① 該出現：40 武裝、敵意(rep 0.05)、逼近 → 放下製造。
	var c1 := _mk_case(40, 0.05, true)
	print("[① 該出現] react=%.2f threshold=%.2f task=%s" % [c1.react, c1.threshold, c1.task])
	if _is_defensive(c1.task):
		print("[該出現] 忙碌目標遇壓境 → 放下製造 派 %s OK" % c1.task)
	else:
		_fails += 1
		print("[FAIL 該出現] 忙碌目標遇壓境攻擊竟續 %s（seam 未斷/門檻過高）" % c1.task)

	# ②a 弱 + 敵意 + 非逼近 → 續製造。
	var c2a := _mk_case(3, 0.05, false)
	_assert_hold("②a 弱敵意非逼近", c2a, TeamData.TASK_MANUFACTURE)
	# ②b 中立帶刀商隊：rep 友好、有武裝(pop 12)、非逼近 → 續製造。
	var c2b := _mk_case(12, 1.0, false)
	_assert_hold("②b 中立帶刀商隊", c2b, TeamData.TASK_MANUFACTURE)
	# ②c 逼近但弱 + 敵意 → 續製造（power_ratio<1，非「能傷你」）。
	var c2c := _mk_case(3, 0.05, true)
	_assert_hold("②c 逼近但弱", c2c, TeamData.TASK_MANUFACTURE)

	# ── ③ 定居生產隊（follow-up）：TASK_PRODUCE + TAG_PRODUCE(unified) 走 preempt path ──
	# ③a 該出現：定居生產隊遇壓境能殺攻擊者 → 放下生產派 defensive（藍圖「犁田遇劫匪放犁」核心）。
	var c3a := _mk_case(40, 0.05, true, TeamData.TASK_PRODUCE, [TeamData.TAG_PRODUCE], false)
	print("[③a 定居生產遇壓境] react=%.2f threshold=%.2f unified=%s task=%s" % [c3a.react, c3a.threshold, c3a.unified, c3a.task])
	if _is_defensive(c3a.task):
		print("[該出現] 生產隊遇壓境 → 放下生產 派 %s OK（TASK_PRODUCE seam 接）" % c3a.task)
	else:
		_fails += 1
		print("[FAIL 該出現] 定居生產隊遇壓境竟續 %s（TASK_PRODUCE 漏 preempt）" % c3a.task)

	# ③b resident guard：居民生產隊（自家 outpost）迎戰排除 → 須派非迎戰 defensive（逃/備戰/求和），不卡死。
	var c3b := _mk_case(40, 0.05, true, TeamData.TASK_PRODUCE, [TeamData.TAG_PRODUCE], true)
	print("[③b 居民生產遇壓境] react=%.2f resident=%s task=%s" % [c3b.react, c3b.resident, c3b.task])
	if c3b.task == TeamData.TASK_DEFEND:
		_fails += 1
		print("[FAIL resident guard] 居民生產隊竟派迎戰(DEFEND)——居民應排除迎戰")
	elif _is_defensive(c3b.task):
		print("[resident guard] 居民生產隊 → 非迎戰 defensive %s OK（迎戰排除不卡死）" % c3b.task)
	else:
		_fails += 1
		print("[FAIL resident guard] 居民生產隊遇壓境竟續 %s（迎戰排除後無反應=卡死）" % c3b.task)

	# ③c 反向守（TASK_PRODUCE）：路過弱/中立 → 續生產。
	var c3d := _mk_case(3, 0.05, false, TeamData.TASK_PRODUCE, [TeamData.TAG_PRODUCE], false)
	_assert_hold("③c 生產+弱非逼近", c3d, TeamData.TASK_PRODUCE)
	var c3e := _mk_case(12, 1.0, false, TeamData.TASK_PRODUCE, [TeamData.TAG_PRODUCE], false)
	_assert_hold("③c 生產+中立帶刀", c3e, TeamData.TASK_PRODUCE)

func _assert_hold(label: String, c: Dictionary, hold_task: String) -> void:
	print("[%s] react=%.2f threshold=%.2f task=%s" % [label, c.react, c.threshold, c.task])
	if c.task == hold_task:
		print("[反向守] %s → 續%s 不抖動 OK" % [label, hold_task])
	else:
		_fails += 1
		print("[FAIL 反向守] %s 誤 preempt 成 %s（見武裝就恐慌）" % [label, c.task])

func _place_plains(state: WorldState, pos: Vector2i) -> void:
	var tile := HexTileData.new()
	tile.tile_id = pos.x * 1000 + pos.y; tile.tile_pos = pos; tile.terrain = "plains"
	state.world.tiles[tile.tile_id] = tile
