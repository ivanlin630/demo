extends SceneTree
# @bed-kind: acceptance
# slice: 把每小時那一趟 pass 按隊錯開相位（裁定 A）—— P1 相位分佈／P3 逐隊間距／P6 陽性對照
#
# ★★★這張票的核心不是「用了 CadenceStagger」，是【檢查頻率】：
#   只在 60 的倍數檢查 ⇒ offset≥1 就跳過一個檢查點 ⇒ 間隔 120 ⇒ 頻率砍半。
#   ⇒ ★所以逐隊間距分布是必跑的：**不得只憑「用了工具」就假設分布正常**。
# ★★兩臂同跑（錯開臂 ＋ 樁關對照臂）⇒ 判決行同時帶兩邊的操作元
#   —— ★P6 的意義是【尖峰必須回來】，而那要兩個數擺在一起才看得出來。
# ★★★MIN_GAP 用 CadenceStagger.min_gap_of() 讀，不自己抄一份 cadence/2
#   （兩份會各自漂，而漂掉的那次不會有症狀）。
#
# env：SP_DAYS（預設 3）／SP_SEED（預設 1337）／SP_CONFIG（預設 warring_states）

const CAD: int = 60

var _fails: int = 0
var _cells: int = 0   # ★到場點名：由 _ok 自己數，不手抄 —— 手抄的數字不會跟著新增的格走

func _initialize() -> void:
	var days: int = int(OS.get_environment("SP_DAYS")) if OS.has_environment("SP_DAYS") else 3
	var sd: int = int(OS.get_environment("SP_SEED")) if OS.has_environment("SP_SEED") else 1337
	var cfg: String = OS.get_environment("SP_CONFIG") if OS.has_environment("SP_CONFIG") else "warring_states"
	print("=== pass 錯開床（days=%d seed=%d config=%s）===" % [days, sd, cfg])

	var stag: Dictionary = _run_arm(true, days, sd, cfg)
	var stub: Dictionary = _run_arm(false, days, sd, cfg)

	var min_gap: int = CadenceStagger.min_gap_of(CAD)
	var gaps: Array = stag["gaps"]          # 全體間距（排序過）
	var n_gap: int = gaps.size()
	print("
[PASSSTAG] ★母體：錯開臂間距樣本 %d 個｜隊數 %d｜天數 %d" % [
		n_gap, int(stag["teams"]), days])
	if n_gap < 100:
		push_error("[PASSSTAG][不可判] 間距樣本只有 %d ⇒ 母體塌陷（tap 沒接上，不是世界很短）" % n_gap)
		quit(2)
		return

	var g_med: int = int(gaps[n_gap / 2])
	var g_min: int = int(gaps[0])
	var g_max: int = int(gaps[n_gap - 1])
	# ★clamp 觸發＝間距恰好等於 MIN_GAP（本票的排程把 last_eval 傳 cur ⇒ 夾住時 gap==MIN_GAP）
	#   ★★這是【推論】不是直接量到的旗標，床把它講明白，不假裝是量到的。
	var clamp_ratio: float = float(stag["clamp_worst"]) / maxf(float(stag["clamp_mean"]), 0.0001)
	var stub_gaps: Array = stub["gaps"]
	var stub_all60: bool = true
	for gv in stub_gaps:
		if int(gv) != CAD:
			stub_all60 = false
			break
	print("[PASSSTAG] gap_median=%d  gap_min=%d  gap_max=%d  dup_in_cycle=%d  peak_stag=%d  peak_stub=%d  clamp_ratio=%.2f  stub_all60=%s" % [
		g_med, g_min, g_max, int(stag["dup"]), int(stag["peak"]), int(stub["peak"]), clamp_ratio,
		"1" if stub_all60 else "0"])
	print("[PASSSTAG] ★母體（不變量#9）：錯開臂 真隊=%d 野獸=%d 在外子隊=%d｜對照臂 真隊=%d 野獸=%d 在外子隊=%d" % [
		int(stag["n_real"]), int(stag["n_beast"]), int(stag["n_sub"]),
		int(stub["n_real"]), int(stub["n_beast"]), int(stub["n_sub"])])
	print("[PASSSTAG] ★判準：gap_median=60±1｜gap 全落在 [%d, %d]｜peak_stub 必須 >> peak_stag｜clamp_ratio<=3" % [
		min_gap, CAD * 2 - 1])

	# ★★★不變量#8：【頻率】拆成計數與間距兩欄，而【只守計數會全綠】。
	#   ★計數是【構造保證】⇒ 判準是恰好一次，不是 median ±5%（鬆的那一格不會紅）。
	#   ★★拆成兩個各自機械可判的條件：①沒有跳過週期（gap <= 2c-1）②同週期不得兩次。
	_ok(int(stag["dup"]) == 0,
		"P3 計數：同一週期內第二次 = %d（應 0）★與間距上界合起來就是【每週期恰好一次】" % int(stag["dup"]))
	_ok(stub_all60,
		"P3 對照臂（樁關）間距全部恰好 60 —— 不變量#8 的【純加法恆為 c】")
	_ok(absi(g_med - CAD) <= 1, "P3 間距中位數 %d（應 60±1）" % g_med)
	_ok(g_min >= min_gap and g_max <= CAD * 2 - 1,
		"P3 間距全落在 [%d, %d]（實測 [%d, %d]）" % [min_gap, CAD * 2 - 1, g_min, g_max])
	_ok(clamp_ratio <= 3.0,
		"P3 任一隊 clamp 觸發率 <= 母體平均 x3（實測 %.2f）★問的是有沒有系統性偏袒同一批隊,不是分佈均不均" % clamp_ratio)
	# ★P1／P6：樁關掉時所有隊擠在相位 0 ⇒ 尖峰必須回來
	_ok(int(stub["peak"]) > int(stag["peak"]) * 3,
		"P6 陽性對照：樁關掉 ⇒ 尖峰回來（stub %d vs stag %d）" % [int(stub["peak"]), int(stag["peak"])])

	print("=== pass_stagger DONE（fail=%d｜到場點名 %d）===" % [_fails, _cells])
	quit(1 if _fails > 0 else 0)

func _ok(cond: bool, msg: String) -> void:
	_cells += 1
	if cond:
		print("  PASS: " + msg)
	else:
		_fails += 1
		push_error("[PASSSTAG][FAIL] " + msg)

# 跑一臂，回 {gaps(排序), peak, teams, clamp_worst, clamp_mean}
func _run_arm(stagger: bool, days: int, sd: int, cfg: String) -> Dictionary:
	print("
-- 臂：%s --" % ("錯開（樁開）" if stagger else "★對照（樁關 ⇒ 全員整點）"))
	WorldState.pass_stagger_enabled = stagger
	SimRunner._pass_gap_last.clear()
	seed(sd)
	Probe.reset(); Probe.arm()
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg)
	var runner := SimRunner.new()
	for _t in range(days * WorldState.TICKS_PER_DAY):
		runner.advance_tick(st, Vector2i(-1, -1))
	WorldState.pass_stagger_enabled = true   # ★還原，免得污染同進程的下一臂

	# ★★不變量#9：【每隊】沒有主詞就是錯的 —— state.teams 裡住著三種東西。
	#   ★錯開的母體就是 state.teams.keys() 全體三種（本票不改母體）
	#   ⇒ ★★★P1／P3 的分母包含野獸與在外子隊 ⇒ 卡面必須分別印出三者各幾個。
	#   ★★這不是形式主義：peak 的分母若含 200 隻野獸，那個峰值的意義完全不同。
	var n_real: int = 0
	var n_beast: int = 0
	var n_sub: int = 0
	for tid0 in st.teams:
		var t0: TeamData = st.teams[tid0]
		if t0 == null:
			continue
		if String(t0.beast_kind) != "":
			n_beast += 1
		elif int(t0.parent_team_id) != -1:
			n_sub += 1
		else:
			n_real += 1
	print("   ★母體三欄：真隊=%d｜野獸=%d｜在外子隊=%d｜合計=%d" % [
		n_real, n_beast, n_sub, st.teams.size()])
	# 相位直方圖
	var peak: int = 0
	for ph in range(CAD):
		var c: int = int(Probe.counts.get("pass.phase.%02d" % ph, 0))
		if c > peak: peak = c
	# 逐隊間距
	var min_gap: int = CadenceStagger.min_gap_of(CAD)
	var gaps: Array = []
	var per_team_clamp: Dictionary = {}
	var per_team_total: Dictionary = {}
	for k in Probe.counts.keys():
		var key: String = String(k)
		if not key.begins_with("pass.gap."):
			continue
		var rest: String = key.substr(9)
		var dot: int = rest.find(".")
		if dot < 0:
			continue
		var tid: int = int(rest.substr(0, dot))
		var gap: int = int(rest.substr(dot + 1))
		var n: int = int(Probe.counts[k])
		for _i in range(n):
			gaps.append(gap)
		per_team_total[tid] = int(per_team_total.get(tid, 0)) + n
		if gap == min_gap:
			per_team_clamp[tid] = int(per_team_clamp.get(tid, 0)) + n
	gaps.sort()
	# clamp 觸發率：逐隊 clamp 次數 / 該隊總間距數
	var worst: float = 0.0
	var sum_rate: float = 0.0
	for tid2 in per_team_total.keys():
		var tot: int = int(per_team_total[tid2])
		if tot <= 0:
			continue
		var r: float = float(per_team_clamp.get(tid2, 0)) / float(tot)
		sum_rate += r
		if r > worst: worst = r
	var mean_rate: float = sum_rate / float(maxi(per_team_total.size(), 1))
	print("   隊數=%d｜間距樣本=%d｜相位尖峰=%d｜clamp 最壞率=%.4f 平均率=%.4f" % [
		per_team_total.size(), gaps.size(), peak, worst, mean_rate])
	# ★★★逐支系統的呈叫次數（systems 2026-09-23：數呈叫次數，不猜、不用 phase_timing）。
	#   ★【計數】不怕短窗也不怕機器忙：分母不會隨世界長大。
	var calls: Dictionary = {}
	var bsum: Dictionary = {}
	for k2 in Probe.counts.keys():
		var k2s: String = String(k2)
		if k2s.begins_with("syscall."):
			calls[k2s.substr(8)] = int(Probe.counts[k2])
	for k3 in Probe.amounts.keys():
		var k3s: String = String(k3)
		if k3s.begins_with("sysbatch."):
			bsum[k3s.substr(9)] = float(Probe.amounts[k3])
	var names: Array = calls.keys()
	names.sort()
	print("   ★逐支系統呈叫次數（共 %d 支）：" % names.size())
	for nm in names:
		var c2: int = int(calls[nm])
		var avg: float = float(bsum.get(nm, 0.0)) / float(maxi(c2, 1))
		# ★★★印【總和】不是只印平均：守恆的宣稱若用【平均×次數】回推，
		#   而平均是四捨五入過的 ⇒ 同一份資料 1.05 與 1.1 差 5.8%。
		#   ★總和是【直接量到的】，平均是從它算出來的 ⇒ 要比就比總和。
		print("     %-18s calls=%-7d batch_sum=%-8d 平均=%.2f" % [
			String(nm), c2, int(round(float(bsum.get(nm, 0.0)))), avg])
	return {"calls": calls, "gaps": gaps, "peak": peak, "teams": per_team_total.size(),
		"clamp_worst": worst, "clamp_mean": mean_rate,
		"dup": int(Probe.counts.get("pass.dup_in_cycle", 0)),
		"n_real": n_real, "n_beast": n_beast, "n_sub": n_sub}
