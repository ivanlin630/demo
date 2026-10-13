class_name OutpostOwnerBank

# Pattern B 所有權 banker：tile.outpost_owner 單一 owner(集中化+審計)。
# 本塊保 last-writer-wins(不改 race);race-policy 解析=後續 refinement(有 chokepoint 才好掛)。
# reason → WorldState.record_driver（driver-ledger；預設 off 零成本）。
# ★簽章帶 state（spec 2026-10-13-alliance-never-moves-faction-leader #8-0）：易主要進玩家事件流 ⇒ 需要 state 才能 emit
#   ★state 可為 null（沒有世界的單元床）⇒ 只記帳、不發事件
static func set_owner(state: WorldState, tile: HexTileData, owner: int, reason: String = "") -> void:
	if tile.outpost_owner == owner:
		return
	# ★★★【易主事件計數】（defer token `outpost-owner-change-tap`，2026-09-16 解鎖）：
	#   ★病：「擁有據點的隊 18 → 24」是**兩個端點的差**，不是事件數 ——
	#     淨變化 +6 可以是 6 次易主，**也可以是 10 次易主 ＋ 4 支原擁有者死亡**
	#   ⇒ ★★**端點差會把 churn 壓平成一個小數字。**
	#   ★★★所以這裡記【事件】，而且分兩維：**因為什麼**（reason）× **什麼形狀的轉移**：
	#     無主→有主 ＝ 接手／蓋起來的那一側｜有主→有主 ＝ **真正的「搶來的」**｜有主→無主 ＝ 釋放
	#   ★純計數：零 RNG、不改控制流、不寫 state。
	var _prev_owner: int = tile.outpost_owner
	tile.outpost_owner = owner
	OwnerOutpostIndex.invalidate()   # ★效能 arc B chokepoint①：owner 真變 → owner→outpost 索引失效
	_emit_if_player_related(state, tile, _prev_owner, owner, reason)
	WorldState.record_driver(tile, "outpost_owner", float(owner), reason, "ownership")
	Probe.bump("g1.outpost_change")
	if Probe.enabled:
		var _shape: String = "unowned_to_owned"
		if _prev_owner != -1 and owner != -1:
			_shape = "owned_to_owned"      # ★這一格才是「搶來的」
		elif _prev_owner != -1 and owner == -1:
			_shape = "owned_to_unowned"
		Probe.bump("outpost.owner_change.shape." + _shape)
		Probe.bump("outpost.owner_change.reason." + (reason if reason != "" else "(未具名)"))
		Probe.bump("outpost.owner_change.%s.%s" % [_shape, (reason if reason != "" else "(未具名)")])

# ★據點易主進玩家事件流（#8-0，收 R² #8+#9）：
#   ·只在【玩家相關】時 emit：舊主或新主是玩家隊或其同勢力隊；subjects 只放這些隊
#   ·wake_thinking=false；★★NPC↔NPC 易主【不 emit】—— emit 會對每個 subject 標 pending_rethink（共用水管、不入指紋），
#     對 NPC 發會悄悄改它們的行為、fp 抓不到
#   ·init（開局佈置）不發
static func _emit_if_player_related(state: WorldState, tile: HexTileData, prev: int, now: int, reason: String) -> void:
	if state == null or reason == "init":
		return
	var ptid: int = state.get_player_team_id()
	if ptid == -1:
		return
	var pt: TeamData = state.teams.get(ptid)
	var pfid: int = int(pt.faction_id) if pt != null else -1
	var subjects: Array = []
	for tid in [prev, now]:
		if int(tid) == -1 or subjects.has(int(tid)):
			continue
		var t: TeamData = state.teams.get(int(tid))
		if int(tid) == ptid or (t != null and pfid != -1 and int(t.faction_id) == pfid):
			subjects.append(int(tid))
	if subjects.is_empty():
		return
	WorldEvents.emit(state, "outpost_owner_changed", subjects, false,
		{"pos": tile.tile_pos, "old": prev, "new": now, "reason": reason})
