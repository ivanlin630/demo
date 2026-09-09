extends SceneTree
# @bed-kind: acceptance
# slice: player_* 進 fp ＝【免費崗哨】
#
# ★裁定的理由與直覺相反：不是「玩家會影響 sim」，是【sim 不該碰 player_*】
#   ⇒ 兩顆【無玩家】的 seeded 跑若在 player_* 段上分岔 ⇒ 有系統偷碰玩家欄，當場現形。
# ★★所以主格不是「fp 變了」，是【無玩家跑裡 player_* 恆為初始值】。
# ★★★而 spec 要求交件寫明【哨兵看到哪一層】：頂層 10 欄；dict 走排序後的鍵＋值（內部鍵看得到）、
#   巢狀第二層以下只走 str()（形狀變看得到，浮點細節不保證）。

var _fails: int = 0
var _sections: int = 0
const EXPECT_SECTIONS: int = 5

func _initialize() -> void:
	print("=== player_* 哨兵床 ===")
	_test_no_player_run_is_pristine()
	_test_sentinel_detects_a_write()
	_test_randi_shares_global_stream()
	_test_player_run_reproducible()
	_test_blind_note_no_longer_lists_player()
	if _sections != EXPECT_SECTIONS:
		_fails += 1
		push_error("[FAIL] 只跑完 %d/%d 段 —— 中途崩掉" % [_sections, EXPECT_SECTIONS])
	print("=== DONE === SECTIONS=%d/%d FAILS=%d" % [_sections, EXPECT_SECTIONS, _fails])
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_fails += 1
		push_error("[FAIL] " + msg)

var _post_setup_section: String = ""

func _run(ticks: int, strip_player: bool) -> WorldState:
	seed(1337)
	var st := WorldState.new()
	GameSetup.setup(st, GameSetup.load_config("res://config/warring_states.json"))
	if strip_player:
		st.player_id = -1   # ★無玩家跑（觀察者）：哨兵要驗的正是這一種
	# ★★基準線是【setup 之後、跑 tick 之前】那一刻，不是 WorldState.new()：
	#   ★★★第一次跑時我拿 new() 當基準，哨兵立刻「抓到」一個差異 —— 而那個差異是
	#   【setup 自己寫的 player_state{coin=50,inventory=[]}】，不是 tick 裡有人偷碰。
	#   ⇒ 基準線選錯 ＝ 哨兵的第一份報告是假陽性，而它看起來跟真陽性一模一樣。
	_post_setup_section = StateFingerprint.player_section(st)
	var runner := SimRunner.new()
	for _t in range(ticks):
		runner.advance_tick(st, Vector2i(-1, -1))
	return st

func _test_no_player_run_is_pristine() -> void:
	print("-- ① 無玩家跑：player_* 必須恆為初始值 --")
	var a := _run(300, true)
	var pristine: String = _post_setup_section   # ★setup 完、tick 之前那一刻
	var b := _run(300, true)
	var sa: String = StateFingerprint.player_section(a)
	print("    跑完的 player 段：%s" % sa.replace("\n", " ｜ "))
	print("    setup 之後（基準線）：%s" % pristine.replace("\n", " ｜ "))
	_ok(StateFingerprint.compute(a) == StateFingerprint.compute(b), "①兩顆同 seed 無玩家跑 fp 相同")
	_ok(sa == StateFingerprint.player_section(b), "①兩顆的 player 段也相同")
	if sa == pristine:
		_ok(true, "①★player 段 ＝ 初始值 ⇒ 300 tick 內【沒有任何系統碰過玩家欄】")
	else:
		# ★這不是床壞了，是【哨兵抓到東西】—— 而 spec §④② 說：發現要列進交件、不順手修
		print("    ★★哨兵抓到差異！初始值：%s" % pristine.replace("\n", " ｜ "))
		_ok(false, "①★★哨兵在無玩家跑的【tick 期間】抓到 player_* 被寫過 ⇒ 這是【發現】，列進交件另票修")
	_sections += 1

func _test_sentinel_detects_a_write() -> void:
	print("-- ② 成對對照：哨兵真的看得見一次偷寫（★沒有這格，①的綠證明不了哨兵有裝上）--")
	var st := WorldState.new()
	st.world = WorldData.new()
	var base: String = StateFingerprint.compute(st)
	var base_sec: String = StateFingerprint.player_section(st)
	# 模擬「某個系統在無玩家世界裡對玩家說話」——正是被 gate 擋住的那種寫入
	st.player_forced_event = {"from_id": 9, "action": "diplomacy"}
	st.player_forced_event_id = "123_456"
	_ok(StateFingerprint.player_section(st) != base_sec, "②寫 player_forced_event ⇒ player 段【變】")
	_ok(StateFingerprint.compute(st) != base, "②而整份 fp 也跟著變（哨兵真的掛在 canon 上）")
	# ★另一半：不得亂紅 —— 動一個【不是 player_*】的東西，player 段不得變
	var st2 := WorldState.new()
	st2.world = WorldData.new()
	var sec2: String = StateFingerprint.player_section(st2)
	var t := TeamData.new()
	t.team_id = 1
	st2.teams[1] = t
	_ok(StateFingerprint.player_section(st2) == sec2, "②★另一半：加一支隊 ⇒ player 段不動（不亂紅）")
	# ★★粒度：dict 的【內部鍵】也看得到（交件要寫明它看到哪一層）
	var st3 := WorldState.new()
	st3.world = WorldData.new()
	st3.player_state = {"a": 1}
	var s3: String = StateFingerprint.player_section(st3)
	st3.player_state["a"] = 2
	_ok(StateFingerprint.player_section(st3) != s3, "②★粒度：player_state 這個 dict 的【內部鍵值】改動看得到")
	_sections += 1

func _test_randi_shares_global_stream() -> void:
	print("-- ③ RNG：randi() 走的是不是【全域流】（★spec 標未驗，我順手驗）--")
	seed(4242)
	var x1: float = randf()
	seed(4242)
	randi()               # ★中間插一發 randi
	var x2: float = randf()
	print("    seed 相同：直接 randf=%.6f｜先 randi 再 randf=%.6f" % [x1, x2])
	_ok(abs(x1 - x2) > 1e-9,
		"③randi() 消耗的是【同一條全域流】⇒ 沒被 gate 住的 str(randi()) 會讓整條世界位移（比多寫一欄嚴重一級）")
	seed(4242)
	var y1: float = randf()
	seed(4242)
	var y2: float = randf()
	_ok(abs(y1 - y2) < 1e-12, "③★對照：不插 randi 時同 seed 兩次 randf 相同（證明上一格的差來自 randi 不是雜訊）")
	_sections += 1

func _test_player_run_reproducible() -> void:
	print("-- ④ 有玩家的跑：同 seed 同操作 ⇒ 同 fp；不同操作 ⇒ 不同 fp（後者是對的，不是 bug）--")
	var a := _run(120, false)
	var b := _run(120, false)
	_ok(StateFingerprint.compute(a) == StateFingerprint.compute(b), "④有玩家的跑仍可重現")
	# 不同操作：對 a 下一個玩家動作（改 player_state）⇒ fp 必須不同
	var fa: String = StateFingerprint.compute(a)
	a.player_state["last_cmd"] = "advance"
	_ok(StateFingerprint.compute(a) != fa, "④★玩家操作 ⇒ fp 不同（★這是哨兵的定義，不是漂移）")
	_sections += 1

func _test_blind_note_no_longer_lists_player() -> void:
	print("-- ⑥ 上一張票的紅利：導出的排除清單自己會跟著變 --")
	var d: Array = StateFingerprint.derived_excludes()
	var still: Array = []
	for n in d:
		if String(n).begins_with("player_"):
			still.append(n)
	print("    排除清單裡剩下的 player_*：%s（總排除 %d 欄）" % [str(still), d.size()])
	_ok(still.is_empty(), "⑥排除清單裡不再有任何 player_*（★沒有手動維護那一行，它自己跟著變）")
	_sections += 1
