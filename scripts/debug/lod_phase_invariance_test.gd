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

# ★床側的 hex 距離（production 的 `_hex_distance` 已隨⑧刪除 —— ★而床要量距離就得自己有一份）。
#   ★★這【不是把它偷渡回 production】：它在 debug 床裡、只用於分組觀測，不進任何決策。
func _hex_dist(a: Vector2i, b: Vector2i) -> int:
	var dx: int = b.x - a.x
	var dy: int = b.y - a.y
	return (absi(dx) + absi(dx + dy) + absi(dy)) / 2

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

	# ★★★第⑧票之後【分班不存在】⇒ `lod.near/far.byteam` 兩個 tap 也不存在
	#   ⇒ ★不能再靠「runner 把你分到哪一批」來分組。
	#   ★★而如果只是把分組拿掉，這張床會從【證明距離無關】退化成【兩組是同一批】的空綠，
	#     而它還會印出漂亮的 PASS ⇒ ★★★那比沒有這張床更糟。
	#   ⇒ 改成【床自己量每隊到錨點的距離】：每個 pass 取樣一次，最後用平均距離分成遠/近兩半。
	var dist_sum: Dictionary = {}   # tid -> 距離總和
	var dist_n: Dictionary = {}     # tid -> 取樣次數（★母體要跟著走，否則平均沒有意義）
	for _t in range(total_ticks):
		runner.advance_tick(state, anchor)
		if _t % SimRunner.NEAR_CADENCE == 0:
			for _tid in state.teams:
				var _tm: TeamData = state.teams[_tid]
				# gate-ok: 純觀測（床側量測，不進任何決策）——讀真 tile_pos 只為了分組
				var _d: int = _hex_dist(_tm.tile_pos, anchor)
				dist_sum[int(_tid)] = float(dist_sum.get(_tid, 0.0)) + float(_d)
				dist_n[int(_tid)] = int(dist_n.get(_tid, 0)) + 1
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

	var pay: Dictionary = _count_by("salary.byteam.")
	# ★分組改由【床自己量的平均距離】決定：以中位數切兩半（★不用固定門檻——
	#   固定門檻在世界形狀改變時會讓一邊變空，而【空的那邊會讓判準變成恆真】）。
	var avg_d: Dictionary = {}
	var ds: Array = []
	for tid in whole:
		if int(dist_n.get(tid, 0)) == 0:
			continue
		var a: float = float(dist_sum[tid]) / float(dist_n[tid])
		avg_d[tid] = a
		ds.append(a)
	ds.sort()
	if ds.is_empty():
		_fail += 1
		print("  [FAIL] 距離取樣母體為 0 —— ★這不是「距離都一樣」，是【沒量到】")
		Probe.enabled = false
		return
	var med: float = ds[ds.size() / 2]
	var g_near: Array = []
	var g_far: Array = []
	for tid in avg_d.keys():
		if float(avg_d[tid]) > med:
			g_far.append(tid)
		else:
			g_near.append(tid)
	print("  分組（全窗存活者，★依【床自己量的平均距離】以中位數 %.1f 切）：遠半 %d 隊 ｜ 近半 %d 隊"
		% [med, g_far.size(), g_near.size()])
	print("     ★★而分班已拆除 ⇒ 這裡的「遠/近」只是【地理事實】，不再是【排程身分】——")
	print("        ★★★所以兩組的執行次數【應該】相同，而「應該」要被量不是被相信。")

	# ── 判準 A/B：母體不能塌陷 ──
	_ok(g_far.size() > 0, "A：far 組非空（母體 %d）★★空的話下面全部【答不了】，不是通過" % g_far.size())
	_ok(g_near.size() > 0, "B：near 組非空（母體 %d）★★同上" % g_near.size())
	if g_far.is_empty() or g_near.is_empty():
		print("  ★★★母體塌陷 ⇒ 本次【沒有量到】距離的影響。處置＝換錨點（挑一個真的有隊常駐的格），")
		print("     ★而不是把判準放寬 —— 放寬會讓這張床從此對這件事沒有鑑別力。")
		return

	# ── ★★★驗收②（第⑧票 §4-2）：判準擴到【三個不同系統】的 per-team 執行次數 ──
	#   ★薪資那條只證明【一條路】距離無關；分班影響的是【每一個 per-team 系統】。
	var sys_ok: bool = true
	for sysname in ["collect", "vision", "fatigue"]:
		var c: Dictionary = _count_by("sysexec.%s.byteam." % sysname)
		var sf: float = 0.0
		var sn: float = 0.0
		var zero_f: int = 0
		for tid in g_far:
			sf += float(c.get(tid, 0))
			if int(c.get(tid, 0)) == 0: zero_f += 1
		for tid in g_near:
			sn += float(c.get(tid, 0))
		var mf: float = sf / maxf(float(g_far.size()), 1.0)
		var mn: float = sn / maxf(float(g_near.size()), 1.0)
		# ★母體先於判準：兩組都 0 ⇒ 這個系統【沒量到】，不是「相等」
		if mf == 0.0 and mn == 0.0:
			_fail += 1
			sys_ok = false
			print("  [FAIL] %-8s ★兩組都是 0 ⇒【沒量到】不是【相等】（tap 沒開／系統沒跑）" % sysname)
			continue
		var rel: float = absf(mf - mn) / maxf(mf, mn)
		_ok(rel <= 0.10 and zero_f == 0,
			"%-8s 遠半平均 %.1f ／ 近半平均 %.1f ⇒ 相對差 %.1f%%（遠半 0 次的隊 %d）"
				% [sysname, mf, mn, rel * 100.0, zero_f])
		if rel > 0.10 or zero_f > 0:
			sys_ok = false
	print("     ★★★三個系統的判準：★相對差 <= 10% 且【遠半沒有任何一隊是 0 次】——")
	print("        ★而「0 次」那格是關鍵：⑧ 之前遠隊【有跑但慢 10 倍】，⑦ 之前遠隊【薪資完全沒跑】")
	print("        ⇒ ★★兩種病的簽名不同（一個是比值 ~0.1、一個是 0），判準要同時抓得到。")
	if not sys_ok:
		print("     ★把這一刀撤掉，上面的相對差應該回到 ~90%（遠隊每 600 才跑、近隊每 60）—— 不是「稍微變大」")


	# ★★★而這個守衛【只管薪資那一條】—— 它原本擺在【所有判準之前】，
	#   ⇒ ★短窗時它 `return` 掉，把【與窗長無關的】三系統判準（collect/vision/fatigue）一起吞掉
	#   ⇒ ★★而卷面只印「窗太短」，看起來像【一條沒過】，實際是【三條根本沒跑】
	#   ⇒ ★★★所以它搬到三系統判準【後面】：一個判準的守衛不該靜默壓掉另一個判準。
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
	var branch: Dictionary = _count_by("levy.branch.byfaction.")
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
		var got: int = int(due.get(int(fid), 0))
		var br: int = int(branch.get(int(fid), 0))
		# ★★★母體先於判準：本分支【每個 pass 進來一次】，所以 `br` 就是這個盟真的被評估過幾次。
		#   ★期望次數要用【它真的在「守成」的那段時間】算，不是用整個窗算 ——
		#     ★★否則一個大半時間在打仗的盟會被判成「徵收壞了」，而那是【拿假設的母體判沒有母體的格】。
		#   ★★★而 pass 之間相隔 NEAR_CADENCE(60)，所以「在守成的 tick 數」≈ br * 60。
		var in_hold_ticks: float = float(br) * float(SimRunner.NEAR_CADENCE)
		var expect: float = in_hold_ticks / float(eff)
		if br == 0:
			rows.append("f%d(貪%.2f義%.2f eff=%d) ★【從未進過「守成」】⇒ 不可判（不是 0 次，是沒有母體）" % [
				int(fid), greed, honor, eff])
			continue
		if expect < 1.0:
			rows.append("f%d(貪%.2f義%.2f eff=%d) 守成 pass=%d ⇒ 期望%.2f 次 <1 ⇒ 不可判（母體太小）" % [
				int(fid), greed, honor, eff, br, expect])
			continue
		checked += 1
		var ratio: float = float(got) / expect
		rows.append("f%d(貪%.2f義%.2f eff=%d) 守成 pass=%d 期望%.1f 實得%d 比值%.2f" % [
			int(fid), greed, honor, eff, br, expect, got, ratio])
		worst = maxf(worst, absf(ratio - 1.0))
	for r in rows:
		print("     " + r)
	# ★★★母體是 0 的時候，卷面要說【它們去哪了】—— 否則「不可判」只是另一個沒有內容的字。
	var sel: Array = []
	for k in Probe.counts.keys():
		var ks: String = String(k)
		if ks.begins_with("intent.sel_"):
			sel.append("%s=%d" % [ks.substr(11), int(Probe.counts[k])])
	sel.sort()
	print("     ★盟實際選到的意圖分布：%s" % (
		"｜".join(PackedStringArray(sel)) if not sel.is_empty() else "（空 ⇒ 連意圖選擇都沒跑到）"))
	print("        ★★而 `_rebuild_goals` 在【缺糧 survival override】那條會【提前 return】(:1436)")
	print("           ⇒ ★★★若盟長期缺糧，`match itype` 整段【根本到不了】—— 守成分支是死的，")
	print("              而那不是⑦的病，是【另一個要單獨查的東西】。")
	_ok(checked > 0, "G：★母體非空（可判的盟 %d）—— ★★0 的話下面【答不了】不是通過" % checked)
	if checked > 0:
		_ok(worst <= 0.35,
			"H：★★★每一盟的【實得／期望】都落在 1±0.35（最差偏離 %.2f）⇒ 排程準時、與人格無關" % worst)
		print("        ★鑑別力：撤掉⑦ ⇒ 比值會塌成 `gcd(60,eff)/60`（1/15~1/30）★★而且【逐盟不同】——")
		print("           那個【散開】就是「假人格訊號」的簽名，不是「全部一起變小」。")

	Probe.enabled = false
