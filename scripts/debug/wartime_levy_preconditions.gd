extends SceneTree
# @bed-kind: diagnostic
# ★量測員派工（systems 2026-10-06，藍圖裁 ae23c656c，票R改題「戰時徵用」）：
# Team7 被抽的 11 刀（Team5×9／Team39×1／Team36×1，reason=raid_out/raid_in），
# 每一刀印：①當下勢力1有沒有任何應急/戰爭宣告狀態(fund_war) ②收稅者是不是勢力1的盟主
# ③扣後Team7庫存是否低於生存儲備(既有絕境門檻：food_days<DecisionTerms.DESPERATION_DAYS，
# 只讀既有函式不另抄常數)。
#
# 帳本：raid_out走set_amt(記新值不記delta)，用既有逐entry重建法處理，卷面標出哪些是重建的。
#
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/wartime_levy_preconditions.gd

const SEED: int = 1337
const TOTAL_TICKS: int = 30 * 1440
const TEAM7: int = 7
const EVENTS: Array = [
	{"tick": 18420, "collector": 5}, {"tick": 20160, "collector": 5}, {"tick": 20220, "collector": 5},
	{"tick": 25260, "collector": 5}, {"tick": 25320, "collector": 5}, {"tick": 26640, "collector": 39},
	{"tick": 27360, "collector": 36}, {"tick": 27660, "collector": 5}, {"tick": 31200, "collector": 5},
	{"tick": 31680, "collector": 5}, {"tick": 31800, "collector": 5},
]
const SET_AMT_REASONS: Array = [
	"loot_mounts_out", "loot_horses_out", "equip_named", "unequip_named", "weapon_recover_anon",
	"auto_withdraw_mounts", "npc_withdraw_vault", "npc_deposit_vault", "init_starting", "init_preset",
	"readiness_food", "raid_out", "aid_out", "deposit_storage", "recruit_anon_pay", "recruit_named_pay",
	"player_take", "overflow_split", "eat_team", "eat_depleted", "provision_carry",
	"spend_holding_team", "subteam_split_in", "merge_absorb_out",
]


func _initialize() -> void:
	var tree_sha: String = _git_head_sha()
	print("[TREE] HEAD=%s" % tree_sha)
	print("[SEED] %d｜殺玩家=否" % SEED)

	seed(SEED)
	var ws: WorldState = MeasureBedHelper.arm_and_setup("res://config/default.json", false)
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)

	WorldState.driver_ledger_enabled = true
	WorldState.clear_driver_ledger()

	var events_by_tick: Dictionary = {}
	for ev in EVENTS:
		events_by_tick[int(ev["tick"])] = ev

	var prev_res: Dictionary = {}   # team_id → {food,goods,coin}
	for tid0 in ws.teams.keys():
		prev_res[int(tid0)] = _snap(ws.teams[tid0])

	var results: Array = []

	for _i in range(TOTAL_TICKS):
		runner.advance_tick(ws, no_player)
		var cur_tick: int = ws.world.current_tick

		if events_by_tick.has(cur_tick):
			var ev2: Dictionary = events_by_tick[cur_tick]
			var collector_id: int = int(ev2["collector"])

			# ── 重建這一tick Team7的 food/coin/goods 逐entry真delta ───────────────
			var entries_plain: Array = []
			var pre: Dictionary = prev_res.get(TEAM7, {})
			var running: Dictionary = {"food": float(pre.get("food", 0.0)), "goods": float(pre.get("goods", 0.0)),
				"coin": float(pre.get("coin", 0.0))}
			for entry in WorldState.driver_ledger:
				var ent = entry["entity"]
				if not (ent is TeamData) or int(ent.team_id) != TEAM7:
					continue
				var field: String = String(entry["field"])
				if not running.has(field):
					continue
				var reason: String = String(entry["reason"])
				var is_sa: bool = SET_AMT_REASONS.has(reason)
				var before: float = float(running[field])
				if is_sa:
					running[field] = float(entry["delta"])
				else:
					running[field] = before + float(entry["delta"])
				entries_plain.append({"field": field, "reason": reason, "is_set_amt": is_sa,
					"rebuilt_delta": snappedf(float(running[field]) - before, 0.01)})

			# ① 勢力1 fund_war 應急/戰爭宣告狀態
			var f1 = ws.factions.get(1)
			var fund_war_active: bool = false
			var goals_now: Array = []
			if f1 != null:
				goals_now = (f1.goals as Array).duplicate()
				for g in goals_now:
					var gd: Dictionary = f1.goal_drivers.get(g, {})
					if String(gd.get("mode", "")) == "fund_war":
						fund_war_active = true
						break

			# ② 收稅者是不是勢力1的盟主
			var is_liege: bool = (f1 != null and int(f1.leader_team_id) == collector_id)
			var liege_id: int = int(f1.leader_team_id) if f1 != null else -999

			# ③ 扣後 Team7 庫存是否低於生存儲備（絕境門檻，既有函式，不抄常數）
			var t7: TeamData = ws.teams.get(TEAM7)
			var food_days: float = -1.0
			var below_reserve: bool = false
			if t7 != null:
				var eff_food: float = ResourceSystem.effective_food(ws, t7)
				var pop_need: float = maxf(float(t7.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY, 0.001)
				food_days = eff_food / pop_need
				below_reserve = food_days < DecisionTerms.DESPERATION_DAYS

			results.append({"tick": cur_tick, "collector": collector_id, "payer": TEAM7,
				"fund_war_active": fund_war_active, "faction1_goals": goals_now,
				"collector_is_liege": is_liege, "liege_team_id": liege_id,
				"food_days_after": snappedf(food_days, 0.01), "desperation_days_threshold": DecisionTerms.DESPERATION_DAYS,
				"below_reserve_after": below_reserve, "ledger_entries": entries_plain})

		WorldState.clear_driver_ledger()
		for tid1 in ws.teams.keys():
			prev_res[int(tid1)] = _snap(ws.teams[tid1])

	print("\n========== Team7 被抽 11 刀：三條前提逐刀核對 ==========")
	print("（★帳本 reason=raid_out 走 set_amt，記新值不記delta——下面 ledger_entries 的\
rebuilt_delta 欄都已逐entry重建，不是字面delta，已標 is_set_amt=true）")
	for r in results:
		print("\n--- tick=%d｜collector=Team%d ---" % [int(r["tick"]), int(r["collector"])])
		print("  ①勢力1 fund_war 應急狀態=%s｜當下 f.goals=%s" % [str(r["fund_war_active"]), str(r["faction1_goals"])])
		print("  ②收稅者是勢力1盟主=%s（盟主team_id=%d）" % [str(r["collector_is_liege"]), int(r["liege_team_id"])])
		print("  ③扣後Team7 food_days=%.2f｜絕境門檻(DESPERATION_DAYS)=%.1f｜低於儲備=%s" % [
			float(r["food_days_after"]), float(r["desperation_days_threshold"]), str(r["below_reserve_after"])])
		print("  帳本逐entry（已重建）：")
		for e in r["ledger_entries"]:
			print("    field=%-6s｜reason=%-12s｜is_set_amt=%s｜重建後真delta=%.2f" \
				% [String(e["field"]), String(e["reason"]), str(e["is_set_amt"]), float(e["rebuilt_delta"])])

	print("\n========== 彙總 ==========")
	var fund_war_n: int = 0
	var liege_n: int = 0
	var below_n: int = 0
	for r2 in results:
		if bool(r2["fund_war_active"]): fund_war_n += 1
		if bool(r2["collector_is_liege"]): liege_n += 1
		if bool(r2["below_reserve_after"]): below_n += 1
	print("11刀中：①fund_war應急狀態成立=%d/11｜②收稅者是盟主=%d/11｜③扣後低於生存儲備=%d/11" \
		% [fund_war_n, liege_n, below_n])

	var out_path: String = "docs/measurements/wartime-levy-preconditions.jsonl"
	var f_out: FileAccess = FileAccess.open(out_path, FileAccess.WRITE)
	f_out.store_line(JSON.stringify({"kind": "meta", "tree": tree_sha, "seed": SEED,
		"fund_war_n": fund_war_n, "liege_n": liege_n, "below_reserve_n": below_n, "total": results.size()}))
	for r3 in results:
		f_out.store_line(JSON.stringify(r3))
	f_out.close()
	print("\n[DUMP-PATH] %s" % out_path)
	print("=== wartime_levy_preconditions DONE ===")
	quit(0)


func _snap(t: TeamData) -> Dictionary:
	return {"food": float(t.resources.get("food", 0.0)), "goods": float(t.resources.get("goods", 0.0)),
		"coin": float(t.resources.get("coin", 0.0))}


func _git_head_sha() -> String:
	var out: Array = []
	OS.execute("git", ["rev-parse", "--short=9", "HEAD"], out, true)
	if out.size() > 0:
		return String(out[0]).strip_edges()
	return "UNKNOWN"
