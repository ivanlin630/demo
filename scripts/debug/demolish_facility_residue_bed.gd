extends SceneTree
# @bed-kind: diagnostic
# slice: 拆除據點會不會留下設施等級殘值（★systems 派 2026-09-10：本輪只交事實，不動 production）
#
# ★★成對：拆前設施等級 vs 拆後 vs 重建後 —— ★★★三個數字都印，不只印結論。
# ★母體地板：拆除與重建【兩段都要真的發生】，任一段沒發生 ⇒ 不可判。

func _initialize() -> void:
	print("=== 拆除／重建的設施殘值（事實查核）===")
	var st := MeasureBedHelper.arm_and_setup("res://config/warring_states.json")
	var os_sys := OutpostSystem.new()
	# 造一格自家據點 ＋ 設施
	var team: TeamData = null
	for tid in st.teams:
		var t: TeamData = st.teams[tid]
		if t.beast_kind == "" and t.parent_team_id == -1:
			team = t
			break
	if team == null:
		print("★母體塌陷：找不到隊 ⇒ 不可判")
		print("=== 不可判（母體塌陷）——★純診斷床不下判決 ===")
		quit(1)
	var tile: HexTileData = st.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)
	if tile == null:
		print("★母體塌陷：隊腳下沒有 tile ⇒ 不可判")
		print("=== 不可判（母體塌陷）——★純診斷床不下判決 ===")
		quit(1)
	tile.outpost_type = "civilian"
	tile.outpost_level = 1
	tile.outpost_owner = team.team_id
	tile.farming_level = 2
	tile.weaponsmith_level = 1
	OwnerOutpostIndex.invalidate()
	FacilityExistenceIndex.invalidate()
	print("①拆前：outpost_level=%d owner=%d farming=%d weaponsmith=%d" % [
		tile.outpost_level, tile.outpost_owner, tile.farming_level, tile.weaponsmith_level])

	# 走 production 的拆除路徑（construction_target action=demolish 完工分支）
	tile.construction_team_id = team.team_id
	tile.construction_target = {"action": "demolish"}
	tile.construction_ticks_left = 0
	os_sys._complete_construction(st, tile, team)   # ★走 production 的完工分支（不是自己模擬一份）
	print("②拆後：outpost_level=%d owner=%d farming=%d weaponsmith=%d" % [
		tile.outpost_level, tile.outpost_owner, tile.farming_level, tile.weaponsmith_level])
	var demolished: bool = tile.outpost_level == 0
	if not demolished:
		print("★★拆除【沒有發生】⇒ 本床不可判（不是「沒有殘值」）")
		print("=== 不可判（母體塌陷）——★純診斷床不下判決 ===")
		quit(1)

	# 重建（同一格、同一隊）
	tile.construction_team_id = team.team_id
	tile.construction_target = {"action": "build", "type": "civilian", "level": 1}
	tile.construction_ticks_left = 0
	os_sys._complete_construction(st, tile, team)
	print("③重建後：outpost_level=%d owner=%d farming=%d weaponsmith=%d" % [
		tile.outpost_level, tile.outpost_owner, tile.farming_level, tile.weaponsmith_level])
	var rebuilt: bool = tile.outpost_level > 0
	print("")
	print("★結論：拆除歸零設施＝%s；重建後設施＝farming %d／weaponsmith %d（★重建段%s）" % [
		"是" if (tile.farming_level == 0 and tile.weaponsmith_level == 0) or not rebuilt else "否",
		tile.farming_level, tile.weaponsmith_level,
		"發生了" if rebuilt else "★沒發生 ⇒ 該欄不可判"])
	print("=== 事實查核完畢（★純診斷：本床不下判決，判準在交件信與測量檔）===")
	quit()
