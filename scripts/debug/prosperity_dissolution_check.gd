extends SceneTree

# ★ 序5 prosperity-attack cascade 溶入引擎 融合驗（核心交付）。融合非刪：cascade 決策
#   (_evaluate_prosperity_attack gate cascade) 溶進引擎 攻擊 option——intent_fit 征服 × readiness/富 prey
#   weight；scout-verify 保為 dispatch-time scaffolding（_commit_conquest_attack）。征服鏈 repertoire 不歸零。
#   鏡射 vendetta/rung/threat check 風格。
#
#   §5 融合驗 6 錨（征服鏈 parity）：
#     ① FORCE 好戰野心隊 + ready + 富弱 prey + 情報夠 → rank_scored[0]=="攻擊"（征服真驅乾淨攻擊鏈）。
#     ② 低 readiness → 攻擊 util 趨 0（沒本錢不出征=readiness 閘，權重非硬閘）→ 非 rank[0]。
#     ③ 慎重隊情報不足 → _commit_conquest_attack 派斥候（TASK_SCOUT + g3.scout_dispatch），非直攻。
#     ④ 莽者情報不足 → 照衝（TASK_ATTACK；confident_enough 門檻低恆過 → S4 誘殺路保）。
#     ⑤ hunger_relief——越餓 readiness_thr_eff 越低（豁出去搶糧；門檻滑降）。
#     ⑥ 富 prey——richness/border 影響 find_prosperity_prey 選誰（非只挑最弱）。
# 任一破 = 融合失敗。

var _fails: int = 0

func _initialize() -> void:
	_check_repertoire()          # ①
	_check_readiness_gate()      # ②
	_check_scout_defer()         # ③
	_check_reckless_charge()     # ④
	_check_hunger_relief()       # ⑤
	_check_rich_prey()           # ⑥
	if _fails == 0:
		print("[prosperity-dissolution] ALL PASS")
	else:
		print("[prosperity-dissolution] FAIL count=%d" % _fails)
	quit()

# ── 手構 ctx（deterministic，繞世界 setup）。leader_values + 征服/readiness 欄位直填 ──
func _ctx(vals: Dictionary) -> DecisionContext:
	var c := DecisionContext.new()
	c.leader_values = vals
	c.food_days = 14.0          # 吃飽（survival_pressure=0；亦關匱乏→搶 boost，隔離征服 intent 路）
	c.population = 20           # > FORAGE_VIABLE_POP → 覓食不 applicable
	c.threat_threshold = 999.0  # 無威脅：threat repertoire 不 applicable
	c.self_armed_ratio = 0.8    # 有牙（capability cap=1）
	return c

func _scored(c: DecisionContext) -> Array:
	return DecisionEngine.rank_scored_ctx(c)

func _opts(c: DecisionContext) -> Array:
	var out: Array = []
	for e in _scored(c): out.append(e["opt"])
	return out

func _first(c: DecisionContext) -> String:
	var r: Array = _scored(c)
	return r[0]["opt"] if not r.is_empty() else "<空>"

func _util_of(c: DecisionContext, opt: String) -> float:
	for e in _scored(c):
		if e["opt"] == opt: return float(e["u"])
	return -1.0

# ── §5-① repertoire：征服 ready 富prey → 攻擊 rank[0] ──
func _check_repertoire() -> void:
	print("--- §5-① repertoire (征服 ready 富prey → 攻擊) ---")
	var c := _ctx({"好戰": 0.9, "野心": 0.9, "慎重": 0.4, "信義": 0.2})
	c.intent = "征服"
	c.intent_target = 1          # 富 prey（rich prey id，has_weak_prey 亦可）
	c.readiness = 0.8
	c.readiness_thr_eff = 0.5
	var top: String = _first(c)
	if top == "攻擊":
		print("[repertoire] FORCE ready 富prey → rank[0]=攻擊 OK (ranked=%s)" % str(_opts(c)))
	else:
		_fails += 1
		print("[FAIL] 預期 rank[0]=攻擊 得 %s (ranked=%s)" % [top, str(_opts(c))])
	# 反向：無征服 intent + 無 prey → 攻擊 不 applicable。
	var c2 := _ctx({"好戰": 0.9, "野心": 0.9})
	if "攻擊" in _opts(c2):
		_fails += 1
		print("[FAIL] 無征服intent/prey 竟開攻擊 (ranked=%s)" % str(_opts(c2)))
	else:
		print("[repertoire] 無征服intent → 攻擊 不 applicable OK")

# ── §5-② readiness 閘：低 readiness → 攻擊 util 趨0 → 非 rank[0] ──
func _check_readiness_gate() -> void:
	print("--- §5-② readiness 閘 (沒本錢不出征) ---")
	var hi := _ctx({"好戰": 0.9, "野心": 0.9, "慎重": 0.4, "信義": 0.2})
	hi.intent = "征服"; hi.intent_target = 1
	hi.readiness = 0.8; hi.readiness_thr_eff = 0.5
	var lo := _ctx({"好戰": 0.9, "野心": 0.9, "慎重": 0.4, "信義": 0.2})
	lo.intent = "征服"; lo.intent_target = 1
	lo.readiness = 0.05; lo.readiness_thr_eff = 0.5   # 沒本錢
	var u_hi: float = _util_of(hi, "攻擊")
	var u_lo: float = _util_of(lo, "攻擊")
	var top_lo: String = _first(lo)
	if u_lo < u_hi and top_lo != "攻擊":
		print("[readiness] 低 readiness 攻擊 util %.3f < 高 readiness %.3f 且非 rank[0](=%s) OK" % [u_lo, u_hi, top_lo])
	else:
		_fails += 1
		print("[FAIL] readiness 閘失效：低=%.3f 高=%.3f top_lo=%s" % [u_lo, u_hi, top_lo])

# ── §5-③ 慎重情報不足 → 派斥候 ──
func _check_scout_defer() -> void:
	print("--- §5-③ 慎重情報不足 → 斥候 ---")
	var s := _world_with_prey(0.7)   # 慎重 0.7
	var atk: TeamData = s.teams[0]
	var fai := FactionAISystem.new()
	var ok: bool = fai._commit_conquest_attack(s, atk, 1)
	if ok and atk.current_task == TeamData.TASK_SCOUT and atk.task_reason == "scout":
		print("[scout] 慎重隊情報不足 → TASK_SCOUT OK (scout_dispatch=%d)" % int(Probe.counts.get("g3.scout_dispatch", 0)))
	else:
		_fails += 1
		print("[FAIL] 慎重情報不足 預期 TASK_SCOUT 得 task=%s reason=%s ok=%s" % [atk.current_task, atk.task_reason, ok])

# ── §5-④ 莽者情報不足 → 照衝（S4 誘殺路保）──
func _check_reckless_charge() -> void:
	print("--- §5-④ 莽者情報不足 → 照衝 ---")
	var s := _world_with_prey(0.05)  # 慎重 0.05（莽者）→ confident_enough 門檻低恆過
	var atk: TeamData = s.teams[0]
	var fai := FactionAISystem.new()
	var ok: bool = fai._commit_conquest_attack(s, atk, 1)
	if ok and atk.current_task == TeamData.TASK_ATTACK and atk.task_reason == "prosperity":
		print("[reckless] 莽者情報不足 → 照衝 TASK_ATTACK OK (誘殺路保)")
	else:
		_fails += 1
		print("[FAIL] 莽者 預期 TASK_ATTACK 得 task=%s reason=%s ok=%s" % [atk.current_task, atk.task_reason, ok])

# ── §5-⑤ hunger_relief：越餓 readiness_thr_eff 越低 ──
func _check_hunger_relief() -> void:
	print("--- §5-⑤ hunger_relief (餓→門檻降) ---")
	var s_fed := _world_with_prey(0.5, 9999.0)   # 吃飽
	var s_hungry := _world_with_prey(0.5, 5.0)    # 5 food / pop → 餓
	var c_fed := DecisionContext.gather(s_fed, s_fed.teams[0])
	var c_hungry := DecisionContext.gather(s_hungry, s_hungry.teams[0])
	if c_hungry.readiness_thr_eff < c_fed.readiness_thr_eff and c_hungry.readiness_thr_eff > 0.0:
		print("[hunger] 餓隊 thr_eff %.3f < 飽隊 %.3f OK (門檻滑降=豁出去搶糧)" % [c_hungry.readiness_thr_eff, c_fed.readiness_thr_eff])
	else:
		_fails += 1
		print("[FAIL] hunger_relief 失效：餓 thr_eff=%.3f 飽=%.3f" % [c_hungry.readiness_thr_eff, c_fed.readiness_thr_eff])

# ── §5-⑥ 富 prey：richness/border 影響 find_prosperity_prey ──
func _check_rich_prey() -> void:
	print("--- §5-⑥ 富 prey 選 (非只最弱) ---")
	var s := _new_state()
	_fill_plains(s, 5)
	var atk := TeamData.new(); atk.team_id = 0; atk.tile_pos = Vector2i(0, 0); atk.faction_id = -1
	var ldr := PersonData.new(); ldr.id = 1; ldr.team_id = 0
	ldr.values = {"貪婪": 0.9, "殘忍": 0.6, "野心": 0.7, "慎重": 0.5}
	s.persons[1] = ldr; atk.leader_id = 1; _seed_pop(atk, 12)
	atk.armed_anon_ratio = 1.0; atk.resources = {"food": 9999.0, "weapon_melee_low": 20.0}
	s.teams[0] = atk
	# 窮弱 prey（近/border，pop 小但無財）：team1 @ (1,0)。
	var poor := TeamData.new(); poor.team_id = 1; poor.tile_pos = Vector2i(1, 0); poor.faction_id = -1
	var p1 := PersonData.new(); p1.id = 2; s.persons[2] = p1; poor.leader_id = 2
	_seed_pop(poor, 3); poor.resources = {"food": 5.0}; s.teams[1] = poor
	# 富 prey（同 border 距，pop 略大但財多）：team2 @ (0,1)。
	var rich := TeamData.new(); rich.team_id = 2; rich.tile_pos = Vector2i(0, 1); rich.faction_id = -1
	var p2 := PersonData.new(); p2.id = 3; s.persons[3] = p2; rich.leader_id = 3
	_seed_pop(rich, 4); rich.resources = {"food": 300.0, "coin": 500.0}; s.teams[2] = rich
	s.team_discovered[0] = [1, 2]
	# 親見 belief（高 cred，值正確）：poor 貧、rich 富。
	BeliefSystem.record_claim(s, 0, 1, 0, "親見",
		{"population_est": 3.0, "armed_est": 1.0, "tile_pos": Vector2i(1, 0), "coin_est": 0.0, "food_est": 5.0}, 1.0, false)
	BeliefSystem.record_claim(s, 0, 2, 0, "親見",
		{"population_est": 4.0, "armed_est": 1.0, "tile_pos": Vector2i(0, 1), "coin_est": 500.0, "food_est": 300.0}, 1.0, false)
	var prey: int = FactionAISystem.find_prosperity_prey(s, atk, ldr)
	if prey == 2:
		print("[rich_prey] find_prosperity_prey → 富 prey(team2) 勝窮弱(team1) OK (貪婪 leader 挑富非最弱)")
	else:
		_fails += 1
		print("[FAIL] 富 prey 預期 team2 得 %d (richness×貪婪 未主導)" % prey)

# ── world helpers ──
# FORCE 獨立攻擊者 + 單一 prey（不確定 belief）。caution=leader 慎重；food=攻擊者食物。
func _world_with_prey(caution: float, food: float = 9999.0) -> WorldState:
	Probe.reset()
	var s := _new_state()
	_fill_plains(s, 3)
	var atk := TeamData.new(); atk.team_id = 0; atk.tile_pos = Vector2i(0, 0); atk.faction_id = -1
	atk.ambition_archetype = AmbitionLadder.ARCHETYPE_FORCE
	atk.ambition_rung = AmbitionLadder.RUNG_EXPAND
	atk.current_task = TeamData.TASK_IDLE
	var ldr := PersonData.new(); ldr.id = 1; ldr.team_id = 0
	ldr.values = {"野心": 0.9, "好戰": 0.9, "信義": 0.1, "慎重": caution, "貪婪": 0.7, "殘忍": 0.7}
	s.persons[1] = ldr; atk.leader_id = 1; _seed_pop(atk, 10)
	atk.armed_anon_ratio = 1.0
	atk.resources = {"food": food, "weapon_melee_low": 20.0}
	s.teams[0] = atk
	var prey := TeamData.new(); prey.team_id = 1; prey.tile_pos = Vector2i(1, 0); prey.faction_id = -1
	var p_ldr := PersonData.new(); p_ldr.id = 2; s.persons[2] = p_ldr; prey.leader_id = 2
	_seed_pop(prey, 5); prey.resources = {"food": 100.0, "coin": 200.0}; s.teams[1] = prey
	s.team_discovered[0] = [1]
	# 單一低可信 relay claim（非親見）→ uncertainty 高 → 慎重者 confident_enough 失敗、莽者過。
	BeliefSystem.record_claim(s, 0, 1, 99, "流民",
		{"population_est": 5.0, "armed_est": 2.0, "tile_pos": Vector2i(1, 0), "coin_est": 200.0},
		0.3, false)
	return s

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
