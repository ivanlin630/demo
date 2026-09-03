extends SceneTree
# @observe-pure
# ★★★腿D：在【控制床】裡把對手加回去（systems 批 2026-09-03，接 peaceful 判別母體 0 的備援）。
#
# ★來由（一條線，不是憑空開的）：
#   organic(warring)：紮根 applicable 22 次、贏 0 次，贏家＝備戰9／徵收7／歸建4／maintain_*2
#   控制床腿A       ：紮根 30/30 贏 —— ★★而那張床【沒有威脅、沒有派系】⇒ 那三個對手【不存在】
#   peaceful 判別   ：想用「對手稀少的世界」問同一題 ⇒ ★★★母體 0（沒人紮營 ⇒ 沒人承諾紮根）⇒ 答不了
#   ⇒ ★備援方向（systems）：【在控制床加入對手】而不是【在 organic 移除對手】
#     —— 同一個變數兩個方向，而後者的母體是我們能控制的。
#
# ★★形狀：基座＝腿A（站自家 L0 營地＋承諾紮根，已知 30/30 贏），★一次只加一個對手
#   D1 加威脅來源     ⇒ 備戰 applicable
#   D2 加派系＋徵收令 ⇒ 徵收 applicable
#   D3 設為子隊       ⇒ 歸建 applicable
#
# ★★★而每一支都【印出我注入的強度】（systems 補的第一件）：
#   「紮根輸給備戰」在【威脅 0.5】與【威脅 5.0】下是完全不同的兩件事；
#   沒有強度，這張床明天就變成一個【不能複驗】的結論。
#
# ★誠實限（systems 先寫的）：構造出來的強度 ≠ organic 的強度
#   ⇒ 這張床只答【原則上會不會輸】，★★不答【在真實世界輸得對不對】
#   （後者靠 organic 那 22 筆，差距全部 ≥0.5，已在手上）。

const N_PER_ARM: int = 30
const GRID: int = 24

var _rows: Dictionary = {}     # arm → Array[Dictionary]
var _inject: Dictionary = {}   # arm → Array[float/String] 注入強度樣本
var _margin: Dictionary = {}   # arm → Array[float] 強度 − 該隊門檻（★分子/分母都要量）

func _initialize() -> void:
	print("=== 腿D：控制床＋對手｜每支母體 %d｜一次只加一個 ===" % N_PER_ARM)
	for arm in ["D1_threat", "D2_levy", "D3_subteam"]:
		Probe.enabled = true; Probe.reset()
		_run_arm(arm)
		_report(arm, Probe.counts.duplicate(true), Probe.samples.duplicate(true))
		Probe.enabled = false
	print(MeasureBedHelper.arm_order_report())
	print("★誠實限：①構造強度 ≠ organic 強度 ⇒ 本床只答【原則上會不會輸】")
	print("   ★★②單 tick 決策快照｜③人格已打散但仍是【我造的分布】")
	quit()

# ── 固定裝置（★與 zhagen_controlled_bed 的腿A 同構，只多一個對手）──
func _mk_world() -> WorldState:
	var s: WorldState = MeasureBedHelper.arm_and_new()
	s.world.current_tick = 100
	for x in range(GRID):
		for y in range(GRID):
			var t := HexTileData.new()
			t.tile_pos = Vector2i(x, y)
			t.terrain = "plains"
			t.resources = {"food": 20.0}
			t.resource_cap = {"food": 40.0}
			s.world.tiles[x * 1000 + y] = t
	return s

func _mk_team(s: WorldState, tid: int, pos: Vector2i) -> TeamData:
	var lead := PersonData.new()
	lead.id = tid * 10
	lead.person_name = "L%d" % tid
	lead.role = "leader"
	lead.team_id = tid
	lead.age = 30
	var i: int = tid % 6
	lead.values = {
		"慎重": 0.2 + 0.12 * float(i),
		"野心": 0.8 - 0.12 * float(i),
		"貪婪": 0.3 + 0.08 * float((i + 2) % 6),
		"好戰": 0.2 + 0.10 * float((i + 4) % 6),
		"忠誠": 0.5,
	}
	lead.skills = {"combat": 0.4, "farming": 0.5}
	s.persons[lead.id] = lead
	var t := TeamData.new()
	t.team_id = tid
	t.leader_id = lead.id
	t.tile_pos = pos
	t.faction_id = -1
	t.current_task = TeamData.TASK_IDLE
	t.survival_committed_option = "紮根"
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", 4 + (tid % 5))
	t.resources = {"food": 40.0 + 20.0 * float(tid % 5), "material": 10.0 * float(tid % 4), "coin": 30.0}
	s.teams[tid] = t
	s.team_discovered[tid] = []
	return t

func _mk_camp(s: WorldState, pos: Vector2i, team_id: int) -> void:
	var tile: HexTileData = s.world.tiles[pos.x * 1000 + pos.y]
	tile.camp_level = 1
	tile.outpost_level = 0
	tile.construction_team_id = -1
	tile.camp_team_id = team_id
	tile.camp_ticks_left = ResourceSystem.L0_DECAY_DAYS * WorldState.TICKS_PER_DAY
	OwnerCampIndex.invalidate()   # ★直接寫 camp_team_id 繞過 chokepoint ⇒ 索引要失效（血證在 zhagen_controlled_bed）

# ── 三支 arm ─────────────────────────────────────────────────────────
func _run_arm(arm: String) -> void:
	var s: WorldState = _mk_world()
	var ai := FactionAISystem.new()
	_rows[arm] = []
	_inject[arm] = []
	_margin[arm] = []
	for k in range(N_PER_ARM):
		var tid: int = 4000 + k
		var camp := Vector2i(2 + (k % 10) * 2, 2 + int(k / 10) * 2)
		var team: TeamData = _mk_team(s, tid, camp)
		_mk_camp(s, camp, tid)
		var note: String = _inject_opponent(s, ai, arm, team, camp, k)
		team.decision_eval_next_tick = 0
		# ★★★逐隊記【贏了沒】＋【它自己那一次的注入強度】（systems 2026-09-04）：
		#   ★總數說得出「4 勝 26 敗」，★★說不出【那 4 勝的威脅值落在哪裡】
		#   ⇒ ★★★而「4 勝集中在最低端」與「4 勝散開」是兩個完全不同的結論
		#     （前者＝強度相依、後者＝那 4 勝是別的東西）。
		#   ★用 Probe 計數的【前後差】判勝負：不新增旗標、不改控制流。
		var _won_before: int = int(Probe.counts.get("zhagen.appl_won", 0))
		ai._decide_unified(s, team)
		var _won: bool = int(Probe.counts.get("zhagen.appl_won", 0)) > _won_before
		_rows[arm].append({
			"tid": tid, "task": team.current_task, "option": team.current_option,
			"committed": team.survival_committed_option, "note": note,
			"won": _won, "strength": (float(_inject[arm][-1]) if not _inject[arm].is_empty() else -1.0),
			"margin": (float(_margin[arm][-1]) if not _margin[arm].is_empty() else NAN),
		})

# ★注入對手，並【回傳強度字串】（systems 補的第一件：不記強度＝不能複驗）
func _inject_opponent(s: WorldState, ai: FactionAISystem, arm: String, team: TeamData,
		camp: Vector2i, k: int) -> String:
	match arm:
		"D1_threat":
			# 敵隊放在【相鄰兩格】，pop 隨 k 遞增 ⇒ 威脅強度有梯度（不是單一值）
			var eid: int = 9000 + k
			var epos: Vector2i = camp + Vector2i(2, 1)
			var elead := PersonData.new()
			elead.id = eid * 10; elead.team_id = eid; elead.role = "leader"
			elead.values = {"好戰": 0.9}; elead.skills = {"combat": 0.8}
			s.persons[elead.id] = elead
			var enemy := TeamData.new()
			enemy.team_id = eid; enemy.leader_id = elead.id; enemy.tile_pos = epos
			enemy.faction_id = -1
			AnonCohort.add(enemy.anon_cohorts, "戰士", "healthy", 5 + k)   # ★pop 5..34 ⇒ 強度梯度
			enemy.resources = {"food": 50.0}
			s.teams[eid] = enemy
			s.team_discovered[team.team_id] = [eid]
			# ★belief 走既有唯一入口 `record_claim`（★親見：source_id == obs_id ⇒ last_tick=本 tick）
			#   ★★不直接塞 `team_intel`：那會繞過這條線唯一的寫入口，而繞過的東西沒有人維護它的語意。
			BeliefSystem.record_claim(s, team.team_id, eid, team.team_id, "親見",
				{"tile_pos": epos, "population_est": enemy.population, "last_tick": s.world.current_tick}, 1.0, false)
			# ★★★鍵名血證：第一版寫 `pop` ⇒ `_power_ratio` 讀的是 `population_est`（threat_assessment.gd:94）
			#   ⇒ 讀不到就 fallback 成 self_pop ⇒ power_ratio≈1 ⇒ 該項貢獻 0
			#   ⇒ ★注入的 pop 5→34 梯度【完全沒進到威脅分】，實測 min=max=0.2000
			#   ⇒ ★★而那個 0.2 看起來是一個【正常的數字】，不是錯誤 —— 這正是「注入強度必須印出來」的理由：
			#     ★★★沒印的話，我會拿一個【自變數其實沒有變】的實驗去回答「強度夠不夠」。
			var sc: float = ThreatAssessment.score(s, team, enemy)
			_inject[arm].append(sc)
			# ★★★第二個自變數（★而它不是我「加」的，是我【本來就在打散人格】而沒把它記下來）：
			#   `threat_threshold = BASE + 慎重 × SPAN`（decision_context.gd:316）
			#   ⇒ ★備戰是否 applicable、以及它壓不壓得過紮根，看的是【分數與門檻的差】不是分數本身
			#   ⇒ ★★所以「贏的強度」與「輸的強度」重疊【不代表強度無關】——
			#     ★★★可能是我拿錯了那把尺（量了分子沒量分母）。這一欄就是去分辨這件事。
			var _caution: float = float(s.persons[team.leader_id].values.get("慎重", 0.5))
			var _thr: float = ThreatAssessment.THREAT_BASE_THRESHOLD + _caution * ThreatAssessment.THREAT_CAUTION_SPAN
			_margin[arm].append(sc - _thr)
			return "enemy_pop=%d dist=%d threat_score=%.4f 門檻=%.4f 餘裕=%.4f" % [
				enemy.population, 3, sc, _thr, sc - _thr]
		"D2_levy":
			# 派系：本隊＋一個更富的 member；faction goals 含「徵收」
			var fid: int = 700 + k
			var rich_id: int = 8000 + k
			var rlead := PersonData.new(); rlead.id = rich_id * 10; rlead.team_id = rich_id
			s.persons[rlead.id] = rlead
			var rich := TeamData.new()
			rich.team_id = rich_id; rich.leader_id = rlead.id; rich.faction_id = fid
			rich.tile_pos = camp + Vector2i(3, 0)
			AnonCohort.add(rich.anon_cohorts, "平民", "healthy", 6)
			rich.resources = {"food": 200.0 + 20.0 * float(k)}   # ★食物量梯度＝徵收額度梯度
			s.teams[rich_id] = rich
			var f := FactionData.new()
			f.faction_id = fid
			f.leader_team_id = team.team_id
			f.member_team_ids = [team.team_id, rich_id]
			f.goals = ["徵收"]
			f.known_member_states = {rich_id: {"food_est": rich.resources["food"]}}
			s.factions[fid] = f
			team.faction_id = fid
			_inject[arm].append(float(rich.resources["food"]))
			return "faction_goals=徵收 rich_food_est=%.0f" % float(rich.resources["food"])
		"D3_subteam":
			# 子隊：母隊存在且 parent_team_id 指過去
			var pid: int = 6000 + k
			var plead := PersonData.new(); plead.id = pid * 10; plead.team_id = pid
			s.persons[plead.id] = plead
			var parent := TeamData.new()
			parent.team_id = pid; parent.leader_id = plead.id; parent.tile_pos = camp + Vector2i(4, 0)
			AnonCohort.add(parent.anon_cohorts, "平民", "healthy", 8)
			parent.resources = {"food": 100.0}
			s.teams[pid] = parent
			team.parent_team_id = pid
			_inject[arm].append(float(k))
			return "parent_team=%d loyalty=%.2f" % [pid, float(s.persons[team.leader_id].values.get("忠誠", 0.5))]
	return "?"

# ── 報告 ─────────────────────────────────────────────────────────────
func _report(arm: String, pc: Dictionary, ps: Dictionary) -> void:
	var rows: Array = _rows[arm]
	print("")
	print("═══ %s ═══" % arm)
	print("  母體（本支建的隊數）= %d" % rows.size())
	# ★注入強度先印（★systems：沒有它，贏與輸都無法解讀）
	var inj: Array = _inject[arm]
	if not inj.is_empty() and inj[0] is float:
		var mn: float = inj[0]
		var mx: float = inj[0]
		var sum: float = 0.0
		for v in inj:
			mn = minf(mn, float(v)); mx = maxf(mx, float(v)); sum += float(v)
		print("  ★注入強度（本支的自變數）：min=%.4f max=%.4f mean=%.4f" % [mn, mx, sum / float(inj.size())])
	for i in range(mini(3, rows.size())):
		print("     樣本%d：%s" % [i, String(rows[i]["note"])])
	print("  ── zhagen tap ──")
	for k in ["zhagen.mother", "zhagen.applicable", "zhagen.not_applicable",
			"zhagen.appl_won", "zhagen.appl_lost"]:
		print("     %-26s = %d" % [k, int(pc.get(k, 0))])
	print("     輸給誰：%s" % _buckets(pc, "zhagen.appl_lost_to."))
	var by_opt: Dictionary = {}
	for r in rows:
		var o: String = String(r["option"])
		by_opt[o if o != "" else "(空)"] = int(by_opt.get(o if o != "" else "(空)", 0)) + 1
	print("  current_option 分布：%s" % _fmt(by_opt))
	# ★★★勝負 × 注入強度（★這一格才分得出「強度相依」與「那幾勝是別的東西」）
	var win_s: Array = []
	var lose_s: Array = []
	for r in rows:
		if bool(r.get("won", false)): win_s.append(float(r.get("strength", -1.0)))
		else: lose_s.append(float(r.get("strength", -1.0)))
	win_s.sort(); lose_s.sort()
	print("  ── ★勝負 × 注入強度 ──")
	print("     ★贏（%d 次）的強度：%s" % [win_s.size(), _nums(win_s)])
	if not lose_s.is_empty():
		print("     輸（%d 次）的強度：min=%.4f max=%.4f" % [lose_s.size(), float(lose_s[0]), float(lose_s[-1])])
	# ★★★同一件事換一把尺：強度 − 該隊自己的門檻（分子/分母都量）
	var win_m: Array = []
	var lose_m: Array = []
	for r in rows:
		var mv = r.get("margin", null)
		if mv == null or is_nan(float(mv)): continue
		if bool(r.get("won", false)): win_m.append(float(mv))
		else: lose_m.append(float(mv))
	win_m.sort(); lose_m.sort()
	if not win_m.is_empty() and not lose_m.is_empty():
		print("     ★餘裕（強度−門檻）：贏 %s ｜ 輸 min=%.4f max=%.4f"
			% [_nums(win_m), float(lose_m[0]), float(lose_m[-1])])
		print("     ★★判讀（同上，換分母）：贏的最大餘裕 %.4f vs 輸的最小餘裕 %.4f ⇒ %s"
			% [float(win_m[-1]), float(lose_m[0]),
				("重疊 ⇒ 這把尺也分不開" if float(win_m[-1]) > float(lose_m[0])
					else "★★★不重疊 ⇒ 分得開的是【餘裕】不是【強度】")])
	if not win_s.is_empty() and not lose_s.is_empty():
		var overlap: bool = float(win_s[-1]) > float(lose_s[0])
		print("     ★★判讀：贏的最大強度 %.4f vs 輸的最小強度 %.4f ⇒ %s"
			% [float(win_s[-1]), float(lose_s[0]),
				("★★★重疊 ⇒ 不是單純的強度門檻（那幾勝另有原因）" if overlap
					else "★★★不重疊 ⇒ 勝負由強度分開＝【強度相依】成立")])
	# ★★★贏的那一半（`won_table`，同格式）——★沒有它，「它為什麼贏」只能靠推論
	var wt: Array = ps.get("zhagen.won_table", [])
	if not wt.is_empty():
		print("  ── ★贏的那幾次：紮根自己的 util ＋【贏家欄位】──")
		print("     ★★「紮根贏」與「備戰根本沒上場」在勝負欄上長得一樣 ⇒ 這裡把整張表印出來")
		for i in range(mini(6, wt.size())):
			var e3: Dictionary = wt[i]
			var t3: Array = e3.get("table", [])
			var zu: float = -1.0
			var top3: Array = []
			for r3 in t3:
				if String(r3["opt"]) == "紮根": zu = float(r3["u"])
			for j in range(mini(5, t3.size())):
				top3.append("%s=%.4f" % [String(t3[j]["opt"]), float(t3[j]["u"])])
			var has_prep: bool = false
			for r4 in t3:
				if String(r4["opt"]) == "備戰": has_prep = true
			print("     紮根u=%.4f｜備戰在候選=%s｜候選數=%d｜%s"
				% [zu, str(has_prep), t3.size(), " ".join(PackedStringArray(top3))])
	# per-option util（★沿用既有 zhagen.lost_table，不新建格式）
	var lt: Array = ps.get("zhagen.lost_table", [])
	if not lt.is_empty():
		print("  ── ★輸掉時的 per-option util（樣本 %d，最多印 3 筆）──" % lt.size())
		for i in range(mini(3, lt.size())):
			var e: Dictionary = lt[i]
			var tbl: Array = e.get("table", [])
			var top: Array = []
			for j in range(mini(5, tbl.size())):
				top.append("%s=%.4f" % [String(tbl[j]["opt"]), float(tbl[j]["u"])])
			print("     贏家=%s｜%s" % [String(e.get("winner", "?")), " ".join(PackedStringArray(top))])

func _buckets(pc: Dictionary, pfx: String) -> String:
	var out: Array = []
	for k in pc.keys():
		if String(k).begins_with(pfx):
			out.append("%s=%d" % [String(k).substr(pfx.length()), int(pc[k])])
	out.sort()
	return "｜".join(PackedStringArray(out)) if not out.is_empty() else "（空）"

func _fmt(d: Dictionary) -> String:
	var ks: Array = d.keys(); ks.sort()
	var parts: Array = []
	for k in ks: parts.append("%s=%d" % [String(k), int(d[k])])
	return " ".join(PackedStringArray(parts))

func _nums(a: Array) -> String:
	var parts: Array = []
	for v in a: parts.append("%.4f" % float(v))
	return " ".join(PackedStringArray(parts)) if not parts.is_empty() else "（無）"
