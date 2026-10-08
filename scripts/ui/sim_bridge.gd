# scripts/ui/sim_bridge.gd
class_name SimBridge

# ★★★S2：這顆不跟隨根旋鈕 ⇒ 重錨會讓它【靜默漂移 6 倍】（舊 24/10＝2.4h → 24/60＝0.4h）。
#   ★本票只做一件事：【保住它現在的真實時長 2.4 小時】—— 不做不是延後，是 S2 自己引入一個 bug。
#   ★★「一個 turn 該多長」（turn 定義統一 60t vs 24t）是 S7 的設計題，不在本票。
#   ★★★這也收掉了 S1b 唯一那顆 (b) 延後：hours() 只吃整數小時表達不了 2.4h，
#     而重錨後分鐘可用：144 分 ＝ 2.4 小時，且 144 = 2.4 × 60 【整數無餘】。
const TURN_MINUTES: int = 144   # ＝ 2.4 小時（時間宣告；tick 數是推導值）
const TICKS_PER_TURN: int = TURN_MINUTES * TimeScale.TICK_PER_MINUTE

var _runner: SimRunner
var _state: WorldState
var _ticks_remaining: int = 0
var _query_api: PlayerQueryApi = PlayerQueryApi.new()

func _init(runner: SimRunner, state: WorldState) -> void:
	_runner = runner
	_state  = state

func get_state() -> WorldState:
	return _state

# 「一直推到有事件擋住它」的哨兵。
# ★★★名字刻意【不叫】 ADVANCE_UNBOUNDED —— 它不是無界：
#   99999 tick ÷ TICKS_PER_DAY(1440) ＝ 約 69.4 天，那是一個【有限天花板】。
#   ★一個承諾得比它交付的多的名字會說謊，而【沒有任何一格在驗名字】
#   ⇒ ★★它的失效是靜的：真的推到 69 天還沒有事件 ⇒ 安靜停下，而畫面看起來像「移動完成了」。
# ★★實務上永遠先被事件擋住：`tick_step()` 一遇到玩家相關事件就把 remaining 歸零。
# ★★★真正無界（`-1` 由 bridge 解讀）另立小票 —— 那會改 `is_advancing()` 的語意，
#   而爆炸半徑已經數過：`_ticks_remaining` 全庫 9 處【都在本檔】，外面沒有人讀它。
# 一個 `request_advance()` 請求容許的上限（≈69.4 天）。
# ★它同時是 UI 夾玩家輸入（G 鍵「跳過 N tick」）的上限 —— 那是【夾具】的語意。
const ADVANCE_MAX_REQUEST: int = 99999

# 「一直推到有事件擋住它」的哨兵 ＝ 請求上限。
# ★★★刻意【衍生】而不是再寫一次 99999：哨兵請求的量不可以超過請求上限，
#   而那個依賴是真的 ⇒ 衍生會讓它們不可能漂開。
# ★★而它們是【兩個名字】不是一個：哨兵是「推到有事件」、夾具是「別超過上限」——
#   共用一個名字會把兩件事黏在一起（今天已在 99999 vs ObserverBridge 的 1000000 上犯過）。
const ADVANCE_UNTIL_EVENT: int = ADVANCE_MAX_REQUEST

# 請求推進 n ticks（非阻塞，由 tick_step 每 frame 分批執行）
func request_advance(n: int) -> void:
	_ticks_remaining = n

# 取消推進
func cancel_advance() -> void:
	_ticks_remaining = 0

# 是否正在推進
func is_advancing() -> bool:
	return _ticks_remaining > 0

# 還要推進幾顆（唯讀觀測口）。
# ★★★它存在的理由是一個【量錯對象】的實測（2026-09-25）：P8 原本量「世界走了幾顆」，
#   而 `tick_step()` 遇到事件會把 remaining 歸零 ⇒ 請求一天、第一幀走完一小時就被擋住
#   ⇒ ★【1440 與 60 在卷面上長得一模一樣】，負對照因此不紅。
# ⇒ ★★被守的性質是「按 X【請求】的是一小時」，而請求量是這裡這個數
#   ——【走了多少】是世界的權利，不是那個鍵的承諾。
func ticks_remaining() -> int:
	return _ticks_remaining

# 是否處於遭遇戰（text UI 不直存 state.encounter_active）
func is_encounter_active() -> bool:
	return _state.encounter_active

# U11: 遭遇戰戰報最新 n 條（UI 經此 facade 讀，不直存 encounter_log）
func query_encounter_log(n: int = 5) -> Array:
	var log: Array = _state.encounter_log
	if log.size() <= n: return log.duplicate()
	return log.slice(log.size() - n)

# 每 frame 呼叫：推進 TICKS_PER_HOUR ticks，回傳結果
# 遭遇戰/新發現事件觸發時自動停止
# ★★★一次 `tick_step()` 最多吃幾個 tick —— ★把它【具名】出來，不是為了好看：
#   `SimRunner.RESULT_TTL_TICKS` 必須 ≥ 這個數，否則一次 step 之內產生的結果句
#   會在同一次 step 裡過期 ⇒ ★★玩家看不到前面那幾十顆 tick 的拒絕訊息，
#   而「拒絕禁靜默」是 (乙) 的核心 ⇒ 兩條規矩互相吃掉。
#   ⇒ ★★★沒有名字的話，那個依賴只存在於【兩處湊巧都寫 TICKS_PER_HOUR】，
#     而床去斷言它就是拿常數跟自己比 —— 改這裡不會有任何東西紅。
#   ⇒ 現在它有名字：`command_replay_bed` 的 P14b 直接比這兩個常數。
const STEP_TICK_BOUND: int = WorldState.TICKS_PER_HOUR

# 返回 { "events": Array, "done": bool }
func tick_step() -> Dictionary:
	if _ticks_remaining <= 0:
		return { "events": [], "done": true }
	var n: int = mini(STEP_TICK_BOUND, _ticks_remaining)
	var adv: Dictionary = advance_ticks(n)
	var events: Array = adv["events"]
	_ticks_remaining = maxi(0, _ticks_remaining - n)
	if _any_stop(events):
		_ticks_remaining = 0   # 停點事件 → 停止推進（★M §2：看到新的隊伍不再停）
	# ★只加鍵（`advanced`／`stall_reason`）：既有讀者只讀 events／done
	return { "events": events, "done": _ticks_remaining <= 0,
		"advanced": adv["advanced"], "stall_reason": adv["stall_reason"] }

# Advance up to n world ticks (not encounter ticks).
# Stops early if a player-relevant event fires.
# ══ ★★★★★【推不動要說為什麼】（故事結束 spec §3③／P7，票 #2 刀 1，2026-10-06）═══════════
#   ★舊版回 `Array`（只有事件）而**完全不看 `advance_tick` 的回傳值** ⇒ 等待繼承人時空轉 n 圈
#     **而且安靜**（呼叫端分不出「推了 n tick 沒事件」與「一 tick 都沒推」）。
#   ⇒ ★★正確的形狀**已經存在**：`PlayerCommandApi.advance_ticks` 回
#     `advanced`／`requested`／`first_stall_tick`／`stall_reason` ⇒ 這裡**跟上同一組鍵**
#     （＋本路徑特有的 `events`）。
#   ⇒ ★★★`story_end_not_physics_bed` 的 P7 **直接比兩邊的鍵集**（兩邊能各自改 ⇒ 是真的比較）：
#     有人改了其中一邊而沒改另一邊 ⇒ 紅。
#   ★語意也照那一支：`r != ""` 的第一個 ⇒ `first_stall_tick`／`stall_reason`；**不提前 break**
#     （那一支也不 break —— 兩條推進路徑不准再分岔）。
func advance_ticks(n: int) -> Dictionary:
	var events: Array = []
	var before: int = _state.world.current_tick
	var stalled_at: int = -1
	var stall_reason: String = ""
	for _i in range(n):
		var snap := _snapshot()
		var seq0: int = _state.player_event_seq
		var player_pos: Vector2i = _player_tile()
		var r: String = _runner.advance_tick(_state, player_pos)
		if r != "" and stalled_at == -1:
			stalled_at = _state.world.current_tick
			stall_reason = r
		var new_evts := _diff_events(snap)
		# ★M §2：停點讀玩家事件匯流排（與事件流 UI 同源），不手刻快照差分
		var stop: Dictionary = WorldEvents.stop_event_since(_state, seq0)
		if not stop.is_empty():
			new_evts.append({ "type": "stop_event", "kind": String(stop.get("kind", "")), "text": String(stop.get("text", "")) })
		events.append_array(new_evts)
		if _any_stop(new_evts):
			break
	return {
		"events": events,
		"advanced": _state.world.current_tick - before, "requested": n,
		"first_stall_tick": stalled_at, "stall_reason": stall_reason,
	}

# Advance one encounter tick.
# Returns "player_turn" when player unit timer == 0,
# "encounter_ended" when encounter_active becomes false,
# "ongoing" otherwise.
func advance_encounter_tick() -> String:
	if not _state.encounter_active:
		return "no_encounter"
	var player_pos: Vector2i = _player_tile()
	var enc_result: String = _runner.advance_tick(_state, player_pos)
	# Translate encounter_system result to view-facing result
	match enc_result:
		"player_turn":
			return "player_turn"
		"attacker_win", "defender_win", "draw":
			return "encounter_ended"
		_:
			if not _state.encounter_active:
				return "encounter_ended"
			return "ongoing"

# ── helpers ───────────────────────────────────────────────

func _player_tile() -> Vector2i:
	if _state.player_id < 0: return Vector2i.ZERO
	var p: PersonData = _state.persons.get(_state.player_id)
	if p == null: return Vector2i.ZERO
	var t: TeamData = _state.teams.get(p.team_id)
	return t.tile_pos if t else Vector2i.ZERO

func get_player_team_id() -> int:
	if _state.player_id < 0: return -1
	var p: PersonData = _state.persons.get(_state.player_id)
	return p.team_id if p else -1

# ── Step 1: tick + player position helpers ─────────────────────────────────────

func get_current_tick() -> int:
	return _state.world.current_tick

func get_player_tile_pos() -> Vector2i:
	var tid: int = get_player_team_id()
	if tid < 0: return Vector2i.ZERO
	var t: TeamData = _state.teams.get(tid)
	return t.tile_pos if t else Vector2i.ZERO

func get_player_move_target() -> Vector2i:
	var tid: int = get_player_team_id()
	if tid < 0: return Vector2i(-1, -1)
	var t: TeamData = _state.teams.get(tid)
	return t.move_target if t else Vector2i(-1, -1)

# ── Step 2: tile query helpers ─────────────────────────────────────────────────

func is_valid_tile(q: int, r: int) -> bool:
	return _state.world.tiles.has(q * 1000 + r)

func query_tile(q: int, r: int) -> Dictionary:
	var key: int = q * 1000 + r
	var tile: HexTileData = _state.world.tiles.get(key)
	if tile == null: return {}
	return {
		"terrain":        tile.terrain,
		"productivity":   tile.harvest_factor,
		"harvest_factor": tile.harvest_factor,
		"resources":      tile.resources.duplicate(),
		"outpost_type":   tile.outpost_type,
		"outpost_level":  tile.outpost_level,
		"outpost_owner":  tile.outpost_owner,
	}

# ★F7／F7b：附身者對一格知道什麼（查詢面那一支；不讀 query_tile 的真值）
func tile_knowledge(q: int, r: int) -> Dictionary:
	return PlayerQueryApi.tile_knowledge(_state, Vector2i(q, r), get_vision_mult())

func render_text_map(player_tid: int, cursor: Vector2i) -> String:
	return TextMapRenderer.render(_state, player_tid, cursor, get_vision_mult())

# ★#9 §8：日夜視野倍率 —— 唯讀，用 runner 那一顆 DayNightSystem（sim 視野用的同一支），不每幀 new
func get_vision_mult() -> float:
	if _runner == null or _runner._day_night_system == null:
		return 1.0
	return _runner._day_night_system.get_vision_mult(_state)

# ★#9 §7③：隊伍代號表（地圖／右欄／游標處三處同讀這一份；產生點在 TextMapRenderer.team_codes）
func get_team_codes(player_tid: int) -> Dictionary:
	return TextMapRenderer.team_codes(_state, player_tid, get_vision_mult())

# ── Step 3: data query wrappers ────────────────────────────────────────────────

# ★記憶頁（打聽 v1 spec §3(G)）：唯讀轉出 —— ★render 讀它不寫 state（同 query_tile 的前例）
func query_memory_panel() -> Dictionary:
	return _query_api.query_memory_panel(_state)

func query_body_slots() -> Dictionary:
	return PlayerApiMapper.map_body_slots(_state)

func query_global_messages(n: int = 10) -> Array:
	return PlayerApiMapper.map_global_messages(_state, n)

func query_visible_teams_render() -> Array:
	return PlayerApiMapper.map_visible_teams_render(_state, get_player_team_id())

# ── Step 4: world tiles + tile/team spatial helpers ───────────────────────────

func query_world_tiles() -> Dictionary:
	var result: Dictionary = {}
	for key in _state.world.tiles:
		var tile: HexTileData = _state.world.tiles[key]
		result[key] = {
			"tile_pos":       tile.tile_pos,
			"terrain":        tile.terrain,
			"harvest_factor": tile.harvest_factor,
			"resources":      tile.resources.duplicate(),
			"outpost_type":   tile.outpost_type,
			"outpost_level":  tile.outpost_level,
			"outpost_owner":  tile.outpost_owner,
		}
	return result

func is_tile_in_vision(q: int, r: int) -> bool:
	var tid: int = get_player_team_id()
	if tid < 0: return true
	var t: TeamData = _state.teams.get(tid)
	if t == null: return false
	var dx: int = q - t.tile_pos.x
	var dy: int = r - t.tile_pos.y
	return (abs(dx) + abs(dx + dy) + abs(dy)) / 2 <= 3

func has_tile_intel(q: int, r: int) -> bool:
	var player_tid: int = get_player_team_id()
	if player_tid < 0: return false
	var discovered: Array = _state.team_discovered.get(player_tid, [])
	var pos := Vector2i(q, r)
	for tid in discovered:
		var intel: Dictionary = BeliefSystem.best_estimate(_state, player_tid, tid)
		if intel.get("tile_pos", Vector2i(-999, -999)) == pos:
			return true
	return false

func get_teams_at_tile(q: int, r: int) -> Array:
	var pos := Vector2i(q, r)
	var result: Array = []
	for tid in _state.teams:
		var t: TeamData = _state.teams[tid]
		if t.tile_pos == pos:
			result.append({
				"id": tid, "faction_id": t.faction_id,
				"population": t.population, "current_task": t.current_task
			})
	return result

func get_all_teams_debug() -> Array:
	var result: Array = []
	for tid in _state.teams:
		var t: TeamData = _state.teams[tid]
		result.append({"id": tid, "pos": t.tile_pos, "pop": t.population, "task": t.current_task})
	return result

func query_render_context() -> Dictionary:
	var ptid: int = get_player_team_id()
	var player_team: TeamData = _state.teams.get(ptid) if ptid >= 0 else null
	var discovered: Array = _state.team_discovered.get(ptid, []) if ptid >= 0 else []
	var disc_positions: Array = []
	for tid in discovered:
		var t: TeamData = _state.teams.get(tid)
		if t: disc_positions.append(t.tile_pos)
	return {
		"player_tile_pos":           player_team.tile_pos if player_team else Vector2i(-1, -1),
		"discovered_team_positions": disc_positions,
		"vision_radius":             3,
	}

func _snapshot() -> Dictionary:
	var ptid: int = get_player_team_id()
	return {
		"encounter_active":  _state.encounter_active,
		"discovered_count":  _state.team_discovered.get(ptid, []).size() if ptid >= 0 else 0,
	}

func _diff_events(snap: Dictionary) -> Array:
	var evts: Array = []
	if _state.encounter_active and not snap["encounter_active"]:
		evts.append({ "type": "encounter_triggered" })
	var ptid: int = get_player_team_id()
	if ptid >= 0:
		var now: int = _state.team_discovered.get(ptid, []).size()
		if now > snap["discovered_count"]:
			evts.append({ "type": "new_team_spotted" })
	return evts

# ★M §2（藍圖 fda4636f1，R² 裁）：推進要停在哪一刻 ＝ 這幾種事件（停點的 kind 集合在 WorldEvents，這裡不抄）
#   ·stop_event：這一 tick 玩家事件匯流排上出現了停點 kind（找上門、被攻擊／遭遇、敵對逼近、成員死亡離隊…）
#   ·encounter_triggered：戰鬥畫面要接管（既有）
#   ★new_team_spotted 不是停點（照舊記進事件、不打斷推進）
static func _is_stop(e: Dictionary) -> bool:
	return String(e.get("type", "")) in ["stop_event", "encounter_triggered"]

# ★不用 lambda：lambda 裡呼 static 在 4.2 解不到（「in base 'Nil'」）
static func _any_stop(evts: Array) -> bool:
	for e in evts:
		if _is_stop(e):
			return true
	return false

# ★M 票 §2②：玩家隊同格或相鄰的敵對隊（最近那一支）{id, dist}；沒有 ⇒ {}（敵對＝player_hostile_teams；旁邊一格在視野內）
func nearest_hostile_within(max_dist: int) -> Dictionary:
	var ptid: int = get_player_team_id()
	var pt: TeamData = _state.live_team(ptid) if ptid >= 0 else null
	if pt == null:
		return {}
	var best: Dictionary = {}
	for hid in _state.player_hostile_teams:
		var h: TeamData = _state.live_team(int(hid))
		if h == null:
			continue
		var d: int = FactionAISystem._hex_dist(pt.tile_pos, h.tile_pos)
		if d <= max_dist and (best.is_empty() or d < int(best["dist"])):
			best = {"id": int(hid), "dist": d}
	return best

# ── Player API (query / command) ───────────────────────────────────────────────

func query_player(request: Dictionary = {}) -> Dictionary:
	return _query_api.get_player_snapshot(_state, request)

func query_player_team(team_id: int) -> Dictionary:
	return _query_api.get_team_details(_state, team_id)

func query_player_member(team_id: int, member_id: int) -> Dictionary:
	return _query_api.get_member_details(_state, team_id, member_id)

func query_player_location(tile_q: int, tile_r: int) -> Dictionary:
	return _query_api.get_location_context(_state, tile_q, tile_r)

func query_player_actions(request: Dictionary) -> Dictionary:
	return _query_api.get_available_actions(_state, request)

func query_trade_preview(target_team_id: int) -> Dictionary:
	return _query_api.get_trade_preview(_state, target_team_id)

func query_trade_session(target_team_id: int) -> Dictionary:
	return _query_api.get_trade_session(_state, target_team_id)

# ★已退場（2026-10-01）：直接成交那一路的**橋接查詢**（活樹裡本來就零呼叫點）。

func get_and_clear_alerts() -> Array:
	return PlayerQueryApi.new().get_and_clear_alerts(_state)

# ★★★不再當場套用：推進佇列，由 sim_runner 在【tick 邊界】消費（spec §3-1）。
#   ★沒有「立刻套用」的旁路（spec §3-4）—— 只要存在一條同步路徑，
#     重播就要問「那一次走的是哪條」，而卷面上兩條路徑長得一模一樣。
#   ★★回傳形狀照 spec §3-1 逐字：{ ok, queued, seq }。
#     ⇒ ★呼叫端原本當場讀 `message`／`ok` 的（實測 66 個呼叫端、54 個當場讀）
#       現在拿不到結果 —— 那個【玩家回饋】要怎麼補，systems 還沒裁，本檔不自己選。
# ★★★#8：按一下＝做一顆 tick（blueprint 裁 2026-09-29；用戶逐字「玩家的介面就是按啥做啥」）。
#   ★掛在【這一個咽喉】而不是 UI 的呼叫點上 —— spec §2① 寫死的位置。
#   ★★而它涵蓋的比 spec 說的多：活的呼叫點是 45 個不是 36
#     （text_ui_main 36 ＋ encounter_view 5 ＋ popup_layer 4；main.gd 那 10 個是死樹 Main.tscn）
#     ⇒ 這正是掛咽喉的理由：★★★【第 46 個呼叫點自動有這個行為】，貼 45 次的版本會漏掉它而沒人發現。
#   ★例外＝自動推進中（Space／X 正在跑）按的令【照舊入列，不另加推進】—— 用既有謂詞，不新造狀態。
#   ★★條件是 `queued` 而不是無條件：`unknown_command` 那一支【什麼都沒入列】
#     ⇒ 它不是「一道令」，推它一顆 tick 會讓打錯字也走掉世界的時間。
#     ★★★（這是我在 HOW 內自己定的那一個微決定，已寫在 handback 給 systems 覆核。）
func command_player(name: String, args: Dictionary) -> Dictionary:
	var r: Dictionary = _enqueue_command(name, args)
	if bool(r.get("queued", false)) and not is_advancing():
		request_advance(1)
	return r

# 原本的 `command_player` 本體（入列＋入列當下唯一會擋的兩件事）。
# ★★改名而不是把推進塞進本體：讓【推進】與【入列】在讀的時候分得開 ——
#   否則下一個人要在入列邏輯裡找一行推進，而那一行看起來像是入列的一部分。
func _enqueue_command(name: String, args: Dictionary) -> Dictionary:
	# ★★★入列當下【唯一】會擋的一件事（systems 裁 2026-09-24，(乙) 的那一句）：
	#   `dispatch` 的 match 認不認得這個 name。★它不是合法性判斷 —— 合法性歸消費點，
	#   而「這個 name 根本不存在」【不會因為推進一顆 tick 而改變】⇒ 擋在這裡沒有第二份真相。
	#   ★★判準走 `VERB` —— 而 P9 保證 `VERB` ≡ `dispatch()` 的 match 名單（異源比對）
	#     ⇒ ★★★這裡不是再抄一份白名單，是用那份【有守衛的】白名單。
	#   ★我原本漏了這一句，是 headless_test 的「unknown cmd: ok=false」紅出來的。
	if not PlayerCommandApi.VERB.has(name):
		return {"ok": false, "queued": false, "code": "unknown_command",
			"message": "沒有這個指令：%s" % name}
	# ★★★同批重複去重（spec §4c②，用戶問「同格招募，待辦為何 3 還 4 道」）：
	#   真因＝每按一次 T 就入列一道 `refresh_targets`（text_ui_main 的 KEY_T 分支）。
	# ★★而它【不准搬出佇列】：那支會寫 `player_pending_targets` ＝ 世界狀態
	#   ⇒ 不入列的話「玩家何時開選單」會改變世界 ⇒ 把票5 修掉的不決定性放回來。
	#   ⇒ 處置是【去重 ＋ 列名】，不是【搬出去】。
	# ★★★判準刻意只看【尾端】：它合併的是「連續、同名、無參數」那一種 ＝【按鍵按太多次】的形狀；
	#   而 `[refresh, move, refresh]` 的第二個【要保留】—— 移動之後可見對象會變，那時它的意義不同。
	#   ⇒ P14 就是守這件事（把判準放寬成「佇列裡有就不加」⇒ 必須紅）。
	# ★只比尾端那一筆的 name ＝【不讀世界】⇒ 不違反「入列當下只擋不讀世界的」那條裁定。
	if _merges_into_tail(name, args):
		var tail: Dictionary = _state.pending_commands[-1]
		# ★回的字要與事實相符：它【確實在佇列裡】，而【沒有多排一道】——兩件都說。
		#   ★★這一句是 2026-09-25 招募那張的教訓：回報的字與事實不符，玩家只看得到那一個。
		return {"ok": true, "queued": true, "merged": true, "seq": int(tail.get("seq", 0)),
			"message": "已排入：%s（同一道，沒有重複排）" % PlayerCommandApi.describe(name, args)}
	_state.command_seq += 1
	_state.pending_commands.append({
		"name": name, "args": args.duplicate(true), "seq": _state.command_seq})
	return {"ok": true, "queued": true, "seq": _state.command_seq,
		"message": "已排入：%s" % PlayerCommandApi.describe(name, args)}

# 頁腳常駐用（spec §3-5③）：★★「待執行 N 道」——★玩家要看得到他按的東西還沒生效。
func pending_command_count() -> int:
	return _state.pending_commands.size()

# 「連續、同名、無參數」＝按鍵按太多次的形狀 ⇒ 併進尾端那一道。
# ★★★為什麼要求【無參數】兩邊都成立：`move_to(3,4)` 與 `move_to(5,6)` 同名而意思不同 ——
#   合併它們會把玩家的第二個決定吃掉，而他不會知道。
func _merges_into_tail(name: String, args: Dictionary) -> bool:
	if not args.is_empty(): return false
	if _state.pending_commands.is_empty(): return false
	var tail: Dictionary = _state.pending_commands[-1]
	if String(tail.get("name", "")) != name: return false
	return Dictionary(tail.get("args", {})).is_empty()

# 頁腳列名用（spec §4c①）：待辦的【動作人話】，最多 max_n 個。
# ★★★文案走 `PlayerCommandApi.describe()` ＝【與入列回音同一份字串】——
#   不另寫一份。★兩份文案會漂，而漂了【沒有任何東西會紅】（P15b 就是 grep 這兩處同源）。
func pending_command_labels(max_n: int = 3) -> Array:
	var out: Array = []
	for c in _state.pending_commands:
		if out.size() >= max_n: break
		out.append(PlayerCommandApi.describe(String(c.get("name", "")), Dictionary(c.get("args", {}))))
	return out

# ★★★【唯讀】：讀結果句不得改變世界（systems 裁 2026-09-23）。
#   ★原本這支是破壞性排空 ⇒ 掛上一個 UI 就會改變 fp ＝ 觀測改變被觀測物。
#   ★★現在清除由消費點依 tick 做（sim_runner.RESULT_TTL_TICKS）
#   ⇒ 呼叫端自己記「我印到哪一條」（UI 端的 local state，不是世界狀態）。
func read_command_results() -> Array:
	return _state.command_results

# ★★★玩家事件佇列的【唯讀】口（spec 2026-09-25 §2③）——同樣不是破壞性排空：
#   讀者自己記「我印到第幾筆」（那是觀眾的事，不是世界的事）。
#   ★清除由消費點依 tick 做（`SimRunner.RESULT_TTL_TICKS`，★與指令結果共用同一個常數）。
func read_player_events() -> Array:
	return _state.player_events

func player_event_count() -> int:
	return _state.player_events.size()

# 玩家主動打開互動選單時呼叫：掃描同格 NPC 加入 pending_targets
# ★★★改成【入列】（spec §3-3b）：它寫 `player_pending_targets` ＝ 世界狀態
#   ⇒ 不入列的話「玩家何時打開選單」會改變世界 ⇒ 重播不可重現。
#   ★它回 void ⇒ 沒有任何呼叫端讀得到結果 ⇒ 這一改【不牽動任何呼叫端】（我逐處查過：活的 5 處全不讀）。
# ★D3（spec 2026-10-07 四缺陷）：介面自己入列、不是玩家下的令 ⇒ 它的結果句不蓋結果行（照進事件流）
#   ⇒ 舊版按「招募」開子選單後，結果行被同一屏結算的這道令蓋成「重掃同格對象：已重掃…」
const UI_INTERNAL_COMMANDS: Array = ["refresh_targets"]
func refresh_interaction_targets() -> void:
	command_player("refresh_targets", {})

# 設定玩家狀態欄位（如 tribute_rate_input）
func set_player_input(key: String, value: Variant) -> void:
	_state.player_state[key] = value

# ★這兩支【不進佇列】：它們不改世界（稽核見 player_query_api 檔頭）
func query_inquiry_options(target_id: int) -> Dictionary:
	return PlayerQueryApi.new().get_inquiry_options(_state, target_id)

func query_recruit_menu(target_id: int) -> Dictionary:
	return PlayerQueryApi.new().get_recruit_menu(_state, target_id)

func query_faction_panel() -> Dictionary:
	return PlayerQueryApi.new().query_faction_panel(_state)

func query_outpost_panel() -> Dictionary:
	return PlayerQueryApi.new().query_outpost_panel(_state)

func query_storage_panel() -> Dictionary:
	return _query_api.get_storage_panel(_state)

func query_subteam_panel() -> Dictionary:
	return PlayerQueryApi.new().query_subteam_panel(_state)

func query_advisor_advice(advisor_pid: int, situation: String) -> String:
	var p: PersonData = _state.persons.get(advisor_pid)
	if p == null: return "顧問不存在"
	return AdvisorSystem.new().get_advice(p, situation, {}, _state)
