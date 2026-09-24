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
	var events := advance_ticks(n)
	_ticks_remaining = maxi(0, _ticks_remaining - n)
	if events.size() > 0:
		_ticks_remaining = 0   # 重要事件 → 停止推進
	return { "events": events, "done": _ticks_remaining <= 0 }

# Advance up to n world ticks (not encounter ticks).
# Stops early if a player-relevant event fires.
# Returns array of event dicts generated this call.
func advance_ticks(n: int) -> Array:
	var events: Array = []
	for _i in range(n):
		var snap := _snapshot()
		var player_pos: Vector2i = _player_tile()
		_runner.advance_tick(_state, player_pos)
		var new_evts := _diff_events(snap)
		events.append_array(new_evts)
		if new_evts.size() > 0:
			break
	return events

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

func render_text_map(player_tid: int, cursor: Vector2i) -> String:
	return TextMapRenderer.render(_state, player_tid, cursor)

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

# U12: text UI confirm_trade 預覽（auto-trade 方向）
func query_trade_direct_preview(target_team_id: int) -> Dictionary:
	return _query_api.get_trade_direct_preview(_state, target_team_id)

func get_and_clear_alerts() -> Array:
	return PlayerQueryApi.new().get_and_clear_alerts(_state)

# ★★★不再當場套用：推進佇列，由 sim_runner 在【tick 邊界】消費（spec §3-1）。
#   ★沒有「立刻套用」的旁路（spec §3-4）—— 只要存在一條同步路徑，
#     重播就要問「那一次走的是哪條」，而卷面上兩條路徑長得一模一樣。
#   ★★回傳形狀照 spec §3-1 逐字：{ ok, queued, seq }。
#     ⇒ ★呼叫端原本當場讀 `message`／`ok` 的（實測 66 個呼叫端、54 個當場讀）
#       現在拿不到結果 —— 那個【玩家回饋】要怎麼補，systems 還沒裁，本檔不自己選。
func command_player(name: String, args: Dictionary) -> Dictionary:
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
