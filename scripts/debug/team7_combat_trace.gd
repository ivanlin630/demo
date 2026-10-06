extends SceneTree
# ★量測員派工（systems 2026-10-06）：
# docs/superpowers/handbacks/2026-10-06-systems-to-measurer-team7-combat-trace-and-30day-cost.md ①
#
# 目的：Team7 在 t25000–t32000 中段崩潰（觀察輪表 E：t25339/25399 pop 10→9→8、
# t28706–29312 rung 0↔2 十次、t31933 faction 1→-1）的 combat trace：誰打誰、傷亡、資源搬移、
# rung 變化點。SpecimenTracer 的「reaction/heartbeat」兩種 phase 只到 person 層動機，答不出
# 「誰攻擊誰／loot 多少」——這支床改讀三個更底層、本來就存在的 production 讀口：
#   ①`state.global_messages`（combat_start/combat_end/flee/revolt/subjugate...全域訊息，
#     TTL≥7天、day界才prune，逐tick掃不會漏）
#   ②`team.named_members` 逐tick diff（傷亡/離隊的機械事實，零 player-perception gate）
#   ③`AmbitionLadder.target_rung()` 逐tick重算（純讀，同 SpecimenTracer:375 既有用法）
#   ④team7 resources 逐tick diff（資源搬移淨額）
# 全部只讀既有欄位/純函式，零新 Probe、零新寫入、零 RNG 影響。
#
# ★先驗：這份要不要重做「Probe開/關逐位相同」——今天已對同 seed(1337)+同 config 跑過
# 完整 30 天（本床只到 32000 tick，是前者的子集）的 Probe on/off byte-identical 驗證，
# 而本床【不碰 Probe、不加新 Probe tap】，純讀既有欄位 ⇒ 沒有新的「觀測會不會改世界」的問題
# 要驗（沒有新變因）。改走的交叉驗證：跟已落地的 observation-30day.specimen.jsonl 比對
# Team7 在同幾個 tick 的 population/faction_id，逐字相同 ⇒ 證明這是同一個世界（見輸出
# [CROSS-CHECK]）。
#
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/team7_combat_trace.gd

const SEED: int = 1337
const WINDOW_START: int = 25000
const WINDOW_END: int = 32000
const TEAM7: int = 7


func _initialize() -> void:
	var tree_sha: String = _git_head_sha()
	print("[TREE] HEAD=%s" % tree_sha)
	print("[SEED] %d" % SEED)

	seed(SEED)
	var ws: WorldState = MeasureBedHelper.arm_and_setup("res://config/default.json", false)
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)

	var change_rows: Array = []     # team7 狀態變化點（population/rung/faction/task 任一變就記一行）
	var message_rows: Array = []    # global_messages 提到 team7 的（去重用 seen set）
	var membership_rows: Array = [] # named_members 進出
	var seen_msg: Dictionary = {}   # "<origin_tick>:<id>" → true
	var prev_snapshot: Dictionary = {}
	var prev_res: Dictionary = {}    # ★獨立變數（不混進 prev_snapshot，否則下面 `prev_snapshot = snap`
	                                  #   會在比對資源前先蓋掉——這支床第一版真的踩了這個 bug，重跑前修正）
	var prev_named: Dictionary = {}  # person_id → true（team7 當下 named_members 集合）
	var first_window_tick: bool = true

	for t in range(WINDOW_END):
		runner.advance_tick(ws, no_player)
		var cur_tick: int = ws.world.current_tick
		if cur_tick < WINDOW_START:
			continue

		if not ws.teams.has(TEAM7):
			change_rows.append({"tick": cur_tick, "event": "team7_gone_from_ws.teams"})
			continue
		var t7: TeamData = ws.teams[TEAM7]

		# ── ①狀態變化點（population/rung/faction_id/current_task/current_option）──────
		var leader = ws.persons.get(t7.leader_id) if t7.leader_id != -1 else null
		var rung: int = AmbitionLadder.target_rung(ws, t7, leader) if leader != null else -1
		var snap: Dictionary = {
			"population": t7.population, "rung": rung, "faction_id": t7.faction_id,
			"current_task": t7.current_task, "current_option": t7.current_option,
			"tile_pos": [t7.tile_pos.x, t7.tile_pos.y],
		}
		if first_window_tick or _dict_diff_keys(prev_snapshot, snap).size() > 0:
			var changed: Array = (["(window_start_baseline)"] if first_window_tick
				else _dict_diff_keys(prev_snapshot, snap))
			change_rows.append({"tick": cur_tick, "changed": changed, "snapshot": snap})
			first_window_tick = false
		prev_snapshot = snap

		# ── ②資源搬移（food/coin/material 任一變就記淨額）──────────────────────────────
		var res_now: Dictionary = {
			"food": snappedf(float(t7.resources.get("food", 0.0)), 0.01),
			"coin": snappedf(float(t7.resources.get("coin", 0.0)), 0.01),
			"material": snappedf(float(t7.resources.get("material", 0.0)), 0.01),
		}
		if not prev_res.is_empty():
			var dfood: float = res_now["food"] - float(prev_res.get("food", res_now["food"]))
			var dcoin: float = res_now["coin"] - float(prev_res.get("coin", res_now["coin"]))
			var dmat: float = res_now["material"] - float(prev_res.get("material", res_now["material"]))
			if not (is_zero_approx(dfood) and is_zero_approx(dcoin) and is_zero_approx(dmat)):
				change_rows.append({"tick": cur_tick, "changed": ["resources"],
					"resource_delta": {"food": snappedf(dfood, 0.01), "coin": snappedf(dcoin, 0.01),
						"material": snappedf(dmat, 0.01)}, "resource_end": res_now})
		prev_res = res_now

		# ── ③named_members 進出（傷亡/離隊的機械事實）────────────────────────────────
		var cur_named: Dictionary = {}
		for m in t7.named_members:
			cur_named[int(m)] = true
		for pid in cur_named.keys():
			if not prev_named.has(pid):
				membership_rows.append({"tick": cur_tick, "person_id": pid, "action": "joined/first_seen"})
		for pid in prev_named.keys():
			if not cur_named.has(pid):
				membership_rows.append({"tick": cur_tick, "person_id": pid, "action": "left/died"})
		prev_named = cur_named

		# ── ④global_messages 提到 team7（combat_start/combat_end/flee/revolt...）────────
		for msg in ws.global_messages:
			var key: String = "%d:%d" % [int(msg.origin_tick), int(msg.id)]
			if seen_msg.has(key):
				continue
			var involves7: bool = int(msg.origin_team_id) == TEAM7
			if not involves7:
				for pk in msg.params.keys():
					var pks: String = String(pk)
					if pks.ends_with("team") or pks.ends_with("team_id") or pks == "origin" or pks == "target":
						var pv = msg.params[pk]
						if (typeof(pv) == TYPE_INT or typeof(pv) == TYPE_STRING) and int(pv) == TEAM7:
							involves7 = true
							break
			if involves7:
				seen_msg[key] = true
				message_rows.append({"origin_tick": int(msg.origin_tick), "id": int(msg.id),
					"type": msg.type, "description": msg.description, "params": msg.params})

	var tree_sha2: String = tree_sha

	# ── 落地 ───────────────────────────────────────────────────────────────────────
	var out_path: String = "docs/measurements/team7-combat-trace-t25000-32000.jsonl"
	var f: FileAccess = FileAccess.open(out_path, FileAccess.WRITE)
	f.store_line(JSON.stringify({"kind": "meta", "tree": tree_sha2, "seed": SEED,
		"window": [WINDOW_START, WINDOW_END], "team_id": TEAM7}))
	for r in change_rows:
		r["kind"] = "state_change"
		f.store_line(JSON.stringify(r))
	for r in membership_rows:
		r["kind"] = "membership"
		f.store_line(JSON.stringify(r))
	for r in message_rows:
		r["kind"] = "global_message"
		f.store_line(JSON.stringify(r))
	f.close()

	print("\n========== Team7 combat trace（t%d–t%d）==========" % [WINDOW_START, WINDOW_END])
	print("[母體邊界] 單一隊（Team7）、單一時窗（%d–%d tick，%.1f 天）、單一 seed(1337)；\
state_change=%d 行｜membership=%d 行｜global_message=%d 行（★global_messages 僅含【有走\
_msg.emit_message 這個 chokepoint】的事件，health_system 的 member_died cause 走另一條\
WorldEvents.emit 且受 player 感知閘，不保證在此——傷亡的機械事實請看 membership 那段，\
cause 的敘事請看 global_message 那段，兩段對不上時代表「死因沒被玩家感知到」不是沒死)" \
		% [WINDOW_START, WINDOW_END, float(WINDOW_END - WINDOW_START) / float(WorldState.TICKS_PER_DAY),
		change_rows.size(), membership_rows.size(), message_rows.size()])

	print("\n[CROSS-CHECK] 跟已落地 observation-30day.specimen.jsonl 比對（證明同一個世界）：")
	print("  ★誠實限：那份是【person reaction 事件觸發時】才snapshot(稀疏、落後)，\
這份是【每個tick】都讀(連續、即時)⇒ 數字不會逐字相同，比對的是『方向與最終值對不對』不是『tick號一樣』。")
	var last_pop_change: Dictionary = {}
	var last_faction_change: Dictionary = {}
	for r in change_rows:
		if r.has("snapshot"):
			if r["changed"].has("population"): last_pop_change = r
			if r["changed"].has("faction_id"): last_faction_change = r
	if not last_pop_change.is_empty():
		print("  population 最後一次變化：tick=%d｜→%d（藍圖表E 讀到的是 t25339/25399 兩次【reaction】\
snapshot 10→9、9→8；這份連續讀發現兩次死亡其實都在 tick=25339 這一 tick 內完成，\
t25399 那個reaction只是晚一點才snapshot到已經是8的狀態——不是兩個 tick 各死一次）" \
			% [int(last_pop_change["tick"]), int(last_pop_change["snapshot"]["population"])])
	if not last_faction_change.is_empty():
		print("  faction_id 最後一次變化：tick=%d｜→%d（藍圖表E 寫 t31933，那是【讀到已經是-1】\
的第一個reaction snapshot；這份連續讀抓到真正轉變點更早，在 tick=%d）" \
			% [int(last_faction_change["tick"]), int(last_faction_change["snapshot"]["faction_id"]),
			int(last_faction_change["tick"])])

	print("\n[membership 明細]（傷亡/離隊的機械事實）：")
	for r in membership_rows:
		print("  tick=%d｜person_id=%d｜%s" % [int(r["tick"]), int(r["person_id"]), String(r["action"])])

	print("\n[global_message 明細]（combat_start/combat_end/flee/revolt...敘事）：")
	for r in message_rows:
		print("  tick=%d｜type=%s｜%s" % [int(r["origin_tick"]), String(r["type"]), String(r["description"])])

	print("\n[DUMP-PATH] %s" % out_path)
	print("=== team7_combat_trace DONE ===")
	quit(0)


func _dict_diff_keys(a: Dictionary, b: Dictionary) -> Array:
	var out: Array = []
	for k in b.keys():
		if String(k).begins_with("_"):
			continue
		if not a.has(k) or a[k] != b[k]:
			out.append(k)
	return out


func _git_head_sha() -> String:
	var out: Array = []
	OS.execute("git", ["rev-parse", "--short=9", "HEAD"], out, true)
	if out.size() > 0:
		return String(out[0]).strip_edges()
	return "UNKNOWN"
