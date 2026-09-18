extends SceneTree
# @bed-kind: invariant
# slice: 凍結終線｜`*multi` 感知蒐集塊（spec §3 格 1-a｜★★★**這一格要在修法【之前】跑**）
#
# ★★★這支床問的**不是**「世界對不對」，是**「那支閘看不看得見這一票會出的錯」**：
#   語意零改變閘（`StateFingerprint`）是這一票唯一撐著「效能變好而語意沒變」那句話的東西。
#   ⇒ ★**如果它對【快取回一個過期的蒐集結果】不敏感，它就會恆綠** ——
#     而恆綠的閘會讓一個真的把行為改掉的修法**看起來是合格的**。
#
# ★★做法（spec §1 逐字：「手動把快取的值弄髒一格」）：
#   這一票要做的快取**還不存在** ⇒ 用一個**永不失效的快取**當故障源
#   （`DecisionContext._pc_fault_stale_prey`，預設關閉、交件前整段刪掉）——
#   ★它正是快取修法**做錯時的樣子**：**同樣的輸入不再得到同樣的輸出**。
#
# ★★★【兩層判準，而不是一層】（血證：我造的陽性對照自己沒打中，而它讀起來就是「這裡沒有問題」）：
#   (1) **注射有沒有咬到** ＝ `_pc_divergent > 0`（快取值 ≠ 當下重算值的次數）
#   (2) 咬到之後 **fp 有沒有不同**
#   ⇒ 三種結局，**不是兩種**：
#      ① 咬到了、fp 不同      ⇒ ✅ 那支閘**對這一票有鑑別力** ⇒ 可以開始修
#      ② 咬到了、fp **相同**  ⇒ ❌ **停下來回報**：閘擋不住這一票（spec §1 明令）
#      ③ **沒咬到**（divergent=0）⇒ ⚠ **不可判**：這一輪什麼都沒證明，要換更兇的注射／更長的窗
#        ★★★①③ 的差別是整票的成敗，而它們在「fp 不同／相同」那一欄上**長得一模一樣**。
#
# env：FPG_TICKS（預設 1200）／FPG_SEED（預設 1337）／FPG_CONFIG（預設 warring_states）

var _fail: int = 0
var _undec: int = 0
# ★★★這一行存在的理由：註冊表的 `expect` 是【逐行】比對的 ⇒ 要釘住各格的證據，
#   就得有一行把它們帶在一起。★釘 `PASS` 是不夠的 —— **一支什麼都沒判的床也能印 PASS**。
var _summary: String = ""
const EXPECTED_CELLS: Array = ["a-baseline", "b-fault", "c-verdict", "d-injector-off", "e-no-world-write", "f-cadence-control"]
var _cells_ran: Array = []

func _cell(name: String) -> void:
	if not _cells_ran.has(name):
		_cells_ran.append(name)

func noop() -> void:
	pass

func _selftest_gate(cell: String) -> Object:
	if OS.get_environment("BED_SELFTEST_DIE") != cell:
		return self
	print("[SELFTEST] ★故意讓 `%s` 這一格在中途死掉" % cell)
	return null

func _roll_call_missing() -> Array:
	var missing: Array = []
	for c in EXPECTED_CELLS:
		if not _cells_ran.has(c): missing.append(c)
	if not missing.is_empty():
		print("[roll-call] ❌ ★**有格沒有跑完**：%s —— 執行期錯誤會靜默中止一支 func，而那看起來像綠" % str(missing))
	return missing

func _initialize() -> void:
	_run()
	var _miss: Array = _roll_call_missing()
	print("[FPGS] %s｜到場點名 %d／%d" % [_summary, _cells_ran.size(), EXPECTED_CELLS.size()])
	print("-- 量測完成；[FAIL] 數 ＝ %d｜[不可判] 數 ＝ %d｜到場點名 %d／%d --" % [
		_fail + _miss.size(), _undec, _cells_ran.size(), EXPECTED_CELLS.size()])
	print("[TEST-SUITE-COMPLETE]")
	quit(1 if (_fail + _miss.size()) > 0 else 0)

func _ok(cond: bool, msg: String) -> void:
	if cond: print("  [OK] %s" % msg)
	else:
		_fail += 1
		push_error("[FAIL] %s" % msg)

func _undecidable(claim: String, why: String, how: String) -> void:
	_undec += 1
	push_error("[不可判] %s" % claim)
	print("  [不可判] %s\n       為什麼：%s\n       怎麼補：%s" % [claim, why, how])

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
	print("[TREE] HEAD=%s scripts-dirty=%d（%s）" % [sha, dirty, "clean" if dirty == 0 else "★dirty"])

var _ticks: int = 1200
var _seed: int = 1337
var _cfg: String = "warring_states"

# ★兩個世界【用同一支入口建】—— ★★不對稱地建世界，fp 會因為一個跟這一票無關的理由不同，
#   而那個 fp「不同」會被讀成「閘有鑑別力」⇒ 一個假的綠。
#   ★★★回傳兩個東西，而第二個是這一格的命門：
#     `fp`    ＝ 語意零改變閘看到的（**終局狀態**）
#     `trace` ＝ ★**逐 tick 的行為軌跡摘要**（每一 tick 全隊的 task／位置／人口）
#   ★為什麼要 trace：`_pc_divergent > 0` 只證明**蒐集出來的欄位**不同，
#   ★★**不證明任何一個決策因此改變** —— 而若決策一個都沒變，世界就真的沒變，
#     ⇒ **fp 相同是【對的】，它什麼都沒瞎**。
#   ★★★這兩件事在「fp 相同」那一欄上長得一模一樣，而**結論相反**：
#     trace 不同 ＋ fp 相同 ⇒ **閘瞎了**（停工回報）
#     trace 相同         ⇒ **注射沒有走到行為** ⇒ 不可判（要更兇的注射）
func _run_world() -> Array:
	seed(_seed)
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/%s.json" % _cfg)
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)
	var trace: int = 0
	for _i in range(_ticks):
		runner.advance_tick(st, no_player)
		var line: String = ""
		for tid in st.teams:
			var t: TeamData = st.teams[tid]
			line += "%d:%s:%d,%d:%d|" % [tid, t.current_task, t.tile_pos.x, t.tile_pos.y, t.population]
		trace = hash("%d#%s#%d" % [trace, line, _i])
	return [StateFingerprint.compute(st), trace]

func _run() -> void:
	_ticks = int(OS.get_environment("FPG_TICKS")) if OS.has_environment("FPG_TICKS") else 1200
	_seed = int(OS.get_environment("FPG_SEED")) if OS.has_environment("FPG_SEED") else 1337
	_cfg = OS.get_environment("FPG_CONFIG") if OS.has_environment("FPG_CONFIG") else "warring_states"
	print("=== 語意零改變閘的陽性對照（config=%s ticks=%d seed=%d）===" % [_cfg, _ticks, _seed])
	print("★問題：**fp 指紋看不看得見「快取回一個過期的蒐集結果」？**（spec §3 格 1-a）")
	_bed_self_check_tree()
	print("[本尺排除] %s" % StateFingerprint.EXCLUDES_SUBFIELD)
	print("   ★★上面那一行是**強制要印**的（invariant）：fp 對被排除的東西是【設計上就不看】，")
	print("   ★★★而這一格要問的正是「我要動的那塊，在不在它看得見的範圍裡」。")

	# ── a：乾淨基準 ──
	_selftest_gate("a-baseline").noop()
	DecisionContext._pc_fault_stale_prey = false
	DecisionContext._pc_reset()
	var _ra: Array = _run_world()
	var fp_clean: String = String(_ra[0])
	var trace_clean: int = int(_ra[1])
	print()
	print("a｜乾淨跑：fp=%s｜★行為軌跡摘要=%d" % [fp_clean, trace_clean])
	_ok(fp_clean.length() == 32,
		"a-前提 ★fp 真的算出來了（32-hex）｜★算不出來的話下面兩格比的是空字串")
	_cell("a-baseline")

	# ── b：注入「永不失效的快取」──
	_selftest_gate("b-fault").noop()
	DecisionContext._pc_fault_stale_prey = true
	DecisionContext._pc_reset()
	var _rb: Array = _run_world()
	var fp_fault: String = String(_rb[0])
	var trace_fault: int = int(_rb[1])
	var hits: int = DecisionContext._pc_hits
	var div: int = DecisionContext._pc_divergent
	DecisionContext._pc_fault_stale_prey = false
	print()
	print("b｜注入永不失效的快取：fp=%s｜★行為軌跡摘要=%d" % [fp_fault, trace_fault])
	print("   讀到快取 %d 次｜★**快取值 ≠ 當下重算值 ＝ %d 次**（＝注射真的咬到的次數）" % [hits, div])
	_ok(hits > 0,
		"b-前提① ★注射的那段 code **真的跑到了**（讀到快取 %d 次）｜★為 0 ⇒ 注射根本沒被執行" % hits)
	_cell("b-fault")

	# ── c：★★★四種結局（我第一版寫三種，而資料逼出了第四種）──
	_selftest_gate("c-verdict").noop()
	print()
	print("— c：判決 —")
	var trace_diff: bool = trace_fault != trace_clean
	var fp_diff: bool = fp_fault != fp_clean
	print("   注射咬到 %d 次｜行為軌跡 %s｜fp %s" % [
		div, "★不同" if trace_diff else "相同", "不同" if fp_diff else "相同"])
	if div == 0:
		_undecidable(
			"「fp 看不看得見一個過期的蒐集結果」",
			"★**注射沒有咬到**：快取值與當下重算值**從來沒有不同過**（divergent=0）"
			+ " ⇒ 這一輪的 fp 相不相同**什麼都不證明**（餵給 fp 的東西根本沒被改掉）",
			"換更兇的注射（改別的 `gather.*` 欄位）或拉長 FPG_TICKS")
	elif not trace_diff:
		# ★★★這一格是【資料逼出來的第四種結局】——我第一版的分類器沒有它：
		#   `_pc_divergent > 0` 只證明**蒐集出來的欄位**不同，
		#   ★**不證明任何一個決策因此改變**（那個欄位可能根本沒有翻轉任何一次排序的勝負）。
		#   ⇒ ★★行為一個都沒變 ⇒ 世界真的沒變 ⇒ **fp 相同是【對的】，它沒有瞎**。
		#   ★★★而這跟「閘瞎了」在 fp 那一欄上**長得一模一樣、結論相反**。
		_undecidable(
			"「fp 看不看得見一個過期的蒐集結果」",
			"★注射咬到了欄位（%d 次），★★**但行為軌跡逐 tick 相同** —— " % div
			+ "沒有任何一個決策因此改變 ⇒ 世界本來就沒變 ⇒ **fp 相同是正確的，不是瞎**",
			"換一個**會改變決策勝負**的注射點（本次注的 `scout_*` 只餵斥候選項）"
			+ " —— ★★★在那之前，**不可以**說那支閘有或沒有鑑別力")
	else:
		_ok(fp_diff,
			"c ★★★**閘對這一票有鑑別力**：注射咬到 %d 次、**行為軌跡不同**，而 fp **也不同**" % div
			+ "（%s ≠ %s）" % [fp_clean.substr(0, 12), fp_fault.substr(0, 12)]
			+ "｜★★行為變了而 fp 相同 ⇒ **停下來回報**：那支閘擋不住這一票（spec §1 明令）")
	print("   判準表：咬到%s／行為%s／fp%s ⇒ %s" % [
		"✅" if div > 0 else "❌",
		"變了" if trace_diff else "沒變",
		"不同" if fp_diff else "相同",
		("✅有鑑別力" if fp_diff else "❌閘瞎了，停工回報") if (div > 0 and trace_diff)
			else ("⚠不可判：注射沒咬到" if div == 0 else "⚠不可判：咬到欄位但沒改到行為")])
	_cell("c-verdict")

	# ── e：★`gather(advance=false)` 不得寫世界（systems 裁：那個 0 要當守衛留下）──
	#   ★★量法不是數 tap（tap 是清單，而清單漏過 `LaborSystem.ensure_fresh` 的兩個寫入點）
	#     —— 是【呼叫前後各取一次全世界指紋】⇒ 對清單完整性不敏感。
	#   ★★★母體一起印：**母體 ＝ 0 的話這一格會恆綠**，那才是真的危險。
	_selftest_gate("e-no-world-write").noop()
	print()
	print("— e：`advance=false` 有沒有寫世界 —")
	DecisionContext._w_reset()
	DecisionContext._w_probe = true
	var _we_fp: String = String(_run_world()[0])
	DecisionContext._w_probe = false
	var w_calls: int = DecisionContext._w_calls
	var w_dirty: int = DecisionContext._w_dirty
	print("   advance=false 呼叫 %d 次｜★其中寫了世界 %d 次（fp=%s）" % [
		w_calls, w_dirty, _we_fp.substr(0, 12)])
	_ok(w_calls > 0,
		"e-前提 ★**母體非 0**：這一輪真的有 `advance=false` 的呼叫（%d 次）" % w_calls
		+ "｜★★為 0 ⇒ 下一句話會【恆綠】，那不是綠是瞎")
	print("   ★其中【cadence／cache 影子雜湊】變了 %d 次（★指紋看不見這一類）" % DecisionContext._w_cad_dirty)
	_ok(w_dirty == 0 and DecisionContext._w_cad_dirty == 0,
		"e ★★★**`advance=false` 一次都沒有寫世界**（指紋 %d／%d｜cadence 影子 %d／%d）" % [
			w_dirty, w_calls, DecisionContext._w_cad_dirty, w_calls]
		+ "｜★>0 ⇒ 「少呼一次 gather」本身就會改變世界 ⇒ (丙-2) 在構造上做不到格 1-e，停工回報")
	_cell("e-no-world-write")

	# ── f：★★★**e 那個 0 自己的陽性對照**（systems 裁 2026-09-18）──
	#   ★沒有這一格，「0」的意思可能是【儀器對這一類寫入不敏感】而不是【沒有寫入】。
	#   ★★實測過的血證就在這一格旁邊：**指紋對 cadence 欄位是【設計上】瞎的**
	#     （`EXCLUDES_SUBFIELD` 自己寫著 `cadence 排程欄(*_eval_next_tick)`；
	#      我 +1 四個 cadence 欄，指紋【逐字不動】）⇒ 所以才有那個影子雜湊。
	#   ★★★這一格釘的是【影子雜湊真的會動】—— 而且順便釘住指紋的盲區是【已知】的，不是被遺忘的。
	_selftest_gate("f-cadence-control").noop()
	print()
	print("— f：e 那個 0 的陽性對照（★手動動 cadence 欄位）—")
	seed(_seed)
	var fs: WorldState = MeasureBedHelper.arm_and_setup("res://config/%s.json" % _cfg)
	var frunner := SimRunner.new()
	for _fi in range(200):
		frunner.advance_tick(fs, Vector2i(-1, -1))
	var cad0: int = DecisionContext._w_cadence_hash(fs)
	var fp0: String = StateFingerprint.compute(fs)
	var ftid: int = -1
	for k in fs.teams: ftid = k; break
	fs.teams[ftid].consolidate_eval_next_tick += 1
	var cad1: int = DecisionContext._w_cadence_hash(fs)
	var fp1: String = StateFingerprint.compute(fs)
	print("   cadence 欄 +1 ⇒ 影子雜湊 %s｜指紋 %s" % [
		"★變了" if cad1 != cad0 else "❌沒變", "變了" if fp1 != fp0 else "★沒變（已知盲區）"])
	_ok(cad1 != cad0,
		"f ★★★**影子雜湊對 cadence 寫入【有】反應** —— e 的那個 0 才有意義"
		+ "｜★沒反應 ⇒ e 是【儀器瞎】不是【沒寫入】")
	_ok(fp1 == fp0,
		"f-② ★**指紋對 cadence 寫入【沒有】反應**（這是【已知且刻意】的排除，不是 bug）"
		+ "｜★★它若忽然有反應 ⇒ `StateFingerprint` 的排除清單改了 ⇒ 影子雜湊可以退休，**回來刪掉它**")
	_cell("f-cadence-control")

	# ── d：★★★陰陽兩格 —— **同一輪之內三跑，不跟任何歷史字串比** ──
	#   ★systems 自我更正（2026-09-18）：原案是「陰那跑 == 釘死的基線字串」，而他改掉了，理由是
	#     **釘歷史 fp ⇒ 任何【合法】的世界改動都會把這支床打紅 ⇒ 它變成噪音**，
	#     ★★而噪音的代價不是多看一眼，是**連它旁邊那支真的紅也開始被忽略**。
	#   ⇒ 現在比較的兩邊只差【注射旗標】這一個變因：
	#       關閉 ×2 ⇒ 兩次 fp 必須【逐字相同】（這支床自己有決定性）
	#       開啟 ×1 ⇒ fp 必須【與關閉不同】（那支語意閘還有牙）
	#   ★★★而「旗標恆真 ＝ 注射器意外常開」會讓開啟那跑與關閉相同 ⇒ 照樣紅。
	#   ★第二次「關閉」【重用 e 那一跑】—— 它本來就是注射關閉的整輪，不必多跑一個世界。
	_selftest_gate("d-injector-off").noop()
	print()
	print("— d：陰陽（同一輪三跑，只差注射旗標）—")
	print("   關閉①=%s｜關閉②=%s｜開啟=%s" % [
		fp_clean.substr(0, 12), _we_fp.substr(0, 12), fp_fault.substr(0, 12)])
	_ok(fp_clean == _we_fp,
		"d-陰 ★**注射關閉的兩跑 fp 逐字相同** —— 這支床自己是決定性的"
		+ "｜★不同 ⇒ 先修這支床，它現在說什麼都不算數")
	_ok(fp_fault != fp_clean,
		"d-陽 ★★**注射開啟的那跑 fp 與關閉不同** —— 那支語意閘還有牙"
		+ "｜★★★相同 ⇒ 兩種都要查：注射器意外常開（旗標恆真），**或**閘失去鑑別力")
	_summary = "陰=%s 陽=%s｜注射咬到=%d｜寫世界=%d／%d｜cadence影子=%d／%d｜cadence對照=%s" % [
		"同" if fp_clean == _we_fp else "★異", "異" if fp_fault != fp_clean else "★同",
		div, w_dirty, w_calls, DecisionContext._w_cad_dirty, w_calls,
		"會動" if cad1 != cad0 else "★不動"]
	_cell("d-injector-off")
