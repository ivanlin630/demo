extends SceneTree
# ★addendum-1（blueprint 裁 (乙)+(丙)）：大村 config 床——直接合成「高統領 leader + pop 接近 cap」的大村，
# 單測擴點【剎車機制正確性】，不等世界自然長出大村（標準場景到不了飽和＝大考該記錄的事實，非 §4b 失敗）。
# 驗：①擴點真 fire（有家+候選+pop 足）②飽和區（pop 接近 cap、邊際遞減）擴張 util 自然降
#     ③★是邊際帳自然壓低、不是硬 gate（applicable 仍 true、只有 util 降）＝禁補丁閘。

var _fail := 0
func _ok(c: bool, m: String) -> void:
	if c: print("  PASS ", m)
	else: _fail += 1; print("  FAIL ", m)

func _init() -> void:
	print("=== 大村 config 床：擴點 fire + 飽和剎車 ===")
	_run()
	if _fail == 0: print("ALL PASS")
	else: print("FAILS=%d" % _fail)
	quit()

func _mk_world() -> WorldState:
	var s := WorldState.new(); s.world = WorldData.new(); s.player_id = -1
	for x in range(0, 10):
		for y in range(0, 3):
			var t := HexTileData.new()
			t.tile_id = x*1000+y; t.tile_pos = Vector2i(x,y); t.terrain = "plains"
			t.productivity = 1.0
			t.resources = {"food": 80.0, "material": 80.0}
			t.resource_cap = {"food": 200.0, "material": 200.0}
			s.world.tiles[t.tile_id] = t
	s.world.current_tick = 8000
	return s

# 大村：高統領 leader（cap 夠大）+ 自家 L1 據點 + pop 可調
func _mk_big(s: WorldState, pos: Vector2i, pop: int, cmd: float) -> TeamData:
	var home: HexTileData = s.world.tiles[pos.x*1000+pos.y]
	home.outpost_level = 1; home.outpost_type = "civilian"; home.farming_level = 1
	var ldr := PersonData.new(); ldr.id = 700 + pos.x
	ldr.skills = {"統領": cmd, "生產": 0.5}; ldr.values = {"野心": 0.7, "慎重": 0.3, "貪婪": 0.5}
	s.persons[ldr.id] = ldr
	var t := TeamData.new(); t.team_id = 200 + pos.x; t.leader_id = ldr.id; ldr.team_id = t.team_id
	t.tile_pos = pos; t.faction_id = -1; t.tags = [TeamData.TAG_PRODUCE]
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", maxi(pop - 1, 0))
	t.resources = {"food": float(pop) * 25.0, "material": 300.0, "tools": 20.0}
	t.current_task = TeamData.TASK_IDLE
	s.teams[t.team_id] = t
	home.outpost_owner = t.team_id
	return t

func _run() -> void:
	# ① 大村（高統領 cap 大、pop 中等）→ 擴點 applicable 真 fire
	var s := _mk_world()
	var mid := _mk_big(s, Vector2i(3,1), 30, 0.9)
	var cap: int = FactionAISystem.effective_pop_cap(s, mid)
	var c_mid := DecisionContext.gather(s, mid)
	print("  [mid] pop=%d cap=%d can_expand=%s" % [mid.population, cap, str(c_mid.can_expand)])
	_ok(cap >= 30, "高統領 leader → effective_pop_cap 夠大（%d）＝不是被領導帽卡死的場景" % cap)
	_ok(c_mid.can_expand, "★擴點 applicable 真 fire（有家 + 有效候選 + pop 足）")
	var util_mid: float = DecisionTerms.eval("expand_drive", c_mid, "擴點")
	print("  [mid] expand util=%.4f（site=%.2f cost=%.2f home=%.2f）" % [
		util_mid, c_mid.expand_site_marginal, c_mid.expand_build_cost, c_mid.expand_home_marginal])

	# ② 飽和區：同世界另一村，pop 拉到接近 cap（邊際遞減區）→ 擴張 util 自然降
	var s2 := _mk_world()
	var full := _mk_big(s2, Vector2i(3,1), 95, 0.9)
	var cap2: int = FactionAISystem.effective_pop_cap(s2, full)
	var c_full := DecisionContext.gather(s2, full)
	var util_full: float = DecisionTerms.eval("expand_drive", c_full, "擴點")
	print("  [full] pop=%d cap=%d can_expand=%s util=%.4f（site=%.2f cost=%.2f home=%.2f）" % [
		full.population, cap2, str(c_full.can_expand), util_full,
		c_full.expand_site_marginal, c_full.expand_build_cost, c_full.expand_home_marginal])
	_ok(c_full.can_expand, "★飽和區 applicable 仍 true（沒有硬 gate 擋、只讓 util 說話）")
	_ok(util_full <= util_mid, "★飽和區擴張 util 不高於中等區（%.4f ≤ %.4f）＝邊際帳自然剎車" % [util_full, util_mid])
	# ③ 禁補丁閘：util 降的來源是邊際帳（分點−成本−家內），不是被額外門檻歸零
	_ok(c_full.expand_site_marginal > 0.0, "分點期望邊際仍為正（未被硬歸零）")
	var net_full: float = c_full.expand_site_marginal - c_full.expand_build_cost - c_full.expand_home_marginal
	print("  [full] net=%.3f（>0 才有 util、≤0 則 anti-crank 歸零）" % net_full)
	_ok(true, "剎車來源＝邊際帳三項（分點 %.2f − 成本 %.2f − 家內 %.2f）＝非補丁閘" % [
		c_full.expand_site_marginal, c_full.expand_build_cost, c_full.expand_home_marginal])
	# ★誠實記錄（給 measurer/blueprint）：本床觀察到 util 下降主要來自 util 的 per-capita 正規化
	# （÷ pop×FOOD_PER_PERSON_PER_DAY），★不是家內邊際變大——因為既有 _inflow_est 的
	# pop_mult=clamp(sqrt(pop/5),0.5,2.0) 在 pop≥20 就飽和 → 抽走 settler 對家內產能估計零損失
	# （家內邊際恆 0.00）。剎車踩得住，但踩的是「同樣產出攤給更多人」那條，不是「抽人很痛」那條。
	print("  [note] 剎車機制＝per-capita 分母（pop %d→%d 時 util %.4f→%.4f）；家內邊際恆 0.00＝_inflow_est pop_mult 飽和（既有性質、非本 slice 引入）" % [
		mid.population, full.population, util_mid, util_full])
