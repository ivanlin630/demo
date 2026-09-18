extends SceneTree
# @bed-kind: diagnostic
# slice: 求居／佔村改讀 belief 據點等級 —— ★世界級「有值的次數：前 vs 後」（spec §3）
#
# ★量法：跑 N tick，**跑完之後**對全部隊各做一次 `gather()`，數兩條 flow 有值的隊數。
#   ★★為什麼把觀測放在【最後】而不是逐 tick：`gather()` 會耗 global RNG
#     ⇒ 逐 tick 觀測會改變世界演化本身（今天剛量到的第四條通道）。
#   ★★★放最後 ⇒ 被觀測的那段演化是乾淨的，而兩棵樹用【完全相同的程序】各跑一次。
# ★誠實限：這是【一個時點的橫斷面】，不是整段期間的累計。
var _undec: int = 0
func _initialize() -> void:
	var days: int = int(OS.get_environment("JC_DAYS")) if OS.has_environment("JC_DAYS") else 8
	var seed_val: int = int(OS.get_environment("JC_SEED")) if OS.has_environment("JC_SEED") else 1337
	seed(seed_val)
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/warring_states.json")
	var runner := SimRunner.new()
	for _i in range(days * WorldState.TICKS_PER_DAY):
		runner.advance_tick(st, Vector2i(-1, -1))
	var teams: int = st.teams.size()
	var sn_sel: int = 0
	var occ_sel: int = 0
	var join_pos: int = 0
	var occupy_pos: int = 0
	for tid in st.teams:
		var c: DecisionContext = DecisionContext.gather(st, st.teams[tid])
		if c.strong_neighbor_id != -1: sn_sel += 1
		if c.occupy_target_id != -1: occ_sel += 1
		if c.join_host_flow > 0.0: join_pos += 1
		if c.occupy_target_flow > 0.0: occupy_pos += 1
	print("[CENSUS] days=%d seed=%d｜母體 %d 隊" % [days, seed_val, teams])
	print("[CENSUS] 選中 strong_neighbor 的隊 ＝ %d｜其中 join_host_flow 有值 ＝ %d" % [sn_sel, join_pos])
	print("[CENSUS] 選中 occupy_target 的隊 ＝ %d｜其中 occupy_target_flow 有值 ＝ %d" % [occ_sel, occupy_pos])
	print("[CENSUS] ★★兩個【母體】要一起看：分母是「選中的隊數」，不是「總隊數」——")
	print("[CENSUS]   分母自己會因為這一票而變（占領那條的候選集上游就被姊妹票改過了）。")

	# ★★★【可歸因的那個數：在【同一個世界】裡比，不跨樹】
	#   ★病：跨樹比（前 3／後 0）混了兩件事 —— 我的修法 ＋ 兩個世界本來就會分岔
	#     （母體 104 隊 vs 98 隊就是分岔的證據）⇒ ★★分子只有 3 的時候，那個比法撐不住結論。
	#   ⇒ 改問一個【同一個世界內】就能回答的問題：
	#       X ＝ 那些選中的 host，**live 地塊上真的有據點**（＝舊 code 會拿來估值的那些）
	#       Y ＝ 其中**我有親眼看過那座城的子記錄**（＝新 code 會估值的那些）
	#     ⇒ ★★★**X − Y 就是這一票【親手歸零】的那些**，而它不含任何跨樹分岔。
	var x_live: int = 0
	var y_rec: int = 0
	var ox_live: int = 0
	var oy_rec: int = 0
	for tid in st.teams:
		var c2: DecisionContext = DecisionContext.gather(st, st.teams[tid])
		if c2.strong_neighbor_id != -1:
			var hp: Vector2i = BeliefSystem.belief_pos(st, tid, c2.strong_neighbor_id)
			if hp != Vector2i(-1, -1):
				var ht: HexTileData = st.world.tiles.get(hp.x * 1000 + hp.y)
				if ht != null and ht.outpost_level > 0:
					x_live += 1
					if not BeliefSystem.known_outpost_at(st, tid, hp, c2.strong_neighbor_id).is_empty():
						y_rec += 1
		if c2.occupy_target_id != -1:
			var vp: Vector2i = BeliefSystem.belief_pos(st, tid, c2.occupy_target_id)
			if vp != Vector2i(-1, -1):
				var vt: HexTileData = st.world.tiles.get(vp.x * 1000 + vp.y)
				if vt != null and vt.outpost_level > 0:
					ox_live += 1
					if not BeliefSystem.known_outpost_at(st, tid, vp, c2.occupy_target_id).is_empty():
						oy_rec += 1
	print("[ATTRIB] join：live 有據點 X=%d｜其中我看過那座城 Y=%d ⇒ ★本票歸零 X−Y=%d" % [
		x_live, y_rec, x_live - y_rec])
	print("[ATTRIB] occupy：live 有據點 X=%d｜其中我看過那座城 Y=%d ⇒ ★本票歸零 X−Y=%d" % [
		ox_live, oy_rec, ox_live - oy_rec])
	print("[ATTRIB] ★讀法：X＝0 ⇒ 這一輪根本沒有「host 站在據點上」的樣本（不可判，不是修過頭）；")
	print("[ATTRIB]       X>0 且 Y＝0 ⇒ 【從來沒有人親眼看過那些城】＝世界事實，不是我把它擋掉；")
	print("[ATTRIB]       X>0 且 Y>0 ⇒ 兩邊都有樣本，X−Y 就是這一票真正改變的那批。")
	if sn_sel == 0 and occ_sel == 0:
		_undec += 1
		push_error("[不可判] 兩條的分母都是 0 ⇒ 這一輪什麼都沒量到（拉長 JC_DAYS）")
	print("-- 普查結束；[不可判] ＝ %d --" % _undec)
	quit(2 if _undec > 0 else 0)
