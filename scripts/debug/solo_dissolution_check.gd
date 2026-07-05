extends SceneTree

# ★ 序2 solo 融合驗（核心交付）。融合非刪 + 反向（capability-grounded）。鏡射 threat_dissolution_check 風格。
#   6a repertoire：9 反應（攻擊/掠奪/外交/survival/生產/貿易/駐守/紮營/投靠）各由對應人格×情境原型達成。
#   6b 反向（capability grounding，藍圖核心）：
#      - 無牙商隊（無 armed）+ 弱prey → 攻擊/掠奪 不在 rank[0]（capability≈0 壓平，非 tag-label 禁）。
#      - 重甲商隊（有 armed）+ 絕境 + 弱prey → 掠奪 可進前列（鎖來自戰力非 label）。
#      - 軍隊（好戰高+有 armed）→ 攻擊傾向在，非誤貿易。
#   Task4 補：unified 守恆（有牙 unified 商隊不被 grounding 誤癱瘓）。
# 任一破 = 融合失敗。

var _fails: int = 0

func _initialize() -> void:
	_check_repertoire()
	_check_reverse()
	_check_unified_conservation()
	if _fails == 0:
		print("[solo-dissolution] ALL PASS")
	else:
		print("[solo-dissolution] FAIL count=%d" % _fails)
	quit()

# ── 手構 ctx（deterministic，繞世界 setup）。leader_values + 情境欄位直填 ──
func _ctx(vals: Dictionary) -> DecisionContext:
	var c := DecisionContext.new()
	c.leader_values = vals
	c.food_days = 14.0        # 預設吃飽（survival_pressure=0，不誤壓）
	c.population = 20         # > FORAGE_VIABLE_POP(15) → 覓食預設不 applicable（除非測試改小）
	c.threat_threshold = 999.0  # 預設無威脅：threat_react(0) < threshold → 備戰/迎戰/求和 不 applicable
	return c                    #   （threat repertoire 由 threat_dissolution_check 專驗；此處驗 solo 主 menu）

func _first(c: DecisionContext) -> String:
	var r: Array = DecisionEngine.rank_scored_ctx(c)
	return r[0]["opt"] if not r.is_empty() else "<空>"

func _opts(c: DecisionContext) -> Array:
	var out: Array = []
	for e in DecisionEngine.rank_scored_ctx(c): out.append(e["opt"])
	return out

func _expect(label: String, c: DecisionContext, expected: String) -> void:
	var got: String = _first(c)
	if got != expected:
		_fails += 1
		print("[FAIL] repertoire 原型%s 預期 %s 得 %s (ranked=%s)" % [label, expected, got, str(_opts(c))])
	else:
		print("[repertoire] 原型%s → %s OK" % [label, got])

# ── 6a repertoire：9 反應各可達 ──
func _check_repertoire() -> void:
	print("--- 6a repertoire (9 反應) ---")

	# 1) 攻擊：好戰野心高 + 有戰兵 + 弱prey + 征服 intent + ready（序5：征服攻擊吃 readiness 閘，沒本錢不出征）
	var c1 := _ctx({"好戰": 0.9, "野心": 0.9, "貪婪": 0.5})
	c1.self_armed_ratio = 0.5; c1.has_weak_prey = true
	c1.intent = "征服"; c1.intent_target = 1
	c1.readiness = 0.8; c1.readiness_thr_eff = 0.5   # 序5 溶入：readiness factor（否則趨0=送死沒本錢）
	_expect("攻擊", c1, "攻擊")

	# 2) 掠奪：貪婪高 + 弱prey + 有戰兵（無征服 intent → 攻擊 不 applicable）
	var c2 := _ctx({"貪婪": 0.9, "好戰": 0.5, "殘忍": 0.5})
	c2.self_armed_ratio = 0.5; c2.has_weak_prey = true
	_expect("掠奪", c2, "掠奪")

	# 3) 貿易：貪婪高 + 市場（有貨+套利+商隊）
	var c3 := _ctx({"貪婪": 0.9})
	c3.has_goods = true; c3.has_arb = true; c3.is_merchant = true
	_expect("貿易", c3, "貿易")

	# 4) 駐守：慎重高 + own outpost（有貨→produce 低，駐守勝生產）
	var c4 := _ctx({"慎重": 0.9, "野心": 0.2, "貪婪": 0.3})
	c4.has_own_outpost = true; c4.has_goods = true
	_expect("駐守", c4, "駐守")

	# 5) 生產：野心高 + own outpost + 階梯缺口（ambition_drive 推生產過建設/駐守）
	var c5 := _ctx({"野心": 0.9, "慎重": 0.5})
	c5.has_own_outpost = true; c5.ambition_gap = 3
	_expect("生產", c5, "生產")

	# 6) 紮營：求生欲高 + 無own + farmable + 絕境（pop 大→覓食不 applicable）
	var c6 := _ctx({"求生欲": 0.9, "野心": 0.3})
	c6.food_days = 1.0; c6.has_farmable_tile = true
	_expect("紮營", c6, "紮營")

	# 7) 投靠：義氣高 + strong neighbor + 絕境
	var c7 := _ctx({"義氣": 0.9, "求生欲": 0.5, "信義": 0.5})
	c7.food_days = 1.0; c7.has_strong_neighbor = true
	_expect("投靠", c7, "投靠")

	# 8) survival(FLEE)：求生欲高 + 威脅逼近（ctx.threat 高，threat_react 低不觸 備戰/迎戰）
	var c8 := _ctx({"求生欲": 0.9})
	c8.threat = 0.9
	_expect("survival", c8, "survival")

	# 9) 外交：派系 directive=外交 + 有 target（faction member 語意）
	var c9 := _ctx({"義氣": 0.7, "計謀": 0.6, "_loyalty": 0.9, "野心": 0.3})
	c9.faction_stakes = ["外交"]; c9.faction_diplo_target = 1
	_expect("外交", c9, "外交")

# ── 6b 反向（capability grounding，藍圖核心）──
func _check_reverse() -> void:
	print("--- 6b 反向 (capability grounding) ---")

	# 無牙商隊：好戰低 + 無 armed（self_armed_ratio=0）+ 弱prey 在場 → 攻擊/掠奪 不在 rank[0]。
	# capability≈0 壓平 loot/attack eval；常態選貿易/其他（非被 tag 禁）。
	var cm := _ctx({"好戰": 0.2, "貪婪": 0.7, "殘忍": 0.5})
	cm.self_armed_ratio = 0.0; cm.has_weak_prey = true
	cm.is_merchant = true; cm.has_goods = true
	var top_m: String = _first(cm)
	if top_m == "攻擊" or top_m == "掠奪":
		_fails += 1
		print("[FAIL] 無牙商隊劫匪化：rank[0]=%s（capability grounding 未壓平；ranked=%s）" \
			% [top_m, str(_opts(cm))])
	else:
		print("[反向] 無牙商隊不劫匪化 → rank[0]=%s OK（攻擊/掠奪 被 capability≈0 壓平）" % top_m)

	# 重甲商隊絕境可揮刀：有 armed + 絕境（food<3）+ 弱prey → 掠奪 進前列（top2）。
	# 證「鎖來自戰力非 label」——同商隊人格，只差 armed 與匱乏，就能揮刀。
	var ca := _ctx({"好戰": 0.3, "貪婪": 0.7, "野心": 0.6, "殘忍": 0.5})
	ca.self_armed_ratio = 0.5; ca.has_weak_prey = true
	ca.food_days = 1.0        # 絕境 → intent_fit 匱乏→搶
	var opts_a: Array = _opts(ca)
	var top2_a: Array = opts_a.slice(0, 2)
	if "掠奪" in top2_a:
		print("[反向] 重甲商隊絕境可揮刀 → 掠奪 進前列 OK (top2=%s)" % str(top2_a))
	else:
		_fails += 1
		print("[FAIL] 重甲商隊絕境無法揮刀：掠奪 不在前列（ranked=%s）" % str(opts_a))

	# 軍隊不變雜貨商：好戰高 + 有 armed + 征服 intent + 弱prey → 攻擊傾向在（rank[0]=攻擊，非誤貿易）。
	var cs := _ctx({"好戰": 0.9, "野心": 0.7, "貪婪": 0.5})
	cs.self_armed_ratio = 0.6; cs.has_weak_prey = true
	cs.intent = "征服"; cs.intent_target = 1
	var top_s: String = _first(cs)
	if top_s == "貿易":
		_fails += 1
		print("[FAIL] 軍隊變雜貨商：rank[0]=貿易（ranked=%s）" % str(_opts(cs)))
	elif top_s == "攻擊" or top_s == "掠奪":
		print("[反向] 軍隊不變雜貨商 → rank[0]=%s OK" % top_s)
	else:
		_fails += 1
		print("[FAIL] 軍隊反應異常：rank[0]=%s 非攻擊/掠奪（ranked=%s）" % [top_s, str(_opts(cs))])

# ── Task4：unified 守恆（capability grounding 進共用 eval → unified 隊也受影響；驗有牙不誤癱瘓、無牙一致）──
# 真世界 setup（rank_scored(state,team) 走真 gather，非手構 ctx）：同情境健康 unified 商隊 + 弱prey，
# 只差 armed_anon_ratio → 驗 grounding 按戰力分辨（有牙掠奪 util>0=可揮刀；無牙≈0=同 solo 反向一致）。
func _check_unified_conservation() -> void:
	print("--- Task4 unified 守恆 (capability grounding 不誤癱瘓有牙 unified 商隊) ---")
	var armed_loot: float = _merchant_loot_util(0.6)    # 有牙 unified 商隊
	var unarmed_loot: float = _merchant_loot_util(0.0)  # 無牙 unified 商隊
	print("[unified] 掠奪 util 有牙=%.3f 無牙=%.3f" % [armed_loot, unarmed_loot])
	# 無牙 unified 商隊：掠奪 被 capability 壓平（≈0）→ 與 solo 反向一致（無牙不劫匪化，跨路徑同理）。
	if unarmed_loot > 0.01:
		_fails += 1
		print("[FAIL] 無牙 unified 商隊 掠奪 util=%.3f 未被壓平（grounding 未生效於 unified 共用 eval）" % unarmed_loot)
	else:
		print("[unified] 無牙 unified 商隊 掠奪 util≈0 OK（同 solo 反向一致）")
	# 有牙 unified 商隊：掠奪 未被誤癱瘓（有本錢→util>0，可揮刀；grounding 對有牙透明=行為守恆）。
	if armed_loot <= unarmed_loot:
		_fails += 1
		print("[FAIL] 有牙 unified 商隊 掠奪 被誤癱瘓（armed=%.3f ≤ unarmed=%.3f）" % [armed_loot, unarmed_loot])
	else:
		print("[unified] 有牙 unified 商隊 掠奪 util>0 未癱瘓 OK（capability 對有牙透明）")
	# 有牙 unified 商隊健康有貨 → 貿易本業 option 仍在 rank（非因 grounding 全走劫掠）。
	var armed_opts: Array = _merchant_rank_opts(0.6)
	if "貿易" in armed_opts:
		print("[unified] 有牙 unified 商隊 貿易本業 option 仍在 rank OK: %s" % str(armed_opts))
	else:
		_fails += 1
		print("[FAIL] 有牙 unified 商隊 貿易 option 消失（本業失守，ranked=%s）" % str(armed_opts))

func _build_merchant(armed_ratio: float) -> Array:
	var state := WorldState.new(); state.world = WorldData.new()
	for px in [5, 6, 7]:   # reachability 路格 (5,5)-(7,5)
		var pt := HexTileData.new()
		pt.tile_id = px * 1000 + 5; pt.tile_pos = Vector2i(px, 5); pt.terrain = "plains"
		state.world.tiles[pt.tile_id] = pt
	var tid := 700
	var t := TeamData.new(); t.team_id = tid; t.tags = [TeamData.TAG_MERCHANT]
	t.tile_pos = Vector2i(5, 5); t.leader_id = tid * 10; t.faction_id = -1
	AnonTierSystem.add_anon(t, "平民", 12); t.armed_anon_ratio = armed_ratio
	t.resources = {"food": 400.0, "goods": 50.0, "coin": 100.0}   # 健康有貨（貿易本業）
	state.teams[tid] = t
	state.team_discovered[tid] = []
	state.team_intel[tid] = {}
	var ldr := PersonData.new(); ldr.id = tid * 10; ldr.team_id = tid
	ldr.values = {"貪婪": 0.7, "好戰": 0.3, "殘忍": 0.5, "野心": 0.4, "慎重": 0.4}
	state.persons[ldr.id] = ldr
	# 弱 prey + belief（G3：有情報才可掠奪）；非逼近 → 不觸威脅 option。
	var pid := 701
	var p := TeamData.new(); p.team_id = pid; p.tile_pos = Vector2i(7, 5); p.faction_id = -1
	p.last_tile_pos = p.tile_pos
	AnonTierSystem.add_anon(p, "平民", 3)
	state.teams[pid] = p
	state.team_discovered[tid].append(pid)
	BeliefSystem.record_claim(state, tid, pid, tid, "親見", {"population_est": 3, "armed_est": 1}, 1.0, false)
	return [state, t]

func _merchant_loot_util(armed_ratio: float) -> float:
	var pair: Array = _build_merchant(armed_ratio)
	for e in DecisionEngine.rank_scored(pair[0], pair[1]):
		if String(e["opt"]) == "掠奪": return float(e["u"])
	return 0.0   # 掠奪 不 applicable/不在 rank → 視為 0

func _merchant_rank_opts(armed_ratio: float) -> Array:
	var pair: Array = _build_merchant(armed_ratio)
	var out: Array = []
	for e in DecisionEngine.rank_scored(pair[0], pair[1]): out.append(e["opt"])
	return out
