# scripts/ui/observer_bridge.gd
class_name ObserverBridge

# 觀測 driver（玩家 sim_bridge 零 diff 另立）：不因事件中斷、frame 時間預算攤 spike。
# LOD 錨點 = headless bed 同策略（無玩家 (-1,-1)）→ sim 行為與二考 assets 一致。

const NO_PLAYER := Vector2i(-1, -1)
const FRAME_BUDGET_MS: float = 12.0
const ENCOUNTER_STUCK_TICKS: int = 800   # mirror WarringHarness 護欄

var _runner: SimRunner
var _state: WorldState

func _init(runner: SimRunner, state: WorldState) -> void:
	_runner = runner
	_state = state

func get_state() -> WorldState:
	return _state

func current_tick() -> int:
	return _state.world.current_tick

# 每 frame 呼叫：推進至多 max_ticks，預算到頂即停（剩餘留下一 frame → spike 攤平非凍結）。
# 回實推 tick 數。單 tick 不可分割 → 單 tick spike 仍會超預算一次，但不累積。
func tick_step(max_ticks: int, budget_ms: float = FRAME_BUDGET_MS) -> int:
	var t0: int = Time.get_ticks_usec()
	var done: int = 0
	while done < max_ticks:
		_runner.advance_tick(_state, NO_PLAYER)
		if _state.encounter_active and _state.encounter_tick > ENCOUNTER_STUCK_TICKS:
			_runner._encounter_system.resolve_encounter_end(_state, "draw")
		done += 1
		if float(Time.get_ticks_usec() - t0) / 1000.0 >= budget_ms:
			break
	return done

# 全量增量消費：origin_tick 水位（global_messages 會 prune、id 非唯一 → 不用 id）。
# 合併兩 channel：global_messages（既有事件型）+ observer_messages（Task0 補洞型）。
# sim_runner tick 增量在 systems 前 → tick T 訊息 origin_tick=T → 消費後水位=current_tick、
# 比較用 `>` 不漏不重。呼叫節奏 = frame 邊界（tick 已完整），TTL 最短 7 天 >> 單 frame 推進量。
func consume_messages(since_tick: int) -> Array:
	var a: Array = _tail_since(_state.global_messages, since_tick)
	var b: Array = _tail_since(_state.observer_messages, since_tick)
	# 兩升冪串穩定合併（同 tick global 先），保 channel 內原順序
	var out: Array = []
	var i: int = 0
	var j: int = 0
	while i < a.size() and j < b.size():
		if a[i].origin_tick <= b[j].origin_tick:
			out.append(a[i]); i += 1
		else:
			out.append(b[j]); j += 1
	while i < a.size():
		out.append(a[i]); i += 1
	while j < b.size():
		out.append(b[j]); j += 1
	return out

# 從尾往回掃到水位（append-only + origin_tick 單調不減 → 尾段即新段），回升冪
static func _tail_since(msgs: Array, since_tick: int) -> Array:
	var start: int = msgs.size()
	while start > 0 and msgs[start - 1].origin_tick > since_tick:
		start -= 1
	return msgs.slice(start)

func query_team(tid: int) -> Dictionary:
	return ObserverQueryApi.query_team(_state, tid)

func query_all_teams() -> Array:
	return ObserverQueryApi.query_all_teams(_state)

func query_map_teams() -> Array:
	return ObserverQueryApi.query_map_teams(_state)

func query_map_tiles() -> Dictionary:
	return ObserverQueryApi.query_map_tiles(_state)

func query_outpost(tpos: Vector2i) -> Dictionary:
	return ObserverQueryApi.query_outpost(_state, tpos)

func query_all_outposts() -> Array:
	return ObserverQueryApi.query_all_outposts(_state)
