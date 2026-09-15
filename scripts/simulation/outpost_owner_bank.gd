class_name OutpostOwnerBank

# Pattern B 所有權 banker：tile.outpost_owner 單一 owner(集中化+審計)。
# 本塊保 last-writer-wins(不改 race);race-policy 解析=後續 refinement(有 chokepoint 才好掛)。
# reason → WorldState.record_driver（driver-ledger；預設 off 零成本）。
static func set_owner(tile: HexTileData, owner: int, reason: String = "") -> void:
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
