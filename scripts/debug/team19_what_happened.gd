extends SceneTree
# @bed-kind: diagnostic
# ★量測員派工（systems 2026-10-07，用戶問題，優先）：重現「人口已滿時接受求投靠」，
# 答「Team19跑去哪」。
#
# ★先讀碼找到的關鍵機制（本床驗證它是不是真的）：
#   player_command_system.gd:_accept_join_request —— capacity = effective_pop_cap - pt.population，
#   will_join = min(from_team.population, max(capacity,0))，will_join<=0 時直接回
#   {"ok":false,"msg":"隊伍已滿，無法收留"}——★在這個分支，SubteamSystem.merge_teams()跟
#   ResourceBank.add(扣食物)都【沒有被呼叫到】（return在它們之前）。
#   而respond_to_forced()結尾 state.player_forced_event={} 是【無條件】執行（不看result.ok），
#   代表求投靠的隊伍本身毫無變化，只是這次「求投靠」互動被玩家的[A]決定結束了。
#
# 做法：世界有玩家(seed1337)，把玩家隊人口灌到cap以上(AnonTierSystem.add_anon)，挑一支
# 真實存在的獨立隊(faction_id==-1)當「Team19」(teleport到玩家腳下,保留它原本完整欄位
# 避免手造假隊缺欄位讓後續AI tick出錯)，寫入join_request forced_event，呼叫
# PlayerCommandSystem.respond_to_forced(state,"accept")(跟真UI按[A]走同一條路)，
# 記錄前後數字，再推120tick觀察它的task序列與位置。
#
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/team19_what_happened.gd

const SEED: int = 1337
const BOOST_TIER: String = ""   # 跑時填 AnonTierSystem.TIER_ORDER[0]


func _initialize() -> void:
	var tree_sha: String = _git_head_sha()
	print("[TREE] HEAD=%s" % tree_sha)
	print("[SEED] %d｜殺玩家=否" % SEED)

	seed(SEED)
	var ws: WorldState = MeasureBedHelper.arm_and_setup("res://config/default.json", false)
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)

	var pt_id: int = ws.get_player_team_id()
	if pt_id == -1 or not ws.teams.has(pt_id):
		print("[HALT] 找不到玩家隊")
		quit(1)
		return
	var pt: TeamData = ws.teams[pt_id]

	print("\n========== 佈置 ==========")
	var cap: int = FactionAISystem.effective_pop_cap(ws, pt)
	print("玩家隊 Team%d｜改造前population=%d｜effective_pop_cap=%d" % [pt_id, pt.population, cap])

	# 灌到人口 >= cap（capacity<=0）
	var tier0: String = String(AnonTierSystem.TIER_ORDER[0])
	var need: int = max(cap - pt.population + 2, 1)
	AnonTierSystem.add_anon(pt, tier0, need)
	print("灌入 anon tier=%s ×%d → 改造後population=%d（cap=%d，capacity=%d，should<=0）" \
		% [tier0, need, pt.population, cap, cap - pt.population])

	# 挑一支真實存在的獨立隊當「Team19」，teleport 到玩家腳下
	var t19_id: int = -1
	for tid in ws.teams.keys():
		if int(tid) == pt_id:
			continue
		var t: TeamData = ws.teams[tid]
		if int(t.faction_id) == -1 and t.population > 0 and t.beast_kind == "":
			t19_id = int(tid)
			break
	if t19_id == -1:
		print("[HALT] 世界裡找不到任何獨立隊可當Team19類比")
		quit(1)
		return
	var t19: TeamData = ws.teams[t19_id]
	var t19_orig_pos: Vector2i = t19.tile_pos
	t19.tile_pos = pt.tile_pos   # teleport 同格（求投靠要求co-located）
	t19.move_target = Vector2i(-1, -1)
	print("選中 Team%d 當「Team19」類比（原位置%s → teleport到玩家腳下%s）｜population=%d｜task=%s" \
		% [t19_id, str(t19_orig_pos), str(pt.tile_pos), t19.population, t19.current_task])

	# ── 按 [A] 前快照 ──────────────────────────────────────────────────────────
	var pop_before: int = pt.population
	var food_before: float = float(pt.resources.get("food", 0.0))
	var t19_pop_before: int = t19.population
	var rep_pt_to_t19_before: float = float(pt.known_reputations.get(t19_id, 0.5))
	var rep_t19_to_pt_before: float = float(t19.known_reputations.get(pt_id, 0.5))

	ws.player_forced_event = {"action": "join_request", "from_id": t19_id}
	ws.player_forced_event_id = str(randi())

	var pcs := PlayerCommandSystem.new()
	var result: Dictionary = pcs.respond_to_forced(ws, "accept")

	print("\n========== 按下 [A]（accept）那一刻 ==========")
	print("回傳：ok=%s｜msg=%s" % [str(result.get("ok", null)), String(result.get("msg", ""))])

	var pop_after: int = pt.population
	var food_after: float = float(pt.resources.get("food", 0.0))
	var t19_pop_after: int = t19.population
	var rep_pt_to_t19_after: float = float(pt.known_reputations.get(t19_id, 0.5))
	var rep_t19_to_pt_after: float = float(t19.known_reputations.get(pt_id, 0.5))
	var t19_still_in_teams: bool = ws.teams.has(t19_id)

	print("玩家隊人口：%d → %d（Δ%d）" % [pop_before, pop_after, pop_after - pop_before])
	print("玩家隊食物：%.2f → %.2f（Δ%.2f）" % [food_before, food_after, food_after - food_before])
	print("Team%d 人口：%d → %d（Δ%d）｜還在ws.teams裡=%s" \
		% [t19_id, t19_pop_before, t19_pop_after, t19_pop_after - t19_pop_before, str(t19_still_in_teams)])
	print("關係帳：玩家對Team%d＝%.3f→%.3f｜Team%d對玩家＝%.3f→%.3f" % [
		t19_id, rep_pt_to_t19_before, rep_pt_to_t19_after, t19_id, rep_t19_to_pt_before, rep_t19_to_pt_after])
	print("player_forced_event 是否已清空：%s（%s）" % [
		str(ws.player_forced_event.is_empty()), str(ws.player_forced_event)])

	# ── 之後120tick（2小時）觀察Team19 ──────────────────────────────────────────
	print("\n========== Team19（Team%d）接下來120 tick的task序列與位置 ==========" % t19_id)
	var prev_task: String = ""
	var prev_pos: Vector2i = Vector2i(-999, -999)
	for i in range(120):
		runner.advance_tick(ws, no_player)
		if not ws.teams.has(t19_id):
			print("  tick=%d｜Team%d 已從 ws.teams 消失" % [i + 1, t19_id])
			break
		var t19b: TeamData = ws.teams[t19_id]
		var cur_task: String = String(t19b.current_task)
		if cur_task != prev_task or t19b.tile_pos != prev_pos:
			print("  tick=%d｜task=%-8s｜pos=%s｜pop=%d" % [ws.world.current_tick, cur_task, str(t19b.tile_pos), t19b.population])
			prev_task = cur_task
			prev_pos = t19b.tile_pos

	print("\n========== Team19 最終狀態 ==========")
	if ws.teams.has(t19_id):
		var t19c: TeamData = ws.teams[t19_id]
		print("仍存在｜task=%s｜pos=%s｜population=%d｜faction_id=%d" \
			% [t19c.current_task, str(t19c.tile_pos), t19c.population, t19c.faction_id])
	else:
		print("已從 ws.teams 消失（滅團／併入／其他 erase 路徑——具體哪一種本床沒細查）")

	print("\n=== team19_what_happened DONE ===")
	quit(0)


func _git_head_sha() -> String:
	var out: Array = []
	OS.execute("git", ["rev-parse", "--short=9", "HEAD"], out, true)
	if out.size() > 0:
		return String(out[0]).strip_edges()
	return "UNKNOWN"
