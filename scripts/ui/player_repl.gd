extends SceneTree
class_name PlayerRepl   # ★床要呼它的詞法器（`keycode_for()` 是純函式）
# ★★★★★★【它沒有 `@bed-kind`，而那是因為它【不是床】】（systems 裁 2026-10-01 §20）
#   ·它原本放在 `scripts/debug/` 並標 `@bed-kind: harness` ⇒ 電池那支 `bed-kind` 紅：
#     「@bed-kind 值不在四選一裡: harness」（合法值 ＝ invariant|acceptance|diagnostic|pending）
#   ·★而**兩個「便宜的修法」都被否決，理由寫在這裡**：
#     ①**給它一個合法值**（例如 `pending`／`diagnostic`）＝ **說謊** ——
#       它不是「還沒接電的床」，★**它根本不是床**，它是**玩家介面的入口**
#     ②**把 `harness` 加進合法值** ＝ **概念漂** —— 讓「床的種類」容納一個不是床的東西
#       ⇒ 下一個人會開始拿它標別的非床腳本，而那支閘的語意就稀釋掉了
#   ⇒ ★★★所以它**搬到 `scripts/ui/`**（它走真的節點、它是玩家入口），
#     而 `bed-kind` 的母體只掃 `scripts/debug/` ⇒ 它**不再被要求宣告種類**，
#     ★而那不是規避：**它本來就不該被那支閘管**。
#   ★而守這支腳本產出的那些性質的是 `scripts/debug/terminal_selfcheck_bed.gd`
#     （它是床、它標 `invariant`、它在註冊表裡）。
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
#   tools\godot.ps1 --headless --script scripts/ui/player_repl.gd
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

# ══ ★★★★★★【框尾：一個整屏結束的明文標記】（spec §2 刀 0）════════════════════
# ★為什麼需要它：客戶端從 socket 讀的是**位元流**，它不知道「這一屏印完了」——
#   沒有框尾的話它只能用「等一下沒有新資料」猜，而那在慢機器上會把半屏當成整屏。
# ★★而**約束不可選**（systems 定 2026-10-06）：框尾必須**構造上不可能出現在畫面內容裡**。
#   ·`compose()` 吐的字串含**引擎給的任意一句話**（事件敘述、結果句…）而且**長度無界**
#     ⇒ ★「挑一個看起來不會出現的字」**不是**構造上不可能，那只是今天剛好沒出現。
#   ⇒ ★★★所以兩件一起做：①挑一個**不可列印**的位元組（EOT `0x04`，畫面永遠不會用它排版）
#     ②**在送出點把那個位元組從內容裡剝掉** —— 於是「內容裡出現框尾」在結構上不可能發生。
#   ⇒ ★而剝掉是**安全的**：那個位元組在畫面上本來就沒有任何意義（它不是中文、不是框線、
#     不是空白）⇒ 剝它不會吃掉任何玩家該看到的東西。
#   ★★★★而它與今天另一條的差別要寫清楚：`_pages_without_header()` 那裡的紀律是
#     「**不認識就不要動**」，而這裡是「**認識而且必須剝**」—— 兩者不衝突：
#     那裡剝的是**可能有意義的一整行**，這裡剝的是**一個在畫面上沒有意義的控制字元**。
# ══ ★★★★★【server 自己退：連線逾時】（spec §2 刀 2，形狀照 `agent_repl.gd:53-60`）═══
# ★為什麼要 server 做而不是 client：**client 被殺的時候只有 server 還在跑**（spec P2b 逐字）。
# ★★沒有它的話：client 起了 Godot 然後死掉 ⇒ 那支 Godot 永遠等一個不會來的連線
#   ⇒ 電池那條「開跑前 Godot 數必須 0」會卡住，而 `machine-busy` 只能說「去問」。
# ★而 15 秒照 `agent_repl.gd` 那支的值（不另訂一個數）—— 它已經在用、而且沒出過事。
# ★★單位是【牆鐘毫秒】（跟 `Time.get_ticks_msec()` 比），**不是模擬 tick** ——
#   電池的 `bare-tick` 那支閘曾把它標成 NEEDS_HUMAN（形狀認不出來 ⇒ 交人判），
#   ⇒ 判 (c) 白名單，規則寫在 `scripts/debug/bare_tick_triage.gd`（精確名，不開寬規則）。
const CONNECT_TIMEOUT_MS: int = 15000
const FRAME_END_BYTE: int = 4           # EOT（`0x04`）—— 不可列印
const FRAME_END: String = "\u0004"

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
	# ══ ★★★★★★【第一屏【不能】在 transport 起來之前畫】（實測抓到，2026-10-06）═══════
	#   ★刀 0 把回程搬到 socket 之後，這一行原本是 `_send_screen()` ——
	#     而它跑在 `_run_tcp_loop()` **之前** ⇒ 那時 `_tcp_client` 是 `null`
	#     ⇒ `_send_screen()` 走它的 fallback ⇒ **第一屏跑到 stdout 去了**
	#     ⇒ 客戶端接上來之後**什麼都收不到** ⇒ 它在 `recv` 上逾時。
	#   ★★而症狀**不像**「第一屏送錯地方」：客戶端看到的是一個 `TimeoutError`
	#     ⇒ 它與「server 根本沒起來」「server 當掉了」長得一樣。
	#   ⇒ ★★★判準：**搬一個輸出的管道時要連它的【時機】一起搬** ——
	#     管道換了之後，「什麼時候那個管道才存在」也變了，而舊的呼叫點不會自己移位。
	#   ⇒ 所以這裡**不畫**：第一屏由**連上之後**那一刻送（見 `_run_tcp_loop`／`_run_stdin_loop`）。
	# ~~_send_screen()~~
	# ★探測-退路：沿用 `agent_repl.gd:13/41-45` 那個形狀（Windows 沒有 pipe://stdin）
	var stdin: FileAccess = FileAccess.open("pipe://stdin", FileAccess.READ)
	if stdin == null:
		stdin = FileAccess.open("/dev/stdin", FileAccess.READ)
	if stdin != null:
		_run_stdin_loop(stdin)
	else:
		_run_tcp_loop()


# ══ ★★★★★★【回程走 socket，不走 stdout】（spec §2 刀 0 —— 它是後面兩刀的前提）══
# ★為什麼搬：**sim 無條件灌 stdout**（`sim_runner.gd` 那些 `print`）
#   ⇒ 客戶端讀 stdout 會**收到混著 log 的畫面** ⇒ ★而那時「印出東西了」與
#     「印出一屏混著 log 的亂碼」在卷面上**都是綠的**（這就是 P1 要求端到端中文字面的理由）。
# ★★而它**同時解掉 CP950 那個洞**：stdout 在 Windows 會被編碼弄花，socket 送的是位元組。
# ★★★而**留在 stdout 的只有一行**：`port=` 那一行 —— 它**不是畫面**，
#   它是客戶端要用來接上來的握手資訊（spec §2 刀 1② 逐字）。
func _send_screen() -> void:
	var screen: String = String(_node._screen_label.text)
	# ★★★★★在**送出點**剝掉框尾位元組 ⇒ 「內容裡出現框尾」結構上不可能發生
	#   （理由寫在 `FRAME_END` 旁邊：`compose()` 含引擎給的任意一句話、長度無界）
	screen = screen.replace(FRAME_END, "")
	if _tcp_client != null and _tcp_client.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		_tcp_client.put_data((screen + FRAME_END).to_utf8_buffer())
		return
	# ★stdin 模式沒有 socket ⇒ 回 stdout，而**那是誠實的**（那條路上沒有別的回程）。
	#   ★★而它仍然印框尾：客戶端的解析方式**兩條路一致**（否則「同源」只是一句話）。
	print(screen + FRAME_END)


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


# ══ ★★★按一個鍵的**唯一**實作（REPL 與終端 E2E 床共用；E2E spec 2026-10-06，systems 裁）══════════════
# ★走**真玩家那一條路**：`_input(event)` ⇒ 逐模式分派到 `_handle_*_mode(keycode)`
#   ⇒ dispatch **一行都不複製**（spec §2③「同源」最便宜的形狀）
# ★★抽出來的理由：E2E 床要送鍵而**不經 socket**（它要讀世界狀態），若在床裡手抄這三行，
#   「床走的路」與「玩家走的路」就是兩份 —— 兩份會漂，而漂掉的那份是靜默的
#
# ══ ★★★★【回來的那一屏 ＝ 推進消化完之後的世界】（E2E spec P10；藍圖 2026-10-07 press-is-do）══════════
# ★舊版：`_input`＋`_refresh` 之後**立刻**回 ⇒ 而 `request_advance()` 只是記一個量，
#   真正走 tick 的是之後幾幀的 `text_ui_main._process`（每幀最多 `SimBridge.STEP_TICK_BOUND`）
#   ⇒ 實測（origin/main `6a5b56c7e`，play.py）：送 `x` 立刻回的那一屏仍是「第 1 天 00:00」，
#     上一次的結果要到**下一次按鍵**才看得到 ⇒ ★玩家畫面永遠落後一步（Space 隔日也一樣）
# ⇒ 現在：推進中就讓幀跑（`await process_frame` ＝ `_process` 那一個幀鐘），直到 `is_advancing()` 為假
#   ★不推進的鍵（Esc／換頁／開面板）`is_advancing()` 一開始就是假 ⇒ **不等任何一幀，立刻回**
#   ★不會卡住（R² 2026-10-07 核過）：事件退出路徑把 remaining 歸零；remaining 每幀單調遞減；
#     await 與 `_process` 是同一個幀鐘
# ⇒ ★呼叫端必須 `await PlayerRepl.press_on(...)`（REPL 的 `_feed` 與 E2E 床都是）
static func press_on(node, kc: int) -> void:
	var ev: InputEventKey = InputEventKey.new()
	ev.keycode = kc
	ev.pressed = true
	# ★終端戰鬥區（spec 2026-10-07 terminal-battle-screen §1①）：戰鬥中鍵送 encounter_view 的終端入口
	#   （text_ui_main._input 戰鬥中照舊 return —— GUI 那次按鍵由引擎廣播給 encounter_view；這裡是終端路）
	var bv = node.get("_encounter_view")
	if bv != null and bv.visible:
		bv.terminal_handle_key(kc)
	else:
		node._input(ev)
	node._refresh()
	# ★等推進消化完：世界推進（is_advancing）＋戰鬥推進（還沒輪到玩家，§1③）
	while node._bridge.is_advancing() or (bv != null and not bv.is_settled_for_terminal()):
		await node.get_tree().process_frame
	node._refresh()


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
	await press_on(_node, kc)
	_send_screen()


func _run_stdin_loop(stdin: FileAccess) -> void:
	print("[player-repl] 就緒（stdin）—— 一行一個鍵；`%s` 離開" % QUIT_TOKEN)
	_send_screen()   # ★第一屏在【就緒之後】送（理由見 `_initialize()` 那一段）
	while not stdin.eof_reached():
		var line: String = stdin.get_line()
		if line.strip_edges() == "":
			continue
		await _feed(line)
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
	# ══ ★★★★★★【斷線即退】（spec §2 刀 2，形狀照 `agent_repl.gd:68-69`／`:98`）═══════
	#   ★舊版：client 斷線之後 `_tcp_client.get_status() != CONNECTED` ⇒ 回去**等下一個連線**
	#     ⇒ ★而那個下一個連線**永遠不會來**（client 已經死了）⇒ 留一支 Godot 在背景。
	#   ★★實測（負對照先紅，2026-10-06）：不送 `:quit`、直接關 socket
	#     ⇒「關 socket 之後 30.1 秒：那一支 Godot 還活著 ＝ True」
	#   ⇒ ★★★所以分兩個階段，而**兩個階段的出口不同**：
	#     ·**還沒連上過** ⇒ 等，但最多 `CONNECT_TIMEOUT_MS`（逾時 ⇒ `quit(1)`：沒人來接）
	#     ·**連上過、然後斷了** ⇒ **立刻退** `quit(0)`（那是 client 走了，不是異常）
	#   ⇒ ★★★★而「連上過」要自己記（`had_client`）：只看 `_tcp_client` 是不是 null
	#     分不出「還沒來」與「來了又走」—— 而那兩種情形要的出口相反。
	var had_client: bool = false
	var deadline: int = Time.get_ticks_msec() + CONNECT_TIMEOUT_MS
	while true:
		if _tcp_client == null:
			if _tcp_server.is_connection_available():
				_tcp_client = _tcp_server.take_connection()
				_tcp_client.poll()
				had_client = true
				# ★★★★★【連上的那一刻送第一屏】—— 客戶端一接上就該看到畫面，
				#   而不是「送一個鍵才看到第一屏」（那會讓玩家以為它沒反應）。
				_send_screen()
			elif Time.get_ticks_msec() > deadline:
				print("[player-repl] ✗ %d 秒內沒有人接上來 ⇒ 自己退（不留一支孤兒）"
					% (CONNECT_TIMEOUT_MS / 1000))
				quit(1)
				return
			else:
				await process_frame
				continue
		_tcp_client.poll()
		var st: int = _tcp_client.get_status()
		if st == StreamPeerTCP.STATUS_NONE or st == StreamPeerTCP.STATUS_ERROR:
			# ★連上過、然後斷了 ⇒ client 走了 ⇒ 立刻退
			print("[player-repl] client 斷線（status=%d）⇒ 自己退" % st)
			quit(0)
			return
		var n: int = _tcp_client.get_available_bytes()
		if n > 0:
			buf += _tcp_client.get_utf8_string(n)
			while buf.contains("\n"):
				var at: int = buf.find("\n")
				var line: String = buf.substr(0, at)
				buf = buf.substr(at + 1)
				if line.strip_edges() != "":
					await _feed(line)
		else:
			await process_frame
