extends SceneTree

func _initialize() -> void:
	_run(); quit()

# Tier1 控制場景床（第二個，鏡射 pursuit_hiding_bed.gd）：churn tap 接線驗證
# （blueprint 授權建，2026-07-15）。純量測 debug script，零 production 邏輯改動。
#
# 故事：specimen 隊絕境（food 低）+ 完全孤立（世界只 1 格、無其他隊可達）→
# _trigger_survival 逐一嘗試 rank_survival 排序的求生選項，每個 finder 都撲空
# （to_task 回 (-1,-1)）→ SpecimenTracer 應記下 result="finder_miss" 的 attempt entry，
# 而非只有最終（可能沒有）committed entry——churn 在 specimen trace 裡直接現形。

func _run() -> void:
	print("=== churn-tap bed：finder_miss/try_set_noop 接線驗證 ===")
	var s := WorldState.new(); s.world = WorldData.new(); s.player_id = -1
	# 只 1 格世界：無鄰格可覓食/無市集/無鄰隊可掠奪投靠——逼所有 finder 撲空。
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(0, 0); tile.terrain = "plains"
	s.world.tiles[0] = tile   # unowned farmable → 紮營 applicable+finder 皆會成功（target 找得到）
	s.world.current_tick = 100

	var team := TeamData.new(); team.team_id = 1; team.tile_pos = Vector2i(0, 0)
	team.faction_id = -1; team.parent_team_id = 99   # 子隊→走 legacy _evaluate_survival body
	var ldr := PersonData.new(); ldr.id = 10; ldr.team_id = 1
	ldr.values = {"求生欲": 0.9}
	s.persons[10] = ldr; team.leader_id = 10
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", 3)
	team.resources = {"food": 0.0, "coin": 0.0}   # 絕境：無糧無錢
	# ★逼 try_set_noop：team 已持有 PRIO_SURVIVAL（另一 task）→ rank_survival 選中的新 option
	# 對 try_set 而言是「同-prio 搶位」，no-op（TaskArbiter 同-prio 拒），非 finder 撲空。
	team.current_task = TeamData.TASK_FLEE
	team.task_priority = TaskArbiter.PRIO_SURVIVAL
	s.teams[1] = team

	SpecimenTracer.reset(); SpecimenTracer.enabled = true
	s.specimen_team_ids = [1]

	var fai := FactionAISystem.new()
	fai._trigger_survival(s, team, "urgent")

	var arch: Array = SpecimenTracer._archive
	print("\n--- archive entries: %d ---" % arch.size())
	var results: Dictionary = {}
	for e in arch:
		var r: String = String(e.get("做什麼", {}).get("result", "(none)"))
		results[r] = int(results.get(r, 0)) + 1
		print("  opt=%s result=%s task=%s target=%s" % [
			e["做什麼"].get("winner_opt", "?"), r, e["做什麼"].get("task", "?"), str(e["做什麼"].get("target", "?"))])
	print("\n結果分布: %s" % str(results))
	if results.has("finder_miss") or results.has("try_set_noop"):
		print("★★confirm churn tap 接線正確：真實 _trigger_survival 路徑（非手呼 capture_decision）產出 finder_miss/try_set_noop entry")
	else:
		print("✗churn tap 未捕到 finder_miss/try_set_noop——場景可能沒逼出撲空，或 wiring 有缺，需再查")

	SpecimenTracer.enabled = false
	print("\n=== churn-tap bed DONE ===")
