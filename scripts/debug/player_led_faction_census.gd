extends SceneTree
# @bed-kind: diagnostic
# slice: 你領導的勢力不自動定目標＋收編要告訴你（spec 2026-10-15-player-led-faction-no-ai-goals-and-subjugate-tells-HOW §驗收 census）——先量再改
# ★普查兩層，各 3 seed × 30 天，不判綠紅、只印數；修前修後各跑一次比：
#   ①無玩家世界（拔掉玩家）：NPC 勢力 goals 分佈、勢力外交入口／送出、十支入口次數、背叛評估／執行、收編次數 ⇒ 修前修後應逐項相同，
#     唯一已知差＝收編多喚醒敗方（事件 subjects 多一隊；次數≈subjugate.emit）。
#   ②有玩家世界（保留玩家）：只比 NPC 勢力（盟主隊非玩家控制）的同類分佈是否同量級；玩家那一側（pc）的計數＝預期變化，印出來。
# ★goals 分佈每小時掃一次 f.goals（_rebuild_goals 每勢力每小時重建；掃描不改被觀測物、不耗 RNG）。

const SEEDS: Array = [1337, 2026, 777]
const DAYS: int = 30
const PREFIXES: Array = ["side.call.", "dip.proactive_call.", "dip.send.", "dip.proposal_sent", "betray.consider.",
	"faction.leave.betrayal", "subjugate.emit", "faction.join.subjugate", "mp.decide.", "rootdiff.INTENT_ARMY_KIND_BONUS"]

func _initialize() -> void:
	print("=== player_led_faction census ｜ %d seed × %d 天 × 兩層 ===" % [SEEDS.size(), DAYS])
	for strip in [true, false]:
		print("── 層 %s ──" % ("①無玩家世界" if strip else "②有玩家世界"))
		for sd in SEEDS:
			seed(sd)
			var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/default.json", strip)
			var runner := SimRunner.new()
			var goal_hist: Dictionary = {}     # NPC 勢力：goal 型別 → 小時×勢力 次數
			var empty_hours: int = 0           # NPC 勢力：goals 為空的小時×勢力
			var pl_goal_hist: Dictionary = {}  # 玩家領導勢力：同上（②層才可能非 0）
			var pl_hours: int = 0
			var end_tick: int = st.world.current_tick + DAYS * WorldState.TICKS_PER_DAY
			while st.world.current_tick < end_tick:
				runner.advance_tick(st, Vector2i(-1, -1))
				if st.world.current_tick % WorldState.TICKS_PER_HOUR != 0:
					continue
				for fid in st.factions:
					var f = st.factions[fid]
					var lt: TeamData = st.teams.get(f.leader_team_id)
					var pl: bool = lt != null and lt.player_controlled
					if pl:
						pl_hours += 1
					elif f.goals.is_empty():
						empty_hours += 1
					for g in f.goals:
						var h: Dictionary = pl_goal_hist if pl else goal_hist
						h[String(g)] = int(h.get(String(g), 0)) + 1
			var parts: Array = []
			var ks: Array = Probe.counts.keys()
			ks.sort()
			for k in ks:
				for pre in PREFIXES:
					if String(k).begins_with(pre):
						parts.append("%s=%d" % [k, int(Probe.counts[k])])
						break
			var gk: Array = goal_hist.keys()
			gk.sort()
			var gs: Array = []
			for k in gk:
				gs.append("%s=%d" % [k, goal_hist[k]])
			print("seed %d｜tick %d｜勢力數 %d｜player_id %d" % [sd, st.world.current_tick, st.factions.size(), st.player_id])
			print("   NPC 勢力 goals（小時×勢力）：%s｜空 %d" % ["  ".join(PackedStringArray(gs)), empty_hours])
			print("   玩家領導勢力：小時 %d｜goals %s" % [pl_hours, str(pl_goal_hist)])
			print("   %s" % "  ".join(PackedStringArray(parts)))
	print("=== player_led_faction census DONE ===")
	quit()
