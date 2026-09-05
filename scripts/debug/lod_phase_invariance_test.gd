extends SceneTree

# ★★★LOD 相位不變性（第⑦票驗收②，systems 2026-09-05 改裁後的形狀）
#
# ★systems 原本的驗收②是「跑兩次（一次全 far、一次 FULL_HD=1 全 near），比總支付額」。
#   ★★我回報那【做不到】：`force_full_hd` 會把 near/far 分班整個關掉
#     ⇒ manufacture／collect／reactions 的 cadence 全部跟著變 ⇒ 那是【兩個世界】，同 seed 也不會相等。
#   ⇒ ★★★systems 改裁：正解是【同一個世界裡同時有 near 隊與 far 隊】，
#      斷言 per-team 發薪次數【與距離無關】。本檔就是那張床。
#
# ★做法：`player_pos` 釘在一個【固定的真實座標】上（不是 (-1,-1)）
#   ⇒ 離它 <= LOD_NEAR_RADIUS(3) 的隊走 near 批次、其餘走 far 批次
#   ⇒ ★而隊會移動，所以「近/遠」是【比例】不是標籤 ⇒ 用 `lod.near/far.byteam.*` 實測分組。
#
# ★★★這張床的鑑別力（★把機制關掉這條會不會還是綠的）：
#   把 ⑦ 撤掉（salary 改回 `current_tick % SALARY_INTERVAL == 0`）⇒ far 組的發薪次數會【變回 0】
#   ⇒ 判準 D（far 組沒有任何一隊是 0）與判準 E（兩組平均差 <= 0.5）都會紅。
#   ★而【不是變小是變 0】—— 那正是 systems 對驗收④的要求。
#
# ★母體塌陷保護：如果測完發現【只有一組有人】，本檔判 FAIL 並說明「這不是通過，是沒量到」。
#
# 用法：LODINV_SEED（default 1337）／LODINV_TICKS（default 43200 = 30 日）

var _fail: int = 0

func _initialize() -> void:
	_run()
	if _fail == 0:
		print("=== DONE === ALL PASS")
	else:
		print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond: print("  [PASS] %s" % msg)
	else: _fail += 1; print("  [FAIL] %s" % msg)

func _count_by(prefix: String) -> Dictionary:
	var out: Dictionary = {}
	for k in Probe.counts.keys():
		var ks: String = String(k)
		if ks.begins_with(prefix):
			out[int(ks.substr(prefix.length()))] = int(Probe.counts[k])
	return out

func _run() -> void:
	var world_seed: int = int(OS.get_environment("LODINV_SEED")) if OS.has_environment("LODINV_SEED") else 1337
	var total_ticks: int = int(OS.get_environment("LODINV_TICKS")) if OS.has_environment("LODINV_TICKS") else WorldState.TICKS_PER_MONTH
	print("=== lod_phase_invariance_test: seed=%d ticks=%d ===" % [world_seed, total_ticks])
	print("★問的是：【同一個世界裡】，一隊拿不拿得到薪水，跟它離觀察者多遠有沒有關係。")
	print("  ★★憲法：計算跟隨【事件密度】不跟隨【觀察者】⇒ 期望答案是【無關】。")
	seed(world_seed)
	SimRunner.force_full_hd = false   # ★必須保留分班 —— 這張床要的就是【兩批同時存在】
	var config: Dictionary = GameSetup.load_config("res://config/default.json")
	config["seed"] = world_seed
	# ★★★arm 順序寫死（bed-arm 閘）：`Probe.arm()` 必須發生在 `GameSetup.setup()` 之前，
	#   ★否則建世界那一段的事件【不在量測窗內】，而那個缺口印出來跟「沒發生」一樣。
	var state: WorldState = MeasureBedHelper.arm_and_setup(config)
	var runner := SimRunner.new()

	# ★把 player_pos 釘在【第一隊的起始格】—— 一個真實座標（不是 (-1,-1)），
	#   ★★而它是【固定】的：隊會走開／走近，所以近遠是實測比例，不是預設標籤。
	var anchor: Vector2i = Vector2i(0, 0)
	var t0_ids: Array = []
	for tid in state.teams:
		t0_ids.append(int(tid))
	t0_ids.sort()
	if not t0_ids.is_empty():
		var t0: TeamData = state.teams[t0_ids[0]]
		anchor = t0.tile_pos
	print("  觀察者錨點 = %s（★固定不動；隊會移動 ⇒ 近/遠是實測比例）" % str(anchor))
	print("  起始隊數 = %d" % t0_ids.size())

	for _t in range(total_ticks):
		runner.advance_tick(state, anchor)
		if state.teams.is_empty():
			break

	var alive_end: Array = []
	for tid in state.teams:
		alive_end.append(int(tid))
	# ★全窗存活 = 開頭有、結尾也在（★中途生／中途死的隊次數天生 <4，不能混進判準）
	var whole: Array = []
	for tid in t0_ids:
		if alive_end.has(tid):
			whole.append(tid)
	print("  全窗存活的隊 = %d／%d（★中途生或中途死的【不進判準】—— 它們的次數天生偏低）"
		% [whole.size(), t0_ids.size()])

	# ★★★窗長守衛：stagger 讓【第一次發薪】落在 [C, 2C) 之間（offset 均勻）
	#   ⇒ 窗 < 3 個週期時，「有些隊 0 次」是【窗太短】不是【⑦ 壞了】
	#   ⇒ ★不要讓這張床在那種窗下印出【看起來像病、其實是量法錯】的紅。
	var _cyc: int = total_ticks / SalarySystem.SALARY_INTERVAL
	if _cyc < 3:
		_fail += 1
		print("  [FAIL] 窗太短：%d tick = %d 個發薪週期（需 >= 3）" % [total_ticks, _cyc])
		print("     ★★理由：stagger 下第一次發薪落在 [C, 2C)，窗 < 3C 時「0 次」分不出")
		print("        【⑦ 壞了】與【還沒輪到】⇒ ★★★這是量法失效，不是結論。")
		Probe.enabled = false
		return
	var pay: Dictionary = _count_by("salary.byteam.")
	var nearc: Dictionary = _count_by("lod.near.byteam.")
	var farc: Dictionary = _count_by("lod.far.byteam.")

	var g_near: Array = []
	var g_far: Array = []
	for tid in whole:
		var n: int = int(nearc.get(tid, 0))
		var f: int = int(farc.get(tid, 0))
		if n + f == 0:
			continue
		var share: float = float(n) / float(n + f)
		if share <= 0.0:
			g_far.append(tid)
		elif share >= 0.5:
			g_near.append(tid)
	print("  分組（全窗存活者）：【純 far】%d 隊 ｜【多數時間 near】%d 隊" % [g_far.size(), g_near.size()])

	# ── 判準 A/B：母體不能塌陷 ──
	_ok(g_far.size() > 0, "A：far 組非空（母體 %d）★★空的話下面全部【答不了】，不是通過" % g_far.size())
	_ok(g_near.size() > 0, "B：near 組非空（母體 %d）★★同上" % g_near.size())
	if g_far.is_empty() or g_near.is_empty():
		print("  ★★★母體塌陷 ⇒ 本次【沒有量到】距離的影響。處置＝換錨點（挑一個真的有隊常駐的格），")
		print("     ★而不是把判準放寬 —— 放寬會讓這張床從此對這件事沒有鑑別力。")
		return

	var sum_far: int = 0
	var zero_far: Array = []
	for tid in g_far:
		var c: int = int(pay.get(tid, 0))
		sum_far += c
		if c == 0: zero_far.append(tid)
	var sum_near: int = 0
	var zero_near: Array = []
	for tid in g_near:
		var c: int = int(pay.get(tid, 0))
		sum_near += c
		if c == 0: zero_near.append(tid)
	var mean_far: float = float(sum_far) / float(g_far.size())
	var mean_near: float = float(sum_near) / float(g_near.size())
	print("  發薪次數：far 組平均 %.2f（合計 %d）｜ near 組平均 %.2f（合計 %d）"
		% [mean_far, sum_far, mean_near, sum_near])

	# ── 判準 C/D：★「變回 0」是⑦的病的簽名 —— 不是「變小」 ──
	_ok(zero_far.is_empty(),
		"C：★far 組【沒有一隊是 0 次】（0 次的隊 = %s）—— ★★這一格就是⑦的病本身" % str(zero_far))
	_ok(zero_near.is_empty(),
		"D：near 組沒有一隊是 0 次（0 次的隊 = %s）" % str(zero_near))

	# ── 判準 E：兩組平均相等（★這是「玩家無關」的操作定義） ──
	_ok(absf(mean_far - mean_near) <= 0.5,
		"E：★★兩組平均差 %.2f <= 0.5 ⇒ 拿不拿得到薪水【與距離無關】（憲法：計算跟隨事件密度不跟隨觀察者）"
			% absf(mean_far - mean_near))

	# ── 判準 F：★次數本身要合理（否則「兩組都是 0」也會讓 E 通過） ──
	#   ★★★這格是給 E 補鑑別力的：E 是【差值】判準，而差值對「兩邊都掛掉」完全不敏感。
	var cycles: int = total_ticks / SalarySystem.SALARY_INTERVAL
	_ok(mean_far >= float(cycles) - 1.5 and mean_near >= float(cycles) - 1.5,
		"F：★★★兩組平均都 >= %d-1.5（窗內週期數 %d；stagger 讓相位落窗尾的隊少一次）—— ★而沒有這格，【兩組都是 0】會讓 E 通過"
			% [cycles, cycles])

	# ════════ ★驗收③：定期徵收的【排程準時度】逐盟比對（systems 2026-09-05 採用我提的替代判準）════════
	# ★原判準（far/near 對照）問錯了問題：`evaluate_all(state, _team_ids)` 的 `_team_ids` 沒用、
	#   `for fid in state.factions` 每個 pass 跑全部的盟 ⇒ ★盟根本不分 far/near ⇒ 那個對照【恆等】。
	# ★★真病是【量化】：pass 只在 `t % 60 == 0` 發生 ⇒ 實際週期 = `lcm(60, eff)`，失真 = `60 / gcd(60, eff)`
	#   而 `eff` 由 leader 的貪婪／義氣算出 ⇒ ★★★失真【隨人格而異】，且【只有平均人格準時】
	#   —— 它製造了一個【假的人格訊號】：看起來像「這位統領不愛徵收」。
	print("")
	print("═══ ★驗收③：定期徵收的排程準時度（逐盟；★合計會把人格相關的失真平均掉）═══")
	var due: Dictionary = _count_by("levy.due.byfaction.")
	var rows: Array = []
	var worst: float = 0.0
	var checked: int = 0
	for fid in state.factions:
		var f = state.factions[fid]
		var lt: TeamData = state.teams.get(f.leader_team_id)
		if lt == null:
			continue
		var lp: PersonData = state.persons.get(lt.leader_id)
		if lp == null:
			continue
		var greed: float = float(lp.values.get("貪婪", 0.5))
		var honor: float = float(lp.values.get("義氣", 0.5))
		var eff: int = maxi(int(FactionAISystem.COLLECT_INTERVAL * (1.5 - greed)
			* (1.0 + honor * FactionAISystem.HONOR_INTERVAL_MULT)), 10)
		var expect: float = float(total_ticks) / float(eff)
		var got: int = int(due.get(int(fid), 0))
		if expect < 1.0:
			continue   # ★窗內連一次都不該有 ⇒ 這盟答不了，別混進判準
		checked += 1
		var ratio: float = float(got) / expect
		rows.append("f%d(貪%.2f義%.2f eff=%d) 期望%.1f 實得%d 比值%.2f" % [
			int(fid), greed, honor, eff, expect, got, ratio])
		worst = maxf(worst, absf(ratio - 1.0))
	for r in rows:
		print("     " + r)
	_ok(checked > 0, "G：★母體非空（可判的盟 %d）—— ★★0 的話下面【答不了】不是通過" % checked)
	if checked > 0:
		_ok(worst <= 0.35,
			"H：★★★每一盟的【實得／期望】都落在 1±0.35（最差偏離 %.2f）⇒ 排程準時、與人格無關" % worst)
		print("        ★鑑別力：撤掉⑦ ⇒ 比值會塌成 `gcd(60,eff)/60`（1/15~1/30）★★而且【逐盟不同】——")
		print("           那個【散開】就是「假人格訊號」的簽名，不是「全部一起變小」。")

	Probe.enabled = false
