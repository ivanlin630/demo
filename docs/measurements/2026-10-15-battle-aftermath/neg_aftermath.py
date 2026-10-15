import io, sys, os, shutil
R = r"A:\GDS\demo\.worktrees\aftermath\scripts\simulation"
F = {"n1": "encounter_system.gd", "n2": "encounter_system.gd", "n3": "player_command_system.gd", "n4": "encounter_system.gd",
     "n5": "encounter_system.gd", "n6": "sim_runner.gd", "n7": "manpower_system.gd", "n8": "manpower_system.gd", "n9": "encounter_system.gd", "n10": "encounter_system.gd", "n11": "encounter_system.gd", "n12": "encounter_system.gd"}
n, mode = sys.argv[1], sys.argv[2]
f = os.path.join(R, F[n])
bak = f + ".negbak"
if mode == "revert":
    shutil.move(bak, f); print(n, "revert ok"); sys.exit(0)
s = io.open(f, encoding="utf-8").read()
shutil.copy(f, bak)
def rep(a, b):
    global s
    if s.count(a) != 1:
        print(n, "ANCHOR MISS", a[:80], s.count(a)); shutil.move(bak, f); sys.exit(2)
    s = s.replace(a, b)
if n == "n1":   # ①事件不走玩家事件（＝改走 NPC 訊息通道，玩家收不到）
    rep('	WorldEvents.emit(state, "combat_end", subs, false, {"aftermath": am.duplicate(true)})\n', '	pass\n')
elif n == "n2":  # ②失能謂詞拿掉血量條件
    rep('''	if unit.get("person_id", -1) == -1 \\
			and float(unit.get("blood", 100.0)) < HealthSystem.BLOOD_COMA_THRESHOLD:
		return false
''', '')
elif n == "n3":  # ③被動結清改成讀人格選（玩家 holder 照 NPC 三分數）
    rep('''	if bool(res.get("fate_pending", false)):
		res["fate_pending"] = false
		lines.append("傷兵被放走（%d 人）" % int(res.get("disabled_enemy", 0)))''', '''	if bool(res.get("fate_pending", false)):
		res["fate_pending"] = false
		var _pt: TeamData = state.teams.get(state.get_player_team_id())
		var _v: TeamData = state.teams.get(int(res.get("fate_victim", -1)))
		if EncounterSystem.npc_fate_choice(state, _pt, _v) != "release" or true:
			EncounterSystem.fate_kill(_pt, _v, int(res.get("disabled_enemy", 0)))
		lines.append("傷兵被放走（%d 人）" % int(res.get("disabled_enemy", 0)))''')
elif n == "n4":  # ④俘不設上限
    rep('	var k: int = mini(n, ManpowerSystem.captive_room(state, holder))\n', '	var k: int = n\n')
elif n == "n5":  # ⑤容量改回兩套（捕獲用人口上限餘裕）
    rep('	var k: int = mini(n, ManpowerSystem.captive_room(state, holder))\n',
        '	var k: int = mini(n, maxi(FactionAISystem.effective_pop_cap(state, holder) - holder.population - AnonTierSystem.total_captives(holder), 0))\n')
elif n == "n6":  # A3b：結清放到指令消化之前（＝放回 request_advance 的位置）
    rep('''	_consume_player_commands(state)
	# ★戰後收尾 §2d：玩家指令消化之後、世界系統之前，把沒處置的戰後 pending 以被動選項結清（冪等）
	PlayerCommandSystem.settle_pending_aftermath(state)
''', '''	PlayerCommandSystem.settle_pending_aftermath(state)
	_consume_player_commands(state)
''')
elif n == "n7":  # A7：玩家 holder 放回 decide_treatment
    rep('''			elif holder.player_controlled:
				treatment = String(group.get("treatment", "厚待"))
			else:''', '''			else:''')
elif n == "n8":  # A7c：缺糧檢查只給 NPC（＝留在 decide_treatment 裡；玩家 holder 永遠不放）
    rep('			if not captive_food_ok(state, holder):\n', '			if not holder.player_controlled and not captive_food_ok(state, holder):\n')
elif n == "n9":  # A10：玩家攻方讀人格
    rep('	if player_atk:\n		am["residents_pending"]', '	if false:\n		am["residents_pending"]')
elif n == "n10":  # systems HOW：拿掉 erase 前的記名處置 ⇒ 零懸空格紅
    rep('		state.remove_member(resident, pid)\n', '')
elif n == "n11":  # 藍圖裁：NPC 路打開 ⇒ 休眠對照格紅
    rep('if player_atk and am.has("captured_tile_id") else', 'if am.has("captured_tile_id") else')
elif n == "n12":  # 藍圖過渡閘拿掉 ⇒ 路過的隊被當居民
    rep('		if same_faction_as != -2 and (same_faction_as == -1 or t.faction_id != same_faction_as): continue\n', '')
io.open(f, "w", encoding="utf-8", newline="").write(s)
print(n, "apply ok")
