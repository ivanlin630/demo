extends SceneTree
# @bed-kind: harness
# ══ 玩家介面 ＝ 終端 REPL（骨架）═══════════════════════════════════════════════
# spec：`docs/superpowers/specs/2026-10-01-player-ui-is-a-terminal-repl-HOW.md`
# 用戶逐字（2026-10-01 第三輪玩測）：「新版UI更爛 爛到沒救 改用終端形式的文字UI
#   你們自己抓排版 重複選項等問題」
#
# ★★★【這支腳本刻意【不】自己組畫面、也【不】自己 dispatch】——
#   它只做三件：①把世界與 UI 起起來 ②把**一行文字變成一個 keycode**
#   ③把 `_screen_label.text`（＝合成後的那一屏）印出來。
#   ⇒ 畫面只有一份（`TextUiView.compose()`）、組裝只有一處（`TextUiMain.build_regions()`）、
#     而按鍵的意義**只有 UI 那條 `_input()` 在決定**。
#
# ★★為什麼走**真的節點**（`res://scenes/TextUI.tscn`）而不是繞過 Label：
#   spec §2② 曾提「`regions` 直接吃 builder 回傳 ⇒ 不必起場景樹」，而**那是一個選項不是要求**
#   （systems 2026-10-01 訂正措辭：**「一處組裝」是要求，「不起場景樹」只是達成它的一種手段**）。
#   ⇒ 量過之後不走那條：`regions` 的五個來源裡四個可以隨時重算，
#     ★而 `result` 不行 —— `_feedback_line` 是**把狀態存在 Label 裡**
#     （`text_ui_main.gd:312`／`:1002` 兩處事件驅動寫入）
#   ⇒ 繞過要付「新開一個 feedback 儲存 ＋ 重寫那 12 分支的模式分派」
#   ⇒ ★★★那會變成**第二條組裝路徑**，正是這張票要治的病。
#
# ★而 `ui_flow_test._make_ui()` 已經用同一條路驅動這棵場景樹（79 格在用）⇒ 已驗證。
#
# 跑法：
#   tools\godot.ps1 --headless --script scripts/debug/player_repl.gd
#   （stdin 可用 ⇒ 逐行讀；不可用 ⇒ 退 TCP 並印出 port，見下）

# ══ ★★★★★【沒有「指令表」—— 只有一個詞法器】════════════════════════════════
# spec §2③ 寫「指令表與 dispatch 讀**同一份宣告**」。
# ★而最便宜的滿足方式不是「寫一份宣告讓兩邊讀」，是**讓其中一份不存在**：
#   ·**單一可列印字元** ⇒ 直接映射成它的 `KEY_*`（`a`→`KEY_A`、`3`→`KEY_3`、`,`→`KEY_COMMA`…）
#   ·**非可列印鍵** ⇒ 用具名 token（下面這一份，**全站唯一一處**）
#   ⇒ 於是 REPL **沒有一份「有哪些指令」的清單** ⇒ 它接受的鍵 ＝ UI 接受的鍵，
#     而「漂開」在結構上不可能發生（沒有第二份可以漂）。
# ★★而**反向掃**那一半由床做：`MODE_KEYMAP` 印出來的每一個鍵，
#   都要能被這個詞法器打出來（否則玩家在終端裡**打不出那個鍵**）。
const NAMED_KEYS: Dictionary = {
	"esc": KEY_ESCAPE,
	"enter": KEY_ENTER,
	"space": KEY_SPACE,
	"tab": KEY_TAB,
	"backspace": KEY_BACKSPACE,
	"up": KEY_UP,
	"down": KEY_DOWN,
	"left": KEY_LEFT,
	"right": KEY_RIGHT,
}

# ★離開 REPL 的 token —— ★★它**不是**一個遊戲按鍵：`Q` 是 UI 的「離開」，
#   而 `:quit` 是**離開這支 harness**。兩者分開，否則「我想結束這支腳本」與
#   「我想在遊戲裡離開」會共用一個鍵，而那是本專案最常見的那個病（一個鍵兩個意思）。
const QUIT_TOKEN: String = ":quit"

var _node: Node = null
var _tcp_server: TCPServer = null
var _tcp_client: StreamPeerTCP = null


func _initialize() -> void:
	# ★與 `ui_flow_test._make_ui()` 同一個 seed 來源：不 seed 的話每個行程的世界都不同
	#   （Godot 每個行程開機時全域 RNG 是隨機的 —— 那支床的檔頭有 33＋6 輪實驗的血證）
	var sd: int = int(OS.get_environment("REPL_SEED")) if OS.get_environment("REPL_SEED") != "" else 1337
	seed(sd)
	print("[player-repl] seed=%d（REPL_SEED 可覆寫）" % sd)
	_node = load("res://scenes/TextUI.tscn").instantiate()
	get_root().add_child(_node)
	await process_frame
	await process_frame
	if _node.get("_screen_label") == null:
		print("[player-repl] ✗ 起不來：`_screen_label` 是 null（場景變了？）")
		quit(1)
		return
	_node._refresh()
	_print_screen()
	# ★探測-退路：沿用 `agent_repl.gd:13/41-45` 那個形狀（Windows 沒有 pipe://stdin）
	var stdin: FileAccess = FileAccess.open("pipe://stdin", FileAccess.READ)
	if stdin == null:
		stdin = FileAccess.open("/dev/stdin", FileAccess.READ)
	if stdin != null:
		_run_stdin_loop(stdin)
	else:
		_run_tcp_loop()


func _print_screen() -> void:
	# ★印的就是**合成後的那一屏**（`_screen_label.text`）——
	#   ★★不另外呼 `TextUiView.compose()`：那會是第二個呼叫點，而 P-regions-1 在數那個。
	print(String(_node._screen_label.text))
	print("")   # 一個空行把每一屏分開（★給人讀的，不是斷言）


# 一行輸入 → 一個 keycode（`-1` ＝ 打不出來）
# ★公開成 static，床才能**不起場景樹**地驗這個詞法器（它是純函式）
static func keycode_for(token: String) -> int:
	var t: String = token.strip_edges()
	if t == "":
		return -1
	var low: String = t.to_lower()
	if NAMED_KEYS.has(low):
		return int(NAMED_KEYS[low])
	if t.length() != 1:
		return -1
	var c: String = t.to_upper()
	var code: int = c.unicode_at(0)
	# A-Z／0-9 的 `KEY_*` 逐字等於它們的 ASCII 碼（Godot 的 Key 列舉就是這樣定的）
	if (code >= KEY_A and code <= KEY_Z) or (code >= KEY_0 and code <= KEY_9):
		return code
	match t:
		",": return KEY_COMMA
		".": return KEY_PERIOD
		"-": return KEY_MINUS
		"=": return KEY_EQUAL
		"/": return KEY_SLASH
		" ": return KEY_SPACE
	return -1


func _feed(token: String) -> void:
	if token.strip_edges().to_lower() == QUIT_TOKEN:
		print("[player-repl] 離開（%s）" % QUIT_TOKEN)
		quit(0)
		return
	var kc: int = keycode_for(token)
	if kc == -1:
		# ★打不出來的 token ⇒ **說出來**，不要靜默吞掉
		#   （「沒反應」與「這個鍵沒有意義」在終端裡長得一樣，而玩家會再打一次）
		print("[player-repl] ✗ 打不出這個鍵：%s（具名鍵：%s｜離開：%s）" % [
			token, ", ".join(PackedStringArray(NAMED_KEYS.keys())), QUIT_TOKEN])
		return
	# ★★走**真玩家那一條路**：`_input(event)` ⇒ 逐模式分派到 `_handle_*_mode(keycode)`
	#   ⇒ dispatch **一行都不複製**（spec §2③「同源」最便宜的形狀）
	var ev: InputEventKey = InputEventKey.new()
	ev.keycode = kc
	ev.pressed = true
	_node._input(ev)
	_node._refresh()
	_print_screen()


func _run_stdin_loop(stdin: FileAccess) -> void:
	print("[player-repl] 就緒（stdin）—— 一行一個鍵；`%s` 離開" % QUIT_TOKEN)
	while not stdin.eof_reached():
		var line: String = stdin.get_line()
		if line.strip_edges() == "":
			continue
		_feed(line)
	quit(0)


func _run_tcp_loop() -> void:
	# ★Windows 沒有 `pipe://stdin` ⇒ 退 TCP（`agent_repl.gd:41-45` 的形狀）
	_tcp_server = TCPServer.new()
	var err: int = _tcp_server.listen(0)
	if err != OK:
		print("[player-repl] ✗ TCP 起不來（err=%d）" % err)
		quit(1)
		return
	print("[player-repl] 就緒（tcp）port=%d —— 一行一個鍵；`%s` 離開" % [
		_tcp_server.get_local_port(), QUIT_TOKEN])
	var buf: String = ""
	while true:
		if _tcp_client == null or _tcp_client.get_status() != StreamPeerTCP.STATUS_CONNECTED:
			if _tcp_server.is_connection_available():
				_tcp_client = _tcp_server.take_connection()
			else:
				await process_frame
				continue
		_tcp_client.poll()
		var n: int = _tcp_client.get_available_bytes()
		if n > 0:
			buf += _tcp_client.get_utf8_string(n)
			while buf.contains("\n"):
				var at: int = buf.find("\n")
				var line: String = buf.substr(0, at)
				buf = buf.substr(at + 1)
				if line.strip_edges() != "":
					_feed(line)
		else:
			await process_frame
