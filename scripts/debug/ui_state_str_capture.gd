extends SceneTree
# @bed-kind: diagnostic
# slice: UI 五分頁票A —— ★取【前】：把 `_build_state_str()` 的輸出【原樣】存檔
#
# ★★★這支床存在的唯一理由：票A 的 P1 是【前後比對】，而「前」只能在改之前取。
#   改完才想起來，就永遠沒有「前」了（systems AMEND §3）。
# ★★存檔要落在 repo 裡（不是「在我手上」），而且【重現條件寫進檔頭】。
# ★raw 存檔：★★★不得 strip、不得排序、不得去重 —— P1 用【逐行計數】比，
#   而舊輸出裡有多條一模一樣的分隔線，去重會讓「四條變一條」也綠。
#
# ── ★★★第一版的三個缺陷（留著，因為下一個人會犯同樣的） ──
#   ①`request_advance()` 沒給參數：它的簽章是 `request_advance(n: int)`（sim_bridge.gd:26）
#     ⇒ 600 次全是錯誤呼叫、世界【一個 tick 都沒推進】，而我當時以為它「很慢」。
#   ②`UC_CONFIG` 讀了、印進檔頭、★從來沒有被用到 —— TextUI 自己載它的世界。
#     ⇒ 檔頭會寫一個【不是實際載到的】config，而那份檔頭正是給下一個人重現用的。
#     ⇒ ★★修法不是把 cfg 接上去（這支床沒有權決定世界），是【印它量到的，不印我以為的】。
#   ③沒有自己的時間預算 ⇒ 撞 wrapper 的 600s 逾時。而那一輪我還誤判成「wrapper 騙人」，
#     ★真相是我自己的指令結尾有 `| tail`，管線的離開碼是 tail 的（wrapper 回的是 98）。
#
# env：UC_TICKS（預設 120）／UC_BUDGET_S（預設 240）／UC_OUT（必填）／UC_SELECT（預設開，=0 關）
#   ★UC_SELECT：把游標選在玩家隊那一格，★★逼出 :716-738 那 ~23 行
#     ⇒ 不逼的話那一段【一行都不會渲染】，而 P1 是前後比對 ⇒ ★★★沒渲染到的區塊改壞了也不會紅
#   ★沒有 UC_CONFIG：世界由 TextUI 自己決定，這支床只負責【記錄它實際拿到什麼】。

func _initialize() -> void:
	_run()

func _run() -> void:
	var want_ticks: int = int(OS.get_environment("UC_TICKS")) if OS.has_environment("UC_TICKS") else 120
	var budget_s: int = int(OS.get_environment("UC_BUDGET_S")) if OS.has_environment("UC_BUDGET_S") else 240
	var out_path: String = OS.get_environment("UC_OUT") if OS.has_environment("UC_OUT") else ""
	print("=== _build_state_str 擷取（目標 ticks=%d 預算=%ds）===" % [want_ticks, budget_s])
	if out_path == "":
		push_error("[UC][不可判] 沒給 UC_OUT ⇒ ★沒有落地路徑的擷取等於沒有擷取")
		quit(2)
		return

	var node = load("res://scenes/TextUI.tscn").instantiate()
	get_root().add_child(node)
	await process_frame
	await process_frame

	var t0: int = Time.get_ticks_msec()
	var st: WorldState = node._bridge.get_state()
	var start_tick: int = st.world.current_tick
	# ★推進：`request_advance(n)` 只是【設定剩餘量】，真正走的是 `_process` 裡的 `tick_step()`
	#   ★★而 tick_step 遇到玩家相關事件會【提前停】⇒ 不能只請求一次就等它跑完，
	#     要看【世界的 tick 真的到了沒】，而不是看我請求過幾次。
	var frames: int = 0
	var re_requests: int = 0
	while st.world.current_tick - start_tick < want_ticks:
		if not node._bridge.is_advancing():
			node._bridge.request_advance(want_ticks - (st.world.current_tick - start_tick))
			re_requests += 1
		await process_frame
		frames += 1
		# ★★★自己的時間預算：撞到就判【不可判】並印出走到哪 —— ★不要讓 wrapper 的逾時來砍，
		#   那樣卷面上只會留下一行 TIMEOUT，看不出它走到第幾 tick。
		if Time.get_ticks_msec() - t0 > budget_s * 1000:
			push_error("[UC][不可判] 預算 %ds 用完：只推進 %d／%d tick（frames=%d 重新請求=%d）" % [
				budget_s, st.world.current_tick - start_tick, want_ticks, frames, re_requests])
			node.queue_free()
			quit(2)
			return

	# ★★★把【選中格】那一段也逼出來（text_ui_main.gd:716 `if _selected != Vector2i(-1,-1)`）：
	#   ★預設 _selected 是 (-1,-1) ⇒ 那 ~23 行【一行都不會渲染】
	#   ⇒ ★★而 P1 是【前後比對】：沒渲染到的區塊，就算被我改壞也不會紅
	#   ⇒ ★★★所以「前」要取【蓋得比較廣】的那一份 —— 那個 if 只會【追加】行，
	#     選中之後的輸出是沒選中的【超集】，不會蓋掉任何東西。
	var did_select: bool = false
	if OS.get_environment("UC_SELECT") != "0":
		var ct: Dictionary = node._cached_snapshot.get("controlled_team", {})
		var cp: Dictionary = ct.get("position", {})
		if not cp.is_empty():
			node._selected = Vector2i(int(cp.get("q", 0)), int(cp.get("r", 0)))
			did_select = true
	var s: String = node._build_state_str()
	var raw_lines: PackedStringArray = s.split("\n")
	# ★母體地板：空輸出與「沒接上」長得一樣 ⇒ 先判不可判，不要存一個空檔案然後說「取過了」
	if s.strip_edges() == "" or raw_lines.size() < 5:
		push_error("[UC][不可判] 輸出只有 %d 行（長度 %d）⇒ 疑似沒建起來，不是「畫面很短」" % [
			raw_lines.size(), s.length()])
		node.queue_free()
		quit(2)
		return

	var f := FileAccess.open(out_path, FileAccess.WRITE)
	if f == null:
		push_error("[UC][不可判] 開不了檔：%s" % out_path)
		node.queue_free()
		quit(2)
		return
	# ★★★檔頭印的是【量到的】不是【請求的】：tick 寫實際值，世界規模現場數
	#   ⇒ 這樣下一個人拿檔頭去重現時，比對的是同一個東西。
	#   ★而檔頭行以 `#UC ` 起頭（正文不可能長這樣）⇒ 比對時跳過。
	f.store_line("#UC tree=%s" % _head())
	f.store_line("#UC tick=%d（起點 %d，實際推進 %d；請求 %d）" % [
		st.world.current_tick, start_tick, st.world.current_tick - start_tick, want_ticks])
	f.store_line("#UC 世界規模（現場數，非設定值）：teams=%d factions=%d persons=%d" % [
		st.teams.size(), st.factions.size(), st.persons.size()])
	f.store_line("#UC 逐字原樣；★不 strip、不排序、不去重（P1 用逐行計數比）")
	f.store_line("#UC 選中格=%s（★關掉的話 :716-738 那 ~23 行不會渲染 ⇒ P1 蓋不到它）" % (
		str(node._selected) if did_select else "無"))
	f.store_line("#UC 行數=%d" % raw_lines.size())
	for ln in raw_lines:
		f.store_line(ln)
	f.close()

	# ★重複行點名：★★這正是 systems 指名的那個坑（多條一模一樣的分隔線）
	var cnt: Dictionary = {}
	for ln in raw_lines:
		cnt[ln] = int(cnt.get(ln, 0)) + 1
	var dups: Array = []
	for k in cnt:
		if int(cnt[k]) > 1:
			dups.append("%dx「%s」" % [int(cnt[k]), String(k).substr(0, 20)])
	print("[UC] 已落地：%s" % out_path)
	print("[UC] 世界：tick=%d teams=%d factions=%d persons=%d（★現場數）" % [
		st.world.current_tick, st.teams.size(), st.factions.size(), st.persons.size()])
	print("[UC] 行數=%d 相異行=%d｜推進用了 %d frames、重新請求 %d 次、%.1fs" % [
		raw_lines.size(), cnt.size(), frames, re_requests, float(Time.get_ticks_msec() - t0) / 1000.0])
	print("[UC] ★重複出現的 raw 行 %d 種：%s" % [dups.size(), ", ".join(dups) if not dups.is_empty() else "（無）"])
	print("[UC]   ⇒ ★★所以 P1 必須用【逐行計數】：集合測試下那些重複行少掉幾條也會綠")
	print("=== ui_state_str_capture DONE ===")
	node.queue_free()
	quit(0)

func _head() -> String:
	# ★樹的身分寫進檔頭：同檔名在這個 repo 有 30 幾棵樹，光寫檔名認不出是哪一份
	var out: Array = []
	var rc: int = OS.execute("git", ["rev-parse", "--short", "HEAD"], out, true)
	if rc != 0 or out.is_empty():
		return "（git 取不到）"
	return String(out[0]).strip_edges()
