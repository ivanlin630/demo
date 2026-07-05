extends SceneTree

# ★ 序4 vendetta 溶入 融合驗（核心交付）。融合非刪：hand vendetta dispatch（PRIO_VENDETTA 直塞
#   TASK_ATTACK）撕除後，feud_pull 掛進 攻擊 option → 血仇成攻擊的一個 weight 驅力。
#   repertoire 該出現還出現、優先序（威脅>血仇>致富攻擊）由 rank 權重 + PRIO 保。鏡射 rung/threat check 風格。
#
#   §5 融合驗錨：
#     1) repertoire：強血仇(intensity 高)+衝動 leader(好戰0.9/慎重0.2)+可見仇敵 → rank_scored_ctx[0]=="攻擊"；
#        無血仇/溫和 leader → 攻擊 非 applicable（feud_pull=0）。
#     2) 優先序 血仇>致富攻擊：血仇隊 攻擊(feud) util 贏過同隊 prosperity option（掠奪）。
#     3) to_task 血仇 target：gather ctx → feud_target_id=仇敵；to_task("攻擊") combat_target=仇敵（非最近獨立 decoy）。
#     4) 優先序 威脅>血仇：壓境威脅下 rank[0]=威脅反應（survival/迎戰…）非攻擊（survival_pressure 碾壓 feud）；
#        loop3 PRIO_THREAT(70) > engine PRIO_DISPATCH(50) 再保 sticky 一層。
# 任一破 = 融合失敗。

var _fails: int = 0

func _initialize() -> void:
	_check_repertoire()
	_check_feud_over_enrich()
	_check_to_task_target()
	_check_threat_over_feud()
	if _fails == 0:
		print("[vendetta-dissolution] ALL PASS")
	else:
		print("[vendetta-dissolution] FAIL count=%d" % _fails)
	quit()

# ── 手構 ctx（deterministic，繞世界 setup）。leader_values + feud 欄位直填 ──
func _ctx(vals: Dictionary) -> DecisionContext:
	var c := DecisionContext.new()
	c.leader_values = vals
	c.food_days = 14.0          # 吃飽（survival_pressure=0，不誤壓；亦關匱乏→搶 boost）
	c.population = 20           # > FORAGE_VIABLE_POP → 覓食不 applicable
	c.threat_threshold = 999.0  # 無威脅：threat repertoire 不 applicable
	c.self_armed_ratio = 0.8    # 有牙（capability 足，attack/loot 不被壓平）
	return c

func _opts(c: DecisionContext) -> Array:
	var out: Array = []
	for e in DecisionEngine.rank_scored_ctx(c): out.append(e["opt"])
	return out

func _first(c: DecisionContext) -> String:
	var r: Array = DecisionEngine.rank_scored_ctx(c)
	return r[0]["opt"] if not r.is_empty() else "<空>"

# ── §5-1 repertoire ──
func _check_repertoire() -> void:
	print("--- §5-1 repertoire (血仇 → 攻擊 融合) ---")
	# 強血仇 + 衝動 leader（好戰0.9/慎重0.2）+ 可見仇敵 → 攻擊 rank[0]。
	# 純血仇路（無 faction_stakes/征服 intent）：攻擊 util 唯一貢獻 = feud_pull × weight(feud)。
	var c1 := _ctx({"好戰": 0.9, "慎重": 0.2, "義氣": 0.3, "野心": 0.4})
	c1.strongest_feud = 1.0
	c1.feud_target_id = 1
	var top1: String = _first(c1)
	if top1 == "攻擊":
		print("[repertoire] 強血仇衝動 leader → rank[0]=攻擊 OK (ranked=%s)" % str(_opts(c1)))
	else:
		_fails += 1
		print("[FAIL] 強血仇衝動 leader 預期 rank[0]=攻擊 得 %s (ranked=%s)" % [top1, str(_opts(c1))])

	# 無血仇 + 溫和 leader → 攻擊 非 applicable（feud_pull=0，無 faction/征服 → 攻擊 gate 全不過）。
	var c2 := _ctx({"好戰": 0.2, "慎重": 0.7, "義氣": 0.6})
	c2.strongest_feud = 0.0
	c2.feud_target_id = -1
	if "攻擊" in _opts(c2):
		_fails += 1
		print("[FAIL] 無血仇溫和 leader 竟開攻擊（ranked=%s）" % str(_opts(c2)))
	else:
		print("[repertoire] 無血仇溫和 leader → 攻擊 不 applicable OK (ranked=%s)" % str(_opts(c2)))

# ── §5-2 優先序：血仇 > 致富攻擊（掠奪）──
func _check_feud_over_enrich() -> void:
	print("--- §5-2 優先序 血仇>致富攻擊 ---")
	# 血仇隊同時有弱 prey（掠奪 applicable）→ 攻擊(feud) util 應贏過 掠奪(致富)。
	var c := _ctx({"好戰": 0.9, "慎重": 0.2, "殘忍": 0.5, "貪婪": 0.5})
	c.strongest_feud = 1.0
	c.feud_target_id = 1
	c.has_weak_prey = true
	c.weak_prey_pos = Vector2i(3, 0)
	var opts: Array = _opts(c)
	var ai: int = opts.find("攻擊")
	var li: int = opts.find("掠奪")
	if ai == -1 or li == -1:
		_fails += 1
		print("[FAIL] 攻擊/掠奪 應同時 applicable（攻擊=%d 掠奪=%d ranked=%s）" % [ai, li, str(opts)])
	elif ai < li:
		print("[repertoire] 血仇>致富攻擊 → 攻擊 rank(%d) 先於 掠奪 rank(%d) OK (ranked=%s)" % [ai, li, str(opts)])
	else:
		_fails += 1
		print("[FAIL] 血仇未勝致富：攻擊 rank(%d) 未先於 掠奪 rank(%d) (ranked=%s)" % [ai, li, str(opts)])

# ── §5-3 to_task 血仇 target：feud_target_id + combat_target=仇敵（非最近獨立 decoy）──
func _check_to_task_target() -> void:
	print("--- §5-3 to_task 血仇 target ---")
	var s := WorldState.new(); s.world = WorldData.new(); s.player_id = -1
	_fill_plains(s, 6)
	# 仇敵隊（feud foe，遠）：team0 @ (5,0)。
	var foe := TeamData.new(); foe.team_id = 0; foe.tile_pos = Vector2i(5, 0)
	var foe_ldr := PersonData.new(); foe_ldr.id = 1; foe_ldr.team_id = 0
	s.persons[1] = foe_ldr; foe.leader_id = 1; AnonTierSystem.add_anon(foe, "平民", 3)
	foe.resources = {"food": 200.0}; s.teams[0] = foe
	# 脫軌者隊（avenger）：team1 @ (0,0)，好戰0.9/慎重0.2 → vendetta gate 過。
	var av := TeamData.new(); av.team_id = 1; av.tile_pos = Vector2i(0, 0); av.faction_id = -1
	var av_ldr := PersonData.new(); av_ldr.id = 2; av_ldr.team_id = 1
	av_ldr.values = {"好戰": 0.9, "慎重": 0.2, "義氣": 0.9}
	s.persons[2] = av_ldr; av.leader_id = 2; AnonTierSystem.add_anon(av, "戰士", 30)
	av.resources = {"food": 300.0}; s.teams[1] = av
	# decoy 獨立隊（近，無血仇）：team2 @ (1,0)。_nearest_independent(av) 應回 decoy（比 foe 近）。
	var decoy := TeamData.new(); decoy.team_id = 2; decoy.tile_pos = Vector2i(1, 0); decoy.faction_id = -1
	var dc_ldr := PersonData.new(); dc_ldr.id = 3; dc_ldr.team_id = 2
	s.persons[3] = dc_ldr; decoy.leader_id = 3; AnonTierSystem.add_anon(decoy, "平民", 5)
	decoy.resources = {"food": 100.0}; s.teams[2] = decoy
	# feud：av_ldr 對 foe_ldr（person 1，team 0）血仇。
	NpcAiSystem.form_feud(av_ldr, 1, 0.8, 0)
	s.team_discovered[1] = [0, 2]

	var ctx := DecisionContext.gather(s, av)
	if ctx.feud_target_id != 0:
		_fails += 1
		print("[FAIL] gather feud_target_id 預期 0(foe) 得 %d" % ctx.feud_target_id)
	else:
		print("[target] gather feud_target_id=0(foe) OK")
	# sanity：_nearest_independent 回 decoy(2)（比 foe(0) 近）→ 若 to_task 走血仇路才會 target foe。
	var nid: int = FactionAISystem.new()._nearest_independent(s, av)
	print("[target] _nearest_independent(av)=%d（decoy 應為 2，證血仇路非最近獨立）" % nid)
	var td: Dictionary = DecisionOptions.to_task(s, av, "攻擊")
	var ct: int = int(td.get("combat_target", -1))
	if ct == 0:
		print("[target] to_task(攻擊) combat_target=0(foe) OK (td=%s)" % str(td))
	else:
		_fails += 1
		print("[FAIL] to_task(攻擊) combat_target 預期 0(foe，血仇 target) 得 %d (td=%s)" % [ct, str(td)])

# ── §5-4 優先序：威脅 > 血仇 ──
# 威脅反應（survival/備戰/迎戰/求和）與 攻擊(feud) 同在 rank_scored 競秤（applicable threat-gated 掛入）。
# 壓境威脅（threat≈0.9）下 survival_pressure(=threat) util 碾壓 feud attack util → rank[0]=威脅反應非攻擊。
# 非 unified idle 隊此 rank 走 _evaluate_solo（loop2），故威脅反應在 dispatch 當下即勝血仇；
# 且 loop3 PRIO_THREAT(70) > engine PRIO_DISPATCH(50) 再保一層（sticky threat 不被血仇搶）。
func _check_threat_over_feud() -> void:
	print("--- §5-4 優先序 威脅>血仇 ---")
	# 強血仇衝動 leader + 壓境威脅（threat/threat_react≈0.9 過門檻）。
	var c := _ctx({"好戰": 0.9, "慎重": 0.2, "求生欲": 0.6, "貪婪": 0.5, "信義": 0.5})
	c.strongest_feud = 1.0
	c.feud_target_id = 1
	c.threat_threshold = 0.4
	c.threat_react = 0.9          # threat option applicable 過門檻
	c.threat = 0.9                # survival_pressure(threat) 量級 → 碾壓 feud attack
	c.threat_id = 9
	c.threat_pos = Vector2i(6, 5)
	c.is_resident = false
	var opts: Array = _opts(c)
	var top: String = _first(c)
	var threat_opts := ["survival", "備戰", "迎戰", "求和"]
	if top == "攻擊":
		_fails += 1
		print("[FAIL] 威脅>血仇：rank[0]=攻擊（血仇壓過壓境威脅，ranked=%s）" % str(opts))
	elif top in threat_opts:
		# repertoire 保：攻擊 仍在 rank（血仇未消失，只被威脅壓）。
		var still: String = "攻擊仍在 repertoire" if "攻擊" in opts else "攻擊被壓出當前 rank"
		print("[priority] 威脅>血仇 → rank[0]=%s（威脅反應勝血仇；%s）OK (ranked=%s)" % [top, still, str(opts)])
	else:
		_fails += 1
		print("[FAIL] 威脅>血仇：rank[0]=%s 非威脅反應（ranked=%s）" % [top, str(opts)])

func _tile(s: WorldState, pos: Vector2i) -> void:
	var key: int = pos.x * 1000 + pos.y
	if not s.world.tiles.has(key):
		var t := HexTileData.new()
		t.tile_id = key; t.tile_pos = pos; t.terrain = "plains"
		s.world.tiles[key] = t

func _fill_plains(s: WorldState, radius: int) -> void:
	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			_tile(s, Vector2i(x, y))
