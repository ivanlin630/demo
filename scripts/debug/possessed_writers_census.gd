extends SceneTree
# @bed-kind: diagnostic
# 附身隊後續 丙（spec 2026-10-13-possessed-team-followups-HOW §丙）：loop3 對附身隊還會寫哪些非 task 欄位——跑出來，不靠讀碼
#   TeamData 帶 setter 的那批欄位（決策節奏／求生承諾／野心／追擊目標／據點駐留／裝備／危機免疫窗／持守…）
#   ＋FailureMemory.record、CoinTreasury.consider_extraction 兩個函式層計數，對被觀察隊（＝附身隊）每寫一次計一次（含同值）
#   情形：
#     lead    ＝玩家當自己隊的隊長（開局常態）
#     member  ＝玩家被邀入一支 NPC 當隊長的隊（附身隊的隊長不是玩家 ⇒ 以 leader_id==player_id 擋的那幾道門不生效）
#   每情形印：欄位 → 寫入次數／值有變的次數／前 5 筆（tick、舊、新）；命中 0 的欄位逐條列（＝這組世界裡走不到）
#   ★誠實限：遭遇以 draw 結束；30 天兩個種子；命中 0 只對這組世界成立
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/possessed_writers_census.gd
#   env PWC_SEEDS（預設 "1337,2"）／PWC_DAYS（預設 30）

const WATCHED: Array = ["decision_eval_next_tick", "previous_task", "current_option", "order_target_id", "order_task",
	"survival_committed_option", "survival_committed_tick", "survival_committed_food", "ambition_rung",
	"prosperity_target_id", "occupying_outpost_since", "residency_eval_next_tick", "pending_owner_change_tick",
	"mobilized_fraction", "equip_order", "armor_config", "guard_ratio", "crisis_released_task", "crisis_released_until",
	"crisis_committed_tick", "crisis_committed_food", "persist_strength", "last_decision_tick"]

func _initialize() -> void:
	var seeds: Array = []
	for s in OS.get_environment("PWC_SEEDS").split(",", false):
		seeds.append(int(s))
	if seeds.is_empty():
		seeds = [1337, 2]
	var days: int = int(OS.get_environment("PWC_DAYS")) if OS.get_environment("PWC_DAYS") != "" else 30
	print("=== possessed_writers_census：附身 %d 天、附身隊非 task 欄位的寫入 ===" % days)
	var total: Dictionary = {}
	for sd in seeds:
		for mode in ["lead", "member"]:
			var h: Dictionary = _run(int(sd), mode, days)
			for k in h:
				var key: String = "%s｜%s" % [mode, k]
				total[key] = int(total.get(key, 0)) + int((h[k] as Dictionary)["n"])
	print("\n── 彙總（各種子相加）──")
	for mode in ["lead", "member"]:
		var hit: Array = []
		var zero: Array = []
		for f in WATCHED:
			var n: int = int(total.get("%s｜%s" % [mode, f], 0))
			if n > 0:
				hit.append("%s×%d" % [f, n])
			else:
				zero.append(f)
		var fn: Array = []
		for k in total:
			if String(k).begins_with(mode + "｜") and not WATCHED.has(String(k).substr(mode.length() + 1)):
				fn.append("%s×%d" % [String(k).substr(mode.length() + 1), int(total[k])])
		print("   %s 有寫：%s" % [mode, ", ".join(hit)])
		print("   %s 函式層：%s" % [mode, ", ".join(fn) if not fn.is_empty() else "（0）"])
		print("   %s 命中 0：%s" % [mode, ", ".join(zero)])
	print("=== possessed_writers_census DONE ===")
	TeamData.mt_watch_tid = -9999
	quit(0)


func _run(sd: int, mode: String, days: int) -> Dictionary:
	seed(sd)
	var st := WorldState.new()
	GameSetup.setup(st, GameSetup.load_config("res://config/default.json"))
	var note: String = ""
	if mode == "member":
		var pid0: int = st.get_player_team_id()
		var other: TeamData = null
		var ids: Array = st.teams.keys()
		ids.sort()
		for tid in ids:
			var t: TeamData = st.teams[tid]
			if int(tid) != pid0 and t.leader_id != -1 and t.beast_kind == "" and t.parent_team_id == -1:
				other = t
				break
		st.remove_member(st.teams[pid0], st.player_id, false)
		st.add_member(other, st.player_id)
		note = "（玩家移入 T%d，隊長 %d）" % [other.team_id, other.leader_id]
	TeamData.mt_hits.clear()
	var runner := SimRunner.new()
	var start: int = st.world.current_tick
	var enc: int = 0
	var froze: int = -1
	var moved: int = 0
	var watch: int = st.get_player_team_id()
	TeamData.mt_watch_tid = watch
	for i in range(days * WorldState.TICKS_PER_DAY):
		TeamData.mt_now = st.world.current_tick
		var p: TeamData = st.teams.get(st.get_player_team_id())
		var res: String = runner.advance_tick(st, p.tile_pos if p != null else Vector2i(-1, -1))
		if st.encounter_active:
			enc += 1
			runner._encounter_system.resolve_encounter_end(st, "draw")
		if res == "awaiting_heir":
			froze = st.world.current_tick
			break
		if st.get_player_team_id() != watch:
			moved += 1
			watch = st.get_player_team_id()
			TeamData.mt_watch_tid = watch   # ★附身隊換了（被併等）⇒ 跟著換觀察對象
	var h: Dictionary = TeamData.mt_hits.duplicate(true)
	TeamData.mt_watch_tid = -9999
	var pt: TeamData = st.teams.get(st.get_player_team_id())
	print("\n── seed %d｜%s%s｜tick %d→%d｜附身隊 T%d possessed=%s｜換隊 %d｜遭遇 draw %d｜凍結 %d ──" % [sd, mode, note, start,
		st.world.current_tick, st.get_player_team_id(), str(pt.possessed if pt != null else false), moved, enc, froze])
	var keys: Array = h.keys()
	keys.sort()
	for k in keys:
		var e: Dictionary = h[k]
		print("   %-34s 寫 %6d｜變 %5d｜%s" % [k, int(e["n"]), int(e["changed"]),
			str((e["first"] as Array).map(func(x): return "t%d %s→%s" % [int(x["tick"]), String(x["old"]).substr(0, 24), String(x["new"]).substr(0, 24)]))])
	return h
