extends SceneTree
# member_tax_baseline_bed：income-tax-split 前置量測（2026-09-05，systems第⑤票）
# 目的：現制 collect_member_tax(coin_treasury.gd:81-96) 的稅收母體分佈——①總額②per-team
# ③PRODUCE隊佔多少④levy<=0被PERSONAL_COIN_FLOOR擋掉次數。
# 零production改動：走既有 WorldState.record_driver（reason="member_tax", kind="resource"）。
# ★陽性對照優先：driver_ledger 過去有 tap bug（record_driver_enabled沒真的開/被cross-run清空），
#   跑前必先驗 _ledger_seen(任何reason/kind的紀錄) > 0，抓不到就回報「儀器沒開」不回報0。
# ★④天生量不到：levy<=0 continue 那行沒有 record_driver 呼叫，ledger看不到「沒發生的事」——
#   如實回報「需要L3 tap」，不用總額反推（systems原信禁止）。
# 用法：BED_CONFIG(default res://config/peaceful_economy.json) BED_DAYS(default 90) BED_SEED(default 1337)

func _initialize() -> void:
	_run(); quit()

func _drain(state: WorldState, acc: Dictionary) -> void:
	var produce_team_ids: Dictionary = acc["produce_team_ids"]
	produce_team_ids.clear()
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.tags.has(TeamData.TAG_PRODUCE):
			produce_team_ids[tid] = true
	var per_team: Dictionary = acc["per_team"]
	for e in WorldState.driver_ledger:
		acc["ledger_seen"] = int(acc["ledger_seen"]) + 1
		if String(e.get("reason", "")) != "member_tax":
			continue
		var delta: float = float(e.get("delta", 0.0))
		if delta <= 0.0:
			continue   # 只算 team.coin+ 那一半（跟 person.coin- 那一半數值對稱，算一次即可）
		var ent = e.get("entity")
		if not (ent is TeamData):
			continue
		var tid2: int = ent.team_id
		acc["total_tax"] = float(acc["total_tax"]) + delta
		per_team[tid2] = float(per_team.get(tid2, 0.0)) + delta
		if produce_team_ids.has(tid2):
			acc["produce_total"] = float(acc["produce_total"]) + delta
	WorldState.clear_driver_ledger()

func _run() -> void:
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 90
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "res://config/peaceful_economy.json"
	var seed_val: int = int(OS.get_environment("BED_SEED")) if OS.has_environment("BED_SEED") else 1337
	seed(seed_val)
	WorldState.driver_ledger_enabled = true
	WorldState.clear_driver_ledger()
	var state: WorldState = MeasureBedHelper.arm_and_setup(cfg, true)
	var runner := SimRunner.new()
	var ticks: int = days * WorldState.TICKS_PER_DAY
	var no_player := Vector2i(-1, -1)

	# ★用 Dictionary 裝累計值（非 int/float 區域變數）——GDScript lambda 閉包對
	#   value-type 區域變數是值捕獲非參照，早前版本用 lambda 寫 _ledger_seen+=1 只改了
	#   閉包自己的副本，外層讀到的永遠是 0（本床自己踩過，已改用 Dictionary 參照型別修正，
	#   ★不是 production/工具問題，是我自己的床邏輯 bug，發現後直接修，未上呈假 0）。
	var acc: Dictionary = {
		"ledger_seen": 0, "total_tax": 0.0, "produce_total": 0.0,
		"per_team": {}, "produce_team_ids": {},
	}

	print("=== member_tax_baseline_bed: config=%s days=%d ticks=%d seed=%d ===" % [cfg, days, ticks, seed_val])

	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if tick % 2000 == 0 and tick > 0:
			_drain(state, acc)
			print("[CHECKPOINT] tick=%d ledger_seen累計=%d total_tax累計=%.1f teams=%d" % [
				tick, int(acc["ledger_seen"]), float(acc["total_tax"]), state.teams.size()])
	_drain(state, acc)
	WorldState.driver_ledger_enabled = false
	var _ledger_seen: int = int(acc["ledger_seen"])
	var total_tax: float = float(acc["total_tax"])
	var produce_total: float = float(acc["produce_total"])
	var per_team: Dictionary = acc["per_team"]
	var produce_team_ids: Dictionary = acc["produce_team_ids"]

	print("\n=== 結果 ===")
	if _ledger_seen <= 0:
		print("[FAIL] ★★★儀器對照失效：_ledger_seen=0，driver_ledger 沒開/沒抽到——本輪數字【全部作廢】，不得讀成『稅收=0』")
		print("=== member_tax_baseline_bed DONE ===")
		return
	print("[OK] 陽性對照：_ledger_seen=%d（非零，ledger 真的在記）" % _ledger_seen)
	print("①member_tax總額=%.2f" % total_tax)
	print("③PRODUCE隊佔=%.2f（%.1f%%）" % [produce_total, (produce_total / total_tax * 100.0) if total_tax > 0.0 else 0.0])
	print("④levy<=0被PERSONAL_COIN_FLOOR擋掉次數：★★★量不到——coin_treasury.gd:92-93 的 `if levy<=0: continue` 沒有 record_driver 呼叫，ledger看不到「沒發生的事」；需要一個L3 tap才能量，本床沒加（跨production scope，如實回報非總額反推）")
	print("②per-team明細（team_id: 稅收累計，只列非0，按稅收降冪）：")
	var team_ids_sorted: Array = per_team.keys()
	team_ids_sorted.sort_custom(func(a, b): return per_team[a] > per_team[b])
	for tid3 in team_ids_sorted:
		var tag_note: String = "PRODUCE" if produce_team_ids.has(tid3) else "非PRODUCE"
		print("  team=%d 稅收=%.2f [%s]" % [tid3, per_team[tid3], tag_note])
	print("=== member_tax_baseline_bed DONE ===")
