extends SceneTree
# @observe-pure
# ★★★A#14 驗證床：**combat 死【現在】還接不接得到 SpecimenTracer**。
#
# ★systems 的規定：判準是【跑】不是【讀】——今天已經三條（#19/#30/#36）是「問題早沒了或被誇大」，
#   而每一條都是【查完才知道】。所以本床先證「病還在不在」，再談修。
#
# ★★做法：指定一隊為 specimen → 讓它【真的死在戰鬥裡】→ 看 tracer 有沒有記到那一刻。
#   ★死法走真路徑：`NpcCombatSystem` 逐 round 打到敗方 pop=0（不是手動 erase）。
# ★★★對照（防「它其實記得到，只是我沒讀對」）：同一隊在【決策】路徑上必須記得到 ——
#   若決策也記不到，那是床設錯，不是產品的病。

var _fail := 0
func _ok(c: bool, m: String) -> void:
	if c: print("  PASS ", m)
	else: _fail += 1; print("  FAIL ", m)

func _mk_team(state: WorldState, tid: int, pos: Vector2i, pop: int, weapons: int) -> TeamData:
	var t := HexTileData.new()
	t.tile_id = pos.x * 1000 + pos.y; t.tile_pos = pos; t.terrain = "plains"
	t.outpost_owner = -1; t.outpost_level = 0
	state.world.tiles[t.tile_id] = t
	var ldr := PersonData.new(); ldr.id = tid * 100 + 1
	ldr.team_id = tid
	ldr.values = {"好戰": 0.6, "求生欲": 0.3, "慎重": 0.3}
	ldr.skills = {"戰鬥": 0.5, "統領": 0.4}
	state.persons[ldr.id] = ldr
	var team := TeamData.new(); team.team_id = tid; team.leader_id = ldr.id
	team.tile_pos = pos; team.current_task = TeamData.TASK_IDLE
	state.teams[tid] = team
	state.add_member(team, ldr.id)
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", maxi(pop - 1, 0))
	team.resources = {"food": 200.0, "weapon_melee_low": weapons}
	return team

func _init() -> void:
	print("=== A#14 specimen combat-death 驗證 ===")
	var state := MeasureBedHelper.arm_and_new()
	seed(1337)
	var victim := _mk_team(state, 1, Vector2i(5, 5), 3, 0)      # 弱：3 人無武器
	var killer := _mk_team(state, 2, Vector2i(5, 5), 40, 40)    # 強：40 人全武裝
	var pop_start: int = victim.population
	state.specimen_team_ids = [1]
	SpecimenTracer.reset()
	SpecimenTracer.enabled = true

	# ── 對照 A：決策路徑【記得到】（證床沒設錯）────────────────────────────
	FactionAISystem.new()._evaluate_solo(state, victim)
	var after_decision: int = SpecimenTracer.entries.size()
	_ok(after_decision > 0, "對照：決策路徑記得到（entries=%d）★沒有這條，下面的 0 證明不了任何事" % after_decision)

	# ── 真事件：把 specimen 打死 ────────────────────────────────────────────
	var before_death: int = SpecimenTracer.entries.size()
	var nc := NpcCombatSystem.new()
	var rounds: int = 0
	# ★敗方會【力竭撤退】＝正確行為（敗北出路），所以一次交戰打不死它
	#   ⇒ 反覆交戰直到 pop 歸零（★這才是「殲滅稀但會發生」的真實形狀）
	while state.teams.has(1) and state.teams[1].population > 0 and rounds < 4000:
		if int(state.teams[1].combat_target) == -1:
			nc.start_combat(state, 2, 1)
		nc.process_ongoing_combat(state, [1, 2])
		state.world.current_tick += 1
		rounds += 1
	var victim_gone: bool = (not state.teams.has(1)) or state.teams[1].population <= 0
	# ★★★systems 2026-09-02：這個數字【床早就算了卻沒印】—— 而沒有它，Δ=0 分不出兩個解釋：
	#   (a) tracer 對戰鬥盲   (b) 這 4000 round 根本沒事發生
	#   ⇒ 判準⑨（床有效性）：★窗內那件事有沒有真的發生，要【印在輸出上】，不是靠讀 code 反推。
	var deaths_combat: int = int(Probe.counts.get("death.combat_pop", 0))
	var pop_end: int = state.teams[1].population if state.teams.has(1) else 0
	print("  戰鬥 round=%d｜specimen 還在世界裡=%s｜pop=%s"
		% [rounds, str(state.teams.has(1)),
		   str(state.teams[1].population) if state.teams.has(1) else "已 erase"])
	# ★★★這一條【不是斷言，是事實記錄】：殲滅在本引擎是【稀有】的（敗方會力竭撤退＝正確行為），
	#   fixture 打了上千 round 也沒把它打死 ⇒ ★把它寫成 FAIL 會變成一張【假紅】的床。
	print("  ★註記：specimen 被打死了嗎 = %s（★殲滅稀＝設計如此，fixture 逼不出來是正常的）"
		% str(victim_gone))
	# ★★★窗內【真的發生了什麼】—— 這三個數字讓上面的 Δ=0 可解讀
	print("  ★★事件母體：specimen pop %d → %d（★掉了 %d 人）｜Probe death.combat_pop=%d"
		% [pop_start, pop_end, pop_start - pop_end, deaths_combat])
	print("  ★★★所以 Δ=0 不是「什麼都沒發生」：★真有人員傷亡，而 tracer 一筆都沒記")
	print("  ★誠實限（強度）：40 全武裝打 %d 無武器、4000 round 只掉 %d 人 ⇒ 【事件母體 ＝ %d】"
		% [pop_start, pop_start - pop_end, pop_start - pop_end])
	print("    ⇒ ★★「tracer 對戰鬥盲」是用【一個樣本】坐實的：方向可信（0 vs %d），★★★強度不可信"
		% [pop_start - pop_end])
	print("    ⇒ ★分不出【全盲】與【漏記率高】—— 要分，得先有一張傷亡率不是 1/4000 的床")

	var after_death: int = SpecimenTracer.entries.size()
	var delta: int = after_death - before_death
	print("  交戰前後 tracer entries：%d → %d（Δ=%d）" % [before_death, after_death, delta])
	# ★★真正的斷言在這裡，而它【比原本那條弱、也比原本那條可證】：
	#   不必打死它 —— 這上千 round 裡有傷亡、有負傷、有撤退、有追擊補刀，
	#   ★★★而 tracer 對【整段戰鬥】記了 0 筆。死亡只是這條盲線的終點，不是它的全部。
	_ok(delta > 0, "★★★戰鬥這一整段被 tracer 記到（Δ>0）—— 這一條紅＝盲點還在")

	# ★★只掃【交戰之後新增】的那些 —— 掃全部會被「決策那一筆」裡的 combat 欄位騙過去
	#   （第一版就是這樣假綠的：對照那筆自己就含 combat 欄 ⇒ 斷言恆真）
	var has_combat_marker: bool = false
	for i in range(before_death, SpecimenTracer.entries.size()):
		var es: String = str(SpecimenTracer.entries[i])
		if es.find("combat") >= 0 or es.find("戰") >= 0 or es.find("death") >= 0:
			has_combat_marker = true; break
	_ok(has_combat_marker, "★【新增的】記錄裡認得出戰鬥/死亡（不只是多了一筆）")

	# ── ★★★死亡本身（systems 2026-09-02 裁：用 `erase` 那一刻當觸發）─────────
	#   ★理由（他的）：erase 就是死亡的【定義點】；而「戰鬥致死的殲滅」是更窄的情境，
	#   ★★而我實測過【殲滅稀是設計】（敗方會力竭撤退）⇒ 要求它會讓驗收【不可達】。
	var before_erase: int = SpecimenTracer.entries.size()
	if state.teams.has(1):
		state.erase_team(1)
	var after_erase: int = SpecimenTracer.entries.size()
	print("  erase 前後 tracer entries：%d → %d（Δ=%d）" % [before_erase, after_erase, after_erase - before_erase])
	_ok(after_erase - before_erase == 1, "★★★死亡被 tracer 記到【剛好一筆】（不是 0、也不是重複記）")
	var death_ok: bool = false
	for i2 in range(before_erase, SpecimenTracer.entries.size()):
		var d: Dictionary = SpecimenTracer.entries[i2]
		if String(d.get("kind", "")) == "death":
			death_ok = true
			print("    記到的內容：tick=%s pop=%s famine_days=%s task=%s reason=%s"
				% [str(d.get("tick")), str(d["狀態"]["pop"]), str(d["狀態"]["famine_days"]),
				   str(d["狀態"]["task"]), str(d["做什麼"]["result"])])
	_ok(death_ok, "★記錄認得出這是【死亡】（kind=death，不是又一筆決策）")
	_ok(SpecimenTracer.death_count == 1, "★death_count 獨立計數（沒混進 decision_count）")

	print("  ★誠實限：")
	print("    ①本床走 NpcCombatSystem 真路徑；若某天 combat 改走別的路，本床會【綠著】而病回來")
	print("    ②★★本床【沒有】逼出真殲滅：戰鬥段證的是「戰鬥全段不可見」，")
	print("      ★★★而死亡段用的是 erase（死亡的定義點，systems 裁准）——")
	print("      ★『戰鬥致死那一刻可見』仍【未直接驗】，這是本票【較弱但可達】的形式")
	if _fail == 0: print("ALL PASS")
	else: print("FAILS=%d" % _fail)
	quit()
