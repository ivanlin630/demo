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
func _mk_case(attacker_pop: int, rep: float, approaching: bool) -> Dictionary:
	var state := WorldState.new(); state.world = WorldData.new()
	# 忙碌目標：軍隊 tag（non-unified，直驗 busy-preemptible gate 分支）、10 平民、好戰 leader。
	var tid := 900
	var t := TeamData.new(); t.team_id = tid; t.tags = ["軍隊"]
	t.tile_pos = Vector2i(5, 5); t.leader_id = tid * 10
	AnonTierSystem.add_anon(t, "平民", 10)
	t.resources = {"food": 300.0}
	t.current_task = TeamData.TASK_MANUFACTURE   # 忙碌（可 preempt）
	t.task_priority = TaskArbiter.PRIO_DISPATCH  # 製造 = 日常 dispatch（PRIO_THREAT 70 可打斷）
	t.combat_target = -1
	state.teams[tid] = t
	state.team_discovered[tid] = []
	state.team_intel[tid] = {}
	var ldr := PersonData.new(); ldr.id = tid * 10; ldr.team_id = tid
	ldr.values = {"求生欲": 0.5, "好戰": 0.9, "慎重": 0.2, "貪婪": 0.5, "信義": 0.5}
	state.persons[ldr.id] = ldr
	_place_plains(state, Vector2i(5, 5))
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
	# sanity：非 unified（走 busy-preemptible 分支，非 idle-skip）。
	if fai.uses_unified(t):
		print("[WARN] case 隊竟 unified");
	var ctx := DecisionContext.gather(state, t)
	Probe.enabled = true
	fai._evaluate_threat(state, t)
	return { "react": ctx.threat_react, "threshold": ctx.threat_threshold, "task": t.current_task }

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
	_assert_hold("②a 弱敵意非逼近", c2a)
	# ②b 中立帶刀商隊：rep 友好、有武裝(pop 12)、非逼近 → 續製造。
	var c2b := _mk_case(12, 1.0, false)
	_assert_hold("②b 中立帶刀商隊", c2b)
	# ②c 逼近但弱 + 敵意 → 續製造（power_ratio<1，非「能傷你」）。
	var c2c := _mk_case(3, 0.05, true)
	_assert_hold("②c 逼近但弱", c2c)

func _assert_hold(label: String, c: Dictionary) -> void:
	print("[%s] react=%.2f threshold=%.2f task=%s" % [label, c.react, c.threshold, c.task])
	if c.task == TeamData.TASK_MANUFACTURE:
		print("[反向守] %s → 續製造 不抖動 OK" % label)
	else:
		_fails += 1
		print("[FAIL 反向守] %s 誤 preempt 成 %s（見武裝就恐慌）" % [label, c.task])

func _place_plains(state: WorldState, pos: Vector2i) -> void:
	var tile := HexTileData.new()
	tile.tile_id = pos.x * 1000 + pos.y; tile.tile_pos = pos; tile.terrain = "plains"
	state.world.tiles[tile.tile_id] = tile
