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
	"_test_p14_reading_does_not_change_the_world", "_test_p14b_results_expire_by_tick",
	"_test_p16_frozen_world_still_answers"]


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
		# ★鍵是 `q*1000 + r`，而且掛在 `world` 底下（sim_bridge.gd:137 是同一份真相）
		#   ★★我原本寫 `st.tiles.has(Vector2i)` —— 那是我【假設】的形狀，實跑丟
		#     `Invalid get index 'tiles'` 五次，把 `_script_for()` 整支砍斷 ⇒ 五格判【不可判】。
		if not st.world.tiles.has(t.x * 1000 + t.y):
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

# ★★★(丁) 落地之後 `PQ|` 進了 fp ⇒ 「入列之後指紋不變」這句話【從今天起是假的】。
#   ★修法不是刪掉那個斷言（那是反方向的空真），是把它【分成三句】：
#     ①世界本體沒變 ②玩家段除了 PQ| 之外逐字沒變 ③★而 PQ| 那一行【確實變了】
#   ★★沒有③的話，①②對「佇列根本沒被記錄進 fp」也同樣成立。
#   ★★★這兩格是我拿 systems 那條新規矩（比較的兩邊必須能各自獨立地改變）
#     回頭掃自己今天寫的每一格時抓到的 —— 一張票的裁定弄壞了另一張票的斷言，而它不會自己喊。
func _pq_line(st: WorldState) -> String:
	for l in StateFingerprint.player_section(st).split(String.chr(10)):
		if l.begins_with("PQ|"):
			return l
	return "（沒有 PQ| 行）"

func _player_section_sans_queue(st: WorldState) -> String:
	var keep: PackedStringArray = PackedStringArray()
	for l in StateFingerprint.player_section(st).split(String.chr(10)):
		if not l.begins_with("PQ|"):
			keep.append(l)
	return String.chr(10).join(keep)

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
		# ★★★位移【最後一條】不是第一條（2026-09-24 實測訂正）：
		#   第一版位移第 0 條 ⇒ fp【相同】⇒ 這一格紅了。我沒有猜，我量了：
		#   改成位移最後一條 ⇒ fp 不同（fc2110c9… vs e516b8c2…）⇒ 差別不在「重播壞掉」，
		#   ★在於每條 `move_to` 會【覆蓋前一條的目標】⇒ 第一條的位移效果被後面五條抹掉。
		#   ⇒ ★★而被斷言的量是【終局 fp】：第 0 條的 tick 根本活不到那裡。
		#   ⇒ ★★★同一條規矩第三次：**對照要擾動的是【被斷言的那個量】，不是它附近的量。**
		#     最後一條是有原則的選擇 —— 沒有任何後續指令可以覆蓋它。
		if i == plan.size() - 1:
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
	var dom_before: Dictionary = StateFingerprint.compute_domains(st)
	var ps_before: String = _player_section_sans_queue(st)
	var pq_before: String = _pq_line(st)
	var c: Dictionary = plan[0]
	st.command_seq += 1
	st.pending_commands.append({"name": String(c["name"]), "args": c["args"], "seq": st.command_seq})
	var after_queue: String = StateFingerprint.compute(st)
	# ★★★這段原本是一條誠實限：「四個新欄位都不在 fp 裡，所以『入列後指紋未變』
	#   有一半是由構造保證的」。★★它【已經過期】—— systems 2026-09-23 裁定佇列進 fp
	#   （`PQ|` 另起一行）⇒ 入列【會】改變整體指紋。
	#   ⇒ ★留著這段字比刪掉危險：它會讓下一個人以為下面那幾格在測別的東西。
	#   ⇒ ★★★而過期的不是那條限制本身，是它描述的世界 —— 改了 fp 就要回頭改讀它的人。
	_check("★世界本體（非玩家段）逐字未變",
		str(dom_before) == str(StateFingerprint.compute_domains(st)))
	_check("★★玩家段【除了 PQ| 那一行】逐字未變", ps_before == _player_section_sans_queue(st))
	_check("★★★而 PQ| 那一行【確實變了】—— 沒有這一格的話，上面兩格對「佇列根本沒被記錄進 fp」也成立",
		pq_before != _pq_line(st))
	_check("（整體指紋因此【應該】不同：入列是世界狀態的改變）", before != after_queue)
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
	_test_p16_frozen_world_still_answers()
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
# ★★★母體從 1 換成【真的母體】（systems 2026-09-23）：原本只驗 `move_to` 一條，
#   ⇒ 它的母體是 1，而真正的母體是 `dispatch()` 白名單裡的【每一個 name】。
#   ★病是真的：VERB 漏一個 name ⇒ `describe()` 回英文 id ⇒ 玩家看到 "post_buy_order"。
#   ★★而判準【不能】寫成「回音不得含 ascii 識別字」—— `掛買單 food×3` 的 `food`
#     就是 ascii 識別字 ⇒ 那樣會誤紅（我第一版就是這樣寫的）。
#   ⇒ ★★★改成【異源比對】：左＝從 `player_command_api.gd` 的 `dispatch()` 原始碼抽出的 match 名單，
#     右＝`VERB` 這個常數。兩邊各自能改變 ⇒ 漏一個就會紅。
#   ★另外逐 name 驗一次「回音不含它自己的英文 id」—— 那是 describe() 掉到 fallback 的長相。
# 負對照：讓 `describe("move_to")` 回一句【固定】而且含 3 含 4 的話（如「移動（第34筆）」） ⇒ ★舊判準 `contains("3") and contains("4")` 會【綠】、新判準才紅 ⇒ 已於 feat/cursor-hover-truth（2026-09-24 這一輪） 實測紅
func _test_p9_enqueue_echo() -> void:
	print("
── P9 入列有回音（母體＝dispatch 白名單全部）──")
	var f := FileAccess.open("res://scripts/simulation/player_command_api.gd", FileAccess.READ)
	if f == null:
		_errors += 1
		print("  ★[不可判] 讀不到 player_command_api.gd")
		_cell("_test_p9_enqueue_echo")
		return
	var src: String = f.get_as_text()
	f.close()
	# 取 dispatch() 的函式體，再抽 `"name":` 那些 match 分支
	var at: int = src.find("func dispatch(")
	var names: Array = []
	if at != -1:
		var body: String = src.substr(at)
		var rx := RegEx.new()
		rx.compile('^		"([a-z_]+)":')
		for line in body.split(String.chr(10)):
			if line.begins_with("func ") and not line.begins_with("func dispatch("):
				break
			var m := rx.search(line)
			if m != null and not names.has(m.get_string(1)):
				names.append(m.get_string(1))
	# ★母體地板：跟【外部期望】比，不是跟自己抽到的陣列比
	#   spec §3-3 說 12、我數出 13、加了 refresh_targets 之後是 14 ⇒ 下限釘 10，抽不到就是抽壞了
	_check("★★母體地板：從 dispatch() 原始碼抽到 %d 個 name（下限 10；抽 0 個＝正則壞了不是沒有指令）"
		% names.size(), names.size() >= 10)
	if names.size() < 10:
		_cell("_test_p9_enqueue_echo")
		return
	# ①每一個可派送的 name 都要有【人話】
	var missing: Array = []
	for n in names:
		if not PlayerCommandApi.VERB.has(n):
			missing.append(n)
	for n in missing: print("    ✗ VERB 沒有「%s」⇒ 玩家會看到英文 id" % String(n))
	_check("★★★dispatch 的每一個 name 在 VERB 裡都有人話（缺 %d 個）" % missing.size(),
		missing.is_empty())
	# ②逐 name 驗回音不含它自己的英文 id（＝describe 掉到 fallback 的長相）
	var fellback: Array = []
	for n in names:
		var d: String = PlayerCommandApi.describe(String(n), {})
		if d.contains(String(n)):
			fellback.append("%s ⇒ 「%s」" % [String(n), d])
	for x in fellback: print("    ✗ %s" % String(x))
	_check("★逐 name：回音不含它自己的英文 id（%d 個掉到 fallback）" % fellback.size(),
		fellback.is_empty())
	# ③真的送一條，驗回音的形狀（含動作、含參數）
	var pair: Array = _fresh()
	var st: WorldState = pair[0]
	var bridge := SimBridge.new(pair[1], st)
	var r: Dictionary = bridge.command_player("move_to", {"tile_q": 3, "tile_r": 4})
	var msg: String = String(r.get("message", ""))
	print("  回音樣本：「%s」" % msg)
	_check("回了 queued", bool(r.get("queued", false)))
	_check("★有回音（message 非空）", msg != "")
	_check("★★回音含【動作】而不只是「已排入」（找「移動」）", msg.contains("移動"))
	# ★★★這一句原本是 `msg.contains("3") and msg.contains("4")` —— 而它是【空的】：
	#   判準錨在「字串裡任何位置有 3 有 4」⇒ tick 號、筆數、id 都能餵飽它
	#   （「已排入第 34 筆」就綠了）⇒ ★它錨在【附帶線索】上，不是錨在被守的性質上。
	# ⇒ ★★換成【被守的性質本身】：兩條不同參數的指令，不准回同一句話。
	#   ★★★那個判準【不可能被附帶數字滿足】，而且【不依賴回音的措辭】——
	#     有人把文案整個改寫，它照樣測得出「兩條不同的指令分不分得出來」。
	var r2: Dictionary = bridge.command_player("move_to", {"tile_q": 5, "tile_r": 6})
	var msg2: String = String(r2.get("message", ""))
	print("  第二條（不同參數）：「%s」" % msg2)
	_check("★母體地板：第二條也真的入列了（否則兩句都空也會「不相同」不成立）",
		bool(r2.get("queued", false)) and msg2 != "")
	_check("★★★參數不同 ⇒ 回音【不相同】（(3,4) vs (5,6)）", msg != msg2)
	_cell("_test_p9_enqueue_echo")


# ══════════ P10［消費點必回結果句］══════════
# ★★★這一格最容易恆綠：母體地板要求那一輪【同時】有①會成功②會被拒絕的指令 ——
#   沒有②的話，「拒絕禁靜默」是一句【對空集合為真】的話。
# 負對照：只讓【第一筆】拒絕不帶「被拒絕」（`sim_runner` 那一行加 `if name == "move_to"` 分支） ⇒ ★舊的覆寫寫法只看最後一筆會【綠】、累積寫法紅（1／2） ⇒ 已於 feat/cursor-hover-truth（2026-09-24 這一輪） 實測紅
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
	bridge.command_player("move_to", {"tile_q": BAD_TILE.x, "tile_r": BAD_TILE.y})  # 應被拒①
	# ★★★第二筆拒絕是【刻意加的】，而理由是這一格自己的判準需要它：
	#   下面「被拒的每一筆都帶原因」在【只有一筆】被拒時，
	#   ★「累積」與「迴圈裡覆寫單一變數」會給出【一模一樣】的答案
	#   ⇒ 那條剛修好的判準【沒有守衛】。⇒ 母體要 ≥2 筆，那個修正才被守住。
	# ★★而它刻意用【不同種類】的拒絕（不是再送一條同型 move_to）：
	#   同型的第二條有可能被消費點視為「覆寫前一個目標」⇒ 那樣就不是兩筆拒絕。
	bridge.command_player("execute_action", {"action_id": "no_such_action_xyz"})     # 應被拒②
	runner.advance_tick(st, Vector2i(-1, -1))
	var ok_n: int = 0
	var bad_n: int = 0
	for r in st.command_results:
		if bool(r.get("ok", false)): ok_n += 1
		else: bad_n += 1
		print("  「%s」" % String(r.get("text", "")))
	_check("★★★母體地板：這一輪【同時】有成功（%d）與被拒（%d）" % [ok_n, bad_n],
		ok_n >= 1 and bad_n >= 1)
	_check("結果句數 ＝ 指令數（%d／3）" % st.command_results.size(), st.command_results.size() == 3)
	# ★★★這一段原本用【單一變數】在迴圈裡記結果 ⇒ 每一圈覆寫上一圈
	#   ⇒ 只有【最後一筆】被拒的算 ⇒ 兩筆拒絕而第一筆沒帶原因【也會綠】。
	#   ⇒ ★那是「迴圈裡的單一變數把母體塌成 1」：跑了 N 圈，判決只反映 1 圈。
	# ⇒ ★★改成【累積】：數被拒幾筆、數帶原因幾筆，兩個數都印出來再比。
	var rejected: int = 0
	var with_reason: int = 0
	for r in st.command_results:
		if not bool(r.get("ok", false)):
			rejected += 1
			var t: String = String(r.get("text", ""))
			if t.contains("被拒絕") and not t.contains("沒有給原因"):
				with_reason += 1
	print("  被拒 %d 筆，其中帶原因 %d 筆" % [rejected, with_reason])
	# ★★★母體地板：那一輪要【真的有】被拒的筆數 —— 0 筆的話「全都帶原因」恆真。
	# ★★★母體地板要求 ≥2：只有一筆的話，「累積」與「覆寫」給出同一個答案
	#   ⇒ 剛修好的那個累積寫法【不會被任何東西守住】。
	_check("★母體地板：這一輪有【至少兩筆】被拒（實測 %d 筆）" % rejected, rejected >= 2)
	_check("★★被拒的【每一筆】都帶原因（%d／%d）" % [with_reason, rejected],
		rejected >= 1 and with_reason == rejected)
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
	var dom0: Dictionary = StateFingerprint.compute_domains(st)
	var r: Dictionary = bridge.command_player("move_to", {"tile_q": BAD_TILE.x, "tile_r": BAD_TILE.y})
	_check("★入列當下回 ok=true（不在這裡判合法性）", bool(r.get("ok", false)))
	_check("★★入列當下【沒有】結果句", st.command_results.is_empty())
	_check("★★★而【世界本體】沒變（佇列以外一個字都沒動）",
		str(dom0) == str(StateFingerprint.compute_domains(st)))
	_check("★而整體指紋【變了】—— 因為佇列本身是世界狀態（(丁) 之後 PQ| 進了 fp）",
		StateFingerprint.compute(st) != before)
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


# ══════════ P16［凍結的世界也要回話，而且解得開］（systems 立 2026-09-24）══════════
# ★★★缺陷變對照：2026-09-24 第一次跑抓到死鎖 —— `game_over`／`choose_heir` 在
#   `_advance_tick_body()` 【被呼叫之前】就 return，而消費點在它裡面
#   ⇒ 凍結世界裡的每一條指令都被【靜默丟棄】，而唯一能解凍的那條也在裡面 ⇒ 永久卡住。
# ★而病不是死鎖，死鎖只是最尖的症狀：★★真正的病是【凍結分支不在消費點的母體裡】。
#   ⇒ 修了症狀而沒有守衛的話，下一次有人在 `_advance_tick_body` 之前再加一條 early return，
#     同樣的病會回來，★★★而它回來的樣子仍然是「玩家按了沒反應」——一個沒有任何東西會紅的症狀。
# ★母體地板：那一輪必須【真的處在凍結狀態】（斷言 advance_tick 回 "awaiting_heir"），
#   否則這一格會在一個從未凍結的世界上恆綠。
func _test_p16_frozen_world_still_answers() -> void:
	print("
── P16 凍結的世界也要回話，而且解得開 ──")
	var pair: Array = _fresh()
	var st: WorldState = pair[0]
	var runner: SimRunner = pair[1]
	var bridge := SimBridge.new(runner, st)
	if st.player_id < 0 or not st.persons.has(st.player_id):
		_errors += 1
		print("  ★[不可判] 沒有玩家")
		_cell("_test_p16_frozen_world_still_answers")
		return
	var ptid: int = int(st.persons[st.player_id].team_id)
	var pt: TeamData = st.teams[ptid]
	# 佈置：leader 已死、等待選繼承人（★沿用 ui_flow_test 既有的佈置形狀，不另造一份）
	var cands: Array = []
	for pid in pt.named_members:
		if pid != pt.leader_id:
			cands.append(pid)
		if cands.size() >= 2:
			break
	while cands.size() < 2:
		var np := PersonData.new()
		np.id = 91000 + cands.size()
		np.team_id = ptid
		np.person_name = "候選%d" % cands.size()
		st.persons[np.id] = np
		pt.named_members.append(np.id)
		cands.append(np.id)
	pt.leader_id = -1
	st.player_forced_event = {"action": "choose_heir", "team_id": ptid, "candidates": cands}
	st.player_forced_event_id = "heir-replay"
	# ★★母體地板：世界【真的】凍住了
	var r0: String = runner.advance_tick(st, Vector2i(-1, -1))
	_check("★★母體地板：世界真的處在凍結狀態（advance_tick 回「%s」）" % r0, r0 == "awaiting_heir")
	if r0 != "awaiting_heir":
		print("  ⇒ 沒有凍住 ⇒ 下面兩格會在一個【從未凍結的世界】上恆綠 ⇒ 不可判")
		_cell("_test_p16_frozen_world_still_answers")
		return
	# ①凍結時送一條【非解凍】指令 ⇒ 必須有回話，不是沉默
	st.command_results = []
	bridge.command_player("move_to", {"tile_q": BAD_TILE.x, "tile_r": BAD_TILE.y})
	var r1: String = runner.advance_tick(st, Vector2i(-1, -1))
	_check("★仍在凍結中（「%s」）" % r1, r1 == "awaiting_heir")
	for e in st.command_results:
		print("  凍結中的回話：「%s」" % String(e.get("text", "")))
	_check("★★★凍結時送指令【有回話】而不是沉默（%d 句）" % st.command_results.size(),
		st.command_results.size() >= 1)
	_check("★而它進了帳（command_log %d 條）" % st.command_log.size(), st.command_log.size() >= 1)
	# ②再送【解凍】指令 ⇒ 世界必須真的解凍
	bridge.command_player("respond_to_forced",
		{"interaction_id": "heir-replay", "response_id": "heir_%d" % int(cands[0])})
	# ★★★時點：凍結檢查在【消費之前】⇒ 消費的那一顆 tick【必然】仍回 awaiting_heir。
	#   ★我第一版就斷在那一顆上，而它紅了 —— 但同一行印出的 leader_id 已經換人了
	#     ⇒ 指令【有生效】，錯的是我的觀察時點，不是產品。
	#   ⇒ ★★所以要走兩顆：第一顆消費（世界在這一顆的開頭還是凍的），第二顆才觀察得到。
	#   ★★★而這一格因此同時守住兩件事：解凍要生效、而且【下一顆 tick 就要看得到】
	#     —— 不是「再過一小時自己好了」。
	var r2: String = runner.advance_tick(st, Vector2i(-1, -1))
	var heir_now: int = int(pt.leader_id)
	var r3: String = runner.advance_tick(st, Vector2i(-1, -1))
	print("  消費那一顆：「%s」｜leader_id=%d ⇒ 下一顆：「%s」" % [r2, heir_now, r3])
	_check("★消費的那一顆 tick 仍回 awaiting_heir（凍結檢查在消費之前）", r2 == "awaiting_heir")
	_check("★★繼承人【真的就位】（leader_id 從 -1 變成 %d）" % heir_now, heir_now == int(cands[0]))
	_check("★★★下一顆 tick 世界就解凍了（「%s」）" % r3, r3 != "awaiting_heir")
	_cell("_test_p16_frozen_world_still_answers")
