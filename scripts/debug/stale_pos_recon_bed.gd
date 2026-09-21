extends SceneTree
# @bed-kind: acceptance
# slice: 過期位置的目標 → 偵查分池（HOW spec 2026-09-17-stale-position-goes-to-scout-pool-HOW.md §3 ＋ §5③）
#
# ★★★本票要修的病一句話：`pick_recon_target` 用 `belief_pos()` 取位置，
#   而 `belief_pos()` 超過 `BELIEF_STALE_TICKS` 就回 `(-1,-1)` ⇒ 那一行 `continue`
#   **把「位置過期」的目標丟掉了** —— 而**偵查的存在理由正是去解決位置過期**。
#
# ★★【三類長得一模一樣，而它們的下一站相反】—— 本床的主要工作就是把它們分開：
#   ①位置過期（有 claim、曾有 tile_pos、只是舊了） ⇒ **該去看一眼**（偵查候選）
#   ②完全沒有 claim                                 ⇒ **不是候選**（連是誰都不知道）
#   ③有 claim 但【從未有過 tile_pos】（轉述型 relay） ⇒ **不是候選**（不知道要去哪裡）
#   ★★★②與③在畫面上都是「沒位置」，所以③要有自己的名字：`recon.skip.claim_without_pos`
#
# ★【誠實限】格1/2a/2b/3/5 是 **fixture 級**：證明「門開對了、式子算對了」，
#   ★★格4 才是世界級（`warring_states` 真跑），它回答「絕境那批隊真的會把偵查排上場嗎」。
#   ★★★每一格都印【樣本數／母體】—— 全 0 是母體塌陷，不是答案。
#
# env：BED_DAYS（格4 的天數，預設 8）／BED_SEED（預設 1337）／BED_CONFIG（預設 warring_states）

var _fails: int = 0
# ★★★到場點名：★執行期錯誤會【靜默中止一支 func】，而那在卷面上與「跑完且通過」長得一樣。
#   ⇒ 數【真的走完的段】，與【常數期望】比 —— ★分母寫死常數，不是拿跑了幾段當分母
#     （分母＝跑了幾段 ⇒ 崩在第一段也會印「1/1」＝自己跟自己比）。
var _sections: int = 0
const EXPECT_SECTIONS: int = 3
var _undec: int = 0

func _initialize() -> void:
	_run()
	# ★閘的判準看【橫幅】不看離開碼（systems 立 2026-09-16）：
	#   ★★沒有結尾標記的話，「FAIL=0」與「根本沒跑」長得一模一樣。
	if _sections != EXPECT_SECTIONS:
		_fails += 1
		push_error("[FAIL] ★只跑完 %d／%d 段 —— 中途中止與通過在卷面上長得一樣" % [
			_sections, EXPECT_SECTIONS])
	print("-- 量測完成；[FAIL] 數 ＝ %d｜[不可判] 數 ＝ %d｜到場點名 %d／%d --" % [
		_fails, _undec, _sections, EXPECT_SECTIONS])
	print("[TEST-SUITE-COMPLETE]")
	quit(1 if _fails > 0 else 0)

# ★【不可判】＝ 這一格宣稱要驗的東西，**這一次執行沒有去驗** ——
#   ★★處置不是刪掉它、也不是把它改成一個做得到的問題，是**留著、標明、而且不算綠**。
func _undecidable(cell: String, claim: String, why: String, how: String) -> void:
	_undec += 1
	push_error("[不可判] %s：%s" % [cell, claim])
	print("  [不可判] %s ——" % cell)
	print("       宣稱：%s" % claim)
	print("       為什麼這次驗不了：%s" % why)
	print("       怎麼驗：%s" % how)

func _ok(cond: bool, msg: String) -> void:
	if cond: print("  [OK] %s" % msg)
	else:
		_fails += 1
		# ★`push_error`（會叫、不停）不是 `assert`（會叫、會停）——
		#   閘要的是「全部跑完 ＋ 每條失敗都被看見」。
		push_error("[FAIL] %s" % msg)

func _bed_self_check_tree() -> void:
	var out: Array = []
	OS.execute("git", ["rev-parse", "--short", "HEAD"], out)
	var sha: String = (out[0] as String).strip_edges() if not out.is_empty() else "UNKNOWN"
	out.clear()
	OS.execute("git", ["status", "--porcelain", "--", "scripts/simulation/"], out)
	var dirty: int = 0
	if not out.is_empty():
		for l in (out[0] as String).split("\n"):
			if l.strip_edges() != "": dirty += 1
	print("[TREE] HEAD=%s scripts/simulation-dirty=%d（%s）" % [
		sha, dirty, "clean" if dirty == 0 else "★dirty：跟別份輸出比對前先確認同 commit"])

# ── fixture 工具 ───────────────────────────────────────────────
func _mk_team(state: WorldState, tid: int, fid: int, lid: int, pos: Vector2i, pop: int) -> TeamData:
	var t := TeamData.new()
	t.team_id = tid; t.faction_id = fid; t.leader_id = lid; t.tile_pos = pos
	# ★`population` 是計算屬性，直接賦值會被靜默吞掉 ⇒ 真的放人進去。
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", pop)
	var p := PersonData.new(); p.id = lid; p.values = {"慎重": 0.5, "貪婪": 0.5}
	state.persons[lid] = p
	state.teams[tid] = t
	return t

# ★claim 的年齡靠【把世界時間往前推】製造，不是手改 claim 內部欄位 ——
#   手改欄位會繞開 `record_claim` 的語意（它自己決定 last_tick 怎麼寫）。
func _claim_at(state: WorldState, obs: int, tgt: int, at_tick: int, fields: Dictionary) -> void:
	var keep: int = state.world.current_tick
	state.world.current_tick = at_tick
	BeliefSystem.record_claim(state, obs, tgt, obs, "親見", fields, 1.0, false)
	state.world.current_tick = keep

func _run() -> void:
	print("=== 過期位置 → 偵查分池 驗收 ===")
	_bed_self_check_tree()
	_cells_fixture(); _sections += 1
	_cell4_world(); _sections += 1
	_cell5_gates_verbatim(); _sections += 1

# ── 格1／格2a／格2b／格3 ─────────────────────────────────────
func _cells_fixture() -> void:
	var day: int = WorldState.TICKS_PER_DAY
	var stale_ticks: int = BeliefSystem.BELIEF_STALE_TICKS
	print("\n— fixture：BELIEF_STALE_TICKS=%d（=%.1f 天）—" % [stale_ticks, float(stale_ticks) / float(day)])

	# 格1：位置過期（4 天前親見、帶 tile_pos）⇒ **必須**是偵查候選
	var s1 := MeasureBedHelper.arm_and_new()
	s1.world.current_tick = 40 * day
	_mk_team(s1, 1, 1, 100, Vector2i(0, 0), 10)
	_mk_team(s1, 21, 2, 121, Vector2i(9, 9), 8)
	_claim_at(s1, 1, 21, 36 * day, {"tile_pos": Vector2i(5, 5), "population_est": 8.0})
	var stale_age: int = s1.world.current_tick - 36 * day
	var pos_today: Vector2i = BeliefSystem.belief_pos(s1, 1, 21)
	var r1: Dictionary = DecisionContext.pick_recon_target(s1, s1.teams[1])
	print("格1｜claim 年齡 %d tick（%.1f 天）＞ 過期線 %d ⇒ belief_pos 今天回 %s｜偵查候選 id=%d value=%.3f" % [
		stale_age, float(stale_age) / float(day), stale_ticks, str(pos_today), int(r1["id"]), float(r1["value"])])
	_ok(pos_today == Vector2i(-1, -1),
		"格1-前提 這一筆**真的是過期的**（`belief_pos` 回 (-1,-1)）"
		+ "｜★前提不成立的話，下一句的綠是【沒有驗到東西】的綠")
	_ok(int(r1["id"]) == 21,
		"格1 ★**位置過期的目標出現在偵查候選集裡**（樣本 1／母體 1）"
		+ "｜★★不出現 ⇒ 還在被 `decision_context.gd` 那一行 `continue` 掉")
	_ok(r1["pos"] == Vector2i(5, 5),
		"格1-b ★候選帶的是【last-known 位置】(5,5) 而不是 (-1,-1)"
		+ "｜★沒有這一半，偵查會被派去一個不存在的座標")
	_ok(float(r1["value"]) > 0.0, "格1-c 它的價值 > 0（★=0 ⇒ 名義上在候選集、實際上永遠選不到）")

	# 格2a：完全沒有 claim ⇒ 不在候選集
	var s2 := MeasureBedHelper.arm_and_new()
	s2.world.current_tick = 40 * day
	_mk_team(s2, 1, 1, 100, Vector2i(0, 0), 10)
	_mk_team(s2, 22, 2, 122, Vector2i(9, 9), 8)
	var r2: Dictionary = DecisionContext.pick_recon_target(s2, s2.teams[1])
	print("格2a｜世界上只有一個目標且它【沒有任何 claim】⇒ 偵查候選 id=%d" % int(r2["id"]))
	_ok(int(r2["id"]) == -1,
		"格2a ★**沒有任何 claim 的目標仍然不在候選集**（樣本 0／母體 1）"
		+ "｜★出現 ⇒ 門拆過頭了：連「這支隊存在」都變成 god-view")

	# 格2b：有 claim、但【從未有過 tile_pos】（轉述型 relay 的形狀）⇒ 不在候選集，且要有名字
	var s3 := MeasureBedHelper.arm_and_new()
	s3.world.current_tick = 40 * day
	_mk_team(s3, 1, 1, 100, Vector2i(0, 0), 10)
	_mk_team(s3, 23, 2, 123, Vector2i(9, 9), 8)
	_claim_at(s3, 1, 23, 39 * day, {"population_est": 8.0})   # ★沒有 tile_pos
	var before: int = int(Probe.counts.get("recon.skip.claim_without_pos", 0))
	var r3: Dictionary = DecisionContext.pick_recon_target(s3, s3.teams[1])
	var named: int = int(Probe.counts.get("recon.skip.claim_without_pos", 0)) - before
	print("格2b｜有 claim（1 天前、不帶位置）⇒ 偵查候選 id=%d｜`recon.skip.claim_without_pos` +%d" % [
		int(r3["id"]), named])
	_ok(int(r3["id"]) == -1,
		"格2b ★**有 claim 但從未有過 `tile_pos` 的目標也不在候選集**（樣本 0／母體 1）")
	_ok(named >= 1,
		"格2b-名字 ★★**這一類有自己的計數**（`recon.skip.claim_without_pos`）"
		+ "｜★★★沒有名字的話它與「位置過期」在畫面上一模一樣，而兩者下一站相反")
	# ★★成對的另一半（陽性對照）：同一個目標【補上 tile_pos】就應該變成候選 ——
	#   沒有這一半，格2b 的綠也可能只是「這支隊本來就不會被選」。
	_claim_at(s3, 1, 23, 39 * day, {"tile_pos": Vector2i(4, 4)})
	var r3b: Dictionary = DecisionContext.pick_recon_target(s3, s3.teams[1])
	print("格2b-對照｜同一個目標補上 tile_pos 之後 ⇒ 偵查候選 id=%d" % int(r3b["id"]))
	_ok(int(r3b["id"]) == 23,
		"格2b-對照 ★**補上位置就變成候選** ⇒ 上一句擋掉的是【沒有位置】，不是【這個目標】")

	# 格3：年齡進【價值】不是進【門】—— 單調遞減、永不為 0
	print("\n— 格3：新鮮度因子 —")
	var tpd: float = 1.0
	var sight: int = 3
	var f0: float = DecisionTerms.recon_freshness_factor(0, tpd, sight)
	var f3: float = DecisionTerms.recon_freshness_factor(3 * day, tpd, sight)
	var f30: float = DecisionTerms.recon_freshness_factor(30 * day, tpd, sight)
	var f3650: float = DecisionTerms.recon_freshness_factor(3650 * day, tpd, sight)
	print("格3｜v=%.2f tiles/day sight=%d ⇒ f(0d)=%.6f f(3d)=%.6f f(30d)=%.6f f(3650d)=%.8f" % [
		tpd, sight, f0, f3, f30, f3650])
	_ok(f0 >= f3 and f3 > f30 and f30 > f3650, "格3-a ★年齡越大 ⇒ 因子越小（單調遞減）")
	_ok(f3650 > 0.0,
		"格3-b ★★**永不為 0**（十年前的情報仍是情報）"
		+ "｜★歸零 ⇒ 我又做出一道靜默的門，只是換了個地方")
	_ok(f0 <= 1.000001, "格3-c 因子不放大價值（≤1）")
	# ★★★速度是【目標的】不是觀察者的：目標跑得越快 ⇒ 同樣年齡的情報越不值錢
	var f_slow: float = DecisionTerms.recon_freshness_factor(5 * day, 0.5, sight)
	var f_fast: float = DecisionTerms.recon_freshness_factor(5 * day, 4.0, sight)
	print("格3-d｜同樣 5 天：目標慢(0.5)=%.6f vs 目標快(4.0)=%.6f" % [f_slow, f_fast])
	_ok(f_slow > f_fast,
		"格3-d ★★★**它讀的是【目標】的移動能力**：跑得快的目標，舊情報更不值錢"
		+ "｜★傳成觀察者的速度 ⇒ 這一句會紅（兩個呼叫長得一模一樣而意思相反）")
	# 年齡真的進了價值：同一個目標，情報越舊 ⇒ 偵查價值越低
	var v_new: float = _recon_value_with_age(2 * day)
	var v_old: float = _recon_value_with_age(20 * day)
	print("格3-e｜同一目標：情報 2 天 value=%.4f／情報 20 天 value=%.4f" % [v_new, v_old])
	_ok(v_new > v_old and v_old > 0.0,
		"格3-e ★年齡進到了**候選的價值**上（而且舊的那個仍 > 0 ⇒ 還在秤上，只是排後面）")

func _recon_value_with_age(age_ticks: int) -> float:
	var day: int = WorldState.TICKS_PER_DAY
	var s := MeasureBedHelper.arm_and_new()
	s.world.current_tick = 100 * day
	_mk_team(s, 1, 1, 100, Vector2i(0, 0), 10)
	_mk_team(s, 31, 2, 131, Vector2i(9, 9), 8)
	_claim_at(s, 1, 31, 100 * day - age_ticks, {"tile_pos": Vector2i(5, 5), "population_est": 8.0})
	return float(DecisionContext.pick_recon_target(s, s.teams[1])["value"])

# ── 格4：世界級 —— 絕境那批隊，偵查有沒有【上場】 ──────────────
func _cell4_world() -> void:
	# ★★★【為什麼它有開關，而關掉時不是綠】：實測 `warring_states` 跑到第 9 天要 ~1800 秒
	#   （隊數 69→101、avg tick 36ms→239ms），★而**絕境的隊要到第 8~10 天才出現**
	#   ⇒ 縮天數 ＝ 母體 0 ＝ 這一格什麼都沒驗到。
	#   ★★所以：merge-gate 那一輪用 `BED_WORLD=0` 跑（秒級、fixture 五格），
	#     而這一格**標成【不可判】而不是跳過** —— 跳過會讓它與「驗過且通過」在畫面上一模一樣。
	#   ★★★閘的 `expect` 會把【不可判 ＝ 1】釘住 ⇒ 哪天有人把它悄悄拿掉，閘會紅。
	if OS.get_environment("BED_WORLD") == "0":
		_undecidable("格4（世界級）",
			"絕境那批隊把【位置過期的目標】排進偵查候選、且偵查真的上場",
			"本次以 BED_WORLD=0 執行（世界級那一段要 ~30 分鐘，不適合放進每次都要跑的閘）",
			"BED_WORLD=1 BED_DAYS=10 GODOT_TIMEOUT=3000 單獨跑一次；交件貼數時標【床的 commit】")
		return
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 8
	var seed_val: int = int(OS.get_environment("BED_SEED")) if OS.has_environment("BED_SEED") else 1337
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "warring_states"
	print("\n— 格4：世界級（config=%s days=%d seed=%d）—" % [cfg, days, seed_val])
	seed(seed_val)
	Probe.reset(); Probe.arm()
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg)
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)
	var pop_days: int = 0            # 母體：餓且有牙的隊天數
	var with_recon: int = 0          # 其中：偵查有候選
	var with_stale_recon: int = 0    # 其中：候選【本身就是位置過期的目標】（★本票打的正是這一格）
	var recon_on_board: int = 0      # 其中：偵查真的出現在 argmax 的秤上
	var samples: Array = []
	var fai := FactionAISystem.new()
	for tick in range(days * WorldState.TICKS_PER_DAY):
		runner.advance_tick(st, no_player)
		if (tick + 1) % WorldState.TICKS_PER_DAY != 0: continue
		var d: int = (tick + 1) / WorldState.TICKS_PER_DAY
		for tid in st.teams:
			var team: TeamData = st.teams[tid]
			if team == null or team.leader_id == -1: continue
			if team.population <= 0: continue
			var need: float = maxf(float(team.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY, 0.001)
			var fd: float = ResourceSystem.effective_food(st, team) / need
			if fd >= DecisionTerms.DESPERATION_DAYS: continue
			if fai._calc_own_armed(st, team) <= 0.0: continue
			pop_days += 1
			# ★★這裡**不**呼叫 `gather` / `rank_scored_ctx` —— 它們是決策路徑上最貴的兩支，
			#   而且 `gather` 自承 MUTATES（會推進 EWMA 與 cadence）⇒ ★**量測會改變被量測物**。
			#   ⇒ 「偵查有沒有上場」改讀**世界自己的結果**：production 選了什麼 task。
			var pick: Dictionary = DecisionContext.pick_recon_target(st, team)
			if team.current_task == TeamData.TASK_SCOUT: recon_on_board += 1
			if int(pick["id"]) == -1: continue
			with_recon += 1
			# ★這一筆的候選是不是【位置過期】的那一類？判準＝今天的 `belief_pos` 回 (-1,-1)
			var is_stale: bool = BeliefSystem.belief_pos(st, team.team_id, int(pick["id"])) == Vector2i(-1, -1)
			if is_stale: with_stale_recon += 1
			if is_stale and samples.size() < 12:
				samples.append("day=%d team=%d food_days=%.2f 候選=%d value=%.2f 現在的 task=%s" % [
					d, team.team_id, fd, int(pick["id"]), float(pick["value"]), team.current_task])
	print("格4｜母體（餓且有牙的隊天數）=%d｜有偵查候選=%d｜其中候選是【位置過期】的=%d｜當天 task 就是偵查=%d" % [
		pop_days, with_recon, with_stale_recon, recon_on_board])
	# ★世界整體的兩個計數（production 自己在跑決策時寫的，不是我這支迴圈寫的）——
	#   ★★它們回答「本票有沒有在【全世界】生效」，而上面那四個只回答絕境那一格。
	print("     [世界] recon.eligible=%d｜其中位置過期=%d｜skip.no_claim=%d｜skip.claim_without_pos=%d｜age_unknown=%d" % [
		int(Probe.counts.get("recon.eligible", 0)), int(Probe.counts.get("recon.eligible.stale_pos", 0)),
		int(Probe.counts.get("recon.skip.no_claim", 0)),
		int(Probe.counts.get("recon.skip.claim_without_pos", 0)),
		int(Probe.counts.get("recon.age_unknown", 0))])
	for s in samples: print("     %s" % s)
	_ok(pop_days > 0,
		"格4-母體 ★母體非 0（=%d）｜★★母體塌陷的話，下面那幾句的綠與紅都不算數" % pop_days)
	_ok(with_stale_recon > 0,
		"格4 ★★★**絕境那批隊把【位置過期的目標】排進了偵查候選**（樣本 %d／母體 %d）" % [
			with_stale_recon, pop_days]
		+ "｜★仍為 0 ⇒ 本票沒打中：它們還是被丟在 `pick_recon_target` 那一行")
	_ok(int(Probe.counts.get("recon.eligible.stale_pos", 0)) > 0,
		"格4-b ★**全世界尺度**：位置過期的目標進到偵查候選集 %d 次（候選集總計 %d 次）" % [
			int(Probe.counts.get("recon.eligible.stale_pos", 0)), int(Probe.counts.get("recon.eligible", 0))]
		+ "｜★這一句與上一句的差別＝【絕境那一格】vs【整個世界】")

# ── 格5：掠奪／攻擊那兩道門逐字未改 ──────────────────────────
func _cell5_gates_verbatim() -> void:
	print("\n— 格5：兩道攻擊性的門逐字未改 —")
	var src: String = FileAccess.get_file_as_string("res://scripts/simulation/faction_ai_system.gd")
	var head: int = src.find("func _find_weakest_prey")
	var body: String = ""
	if head != -1:
		var tail: int = src.find("\nfunc ", head + 10)
		body = src.substr(head, (tail - head) if tail != -1 else 2000)
	_ok(head != -1, "格5-前提 找得到 `_find_weakest_prey`（★找不到 ⇒ 下面兩句的綠是空的）")
	_ok(body.contains("if not BeliefSystem.has_belief(state, team.team_id, tid): continue"),
		"格5-a ★掠奪的第一道門（`has_belief`）**逐字未改**")
	_ok(body.contains("if not PathSystem.estimate_catch_up(state, team, tid, true).reachable: continue"),
		"格5-b ★掠奪的第二道門（`reachable`）**逐字未改**")
	_ok(src.contains("if prey_pos_gate == Vector2i(-1, -1):"),
		"格5-c ★★攻擊側那道門（`belief_pos == (-1,-1)` ⇒ 不可行）**逐字未改**"
		+ "｜★★★放寬它＝讓隊直接打一個它不知道在哪的目標＝隔空作用（違反感知鐵律）")
