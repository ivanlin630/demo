extends SceneTree
# @bed-kind: diagnostic
# slice: 戰後收尾（spec 2026-10-14-battle-aftermath-wounded-captives-pursuit-HOW §2c：容量一支）——先量再改
# ★普查：NPC 對 NPC 世界（拔掉玩家）3 seed × 30 天，量潰逃俘虜（capture_routed_as_captive）的實俘數，
#   以及「俘了又被 enforce 處置」（asm.guardcap_forced）與「養不起放走」（asm.released）次數。
#   ★不判綠紅、只印數；修前修後各跑一次比（spec：跌到 0 或腰斬 ⇒ 停手回 systems）。
# ★潰逃俘虜沒有 tap ⇒ 每 tick 結束時掃每隊 captive_groups，新出現（物件身分沒看過）且 entry＝"潰逃-capture" 的 group
#   加總它的 cohorts ⇒ 那就是那一次 capture_routed 的實俘數（group 在捕獲當下 append；之後同化／逃跑只會變少，
#   所以要在 append 那一個 tick 讀——每 tick 掃一次就是這個用途）。不動產線 code。

const SEEDS: Array = [1337, 2026, 777]
const DAYS: int = 30

func _initialize() -> void:
	print("=== battle_aftermath census：潰逃俘虜／enforce／養不起 ｜ %d seed × %d 天 ===" % [SEEDS.size(), DAYS])
	var sum_events: int = 0
	var sum_caps: int = 0
	for sd in SEEDS:
		seed(sd)
		var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/default.json", true)
		var runner := SimRunner.new()
		var seen_groups: Array = []
		var events: int = 0
		var caps: int = 0
		var per_entry: Dictionary = {}
		var end_tick: int = st.world.current_tick + DAYS * WorldState.TICKS_PER_DAY
		while st.world.current_tick < end_tick:
			runner.advance_tick(st, Vector2i(-1, -1))
			for tid in st.teams:
				var t: TeamData = st.teams[tid]
				for g in t.captive_groups:
					# ★已見清單放在床裡（is_same＝同一個 Dictionary 物件）；不在 group 上標記——觀測不得改被觀測物
					if seen_groups.any(func(x): return is_same(x, g)):
						continue
					seen_groups.append(g)
					var n: int = AnonCohort.total(g.get("cohorts", {}))
					var e: String = String(g.get("entry", "?"))
					per_entry[e] = int(per_entry.get(e, 0)) + n
					if e == "潰逃-capture":
						events += 1
						caps += n
		sum_events += events
		sum_caps += caps
		var asm: Array = []
		var ks: Array = Probe.counts.keys()
		ks.sort()
		for k in ks:
			if String(k).begins_with("asm.") or String(k).begins_with("p1.") or String(k).begins_with("pursuit."):
				asm.append("%s=%d" % [k, int(Probe.counts[k])])
		print("seed %d｜tick %d｜潰逃俘虜 %d 次、共 %d 人｜各 entry 新 group 人數 %s" % [sd, st.world.current_tick, events, caps, str(per_entry)])
		print("   %s" % "  ".join(PackedStringArray(asm)))
	print("── 合計：潰逃俘虜 %d 次、共 %d 人 ──" % [sum_events, sum_caps])
	print("=== battle_aftermath census DONE ===")
	quit()
