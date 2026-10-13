extends SceneTree
# @bed-kind: diagnostic
# 多格移動走一格就停（spec 2026-10-13-multi-hop-move-stops-after-first-tile-HOW 第一顆：只查不改）
#   重現＝藍圖真跑同一串鍵（play.py 預設 seed 1337）：x w w enter m ＋ x×12 ＋ l
#   對玩家隊 move_target 的每一次寫入記：按第幾個鍵時、世界 tick、舊值→新值、寫入來源（arbiter 入口＋_source，或「直接寫」）；task 欄同一支觀察
#   ★2026-10-13 查到：tick 96 _evaluate_threat（loop3）→ _decide_unified(src=threat) 替玩家隊選「覓食」、move_target (9,0)→(10,2)
#   MT_SKIP_KEYS=1 MT_IDLE_HOURS=72 ⇒ 開場就閒置（玩家從不下令）：依來源統計 AI 對附身隊的寫入
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
	var keys: Array = [] if OS.get_environment("MT_SKIP_KEYS") == "1" else KEYS
	for i in range(keys.size()):
		var n0: int = TeamData.mt_log.size()
		await PlayerRepl.press_on(node, PlayerRepl.keycode_for(String(keys[i])))
		var pt: TeamData = st.teams.get(ptid)
		print("[MT] 鍵 %d「%s」｜tick %d｜位置 %s｜move_target %s｜task %s｜游標 %s" % [i, keys[i],
			node._bridge.get_current_tick(), str(pt.tile_pos), str(pt.move_target), str(pt.current_task), str(node._cursor)])
		for j in range(n0, TeamData.mt_log.size()):
			var e: Dictionary = TeamData.mt_log[j]
			print("[MT]    寫 %s：%s → %s ｜來源 %s" % [str(e["field"]), str(e["old"]), str(e["new"]), str(e["src"])])
		print("[MT]    之後 task_reason=%s" % str(pt.get("task_reason")))
	# ★第二段（MT_IDLE_HOURS＞0 才跑）：玩家什麼都不下，只按 x 推進 N 小時 ⇒ 依來源統計寫入（P5／P7 的母體）
	var idle_h: int = int(OS.get_environment("MT_IDLE_HOURS")) if OS.get_environment("MT_IDLE_HOURS") != "" else 0
	if idle_h > 0:
		var n1: int = TeamData.mt_log.size()
		for h in range(idle_h):
			await PlayerRepl.press_on(node, PlayerRepl.keycode_for("x"))
		var by_src: Dictionary = {}
		for j2 in range(n1, TeamData.mt_log.size()):
			var e2: Dictionary = TeamData.mt_log[j2]
			var k2: String = "%s｜%s" % [String(e2["field"]), String(e2["src"])]
			by_src[k2] = int(by_src.get(k2, 0)) + 1
		print("[MT] 閒置 %d 次 x（到 tick %d）：寫入 %d 筆" % [idle_h, node._bridge.get_current_tick(), TeamData.mt_log.size() - n1])
		var ks: Array = by_src.keys()
		ks.sort()
		for k3 in ks:
			print("[MT]    %s ×%d" % [k3, int(by_src[k3])])
	var fb = node.get("_feedback_line")
	print("[MT] 最後結果行：%s" % (String(fb.text) if fb != null else ""))
	print("=== multi_hop_move_writer_diag DONE ===")
	TeamData.mt_watch_tid = -9999
	quit(0)
