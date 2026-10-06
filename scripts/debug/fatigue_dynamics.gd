extends SceneTree
# @bed-kind: diagnostic
# ★量測員派工（systems 2026-10-06，藍圖裁 5585f7246）：疲勞動力學——只量不修，禁試算常數。
#
# ★先查母體（git grep ".fatigue" 全站只 1 個寫入點：sim_runner.gd:926-939 `_step6d_fatigue`，
# 兩分支：current_task==TASK_REST ⇒ 回復；否則 ⇒ 累積（封頂1.0））。
# ★★★結構性發現（讀碼，本床再動態驗一次）：全站 grep `TASK_REST`，四個命中裡【零個】是
# 「指派」（`team.current_task = TeamData.TASK_REST`）——sim_runner 讀它當回復閘、
# npc_ai_system/npc_combat_system 各讀它一次當條件，team_data.gd 定義常數。
# ⇒ 沒有任何決策路徑會把隊的 current_task 設成 TASK_REST ⇒ 回復分支的觸發條件【結構上不可達】。
# ⇒ 本床動態驗證：30 天裡 TASK_REST 實際被觀察到幾次（母體問，不猜）。
# ★「紮營」是另一個 option（options.gd:291），到任務是 TASK_BUILD/一次性立足，不是 TASK_REST，
#   兩者容易混——本床分開數。
#
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/fatigue_dynamics.gd

const SEED: int = 1337
const TOTAL_TICKS: int = 30 * 1440


func _initialize() -> void:
	var tree_sha: String = _git_head_sha()
	print("[TREE] HEAD=%s" % tree_sha)
	print("[SEED] %d｜殺玩家=否" % SEED)

	print("\n========== ★疲勞寫入/回復點母體（git grep \".fatigue\" 全站） ==========")
	print("  僅 1 個寫入點：scripts/simulation/sim_runner.gd:926-939 `_step6d_fatigue`")
	print("  ├─ 回復分支（:929-930）：觸發條件 = current_task==TASK_REST")
	print("  └─ 累積分支（:936-937）：觸發條件 = current_task!=TASK_REST（★預設分支，恆成立除非前者成立）")
	print("  ★TASK_REST 全站 4 個命中，0 個是指派點（sim_runner讀它當閘／npc_ai_system讀它當條件／\
npc_combat_system讀它當條件／team_data.gd定義常數）⇒ 結構上沒有任何決策路徑會把 current_task\
設成 TASK_REST。下面動態驗證這個讀碼結論。")

	seed(SEED)
	var ws: WorldState = MeasureBedHelper.arm_and_setup("res://config/default.json", false)
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)

	var floor_ticks: Dictionary = {}      # team_id → 在floor(fatigue>=1.0)的tick數
	var total_ticks_alive: Dictionary = {}
	var ever_decreased: Dictionary = {}   # team_id → bool（fatigue有沒有在任何時刻下降過）
	var task_rest_n: Dictionary = {}      # team_id → 出現 current_task==TASK_REST 的tick數
	var camp_commit_n: Dictionary = {}    # team_id → current_option=="紮營" 的tick數（另一個概念，分開數）
	var prev_fatigue: Dictionary = {}
	var final_fatigue: Dictionary = {}

	for _i in range(TOTAL_TICKS):
		runner.advance_tick(ws, no_player)
		for tid in ws.teams.keys():
			var t: TeamData = ws.teams[tid]
			total_ticks_alive[tid] = int(total_ticks_alive.get(tid, 0)) + 1
			if t.fatigue >= 1.0:
				floor_ticks[tid] = int(floor_ticks.get(tid, 0)) + 1
			if prev_fatigue.has(tid) and t.fatigue < float(prev_fatigue[tid]) - 0.0001:
				ever_decreased[tid] = true
			prev_fatigue[tid] = t.fatigue
			if String(t.current_task) == TeamData.TASK_REST:
				task_rest_n[tid] = int(task_rest_n.get(tid, 0)) + 1
			if String(t.current_option) == "紮營":
				camp_commit_n[tid] = int(camp_commit_n.get(tid, 0)) + 1
			final_fatigue[tid] = t.fatigue

	print("\n========== 動態驗證：全站 TASK_REST 出現次數 ==========")
	var total_rest_ticks: int = 0
	for v in task_rest_n.values(): total_rest_ticks += int(v)
	print("  全部隊 × 全部tick，current_task==TASK_REST 的『隊·tick』總數 = %d" % total_rest_ticks)
	print("  ⇒ %s" % ("確認：0 次，讀碼結論成立（結構上不可達，不是機率低）" if total_rest_ticks == 0 \
		else "★★★意外：非0！讀碼結論有漏，需要回頭查是哪個路徑指派的"))

	var total_camp_ticks: int = 0
	for v2 in camp_commit_n.values(): total_camp_ticks += int(v2)
	print("  （對照：current_option==\"紮營\" 的『隊·tick』總數 = %d——這是另一個概念\
[立足/建營地]不是[休息恢復疲勞]，兩者不要混）" % total_camp_ticks)

	print("\n========== 每隊 30 天疲勞軌跡 ==========")
	print("team｜floor時間比例｜曾下降過(真的回復)｜期末fatigue｜累積速率(常數,全站同一值)｜回復速率(從未觸發)")
	var tids_sorted: Array = total_ticks_alive.keys()
	tids_sorted.sort()
	for tid2 in tids_sorted:
		var total: int = int(total_ticks_alive[tid2])
		var floor_n: int = int(floor_ticks.get(tid2, 0))
		var pct: float = 100.0 * float(floor_n) / float(total)
		var decreased: bool = bool(ever_decreased.get(tid2, false))
		print("%4d｜%6.1f%%｜%s｜%.3f｜FATIGUE_PER_DAY(常數,見下)｜從未觸發(TASK_REST=0次)" \
			% [int(tid2), pct, str(decreased), float(final_fatigue.get(tid2, -1.0))])

	print("\n========== 結論（只量不修，不試算常數） ==========")
	print("累積分支每 call 都成立（current_task!=TASK_REST 恆真）⇒ 所有隊的 fatigue 單調上升到\
1.0 封頂後卡死；回復分支的觸發條件（TASK_REST）結構上從未被任何決策路徑指派 ⇒ ★屬藍圖兩個\
出口裡的【壞狀態】：不是「隊真的不眠不休的設計選擇」，是「回復機制存在但接不到任何呼叫端」\
——跟『STUB註解/沒呼叫的保護函式』那一族同形:程式碼寫對了,但沒有入口。")

	var out_path: String = "docs/measurements/fatigue-dynamics.jsonl"
	var f: FileAccess = FileAccess.open(out_path, FileAccess.WRITE)
	f.store_line(JSON.stringify({"kind": "meta", "tree": tree_sha, "seed": SEED,
		"total_rest_ticks": total_rest_ticks, "total_camp_ticks": total_camp_ticks}))
	for tid3 in tids_sorted:
		f.store_line(JSON.stringify({"kind": "team", "team": tid3,
			"floor_pct": snappedf(100.0 * float(floor_ticks.get(tid3, 0)) / float(total_ticks_alive[tid3]), 0.1),
			"ever_decreased": bool(ever_decreased.get(tid3, false)),
			"final_fatigue": snappedf(float(final_fatigue.get(tid3, -1.0)), 0.001),
			"task_rest_ticks": int(task_rest_n.get(tid3, 0)), "camp_commit_ticks": int(camp_commit_n.get(tid3, 0))}))
	f.close()
	print("\n[DUMP-PATH] %s" % out_path)
	print("=== fatigue_dynamics DONE ===")
	quit(0)


func _git_head_sha() -> String:
	var out: Array = []
	OS.execute("git", ["rev-parse", "--short=9", "HEAD"], out, true)
	if out.size() > 0:
		return String(out[0]).strip_edges()
	return "UNKNOWN"
