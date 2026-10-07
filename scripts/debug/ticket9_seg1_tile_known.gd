extends SceneTree
# @bed-kind: diagnostic
# 票 #9 地圖記憶 段1（systems 派工 2026-10-07，唯讀量測）：
#   docs/superpowers/handbacks/2026-10-07-systems-to-measurer-DISPATCH-ticket9-seg1-tile-known.md
# 問題：玩家隊的 team_tile_known 是不是空的？——決定地圖記憶是純 render，
# 還是要把 harvest 搬到感知層（spec 2026-09-29-map-memory-and-godview-leak-HOW.md §2）
#
# ★先讀碼找到的關鍵機制（本床驗證它是不是真的）：
#   belief_system.gd:475 harvest_tile_known(state,team) 寫 state.team_tile_known[team.team_id]——
#   它只被四個呼叫端叫到：faction_ai_system.gd:7610(_find_occupy_target)、
#   goal_resolver.gd:1537(_harvest_tile_known delegate)、strategic_ai_system.gd:315、
#   以及 decision_context.gd 內的 DecisionContext.gather()（_find_occupy_target 在 gather() 內被呼）。
#   ★★而 DecisionContext.gather() 的唯一真實入口是 DecisionEngine.rank_scored() → _decide_unified()，
#   ★★★faction_ai_system.gd:4557 `_evaluate_solo_body`一進來就
#   `if team.leader_id == state.player_id: return   # 玩家隊不受 SoloAI 控制`——
#   這一行【在 _decide_unified 之前】return，而玩家隊預設 join_mode=independent（config/default.json:32,
#   faction_id=-1）⇒ 玩家隊走的正是這條 solo 路徑 ⇒ 若這條推論成立，
#   harvest_tile_known 應該【從來沒有被玩家隊呼叫過】，不管玩家隊實際走了多少格。
#   ★本床不只讀碼斷言——下面實際佈置一個玩家附身、真的移動的世界去量。
#
# ★★★【讀碼推論被實測推翻】——SoloAI 的玩家排除【不是】harvest 唯一的入口：
#   `faction_ai_system.gd:_evaluate_loop3_teams`（:1526）對 **state.teams 裡每一支隊**
#   （沒有玩家排除）在 `team.current_task==TASK_IDLE` 時會跑 G2c ambient 填格
#   （:1732 `DecisionContext.gather(state, team, ...)`），這條路【沒有】複製 SoloAI
#   那一行 player 守衛 ⇒ 玩家隊 IDLE 的那些 tick，harvest 照樣被呼。
#   ★實測：玩家隊 team_tile_known 在第1天就是 33（非 0），第3天長到 73——
#   ①>0，照 spec §2 判讀＝「地圖記憶可純 render」，與讀碼第一版預測的方向相反。
#   ★本床只確認「它不是空的」這個事實與量值，不追 1732 是不是故意要玩家也走到——
#   那是下一步的判斷，交派工的人。
#
# ★★★【意外撞到的機制】：第一輪跑到 tick≈7300 附近一場野獸遭遇戰玩家隊戰敗、
#   leader 死亡→觸發 choose_heir 強制事件（已知「玩家 leader 死可凍世界」），
#   世界從此卡在 tick=8543 不再前進（current_tick 恆定，不管再推多少次 advance_tick）
#   ——這不是本床的 bug，是既有機制；下面加了一段「任何強制事件自動選第一個選項」
#   讓 7 天長跑不被隨機事件卡住（★這不是迴避事件，是模擬玩家真的會按一個鍵）。
#
# ★★★相對照：`SimBridge.has_tile_intel()`(sim_bridge.gd:247) 不讀 team_tile_known——
#   它讀 team_discovered + BeliefSystem.best_estimate（別人回報的位置剛好等於那格），
#   是完全不同的一條線（單位位置信念，不是地塊/據點信念）。
#   `SimBridge.query_tile()`(sim_bridge.gd:189) 更直接：不經任何 belief，直讀 state.world.tiles——
#   這兩個是本床④⑤想分清楚的「地圖記憶到底有幾條線，哪條線玩家有、哪條沒有」的旁證，
#   ★不在本票判讀範圍內，只據實印出來。
#
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/ticket9_seg1_tile_known.gd

const DAYS_TO_WATCH: Array = [1, 3, 7]

var _visited: Dictionary = {}   # 玩家隊走過的不同 tile_id（母體地板③）


func _initialize() -> void:
	print("[TREE] HEAD=%s" % _git_head_sha())
	seed(20261007)

	var ws: WorldState = MeasureBedHelper.arm_and_setup("res://config/default.json", false)
	var runner := SimRunner.new()
	var bridge := SimBridge.new(runner, ws)

	var pt_id: int = ws.get_player_team_id()
	if pt_id == -1 or not ws.teams.has(pt_id):
		print("[HALT] 找不到玩家隊（player_id=%d）" % ws.player_id)
		quit(1)
		return
	var pt: TeamData = ws.teams[pt_id]
	print("玩家隊 Team%d｜faction_id=%d（join_mode=independent 預期 -1）｜起點=%s" \
		% [pt_id, pt.faction_id, str(pt.tile_pos)])

	var npc_id: int = -1
	for tid in ws.teams.keys():
		if int(tid) == pt_id:
			continue
		var t: TeamData = ws.teams[tid]
		if t.leader_id != -1:
			npc_id = int(tid)
			break
	if npc_id == -1:
		print("[HALT] 找不到可對照的 NPC 隊")
		quit(1)
		return
	print("對照 NPC 隊：Team%d｜faction_id=%d｜起點=%s" \
		% [npc_id, ws.teams[npc_id].faction_id, str(ws.teams[npc_id].tile_pos)])

	_visited[_tile_id(pt.tile_pos)] = true

	# ★地圖邊界從世界本身量出來（不手猜 radius 怎麼映射座標）——
	#   第一版猜 ±30 全部落在地圖外，move_to 每個 tick 都被判無效、move_target 從沒設上過，
	#   玩家隊走了 0 格。這裡誠實記下來，不默默改。
	var min_x: int = 999999; var max_x: int = -999999
	var min_y: int = 999999; var max_y: int = -999999
	for tid in ws.world.tiles:
		var tp: Vector2i = (ws.world.tiles[tid] as HexTileData).tile_pos
		min_x = mini(min_x, tp.x); max_x = maxi(max_x, tp.x)
		min_y = mini(min_y, tp.y); max_y = maxi(max_y, tp.y)
	print("地圖邊界（從 world.tiles 量出）：x∈[%d,%d]｜y∈[%d,%d]" % [min_x, max_x, min_y, max_y])
	var _corners: Array = [
		Vector2i(min_x, min_y), Vector2i(max_x, max_y),
		Vector2i(max_x, min_y), Vector2i(min_x, max_y),
	]

	# ★玩家隊走法：真的透過玩家指令路徑（SimBridge.command_player "move_to"）發令，
	#   之後用 runner.advance_tick 自己逐 tick 推（不借 bridge.advance_ticks——它一遇到
	#   「新發現」事件就會整批提前停，7 天長跑會被切成很多段，而本床只關心「走了幾格、
	#   team_tile_known 變了沒」，不需要事件逐條攔截；此偏離如實寫在這裡不默默做）。
	var leg: int = 0
	var day_idx: int = 0
	var target_ticks: int = DAYS_TO_WATCH[DAYS_TO_WATCH.size() - 1] * WorldState.TICKS_PER_DAY
	# ★★用世界自己的 current_tick 當天數判準，不用迴圈計數 i——
	#   第一版用 (i+1) 判天，而第 5 天附近撞上一場野獸遭遇戰，advance_tick 那幾拍沒有
	#   把 current_tick 推滿（遭遇戰自己的子時鐘），結果迴圈跑滿 10080 次但 current_tick
	#   只到 8543，第 7 天的卷面其實是「第 5.9 天」。改錨到 current_tick 本身，
	#   並放寬迴圈上限（給遭遇戰吃掉的那些空轉留餘裕），才是誠實的「第 7 天」。
	var safety_cap: int = target_ticks * 3
	var i: int = 0
	var forced_answered: int = 0
	var pcs := PlayerCommandSystem.new()
	while ws.world.current_tick < target_ticks and i < safety_cap:
		# ★強制事件自動選第一個選項（choose_heir 等）——不然撞到就卡死不前進（見上方註解）。
		if not ws.player_forced_event.is_empty():
			var opts: Array = pcs.get_forced_response_options(ws)
			var resp: String = String(opts[0]) if not opts.is_empty() else "refuse"
			var fr: Dictionary = pcs.respond_to_forced(ws, resp)
			forced_answered += 1
			print("  [forced_event] action=%s｜自動選「%s」｜ok=%s｜msg=%s" % [
				String(ws.player_forced_event.get("action", "")), resp,
				str(fr.get("ok", null)), String(fr.get("msg", "")).substr(0, 60)])
		if pt.move_target == Vector2i(-1, -1) and ws.teams.has(pt_id):
			leg += 1
			var dest: Vector2i = _corners[(leg - 1) % _corners.size()]
			var r: Dictionary = bridge.command_player("move_to", {"tile_q": dest.x, "tile_r": dest.y})
			if leg <= 3 or Probe.enabled:
				print("  [move_to] leg=%d｜從%s 設目標→%s｜queued=%s" \
					% [leg, str(pt.tile_pos), str(dest), str(r.get("queued", false))])
		runner.advance_tick(ws, pt.tile_pos)
		i += 1
		if not ws.teams.has(pt_id):
			print("[HALT] 玩家隊在 tick=%d 從 ws.teams 消失" % ws.world.current_tick)
			break
		_visited[_tile_id(pt.tile_pos)] = true
		if day_idx < DAYS_TO_WATCH.size() \
				and ws.world.current_tick >= DAYS_TO_WATCH[day_idx] * WorldState.TICKS_PER_DAY:
			_snapshot(ws, pt_id, npc_id, DAYS_TO_WATCH[day_idx])
			day_idx += 1
	if i >= safety_cap:
		print("[HALT] 撞 safety_cap(%d) 仍未到第 7 天（current_tick=%d）——放棄湊滿，誠實回報" \
			% [safety_cap, ws.world.current_tick])

	print("\n=== ticket9_seg1_tile_known DONE｜共發了 %d 段 move_to 指令｜自動回應 %d 個強制事件 ===" \
		% [leg, forced_answered])
	quit(0)


func _tile_id(p: Vector2i) -> int:
	return p.x * 1000 + p.y


func _snapshot(ws: WorldState, pt_id: int, npc_id: int, day: int) -> void:
	print("\n========== 第 %d 天結束（tick=%d）==========" % [day, ws.world.current_tick])

	# ①②：team_tile_known 大小（玩家 vs NPC）
	var pt_known: int = int(ws.team_tile_known.get(pt_id, {}).size())
	var npc_known: int = int(ws.team_tile_known.get(npc_id, {}).size())
	print("①玩家隊 team_tile_known.size() ＝ %d" % pt_known)
	print("②NPC(Team%d) team_tile_known.size() ＝ %d" % [npc_id, npc_known])

	# ③：玩家隊走過的不同格數（母體地板）
	print("③玩家隊走過的不同格數（累計至今）＝ %d" % _visited.size())

	# ④：team_market_known + known_outposts
	var pt_market: int = int(ws.team_market_known.get(pt_id, {}).size())
	var pt_outposts: int = BeliefSystem.known_outposts(ws, pt_id).size()
	print("④玩家隊 team_market_known.size() ＝ %d｜BeliefSystem.known_outposts().size() ＝ %d" \
		% [pt_market, pt_outposts])

	# ⑤：team_discovered 裡每支隊的 belief_pos 是否 ≠(-1,-1)
	var discovered: Array = ws.team_discovered.get(pt_id, [])
	var resolvable: int = 0
	for tid in discovered:
		var est: Dictionary = BeliefSystem.best_estimate(ws, pt_id, int(tid))
		if est.get("tile_pos", Vector2i(-1, -1)) != Vector2i(-1, -1):
			resolvable += 1
	print("⑤team_discovered[玩家隊] 共 %d 支，其中 belief_pos≠(-1,-1) 的 %d 支（%s）" \
		% [discovered.size(), resolvable,
			("%.0f%%" % (100.0 * resolvable / discovered.size())) if discovered.size() > 0 else "母體=0"])


func _git_head_sha() -> String:
	var out: Array = []
	var rc: int = OS.execute("git", ["rev-parse", "--short=9", "HEAD"], out, true)
	if rc != 0 or out.is_empty():
		return "UNKNOWN"
	return String(out[0]).strip_edges()
