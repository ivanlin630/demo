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
const EXPECTED_CELLS: Array = ["_test_replay_same_fp", "_test_negative_boundary_shift", "_test_queue_defers"]


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
	_check("★入列之後、推進之前：世界指紋未變", before == after_queue)
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
