extends SceneTree
# @bed-kind: acceptance
# slice: 據點知識進 belief（HOW spec 2026-09-17-outpost-belief-claim-HOW.md §3 八格）
#
# ★★★這一票不是「換一個比較準的欄位」，是把【地點的知識】從 god-view 拆出來：
#   舊版 `_enemy_outpost_positions()` **全圖掃真實 tile**，再用「我對【主人】有沒有 belief」當代理
#   ⇒ ★那道閘擋的是**主人**，不是**地點** ⇒ 兩個方向都錯：
#     ①**知道得太多**：沒看過那座城，卻因為在千里外見過主人 ⇒ 它對我存在
#     ②**知道得太少**：★親眼走過那座敵城、從沒見過主人 ⇒ 它對我不存在（★★舊註解沒寫這個方向）
#   ⇒ 3-a／3-b 是**成對的**：兩個方向各消失一半，缺一半就證明不了「換對了」。
#
# ★【誠實限】3-a/3-b/3-d/3-g/3-h 是 fixture 級；3-c/3-e 是**原始碼逐字格**；
#   ★★3-f 才是世界級（兩個方向在真世界各至少一例）。
#
# env：BED_WORLD（=0 時 3-f 標【不可判】）／BED_DAYS（預設 10）／BED_SEED（預設 1337）／BED_CONFIG（預設 warring_states）

var _fails: int = 0
var _undec: int = 0

# ★★★【跑到了幾格】——★血證（本床第一次跑）：`MessageData` 沒有 `payload` 欄 ⇒
#   GDScript 的 `Invalid set index` 是**執行期錯誤，它靜默中止【那一支 func】而不中止整支床**
#   ⇒ ★★**3-h 整格沒有跑，而末行照樣印 `[FAIL] 數 ＝ 0`** ——
#     **「沒有失敗」與「沒有執行」在畫面上一模一樣。**
#   ⇒ ★★★所以每一格自報到場，最後對名單：**少一格就是紅**。
const EXPECTED_CELLS: Array = ["3-a", "3-b", "3-d", "3-h", "3-g", "3-c/3-e"]
var _cells_ran: Array = []

func _cell(name: String) -> void:
	_cells_ran.append(name)

func _initialize() -> void:
	_run()
	var missing: Array = []
	for c in EXPECTED_CELLS:
		if not _cells_ran.has(c): missing.append(c)
	if missing.is_empty():
		print("  [OK] 到場點名 ★每一格都跑完了（%d／%d）" % [_cells_ran.size(), EXPECTED_CELLS.size()])
	else:
		_fails += 1
		push_error("[FAIL] 到場點名：★**有格沒有跑完** ⇒ %s（執行期錯誤會靜默中止一支 func，而那看起來像綠）" % str(missing))
	print("-- 量測完成；[FAIL] 數 ＝ %d｜[不可判] 數 ＝ %d --" % [_fails, _undec])
	print("[TEST-SUITE-COMPLETE]")
	quit(1 if _fails > 0 else 0)

func _ok(cond: bool, msg: String) -> void:
	if cond: print("  [OK] %s" % msg)
	else:
		_fails += 1
		push_error("[FAIL] %s" % msg)

func _undecidable(cell: String, claim: String, why: String, how: String) -> void:
	_undec += 1
	push_error("[不可判] %s：%s" % [cell, claim])
	print("  [不可判] %s ——" % cell)
	print("       宣稱：%s" % claim)
	print("       為什麼這次驗不了：%s" % why)
	print("       怎麼驗：%s" % how)

func _bed_self_check_tree() -> void:
	var out: Array = []
	OS.execute("git", ["rev-parse", "--short", "HEAD"], out)
	var sha: String = (out[0] as String).strip_edges() if not out.is_empty() else "UNKNOWN"
	out.clear()
	OS.execute("git", ["status", "--porcelain", "--", "scripts/"], out)
	var dirty: int = 0
	if not out.is_empty():
		for l in (out[0] as String).split("\n"):
			if l.strip_edges() != "": dirty += 1
	print("[TREE] HEAD=%s scripts-dirty=%d（%s）" % [
		sha, dirty, "clean" if dirty == 0 else "★dirty：跟別份輸出比對前先確認同 commit"])

# ── fixture 工具 ───────────────────────────────────────────────
func _mk_tile(state: WorldState, pos: Vector2i, outpost_owner: int = -1, level: int = 0) -> HexTileData:
	var t := HexTileData.new()
	t.tile_pos = pos
	t.terrain = "plains"
	t.outpost_owner = outpost_owner
	t.outpost_level = level
	state.world.tiles[pos.x * 1000 + pos.y] = t
	return t

func _mk_team(state: WorldState, tid: int, fid: int, lid: int, pos: Vector2i, pop: int) -> TeamData:
	var t := TeamData.new()
	t.team_id = tid; t.faction_id = fid; t.leader_id = lid; t.tile_pos = pos
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", pop)
	var p := PersonData.new(); p.id = lid; p.values = {"慎重": 0.5}
	state.persons[lid] = p
	state.teams[tid] = t
	return t

# ★一個小世界：觀察者(1) ／ 城主(2，據點在 (5,5)) ／ 觀察者站哪由參數決定。
func _mk_world(observer_pos: Vector2i) -> WorldState:
	var s := MeasureBedHelper.arm_and_new()
	s.world.current_tick = 10 * WorldState.TICKS_PER_DAY
	for x in range(0, 12):
		for y in range(0, 12):
			_mk_tile(s, Vector2i(x, y))
	_mk_tile(s, Vector2i(5, 5), 2, 2)   # ★城：主人是 team 2、等級 2
	_mk_team(s, 1, 1, 100, observer_pos, 10)
	_mk_team(s, 2, 2, 200, Vector2i(11, 11), 10)   # ★城主本人站在很遠的地方
	return s

func _run() -> void:
	print("=== 據點知識進 belief 驗收（spec §3）===")
	_bed_self_check_tree()
	_cells_two_directions()
	_cell_d_three_states()
	_cell_h_relay()
	_cell_g_old_consumers()
	_cells_source_verbatim()
	_cell_f_world()

# ── 3-a／3-b：成對的兩個方向 ──────────────────────────────────
func _cells_two_directions() -> void:
	var fai := FactionAISystem.new()

	# 3-a｜見過【主人】、沒見過那座城 ⇒ 城【不在】迴避集
	var s1 := _mk_world(Vector2i(0, 0))   # ★觀察者離城 (5,5) 很遠 ⇒ 視野外
	BeliefSystem.record_claim(s1, 1, 2, 1, "親見",
		{"tile_pos": Vector2i(11, 11), "population_est": 10.0}, 1.0, false)   # ★在千里外見過城主
	BeliefSystem.harvest_tile_known(s1, s1.teams[1])
	var a_set: Array = fai._enemy_outpost_positions(s1, s1.teams[1])
	var a_owner_belief: Vector2i = BeliefSystem.belief_pos(s1, 1, 2)
	print("3-a｜對城主有 belief（%s）、從未走過那座城 ⇒ 迴避集 %s" % [str(a_owner_belief), str(a_set)])
	_ok(a_owner_belief != Vector2i(-1, -1),
		"3-a-前提 ★**我對城主【確實】有情報**（舊版正是靠這個把城放進集合）"
		+ "｜★前提不成立 ⇒ 下一句的綠是空的")
	_ok(not a_set.has(Vector2i(5, 5)),
		"3-a ★**知道得太多那一半消失了**：沒看過的城**不在**迴避集（樣本 1／母體 1）"
		+ "｜★★退回 proxy ⇒ 它會在 ⇒ 這一句會紅")

	# 3-b｜親眼走過那座城、從沒見過主人 ⇒ 城【在】迴避集（★舊註解沒寫的那個方向）
	var s2 := _mk_world(Vector2i(5, 5))   # ★觀察者就站在城上
	BeliefSystem.harvest_tile_known(s2, s2.teams[1])
	var b_set: Array = fai._enemy_outpost_positions(s2, s2.teams[1])
	var b_owner_belief: Vector2i = BeliefSystem.belief_pos(s2, 1, 2)
	print("3-b｜親眼走過那座城、對城主的 belief=%s ⇒ 迴避集 %s" % [str(b_owner_belief), str(b_set)])
	_ok(b_owner_belief == Vector2i(-1, -1),
		"3-b-前提 ★**我對城主【沒有】任何情報**（舊版正是因此把城丟掉）")
	_ok(b_set.has(Vector2i(5, 5)),
		"3-b ★★**知道得太少那一半也消失了**：走過的城**在**迴避集（樣本 1／母體 1）"
		+ "｜★★★這一格是【沒有人寫下來過】的那個方向")
	_cell("3-a"); _cell("3-b")

# ── 3-d：三態（沒看過 ⇒ 空集；看過但很舊 ⇒ 仍在，且不借 BELIEF_STALE_TICKS）──
func _cell_d_three_states() -> void:
	var fai := FactionAISystem.new()
	var day: int = WorldState.TICKS_PER_DAY

	var s_never := _mk_world(Vector2i(0, 0))
	BeliefSystem.harvest_tile_known(s_never, s_never.teams[1])
	var never_set: Array = fai._enemy_outpost_positions(s_never, s_never.teams[1])
	print("3-d-①｜從沒觀察過任何據點 ⇒ 迴避集 %s（世界上確實有一座城）" % str(never_set))
	_ok(never_set.is_empty(),
		"3-d-① ★**沒看過 ⇒ 空集**（★★不是 fallback 到全圖）"
		+ "｜★空集不是失敗，是誠實：不知道的城對我不存在")

	# ★看過、然後過了很久（遠超 BELIEF_STALE_TICKS）⇒ **仍然在集合裡**
	var s_old := _mk_world(Vector2i(5, 5))
	BeliefSystem.harvest_tile_known(s_old, s_old.teams[1])
	s_old.world.current_tick += BeliefSystem.BELIEF_STALE_TICKS + 30 * day   # ★把世界時間往前推
	var old_set: Array = fai._enemy_outpost_positions(s_old, s_old.teams[1])
	var recs: Array = BeliefSystem.known_outposts(s_old, 1)
	var age_days: float = 0.0
	if not recs.is_empty():
		age_days = float(s_old.world.current_tick - int(recs[0]["last_tick"])) / float(day)
	print("3-d-②｜同一則據點知識已 %.1f 天（過期線 %.1f 天）⇒ 迴避集 %s" % [
		age_days, float(BeliefSystem.BELIEF_STALE_TICKS) / float(day), str(old_set)])
	_ok(age_days > float(BeliefSystem.BELIEF_STALE_TICKS) / float(day),
		"3-d-②-前提 ★這則知識**真的**已經超過那條線（%.1f 天）" % age_days)
	_ok(old_set.has(Vector2i(5, 5)),
		"3-d-② ★★**看過但很舊 ⇒ 仍在集合裡**（★據點不會自己走）"
		+ "｜★★★借了 `BELIEF_STALE_TICKS` 那條線 ⇒ 這一句會紅"
		+ "（那條線問的是「它現在還在那裡嗎」，而這裡問的是「我知不知道有這座城」）")

	# ★★成對的另一半：親見「那裡已經沒有據點了」⇒ 子記錄要被**擦掉**
	var s_razed := _mk_world(Vector2i(5, 5))
	BeliefSystem.harvest_tile_known(s_razed, s_razed.teams[1])
	var before_n: int = BeliefSystem.known_outposts(s_razed, 1).size()
	var t: HexTileData = s_razed.world.tiles[5 * 1000 + 5]
	t.outpost_level = 0
	t.outpost_owner = -1                                   # ★城被拆了
	BeliefSystem.harvest_tile_known(s_razed, s_razed.teams[1])   # ★再看一眼
	var after_n: int = BeliefSystem.known_outposts(s_razed, 1).size()
	print("3-d-③｜城被拆掉、觀察者再看一眼 ⇒ 已知據點 %d → %d" % [before_n, after_n])
	_ok(before_n == 1 and after_n == 0,
		"3-d-③ ★**親見「那裡沒有城了」會擦掉舊子記錄**"
		+ "｜★★不擦 ⇒ 被拆的城永遠留在別人的知識裡，而**那不是過期，是錯**")
	_cell("3-d")

# ── 3-h：relay 來的 tile 不得帶據點子記錄 ─────────────────────
func _cell_h_relay() -> void:
	var s := _mk_world(Vector2i(0, 0))
	# ★造一則「聽說 (5,5) 那裡有買賣」的 relay 訊息 ⇒ 它只讓我知道【有這麼一個地方】
	var m := MessageData.new()
	m.type = "order_buy"
	m.params = {"origin_pos": Vector2i(5, 5)}   # ★`msg_market_pos` 讀的就是這個欄（:387）
	s.team_known[1] = [m]
	BeliefSystem.harvest_tile_known(s, s.teams[1])
	var known: Dictionary = s.team_tile_known.get(1, {})
	var has_key: bool = known.has(5 * 1000 + 5)
	var ops: Array = BeliefSystem.known_outposts(s, 1)
	print("3-h｜只從 relay 聽說過 (5,5)：key 在＝%s｜已知據點 %d 筆" % [str(has_key), ops.size()])
	_ok(has_key,
		"3-h-前提 ★relay **確實**讓那塊地進了 `team_tile_known`（否則下一句證不到東西）")
	_ok(ops.is_empty(),
		"3-h ★★**relay 不寫據點子記錄**：聽說有那個地方 ≠ 看過它上面有什麼"
		+ "｜★★★寫了 ⇒ 情報會憑空長出【我從沒看見的城】")
	_cell("3-h")

# ── 3-g：既有兩個消費者只問 key，行為不變 ────────────────────
func _cell_g_old_consumers() -> void:
	var s := _mk_world(Vector2i(5, 5))
	BeliefSystem.harvest_tile_known(s, s.teams[1])
	var known: Dictionary = s.team_tile_known.get(1, {})
	var key_in: bool = known.has(5 * 1000 + 5)
	var val_is_dict: bool = known.get(5 * 1000 + 5) is Dictionary
	# ★既有消費者的兩種存取樣式各跑一次（`has()` 與 `for-in-dict`）
	var walked: int = 0
	for tid in known:
		var tt: HexTileData = s.world.tiles.get(int(tid))
		if tt != null: walked += 1
	print("3-g｜加值之後：key 仍在＝%s｜值已變成 Dictionary＝%s｜for-in 走得到 %d 格" % [
		str(key_in), str(val_is_dict), walked])
	_ok(key_in,
		"3-g-a ★**key 存在的語意逐字不變**（四個既有讀者全部只走 key）")
	_ok(val_is_dict,
		"3-g-b ★前提：那一格的值**確實**已經變成 Dictionary（否則下一句沒驗到東西）")
	_ok(walked == known.size(),
		"3-g-c ★**`for-in-dict` 走得到每一格**（%d／%d）｜★值換形狀時把 `has()`/走訪弄壞 ⇒ 這裡會紅" % [
			walked, known.size()])
	_cell("3-g")

# ── 3-c／3-e：原始碼逐字格 ────────────────────────────────────
func _cells_source_verbatim() -> void:
	print("\n— 3-c／3-e：原始碼 —")
	var fai: String = FileAccess.get_file_as_string("res://scripts/simulation/faction_ai_system.gd")
	var head: int = fai.find("func _enemy_outpost_positions")
	var body: String = ""
	if head != -1:
		var tail: int = fai.find("\nfunc ", head + 10)
		body = fai.substr(head, (tail - head) if tail != -1 else 2000)
	_ok(head != -1, "3-c-前提 找得到 `_enemy_outpost_positions`")
	_ok(not body.contains("for tile_id in state.world.tiles"),
		"3-c-a ★**全圖掃已經刪掉**（★★殘留 ＝ 下一個讀者的陷阱）")
	_ok(not body.contains("tile.outpost_owner") and not body.contains("tile.outpost_level"),
		"3-c-b ★**不再 live 讀 `tile.outpost_owner`／`outpost_level`**")
	_ok(body.contains("BeliefSystem.known_outposts("),
		"3-c-c ★**改讀具名的列舉介面**（`known_outposts` 這個名字是三支同病灶 site 將來的機械判準）")
	# 3-e：錨定性逐字未改（blueprint 明令：欄開了也不准順手接）
	var dc: String = FileAccess.get_file_as_string("res://scripts/simulation/decision/decision_context.gd")
	_ok(dc.contains("var _ranchored: bool = _ract == BeliefSystem.ACT_SETTLED \\\n\t\t\tor _ract == BeliefSystem.ACT_BUILDING")
			or (dc.contains("_ract == BeliefSystem.ACT_SETTLED") and dc.contains("_ract == BeliefSystem.ACT_BUILDING")
				and not dc.contains("known_outposts")),
		"3-e ★★**錨定判準逐字未改，而且 `decision_context` 沒有去碰新欄**"
		+ "｜★blueprint 明令：**欄開了 ≠ 每個想用的地方都該接**"
		+ "（他量到反向數字：受害者側佔比低於母體側 ⇒ 那條路的答案已經是「不需要」）")
	_cell("3-c/3-e")

# ── 3-f：世界級（兩個方向各至少一例）────────────────────────
func _cell_f_world() -> void:
	if OS.get_environment("BED_WORLD") == "0":
		_undecidable("3-f（世界級）",
			"真世界裡兩個方向都發生：有城【因為我走過】而進集合、也有城【因為我沒走過】而不進集合",
			"本次以 BED_WORLD=0 執行（世界級那一段要跑 warring_states 10 天）",
			"BED_WORLD=1 BED_DAYS=10 GODOT_TIMEOUT=3000 單獨跑一次；交件貼數時標【床的 commit】")
		return
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 10
	var seed_val: int = int(OS.get_environment("BED_SEED")) if OS.has_environment("BED_SEED") else 1337
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "warring_states"
	print("\n— 3-f：世界級（config=%s days=%d seed=%d）—" % [cfg, days, seed_val])
	seed(seed_val)
	Probe.reset(); Probe.arm()
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg)
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)
	for _t in range(days * WorldState.TICKS_PER_DAY):
		runner.advance_tick(st, no_player)

	# ★逐隊比對【新版集合】與【舊 proxy 集合】—— 兩個方向各自改變了多少（spec §4）
	var fai := FactionAISystem.new()
	var only_new: int = 0      # ★新版有、proxy 沒有 ＝「知道得太少」被修好的那一半（我走過、沒見過主人）
	var only_proxy: int = 0    # ★proxy 有、新版沒有 ＝「知道得太多」被拿掉的那一半（沒走過、只見過主人）
	var both: int = 0
	var entries_peak: int = 0
	var entries_sum: int = 0
	var observers: int = 0
	var sample_new: Array = []
	var sample_proxy: Array = []
	for tid in st.teams:
		var team: TeamData = st.teams[tid]
		if team == null or team.leader_id == -1 or team.population <= 0: continue
		observers += 1
		var n_ops: int = BeliefSystem.known_outposts(st, team.team_id).size()
		entries_peak = maxi(entries_peak, n_ops)
		entries_sum += n_ops
		var new_set: Array = fai._enemy_outpost_positions(st, team)
		var proxy_set: Array = _proxy_enemy_outposts(st, team)
		for p in new_set:
			if proxy_set.has(p):
				both += 1
			else:
				only_new += 1
				if sample_new.size() < 6:
					sample_new.append("team=%d 城=%s（我走過、而我對主人沒有位置情報）" % [team.team_id, str(p)])
		for p in proxy_set:
			if not new_set.has(p):
				only_proxy += 1
				if sample_proxy.size() < 6:
					sample_proxy.append("team=%d 城=%s（我沒走過、只是見過主人）" % [team.team_id, str(p)])
	print("3-f｜觀察者 %d 支｜已知據點條目：峰值 %d／總和 %d（均 %.2f）" % [
		observers, entries_peak, entries_sum, float(entries_sum) / float(maxi(observers, 1))])
	print("     ★兩個方向：只有新版有＝%d（走過但沒見過主人）／只有 proxy 有＝%d（沒走過只見過主人）／兩者都有＝%d" % [
		only_new, only_proxy, both])
	for s in sample_new: print("     [新版才有] %s" % s)
	for s in sample_proxy: print("     [proxy 才有] %s" % s)
	_ok(observers > 0, "3-f-母體 ★母體非 0（觀察者 %d 支）" % observers)
	_ok(only_new > 0,
		"3-f-a ★**「知道得太少」那一半真的在世界裡發生過**（%d 例）：我走過的城現在算數了" % only_new)
	_ok(only_proxy > 0,
		"3-f-b ★★**「知道得太多」那一半也真的被拿掉了**（%d 例）：沒走過的城不再因為見過主人而存在" % only_proxy
		+ "｜★★★兩個方向都要有 —— 只有一個方向 ⇒ 我只證明了一半")

# ★舊 proxy 的逐字複本（**只在這支床裡**，用來當對照）——
#   ★★它讀 live tile，是 god-view；★★★這正是本票要拆掉的東西，留在床裡只為了量「拆掉了多少」。
func _proxy_enemy_outposts(state: WorldState, leader_team: TeamData) -> Array:
	var out: Array = []
	for tile_id in state.world.tiles:   # gate-ok: debug 對照基準掃（production 已不走這條）
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.outpost_level == 0: continue
		var owner: TeamData = state.teams.get(tile.outpost_owner)
		if owner == null: continue
		if owner.faction_id == leader_team.faction_id and owner.faction_id != -1: continue
		if BeliefSystem.belief_pos(state, leader_team.team_id, owner.team_id) == Vector2i(-1, -1): continue
		out.append(tile.tile_pos)
	return out
