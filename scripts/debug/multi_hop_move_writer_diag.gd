extends SceneTree
# @bed-kind: diagnostic
# 多格移動走一格就停（spec 2026-10-13-multi-hop-move-stops-after-first-tile-HOW 第一顆：只查不改）
#   重現＝藍圖真跑同一串鍵（play.py 預設 seed 1337）：x w w enter m ＋ x×12 ＋ l
#   對玩家隊 move_target 的每一次寫入記：按第幾個鍵時、世界 tick、舊值→新值、寫入當下的 task／task_reason
#   ★2026-10-13 查到：tick 96 _evaluate_threat（loop3）→ _decide_unified(src=threat) 替玩家隊選「覓食」、move_target (9,0)→(10,2)
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/multi_hop_move_writer_diag.gd

const KEYS: Array = ["x", "w", "w", "enter", "m", "x", "x", "x", "x", "x", "x", "x", "x", "x", "x", "x", "x", "l"]


func _initialize() -> void:
	var sd: int = int(OS.get_environment("REPL_SEED")) if OS.get_environment("REPL_SEED") != "" else 1337
	seed(sd)
	var node: Node = load("res://scenes/TextUI.tscn").instantiate()
	get_root().add_child(node)
	await process_frame
	await process_frame
	node._refresh()
	var st: WorldState = node._bridge._state
	var ptid: int = st.get_player_team_id()
	TeamData.mt_watch_tid = ptid
	TeamData.mt_log.clear()
	print("[MT] seed=%d 玩家隊 Team%d 起點 %s" % [sd, ptid, str(st.teams[ptid].tile_pos)])
	var pt0: TeamData = st.teams[ptid]
	var f0 = st.factions.get(pt0.faction_id)
	print("[MT] 玩家隊 faction_id=%d｜勢力 leader_team=%s｜member_team_ids 含玩家隊=%s｜tags=%s｜uses_unified=%s｜parent=%d｜player_commanded_task=「%s」" % [
		pt0.faction_id, str(f0.leader_team_id) if f0 != null else "—", str(f0.member_team_ids.has(ptid)) if f0 != null else "—",
		str(pt0.tags), str(FactionAISystem.shared().uses_unified(pt0)), pt0.parent_team_id, pt0.player_commanded_task])
	for i in range(KEYS.size()):
		var n0: int = TeamData.mt_log.size()
		await PlayerRepl.press_on(node, PlayerRepl.keycode_for(String(KEYS[i])))
		var pt: TeamData = st.teams.get(ptid)
		print("[MT] 鍵 %d「%s」｜tick %d｜位置 %s｜move_target %s｜task %s｜游標 %s" % [i, KEYS[i],
			node._bridge.get_current_tick(), str(pt.tile_pos), str(pt.move_target), str(pt.current_task), str(node._cursor)])
		for j in range(n0, TeamData.mt_log.size()):
			var e: Dictionary = TeamData.mt_log[j]
			print("[MT]    寫入 %s → %s ｜寫入當下 task=%s reason=%s" % [str(e["old"]), str(e["new"]), str(e["task"]), str(e["reason"])])
		print("[MT]    之後 task_reason=%s" % str(pt.get("task_reason")))
	var fb = node.get("_feedback_line")
	print("[MT] 最後結果行：%s" % (String(fb.text) if fb != null else ""))
	print("=== multi_hop_move_writer_diag DONE ===")
	TeamData.mt_watch_tid = -9999
	quit(0)
