extends SceneTree
# ctx-coverage-gate 的探針（★不是床，是閘的一隻手）：
# 印出【每一支 who 動詞真的回了哪些鍵】，讓 bash 端比對 exposed 宣稱。
# ★構造最小世界＋一次 advance gather ⇒ 不跑 tick、不載 config（★閘要便宜）。
# ★★輸出格式：WHOKEYS <verb>\t<key1> <key2> …／WHOMISSING <verb>（動詞不存在）

func _initialize() -> void:
	var st := WorldState.new()
	st.world = WorldData.new()
	st.world.current_tick = 1000
	var tile := HexTileData.new()
	tile.tile_id = 1001
	tile.tile_pos = Vector2i(1, 1)
	tile.terrain = "plains"
	st.world.tiles[1001] = tile
	var t := TeamData.new()
	t.team_id = 1
	t.tile_pos = Vector2i(1, 1)
	AnonTierSystem.add_anon(t, "平民", 5)
	var ldr := PersonData.new()
	ldr.id = 11
	ldr.team_id = 1
	st.persons[11] = ldr
	t.leader_id = 11
	st.teams[1] = t
	st.player_id = 11
	# ★引擎那條路（advance=true）才會寫快照 —— 探針走的是【真的那條】，不是自己塞一個
	DecisionContext.gather(st, t, true)
	var q := PlayerQueryApi.new()
	for verb in ["get_decision_snapshot", "get_player_snapshot", "get_team_details"]:
		if not q.has_method(verb):
			print("WHOMISSING %s" % verb)
			continue
		var r
		match verb:
			"get_player_snapshot": r = q.get_player_snapshot(st, {})
			"get_team_details": r = q.get_team_details(st, 1)
			_: r = q.get_decision_snapshot(st)
		var keys := {}
		_collect(r, keys)
		var arr: Array = keys.keys()
		arr.sort()
		print("WHOKEYS %s\t%s" % [verb, " ".join(arr)])
	print("PROBE-DONE")
	quit()

func _collect(v, keys: Dictionary) -> void:
	if v is Dictionary:
		for k in v:
			keys[String(k)] = true
			_collect(v[k], keys)
	elif v is Array:
		for e in v:
			_collect(e, keys)
