extends SceneTree
# @bed-kind: diagnostic
# 情報面板 追加（spec 2026-10-13-intel-panel-HOW「打聽回答要列內容」：先量三態判定的母體）
# ★普查：玩家打聽時，結果句落在哪一支、為什麼。不是驗收床（不判綠紅），只印數。
#   佈置：同 seed 世界推到第 2 天 02:00（藍圖真玩那一刻）；對每一支活著的 NPC、三個會寫 belief 的題目各問一次
#   ★每次問之前把玩家側被打聽寫入的三份帳還原（team_intel／team_known／team_discovered 的玩家那一格）⇒ 每次都是同一個起點
#   ★玩家隊搬到 NPC 那一格（普查佈置，不是遊戲路徑）
#   印：mode、給方對玩家的口碑 rep2（< 0.3 且非同勢力 ⇒ claims 段提早 return）、給方 known_targets 數、
#       回答 payload 筆數、claims 段該處理的筆數（扣掉玩家自己／敵人題的同勢力）、written／refreshed／conflicted、結果句

const SEED: int = 1337
const TOPICS: Array = ["ask_team_location", "ask_enemy_movement", "ask_recent_events"]

func _initialize() -> void:
	seed(SEED)
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/default.json", false)
	Probe.enabled = false
	var runner := SimRunner.new()
	var ptid: int = st.get_player_team_id()
	while st.world.current_tick < WorldState.TICKS_PER_DAY + 120:
		runner.advance_tick(st, st.teams[ptid].tile_pos)
	var pt: TeamData = st.teams[ptid]
	var home: Vector2i = pt.tile_pos
	var snap: Dictionary = _snap(st, ptid)
	print("=== inquiry_three_state census｜seed %d｜tick %d｜玩家 Team%d @%s 已知 %s ===" % [SEED, st.world.current_tick, ptid,
		str(home), str(BeliefSystem.known_targets(st, ptid))])
	var tally: Dictionary = {}
	var n: int = 0
	for tid in st.teams.keys():
		if int(tid) == ptid or not st.is_live_team(int(tid)):
			continue
		var npc: TeamData = st.teams[tid]
		for topic in TOPICS:
			_restore(st, ptid, snap)
			pt.tile_pos = npc.tile_pos
			var rep2: float = float(npc.known_reputations.get(ptid, 0.5))
			var rep_gate: bool = rep2 < 0.3 and (npc.faction_id == -1 or npc.faction_id != pt.faction_id)
			var considered: int = 0
			for g in BeliefSystem.known_targets(st, int(tid)):
				if int(g) == ptid: continue
				if topic == "ask_enemy_movement":
					var t2: TeamData = st.teams.get(g)
					if t2 == null or TeamData.same_faction(t2, pt): continue
				considered += 1
			st.player_state["gather_intel_npc_id"] = int(tid)
			st.player_state["gather_intel_choice"] = topic
			var out: Dictionary = {}
			var res: Dictionary = _confirm(st, int(tid), pt, ptid, out)
			var msg: String = String(res.get("msg", ""))
			var pl: Dictionary = res.get("payload", {})
			var pn: int = 0
			for k in pl:
				if pl[k] is Array: pn += (pl[k] as Array).size()
			var gk: Array = BeliefSystem.known_targets(st, int(tid))
			print("Team%d @%s｜%s｜rep2 %.2f%s｜給方知 %d %s（含玩家自己＝%s）｜回答 %d 筆｜claims 該處理 %d｜「%s」" % [int(tid),
				str(npc.tile_pos), topic, rep2, "（擋 claims）" if rep_gate else "", gk.size(), str(gk), str(gk.has(ptid)), pn,
				considered, msg])
			var key: String = "%s｜%s%s" % [topic, msg.get_slice("（", 0), "｜rep 擋" if rep_gate else ""]
			tally[key] = int(tally.get(key, 0)) + 1
			n += 1
	pt.tile_pos = home
	print("── 分佈（%d 次打聽）──" % n)
	var keys: Array = tally.keys()
	keys.sort()
	for k in keys:
		print("   %3d  %s" % [int(tally[k]), k])
	print("=== inquiry_three_state census DONE ===")
	quit()

# 真的那條指令路徑（結果句由它組）；out 是看不到的 ⇒ 句子本身就是分支的證據
func _confirm(st: WorldState, tid: int, pt: TeamData, ptid: int, _out: Dictionary) -> Dictionary:
	return PlayerCommandSystem.new()._action_confirm_gather_intel(st, tid, pt, ptid)

func _snap(st: WorldState, ptid: int) -> Dictionary:
	return {"intel": (st.team_intel.get(ptid, {}) as Dictionary).duplicate(true),
		"known": (st.team_known.get(ptid, []) as Array).duplicate(),
		"disc": (st.team_discovered.get(ptid, []) as Array).duplicate()}

func _restore(st: WorldState, ptid: int, s: Dictionary) -> void:
	st.team_intel[ptid] = (s["intel"] as Dictionary).duplicate(true)
	st.team_known[ptid] = (s["known"] as Array).duplicate()
	st.team_discovered[ptid] = (s["disc"] as Array).duplicate()
