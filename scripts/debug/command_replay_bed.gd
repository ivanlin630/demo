extends SceneTree
# @bed-kind: acceptance
# slice: 玩家指令佇列化 —— ★★★這支床【就是】spec §7-② 說的「重播驅動今天不存在、要一起做」。
#
# ★★★它要證明的那一句（spec §1，blueprint 逐字）：
#   決定性 ＝【重播可重現】：同種子 ＋ 同一串玩家指令（每條帶被套用的 tick 編號）
#   ⇒ 同一個世界（fp 逐字相同）。
#
# ★★時序在這裡必須寫死，因為它【差一格不會馬上紅】：
#   ·指令在 `advance_tick()` 之【前】入列
#   ·消費點在 `_step1_advance_time()` 之【後】，而 `current_tick += 1` 發生在它裡面
#   ⇒ ★一條在 `current_tick == T` 時入列的指令，會在 `current_tick == T+1` 被套用，
#     並以 `tick = T+1` 記進 command_log
#   ⇒ ★★所以重播時要在 `current_tick == 記錄的 tick - 1` 那一刻入列。
#   ⇒ ★★★寫錯這個偏移【兩邊會各自內部一致】——原跑與重播都會產出「某個」fp，
#     只是兩個不一樣，而錯誤看起來像「佇列不決定」。所以偏移寫在這裡一次，不散在兩處。
#
# env：CR_SEED（預設 20260923）／CR_CONFIG（預設 warring_states）／CR_TICKS（預設 1200）
#
# ★誠實限（動工時無法消除的）：本床由【腳本】下指令，不經過 `_input()`；
#   ⇒ 它證明的是「同一串指令 ⇒ 同一個世界」，★★不是「玩家按鍵會產生同一串指令」。
#     後者要 UI 層的錄製，不在本票（spec §6）。

const HOUR: int = 60

var _errors: int = 0
var _cells_ran: Array = []

# ★格式對但世界不允許：座標不在地圖上 ⇒ dispatch 認得 name、handler 會拒絕
const BAD_TILE: Vector2i = Vector2i(9999, 9999)
const EXPECTED_CELLS: Array = ["_test_replay_same_fp", "_test_negative_boundary_shift", "_test_queue_defers",
	"_test_p9_enqueue_echo", "_test_p10_result_lines", "_test_p12_reject_comes_late",
	"_test_p13_queries_are_pure", "_test_p13b_confirm_has_a_landing_point",
	"_test_p14_reading_does_not_change_the_world", "_test_p14b_results_expire_by_tick"]


func _cell(name: String) -> void:
	if not _cells_ran.has(name):
		_cells_ran.append(name)


func _check(label: String, cond: bool) -> void:
	if cond:
		print("  PASS: %s" % label)
	else:
		_errors += 1
		print("  FAIL: %s" % label)


func _seed_of() -> int:
	return int(OS.get_environment("CR_SEED")) if OS.has_environment("CR_SEED") else 20260923


func _cfg_of() -> String:
	return OS.get_environment("CR_CONFIG") if OS.has_environment("CR_CONFIG") else "warring_states"


func _ticks_of() -> int:
	return int(OS.get_environment("CR_TICKS")) if OS.has_environment("CR_TICKS") else 1200


func _fresh() -> Array:
	# ★每一趟都從【同一顆種子】重建：★★不共用 WorldState，否則第二趟是接著第一趟跑
	seed(_seed_of())
	var st := WorldState.new()
	GameSetup.setup(st, GameSetup.load_config("res://config/%s.json" % _cfg_of()))
	return [st, SimRunner.new()]


# 產一串【會改到世界】的指令：玩家隊往四個不同的鄰格移動。
# ★★母體地板由呼叫端驗：spec §5-P2 要求「至少 N≥5 條真的改到世界的指令」，
#   ⇒ ★這裡只負責【產生候選】，「它們真的 ok」要由 command_log 的 ok 欄位回答，
#     ★★★不是由「我寫了幾條」回答（寫幾條都綠 ＝ 拿量到的數跟產生它的陣列比）。
func _script_for(st: WorldState) -> Array:
	var pid: int = int(st.player_id)
	if pid < 0 or not st.persons.has(pid):
		return []
	var tid: int = int(st.persons[pid].team_id)
	if not st.teams.has(tid):
		return []
	var here: Vector2i = st.teams[tid].tile_pos
	var dirs: Array = [Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 1), Vector2i(-1, 0),
		Vector2i(0, -1), Vector2i(1, -1)]
	var out: Array = []
	var at: int = 3 * HOUR
	for d in dirs:
		var t: Vector2i = here + d
		if not st.tiles.has(t):
			continue
		out.append({"at": at, "name": "move_to", "args": {"tile_q": t.x, "tile_r": t.y}})
		at += HOUR + 7   # ★刻意不對齊整點：否則每一條都落在同一種相位上
	return out


# 跑一趟：在指定 tick 入列、推進到底、回 { fp, log, ok_count }
# ★`plan` 的每一筆 `at` ＝【入列時的 current_tick】（不是生效 tick）。
func _run(plan: Array) -> Dictionary:
	var pair: Array = _fresh()
	var st: WorldState = pair[0]
	var runner: SimRunner = pair[1]
	var by_tick: Dictionary = {}
	for c in plan:
		var k: int = int(c.get("at", -1))
		if not by_tick.has(k):
			by_tick[k] = []
		by_tick[k].append(c)
	var n: int = _ticks_of()
	for _i in range(n):
		var now: int = st.world.current_tick
		if by_tick.has(now):
			for c in by_tick[now]:
				st.command_seq += 1
				st.pending_commands.append({
					"name": String(c.get("name", "")), "args": c.get("args", {}),
					"seq": st.command_seq})
		runner.advance_tick(st, Vector2i(-1, -1))
	var ok_n: int = 0
	for e in st.command_log:
		if bool(e.get("ok", false)):
			ok_n += 1
	return {"fp": StateFingerprint.compute(st), "log": st.command_log, "ok": ok_n,
		"queued": int(st.command_seq)}


# 把 command_log 轉回【可重播的計畫】：生效 tick − 1 ＝ 入列 tick（見檔頭時序）。
func _plan_from_log(log: Array) -> Array:
	var out: Array = []
	for e in log:
		out.append({"at": int(e.get("tick", 0)) - 1, "name": String(e.get("name", "")),
			"args": e.get("args", {})})
	return out


# ══════════ P2［重播］同種子 ＋ 同一份 command_log ⇒ final_fp 逐字相同 ══════════
func _test_replay_same_fp() -> void:
	print("\n── P2 重播：同種子＋同一串指令 ⇒ 同一個世界 ──")
	var probe: Array = _fresh()
	var plan: Array = _script_for(probe[0])
	if plan.is_empty():
		_errors += 1
		print("  ★[不可判] 造不出指令串（沒有玩家隊或沒有鄰格）⇒ 這不是綠")
		_cell("_test_replay_same_fp")
		return
	var a: Dictionary = _run(plan)
	# ★★★母體地板：要的是【真的改到世界】的條數，而那個數來自 command_log 的 ok 欄位，
	#   不是來自我寫了幾條（spec §5-P2 要求 N≥5）。
	_check("★母體地板：command_log 裡 ok 的指令 %d 條（spec 要求 ≥5）" % int(a["ok"]),
		int(a["ok"]) >= 5)
	_check("★★入列數與記帳數對得上（入列 %d／記帳 %d）" % [int(a["queued"]), a["log"].size()],
		int(a["queued"]) == a["log"].size())
	var b: Dictionary = _run(_plan_from_log(a["log"]))
	print("  fp(原跑)=%s" % String(a["fp"]))
	print("  fp(重播)=%s" % String(b["fp"]))
	_check("★★★final_fp 逐字相同", String(a["fp"]) == String(b["fp"]))
	_cell("_test_replay_same_fp")


# ══════════ P2 的負對照：把一條指令移到【跨過一個小時／一天邊界】⇒ fp 必須不同 ══════════
# ★★★為什麼不用 ±1 tick（R② 訂正）：同一小時內位移一格，很可能逐字相同
#   ⇒ 負對照【恆綠】，而那種綠讀起來就是「重播有效」。
# ★★跨邊界則【母體選擇本身帶保證】：day_boundary 上 check_starvation_deaths／
#   flush_forage_episodes／訊息剪枝本來就在動東西，hour 上有 NEAR_CADENCE 的到期檢查
#   ⇒ 前後【保證】有世界差異，不是「可能有」。
func _test_negative_boundary_shift() -> void:
	print("\n── P2-負 指令跨過小時邊界 ⇒ fp 必須不同 ──")
	var probe: Array = _fresh()
	var plan: Array = _script_for(probe[0])
	if plan.is_empty():
		_errors += 1
		print("  ★[不可判] 造不出指令串 ⇒ 這不是綠")
		_cell("_test_negative_boundary_shift")
		return
	var base: Dictionary = _run(plan)
	var shifted: Array = []
	var moved: int = -1
	for i in range(plan.size()):
		var c: Dictionary = (plan[i] as Dictionary).duplicate(true)
		if i == 0:
			var at: int = int(c["at"])
			# ★推到【下一個整點之後】：保證跨過一個 hour 邊界，而不是同一小時內挪動
			var next_hour: int = (at / HOUR + 1) * HOUR
			c["at"] = next_hour + 1
			moved = int(c["at"]) - at
		shifted.append(c)
	_check("★母體地板：真的位移了（%d tick，且跨過整點）" % moved, moved > 0)
	var s: Dictionary = _run(shifted)
	print("  fp(原)  =%s" % String(base["fp"]))
	print("  fp(位移)=%s" % String(s["fp"]))
	_check("★★★跨邊界位移之後 fp【不同】—— 相同的話這支床測不到任何東西",
		String(base["fp"]) != String(s["fp"]))
	_cell("_test_negative_boundary_shift")


# ══════════ P1［佇列］入列之後、推進之前，世界【沒有】改變 ══════════
func _test_queue_defers() -> void:
	print("\n── P1 入列 ≠ 生效 ──")
	var pair: Array = _fresh()
	var st: WorldState = pair[0]
	var runner: SimRunner = pair[1]
	var plan: Array = _script_for(st)
	if plan.is_empty():
		_errors += 1
		print("  ★[不可判] 造不出指令串 ⇒ 這不是綠")
		_cell("_test_queue_defers")
		return
	var before: String = StateFingerprint.compute(st)
	var c: Dictionary = plan[0]
	st.command_seq += 1
	st.pending_commands.append({"name": String(c["name"]), "args": c["args"], "seq": st.command_seq})
	var after_queue: String = StateFingerprint.compute(st)
	# ★★★誠實限（我自己查出來的，不寫的話這一格會被讀得比它強）：
	#   `pending_commands`／`command_seq`／`command_log`／`command_results` 四個新欄位
	#   【都不在 StateFingerprint 的涵蓋範圍內】（`_emit_player` 沒有它們）
	#   ⇒ ★「入列之後指紋未變」有一半是【由構造保證】的，不是這一格測出來的。
	#   ⇒ ★★它仍然抓得到一件事：入列的動作【順手改到別的世界狀態】。
	#   ⇒ ★★★而「佇列該不該進指紋」是憲法層的問題（全量暫態可觀測性 vs spec P6
	#     要求 world-fp 逐字不變），已呈報 systems，不在這支床自己決定。
	_check("★入列之後、推進之前：世界指紋未變（★見上方誠實限：佇列本身不在指紋裡）",
		before == after_queue)
	_check("★★母體地板：佇列裡真的有一條（%d）" % st.pending_commands.size(),
		st.pending_commands.size() == 1)
	runner.advance_tick(st, Vector2i(-1, -1))
	_check("★★★推進一個 tick 之後：佇列已清空", st.pending_commands.is_empty())
	_check("而它進了帳（command_log %d 條）" % st.command_log.size(), st.command_log.size() == 1)
	if st.command_log.size() == 1:
		var e: Dictionary = st.command_log[0]
		_check("★記的 tick ＝ 遞增【之後】的值（%d，而入列時是 0）" % int(e.get("tick", -1)),
			int(e.get("tick", -1)) == 1)
	_cell("_test_queue_defers")


func _initialize() -> void:
	print("=== 玩家指令重播床（seed=%d config=%s ticks=%d）===" % [
		_seed_of(), _cfg_of(), _ticks_of()])
	_test_queue_defers()
	_test_replay_same_fp()
	_test_negative_boundary_shift()
	_test_p9_enqueue_echo()
	_test_p10_result_lines()
	_test_p12_reject_comes_late()
	_test_p13_queries_are_pure()
	_test_p13b_confirm_has_a_landing_point()
	_test_p14_reading_does_not_change_the_world()
	_test_p14b_results_expire_by_tick()
	var missing: Array = []
	for c in EXPECTED_CELLS:
		if not _cells_ran.has(c):
			missing.append(c)
	if not missing.is_empty():
		_errors += 1
		print("[roll-call] ❌ ★有格沒有跑完：%s —— 執行期錯誤會靜默中止一支 func，而那看起來像綠" % str(missing))
	print("=== command_replay DONE === errors: %d｜到場點名 %d／%d" % [
		_errors, _cells_ran.size(), EXPECTED_CELLS.size()])
	quit(1 if _errors > 0 else 0)


# ══════════ P9［入列有回音］（spec §3-5①，blueprint 裁 (乙)）══════════
# ★母體地板：那句話必須含【動作】—— 只印「已排入」等於沒說，而它會恆綠。
func _test_p9_enqueue_echo() -> void:
	print("
── P9 入列有回音 ──")
	var pair: Array = _fresh()
	var st: WorldState = pair[0]
	var bridge := SimBridge.new(pair[1], st)
	var r: Dictionary = bridge.command_player("move_to", {"tile_q": 3, "tile_r": 4})
	var msg: String = String(r.get("message", ""))
	print("  回音：「%s」" % msg)
	_check("回了 queued", bool(r.get("queued", false)))
	_check("★有回音（message 非空）", msg != "")
	_check("★★母體地板：回音含【動作】而不只是「已排入」（找「移動」）", msg.contains("移動"))
	_check("★★★而它含【參數】—— 否則兩條不同的指令回同一句話", msg.contains("3") and msg.contains("4"))
	_cell("_test_p9_enqueue_echo")


# ══════════ P10［消費點必回結果句］══════════
# ★★★這一格最容易恆綠：母體地板要求那一輪【同時】有①會成功②會被拒絕的指令 ——
#   沒有②的話，「拒絕禁靜默」是一句【對空集合為真】的話。
func _test_p10_result_lines() -> void:
	print("
── P10 消費點必回結果句（成功＋拒絕都要有）──")
	var pair: Array = _fresh()
	var st: WorldState = pair[0]
	var runner: SimRunner = pair[1]
	var bridge := SimBridge.new(runner, st)
	var plan: Array = _script_for(st)
	if plan.is_empty():
		_errors += 1
		print("  ★[不可判] 造不出會成功的指令 ⇒ 這不是綠")
		_cell("_test_p10_result_lines")
		return
	bridge.command_player("move_to", (plan[0] as Dictionary)["args"])          # 應成功
	bridge.command_player("move_to", {"tile_q": BAD_TILE.x, "tile_r": BAD_TILE.y})  # 應被拒
	runner.advance_tick(st, Vector2i(-1, -1))
	var ok_n: int = 0
	var bad_n: int = 0
	for r in st.command_results:
		if bool(r.get("ok", false)): ok_n += 1
		else: bad_n += 1
		print("  「%s」" % String(r.get("text", "")))
	_check("★★★母體地板：這一輪【同時】有成功（%d）與被拒（%d）" % [ok_n, bad_n],
		ok_n >= 1 and bad_n >= 1)
	_check("結果句數 ＝ 指令數（%d／2）" % st.command_results.size(), st.command_results.size() == 2)
	var has_reason: bool = false
	for r in st.command_results:
		if not bool(r.get("ok", false)):
			var t: String = String(r.get("text", ""))
			has_reason = t.contains("被拒絕") and not t.contains("沒有給原因")
	_check("★拒絕那一句【帶原因】（不是「沒有給原因」）", has_reason)
	_cell("_test_p10_result_lines")


# ══════════ P12［拒絕要晚到］══════════
# ★★★這一格專門擋「順手把 `_check_*` 提前到入列」＝ (丁) 從後門回來。
#   ★格式對、世界不允許的指令：入列當下【必須】回「已排入」，到消費點才被拒。
func _test_p12_reject_comes_late() -> void:
	print("
── P12 拒絕要晚到（擋 (丁) 從後門回來）──")
	var pair: Array = _fresh()
	var st: WorldState = pair[0]
	var runner: SimRunner = pair[1]
	var bridge := SimBridge.new(runner, st)
	var before: String = StateFingerprint.compute(st)
	var r: Dictionary = bridge.command_player("move_to", {"tile_q": BAD_TILE.x, "tile_r": BAD_TILE.y})
	_check("★入列當下回 ok=true（不在這裡判合法性）", bool(r.get("ok", false)))
	_check("★★入列當下【沒有】結果句", st.command_results.is_empty())
	_check("★★★而世界也沒變（指紋相同）", StateFingerprint.compute(st) == before)
	runner.advance_tick(st, Vector2i(-1, -1))
	_check("推進一 tick 後才出現結果句（%d 句）" % st.command_results.size(),
		st.command_results.size() == 1)
	if st.command_results.size() == 1:
		_check("★而那一句是【拒絕】", not bool(st.command_results[0].get("ok", true)))
	_check("★★母體地板：那條指令真的進了帳（command_log %d）" % st.command_log.size(),
		st.command_log.size() == 1)
	_cell("_test_p12_reject_comes_late")


# ══════════ P13［被分類為查詢的端點，真的不寫］（systems 立 2026-09-23）══════════
# ★★★為什麼要有這一格：我用【靜態掃描】宣告過「這兩支純讀」，而那個掃描器
#   在同一天錯了三次，★三次都往同一個方向錯（全部是假的「這支不寫」）。
#   ⇒ ★★靜態只負責【縮小範圍】，兜底一定是經驗層 —— 同「未加種子的閘床」那個兩層判準。
# ★做法：同一個世界連呼 5 次 ⇒ world-fp 逐字不變。
#   ★★母體地板：至少一支要真的回 ok=true —— 全部早退的話，「不寫」是一句
#     【對什麼都沒做的東西為真】的話。
#   ★★★負對照：呼一支【會寫】的（_action_trade 寫 player_state["pending_trade_target"]，
#     而那一欄在 StateFingerprint._emit_player 的涵蓋範圍內）⇒ fp 必須【不同】。
#     ★沒有這個負對照的話，一個【根本不看 player_state】的 fp 也會讓上面那格恆綠。
func _test_p13_queries_are_pure() -> void:
	print("
── P13 查詢端點不得有副作用 ──")
	var pair: Array = _fresh()
	var st: WorldState = pair[0]
	var bridge := SimBridge.new(pair[1], st)
	if st.player_id < 0 or not st.persons.has(st.player_id):
		_errors += 1
		print("  ★[不可判] 沒有玩家 ⇒ 這不是綠")
		_cell("_test_p13_queries_are_pure")
		return
	var ptid: int = int(st.persons[st.player_id].team_id)
	# 找一個真的能讓查詢回 ok 的目標（★不是隨便挑一個然後讓它早退）
	var target: int = -1
	var which: String = ""
	for tid in st.teams.keys():
		if int(tid) == ptid: continue
		if bool(bridge.query_inquiry_options(int(tid)).get("ok", false)):
			target = int(tid); which = "打聽"; break
		if bool(bridge.query_recruit_menu(int(tid)).get("ok", false)):
			target = int(tid); which = "招募"; break
	_check("★★母體地板：找得到一個讓查詢真的回 ok 的目標（%s Team%d）" % [which, target], target >= 0)
	if target < 0:
		print("  ⇒ ★全部早退 ⇒ 「不寫」會是一句對空集合為真的話 ⇒ 不可判")
		_cell("_test_p13_queries_are_pure")
		return
	var before: String = StateFingerprint.compute(st)
	for _i in range(5):
		bridge.query_inquiry_options(target)
		bridge.query_recruit_menu(target)
	_check("★★★同一個世界連呼 5 次（兩支各 5 次）⇒ world-fp 逐字不變",
		StateFingerprint.compute(st) == before)
	# ★負對照：呼一支會寫的，fp 必須動
	var sys := PlayerCommandSystem.new()
	var pt: TeamData = st.teams[ptid]
	var fp_mid: String = StateFingerprint.compute(st)
	for _i in range(5):
		sys._action_trade(st, target, pt, ptid)
	_check("★負對照：呼 5 次【會寫的】_action_trade ⇒ fp 必須【不同】（否則這支 fp 看不見這種寫）",
		StateFingerprint.compute(st) != fp_mid)
	_cell("_test_p13_queries_are_pure")


# ══════════ P13b［指令層有沒有落點］（systems 加 2026-09-23）══════════
# ★★★blueprint 把「打聽」拆成兩層：開選單＝查詢（免費）／真去問人＝指令（可有成本）。
#   我做的正好對上（`_action_gather_intel` 走查詢、`confirm_gather_intel` 進佇列）。
# ★而這一格問的是【另一個問題】：那個「指令層」今天在 code 裡【有沒有落點】？
#   ⇒ 做法：連呼 `confirm_gather_intel` 5 次，看 world-fp 動不動。
#   ★★這一格【不是紅綠】——兩種結果都是事實，都要印出來：
#     fp 變了  ⇒ 指令層有落點（它真的動了世界）
#     fp 不變  ⇒ ★★★指令層【今天還沒有落點】—— 那是要回報 blueprint 的事實，
#              不是我要順手補的東西（補它＝替 WHAT 決定「打聽要付什麼代價」）。
func _test_p13b_confirm_has_a_landing_point() -> void:
	print("
── P13b 指令層（confirm_gather_intel）有沒有落點 ──")
	var pair: Array = _fresh()
	var st: WorldState = pair[0]
	var bridge := SimBridge.new(pair[1], st)
	if st.player_id < 0 or not st.persons.has(st.player_id):
		_errors += 1
		print("  ★[不可判] 沒有玩家")
		_cell("_test_p13b_confirm_has_a_landing_point")
		return
	var ptid: int = int(st.persons[st.player_id].team_id)
	var pt: TeamData = st.teams[ptid]
	var target: int = -1
	var choice: String = ""
	for tid in st.teams.keys():
		if int(tid) == ptid: continue
		var q: Dictionary = bridge.query_inquiry_options(int(tid))
		var opts: Array = q.get("data", {}).get("inquiry_options", [])
		if bool(q.get("ok", false)) and not opts.is_empty():
			target = int(tid)
			choice = String((opts[0] as Dictionary).get("id", ""))
			break
	_check("★★母體地板：找得到一個有可打聽選項的目標（Team%d 選項「%s」）" % [target, choice],
		target >= 0 and choice != "")
	if target < 0 or choice == "":
		print("  ⇒ 沒有可打聽的對象 ⇒ 這一格【不可判】，不是「沒有落點」")
		_cell("_test_p13b_confirm_has_a_landing_point")
		return
	# ★設參數【之後】才取基準 —— player_state 本身在 canon 裡，設它會動 fp
	st.player_state["gather_intel_npc_id"] = target
	st.player_state["gather_intel_choice"] = choice
	var sys := PlayerCommandSystem.new()
	var before: String = StateFingerprint.compute(st)
	var ok_n: int = 0
	for _i in range(5):
		if bool(sys._action_confirm_gather_intel(st, target, pt, ptid).get("ok", false)):
			ok_n += 1
	var after: String = StateFingerprint.compute(st)
	_check("★母體地板：那 5 次真的執行成功（%d／5）—— 全失敗的話下面那句沒有主詞" % ok_n, ok_n == 5)
	if after != before:
		print("  ⇒ ★fp 變了 ⇒ 【指令層有落點】：confirm_gather_intel 真的動了世界")
	else:
		print("  ⇒ ★★★fp 【不變】 ⇒ 指令層今天在 code 裡【還沒有落點】——")
		print("     打聽問完之後世界完全沒變（連「誰問過誰」都沒留下）。")
		print("     ★這是要回報 blueprint 的事實（他要的成本掛在這一層），不是這支床的紅燈，")
		print("     ★★也不是我順手補的東西 —— 補它等於替 WHAT 決定打聽要付什麼代價。")
	_cell("_test_p13b_confirm_has_a_landing_point")


# ══════════ P14［讀結果句不得改變世界］（systems 裁 2026-09-23）══════════
# ★★★他要的那句話是「同一顆種子，有 UI 跑與 headless 跑，fp 逐字相同」。
#   ★我改成【等價而且可判】的形狀，理由寫在這裡不藏起來：
#     兩支不同的 entry point 會各自建自己的世界，「同一顆種子」也保證不了兩邊
#     跑的是同一棵樹（TextUI 自己載 config）⇒ 那個比對的主詞會很模糊。
#   ⇒ ★★這裡改成【直接測那個性質】：同一個世界，讀 5 次 ⇒ fp 逐字不變。
#     那正是「有沒有人在看不得改變世界」，而且主詞只有一個。
#   ★★★負對照不可少：做一次【破壞性排空】（＝修法前的舊行為）⇒ fp 必須變。
#     沒有它的話，一支【根本不把 command_results 放進 fp】的指紋也會讓上面那格恆綠。
func _test_p14_reading_does_not_change_the_world() -> void:
	print("
── P14 讀結果句不得改變世界 ──")
	var pair: Array = _fresh()
	var st: WorldState = pair[0]
	var runner: SimRunner = pair[1]
	var bridge := SimBridge.new(runner, st)
	var plan: Array = _script_for(st)
	if plan.is_empty():
		_errors += 1
		print("  ★[不可判] 造不出指令串")
		_cell("_test_p14_reading_does_not_change_the_world")
		return
	bridge.command_player("move_to", (plan[0] as Dictionary)["args"])
	bridge.command_player("move_to", {"tile_q": BAD_TILE.x, "tile_r": BAD_TILE.y})
	runner.advance_tick(st, Vector2i(-1, -1))
	_check("★★母體地板：真的有結果句可以讀（%d 句）—— 0 句的話「讀不改變」恆真"
		% st.command_results.size(), st.command_results.size() >= 2)
	var before: String = StateFingerprint.compute(st)
	for _i in range(5):
		bridge.read_command_results()
	_check("★★★讀 5 次 ⇒ world-fp 逐字不變", StateFingerprint.compute(st) == before)
	# ★負對照：修法前的舊行為（破壞性排空）
	var fp_mid: String = StateFingerprint.compute(st)
	st.command_results = []
	_check("★負對照：做一次破壞性排空（＝修法前的行為）⇒ fp 必須【不同】",
		StateFingerprint.compute(st) != fp_mid)
	_cell("_test_p14_reading_does_not_change_the_world")


# ══════════ P14b［結果句依 tick 過期，不依「有沒有人讀」］══════════
# ★存活上界取 TICKS_PER_HOUR ＝ 一次 `tick_step()` 的上界
#   ⇒ ★★任何【每個 step 讀一次】的觀察者都看得到全部（拒絕禁靜默不被這條規矩吃掉）。
func _test_p14b_results_expire_by_tick() -> void:
	print("
── P14b 結果句依 tick 過期 ──")
	var pair: Array = _fresh()
	var st: WorldState = pair[0]
	var runner: SimRunner = pair[1]
	var bridge := SimBridge.new(runner, st)
	bridge.command_player("move_to", {"tile_q": BAD_TILE.x, "tile_r": BAD_TILE.y})
	runner.advance_tick(st, Vector2i(-1, -1))
	_check("★母體地板：產生了結果句（%d）" % st.command_results.size(), st.command_results.size() == 1)
	# ★★★兩邊都從【各自的具名常數】讀（systems 要的那一行）——
	#   哪天有人為了效能把 `SimBridge.STEP_TICK_BOUND` 改成 `TICKS_PER_HOUR * 2`，
	#   這一行會紅，而【畫面不會靜靜地少講話】。
	#   ★不是拿 TICKS_PER_HOUR 跟 TICKS_PER_HOUR 比：那樣改上界不會有東西紅。
	_check("★★★結果存活 %d tick ≥ 一次 step 的上界 %d tick" % [
		SimRunner.RESULT_TTL_TICKS, SimBridge.STEP_TICK_BOUND],
		SimRunner.RESULT_TTL_TICKS >= SimBridge.STEP_TICK_BOUND)
	# ★★沒有人讀，只是讓世界走 —— 走【不到】一小時：必須還在
	for _i in range(WorldState.TICKS_PER_HOUR - 2):
		runner.advance_tick(st, Vector2i(-1, -1))
	_check("★★走了不到一小時、而且【沒有人讀過】⇒ 結果句還在（%d）"
		% st.command_results.size(), st.command_results.size() == 1)
	for _i in range(4):
		runner.advance_tick(st, Vector2i(-1, -1))
	_check("★★★走過一小時 ⇒ 它自己過期了（%d）—— 清除是世界的函數，不是觀眾的函數"
		% st.command_results.size(), st.command_results.is_empty())
	_cell("_test_p14b_results_expire_by_tick")
