extends SceneTree
# @bed-kind: invariant
# slice: merge 檢查表第 9 步 —— ★★★在【玩家入口】真的跑一段並下指令
#
# ★★★這支床存在的理由是一次真機事故（2026-09-24）：
#   電池 80／80 全綠、`--check-only` 0 錯，而玩家一開遊戲【每一幀】噴
#   `Nonexistent function 'get' in base 'String'`。
#   ⇒ ★根因是 `_events` 混進一個 String，而讀者用 `e.get("msg")`。
#   ⇒ ★★而它沒有被任何一格接住，因為【那條路沒有人走】：
#     床有「入列」的格、有「消費」的格、有「render」的格，
#     ★★★而沒有一支床從【玩家入口】按鍵、讓世界走一段、再看畫面。
#
# ★這支床與 `ui_flow_test` 的 P17 的分工要講清楚，否則它看起來是重複的：
#   ·P17 驗【一顆 tick 的形狀】—— 入列→消費→render 接得起來、結果句進了事件流
#   ·★★本床驗【持續跑的那一段】—— 因為今天那個病是【每一幀】噴，
#     而「跑一顆 tick 不噴」與「跑一千顆不噴」是兩件事
#     （事件流會滿 100 筆而環繞、cadence 會到期、天會換 ⇒ 都是一顆 tick 摸不到的路徑）。
#
# ★★★它【不自己數 SCRIPT ERROR】（床看不到自己的 stderr）——
#   它負責【把那條路走完並印出走到哪】，而 SCRIPT ERROR 的數目由跑它的人從卷面讀。
#   ⇒ 那不是偷懶：★★把「有沒有噴錯」交給床自己判，等於讓被觀測物當裁判。
#
# env：PE_TICKS（預設 1200 ＝ 走過日邊界與多次 cadence）／PE_CMDS（預設 6）

var _fails: int = 0

func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_fails += 1
		push_error("[FAIL] " + msg)


func _initialize() -> void:
	var want_ticks: int = int(OS.get_environment("PE_TICKS")) if OS.has_environment("PE_TICKS") else 1200
	var want_cmds: int = int(OS.get_environment("PE_CMDS")) if OS.has_environment("PE_CMDS") else 6
	print("=== 玩家入口煙霧（目標 %d tick／%d 道指令）===" % [want_ticks, want_cmds])
	seed(4242)
	var node = load("res://scenes/TextUI.tscn").instantiate()
	get_root().add_child(node)
	await process_frame
	await process_frame
	var st: WorldState = node._bridge.get_state()
	var start_tick: int = st.world.current_tick
	# ★下指令用【真實鍵盤路徑】—— 不直呼 bridge（直呼會繞過印回音那一行，
	#   而那正是今天那個病所在的那一段）
	var ev := InputEventKey.new()
	ev.keycode = KEY_M
	ev.pressed = true
	var issued: int = 0
	var frames: int = 0
	var budget_s: int = 240
	var t0: int = Time.get_ticks_msec()
	while st.world.current_tick - start_tick < want_ticks:
		# ★每隔一段就按一次 M（移動到游標）⇒ 讓【下指令】與【推進】交錯發生，
		#   而不是「先下完再推進」——玩家不是那樣玩的。
		if issued < want_cmds and (st.world.current_tick - start_tick) >= issued * (want_ticks / maxi(1, want_cmds)):
			node._input(ev)
			issued += 1
		if not node._bridge.is_advancing():
			node._bridge.request_advance(want_ticks - (st.world.current_tick - start_tick))
		node._process(0.1)
		frames += 1
		if Time.get_ticks_msec() - t0 > budget_s * 1000:
			push_error("[PE][不可判] 預算 %ds 用完：只走到 %d／%d tick（frames=%d）" % [
				budget_s, st.world.current_tick - start_tick, want_ticks, frames])
			node.queue_free()
			quit(2)
			return
	# ★母體地板三道 —— 每一道都擋一種「什麼都沒發生也會綠」
	_ok(st.world.current_tick - start_tick >= want_ticks,
		"母體地板①：世界真的走了 %d tick（★0 tick 的話下面全是空談）" % (st.world.current_tick - start_tick))
	_ok(issued >= want_cmds, "母體地板②：真的下了 %d／%d 道指令" % [issued, want_cmds])
	_ok(st.command_log.size() > 0, "母體地板③：消費點真的吃到了（command_log %d 筆）" % st.command_log.size())
	# ★★而「畫面讀得出來」要走【讀者真的會走的那條路】：
	#   `_events` 混進一個 String ⇒ 這兩支會丟錯，而那個錯會把這支床砍斷 ⇒ 卷面沒有 DONE 行
	var strip: String = TextUiMain._log_strip_text(node._events, 3)
	var dbg: String = node._build_debug_str()
	_ok(node._events.size() > 0, "事件流非空（%d 筆）" % node._events.size())
	_ok(strip.length() > 0, "★_log_strip_text() 走得過去且有內容（%d 字）" % strip.length())
	_ok(dbg.contains("Events(last10)"), "★★_build_debug_str() 印了事件段（它用 e.get(\"type\")／e.get(\"msg\")）")
	_ok(dbg.contains("[cmd]"), "★★★事件段裡看得到【指令的結果】（type=cmd）")
	# ★★★判準窄化成【必須是 Dictionary】，不是【必須有 msg】（2026-09-24 實測訂正）：
	#   玩家入口跑 1200 tick 之後這一條紅了（壞形狀 1／共 12），★而那【不是產品錯】——
	#   `sim_bridge._diff_events()` 合法地產出【只有 type 沒有 msg】的事件
	#   （`{"type":"encounter_triggered"}`／`{"type":"new_team_spotted"}`），
	#   而讀者用 `.get("msg", "")` 本來就容忍它。
	#   ⇒ ★★所以 `_events` 有【兩種合法形狀】，而我把其中一種寫成了缺陷。
	#   ⇒ ★★★窄化的方向要對：真 bug 是【String 混進來】（`String` 沒有 `.get()`）
	#     ⇒ 判「是不是 Dictionary」仍然抓得到它，而不會誤咬 type-only 那一種。
	var bad: int = 0
	for e in node._events:
		if not (e is Dictionary):
			bad += 1
	_ok(bad == 0, "事件流每一筆都是 Dictionary（★String 混進來就會在讀者身上丟錯）（壞形狀 %d／共 %d）" % [bad, node._events.size()])
	_ok(node._state_label.text.length() > 50, "畫面主文非空（%d 字）" % node._state_label.text.length())
	print("[PE] 走了 %d tick、%d frames、下了 %d 道指令｜事件流 %d 筆｜command_log %d 筆" % [
		st.world.current_tick - start_tick, frames, issued, node._events.size(), st.command_log.size()])
	print("=== player_entry_smoke DONE === FAILS=%d" % _fails)
	node.queue_free()
	quit(1 if _fails > 0 else 0)
