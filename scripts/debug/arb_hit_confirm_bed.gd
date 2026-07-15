extends SceneTree

# arb_hit_confirm_bed：arb_hit=0精確根確認——merchant到達move_target那格，賣方在不在？
# 純觀測：只讀不寫，真實advance_tick跑，逐tick盯TAG_MERCHANT隊的到達事件。
# 用法：AHC_SEED（default 1337）AHC_MONTHS（default 6）

func _initialize() -> void:
	_run(); quit()

var _prev_at_target: Dictionary = {}   # team_id -> bool（上tick是否已在move_target，判新到達邊緣）
var _prev_task: Dictionary = {}        # team_id -> String（上次task，判preempt漂走 vs 正常完成）
var _arrivals: Array = []              # 到達事件明細
var _preempt_n: int = 0
var _clean_end_n: int = 0

func _run() -> void:
	var world_seed: int = int(OS.get_environment("AHC_SEED")) if OS.has_environment("AHC_SEED") else 1337
	var months: int = int(OS.get_environment("AHC_MONTHS")) if OS.has_environment("AHC_MONTHS") else 6
	var total_ticks: int = months * WorldState.TICKS_PER_MONTH
	print("=== arb_hit_confirm_bed: seed=%d months=%d ===" % [world_seed, months])
	seed(world_seed)
	SimRunner.force_full_hd = true
	Probe.enabled = true
	Probe.reset()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/default.json")
	config["seed"] = world_seed
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	for tick in range(total_ticks):
		runner.advance_tick(state, no_player)
		_scan(state, tick)
		if state.teams.is_empty():
			break
	_report()
	SimRunner.force_full_hd = false
	Probe.enabled = false
	print("=== DONE ===")

func _scan(state: WorldState, tick: int) -> void:
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		# ★TAG_MERCHANT本世界全程0隊(見trade_funnel_bed native月報「商隊tag=0」)——真正驅動
		# _merchant_trade_target的閘是ambition_archetype==ARCHETYPE_TRADE(faction_ai:2045)，非TAG_MERCHANT。
		if t.ambition_archetype != AmbitionLadder.ARCHETYPE_TRADE:
			continue
		var at_target: bool = (t.move_target != Vector2i(-1, -1)) and (t.tile_pos == t.move_target)
		var was_at_target: bool = bool(_prev_at_target.get(tid, false))
		# 新到達邊緣：這tick第一次到，非持續停留
		if at_target and not was_at_target and t.current_task == TeamData.TASK_TRADE:
			_record_arrival(state, tid, t, tick)
		_prev_at_target[tid] = at_target
		# preempt vs clean 判定：貿易task結束時判斷方式同死法①（下tick task變了）
		var prev_task: String = String(_prev_task.get(tid, ""))
		if prev_task == TeamData.TASK_TRADE and t.current_task != TeamData.TASK_TRADE:
			if t.current_task == TeamData.TASK_FLEE or t.current_task == TeamData.TASK_DEFEND:
				_preempt_n += 1
			else:
				_clean_end_n += 1
		_prev_task[tid] = t.current_task

func _record_arrival(state: WorldState, tid: int, t: TeamData, tick: int) -> void:
	var here: Vector2i = t.tile_pos
	var others: Array = []
	for oid in state.teams:
		if oid == tid:
			continue
		var o: TeamData = state.teams[oid]
		if o.tile_pos == here:
			others.append(oid)
	var tile_id: int = here.x * 1000 + here.y
	var tile: HexTileData = state.world.tiles.get(tile_id)
	var owner: int = tile.outpost_owner if tile != null else -2
	var owner_settled = null
	if owner >= 0 and state.teams.has(owner):
		var ow: TeamData = state.teams[owner]
		owner_settled = (ow.tile_pos == here)
	_arrivals.append({
		"tick": tick, "team": tid, "pos": [here.x, here.y],
		"others_present": others, "tile_outpost_owner": owner, "owner_settled_here": owner_settled,
	})

func _report() -> void:
	print("[ARRIVALS] 總到達次數=%d" % _arrivals.size())
	var with_opponent: int = 0
	var empty_tile: int = 0
	var owner_settled_n: int = 0
	var owner_wander_n: int = 0
	var no_owner_n: int = 0
	for a in _arrivals:
		if (a["others_present"] as Array).size() > 0:
			with_opponent += 1
		else:
			empty_tile += 1
		if a["tile_outpost_owner"] == -1:
			no_owner_n += 1
		elif a["owner_settled_here"] == true:
			owner_settled_n += 1
		elif a["owner_settled_here"] == false:
			owner_wander_n += 1
	print("[ARRIVALS-summary] 到達時有對手隊(any team co-located)=%d 空格(0對手)=%d" % [with_opponent, empty_tile])
	print("[ARRIVALS-summary] tile_outpost_owner: 無owner(-1)=%d owner在家(settled)=%d owner不在家(漫遊)=%d" % [
		no_owner_n, owner_settled_n, owner_wander_n])
	print("[ARRIVALS-detail] 前30筆:")
	for a in _arrivals.slice(0, 30):
		print("  " + str(a))
	print("[PREEMPT-vs-CLEAN] trade結束後: preempt(FLEE/DEFEND)=%d clean(正常轉場)=%d 到達次數(commit到底候選)=%d" % [
		_preempt_n, _clean_end_n, _arrivals.size()])
