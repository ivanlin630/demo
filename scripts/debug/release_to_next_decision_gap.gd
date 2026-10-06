extends SceneTree
# @bed-kind: diagnostic
# ★量測員派工（systems 2026-10-07，用戶裁「思考節律=混合」）：
# 「解除承諾→下一次重決策」等待分佈。WHAT：被解除承諾的隊不得空等超過一小時(60tick)。
#
# ★★★方法說明（誠實限，讀完這段再看數字）：
#   `TaskArbiter.release(team)` 只收 `team` 一個參數，★全站 61 個呼叫點【沒有一個】帶
#   call-site 字串，production 現有的 Probe tap（_note_task_lost 的 bump_sample）也【不帶 tick】
#   ⇒ 純外部觀測【抓不到】release 當下的呼叫檔案——要那個需要在 task_arbiter.gd:334 加一行
#   get_stack() tap，那是碰 production code，不是量測員的格（不另造，交 systems 判要不要加）。
#   ⇒ 本床用【代理偵測】：release() 的身體會在同一次呼叫裡把
#   current_task→TASK_IDLE、task_priority→0、move_target→(-1,-1) 三者一起設定——
#   逐tick watch 這三者從「不是這個狀態」變成「是這個狀態」，當一次 release 事件。
#   ★★自證：release() 開頭無條件 bump「commit.release_clean」或「commit.release_with_commitment」
#   ——本床把代理偵測到的總數跟這兩個 counter 的和做對帳，對不上要印出來、不能默默吞。
#   ★「呼叫來源」沒有檔案可分，改用【釋放前的 task】分——這是能拿到的最接近訊號，
#   不是檔案分類，卷面會寫清楚不假裝是檔案。
#
# 下一次決策：sim_runner._collect_due_teams 用 `cur >= team.pass_next_tick`，`pass_next_tick`
# 是 TeamData 的欄位、release() 不碰它 ⇒ release 那一刻讀 team.pass_next_tick 就是已排定的
# 下一次到期 tick（既有機制，不另造）。
#
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/release_to_next_decision_gap.gd

const SEED: int = 1337
const TOTAL_TICKS: int = 30 * 1440
const OVER_THRESHOLD: int = 60   # WHAT：不得空等超過一小時


func _initialize() -> void:
	var tree_sha: String = _git_head_sha()
	print("[TREE] HEAD=%s" % tree_sha)
	print("[SEED] %d｜殺玩家=否" % SEED)

	seed(SEED)
	var ws: WorldState = MeasureBedHelper.arm_and_setup("res://config/default.json", false)
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)
	Probe.arm()

	var prev_state: Dictionary = {}   # team_id → bool（上一tick是否已處於 idle/prio0/no-target）
	var events: Array = []            # {release_tick, team, prev_task, gap}
	var by_prev_task: Dictionary = {}   # prev_task(代理「來源」) → Array[gap]

	for tid0 in ws.teams.keys():
		var t0: TeamData = ws.teams[tid0]
		prev_state[int(tid0)] = _is_released_state(t0)

	var last_task_before: Dictionary = {}   # team_id → 上一個非idle task（供代理來源判斷）
	for tid00 in ws.teams.keys():
		var t00: TeamData = ws.teams[tid00]
		last_task_before[int(tid00)] = t00.current_task

	for _i in range(TOTAL_TICKS):
		runner.advance_tick(ws, no_player)
		var cur_tick: int = ws.world.current_tick
		for tid in ws.teams.keys():
			var t: TeamData = ws.teams[tid]
			var now_released: bool = _is_released_state(t)
			var was_released: bool = bool(prev_state.get(tid, false))
			if now_released and not was_released:
				var prev_task: String = String(last_task_before.get(tid, "?"))
				var next_decision: int = int(t.pass_next_tick)
				var gap: int = next_decision - cur_tick
				events.append({"release_tick": cur_tick, "team": int(tid), "prev_task": prev_task,
					"next_decision_tick": next_decision, "gap": gap})
				var arr: Array = by_prev_task.get(prev_task, [])
				arr.append(gap)
				by_prev_task[prev_task] = arr
			if not now_released:
				last_task_before[tid] = t.current_task
			prev_state[tid] = now_released

	# ── 自證對帳：代理偵測總數 vs Probe 既有的 release 總數 ────────────────────────
	var probe_release_total: int = int(Probe.counts.get("commit.release_clean", 0)) \
		+ int(Probe.counts.get("commit.release_with_commitment", 0))
	print("\n========== 自證對帳 ==========")
	print("代理偵測到的 release 事件數＝%d｜Probe 既有計數(release_clean+release_with_commitment)＝%d｜%s" \
		% [events.size(), probe_release_total, ("✅一致" if events.size() == probe_release_total else "❌不一致——代理偵測有漏或有多算，下面數字要打折讀")])

	print("\n========== 全域等待分佈 ==========")
	var all_gaps: Array = []
	for e in events: all_gaps.append(int(e["gap"]))
	all_gaps.sort()
	if not all_gaps.is_empty():
		var median: float = _percentile(all_gaps, 0.5)
		var p90: float = _percentile(all_gaps, 0.9)
		var max_gap: int = all_gaps[all_gaps.size() - 1]
		var over_n: int = 0
		for g in all_gaps:
			if g > OVER_THRESHOLD: over_n += 1
		print("事件總數=%d｜中位=%.1f｜p90=%.1f｜最大=%d" % [all_gaps.size(), median, p90, max_gap])
		print("超過 %d tick(1小時) 的筆數=%d｜比例=%.1f%%" % [OVER_THRESHOLD, over_n, 100.0 * float(over_n) / float(all_gaps.size())])

	print("\n========== 按「釋放前的task」分（★代理來源,不是呼叫檔案,見檔頭誠實限） ==========")
	var task_keys: Array = by_prev_task.keys()
	task_keys.sort()
	for tk in task_keys:
		var arr2: Array = by_prev_task[tk]
		arr2.sort()
		var med2: float = _percentile(arr2, 0.5)
		var p902: float = _percentile(arr2, 0.9)
		var max2: int = arr2[arr2.size() - 1]
		var over2: int = 0
		for g2 in arr2:
			if g2 > OVER_THRESHOLD: over2 += 1
		print("  prev_task=%-10s｜n=%-5d｜中位=%-6.1f｜p90=%-6.1f｜最大=%-5d｜超60tick比例=%.1f%%" \
			% [tk, arr2.size(), med2, p902, max2, 100.0 * float(over2) / float(arr2.size())])

	print("\n========== 超過 119 tick 的筆數（systems 讀碼推的理論上限，核真不真） ==========")
	var over119: int = 0
	for g3 in all_gaps:
		if g3 > 119: over119 += 1
	print("gap > 119 的筆數=%d／%d" % [over119, all_gaps.size()])
	print("gap 的最大值=%d（理論推算上限約119，實測%s）" % [
		(all_gaps[all_gaps.size()-1] if not all_gaps.is_empty() else -1),
		("在範圍內" if (not all_gaps.is_empty() and all_gaps[all_gaps.size()-1] <= 119) else "★超出理論推算，要回頭查")])

	var out_path: String = "docs/measurements/release-to-next-decision-gap.jsonl"
	var f: FileAccess = FileAccess.open(out_path, FileAccess.WRITE)
	f.store_line(JSON.stringify({"kind": "meta", "tree": tree_sha, "seed": SEED,
		"proxy_events": events.size(), "probe_release_total": probe_release_total}))
	for e2 in events:
		f.store_line(JSON.stringify(e2))
	f.close()
	print("\n[DUMP-PATH] %s" % out_path)
	print("=== release_to_next_decision_gap DONE ===")
	quit(0)


func _is_released_state(t: TeamData) -> bool:
	return String(t.current_task) == TeamData.TASK_IDLE and int(t.task_priority) == 0 \
		and t.move_target == Vector2i(-1, -1)


func _percentile(sorted_arr: Array, p: float) -> float:
	if sorted_arr.is_empty():
		return -1.0
	var idx: float = p * float(sorted_arr.size() - 1)
	var lo: int = int(floor(idx))
	var hi: int = int(ceil(idx))
	if lo == hi:
		return float(sorted_arr[lo])
	var frac: float = idx - float(lo)
	return float(sorted_arr[lo]) * (1.0 - frac) + float(sorted_arr[hi]) * frac


func _git_head_sha() -> String:
	var out: Array = []
	OS.execute("git", ["rev-parse", "--short=9", "HEAD"], out, true)
	if out.size() > 0:
		return String(out[0]).strip_edges()
	return "UNKNOWN"
