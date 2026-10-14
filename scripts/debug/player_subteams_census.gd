extends SceneTree
# @bed-kind: diagnostic
# 玩家子隊票的先量（spec 2026-10-13-player-subteams-execute-given-tasks 三、四）：純觀測，不判對錯
#   ①NPC 子隊「抵達即歸建」閘（faction_ai `merge.blanket.<task>`）在 30 天世界 fire 幾次、各 task 分佈
#   ②自家人（譜系 TeamData.is_kin）外交：送出次數（kin.dip_send.<act>）、同格找上門（kin.forced_event.<act>）
#   ③自家人被選為最大威脅的次數（kin.threat_best）
#   ④獨立隊自家信使送不到令（herald.kin_nofaction_undelivered；送令只在 same_faction 分支，勢力 -1 永遠進不去）
#   ★tap 只在 Probe.enabled 時記；修前樹要先打上同一組 tap（只加 tap、不動行為）才比得起來
#   ★誠實限：default.json、帶玩家（玩家隊不下令＝閒置）；3 個 seed；遭遇以 draw 結束
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/player_subteams_census.gd
#   env PSC_DAYS（預設 30）、PSC_SEEDS（預設 "1337,2,3"）

const CFG: String = "res://config/default.json"


func _initialize() -> void:
	var days: int = int(OS.get_environment("PSC_DAYS")) if OS.get_environment("PSC_DAYS") != "" else 30
	var seeds_s: String = OS.get_environment("PSC_SEEDS") if OS.get_environment("PSC_SEEDS") != "" else "1337,2,3"
	print("=== player_subteams_census：%d 天 × seed %s ===" % [days, seeds_s])
	for s in seeds_s.split(","):
		_run(int(s), days)
	print("=== player_subteams_census END ===")
	quit(0)


func _run(sd: int, days: int) -> void:
	seed(sd)
	var st: WorldState = MeasureBedHelper.arm_and_setup(CFG, false)
	var runner := SimRunner.new()
	var first_stall: String = ""
	for i in range(days * WorldState.TICKS_PER_DAY):
		var p: TeamData = st.teams.get(st.get_player_team_id())
		var why: String = runner.advance_tick(st, p.tile_pos if p != null else Vector2i(-1, -1))
		if why != "" and first_stall == "":
			first_stall = "tick %d：%s" % [st.world.current_tick, why]
		if st.encounter_active:
			runner._encounter_system.resolve_encounter_end(st, "draw")
		st.player_forced_event = {}
	var c: Dictionary = Probe.counts
	var blanket: PackedStringArray = PackedStringArray()
	var kin: PackedStringArray = PackedStringArray()
	var keys: Array = c.keys()
	keys.sort()
	var blanket_n: int = 0
	for k in keys:
		var ks: String = String(k)
		if ks.begins_with("merge.blanket."):
			blanket.append("%s=%d" % [ks.trim_prefix("merge.blanket."), int(c[k])])
			blanket_n += int(c[k])
		elif (ks.begins_with("kin.") or ks == "herald.kin_nofaction_undelivered") and not ks.ends_with("_sample"):
			kin.append("%s=%d" % [ks, int(c[k])])
	print("\n── seed %d｜%d 天｜首次未推進 %s ──" % [sd, days, first_stall if first_stall != "" else "無"])
	print("   ①一律歸建閘 fire %d 次：%s" % [blanket_n, ", ".join(blanket) if not blanket.is_empty() else "（無）"])
	print("   ②③自家人：%s" % (", ".join(kin) if not kin.is_empty() else "kin.* 全 0（tap 有掛才算數：見下一行）"))
	print("   ★tap 掛了嗎：subteam.forage_arrived=%d（同一支 _evaluate_subteam 的既有 tap；0 ⇒ 子隊母體空，不是 kin 為 0）" % int(c.get("subteam.forage_arrived", 0)))
	for k in ["kin.dip_send", "kin.threat_best"]:
		var smp = Probe.samples.get(k, [])
		if smp is Array and not smp.is_empty():
			print("   樣本 %s：%s" % [k, str(smp.slice(0, 5))])
